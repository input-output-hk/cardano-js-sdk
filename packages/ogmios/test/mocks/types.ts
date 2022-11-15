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
  success: boolean;
  failWith?: {
    type: 'unknownResultError' | 'connectionError';
  };
};

export type SystemStartResponse = {
  success: boolean;
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
  txSubmit: number;
};
