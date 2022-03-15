/* eslint-disable func-style */
import { MissingConfig } from './DataProjection/errors';

export type Config = {
  metadataServerUri: string;
};

function filterAndTypecastEnvs(env: any) {
  const { METADATA_SERVER_URI } = env as NodeJS.ProcessEnv;
  return {
    metadataServerUri: METADATA_SERVER_URI
  };
}

export function getConfig(): Config {
  const { metadataServerUri } = filterAndTypecastEnvs(process.env);
  if (!metadataServerUri) {
    throw new MissingConfig('METADATA_SERVER_URI env not set');
  }
  return { metadataServerUri };
}
