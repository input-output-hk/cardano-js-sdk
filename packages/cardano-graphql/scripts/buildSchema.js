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
