import { InvalidStringError, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { ResponsePoolParameters, createProvider, getExactlyOneObject, graphqlPoolParametersToCore } from '../src/util';

describe('util', () => {
  describe('createProvider', () => {
    const providerFunctions = { fn: jest.fn() };
    let provider: typeof providerFunctions;

    beforeEach(() => {
      providerFunctions.fn.mockReset();
      provider = createProvider(() => providerFunctions)('https://url');
    });

    it('returns provider with functions from provided implementation', async () => {
      providerFunctions.fn.mockResolvedValueOnce('result');
      expect(await provider.fn()).toBe('result');
    });

    it('maps InvalidStringError to ProviderError{InvalidResponse}', async () => {
      const error = new InvalidStringError('error');
      providerFunctions.fn.mockRejectedValueOnce(error);
      await expect(provider.fn()).rejects.toThrowError(new ProviderError(ProviderFailure.InvalidResponse, error));
    });

    it('maps other errors to ProviderError{Unknown}', async () => {
      const error = new Error('other error');
      providerFunctions.fn.mockRejectedValueOnce(error);
      await expect(provider.fn()).rejects.toThrowError(new ProviderError(ProviderFailure.Unknown, error));
    });
  });

  describe('getExactlyOneObject', () => {
    it("returns first array item if it's length is 1", () => {
      expect(getExactlyOneObject(['item'], 'obj')).toBe('item');
    });

    it('throws ProviderError{NotFound} on empty response', async () => {
      expect(() => getExactlyOneObject(undefined, 'obj')).toThrow(ProviderFailure.NotFound);
      expect(() => getExactlyOneObject(null, 'obj')).toThrow(ProviderFailure.NotFound);
      expect(() => getExactlyOneObject([], 'obj')).toThrow(ProviderFailure.NotFound);
    });

    it('throws ProviderError{InvalidResponse} with multiple objects', async () => {
      expect(() => getExactlyOneObject([{}, {}], 'obj')).toThrow(ProviderFailure.InvalidResponse);
    });

    it('throws ProviderError{InvalidResponse} with null/undefined object', async () => {
      expect(() => getExactlyOneObject([null], 'obj')).toThrow(ProviderFailure.InvalidResponse);
      expect(() => getExactlyOneObject([undefined], 'obj')).toThrow(ProviderFailure.InvalidResponse);
    });
  });

  describe('graphqlPoolParametersToCore', () => {
    it('converts graphql PoolParameters to core PoolParameters', () => {
      const gqlPoolParameters: ResponsePoolParameters = {
        cost: 5n,
        margin: { denominator: 2, numerator: 1 },
        metadata: {
          description: 'description',
          ext: {
            pool: {
              id: 'e4b1c8ec89415ce6349755a1aa44b4affbb5f1248ff29943d190c715'
            },
            serial: 1
          },
          extDataUrl: 'https://extdata',
          extSigUrl: 'https://extsig',
          extVkey: 'poolmd_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4stmm43m',
          homepage: 'https://homepage',
          name: 'name',
          ticker: 'TICKER'
        },
        metadataJson: {
          hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad',
          url: 'https://url'
        },
        owners: [{ address: 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27' }],
        pledge: 1000n,
        poolRegistrationCertificate: {
          transaction: { hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad' }
        },
        relays: [{ __typename: 'RelayByName', hostname: 'some.hostname' }],
        rewardAccount: { address: 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27' },
        vrf: '8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0'
      };
      const poolId = 'pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh';
      expect(graphqlPoolParametersToCore(gqlPoolParameters, poolId)).toEqual({
        cost: gqlPoolParameters.cost,
        id: poolId,
        margin: gqlPoolParameters.margin,
        metadata: gqlPoolParameters.metadata,
        metadataJson: gqlPoolParameters.metadataJson,
        owners: [gqlPoolParameters.owners[0].address],
        pledge: gqlPoolParameters.pledge,
        relays: gqlPoolParameters.relays,
        rewardAccount: gqlPoolParameters.rewardAccount.address,
        vrf: gqlPoolParameters.vrf
      });
    });
  });
});
