import type { Cardano } from '../index.js';

// eslint-disable-next-line import/no-extraneous-dependencies
import type { Logger } from 'ts-log';
import type { Percent } from '@cardano-sdk/util';
import type { Tip } from '../Cardano/index.js';

export type HealthCheckResponse = {
  ok: boolean;
  localNode?: {
    ledgerTip?: Tip;
    networkSync?: Percent;
  };
  projectedTip?: Cardano.Tip;
  reason?: string;
};

export interface ProviderDependencies {
  logger: Logger;
}

export interface Provider {
  /**
   * @throws ProviderError
   */
  healthCheck(): Promise<HealthCheckResponse>;
}

export type HttpProviderConfigPaths<T extends Provider> = { [methodName in keyof T]: string };
