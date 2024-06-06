import { createInMemorySupplyDistributionStores } from '../../src/persistence/index.js';
import { createSupplyDistributionTracker } from '../../src/index.js';
import { createWallet } from './util.js';
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
