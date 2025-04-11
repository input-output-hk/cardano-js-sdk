import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import {
  CONTEXT_WITH_KNOWN_ADDRESSES,
  txOut,
  txOutToOwnedAddress,
  txOutWithReferenceScript,
  txOutWithReferenceScriptWithInlineDatum
} from '../testData';
import { CardanoKeyConst, util } from '@cardano-sdk/key-management';
import { mapTxOuts, toTxOut } from '../../src/transformers/txOut';

describe('txOut', () => {
  describe('mapTxOuts', () => {
    it('can map a a set of TxOuts', async () => {
      const txOuts = mapTxOuts(
        [
          txOutWithReferenceScriptWithInlineDatum,
          txOutWithReferenceScriptWithInlineDatum,
          txOutWithReferenceScriptWithInlineDatum
        ],
        CONTEXT_WITH_KNOWN_ADDRESSES
      );

      expect(txOuts.length).toEqual(3);

      for (const out of txOuts) {
        expect(out).toEqual({
          amount: 10n,
          datum: {
            datumHex: '187b',
            type: Ledger.DatumType.INLINE
          },
          destination: {
            params: {
              params: {
                spendingPath: [
                  util.harden(CardanoKeyConst.PURPOSE),
                  util.harden(CardanoKeyConst.COIN_TYPE),
                  util.harden(0),
                  1,
                  0
                ],
                stakingPath: [
                  util.harden(CardanoKeyConst.PURPOSE),
                  util.harden(CardanoKeyConst.COIN_TYPE),
                  util.harden(0),
                  2,
                  0
                ]
              },
              type: Ledger.AddressType.BASE_PAYMENT_KEY_STAKE_KEY
            },
            type: Ledger.TxOutputDestinationType.DEVICE_OWNED
          },
          format: Ledger.TxOutputFormat.MAP_BABBAGE,
          referenceScriptHex: '82015820b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450',
          tokenBundle: null
        });
      }

      expect.assertions(4);
    });
  });

  describe('toTxOut', () => {
    it('can map a simple txOut to third party address', async () => {
      const out = toTxOut(txOut, { ...CONTEXT_WITH_KNOWN_ADDRESSES, useBabbageOutputs: false });

      expect(out).toEqual({
        amount: 10n,
        datumHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
        destination: {
          params: {
            addressHex:
              '009493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc'
          },
          type: Ledger.TxOutputDestinationType.THIRD_PARTY
        },
        format: Ledger.TxOutputFormat.ARRAY_LEGACY,
        tokenBundle: [
          {
            policyIdHex: '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740',
            tokens: [
              {
                amount: 20n,
                assetNameHex: ''
              }
            ]
          },
          {
            policyIdHex: '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82',
            tokens: [
              {
                amount: 50n,
                assetNameHex: '54534c41'
              }
            ]
          },
          {
            policyIdHex: '7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373',
            tokens: [
              {
                amount: 40n,
                assetNameHex: ''
              },
              {
                amount: 30n,
                assetNameHex: '504154415445'
              }
            ]
          }
        ]
      });
    });

    it('can map a simple txOut to owned address', async () => {
      const out = toTxOut(txOutToOwnedAddress, { ...CONTEXT_WITH_KNOWN_ADDRESSES, useBabbageOutputs: false });

      expect(out).toEqual({
        amount: 10n,
        datumHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
        destination: {
          params: {
            params: {
              spendingPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(0),
                1,
                0
              ],
              stakingPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(0),
                2,
                0
              ]
            },
            type: Ledger.AddressType.BASE_PAYMENT_KEY_STAKE_KEY
          },
          type: Ledger.TxOutputDestinationType.DEVICE_OWNED
        },
        format: Ledger.TxOutputFormat.ARRAY_LEGACY,
        tokenBundle: [
          {
            policyIdHex: '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740',
            tokens: [
              {
                amount: 20n,
                assetNameHex: ''
              }
            ]
          },
          {
            policyIdHex: '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82',
            tokens: [
              {
                amount: 50n,
                assetNameHex: '54534c41'
              }
            ]
          },
          {
            policyIdHex: '7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373',
            tokens: [
              {
                amount: 40n,
                assetNameHex: ''
              },
              {
                amount: 30n,
                assetNameHex: '504154415445'
              }
            ]
          }
        ]
      });
    });

    it('can map a txOut with a reference script - datum hash', async () => {
      const out = toTxOut(txOutWithReferenceScript, CONTEXT_WITH_KNOWN_ADDRESSES);

      expect(out).toEqual({
        amount: 10n,
        datum: {
          datumHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
          type: Ledger.DatumType.HASH
        },
        destination: {
          params: {
            params: {
              spendingPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(0),
                1,
                0
              ],
              stakingPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(0),
                2,
                0
              ]
            },
            type: Ledger.AddressType.BASE_PAYMENT_KEY_STAKE_KEY
          },
          type: Ledger.TxOutputDestinationType.DEVICE_OWNED
        },
        format: Ledger.TxOutputFormat.MAP_BABBAGE,
        referenceScriptHex: '82015820b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450',
        tokenBundle: null
      });
    });

    it('can map a txOut with a reference script - inline datum', async () => {
      const out = toTxOut(txOutWithReferenceScriptWithInlineDatum, CONTEXT_WITH_KNOWN_ADDRESSES);

      expect(out).toEqual({
        amount: 10n,
        datum: {
          datumHex: '187b',
          type: Ledger.DatumType.INLINE
        },
        destination: {
          params: {
            params: {
              spendingPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(0),
                1,
                0
              ],
              stakingPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(0),
                2,
                0
              ]
            },
            type: Ledger.AddressType.BASE_PAYMENT_KEY_STAKE_KEY
          },
          type: Ledger.TxOutputDestinationType.DEVICE_OWNED
        },
        format: Ledger.TxOutputFormat.MAP_BABBAGE,
        referenceScriptHex: '82015820b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450',
        tokenBundle: null
      });
    });
  });
});
