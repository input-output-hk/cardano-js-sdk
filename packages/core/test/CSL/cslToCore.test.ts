import { coreToCsl, cslToCore } from '../../src';
import { mintTokenMap, tx, txBody, txIn, txInWithAddress, txOut, valueCoinOnly, valueWithAssets } from './testData';

describe('cslToCore', () => {
  describe('value', () => {
    it('coin only', () => {
      expect(cslToCore.value(coreToCsl.value(valueCoinOnly))).toEqual(valueCoinOnly);
    });
    it('csltOCore coin with assets', () => {
      expect(cslToCore.value(coreToCsl.value(valueWithAssets))).toEqual(valueWithAssets);
    });
  });

  describe('txIn', () => {
    it('converts an input', () => {
      expect(cslToCore.txIn(coreToCsl.txIn(txIn))).toEqual(txIn);
    });
    it('doesnt serialize address', () => {
      expect(cslToCore.txIn(coreToCsl.txIn(txInWithAddress))).toEqual({
        ...txInWithAddress,
        address: undefined
      });
    });
  });

  it('txOut', () => {
    expect(cslToCore.txOut(coreToCsl.txOut(txOut))).toEqual(txOut);
  });

  it('txMint', () => {
    expect(cslToCore.txMint(coreToCsl.txMint(mintTokenMap))).toEqual(mintTokenMap);
  });

  it.todo('txAuxiliaryData');

  test.skip('txBody', () => {
    expect(cslToCore.txBody(coreToCsl.txBody(txBody))).toEqual(txBody);
  });

  test.skip('newTx', () => {
    expect(cslToCore.newTx(coreToCsl.tx(tx))).toEqual(tx);
  });
});
