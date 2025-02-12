/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano, HandleResolution, util } from '@cardano-sdk/core';
import type { Responses } from '@blockfrost/blockfrost-js';

import { BlockfrostClient } from '../../src/blockfrost/BlockfrostClient';
import { BlockfrostHandleProvider, adaHandlePolicyId } from '../../src';
import { logger } from '@cardano-sdk/util-dev';
import { mockResponses } from '../util';

describe('BlockfrostHandleProvider', () => {
  let request: jest.Mock;
  let provider: BlockfrostHandleProvider;

  beforeEach(() => {
    request = jest.fn();
    const client = { request } as unknown as BlockfrostClient;
    provider = new BlockfrostHandleProvider(client, logger);
  });

  describe('resolveHandles', () => {
    test('classic handle', async () => {
      const handle = 'bob';
      const mockedAssetId = Cardano.AssetId.fromParts(adaHandlePolicyId, Cardano.AssetName(util.utf8ToHex(handle)));
      const mockedAddress =
        'addr1qxqs59lphg8g6qndelq8xwqn60ag3aeyfcp33c2kdp46a09re5df3pzwwmyq946axfcejy5n4x0y99wqpgtp2gd0k09qsgy6pz';

      const mockedAssetResponse = [
        {
          address: mockedAddress,
          quantity: '1'
        }
      ] as Responses['asset_addresses'];

      const mockedUtxoResponse = [
        {
          address: mockedAddress,
          amount: [
            {
              quantity: '42000000',
              unit: 'lovelace'
            }
          ],
          block: '7eb8e27d18686c7db9a18f8bbcfe34e3fed6e047afaa2d969904d15e934847e6',
          data_hash: '9e478573ab81ea7a8e31891ce0648b81229f408d596a3483e6f4f9b92d3cf710',
          inline_datum: null,
          output_index: 0,
          reference_script_hash: null,
          tx_hash: '39a7a284c2a0948189dc45dec670211cd4d72f7b66c5726c08d9b3df11e44d58'
        }
      ] as Responses['address_utxo_content'];

      mockResponses(request, [
        [`assets/${mockedAssetId.toString()}/addresses`, mockedAssetResponse],
        [`addresses/${mockedAddress}/utxos/${mockedAssetId.toString()}`, mockedUtxoResponse]
      ]);

      const response = await provider.resolveHandles({ handles: [handle] });

      expect(response).toMatchObject<HandleResolution[]>([
        {
          cardanoAddress: Cardano.PaymentAddress(mockedAddress),
          handle,
          hasDatum: false,
          policyId: adaHandlePolicyId
        }
      ]);
    });

    test('Virtual SubHandle', async () => {
      const handle = 'bob@somedomain';
      const mockedAssetId = Cardano.AssetId.fromParts(adaHandlePolicyId, Cardano.AssetName(util.utf8ToHex(handle)));
      const mockedAddress =
        'addr1qxqs59lphg8g6qndelq8xwqn60ag3aeyfcp33c2kdp46a09re5df3pzwwmyq946axfcejy5n4x0y99wqpgtp2gd0k09qsgy6pz';
      const datumHash = '9e478573ab81ea7a8e31891ce0648b81229f408d596a3483e6f4f9b92d3cf710';

      const mockedAssetResponse = [
        {
          address: mockedAddress,
          quantity: '1'
        }
      ] as Responses['asset_addresses'];

      const mockedUtxoResponse = [
        {
          address: mockedAddress,
          amount: [
            {
              quantity: '42000000',
              unit: 'lovelace'
            }
          ],
          block: '7eb8e27d18686c7db9a18f8bbcfe34e3fed6e047afaa2d969904d15e934847e6',
          data_hash: '9e478573ab81ea7a8e31891ce0648b81229f408d596a3483e6f4f9b92d3cf710',
          inline_datum: null,
          output_index: 0,
          reference_script_hash: null,
          tx_hash: '39a7a284c2a0948189dc45dec670211cd4d72f7b66c5726c08d9b3df11e44d58'
        }
      ] as Responses['address_utxo_content'];

      const mockedScriptsResponse = {
        json_value: {
          resolved_addresses: {
            ada: mockedAddress
          }
        }
      } as Responses['script_datum'];

      mockResponses(request, [
        [`assets/${mockedAssetId.toString()}/addresses`, mockedAssetResponse],
        [`addresses/${mockedAddress}/utxos/${mockedAssetId.toString()}`, mockedUtxoResponse],
        [`scripts/datum/${datumHash}`, mockedScriptsResponse]
      ]);

      const response = await provider.resolveHandles({ handles: [handle] });

      expect(response).toMatchObject<HandleResolution[]>([
        {
          cardanoAddress: Cardano.PaymentAddress(mockedAddress),
          handle,
          hasDatum: false,
          policyId: adaHandlePolicyId
        }
      ]);
    });
  });
});
