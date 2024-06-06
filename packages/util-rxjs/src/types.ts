import type { Observable } from 'rxjs';
import type { RetryBackoffConfig } from 'backoff-rxjs';

export type ObservableType<O> = O extends Observable<infer T> ? T : unknown;

export type ReconnectionConfig = Omit<RetryBackoffConfig, 'shouldRetry'>;
