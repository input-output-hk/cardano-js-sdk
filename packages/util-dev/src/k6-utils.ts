import { Cardano } from '@cardano-sdk/core';
import http from 'k6/http';

/* eslint-disable sonarjs/cognitive-complexity */
export enum Environment {
  dev = 'dev',
  ops = 'ops',
  staging = 'staging',
  live = 'live'
}

export enum Network {
  mainnet = 'mainnet',
  preprod = 'preprod',
  preview = 'preview',
  sanchonet = 'sanchonet'
}

/**
 * Gets the target URL domain under test (dut) based on `TARGET_ENV`, `TARGET_NET` or `DUT` environment variables.
 *
 * @param k6Env the k6 environment variables. It should contain either `TARGET_ENV` and `TARGET_NET`, or `DUT`.
 * @param k6Env.TARGET_ENV ('dev' | 'ops' | 'staging' | 'preprod) and
 * @param k6Env.TARGET_NET `TARGET_NET` ('mainnet' | 'preprod' | 'preview' | 'sanchonet')
 *   are used to build the domain under test (dut).
 * @param k6Env.DUT is used as the domain under test (dut) in case it is a custom domain
 * @param options default `undefined`: use default value for each option.<br />
 * @param options.environments the array of allowed environments - default: `['dev', 'ops', 'staging', 'prod']`.
 * @param options.networks the array of allowed networks - default: `['mainnet', 'preprod', 'preview', 'sanchonet']`.
 * @returns the domain under test (dut) based on the environment variables, (e.g. `live-preprod.lw.iog.io`)
 * @throws if none of `TARGET_ENV` and `TARGET_NET`, or `DUT` are configured, or if the options are invalid.
 */
// eslint-disable-next-line complexity, sonarjs/cognitive-complexity
export const getDut = (
  k6Env: { TARGET_ENV?: string; TARGET_NET?: string; DUT?: string },
  options?: { environments?: Environment[]; networks?: Network[] }
) => {
  const allowedEnvironments = new Set<Environment>([
    Environment.dev,
    Environment.ops,
    Environment.staging,
    Environment.live
  ]);
  const allowedNetworks = new Set<Network>([Network.mainnet, Network.preprod, Network.preview, Network.sanchonet]);
  const allowedOptions = new Set(['environments', 'networks']);

  const { TARGET_ENV, TARGET_NET, DUT } = k6Env;

  if (!(TARGET_ENV && TARGET_NET) && !DUT)
    throw new Error('Please specify both TARGET_ENV and TARGET_NET or DUT (Domain Under Test');

  let urlEnvironments = [...allowedEnvironments];
  let urlNetworks = [...allowedNetworks];

  if (options) {
    if (typeof options !== 'object') throw new Error(`${typeof options}: not allowed type for options`);

    for (const option of Object.keys(options))
      if (!allowedOptions.has(option)) throw new Error(`${options}: not allowed option`);

    const { environments, networks } = options;

    switch (typeof environments) {
      case 'undefined':
        break;

      case 'object':
        if (!Array.isArray(environments)) throw new Error('options.environments must be an array');

        for (const environment of environments)
          if (!allowedEnvironments.has(environment)) throw new Error(`${environment}: not allowed environment`);

        urlEnvironments = environments;

        break;

      default:
        throw new Error(`${typeof environments}: not allowed type for options.environments`);
    }

    switch (typeof networks) {
      case 'undefined':
        break;

      case 'object':
        if (!Array.isArray(networks)) throw new Error('options.networks must be an array');

        for (const network of networks)
          if (!allowedNetworks.has(network)) throw new Error(`${network}: not allowed network`);

        urlNetworks = networks;

        break;

      default:
        throw new Error(`${typeof networks}: not allowed type for options.networks`);
    }
  }

  if (TARGET_ENV && !urlEnvironments.includes(TARGET_ENV as Environment))
    throw new Error(`${TARGET_ENV}: not allowed environment`);
  if (TARGET_NET && !urlNetworks.includes(TARGET_NET as Network)) throw new Error(`${TARGET_NET}: not allowed network`);

  const domainUnderTest = DUT || `${TARGET_ENV}-${TARGET_NET}${TARGET_ENV === 'ops' ? '-1' : ''}.lw.iog.io`;
  // eslint-disable-next-line no-console
  console.log(`Domain under test is: ${domainUnderTest}`);

  return domainUnderTest;
};

