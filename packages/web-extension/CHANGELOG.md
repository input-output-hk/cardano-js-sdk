# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.5.0-nightly.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.5.0-nightly.1...@cardano-sdk/web-extension@0.5.0-nightly.2) (2022-08-02)

**Note:** Version bump only for package @cardano-sdk/web-extension





## [0.5.0-nightly.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.5.0-nightly.0...@cardano-sdk/web-extension@0.5.0-nightly.1) (2022-07-30)

**Note:** Version bump only for package @cardano-sdk/web-extension





## [0.5.0-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.4.0...@cardano-sdk/web-extension@0.5.0-nightly.0) (2022-07-27)


### ⚠ BREAKING CHANGES

* update min utxo computation to be Babbage-compatible

### Bug Fixes

* update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))



## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/web-extension@0.4.0) (2022-07-25)


### ⚠ BREAKING CHANGES

* update min utxo computation to be Babbage-compatible

### Features

* add cip36 metadataBuilder ([0632dc5](https://github.com/input-output-hk/cardano-js-sdk/commit/0632dc508e6be7bc37024e5f8128337ba64a9f47))


### Bug Fixes

* update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))

## 0.3.0 (2022-06-24)


### ⚠ BREAKING CHANGES

* improve ObservableWallet.balance interface
* **web-extension:** rename RemoteApiProperty.Observable->HotObservable
* remove transactions and blocks methods from blockfrost wallet provider
* rename `StakePoolSearchProvider` to `StakePoolProvider`
* add serializable object key transformation support
* **web-extension:** do not timeout remote observable subscriptions
* rm ObservableWallet.networkId (to be resolved via networkInfo$)
* revert 7076fc2ae987948e2c52b696666842ddb67af5d7
* rm cip30 dependency on web-extension
* require to explicitly specify exposed api property names (security reasons)
* hoist cip30 mapping of ObservableWallet to cip30 pkg
* rework cip30 to use web extension messaging ports

### Features

* require to explicitly specify exposed api property names (security reasons) ([f1a0aa4](https://github.com/input-output-hk/cardano-js-sdk/commit/f1a0aa4129705920ea5a734448fea6b99efbdcb4))
* **web-extension:** add remote api nested objects support ([d9f738c](https://github.com/input-output-hk/cardano-js-sdk/commit/d9f738c70c658790aceb2cc855e3b5c87a300107))
* **web-extension:** add remote api observable support ([8ed968c](https://github.com/input-output-hk/cardano-js-sdk/commit/8ed968cf2ca18e902fa9d61281882d1ca20a458a))
* **web-extension:** add rewards provider support ([3630fba](https://github.com/input-output-hk/cardano-js-sdk/commit/3630fbae9fd8bdb5539a32e39b65f2ce8577a481))
* **web-extension:** add utils to expose/consume an AsyncKeyAgent ([80e173d](https://github.com/input-output-hk/cardano-js-sdk/commit/80e173dfb8c7910a660cb62dba67a8765eed247c))
* **web-extension:** export utils to expose/consume an observable wallet ([b215e51](https://github.com/input-output-hk/cardano-js-sdk/commit/b215e5188a011497050921bbaf53c34417189163))


### Bug Fixes

* add missing UTXO_PROVIDER and WALLET_PROVIDER envs to blockfrost instatiation condition ([3773a69](https://github.com/input-output-hk/cardano-js-sdk/commit/3773a69a609a81f5c2541b2c2c21125ae6464cdf))
* **web-extension:** cache remote api properties ([44764aa](https://github.com/input-output-hk/cardano-js-sdk/commit/44764aa6ef578d43b5726ba56a7d5c2f80958359))
* **web-extension:** correctly forward message arguments ([9ceadb4](https://github.com/input-output-hk/cardano-js-sdk/commit/9ceadb4bf4ba8d6de428f3e07ea9e9ff86bde40c))
* **web-extension:** do not timeout remote observable subscriptions ([39422e4](https://github.com/input-output-hk/cardano-js-sdk/commit/39422e4fb1bef7760d4aeacdb4c53a84e326bc8d))
* **web-extension:** ignore non-explicitly-exposed observables and objects ([417dd3b](https://github.com/input-output-hk/cardano-js-sdk/commit/417dd3b1949774ecb26f29af8031ada2751ddd3a))
* **web-extension:** support creating remote objects before source exists ([d4ac17f](https://github.com/input-output-hk/cardano-js-sdk/commit/d4ac17f2ad80bdf3dea1d211187ad4c6457f562d))


### Code Refactoring

* add serializable object key transformation support ([32e422e](https://github.com/input-output-hk/cardano-js-sdk/commit/32e422e83f723a41521193d9cf4206a538fbcb43))
* hoist cip30 mapping of ObservableWallet to cip30 pkg ([7076fc2](https://github.com/input-output-hk/cardano-js-sdk/commit/7076fc2ae987948e2c52b696666842ddb67af5d7))
* improve ObservableWallet.balance interface ([b8371f9](https://github.com/input-output-hk/cardano-js-sdk/commit/b8371f97e151c2e9cb18e0ac431e9703fe490d26))
* remove transactions and blocks methods from blockfrost wallet provider ([e4de136](https://github.com/input-output-hk/cardano-js-sdk/commit/e4de13650f0d387b8e7126077e8721f353af8c85))
* rename `StakePoolSearchProvider` to `StakePoolProvider` ([b432103](https://github.com/input-output-hk/cardano-js-sdk/commit/b43210348da7914664733f85f8be8999271a8667))
* revert 7076fc2ae987948e2c52b696666842ddb67af5d7 ([b30183e](https://github.com/input-output-hk/cardano-js-sdk/commit/b30183e4852606e38c1d5b55dd9dc51ed138fc29))
* rework cip30 to use web extension messaging ports ([837dc9d](https://github.com/input-output-hk/cardano-js-sdk/commit/837dc9da1c19df340953c47381becfe07f02a0c9))
* rm cip30 dependency on web-extension ([77f8642](https://github.com/input-output-hk/cardano-js-sdk/commit/77f8642ebaac3b2615d082184d22a96f4cf86d42))
* rm ObservableWallet.networkId (to be resolved via networkInfo$) ([72be7d7](https://github.com/input-output-hk/cardano-js-sdk/commit/72be7d7fc9dfd1bd12593ab572d9b6734d789822))
* **web-extension:** rename RemoteApiProperty.Observable->HotObservable ([4bc9922](https://github.com/input-output-hk/cardano-js-sdk/commit/4bc99224d3cdcadc90729eecd8cb9ea2d6227438))
