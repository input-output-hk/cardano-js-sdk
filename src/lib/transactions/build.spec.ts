import { expect } from 'chai'
import { buildTransaction } from './build'

describe('buildTransaction', () => {
  it('throws if a transaction is underfunded', () => {
    const inputs = [
      { pointer: { id: '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', index: 1 }, value: 1 },
      { pointer: { id: 'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210', index: 0 }, value: 5 }
    ]

    const outputs = [
      { address: 'Ae2tdPwUPEZCEhYAUVU7evPfQCJjyuwM6n81x6hSjU9TBMSy2YwZEVydssL', value: '5826376' }
    ]

    expect(() => buildTransaction(inputs, outputs)).to.throw(/Unbalanced transaction/)
  })

  it('throws if a transaction is unbalanced', () => {
    const inputs = [
      { pointer: { id: '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', index: 1 }, value: 1 },
      { pointer: { id: 'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210', index: 0 }, value: 1 }
    ]

    const outputs = [
      { address: 'Ae2tdPwUPEZCEhYAUVU7evPfQCJjyuwM6n81x6hSjU9TBMSy2YwZEVydssL', value: '3' }
    ]

    expect(() => buildTransaction(inputs, outputs)).to.throw(/Unbalanced transaction/)
  })
})
