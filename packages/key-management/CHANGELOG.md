# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.3.0-nightly.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.3.0-nightly.0...@cardano-sdk/key-management@0.3.0-nightly.1) (2022-12-07)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.3.0-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.2.1-nightly.3...@cardano-sdk/key-management@0.3.0-nightly.0) (2022-12-05)

### ⚠ BREAKING CHANGES

- rename era-specific types in core

### Features

- **key-management:** ownSignatureKeyPaths now checks for reward account in certificates ([b8ab595](https://github.com/input-output-hk/cardano-js-sdk/commit/b8ab59588475f7cf2b4773f6e8fda084d74aeac0))
- rename era-specific types in core ([c4955b1](https://github.com/input-output-hk/cardano-js-sdk/commit/c4955b1f3ae0992bb55b1c1461a1e449be0b6ef2))
- type GroupedAddress now includes key derivation paths ([8ac0125](https://github.com/input-output-hk/cardano-js-sdk/commit/8ac0125152fa2f3eb95c3e4c32bee077d2df722f))

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
- **key-management:** compile error in test file ([aeface7](https://github.com/input-output-hk/cardano-js-sdk/commit/aeface7d44416864256011f8ef8028cf38133470))

## [0.2.1-nightly.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.2.1-nightly.2...@cardano-sdk/key-management@0.2.1-nightly.3) (2022-12-01)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.2.1-nightly.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.2.1-nightly.1...@cardano-sdk/key-management@0.2.1-nightly.2) (2022-11-24)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.2.1-nightly.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.2.1-nightly.0...@cardano-sdk/key-management@0.2.1-nightly.1) (2022-11-22)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.2.1-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.2.0...@cardano-sdk/key-management@0.2.1-nightly.0) (2022-11-08)

**Note:** Version bump only for package @cardano-sdk/key-management

## 0.2.0 (2022-11-04)

### ⚠ BREAKING CHANGES

- free CSL resources using freeable util
- **dapp-connector:** renamed cip30 package to dapp-connector
- hoist core Address namespace to Cardano.util
- rename `TxInternals` to `TxBodyWithHash`
- **key-management:** deprecate insecure `cachedGetPassword`
- lift key management and governance concepts to new packages

### Bug Fixes

- free CSL resources using freeable util ([5ce0056](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce0056fb108f7bccfbd9f8ef562b82277f3c613))
- **key-management:** custom errors no longer hide inner error details ([0b80e78](https://github.com/input-output-hk/cardano-js-sdk/commit/0b80e786c3a664ca34bc40af8f69d20ccfefa02e))
- **key-management:** don't sign withdrawals for non-own reward accounts ([fd9b254](https://github.com/input-output-hk/cardano-js-sdk/commit/fd9b254a13e60a3c151e87c9053f305ff3532dd6))
- **key-management:** tx that has withdrawals is now signed with stake key ([972a064](https://github.com/input-output-hk/cardano-js-sdk/commit/972a0640970bd140c4f54df8ff9d1b38858aa4ab))

### Code Refactoring

- **dapp-connector:** renamed cip30 package to dapp-connector ([cb4411d](https://github.com/input-output-hk/cardano-js-sdk/commit/cb4411da916b263ad8a6d85e0bdaffcfe21646c5))
- hoist core Address namespace to Cardano.util ([c0af6c3](https://github.com/input-output-hk/cardano-js-sdk/commit/c0af6c333420b4305f021a50bbdf25317b85554f))
- **key-management:** deprecate insecure `cachedGetPassword` ([441842a](https://github.com/input-output-hk/cardano-js-sdk/commit/441842a53e774239c6a2c39ce1b000599fde830d))
- lift key management and governance concepts to new packages ([15cde5f](https://github.com/input-output-hk/cardano-js-sdk/commit/15cde5f9becff94dac17278cb45e3adcaac763b5))
- rename `TxInternals` to `TxBodyWithHash` ([77567aa](https://github.com/input-output-hk/cardano-js-sdk/commit/77567aab56395ded6d9b0ba7488aacc2d3f856a0))
