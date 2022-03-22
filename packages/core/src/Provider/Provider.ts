export interface Provider {
  /**
   * @throws ProviderError
   */
  healthCheck(): Promise<{
    ok: boolean;
  }>;
}
