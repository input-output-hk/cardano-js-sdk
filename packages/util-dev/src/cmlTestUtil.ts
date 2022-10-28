import { CML, Cardano, coreToCml } from '@cardano-sdk/core';
import { ManagedFreeableScope } from '@cardano-sdk/util';

export const createTxInput = (() => {
  let defaultIdx = 0;
  return (
    scope: ManagedFreeableScope,
    bech32TxHash = 'base16_1sw0vvt7mgxghdewkrsptd2n0twueg2a7q88t9cjhtqmpk7xwc07shpk2uq',
    index?: number
  ) =>
    scope.manage(
      CML.TransactionInput.new(
        scope.manage(CML.TransactionHash.from_bech32(bech32TxHash)),
        scope.manage(CML.BigNum.from_str((index || defaultIdx++).toString()))
      )
    );
})();

export const createUnspentTxOutput = (
  scope: ManagedFreeableScope,
  valueQuantities: Cardano.Value,
  bech32Addr = 'addr1vy36kffjf87vzkuyqc5g0ys3fe3pez5zvqg9r5z9q9kfrkg2cs093'
): CML.TransactionUnspentOutput => {
  const address = scope.manage(CML.Address.from_bech32(bech32Addr));
  const amount = coreToCml.value(scope, valueQuantities);
  return scope.manage(
    CML.TransactionUnspentOutput.new(createTxInput(scope), scope.manage(CML.TransactionOutput.new(address, amount)))
  );
};

export const createOutput = (
  scope: ManagedFreeableScope,
  valueQuantities: Cardano.Value,
  bech32Addr = 'addr1vyeljkh3vr4h9s3lyxe7g2meushk3m4nwyzdgtlg96e6mrgg8fnle'
): CML.TransactionOutput =>
  scope.manage(
    CML.TransactionOutput.new(
      scope.manage(CML.Address.from_bech32(bech32Addr)),
      coreToCml.value(scope, valueQuantities)
    )
  );
