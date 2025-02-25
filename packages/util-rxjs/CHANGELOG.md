# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.9.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.9.8...@cardano-sdk/util-rxjs@0.9.9) (2025-02-25)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.9.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.9.7...@cardano-sdk/util-rxjs@0.9.8) (2025-02-24)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.9.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.9.6...@cardano-sdk/util-rxjs@0.9.7) (2025-02-19)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.9.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.9.5...@cardano-sdk/util-rxjs@0.9.6) (2025-02-06)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.9.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.9.4...@cardano-sdk/util-rxjs@0.9.5) (2025-01-31)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.9.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.9.3...@cardano-sdk/util-rxjs@0.9.4) (2025-01-20)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.9.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.9.2...@cardano-sdk/util-rxjs@0.9.3) (2025-01-17)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.9.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.9.1...@cardano-sdk/util-rxjs@0.9.2) (2025-01-09)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.9.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.9.0...@cardano-sdk/util-rxjs@0.9.1) (2025-01-02)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.8.0...@cardano-sdk/util-rxjs@0.9.0) (2024-12-20)

### ⚠ BREAKING CHANGES

* BaseWallet observables error instead of emitting fatalError$
- remove ObservableError.fatalError$
- 'poll' util observable errors instead of calling onFatalError
- remove PollProps.onFatalError
- 'poll' no longer checks for InvalidStringError, it's up to consumer
* rename poll props 'provider' to 'sample'

### Bug Fixes

