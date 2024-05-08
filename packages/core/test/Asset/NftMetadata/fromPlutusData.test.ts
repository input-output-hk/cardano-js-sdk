import { Asset, Cardano, Serialization } from '../../../src';
import { HexBlob } from '@cardano-sdk/util';
import { dummyLogger } from 'ts-log';
import { utf8ToBytes } from '../../../src/util/misc';

const logger = dummyLogger;

const metadatumToPlutusData = (metadatum: Cardano.Metadatum): Cardano.PlutusData => {
  switch (typeof metadatum) {
    case 'bigint':
      return metadatum;
    case 'string':
      return Buffer.from(metadatum, 'utf8');
    default: {
      if (Array.isArray(metadatum)) {
        return {
          items: metadatum.map(metadatumToPlutusData)
        };
      } else if (ArrayBuffer.isView(metadatum)) {
        return metadatum;
      }
      return {
        data: new Map(
          [...metadatum.entries()].map(([key, value]) => [metadatumToPlutusData(key), metadatumToPlutusData(value)])
        )
      };
    }
  }
};

const createOtherPropertiesPlutusData = (
  otherProperties?: Map<string, Cardano.Metadatum>
): Array<[Uint8Array, Cardano.PlutusData]> => {
  if (!otherProperties) return [];
  return [...otherProperties.entries()].map(([key, value]) => [Buffer.from(key, 'utf8'), metadatumToPlutusData(value)]);
};

const createPlutusMap = (utf8Pairs: [string, string][], otherProperties?: Map<string, Cardano.Metadatum>) =>
  new Map<Uint8Array, Cardano.PlutusData>([
    ...utf8Pairs.map(([key, value]) => [utf8ToBytes(key), utf8ToBytes(value)] as const),
    ...createOtherPropertiesPlutusData(otherProperties)
  ]);

const stringKeyValueTupleIfExists = <T extends object>(nftMetadata: T, key: string): [string, string][] =>
  key in nftMetadata ? [[key, nftMetadata[key as keyof T] as string]] : [];

const createFilesPlutusData = (files: Array<Partial<Asset.NftMetadataFile>>): Cardano.PlutusList => ({
  items: files.map((file) => ({
    data: createPlutusMap(
      [
        ...stringKeyValueTupleIfExists(file, 'src'),
        ...stringKeyValueTupleIfExists(file, 'mediaType'),
        ...stringKeyValueTupleIfExists(file, 'name')
      ],
      file.otherProperties
    )
  }))
});

const createPlutusData = (
  nftMetadata: Partial<Omit<Asset.NftMetadata, 'files'>>,
  files?: Partial<Asset.NftMetadataFile>[],
  constructor = 0n
): Cardano.ConstrPlutusData => ({
  constructor,
  fields: {
    items: [
      {
        data: new Map<Cardano.PlutusData, Cardano.PlutusData>([
          ...createPlutusMap(
            [
              ...stringKeyValueTupleIfExists(nftMetadata, 'name'),
              ...stringKeyValueTupleIfExists(nftMetadata, 'image'),
              ...stringKeyValueTupleIfExists(nftMetadata, 'description'),
              ...stringKeyValueTupleIfExists(nftMetadata, 'mediaType')
            ],
            nftMetadata.otherProperties
          ).entries(),
          ...(files ? [[utf8ToBytes('files'), createFilesPlutusData(files)] as const] : [])
        ])
      },
      ...(nftMetadata.version ? [BigInt(nftMetadata.version), { constructor: 0n, fields: { items: [] } }] : []),
      { constructor: 0n, items: [] }
    ]
  }
});

