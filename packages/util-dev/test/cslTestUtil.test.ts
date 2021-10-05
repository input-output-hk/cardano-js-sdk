import { CardanoSerializationLib, loadCardanoSerializationLib } from '@cardano-sdk/core';
import { createTxInput, createOutput, createUnspentTxOutput } from '../src/cslTestUtil';

describe('cslUtil', () => {
  let csl: CardanoSerializationLib;
  beforeAll(async () => {
    csl = await loadCardanoSerializationLib();
  });
  describe('createTxInput', () => {
    it('returns instance of TransactionInput', () => {
      expect(createTxInput(csl)).toBeInstanceOf(csl.TransactionInput);
    });
  });
  describe('createOutput', () => {
    it('returns instance of TransactionOutput', () => {
      expect(createOutput(csl, { coins: 1n })).toBeInstanceOf(csl.TransactionOutput);
    });
  });
  describe('createUnspentTxOutput', () => {
    it('returns instance of TransactionUnspentOutput', () => {
      expect(createUnspentTxOutput(csl, { coins: 1n })).toBeInstanceOf(csl.TransactionUnspentOutput);
    });
  });
});
