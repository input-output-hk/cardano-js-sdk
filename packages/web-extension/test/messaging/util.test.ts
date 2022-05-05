import {
  MethodRequest,
  MethodRequestMessage,
  MethodResponseMessage,
  isRequest,
  isRequestMessage,
  isResponseMessage,
  newMessageId,
  senderOrigin
} from '../../src';

describe('messaging/util', () => {
  const validRequest: MethodRequest = { args: ['arg'], method: 'method' };
  describe('isRequest', () => {
    it('returns true for objects matching MethodRequest type', () => {
      expect(isRequest(validRequest)).toBe(true);
    });
    it('returns false for objects not matching MethodRequest type', () => {
      expect(isRequest(null)).toBe(false);
      expect(isRequest({ method: 'method', noArgs: true })).toBe(false);
    });
  });
  describe('isRequestMessage', () => {
    it('returns true for objects matching MethodRequestMessage type', () => {
      expect(isRequestMessage({ messageId: 'messageId', request: validRequest } as MethodRequestMessage)).toBe(true);
    });
    it('returns false for objects not matching MethodRequestMessage type', () => {
      expect(isRequestMessage(null)).toBe(false);
      expect(isRequestMessage({ messageId: 'messageId' })).toBe(false);
      expect(isRequestMessage({ request: validRequest })).toBe(false);
    });
  });
  describe('isResponseMessage', () => {
    it('returns true for objects matching MethodResponseMessage type', () => {
      expect(isResponseMessage({ messageId: 'messageId', response: null } as MethodResponseMessage)).toBe(true);
      expect(isResponseMessage({ messageId: 'messageId', response: true } as MethodResponseMessage)).toBe(true);
    });
    it('returns false for objects not matching MethodResponseMessage type', () => {
      expect(isResponseMessage(null)).toBe(false);
      expect(isResponseMessage({ messageId: 'messageId' })).toBe(false);
      expect(isResponseMessage({ response: true })).toBe(false);
    });
  });
  describe('messageId', () => {
    it('returns a different random ID on each call', () => {
      expect(newMessageId()).not.toEqual(newMessageId());
    });
  });
  describe('senderOrigin', () => {
    it('returns null when origin url is not present', () => {
      expect(senderOrigin()).toBe(null);
      expect(senderOrigin({ id: 'id' })).toBe(null);
    });
    it('returns origin url it is present', () => {
      expect(senderOrigin({ url: 'http://origin' })).toBe('http://origin');
    });
  });
});
