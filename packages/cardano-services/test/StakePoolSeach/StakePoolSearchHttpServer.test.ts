/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */
// import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { DbSyncStakePoolSearchProvider, StakePoolSearchHttpServer, StakePoolSearchServerConfig } from '../../src';
import { Pool } from 'pg';
import { getPort } from 'get-port-please';
import got from 'got';
// import { util } from '@cardano-sdk/core';

const BAD_REQUEST_STRING = 'Response code 400 (Bad Request)';
const APPLICATION_CBOR = 'application/cbor';
const APPLICATION_JSON = 'application/json';

// const serializeProviderArg = (arg: unknown) => JSON.stringify({ args: [util.toSerializableObject(arg)] });

describe('StakePoolSearchHttpServer', () => {
  let stakePoolSearchProvider: DbSyncStakePoolSearchProvider;
  let stakePoolSearchHttpServer: StakePoolSearchHttpServer;
  let port: number;
  let apiUrlBase: string;
  let config: StakePoolSearchServerConfig;
  beforeAll(async () => {
    port = await getPort();
    apiUrlBase = `http://localhost:${port}`;
    config = { listen: { port } };
  });

  afterEach(async () => {
    jest.resetAllMocks();
  });

  describe('healthy and successful submission', () => {
    beforeAll(async () => {
      stakePoolSearchProvider = new DbSyncStakePoolSearchProvider(new Pool());
      jest.spyOn(stakePoolSearchProvider, 'queryStakePools');
      stakePoolSearchHttpServer = StakePoolSearchHttpServer.create({ stakePoolSearchProvider }, config);
      await stakePoolSearchHttpServer.initialize();
      await stakePoolSearchHttpServer.start();
    });

    afterAll(async () => {
      await stakePoolSearchHttpServer.shutdown();
    });

    describe('/health', () => {
      it('forwards the stakePoolSearchProvider health response', async () => {
        const res = await got(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.statusCode).toBe(200);
        expect(JSON.parse(res.body)).toEqual({ ok: true });
      });
    });

    describe('/search', () => {
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect(
          (
            await got.post(`${apiUrlBase}/search`, {
              json: { args: [] }
            })
          ).statusCode
        ).toEqual(200);
        expect(stakePoolSearchProvider.queryStakePools).toHaveBeenCalledTimes(1);
      });

      it('returns a 400 coded response if the wrong content type header is used', async () => {
        try {
          await got.post(`${apiUrlBase}/search`, {
            headers: { 'Content-Type': APPLICATION_CBOR }
          });
          throw new Error('fail');
        } catch (error: any) {
          expect(error.response.statusCode).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
          expect(stakePoolSearchProvider.queryStakePools).toHaveBeenCalledTimes(0);
        }
      });

      // describe('or condition', () => {
      //   it('search pools by identifier filter', async () => {});
      //   it('search pools by status filter', async () => {});
      //   it('search pools by pledgeMet filter', async () => {});
      //   it('search pools by identifier and status filters', async () => {});
      //   it('search pools by identifier and pledgeMet filters', async () => {});
      //   it('search pools by identifier, status and pledgeMet filters', async () => {});
      // });
      // describe('and condition', () => {
      //   it('search pools by identifier filter', async () => {});
      //   it('search pools by status filter', async () => {});
      //   it('search pools by pledgeMet filter', async () => {});
      //   it('search pools by identifier and status filters', async () => {});
      //   it('search pools by identifier and pledgeMet filters', async () => {});
      //   it('search pools by identifier, status and pledgeMet filters', async () => {});
      // });
    });
  });

  //   describe('healthy but failing submission', () => {
  //     describe('/submit', () => {
  //       // eslint-disable-next-line max-len
  //       it('returns a 400 coded response with detail in the body to a transaction containing a domain violation', async () => {
  //         const stubErrors = [new Cardano.TxSubmissionErrors.BadInputsError({ badInputs: [] })];
  //         txSubmitProvider = {
  //           healthCheck: jest.fn(() => Promise.resolve({ ok: true })),
  //           submitTx: jest.fn(() => Promise.reject(stubErrors))
  //         };
  //         txSubmitHttpServer = TxSubmitHttpServer.create({ txSubmitProvider }, config);
  //         await txSubmitHttpServer.initialize();
  //         await txSubmitHttpServer.start();
  //         try {
  //           await got.post(`${apiUrlBase}/submit`, {
  //             body: Buffer.from(new Uint8Array()).toString(),
  //             headers: { 'Content-Type': APPLICATION_CBOR }
  //           });
  //           throw new Error('fail');
  //           // eslint-disable-next-line @typescript-eslint/no-explicit-any
  //         } catch (error: any) {
  //           expect(error.response.statusCode).toBe(400);
  //           expect(JSON.parse(error.response.body)[0].name).toEqual(stubErrors[0].name);
  //           expect(txSubmitProvider.submitTx).toHaveBeenCalledTimes(1);
  //           await txSubmitHttpServer.shutdown();
  //         }
  //       });
  //     });
  //   });
});
