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
import { MetadataClient } from '../../MetadataClient/MetadataClient';
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
          query = `query getAssetsByIds($assetIds: String[]) {
            queryAsset(filter: { assetId: { in: $assetIds } }) {
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
    const variables = assetIdList.length > 0 ? { $assetIds: assetIdList } : {};
    return { query, variables };
  },
  rollBackward: async ({ point }: RollBackwardContext) => {
    logger.trace('rollBackward', point);
    const query = `
    query {
      var queryTransaction(func: ge(number, ${point.slot})) {
          block{
          slot {
              number 
          }
          },
          mint: [
          {
              Asset AS asset {
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
          }
          ]
      }
    }`;
    const deleteMutation = {
      assetId: null,
      assetName: null,
      assetNameUTF8: null,
      fingerprint: null,
      history: null,
      nftMetadata: null,
      policy: null,
      tokenMetadata: null,
      totalQuantity: null,
      uid: 'uid(Asset)'
    };
    return {
      mutations: { ...deleteMutation },
      variables: { defines: ['Asset'], dql: query }
    };
  },
  rollForward: async (ctx: RollForwardContext, processingResult: CombinedProcessingResult[]) => {
    logger.trace('rollForward', ctx);
    const result = processingResult.find((r) => r.id === HANDLER_ID);
    const { assets } = (await result?.func) as Partial<ProcessingResult>;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const mutations: { [key: string]: any } = {};
    if (assets) mutations.set = assets;
    return {
      mutations
    };
  }
});
