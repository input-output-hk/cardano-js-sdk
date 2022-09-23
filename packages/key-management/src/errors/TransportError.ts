import { ComposableError } from '@cardano-sdk/core';

const formatMessage = (detail?: string) => {
  const messageDetail = detail ? `: ${detail}` : '';
  return `Transport failure${messageDetail}`;
};

export class TransportError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(detail?: string, innerError?: InnerError) {
    super(formatMessage(detail), innerError);
  }
}
