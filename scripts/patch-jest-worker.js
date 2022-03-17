// See https://github.com/facebook/jest/issues/11617
const fs = require('fs');
const path = require('path');

const pathToMessageParentJs = path.join(__dirname, '../node_modules/jest-worker/build/workers/messageParent.js');

const originalContents = fs.readFileSync(pathToMessageParentJs).toString();
const patch = `try {
  parentProcess.send([_types.PARENT_MESSAGE_CUSTOM, message]);
} catch (error) {
  console.error('jest-worker message serialisation failed', error);
  console.dir(message, {depth: 10});
  throw error;
}`;

if (originalContents.includes(patch)) {
  console.log(pathToMessageParentJs, 'is already patched, nothing to do...');
} else {
  const patchedContents = originalContents.replace(
    'parentProcess.send([_types.PARENT_MESSAGE_CUSTOM, message]);',
    patch
  );

  fs.writeFileSync(pathToMessageParentJs, patchedContents);
  console.log(pathToMessageParentJs, 'successfully patched!');
}
