import { Logger } from 'ts-log';
import { Observable, defer, finalize, tap } from 'rxjs';

export const logOperatorDuration =
  <T>(name: string, operator: (source: Observable<T>) => Observable<T>, logger: Logger) =>
  (source: Observable<T>) =>
    defer(() => {
      const start = Date.now();
      let count = 0;

      return source.pipe(
        operator,
        tap(() => count++),
        finalize(() => {
          const duration = Date.now() - start;
          logger.info(`Operator ${name} processed ${count} items in ${duration}ms`);
        })
      );
    });
