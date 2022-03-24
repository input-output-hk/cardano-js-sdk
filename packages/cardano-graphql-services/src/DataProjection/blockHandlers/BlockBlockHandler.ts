import { BlockHandler, RollBackwardContext, RollForwardContext } from '../types';
import { BlockType, getBlockType, getByronBlock, mapBlock, mapByronBlock } from './helpers';
import { Schema, isByronEpochBoundaryBlock } from '@cardano-ogmios/client';
import { dummyLogger } from 'ts-log';

const HANDLER_ID = 'Block';

export const createBlockBlockHandler = (logger = dummyLogger): BlockHandler => ({
  id: HANDLER_ID,
  rollBackward: async ({ point }: RollBackwardContext) => {
    logger.trace('rollBackward', point);
    const slot = point === 'origin' ? 0 : point.slot;
    const query = `
    {
      Block AS var(func: type(Block)) {
            slot @filter(ge(number, ${slot})) {
               number
             }         
      }
    }`;
    const deleteMutation = {
      uid: 'uid(Block)'
    };
    return {
      mutations: { ...deleteMutation },
      variables: { defines: ['Block'], dql: query }
    };
  },
  rollForward: async (ctx: RollForwardContext) => {
    logger.trace('rollForward', ctx);
    let block: BlockType | Schema.StandardBlock | undefined = getBlockType(ctx.block);
    let mutation;
    if (block === undefined) {
      if (isByronEpochBoundaryBlock(ctx.block)) return { mutations: {} };
      block = getByronBlock(ctx.block as Schema.Block);
      mutation = mapByronBlock(block as Schema.StandardBlock);
    } else {
      mutation = mapBlock(block);
    }
    return {
      mutations: { ...mutation, 'dgraph.type': 'Block' }
    };
  }
});
