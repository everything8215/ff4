// encode-rom.js

const fs = require('fs');
const getDirName = require('path').dirname;
const isArray = require('isarray');
const ROMDataCodec = require('./data-codec');
const ROMDataManager = require('./data-manager');
const ROMRange = require('./range');
const hexString = require('./hex-string');

let dataMgr;

function findSubarray(arr, subarr) {

  for (let i = 0; i < 1 + (arr.length - subarr.length); i++) {
    let found = true;
    for (let j = 0; j < subarr.length; j++) {
      if (arr[i + j] !== subarr[j]) {
        found = false;
        break;
      }
    }
    if (found) return i;
  }
  return -1;
}

function encodeArray(obj, definition, data) {

  let pointers = [];
  if (definition.itemLength) {
    // fixed-length array items
    const length = definition.itemLength;
    let totalLength = length * obj.length;
    data = new Uint8Array(totalLength);
    for (let i = 0; i < obj.length; i++) {
      const begin = i * length;
      pointers.push(begin);
      let itemData = new Uint8Array(length);
      itemData = encodeObject(obj[i], definition.assembly, itemData);
      data.set(itemData, begin);
    }

  } else {
    // sequential array items
    let totalLength = 0;
    let dataArray = [];
    for (let i = 0; i < obj.length; i++) {
      pointers.push(totalLength);
      const itemData = encodeObject(obj[i], definition.assembly, null);
      dataArray.push(itemData);
      totalLength += itemData.length;
    }
    data = new Uint8Array(totalLength);
    for (let i = 0; i < obj.length; i++) {
      data.set(dataArray[i], pointers[i]);
    }
  }

  return data;
}

function encodeProperty(obj, definition, data) {

  let value = obj;

  // modify the value if needed
  if (definition.bool) value = (value ? 1 : 0);

  // calculate the index of the first bit
  let mask = Number(definition.mask) || 0xFF;
  let bitIndex = 0;
  let firstBit = 1;
  while (!(firstBit & mask)) {
    bitIndex++;
    firstBit <<= 1;
  }

  // shift and mask the value
  value = (value << bitIndex) & mask;

  // find the beginning and end of this property
  const begin = Number(definition.begin) || 0;
  let end = begin;
  let byteMask = 0xFF;
  while (byteMask & mask) {
    byteMask <<= 8;
    end++;
  }

  // validate the data length
  if (!data) {
    data = new Uint8Array(end);
  } else if (end > data.length) {
    let newData = new Uint8Array(end);
    newData.set(data);
    data = newData;
  }

  // copy property value to data
  let unmask = (~mask) >>> 0;
  for (let i = begin; i < end; i++) {
      data[i] &= (unmask & 0xFF);
      data[i] |= (value & 0xFF);
      unmask >>= 8;
      value >>= 8;
  }

  return data;
}

function encodeObject(obj, definition, data) {

  // default definition is raw data
  definition = definition || { type: 'data' };

  if (definition.type === 'text') {
    const encodingKey = definition.encoding;
    const textCodec = dataMgr.textCodec[encodingKey];
    const begin = definition.begin || 0;
    const textData = textCodec.encode(obj);
    if (data) {
      const padValue = textCodec.getPadValue();
      data.fill(padValue, begin);
      data.set(textData, begin);
    } else {
      data = textData;
    }

  } else if (definition.type === 'assembly') {
    for (let key in obj) {
      const subDefinition = definition.assembly[key];
      data = encodeObject(obj[key], subDefinition, data);
    }

  } else if (definition.type === 'array') {
    data = encodeArray(obj, definition, data);

  } else if (definition.type === 'property') {
    data = encodeProperty(obj, definition, data);

  } else {
    data = new Uint8Array(Buffer.from(obj, 'base64'));
  }

  if (definition.format) {
    const dataCodec = new ROMDataCodec(definition.format);
    data = dataCodec.encode(data);
  }
  return data;
}

function encodeParentObject(key) {
  const definition = dataMgr.getDefinition(key);
  const obj = dataMgr.getObject(key);
  if (isArray(obj) ^ (definition.type === 'array')) {
    console.log(`Object/definition mismatch: ${key}`);
    return;
  }

  let objData;
  let pointers = [];
  if (definition.isSequential || (definition.terminator !== undefined)) {
    // sequential array items
    let totalLength = 0;
    let dataArray = [];
    for (let i = 0; i < obj.length; i++) {
      pointers.push(totalLength);
      const itemData = encodeObject(obj[i], definition.assembly, null);
      dataArray.push(itemData);
      totalLength += itemData.length;
    }
    objData = new Uint8Array(totalLength);
    for (let i = 0; i < obj.length; i++) {
      objData.set(dataArray[i], pointers[i]);
    }

  } else if (definition.itemLength) {
    // fixed-length array items
    const length = definition.itemLength;
    let totalLength = length * obj.length;
    objData = new Uint8Array(totalLength);
    for (let i = 0; i < obj.length; i++) {
      const begin = i * length;
      pointers.push(begin);
      let itemData = new Uint8Array(length);
      itemData = encodeObject(obj[i], definition.assembly, itemData);
      objData.set(itemData, begin);
    }

  } else if (isArray(obj)) {
    // shared array items
    objData = new Uint8Array(0);
    for (let i = 0; i < obj.length; i++) {
      const itemData = encodeObject(obj[i], definition.assembly, null);
      let offset = findSubarray(objData, itemData);
      if (offset === -1) {
        // data not found
        offset = objData.length;
        const newData = new Uint8Array(offset + itemData.length);
        newData.set(objData);
        newData.set(itemData, offset);
        objData = newData;
      }
      pointers.push(offset);
    }

  } else {
    // single object
    objData = encodeObject(obj, definition, null);
    pointers.push(0);
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

  let asmString = '';
  asmString += '.list off\n';
  asmString += '\n';
  asmString += `.define ${asmSymbol}Size`;
  asmString += ` ${hexString(objData.length, 4, '$')}\n`;
  if (definition.arrayLength) {
    asmString += `.define ${asmSymbol}ArrayLength`;
    asmString += ` ${definition.arrayLength}\n`;
  }
  // if (definition.itemLength) {
  //   asmString += `.define ${asmSymbol}ItemLength`;
  //   asmString += ` ${definition.itemLength}\n`;
  // }

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
}

function encodeROM(definitionPath) {
  // load the data file
  const romDefinitionFile = fs.readFileSync(definitionPath);
  const romDefinition = JSON.parse(romDefinitionFile);

  dataMgr = new ROMDataManager(romDefinition);

  for (let key in romDefinition.assembly) {
    const objDefinition = romDefinition.assembly[key];
    if (!objDefinition.file) continue;
    if (objDefinition.isDirty) {
      console.log(`Encoding ${objDefinition.asmSymbol}`);
      encodeParentObject(key);
    }
  }
}

module.exports = encodeROM;
