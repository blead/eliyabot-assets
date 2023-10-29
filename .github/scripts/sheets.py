from google.oauth2 import service_account
from googleapiclient.discovery import build
import json
import logging
import os

SERVICE_ACCOUNT_INFO = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
SPREADSHEET_ID = os.environ.get("SPREADSHEET_ID")
CHARS_JSON = os.environ.get("CHARS_JSON", "processed/playable_characters.json")
EQUIPS_JSON = os.environ.get("EQUIPS_JSON", "processed/playable_equipments.json")

ATTRIBUTE_EN_TO_JP = {
    "Fire": "火",
    "Water": "水",
    "Wind": "風",
    "Thunder": "雷",
    "Light": "光",
    "Dark": "闇",
    "All": "全",
}


def read_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def init_sheet(service_account_info):
    creds = service_account.Credentials.from_service_account_info(
        json.loads(service_account_info)
    )
    return build(
        "sheets",
        "v4",
        credentials=creds.with_scopes(["https://www.googleapis.com/auth/spreadsheets"]),
        cache_discovery=False,
    ).spreadsheets()


def get_sheet_map(sheet, spreadsheetId):
    req = sheet.get(spreadsheetId=spreadsheetId)
    req.uri += "&fields=sheets(properties(sheetId,title))"
    res = req.execute().get("sheets", [])
    return {sh["properties"]["title"]: sh["properties"]["sheetId"] for sh in res}


def get_ranges(sheet, spreadsheetId, ranges):
    res = (
        sheet.values()
        .batchGet(
            spreadsheetId=spreadsheetId, ranges=ranges, valueRenderOption="FORMULA"
        )
        .execute()
    )
    return res.get("valueRanges", [])


def update_ranges(sheet, spreadsheetId, data):
    res = (
        sheet.values()
        .batchUpdate(
            spreadsheetId=spreadsheetId,
            body={"data": data, "valueInputOption": "USER_ENTERED"},
        )
        .execute()
    )
    logging.info(f"UPDATE:Updated {res.get('totalUpdatedCells', 0)} cells")


def append_ranges(sheet, spreadsheetId, range, values):
    res = (
        sheet.values()
        .append(
            spreadsheetId=spreadsheetId,
            range=range,
            valueInputOption="USER_ENTERED",
            body={"values": values},
        )
        .execute()
    )
    logging.info(f"APPEND:Appended {res.get('updates', {}).get('updatedRows', 0)} rows")


# insertions: [(rowidx: int, row: [col: str])]
def insert_rows(sheet, spreadsheetId, sheetId, insertions):
    sheet.batchUpdate(
        spreadsheetId=spreadsheetId,
        body={
            "includeSpreadsheetInResponse": False,
            "requests": [
                {
                    "insertDimension": {
                        "inheritFromBefore": True,
                        "range": {
                            "sheetId": sheetId,
                            "dimension": "ROWS",
                            "startIndex": rowidx,
                            "endIndex": rowidx + 1,
                        },
                    }
                }
                for rowidx, _ in insertions
            ]
            + [
                {
                    "updateCells": {
                        "rows": [
                            {
                                "values": [
                                    {"userEnteredValue": build_user_entered_value(col)}
                                    for col in row
                                ]
                            }
                        ],
                        "fields": "userEnteredValue",
                        "start": {
                            "sheetId": sheetId,
                            "rowIndex": rowidx,
                            "columnIndex": 0,
                        },
                    }
                }
                for rowidx, row in insertions
            ],
        },
    ).execute()
    logging.info(f"INSERT:Inserted {len(insertions)} rows")


def build_user_entered_value(col):
    match col:
        case bool():
            return {"boolValue": col}
        case int() | float():
            return {"numberValue": col}
        case str() if col.startswith("="):
            return {"formulaValue": col}
        case _:
            return {"stringValue": col}


