#!/usr/bin/env node

const decodeROM = require('./romtools/decode-rom');
const hexString = require('./romtools/hex-string');
const fs = require('fs');
const CRC32 = require('crc-32');

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
  const romObj = decodeROM(filePath, romInfo.ripPath);
  romObj.crc32 = hexString(crc32, 8);
  fs.writeFileSync(romInfo.dataPath, JSON.stringify(romObj, null, 2));
  foundOneROM = true;
}

if (!foundOneROM) {
  console.log('No valid ROM files found!\nPlease copy your valid FF4 ROM ' +
      'file(s) into the "vanilla" directory.\nIf your ROM has a header, ' +
      'please remove it first.');
}

process.exit(0);
