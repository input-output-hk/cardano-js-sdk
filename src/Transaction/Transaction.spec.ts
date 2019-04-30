import { expect } from 'chai'
import { Transaction } from './Transaction'

describe('Transaction', () => {
  describe('Finalize', () => {
    it('throws if a transaction has more input than output', () => {
      const inputs = [
        { pointer: { id: '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', index: 1 }, value: '1000000' },
        { pointer: { id: 'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210', index: 0 }, value: '5000000' }
      ]

      let outputs = [
        { address: 'Ae2tdPwUPEZCEhYAUVU7evPfQCJjyuwM6n81x6hSjU9TBMSy2YwZEVydssL', value: '10000' }
      ]

      expect(() => Transaction(inputs, outputs).finalize()).to.throw(/Inputs outweigh outputs/)
    })

    it('throws if a transaction has more output than input', () => {
      const inputs = [
        { pointer: { id: '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', index: 1 }, value: '1' },
        { pointer: { id: 'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210', index: 0 }, value: '1' }
      ]

      const outputs = [
        { address: 'Ae2tdPwUPEZCEhYAUVU7evPfQCJjyuwM6n81x6hSjU9TBMSy2YwZEVydssL', value: '2000000' }
      ]

      expect(() => Transaction(inputs, outputs).finalize()).to.throw(/Outputs outweigh inputs/)
    })

    it('returns a transaction as hex when the transaction is balanced', () => {
      const inputs = [
        { pointer: { id: '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', index: 1 }, value: '1000000' },
        { pointer: { id: 'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210', index: 0 }, value: '5000000' }
      ]

      let outputs = [
        { address: 'Ae2tdPwUPEZCEhYAUVU7evPfQCJjyuwM6n81x6hSjU9TBMSy2YwZEVydssL', value: '6000000' }
      ]

      const fee = Transaction(inputs, outputs).estimateFee()

      outputs[0].value = (6000000 - Number(fee)).toString()
      const transaction = Transaction(inputs, outputs).finalize()
      const expectedHex = '839f8200d81858248258200123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef018200d8185824825820fedcba9876543210fedcba9876543210fedcba9876543210fedcba987654321000ff9f8282d818582183581c9aa3c11f83717c117b5da7f49b9387dc90d1694a75849bd5cbde8e20a0001ae196744f1a0058e69dffa0'
      expect(transaction.to_hex()).to.equal(expectedHex)
    })
  })
})
