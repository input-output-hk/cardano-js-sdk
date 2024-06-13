/* eslint-disable no-bitwise */
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, ChainHistoryProvider } from '@cardano-sdk/core';
import { GroupedAddress, util as KeyManagementUtil, WitnessedTx } from '@cardano-sdk/key-management';
import { Observable, firstValueFrom } from 'rxjs';
import { ObservableWallet, ScriptAddress, isScriptAddress } from '../types';
import { ProtocolParametersRequiredByOutputValidator, createOutputValidator } from '@cardano-sdk/tx-construction';
import { txInEquals } from './util';
import uniqBy from 'lodash/uniqBy.js';

export interface InputResolverContext {
  utxo: {
    /** Subscribed on every InputResolver call */
    available$: Observable<Cardano.Utxo[]>;
  };
  transactions: {
    outgoing: {
      signed$: Observable<WitnessedTx[]>;
    };
  };
}

export interface WalletOutputValidatorContext {
  /* Subscribed on every OutputValidator call */
  protocolParameters$: Observable<ProtocolParametersRequiredByOutputValidator>;
}

export type WalletUtilContext = WalletOutputValidatorContext &
  InputResolverContext & { chainHistoryProvider?: ChainHistoryProvider };

export const createInputResolver = ({ utxo, transactions }: InputResolverContext): Cardano.InputResolver => ({
  async resolveInput(input: Cardano.TxIn, options?: Cardano.ResolveOptions) {
    const utxoAvailable = await firstValueFrom(utxo.available$, { defaultValue: [] });
    const signedTransactions = await firstValueFrom(transactions.outgoing.signed$, { defaultValue: [] });
    const utxoFromSigned = signedTransactions.flatMap(({ tx: signedTx }, signedTxIndex) =>
      signedTx.body.outputs
        .filter((_, outputIndex) => {
          const alreadyConsumed = signedTransactions.some(
            ({ tx: { body } }, i) =>
              signedTxIndex !== i &&
              body.inputs.some((consumedInput) => txInEquals(consumedInput, { index: outputIndex, txId: signedTx.id }))
          );

          return !alreadyConsumed;
        })
        .map((txOut): Cardano.Utxo => {
          const txIn: Cardano.HydratedTxIn = {
            address: txOut.address,
            index: signedTx.body.outputs.indexOf(txOut),
            txId: signedTx.id
          };
          return [txIn, txOut];
        })
    );
    const availableUtxo = [...utxoAvailable, ...utxoFromSigned].find(([txIn]) => txInEquals(txIn, input));

    if (availableUtxo) return availableUtxo[1];

    if (options?.hints) {
      const tx = options?.hints.find((hint) => hint.id === input.txId);

      if (tx && tx.body.outputs.length > input.index) {
        return tx.body.outputs[input.index];
      }
    }
    return null;
  }
});

/**
 * Creates an input resolver that fetch transaction inputs from the backend.
 *
 * This function tries to fetch the transaction from the backend using a `ChainHistoryProvider`. It
 * also caches fetched transactions to optimize subsequent input resolutions.
 *
 * @param provider The backend provider used to fetch transactions by their hashes if
 * they are not found by the inputResolver.
 * @returns An input resolver that can fetch unresolved inputs from the backend.
 */
export const createBackendInputResolver = (provider: ChainHistoryProvider): Cardano.InputResolver => {
  const txCache = new Map<Cardano.TransactionId, Cardano.Tx>();

  const fetchAndCacheTransaction = async (txId: Cardano.TransactionId): Promise<Cardano.Tx | null> => {
    if (txCache.has(txId)) {
      return txCache.get(txId)!;
    }

    const txs = await provider.transactionsByHashes({ ids: [txId] });
    if (txs.length > 0) {
      txCache.set(txId, txs[0]);
      return txs[0];
    }

    return null;
  };

  return {
    async resolveInput(input: Cardano.TxIn, options?: Cardano.ResolveOptions) {
      // Add hints to the cache
      if (options?.hints) {
        for (const hint of options.hints) {
          txCache.set(hint.id, hint);
        }
      }

      const tx = await fetchAndCacheTransaction(input.txId);
      if (!tx) return null;

      return tx.body.outputs.length > input.index ? tx.body.outputs[input.index] : null;
    }
  };
};

/**
 * Combines multiple input resolvers into a single resolver.
 *
 * @param resolvers The input resolvers to combine.
 */
export const combineInputResolvers = (...resolvers: Cardano.InputResolver[]): Cardano.InputResolver => ({
  async resolveInput(txIn: Cardano.TxIn, options?: Cardano.ResolveOptions) {
    for (const resolver of resolvers) {
      const resolved = await resolver.resolveInput(txIn, options);
      if (resolved) return resolved;
    }
    return null;
  }
});

/**
 * @returns common wallet utility functions that are aware of wallet state and computes useful things
 */
