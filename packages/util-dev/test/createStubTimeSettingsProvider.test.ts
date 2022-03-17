import { createStubTimeSettingsProvider } from '../src/createStubTimeSettingsProvider';
import { testnetTimeSettings } from '@cardano-sdk/core';

describe('createStubTimeSettingsProvider', () => {
  it('resolves with provided TimeSettings[]', async () => {
    const provider = createStubTimeSettingsProvider(testnetTimeSettings);
    expect(await provider.getTimeSettings()).toBe(testnetTimeSettings);
  });
});
