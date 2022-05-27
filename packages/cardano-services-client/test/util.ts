import { AxiosError, AxiosResponse } from 'axios';
import { ProviderError, ProviderFailure, util } from '@cardano-sdk/core';

export const axiosError = (bodyError = new Error('error')) => {
  const response = {
    data: util.toSerializableObject(new ProviderError(ProviderFailure.BadRequest, bodyError))
  } as AxiosResponse;
  const error = new AxiosError(undefined, undefined, undefined, undefined, response);
  Object.defineProperty(error, 'response', { value: response });
  return error;
};
