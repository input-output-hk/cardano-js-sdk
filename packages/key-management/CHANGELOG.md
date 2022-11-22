# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

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
