import { ComposableError } from '@cardano-sdk/core';

const formatMessage = (detail?: string) => {
  const messageDetail = detail ? `: ${detail}` : '';
  return `Hardware data mapping failure${messageDetail}`;
};

export class HwMappingError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(detail?: string, innerError?: InnerError) {
    super(formatMessage(detail), innerError);
  }
}
