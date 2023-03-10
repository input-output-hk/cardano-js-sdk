import { DockerUtil } from '@cardano-sdk/util-dev';

module.exports = async () => {
  await DockerUtil.removePostgresContainer();
};
