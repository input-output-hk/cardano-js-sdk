import { Asset } from '../../src/index.js';
import { AssetName } from '../../src/Cardano/index.js';
import { InvalidArgumentError } from '@cardano-sdk/util';

const cases: [Asset.AssetNameLabel, string][] = [
  [0 as Asset.AssetNameLabel, '00000000'],
  [1 as Asset.AssetNameLabel, '00001070'],
  [23 as Asset.AssetNameLabel, '00017650'],
  [99 as Asset.AssetNameLabel, '000632e0'],
  [533 as Asset.AssetNameLabel, '00215410'],
  [2000 as Asset.AssetNameLabel, '007d0550'],
  [4567 as Asset.AssetNameLabel, '011d7690'],
  [11_111 as Asset.AssetNameLabel, '02b670b0'],
  [49_328 as Asset.AssetNameLabel, '0c0b0f40'],
  [65_535 as Asset.AssetNameLabel, '0ffff240']
];

describe('Cardano.Asset.cip67', () => {
  test('asset label is null for asset without label', () => {
    const assetName = AssetName('4172b2ed');

    expect(Asset.AssetNameLabel.decode(assetName)).toBe(null);
  });
  test.each(cases)('decode asset label %p from assetId', (assetLabelNum, assetLabel) => {
    const assetName = AssetName(`${assetLabel}4172b2ed`);

    expect(Asset.AssetNameLabel.decode(assetName)).toEqual({
      content: AssetName('4172b2ed'),
      label: assetLabelNum
    });
  });
  test.each(cases)('encode asset label %p with assetName', (assetLabelNum, assetLabel) => {
    const assetName = AssetName('4172b2ed');

    expect(Asset.AssetNameLabel.encode(assetName, assetLabelNum)).toEqual(AssetName(`${assetLabel}${assetName}`));
  });
  test('encode asset label with out of range label number throws an error', () => {
    const assetName = AssetName('4172b2ed');

    expect(() => Asset.AssetNameLabel.encode(assetName, Asset.AssetNameLabel(65_536))).toThrow(InvalidArgumentError);
  });
});
