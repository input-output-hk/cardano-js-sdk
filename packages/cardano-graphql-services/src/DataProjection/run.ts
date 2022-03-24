/* eslint-disable import/imports-first */
require('../../scripts/patchRequire');
import { DataProjector } from './Service';
import { Logger } from 'ts-log';
import { createLogger } from 'bunyan';
import { getConfig } from '../config';
import fs from 'fs';
import onDeath from 'death';
import path from 'path';

const { metadataServerUri } = getConfig();

void (async () => {
  const logger: Logger = createLogger({
    level: 'debug',
    name: 'dgraph-projector'
  });
  const service = new DataProjector(
    {
      dgraph: {
        addresses: { grpc: 'localhost:9080', http: 'http://localhost:8080' },
        schema: fs.readFileSync(path.resolve(__dirname, '..', '..', 'dist', 'schema.graphql'), 'utf-8')
      },
      metadata: {
        uri: metadataServerUri
      },
      ogmios: { connection: { host: 'localhost', port: 1338 } }
    },
    logger
  );
  await service.initialize();
  await service.start();
  onDeath(async () => {
    await service.shutdown();
    // eslint-disable-next-line unicorn/no-process-exit
    process.exit(1);
  });
})();
