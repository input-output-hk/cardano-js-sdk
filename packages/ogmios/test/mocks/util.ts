import { ServerHealth } from '@cardano-ogmios/client';

export const HEALTH_RESPONSE_BODY: ServerHealth = {
  currentEra: 'alonzo',
  lastKnownTip: {
    height: 100,
    id: '9ef43ab6e234fcf90d103413096c7da752da2f45b15e1259f43d476afd12932c',
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
  network: 'preprod',
  networkSynchronization: 1,
  startTime: '2022-03-13T16:18:59.932519677Z',
  version: '1'
};
