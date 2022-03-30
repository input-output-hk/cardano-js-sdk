import { keyAgentReady, stakePoolSearchProvider, txSubmitProvider, walletProvider } from './config';

describe('config', () => {
  test('all config variables are set', () => {
    expect(walletProvider).toBeTruthy();
    expect(stakePoolSearchProvider).toBeTruthy();
    expect(txSubmitProvider).toBeTruthy();
    expect(keyAgentReady).toBeTruthy();
  });
});
