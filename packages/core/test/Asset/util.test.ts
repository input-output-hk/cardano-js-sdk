import { loadCardanoSerializationLib } from '@cardano-sdk/cardano-serialization-lib';
import { util } from '../../src/Asset';

describe('Asset', () => {
  describe('util', () => {
    it('createAssetSerializer', async () => {
      const CSL = await loadCardanoSerializationLib();
      const serializer = util.createAssetSerializer(CSL);
      const assetId = 'b32_1vk0jj9lmv0cjkvmxw337u467atqcgkauwd4eczaugzagyghp25lTSLA';
      const tsla = serializer.parseId(assetId);
      expect(new TextDecoder().decode(tsla.assetName.name())).toEqual('TSLA');
      expect(tsla.scriptHash.to_bech32('b32_')).toEqual('b32_1vk0jj9lmv0cjkvmxw337u467atqcgkauwd4eczaugzagyghp25l');
      expect(serializer.createId(tsla.scriptHash, tsla.assetName)).toEqual(assetId);
    });
  });
});
