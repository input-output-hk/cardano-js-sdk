import { DockerUtil } from '@cardano-sdk/util-dev';
import { connectionConfig } from '../util';

module.exports = async () => {
  await DockerUtil.setupPostgresContainer(
    connectionConfig.username,
    connectionConfig.password,
    connectionConfig.port.toString()
  );
};
