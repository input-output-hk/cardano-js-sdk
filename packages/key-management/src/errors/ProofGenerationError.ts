import { CustomError } from 'ts-custom-error';

const formatMessage = (detail?: string) => {
  const messageDetail = detail ? `: ${detail}` : '';
  return `Proof generation failure${messageDetail}`;
};

export class ProofGenerationError extends CustomError {
  constructor(detail?: string, public innerError?: unknown) {
    super(formatMessage(detail));
  }
}
