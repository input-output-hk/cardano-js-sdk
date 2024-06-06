import { asMetadatumArray, asMetadatumMap, jsonToMetadatum, metadatumToJson } from '../../src/util/metadatum.js';
import type { Metadatum } from '../../src/Cardano/types/AuxiliaryData.js';

const nestedJson = {
  '0000000000000000000000000000000000000000000000000000000000000000': {
    'NFT-001': {
      image: ['ipfs://some_hash1'],
      name: 'One',
      version: '1.0'
    },
    'NFT-002': {
      image: ['ipfs://some_hash2'],
      name: 'Two',
      version: '1.0'
    },
    'NFT-files': {
      description: ['NFT with different types of files'],
      files: [
        {
          mediaType: 'video/mp4',
          name: 'some name',
          src: 'ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5'
        },
        {
          mediaType: 'audio/mpeg',
          name: 'some name',
          src: ['ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2', 'BU2dLjfWxuJoF2Ny']
        }
      ],
      id: '1',
      image: ['ipfs://somehash'],
      mediaType: 'image/png',
      name: 'NFT with files',
      version: '1.0'
    }
  }
};

const nestedMetadatum: Metadatum = new Map([
  [
    '0000000000000000000000000000000000000000000000000000000000000000',
    new Map<Metadatum, Metadatum>([
      [
        'NFT-001',
        new Map<Metadatum, Metadatum>([
          ['image', ['ipfs://some_hash1']],
          ['name', 'One'],
          ['version', '1.0']
        ])
      ],
      [
        'NFT-002',
        new Map<Metadatum, Metadatum>([
          ['image', ['ipfs://some_hash2']],
          ['name', 'Two'],
          ['version', '1.0']
        ])
      ],
      [
        'NFT-files',
        new Map<Metadatum, Metadatum>([
          ['description', ['NFT with different types of files']],
          [
            'files',
            [
              new Map<Metadatum, Metadatum>([
                ['mediaType', 'video/mp4'],
                ['name', 'some name'],
                ['src', 'ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5']
              ]),
              new Map<Metadatum, Metadatum>([
                ['mediaType', 'audio/mpeg'],
                ['name', 'some name'],
                ['src', ['ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2', 'BU2dLjfWxuJoF2Ny']]
              ])
            ]
          ],
          ['id', '1'],
          ['image', ['ipfs://somehash']],
          ['mediaType', 'image/png'],
          ['name', 'NFT with files'],
          ['version', '1.0']
        ])
      ]
    ])
  ]
]);

describe('util.metadatum', () => {
  describe('asMetadatumMap', () => {
    it('returns argument if it is a MetadatumMap', () => {
      const metadatum: Metadatum = new Map([['some', 'metadatum']]);
      expect(asMetadatumMap(metadatum)).toBe(metadatum);
    });

    it('returns null for any other metadatum type', () => {
      const metadatum: Metadatum = [new Map([['some', 'metadatum']])];
      expect(asMetadatumMap(metadatum)).toBeNull();
    });
  });

  describe('asMetadatumArray', () => {
    it('returns argument if it is Metadatum[]', () => {
      const metadatum: Metadatum = [new Map([['some', 'metadatum']])];
      expect(asMetadatumArray(metadatum)).toBe(metadatum);
    });

    it('returns null for any other metadatum type', () => {
      const metadatum: Metadatum = new Map([['some', 'metadatum']]);
      expect(asMetadatumArray(metadatum)).toBeNull();
    });
  });

  describe('jsonToMetadatum', () => {
    it('returns the json object from a metadatum object', () => {
      const json = {
        field1: '1',
        field2: '2',
        field3: '3'
      };
      const metadatum: Metadatum = new Map([
        ['field1', '1'],
        ['field2', '2'],
        ['field3', '3']
      ]);

      expect(jsonToMetadatum(json)).toMatchObject(metadatum);
    });

    it('returns the json object from a nested metadatum object', () => {
      expect(jsonToMetadatum(nestedJson)).toMatchObject(nestedMetadatum);
    });
  });

  describe('metadatumToJson', () => {
    it('returns the metadatum object from a json object', () => {
      const json = {
        field1: '1',
        field2: '2',
        field3: '3'
      };
      const metadatum: Metadatum = new Map([
        ['field1', '1'],
        ['field2', '2'],
        ['field3', '3']
      ]);

      expect(metadatumToJson(metadatum)).toMatchObject(json);
    });

    it('returns the metadatum object from a nexted json object', () => {
      expect(metadatumToJson(nestedMetadatum)).toMatchObject(nestedJson);
    });
  });
});
