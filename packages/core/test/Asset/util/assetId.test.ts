import { AssetId } from '../../../src/Cardano';
import {
  assetIdFromPolicyAndName,
  assetNameFromAssetId,
  createAssetId,
  parseAssetId,
  policyIdFromAssetId
} from '../../../src/Asset/util';

describe('Asset', () => {
  describe('util', () => {
    it('createAssetId and parseAssetId', async () => {
      const assetId = AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41');
      const tsla = parseAssetId(assetId);
      expect(new TextDecoder().decode(tsla.assetName.name())).toEqual('TSLA');
      expect(Buffer.from(tsla.scriptHash.to_bytes()).toString('hex')).toEqual(
        '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82'
      );
      expect(createAssetId(tsla.scriptHash, tsla.assetName)).toEqual(assetId);
    });
    it('policyIdFromAssetId, assetNameFromAssetId and assetIdFromPolicyAndName', async () => {
      const assetId = AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41');
      const [policyId, assetName] = [policyIdFromAssetId(assetId), assetNameFromAssetId(assetId)];

      expect(policyId).toEqual('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82');
      expect(assetName).toEqual('54534c41');
      expect(assetIdFromPolicyAndName(policyId, assetName)).toEqual(assetId);
    });
  });
});
