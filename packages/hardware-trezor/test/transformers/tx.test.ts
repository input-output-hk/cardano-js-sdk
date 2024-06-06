import * as Trezor from '@trezor/connect';
import { CardanoKeyConst, TxInId, util } from '@cardano-sdk/key-management';
import {
  babbageTxBodyWithScripts,
  contextWithKnownAddresses,
  contextWithoutKnownAddresses,
  knownAddressKeyPath,
  knownAddressPaymentKeyPath,
  knownAddressStakeKeyPath,
  minValidTxBody,
  plutusTxWithBabbage,
  txBody,
  txBodyWithCollaterals,
  txIn
} from '../testData.js';
import { txToTrezor } from '../../src/transformers/tx.js';

describe('tx', () => {
  describe('txToTrezor', () => {
    test('can map min valid transaction', async () => {
      expect(await txToTrezor(minValidTxBody, contextWithoutKnownAddresses)).toEqual({
        additionalWitnessRequests: [],
        fee: '10',
        inputs: [
          {
            prev_hash: txIn.txId,
            prev_index: txIn.index
          }
        ],
        networkId: 0,
        outputs: [
          {
            address:
              'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
            amount: '10',
            format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
          }
        ],
        protocolMagic: 999
      });
    });

    test('can map transaction without scripts', async () => {
      expect(
        await txToTrezor(txBody, {
          ...contextWithKnownAddresses,
          txInKeyPathMap: { [TxInId(txBody.inputs[0])]: knownAddressPaymentKeyPath }
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
            format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY,
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
            format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY,
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
            address:
              'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
            amount: '10',
            datumHash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
            format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
          }
        ],
        protocolMagic: 999,
        referenceInputs: [
          {
            path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 1, 0],
            prev_hash: txIn.txId,
            prev_index: txIn.index
          }
        ],
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

    test('can map babbage transaction with scripts', async () => {
      expect(
        await txToTrezor(babbageTxBodyWithScripts, {
          ...contextWithKnownAddresses,
          txInKeyPathMap: {
            [TxInId(babbageTxBodyWithScripts.inputs[0])]: knownAddressPaymentKeyPath
          }
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
            addressParameters: {
              addressType: Trezor.PROTO.CardanoAddressType.BASE,
              path: knownAddressKeyPath,
              stakingPath: knownAddressStakeKeyPath
            },
            amount: '10',
            datumHash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
            format: Trezor.PROTO.CardanoTxOutputSerializationFormat.MAP_BABBAGE,
            referenceScript: '82015820b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'
          },
          {
            addressParameters: {
              addressType: Trezor.PROTO.CardanoAddressType.BASE,
              path: knownAddressKeyPath,
              stakingPath: knownAddressStakeKeyPath
            },
            amount: '10',
            format: Trezor.PROTO.CardanoTxOutputSerializationFormat.MAP_BABBAGE,
            inlineDatum: '187b',
            referenceScript: '82015820b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'
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

    test('can map transaction with collaterals', async () => {
      expect(await txToTrezor(txBodyWithCollaterals, contextWithoutKnownAddresses)).toEqual({
        additionalWitnessRequests: [],
        collateralInputs: [
          {
            prev_hash: txIn.txId,
            prev_index: txIn.index
          }
        ],
        collateralReturn: {
          address:
            'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
          amount: '10',
          format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
        },
        fee: '10',
        inputs: [
          {
            prev_hash: txIn.txId,
            prev_index: txIn.index
          }
        ],
        networkId: 0,
        outputs: [
          {
            address:
              'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
            amount: '10',
            format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
          }
        ],
        protocolMagic: 999
      });
    });

    test('can map plutus transaction with babbage elements', async () => {
      expect(
        await txToTrezor(plutusTxWithBabbage, {
          ...contextWithKnownAddresses,
          txInKeyPathMap: {
            [TxInId(plutusTxWithBabbage.inputs[0])]: knownAddressPaymentKeyPath,
            [TxInId(plutusTxWithBabbage.collaterals[0])]: knownAddressPaymentKeyPath
          }
        })
      ).toEqual({
        additionalWitnessRequests: [
          [
            2_147_485_500,
            2_147_485_463,
            2_147_483_648,
            knownAddressPaymentKeyPath.role,
            knownAddressPaymentKeyPath.index
          ],
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
        collateralInputs: [
          {
            path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 1, 0],
            prev_hash: txIn.txId,
            prev_index: txIn.index
          }
        ],
        collateralReturn: {
          address:
            'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
          amount: '10',
          format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
        },
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
            addressParameters: {
              addressType: Trezor.PROTO.CardanoAddressType.BASE,
              path: knownAddressKeyPath,
              stakingPath: knownAddressStakeKeyPath
            },
            amount: '10',
            datumHash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
            format: Trezor.PROTO.CardanoTxOutputSerializationFormat.MAP_BABBAGE,
            referenceScript: '82015820b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'
          },
          {
            addressParameters: {
              addressType: Trezor.PROTO.CardanoAddressType.BASE,
              path: knownAddressKeyPath,
              stakingPath: knownAddressStakeKeyPath
            },
            amount: '10',
            format: Trezor.PROTO.CardanoTxOutputSerializationFormat.MAP_BABBAGE,
            inlineDatum: '187b',
            referenceScript: '82015820b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'
          }
        ],
        protocolMagic: 999,
        requiredSigners: [
          {
            keyHash: '6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d39'
          }
        ],
        totalCollateral: '1000',
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
