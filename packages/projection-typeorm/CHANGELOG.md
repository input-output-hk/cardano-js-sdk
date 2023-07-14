# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.3.9-patch.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection-typeorm@0.3.8...@cardano-sdk/projection-typeorm@0.3.9-patch.0) (2023-07-14)

**Note:** Version bump only for package @cardano-sdk/projection-typeorm

## [0.3.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection-typeorm@0.3.7...@cardano-sdk/projection-typeorm@0.3.8) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/projection-typeorm

## [0.3.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection-typeorm@0.3.6...@cardano-sdk/projection-typeorm@0.3.7) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/projection-typeorm

## [0.3.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection-typeorm@0.3.5...@cardano-sdk/projection-typeorm@0.3.6) (2023-06-28)

### Bug Fixes

* unsupported character bug in handles projection ([4144ed2](https://github.com/input-output-hk/cardano-js-sdk/commit/4144ed2925f1c5b118c411ac5eedc3e4a62d3893))

## [0.3.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection-typeorm@0.3.4...@cardano-sdk/projection-typeorm@0.3.5) (2023-06-23)

**Note:** Version bump only for package @cardano-sdk/projection-typeorm

## [0.3.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection-typeorm@0.3.3...@cardano-sdk/projection-typeorm@0.3.4) (2023-06-20)

**Note:** Version bump only for package @cardano-sdk/projection-typeorm

## [0.3.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection-typeorm@0.3.2...@cardano-sdk/projection-typeorm@0.3.3) (2023-06-13)

**Note:** Version bump only for package @cardano-sdk/projection-typeorm

## [0.3.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection-typeorm@0.3.1...@cardano-sdk/projection-typeorm@0.3.2) (2023-06-12)

**Note:** Version bump only for package @cardano-sdk/projection-typeorm

## [0.3.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection-typeorm@0.3.0...@cardano-sdk/projection-typeorm@0.3.1) (2023-06-06)

**Note:** Version bump only for package @cardano-sdk/projection-typeorm

## [0.3.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection-typeorm@0.2.3...@cardano-sdk/projection-typeorm@0.3.0) (2023-06-05)

### ⚠ BREAKING CHANGES

* hoist Cardano.Percent to util package

### Features

* add handle projection ([1d3f4ca](https://github.com/input-output-hk/cardano-js-sdk/commit/1d3f4ca3cfa3f1dfb668847de58eba4d0402d48e))
* add stake pool metadata entity relation ([99a40b7](https://github.com/input-output-hk/cardano-js-sdk/commit/99a40b79a8809c472c7780bcb626451345b65958))

### Code Refactoring

* hoist Cardano.Percent to util package ([e4da0e3](https://github.com/input-output-hk/cardano-js-sdk/commit/e4da0e3851a4bdfd503c1f195c5ba1455ea6675b))

## [0.2.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection-typeorm@0.2.2...@cardano-sdk/projection-typeorm@0.2.3) (2023-06-01)

### Features

* **projection-typeorm:** add stake pools metrics computation job schedule ([a5f56e9](https://github.com/input-output-hk/cardano-js-sdk/commit/a5f56e9105ae2ed1fddb2a64c1c6aeef5016f51a))

## [0.2.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection-typeorm@0.2.1...@cardano-sdk/projection-typeorm@0.2.2) (2023-05-24)

**Note:** Version bump only for package @cardano-sdk/projection-typeorm

## [0.2.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection-typeorm@0.2.0...@cardano-sdk/projection-typeorm@0.2.1) (2023-05-22)

### Features

* add the the pg-boss worker ([561fd50](https://github.com/input-output-hk/cardano-js-sdk/commit/561fd508a4a96307b023b16ce6fed3ce1d7bd536))

## [0.2.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection-typeorm@0.1.1...@cardano-sdk/projection-typeorm@0.2.0) (2023-05-02)

### ⚠ BREAKING CHANGES

- **projection-typeorm:** change Block primary key col to slot
- remove one layer of projection abstraction
- hoist patchObject from util-dev to util package
- **projection:** convert projectIntoSink into rxjs operator
- simplify projection Sink to be an operator
- **projection-typeorm:** use block height as Block primary key

### Features

- **projection-typeorm:** add 'allowNonSequentialBlockHeights' option ([83c29fe](https://github.com/input-output-hk/cardano-js-sdk/commit/83c29fe465cdd5629e650267b0b45a0d8bfb208e))
- **projection-typeorm:** add AssetEntity and storeAssets operator ([c485649](https://github.com/input-output-hk/cardano-js-sdk/commit/c4856496fed1b9c57fd4d3e397b61ac9d30355a9))
- **projection-typeorm:** add stakePoolMetadata sink ([77f0c67](https://github.com/input-output-hk/cardano-js-sdk/commit/77f0c675e6a55f8836609d17b897da487276c2b3))
- **projection-typeorm:** add stakePools sink ([8b90d02](https://github.com/input-output-hk/cardano-js-sdk/commit/8b90d02cd1138c46c5bff29229c7f803fec5f730))
- **projection-typeorm:** add storeUtxo operator and entities ([4a44d52](https://github.com/input-output-hk/cardano-js-sdk/commit/4a44d52971cc9438ce61594045d11de94c2ca84d))
- **projection-typeorm:** change Block primary key col to slot ([1fe8f1c](https://github.com/input-output-hk/cardano-js-sdk/commit/1fe8f1c304bb69010428081618946995b8a323f0))
- **projection-typeorm:** improve withTypeormTransaction overload types ([1b74c16](https://github.com/input-output-hk/cardano-js-sdk/commit/1b74c1623244edf9a797abbf4bbbcba6dce6c253))

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))

### Code Refactoring

- hoist patchObject from util-dev to util package ([bea7e03](https://github.com/input-output-hk/cardano-js-sdk/commit/bea7e035ebdcd7241b6f3cc8feb5fbcfdb90fa46))
- **projection-typeorm:** use block height as Block primary key ([26bd8ad](https://github.com/input-output-hk/cardano-js-sdk/commit/26bd8add501f282316abfa46012858de4dcb7867))
- **projection:** convert projectIntoSink into rxjs operator ([490ca1b](https://github.com/input-output-hk/cardano-js-sdk/commit/490ca1b7f0f92e4fa84179ba3fb265ee68dee735))
- remove one layer of projection abstraction ([6a0eca9](https://github.com/input-output-hk/cardano-js-sdk/commit/6a0eca92d1b6507e7143bfb5a93974b59757d5c5))
- simplify projection Sink to be an operator ([d9c6826](https://github.com/input-output-hk/cardano-js-sdk/commit/d9c68265d63300d26eb73ca93f5ee8be7ff51a12))

## 0.1.1 (2023-03-13)

### Features

- **projection-typeorm:** initial implementation ([d0d8ccb](https://github.com/input-output-hk/cardano-js-sdk/commit/d0d8ccbfac6e5732497cd1719c005a4cc241f30c))
