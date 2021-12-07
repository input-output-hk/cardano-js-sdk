import { Cardano } from '@cardano-sdk/core';

export const createTxInput = (() => {
  let defaultIndex = 0;
  return (
    txId = Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad'),
    address = Cardano.Address('addr1vy36kffjf87vzkuyqc5g0ys3fe3pez5zvqg9r5z9q9kfrkg2cs093'),
    index = defaultIndex++
  ) => ({ address, index, txId });
})();

export const createUnspentTxOutput = (
  value: Cardano.Value,
  address = Cardano.Address('addr1vy36kffjf87vzkuyqc5g0ys3fe3pez5zvqg9r5z9q9kfrkg2cs093')
): Cardano.Utxo => [createTxInput(), { address, value }];

export const createOutput = (
  value: Cardano.Value,
  address = Cardano.Address('addr1vyeljkh3vr4h9s3lyxe7g2meushk3m4nwyzdgtlg96e6mrgg8fnle')
): Cardano.TxOut => ({ address, value });
