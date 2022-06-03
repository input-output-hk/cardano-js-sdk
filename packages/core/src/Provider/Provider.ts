export type HealthCheckResponse = {
  ok: boolean;
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
