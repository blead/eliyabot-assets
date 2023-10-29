local uniqueConditions = import '../../../wf-assets/orderedmap/character/unique_condition.json';

{
  get(id):: if id in uniqueConditions then {
    id: id,
    devname: uniqueConditions[id][0][0],
    name: uniqueConditions[id][0][1],
    duration: uniqueConditions[id][0][3], // inf: '99999999'
    maxStacks: uniqueConditions[id][0][4], // can be '(None)'
  },
  mixin(id):: if id in uniqueConditions then {
    ucName: uniqueConditions[id][0][1],
    ucDuration:
      // checking for 0 just to be safe
      if uniqueConditions[id][0][3] != '99999999' && uniqueConditions[id][0][3] != '0'
      then ' (%gs)' % (std.parseInt(uniqueConditions[id][0][3]) / 60)
      else '',
    ucMaxStacks:
      if uniqueConditions[id][0][4] != '(None)'
      then ' [MAX: %s]' % uniqueConditions[id][0][4]
      else '',
  } else {},
}
