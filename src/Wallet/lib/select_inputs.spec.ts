import { expect } from 'chai'
import { selectInputsAndChangeOutput } from '.'
import { InsufficientValueInUtxosForSelection, MaximumTransactionInputsExceeded } from '../errors'
import { InputSelectionAlgorithm } from '..'

describe('selectInputsAndChangeOutput', () => {
  it('throws if there is insufficient inputs to cover the payment cost', () => {
    const paymentValue = 100000

    const utxosWithAddressing = [
      { address: 'add1', value: '1000', hash: 'foobar', index: 0, change: 0 },
      { address: 'add2', value: '1000', hash: 'foobar', index: 0, change: 0 }
    ]

    expect(() => selectInputsAndChangeOutput(paymentValue, utxosWithAddressing, 'changeAddress', InputSelectionAlgorithm.largestFirst)).to.throw(InsufficientValueInUtxosForSelection)
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

    const { changeOutput } = selectInputsAndChangeOutput(paymentValue, utxosWithAddressing, 'changeAddress', InputSelectionAlgorithm.largestFirst)
    expect(changeOutput).to.eql(undefined)
  })

  describe('largestFirst', () => {
    it('selects the single largest utxo if it covers the payment value', () => {
      const paymentValue = 100000
      const sufficientSingleValue = '1000000000'

      const utxosWithAddressing = [
        { address: 'add1', value: sufficientSingleValue, hash: 'foobar', index: 0, change: 0 },
        { address: 'add2', value: '1000', hash: 'foobar', index: 0, change: 0 }
      ]

      const { inputs, changeOutput } = selectInputsAndChangeOutput(paymentValue, utxosWithAddressing, 'changeAddress', InputSelectionAlgorithm.largestFirst)

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

      const { inputs, changeOutput } = selectInputsAndChangeOutput(paymentValue, utxosWithAddressing, 'changeAddress', InputSelectionAlgorithm.largestFirst)

      expect(inputs.length).to.eql(2)
      expect(inputs[0].value.address).to.eql('add2')
      expect(inputs[0].value.value).to.eql(largestInput)
      expect(inputs[1].value.address).to.eql('add3')
      expect(inputs[1].value.value).to.eql(secondLargestInput)
      expect(changeOutput.value).to.eql(String(Number(largestInput) + Number(secondLargestInput) - paymentValue))
      expect(changeOutput.address).to.eql('changeAddress')
    })

    it('throws if the number of transaction inputs exceeds the maximum', () => {
      const paymentValue = 100
      const dustUtxos = [...Array(100000)].map((_, index) => ({ address: `add${index}`, value: '1', hash: 'foobar', index: 0, change: 0 }))
      expect(() => selectInputsAndChangeOutput(paymentValue, dustUtxos, 'changeAddress', InputSelectionAlgorithm.largestFirst)).to.throw(MaximumTransactionInputsExceeded)
    })
  })

  describe('random', () => {
    it('falls back to largestFirst if transaction input is exceeded', () => {
      const paymentValue = 100
      const dustUtxos = [...Array(10000)].map((_, index) => ({ address: `add${index}`, value: '1', hash: 'foobar', index: 0, change: 0 }))
      const largestUtxo = { address: `largeAddress`, value: '90', hash: 'foobar', index: 0, change: 0 }

      // There is a small chance that the large utxo will end up in the first 50 utxos after a random sort.
      // However this will hit the code fork 99.5% of the time, and the assertion will always pass
      const { inputs } = selectInputsAndChangeOutput(paymentValue, [...dustUtxos, largestUtxo], 'changeAddress', InputSelectionAlgorithm.random)
      expect(inputs.length).to.eql(11)
    })

    it('selects valid utxos and produces change', () => {
      const paymentValue = 100

      // Any combination of these inputs will always product change
      const utxosWithAddressing = [
        { address: 'add1', value: '60', hash: 'foobar', index: 0, change: 0 },
        { address: 'add2', value: '50', hash: 'foobar', index: 0, change: 0 },
        { address: 'add3', value: '33', hash: 'foobar', index: 0, change: 0 },
        { address: 'add4', value: '41', hash: 'foobar', index: 0, change: 0 }
      ]

      const { inputs, changeOutput } = selectInputsAndChangeOutput(paymentValue, utxosWithAddressing, 'changeAddress', InputSelectionAlgorithm.random)
      expect(inputs.length > 0).to.eql(true)
      expect(changeOutput.address).to.eql('changeAddress')
    })
  })
})
