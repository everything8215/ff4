// decode-rom.js

const fs = require('fs');
const getDirName = require('path').dirname;
const isString = require('is-string');
const ROMDataCodec = require('./data-codec');
const ROMDataManager = require('./data-manager');
const ROMRange = require('./range');
const hexString = require('./hex-string');

let dataMgr, romData;

function decodeArray(data, definition) {
  let array = [];

  if (definition.terminator === '\\0') {
    // null-terminated text
    if (!definition.assembly || !definition.assembly.encoding) {
      console.log('Invalid null-terminated text definition');
      return array;
    }
    const encodingKey = definition.assembly.encoding;
    const textCodec = dataMgr.textCodec[encodingKey];
    let begin = 0;
    while (begin < data.length) {
      end = begin + textCodec.textLength(data.subarray(begin));
      const itemData = data.slice(begin, end);
      const itemObj = decodeObject(itemData, definition.assembly);
      array.push(itemObj);
      begin = end;
    }

  } else if (definition.terminator !== undefined) {
    // terminated items
    const terminator = Number(definition.terminator);
    let begin = 0;
    let end = 0;
    while (end < data.length) {
      if (data[end] === terminator) {
        const itemData = data.slice(begin, end + 1);
        const itemObj = decodeObject(itemData, definition.assembly);
        array.push(itemObj);
        begin = end + 1;
      }
      end++;
    }

    // data at end with no terminator
    if (begin !== end) {
      console.log(`Invalid terminated array item`);
    }

  } else if (definition.itemLength) {
    // fixed length items
    const length = definition.itemLength;
    let begin = 0;
    while (begin < data.length) {
      const itemData = data.slice(begin, begin + length);
      const itemObj = decodeObject(itemData, definition.assembly);
      array.push(itemObj);
      begin += length;
    }

  } else {
    console.log('Invalid sub-array');
  }

  return array;
}

function decodeProperty(data, definition) {

  // calculate the index of the first bit
  let mask = Number(definition.mask) || 0xFF;
  let bitIndex = 0;
  let firstBit = 1;
  while (!(firstBit & mask)) {
    bitIndex++;
    firstBit <<= 1;
  }

  let value = 0;
  const begin = Number(definition.begin) || 0;
  const end = Math.min(begin + 3, data.length - 1);
  for (let i = end; i >= begin; i--) {
      value <<= 8;
      value |= data[i];
  }
  value = (value & mask) >> bitIndex;
  if (definition.bool) return (value !== 0);
  return value;
}

function decodeObject(data, definition) {

  // default definition is raw data
  definition = definition || { type: 'data' };

  // decode the data
  const dataCodec = new ROMDataCodec(definition.format);
  const decodedData = dataCodec.decode(data);

  if (definition.type === 'text') {
    const encodingKey = definition.encoding;
    const textCodec = dataMgr.textCodec[encodingKey];
    const begin = definition.begin || 0;
    const textData = data.slice(begin);
    return textCodec.decode(textData);

  } else if (definition.type === 'assembly') {
    let assembly = {};
    for (let key in definition.assembly) {
      const subDefinition = definition.assembly[key];
      if (isString(subDefinition)) continue;
      if (subDefinition.external) continue;
      assembly[key] = decodeObject(decodedData, subDefinition);
    }
    return assembly;

  } else if (definition.type === 'array') {
    return decodeArray(decodedData, definition);

  } else if (definition.type === 'property') {
    return decodeProperty(decodedData, definition);

  } else {
    return dataBase64 = Buffer.from(decodedData).toString('base64');
  }
}

function decodeParentObject(definition) {

  // calculate the appropriate ROM range using the mapper
  const unmappedRange = new ROMRange(definition.range);
  const mappedRange = dataMgr.memoryMap.mapRange(unmappedRange);

  // extract the array data
  const objData = romData.slice(mappedRange.begin, mappedRange.end);

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
      ptrOffset = dataMgr.memoryMap.mapAddress(ptrOffset);
    }

    // extract the pointer table data
    let ptrRange = new ROMRange(ptrDefinition.range);
    ptrRange = dataMgr.memoryMap.mapRange(ptrRange);
    const ptrData = romData.subarray(ptrRange.begin, ptrRange.end);
    const pointerSize = ptrDefinition.pointerSize || 2;

    for (let i = 0; i < (ptrData.length / pointerSize); i++) {
      let pointer = 0;
      pointer |= ptrData[i * pointerSize];
      pointer |= ptrData[i * pointerSize + 1] << 8;
      if (pointerSize > 2) {
        pointer |= ptrData[i * pointerSize + 2] << 16;
      }
      pointer += ptrOffset;
      if (isMapped) {
        // map pointer after adding to pointer offset
        pointer = dataMgr.memoryMap.mapAddress(pointer);
      }
      pointers.push(pointer - mappedRange.begin);
    }

  } else if (definition.itemRanges) {
    for (let i = 0; i < definition.arrayLength; i++) {
      const range = new ROMRange(definition.itemRanges[i]);
      const pointer = dataMgr.memoryMap.mapAddress(range.begin);
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
    for (let i = 0; i < definition.arrayLength; i++) {
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
  for (let i = 0; i < definition.arrayLength; i++) {
    const begin = pointers[i];
    if (definition.terminator !== undefined) {
      let end = begin;
      const terminator = Number(definition.terminator);
      while (end < objData.length) {
        if (objData[end] === terminator) break;
        end++;
      }
      const range = new ROMRange(begin, end + 1);
      itemRanges.push(range);
    } else {
      itemRanges.push(pointerRanges[begin]);
    }

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

  if (!fs.existsSync(definition.file)) {
    let asmString = '';
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
      for (let b = 0; b < pointerData.length; b++) {
        if (b % 16 == 0) {
          asmString += '\n        .byte   ';
        } else {
          asmString += ',';
        }
        asmString += hexString(pointerData[b], 2, '$').toLowerCase();
      }
      asmString += '\n';
    }
    asmString += '\n.list on\n';

    const asmPath = definition.file;
    fs.mkdirSync(getDirName(asmPath), { recursive: true });
    fs.writeFileSync(asmPath, asmString);

    console.log(`${unmappedRange} ${asmSymbol} -> ${definition.file}`);
  }

  if (isArray) {
    // create each array item
    const array = [];
    for (i = 0; i < itemRanges.length; i++) {
      const itemRange = itemRanges[i];
      const itemData = objData.slice(itemRange.begin, itemRange.end);
      array[i] = decodeObject(itemData, definition.assembly);
    }
    return array;
  } else {
    return decodeObject(objData, definition);
  }
}

function decodeROM(romPath, definitionPath) {
  // load the definition file
  const romDefinitionFile = fs.readFileSync(definitionPath);
  const romDefinition = JSON.parse(romDefinitionFile);

  dataMgr = new ROMDataManager(romDefinition);

  // load the ROM file
  romData = new Uint8Array(fs.readFileSync(romPath));

  romDefinition.data = {};
  for (let key in romDefinition.assembly) {
    const objDefinition = romDefinition.assembly[key];
    if (!objDefinition.file) continue;
    romDefinition.data[key] = decodeParentObject(objDefinition);
  }

  return romDefinition;
}

module.exports = decodeROM;
