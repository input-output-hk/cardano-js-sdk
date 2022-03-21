import { BlockHandler, RollBackwardContext, RollForwardContext } from '../types';
import { dummyLogger } from 'ts-log';
import { getBlockType, mapBlock } from './helpers';

const HANDLER_ID = 'Block';

export const createBlockBlockHandler = (logger = dummyLogger): BlockHandler => ({
  id: HANDLER_ID,
  rollBackward: async ({ point }: RollBackwardContext) => {
    logger.trace('rollBackward', point);
    const slot = point === 'origin' ? 0 : point.slot;
    const query = `
      query {
        var queryBlock(func: ge(number, ${slot})) {
            block {
                slot {
                    number 
                }
            }
        }
      }`;
    const deleteMutation = {
      blockNo: null,
      confirmations: null,
      epoch: null,
      hash: null,
      issuer: null,
      nextBlock: null,
      previousBlock: null,
      size: null,
      slot: null,
      totalFees: null,
      totalOutput: null,
      uid: 'uid(Block)'
    };
    return {
      mutations: { ...deleteMutation },
      variables: { defines: ['Block'], dql: query }
    };
  },
  rollForward: async (ctx: RollForwardContext) => {
    logger.trace('rollForward', ctx);
    const block = getBlockType(ctx.block);
    let mutation;
    if (block !== undefined) {
      mutation = mapBlock(block);
    }
    return {
      mutations: { ...mutation }
    };
  }
});
