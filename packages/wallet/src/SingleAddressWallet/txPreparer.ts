import { BehaviorSubject, Observable, combineLatest, filter, firstValueFrom, lastValueFrom, map, take } from 'rxjs';
import { Cardano, coreToCsl } from '@cardano-sdk/core';
import { FinalizeTxProps, InitializeTxProps, ObservableWallet } from '../types';
import { Logger } from 'ts-log';
import { createTransactionInternals, ensureValidityInterval } from '../Transaction';
import { defaultSelectionConstraints } from '@cardano-sdk/input-selection';
import { oneDistinctAfterTrigger } from '../services';

export interface PrepareTxDependencies {
  wallet: Pick<ObservableWallet, 'tip$' | 'protocolParameters$' | 'addresses$' | 'currentEpoch$'> & {
    delegation: Pick<ObservableWallet['delegation'], 'rewardAccounts$'>;
    utxo: Pick<ObservableWallet['utxo'], 'available$'>;
  };
  signer: {
    stubFinalizeTx(props: FinalizeTxProps): Observable<Cardano.NewTxAlonzo>;
  };
  logger: Logger;
}

export const createTxPreparer = ({ wallet, signer, logger }: PrepareTxDependencies) => {
  // TODO: fetching rewards before building every tx is a workaround to a problem described in
  // ../services/DelegationTracker/RewardAccounts.ts/addressRewards inline comment.
  // Once it's resolved, something like this should work:
  const consistentWithdrawals$ = new BehaviorSubject<Cardano.Withdrawal[] | undefined | null>(null);
  const subscriptions = wallet.delegation.rewardAccounts$
    .pipe(
      map((accounts) => accounts.filter(({ rewardBalance }) => rewardBalance)),
      oneDistinctAfterTrigger(
        wallet.currentEpoch$,
        // TODO: The 'equals' should only look for epochNo of the spendable rewards data.
        () => false
      ),
      map((accounts) =>
        accounts.map((account) => ({ quantity: account.rewardBalance, stakeAddress: account.address }))
      ),
      map((withdrawals) => (withdrawals.length > 0 ? withdrawals : undefined))
    )
    .subscribe(consistentWithdrawals$);
  subscriptions.add(
    wallet.currentEpoch$.subscribe(() => {
      if (consistentWithdrawals$.value !== undefined) consistentWithdrawals$.next(null);
    })
  );
  return {
    prepareTx: (props: InitializeTxProps) =>
      lastValueFrom(
        combineLatest([
          wallet.tip$,
          wallet.utxo.available$,
          wallet.protocolParameters$,
          wallet.addresses$,
          consistentWithdrawals$.pipe(
            filter((withdrawals): withdrawals is Cardano.Withdrawal[] | undefined => withdrawals !== null)
          )
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
      ),
    shutdown() {
      consistentWithdrawals$.complete();
    }
  };
};

export type TxPreparer = ReturnType<typeof createTxPreparer>;
