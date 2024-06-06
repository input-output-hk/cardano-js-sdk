import { HexBlob } from '@cardano-sdk/util';
import { util } from '../../src/util/index.js';

describe('encoding', () => {
  test('bytesToHex', () => {
    expect(util.bytesToHex(Buffer.from('abc'))).toEqual('616263');
  });
  test('hexToBytes', () => {
    expect(util.hexToBytes(HexBlob('616263'))).toEqual(Buffer.from('abc'));
  });
  test('utf8ToBytes', () => {
    expect(util.utf8ToBytes('hello')).toEqual(Buffer.from('hello', 'utf8'));
  });
  test('utf8ToHex', () => {
    expect(util.utf8ToHex('hello')).toEqual(Buffer.from('hello', 'utf8').toString('hex'));
  });
});
