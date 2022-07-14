/* eslint-disable sonarjs/cognitive-complexity */
import { GeneratorMetadata } from '../Content';
import { Logger, dummyLogger } from 'ts-log';
import { Ogmios } from '@cardano-sdk/ogmios';

export type GetBlocksResponse = GeneratorMetadata & {
  blocks: { [blockHeight: string]: Ogmios.Schema.Block };
};

export const getBlocks = async (
  blockHeights: number[],
  options: {
    logger?: Logger;
    ogmiosConnectionConfig: Ogmios.ConnectionConfig;
    onBlock?: (slot: number) => void;
  }
): Promise<GetBlocksResponse> => {
  const logger = options?.logger ?? dummyLogger;
  const requestedBlocks: { [blockHeight: string]: Ogmios.Schema.Block } = {};
  return new Promise(async (resolve, reject) => {
    let currentBlock: number;
    // Required to ensure existing messages in the pipe are not processed after the completion condition is met
    let draining = false;
    const response: GetBlocksResponse = {
      blocks: {},
      metadata: {
        cardano: {
          compactGenesis: await Ogmios.StateQuery.genesisConfig(
            await Ogmios.createInteractionContext(reject, logger.info, { connection: options.ogmiosConnectionConfig })
          ),
          intersection: undefined as unknown as Ogmios.ChainSync.Intersection
        }
      }
    };
    try {
      const syncClient = await Ogmios.createChainSyncClient(
        await Ogmios.createInteractionContext(reject, logger.info, { connection: options.ogmiosConnectionConfig }),
        {
          rollBackward: async (_res, requestNext) => {
            requestNext();
          },
          // eslint-disable-next-line complexity
          rollForward: async ({ block }, requestNext) => {
            if (draining) return;
            let b:
              | Ogmios.Schema.BlockByron
              | Ogmios.Schema.StandardBlock
              | Ogmios.Schema.BlockShelley
              | Ogmios.Schema.BlockAllegra
              | Ogmios.Schema.BlockMary
              | Ogmios.Schema.BlockAlonzo;
            if (Ogmios.isByronStandardBlock(block)) {
              b = block.byron as Ogmios.Schema.StandardBlock;
            } else if (Ogmios.isShelleyBlock(block)) {
              b = block.shelley as Ogmios.Schema.BlockShelley;
            } else if (Ogmios.isAllegraBlock(block)) {
              b = block.allegra as Ogmios.Schema.BlockAllegra;
            } else if (Ogmios.isMaryBlock(block)) {
              b = block.mary as Ogmios.Schema.BlockMary;
            } else if (Ogmios.isAlonzoBlock(block)) {
              b = block.alonzo as Ogmios.Schema.BlockAlonzo;
            } else if (Ogmios.isByronEpochBoundaryBlock(block)) {
              b = block.byron as Ogmios.Schema.BlockByron;
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
