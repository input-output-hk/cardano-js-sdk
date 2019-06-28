import { CustomError } from 'ts-custom-error'

export class UnsupportedWalletOperation extends CustomError {
  constructor (walletType: string, operation: string, extraInfo?: string) {
    super()
    this.message = `The ${walletType} wallet does not support the following operation: ${operation}. ${extraInfo}`
    this.name = 'UnsupportedWalletOperation'
  }
}
