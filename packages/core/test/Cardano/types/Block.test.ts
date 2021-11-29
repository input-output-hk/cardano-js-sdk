import { BlockId, VrfVkBech32 } from '../../../src/Cardano';

describe('Cardano/types/Block', () => {
  it('BlockId() accepts a valid transaction hash', () => {
    expect(() => BlockId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed')).not.toThrow();
  });

  it('VrfVkBech32() accepts a valid vrf verification key bech32 string with vrf_vk or poolmd_vk prefix', () => {
    expect(() => VrfVkBech32('vrf_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4s99zvg8')).not.toThrow();
    expect(() => VrfVkBech32('poolmd_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4stmm43m')).not.toThrow();
  });
});
