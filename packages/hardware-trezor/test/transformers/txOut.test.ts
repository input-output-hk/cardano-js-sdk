import * as Trezor from 'trezor-connect';
import {
  contextWithKnownAddresses,
  knownAddressKeyPath,
  knownAddressStakeKeyPath,
  txOut,
  txOutToOwnedAddress,
  txOutWithAssets,
  txOutWithAssetsToOwnedAddress
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
          amount: '10'
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
          tokenBundle: [
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
              policyId: '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740',
              tokenAmounts: [
                {
                  amount: '20',
                  assetNameBytes: ''
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
            addressType: Trezor.CardanoAddressType.BASE,
            path: knownAddressKeyPath,
            stakingPath: knownAddressStakeKeyPath
          },
          amount: '10'
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
            addressType: Trezor.CardanoAddressType.BASE,
            path: knownAddressKeyPath,
            stakingPath: knownAddressStakeKeyPath
          },
          amount: '10',
          tokenBundle: [
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
              policyId: '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740',
              tokenAmounts: [
                {
                  amount: '20',
                  assetNameBytes: ''
                }
              ]
            }
          ]
        });
      }
    });
  });

  describe('toTxOut', () => {
    it('can map a simple transaction output to third party address', async () => {
      const out = toTxOut(txOut, contextWithKnownAddresses);
      expect(out).toEqual({
        address:
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
        amount: '10'
      });
    });

    it('can map a simple transaction output with assets to third party address', async () => {
      const out = toTxOut(txOutWithAssets, contextWithKnownAddresses);
      expect(out).toEqual({
        address:
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
        amount: '10',
        tokenBundle: [
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
            policyId: '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740',
            tokenAmounts: [
              {
                amount: '20',
                assetNameBytes: ''
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
          addressType: Trezor.CardanoAddressType.BASE,
          path: knownAddressKeyPath,
          stakingPath: knownAddressStakeKeyPath
        },
        amount: '10'
      });
    });

    it('can map a simple transaction output with assets to owned address', async () => {
      const out = toTxOut(txOutWithAssetsToOwnedAddress, contextWithKnownAddresses);

      expect(out).toEqual({
        addressParameters: {
          addressType: Trezor.CardanoAddressType.BASE,
          path: knownAddressKeyPath,
          stakingPath: knownAddressStakeKeyPath
        },
        amount: '10',
        tokenBundle: [
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
            policyId: '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740',
            tokenAmounts: [
              {
                amount: '20',
                assetNameBytes: ''
              }
            ]
          }
        ]
      });
    });
  });
});
