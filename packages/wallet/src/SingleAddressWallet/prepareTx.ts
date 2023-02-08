import { Cardano } from '@cardano-sdk/core';
import { FinalizeTxProps, InitializeTxProps, ObservableWallet } from '../types';
import { Logger } from 'ts-log';
import { Observable, combineLatest, filter, firstValueFrom, lastValueFrom, map, take } from 'rxjs';
import { createTransactionInternals, ensureValidityInterval } from '../Transaction';
import { defaultSelectionConstraints } from '@cardano-sdk/tx-construction';

export interface PrepareTxDependencies {
  wallet: Pick<ObservableWallet, 'tip$' | 'protocolParameters$' | 'addresses$' | 'genesisParameters$'> & {
    delegation: Pick<ObservableWallet['delegation'], 'rewardAccounts$'>;
    utxo: Pick<ObservableWallet['utxo'], 'available$'>;
    syncStatus: Pick<ObservableWallet['syncStatus'], 'isSettled$'>;
  };
  signer: {
    stubFinalizeTx(props: FinalizeTxProps): Observable<Cardano.Tx>;
  };
  logger: Logger;
}

export const createTxPreparer =
  ({ wallet, signer, logger }: PrepareTxDependencies) =>
  async (props: InitializeTxProps) => {
    await firstValueFrom(wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)));
    const withdrawals$: Observable<Cardano.Withdrawal[] | undefined> = wallet.delegation.rewardAccounts$.pipe(
      map((accounts) => accounts.filter((account) => account.rewardBalance)),
      map((accounts) =>
        accounts.map((account) => ({ quantity: account.rewardBalance, stakeAddress: account.address }))
      ),
      map((withdrawals) => (withdrawals.length > 0 ? withdrawals : undefined))
    );
    return lastValueFrom(
      combineLatest([
        wallet.tip$,
        wallet.utxo.available$,
        wallet.protocolParameters$,
        wallet.addresses$,
        withdrawals$,
        wallet.genesisParameters$
      ]).pipe(
        take(1),
        map(([tip, utxo, protocolParameters, [{ address: changeAddress }], withdrawals, genesisParameters]) => {
          const validityInterval = ensureValidityInterval(tip.slot, genesisParameters, props.options?.validityInterval);
          const constraints = defaultSelectionConstraints({
            buildTx: async (inputSelection) => {
              logger.debug('Building TX for selection constraints', inputSelection);
              if (withdrawals?.length) {
                logger.debug('Adding rewards withdrawal in the transaction', withdrawals);
              }
              const txInternals = await createTransactionInternals({
                auxiliaryData: props.auxiliaryData,
                certificates: props.certificates,
                changeAddress,
                collaterals: props.collaterals,
                inputSelection,
                mint: props.mint,
                requiredExtraSignatures: props.requiredExtraSignatures,
                scriptIntegrityHash: props.scriptIntegrityHash,
                validityInterval,
                withdrawals
              });

              return await firstValueFrom(
                signer.stubFinalizeTx({
                  auxiliaryData: props.auxiliaryData,
                  extraSigners: props.extraSigners,
                  scripts: props.scripts,
                  signingOptions: props.signingOptions,
                  tx: txInternals
                })
              );
            },
            protocolParameters
          });
          const implicitCoin = Cardano.util.computeImplicitCoin(protocolParameters, {
            certificates: props.certificates,
            withdrawals
          });
          return { changeAddress, constraints, implicitCoin, utxo, validityInterval, withdrawals };
        })
      )
    );
  };

export type PrepareTx = ReturnType<typeof createTxPreparer>;
