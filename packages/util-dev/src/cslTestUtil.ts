import { CSL, Cardano, coreToCsl } from '@cardano-sdk/core';
import { ManagedFreeableScope } from '@cardano-sdk/util';

export const createTxInput = (() => {
  let defaultIdx = 0;
  return (
    scope: ManagedFreeableScope,
    bech32TxHash = 'base16_1sw0vvt7mgxghdewkrsptd2n0twueg2a7q88t9cjhtqmpk7xwc07shpk2uq',
    index?: number
  ) =>
    scope.manage(
      CSL.TransactionInput.new(scope.manage(CSL.TransactionHash.from_bech32(bech32TxHash)), index || defaultIdx++)
    );
})();

export const createUnspentTxOutput = (
  scope: ManagedFreeableScope,
  valueQuantities: Cardano.Value,
  bech32Addr = 'addr1vy36kffjf87vzkuyqc5g0ys3fe3pez5zvqg9r5z9q9kfrkg2cs093'
): CSL.TransactionUnspentOutput => {
  const address = scope.manage(CSL.Address.from_bech32(bech32Addr));
  const amount = coreToCsl.value(scope, valueQuantities);
  return scope.manage(
    CSL.TransactionUnspentOutput.new(createTxInput(scope), scope.manage(CSL.TransactionOutput.new(address, amount)))
  );
};

export const createOutput = (
  scope: ManagedFreeableScope,
  valueQuantities: Cardano.Value,
  bech32Addr = 'addr1vyeljkh3vr4h9s3lyxe7g2meushk3m4nwyzdgtlg96e6mrgg8fnle'
): CSL.TransactionOutput =>
  scope.manage(
    CSL.TransactionOutput.new(
      scope.manage(CSL.Address.from_bech32(bech32Addr)),
      coreToCsl.value(scope, valueQuantities)
    )
  );
