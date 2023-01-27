# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.7.1-nightly.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.7.1-nightly.0...@cardano-sdk/util@0.7.1-nightly.1) (2023-01-27)

### Bug Fixes

- **cardano-services:** updated http provider error handling ([#514](https://github.com/input-output-hk/cardano-js-sdk/issues/514)) ([33a4867](https://github.com/input-output-hk/cardano-js-sdk/commit/33a48670490fa998cef0196eb71492103105dcf7))

## [0.7.1-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.7.0...@cardano-sdk/util@0.7.1-nightly.0) (2022-12-24)

**Note:** Version bump only for package @cardano-sdk/util

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.6.0...@cardano-sdk/util@0.7.0) (2022-12-22)

### ⚠ BREAKING CHANGES

- create a new CML scope for every call of BuildTx in selection constraints

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
- create a new CML scope for every call of BuildTx in selection constraints ([6818ae4](https://github.com/input-output-hk/cardano-js-sdk/commit/6818ae443dd53ac4786ce161f02aef5635433678))
- **util:** fixes util-dev version in dev dependencies ([6c165bf](https://github.com/input-output-hk/cardano-js-sdk/commit/6c165bf9f11159324850d9f7624c02bec9be60e1))

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.5.0...@cardano-sdk/util@0.6.0) (2022-11-04)

### ⚠ BREAKING CHANGES

- lift deepEquals to util package in preparation for further wallet decomposition
- hoist hexString utils to util package

### Features

- **util:** managed scope and util for handling freeable objects ([7f03a53](https://github.com/input-output-hk/cardano-js-sdk/commit/7f03a536b7aa504b022846f7786068806df83c12))
- **util:** typescript DeepPartial utility type ([824e7aa](https://github.com/input-output-hk/cardano-js-sdk/commit/824e7aa8906ad7c3ce5a93770ffc7ed09651da68))

### Bug Fixes

- added missing contraints ([7b351ca](https://github.com/input-output-hk/cardano-js-sdk/commit/7b351cada06b9c5ae2f379d02614e05259f7147a))
- **util:** a websocket closed error is now correctly handled as a network error ([6aa00a1](https://github.com/input-output-hk/cardano-js-sdk/commit/6aa00a10fc21eac13da557d6c7c1de40c3f30b66))

### Code Refactoring

- hoist hexString utils to util package ([0c99d9d](https://github.com/input-output-hk/cardano-js-sdk/commit/0c99d9d37f23bb504d1ac2a530fbe78aa045db66))
- lift deepEquals to util package in preparation for further wallet decomposition ([c935a77](https://github.com/input-output-hk/cardano-js-sdk/commit/c935a77c0bb895ee85b885e8da57ed7de3786e36))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.4.0...@cardano-sdk/util@0.5.0) (2022-08-30)

### ⚠ BREAKING CHANGES

- contextLogger support

### Features

- **util:** expose isConnectionError check ([c9c8bdb](https://github.com/input-output-hk/cardano-js-sdk/commit/c9c8bdbffb16208d2f7aea135ab61dd7dae0be92))

### Code Refactoring

- contextLogger support ([6d5da8e](https://github.com/input-output-hk/cardano-js-sdk/commit/6d5da8ec8bba2033ce378d2f0d9321fd758e7c90))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/util@0.4.0) (2022-07-25)

### Bug Fixes

- **util:** add Set serialization support ([237913f](https://github.com/input-output-hk/cardano-js-sdk/commit/237913f685ee5ae2d5cd7353a92ada8d9f9ff82b))
- **util:** correctly deserialize Set items ([adf458d](https://github.com/input-output-hk/cardano-js-sdk/commit/adf458d150c398ce9589821ef40703c2da5685f7))

## 0.3.0 (2022-06-24)
