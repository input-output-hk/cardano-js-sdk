import { AssetId } from '../../../src/Cardano';
import { getAssetNameAsText } from '../../../src/Asset/util';

describe('getAssetNameAsText', () => {
  it('can get the asset name component as text from the asset id with non encoded name', () => {
    const assetId = AssetId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a736b7977616c6b6572');
    expect(getAssetNameAsText(assetId)).toEqual('skywalker');
  });

  it('can get the asset name component as text from the asset id with cip 67 encoded name', () => {
    const assetId = AssetId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a000de140736b7977616c6b6572');
    expect(getAssetNameAsText(assetId)).toEqual('skywalker');
  });
});
