import { Asset } from '../../../src/index.js';

const validHandles = [
  'bob',
  'a',
  'alice',
  '_',
  'test-handle',
  'test.handle',
  'test-handle.123',
  'handle_name',
  'handle_name',
  'a@alice',
  'alice@a',
  'test-@handle',
  // Exists on mainnet
  '0|0'
];

const invalidHandles = [
  'Alice',
  'bob!',
  '$wallet',
  'alice@',
  '@alice',
  'test*handle#2',
  'lace&bob',
  'ada%1_test',
  'lace ',
  'wallet|',
  'comma,',
  'comma,@sub',
  'sub@comma,',
  '\n',
  '\r',
  ' ',
  'sub@sub@handle',
  // too long
  'test-handle-123.456'
];

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
});
