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
    CurrentProtocolParameters: jest.fn(),
    GenesisParameters: jest.fn(),
    NetworkInfo: jest.fn(),
    Tip: jest.fn()
  };

  beforeEach(() => {
    provider = createGraphQLWalletProviderFromSdk(sdk as unknown as Sdk);
  });

  afterEach(() => {
    sdk.BlocksByHashes.mockReset();
    sdk.CurrentProtocolParameters.mockReset();
    sdk.GenesisParameters.mockReset();
    sdk.Tip.mockReset();
    sdk.NetworkInfo.mockReset();
    getExactlyOneObject.mockClear();
  });

  describe('currentWalletProtocolParameters', () => {
    const protocolParams = {
      coinsPerUtxoWord: 34_482,
      maxCollateralInputs: 3,
      maxTxSize: 16_384,
      maxValueSize: 5000,
      minFeeCoefficient: 44,
      minFeeConstant: 155_381,
      minPoolCost: 340_000_000,
      poolDeposit: 500_000_000,
      protocolVersion: {
        major: 4,
        minor: 0,
        patch: 1
      },
      stakeKeyDeposit: 2_000_000
    };

    it('makes a graphql query and coerces result to core types', async () => {
      sdk.CurrentProtocolParameters.mockResolvedValueOnce({
        queryProtocolParametersAlonzo: [protocolParams]
      });
      expect(await provider.currentWalletProtocolParameters()).toEqual({
        coinsPerUtxoWord: protocolParams.coinsPerUtxoWord,
        maxCollateralInputs: protocolParams.maxCollateralInputs,
        maxTxSize: protocolParams.maxTxSize,
        maxValueSize: protocolParams.maxValueSize,
        minFeeCoefficient: protocolParams.minFeeCoefficient,
        minFeeConstant: protocolParams.minFeeConstant,
        minPoolCost: protocolParams.minPoolCost,
        poolDeposit: protocolParams.poolDeposit,
        protocolVersion: protocolParams.protocolVersion,
        stakeKeyDeposit: protocolParams.stakeKeyDeposit
      });
    });

    it('uses util.getExactlyOneObject to validate response', async () => {
      sdk.CurrentProtocolParameters.mockResolvedValueOnce({});
      await expect(provider.currentWalletProtocolParameters()).rejects.toThrow(ProviderFailure.NotFound);
      expect(getExactlyOneObject).toBeCalledTimes(1);
    });
  });

  describe('networkInfo', () => {
    const block = {
      epoch: {
        activeStakeAggregate: {
          quantitySum: 300_000n
        },
        number: 123,
        startedAt: {
          date: '2021-12-16T16:25:03.994Z'
        }
      },
      totalLiveStake: 100_000_000n
    };
    const timeSettings = {
      epochLength: 60 * 60,
      slotLength: 1
    };
    const ada = {
      supply: { circulating: 10_000_000n, max: 100_000_000n, total: 20_000_000n }
    };

    it('makes a graphql query and coerces result to core types', async () => {
      sdk.NetworkInfo.mockResolvedValueOnce({
        queryAda: [ada],
        queryBlock: [block],
        queryTimeSettings: [timeSettings]
      });
      expect(await provider.networkInfo()).toEqual({
        currentEpoch: {
          end: { date: new Date('2021-12-16T17:25:03.994Z') },
          number: block.epoch.number,
          start: { date: new Date(block.epoch.startedAt.date) }
        },
        lovelaceSupply: {
          circulating: BigInt(ada.supply.circulating),
          max: BigInt(ada.supply.max),
          total: BigInt(ada.supply.total)
        },
        stake: {
          active: block.epoch.activeStakeAggregate.quantitySum,
          live: block.totalLiveStake
        }
      });
    });

    it('throws if active stake is null', async () => {
      sdk.NetworkInfo.mockResolvedValueOnce({
        queryAda: [ada],
        queryBlock: [{ ...block, epoch: { ...block.epoch, activeStakeAggregate: null } }],
        queryTimeSettings: [timeSettings]
      });
      await expect(provider.networkInfo()).rejects.toThrow(ProviderFailure.InvalidResponse);
    });

    it('uses util.getExactlyOneObject to validate response', async () => {
      sdk.NetworkInfo.mockResolvedValueOnce({});
      await expect(provider.networkInfo()).rejects.toThrow(ProviderFailure.NotFound);
      expect(getExactlyOneObject).toBeCalledTimes(1);
    });
  });

  describe('genesisParameters', () => {
    const networkConstants = {
      activeSlotsCoefficient: 0.05,
      maxKESEvolutions: 62,
      networkMagic: 764_824_073,
      securityParameter: 2160,
      slotsPerKESPeriod: 129_600,
      systemStart: '2017-09-23T21:44:51.000Z',
      updateQuorum: 5
    };
    const timeSettings = {
      epochLength: 100_000,
      slotLength: 1
    };
    const ada = {
      supply: { max: 100_000_000n }
    };

    it('makes a graphql query and coerces result to core types', async () => {
      sdk.GenesisParameters.mockResolvedValueOnce({
        queryAda: [ada],
        queryNetworkConstants: [networkConstants],
        queryTimeSettings: [timeSettings]
      });
      expect(await provider.genesisParameters()).toEqual({
        activeSlotsCoefficient: networkConstants.activeSlotsCoefficient,
        epochLength: timeSettings.epochLength,
        maxKesEvolutions: networkConstants.maxKESEvolutions,
        maxLovelaceSupply: BigInt(ada.supply.max),
        networkMagic: networkConstants.networkMagic,
        securityParameter: networkConstants.securityParameter,
        slotLength: timeSettings.slotLength,
        slotsPerKesPeriod: networkConstants.slotsPerKESPeriod,
        systemStart: new Date(networkConstants.systemStart),
        updateQuorum: networkConstants.updateQuorum
      } as Cardano.CompactGenesis);
    });

    // eslint-disable-next-line sonarjs/no-identical-functions
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
      hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad',
      issuer: {
        id: 'pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh',
        vrf: 'vrf_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4s99zvg8'
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
