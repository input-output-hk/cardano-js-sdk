export interface Provider {
  healthCheck(): Promise<{
    ok: boolean;
  }>;
}
