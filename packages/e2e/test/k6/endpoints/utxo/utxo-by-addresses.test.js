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
  const body = JSON.stringify({
    addresses: [
      'addr1q9tz7a36xj7yueynqykp99897qrvpwveef4z6l8z09uuujd5wnak0wyqqhaw7s4c5wpwfkf26u9adszzdp39p2kdf73q3ygrvy'
    ]
  });
  http.post(`${PROVIDER_SERVER_URL}/utxo/utxo-by-addresses`, body, {
    headers: {
      'content-type': 'application/json'
    }
  });
}
