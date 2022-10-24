import { Cardano, ogmiosToCore } from '../../src';

import {
  mockAllegraBlock,
  mockAlonzoBlock,
  mockBabbageBlock,
  mockByronBlock,
  mockMaryBlock,
  mockShelleyBlock
} from './testData';

describe('ogmiosToCore', () => {
  it('can translate from byron block', () => {
    // using https://preprod.cardanoscan.io/block/42 as source of truth
    expect(ogmiosToCore.getBlock(mockByronBlock)).toEqual(<Cardano.BlockMinimal>{
      fees: undefined,
      header: {
        blockNo: 42,
        hash: Cardano.BlockId('5c3103bd0ff5ea85a62b202a1d2500cf3ebe0b9d793ed09e7febfe27ef12c968'),
        slot: 77_761
      },
      issuerVk: undefined,
      previousBlock: Cardano.BlockId('dd8d7559a9b6c1177c0f5a328eb82967af68155d58cbcdc0a59de39a38aaf3f0'),
      // got size: 626 by querying the postgres db populated by db-sync.
      // Using size: undefined until we can calculate it
      size: undefined,
      totalOutput: 0n,
      txCount: 0,
      vrf: undefined
    });
  });

  it('can translate from shelley block', () => {
    // using https://preprod.cardanoscan.io/block/1087 as source of truth
    expect(ogmiosToCore.getBlock(mockShelleyBlock)).toEqual(<Cardano.BlockMinimal>{
      fees: 0n,
      header: {
        blockNo: 1087,
        hash: Cardano.BlockId('071fceb6c20a412b9a9b57baedfe294e3cd9de641cd44c4cf8d0d56217e083ac'),
        slot: 107_220
      },
      issuerVk: Cardano.Ed25519PublicKey('8b0960d234bda67d52432c5d1a26aca2bfb5b9a09f966d9592a7bf0c728a1ecd'),
      previousBlock: Cardano.BlockId('8d5d930981710fc8c6ca9fc8e0628665283f7efb28c7e6bddeee2d289f012dee'),
      // got size by querying the postgres db populated by db-sync
      size: 3,
      totalOutput: 0n,
      txCount: 0,
      // vrf from https://preprod.cexplorer.io/block/071fceb6c20a412b9a9b57baedfe294e3cd9de641cd44c4cf8d0d56217e083ac
      vrf: Cardano.VrfVkBech32('vrf_vk15c2edf9h66wllthgvyttzhzwrngq0rvd0wchzqlw8qray60fq5usfngf29')
    });
  });

  it('can translate from allegra block', () => {
    // Verify data extracted from mock structure
    const ogmiosBlock = mockAllegraBlock.allegra;
    expect(ogmiosToCore.getBlock(mockAllegraBlock)).toEqual(<Cardano.BlockMinimal>{
      fees: ogmiosBlock.body[0].body.fee,
      header: {
        blockNo: ogmiosBlock.header.blockHeight,
        hash: Cardano.BlockId(ogmiosBlock.headerHash),
        slot: ogmiosBlock.header.slot
      },
      issuerVk: Cardano.Ed25519PublicKey(ogmiosBlock.header.issuerVk),
      previousBlock: Cardano.BlockId(ogmiosBlock.header.prevHash),
      size: ogmiosBlock.header.blockSize,
      totalOutput: 0n,
      txCount: ogmiosBlock.body.length,
      vrf: Cardano.VrfVkBech32FromBase64(ogmiosBlock.header.issuerVrf)
    });
  });

  it('can translate from mary block', () => {
    // Verify data extracted from mock structure
    const ogmiosBlock = mockMaryBlock.mary;
    expect(ogmiosToCore.getBlock(mockMaryBlock)).toEqual(<Cardano.BlockMinimal>{
      fees: ogmiosBlock.body[0].body.fee + ogmiosBlock.body[1].body.fee,
      header: {
        blockNo: ogmiosBlock.header.blockHeight,
        hash: Cardano.BlockId(ogmiosBlock.headerHash),
        slot: ogmiosBlock.header.slot
      },
      issuerVk: Cardano.Ed25519PublicKey(ogmiosBlock.header.issuerVk),
      previousBlock: Cardano.BlockId(ogmiosBlock.header.prevHash),
      size: ogmiosBlock.header.blockSize,
      totalOutput:
        ogmiosBlock.body[0].body.outputs[0].value.coins +
        ogmiosBlock.body[1].body.outputs[0].value.coins +
        ogmiosBlock.body[1].body.outputs[1].value.coins,
      txCount: ogmiosBlock.body.length,
      vrf: Cardano.VrfVkBech32FromBase64(ogmiosBlock.header.issuerVrf)
    });
  });

  it('can translate from alonzo block', () => {
    // using https://preprod.cardanoscan.io/block/100000 as source of truth
    expect(ogmiosToCore.getBlock(mockAlonzoBlock)).toEqual(<Cardano.BlockMinimal>{
      fees: 202_549n,
      header: {
        blockNo: 100_000,
        hash: Cardano.BlockId('514f8be63ef25c46bee47a90658977f815919c06222c0b480be1e29efbd72c49'),
        slot: 5_481_752
      },
      issuerVk: Cardano.Ed25519PublicKey('a9d974fd26bfaf385749113f260271430276bed6ef4dad6968535de6778471ce'),

      previousBlock: Cardano.BlockId('518a24a3fb0cc6ee1a31668a63994e4dbda70ede5ff13be494a3b4c1bb7709c8'),
      // got size by querying the postgres db populated by db-sync
      size: 836,
      totalOutput: 8_287_924_709n,
      txCount: 1,
      // vrf from https://preprod.cexplorer.io/block/514f8be63ef25c46bee47a90658977f815919c06222c0b480be1e29efbd72c49
      vrf: Cardano.VrfVkBech32('vrf_vk1p8s5ysf7dgsvfrw0p0q7zczdytkxc95zsq3p9sfshk9s3z86jfdql5fdft')
    });
  });

  it('can translate from babbage block', () => {
    // Verify data extracted from mock structure
    const ogmiosBlock = mockBabbageBlock.babbage;
    expect(ogmiosToCore.getBlock(mockBabbageBlock)).toEqual(<Cardano.BlockMinimal>{
      fees: ogmiosBlock.body[0].body.fee,
      header: {
        blockNo: ogmiosBlock.header.blockHeight,
        hash: Cardano.BlockId(ogmiosBlock.headerHash),
        slot: ogmiosBlock.header.slot
      },
      issuerVk: Cardano.Ed25519PublicKey(ogmiosBlock.header.issuerVk),
      previousBlock: Cardano.BlockId(ogmiosBlock.header.prevHash),
      size: ogmiosBlock.header.blockSize,
      totalOutput: ogmiosBlock.body[0].body.outputs[0].value.coins,
      txCount: ogmiosBlock.body.length,
      vrf: Cardano.VrfVkBech32FromBase64(ogmiosBlock.header.issuerVrf)
    });
  });
});
