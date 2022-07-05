#!/usr/bin/env node

const fs = require('fs');
const CRC32 = require('crc-32');
const ROMDecoder = require('./romtools/rom-decoder');
const hexString = require('./romtools/hex-string');

let decoder;

function decodeLevelProg(data, definition) {
  // decode low level data and high level data separately
  const lowLevelData = data.slice(0, -8);
  const lowLevelObj = decoder.decodeArray(lowLevelData, definition.lowLevel);

  const highLevelData = data.slice(-8);
  const highLevelObj = decoder.decodeArray(highLevelData, definition.highLevel);

  return lowLevelObj.concat(highLevelObj);
}

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

  decoder = new ROMDecoder(ripDefinition);

  // load the ROM file
  const romData = new Uint8Array(fs.readFileSync(filePath));
  const romObj = decoder.decodeROM(romData, ripDefinition);
  romObj.crc32 = hexString(crc32, 8);

  // decode character level progression
  const rawLevelArray = romObj.obj.characterLevelProgression;
  const levelDataDef = ripDefinition.assembly.characterLevelProgression;
  let decodedLevelArray = [];
  for (let levelDataBase64 of rawLevelArray) {
    const rawLevelData = new Uint8Array(Buffer.from(levelDataBase64, 'base64'));
    const decodedLevelData = decodeLevelProg(rawLevelData, levelDataDef);
    decodedLevelArray.push(decodedLevelData);
  }
  romObj.obj.characterLevelProgression = decodedLevelArray;

  fs.writeFileSync(romInfo.dataPath, JSON.stringify(romObj, null, 2));
  foundOneROM = true;
}

if (!foundOneROM) {
  console.log('No valid ROM files found!\nPlease copy your valid FF4 ROM ' +
      'file(s) into the "vanilla" directory.\nIf your ROM has a header, ' +
      'please remove it first.');
}

process.exit(0);
