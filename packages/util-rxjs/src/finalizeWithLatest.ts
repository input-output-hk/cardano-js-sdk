import { finalize, tap } from 'rxjs';
import type { Observable } from 'rxjs';

export const finalizeWithLatest =
  <T>(callback: (latest: T | null) => void) =>
  (value$: Observable<T>) => {
    let latest: T | null = null;
    return value$.pipe(
      tap((value) => (latest = value)),
      finalize(() => callback(latest))
    );
  };
