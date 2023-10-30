local main = import '00_main.libsonnet';
local precondition = import '01_precondition.libsonnet';
local instantTrigger = import '02_instant_trigger.libsonnet';
local instantContent = import '03_instant_content.libsonnet';
local duringTrigger = import '04_during_trigger.libsonnet';
local duringContent = import '05_during_content.libsonnet';
local openingContent = import '06_opening_content.libsonnet';

{
  capitalize(line)::
    if line == '' then ''
    else if std.startsWith(line, '[Main] ') then line[:7] + std.asciiUpper(line[7]) + line[8:]
    else if std.startsWith(line, '[Unison] ') then line[:9] + std.asciiUpper(line[9]) + line[10:]
    else std.asciiUpper(line[0]) + line[1:],

  format(lines):: std.join(' / ', std.map(self.capitalize, lines)),

  parse(abi, parsers):: std.foldl(
    function(desc, parser) desc + parser.parse(abi),
    parsers,
    '',
  ),

  parseAbility(abi):: self.parse(
    abi,
    [
      main,
      precondition.index(4),
      precondition.index(11),
      precondition.index(18),
      instantTrigger.index(25),
      instantContent.index(25),
      duringTrigger.index(92),
      duringContent.index(93),
      openingContent.index(118),
    ],
  ),

  parseAbilityFormatted(abis):: self.format(std.map(self.parseAbility, abis)),

  parseLeaderSkill(abi):: self.parse(
    abi,
    [
      precondition.index(2),
      precondition.index(9),
      precondition.index(16),
      instantTrigger.index(23),
      instantContent.index(23),
      duringTrigger.index(90),
      duringContent.index(91),
      openingContent.index(116),
    ],
  ),

  parseLeaderSkillFormatted(abis):: self.format(std.map(self.parseLeaderSkill, abis)),

  parseEquipment(abi):: self.parse(
    abi,
    [
      precondition.index(3),
      precondition.index(10),
      precondition.index(17),
      instantTrigger.index(24),
      instantContent.index(24),
      duringTrigger.index(91),
      duringContent.index(92),
      openingContent.index(117),
    ],
  ),

  parseEquipmentFormatted(abis)::
    local ids = [abi[0] for abi in abis];
    local idCounts = [id for id in std.uniq(ids) if std.count(ids, id) > 1];
    // local idMap = { [idCounts[i]]: i + 1 for i in std.range(0, std.length(idCounts) - 1) };
    // local label(abi) = if abi[0] in idMap then '(%d) ' % idMap[abi[0]] else '';
    
    // All weapons so far have at most only one enhanced abi in lv3 -> lv5 so we'll hardcode it a bit
    local enhanced(abi) = if std.setMember(abi[0], idCounts) then 'Awaken Lv3 is enhanced: ' else '';

    {
      WeaponSkill: std.join(' / ', [$.capitalize($.parseEquipment(abi)) for abi in abis if abi[1] == '1']),
      AwakenLv3: std.join(' / ', [$.capitalize($.parseEquipment(abi)) for abi in abis if abi[1] == '3']),
      AwakenLv5: std.join(' / ', [enhanced(abi) + $.capitalize($.parseEquipment(abi)) for abi in abis if abi[1] == '5']),
    },
}
