// Requires running dgraph locally.
// You can use docker-compose, see ../docker-compose.yml
const GRAPHQL_URL = 'http://localhost:8080';

const path = require('path');
const fs = require('fs');
const { request, gql } = require('graphql-request');
const generateSchema = require('./generateSchema');

void (async () => {
  const schema = await generateSchema();
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
  const data = await request(`${GRAPHQL_URL}/admin`, query, { sch: schema });
  const distPath = path.join(__dirname, '../dist/dgraph.graphql');
  fs.writeFileSync(distPath, data.updateGQLSchema.gqlSchema.generatedSchema);
  console.log('Dgraph schema set and saved to', distPath);
})();
