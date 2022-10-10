import { GeneratorMetadata } from '../Content';
import { Logger } from 'ts-log';
import { Ogmios } from '@cardano-sdk/ogmios';

export type RollForward = { type: 'rollForward'; block: Ogmios.Schema.Block };
export type RollBackward = { type: 'rollBackward'; rollback: Ogmios.Schema.TipOrOrigin };
export type ChainSyncEvent = RollForward | RollBackward;

export type GetBlocksResponse = GeneratorMetadata & {
  events: ChainSyncEvent[];
};

type RequestedBlocks = { [blockHeight: number]: Ogmios.Schema.Block };

const getBlockHeaderAndHash = (block: Ogmios.Schema.Block) => {
  let header:
    | (Ogmios.Schema.StandardBlock
    | Ogmios.Schema.BlockShelley
    | Ogmios.Schema.BlockAllegra
    | Ogmios.Schema.BlockMary
    | Ogmios.Schema.BlockAlonzo
    | Ogmios.Schema.BlockBabbage)['header'];
  let hash: string | undefined;
  if (Ogmios.isByronStandardBlock(block)) {
    header = block.byron.header;
    hash = block.byron.hash;
  } else if (Ogmios.isShelleyBlock(block)) {
    header = block.shelley.header;
    hash = block.shelley.headerHash;
  } else if (Ogmios.isAllegraBlock(block)) {
    header = block.allegra.header;
    hash = block.allegra.headerHash;
  } else if (Ogmios.isMaryBlock(block)) {
    header = block.mary.header;
    hash = block.mary.headerHash;
  } else if (Ogmios.isAlonzoBlock(block)) {
    header = block.alonzo.header;
    hash = block.alonzo.headerHash;
  } else if (Ogmios.isBabbageBlock(block)) {
    header = block.babbage.header;
    hash = block.babbage.headerHash;
  } else {
    throw new Error('No support for block');
  }
  if (!header || !hash) throw new Error('Header or hash not found for block');
  return {header, hash};
}

const blocksWithRollbacks = (blockHeights: number[], requestedBlocks: RequestedBlocks): ChainSyncEvent[] => {
  const result: ChainSyncEvent[] = [];
  for (const blockHeight of blockHeights) {
    if (blockHeight >= 0) {
      const requestedBlock = requestedBlocks[blockHeight];
      if (!requestedBlock) throw new Error(`Block not found: ${blockHeight}`);
      result.push({type: 'rollForward', block: requestedBlock});
    } else {
      const blockNo = -blockHeight;
      const requestedBlock = requestedBlocks[blockNo];
      if (!requestedBlock) throw new Error(`Cannot rollback to a non-requested block: ${blockHeight}`);
      const {header: {slot}, hash} = getBlockHeaderAndHash(requestedBlock);
      result.push(({type: 'rollBackward', rollback: {blockNo, hash, slot }}));
    }
  }
  return result;
}

export const getBlocks = async (
  blockHeights: number[],
  options: {
    logger: Logger;
    ogmiosConnectionConfig: Ogmios.ConnectionConfig;
    onBlock?: (slot: number) => void;
  }
): Promise<GetBlocksResponse> => {
  const { logger } = options;
  const requestedBlocks: RequestedBlocks = {};
  return new Promise(async (resolve, reject) => {
    let currentBlock: number;
    // Required to ensure existing messages in the pipe are not processed after the completion condition is met
    let draining = false;
    const metadata: GeneratorMetadata['metadata'] = {
      cardano: {
        compactGenesis: await Ogmios.StateQuery.genesisConfig(
          await Ogmios.createInteractionContext(reject, logger.info, { connection: options.ogmiosConnectionConfig })
        ),
        intersection: undefined as unknown as Ogmios.ChainSync.Intersection
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
            const {header} = getBlockHeaderAndHash(block);
            currentBlock = header.blockHeight;
            if (options?.onBlock !== undefined) {
              options.onBlock(currentBlock);
            }
            if (blockHeights.includes(currentBlock)) {
              requestedBlocks[currentBlock] = block;
              if (blockHeights[blockHeights.length - 1] === currentBlock) {
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
      metadata.cardano.intersection = await syncClient.startSync(['origin']);
    } catch (error) {
      logger.error(error);
      return reject(error);
    }
  });
};

