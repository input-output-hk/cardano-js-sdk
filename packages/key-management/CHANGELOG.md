# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.20.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.20.2...@cardano-sdk/key-management@0.20.3) (2024-04-26)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.20.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.20.1...@cardano-sdk/key-management@0.20.2) (2024-04-23)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.20.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.20.0...@cardano-sdk/key-management@0.20.1) (2024-03-26)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.20.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.19.10...@cardano-sdk/key-management@0.20.0) (2024-03-12)

### ⚠ BREAKING CHANGES

* finalizeTx was added to the Witnesser interface
- the PersonalWallet was renamed BaseWallet
- all code specific to Bip32 wallet have been abstracted out of the BaseWallet
- the PersonalWallet must now be constructed with the createPersonalWallet util function
- the SignedTx type was renamed to WitnessedTx
- the UnsignedTx type was renamed to UnwitnessedTx
- the Witness method from the Witnesser interface now returns a WitnessedTx
- extraSigners was moved from the witness field to the signingOptions in both the wallet FinalizeTxProps and witness signingOptions
- wallet repository script wallets ownSigners type now includes paymentScriptKeyPath and stakingScriptKeyPath
- wallet repository script wallets script field replaced by paymentScript and stakingScript
- stubSignTransaction util function now takes and optional dRepPublicKey as part of the context
* bip32Account is now an optional TxBuilder dependency

### Features

