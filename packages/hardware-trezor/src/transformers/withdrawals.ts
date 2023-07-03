import * as Trezor from 'trezor-connect';
import { Cardano } from '@cardano-sdk/core';
import { InvalidArgumentError } from '@cardano-sdk/util';
import { TrezorTxTransformerContext } from '../types';
import { resolveStakeKeyPath } from './keyPaths';

export const toTrezorWithdrawal = (
  withdrawal: Cardano.Withdrawal,
  context: TrezorTxTransformerContext
): Trezor.CardanoWithdrawal => {
  const address = Cardano.Address.fromString(withdrawal.stakeAddress);
  const rewardAddress = address?.asReward();

  if (!rewardAddress) throw new InvalidArgumentError('withdrawal', 'Invalid withdrawal stake address');

  let trezorWithdrawal;
  /**
   * The credential specifies who should control the funds or the staking rights for that address.
   *
   * The credential type could be:
   * - The stake key hash or payment key hash, blake2b-224 hash digests of Ed25519 verification keys.
   * - The script hash, blake2b-224 hash digests of serialized monetary scripts.
   */
  if (rewardAddress.getPaymentCredential().type === Cardano.CredentialType.KeyHash) {
    const keyPath = resolveStakeKeyPath(rewardAddress, context);
    trezorWithdrawal = keyPath
      ? {
          amount: withdrawal.quantity.toString(),
          path: keyPath
        }
      : {
          amount: withdrawal.quantity.toString(),
          keyHash: rewardAddress.getPaymentCredential().hash.toString()
        };
  } else {
    trezorWithdrawal = {
      amount: withdrawal.quantity.toString(),
      scriptHash: rewardAddress.getPaymentCredential().hash.toString()
    };
  }

  return trezorWithdrawal;
};

export const mapWithdrawals = (
  withdrawals: Cardano.Withdrawal[] | undefined,
  context: TrezorTxTransformerContext
): Trezor.CardanoWithdrawal[] | undefined =>
  withdrawals ? withdrawals.map((coreWithdrawal) => toTrezorWithdrawal(coreWithdrawal, context)) : undefined;
