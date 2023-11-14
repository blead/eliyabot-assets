local equipmentAbilities = import '../../wf-assets/orderedmap/ability/ability_soul.json';
local equipmentEnhancementAbilities = import '../../wf-assets/orderedmap/equipment_enhancement/equipment_enhancement_ability.json';
local equipments = import '../../wf-assets/orderedmap/item/equipment.json';
local equipmentStats = import '../../wf-assets/orderedmap/item/equipment_status.json';
local souls = import '../../wf-assets/orderedmap/item/item.json';
local abilityParser = import './ability/parser.libsonnet';
local elements = import './elements.json';
local overrides = import './overrides/equipments.jsonnet';

local Equipment(id, data) =
  {
    id: id,
    DevNicknames: data[0],
    JPName: data[1],
    Rarity: data[11],
    Attribute: elements[souls[id][0][12]],
    MaxHP: if '5' in equipmentStats[id] then equipmentStats[id]['5'][0][0] else equipmentStats[id]['1'][0][0],
    MaxATK: if '5' in equipmentStats[id] then equipmentStats[id]['5'][0][1] else equipmentStats[id]['1'][0][1],
    AbilitySoul:
      if !(id in equipmentAbilities) then null
      else if data[13] == 'true' then abilityParser.parseAbilitySoulFormatted(equipmentAbilities[id])
      else 'Unobtainable',
  }
  + if data[0] in overrides then overrides[data[0]] else {}
  + (if id in equipmentAbilities then abilityParser.parseEquipmentFormatted(equipmentAbilities[id]) else {})
  + (if id in equipmentEnhancementAbilities then abilityParser.parseEquipmentEnhancementFormatted(equipmentEnhancementAbilities[id]) else {});

std.prune([Equipment(equip.key, equip.value[0]) for equip in std.objectKeysValues(equipments)])
