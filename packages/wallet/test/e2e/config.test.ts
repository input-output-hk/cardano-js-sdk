import { keyAgentReady, stakePoolProvider, txSubmitProvider } from './config';

describe('config', () => {
  test('all config variables are set', async () => {
    expect(stakePoolProvider).toBeTruthy();
    expect(txSubmitProvider).toBeTruthy();
    expect(await keyAgentReady).toBeTruthy();
  });
});
