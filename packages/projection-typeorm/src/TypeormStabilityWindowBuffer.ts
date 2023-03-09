/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable brace-style */
import { BlockEntity } from './entity';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { IsNull, LessThan, Not, QueryRunner } from 'typeorm';
import { Logger } from 'ts-log';
import { Observable, ReplaySubject, concatMap, from, map } from 'rxjs';
import {
  Operators,
  RollBackwardEvent,
  RollForwardEvent,
  StabilityWindowBuffer,
  UnifiedProjectorOperator,
  WithBlock
} from '@cardano-sdk/projection';
import { WithLogger, contextLogger } from '@cardano-sdk/util';
import { WithTypeormContext } from './types';

export interface TypeormStabilityWindowBufferProps {
  /**
   * 100 by default
   */
  compactBufferEveryNBlocks?: number;
}

export class TypeormStabilityWindowBuffer
  implements StabilityWindowBuffer<Operators.WithNetworkInfo & WithTypeormContext>
{
  #tail: Cardano.Block | 'origin';
  readonly #logger: Logger;
  readonly #compactEvery: number;
  readonly #tip$ = new ReplaySubject<Cardano.Block | 'origin'>(1);
  readonly #tail$ = new ReplaySubject<Cardano.Block | 'origin'>(1);
  readonly tip$: Observable<Cardano.Block | 'origin'>;
  readonly tail$: Observable<Cardano.Block | 'origin'>;
  readonly handleEvents: UnifiedProjectorOperator<
    Operators.WithNetworkInfo & WithTypeormContext,
    Operators.WithNetworkInfo & WithTypeormContext
  >;

  constructor({ compactBufferEveryNBlocks = 100 }: TypeormStabilityWindowBufferProps, dependencies: WithLogger) {
    this.tip$ = this.#tip$.asObservable();
    this.tail$ = this.#tail$.asObservable();
    this.#compactEvery = compactBufferEveryNBlocks;
    this.#logger = contextLogger(dependencies.logger, 'PgStabilityWindowBuffer');
    this.handleEvents = (evt$) =>
      evt$.pipe(
        concatMap((evt) =>
          from(
            evt.eventType === ChainSyncEventType.RollForward ? this.#rollForward(evt) : this.#rollBackward(evt)
          ).pipe(map(() => evt))
        )
      );
  }

  async initialize(queryRunner: QueryRunner): Promise<void> {
    const repository = queryRunner.manager.getRepository(BlockEntity);
    const [tip, tail] = await Promise.all([
      // findOne fails without `where:`, so using find().
      // It makes 2 queries so is not very efficient,
      // but it should be fine for `initialize`.
      repository.find({
        order: { slot: 'DESC' },
        select: {
          bufferData: true as any
        },
        take: 1
      }),
      repository.find({
        order: { slot: 'ASC' },
        select: {
          bufferData: true as any
        },
        take: 1,
        where: {
          bufferData: Not(IsNull())
        }
      })
    ]);
    this.#tip$.next(tip[0]?.bufferData || 'origin');
    this.#setTail(tail[0]?.bufferData || 'origin');
  }

  shutdown(): void {
    this.#tip$.complete();
    this.#tail$.complete();
  }

  async #rollForward(evt: RollForwardEvent<Operators.WithNetworkInfo & WithTypeormContext>) {
    const { transactionCommitted$, block } = evt;
    await this.#deleteOldBlockData(evt);
    transactionCommitted$.subscribe(() => {
      this.#tip$.next(block);
      if (this.#tail === 'origin') {
        this.#setTail(block);
      }
    });
  }

  async #rollBackward({
    transactionCommitted$,
    queryRunner,
    block: {
      header: { slot, blockNo }
    }
  }: RollBackwardEvent<WithBlock & WithTypeormContext>) {
    const repository = queryRunner.manager.getRepository(BlockEntity);
    const prevTip = await repository.findOne({
      order: {
        slot: 'DESC'
      },
      select: {
        bufferData: true as any
      },
      where: {
        bufferData: Not(IsNull()),
        slot: LessThan(slot)
      }
    });
    if (prevTip?.bufferData && blockNo !== prevTip?.bufferData.header.blockNo + 1) {
      throw new Error('Assert: inconsistent PgStabilityWindowBuffer at rollBackward');
    }
    transactionCommitted$.subscribe(() => {
      this.#tip$.next(prevTip?.bufferData || 'origin');
      if (!prevTip?.bufferData) {
        this.#setTail('origin');
      }
    });
  }

  async #deleteOldBlockData({
    genesisParameters: { securityParameter },
    block: {
      header: { blockNo }
    },
    queryRunner,
    transactionCommitted$
  }: RollForwardEvent<Operators.WithNetworkInfo & WithTypeormContext>) {
    if (blockNo < securityParameter || blockNo % this.#compactEvery !== 0) {
      return;
    }
    const repository = queryRunner.manager.getRepository(BlockEntity);
    const nextTailBlockHeight = blockNo - securityParameter;
    this.#logger.info(`Deleting old block buffer data (<${nextTailBlockHeight})`);
    const [nextTailEntity] = await Promise.all([
      repository.findOne({
        select: {
          bufferData: true as any
        },
        where: {
          height: nextTailBlockHeight
        }
      }),
      repository.update(
        {
          height: LessThan(nextTailBlockHeight)
        },
        {
          blockData: null
        }
      )
      // TODO
      // Review: this is fragile, may be better to make 2 type-safe(r) queries instead:
      // select IDs and then delete
      // queryRunner.query(`
      //   DELETE FROM block_data
      //   WHERE block_id IN (SELECT id FROM block WHERE height < ${nextTailBlockHeight})
      // `)
    ]);
    const nextTail = nextTailEntity?.bufferData;
    if (!nextTail) {
      throw new Error('Assert: inconsistent PgStabilityWindowBuffer at #deleteOldBlockData');
    }
    transactionCommitted$.subscribe(() => this.#setTail(nextTail));
  }

  #setTail(tail: Cardano.Block | 'origin') {
    this.#tail = tail;
    this.#tail$.next(tail);
  }
}
