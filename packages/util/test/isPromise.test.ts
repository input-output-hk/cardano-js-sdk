import { isPromise } from '../src/index.js';

describe('isPromise', () => {
  it('returns true for Promise-like objects', () => expect(isPromise(Promise.resolve())).toBe(true));
  it('returns false for non-Promise-like objects', () => expect(isPromise({})).toBe(false));
});
