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
  http.post(`${PROVIDER_SERVER_URL}/network-info/lovelace-supply`, '{}', {
    headers: {
      'content-type': 'application/json'
    }
  });
}
