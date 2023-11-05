local keywords = import './keywords.libsonnet';
local uniqueCondition = import './unique_condition.libsonnet';
local utils = import './utils.libsonnet';

{
  mode:: 'max',
  index(index=92, mode='max')::
    self {
      mode:: mode,
      parse:: function(abi) super.parse(abi[index:]),
    },

  parse(abi)::
    if abi[0] in self then self[abi[0]](abi[:10])
    else '<during trigger %s not defined> ' % abi[0],

  map(abi, divisor=100000):: {
    local this = self,
    target: keywords.duringTarget(abi[1]) % { type: this.targetType },
    targetP: keywords.duringTargetP(abi[1]) % { type: this.targetType },
    targetType: keywords.type(abi[2]),
    minValue: if abi[3] != '' then (std.parseInt(abi[3]) / divisor),
    value: if abi[4] != '' then (std.parseInt(abi[4]) / divisor),
    valueStr: if self.minValue != null && self.value != null then (
      if $.mode == 'min' then utils.formatZero(self.minValue)
      else if $.mode == 'max' || self.minValue == self.value then utils.formatZero(self.value)
      else '[%s ➝ %s]' % [utils.formatZero(self.minValue), utils.formatZero(self.value)]
    ),
    rampTimes: if abi[5] != '' && abi[5] != '(None)' then std.parseInt(abi[5]) else 0,
    checkType: keywords.type(abi[6]),
    minValue2: if abi[8] != '' then (std.parseInt(abi[8]) / divisor),
    value2: if abi[9] != '' then (std.parseInt(abi[9]) / divisor),
    value2Str: if self.minValue2 != null && self.value2 != null then (
      if $.mode == 'min' then utils.formatZero(self.minValue2)
      else if $.mode == 'max' || self.minValue2 == self.value2 then utils.formatZero(self.value2)
      else '[%s ➝ %s]' % [utils.formatZero(self.minValue2), utils.formatZero(self.value2)]
    ),
  } + uniqueCondition.mixin(abi[7]),

  '':: function(abi) '',
  '0':: function(abi) 'while %(targetP)s HP is at or above %(valueStr)s%%, ' % self.map(abi, divisor=1000),
  // TODO: does smarg abi3 work with just one party member<=50%? see if we have to override targetid 6
  // ["1","6","(None)","50000","50000","","","","","","","false"]
  '1':: function(abi) 'while %(targetP)s HP is at or below %(valueStr)s%%, ' % self.map(abi, divisor=1000),
  '2':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while combo count is at or above %(valueStr)s, '
    else if self.map(abi).valueStr == '1' then 'for every combo, '
    else 'for every %(valueStr)s combo, '
  ) % self.map(abi),
  '4':: function(abi) 'while in fever, ',
  '5':: function(abi) 'while %(valueStr)s or more multiballs are present, ' % self.map(abi),
  '8':: function(abi) 'while %(target)s has a buff, ' % self.map(abi),
  '7':: function(abi) 'while %(target)s has a debuff, ' % self.map(abi),
  '9':: function(abi) 'while %(target)s has ATK buff, ' % self.map(abi),
  '11':: function(abi) 'while %(target)s has skill damage buff, ' % self.map(abi),
  '17':: function(abi) 'while %(target)s has regeneration buff, ' % self.map(abi),
  '27':: function(abi) 'while %(target)s has break/down punisher buff, ' % self.map(abi),
  '30':: function(abi) 'while penetration buff is active, ',
  '31':: function(abi) 'while float buff is active, ',
  '32':: function(abi) 'while power flip damage buff is active, ',
  '36':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while %(target)s has %(valueStr)s or more debuffs, '
    else if self.map(abi).valueStr == '1' then 'for every debuff on %(target)s, '
    else 'for every %(valueStr)s debuffs on %(target)s, '
  ) % self.map(abi),
  '37':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while %(target)s has %(valueStr)s or more buffs, '
    else if self.map(abi).valueStr == '1' then 'for every buff on %(target)s, '
    else 'for every %(valueStr)s buffs on %(target)s, '
  ) % self.map(abi),
  '38':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while %(target)s has %(valueStr)s or more ATK buffs, '
    else if self.map(abi).valueStr == '1' then 'for every ATK buff on %(target)s, '
    else 'for every %(valueStr)s ATK buffs on %(target)s, '
  ) % self.map(abi),
  '40':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while %(target)s has %(valueStr)s or more skill damage buffs, '
    else if self.map(abi).valueStr == '1' then 'for every skill damage buff on %(target)s, '
    else 'for every %(valueStr)s skill damage buffs on %(target)s, '
  ) % self.map(abi),
  '62':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while there are %(valueStr)s or more power flip damage buffs, '
    else if self.map(abi).valueStr == '1' then 'for every power flip damage buffs, '
    else 'for every %(valueStr)s power flip damage buffs, '
  ) % self.map(abi),
  '64':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while %(valueStr)s or more enemies are present, '
    else if self.map(abi).valueStr == '1' then 'for every enemy present, '
    else 'for every %(valueStr)s enemies present, '
  ) % self.map(abi),
  '72':: function(abi) 'while %(target)s has barrier, ' % self.map(abi),
  // TODO: does sneph abi2 work with passive multi-hit instead of a buff?
  '73':: function(abi) 'while %(target)s has multi-hit, ' % self.map(abi),
  '75':: function(abi) 'while %(targetP)s ATK is at or above +%(valueStr)s%%, ' % self.map(abi, divisor=1000),
  '80':: function(abi) 'while %(targetP)s fire resistance is at or above +%(valueStr)s%%, ' % self.map(abi, divisor=1000),
  '81':: function(abi) 'while %(targetP)s water resistance is at or above +%(valueStr)s%%, ' % self.map(abi, divisor=1000),
  '82':: function(abi) 'while %(targetP)s thunder resistance is at or above +%(valueStr)s%%, ' % self.map(abi, divisor=1000),
  '83':: function(abi) 'while %(targetP)s wind resistance is at or above +%(valueStr)s%%, ' % self.map(abi, divisor=1000),
  '84':: function(abi) 'while %(targetP)s light resistance is at or above +%(valueStr)s%%, ' % self.map(abi, divisor=1000),
  '85':: function(abi) 'while %(targetP)s dark resistance is at or above +%(valueStr)s%%, ' % self.map(abi, divisor=1000),
  '91':: function(abi) 'while power flip damage is at or above +%(valueStr)s%%, ' % self.map(abi, divisor=1000),
  '104':: function(abi) 'while speed buff is active, ',
  '107':: function(abi) 'while %(targetP)s skill gauge is at or above %(valueStr)s%%, ' % self.map(abi, divisor=1000),
  '109':: function(abi) (
    'for every %(valueStr)s%% of %(targetP)s HP remaining'
    + (if self.map(abi, divisor=1000).value2Str != '0' then ' above %(value2Str)s%% HP, ' else ', ')
  ) % self.map(abi, divisor=1000),
  '110':: function(abi) (
    'for every %(valueStr)s%% of %(targetP)s HP missing'
    + (if self.map(abi, divisor=1000).value2Str != '100' then ' below %(value2Str)s%% HP, ' else ', ')
  ) % self.map(abi, divisor=1000),
  '134':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while %(target)s has %(valueStr)s or more levels of [%(ucName)s], '
    else if self.map(abi).valueStr == '1' then 'for every level of [%(ucName)s] on %(target)s, '
    else 'for every %(valueStr)s levels of [%(ucName)s] on %(target)s, '
  ) % self.map(abi),
  '136':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while there are %(valueStr)s or more debuffs on an enemy, '
    else if self.map(abi).valueStr == '1' then 'for every debuff on an enemy, '
    else 'for every %(valueStr)s debuffs on an enemy, '
  ) % self.map(abi),
  // this is hard to word the second part without knowledge of the first?
  '152':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while there are %(valueStr)s or more light resistance debuffs on an enemy, '
    else if self.map(abi).valueStr == '1' then 'for every light resistance debuff on an enemy, '
    else 'for every %(valueStr)s light resistance debuffs on an enemy, '
  ) % self.map(abi),
  '178':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while %(target)s has %(valueStr)s or more Adversity buffs, '
    else if self.map(abi).valueStr == '1' then 'for every Adversity buff on %(target)s, '
    else 'for every %(valueStr)s Adversity buffs on %(target)s, '
  ) % self.map(abi),
  '187':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while %(target)s has %(valueStr)s or more water resistance buffs, '
    else if self.map(abi).valueStr == '1' then 'for every water resistance buff on %(target)s, '
    else 'for every %(valueStr)s water resistance buffs on %(target)s, '
  ) % self.map(abi),
  '192':: function(abi) 'against enemies with [%(ucName)s], ' % self.map(abi),
  '194':: self['134'],
  '195':: function(abi) 'while performing consecutive power flips, for every power flip after the first, ',
  '203':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while %(targetP)s skill damage is at or above +%(valueStr)s%%, '
    else 'for every +%(valueStr)s%% of %(targetP)s skill damage, '
  ) % self.map(abi, divisor=1000),
  '204':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while %(targetP)s direct attack damage is at or above +%(valueStr)s%%, '
    else 'for every +%(valueStr)s%% of %(targetP)s direct attack damage, '
  ) % self.map(abi, divisor=1000),
  '207':: function(abi) 'if [%(ucName)s] is not active, ' % self.map(abi),
  '208':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while %(valueStr)s or more Dark multiballs are present, '
    else if self.map(abi).valueStr == '1' then 'for every Dark multiball present, '
    else 'for every %(valueStr)s Dark multiballs present, '
  ) % self.map(abi),
  '209':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while %(valueStr)s or more %(checkType)s multiballs are present, '
    else if self.map(abi).valueStr == '1' then 'for every %(checkType)s multiball present, '
    else 'for every %(valueStr)s %(checkType)s multiballs present, '
  ) % self.map(abi),
  '210':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'while %(valueStr)s or more coffins are present, '
    else if self.map(abi).valueStr == '1' then 'for every coffin present, '
    else 'for every %(valueStr)s coffins present, '
  ) % self.map(abi),
  // 闇属性キャラ全員の棺桶からの復帰回数が 6 回以上の間、
  '213':: function(abi) 'when %(targetP)s revival count is %(valueStr)s or more, ' % self.map(abi),
  '214':: function(abi) 'while max movement speed buff is active, ',
  '227':: function(abi) 'while %(targetP)s HP is below %(valueStr)s%%, ' % self.map(abi, divisor=1000),
}
