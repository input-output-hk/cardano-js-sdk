import { ManagedFreeableScope } from '@cardano-sdk/util';
import { roundRobinRandomImprove } from '@cardano-sdk/input-selection';

import { Cardano } from '@cardano-sdk/core';
import { InitializeTxProps, InitializeTxResult, TxBuilderDependencies } from '../types';
import { createTransactionInternals, defaultSelectionConstraints, ensureValidityInterval, finalizeTx } from '../';

export const initializeTx = async (
  props: InitializeTxProps,
  {
    txBuilderProviders,
    inputSelector = roundRobinRandomImprove(),
    inputResolver,
    keyAgent,
    logger
  }: TxBuilderDependencies
): Promise<InitializeTxResult> => {
  const scope = new ManagedFreeableScope();

  const [tip, genesisParameters, protocolParameters, addresses, changeAddress, rewardAccounts, utxo] =
    await Promise.all([
      txBuilderProviders.tip(),
      txBuilderProviders.genesisParameters(),
      txBuilderProviders.protocolParameters(),
      txBuilderProviders.addresses(),
      txBuilderProviders.changeAddress(),
      txBuilderProviders.rewardAccounts(),
      txBuilderProviders.utxoAvailable()
    ]);
  const validityInterval = ensureValidityInterval(tip.slot, genesisParameters, props.options?.validityInterval);
  const withdrawals: Cardano.Withdrawal[] = rewardAccounts
    .map(({ rewardBalance: quantity, address: stakeAddress }) => ({
      quantity,
      stakeAddress
    }))
    .filter(({ quantity }) => !!quantity);

  const constraints = defaultSelectionConstraints({
    buildTx: async (inputSelection) => {
      logger.debug('Building TX for selection constraints', inputSelection);
      if (withdrawals.length > 0) {
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
        ...(withdrawals.length > 0 ? { withdrawals } : {})
      });

      return await finalizeTx(
        {
          addresses,
          auxiliaryData: props.auxiliaryData,
          scripts: props.scripts,
          signingOptions: props.signingOptions,
          tx: txInternals,
          witness: props.witness
        },
        { inputResolver, keyAgent },
        true
      );
    },
    protocolParameters
  });

  const implicitCoin = Cardano.util.computeImplicitCoin(protocolParameters, {
    certificates: props.certificates,
    withdrawals
  });

  const { selection: inputSelection } = await inputSelector.select({
    constraints,
    implicitValue: { coin: implicitCoin, mint: props.mint },
    outputs: props.outputs || new Set(),
    utxo: new Set(utxo)
  });
  const { body, hash } = await createTransactionInternals({
    auxiliaryData: props.auxiliaryData,
    certificates: props.certificates,
    changeAddress,
    collaterals: props.collaterals,
    inputSelection,
    mint: props.mint,
    requiredExtraSignatures: props.requiredExtraSignatures,
    scriptIntegrityHash: props.scriptIntegrityHash,
    validityInterval,
    ...(withdrawals.length > 0 ? { withdrawals } : {})
  });

  scope.dispose();
  return { body, hash, inputSelection };
};
