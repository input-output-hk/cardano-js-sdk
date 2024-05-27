# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.28.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.27.4...@cardano-sdk/web-extension@0.28.0) (2024-05-20)

### ⚠ BREAKING CHANGES

* **web-extension:** add logger dependency to SigningCoordinator

### Features

* **web-extension:** add log of transaction id when signing ([ba5871b](https://github.com/input-output-hk/cardano-js-sdk/commit/ba5871b71340ac13461a348fbbb2ec24f2a7c077))

## [0.27.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.27.3...@cardano-sdk/web-extension@0.27.4) (2024-05-02)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.27.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.27.2...@cardano-sdk/web-extension@0.27.3) (2024-04-26)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.27.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.27.1...@cardano-sdk/web-extension@0.27.2) (2024-04-23)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.27.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.27.0...@cardano-sdk/web-extension@0.27.1) (2024-04-23)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.27.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.26.2...@cardano-sdk/web-extension@0.27.0) (2024-04-15)

### ⚠ BREAKING CHANGES

* **wallet:** hoist ObservableWallet getPubDRepKey under ObservableWallet.governance

### Features

* **wallet:** implement drep registration tracker ([06a1de5](https://github.com/input-output-hk/cardano-js-sdk/commit/06a1de5ec67e13ecc33111532735242e17256df7))

### Code Refactoring

* **wallet:** hoist ObservableWallet getPubDRepKey under ObservableWallet.governance ([9cf346f](https://github.com/input-output-hk/cardano-js-sdk/commit/9cf346f7945384949a9b3a615680b448d5ffde94))

## [0.26.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.26.1...@cardano-sdk/web-extension@0.26.2) (2024-04-04)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.26.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.26.0...@cardano-sdk/web-extension@0.26.1) (2024-04-03)

### Features

* **tx-construction:** add setValidityInterval to txBuilder ([52102b0](https://github.com/input-output-hk/cardano-js-sdk/commit/52102b0dc3053832b99846dbbd5d87bdd19dd57f))

## [0.26.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.25.0...@cardano-sdk/web-extension@0.26.0) (2024-03-26)

### ⚠ BREAKING CHANGES

* encapsulate `set` fields in CborSet

### Features

* encapsulate `set` fields in CborSet ([06269ab](https://github.com/input-output-hk/cardano-js-sdk/commit/06269abaa323b20931ba6505a0c5aa244d21e783)), closes [/github.com/IntersectMBO/cardano-ledger/blob/master/eras/conway/impl/cddl-files/extra.cddl#L5](https://github.com/input-output-hk//github.com/IntersectMBO/cardano-ledger/blob/master/eras/conway/impl/cddl-files/extra.cddl/issues/L5)
* **web-extension:** added an optional parameter to WalletManager activate to allow force reload ([9149a96](https://github.com/input-output-hk/cardano-js-sdk/commit/9149a96a43e469e46cd626bd7ee385c1356edbba))

## [0.25.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.24.8...@cardano-sdk/web-extension@0.25.0) (2024-03-12)

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
* **wallet:** add signed transactions observable ([aca3660](https://github.com/input-output-hk/cardano-js-sdk/commit/aca3660534cc7660d6ebd9aa6eb1efe9b7862b92))

## [0.24.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.24.7...@cardano-sdk/web-extension@0.24.8) (2024-02-29)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.24.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.24.6...@cardano-sdk/web-extension@0.24.7) (2024-02-28)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.24.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.24.5...@cardano-sdk/web-extension@0.24.6) (2024-02-23)

### Features

* **tx-construction:** add customizeCb to GenericTxBuilder ([87732b6](https://github.com/input-output-hk/cardano-js-sdk/commit/87732b60ec38c9528dde6310bbb608589896870f))

## [0.24.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.24.4...@cardano-sdk/web-extension@0.24.5) (2024-02-12)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.24.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.24.3...@cardano-sdk/web-extension@0.24.4) (2024-02-08)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.24.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.24.2...@cardano-sdk/web-extension@0.24.3) (2024-02-07)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.24.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.24.1...@cardano-sdk/web-extension@0.24.2) (2024-02-05)

### Bug Fixes

* **web-extension:** delete active wallet from storage and emit null on deactivate ([64bf9c0](https://github.com/input-output-hk/cardano-js-sdk/commit/64bf9c0b0f9e41c8695c072df7dbee2eb360c78e))

## [0.24.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.24.0...@cardano-sdk/web-extension@0.24.1) (2024-02-02)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.24.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.23.1...@cardano-sdk/web-extension@0.24.0) (2024-02-02)

### ⚠ BREAKING CHANGES

* TrackerSubject.value$ type changed to T | typeof TrackerSubject.NO_VALUE
* **web-extension:** WalletRepository.addWallet now requires at least 1 account for bip32 wallets

### Bug Fixes

* emit null through remote api when no wallet is active ([bd9b6cd](https://github.com/input-output-hk/cardano-js-sdk/commit/bd9b6cd02854f9e1cdd6935089f945ad8d030e24))
* **web-extension:** correct updateMetadata props type ([521eee5](https://github.com/input-output-hk/cardano-js-sdk/commit/521eee580e81e031e6b0cb0b3308cc3e50b9e856))
* **web-extension:** hoist extendedAccountPublicKey from Bip32Wallet into Bip32WalletAccount ([2184be1](https://github.com/input-output-hk/cardano-js-sdk/commit/2184be13371e3ccde46b20f701236c752eef94cb))

## [0.23.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.23.0...@cardano-sdk/web-extension@0.23.1) (2024-01-31)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.23.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.22.0...@cardano-sdk/web-extension@0.23.0) (2024-01-25)

### ⚠ BREAKING CHANGES

* replace fromSerializableObj getErrorPrototype with errorTypes

### Bug Fixes

* **web-extension:** ignore SigningCoordinator responses from unintended targets ([868600e](https://github.com/input-output-hk/cardano-js-sdk/commit/868600ec0b3ec2cb3739d6bf427cc312e6b57df8))

### Code Refactoring

* replace fromSerializableObj getErrorPrototype with errorTypes ([7a9770c](https://github.com/input-output-hk/cardano-js-sdk/commit/7a9770cc318a0149d2d623eca5c42e8c0699983e))

## [0.22.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.21.0...@cardano-sdk/web-extension@0.22.0) (2024-01-17)

### ⚠ BREAKING CHANGES

* **web-extension:** add metadata to bip32 wallets
- split WalletRepository.updateMetadata into 2 methods
* SignerManager renamed as SignerCoordinator
* added a new type SignDataContext which has two optional fields, sender and address
- sender field of Witnesser signBlob was replaced by a SignDataContext
- sender field of SignerManager signData was replaced by a SignDataContext

### Features

* signerManager and Witnesser now propagate signData confirmation address ([544cc17](https://github.com/input-output-hk/cardano-js-sdk/commit/544cc17ce36da4f4bc186d3c19a4bc34ab67361e))
* **web-extension:** handle wallet metadata in repository LW-9503 ([34d976b](https://github.com/input-output-hk/cardano-js-sdk/commit/34d976be41583b59c30c35ff620219eccc9128e4))

### Code Refactoring

* signerManager renamed as SignerCoordinator ([c7067db](https://github.com/input-output-hk/cardano-js-sdk/commit/c7067db06448570871fbc84af846ebd69c00533c))

## [0.21.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.20.1...@cardano-sdk/web-extension@0.21.0) (2024-01-05)

### ⚠ BREAKING CHANGES

* wallet repository InMemoryWallet entropy field renamed to keyMaterial

### Features

* **web-extension:** add willRetryOnFailure sign option to SignerManager ([7a1bac8](https://github.com/input-output-hk/cardano-js-sdk/commit/7a1bac81b1aeffdeaa8efac8de1059cd03393065))

### Bug Fixes

* **web-extension:** wallet manager now deepEquals the chainId when comparing the active wallet props ([74e9ac1](https://github.com/input-output-hk/cardano-js-sdk/commit/74e9ac1101e5337b60d9be2656b0d6b31a2d63b7))
* **web-extension:** wallet manager will not emit null from activeWalletId$ ([d94b49a](https://github.com/input-output-hk/cardano-js-sdk/commit/d94b49a987ec0e7d50060365cd03f40d63debc8e))

### Code Refactoring

* entropy field in InMemoryWallet renamed to keyMaterial. ([d8b5c72](https://github.com/input-output-hk/cardano-js-sdk/commit/d8b5c72de96a24b84b62f558af952090b53209f3))

## [0.20.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.20.0...@cardano-sdk/web-extension@0.20.1) (2023-12-21)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.20.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.19.0...@cardano-sdk/web-extension@0.20.0) (2023-12-20)

### ⚠ BREAKING CHANGES

* Wallet manager activate method now takes an WalletManagerActivateProps object rather than just a wallet id
- Wallet manager now takes signer manager api as a dependency
- Wallet manager no longer exposes the observable wallet API, this now has to be done by application
- Wallet manager destroy method was renamed destroyData and now will destroy any storage with the same wallet id

### Features

* rework WalletManager ([3e2fc6c](https://github.com/input-output-hk/cardano-js-sdk/commit/3e2fc6c79f0267672fe91732895c686a1a3eeb1f))
* **web-extension:** wallet id type changed to just string ([89f8a31](https://github.com/input-output-hk/cardano-js-sdk/commit/89f8a3189dd35136a95d6c697d1c6bf19291be0b))

## [0.19.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.18.0...@cardano-sdk/web-extension@0.19.0) (2023-12-14)

### ⚠ BREAKING CHANGES

* **web-extension:** remove AccountId used in WalletRepository
* **web-extension:** WalletRepository storage format change (add ownSigners)
* **web-extension:** WalletRepository storage format change (add secrets)

### Features

* **web-extension:** add SignerManager ([6c7cc2d](https://github.com/input-output-hk/cardano-js-sdk/commit/6c7cc2deb53b83eadd965ab73abe9ffcdd512a4f))
* **web-extension:** store dependency wallets for script wallets ([57cf407](https://github.com/input-output-hk/cardano-js-sdk/commit/57cf407fd92da85831c21bd9d63fb2bd45b17ec3))
* **web-extension:** store encypted secrets for in-memory wallets ([b288e70](https://github.com/input-output-hk/cardano-js-sdk/commit/b288e7017b6bf97bf6548d6c5cd242e60868440d))

### Bug Fixes

* delay InMemoryCollectionStore observeAll emission after setAll ([51647eb](https://github.com/input-output-hk/cardano-js-sdk/commit/51647eb1ee64068422c46b1ec064c17404af1e8f))

### Code Refactoring

* **web-extension:** remove AccountId used in WalletRepository ([a3d3c17](https://github.com/input-output-hk/cardano-js-sdk/commit/a3d3c17ff5efb81fa5d259934f75138f99a61920))

## [0.18.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.17.1...@cardano-sdk/web-extension@0.18.0) (2023-12-12)

### ⚠ BREAKING CHANGES

* replace authenticator 'origin' argument to 'sender'
- hoist 'senderOrigin' util to dapp-connector package

### Features

* track cip30 method call origin & update Authenticator api ([75c8af6](https://github.com/input-output-hk/cardano-js-sdk/commit/75c8af6aecc0ddcaeca153e8a3693d6e18edf60e))

## [0.17.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.17.0...@cardano-sdk/web-extension@0.17.1) (2023-12-08)

### Features

* add ObservableWallet.discoverAddreses ([efc4e50](https://github.com/input-output-hk/cardano-js-sdk/commit/efc4e5070ca261b3eec6c93d4ede26c0533d09ee)), closes [#1009](https://github.com/input-output-hk/cardano-js-sdk/issues/1009)

## [0.17.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.16.5...@cardano-sdk/web-extension@0.17.0) (2023-12-07)

### ⚠ BREAKING CHANGES

* remove KeyAgent.knownAddresses
- remove AsyncKeyAgent.knownAddresses$
- remove LazyWalletUtil and setupWallet utils
- replace KeyAgent dependency on InputResolver with props passed to sign method
- re-purpose AddressManager to Bip32Account: addresses are now stored only by the wallet

### Code Refactoring

* remove indirect KeyAgent dependency on ObservableWallet ([8dcfbc4](https://github.com/input-output-hk/cardano-js-sdk/commit/8dcfbc4ab339fcd8efc7d5f241a501eb210b58d4))

## [0.16.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.16.4...@cardano-sdk/web-extension@0.16.5) (2023-12-04)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.16.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.16.3...@cardano-sdk/web-extension@0.16.4) (2023-11-29)

### Features

* **web-extension:** add WalletRepository ([945c4f6](https://github.com/input-output-hk/cardano-js-sdk/commit/945c4f62cc538354d3ba70cb28e7cf8c3a884cb0))

## [0.16.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.16.2...@cardano-sdk/web-extension@0.16.3) (2023-10-19)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.16.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.16.1...@cardano-sdk/web-extension@0.16.2) (2023-10-12)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.16.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.16.0...@cardano-sdk/web-extension@0.16.1) (2023-10-09)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.16.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.15.0...@cardano-sdk/web-extension@0.16.0) (2023-09-29)

### ⚠ BREAKING CHANGES

* - replace `ObservableWallet.activePublicStakeKeys$` with
`publicStakeKeys$` that emits `PubStakeKeyAndStatus[]`

### Features

* cip-95 update calls to get public stake keys ([b1039b4](https://github.com/input-output-hk/cardano-js-sdk/commit/b1039b4b32e74075c1833eb1d0bdaac06368e9b8))

## [0.15.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.14.7...@cardano-sdk/web-extension@0.15.0) (2023-09-20)

### ⚠ BREAKING CHANGES

* delegation distribution portfolio is now persisted on chain and taken into account during change distribution

### Features

* delegation distribution portfolio is now persisted on chain and taken into account during change distribution ([7573938](https://github.com/input-output-hk/cardano-js-sdk/commit/75739385ea422a0621ded87f2b72c5878e3fcf81))

## [0.14.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.14.6...@cardano-sdk/web-extension@0.14.7) (2023-09-12)

### Features

* **wallet:** active public stake keys tracker support for cip95 ([3b8c73d](https://github.com/input-output-hk/cardano-js-sdk/commit/3b8c73d8ab771716da476f7869502a3ec6905c25))

## [0.14.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.14.5...@cardano-sdk/web-extension@0.14.6) (2023-08-29)

### Features

* add getPubDRepKey to PersonalWallet ([a482e92](https://github.com/input-output-hk/cardano-js-sdk/commit/a482e92d7500c6b5bd0ef32438d0337649c2bb27))

## [0.14.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.14.4...@cardano-sdk/web-extension@0.14.5) (2023-08-21)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.14.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.14.3...@cardano-sdk/web-extension@0.14.4) (2023-08-16)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.14.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.14.2...@cardano-sdk/web-extension@0.14.3) (2023-08-15)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.14.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.14.1...@cardano-sdk/web-extension@0.14.2) (2023-08-11)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.14.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.14.0...@cardano-sdk/web-extension@0.14.1) (2023-07-31)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.14.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.13.8...@cardano-sdk/web-extension@0.14.0) (2023-07-26)

### ⚠ BREAKING CHANGES

* **web-extension:** lw-7563 throw RemoteApiShutdownError on disconnect during method call

### Bug Fixes

* **web-extension:** lw-7563 throw RemoteApiShutdownError on disconnect during method call ([dd803c6](https://github.com/input-output-hk/cardano-js-sdk/commit/dd803c6f15a5c4e42eb05413388fef71bb7ad628))

## [0.13.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.13.7...@cardano-sdk/web-extension@0.13.8) (2023-07-17)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.13.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.13.6...@cardano-sdk/web-extension@0.13.7) (2023-07-13)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.13.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.13.5...@cardano-sdk/web-extension@0.13.6) (2023-07-05)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.13.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.13.4...@cardano-sdk/web-extension@0.13.5) (2023-07-04)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.13.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.13.3...@cardano-sdk/web-extension@0.13.4) (2023-07-03)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.13.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.13.2...@cardano-sdk/web-extension@0.13.3) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.13.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.13.1...@cardano-sdk/web-extension@0.13.2) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.13.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.13.0...@cardano-sdk/web-extension@0.13.1) (2023-06-28)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.13.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.12.4...@cardano-sdk/web-extension@0.13.0) (2023-06-23)

### ⚠ BREAKING CHANGES

* txBuilder delegate is replaced by delegatePortfolio.
* TxBuilderProviders.rewardAccounts expects RewardAccountWithPoolId type,
  instead of Omit<RewardAccount, 'delegatee'>

### Features

* remove txBuilder.delegate method ([f21c93b](https://github.com/input-output-hk/cardano-js-sdk/commit/f21c93b251f1bd67f47edd488d9df47c2abf3e0c))
* txBuilder delegatePortfolio ([ec0860e](https://github.com/input-output-hk/cardano-js-sdk/commit/ec0860e37835edbce3c911d6fe65c21b73683de7))

## [0.12.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.12.3...@cardano-sdk/web-extension@0.12.4) (2023-06-20)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.12.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.12.2...@cardano-sdk/web-extension@0.12.3) (2023-06-13)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.12.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.12.1...@cardano-sdk/web-extension@0.12.2) (2023-06-12)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.12.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.12.0...@cardano-sdk/web-extension@0.12.1) (2023-06-06)

### Features

* add ObservableWallet.handles$ that emits own handles ([1c3b532](https://github.com/input-output-hk/cardano-js-sdk/commit/1c3b532c9b9f4fe48ba1555749b21faa27648c1a))

## [0.12.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.11.1...@cardano-sdk/web-extension@0.12.0) (2023-06-05)

### ⚠ BREAKING CHANGES

* **wallet:** Added new properties to DelegationTrackerProps

### Features

* **wallet:** delegation.portfolio$ tracker ([7488d14](https://github.com/input-output-hk/cardano-js-sdk/commit/7488d14008f7aa3d91d7513cfffaeb81e160eb18))

### Bug Fixes

* **web-extension:** decouple/detach objects returned by remote api factory ([a418169](https://github.com/input-output-hk/cardano-js-sdk/commit/a4181695885d4ced3519b4a73df6891c999215ef))

## [0.11.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.11.0...@cardano-sdk/web-extension@0.11.1) (2023-06-01)

### Features

* add HandleProvider interface and handle support implementation to TxBuilder ([f209095](https://github.com/input-output-hk/cardano-js-sdk/commit/f2090952c8a0512fc589674b876f3a27be403140))

## [0.11.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.10.0...@cardano-sdk/web-extension@0.11.0) (2023-05-24)

### ⚠ BREAKING CHANGES

* the single address wallet now takes an additional dependency 'AddressDiscovery'

### Features

* the single address wallet now takes an additional dependency 'AddressDiscovery' ([d6d7cff](https://github.com/input-output-hk/cardano-js-sdk/commit/d6d7cffe3a7089af2aff39e78c491f4e0a06c989))

## [0.10.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.9.0...@cardano-sdk/web-extension@0.10.0) (2023-05-22)

### ⚠ BREAKING CHANGES

* Replace ObservableWalletTxBuilder and buildTx with wallet.createTxBuilder()
- SignedTx type no longer has submit() method.
- TxBuilder no longer has `isSubmitted()`
- Renamed ValidTxBody to UnsignedTx
- Removed ValidTx, InvalidTx, MaybeValidTx
- TxBuilder.build now returns an UnsignedTxPromise.
- TxBuilder.build throws in case of errors instead of returning InvalidTx
- Removed ValidTxOutData, ValidTxOut, InvalidTxOut, MaybeValidTxOut types.
- OutputBuilder.build now returns Cardano.TxOut.
- OutputBuilder.build throws TxOutValidationError in case of errors instead of returning InvalidTxOut
- Replace synchronous builder properties with async inspect()
- Rename some TxBuilder methods for consistency: align with OutputBuilder API,
where 'setters' are not prefixed with 'set'
- Hoist FinalizeTxProps back to 'wallet' package
- Hoist InitializeTxProps.scripts to InitializeTxProps.witness.scripts
- Hoist tx builder output validator arg under 'dependencies' object
- Reject TxBuilder.build.inspect() and sign() with a single error
* **web-extension:** convert factory apiProperties to getApiProperties

### Features

* generic tx-builder ([aa4a539](https://github.com/input-output-hk/cardano-js-sdk/commit/aa4a539d6a5ddd75120450e02afeeba9bed6a527))
* **web-extension:** add RemoteApiPropertyType.ApiFactory ([eacad41](https://github.com/input-output-hk/cardano-js-sdk/commit/eacad41b5b8570ca4e5d0cc4178c4b5740569a4c))

### Bug Fixes

* **web-extension:** make remote api method responses more reliable ([cdd37c9](https://github.com/input-output-hk/cardano-js-sdk/commit/cdd37c9509e67a3ec95e4a20e52e71c9a2889f2c))

### Code Refactoring

* **web-extension:** convert factory apiProperties to getApiProperties ([8de0fad](https://github.com/input-output-hk/cardano-js-sdk/commit/8de0fad4e9a0d6a971372ff7d4a9e89974e12bcd))

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.8.2...@cardano-sdk/web-extension@0.9.0) (2023-05-02)

### ⚠ BREAKING CHANGES

- **web-extension:** WalletManagerWorker now requires an extra dependency: managerStorage
- - renamed `TransactionsTracker.outgoing.confirmed$` to `onChain$`

* renamed `TransactionReemitterProps.transactions.outgoing.confirmed$` to `onChain$`
* renamed web-extension `observableWalletProperties.transactions.outgoing.confirmed$`
  to `onChain$`
* rename ConfirmedTx to OutgoingOnChainTx
* renamed OutgoingOnChainTx.confirmedAt to `slot`

- rename ObservableWallet assets$ to assetInfo$

### Features

- **web-extension:** store and restore last activated wallet props ([1f78d87](https://github.com/input-output-hk/cardano-js-sdk/commit/1f78d87c438c630bf4ee835a387449c667cde319))

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))
- **web-extension:** proxy error responses ([3c20399](https://github.com/input-output-hk/cardano-js-sdk/commit/3c203993faca3916f34626267885aaaec357d0e8))

### Code Refactoring

- rename confirmed$ to onChain$ ([0de59dd](https://github.com/input-output-hk/cardano-js-sdk/commit/0de59dd335d065a85a4467bb501b041d889311b5))
- rename ObservableWallet assets$ to assetInfo$ ([d6b759c](https://github.com/input-output-hk/cardano-js-sdk/commit/d6b759cd2d8db12313a166259277a2c79149e5f9))

## [0.8.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.8.1...@cardano-sdk/web-extension@0.8.2) (2023-03-13)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.8.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.8.0...@cardano-sdk/web-extension@0.8.1) (2023-03-01)

**Note:** Version bump only for package @cardano-sdk/web-extension

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.7.0...@cardano-sdk/web-extension@0.8.0) (2023-02-17)

### ⚠ BREAKING CHANGES

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

### Features

- expose setUnspendable on ObservableWallet interface ([729e5d7](https://github.com/input-output-hk/cardano-js-sdk/commit/729e5d7c63447837a4196f2e19fb306939873a69))

### Bug Fixes

- **wallet-manager:** initialize walletManagerWorker runtime property ([db4ce63](https://github.com/input-output-hk/cardano-js-sdk/commit/db4ce63c85e5b80e2f36e4a92f2c71916c477657))

### Code Refactoring

- refactor the SDK to use the new crypto package ([3b41320](https://github.com/input-output-hk/cardano-js-sdk/commit/3b41320e7971a231d50785733ff4cd0793418d3d))

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.6.0...@cardano-sdk/web-extension@0.7.0) (2022-12-22)

### ⚠ BREAKING CHANGES

- **walletManager:** use a unique walletId with walletManager
- - replace KeyAgent.networkId with KeyAgent.chainId

* remove CardanoNetworkId type
* rename CardanoNetworkMagic->NetworkMagics
* add 'logger' to KeyAgentDependencies
* setupWallet now requires a Logger

- remote api wallet manager

### Features

- adds a retry strategy to single address wallet ([7d01ee9](https://github.com/input-output-hk/cardano-js-sdk/commit/7d01ee931dba467ddd6ec8882d8777c6d289d890))
- **key-management:** expose extendedAccountPublicKey in AsyncKeyAgent ([122b281](https://github.com/input-output-hk/cardano-js-sdk/commit/122b281bc460924e5f69c59c896dec4d056d5de8))
- remote api wallet manager ([043f1df](https://github.com/input-output-hk/cardano-js-sdk/commit/043f1dff7ed85b43e489d972dc5158712c43ee68))
- replace KeyAgent.networkId with KeyAgent.chainId ([e44dee0](https://github.com/input-output-hk/cardano-js-sdk/commit/e44dee054611636f34b0a66e27d7971af01e0296))
- **walletManager:** use a unique walletId with walletManager ([55df794](https://github.com/input-output-hk/cardano-js-sdk/commit/55df794239f7b11fe3e6ea23ca36130e6db6c5eb))

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
- **web-extension:** close key agent channel on walletManagerUi deactivate ([f5d9183](https://github.com/input-output-hk/cardano-js-sdk/commit/f5d918325ba66a6e1433fb0e91cd42bf3d42f72c))
- **web-extension:** do not replay values from disabled remote api objects ([e341675](https://github.com/input-output-hk/cardano-js-sdk/commit/e3416750546412c65830849a3895463fc00bc707))

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.5.0...@cardano-sdk/web-extension@0.6.0) (2022-11-04)

### ⚠ BREAKING CHANGES

- **web-extension:** `ExposeApiProps` `api` has changed to observable `api$`.
  Users can use rxjs `of` function to create an observable: `api$: of(api)` to
  adapt existing code to this change.
- **dapp-connector:** renamed cip30 package to dapp-connector
- lift key management and governance concepts to new packages
- **web-extension:** rename messaging destroy->shutdown for consistent naming

### Features

- **web-extension:** enhance remoteApi to allow changing observed api object ([6245b90](https://github.com/input-output-hk/cardano-js-sdk/commit/6245b908d33aa14a2736f110add4605d3ce3ab4e))

### Bug Fixes

- **web-extension:** destroy messenger ports upon unsubscribing exposed object ([905087b](https://github.com/input-output-hk/cardano-js-sdk/commit/905087b54218e061ae1e19a6377f1a262f8b47d2))
- **web-extension:** encapsulate potential EmptyError with a new RemoteApiShutdownError ([7819453](https://github.com/input-output-hk/cardano-js-sdk/commit/7819453a60c863c5f21168e2084bad7d928f59e9))
- **web-extension:** un-exposing an object in background process doesn't destroy the entire messaging ([8178a13](https://github.com/input-output-hk/cardano-js-sdk/commit/8178a13a40c709e11f1209fd0fe00e7f9f481716))

### Code Refactoring

- **dapp-connector:** renamed cip30 package to dapp-connector ([cb4411d](https://github.com/input-output-hk/cardano-js-sdk/commit/cb4411da916b263ad8a6d85e0bdaffcfe21646c5))
- lift key management and governance concepts to new packages ([15cde5f](https://github.com/input-output-hk/cardano-js-sdk/commit/15cde5f9becff94dac17278cb45e3adcaac763b5))
- **web-extension:** rename messaging destroy->shutdown for consistent naming ([fa0ae48](https://github.com/input-output-hk/cardano-js-sdk/commit/fa0ae480881c12109a99f51cce346505b0105c0e))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/web-extension@0.4.0...@cardano-sdk/web-extension@0.5.0) (2022-08-30)

### ⚠ BREAKING CHANGES

- replace `NetworkInfoProvider.timeSettings` with `eraSummaries`
- logger is now required
- hoist stake$ and lovelaceSupply$ out of ObservableWallet
- - (web-extension) observableWalletProperties has new `transactions.rollback$` property

* (wallet) createAddressTransactionsProvider returns an object with two observables
  `{rollback$, transactionsSource$}`, instead of only the transactionsSource$ observable
* (wallet) TransactionsTracker interface contains new `rollback$` property
* (wallet) TransactionsTracker interface `$confirmed` Observable emits `NewTxAlonzoWithSlot`
  object instead of NewTxAlonzo

- update min utxo computation to be Babbage-compatible

### Features

- replace `NetworkInfoProvider.timeSettings` with `eraSummaries` ([58f6fc7](https://github.com/input-output-hk/cardano-js-sdk/commit/58f6fc7c5ace703583c36f95d3d6962483ad924d))
- resubmit rollback transactions ([2a4ccb0](https://github.com/input-output-hk/cardano-js-sdk/commit/2a4ccb0abead34481e817f807850d29e77d7340a))
- **web-extension:** add utils to expose/consume NetworkInfoStatsTracker ([1598969](https://github.com/input-output-hk/cardano-js-sdk/commit/159896957899d4182b0892b93f4389ed2fc064c3))
- **web-extension:** slightly improve messengers log output ([baf7499](https://github.com/input-output-hk/cardano-js-sdk/commit/baf7499c485818c6a3c7affbf97270d7840e2372))

### Bug Fixes

- update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))
- **web-extension:** do not re-emit all messages upon new port connection ([4b56cab](https://github.com/input-output-hk/cardano-js-sdk/commit/4b56cab7379f359b2d6dce41ff9533fdabdad4c4))
- **web-extension:** use ReplaySubject as a workaround to postMessage/subscribe race ([ed294af](https://github.com/input-output-hk/cardano-js-sdk/commit/ed294af6a6e7283bf9271c5bdef8b591e12658be))

### Code Refactoring

- hoist stake$ and lovelaceSupply$ out of ObservableWallet ([3bf1720](https://github.com/input-output-hk/cardano-js-sdk/commit/3bf17200c8bae46b02817c16e5138d3678cfa3f5))
- logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/web-extension@0.4.0) (2022-07-25)

### ⚠ BREAKING CHANGES

- update min utxo computation to be Babbage-compatible

### Features

- add cip36 metadataBuilder ([0632dc5](https://github.com/input-output-hk/cardano-js-sdk/commit/0632dc508e6be7bc37024e5f8128337ba64a9f47))

### Bug Fixes

- update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))

## 0.3.0 (2022-06-24)

### ⚠ BREAKING CHANGES

- improve ObservableWallet.balance interface
- **web-extension:** rename RemoteApiProperty.Observable->HotObservable
- remove transactions and blocks methods from blockfrost wallet provider
- rename `StakePoolSearchProvider` to `StakePoolProvider`
- add serializable object key transformation support
- **web-extension:** do not timeout remote observable subscriptions
- rm ObservableWallet.networkId (to be resolved via networkInfo$)
- revert 7076fc2ae987948e2c52b696666842ddb67af5d7
- rm cip30 dependency on web-extension
- require to explicitly specify exposed api property names (security reasons)
- hoist cip30 mapping of ObservableWallet to cip30 pkg
- rework cip30 to use web extension messaging ports

### Features

- require to explicitly specify exposed api property names (security reasons) ([f1a0aa4](https://github.com/input-output-hk/cardano-js-sdk/commit/f1a0aa4129705920ea5a734448fea6b99efbdcb4))
- **web-extension:** add remote api nested objects support ([d9f738c](https://github.com/input-output-hk/cardano-js-sdk/commit/d9f738c70c658790aceb2cc855e3b5c87a300107))
- **web-extension:** add remote api observable support ([8ed968c](https://github.com/input-output-hk/cardano-js-sdk/commit/8ed968cf2ca18e902fa9d61281882d1ca20a458a))
- **web-extension:** add rewards provider support ([3630fba](https://github.com/input-output-hk/cardano-js-sdk/commit/3630fbae9fd8bdb5539a32e39b65f2ce8577a481))
- **web-extension:** add utils to expose/consume an AsyncKeyAgent ([80e173d](https://github.com/input-output-hk/cardano-js-sdk/commit/80e173dfb8c7910a660cb62dba67a8765eed247c))
- **web-extension:** export utils to expose/consume an observable wallet ([b215e51](https://github.com/input-output-hk/cardano-js-sdk/commit/b215e5188a011497050921bbaf53c34417189163))

### Bug Fixes

- add missing UTXO_PROVIDER and WALLET_PROVIDER envs to blockfrost instatiation condition ([3773a69](https://github.com/input-output-hk/cardano-js-sdk/commit/3773a69a609a81f5c2541b2c2c21125ae6464cdf))
- **web-extension:** cache remote api properties ([44764aa](https://github.com/input-output-hk/cardano-js-sdk/commit/44764aa6ef578d43b5726ba56a7d5c2f80958359))
- **web-extension:** correctly forward message arguments ([9ceadb4](https://github.com/input-output-hk/cardano-js-sdk/commit/9ceadb4bf4ba8d6de428f3e07ea9e9ff86bde40c))
- **web-extension:** do not timeout remote observable subscriptions ([39422e4](https://github.com/input-output-hk/cardano-js-sdk/commit/39422e4fb1bef7760d4aeacdb4c53a84e326bc8d))
- **web-extension:** ignore non-explicitly-exposed observables and objects ([417dd3b](https://github.com/input-output-hk/cardano-js-sdk/commit/417dd3b1949774ecb26f29af8031ada2751ddd3a))
- **web-extension:** support creating remote objects before source exists ([d4ac17f](https://github.com/input-output-hk/cardano-js-sdk/commit/d4ac17f2ad80bdf3dea1d211187ad4c6457f562d))

### Code Refactoring

- add serializable object key transformation support ([32e422e](https://github.com/input-output-hk/cardano-js-sdk/commit/32e422e83f723a41521193d9cf4206a538fbcb43))
- hoist cip30 mapping of ObservableWallet to cip30 pkg ([7076fc2](https://github.com/input-output-hk/cardano-js-sdk/commit/7076fc2ae987948e2c52b696666842ddb67af5d7))
- improve ObservableWallet.balance interface ([b8371f9](https://github.com/input-output-hk/cardano-js-sdk/commit/b8371f97e151c2e9cb18e0ac431e9703fe490d26))
- remove transactions and blocks methods from blockfrost wallet provider ([e4de136](https://github.com/input-output-hk/cardano-js-sdk/commit/e4de13650f0d387b8e7126077e8721f353af8c85))
- rename `StakePoolSearchProvider` to `StakePoolProvider` ([b432103](https://github.com/input-output-hk/cardano-js-sdk/commit/b43210348da7914664733f85f8be8999271a8667))
- revert 7076fc2ae987948e2c52b696666842ddb67af5d7 ([b30183e](https://github.com/input-output-hk/cardano-js-sdk/commit/b30183e4852606e38c1d5b55dd9dc51ed138fc29))
- rework cip30 to use web extension messaging ports ([837dc9d](https://github.com/input-output-hk/cardano-js-sdk/commit/837dc9da1c19df340953c47381becfe07f02a0c9))
- rm cip30 dependency on web-extension ([77f8642](https://github.com/input-output-hk/cardano-js-sdk/commit/77f8642ebaac3b2615d082184d22a96f4cf86d42))
- rm ObservableWallet.networkId (to be resolved via networkInfo$) ([72be7d7](https://github.com/input-output-hk/cardano-js-sdk/commit/72be7d7fc9dfd1bd12593ab572d9b6734d789822))
- **web-extension:** rename RemoteApiProperty.Observable->HotObservable ([4bc9922](https://github.com/input-output-hk/cardano-js-sdk/commit/4bc99224d3cdcadc90729eecd8cb9ea2d6227438))
