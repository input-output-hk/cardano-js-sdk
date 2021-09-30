import Schema from '@cardano-ogmios/schema';
import { CardanoProvider, Ogmios, Transaction, CardanoSerializationLib, CSL } from '@cardano-sdk/core';
import { createTransactionInternals, KeyManagement, TxInternals, UtxoRepository } from './';
import { dummyLogger, Logger } from 'ts-log';
import { defaultSelectionConstraints } from '@cardano-sdk/cip2';

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
      const txOutputs = props.outputs.map((output) => Ogmios.ogmiosToCsl(csl).txOut(output));
      const constraints = defaultSelectionConstraints({
        csl,
        protocolParameters,
        buildTx: async (inputSelection) => {
          logger.debug('Building TX for selection constraints', inputSelection);
          const transactionInternals = await createTransactionInternals(csl, {
            changeAddress: address,
            inputSelection,
            validityInterval
          });
          const witnessSet = await keyManager.signTransaction(transactionInternals.hash);
          return csl.Transaction.new(transactionInternals.body, witnessSet);
        }
      });
      const inputSelectionResult = await utxoRepository.selectInputs(txOutputs, constraints);
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
