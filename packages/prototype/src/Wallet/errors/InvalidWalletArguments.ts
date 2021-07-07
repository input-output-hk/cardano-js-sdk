import { CustomError } from 'ts-custom-error'
import { ProviderType } from '../../Provider'

export class InvalidWalletArguments extends CustomError {
  constructor (providerType: ProviderType, missingArgument: string) {
    super()
    this.message = `${providerType} requires {${missingArgument}} be provided as an argument`
    this.name = 'InvalidWalletArguments'
  }
}
