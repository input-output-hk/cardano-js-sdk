import { CSL } from '@cardano-sdk/core';
import { createOutput, createTxInput, createUnspentTxOutput } from '../src/cslTestUtil';
import { usingAutoFree } from '@cardano-sdk/util';

describe('cslUtil', () => {
  describe('createTxInput', () => {
    it('returns instance of TransactionInput', () => {
      expect(usingAutoFree((scope) => scope.manage(createTxInput(scope)))).toBeInstanceOf(CSL.TransactionInput);
    });
  });
  describe('createOutput', () => {
    it('returns instance of TransactionOutput', () => {
      expect(usingAutoFree((scope) => createOutput(scope, { coins: 1n }))).toBeInstanceOf(CSL.TransactionOutput);
    });
  });
  describe('createUnspentTxOutput', () => {
    it('returns instance of TransactionUnspentOutput', () => {
      expect(usingAutoFree((scope) => scope.manage(createUnspentTxOutput(scope, { coins: 1n })))).toBeInstanceOf(
        CSL.TransactionUnspentOutput
      );
    });
  });
});
