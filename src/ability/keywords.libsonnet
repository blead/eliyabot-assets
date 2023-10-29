local RACE_MAP = {
  ',': ' / ',
  Mystery: 'Youkai',
  Element: 'Sprite',
  Machine: 'Mecha',
  Plants: 'Plant',
  Devil: 'Demon',
};

local ELEMENT_MAP = {
  Red: 'Fire',
  Blue: 'Water',
  Yellow: 'Thunder',
  Green: 'Wind',
  White: 'Light',
  Black: 'Dark',
  '(None)': 'party',
};

local TRIGGER_TARGET_MAP = {
  '0': 'self',
  '1': 'leader',
  '2': 'second character',
  '3': 'third character',
  '4': 'another %(type)s character',
  '5': 'a %(type)s character',
  '6': self['4'],
  '7': self['5'],
  '8': 'that character',
};

local TRIGGER_TARGET_POSSESSIVE_MAP = {
  '0': 'own',
  '1': "leader's",
  '2': "second character's",
  '3': "third character's",
  '4': "another %(type)s character's",
  '5': "a %(type)s character's",
  '6': self['4'],
  '7': self['5'],
  '8': "that character's",
};

local CONTENT_TARGET_MAP = {
  '0': 'self',
  '1': 'other %(type)s characters',
  '2': 'leader',
  '4': 'third character',
  '5': '%(type)s characters',
  // this changes to 'that multiball' when used with trigger target id=10; workaround done in duringContent
  '7': 'that character',
  '8': 'multiballs',
  '10': 'party character with the lowest HP',
  '14': '%(type)s multiballs',
};

local CONTENT_TARGET_POSSESSIVE_MAP = {
  '0': 'own',
  '1': "other %(type)s characters'",
  '2': "leader's",
  '4': "third character's",
  '5': "%(type)s characters'",
  '7': "that character's",
  '8': "multiballs'",
  '10': "party character with the lowest HP's",
  '14': "%(type)s multiballs'",
};

local DURING_TRIGGER_TARGET_MAP = TRIGGER_TARGET_MAP {
  '7': 'every %(type)s character',
  '9': 'every %(type)s character',
  '10': 'a %(type)s multiball',
};

local DURING_TRIGGER_TARGET_POSSESSIVE_MAP = TRIGGER_TARGET_POSSESSIVE_MAP {
  '7': "all %(type)s characters'",
  '9': "%(type)s characters' total",
  '10': "a %(type)s multiball's",
};

{
  race(keyword)::
    std.foldl(
      function(a, b) std.strReplace(a, b.key, b.value),
      std.objectKeysValues(RACE_MAP),
      keyword,
    ),
  element(keyword)::
    std.foldl(
      function(a, b) std.strReplace(a, b.key, b.value),
      std.objectKeysValues(ELEMENT_MAP),
      keyword,
    ),
  type(keyword):: self.race(self.element(keyword)),
  target(keyword):: if keyword in TRIGGER_TARGET_MAP then TRIGGER_TARGET_MAP[keyword] else '<target: %s>' % keyword,
  targetP(keyword):: if keyword in TRIGGER_TARGET_POSSESSIVE_MAP then TRIGGER_TARGET_POSSESSIVE_MAP[keyword] else '<targetP: %s>' % keyword,
  duringTarget(keyword):: if keyword in DURING_TRIGGER_TARGET_MAP then DURING_TRIGGER_TARGET_MAP[keyword] else '<duringTarget: %s>' % keyword,
  duringTargetP(keyword):: if keyword in DURING_TRIGGER_TARGET_POSSESSIVE_MAP then DURING_TRIGGER_TARGET_POSSESSIVE_MAP[keyword] else '<duringTargetP: %s>' % keyword,
  contentTarget(keyword):: if keyword in CONTENT_TARGET_MAP then CONTENT_TARGET_MAP[keyword] else '<contentTarget: %s>' % keyword,
  contentTargetP(keyword):: if keyword in CONTENT_TARGET_POSSESSIVE_MAP then CONTENT_TARGET_POSSESSIVE_MAP[keyword] else '<contentTargetP: %s>' % keyword,
}
