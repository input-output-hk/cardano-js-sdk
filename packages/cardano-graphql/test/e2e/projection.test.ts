import { DgraphClient, createDgraphClient } from '../../src';
import fs from 'fs';
import path from 'path';

const schema = fs.readFileSync(path.resolve(__dirname, '..', '..', 'dist', 'schema.graphql'), 'utf-8');
const address = 'localhost:9080';

describe('Projections', () => {
  let dgraphClient: DgraphClient;

  beforeEach(() => {
    dgraphClient = createDgraphClient(address, console);
  });

  describe('setting the schema', () => {
    it('completes without throwing an error', async () => {
      await expect(dgraphClient.setSchema(schema)).resolves;
    });
  });
});
