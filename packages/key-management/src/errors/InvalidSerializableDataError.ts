import { CustomError } from 'ts-custom-error';

const formatMessage = (detail?: string) => {
  const messageDetail = detail ? `: ${detail}` : '';
  return `Invalid serializable key agent data${messageDetail}`;
};

export class InvalidSerializableDataError extends CustomError {
  constructor(detail?: string) {
    super(formatMessage(detail));
  }
}
