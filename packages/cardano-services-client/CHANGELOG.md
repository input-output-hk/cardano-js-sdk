# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.4.1-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.4.0...@cardano-sdk/cardano-services-client@0.4.1-nightly.0) (2022-07-27)


### Features

* **cardano-services-client:** add asset info http provider ([866f3d5](https://github.com/input-output-hk/cardano-js-sdk/commit/866f3d5374e7572a966bff0a93a92ebf0412208c))



## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/cardano-services-client@0.4.0) (2022-07-25)


### Features

* **cardano-services-client:** add asset info http provider ([866f3d5](https://github.com/input-output-hk/cardano-js-sdk/commit/866f3d5374e7572a966bff0a93a92ebf0412208c))

## 0.3.0 (2022-06-24)


### ⚠ BREAKING CHANGES

* move stakePoolStats from wallet provider to stake pool provider
* rename `StakePoolSearchProvider` to `StakePoolProvider`
* add serializable object key transformation support
* **cardano-services-client:** reimplement txSubmitHttpProvider using createHttpProvider
* **cardano-graphql:** remove graphql concerns from services client package, rename

### Features

* add ChainHistory http provider ([64aa7ae](https://github.com/input-output-hk/cardano-js-sdk/commit/64aa7aeff061aa2cf9bc6196347f6cf5b9c7f6be))
* add utxo http provider ([a55fcdb](https://github.com/input-output-hk/cardano-js-sdk/commit/a55fcdb08276c37a1852f0c39e5b0a78501ddf0b))
* **cardano-services-client:** add generic http provider client ([72e2060](https://github.com/input-output-hk/cardano-js-sdk/commit/72e20602137a55ca4c6f95221b3d7aa09c10da9a))
* **cardano-services-client:** add stakePoolSearchHttpProvider ([286f41f](https://github.com/input-output-hk/cardano-js-sdk/commit/286f41f700cc6d41fa5192d33e73c87ea6a418ac))
* **cardano-services-client:** networkInfoProvider ([a304468](https://github.com/input-output-hk/cardano-js-sdk/commit/a30446870528acbabda121c691443ee4ba1b2784))
* rewards data ([5ce2ff0](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce2ff00856d362cf0e423ddadadb15cef764932))
* **web-extension:** add rewards provider support ([3630fba](https://github.com/input-output-hk/cardano-js-sdk/commit/3630fbae9fd8bdb5539a32e39b65f2ce8577a481))


### Bug Fixes

* **cardano-services-client:** http provider can now be the return value of an async function ([e732f5d](https://github.com/input-output-hk/cardano-js-sdk/commit/e732f5d7fcacd75cfecda3e1c21f387d21f46bed))
* **cardano-services-client:** update test URL and reword docblock ([4bfe001](https://github.com/input-output-hk/cardano-js-sdk/commit/4bfe0017a48146c81f571967299d360b8efc6732))


### Miscellaneous Chores

* **cardano-graphql:** remove graphql concerns from services client package, rename ([f197e46](https://github.com/input-output-hk/cardano-js-sdk/commit/f197e46254f7f56b6461239a12f213c0e34ccc5c))


### Code Refactoring

* add serializable object key transformation support ([32e422e](https://github.com/input-output-hk/cardano-js-sdk/commit/32e422e83f723a41521193d9cf4206a538fbcb43))
* **cardano-services-client:** reimplement txSubmitHttpProvider using createHttpProvider ([db17e34](https://github.com/input-output-hk/cardano-js-sdk/commit/db17e34193322856b1f5073c39658f223d31087b))
* move stakePoolStats from wallet provider to stake pool provider ([52d71a7](https://github.com/input-output-hk/cardano-js-sdk/commit/52d71a70700b05902cca6205fe01a63f811ba5af))
* rename `StakePoolSearchProvider` to `StakePoolProvider` ([b432103](https://github.com/input-output-hk/cardano-js-sdk/commit/b43210348da7914664733f85f8be8999271a8667))
