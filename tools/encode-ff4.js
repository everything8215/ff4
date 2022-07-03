#!/usr/bin/env node

const encodeROM = require('./romtools/encode-rom');

const dataPath = process.argv[2];
encodeROM(dataPath);
