import { keyAgentReady, stakePoolProvider, txSubmitProvider, walletProvider } from './config';

describe('config', () => {
  test('all config variables are set', async () => {
    expect(walletProvider).toBeTruthy();
    expect(stakePoolProvider).toBeTruthy();
    expect(txSubmitProvider).toBeTruthy();
    expect(await keyAgentReady).toBeTruthy();
  });
});
