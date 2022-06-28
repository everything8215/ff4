
const RipROM = require('./romtools/rip-rom');
const hexString = require('./romtools/hex-string');
const fs = require('fs');
const CRC32 = require('crc-32');

// search the vanilla directory for valid ROM files
const files = fs.readdirSync('vanilla');

let foundOneROM = false;

for (let filename of files) {
    const path = `vanilla/${filename}`;
    stats = fs.statSync(path);
    if (stats.isDirectory()) continue;

    const file = fs.readFileSync(path);
    const crc32 = CRC32.buf(file) >>> 0;

    switch (crc32) {
        case 0x21027C5D:
            console.log('Found ROM: Final Fantasy IV 1.0 (J)');
            RipROM(path, 'vanilla/ff4-jp-rip.json');
            foundOneROM = true;
            break;

        case 0xCAA15E97:
            console.log('Found ROM: Final Fantasy IV 1.1 (J)');
            RipROM(path, 'vanilla/ff4-jp-rip.json');
            foundOneROM = true;
            break;

        case 0x65D0A825:
            console.log('Found ROM: Final Fantasy II 1.0 (U)');
            RipROM(path, 'vanilla/ff4-en-rip.json');
            foundOneROM = true;
            break;

        case 0x23084FCD:
            console.log('Found ROM: Final Fantasy II 1.1 (U)');
            RipROM(path, 'vanilla/ff4-en-rip.json');
            foundOneROM = true;
            break;

        default:
            break;
    }
}

if (!foundOneROM) {
    console.log('No valid ROM files found!\n' +
        'Please copy your valid FF4 ROM file(s) into the "vanilla" directory.\n' +
        'If your ROM has a header, remove it first.')
}

process.exit(0);
