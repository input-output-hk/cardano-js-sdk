import { createPbkdf2Key, emip3decrypt, emip3encrypt } from '../src/index.js';
import { util } from '@cardano-sdk/core';

describe('emip3', () => {
  it('decrypting encrypted value results in original unencrypted value', async () => {
    const unencryptedHex = '123abc';
    const passphrase = Buffer.from('password');
    const encrypted = await emip3encrypt(Buffer.from(unencryptedHex, 'hex'), passphrase);
    expect(util.bytesToHex(encrypted)).not.toEqual(unencryptedHex);
    const decrypted = await emip3decrypt(encrypted, passphrase);
    expect(util.bytesToHex(decrypted!)).toEqual(unencryptedHex);
  });

  it('createPbkdf2Key implementation is aligned with Rust cryptoxide', async () => {
    const passphrase = Buffer.from('Cardano Rust for the winners!', 'utf-8');
    const salt = new Uint8Array([
      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1
    ]);
    const rustKey = '200a09ed78c49e029a3a47e759e6eb4f4da7eac47421b0c0959aed2b9af2a6aa';
    const key = await createPbkdf2Key(passphrase, salt);
    expect(util.bytesToHex(key)).toEqual(rustKey);
  });
});
