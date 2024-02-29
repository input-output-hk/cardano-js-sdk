# Cardano JS SDK | Wallet | Test

Running these suites requires both a supported Ledger and Trezor device to be plugged in via USB. You may need to
install udev rules, if running on Linux, which can be done by using the script documented in
[Download and Install Ledger Live docs], and via the [Trezor Suite] UI.

[download and install ledger live docs]: https://support.ledger.com/hc/en-us/articles/4404389606417-Download-and-install-Ledger-Live?docs=true
[trezor suite]: https://trezor.io/trezor-suite

## Ledger HW Tests

`yarn test:hw:ledger`

## Trezor HW Tests

`yarn test:hw:trezor`
