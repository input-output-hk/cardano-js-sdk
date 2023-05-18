import { HandleInfo, HandleProvider, ResolveHandlesArgs } from './types';
import { HealthCheckResponse, NetworkInfoProvider, ProviderError, ProviderFailure } from '../..';
import { IHandle } from '@koralabs/handles-public-api-interfaces';
import { toHandleInfo } from './utils';
import axios, { AxiosInstance } from 'axios';

export interface KoraLabsHandleProviderDeps {
  serverUrl: string;
  networkInfoProvider: NetworkInfoProvider;
}

export class KoraLabsHandleProvider implements HandleProvider {
  private axiosClient: AxiosInstance;
  private networkInfoProvider: NetworkInfoProvider;

  constructor({ serverUrl, networkInfoProvider }: KoraLabsHandleProviderDeps) {
    this.networkInfoProvider = networkInfoProvider;
    this.axiosClient = axios.create({
      baseURL: serverUrl
    });
  }

  async resolveHandles(args: ResolveHandlesArgs): Promise<HandleInfo[]> {
    try {
      const tip = await this.networkInfoProvider.ledgerTip();
      const response = await Promise.all(
        args.handles.map((handle) => this.axiosClient.get<IHandle>(`/handles/${handle}`))
      );
      return response.map(({ data: apiResponse }) => toHandleInfo({ apiResponse, tip }));
    } catch (error) {
      if (axios.isAxiosError(error)) {
        throw new ProviderError(ProviderFailure.Unhealthy, error, `Failed to resolve handles due to: ${error.message}`);
      }
      throw error;
    }
  }
  async healthCheck(): Promise<HealthCheckResponse> {
    try {
      await this.axiosClient.get('/health');
      return { ok: true };
    } catch {
      return { ok: false };
    }
  }
}

export { HandleInfo, Handle } from './types';
