import * as Trezor from '@trezor/connect';
import { Cardano } from '@cardano-sdk/core';
import { InvalidArgumentError, Transform, areNumbersEqualInConstantTime } from '@cardano-sdk/util';
import { TrezorTxTransformerContext } from '../types';
import { resolveStakeKeyPath } from './keyPaths';

export const toTrezorWithdrawal: Transform<Cardano.Withdrawal, Trezor.CardanoWithdrawal, TrezorTxTransformerContext> = (
  withdrawal,
  context
) => {
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
  if (areNumbersEqualInConstantTime(rewardAddress.getPaymentCredential().type, Cardano.CredentialType.KeyHash)) {
    const keyPath = context?.knownAddresses ? resolveStakeKeyPath(rewardAddress, context.knownAddresses) : null;
    trezorWithdrawal = keyPath
      ? {
          amount: withdrawal.quantity.toString(),
          keyHash: undefined,
          path: keyPath,
          scriptHash: undefined
        }
      : {
          amount: withdrawal.quantity.toString(),
          keyHash: rewardAddress.getPaymentCredential().hash.toString(),
          path: undefined,
          scriptHash: undefined
        };
  } else {
    trezorWithdrawal = {
      amount: withdrawal.quantity.toString(),
      keyHash: undefined,
      path: undefined,
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
