import { Cardano } from '..';

// eslint-disable-next-line import/no-extraneous-dependencies
import { Logger } from 'ts-log';
import { Percent } from '@cardano-sdk/util';
import { Tip } from '../Cardano/types/Block';

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
