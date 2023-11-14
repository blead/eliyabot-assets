local multiballGroups = import '../../../wf-assets/orderedmap/battle/multiball/multiball_group.json';
local overrides = import '../overrides/multiball_groups.jsonnet';

{
  [id]: {
    name: multiballGroups[id][0][0],
  } + if multiballGroups[id][0][0] in overrides then overrides[multiballGroups[id][0][0]] else {}
  for id in std.objectFields(multiballGroups)
}
