import { WalletProvider } from '../../Provider'
import { AxiosWrapper, RequestMethod } from '../RequestHandler'
import { RemotePayment, RemoteTransaction, RemoteWallet } from '../../Remote'

export function CardanoWalletProvider(uri: string, isSocket = false): WalletProvider {
  const requesterHandler = AxiosWrapper(uri, isSocket)

  return {
    wallets: () => {
      return requesterHandler({ path: `v2/wallets`, method: RequestMethod.GET }) as Promise<RemoteWallet[]>
    },
    createWallet: ({ name, mnemonic, mnemonicSecondFactor, passphrase }: {
      name: string
      mnemonic: string
      mnemonicSecondFactor?: string
      passphrase: string
    }) => {
      const mnemonicAsList = mnemonic.split(' ')
      const mnemonicSecondFactorAsList = mnemonicSecondFactor ? mnemonicSecondFactor.split(' ') : []
      const body = {
        name,
        mnemonic_sentence: mnemonicAsList,
        passphrase
      }

      return requesterHandler({
        path: '/v2/wallets',
        method: RequestMethod.POST,
        body: mnemonicSecondFactorAsList.length
          ? { mnemonic_second_factor: mnemonicSecondFactorAsList, ...body }
          : body
      }) as Promise<RemoteWallet>
    },
    getWallet: (walletId: string) => {
      return requesterHandler({ path: `/v2/wallets/${walletId}`, method: RequestMethod.GET }) as Promise<RemoteWallet>
    },
    transactions: async (walletId: string, startDate?: Date, endDate?: Date) => {
      const range = startDate && endDate
        ? `inserted-at ${startDate.toISOString()}-${endDate.toISOString()}`
        : `inserted-at *-*`

      return requesterHandler({
        path: `/v2/wallets/${walletId}/transactions`,
        method: RequestMethod.GET,
        headers: {
          Range: range
        }
      }) as Promise<RemoteTransaction[]>
    },
    createTransaction: async (walletId: string, payments: RemotePayment[], passphrase: string) => {
      return requesterHandler({
        path: `/v2/wallets/${walletId}/transactions`,
        method: RequestMethod.POST,
        body: {
          payments,
          passphrase
        }
      }) as Promise<RemoteTransaction>
    }
  }
}
