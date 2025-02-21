import type { AnyBip32Wallet, WalletType } from '../types';
import type { Cardano, Serialization } from '@cardano-sdk/core';
import type { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import type {
  KeyPurpose,
  MessageSender,
  SignTransactionContext,
  SignTransactionOptions,
  cip8
} from '@cardano-sdk/key-management';
import type { Observable } from 'rxjs';

export type RequestContext<WalletMetadata extends {}, AccountMetadata extends {}> = {
  wallet: AnyBip32Wallet<WalletMetadata, AccountMetadata>;
  accountIndex: number;
  purpose: KeyPurpose;
  chainId: Cardano.ChainId;
};

export type RequestBase<WalletMetadata extends {}, AccountMetadata extends {}> = {
  requestContext: RequestContext<WalletMetadata, AccountMetadata>;
  reject(reason: string): Promise<void>;
};

export type SignOptions = {
  /**
   * if `true`,
   * - underlying KeyAgent errors from this call will not be propagated back to the wallet via SigningCoordinatorSignApi
   * - SigningCoordinator expects user to either retry the call to `sign` or call `reject` manually
   */
  willRetryOnFailure?: boolean;
};

type SignRequestInMemory<R> = {
  walletType: WalletType.InMemory;
  sign(passphrase: Uint8Array, options?: SignOptions): Promise<R>;
};

type SignRequestHardware<R> = {
  walletType: WalletType.Trezor | WalletType.Ledger;
  /**
   * Must be called from user gesture when running in web environments
   *
   * @param noReject if `true`, underlying KeyAgent errors will not be propagated back to the wallet via SigningCoordinatorSignApi
   */
  sign(options?: SignOptions): Promise<R>;
};

export type SignRequest<R> = SignRequestHardware<R> | SignRequestInMemory<R>;

export type TransactionWitnessRequest<WalletMetadata extends {}, AccountMetadata extends {}> = RequestBase<
  WalletMetadata,
  AccountMetadata
> & {
  transaction: Serialization.Transaction;
  signContext: SignTransactionContext;
} & SignRequest<Cardano.Signatures>;

export type SignDataProps = {
  signContext: cip8.Cip8SignDataContext & { sender?: MessageSender };
};

export type SignDataRequest<WalletMetadata extends {}, AccountMetadata extends {}> = RequestBase<
  WalletMetadata,
  AccountMetadata
> &
  SignDataProps &
  SignRequest<Cip30DataSignature>;

export type SignTransactionProps = {
  tx: Serialization.TxCBOR;
  signContext: SignTransactionContext;
  options?: SignTransactionOptions;
};

export interface SigningCoordinatorConfirmationApi<WalletMetadata extends {}, AccountMetadata extends {}> {
  transactionWitnessRequest$: Observable<TransactionWitnessRequest<WalletMetadata, AccountMetadata>>;
  signDataRequest$: Observable<SignDataRequest<WalletMetadata, AccountMetadata>>;
}

export interface SigningCoordinatorSignApi<WalletMetadata extends {}, AccountMetadata extends {}> {
  signTransaction(
    props: SignTransactionProps,
    requestContext: RequestContext<WalletMetadata, AccountMetadata>
  ): Promise<Cardano.Signatures>;
  signData(
    props: cip8.Cip8SignDataContext,
    requestContext: RequestContext<WalletMetadata, AccountMetadata>
  ): Promise<Cip30DataSignature>;
}
