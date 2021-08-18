import {
  ConnectionConfig,
  createChainSyncClient,
  createInteractionContext,
  StateQuery,
  isAllegraBlock,
  isShelleyBlock,
  isMaryBlock,
  Schema
} from '@cardano-ogmios/client';
import { GeneratorMetadata } from '../Content';

import { isByronStandardBlock } from '../util';

export type GetBlocksResponse = GeneratorMetadata & {
  blocks: { [blockHeight: string]: Schema.Block };
};

export async function getBlocks(
  blockHeights: number[],
  options?: {
    ogmiosConnectionConfig: ConnectionConfig;
    onBlock?: (slot: number) => void;
  }
): Promise<GetBlocksResponse> {
  const requestedBlocks: { [blockHeight: string]: Schema.Block } = {};
  // eslint-disable-next-line no-async-promise-executor
  return new Promise(async (resolve, reject) => {
    let currentBlock: number;
    // Required to ensure existing messages in the pipe are not processed after the completion condition is met
    let draining = false;
    const response: GetBlocksResponse = {
      metadata: {
        cardano: {
          compactGenesis: await StateQuery.genesisConfig(
            await createInteractionContext(reject, console.log, { connection: options.ogmiosConnectionConfig })
          ),
          intersection: undefined
        }
      },
      blocks: {}
    };
    try {
      const syncClient = await createChainSyncClient(
        await createInteractionContext(reject, console.log, { connection: options.ogmiosConnectionConfig }),
        {
          rollBackward: async (_res, requestNext) => {
            requestNext();
          },
          rollForward: async ({ block }, requestNext) => {
            if (draining) return;
            let b: Schema.StandardBlock | Schema.BlockShelley | Schema.BlockAllegra | Schema.BlockMary;
            if (isByronStandardBlock(block)) {
              b = block.byron as Schema.StandardBlock;
            } else if (isShelleyBlock(block)) {
              b = block.shelley as Schema.BlockShelley;
            } else if (isAllegraBlock(block)) {
              b = block.allegra as Schema.BlockAllegra;
            } else if (isMaryBlock(block)) {
              b = block.mary as Schema.BlockMary;
            }
            if (b !== undefined) {
              currentBlock = b.header.blockHeight;
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
      console.error(error);
      return reject(error);
    }
  });
}
