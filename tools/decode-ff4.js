#!/usr/bin/env node

const fs = require('fs');
const CRC32 = require('crc-32');
const ROMDataCodec = require('./romtools/data-codec');
const ROMDecoder = require('./romtools/rom-decoder');
const ROMRange = require('./romtools/range');
const hexString = require('./romtools/hex-string');

const romInfoListFF4 = {
  0x21027C5D: {
    name: 'Final Fantasy IV 1.0 (J)',
    ripPath: 'vanilla/ff4-jp-rip.json',
    dataPath: 'ff4-jp-data.json'
  },
  0xCAA15E97: {
    name: 'Final Fantasy IV 1.1 (J)',
    ripPath: 'vanilla/ff4-jp-rip.json',
    dataPath: 'ff4-jp-data.json'
  },
  0x65D0A825: {
    name: 'Final Fantasy II 1.0 (U)',
    ripPath: 'vanilla/ff4-en-rip.json',
    dataPath: 'ff4-en-data.json'
  },
  0x23084FCD: {
    name: 'Final Fantasy II 1.1 (U)',
    ripPath: 'vanilla/ff4-en-rip.json',
    dataPath: 'ff4-en-data.json'
  }
}

function ripMonsterGfx(romObj, ripDefinition, decoder) {
  // determine the graphics index for each monster
  const is3bppList = [];
  const gfxOffsetList = [];
  for (let bank = 0; bank < 5; bank++) {
    const gfxPath = `monsterGraphics${bank + 1}`;
    const gfxRange = new ROMRange(ripDefinition.assembly[gfxPath].range);
    const gfxOffset = decoder.memoryMap.mapAddress(gfxRange.begin & 0xFF0000);
    gfxOffsetList.push(gfxOffset);
    const gfxCount = ripDefinition.assembly[gfxPath].arrayLength;
    is3bppList.push(new Array(gfxCount).fill(true));  // default is 3bpp
  }
  const gfxPropArray = romObj.obj.monsterGraphicsProperties;
  const gfxPtrs = [];
  for (let gfxProp of gfxPropArray) {

    // get the graphics pointer and bank
    const bank = gfxProp.graphicsBank;
    const ptr = gfxProp[`graphicsPointer`] * 8;

    // set all of the graphics pointers to zero
    gfxProp.graphicsIndex1 = 0;
    gfxProp.graphicsIndex2 = 0;
    gfxProp.graphicsIndex3 = 0;
    gfxProp.graphicsIndex4 = 0;
    gfxProp.graphicsIndex5 = 0;

    // get the unmapped graphics pointer
    const gfxOffset = gfxOffsetList[bank];
    const unmappedPtr = decoder.memoryMap.unmapAddress(gfxOffset + ptr);

    // find the pointer in the list of item ranges for this bank
    const gfxPath = `monsterGraphics${bank + 1}`;
    const rangeList = ripDefinition.assembly[gfxPath].itemRanges;
    for (let r = 0; r < rangeList.length; r++) {
      const gfxRange = new ROMRange(rangeList[r]);
      if (gfxRange.begin !== unmappedPtr) continue;
      gfxProp[`graphicsIndex${bank + 1}`] = r;
      is3bppList[bank][r] = gfxProp.is3bpp;
      break;
    }
  }

  // enable the graphics index properties in the definition
  const gfxPropDef = romObj.assembly.monsterGraphicsProperties.assembly.assembly;
  gfxPropDef.graphicsIndex1.invalid = 'obj.graphicsBank !== 0';
  gfxPropDef.graphicsIndex2.invalid = 'obj.graphicsBank !== 1';
  gfxPropDef.graphicsIndex3.invalid = 'obj.graphicsBank !== 2';
  gfxPropDef.graphicsIndex4.invalid = 'obj.graphicsBank !== 3';
  gfxPropDef.graphicsIndex5.invalid = 'obj.graphicsBank !== 4';

  // decode 3bpp and 4bpp monster graphics
  const dataCodec3bpp = new ROMDataCodec('snes3bpp');
  const dataCodec4bpp = new ROMDataCodec('snes4bpp');
  for (let bank = 0; bank < 5; bank++) {
    const gfxPath = `monsterGraphics${bank + 1}`;
    const gfxCount = ripDefinition.assembly[gfxPath].arrayLength;
    for (let r = 0; r < gfxCount; r++) {
      const rawGfxBase64 = Buffer.from(romObj.obj[gfxPath][r], 'base64');
      const rawGfx = new Uint8Array(rawGfxBase64);
      let decodedData;
      if (is3bppList[bank][r]) {
        decodedGfx = dataCodec3bpp.decode(rawGfx);
      } else {
        decodedGfx = dataCodec4bpp.decode(rawGfx);
      }
      romObj.obj[gfxPath][r] = Buffer.from(decodedGfx).toString('base64');
    }
  }
}

