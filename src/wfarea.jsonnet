local playableCharacters = import './playable_characters.jsonnet';

local KEYS = ['DevNicknames', 'SkillRange'];

[{[key]: char[key] for key in KEYS} for char in playableCharacters]
