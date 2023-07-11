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
    assetId: '0645beb92789851be85bfad30a6a9d9a0a98e0e8d41cff86727efb9f317374326c616365',
    extraData: { nftMetadata: true, tokenMetadata: true }
  });
  http.post(`${PROVIDER_SERVER_URL}/asset/get-asset`, body, {
    headers: {
      'content-type': 'application/json'
    }
  });
}
