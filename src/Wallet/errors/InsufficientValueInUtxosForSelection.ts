import { CustomError } from 'ts-custom-error'

export class InsufficientValueInUtxosForSelection extends CustomError {
  constructor (valueNeeded: number, valueInUtxos: number) {
    super()
    this.message = `The account has insufficent utxos for selection. Payment value required is ${valueNeeded}. Value held in utxos is ${valueInUtxos}.`
    this.name = 'InsufficientValueInUtxosForSelection'
  }
}
