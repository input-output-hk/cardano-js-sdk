import { CustomError } from 'ts-custom-error';

const formatMessage = (detail?: string) => {
  const messageDetail = detail ? `: ${detail}` : '';
  return `Authentication failure${messageDetail}`;
};

export class AuthenticationError extends CustomError {
  constructor(detail?: string, public innerError?: unknown) {
    super(formatMessage(detail));
  }
}
