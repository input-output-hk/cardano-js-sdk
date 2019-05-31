# Cardano JS SDK
JavaScript SDK for interacting with Cardano, providing various key management options including support for popular hardware wallets

## Features
*This SDK is a work in progress and should not be used in production. Feature state as follows:*

- [x] Build a transaction and estimate fees
- [x] Transaction input selection
- [ ] Transaction signing
  - [x] memory
  - [ ] Ledger Nano S
  - [ ] Trezor
- [ ] Submit transaction to network
- [ ] Message signing and verification
  - [x] memory
  - [ ] Ledger Nano S
  - [ ] Trezor
- [ ] Staking and Delegation

## Examples
The below examples are implemented as integration tests, they should be very easy to understand.

- [Generate a keypair in memory from a BIP39 mnemonic](src/test/MemoryKeyManager.spec.ts)
- [Message signatures](src/test/SignAndVerify.spec.ts)
- [Get the wallet balance for a BIP44 Public Account](src/test/WalletBalance.spec.ts)
- [Determine the next change and receipt addresses for a BIP44 Public Account](src/test/DetermineNextAddressForWallet.spec.ts)
- [Transaction input selection](src/test/SelectInputsForTransaction.spec.ts)

## Tests

Run the test suite with `npm test`.

### Ledger Nano S Specs
To run the ledger specs:
- Have a Ledger device connect, unlocked and in the Cardano app
- Run `LEDGER_SPECS=true npm test`
  
You will need to interact with the device during the test run.

## Development References

Hardware wallet transaction preparation - https://github.com/Emurgo/yoroi-frontend/tree/develop/app/api/ada/hardwareWallet

BIP44 Specification - https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki

Cardano WASM Implementation - https://github.com/input-output-hk/js-cardano-wasm/blob/master/cardano-wallet/src/lib.rs