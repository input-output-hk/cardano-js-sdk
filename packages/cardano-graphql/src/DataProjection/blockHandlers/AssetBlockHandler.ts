import { BlockHandler } from '../types';
import { dummyLogger } from 'ts-log';

export const createAssetBlockHandler = (logger = dummyLogger): BlockHandler => ({
  id: 'Asset',
  rollBackward: async ({ point }) => {
    logger.trace('rollBackward', point);
    return {
      mutations: {}
    };
  },
  rollForward: async (ctx) => {
    logger.trace('rollForward', ctx);
    return {
      mutations: {}
    };
  }
});
