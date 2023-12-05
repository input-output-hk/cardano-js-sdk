/* eslint-disable no-bitwise */
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { util as KeyManagementUtil } from '@cardano-sdk/key-management';
import { Observable, firstValueFrom } from 'rxjs';
import { ObservableWallet } from '../types';
import { ProtocolParametersRequiredByOutputValidator, createOutputValidator } from '@cardano-sdk/tx-construction';
import { txInEquals } from './util';
import uniqBy from 'lodash/uniqBy';

export interface InputResolverContext {
  utxo: {
    /** Subscribed on every InputResolver call */
    available$: Observable<Cardano.Utxo[]>;
  };
}

export interface WalletOutputValidatorContext {
  /* Subscribed on every OutputValidator call */
  protocolParameters$: Observable<ProtocolParametersRequiredByOutputValidator>;
}

export type WalletUtilContext = WalletOutputValidatorContext & InputResolverContext;

export const createInputResolver = ({ utxo }: InputResolverContext): Cardano.InputResolver => ({
  async resolveInput(input: Cardano.TxIn) {
    const utxoAvailable = await firstValueFrom(utxo.available$);
    const availableUtxo = utxoAvailable?.find(([txIn]) => txInEquals(txIn, input));
    if (!availableUtxo) return null;
    return availableUtxo[1];
  }
});

/**
 * @returns common wallet utility functions that are aware of wallet state and computes useful things
 */
export const createWalletUtil = (context: WalletUtilContext) => ({
  ...createOutputValidator({ protocolParameters: () => firstValueFrom(context.protocolParameters$) }),
  ...createInputResolver(context)
});

export type WalletUtil = ReturnType<typeof createWalletUtil>;

/** All transaction inputs and collaterals must come from our utxo set */
const hasForeignInputs = (
  { body: { inputs, collaterals = [] } }: { body: Pick<Cardano.TxBody, 'inputs' | 'collaterals'> },
  utxoSet: Cardano.Utxo[]
): boolean => [...inputs, ...collaterals].some((txIn) => utxoSet.every((utxo) => !txInEquals(txIn, utxo[0])));

/** Wallet does not include committee certificate keys, so they cannot be signed  */
const hasCommitteeCertificates = ({ certificates }: Cardano.TxBody) =>
  (certificates || []).some(
    (certificate) =>
      certificate.__typename === Cardano.CertificateType.AuthorizeCommitteeHot ||
      certificate.__typename === Cardano.CertificateType.ResignCommitteeCold
  );
/**
 * Gets whether the given TX requires signatures that can not be provided by the given wallet.
 *
 * @param tx The transaction to inspect.
 * @param wallet The wallet that will provide the signatures.
 * @returns true if the wallet can not sign all inputs/certificates; otherwise; false.
 */
export const requiresForeignSignatures = async (tx: Cardano.Tx, wallet: ObservableWallet): Promise<boolean> => {
  const utxoSet = await firstValueFrom(wallet.utxo.total$);
  const knownAddresses = await firstValueFrom(wallet.addresses$);
  const uniqueAccounts: KeyManagementUtil.StakeKeySignerData[] = uniqBy(knownAddresses, 'rewardAccount')
    .map((groupedAddress) => {
      const stakeKeyHash = Cardano.RewardAccount.toHash(groupedAddress.rewardAccount);
      return {
        derivationPath: groupedAddress.stakeKeyDerivationPath,
        poolId: Cardano.PoolId.fromKeyHash(stakeKeyHash),
        rewardAccount: groupedAddress.rewardAccount,
        stakeKeyHash
      };
    })
    .filter((acct): acct is KeyManagementUtil.StakeKeySignerData => acct.derivationPath !== null);

  const dRepKeyHash = (await Crypto.Ed25519PublicKey.fromHex(await wallet.getPubDRepKey()).hash()).hex();

  return (
    hasForeignInputs(tx, utxoSet) ||
    KeyManagementUtil.checkStakeCredentialCertificates(uniqueAccounts, tx.body).requiresForeignSignatures ||
    KeyManagementUtil.getDRepCredentialKeyPaths({ dRepKeyHash, txBody: tx.body }).requiresForeignSignatures ||
    KeyManagementUtil.getVotingProcedureKeyPaths({ dRepKeyHash, groupedAddresses: knownAddresses, txBody: tx.body })
      .requiresForeignSignatures ||
    hasCommitteeCertificates(tx.body)
  );
};
