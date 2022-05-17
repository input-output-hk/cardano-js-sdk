export type HealthCheckResponse = {
  ok: boolean;
};

export interface Provider {
  close?(): Promise<void>;
  /**
   * @throws ProviderError
   */
  healthCheck(): Promise<HealthCheckResponse>;
}
