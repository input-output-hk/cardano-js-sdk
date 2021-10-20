const path = require('path');
const { Schema } = require('../dist');
const { emitSchemaDefinitionFile } = require('type-graphql');

void (async () => {
  const schema = await Schema.build();
  await emitSchemaDefinitionFile(path.join(__dirname, '../dist/schema.graphql'), schema);
})();
