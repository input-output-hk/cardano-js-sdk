// These are utilities used by tests. They are not tested.
// Consider moving some of them to core package utils.
// And some of them to a new 'dev-util' package.
import { CardanoSerializationLib, CSL, Ogmios } from '@cardano-sdk/core';
import { SelectionResult } from '../../src/types';
import { ValueQuantities, valueToValueQuantities, valueQuantitiesToValue } from '../../src/util';

export const TSLA_Asset = '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41';
export const PXL_Asset = '1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c960150584c';
export const Unit_Asset = 'a5425bd7bc4182325188af2340415827a73f845846c165d9e14c5aed556e6974';
export const AllAssets = [TSLA_Asset, PXL_Asset, Unit_Asset];

/**
 * Checks whether UTxO is included in an array of UTxO.
 * Compares utxo.to_bytes().
 */
export const containsUtxo = (haystack: CSL.TransactionUnspentOutput[], needleUtxo: CSL.TransactionUnspentOutput) => {
  const needleUtxoBytes = needleUtxo.to_bytes();
  return haystack.some((haystackUtxo: CSL.TransactionUnspentOutput) => {
    const haystackUtxoBytes = haystackUtxo.to_bytes();
    if (haystackUtxoBytes.length !== needleUtxoBytes.length) {
      return false;
    }
    for (const [idx, utxoByte] of needleUtxoBytes.entries()) {
      if (haystackUtxoBytes[idx] !== utxoByte) {
        return false;
      }
    }
    return true;
  });
};

const getTotalOutputAmounts = (outputs: CSL.TransactionOutput[]): ValueQuantities => {
  let result: ValueQuantities = {
    coins: 0n,
    assets: {} as Record<string, bigint>
  };
  for (const output of outputs) {
    const amount = output.amount();
    result = Ogmios.util.coalesceValueQuantities(result, valueToValueQuantities(amount));
  }
  return result;
};

const getTotalInputAmounts = (results: SelectionResult): ValueQuantities =>
  results.selection.inputs
    .map((input) => input.output().amount())
    .reduce<ValueQuantities>((sum, value) => Ogmios.util.coalesceValueQuantities(sum, valueToValueQuantities(value)), {
      coins: 0n,
      assets: {}
    });

const getTotalChangeAmounts = (results: SelectionResult): ValueQuantities =>
  results.selection.change.reduce<ValueQuantities>(
    (sum, value) => Ogmios.util.coalesceValueQuantities(sum, valueToValueQuantities(value)),
    {
      assets: {},
      coins: 0n
    }
  );

export const createCslTestUtils = (csl: CardanoSerializationLib) => {
  const createTxInput = (() => {
    let defaultIdx = 0;
    return (bech32TxHash = 'base16_1sw0vvt7mgxghdewkrsptd2n0twueg2a7q88t9cjhtqmpk7xwc07shpk2uq', index?: number) =>
      csl.TransactionInput.new(csl.TransactionHash.from_bech32(bech32TxHash), index || defaultIdx++);
  })();

  const createUnspentTxOutput = (
    valueQuantities: ValueQuantities,
    bech32Addr = 'addr1vy36kffjf87vzkuyqc5g0ys3fe3pez5zvqg9r5z9q9kfrkg2cs093'
  ): CSL.TransactionUnspentOutput => {
    const address = csl.Address.from_bech32(bech32Addr);
    const amount = valueQuantitiesToValue(valueQuantities, csl);
    return csl.TransactionUnspentOutput.new(createTxInput(), csl.TransactionOutput.new(address, amount));
  };

  const createOutput = (
    valueQuantities: ValueQuantities,
    bech32Addr = 'addr1vyeljkh3vr4h9s3lyxe7g2meushk3m4nwyzdgtlg96e6mrgg8fnle'
  ): CSL.TransactionOutput =>
    csl.TransactionOutput.new(csl.Address.from_bech32(bech32Addr), valueQuantitiesToValue(valueQuantities, csl));

  return {
    createUnspentTxOutput,
    createOutput,
    getTotalOutputAmounts,
    getTotalInputAmounts,
    getTotalChangeAmounts
  };
};

export type TestUtils = ReturnType<typeof createCslTestUtils>;
