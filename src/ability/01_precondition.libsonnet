local keywords = import './keywords.libsonnet';
local uniqueConditions = import './unique_conditions.libsonnet';

{
  mode:: 'max',
  index(index=4, mode='max')::
    self {
      mode:: mode,
      parse:: function(abi) super.parse(abi[index:]),
    },

  parse(abi)::
    if abi[0] in self then self[abi[0]](abi[:7])
    else '<precondition %s not defined> ' % abi[0],

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
    checkType: keywords.type(abi[5]),
  } + uniqueConditions.mixin(abi[6]),

  '':: function(abi) '',
  '0':: function(abi) '',
  '1':: function(abi) (
    if self.map(abi).valueStr == '6' then 'Resonance [%(checkType)s], '
    else 'if there are %(valueStr)s or more %(checkType)s characters in the party, '
  ) % self.map(abi),
  '2':: function(abi) 'if self is a %(checkType)s character, ' % self.map(abi),
  '7':: function(abi) 'while %(targetP)s HP is at or above %(valueStr)s%%, ' % self.map(abi, divisor=1000),
  '8':: function(abi) 'while %(targetP)s HP is at or below %(valueStr)s%%, ' % self.map(abi, divisor=1000),
  '11':: function(abi) 'while in fever, ',
  '37':: function(abi) 'while penetration buff is active, ',
  '38':: function(abi) 'while float buff is active, ',
  '41':: function(abi) 'if self is leader, ',
  '42':: function(abi) 'if leader is a %(checkType)s character, ' % self.map(abi),
  '45':: function(abi) 'if self is not leader, ',
  '86':: function(abi) 'while %(target)s has barrier, ' % self.map(abi),
  '185':: function(abi) 'outside of fever, ',
  // ...が「...」中の間、かつ、
  '186':: function(abi) 'while %(target)s has [%(ucName)s], ' % self.map(abi),
  // stackable unique condition but description doesn't mention it?: ...が「...」中に
  '187':: function(abi) 'while %(target)s has [%(ucName)s], ' % self.map(abi),
  // hfalche abi3
  // 闇属性キャラの棺桶からの復帰回数が 3 回以上の間に
  '199':: function(abi) 'when %(target)s has been revived %(valueStr)s times or more, ' % self.map(abi),
  // kazuma exclusive
  // 自身が『...』のユニゾンの時
  '200':: function(abi) 'if self is the unison character to [%(checkType)s], ' % self.map(abi),
  // for dual effect abilities
  '201':: function(abi) '[Main] ',
  '202':: function(abi) '[Unison] ',
  // duplicate? of target HP <=
  '204':: self['8'],
  '207':: function(abi)
    if self.map(abi).valueStr == '6' then 'Resonance [Any], '
    else 'if there are %(valueStr)s or more characters with the same element in the party, ' % self.map(abi),
}
