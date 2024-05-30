import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, GroupedAddress, KeyPurpose } from '@cardano-sdk/key-management';
import { Cardano, nativeScriptPolicyId } from '@cardano-sdk/core';

/**
 * Method to derive the wallet's grouped address from the script and network ID.
 *
 * @param {Cardano.NativeScript} paymentScript - The native script to be used for the payment credential.
 * @param {Cardano.NativeScript} stakingScript - The native script to be used for the staking credential.
 * @param {Cardano.NetworkId} networkId - The network identifier.
 * @returns {}GroupedAddress} The derived grouped address.
 */
export const getScriptAddress = (
  paymentScript: Cardano.NativeScript,
  stakingScript: Cardano.NativeScript,
  networkId: Cardano.NetworkId
): GroupedAddress => {
  const paymentScriptHash = nativeScriptPolicyId(paymentScript) as unknown as Crypto.Hash28ByteBase16;
  const stakingScriptHash = nativeScriptPolicyId(stakingScript) as unknown as Crypto.Hash28ByteBase16;

  const paymentScriptCredential = {
    hash: paymentScriptHash,
    type: Cardano.CredentialType.ScriptHash
  };

  const stakeScriptCredential = {
    hash: stakingScriptHash,
    type: Cardano.CredentialType.ScriptHash
  };

  const baseAddress = Cardano.BaseAddress.fromCredentials(networkId, paymentScriptCredential, stakeScriptCredential);

  return {
    accountIndex: 0,
    address: baseAddress.toAddress().toBech32() as Cardano.PaymentAddress,
    index: 0,
    networkId,
    purpose: KeyPurpose.STANDARD,
    rewardAccount: Cardano.RewardAddress.fromCredentials(networkId, stakeScriptCredential)
      .toAddress()
      .toBech32() as Cardano.RewardAccount,
    type: AddressType.External
  };
};
