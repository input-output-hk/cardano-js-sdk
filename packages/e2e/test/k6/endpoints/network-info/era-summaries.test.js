import http from 'k6/http';

const PROVIDER_SERVER_URL = __ENV.PROVIDER_SERVER_URL;

export const options = {
    thresholds: {
        http_req_failed: ['rate<0.01'],
        http_req_duration: ['p(95)<500'],
    },
};

export default function () {
    http.post(`${PROVIDER_SERVER_URL}/network-info/era-summaries`, '{}', {
        headers: {
            'content-type': 'application/json',
        },
    });
}