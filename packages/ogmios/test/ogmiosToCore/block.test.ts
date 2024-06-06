import { Cardano } from '@cardano-sdk/core';
import { ogmiosToCore } from '../../src/index.js';

import {
  mockAllegraBlock,
  mockAlonzoBlock,
  mockBabbageBlock,
  mockBabbageBlockWithNftMetadata,
  mockByronBlock,
  mockMaryBlock,
  mockShelleyBlock
} from './testData.js';

describe('ogmiosToCore', () => {
  describe('blockHeader', () => {
    it('can translate from byron block', () => {
      expect(ogmiosToCore.blockHeader(mockByronBlock)).toEqual(<Cardano.PartialBlockHeader>{
        blockNo: Cardano.BlockNo(42),
        hash: Cardano.BlockId('5c3103bd0ff5ea85a62b202a1d2500cf3ebe0b9d793ed09e7febfe27ef12c968'),
        slot: Cardano.Slot(77_761)
      });
    });
    it('can translate from common block', () => {
      expect(ogmiosToCore.blockHeader(mockShelleyBlock)).toEqual(<Cardano.PartialBlockHeader>{
        blockNo: Cardano.BlockNo(1087),
        hash: Cardano.BlockId('071fceb6c20a412b9a9b57baedfe294e3cd9de641cd44c4cf8d0d56217e083ac'),
        slot: Cardano.Slot(107_220)
      });
    });
  });

  describe('block', () => {
    it('can translate from byron block', () => {
      expect(ogmiosToCore.block(mockByronBlock)).toMatchSnapshot();
    });

    it('can translate from shelley block', () => {
      expect(ogmiosToCore.block(mockShelleyBlock)).toMatchSnapshot();
    });

    it('can translate from allegra block', () => {
      expect(ogmiosToCore.block(mockAllegraBlock)).toMatchSnapshot();
    });

    it('can translate from mary block', () => {
      expect(ogmiosToCore.block(mockMaryBlock)).toMatchSnapshot();
    });

    it('can translate from alonzo block', () => {
      expect(ogmiosToCore.block(mockAlonzoBlock)).toMatchSnapshot();
    });

    describe('babbage', () => {
      it('can translate from babbage block', () => {
        expect(ogmiosToCore.block(mockBabbageBlock)).toMatchSnapshot();
      });

      it('converts auxiliary data maps correctly', () => {
        const coreBlock = ogmiosToCore.block(mockBabbageBlockWithNftMetadata);
        const metadata = coreBlock!.body[0].auxiliaryData!.blob!;
        const nftMetadatum = metadata.get(721n) as Cardano.MetadatumMap;
        const policyIdMetadatum = nftMetadatum.get(
          'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a'
        ) as Cardano.MetadatumMap;
        const tokenMetadatum = policyIdMetadatum.get('bob') as Cardano.MetadatumMap;
        expect(tokenMetadatum.get('name')).toBe('$bob');
        const core = tokenMetadatum.get('core') as Cardano.MetadatumMap;
        expect(core.get('og')).toBe(0n);
        expect(Array.isArray(tokenMetadatum.get('augmentations'))).toBe(true);
      });
    });
  });
});
