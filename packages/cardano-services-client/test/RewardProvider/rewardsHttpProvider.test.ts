import { Cardano } from '@cardano-sdk/core';
import { config, healthCheckResponseWithState } from '../util.js';
import { rewardsHttpProvider } from '../../src/index.js';
import { toSerializableObject } from '@cardano-sdk/util';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';
import type { Reward } from '@cardano-sdk/core';

describe('rewardsHttpProvider', () => {
  const rewardAccount = Cardano.RewardAccount('stake_test1uzxvhl83q8ujv2yvpy6n2krvpdlqqx28h7e9vsk6re43h3c3kufy6');
  let axiosMock: MockAdapter;
  beforeAll(() => {
    axiosMock = new MockAdapter(axios);
  });

  afterEach(() => {
    axiosMock.reset();
  });

  afterAll(() => {
    axiosMock.restore();
  });
  describe('healthCheck', () => {
    it('is ok if 200 response body is { ok: true, localNode }', async () => {
      axiosMock.onPost().replyOnce(200, healthCheckResponseWithState);
      const provider = rewardsHttpProvider(config);
      await expect(provider.healthCheck()).resolves.toEqual(healthCheckResponseWithState);
    });

    it('is not ok if 200 response body is { ok: false }', async () => {
      axiosMock.onPost().replyOnce(200, { ok: false });
      const provider = rewardsHttpProvider(config);
      await expect(provider.healthCheck()).resolves.toEqual({ ok: false });
    });
  });
  test('rewardAccountBalance doesnt throw', async () => {
    const expectedResponse = toSerializableObject(BigInt('0'));
    axiosMock.onPost().replyOnce(200, expectedResponse);
    const provider = rewardsHttpProvider(config);
    const response = toSerializableObject(await provider.rewardAccountBalance({ rewardAccount }));
    expect(response).toEqual(expectedResponse);
  });
  test('rewardsHistory doesnt throw', async () => {
    const expectedResponse = toSerializableObject(new Map<Cardano.RewardAccount, Reward[]>());
    axiosMock.onPost().replyOnce(200, expectedResponse);
    const provider = rewardsHttpProvider(config);
    const response = toSerializableObject(
      await provider.rewardsHistory({
        epochs: { lowerBound: Cardano.EpochNo(10), upperBound: Cardano.EpochNo(20) },
        rewardAccounts: [rewardAccount]
      })
    );
    expect(response).toEqual(expectedResponse);
  });
});
