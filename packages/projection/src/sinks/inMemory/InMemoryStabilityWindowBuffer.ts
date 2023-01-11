import { BehaviorSubject, EMPTY, Observable } from 'rxjs';
import { Cardano, calculateStabilityWindowSlotsCount } from '@cardano-sdk/core';
import { StabilityWindowBuffer } from '../types';
import { WithNetworkInfo } from '../../operators';

export class InMemoryStabilityWindowBuffer implements StabilityWindowBuffer {
  readonly #stabilityWindowSlotsCount: number;
  readonly #blocks: Cardano.Block[] = [];
  readonly tip$ = new BehaviorSubject<Cardano.Block | 'origin'>('origin');
  readonly tail$ = new BehaviorSubject<Cardano.Block | 'origin'>('origin');

  constructor({ genesisParameters }: Pick<WithNetworkInfo, 'genesisParameters'>) {
    this.#stabilityWindowSlotsCount = calculateStabilityWindowSlotsCount(genesisParameters);
  }

  deleteStabilityWindowBlock(block: Cardano.Block): Observable<void> {
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

  addStabilityWindowBlock(block: Cardano.Block): Observable<void> {
    // clear blocks that are past stability window
    const slotThreshold = block.header.slot.valueOf() - this.#stabilityWindowSlotsCount;
    while (this.#blocks.length > 0 && this.#blocks[0].header.slot.valueOf() < slotThreshold) this.#blocks.shift();
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
