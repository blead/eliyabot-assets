local degrees = import '../../wf-assets/orderedmap/degree/degree.json';
local characters = import './characters.jsonnet';

local playable_degrees = std.filter(
  function(x) std.startsWith(x, 'degree_favor_') && !std.endsWith(x, '_2'),
  [degree[0][0] for degree in std.objectValues(degrees)],
);

std.filter(
  function(x) std.member(playable_degrees, 'degree_favor_' + x.DevNicknames) ||
              std.member(playable_degrees, 'degree_favor_' + std.strReplace(x.DevNicknames, '_playable', '')),
  characters,
)
