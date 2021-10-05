import { CardanoSerializationLib, CSL, Ogmios } from '@cardano-sdk/core';

export const createTxInput = (() => {
  let defaultIdx = 0;
  return (
    csl: CardanoSerializationLib,
    bech32TxHash = 'base16_1sw0vvt7mgxghdewkrsptd2n0twueg2a7q88t9cjhtqmpk7xwc07shpk2uq',
    index?: number
  ) => csl.TransactionInput.new(csl.TransactionHash.from_bech32(bech32TxHash), index || defaultIdx++);
})();

export const createUnspentTxOutput = (
  csl: CardanoSerializationLib,
  valueQuantities: Ogmios.util.OgmiosValue,
  bech32Addr = 'addr1vy36kffjf87vzkuyqc5g0ys3fe3pez5zvqg9r5z9q9kfrkg2cs093'
): CSL.TransactionUnspentOutput => {
  const address = csl.Address.from_bech32(bech32Addr);
  const amount = Ogmios.ogmiosToCsl(csl).value(valueQuantities);
  return csl.TransactionUnspentOutput.new(createTxInput(csl), csl.TransactionOutput.new(address, amount));
};

export const createOutput = (
  csl: CardanoSerializationLib,
  valueQuantities: Ogmios.util.OgmiosValue,
  bech32Addr = 'addr1vyeljkh3vr4h9s3lyxe7g2meushk3m4nwyzdgtlg96e6mrgg8fnle'
): CSL.TransactionOutput =>
  csl.TransactionOutput.new(csl.Address.from_bech32(bech32Addr), Ogmios.ogmiosToCsl(csl).value(valueQuantities));
