import { createInMemorySupplyDistributionStores } from '../../src/persistence';
import { createSupplyDistributionTracker } from '../../src';
import { dummyLogger } from 'ts-log';
import { firstValueFrom, of } from 'rxjs';
import { mockNetworkInfoProvider, networkInfo } from '../mocks';

describe('SupplyDistributionTracker', () => {
  it('loads data from the provider', async () => {
    const tracker = createSupplyDistributionTracker(
      {
        trigger$: of(void 0)
      },
      {
        logger: dummyLogger,
        networkInfoProvider: mockNetworkInfoProvider(),
        stores: createInMemorySupplyDistributionStores()
      }
    );
    expect(await firstValueFrom(tracker.stake$)).toEqual(networkInfo.stake);
    expect(await firstValueFrom(tracker.lovelaceSupply$)).toEqual(networkInfo.lovelaceSupply);
    tracker.shutdown();
  });
});
