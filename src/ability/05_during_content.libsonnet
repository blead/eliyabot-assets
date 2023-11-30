local keywords = import './keywords.libsonnet';
local utils = import './utils.libsonnet';

{
  mode:: 'max',
  // id is at [104] but we need triggerTarget from [93]
  index(index=93, mode='max')::
    self {
      mode:: mode,
      parse:: function(abi) super.parse(abi[index:]),
    },

  parse(abi)::
    if abi[11] in self then self[abi[11]](abi[:20])
    else '<during content %s not defined> ' % abi[11],

  map(abi, divisor=1000):: {
    local this = self,
    triggerTarget: abi[0],
    rampTimes: if abi[4] != '' && abi[4] != '(None)' then std.parseInt(abi[4]) else 0,
    rampedValueStrSigned: if self.minValue != null && self.value != null then (
      if $.mode == 'min' then utils.formatZeroSigned(self.minValue * self.rampTimes)
      else if $.mode == 'max' || self.minValue == self.value then utils.formatZeroSigned(self.value * self.rampTimes)
      else '%s ➝ %s' % [utils.formatZeroSigned(self.minValue * self.rampTimes), utils.formatZeroSigned(self.value * self.rampTimes)]
    ),
    doesNotStack: if abi[10] == 'true' then ' (does not stack)' else '',
    target:
      // daedalia's shenanigans
      if self.triggerTarget == '10' && abi[12] == '7' then 'that multiball'
      else keywords.contentTarget(abi[12]) % { type: this.targetType },
    targetP:
      if self.triggerTarget == '10' && abi[12] == '7' then "that multiball's"
      else keywords.contentTargetP(abi[12]) % { type: this.targetType },
    targetType: keywords.type(abi[13]),
    minValue: if abi[15] != '' then std.parseInt(abi[15]) / divisor,
    value: if abi[16] != '' then std.parseInt(abi[16]) / divisor,
    valueStrSigned: if self.minValue != null && self.value != null then (
      if $.mode == 'min' then utils.formatZeroSigned(self.minValue)
      else if $.mode == 'max' || self.minValue == self.value then utils.formatZeroSigned(self.value)
      else '%s ➝ %s' % [utils.formatZeroSigned(self.minValue), utils.formatZeroSigned(self.value)]
    ),
    contentTargetType: keywords.type(abi[19]),
  },

  addStats(mapped)::
    ' %(valueStrSigned)s%%' % mapped
    + (
      // for during effects we don't need to add max when rampTimes = 1
      if mapped.rampTimes > 1 then ' [MAX: %(rampedValueStrSigned)s%%]' % mapped
      else ''
    ),

  '':: function(abi) '',
  '0':: function(abi) '%(targetP)s ATK' % self.map(abi) + self.addStats(self.map(abi)),
  '1':: function(abi) '%(targetP)s direct attack damage' % self.map(abi) + self.addStats(self.map(abi)),
  '2':: function(abi) '%(targetP)s skill damage' % self.map(abi) + self.addStats(self.map(abi)),
  '3':: function(abi) '%(targetP)s skill charge speed' % self.map(abi) + self.addStats(self.map(abi)),
  '4':: function(abi) '%(targetP)s all-elemental resistance' % self.map(abi) + self.addStats(self.map(abi)),
  '5':: function(abi) '%(targetP)s fire resistance' % self.map(abi) + self.addStats(self.map(abi)),
  '6':: function(abi) '%(targetP)s water resistance' % self.map(abi) + self.addStats(self.map(abi)),
  '7':: function(abi) '%(targetP)s thunder resistance' % self.map(abi) + self.addStats(self.map(abi)),
  '8':: function(abi) '%(targetP)s wind resistance' % self.map(abi) + self.addStats(self.map(abi)),
  '9':: function(abi) '%(targetP)s light resistance' % self.map(abi) + self.addStats(self.map(abi)),
  '10':: function(abi) '%(targetP)s dark resistance' % self.map(abi) + self.addStats(self.map(abi)),
  '18':: function(abi) '%(targetP)s fever gain from attacks' % self.map(abi) + self.addStats(self.map(abi)),
  '20':: function(abi) '%(targetP)s damage dealt to %(contentTargetType)s enemies' % self.map(abi) + self.addStats(self.map(abi)),
  '21':: function(abi) '%(targetP)s break/down punisher' % self.map(abi) + self.addStats(self.map(abi)),
  '23':: function(abi) 'power flip damage' + self.addStats(self.map(abi)),
  '26':: function(abi) '%(target)s immunity to ATK debuff' % self.map(abi),
  '35':: function(abi) '%(target)s immunity to poison debuff' % self.map(abi),
  '37':: function(abi) '%(target)s immunity to lethargy debuff' % self.map(abi),
  '43':: function(abi) '%(targetP)s healing received' % self.map(abi) + self.addStats(self.map(abi)),
  '44':: function(abi) 'take damage in place of %(target)s' % self.map(abi),
  '45':: function(abi) 'multi-hit (2x/%(valueStrSigned)s%%)' % self.map(abi),
  '46':: function(abi) 'multi-hit (3x/%(valueStrSigned)s%%)' % self.map(abi),
  '52':: function(abi) 'speed' + self.addStats(self.map(abi)),
  '54':: function(abi) '%(targetP)s damage dealt to enemies with debuffs' % self.map(abi) + self.addStats(self.map(abi)),
  '76':: function(abi) '%(targetP)s damage dealt to enemies with paralyze/stun debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '154':: function(abi) '%(targetP)s ability damage' % self.map(abi) + self.addStats(self.map(abi)),
  '158':: function(abi) '%(targetP)s damage dealt to that enemy' % self.map(abi) + self.addStats(self.map(abi)),
  '159':: function(abi) '%(targetP)s direct attack damage against that enemy' % self.map(abi) + self.addStats(self.map(abi)),
  '221':: function(abi) '%(targetP)s break/down punisher effects apply regardless of break/down status' % self.map(abi),
  '252':: function(abi) '%(targetP)s direct attacks are enhanced [DMG: %(valueStrSigned)s%%]' % self.map(abi),
  '256':: function(abi)
    local mapped = self.map(abi, divisor=-100000);
    'combo count needed for Lv1 power flip %(valueStrSigned)s' % mapped
    + (if mapped.rampTimes > 0 then ' [MAX: %(rampedValueStrSigned)s]' % mapped else '')
    + mapped.doesNotStack,
  '258':: function(abi) '%(targetP)s ATK against that enemy' % self.map(abi) + self.addStats(self.map(abi)),
  '410':: function(abi) 'direct attack damage dealt' + self.addStats(self.map(abi)),
  '411':: function(abi) '%(targetP)s skill damage dealt' % self.map(abi) + self.addStats(self.map(abi)),
  '413':: function(abi) 'power flip damage dealt' + self.addStats(self.map(abi)),
  '419':: function(abi) 'power flip is enhanced',
}
