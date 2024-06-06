import { isConnectionError } from '../src/index.js';

describe('isConnectionError', () => {
  it('returns false for an object that does not resemble a connection error', () => {
    expect(isConnectionError({})).toBe(false);
  });

  it('returns true if "code" indicates that it is a connection error', () => {
    expect(isConnectionError({ code: 'ECONNREFUSED' })).toBe(true);
  });

  it('returns true if "name" indicates that it is a connection error', () => {
    expect(isConnectionError({ name: 'WebSocketClosed' })).toBe(true);
  });

  it('returns true if "innerError" is a connection error', () => {
    expect(isConnectionError({ innerError: { name: 'WebSocketClosed' } })).toBe(true);
  });
});
