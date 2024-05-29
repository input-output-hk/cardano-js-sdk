import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano } from '@cardano-sdk/core';
import { CardanoKeyConst, GroupedAddress, KeyPurpose, util } from '@cardano-sdk/key-management';
import { InvalidArgumentError, Transform, areNumbersEqualInConstantTime } from '@cardano-sdk/util';
import { LedgerTxTransformerContext } from '../types';

interface ResolveKeyPathParams {
  rewardAddress: Cardano.RewardAddress;
  knownAddresses: GroupedAddress[] | undefined;
  purpose?: KeyPurpose;
}

const resolveKeyPath = ({
  rewardAddress,
  knownAddresses,
  purpose = KeyPurpose.STANDARD
}: ResolveKeyPathParams): Ledger.BIP32Path | null => {
  if (!knownAddresses) return null;

  const knownAddress = knownAddresses.find(
    ({ rewardAccount }) => rewardAccount === rewardAddress.toAddress().toBech32()
  );

  if (knownAddress && knownAddress.stakeKeyDerivationPath) {
    return [
      util.harden(purpose),
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
    const keyPath = resolveKeyPath({ knownAddresses: context?.knownAddresses, rewardAddress });
    ledgerWithdrawal = keyPath
      ? {
          amount: withdrawal.quantity,
          stakeCredential: {
            keyPath,
            type: Ledger.CredentialParamsType.KEY_PATH
          } as Ledger.KeyPathCredentialParams
        }
      : {
          amount: withdrawal.quantity,
          stakeCredential: {
            keyHashHex: rewardAddress.getPaymentCredential().hash.toString(),
            type: Ledger.CredentialParamsType.KEY_HASH
          } as Ledger.KeyHashCredentialParams
        };
  } else {
    ledgerWithdrawal = {
      amount: withdrawal.quantity,
      stakeCredential: {
        scriptHashHex: rewardAddress.getPaymentCredential().hash.toString(),
        type: Ledger.CredentialParamsType.SCRIPT_HASH
      } as Ledger.ScriptHashCredentialParams
    };
  }

  return ledgerWithdrawal;
};

export const mapWithdrawals = (
  withdrawals: Cardano.Withdrawal[] | undefined,
  context: LedgerTxTransformerContext
): Ledger.Withdrawal[] | null => {
  if (!withdrawals) return null;
  // Sort withdrawals by address bytes, canonically
  withdrawals.sort((a, b) => {
    const rewardAddress1 = Cardano.Address.fromString(a.stakeAddress)?.asReward();
    const rewardAddress2 = Cardano.Address.fromString(b.stakeAddress)?.asReward();
    if (!rewardAddress1 || !rewardAddress2)
      throw new InvalidArgumentError('withdrawal', 'Invalid withdrawal stake address');
    return rewardAddress1.toAddress().toBytes() > rewardAddress2.toAddress().toBytes() ? 1 : -1;
  });
  return withdrawals.map((coreWithdrawal) => toWithdrawal(coreWithdrawal, context));
};
