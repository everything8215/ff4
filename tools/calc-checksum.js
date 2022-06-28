#!/usr/bin/node

const fs = require('fs');
const hexString = require('./romtools/hex-string');

calcChecksum = function(data) {

    function calcSum(data) {
        let sum = 0;
        for (let i = 0; i < data.length; i++) sum += data[i];
        return sum & 0xFFFF;
    }

    function mirrorSum(data, mask) {
        while (!(data.length & mask)) mask >>= 1;

        const part1 = calcSum(data.slice(0, mask));
        let part2 = 0;

        let nextLength = data.length - mask;
        if (nextLength) {
            part2 = mirrorSum(data.slice(mask), nextLength, mask >> 1);

            while (nextLength < mask) {
                nextLength += nextLength;
                part2 += part2;
            }
        }
        return (part1 + part2) & 0xFFFF;
    }

    return mirrorSum(data, 0x800000);
}

// load the ROM file
const romPath = process.argv[2];
const romBuffer = fs.readFileSync(romPath);
const romData = new Uint8Array(romBuffer);

const checksum = calcChecksum(romData);
const checksumInverse = checksum ^ 0xFFFF;

console.log(`SNES Checksum: ${hexString(checksum, 4)}`);

romData[0x7FDC] = checksumInverse & 0xFF;
romData[0x7FDD] = checksumInverse >> 8;
romData[0x7FDE] = checksum & 0xFF;
romData[0x7FDF] = checksum >> 8;

fs.writeFileSync(romPath, romData);

process.exit(0);
