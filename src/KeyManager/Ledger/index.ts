import { getLedgerTransportForEnvironment, getBindingsForEnvironment } from '../../lib/bindings'
import { KeyManager } from '../KeyManager'
import { TransactionOutput } from '../../Transaction'
import { UnsupportedOperation, InsufficientData } from '../errors'

const { default: Ledger, utils } = require('@cardano-foundation/ledgerjs-hw-app-cardano')
const { AddressKeyIndex, DerivationScheme, Bip44AccountPublic, PublicKey, BlockchainSettings, TransactionFinalized, TransactionSignature, Witness, Transaction } = getBindingsForEnvironment()

async function connectToLedger () {
  const transport = await getLedgerTransportForEnvironment().create()
  return new Ledger(transport)
}

export async function LedgerKeyManager (accountIndex = 0, publicKey?: string): Promise<KeyManager> {
  const ledger = await connectToLedger()

  async function deriveBip44Account () {
    if (!publicKey) {
      const { publicKeyHex, chainCodeHex } = await ledger.getExtendedPublicKey([
        utils.HARDENED + 44,
        utils.HARDENED + 1815,
        utils.HARDENED + accountIndex
      ])

      publicKey = `${publicKeyHex}${chainCodeHex}`
    }

    const wasmPublicKey = PublicKey.from_hex(publicKey)
    return Bip44AccountPublic.new(wasmPublicKey, DerivationScheme.v2())
  }

  return {
    signTransaction: async (transaction, rawInputs, _chainSettings = BlockchainSettings.mainnet(), transactionsAsProofForSpending) => {
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
      const bip44AccountPublic = await deriveBip44Account()

      const tx = Transaction.from_json(transactionJson)
      const transactionFinalizer = new TransactionFinalized(tx)

      ledgerSignedTransaction.witnesses.forEach((ledgerWitness: any) => {
        const pubKey = bip44AccountPublic
          .bip44_chain(ledgerWitness.path[3] === 1)
          .address_key(AddressKeyIndex.new(ledgerWitness.path[4]))

        const txSignature = TransactionSignature.from_hex(
          ledgerWitness.witnessSignatureHex
        )

        const witness = Witness.from_external(pubKey, txSignature)
        transactionFinalizer.add_witness(witness)
      })

      return transactionFinalizer.finalize().to_hex()
    },
    signMessage: async () => {
      throw new UnsupportedOperation('Ledger signMessage')
    },
    publicAccount: () => deriveBip44Account()
  }
}
