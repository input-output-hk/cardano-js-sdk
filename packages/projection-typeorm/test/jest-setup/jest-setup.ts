import { DockerUtil } from '@cardano-sdk/util-dev';
import { connectionConfig } from '../connection';

module.exports = async () => {
  await DockerUtil.setupPostgresContainer(
    connectionConfig.username,
    connectionConfig.password,
    connectionConfig.port.toString()
  );
};