def build_char_row(rowidx, char, cols):
    devname_idx = next(i for i, col in enumerate(cols) if col == "Dev Nicknames")
    row = []
    for col in cols:
        match col:
            case "Character" | "Picture":
                row.append(
                    f'=IMAGE(CONCATENATE("https://eliya-bot.herokuapp.com/img/assets/chars/",{chr(ord("A")+devname_idx)}{rowidx+1},"/full_shot_0.png"))'
                )
            case "Attribute":
                row.append(ATTRIBUTE_EN_TO_JP[char["Attribute"]])
            case "Notes":
                row.append("(auto-generated)")
            case _:
                col_without_spaces = col.replace(" ", "")
                if col_without_spaces in char:
                    row.append(char[col_without_spaces])
                else:
                    row.append("")
    return row


def build_equip_row(rowidx, equip, cols):
    devname_idx = next(i for i, col in enumerate(cols) if col == "Dev Nicknames")
    row = []
    for col in cols:
        match col:
            case "Picture":
                row.append(
                    f'=IMAGE(CONCATENATE("https://eliya-bot.herokuapp.com/img/assets/item/equipment/",{chr(ord("A")+devname_idx)}{rowidx+1},".png"))'
                )
            case "Rarity":
                row.append(f"{equip['Rarity']}*")
            case "Boss" | "Notes":
                row.append("(auto-generated)")
            case _:
                col_without_spaces = col.replace(" ", "")
                if col_without_spaces in equip:
                    row.append(equip[col_without_spaces])
                else:
                    row.append("")
    return row


def update_chars(sheet, spreadsheet_id):
    CHAR_RANGES = [
        "'5* Characters'!A1:Z300",
        "'4* Characters'!A1:Z300",
        "'3* Characters'!A1:Z300",
        "'1*/2* Characters'!A1:Z300",
    ]

    chars = read_json(CHARS_JSON)
    devname_to_char = {char["DevNicknames"]: char for char in chars}
    ranges = get_ranges(sheet, spreadsheet_id, CHAR_RANGES)

    # (rarity, attribute) -> (sheetname, rownum of last char in section)
    insertion_idx = {}
    sheet_name_to_cols = {}

    updated_ranges = []

    for range in ranges:
        sheet_name = range["range"].split("!")[0].strip("'")
        rows = range["values"]
        cols = rows[0]
        sheet_name_to_cols[sheet_name] = cols

        for rownum, row in enumerate(rows[1:], 2):
            try:
                if len(row) < len(cols):
                    row += [""] * (len(cols) - len(row))

                devname = row[
                    next(i for i, col in enumerate(cols) if col == "Dev Nicknames")
                ]

                if devname and devname in devname_to_char:
                    insertion_idx[
                        (
                            devname_to_char[devname]["Rarity"],
                            devname_to_char[devname]["Attribute"],
                        )
                    ] = (sheet_name, rownum)
                    updated_cols = []
                    notesidx = next(i for i, col in enumerate(cols) if col == "Notes")

                    for colidx, col in enumerate(cols):
                        col_without_spaces = col.replace(" ", "")
                        if (
                            col_without_spaces in devname_to_char[devname] and (
                                row[colidx] == "" or (
                                    row[notesidx] == "(auto-generated)"
                                    and row[colidx] != devname_to_char[devname][col_without_spaces]
                                )
                            )
                        ):
                            updated_value = devname_to_char[devname][col_without_spaces]
                            if col_without_spaces == "Attribute":
                                updated_value = ATTRIBUTE_EN_TO_JP[updated_value]
                            updated_ranges.append(
                                {
                                    "range": f"'{sheet_name}'!{chr(ord('A')+colidx)}{rownum}",
                                    "values": [[updated_value]],
                                }
                            )
                            updated_cols.append(col_without_spaces)

                    if updated_cols:
                        logging.info(f"UPDATE:{devname}:{','.join(updated_cols)}")

                    devname_to_char.pop(devname)
            except Exception as e:
                logging.debug(row)
                raise e

    if updated_ranges:
        update_ranges(sheet, spreadsheet_id, updated_ranges)

    missing_chars = devname_to_char.values()
    if missing_chars:
        # sheetname -> (rowidx, char)
        insertion_sheets = {}
        for char in missing_chars:
            sheet_name, rowidx = insertion_idx[(char["Rarity"], char["Attribute"])]
            if sheet_name not in insertion_sheets:
                insertion_sheets[sheet_name] = []
            insertion_sheets[sheet_name].append((rowidx, char))

        sheet_name_to_id = get_sheet_map(sheet, spreadsheet_id)
        for sheet_name, insertion_chars in insertion_sheets.items():
            sheet_id = sheet_name_to_id[sheet_name]
            cols = sheet_name_to_cols[sheet_name]
            shifted_insertion_rows = [
                (
                    rowidx + i,
                    build_char_row(rowidx + i, char, cols),
                )
                for i, (rowidx, char) in enumerate(
                    sorted(insertion_chars, key=lambda x: x[0])
                )
            ]

            devname_idx = next(
                i for i, col in enumerate(cols) if col == "Dev Nicknames"
            )
            for idx, char in shifted_insertion_rows:
                logging.info(f"INSERT:{char[devname_idx]}:'{sheet_name}'!A{idx+1}")

            insert_rows(sheet, spreadsheet_id, sheet_id, shifted_insertion_rows)


