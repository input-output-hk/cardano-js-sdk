import { assetProvider, chainHistoryProvider, walletProvider } from './config';

describe('config', () => {
  test('all config variables are set', () => {
    expect(walletProvider).toBeTruthy();
    expect(assetProvider).toBeTruthy();
    expect(chainHistoryProvider).toBeTruthy();
  });
});
