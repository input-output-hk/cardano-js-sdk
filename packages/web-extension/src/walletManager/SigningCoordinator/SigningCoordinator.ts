import { Cardano, Serialization } from '@cardano-sdk/core';
import { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import { CustomError } from 'ts-custom-error';
import { InMemoryWallet, WalletType } from '../types';
import { KeyAgent, KeyPurpose, SignDataContext, TrezorConfig, errors } from '@cardano-sdk/key-management';
import { KeyAgentFactory } from './KeyAgentFactory';
import { Logger } from 'ts-log';
import {
  RequestBase,
  RequestContext,
  SignDataRequest,
  SignOptions,
  SignRequest,
  SignTransactionProps,
  SigningCoordinatorConfirmationApi,
  SigningCoordinatorSignApi,
  TransactionWitnessRequest
} from './types';
import { Subject } from 'rxjs';
import { WrongTargetError } from '../../messaging';
import { contextLogger } from '@cardano-sdk/util';

export type HardwareKeyAgentOptions = TrezorConfig;

export type SigningCoordinatorProps = {
  hwOptions: HardwareKeyAgentOptions;
};

export type SigningCoordinatorDependencies = {
  keyAgentFactory: KeyAgentFactory;
  logger: Logger;
};

class NoRejectError extends CustomError {
  constructor(public actualError: unknown) {
    super();
  }
}
const throwMaybeWrappedWithNoRejectError = (error: unknown, options?: SignOptions): never => {
  if (options?.willRetryOnFailure) throw new NoRejectError(error);
  throw error;
};

const clearPassphrase = (passphrase: Uint8Array) => {
  for (let i = 0; i < passphrase.length; i++) {
    passphrase[i] = 0;
  }
};

const bubbleResolveReject = async <R>(
  action: () => Promise<R>,
  resolve: (result: R | Promise<R>) => void,
  reject: (error: unknown) => void
): Promise<R> => {
  try {
    const result = await action();
    resolve(result);
    return result;
  } catch (error) {
    if (error instanceof NoRejectError) {
      throw error.actualError;
    }

    reject(error);
    throw error;
  }
};

export class SigningCoordinator<WalletMetadata extends {}, AccountMetadata extends {}>
  implements
    SigningCoordinatorConfirmationApi<WalletMetadata, AccountMetadata>,
    SigningCoordinatorSignApi<WalletMetadata, AccountMetadata>
{
  readonly transactionWitnessRequest$ = new Subject<TransactionWitnessRequest<WalletMetadata, AccountMetadata>>();
  readonly signDataRequest$ = new Subject<SignDataRequest<WalletMetadata, AccountMetadata>>();
  readonly #hwOptions: HardwareKeyAgentOptions;
  readonly #keyAgentFactory: KeyAgentFactory;
  readonly #logger: Logger;

  constructor(props: SigningCoordinatorProps, { keyAgentFactory, logger }: SigningCoordinatorDependencies) {
    this.#hwOptions = props.hwOptions;
    this.#keyAgentFactory = keyAgentFactory;
    this.#logger = contextLogger(logger, 'SigningCoordinator');
  }

  async signTransaction(
    { tx, signContext, options }: SignTransactionProps,
    requestContext: RequestContext<WalletMetadata, AccountMetadata>
  ): Promise<Cardano.Signatures> {
    const transaction = Serialization.Transaction.fromCbor(tx);
    return this.#signRequest(
      this.transactionWitnessRequest$,
      {
        requestContext,
        signContext,
        transaction,
        walletType: requestContext.wallet.type
      },
      (keyAgent) => {
        this.#logger.debug('Signing transaction', transaction.getId());
        return keyAgent.signTransaction(transaction.body(), signContext, options);
      }
    );
  }

  async signData(
    props: SignDataContext,
    requestContext: RequestContext<WalletMetadata, AccountMetadata>
  ): Promise<Cip30DataSignature> {
    return this.#signRequest(
      this.signDataRequest$,
      {
        requestContext,
        signContext: props,
        walletType: requestContext.wallet.type
      },
      (keyAgent) => keyAgent.signCip8Data(props)
    );
  }

  #signRequest<R, Req extends RequestBase<WalletMetadata, AccountMetadata> & SignRequest<R>>(
    emitter$: Subject<Req>,
    request: Omit<Req, 'reject' | 'sign'>,
    sign: (keyAgent: KeyAgent) => Promise<R>
  ) {
    return new Promise<R>((resolve, reject) => {
      if (!emitter$.observed) {
        return reject(new WrongTargetError('Not expecting sign requests at this time'));
      }
      const account = request.requestContext.wallet.accounts.find(
        ({ accountIndex, purpose = KeyPurpose.STANDARD }) =>
          accountIndex === request.requestContext.accountIndex && request.requestContext.purpose === purpose
      );

      if (!account) {
        return reject(
          new errors.ProofGenerationError(
            `Account not found: index=${request.requestContext.accountIndex}, purpose=${request.requestContext.purpose}`
          )
        );
      }

      const commonRequestProps = {
        ...request,
        reject: async (reason: string) => reject(new errors.AuthenticationError(reason))
      };
      emitter$.next(
        request.walletType === WalletType.InMemory
          ? ({
              ...commonRequestProps,
              sign: async (passphrase: Uint8Array, options?: SignOptions) =>
                bubbleResolveReject(
                  async () => {
                    const wallet = request.requestContext.wallet as InMemoryWallet<WalletMetadata, AccountMetadata>;
                    try {
                      const result = await sign(
                        await this.#keyAgentFactory.InMemory({
                          accountIndex: account.accountIndex,
                          chainId: request.requestContext.chainId,
                          encryptedRootPrivateKeyBytes: [
                            ...Buffer.from(wallet.encryptedSecrets.rootPrivateKeyBytes, 'hex')
                          ],
                          extendedAccountPublicKey: account.extendedAccountPublicKey,
                          getPassphrase: async () => passphrase,
                          purpose: account.purpose || KeyPurpose.STANDARD
                        })
                      );
                      clearPassphrase(passphrase);
                      return result;
                    } catch (error) {
                      clearPassphrase(passphrase);
                      return throwMaybeWrappedWithNoRejectError(error, options);
                    }
                  },
                  resolve,
                  reject
                ),
              walletType: request.walletType
            } as Req)
          : ({
              ...commonRequestProps,
              sign: async (): Promise<R> =>
                bubbleResolveReject(
                  async (options?: SignOptions) =>
                    sign(
                      request.walletType === WalletType.Ledger
                        ? await this.#keyAgentFactory.Ledger({
                            accountIndex: request.requestContext.accountIndex,
                            chainId: request.requestContext.chainId,
                            communicationType: this.#hwOptions.communicationType,
                            extendedAccountPublicKey: account.extendedAccountPublicKey,
                            purpose: account.purpose || KeyPurpose.STANDARD
                          })
                        : await this.#keyAgentFactory.Trezor({
                            accountIndex: request.requestContext.accountIndex,
                            chainId: request.requestContext.chainId,
                            extendedAccountPublicKey: account.extendedAccountPublicKey,
                            purpose: account.purpose || KeyPurpose.STANDARD,
                            trezorConfig: this.#hwOptions
                          })
                    ).catch((error) => throwMaybeWrappedWithNoRejectError(error, options)),
                  resolve,
                  reject
                ),
              walletType: request.walletType
            } as Req)
      );
    });
  }
}
