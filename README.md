# Cardano JS SDK
JavaScript SDK for interacting with Cardano, providing various key management options including support for popular hardware wallets

## Features
*This SDK is a work in progress. Feature state as follows:*

- [x] Build a transaction and estimate fees
- [ ] Balance a transaction (delegate input selection)
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

## Development References

Hardware wallet transaction preparation - https://github.com/Emurgo/yoroi-frontend/tree/develop/app/api/ada/hardwareWallet

BIP44 Specification - https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki

Cardano WASM Implementation - https://github.com/input-output-hk/js-cardano-wasm/blob/master/cardano-wallet/src/lib.rs