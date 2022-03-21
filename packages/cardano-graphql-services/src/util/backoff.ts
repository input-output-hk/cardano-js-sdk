/* eslint-disable no-console */
import { getConfig } from '../config';

const { retryLimit } = getConfig();
const EXPONENTIAL_BACKOFF_BASE = 2;
const EXPONENTIAL_BACKOFF_STARTING = 1000;

const sleep = (time: number) => new Promise((resolve) => setTimeout(resolve, time));

export const exponentialBackoff = async (callback: Function) => {
  console.error('Starting exponential backoff');
  let shouldContinue = true;
  let round = 0;
  let result;

  while (shouldContinue) {
    console.log(`Exponential backoff, round: ${round}`);
    try {
      await sleep(EXPONENTIAL_BACKOFF_STARTING * EXPONENTIAL_BACKOFF_BASE ** round);
      result = await callback;
      console.log('Exponential backoff - callback done');
      shouldContinue = false;
    } catch (error) {
      console.error('Exponential backoff - error thrown');
      round++;
      if (round === retryLimit) {
        console.error('Retry limit met, finishing exponential backoff');
        shouldContinue = false;
        throw error;
      }
    }
  }
  return { result, success: !!result };
};
