import Schema from '@cardano-ogmios/schema';
import { CardanoSerializationLib, CSL } from '@cardano-sdk/cardano-serialization-lib';
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
  signTx: (body: CSL.TransactionBody, hash: CSL.TransactionHash) => Promise<CSL.Transaction>;
  submitTx: (tx: CSL.Transaction) => Promise<boolean>;
}

const ensureValidityInterval = (
  currentSlot: number,
  validityInterval?: Transaction.ValidityInterval
): Transaction.ValidityInterval =>
  // Todo: Based this on slot duration, to equal 2hrs
  ({ invalidHereafter: currentSlot + 3600, ...validityInterval });

export const createSingleAddressWallet = async (
  csl: CardanoSerializationLib,
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
      const txOutputs = csl.TransactionOutputs.new();
      for (const output of props.outputs) {
        txOutputs.add(Ogmios.ogmiosToCsl(csl).txOut(output));
      }
      const inputSelectionResult = await utxoRepository.selectInputs(txOutputs, {
        computeMinimumCost: async ({ utxo, outputs, change }) => {
          const transactionInternals = await createTransactionInternals(csl, {
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
          const tx = csl.Transaction.new(transactionInternals.body, witnessSet);
          return BigInt(
            csl
              .min_fee(
                tx,
                csl.LinearFee.new(
                  csl.BigNum.from_str(protocolParameters.minFeeCoefficient.toString()),
                  csl.BigNum.from_str(protocolParameters.minFeeConstant.toString())
                )
              )
              .to_str()
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
      return createTransactionInternals(csl, {
        changeAddress: address,
        inputSelection: inputSelectionResult.selection,
        validityInterval
      });
    },
    signTx: async (body, hash) => {
      const witnessSet = await keyManager.signTransaction(hash);
      return csl.Transaction.new(body, witnessSet);
    },
    submitTx: async (tx) => provider.submitTx(tx)
  };
};
