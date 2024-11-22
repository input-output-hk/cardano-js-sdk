/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano, DRepInfo } from '@cardano-sdk/core';
import type { Responses } from '@blockfrost/blockfrost-js';

import { BlockfrostClient } from '../../src/blockfrost/BlockfrostClient';
import { BlockfrostDRepProvider } from '../../src';
import { logger } from '@cardano-sdk/util-dev';
import { mockResponses } from '../util';

describe('BlockfrostDRepProvider', () => {
  let request: jest.Mock;
  let provider: BlockfrostDRepProvider;

  beforeEach(() => {
    request = jest.fn();
    const client = { request } as unknown as BlockfrostClient;
    provider = new BlockfrostDRepProvider(client, logger);
  });

  describe('getDRep', () => {
    const mockedDRepId = Cardano.DRepID('drep15cfxz9exyn5rx0807zvxfrvslrjqfchrd4d47kv9e0f46uedqtc');
    const mockedAssetResponse = {
      active: true,
      active_epoch: 420,
      amount: '2000000',
      drep_id: 'drep15cfxz9exyn5rx0807zvxfrvslrjqfchrd4d47kv9e0f46uedqtc',
      has_script: true,
      hex: 'a61261172624e8333ceff098648d90f8e404e2e36d5b5f5985cbd35d'
    } as Responses['drep'];

    test('getDRepInfo', async () => {
      mockResponses(request, [
        [
          `governance/dreps/${mockedDRepId}`,
          {
            ...mockedAssetResponse
          }
        ]
      ]);

      const response = await provider.getDRepInfo({ id: mockedDRepId });

      expect(response).toMatchObject<DRepInfo>({
        active: true,
        activeEpoch: Cardano.EpochNo(420),
        amount: 2_000_000n,
        hasScript: true,
        id: mockedDRepId
      });
    });
  });
});
