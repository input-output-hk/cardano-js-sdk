import http from 'k6/http';

const PROVIDER_SERVER_URL = __ENV.PROVIDER_SERVER_URL;

export const options = {
    thresholds: {
        http_req_failed: ['rate<0.01'],
        http_req_duration: ['p(95)<500'],
    },
};

export default function () {
    const body = JSON.stringify({ids:["ae57a7127813a9a00116fa137cf4e0757cb77dc72bdae1e09a843e5f57873957"]})
    http.post(`${PROVIDER_SERVER_URL}/chain-history/txs/by-hashes`, body, {
        headers: {
            'content-type': 'application/json',
        },
    });
}