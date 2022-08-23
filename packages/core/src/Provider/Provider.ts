import { Percent } from '../Cardano';
import { Tip } from '@cardano-ogmios/schema';

export type HealthCheckResponse = {
  ok: boolean;
  localNode?: {
    ledgerTip?: Tip;
    networkSync?: Percent;
  };
};

export interface Provider {
  start?(): Promise<void>;
  /**
   * @throws ProviderError
   */
  close?(): Promise<void>;
  /**
   * @throws ProviderError
   */
  healthCheck(): Promise<HealthCheckResponse>;
}
