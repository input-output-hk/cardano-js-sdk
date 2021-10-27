import { CSL } from '@cardano-sdk/core';
import { createOutput, createTxInput, createUnspentTxOutput } from '../src/cslTestUtil';

describe('cslUtil', () => {
  describe('createTxInput', () => {
    it('returns instance of TransactionInput', () => {
      expect(createTxInput()).toBeInstanceOf(CSL.TransactionInput);
    });
  });
  describe('createOutput', () => {
    it('returns instance of TransactionOutput', () => {
      expect(createOutput({ coins: 1n })).toBeInstanceOf(CSL.TransactionOutput);
    });
  });
  describe('createUnspentTxOutput', () => {
    it('returns instance of TransactionUnspentOutput', () => {
      expect(createUnspentTxOutput({ coins: 1n })).toBeInstanceOf(CSL.TransactionUnspentOutput);
    });
  });
});
