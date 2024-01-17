import {
  AccountKeyDerivationPath,
  SignBlobResult,
  SignDataContext,
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

export type TransactionWitnessRequest<WalletMetadata extends {}> = RequestBase<WalletMetadata> & {
  transaction: Serialization.Transaction;
  signContext: SignTransactionContext;
} & SignRequest<Cardano.Signatures>;

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

export interface SigningCoordinatorConfirmationApi<WalletMetadata extends {}> {
  transactionWitnessRequest$: Observable<TransactionWitnessRequest<WalletMetadata>>;
  signDataRequest$: Observable<SignDataRequest<WalletMetadata>>;
}

export interface SigningCoordinatorSignApi<WalletMetadata extends {}> {
  signTransaction(
    props: SignTransactionProps,
    requestContext: RequestContext<WalletMetadata>
  ): Promise<Cardano.Signatures>;
  signData(props: SignDataProps, requestContext: RequestContext<WalletMetadata>): Promise<SignBlobResult>;
}
