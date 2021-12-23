// Review: this is a big file, might be good to split this as well as graphqlTransactionsToCore.ts into multiple files
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable unicorn/consistent-function-scoping */
/* eslint-disable max-len */
import { Cardano } from '@cardano-sdk/core';
import { TransactionsByHashesQuery } from '../../../src/sdk';
import { cloneDeep, merge } from 'lodash';
import { getExactlyOneObject } from '../../../src/util/getExactlyOneObject';
import { graphqlTransactionsToCore } from '../../../src/WalletProvider/queryTransactions/graphqlTransactionsToCore';

jest.mock('../../../src/util/graphqlPoolParametersToCore');
const { graphqlPoolParametersToCore } = jest.requireMock('../../../src/util/graphqlPoolParametersToCore');

type GraphqlTx = NonNullable<NonNullable<TransactionsByHashesQuery['queryTransaction']>[0]>;
type GraphqlCertificate = NonNullable<GraphqlTx['certificates']>[0];
type GraphqlAuxiliaryDataBody = NonNullable<GraphqlTx['auxiliaryData']>['body'];
type GraphqlScript = NonNullable<GraphqlAuxiliaryDataBody['scripts']>[0]['script'];
type GraphqlMetadatum = NonNullable<GraphqlAuxiliaryDataBody['blob']>[0]['metadatum'];
type PartialCoreTx = Omit<Partial<Cardano.TxAlonzo>, 'body'> & { body?: Partial<Cardano.TxBodyAlonzo> };

