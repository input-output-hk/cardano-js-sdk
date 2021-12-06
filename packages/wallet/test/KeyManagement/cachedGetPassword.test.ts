import { KeyManagement } from '../../src';

jest.useFakeTimers();

describe('cachedGetPassword', () => {
  let getPassword: jest.Mock;
  let cachedGetPassword: KeyManagement.GetPassword;
  const cacheDuration = 100;
  const password = Buffer.from('password');

  beforeEach(() => {
    getPassword = jest.fn().mockResolvedValue(password);
    cachedGetPassword = KeyManagement.cachedGetPassword(getPassword, cacheDuration);
  });

  it('caches password for specified duration"', async () => {
    const pw1 = await cachedGetPassword();
    expect(getPassword).toBeCalledTimes(1);
    expect(pw1).toBe(password);

    jest.advanceTimersByTime(cacheDuration / 2);
    const pw2 = await cachedGetPassword();
    expect(getPassword).toBeCalledTimes(1);
    expect(pw2).toBe(password);

    jest.advanceTimersByTime(cacheDuration / 2 + 1);
    const pw3 = await cachedGetPassword();
    expect(getPassword).toBeCalledTimes(2);
    expect(pw3).toBe(password);
  });

  it('ignores cache when "noCache=true', async () => {
    const pw1 = await cachedGetPassword();
    expect(pw1).toBe(password);
    expect(getPassword).toBeCalledTimes(1);

    jest.advanceTimersByTime(cacheDuration / 2);
    const pw2 = await cachedGetPassword(true);
    expect(getPassword).toBeCalledTimes(2);
    expect(pw2).toBe(password);
  });
});
