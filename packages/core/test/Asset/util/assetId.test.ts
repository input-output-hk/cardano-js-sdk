import { AssetId } from '../../../src/Cardano';
import { assetIdFromPolicyAndName, assetNameFromAssetId, policyIdFromAssetId } from '../../../src/Asset/util';

describe('Asset', () => {
  describe('util', () => {
    it('policyIdFromAssetId, assetNameFromAssetId and assetIdFromPolicyAndName', async () => {
      const assetId = AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41');
      const [policyId, assetName] = [policyIdFromAssetId(assetId), assetNameFromAssetId(assetId)];

      expect(policyId).toEqual('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82');
      expect(assetName).toEqual('54534c41');
      expect(assetIdFromPolicyAndName(policyId, assetName)).toEqual(assetId);
    });
  });
});
