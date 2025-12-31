import pkg from 'crypto-js';
const { AES, enc, mode, pad } = pkg;
import fs from 'fs';

function makeKey(userId) {
  return userId.substring(0, 16); // only first 16 chars
}

function aesDecrypt(cipherText, userId) {
  const key = enc.Utf8.parse(makeKey(userId));
  const decrypted = AES.decrypt(cipherText, key, {
    mode: mode.ECB,
    padding: pad.Pkcs7,
  });
  return decrypted.toString(enc.Utf8);
}

// --- CONFIG ---
const OLD_UID = "FB_UID";
const BACKUP_FILE = "backup.json";  // path to your backup JSON

// Load backup
const raw = fs.readFileSync(BACKUP_FILE, "utf8");
const entries = JSON.parse(raw);

// Try first 3 entries
entries.slice(0, 3).forEach((entry, i) => {
  try {
    const decrypted = aesDecrypt(entry.encryptedValue, OLD_UID); // adjust "content" to your actual field name
    console.log(`Entry #${i + 1}:`, decrypted.substring(0, 100)); // print first 100 chars
  } catch (e) {
    console.error(`Failed to decrypt entry #${i + 1}:`, e.message);
  }
});