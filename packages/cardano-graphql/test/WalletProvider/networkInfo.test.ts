import { ProviderFailure } from '@cardano-sdk/core';
import { getExactlyOneObject } from '../../src/util';
import { networkInfoProvider } from '../../src/WalletProvider/networkInfo';

describe('CardanoGraphQLWalletProvider.networkInfo', () => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let sdk: any;
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

  beforeEach(() => {
    sdk = { NetworkInfo: jest.fn() };
  });

  it('makes a graphql query and coerces result to core types', async () => {
    sdk.NetworkInfo.mockResolvedValueOnce({
      queryAda: [ada],
      queryBlock: [block],
      queryTimeSettings: [timeSettings]
    });
    const getNetworkInfo = networkInfoProvider({
      getExactlyOneObject,
      sdk
    });
    expect(await getNetworkInfo()).toEqual({
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
    const getNetworkInfo = networkInfoProvider({
      getExactlyOneObject,
      sdk
    });
    await expect(getNetworkInfo()).rejects.toThrow(ProviderFailure.InvalidResponse);
  });

  it('uses util.getExactlyOneObject to validate response', async () => {
    const getExactlyOneObjectMock = jest.fn().mockImplementation(getExactlyOneObject);
    sdk.NetworkInfo.mockResolvedValueOnce({});
    const getNetworkInfo = networkInfoProvider({
      getExactlyOneObject: getExactlyOneObjectMock,
      sdk
    });
    await expect(getNetworkInfo()).rejects.toThrow(ProviderFailure.NotFound);
    expect(getExactlyOneObjectMock).toBeCalledTimes(1);
  });
});