def update_equips(sheet, spreadsheet_id):
    EQUIP_RANGES = [
        "'Gacha/Story Weapons'!A1:Z300",
        "'Boss/Event Weapons'!A1:Z300",
    ]

    equips = read_json(EQUIPS_JSON)
    devname_to_equip = {equip["DevNicknames"]: equip for equip in equips}
    ranges = get_ranges(sheet, spreadsheet_id, EQUIP_RANGES)

    last_range_cols = []
    last_idx = 0

    updated_ranges = []

    for range in ranges:
        sheet_name = range["range"].split("!")[0].strip("'")
        rows = range["values"]
        cols = rows[0]

        last_range_cols = cols
        last_idx = len(rows)

        for rownum, row in enumerate(rows[1:], 2):
            try:
                if len(row) < len(cols):
                    row += [""] * (len(cols) - len(row))

                devname = row[
                    next(i for i, col in enumerate(cols) if col == "Dev Nicknames")
                ]

                if devname and devname in devname_to_equip:
                    updated_cols = []
                    notesidx = next(i for i, col in enumerate(cols) if col == "Boss" or col == "Notes")

                    for colidx, col in enumerate(cols):
                        col_without_spaces = col.replace(" ", "")
                        if (
                            col_without_spaces in devname_to_equip[devname] and (
                                row[colidx] == "" or (
                                    row[notesidx] == "(auto-generated)"
                                    and row[colidx] != devname_to_equip[devname][col_without_spaces]
                                )
                            )
                        ):
                            updated_value = devname_to_equip[devname][
                                col_without_spaces
                            ]
                            if col_without_spaces == "Attribute":
                                updated_value = ATTRIBUTE_EN_TO_JP[updated_value]
                            updated_ranges.append(
                                {
                                    "range": f"'{sheet_name}'!{chr(ord('A')+colidx)}{rownum}",
                                    "values": [[updated_value]],
                                }
                            )
                            updated_cols.append(col_without_spaces)

                    if updated_cols:
                        logging.info(f"UPDATE:{devname}:{','.join(updated_cols)}")

                    devname_to_equip.pop(devname)
            except Exception as e:
                logging.debug(row)
                raise e

    if updated_ranges:
        update_ranges(sheet, spreadsheet_id, updated_ranges)

    missing_equips = devname_to_equip.values()
    if missing_equips:
        for i, equip in enumerate(missing_equips):
            logging.info(
                f"APPEND:{equip['DevNicknames']}:{ranges[-1]['range'].split('!')[0]}!A{last_idx+i}"
            )

        append_ranges(
            sheet,
            spreadsheet_id,
            ranges[-1]["range"],
            [
                build_equip_row(last_idx + i, equip, last_range_cols)
                for i, equip in enumerate(missing_equips)
            ],
        )


def main():
    logging.basicConfig(level=logging.INFO)

    sheet = init_sheet(SERVICE_ACCOUNT_INFO)
    update_chars(sheet, SPREADSHEET_ID)
    update_equips(sheet, SPREADSHEET_ID)


if __name__ == "__main__":
    main()
