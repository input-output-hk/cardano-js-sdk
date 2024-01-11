import {
  AccountKeyDerivationPath,
  MessageSender,
  SignBlobResult,
  SignTransactionContext,
  SignTransactionOptions
} from '@cardano-sdk/key-management';
import { AnyBip32Wallet, WalletType } from '../types';
import { Cardano, Serialization, TxCBOR } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';
import { Observable } from 'rxjs';

export type RequestContext<WalletMetadata extends {}> = {
  wallet: AnyBip32Wallet<WalletMetadata>;
  accountIndex: number;
  chainId: Cardano.ChainId;
};

export type RequestBase<WalletMetadata extends {}> = {
  requestContext: RequestContext<WalletMetadata>;
  reject(reason: string): Promise<void>;
};

type SignRequestInMemory<R> = {
  walletType: WalletType.InMemory;
  sign(passphrase: Uint8Array): Promise<R>;
};

type SignRequestHardware<R> = {
  walletType: WalletType.Trezor | WalletType.Ledger;
  /** Must be called from user gesture when running in web environments */
  sign(): Promise<R>;
};

export type SignRequest<R> = SignRequestHardware<R> | SignRequestInMemory<R>;

export type TransactionWitnessRequest<WalletMetadata extends {}> = RequestBase<WalletMetadata> & {
  transaction: Serialization.Transaction;
  signContext: SignTransactionContext;
} & SignRequest<Cardano.Signatures>;

export type SignDataContext = { sender?: MessageSender };

export type SignDataProps = {
  derivationPath: AccountKeyDerivationPath;
  blob: HexBlob;
  signContext: SignDataContext;
};

export type SignDataRequest<WalletMetadata extends {}> = RequestBase<WalletMetadata> &
  SignDataProps &
  SignRequest<SignBlobResult>;

export type SignTransactionProps = {
  tx: TxCBOR;
  signContext: SignTransactionContext;
  options?: SignTransactionOptions;
};

export interface SignerManagerConfirmationApi<WalletMetadata extends {}> {
  transactionWitnessRequest$: Observable<TransactionWitnessRequest<WalletMetadata>>;
  signDataRequest$: Observable<SignDataRequest<WalletMetadata>>;
}

export interface SignerManagerSignApi<WalletMetadata extends {}> {
  signTransaction(
    props: SignTransactionProps,
    requestContext: RequestContext<WalletMetadata>
  ): Promise<Cardano.Signatures>;
  signData(props: SignDataProps, requestContext: RequestContext<WalletMetadata>): Promise<SignBlobResult>;
}
