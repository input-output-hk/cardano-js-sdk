import { Cardano } from '@cardano-sdk/core';
import { ogmiosToCore } from '../../src';

import {
  mockAllegraBlock,
  mockAlonzoBlock,
  mockBabbageBlock,
  mockBabbageBlockWithNftMetadata,
  mockByronBlock,
  mockMaryBlock,
  mockShelleyBlock
} from './testData';

describe('ogmiosToCore', () => {
  describe('blockHeader', () => {
    it('can translate from byron block', () => {
      const block = ogmiosToCore.blockHeader(mockByronBlock)!;
      expect(typeof block.blockNo).toBe('number');
      expect(typeof block.hash).toBe('string');
      expect(typeof block.slot).toBe('number');
    });
    it('can translate from shelley block', () => {
      const block = ogmiosToCore.blockHeader(mockShelleyBlock)!;
      expect(typeof block.blockNo).toBe('number');
      expect(typeof block.hash).toBe('string');
      expect(typeof block.slot).toBe('number');
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
        const metadata = coreBlock!.body.find((tx) => tx.auxiliaryData?.blob?.has(721n))!.auxiliaryData!.blob!;
        const nftMetadatum = metadata.get(721n) as Cardano.MetadatumMap;
        const policyIdMetadatum = nftMetadatum.get(nftMetadatum.keys().next().value) as Cardano.MetadatumMap;
        const tokenMetadatum = policyIdMetadatum.get(policyIdMetadatum.keys().next().value) as Cardano.MetadatumMap;
        expect(typeof tokenMetadatum.get('name')).toBe('string');
      });
    });

    it.todo('maps all native scripts correctly');
  });
});
