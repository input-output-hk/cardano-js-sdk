import { BehaviorSubject, Observable, from, switchMap, tap } from 'rxjs';
import { Cardano } from '@cardano-sdk/core';
import { Logger, dummyLogger } from 'ts-log';

import { AppDataSource } from './data-source';
import { StabilityWindowBuffer } from '../types';
import { fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';
import { StabilityWindowBlockEntity } from './entity/StabilityWindowBlock.entity';

export class PgStabilityWindowBuffer implements StabilityWindowBuffer {
  tip$: Observable<Cardano.Block | 'origin'>;
  tail$: Observable<Cardano.Block | 'origin'>;

  logger: Logger;

  constructor() {
    this.tip$ = this.#tip.asObservable();
    this.tail$ = this.#tail.asObservable();
    this.logger = dummyLogger;
  }

  addStabilityWindowBlock(block: Cardano.Block): Observable<void> {
    // Query runner will be provided as input, to allow building transactions
    const queryRunner = AppDataSource.createQueryRunner();
    const b = new StabilityWindowBlockEntity();
    b.slot = block.header.slot;
    b.blockHash = block.header.hash;
    b.blockHexBlob = JSON.stringify(toSerializableObject(block));
    return from(queryRunner.manager.save(b)).pipe(
      tap((v) => this.#tip.next(fromSerializableObject<Cardano.Block>(JSON.parse(v.blockHexBlob))),
      // TODO: remove switch map when queryRunner will be an input, so commit will be controlled from outside
      switchMap(() => from(queryRunner.commitTransaction()))
    );
  }

  deleteStabilityWindowBlock(evt: Cardano.Block): Observable<void> {
    // Query runner will be provided as input, to allow building transactions
    const queryRunner = AppDataSource.createQueryRunner();
    const slotCondition: Partial<StabilityWindowBlockEntity> = { slot: evt.header.slot };
    return from(
      queryRunner.manager.delete<StabilityWindowBlockEntity>(StabilityWindowBlockEntity, slotCondition)
    ).pipe(switchMap(() => from(queryRunner.commitTransaction())));
  }
}
