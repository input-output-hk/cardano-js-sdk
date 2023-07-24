# Running tests locally

## Prerequisites

1. [K6 installed locally](https://k6.io/docs/get-started/installation/). Needed for `k6 run the-test.js`.
1. Metrics dashboards & reports: install [K6 Dashboards extension](https://github.com/szkiba/xk6-dashboard#download)
    - **Make sure you are using `k6` binary downloaded/built from `xk6-dashboard` project** when running or replaying**.
     Otherwise the command will fail with `invalid output type 'dashboard', available types are`.
    - K6 dashboards are available by default in: http://127.0.0.1:5665

## Running

- Without K6 dashboards:
  ```k6 run test-file.js --out json=test-file-out.json --out csv=test-file-out.csv```

- With K6 dashboards while test is running.
  `k6 run test-file.js --out json=test-file-out.json --out csv=test-file-out.csv --out dashboard`

- Open K6 dashboards for a previous run. The `json` out file is needed.
  `k6 dashboard replay test-file-out.json`

