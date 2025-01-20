import * as AssetId from '../assetId';
import { Cardano, Paginated, TransactionsByAddressesArgs } from '@cardano-sdk/core';
import { currentEpoch, handleAssetId, ledgerTip, stakeCredential } from './mockData';
import { somePartialStakePools } from '../createStubStakePoolProvider';
import delay from 'delay';

export const getRandomTxId = () =>
  Array.from({ length: 64 })
    .map(() => Math.floor(Math.random() * 16).toString(16))
    .join('');

const address = Cardano.PaymentAddress(
  'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
);

export const generateTxAlonzo = (qty: number): Cardano.HydratedTx[] =>
  [...Array.from({ length: qty }).keys()].map((index) => ({
    blockHeader: {
      blockNo: Cardano.BlockNo(10_669),
      slot: Cardano.Slot(37_834_496)
    } as Cardano.PartialBlockHeader,
    body: {
      fee: 200_000n,
      inputs: [
        {
          address,
          index,
          txId: Cardano.TransactionId(getRandomTxId())
        }
      ],
      outputs: [
        {
          address,
          value: { coins: 5_000_000n }
        }
      ],
      validityInterval: {
        invalidHereafter: Cardano.Slot(20_000 + index)
      }
    },
    id: Cardano.TransactionId(getRandomTxId()),
    index,
    inputSource: Cardano.InputSource.inputs,
    txSize: 100_000,
    witness: {
      signatures: new Map()
    }
  }));

