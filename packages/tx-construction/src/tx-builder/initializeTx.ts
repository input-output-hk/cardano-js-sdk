import { StaticChangeAddressResolver, roundRobinRandomImprove } from '@cardano-sdk/input-selection';

import { Cardano } from '@cardano-sdk/core';
import { InitializeTxProps, InitializeTxResult } from '../types';
import { TxBuilderDependencies } from './types';
import { createTransactionInternals } from '../createTransactionInternals';
import { defaultSelectionConstraints } from '../input-selection';
import { ensureValidityInterval } from '../ensureValidityInterval';
import { finalizeTx } from './finalizeTx';
import { util } from '@cardano-sdk/key-management';

export const initializeTx = async (
  props: InitializeTxProps,
  {
    txBuilderProviders,
    inputSelector,
    inputResolver,
    bip32Account: addressManager,
    witnesser,
    logger
  }: TxBuilderDependencies
): Promise<InitializeTxResult> => {
  const [tip, genesisParameters, protocolParameters, rewardAccounts, utxo, addresses] = await Promise.all([
    txBuilderProviders.tip(),
    txBuilderProviders.genesisParameters(),
    txBuilderProviders.protocolParameters(),
    txBuilderProviders.rewardAccounts(),
    txBuilderProviders.utxoAvailable(),
    txBuilderProviders.addresses.get()
  ]);

  inputSelector =
    inputSelector ??
    roundRobinRandomImprove({
      changeAddressResolver: new StaticChangeAddressResolver(async () => addresses)
    });

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
      const unsignedTx = await createTransactionInternals({
        auxiliaryData: props.auxiliaryData,
        certificates: props.certificates,
        collaterals: props.collaterals,
        inputSelection,
        mint: props.mint,
        requiredExtraSignatures: props.requiredExtraSignatures,
        scriptIntegrityHash: props.scriptIntegrityHash,
        validityInterval,
        ...(withdrawals.length > 0 ? { withdrawals } : {})
      });

      const { tx } = await finalizeTx(
        unsignedTx,
        {
          auxiliaryData: props.auxiliaryData,
          handleResolutions: props.handleResolutions ?? [],
          signingContext: {
            knownAddresses: addresses,
            txInKeyPathMap: await util.createTxInKeyPathMap(unsignedTx.body, addresses, inputResolver)
          },
          signingOptions: props.signingOptions,
          witness: props.witness
        },
        { bip32Account: addressManager, witnesser },
        true
      );
      return tx;
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
    collaterals: props.collaterals,
    inputSelection,
    mint: props.mint,
    requiredExtraSignatures: props.requiredExtraSignatures,
    scriptIntegrityHash: props.scriptIntegrityHash,
    validityInterval,
    ...(withdrawals.length > 0 ? { withdrawals } : {})
  });

  return { body, hash, inputSelection };
};
