import { WalletProvider } from '../../Provider'
import axios from 'axios'

interface Payment {
  address: string
  value: string
}

export function CardanoWalletProvider(uri: string): WalletProvider {
  return {
    wallets: async () => {
      const { data } = await axios.get(`${uri}/v2/wallets`)
      return data
    },
    createWallet: async ({ name, mnemonic, mnemonicSecondFactor, passphrase }: {
      name: string
      mnemonic: string
      mnemonicSecondFactor: string
      passphrase: string
    }) => {
      const { data } = await axios.post(`${uri}/v2/wallets`, {
        name,
        mnemonic_sentence: mnemonic,
        mnemonic_second_factor: mnemonicSecondFactor,
        passphrase
      })

      return data
    },
    transactions: async (walletId: number, startDate?: string, endDate?: string) => {
      const range = startDate && endDate
        ? `inserted-at 20190227T160329Z-*`
        : ``

      const { data } = await axios.get(`${uri}/v2/wallets/${walletId}/transactions`, {
        headers: {
          Range: range
        }
      })

      return data
    },
    createTransaction: async (walletId: number, payments: Payment[], passphrase: string) => {
      const mappedPayments = payments.map(payment => {
        return {
          address: payment.address,
          amount: {
            quantity: Number(payment.value),
            unit: 'lovelace'
          }
        }
      })

      const { data } = await axios.post(`${uri}/v2/wallets/${walletId}/transactions`, {
        payments: mappedPayments,
        passphrase
      })

      return data
    }
  }
}
