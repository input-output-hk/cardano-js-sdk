import { CSL, Cardano } from '@cardano-sdk/core';
import { KeyManager } from '../KeyManagement';

export type Withdrawal = {
  address: CSL.RewardAddress;
  quantity: CSL.BigNum;
};

export const withdrawal = (
  keyManager: KeyManager,
  quantity: Cardano.Lovelace,
  network: number = Cardano.NetworkId.mainnet
): Withdrawal => ({
  address: CSL.RewardAddress.new(network, CSL.StakeCredential.from_keyhash(keyManager.stakeKey.hash())),
  quantity: CSL.BigNum.from_str(quantity.toString())
});
