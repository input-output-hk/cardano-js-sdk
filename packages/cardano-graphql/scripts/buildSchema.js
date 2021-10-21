// Requires running dgraph locally.
// You can use docker-compose, see ../docker-compose.yml
const GRAPHQL_URL = 'http://localhost:8080';

const path = require('path');
const fs = require('fs');
const Schema = require('../dist/Schema');
const { printSchemaWithDirectives } = require('@graphql-tools/utils');
const { request, gql } = require('graphql-request');

void (async () => {
  const graphqlSchema = await Schema.build();
  const printedSchema = await printSchemaWithDirectives(graphqlSchema);
  fs.writeFileSync(path.join(__dirname, '../dist/schema.graphql'), printedSchema);
  /* eslint-disable no-console */
  console.log('Generated schema');

  const query = gql`
    mutation ($sch: String!) {
      updateGQLSchema(input: { set: { schema: $sch } }) {
        gqlSchema {
          generatedSchema
        }
      }
    }
  `;
  const data = await request(`${GRAPHQL_URL}/admin`, query, { sch: printedSchema });
  fs.writeFileSync(path.join(__dirname, '../dist/dgraph.graphql'), data.updateGQLSchema.gqlSchema.generatedSchema);
  console.log('Dgraph schema set');
})();
