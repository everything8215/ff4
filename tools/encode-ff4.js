#!/usr/bin/env node

const fs = require('fs');
const ROMEncoder = require('./romtools/rom-encoder');

let encoder;

function encodeLevelProg(obj, definition) {
  // decode low level data and high level data separately
  const lowLevelObj = obj.slice(0, -8);
  const lowLevelData = encoder.encodeArray(lowLevelObj, definition.lowLevel);

  const highLevelObj = obj.slice(-8);
  const highLevelData = encoder.encodeArray(highLevelObj, definition.highLevel);

  const combinedData = new Uint8Array(lowLevelData.length + 8);
  combinedData.set(lowLevelData);
  combinedData.set(highLevelData, lowLevelData.length);
  return Buffer.from(combinedData).toString('base64');
}

// load the data file
const dataPath = process.argv[2];
const romDefinitionFile = fs.readFileSync(dataPath);
const romDefinition = JSON.parse(romDefinitionFile);

encoder = new ROMEncoder(romDefinition);

// encode the level progression data
const levelProgObj = romDefinition.obj.characterLevelProgression;
const levelDataDef = romDefinition.assembly.characterLevelProgression;
let encodedLevelArray = [];
for (let levelObj of levelProgObj) {
  const encodedLevelData = encodeLevelProg(levelObj, levelDataDef);
  encodedLevelArray.push(encodedLevelData);
}
romDefinition.obj.characterLevelProgression = encodedLevelArray;

encoder.encodeROM(romDefinition);

process.exit(0);
