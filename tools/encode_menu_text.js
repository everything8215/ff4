#!/usr/bin/node

const fs = require('fs');
const isString = require('is-string');
const isNumber = require('is-number');
const isArray = require('isarray');

class ROMTextEncoding {
    constructor(definition, charTables) {

        this.encodingTable = {};
        this.decodingTable = [];

        if (!isArray(definition.charTable)) { return; }
        for (let i = 0; i < definition.charTable.length; i++) {
            const charTableKey = definition.charTable[i];
            const charTable = charTables[charTableKey];
            if (!charTable) continue;
            const keys = Object.keys(charTable.char);
            for (let c = 0; c < keys.length; c++) {
                const key = keys[c];
                const value = charTable.char[key];
                this.decodingTable[Number(key)] = value;
                this.encodingTable[value] = Number(key);
            }
        }
    }

    encode(text) {
        let data = [];
        let i = 0;
        const keys = Object.keys(this.encodingTable);

        while (i < text.length) {
            var remainingText = text.substring(i);
            var matches = keys.filter(function(s) {
                return remainingText.startsWith(s);
            });

            if (!matches.length && remainingText.startsWith('\\x')) {
                parameter = `0${remainingText.substring(1, 4)}`;
                i += 4;
                const n = Number(parameter);
                if (!isNumber(n)) {
                    console.log(`Invalid value: ${parameter}`);
                } else {
                    data.push(n);
                }
                continue;

            } else if (!matches.length) {
                console.log(`Invalid character: ${remainingText[0]}`);
                i++;
                continue;
            }

            var match = matches.reduce(function (a, b) {
                return a.length > b.length ? a : b;
            });

            // end of string
            if (match === "\\0") break;

            var value = this.encodingTable[match];
            i += match.length;

            if (match.endsWith("[[")) {
                // 2-byte parameter
                var end = text.indexOf("]]", i);
                var parameter = text.substring(i, end);
                var n = Number(parameter);
                if (!isNumber(n) || n > 0xFFFF) {
                    console.log("Invalid parameter: " + parameter);
                    n = 0;
                    end = i;
                }
                i = end + 2;
                value <<= 16;
                value |= n;
            } else if (match.endsWith("[")) {
                // 1-byte parameter
                var end = text.indexOf("]", i);
                var parameter = text.substring(i, end);
                var n = Number(parameter);
                if (!isNumber(n) || n > 0xFF) {
                    console.log("Invalid parameter: " + parameter);
                    n = 0;
                    end = i;
                }
                i = end + 1;
                value <<= 8;
                value |= n;
            }

            if (value > 0xFF) {
                data.push(value >> 8);
                data.push(value & 0xFF);
            } else {
                data.push(value);
            }
        }

        var terminator = this.encodingTable["\\0"];
        if (isNumber(terminator) && data[data.length - 1] !== terminator) {
            data.push(terminator);
        }

        return Uint8Array.from(data);
    }
}

const langSuffix = process.argv[2] || 'jp';

let menuStrPath, outputPath, definitionPath;

menuStrPath = `../include/menu_text_${langSuffix}.json`;
outputPath = `text/menu_text_${langSuffix}.inc`;
definitionPath = `../vanilla/ff4-${langSuffix}-rip.json`;

const menuStrFile = fs.readFileSync(menuStrPath);
const menuStr = JSON.parse(menuStrFile);

const romDefinitionFile = fs.readFileSync(definitionPath);
const romDefinition = JSON.parse(romDefinitionFile);

const encodingDefinition = romDefinition.textEncoding.menuText;
const charTables = romDefinition.charTable;
const encoding = new ROMTextEncoding(encodingDefinition, charTables);

let bigString = '';
for (let label in menuStr) {
    const str = menuStr[label];
    const strData = encoding.encode(str);
    bigString += `.define ${label} `;
    for (let i = 0; i < strData.length; i++) {
        if (i !== 0) {
            bigString += ',';
        }
        bigString += '$' + strData[i].toString(16).padStart(2, '0');
    }
    bigString += '\n';
}

fs.writeFileSync(outputPath, bigString);

process.exit(0);