* retry all ProviderErrors except BadRequest and NotImplemented ([bf4a8b9](https://github.com/input-output-hk/cardano-js-sdk/commit/bf4a8b99b4e7af58021c8081d5011eacb65f3422))

### Code Refactoring

* rename 'coldObservableProvider' util to 'poll' ([9bad2df](https://github.com/input-output-hk/cardano-js-sdk/commit/9bad2df58d48e920881da68adf51c20ee1d7c886))

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.43...@cardano-sdk/util-rxjs@0.8.0) (2024-12-05)

### ⚠ BREAKING CHANGES

* coldObservableProvider logs errors

### Features

* coldObservableProvider logs errors ([b2caa15](https://github.com/input-output-hk/cardano-js-sdk/commit/b2caa157416747d0e7ad28c941d31dbf55abad78))

## [0.7.43](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.42...@cardano-sdk/util-rxjs@0.7.43) (2024-12-02)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.42](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.41...@cardano-sdk/util-rxjs@0.7.42) (2024-12-02)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.41](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.40...@cardano-sdk/util-rxjs@0.7.41) (2024-11-23)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.40](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.39...@cardano-sdk/util-rxjs@0.7.40) (2024-11-20)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.39](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.38...@cardano-sdk/util-rxjs@0.7.39) (2024-11-18)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.38](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.37...@cardano-sdk/util-rxjs@0.7.38) (2024-10-25)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.37](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.36...@cardano-sdk/util-rxjs@0.7.37) (2024-10-11)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.36](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.35...@cardano-sdk/util-rxjs@0.7.36) (2024-10-06)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.35](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.34...@cardano-sdk/util-rxjs@0.7.35) (2024-10-03)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.34](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.33...@cardano-sdk/util-rxjs@0.7.34) (2024-09-27)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.33](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.32...@cardano-sdk/util-rxjs@0.7.33) (2024-09-25)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.32](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.31...@cardano-sdk/util-rxjs@0.7.32) (2024-09-12)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.31](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.30...@cardano-sdk/util-rxjs@0.7.31) (2024-09-10)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.30](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.29...@cardano-sdk/util-rxjs@0.7.30) (2024-09-06)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.29](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.28...@cardano-sdk/util-rxjs@0.7.29) (2024-09-04)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.28](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.27...@cardano-sdk/util-rxjs@0.7.28) (2024-08-23)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.27](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.26...@cardano-sdk/util-rxjs@0.7.27) (2024-08-22)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.26](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.25...@cardano-sdk/util-rxjs@0.7.26) (2024-08-21)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.25](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.24...@cardano-sdk/util-rxjs@0.7.25) (2024-08-20)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.24](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.23...@cardano-sdk/util-rxjs@0.7.24) (2024-08-07)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.23](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.22...@cardano-sdk/util-rxjs@0.7.23) (2024-08-01)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.22](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.21...@cardano-sdk/util-rxjs@0.7.22) (2024-07-31)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.21](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.20...@cardano-sdk/util-rxjs@0.7.21) (2024-07-25)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.20](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.19...@cardano-sdk/util-rxjs@0.7.20) (2024-07-22)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.19](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.18...@cardano-sdk/util-rxjs@0.7.19) (2024-07-11)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.18](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.17...@cardano-sdk/util-rxjs@0.7.18) (2024-06-20)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.17](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.16...@cardano-sdk/util-rxjs@0.7.17) (2024-06-17)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.16](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.15...@cardano-sdk/util-rxjs@0.7.16) (2024-06-14)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.15](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.14...@cardano-sdk/util-rxjs@0.7.15) (2024-06-05)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.14](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.13...@cardano-sdk/util-rxjs@0.7.14) (2024-05-20)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.13](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.12...@cardano-sdk/util-rxjs@0.7.13) (2024-05-02)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.12](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.11...@cardano-sdk/util-rxjs@0.7.12) (2024-04-26)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.10...@cardano-sdk/util-rxjs@0.7.11) (2024-04-23)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.9...@cardano-sdk/util-rxjs@0.7.10) (2024-04-15)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.8...@cardano-sdk/util-rxjs@0.7.9) (2024-03-26)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.7...@cardano-sdk/util-rxjs@0.7.8) (2024-03-12)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.6...@cardano-sdk/util-rxjs@0.7.7) (2024-02-29)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.5...@cardano-sdk/util-rxjs@0.7.6) (2024-02-28)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.4...@cardano-sdk/util-rxjs@0.7.5) (2024-02-23)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.3...@cardano-sdk/util-rxjs@0.7.4) (2024-02-12)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.2...@cardano-sdk/util-rxjs@0.7.3) (2024-02-08)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.1...@cardano-sdk/util-rxjs@0.7.2) (2024-02-07)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.7.0...@cardano-sdk/util-rxjs@0.7.1) (2024-02-02)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.6.11...@cardano-sdk/util-rxjs@0.7.0) (2024-02-02)

### ⚠ BREAKING CHANGES

* TrackerSubject.value$ type changed to T | typeof TrackerSubject.NO_VALUE

### Bug Fixes

* emit null through remote api when no wallet is active ([bd9b6cd](https://github.com/input-output-hk/cardano-js-sdk/commit/bd9b6cd02854f9e1cdd6935089f945ad8d030e24))

## [0.6.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.6.10...@cardano-sdk/util-rxjs@0.6.11) (2024-01-31)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.6.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.6.9...@cardano-sdk/util-rxjs@0.6.10) (2024-01-25)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.6.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.6.8...@cardano-sdk/util-rxjs@0.6.9) (2024-01-17)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.6.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.6.7...@cardano-sdk/util-rxjs@0.6.8) (2024-01-05)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.6.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.6.6...@cardano-sdk/util-rxjs@0.6.7) (2023-12-21)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.6.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.6.5...@cardano-sdk/util-rxjs@0.6.6) (2023-12-20)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.6.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.6.4...@cardano-sdk/util-rxjs@0.6.5) (2023-12-14)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.6.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.6.3...@cardano-sdk/util-rxjs@0.6.4) (2023-12-12)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.6.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.6.2...@cardano-sdk/util-rxjs@0.6.3) (2023-12-07)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.6.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.6.1...@cardano-sdk/util-rxjs@0.6.2) (2023-12-04)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.6.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.6.0...@cardano-sdk/util-rxjs@0.6.1) (2023-11-29)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.14...@cardano-sdk/util-rxjs@0.6.0) (2023-10-19)

### ⚠ BREAKING CHANGES

* hoist ReconnectionConfig type from ogmios to util-rxjs

### Code Refactoring

* hoist ReconnectionConfig type from ogmios to util-rxjs ([704b5d6](https://github.com/input-output-hk/cardano-js-sdk/commit/704b5d6c82e6290c5f08800311d36d1b5d7a1eeb))

## [0.5.14](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.13...@cardano-sdk/util-rxjs@0.5.14) (2023-10-12)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.5.13](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.12...@cardano-sdk/util-rxjs@0.5.13) (2023-10-09)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.5.12](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.11...@cardano-sdk/util-rxjs@0.5.12) (2023-09-29)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.5.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.10...@cardano-sdk/util-rxjs@0.5.11) (2023-09-20)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.5.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.9...@cardano-sdk/util-rxjs@0.5.10) (2023-09-12)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.5.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.8...@cardano-sdk/util-rxjs@0.5.9) (2023-08-29)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.5.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.7...@cardano-sdk/util-rxjs@0.5.8) (2023-08-21)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.5.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.6...@cardano-sdk/util-rxjs@0.5.7) (2023-08-15)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.5.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.5...@cardano-sdk/util-rxjs@0.5.6) (2023-08-11)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.5.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.4...@cardano-sdk/util-rxjs@0.5.5) (2023-07-31)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.5.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.3...@cardano-sdk/util-rxjs@0.5.4) (2023-07-13)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.5.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.2...@cardano-sdk/util-rxjs@0.5.3) (2023-07-04)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.5.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.1...@cardano-sdk/util-rxjs@0.5.2) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.5.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.5.0...@cardano-sdk/util-rxjs@0.5.1) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.16...@cardano-sdk/util-rxjs@0.5.0) (2023-06-28)

### ⚠ BREAKING CHANGES

* move coldObservableProvider to util-rxjs package

### Code Refactoring

* move coldObservableProvider to util-rxjs package ([3522d0c](https://github.com/input-output-hk/cardano-js-sdk/commit/3522d0cbbde21c59e483d769cee14ffee4648972))

## [0.4.16](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.15...@cardano-sdk/util-rxjs@0.4.16) (2023-06-23)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.4.15](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.14...@cardano-sdk/util-rxjs@0.4.15) (2023-06-20)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.4.14](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.13...@cardano-sdk/util-rxjs@0.4.14) (2023-06-13)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.4.13](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.12...@cardano-sdk/util-rxjs@0.4.13) (2023-06-12)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.4.12](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.11...@cardano-sdk/util-rxjs@0.4.12) (2023-06-06)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.4.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.10...@cardano-sdk/util-rxjs@0.4.11) (2023-06-05)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.4.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.9...@cardano-sdk/util-rxjs@0.4.10) (2023-06-01)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.4.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.8...@cardano-sdk/util-rxjs@0.4.9) (2023-05-24)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.4.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.7...@cardano-sdk/util-rxjs@0.4.8) (2023-05-22)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.4.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.6...@cardano-sdk/util-rxjs@0.4.7) (2023-05-02)

### Features

- **util-rxjs:** add shareRetryBackoff operator ([b0f5eb5](https://github.com/input-output-hk/cardano-js-sdk/commit/b0f5eb5fe06c26eb7eece263017f11fb151b9101))
- **wallet:** concatAndCombineLatest creator function ([305f2ed](https://github.com/input-output-hk/cardano-js-sdk/commit/305f2ed0039c8f355e4b973c41392c8c601b9312))

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))

## [0.4.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.5...@cardano-sdk/util-rxjs@0.4.6) (2023-03-13)

### Features

- **util-rxjs:** add finalizeWithLatest operator ([efb46ec](https://github.com/input-output-hk/cardano-js-sdk/commit/efb46eca852dee9faa0e6004a64b3227e0fb62fe))

## [0.4.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.4...@cardano-sdk/util-rxjs@0.4.5) (2023-03-01)

### Bug Fixes

- **util-rxjs:** blockingWithLatestFrom now unsubscribes from dependency when source completes ([246f74f](https://github.com/input-output-hk/cardano-js-sdk/commit/246f74f0892121a74f502fd2eb04cf095cbe087a))
- **util-rxjs:** set blockingWithLatestFrom mergeScan concurrency to 1 ([8e7108a](https://github.com/input-output-hk/cardano-js-sdk/commit/8e7108a1115a1ce3d4240803aaf5537ca47803b9))

## [0.4.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.3...@cardano-sdk/util-rxjs@0.4.4) (2023-02-17)

### Features

- **util-rxjs:** add 'passthrough' operator ([5696105](https://github.com/input-output-hk/cardano-js-sdk/commit/5696105729bf5839c1e07603333c4f69efd5d080))

### Bug Fixes

- **util-rxjs:** rework blockingWithLatestFrom ([3d9e41c](https://github.com/input-output-hk/cardano-js-sdk/commit/3d9e41cbc309557fdc080587b7394de654a115ee))

## [0.4.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.2...@cardano-sdk/util-rxjs@0.4.3) (2022-12-22)

### Features

- initial projection implementation ([8a93d8d](https://github.com/input-output-hk/cardano-js-sdk/commit/8a93d8d427eb947b6f34566f8a694fcedfe0e59f))
- **util-rxjs:** add blockingWithLatestFrom and toEmpty operators ([d2e84a9](https://github.com/input-output-hk/cardano-js-sdk/commit/d2e84a996de47df7ce181ca0845a23e3d0105734))

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))

## [0.4.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.1...@cardano-sdk/util-rxjs@0.4.2) (2022-11-04)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.4.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-rxjs@0.4.0...@cardano-sdk/util-rxjs@0.4.1) (2022-08-30)

**Note:** Version bump only for package @cardano-sdk/util-rxjs

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/util-rxjs@0.4.0) (2022-07-25)

## 0.3.0 (2022-06-24)
