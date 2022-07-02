// data-manager.js

const ROMTextCodec = require('./text-codec');
const ROMMemoryMap = require('./memory-map');

class ROMDataManager {
  constructor(data) {

    this.data = data;

    // create the memory mapper
    const mapMode = data.mode || ROMMemoryMap.MapMode.none;
    this.memoryMap = new ROMMemoryMap(mapMode);

    // create text codecs
    this.textCodec = {};
    for (let key in data.textEncoding) {
      const encodingDef = data.textEncoding[key];
      this.textCodec[key] = new ROMTextCodec(encodingDef, data.charTable);
    }

    // create string tables

  }
}

module.exports = ROMDataManager;
