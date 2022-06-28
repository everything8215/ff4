
const ROMRange = require('./rom-range');

class ROMMemoryMap {
    constructor(mode) {
        this.mode = mode;
    }

    bankSize() {
        switch (this.mode) {
            case ROMMemoryMap.MapMode.mmc1: return 0x4000;
            case ROMMemoryMap.MapMode.mmc3: return 0x2000;
            case ROMMemoryMap.MapMode.loROM: return 0x8000;
            case ROMMemoryMap.MapMode.hiROM: return 0x10000;
            case ROMMemoryMap.MapMode.x16: return 0x2000;
            case ROMMemoryMap.MapMode.wsc: return 0x10000;
            default: return 0x10000;
        }
    }

    mapAddress(address) {
        switch (this.mode) {
            case ROMMemoryMap.MapMode.mmc1:
                var bank = address & 0xFF0000;
                return (bank >> 2) + (address & 0x3FFF) + 0x10;

            case ROMMemoryMap.MapMode.mmc3:
                var bank = address & 0xFF0000;
                return (bank >> 3) + (address & 0x1FFF) + 0x10;

            case ROMMemoryMap.MapMode.loROM:
                var bank = address & 0xFF0000;
                return (bank >> 1) + (address & 0x7FFF);

            case ROMMemoryMap.MapMode.hiROM:
                if (address >= 0xC00000) {
                    return address - 0xC00000;
                } else if (address >= 0x800000) {
                    return address - 0x800000;
                } else {
                    return address;
                }

            case ROMMemoryMap.MapMode.gba:
                if (address >= 0x08000000) {
                    return address - 0x08000000;
                } else {
                    return address;
                }

            case ROMMemoryMap.MapMode.x16:
                var bank = address & 0xFF0000;
                bank -= 0x010000;
                return (bank >> 3) + (address & 0x1FFF) + 2;

            case ROMMemoryMap.MapMode.wsc:
                if (address < 0x10000000) return address;  // raw address
                var bank = (address >> 12) & 0xFF0000;
                return bank + (address & 0xFFFF);

            case ROMMemoryMap.MapMode.None:
            default:
                return address;
        }
    }

    unmapAddress(address) {
        switch (this.mode) {
            case ROMMemoryMap.MapMode.mmc1:
                address -= 0x10; // iNES header
                var bank = (address << 2) & 0xFF0000;
                return bank | (address & 0x3FFF) | 0x8000;

            case ROMMemoryMap.MapMode.mmc3:
                address -= 0x10; // iNES header
                var bank = (address << 3) & 0xFF0000;
                if (bank & 0x010000) {
                    return bank | (address & 0x1FFF) | 0xA000;
                } else {
                    return bank | (address & 0x1FFF) | 0x8000;
                }

            case ROMMemoryMap.MapMode.loROM:
                var bank = (address << 1) & 0xFF0000;
                return bank | (address & 0x7FFF) | 0x8000;

            case ROMMemoryMap.MapMode.hiROM:
                return address + 0xC00000;

            case ROMMemoryMap.MapMode.gba:
                return address | 0x08000000;

            case ROMMemoryMap.MapMode.x16:
                address -= 2; // header
                var bank = (address << 3) & 0xFF0000;
                bank += 0x010000;
                return bank | (address & 0x1FFF) | 0xA000;

            case ROMMemoryMap.MapMode.wsc:
                if (address > 0x0F0000) return address;  // raw address
                var bank = (address & 0x0F0000) << 12;
                return bank | (address & 0xFFFF);

            case ROMMemoryMap.MapMode.None:
            default:
                return address;
        }
    }

    mapRange(range) {
        var begin = this.mapAddress(range.begin);
        var end = this.mapAddress(range.end);
        return new ROMRange(begin, end);
    }

    unmapRange(range) {
        var begin = this.unmapAddress(range.begin);
        var end = this.unmapAddress(range.end);
        return new ROMRange(begin, end);
    }
}

ROMMemoryMap.MapMode = {
    none: "none",
    mmc1: "mmc1",
    mmc3: "mmc3",
    loROM: "loROM",
    hiROM: "hiROM",
    gba: "gba",
    x16: "x16",
    psx: "psx",
    wsc: "wsc"
}

module.exports = ROMMemoryMap;
