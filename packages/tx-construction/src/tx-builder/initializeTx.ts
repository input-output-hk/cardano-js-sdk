import { StaticChangeAddressResolver, roundRobinRandomImprove } from '@cardano-sdk/input-selection';

import { Cardano } from '@cardano-sdk/core';
import { InitializeTxProps, InitializeTxResult } from '../types';
import { TxBuilderDependencies } from './types';
import { createTransactionInternals } from '../createTransactionInternals';
import { defaultSelectionConstraints } from '../input-selection';
import { ensureValidityInterval } from '../ensureValidityInterval';
import { finalizeTx } from './finalizeTx';
import { firstValueFrom } from 'rxjs';

export const initializeTx = async (
  props: InitializeTxProps,
  { txBuilderProviders, inputSelector, inputResolver, keyAgent, logger }: TxBuilderDependencies
): Promise<InitializeTxResult> => {
  const [tip, genesisParameters, protocolParameters, addresses, rewardAccounts, utxo] = await Promise.all([
    txBuilderProviders.tip(),
    txBuilderProviders.genesisParameters(),
    txBuilderProviders.protocolParameters(),
    firstValueFrom(keyAgent.knownAddresses$),
    txBuilderProviders.rewardAccounts(),
    txBuilderProviders.utxoAvailable()
  ]);

  inputSelector =
    inputSelector ??
    roundRobinRandomImprove({
      changeAddressResolver: new StaticChangeAddressResolver(() => firstValueFrom(keyAgent.knownAddresses$))
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
          handles: props.handles ?? [],
          ownAddresses: addresses,
          signingOptions: props.signingOptions,
          witness: props.witness
        },
        { inputResolver, keyAgent },
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
