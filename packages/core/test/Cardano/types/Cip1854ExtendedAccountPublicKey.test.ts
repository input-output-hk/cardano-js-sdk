import { Bip32PublicKeyHex } from '@cardano-sdk/crypto';
import { Cip1854ExtendedAccountPublicKey } from '../../../src/Cardano';

const bip32PublicKeyPrefix = 'acct_shared_xvk';

describe('Cardano/types/Cip1854ExtendedAccountPublicKey', () => {
  const publicKeyHex = Bip32PublicKeyHex(
    '979693650bb44f26010e9f7b3b550b0602c748d1d00981747bac5c34cf5b945fe01a39317b9b701e58ee16b5ed16aa4444704b98cc997bdd6c5a9502a8b7d70d'
  );

  describe('Cip1854ExtendedAccountPublicKey', () => {
    it('Accepts a valid bech32-encoded CIP1854 public key', () => {
      const bip32PublicKey =
        'acct_shared_xvk1q395kywke7mufrysg33nsm6ggjxswu4g8q8ag7ks9kdyaczchtemd5d2armrfstfa32lamhxfl3sskgcmxm4zdhtvut362796ez4ecqx6vnht';
      expect(Cip1854ExtendedAccountPublicKey(bip32PublicKey)).toEqual(bip32PublicKey);
    });

    it('Throws an error when an invalid bech32-encoded CIP1854 public key is passed', () => {
      expect(() => Cip1854ExtendedAccountPublicKey(publicKeyHex)).toThrow();
      expect(() =>
        Cip1854ExtendedAccountPublicKey(
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        )
      ).toThrow();
      expect(() => Cip1854ExtendedAccountPublicKey('invalid')).toThrow();
    });
  });

  it('fromBip32PublicKeyHex encodes a valid CIP1854 bip32 public key according to CIP5 specification', () => {
    const cip1854PublicKey = Cip1854ExtendedAccountPublicKey.fromBip32PublicKeyHex(publicKeyHex);
    expect(cip1854PublicKey.startsWith(bip32PublicKeyPrefix)).toBe(true);
  });

  it('toBip32PublicKeyHex decodes a bech32-encoded CIP1854 bip32 public key to a hex string', () => {
    const cip1854PublicKey = Cip1854ExtendedAccountPublicKey.fromBip32PublicKeyHex(publicKeyHex);
    const originalHex = Cip1854ExtendedAccountPublicKey.toBip32PublicKeyHex(cip1854PublicKey);
    expect(originalHex).toEqual(publicKeyHex);
  });
});
