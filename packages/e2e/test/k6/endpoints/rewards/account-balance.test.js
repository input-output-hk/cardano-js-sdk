import http from 'k6/http';

const PROVIDER_SERVER_URL = __ENV.PROVIDER_SERVER_URL;

export const options = {
    thresholds: {
        http_req_failed: ['rate<0.01'],
        http_req_duration: ['p(95)<500'],
    },
};

export default function () {
    const body = JSON.stringify({rewardAccount: "stake1uygxsnx9gxhn3pkq2e9k97wza02c6vl7njuk5x7fs0tpjgc9qf8ag"})
    http.post(`${PROVIDER_SERVER_URL}/rewards/account-balance`, body, {
        headers: {
            'content-type': 'application/json',
        },
    });
}