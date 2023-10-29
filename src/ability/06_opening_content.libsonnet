local keywords = import './keywords.libsonnet';

{
  index(index=118)::
    self {
      parse:: function(abi) super.parse(abi[index:]),
    },

  parse(abi)::
    if abi[0] in self then self[abi[0]](abi[:3])
    else '(opening content %s not defined) ' % abi[0],

  map(abi, multiplier=100):: {
    value: if abi[2] != '' then std.parseJson(abi[2]) * multiplier,
    valueStrSigned: if self.value != null then (if self.value == 0 then '+0' else '%+g' % self.value),
  },

  '':: function(abi) '',
  '0':: function(abi) 'own EXP received %(valueStrSigned)s%%' % self.map(abi),
  '2':: function(abi) 'amount of mana dropped %(valueStrSigned)s%%' % self.map(abi),
}
