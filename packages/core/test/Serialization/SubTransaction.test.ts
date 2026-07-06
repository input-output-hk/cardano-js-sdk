import * as Cardano from '../../src/Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { SubTransaction, SubTransactionBody, TransactionBody } from '../../src/Serialization';
import { signature, vkey } from './testData';
import { vectorsForRule } from './dijkstraVectors';

const minimalBodyCbor = HexBlob('a200d90102800180');
const auxDataCbor = 'a1016474657374';
const witnessSetCbor = `a100d9010281825820${vkey}5840${signature}`;

const withAuxDataCbor = HexBlob(`83${minimalBodyCbor}a0${auxDataCbor}`);
const withWitnessCbor = HexBlob(`83${minimalBodyCbor}${witnessSetCbor}f6`);
const twoElementCbor = HexBlob(`82${minimalBodyCbor}a0`);
const fourElementCbor = HexBlob(`84${minimalBodyCbor}a0f5f6`);

const [minimalVector] = vectorsForRule('sub_transaction');
const minimalCbor = HexBlob(minimalVector.hex);

const minimalCore: Cardano.SubTransaction = {
  body: { inputs: [], outputs: [] },
  witness: { signatures: new Map() }
};

const witnessedCore: Cardano.SubTransaction = {
  auxiliaryData: { blob: new Map<bigint, Cardano.Metadatum>([[1n, 'test']]) },
  body: { inputs: [], outputs: [] },
  witness: {
    signatures: new Map([[Crypto.Ed25519PublicKeyHex(vkey), Crypto.Ed25519SignatureHex(signature)]])
  }
};

describe('SubTransaction', () => {
  describe('round trips', () => {
    it('round trips the ledger minimal vector (null auxiliary data) byte-exactly', () => {
      const subTx = SubTransaction.fromCbor(minimalCbor);

      expect(subTx.toCbor()).toEqual(minimalCbor);
      expect(subTx.auxiliaryData()).toBeUndefined();
    });

    it('round trips a frame with auxiliary data byte-exactly', () => {
      const subTx = SubTransaction.fromCbor(withAuxDataCbor);

      expect(subTx.toCbor()).toEqual(withAuxDataCbor);
      expect(subTx.auxiliaryData()).not.toBeUndefined();
    });

    it('round trips a frame with a vkey witness set byte-exactly', () => {
      const subTx = SubTransaction.fromCbor(withWitnessCbor);

      expect(subTx.toCbor()).toEqual(withWitnessCbor);
      expect(subTx.witnessSet().vkeys()!.size()).toEqual(1);
    });

    it('re-encodes null vs present auxiliary data exactly after a property change', () => {
      const fromNull = SubTransaction.fromCbor(minimalCbor);
      fromNull.setAuxiliaryData(fromNull.auxiliaryData());
      expect(fromNull.toCbor()).toEqual(minimalCbor);

      const fromPresent = SubTransaction.fromCbor(withAuxDataCbor);
      fromPresent.setAuxiliaryData(fromPresent.auxiliaryData());
      expect(fromPresent.toCbor()).toEqual(withAuxDataCbor);
    });
  });

  describe('frame arity', () => {
    it('rejects a 2-element frame', () => {
      expect(() => SubTransaction.fromCbor(twoElementCbor)).toThrowError(
        'Sub transaction frame must be exactly 3 elements'
      );
    });

    it('rejects a 4-element is_valid style frame', () => {
      expect(() => SubTransaction.fromCbor(fourElementCbor)).toThrowError(
        'Sub transaction frame must be exactly 3 elements'
      );
    });
  });

  describe('getId', () => {
    it('derives the id like the top level transaction id for identical body bytes', () => {
      const subTx = SubTransaction.fromCbor(minimalCbor);
      const topLevelId = TransactionBody.fromCbor(minimalBodyCbor).hash();

      expect(subTx.getId()).toEqual(topLevelId);
    });

    it('changes the id when the body changes', () => {
      const subTx = SubTransaction.fromCbor(minimalCbor);
      const originalId = subTx.getId();

      const otherBody = SubTransaction.fromCbor(withWitnessCbor).body();
      otherBody.setTtl(Cardano.Slot(100));
      subTx.setBody(otherBody);

      expect(subTx.getId()).not.toEqual(originalId);
    });
  });

  describe('toCore/fromCore', () => {
    it('is symmetric for the minimal sub transaction', () => {
      const subTx = SubTransaction.fromCbor(minimalCbor);
      const core = subTx.toCore();

      expect(core).toEqual(minimalCore);
      expect(SubTransaction.fromCore(core).toCbor()).toEqual(minimalCbor);
    });

    it('is symmetric for a witnessed sub transaction with auxiliary data', () => {
      const subTx = SubTransaction.fromCore(witnessedCore);

      expect(subTx.toCore()).toEqual(witnessedCore);
      expect(SubTransaction.fromCbor(subTx.toCbor()).toCore()).toEqual(witnessedCore);
    });

    it('encodes the witnessed core sub transaction byte-identically to the constructed vector', () => {
      const subTx = SubTransaction.fromCore(witnessedCore);

      expect(subTx.toCbor()).toEqual(HexBlob(`83${minimalBodyCbor}${witnessSetCbor}${auxDataCbor}`));
    });
  });

  describe('setters and clone', () => {
    it('can set the body, witness set and auxiliary data', () => {
      const subTx = SubTransaction.fromCbor(minimalCbor);
      const other = SubTransaction.fromCbor(withWitnessCbor);
      const withAux = SubTransaction.fromCbor(withAuxDataCbor);

      subTx.setWitnessSet(other.witnessSet());
      subTx.setAuxiliaryData(withAux.auxiliaryData());
      subTx.setBody(SubTransactionBody.fromCbor(minimalBodyCbor));

      expect(subTx.toCbor()).toEqual(HexBlob(`83${minimalBodyCbor}${witnessSetCbor}${auxDataCbor}`));
    });

    it('can perform a deep clone of the object', () => {
      const subTx = SubTransaction.fromCbor(withAuxDataCbor);
      const cloned = subTx.clone();

      subTx.setAuxiliaryData();

      expect(cloned.toCbor()).toEqual(withAuxDataCbor);
      expect(subTx.toCbor()).toEqual(minimalCbor);
    });
  });
});
