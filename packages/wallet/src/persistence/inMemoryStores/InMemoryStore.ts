import { of } from 'rxjs';
import type { Destroyable } from '../types.js';
import type { Observable } from 'rxjs';

export abstract class InMemoryStore implements Destroyable {
  destroyed = false;
  destroy(): Observable<void> {
    this.destroyed = true;
    return of(void 0);
  }
}
