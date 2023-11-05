local keywords = import './keywords.libsonnet';
local utils = import './utils.libsonnet';

{
  mode:: 'max',
  index(index=118, mode='max')::
    self {
      mode:: mode,
      parse:: function(abi) super.parse(abi[index:]),
    },

  parse(abi)::
    if abi[0] in self then self[abi[0]](abi[:3])
    else '<opening content %s not defined> ' % abi[0],

  map(abi, multiplier=100):: {
    minValue: if abi[1] != '' then std.parseJson(abi[1]) * multiplier,
    value: if abi[2] != '' then std.parseJson(abi[2]) * multiplier,
    valueStrSigned: if self.minValue != null && self.value != null then (
      if $.mode == 'min' then utils.formatZeroSigned(self.minValue)
      else if $.mode == 'max' || self.minValue == self.value then utils.formatZeroSigned(self.value)
      else '[%s ➝ %s]' % [utils.formatZeroSigned(self.minValue), utils.formatZeroSigned(self.value)]
    ),
  },

  '':: function(abi) '',
  '0':: function(abi) 'own EXP received %(valueStrSigned)s%%' % self.map(abi),
  '2':: function(abi) 'amount of mana dropped %(valueStrSigned)s%%' % self.map(abi),
}