function ripLevelProg(romObj, ripDefinition, decoder) {
  // decode character level progression
  const rawLevelArray = romObj.obj.LevelUpProp;
  const levelUpPropLow = ripDefinition.obj.LevelUpPropLow;
  const levelUpPropHigh = ripDefinition.obj.LevelUpPropHigh;
  const levelUpDefLow = ripDefinition.assembly.LevelUpPropLow.assembly;
  const levelUpDefHigh = ripDefinition.assembly.LevelUpPropHigh.assembly;
  let decodedLowLevelArray = [];
  let decodedHighLevelArray = [];
  for (let levelDataBase64 of rawLevelArray) {
    const rawLevelData = new Uint8Array(Buffer.from(levelDataBase64, 'base64'));

    // decode low level data and high level data separately
    const lowLevelData = rawLevelData.slice(0, -8);
    const lowLevelObj = decoder.decodeArray(lowLevelData, levelUpDefLow);
    decodedLowLevelArray.push(lowLevelObj);

    const highLevelData = rawLevelData.slice(-8);
    const highLevelObj = decoder.decodeArray(highLevelData, levelUpDefHigh);
    decodedHighLevelArray.push(highLevelObj);
  }
  romObj.obj.LevelUpPropLow = decodedLowLevelArray;
  romObj.obj.LevelUpPropHigh = decodedHighLevelArray;
}

// search the vanilla directory for valid ROM files
const files = fs.readdirSync('vanilla');

let foundOneROM = false;
for (let filename of files) {
  const filePath = `vanilla/${filename}`;
  if (fs.statSync(filePath).isDirectory()) continue;

  const fileBuf = fs.readFileSync(filePath);
  const crc32 = CRC32.buf(fileBuf) >>> 0;
  const romInfo = romInfoListFF4[crc32];
  if (!romInfo) continue;

  console.log(`Found ROM: ${romInfo.name}`);
  console.log(`File: ${filePath}`);

  // load the definition file
  const ripDefinitionFile = fs.readFileSync(romInfo.ripPath);
  const ripDefinition = JSON.parse(ripDefinitionFile);

  const decoder = new ROMDecoder(ripDefinition);

  // load the ROM file
  const romData = new Uint8Array(fs.readFileSync(filePath));
  const romObj = decoder.decodeROM(romData, ripDefinition);
  romObj.crc32 = hexString(crc32, 8);

  ripMonsterGfx(romObj, ripDefinition, decoder);
  ripLevelProg(romObj, ripDefinition, decoder);

  fs.writeFileSync(romInfo.dataPath, JSON.stringify(romObj, null, 2));
  foundOneROM = true;
}

if (!foundOneROM) {
  console.log('No valid ROM files found!\nPlease copy your valid FF4 ROM ' +
      'file(s) into the "vanilla" directory.\nIf your ROM has a header, ' +
      'please remove it first.');
}

process.exit(0);
