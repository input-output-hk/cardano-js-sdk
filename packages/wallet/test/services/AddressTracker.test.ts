import { EMPTY, firstValueFrom, of } from 'rxjs';
import { createAddressTracker } from '../../src/index.js';
import { createTestScheduler, logger } from '@cardano-sdk/util-dev';
import type { AddressTracker } from '../../src/index.js';
import type { Cardano } from '@cardano-sdk/core';
import type { GroupedAddress } from '@cardano-sdk/key-management';
import type { WalletStores } from '../../src/persistence/index.js';

describe('AddressTracker', () => {
  let store: jest.Mocked<WalletStores['addresses']>;
  let addressTracker: AddressTracker;
  const discoveredAddresses = [{ address: 'addr1' as Cardano.PaymentAddress } as GroupedAddress];

  beforeEach(() => {
    store = {
      destroy: jest.fn(),
      destroyed: false,
      get: jest.fn(() => EMPTY),
      set: jest.fn((_: GroupedAddress[]) => of(void 0))
    };
  });

  afterEach(() => addressTracker.shutdown());

  describe('load', () => {
    describe('no addresses are stored', () => {
      it('subscribes to addressDiscovery$, stores discovered addresses and emits from addresses$', () => {
        createTestScheduler().run(({ cold, expectObservable, expectSubscriptions, flush }) => {
          const addressDiscovery$ = cold<GroupedAddress[]>('a', { a: discoveredAddresses });
          addressTracker = createAddressTracker({
            addressDiscovery$,
            logger,
            store
          });
          expectObservable(addressTracker.addresses$).toBe('a', { a: discoveredAddresses });
          expectSubscriptions(addressDiscovery$.subscriptions).toBe('^');
          flush();
          expect(store.get).toBeCalledTimes(1);
          expect(store.set).toBeCalledTimes(1);
          expect(store.set).toBeCalledWith(discoveredAddresses);
        });
      });
    });

    describe('some address(-es) are stored', () => {
      it('emits stored addresses and does not subscribe to addressDiscovery$', () => {
        createTestScheduler().run(({ cold, expectObservable, expectSubscriptions, flush }) => {
          const storedAddresses = [{ address: 'addrstored' as Cardano.PaymentAddress } as GroupedAddress];
          store.get.mockReturnValueOnce(cold('a', { a: storedAddresses }));
          const addressDiscovery$ = cold<GroupedAddress[]>('|');
          addressTracker = createAddressTracker({
            addressDiscovery$,
            logger,
            store
          });
          expectObservable(addressTracker.addresses$).toBe('a', { a: storedAddresses });
          expectSubscriptions(addressDiscovery$.subscriptions).toBe('');
          flush();
          expect(store.get).toBeCalledTimes(1);
          expect(store.set).not.toBeCalled();
        });
      });
    });
  });

  describe('addAddresses', () => {
    it('stores new addresses and emits from addresses$', async () => {
      const addressDiscovery$ = of(discoveredAddresses);
      addressTracker = createAddressTracker({
        addressDiscovery$,
        logger,
        store
      });
      await expect(firstValueFrom(addressTracker.addresses$)).resolves.toEqual(discoveredAddresses);
      const newAddress = { address: 'addr2' as Cardano.PaymentAddress } as GroupedAddress;
      const combinedAddresses = [...discoveredAddresses, newAddress];

      await expect(firstValueFrom(addressTracker.addAddresses([newAddress]))).resolves.toEqual(combinedAddresses);
      await expect(firstValueFrom(addressTracker.addresses$)).resolves.toEqual(combinedAddresses);
      expect(store.set).toBeCalledTimes(2);
      expect(store.set).toBeCalledWith(combinedAddresses);
    });
  });
});
