import { keyManager, stakePoolSearchProvider, walletProvider } from './config';

describe('config', () => {
  test('all config variables are set', () => {
    expect(walletProvider).toBeTruthy();
    expect(stakePoolSearchProvider).toBeTruthy();
    expect(keyManager).toBeTruthy();
  });
});
