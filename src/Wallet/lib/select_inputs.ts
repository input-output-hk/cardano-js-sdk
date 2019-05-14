import { TransactionInput, TransactionOutput } from '../../Transaction'
import { getBindingsForEnvironment } from '../../lib/bindings'
import { UtxoWithAddressing } from '..'
import { TxInput as CardanoTxInput } from 'cardano-wallet'
import { convertCoinToLovelace } from '../../Utils'
const { Coin, TransactionId, TxoPointer, TxInput, TxOut, OutputPolicy, Address, InputSelectionBuilder, LinearFeeAlgorithm } = getBindingsForEnvironment()

export interface TransactionSelection {
  inputs: TransactionInput[]
  changeOutput: TransactionOutput
}

export function selectInputsAndChangeOutput(outputs: TransactionOutput[], utxoSet: UtxoWithAddressing[], changeAddress: string, linearFeeAlgorithm = LinearFeeAlgorithm.default()): TransactionSelection {
  const potentialInputs: CardanoTxInput[] = utxoSet.map(utxo => {
    return TxInput.new(
      TxoPointer.new(TransactionId.from_hex(utxo.id), utxo.index),
      TxOut.new(Address.from_base58(utxo.address), Coin.from_str(utxo.value))
    )
  })

  const txOuts = outputs.map((out) => TxOut.new(Address.from_base58(out.address), Coin.from_str(out.value)))
  const changeOutputPolicy = OutputPolicy.change_to_one_address(Address.from_base58(changeAddress))

  let selectionBuilder = InputSelectionBuilder.first_match_first()
  potentialInputs.forEach(input => selectionBuilder.add_input(input))
  txOuts.forEach(output => selectionBuilder.add_output(output))

  const selectionResult = selectionBuilder.select_inputs(linearFeeAlgorithm, changeOutputPolicy)

  const estimatedChange = convertCoinToLovelace(selectionResult.estimated_change())
  const pointers = potentialInputs.map(i => {
    return TxoPointer.from_json(i.to_json().ptr)
  })

  let changeOutput
  if (estimatedChange !== '0') {
    changeOutput = {
      value: estimatedChange,
      address: changeAddress
    }
  }

  const selectedPointers = pointers.filter((pointer) => selectionResult.is_input(pointer))

  const inputs: TransactionInput[] = selectedPointers.map(ptr => {
    const pointer = ptr.to_json()
    const relevantUtxo = utxoSet.find(u => u.id === pointer.id)

    const value = {
      address: relevantUtxo.address,
      value: relevantUtxo.value
    }

    const addressing = relevantUtxo.addressing
    return { pointer, value, addressing }
  })

  return { inputs, changeOutput }
}
