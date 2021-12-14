import { KeyManagement } from '../../src';

jest.useFakeTimers();

describe('cachedGetPassword', () => {
  let getPassword: jest.Mock;
  let cachedGetPassword: KeyManagement.GetPassword;
  const getPasswordDuration = 10;
  const cacheDuration = 100;
  const password = Buffer.from('password');

  beforeEach(() => {
    getPassword = jest
      .fn()
      .mockImplementation(() => new Promise((resolve) => setTimeout(() => resolve(password), getPasswordDuration)));
    cachedGetPassword = KeyManagement.cachedGetPassword(getPassword, cacheDuration);
  });

  it('caches password for specified duration"', async () => {
    const pw1 = cachedGetPassword();
    jest.advanceTimersByTime(getPasswordDuration);
    expect(await pw1).toBe(password);
    expect(getPassword).toBeCalledTimes(1);

    jest.advanceTimersByTime(cacheDuration - 1);
    const pw2 = cachedGetPassword();
    expect(await pw2).toBe(password);
    expect(getPassword).toBeCalledTimes(1);

    jest.advanceTimersByTime(1);
    const pw3 = cachedGetPassword();
    jest.advanceTimersByTime(getPasswordDuration);
    expect(await pw3).toBe(password);
    expect(getPassword).toBeCalledTimes(2);
  });

  it('does not call underlying "getPassword" again while already authenticating', async () => {
    const pw1 = cachedGetPassword();
    jest.advanceTimersByTime(getPasswordDuration / 2);
    const pw2 = cachedGetPassword();
    jest.advanceTimersByTime(getPasswordDuration / 2);
    expect(await pw1).toBe(password);
    expect(await pw2).toBe(password);
    expect(getPassword).toBeCalledTimes(1);
  });

  it('does not cache failed "getPassword"', async () => {
    getPassword.mockRejectedValueOnce(new Error('any error'));
    await expect(cachedGetPassword()).rejects.toThrowError();
    const pw = cachedGetPassword();
    jest.advanceTimersByTime(getPasswordDuration);
    expect(await pw).toBe(password);
    expect(getPassword).toBeCalledTimes(2);
  });

  it('ignores cache when "noCache=true', async () => {
    const pw = cachedGetPassword();
    jest.advanceTimersByTime(getPasswordDuration);
    expect(await pw).toBe(password);
    expect(getPassword).toBeCalledTimes(1);

    jest.advanceTimersByTime(cacheDuration / 2);
    const pw2 = cachedGetPassword(true);
    jest.advanceTimersByTime(getPasswordDuration);
    expect(await pw2).toBe(password);
    expect(getPassword).toBeCalledTimes(2);
  });
});
