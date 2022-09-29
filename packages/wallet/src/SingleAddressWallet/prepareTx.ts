import { Cardano, coreToCsl } from '@cardano-sdk/core';
import { FinalizeTxProps, InitializeTxProps, ObservableWallet } from '../types';
import { Logger } from 'ts-log';
import { Observable, combineLatest, firstValueFrom, lastValueFrom, map, take } from 'rxjs';
import { createTransactionInternals, ensureValidityInterval } from '../Transaction';
import { defaultSelectionConstraints } from '@cardano-sdk/input-selection';

export interface PrepareTxDependencies {
  wallet: Pick<ObservableWallet, 'tip$' | 'protocolParameters$' | 'addresses$'> & {
    delegation: Pick<ObservableWallet['delegation'], 'rewardAccounts$'>;
    utxo: Pick<ObservableWallet['utxo'], 'available$'>;
  };
  signer: {
    stubFinalizeTx(props: FinalizeTxProps): Observable<Cardano.NewTxAlonzo>;
  };
  logger: Logger;
}

export const createTxPreparer =
  ({ wallet, signer, logger }: PrepareTxDependencies) =>
  (props: InitializeTxProps) => {
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
        withdrawals$
      ]).pipe(
        take(1),
        map(([tip, utxo, protocolParameters, [{ address: changeAddress }], withdrawals]) => {
          const validityInterval = ensureValidityInterval(tip.slot, props.options?.validityInterval);
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
              return coreToCsl.tx(
                await firstValueFrom(
                  signer.stubFinalizeTx({
                    auxiliaryData: props.auxiliaryData,
                    extraSigners: props.extraSigners,
                    scripts: props.scripts,
                    signingOptions: props.signingOptions,
                    tx: txInternals
                  })
                )
              );
            },
            protocolParameters
          });
          const implicitCoin = Cardano.util.computeImplicitCoin(protocolParameters, props);
          return { changeAddress, constraints, implicitCoin, utxo, validityInterval, withdrawals };
        })
      )
    );
  };

export type PrepareTx = ReturnType<typeof createTxPreparer>;
