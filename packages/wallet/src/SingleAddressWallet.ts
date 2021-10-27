import { BalanceTracker, KeyManagement, TransactionError, TransactionFailure, TransactionTracker } from '.';
import { CSL, Cardano, ProviderError, WalletProvider, coreToCsl } from '@cardano-sdk/core';
import { InitializeTxProps, TxInternals, computeImplicitCoin, createTransactionInternals } from './Transaction';
import { Logger, dummyLogger } from 'ts-log';
import { UtxoRepository } from './types';
import { defaultSelectionConstraints } from '@cardano-sdk/cip2';

export interface SubmitTxResult {
  /**
   * Resolves when transaction is submitted.
   * Rejects with {TransactionError}.
   */
  submitted: Promise<void>;
  /**
   * Resolves when transaction is submitted and confirmed.
   * Rejects with {TransactionError}.
   */
  confirmed: Promise<void>;
}
export interface SingleAddressWallet {
  address: Cardano.Address;
  balance: BalanceTracker;
  initializeTx: (props: InitializeTxProps) => Promise<TxInternals>;
  name: string;
  signTx: (body: CSL.TransactionBody, hash: CSL.TransactionHash) => Promise<CSL.Transaction>;
  submitTx: (tx: CSL.Transaction) => SubmitTxResult;
}

export interface SingleAddressWalletDependencies {
  keyManager: KeyManagement.KeyManager;
  logger?: Logger;
  provider: WalletProvider;
  utxoRepository: UtxoRepository;
  txTracker: TransactionTracker;
  balanceTracker?: BalanceTracker;
}

export interface SingleAddressWalletProps {
  name: string;
}

const ensureValidityInterval = (
  currentSlot: number,
  validityInterval?: Cardano.ValidityInterval
): Cardano.ValidityInterval =>
  // Todo: Based this on slot duration, to equal 2hrs
  ({ invalidHereafter: currentSlot + 3600, ...validityInterval });

export const createSingleAddressWallet = async (
  { name }: SingleAddressWalletProps,
  {
    provider,
    keyManager,
    utxoRepository,
    txTracker,
    balanceTracker = new BalanceTracker(utxoRepository),
    logger = dummyLogger
  }: SingleAddressWalletDependencies
): Promise<SingleAddressWallet> => {
  const address = keyManager.deriveAddress(0, 0);
  const protocolParameters = await provider.currentWalletProtocolParameters();
  const signTx = async (body: CSL.TransactionBody, hash: CSL.TransactionHash) => {
    const witnessSet = await keyManager.signTransaction(hash);
    return CSL.Transaction.new(body, witnessSet);
  };
  return {
    address,
    balance: balanceTracker,
    initializeTx: async (props) => {
      const tip = await provider.ledgerTip();
      const validityInterval = ensureValidityInterval(tip.slot, props.options?.validityInterval);
      const txOutputs = new Set([...props.outputs].map((output) => coreToCsl.txOut(output)));
      const constraints = defaultSelectionConstraints({
        buildTx: async (inputSelection) => {
          logger.debug('Building TX for selection constraints', inputSelection);
          const { body, hash } = await createTransactionInternals({
            changeAddress: address,
            inputSelection,
            validityInterval
          });
          return signTx(body, hash);
        },
        protocolParameters
      });
      const implicitCoin = computeImplicitCoin(protocolParameters, props);
      const inputSelectionResult = await utxoRepository.selectInputs(txOutputs, constraints, implicitCoin);
      return createTransactionInternals({
        changeAddress: address,
        inputSelection: inputSelectionResult.selection,
        validityInterval
      });
    },
    name,
    signTx,
    submitTx: (tx) => {
      const submitted = provider.submitTx(tx).catch((error) => {
        if (error instanceof ProviderError) {
          throw new TransactionError(TransactionFailure.FailedToSubmit, error, error.detail);
        }
        throw new TransactionError(TransactionFailure.FailedToSubmit, error);
      });
      const confirmed = txTracker.track(tx, submitted);
      return {
        confirmed,
        submitted
      };
    }
  };
};
