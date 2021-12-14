/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable max-len */
import { BlocksByHashesQuery, Sdk } from '../../src/sdk';
import { Cardano, ProviderFailure, WalletProvider } from '@cardano-sdk/core';
import { createGraphQLWalletProviderFromSdk } from '../../src/WalletProvider/CardanoGraphQLWalletProvider';

jest.mock('../../src/util', () => {
  const actual = jest.requireActual('../../src/util');
  return {
    ...actual,
    getExactlyOneObject: jest.fn().mockImplementation((...args) => actual.getExactlyOneObject(...args))
  };
});
const { getExactlyOneObject } = jest.requireMock('../../src/util');

describe('CardanoGraphQLWalletProvider', () => {
  let provider: WalletProvider;
  const sdk = {
    BlocksByHashes: jest.fn(),
    GenesisParameters: jest.fn(),
    ProtocolParameters: jest.fn(),
    Tip: jest.fn()
  };

  beforeEach(() => {
    provider = createGraphQLWalletProviderFromSdk(sdk as unknown as Sdk);
  });

  afterEach(() => {
    sdk.Tip.mockReset();
    getExactlyOneObject.mockClear();
  });

  describe('currentWalletProtocolParameters', () => {
    const protocolParams = {
      coinsPerUtxoWord: 34_482,
      keyDeposit: 2_000_000,
      maxCollateralInputs: 3,
      maxTxSize: 16_384,
      maxValSize: 5000,
      minFeeA: 44,
      minFeeB: 155_381,
      minPoolCost: 340_000_000,
      poolDeposit: 500_000_000,
      protocolVersion: {
        major: 4,
        minor: 0,
        patch: 1
      }
    };

    it('makes a graphql query and coerces result to core types', async () => {
      sdk.ProtocolParameters.mockResolvedValueOnce({
        queryProtocolParameters: [protocolParams]
      });
      expect(await provider.currentWalletProtocolParameters()).toEqual({
        coinsPerUtxoWord: protocolParams.coinsPerUtxoWord,
        maxCollateralInputs: protocolParams.maxCollateralInputs,
        maxTxSize: protocolParams.maxTxSize,
        maxValueSize: protocolParams.maxValSize,
        minFeeCoefficient: protocolParams.minFeeA,
        minFeeConstant: protocolParams.minFeeB,
        minPoolCost: protocolParams.minPoolCost,
        poolDeposit: protocolParams.poolDeposit,
        protocolVersion: protocolParams.protocolVersion,
        stakeKeyDeposit: protocolParams.keyDeposit
      });
    });

    it('uses util.getExactlyOneObject to validate response', async () => {
      sdk.ProtocolParameters.mockResolvedValueOnce({});
      await expect(provider.currentWalletProtocolParameters()).rejects.toThrow(ProviderFailure.NotFound);
      expect(getExactlyOneObject).toBeCalledTimes(1);
    });
  });

  describe('genesisParameters', () => {
    const genesisParams = {
      activeSlotsCoeff: 0.05,
      epochLength: 432_000,
      maxKESEvolutions: 62,
      maxLovelaceSupply: 45_000_000_000_000_000n,
      networkMagic: 764_824_073,
      securityParam: 2160,
      slotLength: 1,
      slotsPerKESPeriod: 129_600,
      systemStart: '2017-09-23T21:44:51.000Z',
      updateQuorum: 5
    };

    it('makes a graphql query and coerces result to core types', async () => {
      sdk.GenesisParameters.mockResolvedValueOnce({
        queryShelleyGenesis: [genesisParams]
      });
      expect(await provider.genesisParameters()).toEqual({
        activeSlotsCoefficient: genesisParams.activeSlotsCoeff,
        epochLength: genesisParams.epochLength,
        maxKesEvolutions: genesisParams.maxKESEvolutions,
        maxLovelaceSupply: BigInt(genesisParams.maxLovelaceSupply),
        networkMagic: genesisParams.networkMagic,
        securityParameter: genesisParams.securityParam,
        slotLength: genesisParams.slotLength,
        slotsPerKesPeriod: genesisParams.slotsPerKESPeriod,
        systemStart: new Date(genesisParams.systemStart),
        updateQuorum: genesisParams.updateQuorum
      } as Cardano.CompactGenesis);
    });

    it('uses util.getExactlyOneObject to validate response', async () => {
      sdk.GenesisParameters.mockResolvedValueOnce({});
      await expect(provider.genesisParameters()).rejects.toThrow(ProviderFailure.NotFound);
      expect(getExactlyOneObject).toBeCalledTimes(1);
    });
  });

  describe('ledgerTip', () => {
    const tip = {
      blockNo: 1,
      hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad',
      slot: { number: 2 }
    };

    it('makes a graphql query and coerces result to core types', async () => {
      sdk.Tip.mockResolvedValueOnce({
        queryBlock: [tip]
      });
      expect(await provider.ledgerTip()).toEqual({
        blockNo: tip.blockNo,
        hash: tip.hash,
        slot: tip.slot.number
      });
    });

    it('uses util.getExactlyOneObject to validate response', async () => {
      sdk.Tip.mockResolvedValueOnce({});
      await expect(provider.ledgerTip()).rejects.toThrow(ProviderFailure.NotFound);
      expect(getExactlyOneObject).toBeCalledTimes(1);
    });
  });

  describe('queryBlocksByHashes', () => {
    const block = {
      blockNo: 1,
      confirmations: 4,
      epoch: { number: 5 },
      fees: 123n,
      hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad',
      issuer: {
        id: 'pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh',
        vrf: 'vrf_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4s99zvg8'
      },
      nextBlock: { hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cae' },
      previousBlock: { hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99caa' },
      size: 6n,
      slot: { date: '2019-10-12T07:20:50.52Z', number: 2, slotInEpoch: 3 },
      totalOutput: 700n,
      transactionsAggregate: {
        count: 3
      }
    } as NonNullable<NonNullable<BlocksByHashesQuery['queryBlock']>[0]>;
    const blockHash = Cardano.BlockId(block.hash);

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
        fees: block.fees,
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
        vrf: block.issuer.vrf
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
});
