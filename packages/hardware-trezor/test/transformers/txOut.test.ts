import * as Trezor from '@trezor/connect';
import {
  contextWithKnownAddresses,
  knownAddressKeyPath,
  knownAddressStakeKeyPath,
  txOut,
  txOutToOwnedAddress,
  txOutWithAssets,
  txOutWithAssetsToOwnedAddress,
  txOutWithDatumHash,
  txOutWithDatumHashAndOwnedAddress,
  txOutWithInlineDatum,
  txOutWithInlineDatumAndOwnedAddress,
  txOutWithReferenceScriptAndDatumHash,
  txOutWithReferenceScriptAndInlineDatum
} from '../testData';
import { mapTxOuts, toTxOut } from '../../src/transformers/txOut';

describe('txOut', () => {
  describe('mapTxOuts', () => {
    it('can map a set of transaction outputs to third party address', async () => {
      const txOuts = mapTxOuts([txOut, txOut, txOut], contextWithKnownAddresses);

      expect(txOuts.length).toEqual(3);
      for (const out of txOuts) {
        expect(out).toEqual({
          address:
            'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
          amount: '10',
          format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
        });
      }
    });

    it('can map a set of transaction outputs with assets to third party address', async () => {
      const txOuts = mapTxOuts([txOutWithAssets, txOutWithAssets, txOutWithAssets], contextWithKnownAddresses);

      expect(txOuts.length).toEqual(3);

      for (const out of txOuts) {
        expect(out).toEqual({
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
        });
      }
    });

    it('can map a set of transaction outputs to owned address', async () => {
      const txOuts = mapTxOuts(
        [txOutToOwnedAddress, txOutToOwnedAddress, txOutToOwnedAddress],
        contextWithKnownAddresses
      );

      expect(txOuts.length).toEqual(3);

      for (const out of txOuts) {
        expect(out).toEqual({
          addressParameters: {
            addressType: Trezor.PROTO.CardanoAddressType.BASE,
            path: knownAddressKeyPath,
            stakingPath: knownAddressStakeKeyPath
          },
          amount: '10',
          format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
        });
      }
    });

    it('can map a set of transaction outputs with assets to owned address', async () => {
      const txOuts = mapTxOuts(
        [txOutWithAssetsToOwnedAddress, txOutWithAssetsToOwnedAddress, txOutWithAssetsToOwnedAddress],
        contextWithKnownAddresses
      );

      expect(txOuts.length).toEqual(3);

      for (const out of txOuts) {
        expect(out).toEqual({
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
        });
      }
    });

    it('can map a set of transaction outputs with both output formats', async () => {
      const legacyTxOuts = mapTxOuts([txOutWithDatumHashAndOwnedAddress], contextWithKnownAddresses);

      const babbageTxOuts = mapTxOuts([txOutWithReferenceScriptAndDatumHash], {
        ...contextWithKnownAddresses,
        useBabbageOutputs: true
      });

      expect(legacyTxOuts.length).toEqual(1);

      expect(legacyTxOuts).toEqual([
        {
          addressParameters: {
            addressType: Trezor.PROTO.CardanoAddressType.BASE,
            path: knownAddressKeyPath,
            stakingPath: knownAddressStakeKeyPath
          },
          amount: '10',
          datumHash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
          format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
        }
      ]);

      expect(babbageTxOuts.length).toEqual(1);

      expect(babbageTxOuts).toEqual([
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
        }
      ]);
    });
  });

  describe('toTxOut', () => {
    it('can map a simple transaction output to third party address', async () => {
      const out = toTxOut(txOut, contextWithKnownAddresses);
      expect(out).toEqual({
        address:
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
        amount: '10',
        format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
      });
    });

    it('can map a simple transaction output with assets to third party address', async () => {
      const out = toTxOut(txOutWithAssets, contextWithKnownAddresses);
      expect(out).toEqual({
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
      });
    });

    it('can map a simple transaction output to owned address', async () => {
      const out = toTxOut(txOutToOwnedAddress, contextWithKnownAddresses);

      expect(out).toEqual({
        addressParameters: {
          addressType: Trezor.PROTO.CardanoAddressType.BASE,
          path: knownAddressKeyPath,
          stakingPath: knownAddressStakeKeyPath
        },
        amount: '10',
        format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
      });
    });

    it('can map a simple transaction output with assets to owned address', async () => {
      const out = toTxOut(txOutWithAssetsToOwnedAddress, contextWithKnownAddresses);

      expect(out).toEqual({
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
      });
    });

    it('can map simple transaction output with datum hash', async () => {
      const out = toTxOut(txOutWithDatumHash, contextWithKnownAddresses);

      expect(out).toEqual({
        address:
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
        amount: '10',
        datumHash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
        format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
      });
    });

    it('can map simple transaction output with datum hash to owned address', async () => {
      const out = toTxOut(txOutWithDatumHashAndOwnedAddress, contextWithKnownAddresses);

      expect(out).toEqual({
        addressParameters: {
          addressType: Trezor.PROTO.CardanoAddressType.BASE,
          path: knownAddressKeyPath,
          stakingPath: knownAddressStakeKeyPath
        },
        amount: '10',
        datumHash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
        format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
      });
    });

    it('can map simple transaction with inline datum', async () => {
      const out = toTxOut(txOutWithInlineDatum, { ...contextWithKnownAddresses, useBabbageOutputs: true });

      expect(out).toEqual({
        address:
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
        amount: '10',
        format: Trezor.PROTO.CardanoTxOutputSerializationFormat.MAP_BABBAGE,
        inlineDatum: '187b'
      });
    });

    it('can map simple transaction with inline datum to owned address', async () => {
      const out = toTxOut(txOutWithInlineDatumAndOwnedAddress, {
        ...contextWithKnownAddresses,
        useBabbageOutputs: true
      });

      expect(out).toEqual({
        addressParameters: {
          addressType: Trezor.PROTO.CardanoAddressType.BASE,
          path: knownAddressKeyPath,
          stakingPath: knownAddressStakeKeyPath
        },
        amount: '10',
        format: Trezor.PROTO.CardanoTxOutputSerializationFormat.MAP_BABBAGE,
        inlineDatum: '187b'
      });
    });

    it('can map a simple transaction output with reference script and datum hash', async () => {
      const out = toTxOut(txOutWithReferenceScriptAndDatumHash, {
        ...contextWithKnownAddresses,
        useBabbageOutputs: true
      });
      expect(out).toEqual({
        addressParameters: {
          addressType: Trezor.PROTO.CardanoAddressType.BASE,
          path: knownAddressKeyPath,
          stakingPath: knownAddressStakeKeyPath
        },
        amount: '10',
        datumHash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
        format: Trezor.PROTO.CardanoTxOutputSerializationFormat.MAP_BABBAGE,
        referenceScript: '82015820b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'
      });
    });

    it('can map a simple transaction output with reference script and inline datum', async () => {
      const out = toTxOut(txOutWithReferenceScriptAndInlineDatum, {
        ...contextWithKnownAddresses,
        useBabbageOutputs: true
      });
      expect(out).toEqual({
        addressParameters: {
          addressType: Trezor.PROTO.CardanoAddressType.BASE,
          path: knownAddressKeyPath,
          stakingPath: knownAddressStakeKeyPath
        },
        amount: '10',
        format: Trezor.PROTO.CardanoTxOutputSerializationFormat.MAP_BABBAGE,
        inlineDatum: '187b',
        referenceScript: '82015820b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450'
      });
    });
  });
});
