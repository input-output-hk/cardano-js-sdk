import { Cardano } from '@cardano-sdk/core';
import { ogmiosToCore } from '../../src';

import {
  mockAllegraBlock,
  mockAlonzoBlock,
  mockBabbageBlock,
  mockByronBlock,
  mockMaryBlock,
  mockShelleyBlock
} from './testData';

describe('ogmiosToCore', () => {
  describe('blockHeader', () => {
    it('can translate from byron block', () => {
      expect(ogmiosToCore.blockHeader(mockByronBlock)).toEqual(<Cardano.PartialBlockHeader>{
        blockNo: 42,
        hash: Cardano.BlockId('5c3103bd0ff5ea85a62b202a1d2500cf3ebe0b9d793ed09e7febfe27ef12c968'),
        slot: 77_761
      });
    });
    it('can translate from common block', () => {
      expect(ogmiosToCore.blockHeader(mockShelleyBlock)).toEqual(<Cardano.PartialBlockHeader>{
        blockNo: 1087,
        hash: Cardano.BlockId('071fceb6c20a412b9a9b57baedfe294e3cd9de641cd44c4cf8d0d56217e083ac'),
        slot: 107_220
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

    it('can translate from babbage block', () => {
      expect(ogmiosToCore.block(mockBabbageBlock)).toMatchSnapshot();
    });
  });
});
