#!/usr/bin/env node

const fs = require('fs');
const isString = require('is-string');
const isNumber = require('is-number');
const isArray = require('isarray');
const hexString = require('./romtools/hex-string');
const ROMTextCodec = require('./romtools/text-codec');

const langSuffix = process.argv[2] || 'jp';

const menuStrPath = `../include/menu_text_${langSuffix}.json`;
const outputPath = `text/menu_text_${langSuffix}.inc`;
const definitionPath = `../vanilla/ff4-${langSuffix}-rip.json`;

const menuStrFile = fs.readFileSync(menuStrPath);
const menuStr = JSON.parse(menuStrFile);

const romDefinitionFile = fs.readFileSync(definitionPath);
const romDefinition = JSON.parse(romDefinitionFile);

const encodingDefinition = romDefinition.textEncoding.menuText;
const charTables = romDefinition.charTable;
const codec = new ROMTextCodec(encodingDefinition, charTables);

let bigString = '';
for (let label in menuStr) {
  const str = menuStr[label];
  const strData = codec.encode(str);
  bigString += `.define ${label} `;
  for (let i = 0; i < strData.length; i++) {
    if (i) bigString += ',';
    bigString += hexString(strData[i], 2, '$');
  }
  bigString += '\n';
}

fs.writeFileSync(outputPath, bigString);

process.exit(0);
