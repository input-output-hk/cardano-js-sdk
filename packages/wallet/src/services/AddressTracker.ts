import {
  Subject,
  defaultIfEmpty,
  distinctUntilChanged,
  filter,
  map,
  merge,
  mergeMap,
  of,
  shareReplay,
  switchMap,
  take,
  tap
} from 'rxjs';
import { groupedAddressesEquals } from './util/index.js';
import type { GroupedAddress } from '@cardano-sdk/key-management';
import type { Logger } from 'ts-log';
import type { Observable } from 'rxjs';
import type { WalletStores } from '../persistence/index.js';

export type AddressTrackerDependencies = {
  store: WalletStores['addresses'];
  addressDiscovery$: Observable<GroupedAddress[]>;
  logger: Logger;
};

export const createAddressTracker = ({ addressDiscovery$, store, logger }: AddressTrackerDependencies) => {
  // eslint-disable-next-line unicorn/consistent-function-scoping
  const storeAddresses = () => (addresses$: Observable<GroupedAddress[]>) =>
    addresses$.pipe(switchMap((addresses) => store.set(addresses).pipe(map(() => addresses))));

  const newAddresses$ = new Subject<GroupedAddress[]>();
  const addresses$ = store
    .get()
    .pipe(
      defaultIfEmpty([]),
      mergeMap(
        // derive addresses if none available
        (addresses) => {
          if (addresses.length === 0) {
            logger.debug('No addresses available; initiating address discovery process');
            return addressDiscovery$.pipe(
              tap((derivedAddresses) => {
                if (derivedAddresses.length === 0) {
                  throw new Error('Address discovery derived 0 addresses');
                }
              }),
              storeAddresses()
            );
          }

          return of(addresses);
        }
      ),
      switchMap((addresses) => {
        const addressCache = [...addresses];
        return merge(
          of(addresses),
          newAddresses$.pipe(
            map((newAddresses) => {
              for (const newAddress of newAddresses) {
                if (addressCache.some((addr) => addr.address === newAddress.address)) {
                  logger.warn('Address already exists', newAddress.address);
                  continue;
                }

                addressCache.push(newAddress);
              }

              return [...addressCache];
            }),
            storeAddresses()
          )
        ).pipe(distinctUntilChanged(groupedAddressesEquals));
      })
    )
    .pipe(shareReplay(1));

  return {
    addAddresses: (newAddresses: GroupedAddress[]) => {
      newAddresses$.next(newAddresses);
      return addresses$.pipe(
        filter((addresses) =>
          newAddresses.every(({ address: newAddress }) => addresses.some(({ address }) => address === newAddress))
        ),
        take(1)
      );
    },
    addresses$,
    shutdown: newAddresses$.complete.bind(newAddresses$)
  };
};

export type AddressTracker = ReturnType<typeof createAddressTracker>;
