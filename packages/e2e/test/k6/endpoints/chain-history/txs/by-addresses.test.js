import http from 'k6/http';

const PROVIDER_SERVER_URL = __ENV.PROVIDER_SERVER_URL;

export const options = {
    thresholds: {
        http_req_failed: ['rate<0.01'],
        http_req_duration: ['p(95)<500'],
    },
};

export default function () {
    const body = JSON.stringify({
        addresses: ["addr1q9jnd74u484lgt3gzaxwmawqxr3mh7vzpjwr6e0ac0qypfcsdpxv2sd08zrvq4jtvtuu967435ela89edgdunq7kry3sltwvnx"],
        blockRange: {lowerBound: 8555233},
        pagination: {limit: 25, startAt: 0}
    })
    http.post(`${PROVIDER_SERVER_URL}/chain-history/txs/by-addresses`, body, {
        headers: {
            'content-type': 'application/json',
        },
    });
}