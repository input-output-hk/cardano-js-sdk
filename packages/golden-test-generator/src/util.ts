import { Schema } from '@cardano-ogmios/client';
import { getLastCommit } from 'git-last-commit';
// eslint-disable-next-line unicorn/prefer-node-protocol
import { promisify } from 'util';

// Todo: Hoist to @cardano-ogmios/client
export const isByronStandardBlock = (block: Schema.Block): block is { byron: Schema.StandardBlock } =>
  (block as { byron: Schema.StandardBlock }).byron?.header.slot !== undefined;

export const isByronEpochBoundaryBlock = (block: Schema.Block): block is { byron: Schema.EpochBoundaryBlock } => {
  const castBlock = block as { byron: Schema.EpochBoundaryBlock };
  return castBlock.byron?.hash !== undefined && castBlock.byron?.header.epoch !== undefined;
};

export const getLastCommitPromise = promisify(getLastCommit);
