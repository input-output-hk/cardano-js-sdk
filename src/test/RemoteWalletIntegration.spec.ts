import { expect, use } from 'chai'
import * as chaiAsPromised from 'chai-as-promised'
import CardanoSDK, { CardanoWalletProvider } from '..'
import { generateMnemonic } from 'bip39'
import { RemotePayment, RemoteUnit } from '../Remote'
import { RequestError } from '../lib'
import { mockProvider } from './utils'
const faker = require('faker')
use(chaiAsPromised)

describe('Example: Interacting with remote wallets', function () {
  this.timeout(20000)
  // The node, wallet and seed are pulled from `Sam-Jeston/cardano-sl-byron`
  const localApiEndpoint = 'http://localhost:8088'

  let cardano: ReturnType<typeof CardanoSDK>
  let connection: ReturnType<typeof cardano.connect>
  const GENERIC_PASSPHRASE = 'Secure Passphrase'
  beforeEach(() => {
    cardano = CardanoSDK()
    connection = cardano.connect(CardanoWalletProvider(localApiEndpoint))
  })

  async function createAndGetNewWallet () {
    const mnemonic = generateMnemonic(256)
    const newWalletName = faker.name.findName()

    await connection.createWallet({ mnemonic, name: newWalletName, passphrase: GENERIC_PASSPHRASE })

    const wallets = await connection.listWallets()
    return wallets.find(w => w.name === newWalletName)
  }

  async function pollTransactionUntilConfirmed (walletId: string, transactionId: string): Promise<void> {
    const transactions = await connection.wallet({ walletId }).transactions()
    const targetTransaction = transactions.find(t => t.id === transactionId)

    if (targetTransaction.status === 'pending') {
      await new Promise(resolve => setTimeout(resolve, 1000))
      return pollTransactionUntilConfirmed(walletId, transactionId)
    }
  }

  describe('connection', () => {
    describe('list wallets', () => {
      it('allows the connection to list existing wallets', async () => {
        const wallets = await connection.listWallets()
        const bobsWallet = wallets[0]
        const alicesWallet = wallets[1]

        expect(bobsWallet.name).to.eql('Bob')
        expect(alicesWallet.name).to.eql('Alice')
      })
    })

    describe('create wallet', () => {
      it('allows the connection to create a new wallet, with only a mnemonic', async () => {
        const newWallet = await createAndGetNewWallet()
        expect(newWallet.balance.total.quantity).to.eql(0)
      })

      it('allows the connection to create a new wallet, with a mnemonic and second factor', async () => {
        const mnemonic = generateMnemonic(256)
        const secondFactor = generateMnemonic(128)
        const newWalletName = faker.name.findName()

        await connection.createWallet({ mnemonic, mnemonicSecondFactor: secondFactor, name: newWalletName, passphrase: 'Secure Passphrase' })

        const wallets = await connection.listWallets()
        const newWallet = wallets.find(w => w.name === newWalletName)
        expect(newWallet.balance.total.quantity).to.eql(0)
      })
    })

    describe('Wallet', () => {
      describe('balance', () => {
        it('exposes a queryable balance for a wallet', async () => {
          const wallets = await connection.listWallets()
          const bobsWalletId = wallets[0].id
          const balance = await connection.wallet({ walletId: bobsWalletId }).balance()
          expect(balance > 0).to.eql(true)
        })
      })

      describe('createAndSignTransaction', () => {
        it('fails to create a transaction for a wallet without funds', async () => {
          const newWallet = await createAndGetNewWallet()

          const mnemonic = generateMnemonic()
          const newParentKey = await cardano.InMemoryKeyManager({ mnemonic, password: 'pw' }).publicParentKey()
          const { address } = await cardano.connect(mockProvider).wallet({ publicParentKey: newParentKey }).getNextReceivingAddress()

          const payment: RemotePayment = {
            address,
            amount: {
              quantity: 1000000,
              unit: RemoteUnit.lovelace
            }
          }

          const failedRequest = connection.wallet({ walletId: newWallet.id }).createAndSignTransaction([payment], GENERIC_PASSPHRASE)
          return expect(failedRequest).to.eventually.be.rejectedWith(RequestError)
        })

        it('creates a transaction for a funded wallet to another wallet', async () => {
          const wallets = await connection.listWallets()
          const bobsWalletId = wallets[0].id
          const alicesWalletId = wallets[1].id

          const alicesNextAddress = await connection.wallet({ walletId: alicesWalletId }).getNextReceivingAddress()

          const payment: RemotePayment = {
            address: alicesNextAddress.address,
            amount: {
              quantity: 1000000,
              unit: RemoteUnit.lovelace
            }
          }

          const res = await connection.wallet({ walletId: bobsWalletId }).createAndSignTransaction([payment], GENERIC_PASSPHRASE)
          const paymentAsOutput = res.outputs.filter(output => output.address === alicesNextAddress.address)
          expect(!!paymentAsOutput).to.eql(true)
        })

        // TODO: This is failing with "code":"rejected_by_core_node"
        // Must be the base58 address or something...
        it.skip('creates a transaction for a funded wallet to an external address', async () => {
          const wallets = await connection.listWallets()
          const bobsWalletId = wallets[0].id

          const mnemonic = generateMnemonic()
          const newParentKey = await cardano.InMemoryKeyManager({ mnemonic, password: 'pw' }).publicParentKey()
          const { address } = await cardano.connect(mockProvider).wallet({ publicParentKey: newParentKey }).getNextReceivingAddress()

          const payment: RemotePayment = {
            address,
            amount: {
              quantity: 1000000,
              unit: RemoteUnit.lovelace
            }
          }

          const res = await connection.wallet({ walletId: bobsWalletId }).createAndSignTransaction([payment], GENERIC_PASSPHRASE)
          console.log(JSON.stringify(res))
        })
      })

      // INFO: Awaiting list transaction implementation in cardano-wallet
      describe.skip('getNextReceivingAddress', () => {
        it('updates the next receiving address after it is used in a transaction', async () => {
          const wallets = await connection.listWallets()
          const bobsWalletId = wallets[0].id
          const alicesWalletId = wallets[1].id

          const alicesInitialNextAddress = await connection.wallet({ walletId: alicesWalletId }).getNextReceivingAddress()

          const payment: RemotePayment = {
            address: alicesInitialNextAddress.address,
            amount: {
              quantity: 1000000,
              unit: RemoteUnit.lovelace
            }
          }

          const tx = await connection.wallet({ walletId: bobsWalletId }).createAndSignTransaction([payment], GENERIC_PASSPHRASE)
          await pollTransactionUntilConfirmed(bobsWalletId, tx.id)
          const alicesNewNextAddress = await connection.wallet({ walletId: alicesWalletId }).getNextReceivingAddress()
          expect(alicesInitialNextAddress.address).to.not.eql(alicesNewNextAddress.address)
        })
      })

      // INFO: Awaiting list transaction implementation in cardano-wallet
      describe.skip('transactions', () => {
        it('lists no stransactions for a new wallet', () => {

        })

        it('lists transactions for a wallet with on-chain history', () => {

        })
      })
    })
  })
})
