import { createOutput, createTxInput, createUnspentTxOutput } from '../src/txTestUtil.js';

describe('txTestUtil', () => {
  describe('createTxInput', () => {
    it('returns new input index on each call', () => {
      expect(createTxInput().index).not.toEqual(createTxInput().index);
    });
  });
  test('createOutput', () => {
    expect(createOutput({ coins: 1n }).value.coins).toBe(1n);
  });
  test('createUnspentTxOutput', () => {
    expect(createUnspentTxOutput({ coins: 1n })[1].value.coins).toBe(1n);
  });
});
