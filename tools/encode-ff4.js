#!/usr/bin/env node

const fs = require('fs');
const ROMEncoder = require('./romtools/rom-encoder');
const ROMMemoryMap = require('./romtools/memory-map');
const ROMRange = require('./romtools/range');
const ROMDataCodec = require('./romtools/data-codec');

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

function encodeMonsterGfx(definition) {

  let isDirty = false;
  isDirty |= definition.assembly.monsterGraphicsProperties.isDirty;
  isDirty |= definition.assembly.monsterGraphics1.isDirty;
  isDirty |= definition.assembly.monsterGraphics1.isDirty;
  isDirty |= definition.assembly.monsterGraphics1.isDirty;
  isDirty |= definition.assembly.monsterGraphics1.isDirty;
  isDirty |= definition.assembly.monsterGraphics1.isDirty;
  if (!isDirty) return;

  const memoryMap = new ROMMemoryMap(definition.mode);

  // need to choose 3bpp or 4bpp for each monster graphics
  const is3bppList = [];
  const gfxOffsetList = [];
  for (let bank = 0; bank < 5; bank++) {
    const gfxPath = `monsterGraphics${bank + 1}`;
    const gfxRange = new ROMRange(definition.assembly[gfxPath].range);
    const gfxOffset = memoryMap.mapAddress(gfxRange.begin & 0xFF0000);
    gfxOffsetList.push(gfxOffset);
    const gfxCount = definition.assembly[gfxPath].arrayLength;
    is3bppList.push(new Array(gfxCount).fill(true));  // default is 3bpp
  }

  // set the graphics pointer for each monster
  const gfxPropArray = definition.obj.monsterGraphicsProperties;
  for (let gfxProp of gfxPropArray) {

    // get the graphics pointer and bank
    const bank = gfxProp.graphicsBank;
    const gfxIndex = gfxProp[`graphicsIndex${bank + 1}`];

    // get the unmapped graphics pointer
    const gfxPath = `monsterGraphics${bank + 1}`;
    const gfxRangeString = definition.assembly[gfxPath].itemRanges[gfxIndex];
    const gfxRange = new ROMRange(gfxRangeString);
    const mappedPtr = memoryMap.mapAddress(gfxRange.begin);
    gfxProp.graphicsPointer = (mappedPtr - gfxOffsetList[bank]) >> 3;

    is3bppList[bank][gfxIndex] = gfxProp.is3bpp;
  }

  // don't assembly the graphics index
  const gfxPropDef = definition.assembly.monsterGraphicsProperties.assembly.assembly;
  gfxPropDef.graphicsIndex1.invalid = true;
  gfxPropDef.graphicsIndex2.invalid = true;
  gfxPropDef.graphicsIndex3.invalid = true;
  gfxPropDef.graphicsIndex4.invalid = true;
  gfxPropDef.graphicsIndex5.invalid = true;

  // encode 3bpp and 4bpp monster graphics
  const dataCodec3bpp = new ROMDataCodec('snes3bpp');
  const dataCodec4bpp = new ROMDataCodec('snes4bpp');
  for (let bank = 0; bank < 5; bank++) {
    const gfxPath = `monsterGraphics${bank + 1}`;
    const gfxCount = definition.assembly[gfxPath].arrayLength;
    for (let r = 0; r < gfxCount; r++) {
      const rawGfxBase64 = Buffer.from(definition.obj[gfxPath][r], 'base64');
      const rawGfx = new Uint8Array(rawGfxBase64);
      let decodedData;
      if (is3bppList[bank][r]) {
        decodedGfx = dataCodec3bpp.encode(rawGfx);
      } else {
        decodedGfx = dataCodec4bpp.encode(rawGfx);
      }
      definition.obj[gfxPath][r] = Buffer.from(decodedGfx).toString('base64');
    }
  }
}

function encodeTreasureIndex(definition) {
  let isDirty = definition.assembly.mapTriggers1.isDirty;
  isDirty |= definition.assembly.mapTriggers2.isDirty;
  if (!isDirty) return

  let t = 0;
  for (let m = 0; m < definition.obj.mapProperties.length; m++) {

    // reset to zero for underground/moon treasures
    if (m === 256) t = 0;
    definition.obj.mapProperties[m].treasure = t;

    let triggerArray;
    if (m < 256) {
      triggerArray = definition.obj.mapTriggers1[m];
    } else {
      triggerArray = definition.obj.mapTriggers2[m - 256];
    }
    for (const trigger of triggerArray) {
      if (trigger.map === 0xFE) t++;
    }

    if (t > 256) {
      throw 'Treasure overflow: data contains more than 256 treasures';
    }
  }
}

// load the data file
const dataPath = process.argv[2];
const romDefinitionFile = fs.readFileSync(dataPath);
const romDefinition = JSON.parse(romDefinitionFile);

const encoder = new ROMEncoder(romDefinition);

try {
  encodeMonsterGfx(romDefinition);
  encodeTreasureIndex(romDefinition);

  // encode the level progression data
  const levelUpPropLow = romDefinition.obj.LevelUpPropLow;
  const levelUpPropHigh = romDefinition.obj.LevelUpPropHigh;
  const levelUpDefLow = romDefinition.assembly.LevelUpPropLow.assembly;
  const levelUpDefHigh = romDefinition.assembly.LevelUpPropHigh.assembly;

  if (levelUpDefLow.isDirty || levelUpDefHigh.isDirty) {
    let encodedLevelArray = [];
    for (let i = 0; i < levelUpPropLow.length; i++) {
      // encode low level data and high level data separately
      const lowLevelObj = levelUpPropLow[i];
      const lowLevelData = encoder.encodeArray(lowLevelObj, levelUpDefLow);

      const highLevelObj = levelUpPropHigh[i];
      const highLevelData = encoder.encodeArray(highLevelObj, levelUpDefHigh);

      const combinedData = new Uint8Array(lowLevelData.length + 8);
      combinedData.set(lowLevelData);
      combinedData.set(highLevelData, lowLevelData.length);

      const encodedLevelData = Buffer.from(combinedData).toString('base64');
      encodedLevelArray.push(encodedLevelData);

    }
    romDefinition.obj.LevelUpProp = encodedLevelArray;
    romDefinition.assembly.LevelUpProp.isDirty = true;
  }

} catch(e) {
  console.log(e);
  process.exit(1);
}

encoder.encodeROM(romDefinition);

process.exit(0);
