import { BlockHandler, RollForwardContext } from '../../src/DataProjection/types';
import { DgraphClient } from '../../src/DataProjection/DgraphClient';
import {
  Schema,
  isAllegraBlock,
  isAlonzoBlock,
  isByronEpochBoundaryBlock,
  isByronStandardBlock,
  isMaryBlock,
  isShelleyBlock
} from '@cardano-ogmios/client';
import { mergedRollForwardUpsert } from '../../src/DataProjection/util';

const blockHandlers: BlockHandler[] = [
  {
    id: 'one',
    rollBackward: () =>
      Promise.resolve({
        mutations: { delete: [] }
      }),
    rollForward: ({ block }) => {
      let b:
        | Schema.EpochBoundaryBlock
        | Schema.StandardBlock
        | Schema.BlockShelley
        | Schema.BlockAllegra
        | Schema.BlockMary
        | Schema.BlockAlonzo;
      if (isByronEpochBoundaryBlock(block)) {
        b = block.byron as Schema.EpochBoundaryBlock;
      } else if (isByronStandardBlock(block)) {
        b = block.byron as Schema.StandardBlock;
      } else if (isShelleyBlock(block)) {
        b = block.shelley as Schema.BlockShelley;
      } else if (isAllegraBlock(block)) {
        b = block.allegra as Schema.BlockAllegra;
      } else if (isMaryBlock(block)) {
        b = block.mary as Schema.BlockMary;
      } else if (isAlonzoBlock(block)) {
        b = block.alonzo as Schema.BlockAlonzo;
      } else {
        throw new Error('UnknownBlockType');
      }
      return Promise.resolve({
        mutations: { set: [{ blocks: { number: b.header?.blockHeight } }] }
      });
    }
  }
];

describe('Data projection utils', () => {
  let dgraphClient: DgraphClient;

  beforeEach(() => {
    dgraphClient = new DgraphClient('http://localhost:8000');
  });

  describe('mergedRollForwardUpsert', () => {
    let context: RollForwardContext;
    beforeEach(() => {
      context = {
        block: {
          alonzo: {
            header: {
              blockHash: '',
              blockHeight: 1000,
              blockSize: 100,
              issuerVk: '',
              issuerVrf: '',
              leaderValue: { proof: '' },
              opCert: { count: 1 },
              prevHash: '',
              protocolVersion: { major: 5, minor: 7 },
              signature: '',
              slot: 2000
            }
          }
        },
        txn: dgraphClient.newTxn()
      };
    });

    it('returns a merged upsert from a given array of BlockHandlers and context', async () => {
      const upsert = await mergedRollForwardUpsert(blockHandlers, context);
      expect(upsert).toEqual({
        mutations: { set: [{ blocks: { number: 1000 } }] }
      });
    });
  });
});
