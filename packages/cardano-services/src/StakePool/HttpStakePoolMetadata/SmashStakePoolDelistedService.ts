import { SmashStakePoolDelistedServiceError } from './errors.js';
import axios from 'axios';
import type { AxiosInstance } from 'axios';
import type { CustomError } from 'ts-custom-error';
import type { SmashDelistedResponse } from './types.js';
import type { SmashStakePoolDelistedService } from '../types.js';

export const createSmashStakePoolDelistedService = (
  smashUrl: string,
  axiosClient: AxiosInstance = axios.create({
    maxContentLength: 5000,
    timeout: 2 * 1000
  })
): SmashStakePoolDelistedService => ({
  async getDelistedStakePoolIds(): Promise<Array<string> | CustomError> {
    const smashDelistedUrl = `${smashUrl}/delisted`;
    return axiosClient
      .get<Array<SmashDelistedResponse>>(smashDelistedUrl)
      .then((response) => response.data.map((d) => d.poolId))
      .catch(
        (error) =>
          new SmashStakePoolDelistedServiceError(
            error,
            `SmashStakePoolDelistedService failed to fetch delisted pool ids from ${smashDelistedUrl} due to ${
              error ? error.message : 'unknown error'
            }`
          )
      );
  }
});
