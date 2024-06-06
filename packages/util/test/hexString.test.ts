import { bufferToHexString, hexStringToBuffer } from '../src/index.js';

describe('hexString', () => {
  test('hexStringToBuffer', () =>
    expect(typeof hexStringToBuffer('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed')).toBe(
      'object'
    ));

  test('bufferToHexString', () => expect(bufferToHexString(Buffer.from(new Uint8Array()))).toBe(''));

  test('conversion of hexStringToBuffer output back via bufferToHexString', () => {
    const buffer = hexStringToBuffer('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed');
    const hexString = bufferToHexString(buffer);
    expect(hexStringToBuffer(hexString)).toStrictEqual(buffer);
  });
});
