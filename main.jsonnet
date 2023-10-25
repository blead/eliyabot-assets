{
  'output/characters.json': std.manifestJsonEx(import './src/characters.jsonnet', '  '),
  'output/equipments.json': std.manifestJsonEx(import './src/equipments.jsonnet', '  '),
  'processed/playable_characters.json': std.manifestJsonMinified(import './src/playable_characters.jsonnet'),
  'processed/playable_equipments.json': std.manifestJsonMinified(import './src/playable_equipments.jsonnet'),
  'processed/wfarea.json': std.manifestJsonMinified(import './src/wfarea.jsonnet'),
}
