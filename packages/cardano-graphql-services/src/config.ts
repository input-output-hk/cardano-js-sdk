/* eslint-disable func-style */
import { MissingConfig } from './DataProjection/errors';
import { config } from 'dotenv';

export type Config = {
  metadataServerUri: string;
  retryLimit: number;
};

function filterAndTypecastEnvs(env: any) {
  const { METADATA_SERVER_URI, RETRY_LIMIT } = env as NodeJS.ProcessEnv;
  return {
    metadataServerUri: METADATA_SERVER_URI,
    retryLimit: Number(RETRY_LIMIT)
  };
}

export function getConfig(): Config {
  config();
  const { metadataServerUri, retryLimit } = filterAndTypecastEnvs(process.env);
  if (!metadataServerUri) {
    throw new MissingConfig('METADATA_SERVER_URI env not set');
  }
  if (!retryLimit) {
    throw new MissingConfig('RETRY_LIMIT env not set');
  }
  return { metadataServerUri, retryLimit };
}
