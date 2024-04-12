import { Cardano, HandleProvider, ProviderError, ProviderFailure, ResolveHandlesArgs } from '@cardano-sdk/core';
import { HandleHttpService, HttpServer, emptyStringHandleResolutionRequestError } from '../../src';
import { getRandomPort } from 'get-port-please';
import { logger } from '@cardano-sdk/util-dev';
import axios, { AxiosResponse } from 'axios';

const parseBody = (data: unknown): { body?: unknown; rawBody: string } => {
  if (typeof data === 'string') {
    const rawBody = data;
    let body: unknown;

    try {
      body = JSON.parse(data);
    } catch {
      return { rawBody };
    }

    return { body, rawBody };
  }

  return { body: data, rawBody: JSON.stringify(data) };
};

describe('HandleHttpService', () => {
  let port: number;
  let server: HttpServer;

  const createServer = async (handleProvider: HandleProvider) => {
    const service = new HandleHttpService({ handleProvider, logger });

    port = await getRandomPort();
    server = new HttpServer({ listen: { port } }, { logger, services: [service] });

    await server.initialize();
    await server.start();
  };

  const performRequest = async (
    path: 'health' | 'resolve',
    args: Partial<ResolveHandlesArgs>
  ): Promise<{
    body?: unknown;
    message?: string;
    rawBody?: string;
    status?: number;
    statusText?: string;
  }> => {
    let res: AxiosResponse;

    try {
      res = await axios.post(`http://localhost:${port}/v1.0.0/handle/${path}`, JSON.stringify(args), {
        headers: { 'Content-Type': 'application/json' }
      });
    } catch (error) {
      if (!axios.isAxiosError(error)) throw error;

      const { message, response } = error;

      if (!response)
        return {
          message,
          statusText: `${typeof error.status === 'string' ? error.status : JSON.stringify(error.status)}`
        };

      const { data, status, statusText } = response;

      return { message, status, statusText, ...parseBody(data) };
    }

    const { data, status, statusText } = res;

    return { status, statusText, ...parseBody(data) };
  };

  afterEach(() => server.shutdown());

  describe('unhealthy state', () => {
    beforeEach(() =>
      createServer({
        getPolicyIds: () => Promise.resolve([]),
        healthCheck: () => Promise.resolve({ ok: false, reason: 'test reason' }),
        resolveHandles: () => {
          throw new ProviderError(ProviderFailure.Unhealthy, new Error('test error'), 'test details');
        }
      })
    );

    it('HandleHttpService /health gives correct unhealthy response', async () => {
      const { body, status } = await performRequest('health', {});

      expect({ body, status }).toEqual({ body: { ok: false, reason: 'test reason' }, status: 200 });
    });

    it('HandleHttpService /resolve fails with correct error details', async () => {
      const { message, rawBody, status, statusText } = await performRequest('resolve', { handles: ['test'] });

      expect({ message, status, statusText }).toEqual({
        message: 'Request failed with status code 500',
        status: 500,
        statusText: 'Internal Server Error'
      });
      expect(rawBody).toMatch(/UNHEALTHY \(test details\) due to\\n Error: test error/);
    });
  });

  describe('healthy state', () => {
    beforeEach(() =>
      createServer({
        getPolicyIds: () => Promise.resolve([]),
        healthCheck: () => Promise.resolve({ ok: true }),
        resolveHandles: () => Promise.resolve([null])
      })
    );

    it('HandleHttpService /health gives correct healthy response', async () => {
      const { body, status } = await performRequest('health', {});

      expect({ body, status }).toEqual({ body: { ok: true }, status: 200 });
    });

    it('HandleHttpService /resolve responds with provider response', async () => {
      const { body, status } = await performRequest('resolve', { handles: ['test'] });

      expect({ body, status }).toEqual({ body: [null], status: 200 });
    });
  });

  it('valid not empty response is openApi schema compliant', async () => {
    await createServer({
      getPolicyIds: () => Promise.resolve([<Cardano.PolicyId>'test_policy']),
      healthCheck: () => Promise.resolve({ ok: true }),
      resolveHandles: () =>
        Promise.resolve([
          {
            cardanoAddress: <Cardano.PaymentAddress>'test_address',
            handle: 'test',
            hasDatum: true,
            policyId: <Cardano.PolicyId>'test_policy',
            resolvedAt: { hash: <Cardano.BlockId>'test_hash', slot: <Cardano.Slot>42 }
          }
        ])
    });

    const { body, status } = await performRequest('resolve', { handles: ['test'] });

    expect({ body, status }).toEqual({
      body: [
        {
          cardanoAddress: 'test_address',
          handle: 'test',
          hasDatum: true,
          policyId: 'test_policy',
          resolvedAt: { hash: 'test_hash', slot: 42 }
        }
      ],
      status: 200
    });
  });

  it('converts BadRequest ProviderError into a 400 HTTP response', async () => {
    await createServer({
      getPolicyIds: () => Promise.resolve([]),
      healthCheck: () => Promise.resolve({ ok: true }),
      resolveHandles: () => Promise.reject(emptyStringHandleResolutionRequestError())
    });

    const { message, rawBody, status, statusText } = await performRequest('resolve', { handles: [''] });

    expect({ message, status, statusText }).toEqual({
      message: 'Request failed with status code 400',
      status: 400,
      statusText: 'Bad Request'
    });
    expect(rawBody).toMatch(/Empty string handle can't be resolved/);
  });
});
