import { BlockId, SlotLeader, VrfVkBech32 } from '../../../src/Cardano/index.js';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { InvalidStringError, typedBech32 } from '@cardano-sdk/util';

jest.mock('@cardano-sdk/util', () => {
  const actual = jest.requireActual('@cardano-sdk/util');
  return {
    ...actual,
    typedBech32: jest.fn().mockImplementation((...args) => actual.typedBech32(...args))
  };
});

jest.mock('@cardano-sdk/crypto', () => {
  const actual = jest.requireActual('@cardano-sdk/crypto');
  return {
    ...actual,
    Hash28ByteBase16: jest.fn().mockImplementation((...args) => actual.Hash28ByteBase16(...args)),
    Hash32ByteBase16: jest.fn().mockImplementation((...args) => actual.Hash32ByteBase16(...args))
  };
});

describe('Cardano/types/Block', () => {
  it('BlockId() accepts a valid transaction hash and is implemented using Hash32ByteBase16', () => {
    expect(() => BlockId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed')).not.toThrow();
    expect(Hash32ByteBase16).toBeCalledWith('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed');
  });

  it('VrfVkBech32() accepts a valid vrf vkey bech32 string and is implemented using typedBech32', () => {
    expect(() => VrfVkBech32('vrf_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4s99zvg8')).not.toThrow();
    expect(typedBech32).toBeCalledWith(
      'vrf_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4s99zvg8',
      'vrf_vk',
      52
    );
  });

  describe('SlotLeader()', () => {
    it('accepts a valid PoolId and is implemented using typedBech32', () => {
      expect(() => SlotLeader('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh')).not.toThrow();
    });
    it('accepts a valid Shelley genesis delegate', () => {
      expect(() => SlotLeader('eff1b5b26e65b791d6f236c7c0264012bd1696759d22bdb4dd0f6f56')).not.toThrow();
    });
    it('accepts a valid Shelley genesis in prefix format', () => {
      expect(() => SlotLeader('ShelleyGenesis-eff1b5b26e65b791')).not.toThrow();
    });
    it('throws for any other strings', () => {
      expect(() => SlotLeader('ShelleyGenesis-eff1b5b26e65b79')).toThrowError(InvalidStringError);
    });
  });
});
