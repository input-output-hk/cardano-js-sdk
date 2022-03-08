import { BlockHandler, RollForwardContext, Upsert } from './types';
import lodash from 'lodash-es';

// eslint-disable-next-line @typescript-eslint/no-empty-function
// const noOp = (): void => {};

// export const mergedQuery = async (blockHandlers: BlockHandler[], ctx: RollForwardContext): Promise<DQL> =>
//   blockHandlers
//     .map((handler) => (handler.query ? handler.query(ctx) : ''))
//     .reduce(async (acc, curr) => (await acc) + (await curr));

// export const mergedPreProcessingResults = async (
//   blockHandlers: BlockHandler[],
//   ctx: RollForwardContext,
//   queryResult: any
// ): Promise<any> =>
//   blockHandlers.map((handler) =>
//     handler.process
//       ? { func: handler.process(ctx, queryResult), handler: handler.id }
//       : { func: noOp(), id: handler.id }
//   );

export const mergedRollForwardUpsert = async (
  blockHandlers: BlockHandler[],
  ctx: RollForwardContext
  // processingResult: any
): Promise<Upsert> =>
  blockHandlers
    .map((handler) => handler.rollForward(ctx))
    .reduce(async (acc, curr) => lodash.merge(await acc, await curr));
