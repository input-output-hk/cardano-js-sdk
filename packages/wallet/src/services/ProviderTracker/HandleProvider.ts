import {
  Cardano,
  HandleIssuer,
  HandleProvider,
  HandleResolution,
  HealthCheckResponse,
  NetworkInfoProvider,
  ProviderError,
  ProviderFailure,
  ResolveHandlesArgs
} from '@cardano-sdk/core';

import { IHandle } from '@koralabs/handles-public-api-interfaces';
import axios, { AxiosAdapter, AxiosInstance } from 'axios';

export interface KoraLabsHandleProviderDeps {
  serverUrl: string;
  networkInfoProvider: NetworkInfoProvider;
  adapter?: AxiosAdapter;
}

export const toHandleResolution = ({
  apiResponse,
  tip
}: {
  apiResponse: IHandle;
  tip: Cardano.Tip;
}): HandleResolution => ({
  handle: apiResponse.name,
  hasDatum: apiResponse.hasDatum,
  issuer: HandleIssuer.KoraLabs,
  resolvedAddresses: {
    cardano: Cardano.PaymentAddress(apiResponse.resolved_addresses.ada)
  },
  resolvedAt: {
    hash: tip.hash,
    slot: tip.slot
  }
});

export class KoraLabsHandleProvider implements HandleProvider {
  private axiosClient: AxiosInstance;
  private networkInfoProvider: NetworkInfoProvider;

  constructor({ serverUrl, networkInfoProvider, adapter }: KoraLabsHandleProviderDeps) {
    this.networkInfoProvider = networkInfoProvider;
    this.axiosClient = axios.create({
      adapter,
      baseURL: serverUrl
    });
  }

  async resolveHandles(args: ResolveHandlesArgs): Promise<HandleResolution[]> {
    try {
      const tip = await this.networkInfoProvider.ledgerTip();
      const response = await Promise.all(
        args.handles.map((handle) => this.axiosClient.get<IHandle>(`/handles/${handle}`))
      );
      return response.map(({ data: apiResponse }) => toHandleResolution({ apiResponse, tip }));
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
