import json
import re
import os

PLAYABLE_CHARS_JSON = os.environ.get(
    "PLAYABLE_CHARS_JSON", "processed/playable_chars.json"
)
WFAREA_JSON = os.environ.get("WFAREA_JSON", "processed/wfarea.json")

KEYS = ["DevNicknames", "SkillRange"]


def main():
    with open(PLAYABLE_CHARS_JSON, encoding="utf-8") as playable_chars_json, open(
        WFAREA_JSON, "w", encoding="utf-8"
    ) as wfarea_json:
        chars = json.load(playable_chars_json)

        json.dump(
            [{key: char[key] for key in KEYS} for char in chars],
            wfarea_json,
            ensure_ascii=False,
            separators=(",", ":"),
        )


if __name__ == "__main__":
    main()
