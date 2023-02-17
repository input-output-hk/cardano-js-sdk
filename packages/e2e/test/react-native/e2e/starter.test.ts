import { by, device, element, expect } from 'detox';

describe('Example', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should have correct title and text for the first section', async () => {
    await expect(element(by.id('section-0-title'))).toBeVisible();
    await expect(element(by.id('section-0-title'))).toHaveText('Step One');
    await expect(element(by.id('section-0-text'))).toBeVisible();
    await expect(element(by.id('section-0-text'))).toHaveText(
      'Edit App.tsx to change this screen and then come back to see your edits.'
    );
  });
});
