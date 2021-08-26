import { CustomError } from 'ts-custom-error';

/**
 * ProofGeneration - User has accepted the transaction sign, but the wallet was
 * unable to sign the transaction (e.g. not having some of the private keys)
 * - UserDeclined - User declined to sign the transaction
 */
enum TxSignErrorCode {
  ProofGeneration = 1,
  UserDeclined = 2
}
export class TxSignError extends CustomError {
  code: TxSignErrorCode;
  info: string;

  public constructor(code: TxSignErrorCode, info: string) {
    super();
    this.code = code;
    this.info = info;
  }
}
