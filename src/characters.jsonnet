local characters = import '../../wf-assets/orderedmap/character/character.json';
local characterStats = import '../../wf-assets/orderedmap/character/character_status.json';
local characterTexts = import '../../wf-assets/orderedmap/character/character_text.json';
local characterSkills = import '../../wf-assets/orderedmap/skill/action_skill.json';
local banners = import './banners.jsonnet';
local elements = import './elements.json';

local MAX_LV_BONUS = [null, 12 * 0.004, 10 * 0.005, 8 * 0.008, 6 * 0.015, 4 * 0.03];
local AWAKEN_STATS = [null, [30, 150], [40, 200], [50, 250], [54, 270], [60, 300]];
local ROLES = { '0': 'Sword', '1': 'Fist', '2': 'Bow', '3': 'Support', '4': 'Special' };
local RACE_MAP = { ',': ' / ', Mystery: 'Youkai', Element: 'Sprite', Machine: 'Mecha', Plants: 'Plant', Devil: 'Demon' };

local Character(id, data) = if std.objectHas(characterSkills[data[0]], '2') then {
  id: id,
  leaderSkillName: characterTexts[id][0][8],
  skillName: characterTexts[id][0][6],
  skillDescription: characterTexts[id][0][7],
  banners: std.filter(function(x) std.member(x.pickup, id), banners),

  DevNicknames: data[0],
  SubName: characterTexts[id][0][3],
  JPName: characterTexts[id][0][1],
  Rarity: std.parseInt(data[2]),
  Attribute: elements[data[3]],
  Role: ROLES[data[6]],
  Race: std.foldl(
    function(a, b) std.strReplace(a, b.key, b.value),
    std.objectKeysValues(RACE_MAP),
    data[4],
  ),
  Stance: data[26],
  Gender: std.strReplace(data[7], 'Ririi', 'Lily'),
  MaxHP: std.ceil(std.parseInt(characterStats[id]['100'][0][0]) * (1 + MAX_LV_BONUS[self.Rarity])) + AWAKEN_STATS[self.Rarity][1],
  MaxATK: std.ceil(std.parseInt(characterStats[id]['100'][0][1]) * (1 + MAX_LV_BONUS[self.Rarity])) + AWAKEN_STATS[self.Rarity][0],
  SkillWait: characterSkills[data[0]]['2'][0][5],
  SkillIcon: std.strReplace(characterSkills[data[0]]['2'][0][2], 'dynamic/skill/', ''),
  SkillRange: characterSkills[data[0]]['2'][0][8:16],

  // ENName: '[' + self.SubName + ']\n' + self.JPName,
  LeaderBuff: '[' + self.leaderSkillName + ']\n',
  Skill: '[' + self.skillName + ']\n' + self.skillDescription,
  Obtain: if std.length(self.banners) > 0 && self.banners[0].name == '流星祭ガチャ' then '[Limited] Meteor Festival Gacha',
};

std.prune([Character(char.key, char.value[0]) for char in std.objectKeysValues(characters)])