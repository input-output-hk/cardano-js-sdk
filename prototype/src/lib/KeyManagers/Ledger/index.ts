import { getLedgerTransportForEnvironment } from '../../bindings'
import { KeyManager, UnsupportedOperation, InsufficientData } from '../../../KeyManager'
import { TransactionOutput } from '../../../Transaction'
import { ChainSettings } from '../../../Cardano'
import { AddressType } from '../../../Wallet'

const { default: Ledger, utils } = require('@cardano-foundation/ledgerjs-hw-app-cardano')

async function connectToLedger () {
  const transport = await getLedgerTransportForEnvironment().create()
  return new Ledger(transport)
}

export async function LedgerKeyManager (accountIndex = 0, publicParentKey?: string): Promise<KeyManager> {
  const ledger = await connectToLedger()

  async function deriveBip44Account () {
    if (!publicParentKey) {
      const { publicKeyHex, chainCodeHex } = await ledger.getExtendedPublicKey([
        utils.HARDENED + 44,
        utils.HARDENED + 1815,
        utils.HARDENED + accountIndex
      ])

      publicParentKey = `${publicKeyHex}${chainCodeHex}`
    }

    return publicParentKey
  }

  return {
    signTransaction: async (transaction, rawInputs, _chainSettings = ChainSettings.mainnet, transactionsAsProofForSpending) => {
      const transactionJson = transaction.toJson()

      for (const txInput of rawInputs) {
        if (!transactionsAsProofForSpending[txInput.pointer.id]) {
          throw new InsufficientData('Ledger signTransaction', 'transaction bodies for inputs being spent')
        }
      }

      const inputs = rawInputs.map(input => {
        return {
          txDataHex: transactionsAsProofForSpending[input.pointer.id],
          outputIndex: input.pointer.index,
          path: utils.str_to_path(`44'/1815'/${accountIndex}'/${input.addressing.change}/${input.addressing.index}`)
        }
      })

      const rawOutputs: TransactionOutput[] = transactionJson.outputs
      const outputs = rawOutputs.map(output => {
        return { amountStr: String(output.value), address58: output.address }
      })

      const ledgerSignedTransaction = await ledger.signTransaction(inputs, outputs)
      const publicParentKey = await deriveBip44Account()

      ledgerSignedTransaction.witnesses.forEach((ledgerWitness: any) => {
        transaction.addExternalWitness({
          addressType: ledgerWitness.path[3] === 1 ? AddressType.internal : AddressType.external,
          witnessIndex: ledgerWitness.path[4],
          publicParentKey,
          witnessHex: ledgerWitness.witnessSignatureHex
        })
      })

      return transaction.finalize()
    },
    signMessage: async () => {
      throw new UnsupportedOperation('Ledger signMessage')
    },
    publicParentKey: () => deriveBip44Account()
  }
}
