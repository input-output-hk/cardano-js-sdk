import {
  CIP_20_METADATUM_LABEL,
  MessageValidationError,
  MessageValidationFailure,
  toCIP20Metadata,
  validateMessage
} from '../../src/TxMetadata';
import { Cardano } from '../../src';
import { TxMetadata } from '../../src/Cardano';

describe('TxMetadata.cip20', () => {
  const compliantShortMessage = 'Lorem ipsum dolor';
  const compliantMaxMessage = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean';
  const oversizeMessage = `${compliantMaxMessage}1`;
  describe('validateMessage', () => {
    it('validates a CIP-20 message if a string and less than or equal to 64 bytes', () => {
      expect(validateMessage(compliantShortMessage)).toStrictEqual({ valid: true });
      expect(validateMessage(compliantMaxMessage)).toStrictEqual({ valid: true });
    });
    it('invalidates a CIP-20 message if a string but over 64 bytes', () => {
      expect(validateMessage(oversizeMessage)).toStrictEqual({
        failure: MessageValidationFailure.oversize,
        valid: false
      });
    });
    it('invalidates a CIP-20 message if wrong type', () => {
      expect(validateMessage(1 as unknown as string)).toStrictEqual({
        failure: MessageValidationFailure.wrongType,
        valid: false
      });
      expect(validateMessage({ message: compliantShortMessage } as unknown as string)).toStrictEqual({
        failure: MessageValidationFailure.wrongType,
        valid: false
      });
      expect(validateMessage([compliantShortMessage] as unknown as string)).toStrictEqual({
        failure: MessageValidationFailure.wrongType,
        valid: false
      });
      expect(
        validateMessage(new Map([[CIP_20_METADATUM_LABEL, compliantShortMessage]]) as unknown as string)
      ).toStrictEqual({ failure: MessageValidationFailure.wrongType, valid: false });
    });
  });
  describe('toCIP20Metadata', () => {
    describe('args object', () => {
      it('produces a CIP-20-compliant TxMetadata map', () => {
        const metadata = toCIP20Metadata({ messages: [compliantShortMessage] }) as TxMetadata;
        expect(metadata.has(CIP_20_METADATUM_LABEL)).toBe(true);
        const cip20Metadata = metadata.get(CIP_20_METADATUM_LABEL) as Cardano.MetadatumMap;
        expect(cip20Metadata.get('msg')).toStrictEqual([compliantShortMessage]);
      });
      it('throws an error if any messages are invalid', () => {
        expect(() =>
          toCIP20Metadata({
            messages: [compliantShortMessage, compliantMaxMessage, oversizeMessage]
          })
        ).toThrowError(MessageValidationError);
      });
    });
    describe('producing a CIP-20-compliant TxMetadata map with a string arg', () => {
      test('larger than 64 bytes', () => {
        const metadata = toCIP20Metadata(oversizeMessage) as TxMetadata;
        expect(metadata.has(CIP_20_METADATUM_LABEL)).toBe(true);
        const cip20Metadata = metadata.get(CIP_20_METADATUM_LABEL) as Cardano.MetadatumMap;
        expect((cip20Metadata.get('msg') as string[]).length).toBe(2);
      });
      test('equal to 64 bytes', () => {
        const metadata = toCIP20Metadata(compliantMaxMessage) as TxMetadata;
        expect(metadata.has(CIP_20_METADATUM_LABEL)).toBe(true);
        const cip20Metadata = metadata.get(CIP_20_METADATUM_LABEL) as Cardano.MetadatumMap;
        expect((cip20Metadata.get('msg') as string[]).length).toBe(1);
      });
      test('smaller than to 64 bytes', () => {
        const metadata = toCIP20Metadata(compliantShortMessage) as TxMetadata;
        expect(metadata.has(CIP_20_METADATUM_LABEL)).toBe(true);
        const cip20Metadata = metadata.get(CIP_20_METADATUM_LABEL) as Cardano.MetadatumMap;
        expect((cip20Metadata.get('msg') as string[]).length).toBe(1);
      });
    });
  });
});
