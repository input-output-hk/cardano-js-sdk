import { expect } from 'chai'
import { largestFirst } from '.'
import { InsufficientValueInUtxosForSelection } from '../errors'

describe('coinSelection', () => {
  describe('largestFirst', () => {
    it('throws if there is insufficient inputs to cover the payment cost', () => {
      const paymentValue = 100000

      const utxosWithAddressing = [
        { address: 'add1', value: '1000', hash: 'foobar', index: 0, change: 0 },
        { address: 'add2', value: '1000', hash: 'foobar', index: 0, change: 0 }
      ]

      expect(() => largestFirst(paymentValue, utxosWithAddressing, 'changeAddress')).to.throw(InsufficientValueInUtxosForSelection)
    })

    it('selects the single largest utxo if it covers the payment value', () => {
      const paymentValue = 100000
      const sufficientSingleValue = '1000000000'

      const utxosWithAddressing = [
        { address: 'add1', value: sufficientSingleValue, hash: 'foobar', index: 0, change: 0 },
        { address: 'add2', value: '1000', hash: 'foobar', index: 0, change: 0 }
      ]

      const { inputs, changeOutput } = largestFirst(paymentValue, utxosWithAddressing, 'changeAddress')

      expect(inputs.length).to.eql(1)
      expect(inputs[0].value.address).to.eql('add1')
      expect(inputs[0].value.value).to.eql(sufficientSingleValue)
      expect(changeOutput.value).to.eql(String(Number(sufficientSingleValue) - paymentValue))
      expect(changeOutput.address).to.eql('changeAddress')
    })

    it('selects the largest utxos in descending order multiple are required to cover the payment value', () => {
      const paymentValue = 100000
      const largestInput = '90000'
      const secondLargestInput = '20000'

      const utxosWithAddressing = [
        { address: 'add1', value: '22', hash: 'foobar', index: 0, change: 0 },
        { address: 'add2', value: largestInput, hash: 'foobar', index: 0, change: 0 },
        { address: 'add3', value: secondLargestInput, hash: 'foobar', index: 0, change: 0 }
      ]

      const { inputs, changeOutput } = largestFirst(paymentValue, utxosWithAddressing, 'changeAddress')

      expect(inputs.length).to.eql(2)
      expect(inputs[0].value.address).to.eql('add2')
      expect(inputs[0].value.value).to.eql(largestInput)
      expect(inputs[1].value.address).to.eql('add3')
      expect(inputs[1].value.value).to.eql(secondLargestInput)
      expect(changeOutput.value).to.eql(String(Number(largestInput) + Number(secondLargestInput) - paymentValue))
      expect(changeOutput.address).to.eql('changeAddress')
    })

    it('does not return a change output if exact payment is made', () => {
      const paymentValue = 100000
      const largestInput = '90000'
      const secondLargestInput = '10000'

      const utxosWithAddressing = [
        { address: 'add1', value: '22', hash: 'foobar', index: 0, change: 0 },
        { address: 'add2', value: largestInput, hash: 'foobar', index: 0, change: 0 },
        { address: 'add3', value: secondLargestInput, hash: 'foobar', index: 0, change: 0 }
      ]

      const { changeOutput } = largestFirst(paymentValue, utxosWithAddressing, 'changeAddress')
      expect(changeOutput).to.eql(undefined)
    })
  })
})
