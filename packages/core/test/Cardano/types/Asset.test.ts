import { AssetFingerprint, AssetId, AssetName, PolicyId } from '../../../src/Cardano';

describe('Cardano/types/Asset', () => {
  it('AssetId() accepts a valid asset id', () => {
    expect(() => AssetId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed')).not.toThrow();
  });
  it('PolicyId() accepts a valid policy id', () => {
    expect(() => PolicyId('1e349c9bdea19fd6c147626a5260bc44b71635f398b67c59881df209')).not.toThrow();
  });
  it('AssetName() accepts a valid asset name', () => {
    expect(() => AssetName('1e349c9bdea19fd')).not.toThrow();
  });
  it('AssetFingerprint() accepts a valid asset fingerprint', () => {
    expect(() => AssetFingerprint('asset13n25uv0yaf5kus35fm2k86cqy60z58d9xmde92')).not.toThrow();
  });
});
