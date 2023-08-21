/* eslint-disable no-bitwise */
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { Observable, firstValueFrom } from 'rxjs';
import { ObservableWallet } from '../types';
import { ProtocolParametersRequiredByOutputValidator, createOutputValidator } from '@cardano-sdk/tx-construction';
import { txInEquals } from './util';
import uniqBy from 'lodash/uniqBy';

export interface InputResolverContext {
  utxo: {
    /**
     * Subscribed on every InputResolver call
     */
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

type SetWalletUtilContext = (context: WalletUtilContext) => void;

/**
 * Creates a WalletUtil that has an additional function to `initialize` by setting the context.
 * Calls to WalletUtil functions will only resolve after initializing.
 *
 * @returns common wallet utility functions that are aware of wallet state and computes useful things
 */
export const createLazyWalletUtil = (): WalletUtil & { initialize: SetWalletUtilContext } => {
  let initialize: SetWalletUtilContext;
  const resolverReady = new Promise((resolve: SetWalletUtilContext) => (initialize = resolve)).then(createWalletUtil);
  return {
    initialize: initialize!,
    async resolveInput(input) {
      const resolver = await resolverReady;
      return resolver.resolveInput(input);
    },
    async validateOutput(output) {
      const resolver = await resolverReady;
      return resolver.validateOutput(output);
    },
    async validateOutputs(outputs) {
      const resolver = await resolverReady;
      return resolver.validateOutputs(outputs);
    },
    async validateValue(value) {
      const resolver = await resolverReady;
      return resolver.validateValue(value);
    },
    async validateValues(values) {
      const resolver = await resolverReady;
      return resolver.validateValues(values);
    }
  };
};

/**
 * Gets whether the given TX requires signatures that can not be provided by the given wallet.
 *
 * @param tx The transaction to inspect.
 * @param wallet The wallet that will provide the signatures.
 * @returns true if the wallet can not sign all inputs/certificates; otherwise; false.
 */
// eslint-disable-next-line complexity, sonarjs/cognitive-complexity
export const requiresForeignSignatures = async (tx: Cardano.Tx, wallet: ObservableWallet): Promise<boolean> => {
  const utxoSet = await firstValueFrom(wallet.utxo.total$);
  const knownAddresses = await firstValueFrom(wallet.addresses$);
  const uniqueAccounts = uniqBy(knownAddresses, 'rewardAccount').map((groupedAddress) => {
    const stakeKeyHash = Cardano.RewardAccount.toHash(groupedAddress.rewardAccount);
    return {
      poolId: Cardano.PoolId.fromKeyHash(stakeKeyHash),
      rewardAccount: groupedAddress.rewardAccount,
      stakeKeyHash
    };
  });

  // Iterate over the inputs and see if all of them are present in our UTXO set.
  for (const input of tx.body.inputs) {
    const ownsInput = utxoSet.find(
      (utxo: Cardano.Utxo) => input.txId === utxo[0].txId && input.index === utxo[0].index
    );

    if (!ownsInput) return true;
  }

  // Iterate over the collateral inputs and see if all of them are present in our UTXO set.
  if (tx.body.collaterals) {
    for (const input of tx.body.collaterals) {
      const ownsInput = utxoSet.find(
        (utxo: Cardano.Utxo) => input.txId === utxo[0].txId && input.index === utxo[0].index
      );

      if (!ownsInput) return true;
    }
  }

  // If all inputs are accounted for, see if all certificates belong to any of our reward accounts.
  if (!tx.body.certificates) return false;

  for (const certificate of tx.body.certificates) {
    let matchesOneAccount = false;

    for (const account of uniqueAccounts) {
      switch (certificate.__typename) {
        case Cardano.CertificateType.StakeKeyDeregistration:
        case Cardano.CertificateType.StakeDelegation:
          if (certificate.stakeKeyHash === account.stakeKeyHash) matchesOneAccount = true;
          break;
        case Cardano.CertificateType.PoolRegistration:
          for (const owner of certificate.poolParameters.owners) {
            // eslint-disable-next-line max-depth
            if (owner === account.rewardAccount) matchesOneAccount = true;
          }
          break;
        case Cardano.CertificateType.PoolRetirement:
          if (certificate.poolId === account.poolId) matchesOneAccount = true;
          break;
        case Cardano.CertificateType.MIR:
          if (
            certificate.kind === Cardano.MirCertificateKind.ToStakeCreds &&
            certificate.stakeCredential!.hash ===
              Crypto.Hash28ByteBase16(Cardano.RewardAccount.toHash(account.rewardAccount))
          )
            matchesOneAccount = true;
          break;
        case Cardano.CertificateType.StakeKeyRegistration:
        case Cardano.CertificateType.GenesisKeyDelegation:
        default:
          // These certificates don't require our signature, so we will map them as 'accounted for'.
          matchesOneAccount = true;
      }
    }

    // If it doesn't match at least one account, then it requires a foreign signature.
    if (!matchesOneAccount) return true;
  }

  return false;
};
