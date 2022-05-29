import { Commit } from 'git-last-commit';
import { Ogmios } from '@cardano-sdk/ogmios';
import { getLastCommitPromise } from './util';
const packageJson = require('../package.json');

export type Metadata = {
  cardano: {
    compactGenesis: Ogmios.Schema.CompactGenesis;
    intersection: Ogmios.ChainSync.Intersection;
  };
  software: {
    name: string;
    version: string;
    commit: Pick<Commit, 'hash' | 'tags'>;
  };
};

export type GeneratorMetadata = { metadata: { cardano: Metadata['cardano'] } };

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
