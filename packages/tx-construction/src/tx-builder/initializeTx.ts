import { Cardano, Serialization } from '@cardano-sdk/core';
import { GreedyTxEvaluator } from './GreedyTxEvaluator';
import { InitializeTxProps, InitializeTxResult } from '../types';
import { KeyPurpose, util } from '@cardano-sdk/key-management';
import { RedeemersByType, defaultSelectionConstraints } from '../input-selection';
import { StaticChangeAddressResolver, roundRobinRandomImprove } from '@cardano-sdk/input-selection';
import { TxBuilderDependencies } from './types';
import { createPreInputSelectionTxBody, includeChangeAndInputs } from '../createTransactionInternals';
import { ensureValidityInterval } from '../ensureValidityInterval';

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

  const txEvaluator = props.txEvaluator ?? new GreedyTxEvaluator(() => txBuilderProviders.protocolParameters());

  inputSelector =
    inputSelector ??
    roundRobinRandomImprove({
      changeAddressResolver: new StaticChangeAddressResolver(async () => addresses)
    });

  // Create transaction body that can be customized by the user via the customizeCb
  const { txBody, auxiliaryData } = createPreInputSelectionTxBody({
    auxiliaryData: props.auxiliaryData,
    certificates: props.certificates,
    collateralReturn: props.collateralReturn,
    collaterals: props.collaterals,
    mint: props.mint,
    outputs: [...(props.outputs || [])],
    referenceInputs: props.referenceInputs,
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
      const unwitnessedTx = includeChangeAndInputs({
        bodyPreInputSelection,
        inputSelection,
        scriptVersions: props.scriptVersions,
        witness: props.witness as Cardano.Witness
      });

      const dRepPublicKey = addressManager
        ? (await addressManager.derivePublicKey(util.DREP_KEY_DERIVATION_PATH)).hex()
        : undefined;

      const transaction = new Serialization.Transaction(
        Serialization.TransactionBody.fromCore(unwitnessedTx.body),
        Serialization.TransactionWitnessSet.fromCore(
          props.witness ? (props.witness as Cardano.Witness) : { signatures: new Map() }
        ),
        auxiliaryData ? Serialization.AuxiliaryData.fromCore(auxiliaryData) : undefined
      );

      const signingContext = {
        dRepPublicKey,
        handleResolutions: props.handleResolutions ?? [],
        knownAddresses: addresses,
        // TODO: Not sure about this. What is the best way to pass purpose to defaultSelectionConstraints?
        purpose: KeyPurpose.STANDARD,
        txInKeyPathMap: await util.createTxInKeyPathMap(unwitnessedTx.body, addresses, inputResolver)
      };

      const signingOptions = { ...props.signingOptions, stubSign: true };

      const { tx } = await witnesser.witness(transaction, signingContext, signingOptions);

      return tx;
    },
    protocolParameters,
    redeemersByType: props.redeemersByType ?? ({} as RedeemersByType),
    txEvaluator
  });

  const implicitCoin = Cardano.util.computeImplicitCoin(protocolParameters, {
    certificates: bodyPreInputSelection.certificates,
    proposalProcedures: bodyPreInputSelection.proposalProcedures,
    withdrawals: bodyPreInputSelection.withdrawals
  });

  const { selection: inputSelection, redeemers } = await inputSelector.select({
    constraints,
    implicitValue: { coin: implicitCoin, mint: bodyPreInputSelection.mint },
    outputs: new Set(bodyPreInputSelection.outputs),
    preSelectedUtxo: props.inputs || new Set(),
    utxo: new Set(utxo)
  });

  const witness = { ...props.witness, redeemers } as Cardano.Witness;

  const { body, hash } = includeChangeAndInputs({
    bodyPreInputSelection,
    inputSelection,
    scriptVersions: props.scriptVersions,
    witness
  });

  return { body, hash, inputSelection, redeemers };
};
