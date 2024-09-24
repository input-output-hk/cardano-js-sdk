/* eslint-disable @typescript-eslint/no-explicit-any */
import { BlockDataEntity } from './entity';
import { Cardano } from '@cardano-sdk/core';
import {
  ChainSyncEventType,
  ProjectionEvent,
  RollForwardEvent,
  StabilityWindowBuffer,
  WithNetworkInfo
} from '@cardano-sdk/projection';
import { LessThan, QueryRunner } from 'typeorm';
import { Logger } from 'ts-log';
import { Observable, catchError, concatMap, from, map, of, switchMap, take } from 'rxjs';
import { ReconnectionConfig } from '@cardano-sdk/util-rxjs';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { TypeormConnection } from './createDataSource';
import { WithLogger, contextLogger } from '@cardano-sdk/util';
import { WithTypeormContext } from './operators';
import { isRecoverableTypeormError } from './isRecoverableTypeormError';

export interface TypeormStabilityWindowBufferProps extends WithLogger {
  /** 100 by default */
  compactBufferEveryNBlocks?: number;
  /** Used for getBlock, which is called at the time of bootstrap or rollback */
  connection$: Observable<TypeormConnection>;
  /** Retry strategy for getBlock. Buffer will re-subscribe to connection$ on each retry. */
  reconnectionConfig: ReconnectionConfig;
}

export const willStoreBlockData = ({
  genesisParameters,
  block,
  tip
}: {
  genesisParameters: Cardano.CompactGenesis;
  block: Cardano.Block;
  tip: Cardano.Tip;
}) => block.header.blockNo >= tip.blockNo - genesisParameters.securityParameter;

export class TypeormStabilityWindowBuffer implements StabilityWindowBuffer {
  readonly #queryRunner$: Observable<QueryRunner>;
  readonly #retryBackoffConfig: RetryBackoffConfig;
  readonly #logger: Logger;
  readonly #compactEvery: number;

  constructor({
    compactBufferEveryNBlocks = 100,
    connection$,
    logger,
    reconnectionConfig
  }: TypeormStabilityWindowBufferProps) {
    this.#compactEvery = compactBufferEveryNBlocks;
    this.#logger = contextLogger(logger, 'TypeormStabilityWindowBuffer');
    this.#queryRunner$ = connection$.pipe(map(({ queryRunner }) => queryRunner));
    this.#retryBackoffConfig = {
      ...reconnectionConfig,
      shouldRetry: isRecoverableTypeormError
    };
  }

  getBlock(id: Cardano.BlockId): Observable<Cardano.Block | null> {
    this.#logger.debug('getBlock', id);
    return this.#queryRunner$.pipe(
      switchMap((queryRunner) => {
        this.#logger.debug('getBlock query runner');
        const repository = queryRunner.manager.getRepository(BlockDataEntity);
        return from(
          (async () => {
            const blockDataEntity = await repository.findOne({ where: { block: { hash: id } } });
            this.#logger.debug('getBlock found', blockDataEntity);
            return blockDataEntity?.data || null;
          })()
        );
      }),
      take(1),
      catchError((err) => {
        this.#logger.error(err);
        throw err;
      }),
      retryBackoff(this.#retryBackoffConfig)
    );
  }

  storeBlockData<T extends ProjectionEvent<WithTypeormContext>>() {
    return (evt$: Observable<T>) =>
      evt$.pipe(
        concatMap((evt) => {
          if (
            evt.eventType === ChainSyncEventType.RollForward &&
            evt.block.header.blockNo >= evt.tip.blockNo - evt.genesisParameters.securityParameter
          ) {
            return from(this.#rollForward(evt)).pipe(map(() => evt));
          }
          return of(evt);
        })
      );
  }

  async #rollForward(evt: RollForwardEvent<WithNetworkInfo & WithTypeormContext>) {
    const { eventType, queryRunner, block } = evt;
    const {
      header: { blockNo }
    } = block;
    const repository = queryRunner.manager.getRepository(BlockDataEntity);
    if (eventType === ChainSyncEventType.RollForward) {
      this.#logger.debug('Add block data at height', blockNo);
      const blockData = repository.create({
        block: {
          height: blockNo
        },
        data: block
      });
      await Promise.all([repository.insert(blockData), this.#deleteOldBlockData(evt)]);
    }
  }

  async #deleteOldBlockData({
    genesisParameters: { securityParameter },
    block: {
      header: { blockNo }
    },
    queryRunner
  }: RollForwardEvent<WithNetworkInfo & WithTypeormContext>) {
    if (blockNo % this.#compactEvery !== 0) {
      return;
    }
    const repository = queryRunner.manager.getRepository(BlockDataEntity);
    const nextTailBlockHeight = blockNo - securityParameter;
    await repository.delete({
      blockHeight: LessThan(nextTailBlockHeight)
    });
  }
}
