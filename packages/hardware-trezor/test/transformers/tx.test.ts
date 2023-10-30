import * as Trezor from '@trezor/connect';
import { CardanoKeyConst, util } from '@cardano-sdk/key-management';
import {
  contextWithKnownAddresses,
  contextWithoutKnownAddresses,
  knownAddressKeyPath,
  knownAddressStakeKeyPath,
  minValidTxBody,
  txBody,
  txIn
} from '../testData';
import { txToTrezor } from '../../src/transformers/tx';

describe('tx', () => {
  describe('txToTrezor', () => {
    test('can map min valid transaction', async () => {
      expect(
        await txToTrezor({
          ...contextWithoutKnownAddresses,
          cardanoTxBody: minValidTxBody
        })
      ).toEqual({
        additionalWitnessRequests: [],
        auxiliaryData: undefined,
        certificates: [],
        fee: '10',
        inputs: [
          {
            prev_hash: txIn.txId,
            prev_index: txIn.index
          }
        ],
        mint: undefined,
        networkId: 0,
        outputs: [
          {
            address:
              'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
            amount: '10'
          }
        ],
        protocolMagic: 999,
        ttl: undefined,
        validityIntervalStart: undefined,
        withdrawals: []
      });
    });

    test('can map transaction', async () => {
      expect(
        await txToTrezor({
          ...contextWithKnownAddresses,
          cardanoTxBody: txBody
        })
      ).toEqual({
        additionalWitnessRequests: [
          [2_147_485_500, 2_147_485_463, 2_147_483_648, 1, 0], // payment key path
          [2_147_485_500, 2_147_485_463, 2_147_483_648, 2, 0] // reward account key path
        ],
        auxiliaryData: {
          hash: '2ceb364d93225b4a0f004a0975a13eb50c3cc6348474b4fe9121f8dc72ca0cfa'
        },
        certificates: [
          {
            path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 2, 0],
            pool: '153806dbcd134ddee69a8c5204e38ac80448f62342f8c23cfe4b7edf',
            type: Trezor.PROTO.CardanoCertificateType.STAKE_DELEGATION
          }
        ],
        fee: '10',
        inputs: [
          {
            path: knownAddressKeyPath,
            prev_hash: txIn.txId,
            prev_index: txIn.index
          }
        ],
        mint: [
          {
            policyId: '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740',
            tokenAmounts: [{ assetNameBytes: '', mintAmount: '20' }]
          },
          {
            policyId: '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82',
            tokenAmounts: [{ assetNameBytes: '54534c41', mintAmount: '-50' }]
          },
          {
            policyId: '7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373',
            tokenAmounts: [
              { assetNameBytes: '', mintAmount: '40' },
              { assetNameBytes: '504154415445', mintAmount: '30' }
            ]
          }
        ],
        networkId: 0,
        outputs: [
          {
            address:
              'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
            amount: '10',
            tokenBundle: [
              {
                policyId: '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740',
                tokenAmounts: [
                  {
                    amount: '20',
                    assetNameBytes: ''
                  }
                ]
              },
              {
                policyId: '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82',
                tokenAmounts: [
                  {
                    amount: '50',
                    assetNameBytes: '54534c41'
                  }
                ]
              },
              {
                policyId: '7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373',
                tokenAmounts: [
                  {
                    amount: '40',
                    assetNameBytes: ''
                  },
                  {
                    amount: '30',
                    assetNameBytes: '504154415445'
                  }
                ]
              }
            ]
          },
          {
            addressParameters: {
              addressType: Trezor.PROTO.CardanoAddressType.BASE,
              path: knownAddressKeyPath,
              stakingPath: knownAddressStakeKeyPath
            },
            amount: '10',
            tokenBundle: [
              {
                policyId: '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740',
                tokenAmounts: [
                  {
                    amount: '20',
                    assetNameBytes: ''
                  }
                ]
              },
              {
                policyId: '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82',
                tokenAmounts: [
                  {
                    amount: '50',
                    assetNameBytes: '54534c41'
                  }
                ]
              },
              {
                policyId: '7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373',
                tokenAmounts: [
                  {
                    amount: '40',
                    assetNameBytes: ''
                  },
                  {
                    amount: '30',
                    assetNameBytes: '504154415445'
                  }
                ]
              }
            ]
          }
        ],
        protocolMagic: 999,
        ttl: '1000',
        validityIntervalStart: '100',
        withdrawals: [
          {
            amount: '5',
            path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 2, 0]
          }
        ]
      });
    });
  });
});
