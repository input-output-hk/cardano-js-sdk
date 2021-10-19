import { createAssetId, parseAssetId } from '../../src/Asset/util';

describe('Asset', () => {
  describe('util', () => {
    it('createAssetId and parseAssetId', async () => {
      const assetId = '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41';
      const tsla = parseAssetId(assetId);
      expect(new TextDecoder().decode(tsla.assetName.name())).toEqual('TSLA');
      expect(Buffer.from(tsla.scriptHash.to_bytes()).toString('hex')).toEqual(
        '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82'
      );
      expect(createAssetId(tsla.scriptHash, tsla.assetName)).toEqual(assetId);
    });
  });
});
