import { check } from 'k6';
import http from 'k6/http';

// eslint-disable-next-line no-undef
const STAKE_POOL_PROVIDER_URL = __ENV.PROVIDER_SERVER_URL;
const MAX_STAKE_POOLS = 500;
export const options = {
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01']
  }
};

export const setup = () => {
  const stakePools = [];
  let idx = 0;
  const limit = 25;

  // Get the list of stake pools
  while (stakePools.length < MAX_STAKE_POOLS) {
    const searchResponse = http.post(
      `${STAKE_POOL_PROVIDER_URL}/stake-pool/search`,
      JSON.stringify({
        pagination: {
          limit,
          startAt: idx * limit
        }
      }),
      {
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );
    idx++;
    check(searchResponse, {
      'Initial query successfull': (r) => r.status === 200
    });
    const parsedPageResults = JSON.parse(searchResponse.body.toString()).pageResults;
    stakePools.push(...parsedPageResults);
    if (parsedPageResults.length < 25) break;
  }
  return { stakePools };
};

export default function (data) {
  const randomIndex = Math.floor(Math.random() * data.stakePools.length);
  // Select random stake pool from the list to query by id
  const stakePool = data.stakePools[randomIndex];
  const requestBody = {
    filters: {
      identifier: { values: [{ id: stakePool.id }] },
      pledgeMet: true
    },
    pagination: { limit: 2, startAt: 0 }
  };
  return http.post(`${STAKE_POOL_PROVIDER_URL}/stake-pool/search`, JSON.stringify(requestBody), {
    headers: { 'Content-Type': 'application/json' }
  });
}
