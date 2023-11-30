local keywords = import './keywords.libsonnet';
local multiballGroups = import './multiball_groups.libsonnet';
local whenBattleBegins = import './when_battle_begins.json';

local everyTime(count) = if count == '1' then 'when ' else 'every %s times ' % count;

{
  mode:: 'max',
  index(index=25, mode='max')::
    self {
      mode:: mode,
      parse:: function(abi) super.parse(abi[index:]),
    },

  parse(abi)::
    if abi[0] in self then self[abi[0]](abi[:21])
    else '<instant trigger %s not defined> ' % abi[0],

  map(abi, divisor=100000):: {
    local this = self,
    target: keywords.target(abi[1]) % { type: this.targetType },
    targetP: keywords.targetP(abi[1]) % { type: this.targetType },
    targetType: keywords.type(abi[2]),
    minValue: if abi[3] != '' then std.parseInt(abi[3]) / divisor,
    value: if abi[4] != '' then std.parseInt(abi[4]) / divisor,
    valueStr:
      if $.mode == 'min' then '%g' % self.minValue
      else if $.mode == 'max' || self.minValue == self.value then '%g' % self.value
      else '%g ➝ %g' % [self.minValue, self.value],
    minValue2: if abi[5] != '' then std.parseInt(abi[5]) / divisor,
    value2: if abi[6] != '' then std.parseInt(abi[6]) / divisor,
    value2Str:
      if $.mode == 'min' then '%g' % self.minValue2
      else if $.mode == 'max' || self.minValue2 == self.value2 then '%g' % self.value2
      else '%g ➝ %g' % [self.minValue2, self.value2],
    rampTimes: if abi[7] != '' && abi[7] != '(None)' then std.parseInt(abi[7]) else 0,
    checkType: keywords.type(abi[9]),
    multiballGroup: if abi[11] in multiballGroups then multiballGroups[abi[11]].name else '<multiballGroup: %s>' % abi[11],
    instantContent: abi[20],
  },

  '':: function(abi) '',
  '(None)':: self[''],
  '0':: function(abi) if std.setMember(self.map(abi).instantContent, whenBattleBegins) then 'when battle begins, ' else '',
  '2':: function(abi)
    if self.map(abi).valueStr == '1' then 'every power flip, '
    else 'every %(valueStr)s power flips, ' % self.map(abi),
  '3':: function(abi)
    if self.map(abi).valueStr == '1' then 'every dash, '
    else 'every %(valueStr)s dashes, ' % self.map(abi),
  '4':: function(abi)
    if self.map(abi).valueStr == '1' then 'every ball flip, '
    else 'every %(valueStr)s ball flips, ' % self.map(abi),
  '5':: function(abi)
    if self.map(abi).valueStr == '1' then 'when entering fever, '
    else 'every %(valueStr)s fevers, ' % self.map(abi),
  '6':: function(abi) everyTime(self.map(abi).valueStr) + 'a multiball appears, ',
  '7':: function(abi)
    if self.map(abi).valueStr == '1' then 'every enemy defeated, '
    else 'every %(valueStr)s enemies defeated, ' % self.map(abi),
  '8':: function(abi) 'every %(valueStr)s combo, ' % self.map(abi),
  '9':: function(abi) 'when a ball flip occurs above %(valueStr)s combo, ' % self.map(abi),
  '11':: function(abi)
    if self.map(abi).valueStr == '1' then 'every power flip hit, '
    else 'every %(valueStr)s power flip hits, ' % self.map(abi),
  '14':: function(abi) everyTime(self.map(abi).valueStr) + '%(target)s is revived, ' % self.map(abi),
  '15':: function(abi) everyTime(self.map(abi).valueStr) + '%(target)s recovers HP, ' % self.map(abi),
  '16':: function(abi) (
    if self.map(abi).valueStr == '1' then 'every direct attack by %(target)s, '
    else 'every %(valueStr)s direct attacks by %(target)s, '
  ) % self.map(abi),
  '17':: function(abi) everyTime(self.map(abi).valueStr) + '%(target)s receives damage, ' % self.map(abi),
  '19':: function(abi) everyTime(self.map(abi).valueStr) + '%(targetP)s skill activates, ' % self.map(abi),
  '20':: function(abi) everyTime(self.map(abi).valueStr) + '%(targetP)s skill gauge reaches %(valueStr)s%%, ' % self.map(abi, divisor=1000),
  '21':: function(abi) 'when %(targetP)s HP falls to or below %(valueStr)s%%, ' % self.map(abi, divisor=1000),
  '22':: function(abi)
    if self.map(abi).valueStr == '1' then 'every flip, '
    else 'every %(valueStr)s flips, ' % self.map(abi),
  '24':: function(abi) everyTime(self.map(abi).valueStr) + '%(target)s receives a debuff, ' % self.map(abi),
  '25':: function(abi) everyTime(self.map(abi).valueStr) + '%(target)s gains a buff, ' % self.map(abi),
  '26':: function(abi) everyTime(self.map(abi).valueStr) + '%(target)s gains an ATK buff, ' % self.map(abi),
  '47':: function(abi) everyTime(self.map(abi).valueStr) + 'party gains penetration buff, ',
  '48':: function(abi) everyTime(self.map(abi).valueStr) + 'party gains float buff, ',
  '49':: function(abi) everyTime(self.map(abi).valueStr) + 'party gains power flip damage buff, ',
  '53':: function(abi) (
    if self.map(abi).valueStr == '6' then 'Resonance [%(checkType)s], '
    else if self.map(abi).rampTimes <= 1 then 'if there are %(valueStr)s or more %(checkType)s characters in the party, '
    else if self.map(abi).valueStr == '1' then 'for every %(checkType)s character in the party, '
    else 'for every %(valueStr)s %(checkType)s characters in the party, '
  ) % self.map(abi),
  '54':: function(abi) 'if self is a %(checkType)s character, ' % self.map(abi),
  '56':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'if there are %(valueStr)s or more elements among party members, '
    else if self.map(abi).valueStr == '1' then 'for every element among party members, '
    else 'for every %(valueStr)s elements among party members, '
  ) % self.map(abi),
  '57':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'if there are %(valueStr)s or more races among party members, '
    else if self.map(abi).valueStr == '1' then 'for every race among party members, '
    else 'for every %(valueStr)s races among party members, '
  ) % self.map(abi),
  '59':: function(abi)
    if self.map(abi).valueStr == '1' then 'every Lv1 power flip, '
    else 'every %(valueStr)s Lv1 power flips, ' % self.map(abi),
  '60':: function(abi)
    if self.map(abi).valueStr == '1' then 'every Lv2 power flip, '
    else 'every %(valueStr)s Lv2 power flips, ' % self.map(abi),
  '61':: function(abi)
    if self.map(abi).valueStr == '1' then 'every Lv3 power flip, '
    else 'every %(valueStr)s Lv3 power flips, ' % self.map(abi),
  '62':: function(abi) 'if self is leader, ',
  '66':: function(abi) 'upon reaching %(valueStr)s combo, ' % self.map(abi),
  '67':: function(abi) 'if leader is a %(checkType)s character, ' % self.map(abi),
  '72':: function(abi) everyTime(self.map(abi).valueStr) + 'fever gauge is increased by abilities, ',
  '73':: function(abi)
    if self.map(abi).valueStr == '1' then 'every 1 second, '
    else 'every %(valueStr)s seconds, ' % self.map(abi, divisor=6000000),
  '74':: function(abi) 'when %(target)s recovers %(valueStr)s HP or above at once, ' % self.map(abi),
  // 敵がマヒ・スタン効果になる度
  '98':: function(abi) everyTime(self.map(abi).valueStr) + 'an enemy gets paralyze/stun debuff, ',
  '103':: function(abi) everyTime(self.map(abi).valueStr) + '%(targetP)s skill hits, ' % self.map(abi),
  // 敵が1体マヒ・スタン効果になる度
  '127':: self['98'],
  '133':: function(abi) everyTime(self.map(abi).valueStr) + '%(target)s receives barrier, ' % self.map(abi),
  '134':: function(abi) everyTime(self.map(abi).valueStr) + '%(target)s direct attacks an enemy, ' % self.map(abi),
  '135':: function(abi) everyTime(self.map(abi).valueStr) + '%(target)s becomes a coffin, ' % self.map(abi),
  '137':: function(abi) everyTime(self.map(abi).valueStr) + '%(targetP)s skill gauge is increased by an ability or skill' % self.map(abi),
  '139':: function(abi) everyTime(self.map(abi).valueStr) + '%(targetP)s ability deals damage, ' % self.map(abi),
  '140':: function(abi) everyTime(self.map(abi).valueStr) + '%(targetP)s damage ability activates, ' % self.map(abi),
  '180':: function(abi) everyTime(self.map(abi).valueStr) + 'fever ends, ',
  '182':: function(abi)
    if self.map(abi).valueStr == '1' then 'every consecutive power flip, '
    else 'every %(valueStr)s consecutive power flips, ' % self.map(abi),
  '192':: function(abi) everyTime(self.map(abi).valueStr) + '[%(multiballGroup)s] disappears, ' % self.map(abi),
  '193':: function(abi) everyTime(self.map(abi).valueStr) + '%(target)s bumps into an enemy, ' % self.map(abi),
  '194':: function(abi)
    if self.map(abi).checkType == 'tag_megumin' then 'if self is the unison character to [Megumin], '
    else 'if self is the unison character to a %(checkType)s character, ' % self.map(abi),
  '231':: function(abi)
    if self.map(abi).value2Str == '1' then 'every 1 second of penetration buff, '
    else 'every %(value2Str)s seconds of penetration buff, ' % self.map(abi, divisor=6000000),
  '232':: function(abi)
    if self.map(abi).value2Str == '1' then 'every 1 second of float buff, '
    else 'every %(value2Str)s seconds of float buff, ' % self.map(abi, divisor=6000000),
  '244':: function(abi)
    if self.map(abi).valueStr == '1' then 'every 1 second of fever, '
    else 'every %(valueStr)s seconds of fever, ' % self.map(abi, divisor=6000000),
  '251':: function(abi) 'upon reaching %(valueStr)s combo %(value2Str)s times, ' % self.map(abi),
  '253':: function(abi) (
    if self.map(abi).valueStr == '6' then 'Resonance [Any], '
    else if self.map(abi).rampTimes <= 1 then 'if there are %(valueStr)s or more characters with the same element in the party, '
    else if self.map(abi).valueStr == '1' then 'for every character with the same element in the party, '
    else 'for every %(valueStr)s characters with the same element in the party, '
  ) % self.map(abi),
  '256':: function(abi)
    if self.map(abi).valueStr == '1' then 'every Lv1 or Lv2 power flip, '
    else 'every %(valueStr)s Lv1 or Lv2 power flips, ' % self.map(abi),
  '257':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'when battle begins, if %(target)s exceeds its max skill gauge by %(valueStr)s%%, '
    else 'when battle begins, for every %(valueStr)s%% skill gauge by which %(target)s exceeds its max skill gauge, '
  ) % self.map(abi, divisor=1000),
}
