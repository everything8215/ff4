// rip-rom.js

const fs = require('fs');
const getDirName = require('path').dirname;
const ROMDataCodec = require('./rom-data-codec');
const ROMMemoryMap = require('./rom-memory-map');
const ROMRange = require('./rom-range');
const hexString = require('./hex-string');

let memoryMap, romData;

function RipObject(definition) {

    // calculate the appropriate ROM range using the mapper
    const unmappedRange = new ROMRange(definition.range);
    const mappedRange = memoryMap.mapRange(unmappedRange);

    // extract the array data
    const objData = romData.subarray(mappedRange.begin, mappedRange.end);

    // decode the data
    const codec = new ROMDataCodec(definition.format);
    const decodedData = codec.decode(objData);

    // make a list of pointers
    let pointers = [];
    let isArray = true;

    if (definition.pointerTable) {

        // extract the pointer table
        const ptrDefinition = definition.pointerTable;
        const isMapped = ptrDefinition.isMapped;
        let ptrOffset = Number(ptrDefinition.offset);
        if (!isMapped) {
            // map pointer offset first, then add pointers
            ptrOffset = memoryMap.mapAddress(ptrOffset);
        }

        // extract the pointer table data
        let ptrRange = new ROMRange(ptrDefinition.range);
        ptrRange = memoryMap.mapRange(ptrRange);
        const ptrData = romData.subarray(ptrRange.begin, ptrRange.end);
        const pointerSize = ptrDefinition.pointerSize || 2;

        for (var i = 0; i < (ptrData.length / pointerSize); i++) {
            let pointer = 0;
            pointer |= ptrData[i * pointerSize];
            pointer |= ptrData[i * pointerSize + 1] << 8;
            if (pointerSize > 2) {
                pointer |= ptrData[i * pointerSize + 2] << 16;
            }
            pointer += ptrOffset;
            if (isMapped) {
                // map pointer after adding to pointer offset
                pointer = memoryMap.mapAddress(pointer);
            }
            pointers.push(pointer - mappedRange.begin);
        }

    } else if (definition.itemRanges) {
        for (var i = 0; i < definition.arrayLength; i++) {
            const range = new ROMRange(definition.itemRanges[i]);
            const pointer = memoryMap.mapAddress(range.begin);
            pointers.push(pointer - mappedRange.begin);
        }

    } else if (definition.terminator !== undefined) {
        // terminated items
        const terminator = Number(definition.terminator);
        pointers.push(0);
        for (let p = 0; p < (objData.length - 1); p++) {
            if (objData[p] === terminator) {
                pointers.push(p + 1);
            }
        }

    } else if (definition.itemLength) {
        // fixed length items
        const length = definition.itemLength;
        for (var i = 0; i < definition.arrayLength; i++) {
            pointers.push(i * length);
        }
    } else {
        // single object
        pointers.push(0);
        isArray = false;
    }

    // remove duplicates and sort pointers
    const sortedPointers = [...new Set(pointers)].sort(function(a, b) {
        return a - b;
    });

    // create a list of pointer ranges (these may not correspond
    // with item ranges in some cases)
    let pointerRanges = {};
    for (let p = 0; p < sortedPointers.length; p++) {
        const begin = sortedPointers[p];
        let end = objData.length;
        if (p !== (sortedPointers.length - 1)) {
            end = sortedPointers[p + 1];
        }
        pointerRanges[begin] = new ROMRange(begin, end);
    }

    const itemRanges = [];
    const labelOffsets = {};
    for (let i = 0; i < pointers.length; i++) {
        const begin = pointers[i];
        itemRanges.push(pointerRanges[begin]);
        if (isArray) {
            // add a label offset
            if (labelOffsets[begin]) {
                labelOffsets[begin].push(i);
            } else {
                labelOffsets[begin] = [i];
            }
        }
    }
    const asmSymbol = definition.asmSymbol;

    asmString = '';
    asmString += '.list off\n';
    asmString += '\n';
    asmString += `; Object Symbol: ${asmSymbol}\n`;
    asmString += `; Mapper Range:  ${unmappedRange}\n`;
    asmString += `; File Range:    ${mappedRange}\n`;
    asmString += '\n';
    asmString += `.define ${asmSymbol}Size`;
    asmString += ` ${hexString(mappedRange.length, 4, '$')}\n`;
    if (isArray) {
        asmString += `.define ${asmSymbol}ArrayLength`;
        asmString += ` ${itemRanges.length}\n`;
    }

    asmString += `\n${definition.asmSymbol}:\n`;

    for (let pointer of sortedPointers) {
        // skip if pointer is out of range
        if (pointer < 0 || pointer > objData.length) {
            continue;
        }

        const itemList = labelOffsets[pointer] || [];
        const range = pointerRanges[pointer];
        // print the label
        for (let i = 0; i < itemList.length; i++) {
            const indexString = hexString(itemList[i], 4, '').toLowerCase();
            asmString += `\n${definition.asmSymbol}_${indexString}:`;
        }

        // print the data
        const pointerData = objData.subarray(range.begin, range.end);
        for (var b = 0; b < pointerData.length; b++) {
            if (b % 16 == 0) {
                asmString += '\n        .byte   ';
            } else {
                asmString += ',';
            }
            asmString += `${hexString(pointerData[b], 2, '$').toLowerCase()}`;
        }
        asmString += '\n';
    }
    asmString += '\n.list on\n';

    // create each array item
    const array = [];
    for (i = 0; i < itemRanges.length; i++) {
        var range = itemRanges[i];
        array[i] = objData.slice(range.begin, range.end);
    }

    const asmPath = definition.file;
    fs.mkdirSync(getDirName(asmPath), { recursive: true });
    fs.writeFileSync(asmPath, asmString);

    console.log(`${unmappedRange} ${asmSymbol} -> ${definition.file}`);
}

function RipROM(romPath, definitionPath) {
    // load the definition file
    const romDefinitionFile = fs.readFileSync(definitionPath);
    const romDefinition = JSON.parse(romDefinitionFile);

    // load the ROM file
    romData = new Uint8Array(fs.readFileSync(romPath));

    const romObj = {};

    // create the memory mapper
    const mapMode = romDefinition.mode;
    memoryMap = new ROMMemoryMap(mapMode);

    for (let key in romDefinition.assembly) {
        const objDefinition = romDefinition.assembly[key];
        if (!objDefinition.file) continue;
        // skip if the file already exists
        if (fs.existsSync(objDefinition.file)) continue;
        romObj[key] = RipObject(objDefinition);
    }

    return romObj;
}

module.exports = RipROM;
