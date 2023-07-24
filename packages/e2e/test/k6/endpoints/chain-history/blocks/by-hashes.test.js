import http from 'k6/http';

// eslint-disable-next-line no-undef
const PROVIDER_SERVER_URL = __ENV.PROVIDER_SERVER_URL;

export const options = {
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01']
  }
};

export default function () {
  const body = JSON.stringify({ ids: ['ae57a7127813a9a00116fa137cf4e0757cb77dc72bdae1e09a843e5f57873957'] });
  http.post(`${PROVIDER_SERVER_URL}/chain-history/blocks/by-hashes`, body, {
    headers: {
      'content-type': 'application/json'
    }
  });
}
