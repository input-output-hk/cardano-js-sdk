/* eslint-disable sonarjs/no-nested-switch */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { HEALTH_RESPONSE_BODY } from './util.js';
import { createServer } from 'http';
import WebSocket from 'ws';
import delay from 'delay';
import fs from 'fs';
import path from 'path';
import type {
  EraMismatch,
  EraSummary,
  IntersectionFound,
  IntersectionNotFound,
  PointOrOrigin
} from '@cardano-ogmios/schema';
import type {
  EraSummariesResponse,
  GenesisConfigResponse,
  HealthCheckResponse,
  InvocationState,
  StakeDistributionResponse,
  SystemStartResponse,
  TxSubmitResponse
} from './types.js';
import type { Milliseconds } from '@cardano-sdk/core';
import type { Schema } from '@cardano-ogmios/client';
import type { Server } from 'http';

export interface MockOgmiosServerConfig {
  healthCheck?: {
    response: HealthCheckResponse;
    /**
     * The Ogmios clients use the server health check during
     * initialization, so a number of invocations must skipped depending on the test scenario.
     */
    skipInvocations?: number;
  };
  submitTx?: {
    response: TxSubmitResponse | TxSubmitResponse[];
  };
  stateQuery?: {
    eraSummaries?: {
      response: EraSummariesResponse | EraSummariesResponse[];
    };
    genesisConfig?: {
      response: GenesisConfigResponse | GenesisConfigResponse[];
    };
    systemStart?: {
      response: SystemStartResponse | SystemStartResponse[];
    };
    stakeDistribution?: {
      response: StakeDistributionResponse;
    };
  };
  /** Also used for chainSync.start */
  findIntersect?: (points: PointOrOrigin[]) => IntersectionFound | IntersectionNotFound;
  chainSync?: {
    requestNext: {
      /** Filenames of test vectors */
      responses: string[];
    };
  };
  submitTxHook?: (data?: Uint8Array) => void;
  maxConnections?: number;
}

export const mockGenesisConfig = {
  activeSlotsCoefficient: '1/20',
  epochLength: 86_400,
  maxKesEvolutions: 120,
  maxLovelaceSupply: 45_000_000_000_000_000,
  network: 'testnet',
  networkMagic: 2,
  securityParameter: 432,
  slotLength: 1,
  slotsPerKesPeriod: 86_400,
  systemStart: '2022-08-09T00:00:00Z',
  updateQuorum: 5
} as Schema.CompactGenesis;

export const mockEraSummaries: EraSummary[] = [
  {
    end: { epoch: 74, slot: 1_598_400, time: 31_968_000 },
    parameters: { epochLength: 21_600, safeZone: 4320, slotLength: 20 },
    start: { epoch: 0, slot: 0, time: 0 }
  },
  {
    end: { epoch: 102, slot: 13_694_400, time: 44_064_000 },
    parameters: { epochLength: 432_000, safeZone: 129_600, slotLength: 1 },
    start: { epoch: 74, slot: 1_598_400, time: 31_968_000 }
  }
];

const handleFindIntersect = (args: any, config: MockOgmiosServerConfig, send: (result: unknown) => void) => {
  const response = config.findIntersect?.(args.points);
  if (!response) {
    throw new Error('findIntersect config not found');
  }
  send(response);
};

