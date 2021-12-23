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
type PartialCoreTx = Omit<Partial<Cardano.TxAlonzo>, 'body'> & { body: Partial<Cardano.TxBodyAlonzo> };

describe('WalletProvider/queryTransactions/graphqlTransactionsToCore', () => {
  const protocolParameters = [{ poolDeposit: 4, stakeKeyDeposit: 2 }];

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
        value: { coin: 123_456n }
      }
    ],
    size: 1234n,
    witness: {
      signatures: [
        {
          publicKey: { key: '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39' },
          signature:
            '709f937c4ce152c81f8406c03279ff5a8556a12a8657e40a578eaaa6223d2e6a2fece39733429e3ec73a6c798561b5c2d47d82224d656b1d964cfe8b5fdffe09'
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
          datum: undefined,
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

  describe('certificates', () => {
    const poolId = Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh');
    const rewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');

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
