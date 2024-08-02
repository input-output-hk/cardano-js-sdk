import { AssetFingerprint, AssetId, AssetName, PolicyId } from '../../../src/Cardano';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { InvalidStringError, assertIsHexString, typedBech32 } from '@cardano-sdk/util';

jest.mock('@cardano-sdk/util', () => {
  const actual = jest.requireActual('@cardano-sdk/util');
  return {
    ...actual,
    assertIsHexString: jest.fn().mockImplementation((...args) => actual.assertIsHexString(...args)),
    typedBech32: jest.fn().mockImplementation((...args) => actual.typedBech32(...args))
  };
});

jest.mock('@cardano-sdk/crypto', () => {
  const actual = jest.requireActual('@cardano-sdk/crypto');
  return {
    ...actual,
    Hash28ByteBase16: jest.fn().mockImplementation((...args) => actual.Hash28ByteBase16(...args))
  };
});

const createFingerprint = (policyId: string, assetName: string): string =>
  AssetFingerprint.fromParts(PolicyId(policyId), AssetName(assetName));

describe('Cardano/types/Asset', () => {
  describe('AssetId', () => {
    describe('getPolicyId', () => {
      it('can get the policy ID component from the asset id', () => {
        const asstId = AssetId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed');

        expect(AssetId.getPolicyId(asstId)).toEqual('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea');
      });
    });

    describe('getAssetName', () => {
      it('can get the asset name component from the asset id', () => {
        const asstId = AssetId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed');

        expect(AssetId.getAssetName(asstId)).toEqual('4172b2ed');
      });
    });

    describe('fromParts', () => {
      it('can get the asset name component from the asset id', () => {
        const asstId = AssetId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed');

        expect(
          AssetId.fromParts(PolicyId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea'), AssetName('4172b2ed'))
        ).toEqual(asstId);
      });
    });

    it('accepts a valid asset id and is implemented using util.assetIsHexString', () => {
      expect(() => AssetId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed')).not.toThrow();
      expect(assertIsHexString).toBeCalledWith('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed');
    });

    it('accepts asset id where policy id and asset name are separated with a dot', () => {
      expect(AssetId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea.4172b2ed')).toEqual(
        '0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed'
      );
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
    expect(Hash28ByteBase16).toBeCalledWith('1e349c9bdea19fd6c147626a5260bc44b71635f398b67c59881df209');
  });

  describe('AssetName', () => {
    it('accepts a valid asset name and is implemented using util.assertIsHexString', () => {
      expect(() => AssetName('1e349c9bdea19fd')).not.toThrow();
      expect(assertIsHexString).toBeCalledWith('1e349c9bdea19fd');
    });

    it('accepts an empty string', () => {
      expect(() => AssetName('')).not.toThrow();
    });

    it('does not accept a hex string > 64 chars', () => {
      expect(() => AssetName('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5e0dbe461abc')).toThrow();
    });

    describe('toUTF8', () => {
      it('decodes hex string (bytes) to utf8 string', () => {
        expect(AssetName.toUTF8(AssetName('737472'))).toEqual('str');
      });
      it('throws InvalidStringError when it cannot be decoded to utf8', () => {
        expect(() => AssetName.toUTF8(AssetName('e8'))).toThrowError(InvalidStringError);
      });
      it('strips invisible characters when requested', () => {
        expect(AssetName.toUTF8(AssetName('100000'), true)).toEqual('');
      });
    });
  });

  describe('AssetFingerprint', () => {
    it('accepts a valid asset fingerprint and is implemented using util.typedBech32', () => {
      expect(() => AssetFingerprint('asset13n25uv0yaf5kus35fm2k86cqy60z58d9xmde92')).not.toThrow();
      expect(typedBech32).toBeCalledWith('asset13n25uv0yaf5kus35fm2k86cqy60z58d9xmde92', 'asset', 32);
    });

    it('creates expected fingerprint from cip14 test vectors', async () => {
      expect(createFingerprint('7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373', '')).toEqual(
        'asset1rjklcrnsdzqp65wjgrg55sy9723kw09mlgvlc3'
      );

      expect(createFingerprint('7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc37e', '')).toEqual(
        'asset1nl0puwxmhas8fawxp8nx4e2q3wekg969n2auw3'
      );

      expect(createFingerprint('1e349c9bdea19fd6c147626a5260bc44b71635f398b67c59881df209', '')).toEqual(
        'asset1uyuxku60yqe57nusqzjx38aan3f2wq6s93f6ea'
      );

      expect(createFingerprint('7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373', '504154415445')).toEqual(
        'asset13n25uv0yaf5kus35fm2k86cqy60z58d9xmde92'
      );

      expect(createFingerprint('1e349c9bdea19fd6c147626a5260bc44b71635f398b67c59881df209', '504154415445')).toEqual(
        'asset1hv4p5tv2a837mzqrst04d0dcptdjmluqvdx9k3'
      );

      expect(
        createFingerprint(
          '1e349c9bdea19fd6c147626a5260bc44b71635f398b67c59881df209',
          '7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373'
        )
      ).toEqual('asset1aqrdypg669jgazruv5ah07nuyqe0wxjhe2el6f');

      expect(
        createFingerprint(
          '7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373',
          '1e349c9bdea19fd6c147626a5260bc44b71635f398b67c59881df209'
        )
      ).toEqual('asset17jd78wukhtrnmjh3fngzasxm8rck0l2r4hhyyt');

      expect(
        createFingerprint(
          '7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373',
          '0000000000000000000000000000000000000000000000000000000000000000'
        )
      ).toEqual('asset1pkpwyknlvul7az0xx8czhl60pyel45rpje4z8w');
    });
  });
});
