local customAbilityStrings = import '../../../wf-assets/orderedmap/string/custom_ability_string.json';
local overrides = import '../overrides/custom_ability_strings.jsonnet';

{
  [id]: if id in overrides then overrides[id] else customAbilityStrings[id][0][0]
  for id in std.objectFields(customAbilityStrings)
}