describe('NftMetadata.fromPlutusData', () => {
  const mediaType = Asset.MediaType('image/jpeg');
  const assetName = 'CIP0025-v2';
  const assetImageIPFS = Asset.Uri('ipfs://QmWS6DgF8Ma8oooBn7CtD3ChHyzzMw5NXWfnDbVFTip8af');
  const assetImageHTTPS = Asset.Uri('https://tokens.cardano.org');

  const minimalCoreMetadata: Asset.NftMetadata = {
    image: assetImageHTTPS,
    name: assetName,
    version: '1'
  };
  const minimalPlutusMetadata = createPlutusData(minimalCoreMetadata);

  describe('invalid metadata on optional fields', () => {
    it('omits files with a missing file media type', () => {
      const plutusData = createPlutusData(
        {
          ...minimalCoreMetadata
        },
        [
          {
            src: assetImageHTTPS
          },
          {
            mediaType,
            src: assetImageIPFS
          }
        ]
      );
      const result = Asset.NftMetadata.fromPlutusData(plutusData, logger);
      expect(result).toBeTruthy();
      expect(result!.files).toHaveLength(1);
    });

    it('omits files with a missing file source', () => {
      const plutusData = createPlutusData(minimalCoreMetadata, [
        {
          mediaType
        },
        {
          mediaType,
          src: assetImageHTTPS
        }
      ]);

      const result = Asset.NftMetadata.fromPlutusData(plutusData, logger);
      expect(result).toBeTruthy();
      expect(result!.files).toHaveLength(1);
    });
  });

  it('returns null for non-cip68 plutusData', () => {
    const plutusData: Cardano.PlutusData = {
      data: new Map<Cardano.PlutusData, Cardano.PlutusData>()
    };
    expect(Asset.NftMetadata.fromPlutusData(plutusData, logger)).toBeNull();
  });

  it('returns null for cip68 plutusData with invalid image format', () => {
    const plutusData = createPlutusData({
      ...minimalCoreMetadata,
      image: 'http/tokens.cardano.org' as Asset.Uri
    });
    expect(Asset.NftMetadata.fromPlutusData(plutusData, logger)).toBeNull();
  });

  it('converts minimal metadata', () => {
    expect(Asset.NftMetadata.fromPlutusData(minimalPlutusMetadata, logger)).toEqual(minimalCoreMetadata);
  });

  it('supports base64 decoded image following data URL scheme standard', () => {
    const base64DecodedImage =
      'data:image/png;base64,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';

    const plutusData = createPlutusData({
      ...minimalCoreMetadata,
      image: base64DecodedImage as Asset.Uri
    });
    const result = Asset.NftMetadata.fromPlutusData(plutusData, logger);
    expect(result?.image).toEqual(base64DecodedImage);
  });

  it('coverts optional properties (mediaType, description and <other properties>)', () => {
    const nftMetadata = {
      ...minimalCoreMetadata,
      description: 'some description',
      mediaType: Asset.ImageMediaType('image/png'),
      otherProperties: new Map<string, Cardano.Metadatum>([['extraProp', 'extra']])
    };
    const plutusData = createPlutusData(nftMetadata);
    expect(Asset.NftMetadata.fromPlutusData(plutusData, logger)).toEqual(nftMetadata);
  });

  it('coverts files', () => {
    const base64FileSrc =
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAlYAAAJWCAYAAACapc' +
      'kfAAAMF0lEQVR4nO3YMWtedRiHYZVDnTs4dMg3UDo1Qyeh0G7FvUuGElBwk9IUCp' +
      'maUjo7lCLi7FAcBDN1cusQcHRyqKNdnfQDuJTX++RJ3ve6PsCfH4cz3DwffvnD6T' +
      '8fAADwv300PQAAYFsIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAI' +
      'gIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKw' +
      'CAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiL' +
      'ACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAI' +
      'gIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKw' +
      'CAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiL' +
      'ACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAI' +
      'gIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKw' +
      'CAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiL' +
      'ACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAI' +
      'gIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKw' +
      'CAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiL' +
      'ACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAI' +
      'gs0wPgr5+/m55A5MaNG9MT2HG/f/LZ9AR2nIsVAEBEWAEARIQVAEBEWAEARIQVAE' +
      'BEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWA' +
      'EARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARI' +
      'QVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAE' +
      'BEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBkmR4A/NezW/vTEz' +
      'ayt783PYEd99XZ9AJ2nYsVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWA' +
      'EARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARI' +
      'QVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAE' +
      'BEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWA' +
      'EARIQVAEBEWAEARIQVAEBEWAEARIQVAEBkmR4Az27tT0/YKXv7e9MTALaWixUAQE' +
      'RYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQ' +
      'BEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBElu' +
      'kBwPk6vP90esKF8+Llw+kJwJZwsQIAiAgrAICIsAIAiAgrAICIsAIAiAgrAICIsA' +
      'IAiAgrAICIsAIAiAgrAICIsAIAiAgrAICIsAIAiAgrAICIsAIAiAgrAICIsAIAiA' +
      'grAICIsAIAiAgrAICIsAIAiAgrAIDIMj0AOF+PD++t9vYXz05We/vVg6PV3j68/3' +
      'S1t1+8fLja22ta85usafl6vX8Q3oeLFQBARFgBAESEFQBARFgBAESEFQBARFgBAE' +
      'SEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQ' +
      'BARFgBAESEFQBARFgBAESEFQBARFgBAESW6QHA9nj14Gh6wkYeH96bnnDhvHn3x2' +
      'pvr/mfnKz2MrwfFysAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICC' +
      'sAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgI' +
      'iwAgCICCsAgIiwAgCILNMDgO2xt783PYHImx+/nZ6wmbPpAew6FysAgIiwAgCICC' +
      'sAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgI' +
      'iwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCILNMD4OTjT6' +
      'cnbOTo79+mJwBwwbhYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQE' +
      'RYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQ' +
      'BEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhB' +
      'UAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQE' +
      'RYAQBEhBUAQERYAQBEhBUAQERYAQBElukBAFw8f/7062pvX7t7c7W3YZqLFQBARF' +
      'gBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAE' +
      'SEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESW6Q' +
      'EAXDzX7t6cngCXkosVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARI' +
      'QVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAE' +
      'BEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWA' +
      'EARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARI' +
      'QVAEBEWAEARIQVAEBEWAEARIQVAEBkmR4Al9Wdk+fTEzbyy9E30xMAtpaLFQBARF' +
      'gBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAE' +
      'SEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESW6Q' +
      'HA+bpz8nx6ApfA58ffT0+AS8nFCgAgIqwAACLCCgAgIqwAACLCCgAgIqwAACLCCg' +
      'AgIqwAACLCCgAgIqwAACLCCgAgIqwAACLCCgAgIqwAACLCCgAgIqwAACLCCgAgIq' +
      'wAACLCCgAgIqwAACLCCgAgIqwAACLL9ABge1y98nZ6AsAoFysAgIiwAgCICCsAgI' +
      'iwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAg' +
      'CICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCILNMD4PXxwfQEAE' +
      'i4WAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWA' +
      'EARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARI' +
      'QVAEBkmR5A5/XxwfQEIlevvJ2ewI47e3J7esJGrj86nZ7AjnOxAgCICCsAgIiwAg' +
      'CICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICC' +
      'sAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgMgyPeAien18MD' +
      '2ByNUrb6cnAOfo7Mnt6Qkbuf7odHoCERcrAICIsAIAiAgrAICIsAIAiAgrAICIsA' +
      'IAiAgrAICIsAIAiAgrAICIsAIAiAgrAICIsAIAiAgrAICIsAIAiAgrAICIsAIAiA' +
      'grAICIsAIAiAgrAICIsAIAiAgrAICIsAIAiPwLOiNBXRuPIIgAAAAASUVORK5CYI' +
      'I=';

    const files: Asset.NftMetadataFile[] = [
      { mediaType, name: 'file1', src: Asset.Uri('https://file1.location') },
      {
        mediaType: Asset.MediaType('image/png'),
        name: 'file2',
        otherProperties: new Map([['custom', 'prop']]),
        src: Asset.Uri('ipfs://file2.location')
      },
      { mediaType, name: 'file3', src: Asset.Uri(base64FileSrc) }
    ];

    const plutusData = createPlutusData(minimalCoreMetadata, files);

    expect(Asset.NftMetadata.fromPlutusData(plutusData, logger)).toEqual({
      ...minimalCoreMetadata,
      files
    });
  });

  it('ignores non-0 constructor', () => {
    expect(Asset.NftMetadata.fromPlutusData(createPlutusData(minimalCoreMetadata, [], 1n), logger)).toBeNull();
  });

  it('can convert AdaHandle datum', () => {
    const nftMetadataDatum = HexBlob(
      'd8799faa446e616d654724736e656b363945696d6167655838697066733a2f2f7a6232726861476b726d32675143333636535a626254516d6a446433666a64343466744848344c34547441427970534b61496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d626572004672617269747946636f6d6d6f6e466c656e677468064a636861726163746572734f6c6574746572732c6e756d62657273516e756d657269635f6d6f64696669657273404776657273696f6e0101a84e7374616e646172645f696d6167655838697066733a2f2f7a6232726861476b726d32675143333636535a626254516d6a446433666a64343466744848344c34547441427970534b6146706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f616464726573735839003382fe4bf2249a8fb53df0b64aba1c78c95f117a7d57c59d9869b341389caccf78b5f141efbd97de910777674368d8ffedbb3fdc797028384c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1ff'
    );

    const datum = Serialization.Datum.newInlineData(
      Serialization.PlutusData.fromCbor(nftMetadataDatum)
    ).toCore() as Cardano.PlutusData;

    const nftMetadata = Asset.NftMetadata.fromPlutusData(datum, logger)!;
    expect(nftMetadata.description).toBeUndefined();
    expect(typeof nftMetadata.image).toBe('string');
    expect(typeof nftMetadata.mediaType).toBe('string');
    expect(typeof nftMetadata.name).toBe('string');
    expect(typeof nftMetadata.version).toBe('string');
    expect(typeof nftMetadata.otherProperties?.get('og')).toBe('bigint');
    expect(nftMetadata.files).toBeUndefined();
  });

  it('can convert NMKR datum', () => {
    const nmkrDatum = HexBlob(
      'd8799fa5446e616d654b6e6d6b724e4654386d617945696d6167655835697066733a2f2f516d4e77566157314b655471424a4b4b6963355553443165424c41315a48396b596b455674535952423646314d64496d656469615479706549696d6167652f706e674b6465736372697074696f6e404566696c65739fa3496d656469615479706549696d6167652f706e67446e616d654b6e6d6b724e4654386d6179437372635835697066733a2f2f516d4e77566157314b655471424a4b4b6963355553443165424c41315a48396b596b455674535952423646314d64ff01ff'
    );
    const datum = Serialization.Datum.newInlineData(
      Serialization.PlutusData.fromCbor(nmkrDatum)
    ).toCore() as Cardano.PlutusData;

    const nftMetadata = Asset.NftMetadata.fromPlutusData(datum, logger)!;

    expect(nftMetadata).toMatchObject({
      name: 'nmkrNFT8may'
    });
  });
});
