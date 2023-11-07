local customAbilityStrings = import '../../../wf-assets/orderedmap/string/custom_ability_string.json';
local keywords = import './keywords.libsonnet';
local uniqueCondition = import './unique_condition.libsonnet';
local utils = import './utils.libsonnet';

local buffRampTimes(times, min, max) =
  if times > 0 then ' (Effect amplified %s%% [MAX: %s%%] with each skill activation)' % [min, max]
  else '';

local delay(sec) = if sec != '' && sec != '0' then ' after %ss' % sec else '';

local triggerTimes(count) =
  if count == 1 then ' for one time only'
  else if count > 1 then ' for up to %d times' % count
  else '';

local cooldown(cd) = if cd > 0 then ' (CT: %gs)' % cd else '';

local untilFlip(count) =
  if count == 1 then ' until the next flip'
  else if count > 1 then ' for the next %d flips' % count
  else '';

local untilFlipEnds(count, level=3) =
  if count == 1 then ' until power flip Lv%d ends' % level
  else if count > 1 then ' until the next %d Lv%d power flips end' % [count, level]
  else '';

local activatesSeparately(cond) = if cond == 'true' then ' (activates separately for each character)' else '';

{
  mode:: 'max',
  // id is at [45]
  index(index=25, mode='max')::
    self {
      mode:: mode,
      parse:: function(abi) super.parse(abi[index:]),
    },

  parse(abi)::
    if abi[20] in self then self[abi[20]](abi[:55])
    else '<instant content %s not defined> ' % abi[20],

  map(abi, divisor=1000):: {
    local this = self,
    triggerId: abi[0],
    rampTimes: if abi[7] != '' && abi[7] != '(None)' then std.parseInt(abi[7]) else 0,
    rampedValueStrSigned: if self.minValue != null && self.value != null then (
      if $.mode == 'min' then utils.formatZeroSigned(self.minValue * self.rampTimes)
      else if $.mode == 'max' || self.minValue == self.value then utils.formatZeroSigned(self.value * self.rampTimes)
      else '%s ➝ %s' % [utils.formatZeroSigned(self.minValue * self.rampTimes), utils.formatZeroSigned(self.value * self.rampTimes)]
    ),
    cooldown: if abi[8] != '' then std.parseInt(abi[8]) / 60 else 0,
    delay: abi[19],
    target: keywords.contentTarget(abi[21]) % { type: this.targetType },
    targetP: keywords.contentTargetP(abi[21]) % { type: this.targetType },
    targetType: keywords.type(abi[22]),
    minValue: if abi[24] != '' then std.parseInt(abi[24]) / divisor,
    value: if abi[25] != '' then std.parseInt(abi[25]) / divisor,
    valueStr: if self.minValue != null && self.value != null then (
      if $.mode == 'min' then utils.formatZero(self.minValue)
      else if $.mode == 'max' || self.minValue == self.value then utils.formatZero(self.value)
      else '%s ➝ %s' % [utils.formatZero(self.minValue), utils.formatZero(self.value)]
    ),
    valueStrSigned: if self.minValue != null && self.value != null then (
      if $.mode == 'min' then utils.formatZeroSigned(self.minValue)
      else if $.mode == 'max' || self.minValue == self.value then utils.formatZeroSigned(self.value)
      else '%s ➝ %s' % [utils.formatZeroSigned(self.minValue), utils.formatZeroSigned(self.value)]
    ),
    minValue2: if abi[26] != '' then std.parseInt(abi[26]) / divisor,
    value2: if abi[27] != '' then std.parseInt(abi[27]) / divisor,
    value2Str: if self.minValue2 != null && self.value2 != null then (
      if $.mode == 'min' then utils.formatZero(self.minValue2)
      else if $.mode == 'max' || self.minValue2 == self.value2 then utils.formatZero(self.value2)
      else '%s ➝ %s' % [utils.formatZero(self.minValue2), utils.formatZero(self.value2)]
    ),
    value2StrSigned: if self.minValue2 != null && self.value2 != null then (
      if $.mode == 'min' then utils.formatZeroSigned(self.minValue2)
      else if $.mode == 'max' || self.minValue2 == self.value2 then utils.formatZeroSigned(self.value2)
      else '%s ➝ %s' % [utils.formatZeroSigned(self.minValue2), utils.formatZeroSigned(self.value2)]
    ),
    minBuffDuration: if abi[30] != '' && abi[30] != '9.999999E11' then std.parseInt(abi[30]) / 6000000,
    buffDuration: if abi[31] != '' && abi[31] != '9.999999E11' then std.parseInt(abi[31]) / 6000000,
    buffDurationStr: if self.minBuffDuration != null && self.buffDuration != null then (
      if $.mode == 'min' then utils.formatZero(self.minBuffDuration)
      else if $.mode == 'max' || self.minBuffDuration == self.buffDuration then utils.formatZero(self.buffDuration)
      else '%s ➝ %s' % [utils.formatZero(self.minBuffDuration), utils.formatZero(self.buffDuration)]
    ),
    buffStacks: if abi[34] != '' && abi[34] != '(None)' then std.parseInt(abi[34]) else 0,
    stackedValueStrSigned: if self.minValue != null && self.value != null then (
      if $.mode == 'min' then utils.formatZeroSigned(self.minValue * self.buffStacks)
      else if $.mode == 'max' || self.minValue == self.value then utils.formatZeroSigned(self.value * self.buffStacks)
      else '%s ➝ %s' % [utils.formatZeroSigned(self.minValue * self.buffStacks), utils.formatZeroSigned(self.value * self.buffStacks)]
    ),
    buffStackable: if self.buffStacks > 0 then 'stackable ' else '',
    buffUntilFlip: if abi[35] != '' && abi[35] != '(None)' then std.parseInt(abi[35]) else 0,
    buffUntilFlipEnds: if abi[37] != '' && abi[37] != '(None)' then std.parseInt(abi[37]) else 0,
    buffUntilFlipEndsLv: if abi[38] != '' && abi[38] != '(None)' then std.parseInt(abi[38]) else 0,
    contentTargetType: keywords.type(abi[39]),
    buffUndispellable: abi[40] == '1',
    // displayed value = internal value + 1
    buffRampTimes: if abi[54] != '' then std.parseInt(abi[54]) + 1 else 0,
    buffRampedValueStrSigned: if self.minValue != null && self.value != null then (
      if $.mode == 'min' then utils.formatZeroSigned(self.minValue * self.buffRampTimes)
      else if $.mode == 'max' || self.minValue == self.value then utils.formatZeroSigned(self.value * self.buffRampTimes)
      else '%s ➝ %s' % [utils.formatZeroSigned(self.minValue * self.buffRampTimes), utils.formatZeroSigned(self.value * self.buffRampTimes)]
    ),
    changeSkill:
      if abi[43] in customAbilityStrings then customAbilityStrings[abi[43]][0][0]
      else '<changeSkill: %s>' % abi[43],
    activatesSeparately: abi[45],
  } + uniqueCondition.mixin(abi[41]),

  addBuff(mapped)::
    ' (%(valueStrSigned)s%%/%(buffDurationStr)ss' % mapped
    + (
      if mapped.buffStacks > 0 then '/MAX: %(stackedValueStrSigned)s%%' % mapped
      else ''
    ) + ')'
    + buffRampTimes(mapped.buffRampTimes, mapped.valueStrSigned, mapped.buffRampedValueStrSigned)
    + delay(mapped.delay)
    + untilFlip(mapped.buffUntilFlip)
    + untilFlipEnds(mapped.buffUntilFlipEnds, mapped.buffUntilFlipEndsLv)
    + activatesSeparately(mapped.activatesSeparately)
    + triggerTimes(mapped.rampTimes)
    + cooldown(mapped.cooldown),

  addStats(mapped)::
    local minRamp = if std.setMember(mapped.triggerId, ['252', '52', '55', '56']) then 1 else 0;
    ' %(valueStrSigned)s%%' % mapped
    + (if mapped.rampTimes > minRamp then ' [MAX: %(rampedValueStrSigned)s%%]' % mapped else '')
    + delay(mapped.delay)
    + cooldown(mapped.cooldown),

  '':: function(abi) '',
  '0':: function(abi) 'grant %(target)s %(buffStackable)sATK buff' % self.map(abi) + self.addBuff(self.map(abi)),
  '1':: function(abi) 'grant %(target)s %(buffStackable)sskill damage buff' % self.map(abi) + self.addBuff(self.map(abi)),
  '2':: function(abi) 'grant %(target)s %(buffStackable)sall-elemental resistance buff' % self.map(abi) + self.addBuff(self.map(abi)),
  '4':: function(abi) 'grant %(target)s %(buffStackable)swater resistance buff' % self.map(abi) + self.addBuff(self.map(abi)),
  '5':: function(abi) 'grant %(target)s %(buffStackable)sthunder resistance buff' % self.map(abi) + self.addBuff(self.map(abi)),
  '7':: function(abi) 'grant %(target)s %(buffStackable)slight resistance buff' % self.map(abi) + self.addBuff(self.map(abi)),
  '8':: function(abi) 'grant %(target)s %(buffStackable)sdark resistance buff' % self.map(abi) + self.addBuff(self.map(abi)),
  '16':: function(abi)
    'grant %(target)s invincibility buff (%(buffDurationStr)ss' % self.map(abi)
    + (if self.map(abi).buffUndispellable then '/undispellable)' else ')')
    + delay(self.map(abi).delay)
    + untilFlip(self.map(abi).buffUntilFlip)
    + untilFlipEnds(self.map(abi).buffUntilFlipEnds, self.map(abi).buffUntilFlipEndsLv)
    + activatesSeparately(self.map(abi).activatesSeparately)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '17':: function(abi)
    'grant %(target)s regeneration buff (%(valueStr)s/%(buffDurationStr)ss)' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + untilFlip(self.map(abi).buffUntilFlip)
    + untilFlipEnds(self.map(abi).buffUntilFlipEnds, self.map(abi).buffUntilFlipEndsLv)
    + activatesSeparately(self.map(abi).activatesSeparately)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '21':: function(abi) 'grant %(target)s %(buffStackable)sincreased fever gain from attacks buff' % self.map(abi) + self.addBuff(self.map(abi)),
  '24':: function(abi) 'grant %(target)s %(buffStackable)sbreak/down punisher buff' % self.map(abi) + self.addBuff(self.map(abi)),
  '26':: function(abi)
    'grant penetration buff (%(buffDurationStr)ss)' % self.map(abi)
    + delay(self.map(abi).delay)
    + untilFlip(self.map(abi).buffUntilFlip)
    + untilFlipEnds(self.map(abi).buffUntilFlipEnds, self.map(abi).buffUntilFlipEndsLv)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '27':: function(abi)
    'grant float buff (%(buffDurationStr)ss)' % self.map(abi)
    + delay(self.map(abi).delay)
    + untilFlip(self.map(abi).buffUntilFlip)
    + untilFlipEnds(self.map(abi).buffUntilFlipEnds, self.map(abi).buffUntilFlipEndsLv)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '28':: function(abi) 'grant %(buffStackable)spower flip damage buff' % self.map(abi) + self.addBuff(self.map(abi)),
  '31':: function(abi)
    'grant dash cooldown reduction buff (%(buffDurationStr)ss)' % self.map(abi)
    + delay(self.map(abi).delay)
    + untilFlip(self.map(abi).buffUntilFlip)
    + untilFlipEnds(self.map(abi).buffUntilFlipEnds, self.map(abi).buffUntilFlipEndsLv)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '32':: function(abi) '%(targetP)s ATK' % self.map(abi) + self.addStats(self.map(abi)),
  '33':: function(abi) '%(targetP)s direct attack damage' % self.map(abi) + self.addStats(self.map(abi)),
  '34':: function(abi) '%(targetP)s skill damage' % self.map(abi) + self.addStats(self.map(abi)),
  '35':: function(abi) '%(targetP)s skill charge rate' % self.map(abi) + self.addStats(self.map(abi)),
  '36':: function(abi) '%(targetP)s all-elemental resistance' % self.map(abi) + self.addStats(self.map(abi)),
  '37':: function(abi) '%(targetP)s fire resistance' % self.map(abi) + self.addStats(self.map(abi)),
  '38':: function(abi) '%(targetP)s water resistance' % self.map(abi) + self.addStats(self.map(abi)),
  '39':: function(abi) '%(targetP)s thunder resistance' % self.map(abi) + self.addStats(self.map(abi)),
  '40':: function(abi) '%(targetP)s wind resistance' % self.map(abi) + self.addStats(self.map(abi)),
  '41':: function(abi) '%(targetP)s light resistance' % self.map(abi) + self.addStats(self.map(abi)),
  '42':: function(abi) '%(targetP)s dark resistance' % self.map(abi) + self.addStats(self.map(abi)),
  '43':: function(abi)
    '%(targetP)s received ell-elemental damage %(valueStrSigned)s' % self.map(abi, divisor=-100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '50':: function(abi) '%(targetP)s fever gain from attacks' % self.map(abi) + self.addStats(self.map(abi)),
  '51':: function(abi) '%(targetP)s ease of downing enemies' % self.map(abi) + self.addStats(self.map(abi)),
  '52':: function(abi) '%(targetP)s damage dealt to %(contentTargetType)s enemies' % self.map(abi) + self.addStats(self.map(abi)),
  '53':: function(abi) '%(targetP)s break/down punisher' % self.map(abi) + self.addStats(self.map(abi)),
  '55':: function(abi) 'power flip damage' + self.addStats(self.map(abi)),
  '56':: function(abi) 'fever mode duration' + self.addStats(self.map(abi)),
  '59':: function(abi) '%(target)s immunity to ATK debuff' % self.map(abi),
  '60':: function(abi) '%(target)s immunity to skill damage debuff' % self.map(abi),
  '62':: function(abi) '%(target)s immunity to fire resistance debuff' % self.map(abi),
  '63':: function(abi) '%(target)s immunity to water resistance debuff' % self.map(abi),
  '64':: function(abi) '%(target)s immunity to thunder resistance debuff' % self.map(abi),
  '65':: function(abi) '%(target)s immunity to wind resistance debuff' % self.map(abi),
  '66':: function(abi) '%(target)s immunity to light resistance debuff' % self.map(abi),
  '67':: function(abi) '%(target)s immunity to dark resistance debuff' % self.map(abi),
  '68':: function(abi) '%(target)s immunity to poison debuff' % self.map(abi),
  '69':: function(abi) '%(target)s immunity to paralyze debuff' % self.map(abi),
  '70':: function(abi) '%(target)s immunity to lethargy debuff' % self.map(abi),
  '96':: function(abi) '%(targetP)s damage dealt to enemies with debuffs' % self.map(abi) + self.addStats(self.map(abi)),
  '99':: function(abi) '%(targetP)s damage dealt to enemies with ATK debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '108':: function(abi) '%(targetP)s damage dealt to enemies with fire resistance debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '109':: function(abi) '%(targetP)s damage dealt to enemies with water resistance debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '110':: function(abi) '%(targetP)s damage dealt to enemies with thunder resistance debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '111':: function(abi) '%(targetP)s damage dealt to enemies with wind resistance debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '112':: function(abi) '%(targetP)s damage dealt to enemies with light resistance debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '113':: function(abi) '%(targetP)s damage dealt to enemies with dark resistance debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '117':: function(abi) '%(targetP)s damage dealt to enemies with poison debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '118':: function(abi) '%(targetP)s damage dealt to enemies with paralyze/stun debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '119':: function(abi) '%(targetP)s damage dealt to enemies with slow debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '124':: function(abi) '%(targetP)s direct attack damage against enemies with debuffs' % self.map(abi) + self.addStats(self.map(abi)),
  '145':: function(abi) '%(targetP)s direct attack damage against enemies with poison debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '151':: function(abi) 'Lv1 power flip damage' + self.addStats(self.map(abi)),
  '152':: function(abi) 'Lv2 power flip damage' + self.addStats(self.map(abi)),
  '153':: function(abi) 'Lv3 power flip damage' + self.addStats(self.map(abi)),
  '156':: function(abi) '%(targetP)s buff duration' % self.map(abi) + self.addStats(self.map(abi)),
  '157':: function(abi) '%(targetP)s ATK buff duration' % self.map(abi) + self.addStats(self.map(abi)),
  '159':: function(abi) '%(targetP)s skill damage buff duration' % self.map(abi) + self.addStats(self.map(abi)),
  '163':: function(abi) '%(targetP)s water resistance buff duration' % self.map(abi) + self.addStats(self.map(abi)),
  '165':: function(abi) '%(targetP)s wind resistance buff duration' % self.map(abi) + self.addStats(self.map(abi)),
  '177':: function(abi) '%(targetP)s regeneration buff duration' % self.map(abi) + self.addStats(self.map(abi)),
  '190':: function(abi) 'penetration buff duration' + self.addStats(self.map(abi)),
  '191':: function(abi) 'float buff duration' + self.addStats(self.map(abi)),
  '192':: function(abi) 'power flip damage buff duration' + self.addStats(self.map(abi)),
  '195':: function(abi) '%(targetP)s healing received' % self.map(abi) + self.addStats(self.map(abi)),
  '197':: function(abi) 'take damage in place of %(target)s' % self.map(abi),
  '198':: function(abi)
    'take damage in place of %(target)s for %(buffDurationStr)ss' % self.map(abi)
    + delay(self.map(abi).delay)
    + untilFlip(self.map(abi).buffUntilFlip)
    + untilFlipEnds(self.map(abi).buffUntilFlipEnds, self.map(abi).buffUntilFlipEndsLv)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '200':: function(abi)
    local mapped = self.map(abi, divisor=-100000);
    'combo count needed for Lv3 power flip %(valueStrSigned)s' % mapped
    + (if mapped.rampTimes > 0 then ' [MAX: %(rampedValueStrSigned)s]' % mapped else '')
    + delay(self.map(abi).delay)
    + cooldown(self.map(abi).cooldown),
  '201':: function(abi) 'multi-hit (2x/%(valueStrSigned)s%%)' % self.map(abi),
  '202':: function(abi) 'multi-hit (3x/%(valueStrSigned)s%%)' % self.map(abi),
  '203':: function(abi)
    '%(targetP)s coffin count %(valueStrSigned)s' % self.map(abi, divisor=-100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '205':: function(abi) '%(targetP)s HP' % self.map(abi) + self.addStats(self.map(abi)),
  '206':: function(abi)
    'heal %(target)s for %(valueStr)s%% of max HP' % self.map(abi)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '209':: function(abi)
    'deal damage to %(target)s equating %(valueStr)s%% of max HP' % self.map(abi)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '211':: function(abi)
    '%(targetP)s skill gauge %(valueStrSigned)s%%' % self.map(abi)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '213':: function(abi)
    'fever gauge %(valueStrSigned)s' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '214':: function(abi) 'grant %(target)s %(buffStackable)sdirect attack damage buff' % self.map(abi) + self.addBuff(self.map(abi)),
  '220':: function(abi) '%(target)s immunity to silence debuff' % self.map(abi),
  '223':: function(abi)
    'grant %(target)s multi-hit buff (2x/%(valueStrSigned)s%%/%(buffDurationStr)ss)' % self.map(abi)
    + delay(self.map(abi).delay)
    + untilFlip(self.map(abi).buffUntilFlip)
    + untilFlipEnds(self.map(abi).buffUntilFlipEnds, self.map(abi).buffUntilFlipEndsLv)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '224':: function(abi)
    'grant %(target)s multi-hit buff (3x/%(valueStrSigned)s%%/%(buffDurationStr)ss)' % self.map(abi)
    + delay(self.map(abi).delay)
    + untilFlip(self.map(abi).buffUntilFlip)
    + untilFlipEnds(self.map(abi).buffUntilFlipEnds, self.map(abi).buffUntilFlipEndsLv)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '226':: function(abi)
    'combo %(valueStrSigned)s' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '227':: function(abi)
    'grant %(target)s barrier equating %(valueStr)s%% of max HP' % self.map(abi)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '228':: function(abi) 'grant %(buffStackable)sspeed buff' % self.map(abi) + self.addBuff(self.map(abi)),
  '245':: function(abi) '%(targetP)s max skill gauge' % self.map(abi) + self.addStats(self.map(abi)),
  '246':: function(abi)
    'fever activation count %(valueStrSigned)s' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '248':: function(abi)
    'power flip activation count %(valueStrSigned)s' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '251':: function(abi)
    'deal fire damage to all enemies equating %(valueStr)s times of %(targetP)s ATK' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '253':: function(abi)
    'deal thunder damage to all enemies equating %(valueStr)s times of %(targetP)s ATK' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '255':: function(abi)
    'deal light damage to all enemies equating %(valueStr)s times of %(targetP)s ATK' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '267':: function(abi)
    'deal light damage to all enemies equating %(valueStr)s times of %(targetP)s max HP' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '291':: function(abi)
    '%(targetP)s damage taken from enemies with ATK debuff' % self.map(abi)
    + self.addStats(self.map(abi, divisor=-1000)),
  '309':: function(abi)
    '%(targetP)s damage taken from enemies with poison debuff' % self.map(abi)
    + self.addStats(self.map(abi, divisor=-1000)),
  '315':: function(abi)
    '%(targetP)s damage taken from enemies with [%(ucName)s] debuff' % self.map(abi)
    + self.addStats(self.map(abi, divisor=-1000)),
  '318':: function(abi)
    'deal thunder damage to that enemy equating %(valueStr)s times of %(targetP)s ATK' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '332':: function(abi)
    'deal light damage to that enemy equating %(valueStr)s times of %(targetP)s max HP' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '356':: function(abi)
    'deal light damage to nearest enemy equating %(valueStr)s times of %(targetP)s ATK' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '368':: function(abi)
    'deal light damage to nearest enemy equating %(valueStr)s times of %(targetP)s max HP' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '388':: function(abi) '%(targetP)s ability damage' % self.map(abi) + self.addStats(self.map(abi)),
  '390':: function(abi)
    'reset combo count to %(valueStr)s' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '391':: function(abi)
    'inflict %(buffStackable)sATK debuff' % self.map(abi)
    + self.addBuff(self.map(abi))
    + ' to all enemies',
  '393':: function(abi)
    'inflict %(buffStackable)sfire resistance debuff' % self.map(abi)
    + self.addBuff(self.map(abi))
    + ' to all enemies',
  '413':: function(abi)
    'inflict all enemies with [%(ucName)s]%(ucDuration)s' % self.map(abi)
    + delay(self.map(abi).delay)
    + untilFlip(self.map(abi).buffUntilFlip)
    + untilFlipEnds(self.map(abi).buffUntilFlipEnds, self.map(abi).buffUntilFlipEndsLv)
    + activatesSeparately(self.map(abi).activatesSeparately)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '461':: function(abi)
    (
      'grant %(target)s '
      + (if self.map(abi, divisor=100000).valueStr != '1' then '%(valueStr)s levels of ' else '')
      + '[%(ucName)s]%(ucDuration)s%(ucMaxStacks)s (undispellable)'
    ) % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + untilFlip(self.map(abi).buffUntilFlip)
    + untilFlipEnds(self.map(abi).buffUntilFlipEnds, self.map(abi).buffUntilFlipEndsLv)
    + activatesSeparately(self.map(abi).activatesSeparately)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '462':: function(abi) 'take %(valueStr)s%% of damage in place of %(target)s' % self.map(abi),
  '468':: function(abi)
    'grant %(target)s guts buff' % self.map(abi)
    + (if self.map(abi).buffUndispellable then ' (undispellable)' else '')
    + delay(self.map(abi).delay)
    + untilFlip(self.map(abi).buffUntilFlip)
    + untilFlipEnds(self.map(abi).buffUntilFlipEnds, self.map(abi).buffUntilFlipEndsLv)
    + activatesSeparately(self.map(abi).activatesSeparately)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '470':: function(abi)
    'grant %(target)s Adversity buff (MAX: %(valueStrSigned)s%%/%(buffDurationStr)ss)' % self.map(abi)
    + delay(self.map(abi).delay)
    + untilFlip(self.map(abi).buffUntilFlip)
    + untilFlipEnds(self.map(abi).buffUntilFlipEnds, self.map(abi).buffUntilFlipEndsLv)
    + activatesSeparately(self.map(abi).activatesSeparately)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '483':: function(abi) "%(contentTargetType)s multiballs' ATK" % self.map(abi) + self.addStats(self.map(abi)),
  '484':: function(abi) "%(contentTargetType)s multiballs' direct attack damage" % self.map(abi) + self.addStats(self.map(abi)),
  '485':: function(abi) "%(contentTargetType)s multiballs' HP" % self.map(abi) + self.addStats(self.map(abi)),
  '487':: function(abi) '%(targetP)s ability damage buff duration' % self.map(abi) + self.addStats(self.map(abi)),
  '489':: function(abi)
    'grant combo boost buff [combo %(valueStrSigned)s]' % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + untilFlip(self.map(abi).buffUntilFlip)
    + untilFlipEnds(self.map(abi).buffUntilFlipEnds, self.map(abi).buffUntilFlipEndsLv)
    + activatesSeparately(self.map(abi).activatesSeparately)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '491':: function(abi) '%(targetP)s ATK against enemies with debuffs' % self.map(abi) + self.addStats(self.map(abi)),
  '503':: function(abi) '%(targetP)s ATK against enemies with fire resistance debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '504':: function(abi) '%(targetP)s ATK against enemies with water resistance debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '505':: function(abi) '%(targetP)s ATK against enemies with thunder resistance debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '506':: function(abi) '%(targetP)s ATK against enemies with wind resistance debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '507':: function(abi) '%(targetP)s ATK against enemies with light resistance debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '508':: function(abi) '%(targetP)s ATK against enemies with dark resistance debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '512':: function(abi) '%(targetP)s ATK against enemies with poison debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '514':: function(abi) '%(targetP)s ATK against enemies with slow debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '518':: function(abi) '%(targetP)s damage dealt to enemies with [%(ucName)s]' % self.map(abi) + self.addStats(self.map(abi)),
  '520':: function(abi) '%(targetP)s ATK against enemies with [%(ucName)s]' % self.map(abi) + self.addStats(self.map(abi)),
  '524':: function(abi) 'powerflip damage during Lv3 powerflip' + self.addStats(self.map(abi)),
  '525':: function(abi)
    (
      'remove %(valueStr)s '
      + (if self.map(abi, divisor=100000).valueStr == '1' then 'level ' else 'levels ')
      + 'of [%(ucName)s] from %(target)s'
    ) % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '527':: function(abi)
    (
      'remove %(valueStr)s '
      + (if self.map(abi, divisor=100000).valueStr == '1' then 'debuff ' else 'debuffs ')
      + 'from %(target)s'
    ) % self.map(abi, divisor=100000)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '528':: function(abi)
    'remove [%(ucName)s] from %(target)s' % self.map(abi)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '536':: function(abi) self.map(abi).changeSkill,
  '538':: function(abi) '%(targetP)s skill damage against enemies with debuffs' % self.map(abi) + self.addStats(self.map(abi)),
  '551':: function(abi) '%(targetP)s skill damage against enemies with water resistance debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '560':: function(abi) '%(targetP)s skill damage against enemies with paralyze/stun debuff' % self.map(abi) + self.addStats(self.map(abi)),
  '628':: function(abi) '%(valueStr)s%% of own damage taken is shared equally to %(target)s instead' % self.map(abi),
  // ability skill e.g., hildegarde summoning balls
  '629':: self['536'],
  '690':: function(abi) 'max movement speed buff duration' + self.addStats(self.map(abi)),
  '696':: function(abi) 'power flip damage dealt' + self.addStats(self.map(abi)),
  '704':: self['536'],
  '705':: self['536'],
  '706':: self['536'],
  '713':: function(abi) 'grant %(target)s %(buffStackable)sdirect attack enhanced buff' % self.map(abi) + self.addBuff(self.map(abi)),
  '715':: function(abi) 'direct attack enhanced buff duration' + self.addStats(self.map(abi)),
  '717':: function(abi)
    "add %(valueStr)s%% of Unison character's base ATK to %(targetP)s base ATK" % self.map(abi)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '718':: function(abi)
    'combo count needed for Lv3 power flip %(valueStrSigned)s (%(buffDurationStr)ss)' % self.map(abi, divisor=-100000)
    + delay(self.map(abi).delay)
    + untilFlip(self.map(abi).buffUntilFlip)
    + untilFlipEnds(self.map(abi).buffUntilFlipEnds, self.map(abi).buffUntilFlipEndsLv)
    + activatesSeparately(self.map(abi).activatesSeparately)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
  '719':: function(abi)
    'deal damage to %(target)s whose HP is at or above %(value2Str)s%% equating %(valueStr)s%% of max HP' % self.map(abi)
    + delay(self.map(abi).delay)
    + triggerTimes(self.map(abi).rampTimes)
    + cooldown(self.map(abi).cooldown),
}
