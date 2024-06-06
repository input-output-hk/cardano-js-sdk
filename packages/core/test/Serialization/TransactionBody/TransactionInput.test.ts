/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano/index.js';
import { HexBlob } from '@cardano-sdk/util';
import { TransactionInput } from '../../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib

const cbor = HexBlob('8258200102030405060708090a0b0c0d0e0f0e0d0c0b0a09080706050403020100102005');

const core = {
  index: 5,
  txId: Cardano.TransactionId('0102030405060708090a0b0c0d0e0f0e0d0c0b0a090807060504030201001020')
};

describe('TransactionInput', () => {
  it('can decode TransactionInput from CBOR', () => {
    const input = TransactionInput.fromCbor(cbor);

    expect(input.index()).toEqual(5n);
    expect(input.transactionId()).toEqual('0102030405060708090a0b0c0d0e0f0e0d0c0b0a090807060504030201001020');
  });

  it('can decode TransactionInput from Core', () => {
    const input = TransactionInput.fromCore(core);

    expect(input.index()).toEqual(5n);
    expect(input.transactionId()).toEqual('0102030405060708090a0b0c0d0e0f0e0d0c0b0a090807060504030201001020');
  });

  it('can encode TransactionInput to CBOR', () => {
    const input = TransactionInput.fromCore(core);

    expect(input.toCbor()).toEqual('8258200102030405060708090a0b0c0d0e0f0e0d0c0b0a09080706050403020100102005');
  });

  it('can encode TransactionInput to Core', () => {
    const input = TransactionInput.fromCbor(cbor);

    expect(input.toCore()).toEqual(core);
  });
});
