import { Cardano, util } from '@cardano-sdk/core';

import { TxTokenBuilder } from '../../../src/tx-builder/TokenBuilder';

describe('TxTokenBuilder', () => {
  const policyId: Cardano.PolicyId = Cardano.PolicyId('50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb');
  let builder: TxTokenBuilder;
  const tokenName = 'testToken';

  beforeEach(() => {
    builder = new TxTokenBuilder(policyId);
  });

  it('should initialize with an empty assets map', () => {
    const result: Cardano.TokenMap = builder.build();
    expect(result).toEqual(new Map());
  });

  it('should add an asset to the map based on the policyId and the asset name', () => {
    const quantity = 10n;
    const expectedAssetId = Cardano.AssetId.fromParts(policyId, Cardano.AssetName(util.utf8ToHex(tokenName)));
    builder.addAsset(tokenName, quantity);
    const result: Cardano.TokenMap = builder.build();
    expect(result).toEqual(new Map([[expectedAssetId, quantity]]));
  });

  it('should overwrite an existing asset in the map', () => {
    const quantity1 = 10n;
    const quantity2 = 20n;
    builder.addAsset(tokenName, quantity1);
    builder.addAsset(tokenName, quantity2);
    const result: Cardano.TokenMap = builder.build();
    expect([...result.values()][0]).toEqual(quantity2);
  });
});
