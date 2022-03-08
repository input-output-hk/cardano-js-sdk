/* eslint-disable import/imports-first */
require('../../scripts/patchRequire');
import { Logger } from 'ts-log';
import { Service } from './Service';
import { createLogger } from 'bunyan';
import fs from 'fs';
import onDeath from 'death';
import path from 'path';

void (async () => {
  const logger: Logger = createLogger({
    level: 'debug',
    name: 'dgraph-projector'
  });
  const service = new Service(
    {
      dgraph: {
        address: 'http://localhost:8080',
        schema: fs.readFileSync(path.resolve(__dirname, '..', '..', 'dist', 'schema.graphql'), 'utf-8')
      }
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
