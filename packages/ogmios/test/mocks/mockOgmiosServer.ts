/* eslint-disable sonarjs/no-duplicate-string */
import { Schema, UnknownResultError } from '@cardano-ogmios/client';
import { Server, createServer } from 'http';
import WebSocket from 'ws';

const HEALTH_RESPONSE_BODY = {
  connectionStatus: 'connected',
  currentEpoch: 192,
  currentEra: 'Alonzo',
  lastKnownTip: {
    blockNo: 3_391_731,
    hash: '9ef43ab6e234fcf90d103413096c7da752da2f45b15e1259f43d476afd12932c',
    slot: 52_819_355
  },
  lastTipUpdate: '2022-03-13T16:22:51.423778138Z',
  metrics: {
    activeConnections: 0,
    runtimeStats: {
      cpuTime: 1_346_462_892,
      currentHeapSize: 331,
      gcCpuTime: 1_217_193_590,
      maxHeapSize: 367
    },
    sessionDurations: {
      max: 0,
      mean: 0,
      min: 0
    },
    totalConnections: 0,
    totalMessages: 0,
    totalUnrouted: 0
  },
  networkSynchronization: 1,
  slotInEpoch: 244_955,
  startTime: '2022-03-13T16:18:59.932519677Z'
};

export interface MockOgmiosServerConfig {
  healthCheck?: {
    response: {
      success: boolean;
      failWith?: Error;
      networkSynchronization?: number;
    };
  };
  submitTx?: {
    response: {
      success: boolean;
      failWith?: {
        type: 'eraMismatch' | 'beforeValidityInterval';
      };
    };
  };
  stateQuery?: {
    eraSummaries?: {
      response: {
        success: boolean;
        failWith?: {
          type: 'unknownResultError' | 'connectionError';
        };
      };
    };
    systemStart?: {
      response: {
        success: boolean;
        failWith?: {
          type: 'queryUnavailableInEra';
        };
      };
    };
    stakeDistribution?: {
      response: {
        success: boolean;
        failWith?: {
          type: 'queryUnavailableInEra';
        };
      };
    };
  };
  submitTxHook?: (data?: Uint8Array) => void;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const handleSubmitTx = async (config: MockOgmiosServerConfig, args: any, send: (result: unknown) => void) => {
  let result: Schema.SubmitSuccess | Schema.SubmitFail;

  if (config.submitTx?.response.success) {
    result = { SubmitSuccess: { txId: '###' } };
  } else if (config.submitTx?.response.failWith?.type === 'eraMismatch') {
    result = { SubmitFail: [{ eraMismatch: { ledgerEra: 'Shelley', queryEra: 'Alonzo' } }] };
  } else if (config.submitTx?.response.failWith?.type === 'beforeValidityInterval') {
    result = {
      SubmitFail: [
        { outsideOfValidityInterval: { currentSlot: 23, interval: { invalidBefore: 42, invalidHereafter: null } } }
      ]
    };
  } else {
    throw new Error('Unknown mock response');
  }
  if (config.submitTxHook) await config.submitTxHook(Uint8Array.from(Buffer.from(args.submit, 'hex')));
  send(result);
};

const handleQuery = async (query: string, config: MockOgmiosServerConfig, send: (result: unknown) => void) => {
  let result:
    | Schema.EraSummary[]
    | Date
    | 'QueryUnavailableInCurrentEra'
    | Schema.PoolDistribution
    | UnknownResultError;
  switch (query) {
    case 'eraSummaries':
      if (config.stateQuery?.eraSummaries?.response.success) {
        result = [
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
      } else if (config.stateQuery?.eraSummaries?.response.failWith?.type === 'unknownResultError') {
        result = new UnknownResultError('');
      } else if (config.stateQuery?.eraSummaries?.response.failWith?.type === 'connectionError') {
        result = new UnknownResultError({ code: 'ECONNREFUSED' });
      } else {
        throw new Error('Unknown mock response');
      }
      break;
    case 'systemStart':
      if (config.stateQuery?.systemStart?.response.success) {
        result = new Date(1_506_203_091_000);
      } else if (config.stateQuery?.systemStart?.response.failWith?.type === 'queryUnavailableInEra') {
        result = 'QueryUnavailableInCurrentEra';
      } else {
        throw new Error('Unknown mock response');
      }
      break;
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
      throw new Error('Query not mocked');
  }
  send(result);
};

export const createMockOgmiosServer = (config: MockOgmiosServerConfig): Server => {
  const server = createServer((req, res) => {
    if (config.healthCheck?.response.success === false) {
      res.statusCode = 500;
      return res.end('{"error":"INTERNAL_SERVER_ERROR"}');
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
        networkSynchronization: config.healthCheck?.response.networkSynchronization
      })
    );
  });
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
          await handleSubmitTx(config, args, send);
          break;
        case 'Query':
          await handleQuery(args.query, config, send);
          break;
        default:
          throw new Error('Method not mocked');
      }
    });
  });
  return server;
};

export const listenPromise = (server: Server, port: number, hostname?: string): Promise<Server> =>
  new Promise((resolve, reject) => {
    server.listen(port, hostname, () => resolve(server));
    server.on('error', reject);
  });

export const serverClosePromise = (server: Server): Promise<void> =>
  new Promise((resolve, reject) => server.close((error) => (error ? reject(error) : resolve())));
