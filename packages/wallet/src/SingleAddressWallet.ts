import Schema from '@cardano-ogmios/schema';
import { CardanoProvider, Ogmios, Transaction, CardanoSerializationLib, CSL } from '@cardano-sdk/core';
import { UtxoRepository } from './types';
import { dummyLogger, Logger } from 'ts-log';
import { defaultSelectionConstraints } from '@cardano-sdk/cip2';
import { computeImplicitCoin, createTransactionInternals, InitializeTxProps, TxInternals } from './Transaction';
import { KeyManagement } from '.';

export interface SingleAddressWallet {
  address: Schema.Address;
  initializeTx: (props: InitializeTxProps) => Promise<TxInternals>;
  name: string;
  signTx: (body: CSL.TransactionBody, hash: CSL.TransactionHash) => Promise<CSL.Transaction>;
  submitTx: (tx: CSL.Transaction) => Promise<boolean>;
}

export interface SingleAddressWalletDependencies {
  csl: CardanoSerializationLib;
  keyManager: KeyManagement.KeyManager;
  logger?: Logger;
  provider: CardanoProvider;
  utxoRepository: UtxoRepository;
}

export interface SingleAddressWalletProps {
  name: string;
}

const ensureValidityInterval = (
  currentSlot: number,
  validityInterval?: Transaction.ValidityInterval
): Transaction.ValidityInterval =>
  // Todo: Based this on slot duration, to equal 2hrs
  ({ invalidHereafter: currentSlot + 3600, ...validityInterval });

export const createSingleAddressWallet = async (
  { name }: SingleAddressWalletProps,
  { csl, provider, keyManager, utxoRepository, logger = dummyLogger }: SingleAddressWalletDependencies
): Promise<SingleAddressWallet> => {
  const address = keyManager.deriveAddress(0, 0);
  const protocolParameters = await provider.currentWalletProtocolParameters();
  const signTx = async (body: CSL.TransactionBody, hash: CSL.TransactionHash) => {
    const witnessSet = await keyManager.signTransaction(hash);
    return csl.Transaction.new(body, witnessSet);
  };
  return {
    address,
    initializeTx: async (props) => {
      const tip = await provider.ledgerTip();
      const validityInterval = ensureValidityInterval(tip.slot, props.options?.validityInterval);
      const txOutputs = new Set([...props.outputs].map((output) => Ogmios.ogmiosToCsl(csl).txOut(output)));
      const constraints = defaultSelectionConstraints({
        csl,
        protocolParameters,
        buildTx: async (inputSelection) => {
          logger.debug('Building TX for selection constraints', inputSelection);
          const { body, hash } = await createTransactionInternals(csl, {
            changeAddress: address,
            inputSelection,
            validityInterval
          });
          return signTx(body, hash);
        }
      });
      const implicitCoin = computeImplicitCoin(protocolParameters, props);
      const inputSelectionResult = await utxoRepository.selectInputs(txOutputs, constraints, implicitCoin);
      return createTransactionInternals(csl, {
        changeAddress: address,
        inputSelection: inputSelectionResult.selection,
        validityInterval
      });
    },
    name,
    signTx,
    submitTx: async (tx) => provider.submitTx(tx)
  };
};
