import {
  Cardano,
  HealthCheckResponse,
  NetworkInfoProvider,
  Point,
  ProviderError,
  ProviderFailure,
  ResolveHandlesArgs
} from '@cardano-sdk/core';
import { Uri } from '@cardano-sdk/core/dist/cjs/Asset';

// eslint-disable-next-line import/no-extraneous-dependencies
import { IHandle } from '@koralabs/handles-public-api-interfaces';
import axios, { AxiosAdapter, AxiosInstance } from 'axios';

/**
 * The KoraLabsHandleProvider endpoint paths.
 */
const paths = {
  handles: '/handles',
  healthCheck: '/health'
};
export type Handle = string;

export interface KoraLabsHandleProviderDeps {
  serverUrl: string;
  networkInfoProvider: NetworkInfoProvider;
  adapter?: AxiosAdapter;
  policyId: Cardano.PolicyId;
}

export interface HandleResolution {
  policyId: Cardano.PolicyId;
  handle: Handle;
  resolvedAddresses: {
    cardano: Cardano.PaymentAddress;
    hasDatum: boolean;
    defaultForStakeKey?: Handle;
    defaultForPaymentKey?: Handle;
  };
  resolvedAt: Point;
  backgroundImage?: Uri;
  profilePic?: Uri;
}

export const toHandleResolution = ({
  apiResponse,
  tip,
  policyId
}: {
  apiResponse: IHandle;
  tip: Cardano.Tip;
  policyId: Cardano.PolicyId;
}): HandleResolution => ({
  handle: apiResponse.name,
  policyId,
  resolvedAddresses: {
    cardano: Cardano.PaymentAddress(apiResponse.resolved_addresses.ada),
    hasDatum: apiResponse.hasDatum
  },
  resolvedAt: {
    hash: tip.hash,
    slot: tip.slot
  }
});

/**
 * Creates a KoraLabs Provider instance to resolve Standard Handles
 *
 * @param KoraLabsHandleProviderDeps The configuration object fot the KoraLabs Handle Provider.
 */
export class KoraLabsHandleProvider {
  private axiosClient: AxiosInstance;
  private networkInfoProvider: NetworkInfoProvider;
  policyId: Cardano.PolicyId;

  constructor({ serverUrl, networkInfoProvider, adapter, policyId }: KoraLabsHandleProviderDeps) {
    this.networkInfoProvider = networkInfoProvider;
    this.axiosClient = axios.create({
      adapter,
      baseURL: serverUrl
    });
    this.policyId = policyId;
  }

  async resolveHandles(args: ResolveHandlesArgs): Promise<Array<HandleResolution | null>> {
    try {
      const tip = await this.networkInfoProvider.ledgerTip();
      const results = await Promise.all(
        args.handles.map((handle) => this.axiosClient.get<IHandle>(`${paths.handles}/${handle}`))
      );
      return results.map(({ data: apiResponse }) => toHandleResolution({ apiResponse, policyId: this.policyId, tip }));
    } catch (error) {
      if (axios.isAxiosError(error)) {
        if (error.request) {
          throw new ProviderError(ProviderFailure.ConnectionFailure, error, error.code);
        }

        if (error.response?.status === 404) {
          return [null];
        }

        throw new ProviderError(ProviderFailure.Unhealthy, error, `Failed to resolve handles due to: ${error.message}`);
      }
      if (error instanceof ProviderError) throw error;
      throw new ProviderError(ProviderFailure.Unknown, error, 'Failed to resolve handles');
    }
  }

  async healthCheck(): Promise<HealthCheckResponse> {
    try {
      await this.axiosClient.get(`${paths.healthCheck}`);
      return { ok: true };
    } catch {
      return { ok: false };
    }
  }
}
