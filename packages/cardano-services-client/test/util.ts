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
