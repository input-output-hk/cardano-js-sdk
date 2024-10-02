import { Cardano } from '@cardano-sdk/core';
import { Observable, Subscription } from 'rxjs';

export type AccountChangeCb = (addresses: Cardano.BaseAddress[]) => unknown;
export type NetworkChangeCb = (network: Cardano.NetworkId) => unknown;
export enum Cip30EventName {
  'accountChange' = 'accountChange',
  'networkChange' = 'networkChange'
}
export type Cip30EventMethod = (eventName: Cip30EventName, callback: AccountChangeCb | NetworkChangeCb) => void;
export type Cip30Event = { eventName: Cip30EventName; data: Cardano.NetworkId | Cardano.BaseAddress[] };
type Cip30NetworkChangeEvent = { eventName: Cip30EventName.networkChange; data: Cardano.NetworkId };
type Cip30AccountChangeEvent = { eventName: Cip30EventName.accountChange; data: Cardano.BaseAddress[] };
type Cip30EventRegistryMap = {
  accountChange: AccountChangeCb[];
  networkChange: NetworkChangeCb[];
};

const isNetworkChangeEvent = (event: Cip30Event): event is Cip30NetworkChangeEvent =>
  event.eventName === Cip30EventName.networkChange;

const isAccountChangeEvent = (event: Cip30Event): event is Cip30AccountChangeEvent =>
  event.eventName === Cip30EventName.accountChange;

/**
 * This class is responsible for registering and deregistering callbacks for specific events.
 * It also handles calling the registered callbacks.
 */
export class Cip30EventRegistry {
  #cip30Event$: Observable<Cip30Event>;
  #registry: Cip30EventRegistryMap;
  #subscription: Subscription;

  constructor(cip30Event$: Observable<Cip30Event>) {
    this.#cip30Event$ = cip30Event$;
    this.#registry = {
      accountChange: [],
      networkChange: []
    };

    this.#subscription = this.#cip30Event$.subscribe((event) => {
      if (isNetworkChangeEvent(event)) {
        const { data } = event;
        for (const callback of this.#registry.networkChange) callback(data);
      } else if (isAccountChangeEvent(event)) {
        const { data } = event;
        for (const callback of this.#registry.accountChange) callback(data);
      }
    });
  }

  /**
   * Register a callback for a specific event name.
   *
   * @param eventName - The event name to register the callback for.
   * @param callback - The callback to be called when the event is triggered.
   */
  register(eventName: Cip30EventName, callback: AccountChangeCb | NetworkChangeCb) {
    if (this.#subscription.closed) return;

    if (eventName === Cip30EventName.accountChange) {
      this.#registry.accountChange.push(callback as AccountChangeCb);
    } else if (eventName === Cip30EventName.networkChange) {
      this.#registry.networkChange.push(callback as NetworkChangeCb);
    }
  }

  /**
   * Deregister a callback for a specific event name. The callback must be the same reference used on registration.
   *
   * @param eventName - The event name to deregister the callback from.
   * @param callback - The callback to be deregistered.
   */
  deregister(eventName: Cip30EventName, callback: AccountChangeCb | NetworkChangeCb) {
    if (this.#subscription.closed) return;

    if (eventName === Cip30EventName.accountChange) {
      this.#registry.accountChange = this.#registry.accountChange.filter((cb) => cb !== callback);
    } else if (eventName === Cip30EventName.networkChange) {
      this.#registry.networkChange = this.#registry.networkChange.filter((cb) => cb !== callback);
    }
  }

  /** Unsubscribe from the event stream. Once called, the registry can no longer be used. */
  shutdown() {
    if (this.#subscription.closed) return;
    this.#subscription.unsubscribe();
  }
}
