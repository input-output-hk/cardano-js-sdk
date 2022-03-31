export type HealthCheckResponse = {
  ok: boolean;
};

export interface Provider {
  /**
   * @throws ProviderError
   */
  healthCheck(): Promise<HealthCheckResponse>;
}
