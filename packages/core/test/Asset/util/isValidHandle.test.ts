import { Asset } from '../../../src';

const validHandles = [
  'bob',
  'a',
  'alice',
  'test-handle',
  'test.handle',
  'test-handle-123',
  'test-handle-123.456',
  'handle_name',
  '@alice',
  'test-@handle'
];

const invalidHandles = ['bob!', '$wallet', 'test*handle#2', 'lace&bob', 'ada%1_test', 'lace ', 'wallet  '];

describe('isValidHandle', () => {
  test('returns false for empty string', () => {
    expect(Asset.util.isValidHandle('')).toBe(false);
  });
  test.each(validHandles)('returns true for valid handle %s', (handle) => {
    expect(Asset.util.isValidHandle(handle)).toBe(true);
  });
  test.each(invalidHandles)('returns false for invalid handle %s', (handle) => {
    expect(Asset.util.isValidHandle(handle)).toBe(false);
  });
  test.each(invalidHandles)('returns false for invalid handle with spaces and tabs', (handle) => {
    expect(Asset.util.isValidHandle(handle)).toBe(false);
  });
  test.each(validHandles)('returns ok for @ symbol', (handle) => {
    expect(Asset.util.isValidHandle(handle)).toBe(true);
  });
});
