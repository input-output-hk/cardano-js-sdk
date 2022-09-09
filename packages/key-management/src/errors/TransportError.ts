import { CustomError } from 'ts-custom-error';

const formatMessage = (detail?: string) => {
  const messageDetail = detail ? `: ${detail}` : '';
  return `Transport failure${messageDetail}`;
};

export class TransportError extends CustomError {
  constructor(detail?: string, public innerError?: unknown) {
    super(formatMessage(detail));
  }
}
