// migrate_thankyoulist.js
import pkg from 'crypto-js';
const { AES, enc, mode, pad } = pkg;
import fs from 'fs';
import admin from 'firebase-admin';
import { Timestamp } from "firebase-admin/firestore";

// --- CONFIG ---
const OLD_UID = "";          // old Facebook UID
const NEW_UID = ""; // new Google UID (test first, real later)
const BACKUP_FILE = ""; // path to backup file

// --- INIT FIRESTORE ---
if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error("❌ Please set GOOGLE_APPLICATION_CREDENTIALS env var to your service account JSON");
  process.exit(1);
}

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
}
const firestore = admin.firestore();

// --- CRYPTO HELPERS ---
function makeKey(userId) {
  return userId.substring(0, 16); // first 16 chars only
}

function aesDecrypt(cipherText, userId) {
  const key = enc.Utf8.parse(makeKey(userId));
  const decrypted = AES.decrypt(cipherText, key, {
    mode: mode.ECB,
    padding: pad.Pkcs7,
  });
  return decrypted.toString(enc.Utf8);
}

function aesEncrypt(plainText, userId) {
  const key = enc.Utf8.parse(makeKey(userId));
  const encrypted = AES.encrypt(plainText, key, {
    mode: mode.ECB,
    padding: pad.Pkcs7,
  });
  return encrypted.toString();
}

function convertToTimestamp(obj) {
  if (obj && typeof obj._seconds === "number" && typeof obj._nanoseconds === "number") {
    return new Timestamp(obj._seconds, obj._nanoseconds);
  }
  return obj;
}

// --- MAIN MIGRATION ---
async function migrate() {
  const args = process.argv.slice(2);
  const dryRun = args.includes("--dry-run");
  const limitArg = args.find(a => a.startsWith("--limit"));
  const limit = limitArg ? parseInt(limitArg.split("=")[1], 10) : null;

  // Load backup data
  const raw = fs.readFileSync(BACKUP_FILE, "utf8");
  let entries = JSON.parse(raw);

  if (limit) {
    entries = entries.slice(0, limit);
  }

  console.log(`🚀 Starting migration: ${entries.length} entries`);
  if (dryRun) console.log("⚠️ Running in DRY-RUN mode (no Firestore writes)");

  for (const entry of entries) {
    try {
      // 1. Decrypt with old UID
      const decrypted = aesDecrypt(entry.encryptedValue, OLD_UID);

      // 2. Re-encrypt with new UID
      const reEncrypted = aesEncrypt(decrypted, NEW_UID);

      // 3. Prepare new doc
      const newDoc = {
        date: entry.date,
        encryptedValue: reEncrypted,
        createTime: convertToTimestamp(entry.createTime),
        migrateTime: Timestamp.now(),
      };

      if (dryRun) {
        console.log("Would migrate:", {
          id: entry.id,
          preview: decrypted.substring(0, 40) + "...",
          migrateTime: newDoc.migrateTime,
        });
      } else {
        await firestore
          .collection("users")
          .doc(NEW_UID)
          .collection("thankYouList")
          .doc(entry.id)
          .set(newDoc);
        console.log(`✅ Migrated entry ${entry.id}`);
      }
    } catch (e) {
      console.error(`❌ Failed to migrate ${entry.id}:`, e.message);
    }
  }

  console.log("🎉 Migration finished.");
}

migrate();