const handleRequestNext = (config: MockOgmiosServerConfig, send: (result: unknown) => void) => {
  const fileName = config.chainSync?.requestNext.responses.shift();
  if (!fileName) {
    throw new Error('No next event in config requestNext');
  }
  // This will lose precision with large numbers
  send(JSON.parse(fs.readFileSync(path.join(__dirname, './chainSyncEvents', fileName), 'utf-8')));
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const handleSubmitTx = async (
  invocations: InvocationState,
  config: MockOgmiosServerConfig,
  args: any,
  send: (result: unknown) => void
) => {
  const { submitTx, submitTxHook } = config;
  if (!submitTx) throw new Error('Missing submitTx in mock config');

  let { response } = submitTx;
  if (!Array.isArray(response)) response = [response];

  let result: Schema.SubmitSuccess | Schema.SubmitFail;

  if (invocations.txSubmit >= response.length) {
    invocations.txSubmit = response.length - 1;
  }

  if (response[invocations.txSubmit].success) {
    result = { SubmitSuccess: { txId: '###' } };
    ++invocations.txSubmit;
  } else if (response[invocations.txSubmit].failWith?.type === 'eraMismatch') {
    ++invocations.txSubmit;
    result = { SubmitFail: [{ eraMismatch: { ledgerEra: 'Shelley', queryEra: 'Alonzo' } }] };
  } else if (response[invocations.txSubmit].failWith?.type === 'beforeValidityInterval') {
    result = {
      SubmitFail: [
        { outsideOfValidityInterval: { currentSlot: 23, interval: { invalidBefore: 42, invalidHereafter: null } } }
      ]
    };
    ++invocations.txSubmit;
  } else {
    throw new Error('Unknown mock response');
  }
  if (submitTxHook) await submitTxHook(Uint8Array.from(Buffer.from(args.submit, 'hex')));
  send(result);
};

// eslint-disable-next-line complexity, sonarjs/cognitive-complexity, max-statements
const handleQuery = async (query: string, config: MockOgmiosServerConfig, send: (result: unknown) => void) => {
  let result: any;
  switch (query) {
    case 'eraSummaries': {
      const responseConfig = config.stateQuery?.eraSummaries?.response;
      const response = Array.isArray(responseConfig) ? responseConfig.shift() : responseConfig;
      if (response?.success) {
        result = response.eraSummaries || mockEraSummaries;
      } else if (response?.failWith?.type === 'unknownResultError') {
        result = 'unknown';
      } else {
        throw new Error('Unknown mock response');
      }
      break;
    }
    case 'systemStart': {
      const responseConfig = config.stateQuery?.systemStart?.response;
      const response = Array.isArray(responseConfig) ? responseConfig.shift() : responseConfig;
      if (response?.success) {
        result = response.systemStart || new Date(1_506_203_091_000);
      } else if (response?.failWith?.type === 'queryUnavailableInEra') {
        result = 'QueryUnavailableInCurrentEra';
      } else {
        throw new Error('Unknown mock response');
      }
      break;
    }
    case 'genesisConfig': {
      const responseConfig = config.stateQuery?.genesisConfig?.response;
      const response = Array.isArray(responseConfig) ? responseConfig.shift() : responseConfig;
      if (response?.success) {
        result = response.config || mockGenesisConfig;
      } else if (response?.failWith?.type) {
        switch (response?.failWith?.type) {
          case 'queryUnavailableInCurrentEraError': {
            result = 'QueryUnavailableInCurrentEra';
            break;
          }
          case 'eraMismatchError': {
            result = { eraMismatch: { ledgerEra: 'Byron', queryEra: 'Shelley' } } as EraMismatch;
            break;
          }
          case 'unknownResultError': {
            result = 'unknown';
            break;
          }
          default:
            throw new Error(`Unknown failedWith.type: ${response?.failWith.type}`);
        }
      } else {
        throw new Error(`Invalid response config: ${response}`);
      }
      break;
    }
    case 'stakeDistribution':
      if (config.stateQuery?.stakeDistribution?.response.success) {
        result = {
          pool1la4ghj4w4f8p4yk4qmx0qvqmzv6592ee9rs0vgla5w6lc2nc8w5: {
            stake: '10098109508/40453712883332027',
            vrf: '4e4a2e82dc455449bf5f1f6d249470963cf97389b5dc4d2118fe21625f50f518'
          },
          pool1lad5j5kawu60qljfqh02vnazxrahtaaj6cpaz4xeluw5xf023cg: {
            stake: '14255969766/40453712883332027',
            vrf: '474a6d2a44b51add62d8f2fd8fe80abc722bf84478479b617ad05b39aaa84971'
          },
          pool1llugtz5r4t6m7xz6es4qu7cszllm5y3uvx3ast5a9jzlv7h3xdu: {
            stake: '98763124501826/40453712883332027',
            vrf: 'dc1c0fd7d2fd95b6e9bf0e50ab5cb722edbd7d6e85b7d53323884d429ec6a83c'
          },
          pool1lu6ll4rcxm92059ggy6uym2p804s5hcwqyyn5vyqhy35kuxtn2f: {
            stake: '1494933206/40453712883332027',
            vrf: '4a13d5e99a1868788057bf401fdb4379b7846290dd948918839981088059a564'
          }
        };
      } else if (config.stateQuery?.stakeDistribution?.response.failWith?.type === 'queryUnavailableInEra') {
        result = 'QueryUnavailableInCurrentEra';
      } else {
        throw new Error('Unknown mock response');
      }
      break;
    default:
      throw new Error(`Query not mocked: ${query}`);
  }
  send(result);
};

export type MockServer = Server & { wss: WebSocket.Server; invocations: InvocationState };

// eslint-disable-next-line sonarjs/cognitive-complexity
export const createMockOgmiosServer = (config: MockOgmiosServerConfig): MockServer => {
  const invocations: InvocationState = {
    health: 0,
    txSubmit: 0
  };

  const server = createServer((req, res) => {
    if (req.url === '/health') {
      if (
        config.healthCheck?.response.success === false &&
        invocations.health === (config.healthCheck?.skipInvocations || 0)
      ) {
        res.statusCode = 500;
        return res.end('{"error":"INTERNAL_SERVER_ERROR"}');
      }
      invocations.health++;
    }
    res.setHeader('Content-Type', 'application/json');

    if (req.method !== 'GET' || req.url !== '/health') {
      res.statusCode = 405;
      res.end('{"error":"METHOD_NOT_ALLOWED"}');
      return;
    }

    res.end(
      JSON.stringify({
        ...HEALTH_RESPONSE_BODY,
        lastKnownTip: config.healthCheck?.response.blockNo
          ? { ...HEALTH_RESPONSE_BODY.lastKnownTip, blockNo: config.healthCheck.response.blockNo }
          : HEALTH_RESPONSE_BODY.lastKnownTip,
        networkSynchronization:
          config.healthCheck?.response.networkSynchronization ?? HEALTH_RESPONSE_BODY.networkSynchronization
      })
    );
  });
  if (config.maxConnections) {
    server.maxConnections = config.maxConnections;
  }
  const wss = new WebSocket.Server({
    server
  });
  wss.on('connection', (ws) => {
    ws.on('message', async (data) => {
      const { args, methodname, mirror } = JSON.parse(data as string);
      const send = (result: unknown) =>
        ws.send(
          JSON.stringify({
            methodname,
            reflection: mirror,
            result,
            servicename: 'ogmios',
            type: 'jsonwsp/response',
            version: '1.0'
          })
        );
      switch (methodname) {
        case 'SubmitTx':
          await handleSubmitTx(invocations, config, args, send);
          break;
        case 'Query':
          await handleQuery(args.query, config, send);
          break;
        case 'FindIntersect':
          handleFindIntersect(args, config, send);
          break;
        case 'RequestNext':
          handleRequestNext(config, send);
          break;
        default:
          throw new Error(`Method not mocked: ${methodname}`);
      }
    });
  });
  (server as any).wss = wss;
  (server as any).invocations = invocations;
  return server as MockServer;
};

export const listenPromise = (server: Server, port: number, hostname?: string): Promise<Server> =>
  new Promise((resolve, reject) => {
    server.listen(port, hostname, () => resolve(server));
    server.on('error', reject);
  });

export const serverClosePromise = (server: Server): Promise<void> =>
  new Promise((resolve, reject) => server.close((error) => (error ? reject(error) : resolve())));

export const waitForWsClientsDisconnect = (server: Server, timeout: Milliseconds): Promise<void> =>
  Promise.race<any>([
    new Promise<void>((resolve) => {
      const wss: WebSocket.Server = (server as any).wss;
      let numClients = wss.clients.size;
      if (numClients === 0) {
        resolve();
      } else {
        for (const client of wss.clients) {
          // eslint-disable-next-line no-loop-func
          client.on('close', () => {
            if (--numClients === 0) {
              resolve();
            }
          });
        }
      }
    }),
    delay(timeout).then(() => {
      throw new Error(`Websocket clients did not disconnect in ${timeout}`);
    })
  ]);
