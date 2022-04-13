import { Cardano, StakePoolQueryOptions } from '@cardano-sdk/core';

interface StakePoolSearchErrors {
  condition?: string;
  status?: string;
}
// TODO: this may be replaces by openApi schema validations
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const isValidStakePoolOptions = (request: StakePoolQueryOptions) => {
  const errors: StakePoolSearchErrors = {};
  if (request?.filters?._condition && !['and', 'or'].includes(request?.filters?._condition)) {
    errors.condition = 'Given condition is invalid';
  }
  if (
    request?.filters?.status &&
    Array.isArray(request?.filters?.status) &&
    request?.filters?.status.every((status) => !Object.values(Cardano.StakePoolStatus).includes(status))
  ) {
    errors.status = 'Given status is invalid';
  }
  return {
    errors,
    valid: Object.keys(errors).length === 0
  };
};
