// These are utilities used by tests. They are not tested.
// Consider moving some of them to core package utils.
// And some of them to a new 'dev-util' package.
import { CardanoSerializationLib, CSL, Ogmios } from '@cardano-sdk/core';
import { SelectionResult } from '../../src/types';

export const TSLA_Asset = '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41';
export const PXL_Asset = '1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c960150584c';
export const Unit_Asset = 'a5425bd7bc4182325188af2340415827a73f845846c165d9e14c5aed556e6974';
export const AllAssets = [TSLA_Asset, PXL_Asset, Unit_Asset];

const getTotalOutputAmounts = (outputs: CSL.TransactionOutput[]): Ogmios.util.OgmiosValue => {
  let result: Ogmios.util.OgmiosValue = {
    coins: 0n,
    assets: {} as Record<string, bigint>
  };
  for (const output of outputs) {
    const amount = output.amount();
    result = Ogmios.util.coalesceValueQuantities(result, Ogmios.cslToOgmios.value(amount));
  }
  return result;
};

const getTotalInputAmounts = (results: SelectionResult): Ogmios.util.OgmiosValue =>
  [...results.selection.inputs]
    .map((input) => input.output().amount())
    .reduce<Ogmios.util.OgmiosValue>(
      (sum, value) => Ogmios.util.coalesceValueQuantities(sum, Ogmios.cslToOgmios.value(value)),
      {
        coins: 0n,
        assets: {}
      }
    );

const getTotalChangeAmounts = (results: SelectionResult): Ogmios.util.OgmiosValue =>
  [...results.selection.change].reduce<Ogmios.util.OgmiosValue>(
    (sum, value) => Ogmios.util.coalesceValueQuantities(sum, Ogmios.cslToOgmios.value(value)),
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
    valueQuantities: Ogmios.util.OgmiosValue,
    bech32Addr = 'addr1vy36kffjf87vzkuyqc5g0ys3fe3pez5zvqg9r5z9q9kfrkg2cs093'
  ): CSL.TransactionUnspentOutput => {
    const address = csl.Address.from_bech32(bech32Addr);
    const amount = Ogmios.ogmiosToCsl(csl).value(valueQuantities);
    return csl.TransactionUnspentOutput.new(createTxInput(), csl.TransactionOutput.new(address, amount));
  };

  const createOutput = (
    valueQuantities: Ogmios.util.OgmiosValue,
    bech32Addr = 'addr1vyeljkh3vr4h9s3lyxe7g2meushk3m4nwyzdgtlg96e6mrgg8fnle'
  ): CSL.TransactionOutput =>
    csl.TransactionOutput.new(csl.Address.from_bech32(bech32Addr), Ogmios.ogmiosToCsl(csl).value(valueQuantities));

  return {
    createUnspentTxOutput,
    createOutput,
    getTotalOutputAmounts,
    getTotalInputAmounts,
    getTotalChangeAmounts
  };
};

export type TestUtils = ReturnType<typeof createCslTestUtils>;
