import * as k6Utils from '../../../../../util-dev/dist/cjs/k6-utils.js';
import { SharedArray } from 'k6/data';
import { apiVersion } from '../../../../../cardano-services-client/src/version.ts';
import { check, fail } from 'k6';
import exec from 'k6/execution';
import http from 'k6/http';

/**
 * # Script description:
 * - Sends REQUEST_COUNT HTTP requests to fetch assets. Since the number of iterations is indirectly controlled by the
 *   duration and rate, it is possible to be slightly inaccurate.
 * - Requests are started 1/s. A maximum of 20 VUs are used, so the maximum number of in-flight requests is 20.
 * - The total number of assets requested per request is the sum of the ASSETS_* variables
 * - AssetIds used are taken from mainnet. If the requested number of assets for the whole test is estimated to be larger
 *   than the sample, the test will fail.
 * - Test verifies that:
 *   - Threshold for FAIL responses not exceeded (1% for example)
 *   - Threshold for response having the wrong number of assets compared to requested is not exceeded (1% for example)
 *   - 95th percentile of response time is less than 500ms
 */

// eslint-disable-next-line no-undef
const K6_ENV = __ENV;

const ASSETS_NO_METADATA_PER_REQUEST = Number.parseInt(K6_ENV.ASSETS_NO_METADATA_PER_REQUEST || 1);
const ASSETS_ON_CHAIN_METADATA_PER_REQUEST = Number.parseInt(K6_ENV.ASSETS_ON_CHAIN_METADATA_PER_REQUEST || 0);
const ASSETS_OFF_CHAIN_METADATA_PER_REQUEST = Number.parseInt(K6_ENV.ASSETS_OFF_CHAIN_METADATA_PER_REQUEST || 0);
const REQUESTS_COUNT = Number.parseInt(K6_ENV.REQUESTS_COUNT || 1);

const dut = k6Utils.getDut(K6_ENV, { environments: ['dev'], networks: ['mainnet'] });
const sdkCom = new k6Utils.SdkCom({ apiVersion, dut, k6Http: http });

export const options = {
  scenarios: {
    getAssets: {
      // How long the test lasts.
      // There's an extra iteration that I am correcting here.
      duration: `${REQUESTS_COUNT}s`,
      // Start iterations at a specific rate (`rate/timeUnit`) for `duration`
      // Each iteration is executed by a VU. If the iteration ends, the VU is reused for the next iteration.
      // `maxVUs` when a VU does not receive a response by the end of the iteration, a new VU is allocated
      // for the next iteration. If the number of VUs reaches `maxVUs`, iterations are delayed until a VU is available.
      executor: 'constant-arrival-rate',
      // Randomly picked. This will be the maximum number of in-flight requests (requests waiting for a response).
      maxVUs: 20,
      // Have one 1 VU ready to handle the first iteration.
      preAllocatedVUs: 1,
      // How many iterations per time unit
      rate: 1,
      // Ensure a single iteration is run by making the duration small (1s) and rate higher 1/2s.
      // Otherwise, for duration=1s and rate 1/s, it runs 2 iterations. It could be a bug...
      timeUnit: REQUESTS_COUNT > 1 ? '1s' : '2s'
    }
  },
  thresholds: {
    // Fail if more than 1% of the requests have invalid number of assets in the response
    'checks{assetsCountInResponse:assetsCountInResponse}': [{ abortOnFail: true, threshold: 'rate>0.99' }],
    http_req_duration: ['p(95)<2000'],
    http_req_failed: [{ abortOnFail: true, threshold: 'rate<0.1' }]
  }
};

const assetsSample = new SharedArray('assets', () => {
  // eslint-disable-next-line no-undef
  const assetsMainnetJson = open('../../../dump/assets/mainnet.json');
  const assetsMainnet = JSON.parse(assetsMainnetJson).assets;
  return [
    assetsMainnet.filter((asset) => !asset.hasMetadata).map((asset) => asset.id),
    assetsMainnet.filter((asset) => asset.hasOffchainMetadata).map((asset) => asset.id),
    assetsMainnet.filter((asset) => asset.hasMetadata && !asset.hasOffchainMetadata).map((asset) => asset.id)
  ];
});

