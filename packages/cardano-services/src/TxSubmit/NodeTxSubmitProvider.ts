import { EmptyError, firstValueFrom } from 'rxjs';
import {
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
  HandleOwnerChangeError,
  HandleProvider,
  HealthCheckResponse,
  ObservableCardanoNode,
  ProviderError,
  ProviderFailure,
  SubmitTxArgs,
  TxSubmissionError,
  TxSubmitProvider
} from '@cardano-sdk/core';
import { InMemoryCache } from '../InMemoryCache';
import { Logger } from 'ts-log';
import { WithLogger } from '@cardano-sdk/util';

type ObservableTxSubmitter = Pick<ObservableCardanoNode, 'healthCheck$' | 'submitTx'>;
export type NodeTxSubmitProviderProps = WithLogger & {
  handleProvider?: HandleProvider;
  cardanoNode: ObservableTxSubmitter;
  healthCheckCache: InMemoryCache;
};

const emptyMessage = 'ObservableCardanoNode observable completed without emitting';
const toProviderError = (error: unknown) => {
  if (error instanceof TxSubmissionError) {
    throw new ProviderError(ProviderFailure.BadRequest, error);
  } else if (error instanceof GeneralCardanoNodeError) {
    throw new ProviderError(
      error.code === GeneralCardanoNodeErrorCode.ConnectionFailure
        ? ProviderFailure.ConnectionFailure
        : error.code === GeneralCardanoNodeErrorCode.ServerNotReady
        ? ProviderFailure.ServerUnavailable
        : ProviderFailure.Unknown,
      error
    );
  }
  if (error instanceof EmptyError) {
    throw new ProviderError(
      ProviderFailure.ServerUnavailable,
      new GeneralCardanoNodeError(GeneralCardanoNodeErrorCode.ServerNotReady, null, emptyMessage)
    );
  }
  throw new ProviderError(ProviderFailure.Unknown, error);
};

/** Submit transactions to an ObservableCardanoNode. Validates handle resolutions against a HandleProvider. */
export class NodeTxSubmitProvider implements TxSubmitProvider {
  #logger: Logger;
  #cardanoNode: ObservableTxSubmitter;
  #handleProvider?: HandleProvider;
  #healthCheckCache: InMemoryCache;

  constructor({ handleProvider, cardanoNode, logger, healthCheckCache }: NodeTxSubmitProviderProps) {
    this.#handleProvider = handleProvider;
    this.#cardanoNode = cardanoNode;
    this.#logger = logger;
    this.#healthCheckCache = healthCheckCache;
  }

  async submitTx({ signedTransaction, context }: SubmitTxArgs): Promise<void> {
    await this.#throwIfHandleResolutionConflict(context);
    await firstValueFrom(this.#cardanoNode.submitTx(signedTransaction)).catch(toProviderError);
  }

  async #checkHealth(): Promise<HealthCheckResponse> {
    const [cardanoNodeHealth, handleProviderHealth] = await Promise.all([
      firstValueFrom(this.#cardanoNode.healthCheck$).catch((error): HealthCheckResponse => {
        if (error instanceof EmptyError) {
          return { ok: false, reason: emptyMessage };
        }
        this.#logger.error('Unexpected healtcheck error', error);
        return { ok: false, reason: 'Internal error' };
      }),
      this.#handleProvider?.healthCheck()
    ]);
    return {
      localNode: cardanoNodeHealth.localNode,
      ok: cardanoNodeHealth.ok && (!handleProviderHealth || handleProviderHealth.ok),
      reason: cardanoNodeHealth.reason || handleProviderHealth?.reason
    };
  }

  async healthCheck(): Promise<HealthCheckResponse> {
    return this.#healthCheckCache.get('ogmios_cardano_node', () => this.#checkHealth());
  }

  async #throwIfHandleResolutionConflict(context: SubmitTxArgs['context']): Promise<void> {
    if (context?.handleResolutions && context.handleResolutions.length > 0) {
      if (!this.#handleProvider) {
        this.#logger.debug('No handle provider: bypassing handle validation');
        return;
      }

      const handleInfoList = await this.#handleProvider.resolveHandles({
        handles: context.handleResolutions.map((hndRes) => hndRes.handle)
      });

      for (const [index, handleInfo] of handleInfoList.entries()) {
        if (!handleInfo || handleInfo.cardanoAddress !== context.handleResolutions[index].cardanoAddress) {
          const handleOwnerChangeError = new HandleOwnerChangeError(
            context.handleResolutions[index].handle,
            context.handleResolutions[index].cardanoAddress,
            handleInfo ? handleInfo.cardanoAddress : null
          );
          throw new ProviderError(ProviderFailure.Conflict, handleOwnerChangeError);
        }
      }
    }
  }
}