* added SharedWallet implementation ([272f392](https://github.com/input-output-hk/cardano-js-sdk/commit/272f3923ac872337cdf1f8647ac07c6a7a78384a))
* finalizeTxDependencies no longer requires a bip32Account, but should provide a dRepPublicKey if available ([eaf01dd](https://github.com/input-output-hk/cardano-js-sdk/commit/eaf01dd4135a37c77295e4c587f9897e9eb50890))

## [0.19.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.19.9...@cardano-sdk/key-management@0.19.10) (2024-02-29)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.19.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.19.8...@cardano-sdk/key-management@0.19.9) (2024-02-28)

### Features

* sign own dRep registration certificate ([b384e85](https://github.com/input-output-hk/cardano-js-sdk/commit/b384e85d8449b96e0115111d2313e0fe5d60103d))

## [0.19.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.19.7...@cardano-sdk/key-management@0.19.8) (2024-02-23)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.19.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.19.6...@cardano-sdk/key-management@0.19.7) (2024-02-12)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.19.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.19.5...@cardano-sdk/key-management@0.19.6) (2024-02-08)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.19.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.19.4...@cardano-sdk/key-management@0.19.5) (2024-02-07)

### Features

* **key-management:** add payload to SignDataContext when signing cip8 structure ([17a82b5](https://github.com/input-output-hk/cardano-js-sdk/commit/17a82b57ec96939dd5501e28f32cda7898533065))

## [0.19.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.19.3...@cardano-sdk/key-management@0.19.4) (2024-02-02)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.19.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.19.2...@cardano-sdk/key-management@0.19.3) (2024-02-02)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.19.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.19.1...@cardano-sdk/key-management@0.19.2) (2024-01-31)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.19.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.19.0...@cardano-sdk/key-management@0.19.1) (2024-01-25)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.19.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.18.1...@cardano-sdk/key-management@0.19.0) (2024-01-17)

### ⚠ BREAKING CHANGES

* added a new type SignDataContext which has two optional fields, sender and address
- sender field of Witnesser signBlob was replaced by a SignDataContext
- sender field of SignerManager signData was replaced by a SignDataContext

### Features

* signerManager and Witnesser now propagate signData confirmation address ([544cc17](https://github.com/input-output-hk/cardano-js-sdk/commit/544cc17ce36da4f4bc186d3c19a4bc34ab67361e))

## [0.18.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.18.0...@cardano-sdk/key-management@0.18.1) (2024-01-05)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.18.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.17.1...@cardano-sdk/key-management@0.18.0) (2023-12-20)

### ⚠ BREAKING CHANGES

* Witnesser witness method now takes a complete serializable Transaction

### Features

* witnesser witness method now takes a complete serializable Transaction ([07a7305](https://github.com/input-output-hk/cardano-js-sdk/commit/07a730536ef9b0cd5a4760e143e35bdca4ce8d8d))

## [0.17.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.17.0...@cardano-sdk/key-management@0.17.1) (2023-12-14)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.17.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.16.0...@cardano-sdk/key-management@0.17.0) (2023-12-12)

### ⚠ BREAKING CHANGES

* replace authenticator 'origin' argument to 'sender'
- hoist 'senderOrigin' util to dapp-connector package

### Features

* track cip30 method call origin & update Authenticator api ([75c8af6](https://github.com/input-output-hk/cardano-js-sdk/commit/75c8af6aecc0ddcaeca153e8a3693d6e18edf60e))

## [0.16.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.15.1...@cardano-sdk/key-management@0.16.0) (2023-12-07)

### ⚠ BREAKING CHANGES

* remove KeyAgent.knownAddresses
- remove AsyncKeyAgent.knownAddresses$
- remove LazyWalletUtil and setupWallet utils
- replace KeyAgent dependency on InputResolver with props passed to sign method
- re-purpose AddressManager to Bip32Account: addresses are now stored only by the wallet

### Code Refactoring

* remove indirect KeyAgent dependency on ObservableWallet ([8dcfbc4](https://github.com/input-output-hk/cardano-js-sdk/commit/8dcfbc4ab339fcd8efc7d5f241a501eb210b58d4))

## [0.15.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.15.0...@cardano-sdk/key-management@0.15.1) (2023-12-04)

### Features

* **key-management:** sign conway stake key registration certificates ([63b8a1d](https://github.com/input-output-hk/cardano-js-sdk/commit/63b8a1df2888f27a2f9078f8554b38af5f91d8c9))

## [0.15.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.14.0...@cardano-sdk/key-management@0.15.0) (2023-11-29)

### ⚠ BREAKING CHANGES

* personal wallet now takes a Bip32 address manager and a witnesser instead of key agent
* stake registration and deregistration certificates now take a Credential instead of key hash

### Features

* personal wallet now takes a Bip32 address manager and a witnesser instead of key agent ([8308bf1](https://github.com/input-output-hk/cardano-js-sdk/commit/8308bf1876fd5a0bee215ea598a87ef08bd2f15f))
* stake registration and deregistration certificates now take a Credential instead of key hash ([49612f0](https://github.com/input-output-hk/cardano-js-sdk/commit/49612f0f313f357e7e2a7eed406852cbd2bb3dec))

## [0.14.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.13.0...@cardano-sdk/key-management@0.14.0) (2023-10-12)

### ⚠ BREAKING CHANGES

* the TrezorKeyAgent class was moved from `key-management` to `hardware-trezor` package

### Features

* add dedicated Trezor package ([2a1b075](https://github.com/input-output-hk/cardano-js-sdk/commit/2a1b0754adfd29f1ef2f820b59f91f950cddb4d9))

## [0.13.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.12.0...@cardano-sdk/key-management@0.13.0) (2023-10-09)

### ⚠ BREAKING CHANGES

* core package no longer exports the CML types

### Features

* core package no longer exports the CML types ([51545ed](https://github.com/input-output-hk/cardano-js-sdk/commit/51545ed82b4abeb795b0a50ad7d299ddb5da4a0d))

## [0.12.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.11.0...@cardano-sdk/key-management@0.12.0) (2023-09-29)

### ⚠ BREAKING CHANGES

* - key-management `stubSignTransaction` positional args were replaced by named args,
as defined in `StubSignTransactionProps`.
A new `dRepPublicKey` named arg is part of `StubSignTransactionProps`

### Features

* update for Conway transaction fields ([c32513b](https://github.com/input-output-hk/cardano-js-sdk/commit/c32513bb89d0318dba35227c3509204166a209b2))

## [0.11.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.10.3...@cardano-sdk/key-management@0.11.0) (2023-09-20)

### ⚠ BREAKING CHANGES

* remove the CML serialization code from core package
* **key-management:** remove deprecated trezor hardware wallet implementation

### Features

* add support for signing data with a DRepID in CIP-95 API ([3057cce](https://github.com/input-output-hk/cardano-js-sdk/commit/3057cce6ac1585d6ae2a62a89d0417e5fb2416f4))
* **key-management:** remove deprecated trezor hardware wallet implementation ([76bed53](https://github.com/input-output-hk/cardano-js-sdk/commit/76bed5378c1c1930f6774927ee4fe3d5ab8d1964))
* remove the CML serialization code from core package ([62f4252](https://github.com/input-output-hk/cardano-js-sdk/commit/62f4252b094938db05b81c928c03c1eecec2be55))

## [0.10.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.10.2...@cardano-sdk/key-management@0.10.3) (2023-09-12)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.10.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.10.1...@cardano-sdk/key-management@0.10.2) (2023-08-29)

### Features

* add getPubDRepKey to PersonalWallet ([a482e92](https://github.com/input-output-hk/cardano-js-sdk/commit/a482e92d7500c6b5bd0ef32438d0337649c2bb27))

## [0.10.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.10.0...@cardano-sdk/key-management@0.10.1) (2023-08-21)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.10.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.9.0...@cardano-sdk/key-management@0.10.0) (2023-08-15)

### ⚠ BREAKING CHANGES

* updated MIR certificate interface to match the CDDL specification

### Features

* updated MIR certificate interface to match the CDDL specification ([03d5079](https://github.com/input-output-hk/cardano-js-sdk/commit/03d507951ff310a4019f5ec2f1871fdad77939ee))

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.8.2...@cardano-sdk/key-management@0.9.0) (2023-08-11)

### ⚠ BREAKING CHANGES

* rename AddressEntity.stakingCredentialHash -> stakeCredentialHash
- rename BaseAddress.getStakingCredential -> getStakeCredential
* **key-management:** communicationType param is the required param for all TrezorKeyAgent methods.
By defining communicationType you are able to communicate with proper trezor web or node package

### Miscellaneous Chores

* **key-management:** replace legacy trezor-connect package with dedicated node and web packages ([906c41e](https://github.com/input-output-hk/cardano-js-sdk/commit/906c41e0ebae6608290734d674d5aa08242adcd9))

### Code Refactoring

* rename/replace occurences of 'staking' with 'stake' where appropriate ([05fc4c4](https://github.com/input-output-hk/cardano-js-sdk/commit/05fc4c4d83137eb3137583ca0bb443825eac1445))

## [0.8.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.8.1...@cardano-sdk/key-management@0.8.2) (2023-07-31)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.8.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.8.0...@cardano-sdk/key-management@0.8.1) (2023-07-13)

### Bug Fixes

* wallet finalizeTx and CIP30 requiresForeignSignatures now wait for at least one known address ([b5fde00](https://github.com/input-output-hk/cardano-js-sdk/commit/b5fde0038dde4082d3cd5eac3bbb8141733ec5b6))

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.7.11...@cardano-sdk/key-management@0.8.0) (2023-07-05)

### ⚠ BREAKING CHANGES

* **key-management:** change behavior of ensureStakeKeys to return all reward accounts

### Features

* **key-management:** change behavior of ensureStakeKeys to return all reward accounts ([faaf9b0](https://github.com/input-output-hk/cardano-js-sdk/commit/faaf9b02eff1dd786c93d1b95b22c0aad193def3))

## [0.7.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.7.10...@cardano-sdk/key-management@0.7.11) (2023-07-04)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.7.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.7.9...@cardano-sdk/key-management@0.7.10) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.7.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.7.8...@cardano-sdk/key-management@0.7.9) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.7.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.7.7...@cardano-sdk/key-management@0.7.8) (2023-06-28)

### Bug Fixes

* **tx-construction:** wait for new stakeKeys in rewardAccounts ([a74b665](https://github.com/input-output-hk/cardano-js-sdk/commit/a74b66505e19681d21d547e6418f0980b112b070))

## [0.7.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.7.6...@cardano-sdk/key-management@0.7.7) (2023-06-23)

### Features

* **key-agent:** util to derive stake keys ([f2691dc](https://github.com/input-output-hk/cardano-js-sdk/commit/f2691dce76b5bfe5b89369ff81af2cb9d591b4f6))

## [0.7.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.7.5...@cardano-sdk/key-management@0.7.6) (2023-06-20)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.7.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.7.4...@cardano-sdk/key-management@0.7.5) (2023-06-13)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.7.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.7.3...@cardano-sdk/key-management@0.7.4) (2023-06-12)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.7.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.7.2...@cardano-sdk/key-management@0.7.3) (2023-06-06)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.7.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.7.1...@cardano-sdk/key-management@0.7.2) (2023-06-05)

### Bug Fixes

* **key-management:** the InMemoryKeyAgent now correctly takes into account the requiredSigners field ([2071885](https://github.com/input-output-hk/cardano-js-sdk/commit/20718855f9c00071947f927b4f5280cea9b41a43))

## [0.7.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.7.0...@cardano-sdk/key-management@0.7.1) (2023-06-01)

**Note:** Version bump only for package @cardano-sdk/key-management

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.6.0...@cardano-sdk/key-management@0.7.0) (2023-05-24)

### ⚠ BREAKING CHANGES

* the single address wallet now takes an additional dependency 'AddressDiscovery'

### Features

* the single address wallet now takes an additional dependency 'AddressDiscovery' ([d6d7cff](https://github.com/input-output-hk/cardano-js-sdk/commit/d6d7cffe3a7089af2aff39e78c491f4e0a06c989))

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.5.1...@cardano-sdk/key-management@0.6.0) (2023-05-22)

### ⚠ BREAKING CHANGES

* add ledger package with transformations
* - KeyAgentBase deriveAddress method now requires the caller to specify the skate key index

### Features

* add ledger package with transformations ([58f3a22](https://github.com/input-output-hk/cardano-js-sdk/commit/58f3a227d466c0083bcfe9243311ac2bca4e48df))
* key agent now takes an additional parameter stakeKeyDerivationIndex ([cbfd3c1](https://github.com/input-output-hk/cardano-js-sdk/commit/cbfd3c1ea55de4355e38f822868b0a7b6bd3953a))

### Bug Fixes

* **key-management:** fixed ttl ([38ca6dd](https://github.com/input-output-hk/cardano-js-sdk/commit/38ca6ddd0524ffef9de92693e04bda19b7c53e44))

## [0.5.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.5.0...@cardano-sdk/key-management@0.5.1) (2023-05-02)

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/key-management@0.4.1...@cardano-sdk/key-management@0.5.0) (2023-03-13)

### ⚠ BREAKING CHANGES

- upgrade resolveInputAddress to resolveInput
- add new Address types that implement CIP-19 natively
- core type for address string reprensetation 'Address' renamed to PaymentAddress

### Features

- add new Address types that implement CIP-19 natively ([a892176](https://github.com/input-output-hk/cardano-js-sdk/commit/a8921760b714b090bb6c15d6b4696e2dd0b2fdc5))
- **key-management:** ownSignatureKeyPaths will now also take into account collateral inputs ([991c117](https://github.com/input-output-hk/cardano-js-sdk/commit/991c1170060c751996a6fe4a1ba4f9b987f42e7d))
- upgrade resolveInputAddress to resolveInput ([fcfa035](https://github.com/input-output-hk/cardano-js-sdk/commit/fcfa035a3498f675945dafcc82b8f05c08318dd8))

### Bug Fixes

- **key-management:** removed redundant signing for stake key registration certificates ([8f2edd0](https://github.com/input-output-hk/cardano-js-sdk/commit/8f2edd061410fab28e4a33a5a4f753e724732dbf))
- **wallet:** cip30 interface now throws ProofGeneration error if it cant sign the tx as specified ([81d9c9c](https://github.com/input-output-hk/cardano-js-sdk/commit/81d9c9cb32dc05d2f579d285fa58a638041dd3d1))

### Code Refactoring

- core type for address string reprensetation 'Address' renamed to PaymentAddress ([4287463](https://github.com/input-output-hk/cardano-js-sdk/commit/42874633de6069510efdc57323f61140d22ed203))

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
