import { Observable } from 'rxjs';

export type MaybeObservable<T> = T | Observable<T>;
