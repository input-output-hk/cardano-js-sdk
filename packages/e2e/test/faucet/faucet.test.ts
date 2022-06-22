import { FaucetProvider } from '../../src/FaucetProvider/types';
import { faucetProvider } from '../config';

describe('CardanoWalletFaucetProvider', () => {
  const _faucetProvider: FaucetProvider = faucetProvider;

  beforeAll(async () => {
    await _faucetProvider.start();
    const healthCheck = await _faucetProvider.healthCheck();

    if (!healthCheck.ok) throw new Error('Faucet provider could not be started.');
  });

  afterAll(async () => {
    await _faucetProvider.close();
  });

  it('must be able to fund a wallet with the requested amount of ada.', async () => {
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
