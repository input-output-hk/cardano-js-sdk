import { AxiosError, AxiosResponse } from 'axios';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { toSerializableObject } from '@cardano-sdk/util';

export const axiosError = (bodyError = new Error('error')) => {
  const response = {
    data: toSerializableObject(new ProviderError(ProviderFailure.BadRequest, bodyError))
  } as AxiosResponse;
  const error = new AxiosError(undefined, undefined, undefined, undefined, response);
  Object.defineProperty(error, 'response', { value: response });
  return error;
};

export const healthCheckResponseWithState = {
  localNode: {
    ledgerTip: {
      blockNo: 3_391_731,
      hash: '9ef43ab6e234fcf90d103413096c7da752da2f45b15e1259f43d476afd12932c',
      slot: 52_819_355
    },
    networkSync: 0.999
  },
  ok: true
};
