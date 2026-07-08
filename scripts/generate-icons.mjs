// Generates PLACEHOLDER PWA icons (solid brand-emerald squares) with zero
// dependencies — a tiny hand-rolled PNG encoder (Node built-ins only).
// These stand in until the branded icon set lands; re-run with `pnpm icons`.
// Outputs:
//   app/icon.png                       (favicon, auto-detected by Next)
//   app/apple-icon.png                 (apple touch icon, auto-detected by Next)
//   public/icons/icon-192.png          (manifest, purpose any)
//   public/icons/icon-512.png          (manifest, purpose any)
//   public/icons/icon-192-maskable.png (manifest, purpose maskable)
//   public/icons/icon-512-maskable.png (manifest, purpose maskable)

import { deflateSync } from "node:zlib";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = resolve(__dirname, "..");

// Placeholder deep emerald (#065F46). Prompt 5 replaces with the real brand icon.
const COLOR = [6, 95, 70];

const CRC_TABLE = (() => {
  const table = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) {
      c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    }
    table[n] = c >>> 0;
  }
  return table;
})();

function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) {
    c = CRC_TABLE[(c ^ buf[i]) & 0xff] ^ (c >>> 8);
  }
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const typeBuf = Buffer.from(type, "ascii");
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])), 0);
  return Buffer.concat([len, typeBuf, data, crc]);
}

function solidPng(size, [r, g, b]) {
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);

  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(size, 0);
  ihdr.writeUInt32BE(size, 4);
  ihdr[8] = 8; // bit depth
  ihdr[9] = 2; // colour type: RGB
  ihdr[10] = 0; // compression
  ihdr[11] = 0; // filter
  ihdr[12] = 0; // interlace

  const rowLength = size * 3 + 1;
  const raw = Buffer.alloc(rowLength * size);
  for (let y = 0; y < size; y++) {
    const rowStart = y * rowLength;
    raw[rowStart] = 0; // filter type: none
    for (let x = 0; x < size; x++) {
      const px = rowStart + 1 + x * 3;
      raw[px] = r;
      raw[px + 1] = g;
      raw[px + 2] = b;
    }
  }

  const idat = deflateSync(raw, { level: 9 });

  return Buffer.concat([
    signature,
    chunk("IHDR", ihdr),
    chunk("IDAT", idat),
    chunk("IEND", Buffer.alloc(0)),
  ]);
}

function write(relPath, size) {
  const outPath = resolve(root, relPath);
  mkdirSync(dirname(outPath), { recursive: true });
  writeFileSync(outPath, solidPng(size, COLOR));
  console.log(`  ✓ ${relPath} (${size}×${size})`);
}

console.log("Generating placeholder PWA icons…");
write("app/icon.png", 256);
write("app/apple-icon.png", 180);
write("public/icons/icon-192.png", 192);
write("public/icons/icon-512.png", 512);
write("public/icons/icon-192-maskable.png", 192);
write("public/icons/icon-512-maskable.png", 512);
console.log("Done.");
