# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.4.1-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.4.0...@cardano-sdk/tx-construction@0.4.1-nightly.0) (2023-05-04)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.3.0...@cardano-sdk/tx-construction@0.4.0) (2023-05-02)

### ⚠ BREAKING CHANGES

- - auxiliaryDataHash is now included in the TxBody core type.

* networkId is now included in the TxBody core type.
* auxiliaryData no longer contains the optional hash field.
* auxiliaryData no longer contains the optional body field.

### Features

- added new Transaction class that can convert between CBOR and the Core Tx type ([cc9a80c](https://github.com/input-output-hk/cardano-js-sdk/commit/cc9a80c17f1c0f46124b0c04c597a7ff96e517d3))
- transaction body core type now includes the auxiliaryDataHash and networkId fields ([8b92b01](https://github.com/input-output-hk/cardano-js-sdk/commit/8b92b0190083a2b956ae1e188121414428f6663b))

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))

## [0.3.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.2.1...@cardano-sdk/tx-construction@0.3.0) (2023-03-13)

### ⚠ BREAKING CHANGES

- core type for address string reprensetation 'Address' renamed to PaymentAddress

### Code Refactoring

- core type for address string reprensetation 'Address' renamed to PaymentAddress ([4287463](https://github.com/input-output-hk/cardano-js-sdk/commit/42874633de6069510efdc57323f61140d22ed203))

## [0.2.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.2.0...@cardano-sdk/tx-construction@0.2.1) (2023-03-01)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## 0.2.0 (2023-02-17)

### ⚠ BREAKING CHANGES

- - The default input selection constraints were moved from input-selection package to tx-construction package.

### Features

- new tx construction package added ([45c0c75](https://github.com/input-output-hk/cardano-js-sdk/commit/45c0c75b20f766a069af45cec636a1756a3fc0da))
