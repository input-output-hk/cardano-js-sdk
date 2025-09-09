/* eslint-disable sonarjs/no-identical-functions */
import * as Crypto from '@cardano-sdk/crypto';
import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Ada, InvalidDataReason } from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { CardanoKeyConst, CommunicationType, KeyPurpose, util } from '@cardano-sdk/key-management';
import { LedgerKeyAgent } from '../src';
import { dummyLogger } from 'ts-log';
import { poolId, poolParameters, pureAdaTxOut, stakeKeyHash, txIn, txOutWithDatum } from './testData';
import Transport from '@ledgerhq/hw-transport';

describe('LedgerKeyAgent', () => {
  describe('getSigningMode', () => {
    it('can detect ordinary transaction signing mode', async () => {
      const tx: Ledger.Transaction = {
        fee: 10n,
        includeNetworkId: false,
        inputs: [
          {
            outputIndex: 0,
            path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 1, 0],
            txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
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
            format: Ledger.TxOutputFormat.ARRAY_LEGACY
          }
        ],
        ttl: 1000,
        validityIntervalStart: 100
      };

      expect(LedgerKeyAgent.getSigningMode(tx)).toEqual(Ledger.TransactionSigningMode.ORDINARY_TRANSACTION);
    });

    it('can detect pool registration as owner transaction signing mode', async () => {
      const tx: Ledger.Transaction = {
        certificates: [
          {
            params: {
              cost: 1000n,
              margin: {
                denominator: 5,
                numerator: 1
              },
              metadata: {
                metadataHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
                metadataUrl: 'https://example.com'
              },
              pledge: 10_000n,
              poolKey: {
                params: {
                  path: [
                    util.harden(CardanoKeyConst.PURPOSE),
                    util.harden(CardanoKeyConst.COIN_TYPE),
                    util.harden(0),
                    2,
                    0
                  ]
                },
                type: Ledger.PoolKeyType.DEVICE_OWNED
              },
              poolOwners: [
                {
                  params: {
                    stakingPath: [
                      util.harden(CardanoKeyConst.PURPOSE),
                      util.harden(CardanoKeyConst.COIN_TYPE),
                      util.harden(0),
                      2,
                      0
                    ]
                  },
                  type: Ledger.PoolOwnerType.DEVICE_OWNED
                }
              ],
              relays: [
                {
                  params: {
                    // eslint-disable-next-line sonarjs/no-duplicate-string
                    dnsName: 'example.com',
                    portNumber: 5000
                  },
                  type: 1
                },
                {
                  params: {
                    ipv4: '127.0.0.1',
                    portNumber: 6000
                  },
                  type: 0
                },
                {
                  params: {
                    dnsName: 'example.com'
                  },
                  type: 1
                }
              ],
              rewardAccount: {
                params: {
                  path: [
                    util.harden(CardanoKeyConst.PURPOSE),
                    util.harden(CardanoKeyConst.COIN_TYPE),
                    util.harden(0),
                    2,
                    0
                  ]
                },
                type: Ledger.PoolRewardAccountType.DEVICE_OWNED
              },
              vrfKeyHashHex: '8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0'
            },
            type: 3
          }
        ],
        fee: 10n,
        includeNetworkId: false,
        inputs: [
          {
            outputIndex: 0,
            path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 1, 0],
            txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
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
            format: Ledger.TxOutputFormat.ARRAY_LEGACY
          }
        ],
        ttl: 1000,
        validityIntervalStart: 100
      };

      expect(LedgerKeyAgent.getSigningMode(tx)).toEqual(Ledger.TransactionSigningMode.POOL_REGISTRATION_AS_OWNER);
    });

    it('can detect pool registration as operator transaction signing mode', async () => {
      const tx: Ledger.Transaction = {
        certificates: [
          {
            params: {
              cost: 1000n,
              margin: {
                denominator: 5,
                numerator: 1
              },
              metadata: {
                metadataHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
                metadataUrl: 'https://example.com'
              },
              pledge: 10_000n,
              poolKey: {
                params: {
                  path: [
                    util.harden(CardanoKeyConst.PURPOSE),
                    util.harden(CardanoKeyConst.COIN_TYPE),
                    util.harden(0),
                    2,
                    0
                  ]
                },
                type: Ledger.PoolKeyType.DEVICE_OWNED
              },
              poolOwners: [
                {
                  params: {
                    stakingKeyHashHex: stakeKeyHash
                  },
                  type: Ledger.PoolOwnerType.THIRD_PARTY
                }
              ],
              relays: [
                {
                  params: {
                    dnsName: 'example.com',
                    portNumber: 5000
                  },
                  type: 1
                },
                {
                  params: {
                    ipv4: '127.0.0.1',
                    portNumber: 6000
                  },
                  type: 0
                },
                {
                  params: {
                    dnsName: 'example.com'
                  },
                  type: 1
                }
              ],
              rewardAccount: {
                params: {
                  path: [
                    util.harden(CardanoKeyConst.PURPOSE),
                    util.harden(CardanoKeyConst.COIN_TYPE),
                    util.harden(0),
                    2,
                    0
                  ]
                },
                type: Ledger.PoolRewardAccountType.DEVICE_OWNED
              },
              vrfKeyHashHex: '8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0'
            },
            type: 3
          }
        ],
        fee: 10n,
        includeNetworkId: false,
        inputs: [
          {
            outputIndex: 0,
            path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 1, 0],
            txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
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
            format: Ledger.TxOutputFormat.ARRAY_LEGACY
          }
        ],
        ttl: 1000,
        validityIntervalStart: 100
      };

      expect(LedgerKeyAgent.getSigningMode(tx)).toEqual(Ledger.TransactionSigningMode.POOL_REGISTRATION_AS_OPERATOR);
    });

    it('can detect plutus transaction signing mode', async () => {
      const tx: Ledger.Transaction = {
        collateralInputs: [
          {
            outputIndex: 0,
            path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 1, 0],
            txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
          }
        ],
        fee: 10n,
        includeNetworkId: false,
        inputs: [
          {
            outputIndex: 0,
            path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 1, 0],
            txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
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
            format: Ledger.TxOutputFormat.ARRAY_LEGACY
          }
        ],
        ttl: 1000,
        validityIntervalStart: 100
      };

      expect(LedgerKeyAgent.getSigningMode(tx)).toEqual(Ledger.TransactionSigningMode.PLUTUS_TRANSACTION);
    });

    it('can detect multisig transaction signing mode', async () => {
      const tx: Ledger.Transaction = {
        certificates: [
          {
            params: {
              stakeCredential: {
                scriptHashHex: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
                type: Ledger.CredentialParamsType.SCRIPT_HASH
              }
            },
            type: Ledger.CertificateType.STAKE_DEREGISTRATION
          }
        ],
        fee: 10n,
        includeNetworkId: false,
        inputs: [
          {
            outputIndex: 0,
            path: null,
            txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f190000'
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
            format: Ledger.TxOutputFormat.ARRAY_LEGACY
          }
        ],
        ttl: 1000,
        validityIntervalStart: 100
      };

      expect(LedgerKeyAgent.getSigningMode(tx)).toEqual(Ledger.TransactionSigningMode.MULTISIG_TRANSACTION);
    });

    it('can detect ordinary transaction signing mode when we own a required signer', async () => {
      const tx: Ledger.Transaction = {
        certificates: [
          {
            params: {
              stakeCredential: {
                scriptHashHex: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
                type: Ledger.CredentialParamsType.SCRIPT_HASH
              }
            },
            type: Ledger.CertificateType.STAKE_DEREGISTRATION
          }
        ],
        fee: 10n,
        includeNetworkId: false,
        inputs: [
          {
            outputIndex: 0,
            path: null,
            txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f190000'
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
            format: Ledger.TxOutputFormat.ARRAY_LEGACY
          }
        ],
        requiredSigners: [
          { path: [util.harden(1852), util.harden(1815), util.harden(0), 2, 0], type: Ledger.TxRequiredSignerType.PATH }
        ],
        ttl: 1000,
        validityIntervalStart: 100
      };

      expect(LedgerKeyAgent.getSigningMode(tx)).toEqual(Ledger.TransactionSigningMode.ORDINARY_TRANSACTION);
    });
  });

  describe('Unsupported Transaction Errors', () => {
    let keyAgentMock: LedgerKeyAgent;
    const noAddressesOptions = {
      knownAddresses: [],
      txInKeyPathMap: {}
    };

    beforeAll(async () => {
      LedgerKeyAgent.checkDeviceConnection = async () => new Ada(new Transport());

      keyAgentMock = new LedgerKeyAgent(
        {
          accountIndex: 0,
          chainId: Cardano.ChainIds.Preview,
          communicationType: CommunicationType.Node,
          extendedAccountPublicKey: Crypto.Bip32PublicKeyHex(
            '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
          ),
          purpose: KeyPurpose.STANDARD
        },
        {
          bip32Ed25519: await Crypto.SodiumBip32Ed25519.create(),
          logger: dummyLogger
        }
      );
    });

    it('Ordinary transaction fails if it contains a pool registration certificate', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.ORDINARY_TRANSACTION;

      const txBody = Serialization.TransactionBody.fromCore({
        certificates: [
          {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters
          }
        ],
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_ORDINARY__POOL_REGISTRATION_NOT_ALLOWED
      );
    });

    it('Ordinary transaction fails if it contains a foreign delegation certificate', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.ORDINARY_TRANSACTION;

      const txBody = Serialization.TransactionBody.fromCore({
        certificates: [
          {
            __typename: Cardano.CertificateType.StakeDelegation,
            poolId,
            stakeCredential: {
              hash: '00000000000000000000000000000000000000000000000000000000' as unknown as Crypto.Hash28ByteBase16,
              type: Cardano.CredentialType.KeyHash
            }
          }
        ],
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_ORDINARY__CERTIFICATE_STAKE_CREDENTIAL_ONLY_AS_PATH
      );
    });

    it('Ordinary transaction fails if it contains withdrawals with foreign keys', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.ORDINARY_TRANSACTION;

      const txBody = Serialization.TransactionBody.fromCore({
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut],
        withdrawals: [
          {
            quantity: 5n,
            stakeAddress: Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
          }
        ]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_ORDINARY__WITHDRAWAL_ONLY_AS_PATH
      );
    });

    it('Ordinary transaction fails if it contains collateral inputs', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.ORDINARY_TRANSACTION;

      const txBody = Serialization.TransactionBody.fromCore({
        collaterals: [{ ...txIn, index: txIn.index + 1 }],
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_ORDINARY__COLLATERAL_INPUTS_NOT_ALLOWED
      );
    });

    it('Ordinary transaction fails if it contains collateral outputs', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.ORDINARY_TRANSACTION;

      const txBody = Serialization.TransactionBody.fromCore({
        collateralReturn: pureAdaTxOut,
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_ORDINARY__COLLATERAL_OUTPUT_NOT_ALLOWED
      );
    });

    it('Ordinary transaction fails if it contains total collateral', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.ORDINARY_TRANSACTION;

      const txBody = Serialization.TransactionBody.fromCore({
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut],
        totalCollateral: 10n
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_ORDINARY__TOTAL_COLLATERAL_NOT_ALLOWED
      );
    });

    it('Ordinary transaction fails if it contains reference input', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.ORDINARY_TRANSACTION;

      const txBody = Serialization.TransactionBody.fromCore({
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut],
        referenceInputs: [txIn]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_ORDINARY__REFERENCE_INPUTS_NOT_ALLOWED
      );
    });

    it('Multisig transaction fails if it contains a pool registration certificate', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.MULTISIG_TRANSACTION;

      const txBody = Serialization.TransactionBody.fromCore({
        certificates: [
          {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters
          }
        ],
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_MULTISIG__POOL_REGISTRATION_NOT_ALLOWED
      );
    });

    it('Multisig transaction fails if it contains collateral inputs', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.MULTISIG_TRANSACTION;

      const txBody = Serialization.TransactionBody.fromCore({
        collaterals: [{ ...txIn, index: txIn.index + 1 }],
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_MULTISIG__COLLATERAL_INPUTS_NOT_ALLOWED
      );
    });

    it('Multisig transaction fails if it contains collateral outputs', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.MULTISIG_TRANSACTION;

      const txBody = Serialization.TransactionBody.fromCore({
        collateralReturn: pureAdaTxOut,
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_MULTISIG__COLLATERAL_OUTPUT_NOT_ALLOWED
      );
    });

    it('Multisig transaction fails if it contains total collateral', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.MULTISIG_TRANSACTION;

      const txBody = Serialization.TransactionBody.fromCore({
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut],
        totalCollateral: 10n
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_MULTISIG__TOTAL_COLLATERAL_NOT_ALLOWED
      );
    });

    it('Multisig transaction fails if it contains reference input', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.MULTISIG_TRANSACTION;

      const txBody = Serialization.TransactionBody.fromCore({
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut],
        referenceInputs: [txIn]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_MULTISIG__REFERENCE_INPUTS_NOT_ALLOWED
      );
    });

    it('Plutus transaction fails if it contains a pool registration certificate', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.PLUTUS_TRANSACTION;

      const txBody = Serialization.TransactionBody.fromCore({
        certificates: [
          {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters
          }
        ],
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_PLUTUS__POOL_REGISTRATION_NOT_ALLOWED
      );
    });

    it('Pool registration as owner transaction fails if it contains datum in outputs', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.POOL_REGISTRATION_AS_OWNER;

      const txBody = Serialization.TransactionBody.fromCore({
        certificates: [
          {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters
          }
        ],
        fee: 10n,
        inputs: [txIn],
        outputs: [txOutWithDatum]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_POOL_OWNER__DATUM_NOT_ALLOWED
      );
    });

    it('Pool registration as owner transaction fails if it contains more than one device owner', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.POOL_REGISTRATION_AS_OWNER;

      const txBody = Serialization.TransactionBody.fromCore({
        certificates: [
          {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters
          }
        ],
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut],
        referenceInputs: [txIn]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_POOL_OWNER__SINGLE_DEVICE_OWNER_REQUIRED
      );
    });

    it('Pool registration as owner transaction fails if it contains more than one certificate', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.POOL_REGISTRATION_AS_OWNER;

      const txBody = Serialization.TransactionBody.fromCore({
        certificates: [
          {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters
          },
          {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters
          }
        ],
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_POOL_OWNER__SINGLE_POOL_REG_CERTIFICATE_REQUIRED
      );
    });

    it('Pool registration as operator transaction fails if it contains datum in outputs', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.POOL_REGISTRATION_AS_OPERATOR;

      const txBody = Serialization.TransactionBody.fromCore({
        certificates: [
          {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters
          }
        ],
        fee: 10n,
        inputs: [txIn],
        outputs: [txOutWithDatum]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_POOL_OPERATOR__DATUM_NOT_ALLOWED
      );
    });

    it('Pool registration as operator transaction fails if it contains more than one certificate', async () => {
      LedgerKeyAgent.getSigningMode = () => Ledger.TransactionSigningMode.POOL_REGISTRATION_AS_OPERATOR;

      const txBody = Serialization.TransactionBody.fromCore({
        certificates: [
          {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters
          },
          {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters
          }
        ],
        fee: 10n,
        inputs: [txIn],
        outputs: [pureAdaTxOut]
      });

      await expect(async () => await keyAgentMock.signTransaction(txBody, noAddressesOptions)).rejects.toThrow(
        InvalidDataReason.SIGN_MODE_POOL_OPERATOR__SINGLE_POOL_REG_CERTIFICATE_REQUIRED
      );
    });
  });
});
