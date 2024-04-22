import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano } from '@cardano-sdk/core';
import { CardanoKeyConst, GroupedAddress, util } from '@cardano-sdk/key-management';
import { InvalidArgumentError, Transform, areNumbersEqualInConstantTime } from '@cardano-sdk/util';
import { LedgerTxTransformerContext } from '../types';

const resolveKeyPath = (
  rewardAddress: Cardano.RewardAddress,
  knownAddresses: GroupedAddress[] | undefined
): Ledger.BIP32Path | null => {
  if (!knownAddresses) return null;

  const knownAddress = knownAddresses.find(
    ({ rewardAccount }) => rewardAccount === rewardAddress.toAddress().toBech32()
  );

  if (knownAddress && knownAddress.stakeKeyDerivationPath) {
    return [
      util.harden(CardanoKeyConst.PURPOSE),
      util.harden(CardanoKeyConst.COIN_TYPE),
      util.harden(knownAddress.accountIndex),
      knownAddress.stakeKeyDerivationPath.role,
      knownAddress.stakeKeyDerivationPath.index
    ];
  }

  return null;
};

export const toWithdrawal: Transform<Cardano.Withdrawal, Ledger.Withdrawal, LedgerTxTransformerContext> = (
  withdrawal,
  context
) => {
  const address = Cardano.Address.fromString(withdrawal.stakeAddress);
  const rewardAddress = address?.asReward();

  if (!rewardAddress) throw new InvalidArgumentError('withdrawal', 'Invalid withdrawal stake address');

  let ledgerWithdrawal;

  if (areNumbersEqualInConstantTime(rewardAddress.getPaymentCredential().type, Cardano.CredentialType.KeyHash)) {
    const keyPath = resolveKeyPath(rewardAddress, context?.knownAddresses);
    ledgerWithdrawal = keyPath
      ? {
          amount: withdrawal.quantity,
          stakeCredential: {
            keyPath,
            type: Ledger.StakeCredentialParamsType.KEY_PATH
          } as Ledger.KeyPathStakeCredentialParams
        }
      : {
          amount: withdrawal.quantity,
          stakeCredential: {
            keyHashHex: rewardAddress.getPaymentCredential().hash.toString(),
            type: Ledger.StakeCredentialParamsType.KEY_HASH
          } as Ledger.KeyHashStakeCredentialParams
        };
  } else {
    ledgerWithdrawal = {
      amount: withdrawal.quantity,
      stakeCredential: {
        scriptHashHex: rewardAddress.getPaymentCredential().hash.toString(),
        type: Ledger.StakeCredentialParamsType.SCRIPT_HASH
      } as Ledger.ScriptStakeCredentialParams
    };
  }

  return ledgerWithdrawal;
};

export const mapWithdrawals = (
  withdrawals: Cardano.Withdrawal[] | undefined,
  context: LedgerTxTransformerContext
): Ledger.Withdrawal[] | null =>
  withdrawals ? withdrawals.map((coreWithdrawal) => toWithdrawal(coreWithdrawal, context)) : null;
