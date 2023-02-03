import { BehaviorSubject, EMPTY, Observable } from 'rxjs';
import { Cardano } from '@cardano-sdk/core';
import { RollForwardEvent } from '../../types';
import { StabilityWindowBuffer } from '../types';
import { WithNetworkInfo } from '../../operators';

export class InMemoryStabilityWindowBuffer<E extends WithNetworkInfo> implements StabilityWindowBuffer<E> {
  readonly #blocks: Cardano.Block[] = [];
  readonly tip$ = new BehaviorSubject<Cardano.Block | 'origin'>('origin');
  readonly tail$ = new BehaviorSubject<Cardano.Block | 'origin'>('origin');

  deleteBlock(block: Cardano.Block): Observable<void> {
    for (let i = this.#blocks.length - 1; i >= 0; i--) {
      const bufferBlock = this.#blocks[i];
      if (bufferBlock.header.hash === block.header.hash) {
        this.#blocks.splice(i, 1);
        break;
      }
    }
    this.tip$.next(this.#blocks[this.#blocks.length - 1] || 'origin');
    const newTail = this.#blocks[0] || 'origin';
    this.#setTail(newTail);
    return EMPTY;
  }

  rollForward({
    block,
    genesisParameters: { securityParameter }
  }: RollForwardEvent<WithNetworkInfo>): Observable<void> {
    // clear blocks that are past stability window
    while (this.#blocks.length > securityParameter) this.#blocks.shift();
    // add current block to cache and return the event unchanged
    this.#blocks.push(block);
    this.tip$.next(block);
    this.#setTail(this.#blocks[0]);
    return EMPTY;
  }

  #setTail(tail: Cardano.Block | 'origin') {
    if (this.tail$.value !== tail) {
      this.tail$.next(tail);
    }
  }
}
