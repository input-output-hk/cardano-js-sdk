import { ChainSyncEvent, ChainSyncEventType, Intersection } from '@cardano-sdk/core';
import { GeneratorMetadata } from '../Content';
import { Logger } from 'ts-log';
import { Ogmios, ogmiosToCore } from '@cardano-sdk/ogmios';

type CardanoMetadata = Pick<GeneratorMetadata['metadata'], 'cardano'>;

export type GetChainSyncEventsResponse = {
  events: ChainSyncEvent[];
  metadata: CardanoMetadata;
};

type RequestedBlocks = { [blockHeight: number]: Ogmios.Schema.Block };

const blocksWithRollbacks = (blockHeights: number[], requestedBlocks: RequestedBlocks): ChainSyncEvent[] => {
  const result: ChainSyncEvent[] = [];
  for (const blockHeight of blockHeights) {
    if (blockHeight >= 0) {
      const requestedBlock = requestedBlocks[blockHeight];
      if (!requestedBlock) throw new Error(`Block not found: ${blockHeight}`);
      const block = ogmiosToCore.block(requestedBlock);
      block && result.push({ block, eventType: ChainSyncEventType.RollForward, tip: block.header });
    } else {
      const blockNo = -blockHeight;
      const requestedBlock = requestedBlocks[blockNo];
      if (!requestedBlock) throw new Error(`Cannot rollback to a non-requested block: ${blockHeight}`);
      const header = ogmiosToCore.blockHeader(requestedBlock);
      header && result.push({ eventType: ChainSyncEventType.RollBackward, tip: header });
    }
  }
  return result;
};

export const getChainSyncEvents = async (
  blockHeights: number[],
  options: {
    logger: Logger;
    ogmiosConnectionConfig: Ogmios.ConnectionConfig;
    onBlock?: (slot: number) => void;
  }
): Promise<GetChainSyncEventsResponse> => {
  const { logger, onBlock, ogmiosConnectionConfig } = options;
  const requestedBlocks: RequestedBlocks = {};
  return new Promise(async (resolve, reject) => {
    let currentBlock: number;
    // Required to ensure existing messages in the pipe are not processed after the completion condition is met
    let draining = false;
    const metadata: CardanoMetadata = {
      cardano: {
        compactGenesis: ogmiosToCore.genesis(
          await Ogmios.StateQuery.genesisConfig(
            await Ogmios.createInteractionContext(reject, logger.info, { connection: ogmiosConnectionConfig })
          )
        ),
        intersection: undefined as unknown as Intersection
      }
    };
    const maxHeight = Math.max(...blockHeights);
    try {
      const syncClient = await Ogmios.createChainSyncClient(
        await Ogmios.createInteractionContext(reject, logger.info, { connection: ogmiosConnectionConfig }),
        {
          rollBackward: async (_res, requestNext) => {
            requestNext();
          },
          rollForward: async ({ block }, requestNext) => {
            if (draining) return;
            const header = ogmiosToCore.blockHeader(block);
            if (!header) return;
            currentBlock = header.blockNo.valueOf();
            if (onBlock !== undefined) {
              onBlock(currentBlock);
            }
            if (blockHeights.includes(currentBlock)) {
              requestedBlocks[currentBlock] = block;
              if (maxHeight === currentBlock) {
                draining = true;
                await syncClient.shutdown();
                return resolve({
                  events: blocksWithRollbacks(blockHeights, requestedBlocks),
                  metadata
                });
              }
            }
            requestNext();
          }
        }
      );
      metadata.cardano.intersection = (await syncClient.startSync(['origin'])) as Intersection;
    } catch (error) {
      logger.error(error);
      return reject(error);
    }
  });
};
