// assets/minify.mjs
import { readFileSync, writeFileSync } from "node:fs";
import { deflateRawSync }             from "node:zlib";

/**
 * Usage:  node minify.mjs <PLAINTEXT_FILE>
 * result:   <name>.hex  — hex-encoded Deflate frame (level 9)
 *           <name>.len  — original byte length (raw UTF-8)
 */

const srcName = process.argv[2];
if (!srcName) throw new Error("missing <file.txt> argument");

const raw      = readFileSync(srcName);
const deflated = deflateRawSync(raw, { level: 9 });

writeFileSync(srcName.replace(/\.txt$/i, ".hex"), deflated.toString("hex"));
writeFileSync(srcName.replace(/\.txt$/i, ".len"), String(raw.length));

console.log(`✔  ${srcName}  →  ${(raw.length/1024).toFixed(1)} kB raw  →  ${(deflated.length/1024).toFixed(1)} kB deflate`);