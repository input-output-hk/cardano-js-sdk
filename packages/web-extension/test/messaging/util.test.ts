import {
  EmitMessage,
  MethodRequest,
  RequestMessage,
  ResponseMessage,
  SubscriptionMessage,
  isEmitMessage,
  isRequest,
  isRequestMessage,
  isResponseMessage,
  isSubscriptionMessage,
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
      expect(isRequestMessage({ messageId: 'messageId', request: validRequest } as RequestMessage)).toBe(true);
    });
    it('returns false for objects not matching MethodRequestMessage type', () => {
      expect(isRequestMessage(null)).toBe(false);
      expect(isRequestMessage({ messageId: 'messageId' })).toBe(false);
      expect(isRequestMessage({ request: validRequest })).toBe(false);
    });
  });
  describe('isResponseMessage', () => {
    it('returns true for objects matching ResponseMessage type', () => {
      expect(isResponseMessage({ messageId: 'messageId', response: null } as ResponseMessage)).toBe(true);
      expect(isResponseMessage({ messageId: 'messageId', response: true } as ResponseMessage)).toBe(true);
    });
    it('returns false for objects not matching ResponseMessage type', () => {
      expect(isResponseMessage(null)).toBe(false);
      expect(isResponseMessage({ messageId: 'messageId' })).toBe(false);
      expect(isResponseMessage({ response: true })).toBe(false);
    });
  });
  describe('isSubscriptionMessage', () => {
    it('returns true for objects matching SubscriptionMessage type', () => {
      expect(isSubscriptionMessage({ messageId: 'messageId', subscribe: false } as SubscriptionMessage)).toBe(true);
      expect(isSubscriptionMessage({ messageId: 'messageId', subscribe: true } as SubscriptionMessage)).toBe(true);
    });
    it('returns false for objects not matching SubscriptionMessage type', () => {
      expect(isSubscriptionMessage(null)).toBe(false);
      expect(isSubscriptionMessage({ messageId: 'messageId' })).toBe(false);
      expect(isSubscriptionMessage({ subscribe: true })).toBe(false);
    });
  });
  describe('isEmitMessage', () => {
    it('returns true for objects matching EmitMessage type', () => {
      expect(isEmitMessage({ emit: null, messageId: 'messageId' } as EmitMessage)).toBe(true);
      expect(isEmitMessage({ emit: 'message', messageId: 'messageId' } as EmitMessage)).toBe(true);
    });
    it('returns false for objects not matching EmitMessage type', () => {
      expect(isEmitMessage(null)).toBe(false);
      expect(isEmitMessage({ messageId: 'messageId' })).toBe(false);
      expect(isEmitMessage({ emit: true })).toBe(false);
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
