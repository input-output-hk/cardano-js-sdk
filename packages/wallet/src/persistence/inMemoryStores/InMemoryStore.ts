import { Destroyable } from '../types';
import { Observable, of } from 'rxjs';

export abstract class InMemoryStore implements Destroyable {
  destroyed = false;
  destroy(): Observable<void> {
    this.destroyed = true;
    return of(void 0);
  }
}
