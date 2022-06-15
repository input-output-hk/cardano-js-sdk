import { assetProvider, chainHistoryProvider } from './config';

describe('config', () => {
  test('all config variables are set', () => {
    expect(assetProvider).toBeTruthy();
    expect(chainHistoryProvider).toBeTruthy();
  });
});
