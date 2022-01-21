const Schema = require('../dist/Schema');
const { printSchemaWithDirectives } = require('@graphql-tools/utils');

module.exports = async () => {
  const graphqlSchema = await Schema.build();
  const printedSchema = printSchemaWithDirectives(graphqlSchema);
  // remove custom scalars as dgraph doesn't support them, needed for DateTime
  return printedSchema.replace(/\n?(?:""".+"""\n)?scalar .+/g, '');
};
