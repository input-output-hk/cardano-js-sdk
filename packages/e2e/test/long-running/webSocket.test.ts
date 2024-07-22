import { CardanoWsClient, chainHistoryHttpProvider } from '@cardano-sdk/cardano-services-client';
import { getEnv, walletVariables } from '../../src';
import { logger } from '@cardano-sdk/util-dev';

const env = getEnv([...walletVariables]);

describe('Web Socket', () => {
  const chainHistoryProvider = chainHistoryHttpProvider({ logger, ...env.TEST_CLIENT_CHAIN_HISTORY_PROVIDER_PARAMS });
  let client: CardanoWsClient;

  const openClient = () =>
    (client = new CardanoWsClient({ chainHistoryProvider, logger }, { url: new URL(env.WS_PROVIDER_URL) }));

  const closeClient = () => (client ? client.close() : Promise.resolve());

  afterEach(closeClient);

  it('CardanoWsClient.epoch$ emits on epoch rollover', (done) => {
    openClient();

    // If it emits on epoch rollover ok, otherwise the test fails on timeout
    const subscription = client.epoch$.subscribe(() => {
      subscription.unsubscribe();
      done();
    });
  });
});