export const createWalletUtil = (context: WalletUtilContext) => ({
  ...createOutputValidator({ protocolParameters: () => firstValueFrom(context.protocolParameters$) }),
  ...(context.chainHistoryProvider
    ? combineInputResolvers(createInputResolver(context), createBackendInputResolver(context.chainHistoryProvider))
    : createInputResolver(context))
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
 * Gets whether the given transaction has certificates that require a witness that can not be provided by the script wallet.
 *
 * @param rewardAccount The reward account of the script wallet.
 * @param certificates The certificates to inspect.
 */
// eslint-disable-next-line complexity
const scriptWalletHasForeignCertificates = (
  rewardAccount: Cardano.RewardAccount,
  certificates?: Cardano.Certificate[]
  // eslint-disable-next-line sonarjs/cognitive-complexity
) => {
  if (!certificates) {
    return false;
  }

  const scriptHash = Cardano.RewardAccount.toHash(rewardAccount) as unknown as Crypto.Hash28ByteBase16;
  for (const certificate of certificates) {
    switch (certificate.__typename) {
      case Cardano.CertificateType.Registration:
      case Cardano.CertificateType.StakeRegistration:
      case Cardano.CertificateType.GenesisKeyDelegation:
        continue; // Doesnt require signature.
      case Cardano.CertificateType.StakeDeregistration:
      case Cardano.CertificateType.StakeDelegation:
      case Cardano.CertificateType.Unregistration:
      case Cardano.CertificateType.VoteDelegation:
      case Cardano.CertificateType.StakeVoteDelegation:
      case Cardano.CertificateType.StakeRegistrationDelegation:
      case Cardano.CertificateType.VoteRegistrationDelegation:
      case Cardano.CertificateType.MIR:
      case Cardano.CertificateType.StakeVoteRegistrationDelegation: {
        if (
          !certificate.stakeCredential ||
          certificate.stakeCredential.type !== Cardano.CredentialType.ScriptHash ||
          certificate.stakeCredential.hash !== scriptHash
        ) {
          return true;
        }

        break;
      }
      case Cardano.CertificateType.PoolRegistration: {
        const account = certificate.poolParameters.owners.find((acct) => acct === rewardAccount);

        if (!account) {
          return true;
        }

        break;
      }
      case Cardano.CertificateType.PoolRetirement:
        {
          const poolId = Cardano.PoolId.fromKeyHash(Cardano.RewardAccount.toHash(rewardAccount));
          if (certificate.poolId !== poolId) {
            return true;
          }
        }
        break;
      case Cardano.CertificateType.RegisterDelegateRepresentative:
      case Cardano.CertificateType.UnregisterDelegateRepresentative:
      case Cardano.CertificateType.UpdateDelegateRepresentative:
        if (
          !certificate.dRepCredential ||
          certificate.dRepCredential.type !== Cardano.CredentialType.ScriptHash ||
          certificate.dRepCredential.hash !== scriptHash
        ) {
          return true;
        }
        break;
      case Cardano.CertificateType.AuthorizeCommitteeHot:
      case Cardano.CertificateType.ResignCommitteeCold:
        return true;
    }
  }

  return false;
};

/**
 * Until CIP-095 supports script credential for dReps, we cant witness any voting procedures as the only
 * voter type for this type of wallet is DrepScriptHashVoter
 */
const scriptWalletHasForeignVotingProcedures = (
  rewardAccount: Cardano.RewardAccount,
  votingProcedures?: Cardano.VotingProcedures
) => {
  if (!votingProcedures) {
    return false;
  }

  for (const procedure of votingProcedures) {
    switch (procedure.voter.__typename) {
      case Cardano.VoterType.ccHotKeyHash:
      case Cardano.VoterType.ccHotScriptHash:
      case Cardano.VoterType.stakePoolKeyHash:
      case Cardano.VoterType.dRepKeyHash:
        return true;
      case Cardano.VoterType.dRepScriptHash: {
        const scriptHash = Cardano.RewardAccount.toHash(rewardAccount) as unknown as Crypto.Hash28ByteBase16;

        if (procedure.voter.credential.hash !== scriptHash) {
          return true;
        }
      }
    }
  }
  return false;
};

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
  const isScriptWallet = knownAddresses.some((address) => isScriptAddress(address));

  if (isScriptWallet) {
    const scriptAddresses = knownAddresses.map((address) => address as ScriptAddress);

    // Script addresses have a single payment credential and stake credential.
    return (
      hasForeignInputs(tx, utxoSet) ||
      scriptWalletHasForeignCertificates(scriptAddresses[0].rewardAccount, tx.body.certificates) ||
      scriptWalletHasForeignVotingProcedures(scriptAddresses[0].rewardAccount, tx.body.votingProcedures)
    );
  }

  const keyHashAddresses = knownAddresses.map((address) => address as GroupedAddress);

  const uniqueAccounts: KeyManagementUtil.StakeKeySignerData[] = uniqBy(keyHashAddresses, 'rewardAccount')
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

  const dRepKey = await wallet.governance.getPubDRepKey();
  const dRepKeyHash = dRepKey ? (await Crypto.Ed25519PublicKey.fromHex(dRepKey).hash()).hex() : undefined;

  return (
    hasForeignInputs(tx, utxoSet) ||
    KeyManagementUtil.checkStakeCredentialCertificates(uniqueAccounts, tx.body).requiresForeignSignatures ||
    (dRepKeyHash &&
      KeyManagementUtil.getDRepCredentialKeyPaths({ dRepKeyHash, txBody: tx.body }).requiresForeignSignatures) ||
    (dRepKeyHash &&
      KeyManagementUtil.getVotingProcedureKeyPaths({ dRepKeyHash, groupedAddresses: keyHashAddresses, txBody: tx.body })
        .requiresForeignSignatures) ||
    hasCommitteeCertificates(tx.body)
  );
};
