import { DockerUtil } from '@cardano-sdk/util-dev';
import { connectionConfig } from '../util.js';
import path from 'path';

module.exports = async () => {
  await DockerUtil.setupPostgresContainer(
    connectionConfig.username,
    connectionConfig.password,
    connectionConfig.port.toString(),
    [`${path.join(__dirname, 'initdb.d')}:/docker-entrypoint-initdb.d`],
    'projection'
  );
};
