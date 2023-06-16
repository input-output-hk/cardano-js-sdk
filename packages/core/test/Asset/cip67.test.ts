import { Asset } from '../../src';
import { AssetName } from '../../src/Cardano';
import { InvalidArgumentError } from '@cardano-sdk/util';

const cases: [number, string][] = [
  [0, '00000000'],
  [1, '00001070'],
  [23, '00017650'],
  [99, '000632e0'],
  [533, '00215410'],
  [2000, '007d0550'],
  [4567, '011d7690'],
  [11_111, '02b670b0'],
  [49_328, '0c0b0f40'],
  [65_535, '0ffff240']
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
