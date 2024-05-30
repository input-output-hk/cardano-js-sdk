import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { CONTEXT_WITH_KNOWN_ADDRESSES, babbageTxWithoutScript, stakeCredential, tx } from '../testData';
import { Cardano } from '@cardano-sdk/core';
import { CardanoKeyConst, KeyPurpose, TxInId, util } from '@cardano-sdk/key-management';
import { toLedgerTx } from '../../src';

describe('tx', () => {
  describe('toLedgerTx', () => {
    test('can map a transaction with scripts', async () => {
      const paymentKeyPath = { index: 0, purpose: KeyPurpose.STANDARD, role: 1 };
      const stakeKeyPath = { index: 0, purpose: KeyPurpose.STANDARD, role: 2 };
      expect(
        await toLedgerTx(tx.body, {
          ...CONTEXT_WITH_KNOWN_ADDRESSES,
          txInKeyPathMap: {
            [TxInId(tx.body.inputs[0])]: paymentKeyPath,
            [TxInId(tx.body.collaterals![0])]: paymentKeyPath
          }
        })
      ).toEqual({
        auxiliaryData: {
          params: {
            hashHex: '2ceb364d93225b4a0f004a0975a13eb50c3cc6348474b4fe9121f8dc72ca0cfa'
          },
          type: Ledger.TxAuxiliaryDataType.ARBITRARY_HASH
        },
        certificates: [
          {
            params: {
              poolKeyPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(CONTEXT_WITH_KNOWN_ADDRESSES.accountIndex),
                stakeKeyPath.role,
                stakeKeyPath.index
              ],
              retirementEpoch: 500
            },
            type: Ledger.CertificateType.STAKE_POOL_RETIREMENT
          }
        ],
        collateralInputs: [
          {
            outputIndex: 1,
            path: [
              util.harden(CardanoKeyConst.PURPOSE),
              util.harden(CardanoKeyConst.COIN_TYPE),
              util.harden(CONTEXT_WITH_KNOWN_ADDRESSES.accountIndex),
              paymentKeyPath.role,
              paymentKeyPath.index
            ],
            txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
          }
        ],
        collateralOutput: null,
        fee: 10n,
        includeNetworkId: false,
        inputs: [
          {
            outputIndex: 0,
            path: [
              util.harden(CardanoKeyConst.PURPOSE),
              util.harden(CardanoKeyConst.COIN_TYPE),
              util.harden(CONTEXT_WITH_KNOWN_ADDRESSES.accountIndex),
              paymentKeyPath.role,
              paymentKeyPath.index
            ],
            txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
          }
        ],
        mint: [
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
                amount: -50n,
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
        ],
        network: {
          networkId: Ledger.Networks.Testnet.networkId,
          protocolMagic: 999
        },
        outputs: [
          {
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
          }
        ],
        referenceInputs: null,
        requiredSigners: [
          {
            hashHex: '6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d39',
            type: Ledger.TxRequiredSignerType.HASH
          }
        ],
        scriptDataHashHex: '6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d38abc123de',
        ttl: 1000,
        validityIntervalStart: 100,
        votingProcedures: null,
        withdrawals: [
          {
            amount: 5n,
            stakeCredential: {
              keyHashHex: '13cf55d175ea848b87deb3e914febd7e028e2bf6534475d52fb9c3d0',
              type: Ledger.CredentialParamsType.KEY_HASH
            }
          }
        ]
      });
    });

    test('can map a transaction without scripts', async () => {
      const paymentKeyPath = { index: 0, purpose: KeyPurpose.STANDARD, role: 1 };
      expect(
        await toLedgerTx(babbageTxWithoutScript.body, {
          ...CONTEXT_WITH_KNOWN_ADDRESSES,
          txInKeyPathMap: {
            [TxInId(babbageTxWithoutScript.body.inputs[0])]: paymentKeyPath
          }
        })
      ).toEqual({
        auxiliaryData: null,
        certificates: null,
        collateralInputs: null,
        collateralOutput: null,
        fee: 10n,
        includeNetworkId: false,
        inputs: [
          {
            outputIndex: 0,
            path: [
              util.harden(CardanoKeyConst.PURPOSE),
              util.harden(CardanoKeyConst.COIN_TYPE),
              util.harden(CONTEXT_WITH_KNOWN_ADDRESSES.accountIndex),
              paymentKeyPath.role,
              paymentKeyPath.index
            ],
            txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
          }
        ],
        mint: null,
        network: {
          networkId: Ledger.Networks.Testnet.networkId,
          protocolMagic: 999
        },
        outputs: [
          {
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
          }
        ],
        referenceInputs: null,
        requiredSigners: null,
        ttl: 1000,
        validityIntervalStart: 100,
        votingProcedures: null,
        withdrawals: null
      });
    });

    test('can map a transaction with new conway-era certs', async () => {
      const stakeKeyPath = { index: 0, role: 2 };
      const txBodyWithRegistrationCert = {
        ...tx.body,
        certificates: [
          {
            __typename: Cardano.CertificateType.Registration,
            deposit: 5n,
            stakeCredential
          } as Cardano.Certificate
        ]
      };

      expect(
        await toLedgerTx(txBodyWithRegistrationCert, {
          ...CONTEXT_WITH_KNOWN_ADDRESSES
        })
      ).toEqual({
        auxiliaryData: {
          params: {
            hashHex: '2ceb364d93225b4a0f004a0975a13eb50c3cc6348474b4fe9121f8dc72ca0cfa'
          },
          type: Ledger.TxAuxiliaryDataType.ARBITRARY_HASH
        },
        certificates: [
          {
            params: {
              deposit: 5n,
              stakeCredential: {
                keyPath: [
                  util.harden(CardanoKeyConst.PURPOSE),
                  util.harden(CardanoKeyConst.COIN_TYPE),
                  util.harden(CONTEXT_WITH_KNOWN_ADDRESSES.accountIndex),
                  stakeKeyPath.role,
                  stakeKeyPath.index
                ],
                type: 0
              }
            },
            type: Ledger.CertificateType.STAKE_REGISTRATION_CONWAY
          }
        ],
        collateralInputs: [
          {
            outputIndex: 1,
            path: null,
            txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
          }
        ],
        collateralOutput: null,
        fee: 10n,
        includeNetworkId: false,
        inputs: [
          {
            outputIndex: 0,
            path: null,
            txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
          }
        ],
        mint: [
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
                amount: -50n,
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
        ],
        network: {
          networkId: Ledger.Networks.Testnet.networkId,
          protocolMagic: 999
        },
        outputs: [
          {
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
          }
        ],
        referenceInputs: null,
        requiredSigners: [
          {
            hashHex: '6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d39',
            type: Ledger.TxRequiredSignerType.HASH
          }
        ],
        scriptDataHashHex: '6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d38abc123de',
        ttl: 1000,
        validityIntervalStart: 100,
        votingProcedures: null,
        withdrawals: [
          {
            amount: 5n,
            stakeCredential: {
              keyHashHex: '13cf55d175ea848b87deb3e914febd7e028e2bf6534475d52fb9c3d0',
              type: Ledger.CredentialParamsType.KEY_HASH
            }
          }
        ]
      });
    });
  });
});
