import json
import re
import os

CHARS_JSON = os.environ.get("CHARS_JSON", "data/chars.json")
EQUIPS_JSON = os.environ.get("EQUIPS_JSON", "data/equips.json")
DEGREE_JSON = os.environ.get("DEGREE_JSON", "json/degree/degree.json")
PLAYABLE_CHARS_JSON = os.environ.get(
    "PLAYABLE_CHARS_JSON", "processed/playable_chars.json"
)
PLAYABLE_EQUIPS_JSON = os.environ.get(
    "PLAYABLE_EQUIPS_JSON", "processed/playable_equips.json"
)


def filter_chars():
    with open(CHARS_JSON, encoding="utf-8") as chars_json, open(
        DEGREE_JSON, encoding="utf-8"
    ) as degree_json, open(
        PLAYABLE_CHARS_JSON, "w", encoding="utf-8"
    ) as playable_chars_json:
        chars = json.load(chars_json)
        degrees = json.load(degree_json)
        pattern = re.compile("^degree_favor_(?!.*_2$).*$")

        playable = {
            degree[0][0]
            for degree in degrees.values()
            if pattern.fullmatch(degree[0][0])
        }

        json.dump(
            [
                char
                for char in chars
                if f'degree_favor_{char["DevNicknames"]}' in playable
                or f'degree_favor_{char["DevNicknames"].removesuffix("_playable")}'
                in playable
            ],
            playable_chars_json,
            ensure_ascii=False,
            separators=(",", ":"),
        )


def filter_equips():
    with open(EQUIPS_JSON, encoding="utf-8") as equips_json, open(
        PLAYABLE_EQUIPS_JSON, "w", encoding="utf-8"
    ) as playable_equips_json:
        equips = json.load(equips_json)
        json.dump(
            [
                equip
                for equip in equips
                if not equip["DevNicknames"].startswith("non_playable_equipment_")
            ],
            playable_equips_json,
            ensure_ascii=False,
            separators=(",", ":"),
        )


def main():
    filter_chars()
    filter_equips()


if __name__ == "__main__":
    main()
