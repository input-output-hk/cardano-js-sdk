import { removePostgresContainer } from './docker';

module.exports = async () => {
  await removePostgresContainer();
};
