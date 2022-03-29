import { Asset } from '../../../Schema';
import {
  BlockHandler,
  CombinedProcessingResult,
  CombinedQueryResult,
  ProcessingResult,
  QueryResult,
  RollBackwardContext,
  RollForwardContext
} from '../../types';
// import { MetadataClient } from '../../../MetadataClient/MetadataClient';
import { dummyLogger } from 'ts-log';
import { getAssetBlockType, getAssetIdsFromTransaction, getAssetsFromTransaction, mapAsset } from './helpers';

const HANDLER_ID = 'Asset';

export const createAssetBlockHandler = (
  // metadataClient: MetadataClient,
  logger = dummyLogger
): BlockHandler => ({
  id: HANDLER_ID,
  process: async (ctx: RollForwardContext, queryResult: CombinedQueryResult) => {
    const block = getAssetBlockType(ctx.block);
    const assetList: Asset[] = [];
    if (block?.body !== undefined) {
      for (const tx of block.body) {
        assetList.push(...getAssetsFromTransaction(tx));
      }
    }
    const assetIdsFound = new Set(queryResult.assets.map((asset) => asset['Asset.assetId']));
    const assetsToInsert: Asset[] = assetList.filter((asset) => !assetIdsFound.has(asset.assetId));
    if (assetsToInsert.length > 0) {
      logger.debug('About to fetch assets metadata');
      // FIXME: querying for assets metadata really slows the performance
      // const assetIds = assetsToInsert.map((asset) => asset.assetId);
      // const metadata = await metadataClient.fetch(assetIds);
      // for (const [index, asset] of assetsToInsert.entries()) {
      //   if (metadata[index]) {
      //     asset.tokenMetadata = mapAssetMetadata(metadata[index]);
      //   }
      //   assetsToInsert.push(asset);
      // }
    }

    return { assets: assetsToInsert };
  },
  query: async (ctx: RollForwardContext): Promise<QueryResult> => {
    const block = getAssetBlockType(ctx.block);
    let query = '';
    const assetIdList: string[] = [];
    if (block?.body !== undefined) {
      logger.info('About to read block transactions');
      for (const tx of block.body) {
        assetIdList.push(...getAssetIdsFromTransaction(tx));
      }
    }
    if (assetIdList.length > 0) {
      // FIXME: asset id list should be taken from query var.
      // Apparently not supported by dgraph:
      // https://discuss.dgraph.io/t/support-lists-in-query-variables-dgraphs-graphql-variable/8758
      query = `query getAssetsByIds{
        assets(func: type(Asset)) @filter(eq(Asset.assetId, [${assetIdList}]))  {
          Asset.assetId
        }
      }`;
      // variables = { $assetIds: `${assetIdList}` };
    }
    return { query, variables: {} };
  },
  rollBackward: async ({ point }: RollBackwardContext) => {
    logger.trace('rollBackward', point);
    const slot = point === 'origin' ? 0 : point.slot;
    const query = `
    query {
      var queryTransaction(type(Transaction)) {
          Transaction.block {
	          Block.slot @filter(ge(number, ${slot})) {
              number
            } 
          },
          Transaction.mint: 
	          {
	              asset AS Token.asset {
                  Asset.assetId
	              }
	          }
      }
    }`;
    const deleteMutation = {
      uid: 'uid(asset)'
    };
    return {
      mutations: { ...deleteMutation },
      variables: { defines: ['asset'], dql: query }
    };
  },
  rollForward: async (ctx: RollForwardContext, processingResult?: CombinedProcessingResult[]) => {
    logger.trace('rollForward', ctx);
    if (!processingResult) return { mutations: {} };
    const result = processingResult.find((r) => r.id === HANDLER_ID);
    const { assets } = (await result?.func) as Partial<ProcessingResult>;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let mutations: { [key: string]: any } = {};
    if (assets) mutations = assets.map(mapAsset);
    return {
      mutations
    };
  }
});
