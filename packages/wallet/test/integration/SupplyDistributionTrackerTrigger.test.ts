import { createInMemorySupplyDistributionStores } from '../../src/persistence';
import { createSupplyDistributionTracker } from '../../src';
import { createWallet } from './util';
import { dummyLogger } from 'ts-log';
import { mockProviders } from '@cardano-sdk/util-dev';

describe('SupplyDistributionTracker', () => {
  it('accepts an ObservableWallet as "trigger"', async () => {
    const { wallet } = await createWallet();
    const tracker = createSupplyDistributionTracker(
      // the test is that this line compiles
      { trigger$: wallet.currentEpoch$ },
      {
        logger: dummyLogger,
        networkInfoProvider: mockProviders.mockNetworkInfoProvider(),
        stores: createInMemorySupplyDistributionStores()
      }
    );
    tracker.shutdown();
    wallet.shutdown();
  });
});
