// cSpell:ignore kora koralabs
import {
  Asset,
  Cardano,
  HandleProvider,
  HandleResolution,
  HealthCheckResponse,
  ProviderError,
  ProviderFailure,
  ResolveHandlesArgs
} from '@cardano-sdk/core';

// eslint-disable-next-line import/no-extraneous-dependencies
import { IHandle } from '@koralabs/handles-public-api-interfaces';
import axios, { AxiosAdapter, AxiosInstance } from 'axios';

/** The KoraLabsHandleProvider endpoint paths. */
const paths = {
  handles: '/handles',
  healthCheck: '/health'
};

export interface KoraLabsHandleProviderDeps {
  serverUrl: string;
  adapter?: AxiosAdapter;
  policyId: Cardano.PolicyId;
}

export const toHandleResolution = ({ apiResponse, policyId }: { apiResponse: IHandle; policyId: Cardano.PolicyId }) => {
  const cardano = Cardano.PaymentAddress(apiResponse.resolved_addresses.ada);
  const result: HandleResolution = {
    addresses: { cardano },
    backgroundImage: apiResponse.bg_image ? Asset.Uri(apiResponse.bg_image) : undefined,
    cardanoAddress: cardano,
    handle: apiResponse.name,
    hasDatum: apiResponse.has_datum,
    image: apiResponse.image ? Asset.Uri(apiResponse.image) : undefined,
    policyId,
    profilePic: apiResponse.pfp_image ? Asset.Uri(apiResponse.pfp_image) : undefined
  };

  if ('btc' in apiResponse.resolved_addresses) result.addresses.bitcoin = apiResponse.resolved_addresses.btc;

  return result;
};

/**
 * Creates a KoraLabs Provider instance to resolve Standard Handles
 *
 * @param KoraLabsHandleProviderDeps The configuration object fot the KoraLabs Handle Provider.
 */
export class KoraLabsHandleProvider implements HandleProvider {
  private axiosClient: AxiosInstance;
  policyId: Cardano.PolicyId;

  constructor({ serverUrl, adapter, policyId }: KoraLabsHandleProviderDeps) {
    this.axiosClient = axios.create({
      adapter,
      baseURL: serverUrl
    });
    this.policyId = policyId;
  }

  resolveHandles({ handles }: ResolveHandlesArgs): Promise<Array<HandleResolution | null>> {
    // eslint-disable-next-line unicorn/consistent-function-scoping
    const resolveHandle = async (handle: string) => {
      try {
        const { data } = await this.axiosClient.get<IHandle>(`${paths.handles}/${handle}`);

        return toHandleResolution({ apiResponse: data, policyId: this.policyId });
      } catch (error) {
        if (error instanceof ProviderError) throw error;
        if (axios.isAxiosError(error)) {
          if (error.response?.status === 404) return null;
          if (error.request) throw new ProviderError(ProviderFailure.ConnectionFailure, error, error.code);

          throw new ProviderError(
            ProviderFailure.Unhealthy,
            error,
            `Failed to resolve handles due to: ${error.message}`
          );
        }

        throw new ProviderError(ProviderFailure.Unknown, error, 'Failed to resolve handles');
      }
    };

    return Promise.all(handles.map((handle) => resolveHandle(handle)));
  }

  async healthCheck(): Promise<HealthCheckResponse> {
    try {
      await this.axiosClient.get(`${paths.healthCheck}`);
      return { ok: true };
    } catch {
      return { ok: false };
    }
  }

  async getPolicyIds(): Promise<Cardano.PolicyId[]> {
    return [this.policyId];
  }
}
