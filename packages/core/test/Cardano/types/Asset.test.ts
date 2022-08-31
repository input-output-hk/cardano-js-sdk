import { AssetFingerprint, AssetId, AssetName, PolicyId, util } from '../../../src/Cardano';

jest.mock('../../../src/Cardano/util/primitives', () => {
  const actual = jest.requireActual('../../../src/Cardano/util/primitives');
  return {
    Hash28ByteBase16: jest.fn().mockImplementation((...args) => actual.Hash28ByteBase16(...args)),
    assertIsHexString: jest.fn().mockImplementation((...args) => actual.assertIsHexString(...args)),
    typedBech32: jest.fn().mockImplementation((...args) => actual.typedBech32(...args))
  };
});

describe('Cardano/types/Asset', () => {
  describe('AssetId', () => {
    it('accepts a valid asset id and is implemented using util.assetIsHexString', () => {
      expect(() => AssetId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed')).not.toThrow();
      expect(util.assertIsHexString).toBeCalledWith('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed');
    });

    it('does not accept a hex string < 56 chars', () => {
      expect(() => AssetId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5e')).toThrow();
    });

    it('does not accept a hex string > 120 chars', () => {
      expect(() =>
        AssetId(
          // eslint-disable-next-line max-len
          '0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5e0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5e92b3034f46b'
        )
      ).toThrow();
    });
  });

  it('PolicyId() accepts a valid policy id and is implemented using util.Hash28ByteBase16', () => {
    expect(() => PolicyId('1e349c9bdea19fd6c147626a5260bc44b71635f398b67c59881df209')).not.toThrow();
    expect(util.Hash28ByteBase16).toBeCalledWith('1e349c9bdea19fd6c147626a5260bc44b71635f398b67c59881df209');
  });

  describe('AssetName', () => {
    it('accepts a valid asset name and is implemented using util.assertIsHexString', () => {
      expect(() => AssetName('1e349c9bdea19fd')).not.toThrow();
      expect(util.assertIsHexString).toBeCalledWith('1e349c9bdea19fd');
    });

    it('accepts an empty string', () => {
      expect(() => AssetName('')).not.toThrow();
    });

    it('does not accept a hex string > 64 chars', () => {
      expect(() => AssetName('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5e0dbe461abc')).toThrow();
    });
  });

  describe('AssetFingerprint', () => {
    it('accepts a valid asset fingerprint and is implemented using util.typedBech32', () => {
      expect(() => AssetFingerprint('asset13n25uv0yaf5kus35fm2k86cqy60z58d9xmde92')).not.toThrow();
      expect(util.typedBech32).toBeCalledWith('asset13n25uv0yaf5kus35fm2k86cqy60z58d9xmde92', 'asset', 32);
    });

    it('can be build from the policy id and asset name', async () => {
      const policyId = PolicyId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82');
      const assetName = AssetName('54534c41');
      expect(AssetFingerprint.fromParts(policyId, assetName)).toEqual('asset1rqluyux4nxv6kjashz626c8usp8g88unmqwnyh');
    });
  });
});
