import { Server, createServer } from 'http';
import { SubmitFail, SubmitSuccess } from '@cardano-ogmios/schema';
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
  submitTx: {
    response: {
      success: boolean;
      failWith?: {
        type: 'eraMismatch';
      };
    };
  };
}

export const createMockOgmiosServer = (config: MockOgmiosServerConfig): Server => {
  const server = createServer((req, res) => {
    res.setHeader('Content-Type', 'application/json');

    if (req.method !== 'GET' || req.url !== '/health') {
      res.statusCode = 405;
      res.end('{"error":"METHOD_NOT_ALLOWED"}');
      return;
    }

    res.end(JSON.stringify(HEALTH_RESPONSE_BODY));
  });
  const wss = new WebSocket.Server({
    server
  });
  wss.on('connection', (ws) => {
    ws.on('message', (data) => {
      const { methodname, mirror } = JSON.parse(data as string);
      if (methodname === 'SubmitTx') {
        let result: SubmitSuccess | SubmitFail;
        if (config.submitTx.response.success) {
          result = 'SubmitSuccess';
        } else if (config.submitTx.response.failWith?.type === 'eraMismatch') {
          result = { SubmitFail: [{ eraMismatch: { ledgerEra: 'Shelley', queryEra: 'Alonzo' } }] };
        } else {
          throw new Error('Unknown mock response');
        }
        ws.send(
          JSON.stringify({
            methodname: 'SubmitTx',
            reflection: mirror,
            result,
            servicename: 'ogmios',
            type: 'jsonwsp/response',
            version: '1.0'
          })
        );
      }
    });
  });
  return server;
};
