import { Cardano, Intersection } from '@cardano-sdk/core';
import { Ogmios } from '@cardano-sdk/ogmios';
import { getLastCommit } from 'git-last-commit';
// eslint-disable-next-line unicorn/prefer-node-protocol
import { promisify } from 'util';

export const getLastCommitPromise = promisify(getLastCommit);

export const ogmiosIntersectionToCore = ({
  intersection,
  tip
}: Ogmios.ChainSynchronization.Intersection): Intersection => ({
  point:
    intersection === 'origin'
      ? 'origin'
      : {
          hash: Cardano.BlockId(intersection.id),
          slot: Cardano.Slot(intersection.slot)
        },
  tip:
    tip === 'origin'
      ? 'origin'
      : {
          blockNo: Cardano.BlockNo(tip.height),
          hash: Cardano.BlockId(tip.id),
          slot: Cardano.Slot(tip.slot)
        }
});
