const {Firestore} = require('@google-cloud/firestore');
const fs = require('fs');

const firestore = new Firestore();

async function exportUserData(oldUid) {
  const snapshot = await firestore
    .collection('users')
    .doc(oldUid)
    .collection('thankYouList')
    .get();

  const data = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
  }));

  fs.writeFileSync(`backup-${oldUid}.json`, JSON.stringify(data, null, 2));
  console.log(`Exported ${data.length} docs for user ${oldUid}`);
}

exportUserData('UserId');