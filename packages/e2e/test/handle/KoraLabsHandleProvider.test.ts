// cSpell:ignore kora subhandles
/* eslint-disable no-magic-numbers */
/* eslint-disable camelcase */
import { Cardano, HandleResolution } from '@cardano-sdk/core';
import { KoraLabsHandleProvider } from '@cardano-sdk/cardano-services-client';

const handlePolicyId = 'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a';

const config = {
  policyId: Cardano.PolicyId(handlePolicyId),
  serverUrl: 'https://preprod.api.handle.me/'
};

const checkHandleResolution = (source: string, result: unknown) => {
  expect(typeof result).toBe('object');

  const { backgroundImage, cardanoAddress, handle, hasDatum, image, policyId, profilePic } = result as HandleResolution;

  expect(['string', 'undefined']).toContain(typeof backgroundImage);
  expect(typeof cardanoAddress).toBe('string');
  expect(cardanoAddress.startsWith('addr_')).toBe(true);
  expect(handle).toBe(source);
  expect(typeof hasDatum).toBe('boolean');
  expect(typeof image).toBe('string');
  expect(policyId).toBe(handlePolicyId);
  expect(['string', 'undefined']).toContain(typeof profilePic);
};

// Fix flaky tests LW-13058
describe.skip('KoraLabsHandleProvider', () => {
  let provider: KoraLabsHandleProvider;

  beforeAll(() => {
    provider = new KoraLabsHandleProvider(config);
  });

  describe('resolveHandles', () => {
    test('HandleProvider should resolve a single handle', async () => {
      const [result] = await provider.resolveHandles({ handles: ['test_handle_1'] });

      checkHandleResolution('test_handle_1', result);
    });

    test('HandleProvider should resolve multiple handles', async () => {
      const [result2, result3] = await provider.resolveHandles({ handles: ['test_handle_2', 'test_handle_3'] });

      checkHandleResolution('test_handle_2', result2);
      checkHandleResolution('test_handle_3', result3);
    });

    test('HandleProvider should return null for for not found handle', async () => {
      const [resultN, result1] = await provider.resolveHandles({ handles: ['does_not_exists', 'test_handle_1'] });

      expect(resultN).toBe(null);
      checkHandleResolution('test_handle_1', result1);
    });

    test('HandleProvider should resolve handle, subhandles and virtual subhandles', async () => {
      const [result1, result2, result3] = await provider.resolveHandles({
        handles: ['handle', 'ada.handle', 'space@ada.handle']
      });

      checkHandleResolution('handle', result1);
      checkHandleResolution('ada.handle', result2);
      checkHandleResolution('space@ada.handle', result3);
    });
  });

  describe('health checks', () => {
    test('HandleProvider should get ok health check', async () => {
      const result = await provider.healthCheck();

      expect(result.ok).toEqual(true);
    });
  });

  describe('get policy ids', () => {
    test('HandleProvider should get handle policy ids', async () => {
      const policyIds = await provider.getPolicyIds();

      expect(policyIds.length).toEqual(1);
      expect(policyIds).toEqual([config.policyId]);
    });
  });
});
