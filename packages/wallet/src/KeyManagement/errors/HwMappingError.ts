import { CustomError } from 'ts-custom-error';

const formatMessage = (detail?: string) => {
  const messageDetail = detail ? `: ${detail}` : '';
  return `Hardware date mapping failure${messageDetail}`;
};

export class HwMappingError extends CustomError {
  constructor(detail?: string, public innerError?: unknown) {
    super(formatMessage(detail));
  }
}
