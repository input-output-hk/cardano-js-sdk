import { ChainSyncEventType } from '@cardano-sdk/core';
import { Ogmios, ogmiosToCore } from '@cardano-sdk/ogmios';
import { generateRandomHexString } from '@cardano-sdk/util-dev';
import type { Cardano, Intersection } from '@cardano-sdk/core';
import type { GeneratorMetadata } from '../Content.js';
import type { Logger } from 'ts-log';
import type { SerializedChainSyncEvent } from '@cardano-sdk/util-dev';

type CardanoMetadata = Pick<GeneratorMetadata['metadata'], 'cardano'>;

export type GetChainSyncEventsResponse = {
  events: SerializedChainSyncEvent[];
  metadata: CardanoMetadata;
};

type RequestedBlocks = { [blockHeight: number]: Ogmios.Schema.Block };

// eslint-disable-next-line sonarjs/cognitive-complexity
const blocksWithRollbacks = (blockHeights: number[], requestedBlocks: RequestedBlocks): SerializedChainSyncEvent[] => {
  const result: SerializedChainSyncEvent[] = [];
  for (const blockHeight of blockHeights) {
    if (blockHeight >= 0) {
      const requestedBlock = requestedBlocks[blockHeight];
      if (!requestedBlock) throw new Error(`Block not found: ${blockHeight}`);
      const block = ogmiosToCore.block(requestedBlock);
      if (!block) continue;
      if (
        result.some(
          (existingBlock) =>
            existingBlock.eventType === ChainSyncEventType.RollForward &&
            existingBlock.block.header.hash === block?.header.hash
        )
      ) {
        // Replaying a block after rollback should have a different hash
        block.header.hash = generateRandomHexString(block.header.hash.length) as Cardano.BlockId;
      }
      result.push({ block, eventType: ChainSyncEventType.RollForward, tip: block.header });
    } else {
      const blockNo = -blockHeight;
      // Find last added RollForward block that matches requested block height
      let requestedBlock: Cardano.Block | undefined;
      for (let i = result.length - 1; i >= 0; i--) {
        const evt = result[i];
        if (evt.eventType === ChainSyncEventType.RollForward && evt.block.header.blockNo === blockNo) {
          requestedBlock = evt.block;
          break;
        }
      }
      if (!requestedBlock) throw new Error(`Cannot rollback to a non-requested block: ${blockHeight}`);

      result.push({
        eventType: ChainSyncEventType.RollBackward,
        point: {
          hash: requestedBlock.header.hash,
          slot: requestedBlock.header.slot
        },
        tip: requestedBlock.header
      });
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
            currentBlock = header.blockNo;

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
