/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { ChangeAddressResolver, Selection } from '@cardano-sdk/input-selection';

export class MockChangeAddressResolver implements ChangeAddressResolver {
  async resolve(selection: Selection) {
    return selection.change.map((txOut) => ({
      ...txOut,
      address: Cardano.PaymentAddress(
        'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
      )
    }));
  }
}

export const getStakeCredential = (rewardAccount: Cardano.RewardAccount) => {
  const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount);
  return {
    hash: stakeKeyHash,
    type: Cardano.CredentialType.KeyHash
  };
};

export const getPaymentCredential = (address: Cardano.PaymentAddress) =>
  Cardano.Address.fromBech32(address).asBase()!.getPaymentCredential();

export const getPayToPubKeyHashScript = (keyHash: Crypto.Ed25519KeyHashHex): Cardano.Script => ({
  __type: Cardano.ScriptType.Native,
  keyHash,
  kind: Cardano.NativeScriptKind.RequireSignature
});
