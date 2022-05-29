/* eslint-disable sonarjs/cognitive-complexity */
import {
  ChainSync,
  ConnectionConfig,
  Schema,
  StateQuery,
  createChainSyncClient,
  createInteractionContext,
  isAllegraBlock,
  isAlonzoBlock,
  isMaryBlock,
  isShelleyBlock
} from '@cardano-ogmios/client';
import { GeneratorMetadata } from '../Content';
import { Logger, dummyLogger } from 'ts-log';

import { isByronStandardBlock } from '../util';

export type GetBlocksResponse = GeneratorMetadata & {
  blocks: { [blockHeight: string]: Schema.Block };
};

export const getBlocks = async (
  blockHeights: number[],
  options: {
    logger?: Logger;
    ogmiosConnectionConfig: ConnectionConfig;
    onBlock?: (slot: number) => void;
  }
): Promise<GetBlocksResponse> => {
  const logger = options?.logger ?? dummyLogger;
  const requestedBlocks: { [blockHeight: string]: Schema.Block } = {};
  return new Promise(async (resolve, reject) => {
    let currentBlock: number;
    // Required to ensure existing messages in the pipe are not processed after the completion condition is met
    let draining = false;
    const response: GetBlocksResponse = {
      blocks: {},
      metadata: {
        cardano: {
          compactGenesis: await StateQuery.genesisConfig(
            await createInteractionContext(reject, logger.info, { connection: options.ogmiosConnectionConfig })
          ),
          intersection: undefined as unknown as ChainSync.Intersection
        }
      }
    };
    try {
      const syncClient = await createChainSyncClient(
        await createInteractionContext(reject, logger.info, { connection: options.ogmiosConnectionConfig }),
        {
          rollBackward: async (_res, requestNext) => {
            requestNext();
          },
          rollForward: async ({ block }, requestNext) => {
            if (draining) return;
            let b:
              | Schema.StandardBlock
              | Schema.BlockShelley
              | Schema.BlockAllegra
              | Schema.BlockMary
              | Schema.BlockAlonzo;
            if (isByronStandardBlock(block)) {
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
              throw new Error('No support for block');
            }
            if (b !== undefined) {
              currentBlock = b.header!.blockHeight;
              if (options?.onBlock !== undefined) {
                options.onBlock(currentBlock);
              }
              if (blockHeights.includes(currentBlock)) {
                requestedBlocks[currentBlock] = block;
                if (blockHeights[blockHeights.length - 1] === currentBlock) {
                  draining = true;
                  response.blocks = requestedBlocks;
                  await syncClient.shutdown();
                  return resolve(response);
                }
              }
            }
            requestNext();
          }
        }
      );
      response.metadata.cardano.intersection = await syncClient.startSync(['origin']);
    } catch (error) {
      logger.error(error);
      return reject(error);
    }
  });
};
