local gachas = import '../../wf-assets/orderedmap/gacha/gacha.json';
local gachaFeatureContent = import '../../wf-assets/orderedmap/gacha/gacha_feature_content.json';

local GachaFeatureContent(id) = std.filterMap(
  function(x) x[0] == '2',
  function(x) x[7],
  [gfc[0] for gfc in std.objectValues(gachaFeatureContent[id])],
);

local Gacha(id, data) = {
  id: id,
  devName: data[0],
  name: data[1],
  startDate: data[29],
  endDate: data[30],
  pickup: GachaFeatureContent(id),
};

std.sort([Gacha(gacha.key, gacha.value[0]) for gacha in std.objectKeysValues(gachas)], function(x) x.startDate)
