describe('background services', () => {
  const divAdaPrice = '#adaPrice';

  before(async () => {
    await browser.url('chrome-extension://lgehgfkeagjdklnanflcjoipaphegomm/ui.html');
  });

  it('gets the price from observable in background process', async () => {
    await expect($(divAdaPrice)).toHaveText('2.99');
  });
});
