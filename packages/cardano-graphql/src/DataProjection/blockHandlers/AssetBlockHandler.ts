import { QueryResult, QueryVariables, RollBackwardContext, RollForwardContext } from '../types';
import { Schema, isAlonzoBlock, isMaryBlock } from '@cardano-ogmios/client';
import { dummyLogger } from 'ts-log';

export const createAssetBlockHandler = (logger = dummyLogger) => ({
  id: 'Asset',
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
          query = `query getAssetById($assetIds: string) {
            asset(func: eq(assetId, $assetIds)) {
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
  // process: (ctx: RollForwardContext, queryResult?: CombinedQueryResult) => {},
  rollBackward: async ({ point }: RollBackwardContext) => {
    logger.trace('rollBackward', point);
    return {
      mutations: {}
    };
  },
  rollForward: async (ctx: RollForwardContext) => {
    logger.trace('rollForward', ctx);
    return {
      mutations: {}
    };
  }
});
