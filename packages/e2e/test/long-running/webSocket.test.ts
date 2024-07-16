import { CardanoWsClient } from '@cardano-sdk/cardano-services-client';
import { getEnv, walletVariables } from '../../src';
import { logger } from '@cardano-sdk/util-dev';

const env = getEnv([...walletVariables]);

describe('Web Socket', () => {
  let client: CardanoWsClient;

  const openClient = () => (client = new CardanoWsClient({ logger }, { url: new URL(env.WS_PROVIDER_URL) }));

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
