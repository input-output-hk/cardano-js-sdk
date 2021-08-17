# Cardano JS SDK

JavaScript SDK for interacting with Cardano, providing various key management options including support for popular hardware wallets. The library supports multiple Cardano APIs by establishing a [_Provider_](src/Provider/Provider.ts) interface. This is beneficial for both development workflow and production scenarios, as application logic does not become coupled to any one implementation.

There are two _provider_ types, and it is important to understand the difference when using the SDK. We have defined the _CardanoProvider_ and _WalletProvider_.

To satisfy the _CardanoProvider_ interface, the _provider_ must be able to supply a complete, queryable interface into the chain state. Any address should be queryable for both historic transactions and current UTXOs. When interfacing with a _CardanoProvider_, we use the _ClientWallet_ implementation to satisfy wallet behaviour. 

A _WalletProvider_ satisfies a smaller interface than _CardanoProvider_. The _WalletProvider_ maintains historic chain state only for address sets derived from known parent public keys, which are stored server side. When interfacing with a _WalletProvider_, we use the _RemoteWallet_ implementation to satisfy wallet behaviour, which is in most cases a simple mapping directly to the _WalletProvider_.

 - [Style Guide](docs/style_guide.md)
 - [More documentation](docs)

## Project State: Alpha

This SDK is a work in progress and should not be used in production. The initial _provider_ and Cardano _primitive_ implementations are in the base package at this stage, but the intention is to publish separate packages to allow for composition into a clean and minimal bundle.

### Feature progress

- [x] Build a transaction and estimate fees
- [x] Transaction input selection
- [ ] Transaction signing
  - [x] memory
  - [x] Ledger Nano S
  - [ ] Trezor
- [ ] Message signing and verification
  - [x] memory
  - [ ] Ledger Nano S
  - [ ] Trezor  
- [ ] Cardano Providers
  - [ ] [cardano-wallet](https://github.com/input-output-hk/cardano-wallet)
- [ ] Staking and Delegation

## Examples
The below examples are implemented as integration tests, they should be very easy to understand.

- [Generate a keypair in memory from a BIP39 mnemonic](src/test/InMemoryKeyManager.spec.ts)
- [Message signatures](src/test/SignAndVerify.spec.ts)
- [Get the wallet balance for a BIP44 Account](src/test/WalletBalance.spec.ts)
- [Determine the next change and receipt addresses for a BIP44 Account](src/test/DetermineNextAddressForWallet.spec.ts)
- [Transaction input selection](src/test/SelectInputsForTransaction.spec.ts)
- [Interact with a remote wallet](src/test/RemoteWalletIntegration.spec.ts)

## Tests

Run the test suite with `npm test`.

### Ledger Nano S Specs
To run the ledger specs:
- Have a Ledger device connect, unlocked and in the Cardano app
- Run `LEDGER_SPECS=true npm test`
  
You will need to interact with the device during the test run.
