import { CustomError } from 'ts-custom-error';
import { SmashDelistedResponse } from './types';
import { SmashStakePoolDelistedService } from '../types';
import { SmashStakePoolDelistedServiceError } from './errors';
import axios, { AxiosInstance } from 'axios';

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
