import { Commit } from 'git-last-commit';
import { getLastCommitPromise } from './util';
import type { ChainSyncMetadata } from '@cardano-sdk/util-dev';
const packageJson = require('../../package.json');

export type Metadata = {
  cardano: ChainSyncMetadata['cardano'];
  software: {
    name: string;
    version: string;
    commit: Pick<Commit, 'hash' | 'tags'>;
  };
};

export type GeneratorMetadata = { metadata: { cardano: Metadata['cardano']; options?: { blockHeights: string } } };

export const prepareContent = async <Body>(
  metadata: Omit<Metadata, 'software'>,
  body: Body
): Promise<{
  metadata: Metadata;
  body: Body;
}> => {
  const lastCommit = await getLastCommitPromise();
  return {
    body,
    metadata: {
      ...metadata,

      software: {
        commit: {
          hash: lastCommit.hash,
          tags: lastCommit.tags
        },
        name: packageJson.name,
        version: packageJson.version
      }
    }
  };
};
