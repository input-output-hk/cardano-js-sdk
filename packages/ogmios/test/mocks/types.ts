import { Schema } from '@cardano-ogmios/client';

export type HealthCheckResponse = {
  success: boolean;
  failWith?: Error;
  blockNo?: number;
  networkSynchronization?: number;
};

export type TxSubmitResponse = {
  success: boolean;
  failWith?: {
    type: 'eraMismatch' | 'beforeValidityInterval';
  };
};

export type EraSummariesResponse = {
  eraSummaries?: Schema.EraSummary[];
  success: boolean;
  failWith?: {
    type: 'unknownResultError';
  };
};

export type GenesisConfigResponse = {
  success: boolean;
  config?: Schema.GenesisShelley;
  failWith?: {
    type: 'queryUnavailableInCurrentEraError' | 'eraMismatchError' | 'unknownResultError';
  };
};

export type SystemStartResponse = {
  success: boolean;
  systemStart?: Date;
  failWith?: {
    type: 'queryUnavailableInEra';
  };
};

export type StakeDistributionResponse = {
  success: boolean;
  failWith?: {
    type: 'queryUnavailableInEra';
  };
};

export type InvocationState = {
  health: number;
  txSubmit: number;
};
