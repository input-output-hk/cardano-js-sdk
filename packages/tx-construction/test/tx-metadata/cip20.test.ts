import { CIP20 } from '../../src';
import { Cardano } from '@cardano-sdk/core';

describe('CIP20', () => {
  const compliantShortMessage = 'Lorem ipsum dolor';
  const compliantMaxMessage = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean';
  const oversizeMessage = `${compliantMaxMessage}1`;
  describe('validateMessage', () => {
    it('validates a CIP-20 message if a string and less than or equal to 64 bytes', () => {
      expect(CIP20.validateMessage(compliantShortMessage)).toStrictEqual({ valid: true });
      expect(CIP20.validateMessage(compliantMaxMessage)).toStrictEqual({ valid: true });
    });
    it('invalidates a CIP-20 message if a string but over 64 bytes', () => {
      expect(CIP20.validateMessage(oversizeMessage)).toStrictEqual({
        failure: CIP20.MessageValidationFailure.oversize,
        valid: false
      });
    });
    it('invalidates a CIP-20 message if wrong type', () => {
      expect(CIP20.validateMessage(1 as unknown as string)).toStrictEqual({
        failure: CIP20.MessageValidationFailure.wrongType,
        valid: false
      });
      expect(CIP20.validateMessage({ message: compliantShortMessage } as unknown as string)).toStrictEqual({
        failure: CIP20.MessageValidationFailure.wrongType,
        valid: false
      });
      expect(CIP20.validateMessage([compliantShortMessage] as unknown as string)).toStrictEqual({
        failure: CIP20.MessageValidationFailure.wrongType,
        valid: false
      });
      expect(
        CIP20.validateMessage(new Map([[CIP20.METADATUM_LABEL, compliantShortMessage]]) as unknown as string)
      ).toStrictEqual({ failure: CIP20.MessageValidationFailure.wrongType, valid: false });
    });
  });
  describe('toTxMetadata', () => {
    describe('args object', () => {
      it('produces a CIP20-compliant TxMetadata map', () => {
        const metadata = CIP20.toTxMetadata({ messages: [compliantShortMessage] }) as Cardano.TxMetadata;
        expect(metadata.has(CIP20.METADATUM_LABEL)).toBe(true);
        const cip20Metadata = metadata.get(CIP20.METADATUM_LABEL) as Cardano.MetadatumMap;
        expect(cip20Metadata.get('msg')).toStrictEqual([compliantShortMessage]);
      });
      it('throws an error if any messages are invalid', () => {
        expect(() =>
          CIP20.toTxMetadata({
            messages: [compliantShortMessage, compliantMaxMessage, oversizeMessage]
          })
        ).toThrowError(CIP20.MessageValidationError);
      });
    });
    describe('produces a CIP20-compliant TxMetadata map with a string arg', () => {
      test('larger than 64 bytes', () => {
        const metadata = CIP20.toTxMetadata(oversizeMessage) as Cardano.TxMetadata;
        expect(metadata.has(CIP20.METADATUM_LABEL)).toBe(true);
        const cip20Metadata = metadata.get(CIP20.METADATUM_LABEL) as Cardano.MetadatumMap;
        expect((cip20Metadata.get('msg') as string[]).length).toBe(2);
      });
      test('equal to 64 bytes', () => {
        const metadata = CIP20.toTxMetadata(compliantMaxMessage) as Cardano.TxMetadata;
        expect(metadata.has(CIP20.METADATUM_LABEL)).toBe(true);
        const cip20Metadata = metadata.get(CIP20.METADATUM_LABEL) as Cardano.MetadatumMap;
        expect((cip20Metadata.get('msg') as string[]).length).toBe(1);
      });
      test('smaller than to 64 bytes', () => {
        const metadata = CIP20.toTxMetadata(compliantShortMessage) as Cardano.TxMetadata;
        expect(metadata.has(CIP20.METADATUM_LABEL)).toBe(true);
        const cip20Metadata = metadata.get(CIP20.METADATUM_LABEL) as Cardano.MetadatumMap;
        expect((cip20Metadata.get('msg') as string[]).length).toBe(1);
      });
    });
  });
});
