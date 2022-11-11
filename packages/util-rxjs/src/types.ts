import { Observable } from 'rxjs';

export type ObservableType<O> = O extends Observable<infer T> ? T : unknown;
