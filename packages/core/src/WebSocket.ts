import { HealthCheckResponse, NetworkInfoProvider, Provider } from './Provider';
import { HydratedTx, PaymentAddress } from './Cardano';
import { Observable, ReplaySubject, firstValueFrom } from 'rxjs';

export type AsyncReturnType<F extends () => unknown> = F extends () => Promise<infer R> ? R : never;

export type NetworkInfoMethods = Exclude<keyof NetworkInfoProvider, 'healthCheck'>;
export type NetworkInfoResponses = { [m in NetworkInfoMethods]: AsyncReturnType<NetworkInfoProvider[m]> };

export interface WSMessage {
  /** The addresses the client subscribes. */
  addresses?: PaymentAddress[];

  /** The client id assigned by the server. */
  clientId?: string;

  /** Latest value(s) for the `NetworkInfoProvider` methods.*/
  networkInfo?: Partial<NetworkInfoResponses>;

  /** The request id from client to server. */
  requestId?: number;

  /** This message is the response to the message with this id. */
  responseTo?: number;

  /** The transactions. */
  transactions?: HydratedTx[];
}

export class WsProvider implements Provider {
  /** Emits the health state. */
  public health$: Observable<HealthCheckResponse>;

  private healthSubject$: ReplaySubject<HealthCheckResponse>;
  private reason?: string;

  constructor() {
    this.health$ = this.healthSubject$ = new ReplaySubject<HealthCheckResponse>(1);
    this.healthSubject$.next({ ok: false, reason: 'starting' });
  }

  protected emitHealth(reason?: string, overwrite?: boolean) {
    if (!reason) {
      this.reason = undefined;

      return this.healthSubject$.next({ ok: true });
    }

    if (overwrite || !this.reason) this.reason = reason;

    this.healthSubject$.next({ ok: false, reason: this.reason });
  }

  public healthCheck() {
    return firstValueFrom(this.health$);
  }
}
