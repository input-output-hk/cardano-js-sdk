import {
  BlockHandler,
  CombinedProcessingResult,
  ProcessParameters,
  ProcessingResult,
  QueryResult,
  QueryVariables,
  RollBackwardContext,
  RollForwardContext
} from '../types';
import { MetadataClient } from '../MetadataClient';
import { Schema, isAlonzoBlock, isMaryBlock } from '@cardano-ogmios/client';
import { dummyLogger } from 'ts-log';

const HANDLER_ID = 'Asset';

export const createAssetBlockHandler = (metadataClient: MetadataClient, logger = dummyLogger): BlockHandler => ({
  id: HANDLER_ID,
  process: async ({ queryResult }: ProcessParameters) => {
    const assetsToInsert = [];
    if (queryResult) {
      for (const asset of queryResult.data.assets) {
        logger.info('About to fetch asset metadata');
        if (!(await metadataClient.fetch([asset.assetId]))) {
          assetsToInsert.push(asset);
        }
      }
    }
    return { assets: assetsToInsert };
  },
  // eslint-disable-next-line sonarjs/cognitive-complexity
  query: async (ctx: RollForwardContext): Promise<QueryResult<QueryVariables>> => {
    const { block } = ctx;
    let b: Schema.BlockMary | Schema.BlockAlonzo | undefined;
    if (isAlonzoBlock(block)) {
      b = block.alonzo as Schema.BlockAlonzo;
    } else if (isMaryBlock(block)) {
      b = block.mary as Schema.BlockMary;
    }
    let query = '';
    const assetIdList: string[] = [];
    if (b?.body !== undefined) {
      logger.info('About to read block transactions');
      for (const tx of b.body) {
        const txBodyMintAssets = tx.body.mint.assets;
        if (txBodyMintAssets) {
          logger.info('Assets found');
          query = `query getAssetsByIds($assetIds: string) {
            assets(func: eq(assetId, $assetIds)) {
              assetId,
              assetName,
              assetNameUTF8,
              policy,
              totalQuantity,
              fingerprint,
              history,
              tokenMetadata,
              nftMetadata
            }
          }`;
          for (const entry of Object.entries(txBodyMintAssets)) {
            const [policyId, assetName] = entry[0].split('.');
            assetIdList.push(`${policyId}${assetName !== undefined ? assetName : ''}`);
          }
        }
      }
    }
    const variables = assetIdList.length > 0 ? { $assetIds: `${assetIdList}` } : {};
    return { query, variables };
  },
  rollBackward: async ({ point }: RollBackwardContext) => {
    logger.trace('rollBackward', point);
    return {
      mutations: {}
    };
  },
  rollForward: async (ctx: RollForwardContext, processingResult: CombinedProcessingResult[]) => {
    logger.trace('rollForward', ctx);
    const result = processingResult.find((r) => r.id === HANDLER_ID);
    const { assets } = (await result?.func) as Partial<ProcessingResult>;
    const mutations: { [key: string]: any } = {};
    if (assets) mutations.set = assets;
    return {
      mutations
    };
  }
});