export const queryTransactionsResult: Paginated<Cardano.HydratedTx> = {
  pageResults: [
    {
      blockHeader: {
        blockNo: Cardano.BlockNo(10_050),
        slot: Cardano.Slot(ledgerTip.slot - 150_000)
      } as Cardano.PartialBlockHeader,
      body: {
        certificates: [
          {
            __typename: Cardano.CertificateType.StakeRegistration,
            stakeCredential
          },
          {
            __typename: Cardano.CertificateType.StakeDelegation,
            poolId: somePartialStakePools[0].id,
            stakeCredential
          }
        ],
        fee: 200_000n,
        inputs: [
          {
            address: Cardano.PaymentAddress(
              'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
            ),
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],
        outputs: [
          {
            address: Cardano.PaymentAddress(
              'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
            ),
            value: { coins: 5_000_000n }
          },
          {
            address: Cardano.PaymentAddress(
              'addr_test1qplfzem2xsc29wxysf8wkdqrm4s4mmncd40qnjq9sk84l3tuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q52ukj5'
            ),
            value: { coins: 5_000_000n }
          },
          {
            address: Cardano.PaymentAddress(
              'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
            ),
            value: { coins: 9_825_963n }
          }
        ],
        validityInterval: {
          invalidHereafter: Cardano.Slot(ledgerTip.slot + 1)
        }
      },
      id: Cardano.TransactionId('12fa9af65e21b36ec4dc4cbce478e911d52585adb46f2b4fe3d6563e7ee5a61a'),
      index: 0,
      inputSource: Cardano.InputSource.inputs,
      txSize: 100_000,
      witness: {
        signatures: new Map()
      }
    },
    {
      blockHeader: {
        blockNo: Cardano.BlockNo(10_100),
        slot: Cardano.Slot(ledgerTip.slot - 100_000)
      } as Cardano.PartialBlockHeader,
      body: {
        fee: 123n,
        inputs: [
          {
            address: Cardano.PaymentAddress(
              'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
            ),
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],
        outputs: [
          {
            address: Cardano.PaymentAddress(
              'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
            ),
            value: {
              assets: new Map([
                [AssetId.TSLA, 1n],
                [handleAssetId, 1n]
              ]),
              coins: 5_000_000n
            }
          }
        ],
        validityInterval: {
          invalidHereafter: Cardano.Slot(ledgerTip.slot + 1)
        }
      },
      id: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad'),
      index: 1,
      inputSource: Cardano.InputSource.inputs,
      txSize: 200_000,
      witness: {
        signatures: new Map()
      }
    }
  ],
  totalResultCount: 2
};

export const queryTransactionsResult2: Paginated<Cardano.HydratedTx> = {
  pageResults: [
    ...queryTransactionsResult.pageResults,
    {
      ...queryTransactionsResult.pageResults[1],
      blockHeader: {
        blockNo: Cardano.BlockNo(10_150),
        slot: Cardano.Slot(ledgerTip.slot - 50_000)
      },
      id: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99caa')
    } as Cardano.HydratedTx
  ],
  totalResultCount: 3
};

export const filterAndPaginateTransactions = (
  response: Cardano.HydratedTx[],
  args: TransactionsByAddressesArgs
): Paginated<Cardano.HydratedTx> => {
  const pageResults = response.filter((res) => res.blockHeader.blockNo >= (args.blockRange?.lowerBound || 0));
  const totalResultCount = pageResults.length;
  if (args.pagination) {
    if (args.pagination.order === 'desc') pageResults.reverse();
    const slice = pageResults.slice(args.pagination.startAt, args.pagination.limit);
    return { pageResults: slice, totalResultCount };
  }
  return { pageResults, totalResultCount };
};

const withCertificatesStakeCredential = (transactions: Cardano.HydratedTx[], rewardAccount?: Cardano.RewardAccount) =>
  rewardAccount
    ? transactions.map((tx) => ({
        ...tx,
        body: {
          ...tx.body,
          certificates: tx.body.certificates?.map((certificate) =>
            'stakeCredential' in certificate
              ? {
                  ...certificate,
                  stakeCredential: {
                    hash: Cardano.RewardAccount.toHash(rewardAccount),
                    type: Cardano.CredentialType.KeyHash
                  }
                }
              : certificate
          )
        }
      }))
    : transactions;

export const blocksByHashes = [{ epoch: Cardano.EpochNo(currentEpoch.number - 3) } as Cardano.ExtendedBlockInfo];

/** Provider stub for testing returns ChainHistoryProvider-compatible object */
export const mockChainHistoryProvider = (props: { rewardAccount?: Cardano.RewardAccount } = {}) => ({
  blocksByHashes: jest.fn().mockResolvedValue(blocksByHashes),
  healthCheck: jest.fn().mockResolvedValue({ ok: true }),
  transactionsByAddresses: jest
    .fn()
    .mockImplementationOnce((args: TransactionsByAddressesArgs) =>
      filterAndPaginateTransactions(
        withCertificatesStakeCredential(queryTransactionsResult.pageResults, props.rewardAccount),
        args
      )
    )
    .mockResolvedValue({
      pageResults: [...queryTransactionsResult.pageResults],
      totalResultCount: 0 // Returning total result count 0 after the first result will make the address discovery stop
    }),
  transactionsByHashes: jest.fn().mockResolvedValue(queryTransactionsResult)
});

/**
 * A different provider stub for testing, supports delay to simulate network requests.
 *
 * @returns ChainHistoryProvider that returns data that is slightly different to mockChainHistoryProvider.
 */
export const mockChainHistoryProvider2 = (delayMs: number) => {
  const delayedJestFn = <T>(resolvedValue: T) =>
    jest.fn().mockImplementationOnce(() => delay(delayMs).then(() => resolvedValue));

  return {
    blocksByHashes: delayedJestFn(blocksByHashes),
    healthCheck: delayedJestFn({ ok: true }),
    transactionsByAddresses: jest.fn((args: TransactionsByAddressesArgs) =>
      delay(delayMs).then(() => filterAndPaginateTransactions(queryTransactionsResult2.pageResults, args))
    ),
    transactionsByHashes: delayedJestFn(queryTransactionsResult2)
  };
};

export type ChainHistoryProviderStub = ReturnType<typeof mockChainHistoryProvider>;
