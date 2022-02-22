import { util } from '../../src/util';

test('bytesToHex', () => {
  expect(util.bytesToHex(Buffer.from('abc'))).toBe('616263');
});
