import { StaticChangeAddressResolver, roundRobinRandomImprove } from '@cardano-sdk/input-selection';

import { Cardano } from '@cardano-sdk/core';
import { InitializeTxProps, InitializeTxResult } from '../types';
import { TxBuilderDependencies } from './types';
import { createPreInputSelectionTxBody, includeChangeAndInputs } from '../createTransactionInternals';
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

  // Create transaction body that can be customized by the user via the customizeCb
  const { txBody, auxiliaryData } = createPreInputSelectionTxBody({
    auxiliaryData: props.auxiliaryData,
    certificates: props.certificates,
    collaterals: props.collaterals,
    mint: props.mint,
    outputs: [...(props.outputs || [])],
    requiredExtraSignatures: props.requiredExtraSignatures,
    scriptIntegrityHash: props.scriptIntegrityHash,
    validityInterval: ensureValidityInterval(tip.slot, genesisParameters, props.options?.validityInterval),
    withdrawals: rewardAccounts
      .map(({ rewardBalance: quantity, address: stakeAddress }) => ({
        quantity,
        stakeAddress
      }))
      .filter(({ quantity }) => !!quantity)
  });

  const bodyPreInputSelection = props.customizeCb ? props.customizeCb({ txBody }) : txBody;

  const constraints = defaultSelectionConstraints({
    buildTx: async (inputSelection) => {
      logger.debug('Building TX for selection constraints', inputSelection);
      if (bodyPreInputSelection.withdrawals?.length) {
        logger.debug('Adding rewards withdrawal in the transaction', bodyPreInputSelection.withdrawals);
      }
      const unsignedTx = includeChangeAndInputs({
        bodyPreInputSelection,
        inputSelection
      });

      const { tx } = await finalizeTx(
        unsignedTx,
        {
          auxiliaryData,
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
    certificates: bodyPreInputSelection.certificates,
    withdrawals: bodyPreInputSelection.withdrawals
  });

  const { selection: inputSelection } = await inputSelector.select({
    constraints,
    implicitValue: { coin: implicitCoin, mint: bodyPreInputSelection.mint },
    outputs: new Set(bodyPreInputSelection.outputs),
    utxo: new Set(utxo)
  });

  const { body, hash } = includeChangeAndInputs({
    bodyPreInputSelection,
    inputSelection
  });
  return { body, hash, inputSelection };
};
