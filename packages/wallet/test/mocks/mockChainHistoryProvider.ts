/* eslint-disable max-len */
import { Cardano, Paginated } from '@cardano-sdk/core';
import { currentEpoch, ledgerTip, stakeKeyHash } from './mockData';
import { somePartialStakePools } from '@cardano-sdk/util-dev';
import delay from 'delay';

export const getRandomTxId = () =>
  Array.from({ length: 64 })
    .map(() => Math.floor(Math.random() * 16).toString(16))
    .join('');

const address = Cardano.Address(
  'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
);

export const generateTxAlonzo = (qty: number): Cardano.TxAlonzo[] =>
  [...Array.from({ length: qty }).keys()].map((index) => ({
    blockHeader: {
      blockNo: 10_669,
      slot: 37_834_496
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
        invalidHereafter: 20_000 + index
      }
    },
    id: Cardano.TransactionId(getRandomTxId()),
    index,
    txSize: 100_000,
    witness: {
      signatures: new Map()
    }
  }));

export const queryTransactionsResult: Paginated<Cardano.TxAlonzo> = {
  pageResults: [
    {
      blockHeader: {
        blockNo: 10_050,
        slot: ledgerTip.slot - 150_000
      } as Cardano.PartialBlockHeader,
      body: {
        certificates: [
          {
            __typename: Cardano.CertificateType.StakeKeyRegistration,
            stakeKeyHash
          },
          {
            __typename: Cardano.CertificateType.StakeDelegation,
            poolId: somePartialStakePools[0].id,
            stakeKeyHash
          }
        ],
        fee: 200_000n,
        inputs: [
          {
            address: Cardano.Address(
              'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
            ),
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],
        outputs: [
          {
            address: Cardano.Address(
              'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
            ),
            value: { coins: 5_000_000n }
          },
          {
            address: Cardano.Address(
              'addr_test1qplfzem2xsc29wxysf8wkdqrm4s4mmncd40qnjq9sk84l3tuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q52ukj5'
            ),
            value: { coins: 5_000_000n }
          },
          {
            address: Cardano.Address(
              'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
            ),
            value: { coins: 9_825_963n }
          }
        ],
        validityInterval: {
          invalidHereafter: ledgerTip.slot + 1
        }
      },
      id: Cardano.TransactionId('12fa9af65e21b36ec4dc4cbce478e911d52585adb46f2b4fe3d6563e7ee5a61a'),
      index: 0,
      txSize: 100_000,
      witness: {
        signatures: new Map()
      }
    },
    {
      blockHeader: {
        blockNo: 10_100,
        slot: ledgerTip.slot - 100_000
      },
      body: {
        inputs: [
          {
            address: Cardano.Address(
              'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
            ),
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],
        outputs: [
          {
            address: Cardano.Address(
              'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
            ),
            value: { coins: 5_000_000n }
          }
        ],
        validityInterval: {
          invalidHereafter: ledgerTip.slot + 1
        }
      },
      id: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad')
    } as Cardano.TxAlonzo
  ],
  totalResultCount: 2
};

export const queryTransactionsResult2: Paginated<Cardano.TxAlonzo> = {
  pageResults: [
    ...queryTransactionsResult.pageResults,
    {
      ...queryTransactionsResult.pageResults[1],
      blockHeader: {
        blockNo: 10_150,
        slot: ledgerTip.slot - 50_000
      },
      id: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99caa')
    } as Cardano.TxAlonzo
  ],
  totalResultCount: 3
};

const queryTransactions = () => jest.fn().mockResolvedValueOnce(queryTransactionsResult);

export const blocksByHashes = [{ epoch: currentEpoch.number - 3 } as Cardano.ExtendedBlockInfo];

/**
 * Provider stub for testing
 *
 * returns ChainHistoryProvider-compatible object
 */
export const mockChainHistoryProvider = () => ({
  blocksByHashes: jest.fn().mockResolvedValue(blocksByHashes),
  healthCheck: jest.fn().mockResolvedValue({ ok: true }),
  transactionsByAddresses: queryTransactions(),
  transactionsByHashes: queryTransactions()
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
    transactionsByAddresses: delayedJestFn(queryTransactionsResult2),
    transactionsByHashes: delayedJestFn(queryTransactionsResult2)
  };
};

export type ChainHistoryProviderStub = ReturnType<typeof mockChainHistoryProvider>;