describe('WalletProvider/queryTransactions/graphqlTransactionsToCore', () => {
  const protocolParameters = [{ poolDeposit: 4, stakeKeyDeposit: 2 }];
  const address = Cardano.Address('addr_test1vrdkagyspkmt96k6z87rnt9dzzy8mlcex7awjymm8wx434q837u24');
  const keyHash = Cardano.Ed25519KeyHash('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39');
  const rewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
  const publicKey = Cardano.Ed25519PublicKey('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39');
  const scriptIntegrityHash = '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3';
  const signature =
    '709f937c4ce152c81f8406c03279ff5a8556a12a8657e40a578eaaa6223d2e6a2fece39733429e3ec73a6c798561b5c2d47d82224d656b1d964cfe8b5fdffe09';

  const minimalGraphqlTx: GraphqlTx = {
    block: {
      blockNo: 123,
      hash: '356b7d7dbb696ccd12775c016941057a9dc70898d87a63fc752271bb46856940',
      slot: { number: 12_345 }
    },
    fee: 12n,
    hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad',
    index: 2,
    inputs: [
      {
        address: {
          address:
            'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
        },
        index: 1
      }
    ],
    outputs: [
      {
        address: {
          address:
            'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
        },
        datumHash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cac',
        value: { coin: 123_456n }
      }
    ],
    size: 1234n,
    witness: {
      signatures: [
        {
          publicKey: { key: publicKey.toString() },
          signature
        }
      ]
    }
  };

  const txId = Cardano.TransactionId(minimalGraphqlTx.hash);
  const minimalCoreTx: Cardano.TxAlonzo = {
    // Fields are explicitly set to undefined to work with jest's toEqual matcher
    auxiliaryData: undefined,
    blockHeader: {
      blockNo: minimalGraphqlTx.block.blockNo,
      hash: Cardano.BlockId(minimalGraphqlTx.block.hash),
      slot: minimalGraphqlTx.block.slot.number
    },
    body: {
      certificates: undefined,
      collaterals: undefined,
      fee: minimalGraphqlTx.fee,
      inputs: [
        {
          address: Cardano.Address(minimalGraphqlTx.inputs[0].address.address),
          index: minimalGraphqlTx.inputs[0].index,
          txId
        }
      ],
      mint: undefined,
      outputs: [
        {
          address: Cardano.Address(minimalGraphqlTx.outputs[0].address.address),
          datum: Cardano.Hash32ByteBase16('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cac'),
          value: { assets: new Map(), coins: minimalGraphqlTx.outputs[0].value.coin }
        }
      ],
      requiredExtraSignatures: undefined,
      scriptIntegrityHash: undefined,
      validityInterval: {
        invalidBefore: undefined,
        invalidHereafter: undefined
      },
      withdrawals: undefined
    },
    id: txId,
    implicitCoin: {
      deposit: 0n,
      input: 0n
    },
    index: minimalGraphqlTx.index,
    txSize: Number(minimalGraphqlTx.size),
    witness: {
      bootstrap: undefined,
      datums: undefined,
      redeemers: undefined,
      scripts: undefined,
      signatures: new Map([
        [
          Cardano.Ed25519PublicKey(minimalGraphqlTx.witness.signatures[0].publicKey.key),
          Cardano.Ed25519Signature(minimalGraphqlTx.witness.signatures[0].signature)
        ]
      ])
    }
  };

  const testTxPropertiesConversion = (extraGraphqlTxData: Partial<GraphqlTx>, expectedCoreProps: PartialCoreTx) =>
    expect(
      graphqlTransactionsToCore([merge(extraGraphqlTxData, minimalGraphqlTx)], protocolParameters, getExactlyOneObject)
    ).toEqual([merge(cloneDeep(minimalCoreTx), expectedCoreProps)]);

  it('maps minimal transaction to core types', () => {
    expect(graphqlTransactionsToCore([minimalGraphqlTx], protocolParameters, getExactlyOneObject)).toEqual([
      minimalCoreTx
    ]);
  });

  it('maps collateral inputs to core types', () => {
    testTxPropertiesConversion(
      {
        collateral: [{ address: { address: address.toString() }, index: 1 }]
      },
      {
        body: {
          collaterals: [{ address, index: 1, txId }]
        }
      }
    );
  });

  it('maps "mint" to core types', () => {
    const assetId = 'b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e';
    testTxPropertiesConversion(
      {
        mint: [{ asset: { assetId }, quantity: '123' }]
      },
      {
        body: {
          mint: new Map([[Cardano.AssetId(assetId), 123n]])
        }
      }
    );
  });

  it('maps "requiredExtraSignatures" to core types', () => {
    testTxPropertiesConversion(
      {
        requiredExtraSignatures: [{ hash: keyHash.toString() }]
      },
      {
        body: {
          requiredExtraSignatures: [keyHash]
        }
      }
    );
  });

  it('maps "scriptIntegrityHash" to core type', () => {
    testTxPropertiesConversion(
      { scriptIntegrityHash },
      {
        body: {
          scriptIntegrityHash: Cardano.Hash28ByteBase16(scriptIntegrityHash)
        }
      }
    );
  });

  it('maps "validityInterval" to core type', () => {
    testTxPropertiesConversion(
      { invalidBefore: { slotNo: 2 }, invalidHereafter: { slotNo: 5 } },
      {
        body: {
          validityInterval: {
            invalidBefore: 2,
            invalidHereafter: 5
          }
        }
      }
    );
  });

  it('maps "withdrawals" to core type and affects implicit input', () => {
    testTxPropertiesConversion(
      { withdrawals: [{ quantity: 123n, rewardAccount: { address: rewardAccount.toString() } }] },
      {
        body: {
          // TODO: rename core Withdrawal.stakeAddress to rewardAccount
          withdrawals: [{ quantity: 123n, stakeAddress: rewardAccount }]
        },
        implicitCoin: {
          input: 123n
        }
      }
    );
  });

  describe('witness', () => {
    it('maps "bootstrap" to core type', () => {
      const bootstrap = {
        addressAttributes: 'attr',
        chainCode: 'chain',
        key: { key: publicKey.toString() },
        signature
      };
      testTxPropertiesConversion(
        {
          witness: {
            ...minimalGraphqlTx.witness,
            bootstrap: [bootstrap]
          }
        },
        {
          witness: {
            ...minimalCoreTx.witness,
            bootstrap: [
              {
                addressAttributes: bootstrap.addressAttributes,
                chainCode: bootstrap.chainCode,
                key: bootstrap.key.key,
                signature: bootstrap.signature
              }
            ]
          }
        }
      );
    });

    it('maps "datums" to core type', () => {
      testTxPropertiesConversion(
        {
          witness: {
            ...minimalGraphqlTx.witness,
            datums: [{ datum: 'datum', hash: 'abc123' }]
          }
        },
        {
          witness: {
            ...minimalCoreTx.witness,
            datums: { abc123: 'datum' }
          }
        }
      );
    });

    it('maps "redeemers" to core type', () => {
      const redeemer = {
        executionUnits: { memory: 1, steps: 2 },
        index: 1,
        purpose: 'spend' as const,
        scriptHash: scriptIntegrityHash
      };
      testTxPropertiesConversion(
        {
          witness: {
            ...minimalGraphqlTx.witness,
            redeemers: [redeemer]
          }
        },
        {
          witness: {
            ...minimalCoreTx.witness,
            redeemers: [redeemer as any]
          }
        }
      );
    });

    it('maps "scripts" to core type', () => {
      // detailed script parsing is tested for scripts in auxiliary data
      testTxPropertiesConversion(
        {
          witness: {
            ...minimalGraphqlTx.witness,
            scripts: [{ key: publicKey.toString(), script: { __typename: 'PlutusScript', cborHex: 'abc123' } }]
          }
        },
        {
          witness: {
            ...minimalCoreTx.witness,
            scripts: { [publicKey.toString()]: { plutus: 'abc123' } }
          }
        }
      );
    });
  });

  describe('auxiliaryData', () => {
    const hash = Cardano.Hash32ByteBase16('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d');

    describe('blob', () => {
      const label = 'label';
      const testMetadatumConversion = (metadatum: GraphqlMetadatum, coreMetadatum: Cardano.Metadatum) =>
        testTxPropertiesConversion(
          {
            auxiliaryData: {
              body: {
                blob: [{ label, metadatum }]
              },
              hash: hash.toString()
            }
          },
          {
            auxiliaryData: {
              body: {
                blob: {
                  [label]: coreMetadatum
                },
                scripts: undefined
              },
              hash
            }
          }
        );

      it('maps integer metadatum to core type', () => {
        const metadatum = { __typename: 'IntegerMetadatum' as const, int: 5 };
        testMetadatumConversion(metadatum, BigInt(metadatum.int));
      });

      it('maps string metadatum to core type', () => {
        const metadatum = { __typename: 'StringMetadatum' as const, string: 'str' };
        testMetadatumConversion(metadatum, metadatum.string);
      });

      it('maps bytes metadatum to core type', () => {
        const metadatum = { __typename: 'BytesMetadatum' as const, bytes: 'abc123' };
        testMetadatumConversion(metadatum, Buffer.from(metadatum.bytes, 'hex'));
      });

      it('maps a metadatum map to core type', () => {
        const metadatum = {
          __typename: 'MetadatumMap' as const,
          map: [{ label: 'nested', metadatum: { __typename: 'StringMetadatum' as const, string: 'value' } }]
        };
        testMetadatumConversion(metadatum, {
          [metadatum.map[0].label]: metadatum.map[0].metadatum.string
        });
      });

      it('maps a metadatum array to core type', () => {
        const metadatum = {
          __typename: 'MetadatumArray' as const,
          array: [{ metadatum: { __typename: 'StringMetadatum' as const, string: 'value' } }]
        };
        testMetadatumConversion(
          {
            __typename: 'MetadatumArray' as const,
            array: [{ __typename: 'StringMetadatum' as const, string: 'value' }]
          },
          [metadatum.array[0].metadatum.string]
        );
      });
    });

    describe('scripts', () => {
      const testScriptConversion = (graphqlScript: GraphqlScript, coreScript: Cardano.Script) =>
        testTxPropertiesConversion(
          {
            auxiliaryData: {
              body: {
                scripts: [{ script: graphqlScript }]
              },
              hash: hash.toString()
            }
          },
          {
            auxiliaryData: {
              body: {
                blob: undefined,
                scripts: [coreScript]
              },
              hash
            }
          }
        );

      it('maps plutus script to core type', () => {
        const script = { __typename: 'PlutusScript' as const, cborHex: 'abc123' };
        testScriptConversion(script, { plutus: script.cborHex });
      });

      describe('native', () => {
        it('maps "all" to core type', () => {
          const script = {
            __typename: 'NativeScript' as const,
            all: [{ __typename: 'NativeScript' as const, startsAt: { number: 123 } }]
          };
          testScriptConversion(script, { native: { all: [{ startsAt: script.all[0].startsAt.number }] } });
        });

        it('maps "any" to core type', () => {
          const script = {
            __typename: 'NativeScript' as const,
            any: [{ __typename: 'NativeScript' as const, startsAt: { number: 123 } }]
          };
          testScriptConversion(script, { native: { any: [{ startsAt: script.any[0].startsAt.number }] } });
        });

        it('maps "nof" to core type', () => {
          const script = {
            __typename: 'NativeScript' as const,
            nof: [{ key: 'key', scripts: [{ __typename: 'NativeScript' as const, startsAt: { number: 123 } }] }]
          };
          testScriptConversion(script, {
            native: {
              [script.nof[0].key]: [{ startsAt: script.nof[0].scripts[0].startsAt.number }]
            }
          });
        });

        it('maps "vkey" to core type', () => {
          const script = {
            __typename: 'NativeScript' as const,
            vkey: { key: '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39' }
          };
          testScriptConversion(script, { native: script.vkey.key });
        });

        it('maps "startsAt" to core type', () => {
          const script = {
            __typename: 'NativeScript' as const,
            startsAt: { number: 123 }
          };
          testScriptConversion(script, { native: { startsAt: script.startsAt.number } });
        });

        it('maps "expiresAt" to core type', () => {
          const script = {
            __typename: 'NativeScript' as const,
            expiresAt: { number: 123 }
          };
          testScriptConversion(script, { native: { expiresAt: script.expiresAt.number } });
        });
      });
    });
  });

  describe('certificates', () => {
    const poolId = Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh');

    const testCertificateConversion = (
      graphqlCertificate: GraphqlCertificate,
      expectedCoreCertificate: Cardano.Certificate
    ) =>
      testTxPropertiesConversion(
        { certificates: [graphqlCertificate] },
        { body: { certificates: [expectedCoreCertificate] } }
      );

    it('maps GenesisKeyDelegationCertificate to core type', () => {
      const cert = {
        __typename: 'GenesisKeyDelegationCertificate' as const,
        genesisDelegateHash: '3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d',
        genesisHash: '3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80c',
        vrfKeyHash: '3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80c'
      };
      testCertificateConversion(cert, cert as any);
    });

    it('maps MirCertificate to core type', () => {
      const cert = {
        __typename: 'MirCertificate' as const,
        pot: 'reserve',
        quantity: 10n,
        rewardAccount: { address: 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27' }
      };
      testCertificateConversion(cert, {
        ...cert,
        rewardAccount: cert.rewardAccount.address
      } as any);
    });

    it('PoolRegistrationCertificate is mapped to core type using graphqlPoolParametersToCore util and affects deposit', () => {
      const poolParameters = { stakePool: { id: poolId } };
      const corePoolParameters = { mapped: 'parameters' };
      graphqlPoolParametersToCore.mockReturnValueOnce(corePoolParameters);
      const cert = { __typename: 'PoolRegistrationCertificate' as const, epoch: { number: 123 }, poolParameters };
      testTxPropertiesConversion(
        { certificates: [cert as any] },
        {
          body: {
            certificates: [
              {
                __typename: Cardano.CertificateType.PoolRegistration,
                epoch: cert.epoch.number,
                poolId,
                poolParameters: corePoolParameters
              } as any
            ]
          },
          implicitCoin: {
            deposit: 4n
          }
        }
      );
      expect(graphqlPoolParametersToCore).toHaveBeenCalledTimes(1);
      expect(graphqlPoolParametersToCore).toHaveBeenCalledWith(poolParameters, poolId);
    });

    it('PoolRetirementCertificate is mapped to core type and affects implicit input', () => {
      const cert = {
        __typename: 'PoolRetirementCertificate' as const,
        epoch: { number: 123 },
        stakePool: { id: poolId.toString() }
      };
      testTxPropertiesConversion(
        { certificates: [cert] },
        {
          body: {
            certificates: [
              {
                __typename: Cardano.CertificateType.PoolRetirement,
                epoch: cert.epoch.number,
                poolId
              }
            ]
          },
          implicitCoin: {
            input: 4n
          }
        }
      );
    });

    it('maps StakeDelegationCertificate to core type', () => {
      const cert = {
        __typename: 'StakeDelegationCertificate' as const,
        epoch: { number: 123 },
        rewardAccount: { address: rewardAccount.toString() },
        stakePool: { id: poolId.toString() }
      };
      testCertificateConversion(cert, {
        __typename: Cardano.CertificateType.StakeDelegation,
        epoch: cert.epoch.number,
        poolId,
        rewardAccount
      });
    });

    it('StakeKeyDeregistrationCertificate is mapped to core type and affects implicit input', () => {
      const cert = {
        __typename: 'StakeKeyDeregistrationCertificate' as const,
        rewardAccount: { address: rewardAccount.toString() }
      };
      testTxPropertiesConversion(
        { certificates: [cert] },
        {
          body: {
            certificates: [
              {
                __typename: Cardano.CertificateType.StakeKeyDeregistration,
                rewardAccount
              }
            ]
          },
          implicitCoin: {
            input: 2n
          }
        }
      );
    });

    it('StakeKeyRegistrationCertificate is mapped to core type and affects deposit', () => {
      const cert = {
        __typename: 'StakeKeyRegistrationCertificate' as const,
        rewardAccount: { address: rewardAccount.toString() }
      };
      testTxPropertiesConversion(
        { certificates: [cert] },
        {
          body: {
            certificates: [
              {
                __typename: Cardano.CertificateType.StakeKeyRegistration,
                rewardAccount
              }
            ]
          },
          implicitCoin: {
            deposit: 2n
          }
        }
      );
    });
  });
});
