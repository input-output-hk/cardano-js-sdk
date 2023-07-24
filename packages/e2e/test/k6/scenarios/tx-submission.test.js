import { Counter } from 'k6/metrics';
import http from 'k6/http';

// eslint-disable-next-line no-undef
const PROVIDER_SERVER_URL = __ENV.PROVIDER_SERVER_URL;

http.setResponseCallback(http.expectedStatuses(400));

const INVALID_TX =
  '84a400818258201145fe128b5bc6d5b369ab06eae8b3d85705273184e1c420cbe1bc112af886cf02018282583901dbff800b7afbd55960e261a5988c30063602d4be2ab347eeb4b42b47e2ea03ca80cfecf85c4839a05db1c55d5f5b70773409d0f6895c51881a0292a60482583901d020e5ab3faa7e90daff03c780c07c210fda6e4990d7c169c421398fe2ea03ca80cfecf85c4839a05db1c55d5f5b70773409d0f6895c51881a000f4240021a0002917d031a0549823fa1008182582099280dfe10ded05fa081bb298c5b99150951bd231b98120bd406d6155461642458405ff5e145bf054ebae5b9fc2f7712b57f0c68d490edc5c2d16c6cc4633b7a05f677e996048121fd5275fc22575cdc3317bf9dc107d679ed2cfd528c90fda30f00f5f6';

const submissionCount = new Counter('submission_count');

const executor = 'constant-arrival-rate';

export const options = {
  ext: {
    loadimpact: {
      apm: [],
      distribution: { 'amazon:de:frankfurt': { loadZone: 'amazon:de:frankfurt', percent: 100 } }
    }
  },
  scenarios: {
    SixtyPerMin: {
      duration: '10m',
      exec: 'submitTx',
      executor,
      gracefulStop: '0s',
      preAllocatedVUs: 1,
      rate: 60,
      startTime: '10m',
      timeUnit: '1m'
    },
    TenPerMin: {
      duration: '10m',
      exec: 'submitTx',
      executor,
      gracefulStop: '0s',
      preAllocatedVUs: 1,
      rate: 10,
      timeUnit: '1m'
    },
    TwoHundredPerMin: {
      duration: '10m',
      exec: 'submitTx',
      executor,
      gracefulStop: '0s',
      preAllocatedVUs: 1,
      rate: 200,
      startTime: '20m',
      timeUnit: '1m'
    }
  }
};

/** Util functions for sending the http post requests to cardano-sdk services */
const cardanoHttpPost = (url, body = {}) => {
  const opts = { headers: { 'content-type': 'application/json' } };
  return http.post(`${PROVIDER_SERVER_URL}/${url}`, JSON.stringify(body), opts);
};

export default function () {
  cardanoHttpPost('tx-submit/submit', { signedTransaction: INVALID_TX });
  submissionCount.add(1);
}
