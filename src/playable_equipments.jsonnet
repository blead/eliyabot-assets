local equipments = import './equipments.jsonnet';

std.filter(
  function(x) !std.startsWith(x.DevNicknames, 'non_playable_equipment_'),
  equipments,
)
