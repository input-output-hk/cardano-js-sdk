import { Cardano } from '@cardano-sdk/core';
import { DataSource } from 'typeorm';
import { EMPTY, Observable, Subject } from 'rxjs';
import { Logger, dummyLogger } from 'ts-log';

import { RollForwardEvent } from '../../types';
import { StabilityWindowBuffer } from '../types';
import { WithNetworkInfo } from '../../operators';
import { WithPgContext } from './types';

export class PgStabilityWindowBuffer implements StabilityWindowBuffer<WithNetworkInfo & WithPgContext> {
  #tip$ = new Subject<Cardano.Block | 'origin'>();
  #tail$ = new Subject<Cardano.Block | 'origin'>();
  tip$: Observable<Cardano.Block | 'origin'>;
  tail$: Observable<Cardano.Block | 'origin'>;

  logger: Logger;

  constructor() {
    this.tip$ = this.#tip$.asObservable();
    this.tail$ = this.#tail$.asObservable();
    this.logger = dummyLogger;
  }

  // TODO: implement this
  rollForward({
    block,
    transactionCommit$,
    queryRunner
  }: RollForwardEvent<WithNetworkInfo & WithPgContext>): Observable<void> {
    // It should be ok to run the compaction once per initialization of the service/reconnection.
    // Query runner will be provided as input, to allow building transactions
    // const b = new StabilityWindowBlockEntity();
    // b.slot = block.header.slot;
    // b.blockHash = block.header.hash;
    // b.blockHexBlob = JSON.stringify(toSerializableObject(block));
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    block;
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    transactionCommit$; // TODO: use this to set new tip$
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    queryRunner;
    return EMPTY;
    // return from(queryRunner.manager.save(b)).pipe(
    //   tap((v) => this.#tip.next(fromSerializableObject<Cardano.Block>(JSON.parse(v.blockHexBlob))),
    //   // TODO: remove switch map when queryRunner will be an input, so commit will be controlled from outside
    //   switchMap(() => from(queryRunner.commitTransaction()))
    // );
  }

  // TODO: implement this
  deleteBlock(_evt: Cardano.Block): Observable<void> {
    // Query runner will be provided as input, to allow building transactions
    // const queryRunner = AppDataSource.createQueryRunner();
    // const slotCondition: Partial<StabilityWindowBlockEntity> = { slot: evt.header.slot };
    return EMPTY;
    // return from(
    //   queryRunner.manager.delete<StabilityWindowBlockEntity>(StabilityWindowBlockEntity, slotCondition)
    // ).pipe(switchMap(() => from(queryRunner.commitTransaction())));
  }

  async initialize(_dataSource: DataSource): Promise<void> {
    // TODO: compact (delete) old blocks from tail and set tip$ and tail$.
    // tail$ can have constant value after initialization,
    // as there is no need to keep the buffer of minimum required size -
    // there is no harm of it being larger, other than taking more disk space.
  }
}
