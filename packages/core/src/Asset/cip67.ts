import { AssetName } from '../Cardano/types/Asset';
import { InvalidArgumentError, OpaqueNumber } from '@cardano-sdk/util';
import crc8 from './crc8';

const ASSET_LABEL_LENGTH = 8;
const ASSET_LABEL_BRACKET = '0';

export type AssetNameLabel = OpaqueNumber<'AssetNameLabelNum'>;
export const AssetNameLabel = (value: number): AssetNameLabel => value as AssetNameLabel;

export const AssetNameLabelNum = {
  ReferenceNFT: 100 as AssetNameLabel,
  UserFT: 333 as AssetNameLabel,
  UserNFT: 222 as AssetNameLabel,
  UserRFT: 444 as AssetNameLabel,
  VirtualHandle: 0 as AssetNameLabel
};

export interface DecodedAssetName {
  label: AssetNameLabel;
  content: AssetName;
}

const assertLabelNumInterval = (labelNum: number) => {
  if (labelNum < 0 || labelNum > 65_535) {
    throw new InvalidArgumentError('Label num', `Label ${labelNum} out of range 0 - 65535.`);
  }
};

const checksum = (labelNumHex: string) =>
  crc8(Uint8Array.from(Buffer.from(labelNumHex, 'hex')))
    .toString(16)
    .padStart(2, '0');

const isInvalidChecksum = (labelNumHex: string, labelChecksum: string) => labelChecksum !== checksum(labelNumHex);

const isInvalidLength = (label: string) => label.length !== ASSET_LABEL_LENGTH;

const isInvalidBracket = (lead: string, end: string) => lead !== ASSET_LABEL_BRACKET || end !== ASSET_LABEL_BRACKET;

const assetNameLabelHexToNum = (label: string): AssetNameLabel | null => {
  const labelLeadBracket = label[0];
  const labelEndBracket = label[7];
  const labelNumHex = label.slice(1, 5);
  const labelChecksum = label.slice(5, 7);

  if (
    isInvalidLength(label) ||
    isInvalidBracket(labelLeadBracket, labelEndBracket) ||
    isInvalidChecksum(labelNumHex, labelChecksum)
  ) {
    return null;
  }

  return AssetNameLabel(Number.parseInt(labelNumHex, 16));
};

AssetNameLabel.decode = (assetName: AssetName): DecodedAssetName | null => {
  const assetNameLabel = assetName.slice(0, ASSET_LABEL_LENGTH);
  const assetNameContent = assetName.slice(ASSET_LABEL_LENGTH);
  const assetNameLabelNum = assetNameLabelHexToNum(assetNameLabel);

  if (assetNameLabelNum === null) {
    return null;
  }

  return {
    content: AssetName(assetNameContent),
    label: assetNameLabelNum
  };
};

AssetNameLabel.encode = (assetName: AssetName, labelNum: AssetNameLabel): AssetName => {
  assertLabelNumInterval(labelNum);
  const labelNumHex = labelNum.toString(16).padStart(4, ASSET_LABEL_BRACKET);
  return AssetName(`${ASSET_LABEL_BRACKET}${labelNumHex}${checksum(labelNumHex)}${ASSET_LABEL_BRACKET}${assetName}`);
};
