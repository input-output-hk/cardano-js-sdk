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
      // using https://preprod.cardanoscan.io/block/42 as source of truth
      expect(ogmiosToCore.block(mockByronBlock)).toEqual(<Cardano.Block>{
        body: [],
        fees: undefined,
        header: {
          blockNo: Cardano.BlockNo(42),
          hash: Cardano.BlockId('5c3103bd0ff5ea85a62b202a1d2500cf3ebe0b9d793ed09e7febfe27ef12c968'),
          slot: Cardano.Slot(77_761)
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
      expect(ogmiosToCore.block(mockShelleyBlock)).toEqual(<Cardano.Block>{
        body: [],
        fees: 0n,
        header: {
          blockNo: Cardano.BlockNo(1087),
          hash: Cardano.BlockId('071fceb6c20a412b9a9b57baedfe294e3cd9de641cd44c4cf8d0d56217e083ac'),
          slot: Cardano.Slot(107_220)
        },
        issuerVk: Cardano.Ed25519PublicKey('8b0960d234bda67d52432c5d1a26aca2bfb5b9a09f966d9592a7bf0c728a1ecd'),
        previousBlock: Cardano.BlockId('8d5d930981710fc8c6ca9fc8e0628665283f7efb28c7e6bddeee2d289f012dee'),
        // got size by querying the postgres db populated by db-sync
        size: Cardano.BlockSize(3),
        totalOutput: 0n,
        txCount: 0,
        // vrf from https://preprod.cexplorer.io/block/071fceb6c20a412b9a9b57baedfe294e3cd9de641cd44c4cf8d0d56217e083ac
        vrf: Cardano.VrfVkBech32('vrf_vk15c2edf9h66wllthgvyttzhzwrngq0rvd0wchzqlw8qray60fq5usfngf29')
      });
    });

    it('can translate from allegra block', () => {
      // Verify data extracted from mock structure
      const ogmiosBlock = mockAllegraBlock.allegra;
      expect(ogmiosToCore.block(mockAllegraBlock)).toEqual(<Cardano.Block>{
        body: [
          {
            body: {
              certificates: [] as Cardano.Certificate[]
            }
          } as Cardano.HydratedTx
        ],
        fees: ogmiosBlock.body[0].body.fee,
        header: {
          blockNo: Cardano.BlockNo(ogmiosBlock.header.blockHeight),
          hash: Cardano.BlockId(ogmiosBlock.headerHash),
          slot: Cardano.Slot(ogmiosBlock.header.slot)
        },
        issuerVk: Cardano.Ed25519PublicKey(ogmiosBlock.header.issuerVk),
        previousBlock: Cardano.BlockId(ogmiosBlock.header.prevHash),
        size: Cardano.BlockSize(ogmiosBlock.header.blockSize),
        totalOutput: 0n,
        txCount: ogmiosBlock.body.length,
        vrf: Cardano.VrfVkBech32FromBase64(ogmiosBlock.header.issuerVrf)
      });
    });

    it('can translate from mary block', () => {
      // Verify data extracted from mock structure
      const ogmiosBlock = mockMaryBlock.mary;
      expect(ogmiosToCore.block(mockMaryBlock)).toEqual(<Cardano.Block>{
        body: [
          {
            body: {
              certificates: [
                {
                  __typename: Cardano.CertificateType.StakeKeyRegistration,
                  stakeKeyHash: Cardano.Ed25519KeyHash('b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54')
                },
                {
                  __typename: Cardano.CertificateType.GenesisKeyDelegation,
                  genesisDelegateHash: 'a646474b8f5431261506b6c273d307c7569a4eb6c96b42dd4a29520a',
                  genesisHash: '0d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4',
                  vrfKeyHash: '03170a2e7597b7b7e3d84c05391d139a62b157e78786d8c082f29dcf4c111314'
                }
              ]
            }
          },
          {
            body: {
              certificates: [
                {
                  __typename: Cardano.CertificateType.PoolRegistration,
                  poolParameters: {
                    cost: 810n,
                    id: 'pool15erywju02scjv9gxkmp885c8catf5n4ke9459h2299fq57u9c3e',
                    margin: {
                      denominator: 1,
                      numerator: 0
                    },
                    metadataJson: undefined,
                    owners: ['stake_test1uq659t9n5excps5nqgnq6ckrhpa8g2k3f2lc2h4uvuess8sr44gva'],
                    pledge: 525n,
                    relays: [],
                    rewardAccount: 'stake_test1uz66ue36465w2qq40005h2hadad6pnjht8mu6sgplsfj74q9f9d7l',
                    vrf: 'bb30a42c1e62f0afda5f0a4e8a562f7a13a24cea00ee81917b86b89e801314aa'
                  }
                }
              ]
            }
          }
        ],
        fees: ogmiosBlock.body[0].body.fee + ogmiosBlock.body[1].body.fee,
        header: {
          blockNo: Cardano.BlockNo(ogmiosBlock.header.blockHeight),
          hash: Cardano.BlockId(ogmiosBlock.headerHash),
          slot: Cardano.Slot(ogmiosBlock.header.slot)
        },
        issuerVk: Cardano.Ed25519PublicKey(ogmiosBlock.header.issuerVk),
        previousBlock: Cardano.BlockId(ogmiosBlock.header.prevHash),
        size: Cardano.BlockSize(ogmiosBlock.header.blockSize),
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
      expect(ogmiosToCore.block(mockAlonzoBlock)).toEqual(<Cardano.Block>{
        body: [
          {
            body: {
              certificates: [
                {
                  __typename: Cardano.CertificateType.StakeDelegation,
                  poolId: Cardano.PoolId('pool15erywju02scjv9gxkmp885c8catf5n4ke9459h2299fq57u9c3e'),
                  stakeKeyHash: Cardano.Ed25519KeyHash('f2f6381fa7a3dcc144939b47dffb7dad677856dfbbee4c4b7e426049')
                },
                {
                  __typename: Cardano.CertificateType.StakeKeyDeregistration,
                  stakeKeyHash: Cardano.Ed25519KeyHash('f2f6381fa7a3dcc144939b47dffb7dad677856dfbbee4c4b7e426049')
                },
                {
                  __typename: Cardano.CertificateType.PoolRetirement,
                  epoch: Cardano.EpochNo(123),
                  poolId: Cardano.PoolId('pool15erywju02scjv9gxkmp885c8catf5n4ke9459h2299fq57u9c3e')
                },
                {
                  __typename: Cardano.CertificateType.GenesisKeyDelegation,
                  genesisDelegateHash: 'e0a714319812c3f773ba04ec5d6b3ffcd5aad85006805b047b082541',
                  genesisHash: 'b16b56f5ec064be6ac3cab6035efae86b366cc3dc4a0d571603d70e5',
                  vrfKeyHash: '95c3003a78585e0db8c9496f6deef4de0ff000994b8534cd66d4fe96bb21ddd3'
                }
              ] as Cardano.Certificate[]
            }
          } as Cardano.HydratedTx
        ],
        fees: 202_549n,
        header: {
          blockNo: Cardano.BlockNo(100_000),
          hash: Cardano.BlockId('514f8be63ef25c46bee47a90658977f815919c06222c0b480be1e29efbd72c49'),
          slot: Cardano.Slot(5_481_752)
        },
        issuerVk: Cardano.Ed25519PublicKey('a9d974fd26bfaf385749113f260271430276bed6ef4dad6968535de6778471ce'),

        previousBlock: Cardano.BlockId('518a24a3fb0cc6ee1a31668a63994e4dbda70ede5ff13be494a3b4c1bb7709c8'),
        // got size by querying the postgres db populated by db-sync
        size: Cardano.BlockSize(836),
        totalOutput: 8_287_924_709n,
        txCount: 1,
        // vrf from https://preprod.cexplorer.io/block/514f8be63ef25c46bee47a90658977f815919c06222c0b480be1e29efbd72c49
        vrf: Cardano.VrfVkBech32('vrf_vk1p8s5ysf7dgsvfrw0p0q7zczdytkxc95zsq3p9sfshk9s3z86jfdql5fdft')
      });
    });

    it('can translate from babbage block', () => {
      // Verify data extracted from mock structure
      const ogmiosBlock = mockBabbageBlock.babbage;
      expect(ogmiosToCore.block(mockBabbageBlock)).toEqual(<Cardano.Block>{
        body: [
          {
            body: {
              certificates: [
                {
                  __typename: Cardano.CertificateType.MIR,
                  pot: 'reserve',
                  quantity: 712n
                },
                {
                  __typename: Cardano.CertificateType.PoolRegistration,
                  poolParameters: {
                    cost: 290n,
                    id: 'pool1kkhxvw4w4rjsq9tmma964lt0twsvu46e7lx5zq0uzvh4ge9n0hc',
                    margin: {
                      denominator: 2,
                      numerator: 1
                    },
                    metadataJson: {
                      hash: '2738e2233800ab7f82bd2212a9a55f52d4851f9147f161684c63e6655bedb562',
                      url: 'https://public.bladepool.com/metadata.json'
                    },
                    owners: [],
                    pledge: 229n,
                    relays: [
                      {
                        __typename: 'RelayByAddress',
                        ipv4: '192.0.2.1',
                        ipv6: '2001:db8::1',
                        port: undefined
                      },
                      {
                        __typename: 'RelayByName',
                        hostname: 'foo.example.com',
                        port: undefined
                      }
                    ],
                    rewardAccount: 'stake_test1urs2w9p3nqfv8amnhgzwchtt8l7dt2kc2qrgqkcy0vyz2sgcp89zz',
                    vrf: 'ee155ace9c40292074cb6aff8c9ccdd273c81648ff1149ef36bcea6ebb8a3e25'
                  }
                }
              ]
            }
          }
        ],
        fees: ogmiosBlock.body[0].body.fee,
        header: {
          blockNo: Cardano.BlockNo(ogmiosBlock.header.blockHeight),
          hash: Cardano.BlockId(ogmiosBlock.headerHash),
          slot: Cardano.Slot(ogmiosBlock.header.slot)
        },
        issuerVk: Cardano.Ed25519PublicKey(ogmiosBlock.header.issuerVk),
        size: Cardano.BlockSize(ogmiosBlock.header.blockSize),
        totalOutput: ogmiosBlock.body[0].body.outputs[0].value.coins,
        txCount: ogmiosBlock.body.length,
        vrf: Cardano.VrfVkBech32FromBase64(ogmiosBlock.header.issuerVrf)
      });
    });
  });
});
