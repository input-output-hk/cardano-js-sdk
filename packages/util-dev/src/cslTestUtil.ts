import { Ogmios, CSL } from '@cardano-sdk/core';

export const createTxInput = (() => {
  let defaultIdx = 0;
  return (bech32TxHash = 'base16_1sw0vvt7mgxghdewkrsptd2n0twueg2a7q88t9cjhtqmpk7xwc07shpk2uq', index?: number) =>
    CSL.TransactionInput.new(CSL.TransactionHash.from_bech32(bech32TxHash), index || defaultIdx++);
})();

export const createUnspentTxOutput = (
  valueQuantities: Ogmios.Value,
  bech32Addr = 'addr1vy36kffjf87vzkuyqc5g0ys3fe3pez5zvqg9r5z9q9kfrkg2cs093'
): CSL.TransactionUnspentOutput => {
  const address = CSL.Address.from_bech32(bech32Addr);
  const amount = Ogmios.ogmiosToCsl.value(valueQuantities);
  return CSL.TransactionUnspentOutput.new(createTxInput(), CSL.TransactionOutput.new(address, amount));
};

export const createOutput = (
  valueQuantities: Ogmios.Value,
  bech32Addr = 'addr1vyeljkh3vr4h9s3lyxe7g2meushk3m4nwyzdgtlg96e6mrgg8fnle'
): CSL.TransactionOutput =>
  CSL.TransactionOutput.new(CSL.Address.from_bech32(bech32Addr), Ogmios.ogmiosToCsl.value(valueQuantities));
