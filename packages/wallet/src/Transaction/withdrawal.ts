import { Lovelace } from '@cardano-ogmios/schema';
import { Cardano, CardanoSerializationLib, CSL } from '@cardano-sdk/core';
import { KeyManager } from '../KeyManagement';

export type Withdrawal = {
  address: CSL.RewardAddress;
  quantity: CSL.BigNum;
};

export const withdrawal = (
  csl: CardanoSerializationLib,
  keyManager: KeyManager,
  quantity: Lovelace,
  network: number = Cardano.NetworkId.mainnet
): Withdrawal => ({
  address: csl.RewardAddress.new(network, csl.StakeCredential.from_keyhash(keyManager.stakeKey.hash())),
  quantity: csl.BigNum.from_str(quantity.toString())
});