/** equivalent to lodash.chunk */
export const chunkArray = <T>(array: T[], chunkSize: number): T[][] => {
  const arrayCopy = [...array];
  const chunked = [];
  while (arrayCopy.length > 0) {
    chunked.push(arrayCopy.splice(0, chunkSize));
  }
  return chunked;
};

/** Based on packages/cardano-services-client/src/version.ts */
type ApiVersion = {
  assetInfo: string;
  chainHistory: string;
  handle: string;
  networkInfo: string;
  rewards: string;
  root: string;
  stakePool: string;
  txSubmit: string;
  utxo: string;
};

type ServiceName = keyof ApiVersion;

/** Wrapper class for http/ws calls to SDK back-end */
export class SdkCom {
  /** Domain under test (e.g. dev-sanchonet.lw.iog.io) */
  #httpUrl: string;
  #apiVersion: ApiVersion;
  #k6Http: { post: typeof http.post };

  constructor({
    dut,
    secure = true,
    apiVersion,
    k6Http
  }: {
    dut: string;
    secure?: boolean;
    apiVersion: ApiVersion;
    k6Http: { post: typeof http.post };
  }) {
    const scheme = secure ? 'https' : 'http';
    this.#httpUrl = `${scheme}://${dut}`;
    this.#apiVersion = apiVersion;
    this.#k6Http = k6Http;
  }

  tip() {
    return this.httpPost('network-info/ledger-tip', 'networkInfo');
  }

  eraSummaries() {
    return this.httpPost('network-info/era-summaries', 'networkInfo');
  }

  genesisParameters() {
    return this.httpPost('network-info/genesis-parameters', 'networkInfo');
  }

  protocolParameters() {
    return this.httpPost('network-info/protocol-parameters', 'networkInfo');
  }

  lovelaceSupply() {
    return this.httpPost('network-info/lovelace-supply', 'networkInfo');
  }

  stake() {
    return this.httpPost('network-info/stake', 'networkInfo');
  }

  stakePoolStats() {
    return this.httpPost('stake-pool/stats', 'stakePool');
  }

  /** Util functions for sending the http post requests to cardano-sdk services */
  httpPost(url: string, serviceName: ServiceName, body = {}) {
    const opts = { headers: { 'content-type': 'application/json' }, timeout: '1m' };
    return this.#k6Http.post(`${this.#httpUrl}/v${this.#apiVersion[serviceName]}/${url}`, JSON.stringify(body), opts);
  }

  /**
   *
   * @param addresses Bech32 cardano addresses: `Cardano.Address[]`
   * @param takeOne  true: query only the first page; false: query until no more pages
   * @param pageSize Use as request page size. Also, bundle this many addresses on each request.
   */
  txsByAddress(addresses: Cardano.Address[], takeOne = false, pageSize = 25): void {
    const addressChunks = chunkArray(addresses, pageSize);
    for (const chunk of addressChunks) {
      let startAt = 0;
      let txCount = 0;

      do {
        const resp = this.httpPost('chain-history/txs/by-addresses', 'chainHistory', {
          addresses: chunk,
          blockRange: { lowerBound: { __type: 'undefined' } },
          pagination: { limit: pageSize, startAt }
        });

        if (resp.status !== 200 || typeof resp.body !== 'string') {
          // No point in trying to get the other pages.
          // Should we log this? it will show up as if the restoration was quicker since this wallet did not fetch all the pages
          break;
        }

        const { pageResults } = JSON.parse(resp.body);
        startAt += pageSize;
        txCount = pageResults.length;
      } while (txCount === pageSize && !takeOne);
    }
  }

  utxosByAddresses(addresses: Cardano.Address[]): void {
    const addressChunks = chunkArray(addresses, 25);
    for (const chunk of addressChunks) {
      this.httpPost('utxo/utxo-by-addresses', 'utxo', { addresses: chunk });
    }
  }

  rewardsAccBalance(rewardAccount: Cardano.RewardAccount) {
    return this.httpPost('rewards/account-balance', 'rewards', { rewardAccount });
  }

  stakePoolSearch(poolAddress: Cardano.PoolId) {
    return this.httpPost('stake-pool/search', 'stakePool', {
      filters: { identifier: { values: [{ id: poolAddress }] } },
      pagination: { limit: 1, startAt: 0 }
    });
  }

  getAssets({
    assetIds,
    nftMetadata,
    tokenMetadata
  }: {
    assetIds: Cardano.AssetId[];
    nftMetadata: boolean;
    tokenMetadata: boolean;
  }) {
    return this.httpPost('asset/get-assets', 'assetInfo', {
      assetIds,
      extraData: { nftMetadata, tokenMetadata }
    });
  }
}
