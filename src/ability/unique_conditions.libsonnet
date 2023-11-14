local uniqueConditions = import '../../../wf-assets/orderedmap/character/unique_condition.json';
local overrides = import '../overrides/unique_conditions.jsonnet';

{
  get(id):: if id in uniqueConditions then {
    id: id,
    devname: uniqueConditions[id][0][0],
    name: uniqueConditions[id][0][1],
    duration: uniqueConditions[id][0][3],  // inf: '99999999'
    maxStacks: uniqueConditions[id][0][4],  // can be '(None)'
  } + if uniqueConditions[id][0][1] in overrides then overrides[uniqueConditions[id][0][1]] else {},
  mixin(id):: if id in uniqueConditions then {
    local uc = $.get(id),
    ucName: uc.name,
    ucDuration:
      // checking for 0 just to be safe
      if uc.duration != '99999999' && uc.duration != '0'
      then ' (%gs)' % (std.parseInt(uc.duration) / 60)
      else '',
    ucMaxStacks:
      if uc.maxStacks != '(None)'
      then ' [MAX: %s]' % uc.maxStacks
      else '',
  } else {},
}
