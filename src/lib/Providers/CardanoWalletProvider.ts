import { WalletProvider } from '../../Provider'
import axios from 'axios'
import { RemotePayment, RemoteTransaction, RemoteWallet } from '../../Remote'

export function CardanoWalletProvider (uri: string): WalletProvider {
  return {
    wallets: async () => {
      const { data } = await axios.get(`${uri}/v2/wallets`)
      return data as RemoteWallet[]
    },
    createWallet: async ({ name, mnemonic, mnemonicSecondFactor, passphrase }: {
      name: string
      mnemonic: string
      mnemonicSecondFactor?: string
      passphrase: string
    }) => {
      const { data } = await axios.post(`${uri}/v2/wallets`, {
        name,
        mnemonic_sentence: mnemonic,
        mnemonic_second_factor: mnemonicSecondFactor,
        passphrase
      })

      return data as RemoteWallet
    },
    getWallet: async (walletId: string) => {
      const { data } = await axios.get(`${uri}/v2/wallets/${walletId}`)
      return data as RemoteWallet
    },
    transactions: async (walletId: string, startDate?: string, endDate?: string) => {
      const range = startDate && endDate
        ? `inserted-at 20190227T160329Z-*`
        : ``

      const { data } = await axios.get(`${uri}/v2/wallets/${walletId}/transactions`, {
        headers: {
          Range: range
        }
      })

      return data as RemoteTransaction[]
    },
    createTransaction: async (walletId: string, payments: RemotePayment[], passphrase: string) => {
      const { data } = await axios.post(`${uri}/v2/wallets/${walletId}/transactions`, {
        payments,
        passphrase
      })

      return data
    }
  }
}
