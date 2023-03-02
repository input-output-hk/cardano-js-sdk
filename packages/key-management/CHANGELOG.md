# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.4.2-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.4.1...@cardano-sdk/key-management@0.4.2-nightly.0) (2023-03-02)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.4.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.4.0...@cardano-sdk/key-management@0.4.1) (2023-03-01)

### Bug Fixes

- **key-management:** correct logic in mint/burn hardware wallet mapping ([674ad20](https://github.com/input-output-hk/cardano-js-sdk/commit/674ad20b05d24b619076f481cc14bfe7ab1dd790))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.3.0...@cardano-sdk/key-management@0.4.0) (2023-02-17)

### ⚠ BREAKING CHANGES

- replaces occurrences of password with passphrase
- - Bip32PublicKey removed from core and replaced by the Bip32PublicKeyHex type from the crypto package.

* Bip32PrivateKey removed from core and replaced by the Bip32PrivateKeyHex type from the crypto package.
* Ed25519PublicKey removed from core and replaced by the Ed25519PublicKeyHex type from the crypto package.
* Ed25519PrivateKey removed from core and replaced by the Ed25519PrivateKeyHex type from the crypto package.
* Ed25519KeyHash removed from core and replaced by the Ed25519KeyHashHex type from the the crypto package.
* Ed25519Signature removed from core and replaced by the Ed25519SignatureHex type from the crypto package.
* Hash32ByteBase16 removed from core and replaced by the Hash32ByteBase16 type from the crypto package.
* Hash28ByteBase16 removed from core and replaced by the Hash28ByteBase16 type from the crypto package.
* The KeyAgent interface now has a new field bip32Ed25519.
* The KeyAgentBase class and all its derived classes (InMemoryKeyAgent, LedgerKeyAgent and TrezorKeyAgent) must now be provided with a Bip32Ed25519 implementation on their constructors.
* Bip32Path type was removed from the key-management package and replaced by the Bip32Path from the crypto package.

- hoist Opaque types, hexBlob, Base64Blob and related utils

### Bug Fixes

- **key-management:** correct ledger tx mapping validityIntervalStart prop name ([4627230](https://github.com/input-output-hk/cardano-js-sdk/commit/4627230ff0eb26a473cf3dc1c4c544d5bee8bb09))

### Code Refactoring

- hoist Opaque types, hexBlob, Base64Blob and related utils ([391a8f2](https://github.com/input-output-hk/cardano-js-sdk/commit/391a8f20d60607c4fb6ce8586b97ae96841f759b))
- refactor the SDK to use the new crypto package ([3b41320](https://github.com/input-output-hk/cardano-js-sdk/commit/3b41320e7971a231d50785733ff4cd0793418d3d))
- replaces occurrences of password with passphrase ([0c0ec5f](https://github.com/input-output-hk/cardano-js-sdk/commit/0c0ec5fba7a0f7595dbca5b2ab1c66e58ac49e36))

## [0.3.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.2.0...@cardano-sdk/key-management@0.3.0) (2022-12-22)

### ⚠ BREAKING CHANGES

- - replace KeyAgent.networkId with KeyAgent.chainId

* remove CardanoNetworkId type
* rename CardanoNetworkMagic->NetworkMagics
* add 'logger' to KeyAgentDependencies
* setupWallet now requires a Logger

- use titlecase for mainnet/testnet in NetworkId
- rename era-specific types in core

### Features

- **key-management:** expose extendedAccountPublicKey in AsyncKeyAgent ([122b281](https://github.com/input-output-hk/cardano-js-sdk/commit/122b281bc460924e5f69c59c896dec4d056d5de8))
- **key-management:** ownSignatureKeyPaths now checks for reward account in certificates ([b8ab595](https://github.com/input-output-hk/cardano-js-sdk/commit/b8ab59588475f7cf2b4773f6e8fda084d74aeac0))
- rename era-specific types in core ([c4955b1](https://github.com/input-output-hk/cardano-js-sdk/commit/c4955b1f3ae0992bb55b1c1461a1e449be0b6ef2))
- replace KeyAgent.networkId with KeyAgent.chainId ([e44dee0](https://github.com/input-output-hk/cardano-js-sdk/commit/e44dee054611636f34b0a66e27d7971af01e0296))
- type GroupedAddress now includes key derivation paths ([8ac0125](https://github.com/input-output-hk/cardano-js-sdk/commit/8ac0125152fa2f3eb95c3e4c32bee077d2df722f))

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
- **key-management:** compile error in test file ([aeface7](https://github.com/input-output-hk/cardano-js-sdk/commit/aeface7d44416864256011f8ef8028cf38133470))

### Code Refactoring

- use titlecase for mainnet/testnet in NetworkId ([252c589](https://github.com/input-output-hk/cardano-js-sdk/commit/252c589480d3e422b9021ea66a67af978fb80264))

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
