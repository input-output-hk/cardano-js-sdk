/* eslint-disable sonarjs/no-duplicate-string */
import { BlocksByHashesQuery, Sdk } from '../../src/sdk';
import { Cardano, WalletProvider } from '@cardano-sdk/core';
import { createGraphQLWalletProviderFromSdk } from '../../src/WalletProvider/CardanoGraphQLWalletProvider';

describe('CardanoGraphQLWalletProvider.queryBlocksByHashes', () => {
  let provider: WalletProvider;
  const sdk = { BlocksByHashes: jest.fn() };
  const block = {
    blockNo: 1,
    confirmations: 4,
    epoch: { number: 5 },
    hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad',
    issuer: {
      id: 'pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh',
      poolParameters: [
        {
          vrf: 'vrf_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4s99zvg8'
        }
      ]
    },
    nextBlock: { hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cae' },
    previousBlock: { hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99caa' },
    size: 6n,
    slot: { date: '2019-10-12T07:20:50.52Z', number: 2, slotInEpoch: 3 },
    totalFees: 123n,
    totalOutput: 700n,
    transactionsAggregate: {
      count: 3
    }
  } as NonNullable<NonNullable<BlocksByHashesQuery['queryBlock']>[0]>;
  const blockHash = Cardano.BlockId(block.hash);

  beforeEach(() => (provider = createGraphQLWalletProviderFromSdk(sdk as unknown as Sdk)));
  afterEach(() => sdk.BlocksByHashes.mockReset());

  it('makes a graphql query and coerces result to core types', async () => {
    sdk.BlocksByHashes.mockResolvedValueOnce({
      queryBlock: [block, { ...block, hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99caa' }]
    });
    const blocks = await provider.queryBlocksByHashes([
      blockHash,
      Cardano.BlockId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99caa')
    ]);
    expect(blocks).toHaveLength(2);
    expect(blocks[0]).toEqual({
      confirmations: block.confirmations,
      date: new Date(block.slot.date),
      epoch: block.epoch.number,
      epochSlot: block.slot.slotInEpoch,
      fees: block.totalFees,
      header: {
        blockNo: block.blockNo,
        hash: block.hash,
        slot: block.slot.number
      },
      nextBlock: block.nextBlock.hash,
      previousBlock: block.previousBlock.hash,
      size: Number(block.size),
      slotLeader: block.issuer.id,
      totalOutput: block.totalOutput,
      txCount: block.transactionsAggregate!.count,
      vrf: block.issuer.poolParameters[0].vrf
    });
  });

  it('returns an empty array on undefined response', async () => {
    sdk.BlocksByHashes.mockResolvedValueOnce({});
    expect(await provider.queryBlocksByHashes([blockHash])).toEqual([]);
  });

  it('assumes there are no transactions if transactionsAggregate is undefined', async () => {
    sdk.BlocksByHashes.mockResolvedValueOnce({ queryBlock: [{ ...block, transactionsAggregate: undefined }] });
    const [response] = await provider.queryBlocksByHashes([blockHash]);
    expect(response.txCount).toBe(0);
  });
});
