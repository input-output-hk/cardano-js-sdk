import { Cardano } from '..';
import { Percent } from '../Cardano';
// eslint-disable-next-line import/no-extraneous-dependencies
import { Tip } from '@cardano-ogmios/schema';

export type HealthCheckResponse = {
  ok: boolean;
  localNode?: {
    ledgerTip?: Tip;
    networkSync?: Percent;
  };
  projectedTip?: Cardano.Tip;
};

export interface Provider {
  /**
   * @throws ProviderError
   */
  healthCheck(): Promise<HealthCheckResponse>;
}
