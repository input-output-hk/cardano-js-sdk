import * as envalid from 'envalid';
import { FaucetProvider } from '../../src/FaucetProvider';
import { KeyManagement } from '@cardano-sdk/wallet';
import { faucetProviderFactory, keyAgentById } from '../../src/factories';

// Verify environment.
export const env = envalid.cleanEnv(process.env, {
  FAUCET_PROVIDER: envalid.str(),
  FAUCET_PROVIDER_PARAMS: envalid.json({ default: {} }),
  KEY_MANAGEMENT_PARAMS: envalid.json({ default: {} }),
  KEY_MANAGEMENT_PROVIDER: envalid.str()
});

describe('CardanoWalletFaucetProvider', () => {
  let _faucetProvider: FaucetProvider;
  let _keyAgent: KeyManagement.AsyncKeyAgent;

  beforeAll(async () => {
    _faucetProvider = await faucetProviderFactory.create(env.FAUCET_PROVIDER, env.FAUCET_PROVIDER_PARAMS);
    _keyAgent = await keyAgentById(0, env.KEY_MANAGEMENT_PROVIDER, env.KEY_MANAGEMENT_PARAMS);

    await _faucetProvider.start();

    const healthCheck = await _faucetProvider.healthCheck();

    if (!healthCheck.ok) throw new Error('Faucet provider could not be started.');
  });

  afterAll(async () => {
    await _faucetProvider.close();
  });

  it('must be able to fund a wallet with the requested amount of ada.', async () => {
    await _keyAgent.deriveAddress({ index: 0, type: KeyManagement.AddressType.Internal });
    await _faucetProvider.request('addr_test1vrgylrse49du60jdy7h46mg5mwft6kw8r0l4v5pklkj324cm247gf', 33_000_000);
  });

  it('must be able to fund several wallets in a single transaction with the requested amount of ada.', async () => {
    await _faucetProvider.multiRequest(
      [
        'addr_test1vrgylrse49du60jdy7h46mg5mwft6kw8r0l4v5pklkj324cm247gf',
        'addr_test1vrgylrse49du60jdy7h46mg5mwft6kw8r0l4v5pklkj324cm247gf'
      ],
      [33_000_000, 22_000_000]
    );
  });
});
