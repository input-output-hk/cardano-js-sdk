import { BehaviorSubject, Observable, of, tap } from 'rxjs';
import { Cardano, TipOrOrigin } from '@cardano-sdk/core';
import { ChainSyncEventType } from '../ObservableCardanoNode';
import { StabilityWindowBuffer, UnifiedExtChainSyncObservable, WithNetworkInfo } from '../types';

export class InMemoryStabilityWindowBuffer implements StabilityWindowBuffer {
  readonly #blocks: Cardano.Block[] = [];
  readonly tip$: BehaviorSubject<TipOrOrigin> = new BehaviorSubject<TipOrOrigin>('origin');

  getBlock(id: Cardano.BlockId): Observable<Cardano.Block | null> {
    return of(this.#blocks.find((block) => block.header.hash === id) || null);
  }

  handleEvents<E extends WithNetworkInfo>() {
    return (evt$: UnifiedExtChainSyncObservable<E>) =>
      evt$.pipe(
        tap(({ eventType, block, genesisParameters: { securityParameter } }) => {
          if (eventType === ChainSyncEventType.RollForward) {
            // clear blocks that are past stability window
            while (this.#blocks.length > securityParameter) this.#blocks.shift();
            // add current block to cache and return the event unchanged
            this.#blocks.push(block);
            this.tip$.next(block.header);
          } else if (eventType === ChainSyncEventType.RollBackward) {
            const lastBlock = this.#blocks.pop();
            if (lastBlock?.header.hash !== block.header.hash) {
              throw new Error('Assert: inconsistent stability window buffer at RollBackward');
            }
            this.tip$.next(this.#blocks[this.#blocks.length - 1]?.header || 'origin');
          }
        })
      );
  }
}
