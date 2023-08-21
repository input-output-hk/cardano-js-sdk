#!/bin/bash
# Generating pair of keys for provided mnemonic

echo "vacant violin soft weird deliver render brief always monitor general maid smart jelly core drastic erode echo there clump dizzy card filter option defense" >phrase.prv
cat phrase.prv | cardano-address key from-recovery-phrase Shelley >rootkey.prv
cat rootkey.prv | cardano-address key child 1852H/1815H/0H/0/0 >addr.prv
cat rootkey.prv | cardano-address key child 1852H/1815H/0H/2/0 >stake.prv
cat stake.prv | cardano-address key public --with-chain-code >stake.pub
cat addr.prv | cardano-address key public --with-chain-code | cardano-address address payment --network-tag testnet >payment.addr
cat payment.addr | cardano-address address delegation "$(cat stake.pub)" >base.addr
cardano-cli key convert-cardano-address-key --signing-key-file addr.prv --shelley-payment-key --out-file payment.skey
cardano-cli key verification-key --signing-key-file payment.skey --verification-key-file Ext_ShelleyPayment.vkey
cardano-cli key non-extended-key --extended-verification-key-file Ext_ShelleyPayment.vkey --verification-key-file payment.vkey
rm phrase.prv rootkey.prv addr.prv stake.prv stake.pub payment.addr Ext_ShelleyPayment.vkey