export const setup = () => {
  const [assetsNoMetadata, assetsWithOffChainMetadata, assetsWithOnChainMetadata] = assetsSample;
  const availableAssetsInSample = {
    noMetadata: assetsNoMetadata.length,
    withOffChainMetadata: assetsWithOffChainMetadata.length,
    withOnChainMetadata: assetsWithOnChainMetadata.length
  };

  const totalAssetsToQuery = {
    noMetadata: ASSETS_NO_METADATA_PER_REQUEST * REQUESTS_COUNT,
    withOffChainMetadata: ASSETS_OFF_CHAIN_METADATA_PER_REQUEST * REQUESTS_COUNT,
    withOnChainMetadata: ASSETS_ON_CHAIN_METADATA_PER_REQUEST * REQUESTS_COUNT
  };

  // Validate we have sufficient assets in the sample to query. Assets already queried will be cached in the back-end
  // So we need to query a different set of assets on each request.
  if (
    !check(totalAssetsToQuery, {
      'Sufficient assets with no metadata in sample': ({ noMetadata }) =>
        noMetadata <= availableAssetsInSample.noMetadata,
      'Sufficient assets with off-chain metadata in sample': ({ withOffChainMetadata }) =>
        withOffChainMetadata <= availableAssetsInSample.withOffChainMetadata,
      'Sufficient assets with on-chain metadata in sample': ({ withOnChainMetadata }) =>
        withOnChainMetadata <= availableAssetsInSample.withOnChainMetadata
    })
  ) {
    fail(
      `Insufficient assets in sample. Requested: ${JSON.stringify(totalAssetsToQuery)}, but have ${JSON.stringify(
        availableAssetsInSample
      )}`
    );
  }
};

const getAssetsSlice = (assets, iteration, perRequest) => {
  if (perRequest === 0) {
    return [];
  }
  // We've already verified we have enough samples, but the actual iteration count
  // is indirectly controlled with DURATION and RATE, so we need to ensure we don't go out of bounds.
  const start = (perRequest * iteration) % assets.length;
  const end = start + perRequest;
  return assets.slice(start, end);
};

export const run = () => {
  const [assetsNoMetadata, assetsWithOffChainMetadata, assetsWithOnChainMetadata] = assetsSample;
  const iteration = exec.scenario.iterationInTest;
  const assetIds = [
    ...getAssetsSlice(assetsNoMetadata, iteration, ASSETS_NO_METADATA_PER_REQUEST),
    ...getAssetsSlice(assetsWithOffChainMetadata, iteration, ASSETS_OFF_CHAIN_METADATA_PER_REQUEST),
    ...getAssetsSlice(assetsWithOnChainMetadata, iteration, ASSETS_ON_CHAIN_METADATA_PER_REQUEST)
  ];

  // It could have less than requested if we are at the end of the sample
  if (!check(assetIds, { 'Request has at least 1 asset': (ids) => ids.length > 0 })) {
    fail('Test error: should request at least 1 asset. This might be a test bug or a configuration issue.');
  }
  const response = sdkCom.getAssets({ assetIds, nftMetadata: true, tokenMetadata: true });

  if (
    response.status === 200 && // OK responses should have the same number of assets as requested
    !check(
      response.body,
      {
        'response body contains same number of assets as requested': (assetsInResponse) =>
          JSON.parse(assetsInResponse).length === assetIds.length
      },
      { assetsCountInResponse: 'assetsCountInResponse' }
    )
  ) {
    console.error(`Expected ${assetIds.length} assets in response, but got ${response.body.length}`);
    console.error(`Requested assets: ${assetIds}`);
    console.error(`Response: ${response.body}`);
  }
};

export default run;
