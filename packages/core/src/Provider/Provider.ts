import { Percent } from '../Cardano';
// eslint-disable-next-line import/no-extraneous-dependencies
import { Tip } from '@cardano-ogmios/schema';

export type HealthCheckResponse = {
  ok: boolean;
  localNode?: {
    ledgerTip?: Tip;
    networkSync?: Percent;
  };
};

export interface Provider {
  /**
   * @throws ProviderError
   */
  healthCheck(): Promise<HealthCheckResponse>;
}
