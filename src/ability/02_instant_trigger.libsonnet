local multiballGroups = import '../../../wf-assets/orderedmap/battle/multiball/multiball_group.json';
local keywords = import './keywords.libsonnet';
local whenBattleBegins = import './when_battle_begins.json';

local everyTime(count) = if count == 1 then 'when ' else 'every %s times ' % count;

{
  index(index=25)::
    self {
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
    value: if abi[4] != '' then std.parseInt(abi[4]) / divisor,
    value2: if abi[6] != '' then std.parseInt(abi[6]) / divisor,
    rampTimes: if abi[7] != '' && abi[7] != '(None)' then std.parseInt(abi[7]) else 0,
    checkType: keywords.type(abi[9]),
    multiballGroup: if abi[11] in multiballGroups then multiballGroups[abi[11]][0][0] else '<multiballGroup: %s>' % abi[11],
    instantContent: abi[20],
  },

  '':: function(abi) '',
  '0':: function(abi) if std.setMember(self.map(abi).instantContent, whenBattleBegins) then 'when battle begins, ' else '',
  '1':: function(abi)
    if self.map(abi).value == 1 then 'every power flip, '
    else 'every %(value)g power flips, ' % self.map(abi),
  '2':: function(abi)
    if self.map(abi).value == 1 then 'every dash, '
    else 'every %(value)g dashes, ' % self.map(abi),
  '3':: function(abi)
    if self.map(abi).value == 1 then 'every ball flip, '
    else 'every %(value)g ball flips, ' % self.map(abi),
  '4':: function(abi)
    if self.map(abi).value == 1 then 'when entering fever, '
    else 'every %(value)g fevers, ' % self.map(abi),
  '5':: function(abi) everyTime(self.map(abi).value) + 'a multiball appears, ',
  '6':: function(abi)
    if self.map(abi).value == 1 then 'every enemy defeated, '
    else 'every %(value)g enemies defeated, ' % self.map(abi),
  '7':: function(abi) 'every %(value)g combo, ' % self.map(abi),
  '8':: function(abi) 'when a ball flip occurs above %(value)g combo, ' % self.map(abi),
  '13':: function(abi) everyTime(self.map(abi).value) + '%(target)s is revived, ' % self.map(abi),
  '14':: function(abi) everyTime(self.map(abi).value) + '%(target)s recovers HP, ' % self.map(abi),
  '15':: function(abi) (
    if self.map(abi).value == 1 then 'every direct attack by %(target)s, '
    else 'every %(value)g direct attacks by %(target)s, '
  ) % self.map(abi),
  '16':: function(abi) everyTime(self.map(abi).value) + '%(target)s receives damage, ' % self.map(abi),
  '18':: function(abi) everyTime(self.map(abi).value) + '%(targetP)s skill activates, ' % self.map(abi),
  '19':: function(abi) everyTime(self.map(abi).value) + '%(targetP)s skill gauge reaches %(value)g%%, ' % self.map(abi, divisor=1000),
  '20':: function(abi) 'when %(targetP)s HP falls to or below %(value)g%%, ' % self.map(abi, divisor=1000),
  '21':: function(abi)
    if self.map(abi).value == 1 then 'every flip, '
    else 'every %(value)g flips, ' % self.map(abi),
  '23':: function(abi) everyTime(self.map(abi).value) + '%(target)s receives a debuff, ' % self.map(abi),
  '24':: function(abi) everyTime(self.map(abi).value) + '%(target)s gains a buff, ' % self.map(abi),
  '25':: function(abi) everyTime(self.map(abi).value) + '%(target)s gains an ATK buff, ' % self.map(abi),
  '46':: function(abi) everyTime(self.map(abi).value) + 'party gains penetration buff, ',
  '48':: function(abi) everyTime(self.map(abi).value) + 'party gains power flip damage buff, ',
  '47':: function(abi) everyTime(self.map(abi).value) + 'party gains float buff, ',
  '52':: function(abi) (
    if self.map(abi).value == 6 then 'Resonance [%(checkType)s], '
    else if self.map(abi).rampTimes <= 1 then 'if there are %(value)g or more %(checkType)s characters in the party, '
    else if self.map(abi).value == 1 then 'for every %(checkType)s character in the party, '
    else 'for every %(value)g %(checkType)s characters in the party, '
  ) % self.map(abi),
  '53':: function(abi) 'if self is a %(checkType)s character, ' % self.map(abi),
  '55':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'if there are %(value)g or more elements among party members, '
    else if self.map(abi).value == 1 then 'for every element among party members, '
    else 'for every %(value)g elements among party members, '
  ) % self.map(abi),
  '56':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'if there are %(value)g or more races among party members, '
    else if self.map(abi).value == 1 then 'for every race among party members, '
    else 'for every %(value)g races among party members, '
  ) % self.map(abi),
  '58':: function(abi)
    if self.map(abi).value == 1 then 'every Lv1 power flip, '
    else 'every %(value)g Lv1 power flips, ' % self.map(abi),
  '59':: function(abi)
    if self.map(abi).value == 1 then 'every Lv2 power flip, '
    else 'every %(value)g Lv2 power flips, ' % self.map(abi),
  '60':: function(abi)
    if self.map(abi).value == 1 then 'every Lv3 power flip, '
    else 'every %(value)g Lv3 power flips, ' % self.map(abi),
  '61':: function(abi) 'if self is leader, ',
  '65':: function(abi) 'upon reaching %(value)g combo, ' % self.map(abi),
  '66':: function(abi) 'if leader is a %(checkType)s character, ' % self.map(abi),
  '71':: function(abi) everyTime(self.map(abi).value) + 'fever gauge is increased by abilities, ',
  '72':: function(abi)
    if self.map(abi).value == 1 then 'every 1 second, '
    else 'every %(value)g seconds, ' % self.map(abi, divisor=6000000),
  '73':: function(abi) 'when %(target)s recovers %(value)g HP or above at once, ' % self.map(abi),
  // 敵がマヒ・スタン効果になる度
  '97':: function(abi) everyTime(self.map(abi).value) + 'an enemy gets paralyze/stun debuff, ',
  '102':: function(abi) everyTime(self.map(abi).value) + '%(targetP)s skill hits, ' % self.map(abi),
  // 敵が1体マヒ・スタン効果になる度
  '126':: self['97'],
  '132':: function(abi) everyTime(self.map(abi).value) + '%(target)s receives barrier, ' % self.map(abi),
  '133':: function(abi) everyTime(self.map(abi).value) + '%(target)s direct attacks an enemy, ' % self.map(abi),
  '134':: function(abi) everyTime(self.map(abi).value) + '%(target)s becomes a coffin, ' % self.map(abi),
  '136':: function(abi) everyTime(self.map(abi).value) + '%(targetP)s skill gauge is increased by an ability or skill' % self.map(abi),
  '138':: function(abi) everyTime(self.map(abi).value) + '%(targetP)s ability deals damage, ' % self.map(abi),
  '139':: function(abi) everyTime(self.map(abi).value) + '%(targetP)s damage ability activates, ' % self.map(abi),
  '179':: function(abi) everyTime(self.map(abi).value) + 'fever ends, ',
  '181':: function(abi)
    if self.map(abi).value == 1 then 'every consecutive power flip, '
    else 'every %(value)g consecutive power flips, ' % self.map(abi),
  '191':: function(abi) everyTime(self.map(abi).value) + '[%(multiballGroup)s] disappears, ' % self.map(abi),
  '192':: function(abi) everyTime(self.map(abi).value) + '%(target)s bumps into an enemy, ' % self.map(abi),
  '193':: function(abi) 'if self is the unison character to [%(checkType)s], ' % self.map(abi),
  '231':: function(abi)
    if self.map(abi).value2 == 1 then 'every 1 second of float buff, '
    else 'every %(value2)g seconds of float buff, ' % self.map(abi, divisor=6000000),
  '250':: function(abi) 'upon reaching %(value)g combo %(value2)g times, ' % self.map(abi),
  '252':: function(abi) (
    if self.map(abi).value == 6 then 'Resonance [Any], '
    else if self.map(abi).rampTimes <= 1 then 'if there are %(value)g or more characters with the same element in the party, '
    else if self.map(abi).value == 1 then 'for every character with the same element in the party, '
    else 'for every %(value)g characters with the same element in the party, '
  ) % self.map(abi),
  '255':: function(abi)
    if self.map(abi).value == 1 then 'every Lv1 or Lv2 power flip, '
    else 'every %(value)g Lv1 or Lv2 power flips, ' % self.map(abi),
  '256':: function(abi) (
    if self.map(abi).rampTimes <= 1 then 'when battle begins, if %(target)s exceeds its max skill gauge by %(value)g%%, '
    else 'when battle begins, for every %(value)g%% skill gauge by which %(target)s exceeds its max skill gauge, '
  ) % self.map(abi, divisor=1000),
}
