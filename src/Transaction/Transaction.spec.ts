import { expect } from 'chai'
import Transaction, { TransactionInput, TransactionOutput } from './'
import { InsufficientTransactionInput } from './errors'
import { EmptyArray } from '../lib/validator/errors'
import { RustCardano } from '../lib'

describe('Transaction', () => {
  it('throws if inputs are invalid', () => {
    const emptyInputArray = [] as TransactionInput[]
    const invalidInputType = [{ foo: 'bar' }] as any[]

    let outputs = [
      { address: 'Ae2tdPwUPEZCEhYAUVU7evPfQCJjyuwM6n81x6hSjU9TBMSy2YwZEVydssL', value: '10000' }
    ]

    expect(() => Transaction(RustCardano, emptyInputArray, outputs)).to.throw(EmptyArray)
    expect(() => Transaction(RustCardano, invalidInputType, outputs)).to.throw(/Invalid value/)
  })

  it('throws if outputs are invalid', () => {
    const inputs = [
      { pointer: { id: '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', index: 1 }, value: { address: 'addressWithFunds1', value: '1000000' } },
      { pointer: { id: 'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210', index: 0 }, value: { address: 'addressWithFunds2', value: '6000000' } }
    ]

    const emptyOutputArray = [] as TransactionOutput[]
    const invalidOutputType = [{ foo: 'bar' }] as any[]

    expect(() => Transaction(RustCardano, inputs, emptyOutputArray)).to.throw(EmptyArray)
    expect(() => Transaction(RustCardano, inputs, invalidOutputType)).to.throw(/Invalid value/)
  })

  it('throws if a transaction has more combined output value than input value', () => {
    const inputs = [
      { pointer: { id: '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', index: 1 }, value: { address: 'addressWithFunds1', value: '1' } },
      { pointer: { id: 'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210', index: 0 }, value: { address: 'addressWithFunds2', value: '1' } }
    ]

    const outputs = [
      { address: 'Ae2tdPwUPEZCEhYAUVU7evPfQCJjyuwM6n81x6hSjU9TBMSy2YwZEVydssL', value: '2000000' }
    ]

    expect(() => Transaction(RustCardano, inputs, outputs)).to.throw(InsufficientTransactionInput)
  })

  it('accepts more combined input value than output, to cover fees', () => {
    const inputs = [
      { pointer: { id: '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', index: 1 }, value: { address: 'addressWithFunds1', value: '1000000' } },
      { pointer: { id: 'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210', index: 0 }, value: { address: 'addressWithFunds2', value: '5000000' } }
    ]

    let outputs = [
      { address: 'Ae2tdPwUPEZCEhYAUVU7evPfQCJjyuwM6n81x6hSjU9TBMSy2YwZEVydssL', value: '10000' }
    ]

    expect(() => Transaction(RustCardano, inputs, outputs)).to.not.throw()
  })

  it('allows access to a transaction as hex', () => {
    const inputs = [
      { pointer: { id: '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', index: 1 }, value: { address: 'addressWithFunds1', value: '2000000' } },
      { pointer: { id: 'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210', index: 0 }, value: { address: 'addressWithFunds2', value: '5000000' } }
    ]

    let outputs = [
      { address: 'Ae2tdPwUPEZCEhYAUVU7evPfQCJjyuwM6n81x6hSjU9TBMSy2YwZEVydssL', value: '6000000' }
    ]

    const fee = Transaction(RustCardano, inputs, outputs).estimateFee()

    outputs[0].value = (6000000 - Number(fee)).toString()
    const transaction = Transaction(RustCardano, inputs, outputs)
    const expectedHex = '839f8200d81858248258200123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef018200d8185824825820fedcba9876543210fedcba9876543210fedcba9876543210fedcba987654321000ff9f8282d818582183581c9aa3c11f83717c117b5da7f49b9387dc90d1694a75849bd5cbde8e20a0001ae196744f1a0058e69dffa0'
    expect(transaction.toHex()).to.equal(expectedHex)
  })

  describe('fee', () => {
    it('returns the realised fee of a transaction', () => {
      const inputs = [
        { pointer: { id: '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', index: 1 }, value: { address: 'addressWithFunds1', value: '1000000' } },
        { pointer: { id: 'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210', index: 0 }, value: { address: 'addressWithFunds2', value: '6010000' } }
      ]

      let outputs = [
        { address: 'Ae2tdPwUPEZCEhYAUVU7evPfQCJjyuwM6n81x6hSjU9TBMSy2YwZEVydssL', value: '5000000' }
      ]

      const estimatedFee = Transaction(RustCardano, inputs, outputs).estimateFee()
      const realisedFee = Transaction(RustCardano, inputs, outputs).fee()

      expect(realisedFee).to.equal('2010000')
      expect(realisedFee).to.not.eql(estimatedFee)
    })
  })
})
