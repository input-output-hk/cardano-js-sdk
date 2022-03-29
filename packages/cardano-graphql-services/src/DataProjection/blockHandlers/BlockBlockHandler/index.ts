import { BlockHandler, RollBackwardContext, RollForwardContext } from '../../types';
import { BlockType, getBlockType, mapBlock, mapByronBlock, mapByronEpochBoundaryBlock } from './helpers';
import { Schema, isByronEpochBoundaryBlock, isByronStandardBlock } from '@cardano-ogmios/client';
import { dummyLogger } from 'ts-log';

const HANDLER_ID = 'Block';

export const createBlockBlockHandler = (logger = dummyLogger): BlockHandler => ({
  id: HANDLER_ID,
  rollBackward: async ({ point }: RollBackwardContext) => {
    logger.trace('rollBackward', point);
    const slot = point === 'origin' ? 0 : point.slot;
    const query = `
    {
      block AS var(func: type(Block)) {
            Block.slot @filter(ge(number, ${slot})) {
               number
             }         
      }
    }`;
    const deleteMutation = {
      uid: 'uid(block)'
    };
    return {
      mutations: { ...deleteMutation },
      variables: { defines: ['block'], dql: query }
    };
  },
  rollForward: async (ctx: RollForwardContext) => {
    logger.trace('rollForward', ctx);
    const block: BlockType | undefined = getBlockType(ctx.block);
    let mutation;
    if (block !== undefined) {
      mutation = mapBlock(block as BlockType);
    } else if (isByronEpochBoundaryBlock(ctx.block))
      mutation = mapByronEpochBoundaryBlock(ctx.block.byron as Schema.EpochBoundaryBlock);
    else if (isByronStandardBlock(ctx.block)) mutation = mapByronBlock(ctx.block.byron as Schema.StandardBlock);
    return {
      mutations: { ...mutation, 'dgraph.type': 'Block' }
    };
  }
});
