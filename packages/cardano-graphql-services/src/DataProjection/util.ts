import { AssetMetadata } from '../MetadataClient/types';
import {
  BlockHandler,
  CombinedProcessingResult,
  CombinedQueryResult,
  QueryResult,
  QueryVariables,
  RollBackwardContext,
  RollForwardContext,
  Upsert
} from './types';
import lodash from 'lodash-es';
import { Asset } from '@cardano-sdk/core';

export const mergedQuery = async (
  blockHandlers: BlockHandler[],
  ctx: RollForwardContext
): Promise<QueryResult<QueryVariables>> =>
  blockHandlers
    .filter((handler) => handler.query)
    .map((handler) => handler.query!(ctx))
    .reduce(async (acc, curr) => {
      const currResult = await curr;
      const accResult = await acc;
      return {
        query: currResult.query + accResult.query,
        variables: { ...currResult.variables, ...accResult.variables }
      };
    });

export const mergedProcessingResults = async (
  blockHandlers: BlockHandler[],
  ctx: RollForwardContext,
  mergedQueryResults: CombinedQueryResult
): Promise<CombinedProcessingResult[]> =>
  Promise.all(
    blockHandlers
      .filter((handler) => handler.process)
      .map(async (handler) => ({
        func: await handler.process!({ ctx, queryResult: mergedQueryResults }),
        id: handler.id
      }))
  );

export const mergedRollForwardUpsert = async (
  blockHandlers: BlockHandler[],
  ctx: RollForwardContext,
  processingResult: CombinedProcessingResult[]
): Promise<Upsert> =>
  blockHandlers
    .map((handler) => handler.rollForward(ctx, processingResult))
    .reduce(async (acc, curr) => lodash.merge(await acc, await curr));

export const mergedRollBackwardUpsert = async (blockHandlers: BlockHandler[], ctx: RollBackwardContext) =>
  blockHandlers
    .map((handler) => handler.rollBackward(ctx))
    .reduce(async (acc, curr) => lodash.merge(await acc, await curr));

export const mapMetadata = (serverAssetMetadata: AssetMetadata): Asset.TokenMetadata => ({
  decimals: serverAssetMetadata.decimals.value,
  desc: serverAssetMetadata.description?.value,
  name: serverAssetMetadata.name?.value,
  ticker: serverAssetMetadata.ticker?.value,
  url: serverAssetMetadata.url?.value
  // Missing fields: sizedIcons, icon
});
