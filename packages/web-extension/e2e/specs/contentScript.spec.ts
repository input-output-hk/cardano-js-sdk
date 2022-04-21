describe('contentScript', () => {
  it('should set h2 text', async () => {
    await browser.url('https://the-internet.herokuapp.com/login');

    await expect($('h2')).toHaveText('h2');
  });
});
