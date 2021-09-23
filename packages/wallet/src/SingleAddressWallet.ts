import Schema from '@cardano-ogmios/schema';
import CardanoSerializationLib from '@emurgo/cardano-serialization-lib-nodejs';
import { CardanoProvider, Ogmios, Transaction } from '@cardano-sdk/core';
import { createTransactionInternals, KeyManagement, TxInternals, UtxoRepository } from './';
import { dummyLogger, Logger } from 'ts-log';

export type InitializeTxProps = {
  outputs: Schema.TxOut[];
  options?: {
    validityInterval?: Transaction.ValidityInterval;
  };
};

export interface SingleAddressWallet {
  address: Schema.Address;
  initializeTx: (props: InitializeTxProps) => Promise<TxInternals>;
  signTx: (
    body: CardanoSerializationLib.TransactionBody,
    hash: CardanoSerializationLib.TransactionHash
  ) => Promise<CardanoSerializationLib.Transaction>;
  submitTx: (tx: CardanoSerializationLib.Transaction) => Promise<boolean>;
}

const ensureValidityInterval = (
  currentSlot: number,
  validityInterval?: Transaction.ValidityInterval
): Transaction.ValidityInterval =>
  // Todo: Based this on slot duration, to equal 2hrs
  ({ invalidHereafter: currentSlot + 3600, ...validityInterval });

export const createSingleAddressWallet = async (
  CSL: typeof CardanoSerializationLib,
  provider: CardanoProvider,
  keyManager: KeyManagement.KeyManager,
  utxoRepository: UtxoRepository,
  logger: Logger = dummyLogger
): Promise<SingleAddressWallet> => {
  const address = keyManager.deriveAddress(0, 0);
  const protocolParameters = await provider.currentWalletProtocolParameters();
  return {
    address,
    initializeTx: async (props) => {
      const tip = await provider.ledgerTip();
      const validityInterval = ensureValidityInterval(tip.slot, props.options?.validityInterval);
      const txOutputs = CSL.TransactionOutputs.new();
      for (const output of props.outputs) {
        txOutputs.add(Ogmios.OgmiosToCardanoWasm.txOut(output));
      }
      const inputSelectionResult = await utxoRepository.selectInputs(txOutputs, {
        computeMinimumCost: async ({ utxo, outputs, change }) => {
          const transactionInternals = await createTransactionInternals(CSL, {
            changeAddress: address,
            inputSelection: {
              outputs,
              inputs: utxo,
              change,
              fee: 0n
            },
            validityInterval
          });
          const witnessSet = await keyManager.signTransaction(transactionInternals.hash);
          const tx = CSL.Transaction.new(transactionInternals.body, witnessSet);
          return BigInt(
            CSL.min_fee(
              tx,
              CSL.LinearFee.new(
                CSL.BigNum.from_str(protocolParameters.minFeeCoefficient.toString()),
                CSL.BigNum.from_str(protocolParameters.minFeeConstant.toString())
              )
            ).to_str()
          );
        },
        tokenBundleSizeExceedsLimit: (tokenBundle) => {
          logger.debug('SelectionConstraint: tokenBundleSizeExceedsLimit', tokenBundle);
          // Todo: Replace with real implementation
          return false;
        },
        computeMinimumCoinQuantity: (assetQuantities) => {
          logger.debug('SelectionConstraint: computeMinimumCoinQuantity', assetQuantities);
          // Todo: Replace with real implementation
          return 1_000_000n;
        },
        computeSelectionLimit: async (selectionSkeleton) => {
          logger.debug('SelectionConstraint: computeSelectionLimit', selectionSkeleton);
          // Todo: Replace with real implementation
          return 5;
        }
      });
      return createTransactionInternals(CSL, {
        changeAddress: address,
        inputSelection: inputSelectionResult.selection,
        validityInterval
      });
    },
    signTx: async (body, hash) => {
      const witnessSet = await keyManager.signTransaction(hash);
      return CSL.Transaction.new(body, witnessSet);
    },
    submitTx: async (tx) => provider.submitTx(tx)
  };
};
