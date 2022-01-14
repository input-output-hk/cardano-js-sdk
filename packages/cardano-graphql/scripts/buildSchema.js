// This is a little hacky, it would be better to set up ESM builds instead
const Module = require('module');
const originalRequire = Module.prototype.require;
Module.prototype.require = function () {
  return originalRequire.apply(this, arguments[0] === 'lodash-es' ? ['lodash'] : arguments);
};

const path = require('path');
const fs = require('fs');
const generateSchema = require('./generateSchema');

void (async () => {
  const printedSchema = await generateSchema();
  const distPath = path.join(__dirname, '../dist/schema.graphql');
  fs.writeFileSync(distPath, printedSchema);
  // eslint-disable-next-line no-console
  console.log('Schema saved to', distPath);
})();
