import { CSL } from '@cardano-sdk/core';

export type Withdrawal = {
  address: CSL.RewardAddress;
  quantity: CSL.BigNum;
};
