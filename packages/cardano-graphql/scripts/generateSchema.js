const Schema = require('../dist/Schema');
const { printSchemaWithDirectives } = require('@graphql-tools/utils');

module.exports = async () => {
  const graphqlSchema = await Schema.build();
  return printSchemaWithDirectives(graphqlSchema);
};
