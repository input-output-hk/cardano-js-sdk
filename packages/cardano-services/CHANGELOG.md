# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.6.0-nightly.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.6.0-nightly.5...@cardano-sdk/cardano-services@0.6.0-nightly.6) (2022-09-15)

**Note:** Version bump only for package @cardano-sdk/cardano-services





## [0.6.0-nightly.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.5.0...@cardano-sdk/cardano-services@0.6.0-nightly.5) (2022-09-14)


### ⚠ BREAKING CHANGES

* rework TxSubmitProvider to submit transactions as hex string instead of Buffer
* rework all provider signatures args from positional to a single object
* convert boolean args to support ENV counterparts, parse as booleans
* hoist hexString utils to util package

### Features

* **cardano-services:** adds log of incoming requests ([f302f9c](https://github.com/input-output-hk/cardano-js-sdk/commit/f302f9c656b9026b3b19a63a4ce818acea841a77))
* **cardano-services:** enhance metrics endpoint ([0fdbb85](https://github.com/input-output-hk/cardano-js-sdk/commit/0fdbb85777d1d8c79189843ad8c7936a42e22380))


### Bug Fixes

* **cardano-services:** correct interval type and only clear if defined ([a23f384](https://github.com/input-output-hk/cardano-js-sdk/commit/a23f3846d85740675b57c14988ac08e35ee133b9))
* **cardano-services:** handle CardanoTokenRegistry errors ([32a9b1f](https://github.com/input-output-hk/cardano-js-sdk/commit/32a9b1f4714cd556ef3bf2597b52a4d481efcc58))
* convert boolean args to support ENV counterparts, parse as booleans ([d14bd9d](https://github.com/input-output-hk/cardano-js-sdk/commit/d14bd9d8aeec64f04aab094e0aceb8dc5b803926))
* remove nullability of Protocol Parameters ([f75859d](https://github.com/input-output-hk/cardano-js-sdk/commit/f75859d644c2a6c4d4844b179357ccab7db537bf))


### Code Refactoring

* hoist hexString utils to util package ([0c99d9d](https://github.com/input-output-hk/cardano-js-sdk/commit/0c99d9d37f23bb504d1ac2a530fbe78aa045db66))
* rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))
* rework TxSubmitProvider to submit transactions as hex string instead of Buffer ([032a1b7](https://github.com/input-output-hk/cardano-js-sdk/commit/032a1b7a11941d52b5baf0d447b615c58a294068))



## [0.6.0-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.5.0...@cardano-sdk/cardano-services@0.6.0-nightly.0) (2022-09-14)


### ⚠ BREAKING CHANGES

* rework TxSubmitProvider to submit transactions as hex string instead of Buffer
* rework all provider signatures args from positional to a single object
* convert boolean args to support ENV counterparts, parse as booleans
* hoist hexString utils to util package

### Features

* **cardano-services:** adds log of incoming requests ([f302f9c](https://github.com/input-output-hk/cardano-js-sdk/commit/f302f9c656b9026b3b19a63a4ce818acea841a77))
* **cardano-services:** enhance metrics endpoint ([0fdbb85](https://github.com/input-output-hk/cardano-js-sdk/commit/0fdbb85777d1d8c79189843ad8c7936a42e22380))


### Bug Fixes

* **cardano-services:** correct interval type and only clear if defined ([a23f384](https://github.com/input-output-hk/cardano-js-sdk/commit/a23f3846d85740675b57c14988ac08e35ee133b9))
* **cardano-services:** handle CardanoTokenRegistry errors ([32a9b1f](https://github.com/input-output-hk/cardano-js-sdk/commit/32a9b1f4714cd556ef3bf2597b52a4d481efcc58))
* convert boolean args to support ENV counterparts, parse as booleans ([d14bd9d](https://github.com/input-output-hk/cardano-js-sdk/commit/d14bd9d8aeec64f04aab094e0aceb8dc5b803926))
* remove nullability of Protocol Parameters ([f75859d](https://github.com/input-output-hk/cardano-js-sdk/commit/f75859d644c2a6c4d4844b179357ccab7db537bf))


### Code Refactoring

* hoist hexString utils to util package ([0c99d9d](https://github.com/input-output-hk/cardano-js-sdk/commit/0c99d9d37f23bb504d1ac2a530fbe78aa045db66))
* rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))
* rework TxSubmitProvider to submit transactions as hex string instead of Buffer ([032a1b7](https://github.com/input-output-hk/cardano-js-sdk/commit/032a1b7a11941d52b5baf0d447b615c58a294068))



## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.4.0...@cardano-sdk/cardano-services@0.5.0) (2022-08-30)


### ⚠ BREAKING CHANGES

* consolidate cli & run entrypoints
* rm TxAlonzo.implicitCoin
* removed Ogmios schema package dependency
* replace `NetworkInfoProvider.timeSettings` with `eraSummaries`
* logger is now required
* contextLogger support
* **cardano-services:** make interface properties name more specific

### Features

* **cardano-services:** add db-sync asset http service ([fb254e5](https://github.com/input-output-hk/cardano-js-sdk/commit/fb254e5e8d6058f891cefb479456558fb3835dd0))
* **cardano-services:** add db-sync asset provider ([9763c59](https://github.com/input-output-hk/cardano-js-sdk/commit/9763c598ef5f1b3c95672424fb57647784024298))
* **cardano-services:** add support for secure db connection ([380a633](https://github.com/input-output-hk/cardano-js-sdk/commit/380a6338db024a8dd7ca960fb93ec4da7d3769b5))
* **cardano-services:** cache stake pool queries ([3b65972](https://github.com/input-output-hk/cardano-js-sdk/commit/3b65972b74d410312005c9c60d1b48c269b81aaa))
* **cardano-services:** root health check endpoint ([aff7c6a](https://github.com/input-output-hk/cardano-js-sdk/commit/aff7c6a2b277d24c067e9cec1a14ffd35e8afb17))
* **cardano-services:** uniform ttl parameter of in memory cache methods to be expressed in seconds ([670d0c1](https://github.com/input-output-hk/cardano-js-sdk/commit/670d0c12589a4385b72c445e5f332e195f3b8000))
* implement tx submit worker error handling ([55bc023](https://github.com/input-output-hk/cardano-js-sdk/commit/55bc023a255a27ecdcf19ee6a2e92cc37b0f3801))
* ogmios cardano node DNS resolution ([d132c9f](https://github.com/input-output-hk/cardano-js-sdk/commit/d132c9f52485086a5cf797217d48c816ae51d2b3))
* replace `NetworkInfoProvider.timeSettings` with `eraSummaries` ([58f6fc7](https://github.com/input-output-hk/cardano-js-sdk/commit/58f6fc7c5ace703583c36f95d3d6962483ad924d))


### Bug Fixes

* **cardano-services:**  empty array and default condition for  identifier filters - search stakePool ([43b8481](https://github.com/input-output-hk/cardano-js-sdk/commit/43b848141d66680001f7cf8efc56d14784077de7))
* **cardano-services:** fixed a division by 0 on APY calculation if epoch lenght is less than 1 day ([bb041cf](https://github.com/input-output-hk/cardano-js-sdk/commit/bb041cf9f36b3eefc38859a1260c9baf585593aa))
* **cardano-services:** initialize CardanoNode ([3c3a5ee](https://github.com/input-output-hk/cardano-js-sdk/commit/3c3a5ee9e6d7068981ed35fcf892992f215473b9))
* **cardano-services:** make HTTP services depend on provider interfaces, rather than classes ([1fef381](https://github.com/input-output-hk/cardano-js-sdk/commit/1fef3819d159e92af6d691d89b0e90a73d9f66ca))
* malformed string and add missing service to Docker defaults ([b40edf6](https://github.com/input-output-hk/cardano-js-sdk/commit/b40edf6f2aec7d654206725e38c88ab1f60d8222))


### Performance Improvements

* improve lovelace supply queries ([7964a2f](https://github.com/input-output-hk/cardano-js-sdk/commit/7964a2f4119c5ee9e8c81589781a8494967b81ee))


### Code Refactoring

* **cardano-services:** make interface properties name more specific ([854408d](https://github.com/input-output-hk/cardano-js-sdk/commit/854408dbf6cf5e7c80280ab104826d8309c801fa))
* consolidate cli & run entrypoints ([1452bfb](https://github.com/input-output-hk/cardano-js-sdk/commit/1452bfb4935129a37dbd83680d623dca081f3948))
* contextLogger support ([6d5da8e](https://github.com/input-output-hk/cardano-js-sdk/commit/6d5da8ec8bba2033ce378d2f0d9321fd758e7c90))
* logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))
* removed Ogmios schema package dependency ([4ed2408](https://github.com/input-output-hk/cardano-js-sdk/commit/4ed24087aa5646c6f68ba31c42fc3f8a317df3b9))
* rm TxAlonzo.implicitCoin ([167d205](https://github.com/input-output-hk/cardano-js-sdk/commit/167d205dd15c857b229f968ab53a6e52e5504d3f))



## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/cardano-services@0.4.0) (2022-07-25)


### ⚠ BREAKING CHANGES

* **cardano-services:** make interface properties name more specific
* **cardano-services:** remove static create
* **cardano-services:** service improvements

### Features

* add new `apy` sort field to stake pools ([161ccd8](https://github.com/input-output-hk/cardano-js-sdk/commit/161ccd83c318bb874e59c39cbb9fc1f9b94e3e32))
* **cardano-services:** add db-sync asset http service ([fb254e5](https://github.com/input-output-hk/cardano-js-sdk/commit/fb254e5e8d6058f891cefb479456558fb3835dd0))
* **cardano-services:** add db-sync asset provider ([9763c59](https://github.com/input-output-hk/cardano-js-sdk/commit/9763c598ef5f1b3c95672424fb57647784024298))
* **cardano-services:** add DbSyncNftMetadataService ([f667c0a](https://github.com/input-output-hk/cardano-js-sdk/commit/f667c0a41365eb658b6ec7e8fe9f74bb80aa5243))
* **cardano-services:** add token metadata provider ([040e0eb](https://github.com/input-output-hk/cardano-js-sdk/commit/040e0eb4e7e116724a759eb13d38b803863338c7))
* **cardano-services:** implements rabbitmq new interface ([a880367](https://github.com/input-output-hk/cardano-js-sdk/commit/a880367bb8044a45645dbd30772040ad9422dc59))
* **cardano-services:** service discovery via DNS ([4d4dd36](https://github.com/input-output-hk/cardano-js-sdk/commit/4d4dd36cd4cdf302efc4797821917bdb22974519))
* **cardano-services:** support loading secrets in run.ts for compatibility with existing pattern ([b9ece18](https://github.com/input-output-hk/cardano-js-sdk/commit/b9ece181b36022d2c7d732ef8342be47d9f9aad8))
* sort stake pools by fixed cost ([6e1d6e4](https://github.com/input-output-hk/cardano-js-sdk/commit/6e1d6e4179794aa92b7d3279e3534beb2ac29978))
* support any network by fetching time settings from the node ([08d9ed2](https://github.com/input-output-hk/cardano-js-sdk/commit/08d9ed2b6aa20cf4df2a063f046f4e5ca28c6bd5))


### Bug Fixes

* allow pool relay nullable fields in open api validation ([e7fe121](https://github.com/input-output-hk/cardano-js-sdk/commit/e7fe1215ee02e8672c269796e49f639268b02483))
* **cardano-services:** add missing ENV to run.ts ([13f8698](https://github.com/input-output-hk/cardano-js-sdk/commit/13f869899ba50390e8abe29424d742590be17ae1))
* **cardano-services:** make HTTP services depend on provider interfaces, rather than classes ([1fef381](https://github.com/input-output-hk/cardano-js-sdk/commit/1fef3819d159e92af6d691d89b0e90a73d9f66ca))
* **cardano-services:** stake pool healthcheck ([90e84ee](https://github.com/input-output-hk/cardano-js-sdk/commit/90e84eee1d3d50e043098f73b01d2d084f46f40f))


### Performance Improvements

* improve lovelace supply queries ([7964a2f](https://github.com/input-output-hk/cardano-js-sdk/commit/7964a2f4119c5ee9e8c81589781a8494967b81ee))


### Code Refactoring

* **cardano-services:** make interface properties name more specific ([854408d](https://github.com/input-output-hk/cardano-js-sdk/commit/854408dbf6cf5e7c80280ab104826d8309c801fa))
* **cardano-services:** remove static create ([7eddc2b](https://github.com/input-output-hk/cardano-js-sdk/commit/7eddc2b5aa44ba96b9fe50d599bc10fa80c0bff8))
* **cardano-services:** service improvements ([6eda4aa](https://github.com/input-output-hk/cardano-js-sdk/commit/6eda4aa5776db6658c3526e0a17a2554bf01c6b0))

## 0.3.0 (2022-06-24)


### ⚠ BREAKING CHANGES

* move stakePoolStats from wallet provider to stake pool provider
* rename `StakePoolSearchProvider` to `StakePoolProvider`
* **cardano-services:** compress the multiple entrypoints into a single top-level set
* **cardano-services:** make TxSubmitHttpServer compatible with createHttpProvider<T>
* **cardano-graphql-services:** remove graphql concerns from services package, rename

### Features

* add ChainHistory http provider ([64aa7ae](https://github.com/input-output-hk/cardano-js-sdk/commit/64aa7aeff061aa2cf9bc6196347f6cf5b9c7f6be))
* add sort stake pools by saturation ([#270](https://github.com/input-output-hk/cardano-js-sdk/issues/270)) ([2a9abff](https://github.com/input-output-hk/cardano-js-sdk/commit/2a9abffae06fc462e1811430c0dc8dfa4520091c))
* add totalResultCount to StakePoolSearch response ([4265f6a](https://github.com/input-output-hk/cardano-js-sdk/commit/4265f6af60a92c93604b93167fd297530b6e01f8))
* add utxo http provider ([a55fcdb](https://github.com/input-output-hk/cardano-js-sdk/commit/a55fcdb08276c37a1852f0c39e5b0a78501ddf0b))
* **cardano-services:** add HttpServer.sendJSON ([c60bcf9](https://github.com/input-output-hk/cardano-js-sdk/commit/c60bcf9d7cf0cd1d0ad993939996d02f7be2af2f))
* **cardano-services:** add pool rewards to stake pool search ([f2ed680](https://github.com/input-output-hk/cardano-js-sdk/commit/f2ed680b3dd37c3aa7ced4c99b3e36cf1bd89f83))
* **cardano-services:** add query for stake pool epoch rewards ([7417896](https://github.com/input-output-hk/cardano-js-sdk/commit/74178962608abaf8b96a3b6f7fe09eea701cbfbf))
* **cardano-services:** add sort by order & field ([dd80375](https://github.com/input-output-hk/cardano-js-sdk/commit/dd8037523275ecd9ea13b695a5fff6515918d8a2))
* **cardano-services:** add stake pools metrics and open api validation ([2c010ee](https://github.com/input-output-hk/cardano-js-sdk/commit/2c010ee32f05f7f22968a70d19e965e21d49bdcb))
* **cardano-services:** added call chain of close method from HttpServer to HttpService to Provider ([aa44bdf](https://github.com/input-output-hk/cardano-js-sdk/commit/aa44bdf2304ae55ac0084efa85d72fea7b1f7445))
* **cardano-services:** adds tx submission via rabbitmq load test ([5f6a160](https://github.com/input-output-hk/cardano-js-sdk/commit/5f6a160b2b6724ab7d387229f6c4d3e73e43bdc8))
* **cardano-services:** create NetworkInfo service ([b003d49](https://github.com/input-output-hk/cardano-js-sdk/commit/b003d499b6fad289b8d9656c6293a4f23856b5ed))
* **cardano-services:** integrated in CLIs TxSubmitWorker from @cardano-sdk/rabbitmq ([56adf12](https://github.com/input-output-hk/cardano-js-sdk/commit/56adf12cd4dcd1e5144a67f2d4c2fca4ec9e1c93))
* **cardano-services:** log services HTTP server is using ([7da7802](https://github.com/input-output-hk/cardano-js-sdk/commit/7da7802aef5a93128dbe8eefc5e744631c0a8b8a))
* **cardano-services:** run multiple services from a single HTTP server ([35770e0](https://github.com/input-output-hk/cardano-js-sdk/commit/35770e0ee2767e4a9352c4ebbc09563c80be1f65))
* **cardano-services:** stake pool search http server ([c3dd013](https://github.com/input-output-hk/cardano-js-sdk/commit/c3dd0133843327906535ce2ac623482cf95dd397))
* create InMemoryCache ([a2bfcc6](https://github.com/input-output-hk/cardano-js-sdk/commit/a2bfcc62c25e71d78d07b961267d7ce9679b6cf4))
* rewards data ([5ce2ff0](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce2ff00856d362cf0e423ddadadb15cef764932))


### Bug Fixes

* **cardano-services:** added @cardano-sdk/rabbitmq dependency ([f561a1e](https://github.com/input-output-hk/cardano-js-sdk/commit/f561a1e49be3ecba7a0c16dac516c4ad0db7b30c))
* **cardano-services:** align exit codes on error ([ce8464f](https://github.com/input-output-hk/cardano-js-sdk/commit/ce8464fe4f2f3bb3853667bb95e366d2a7fa700b))
* **cardano-services:** change stake pool search response body data to match provider method ([d83d4af](https://github.com/input-output-hk/cardano-js-sdk/commit/d83d4afd1476edf1b36d50f607e0fb2b75854661))
* **cardano-services:** fix findPoolEpoch rewards, add rounding ([e386211](https://github.com/input-output-hk/cardano-js-sdk/commit/e386211f3b4f5307f2001bce792c24e1deba3182))
* **cardano-services:** fix findPoolsOwners query ([619b2b8](https://github.com/input-output-hk/cardano-js-sdk/commit/619b2b8dacdc1f7efa4bdae69c46f253f14df7c8))
* **cardano-services:** fix pools_delegated on pledgeMet query ([a68771a](https://github.com/input-output-hk/cardano-js-sdk/commit/a68771a36884dc03b3badd61162f5f86e0765ef4))
* **cardano-services:** fixed bin entry in package.json ([de9b89e](https://github.com/input-output-hk/cardano-js-sdk/commit/de9b89e0d6a0d624d9dbc91f4aea2a623597de74))
* **cardano-services:** health check api can now be called in get as well ([b68e90c](https://github.com/input-output-hk/cardano-js-sdk/commit/b68e90c9d194e707d6bd7397cb391735b248849a))
* **cardano-services:** resolve package.json path when cli is run with ts-node ([9c77218](https://github.com/input-output-hk/cardano-js-sdk/commit/9c77218c459834911286dfe95a44a140312fd76f))
* **cardano-services:** updates NetworkInfo OpenAPI spec to align with refactor ([626e8be](https://github.com/input-output-hk/cardano-js-sdk/commit/626e8be65e367d139b7444621355ac1918305673))
* division by zero error at pool rewards query ([#280](https://github.com/input-output-hk/cardano-js-sdk/issues/280)) ([116ed12](https://github.com/input-output-hk/cardano-js-sdk/commit/116ed128d488f211639f5648030e30cfa4855fcb))
* use ordering within UTxO query for reproducible results ([889b437](https://github.com/input-output-hk/cardano-js-sdk/commit/889b43773bdab51eb204ad3a7406b4ddb48000a4))


### Performance Improvements

* **cardano-services:** enhance cache get method ([99b2b9d](https://github.com/input-output-hk/cardano-js-sdk/commit/99b2b9db0e0f0a5e1171690ab519f1424e46c283))


### Miscellaneous Chores

* **cardano-graphql-services:** remove graphql concerns from services package, rename ([71a939b](https://github.com/input-output-hk/cardano-js-sdk/commit/71a939b874296d86183d89fce7877c565630e921))


### Code Refactoring

* **cardano-services:** compress the multiple entrypoints into a single top-level set ([4c3c975](https://github.com/input-output-hk/cardano-js-sdk/commit/4c3c9750006eb987edd7eb5b1a0f9038fcb154d9))
* **cardano-services:** make TxSubmitHttpServer compatible with createHttpProvider<T> ([131f234](https://github.com/input-output-hk/cardano-js-sdk/commit/131f2349b2e54be4765a1db1505d2e7ac4504089))
* move stakePoolStats from wallet provider to stake pool provider ([52d71a7](https://github.com/input-output-hk/cardano-js-sdk/commit/52d71a70700b05902cca6205fe01a63f811ba5af))
* rename `StakePoolSearchProvider` to `StakePoolProvider` ([b432103](https://github.com/input-output-hk/cardano-js-sdk/commit/b43210348da7914664733f85f8be8999271a8667))
