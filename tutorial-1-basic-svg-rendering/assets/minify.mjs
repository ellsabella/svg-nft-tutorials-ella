// minify.mjs
import { deflateRawSync } from 'node:zlib';
import { readFileSync, writeFileSync } from 'node:fs';
import { basename, extname, dirname, resolve, join } from 'node:path';

// ── 1  resolve paths ───────────────────────────────────────────────
const [ , , srcArg = 'tspans.txt' ] = process.argv;
const srcPath = resolve(srcArg);                 // absolute path to input
const folder  = dirname(srcPath);                // its directory
const base    = basename(srcPath, extname(srcPath)); // "tspans98"

// ── 2  read & compress ─────────────────────────────────────────────
const src = readFileSync(srcPath);
const def = deflateRawSync(src, { level: 9 });

// ── 3  write outputs right next to the input file ──────────────────
writeFileSync(join(folder, `${base}.def`), def);
writeFileSync(join(folder, `${base}.hex`), def.toString('hex'));
writeFileSync(join(folder, `${base}.len`), String(src.length));

console.log(`✅ ${srcArg}: ${src.length} → ${def.length} bytes`);
console.log(`   • ${base}.def  • ${base}.hex  • ${base}.len  (in ${folder})`);