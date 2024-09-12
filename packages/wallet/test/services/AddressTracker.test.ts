import { AddressTracker, createAddressTracker } from '../../src';
import { AddressType, GroupedAddress, KeyRole } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { EMPTY, firstValueFrom, of } from 'rxjs';
import { WalletStores } from '../../src/persistence';
import { address_0_0, address_0_5, address_5_0, rewardAccount_0, rewardAccount_5 } from './ChangeAddress/testData';
import { createTestScheduler, logger } from '@cardano-sdk/util-dev';
import { sortAddresses } from '../../src/services/util/sortAddresses';

describe('AddressTracker', () => {
  let store: jest.Mocked<WalletStores['addresses']>;
  let addressTracker: AddressTracker;
  const discoveredAddresses = [
    {
      accountIndex: 0,
      address: address_5_0,
      index: 5,
      networkId: Cardano.NetworkId.Testnet,
      rewardAccount: rewardAccount_0,
      stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
      type: AddressType.External
    },
    {
      accountIndex: 0,
      address: address_0_5,
      index: 0,
      networkId: Cardano.NetworkId.Testnet,
      rewardAccount: rewardAccount_5,
      stakeKeyDerivationPath: { index: 5, role: KeyRole.Stake },
      type: AddressType.External
    },
    {
      accountIndex: 0,
      address: address_0_0,
      index: 0,
      networkId: Cardano.NetworkId.Testnet,
      rewardAccount: rewardAccount_0,
      stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
      type: AddressType.External
    }
  ];

  beforeEach(() => {
    store = {
      destroy: jest.fn(),
      destroyed: false,
      get: jest.fn(() => EMPTY),
      set: jest.fn((_: GroupedAddress[]) => of(void 0))
    };
  });

  const sortedDiscoveredAddresses = sortAddresses(discoveredAddresses);

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
          expectObservable(addressTracker.addresses$).toBe('a', { a: sortedDiscoveredAddresses });
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
      await expect(firstValueFrom(addressTracker.addresses$)).resolves.toEqual(sortedDiscoveredAddresses);
      const newAddress = { address: 'addr2' as Cardano.PaymentAddress } as GroupedAddress;
      const combinedAddresses = [...discoveredAddresses, newAddress];

      await expect(firstValueFrom(addressTracker.addAddresses([newAddress]))).resolves.toEqual(combinedAddresses);
      await expect(firstValueFrom(addressTracker.addresses$)).resolves.toEqual(sortAddresses(combinedAddresses));
      expect(store.set).toBeCalledTimes(2);
      expect(store.set).toBeCalledWith(combinedAddresses);
    });
  });
});
