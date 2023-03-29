import { BehaviorSubject, tap } from 'rxjs';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { StabilityWindowBuffer } from '../types';
import { UnifiedProjectorObservable } from '../../types';
import { WithNetworkInfo } from '../../operators';

export class InMemoryStabilityWindowBuffer implements StabilityWindowBuffer {
  readonly #blocks: Cardano.Block[] = [];
  readonly tip$ = new BehaviorSubject<Cardano.Block | 'origin'>('origin');
  readonly tail$ = new BehaviorSubject<Cardano.Block | 'origin'>('origin');

  handleEvents<E extends WithNetworkInfo>() {
    return (evt$: UnifiedProjectorObservable<E>) =>
      evt$.pipe(
        tap(({ eventType, block, genesisParameters: { securityParameter } }) => {
          if (eventType === ChainSyncEventType.RollForward) {
            // clear blocks that are past stability window
            while (this.#blocks.length > securityParameter) this.#blocks.shift();
            // add current block to cache and return the event unchanged
            this.#blocks.push(block);
            this.tip$.next(block);
            this.#setTail(this.#blocks[0]);
          } else if (eventType === ChainSyncEventType.RollBackward) {
            const lastBlock = this.#blocks.pop();
            if (lastBlock?.header.hash !== block.header.hash) {
              throw new Error('Assert: inconsistent stability window buffer at RollBackward');
            }
            this.tip$.next(this.#blocks[this.#blocks.length - 1] || 'origin');
            this.#setTail(this.#blocks[0] || 'origin');
          }
        })
      );
  }

  shutdown(): void {
    this.tip$.complete();
    this.tail$.complete();
  }

  #setTail(tail: Cardano.Block | 'origin') {
    if (this.tail$.value !== tail) {
      this.tail$.next(tail);
    }
  }
}
