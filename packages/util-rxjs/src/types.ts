import { Observable } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';

export type ObservableType<O> = O extends Observable<infer T> ? T : unknown;

export type ReconnectionConfig = Omit<RetryBackoffConfig, 'shouldRetry'>;
