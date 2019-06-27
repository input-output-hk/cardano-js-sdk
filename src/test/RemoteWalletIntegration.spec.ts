import { expect } from 'chai'
import CardanoSDK, { CardanoWalletProvider } from '..'
import { generateMnemonic } from 'bip39';
const faker = require('faker')

describe.only('Example: Interacting with remote wallets', () => {
  // The wallet details are pulled from `Sam-Jeston/cardano-sl-byron`
  // as we use this as the node to test against
  // const walletsReferences = {
  //   Bob: {
  //     spendingPassphrase: 'Secure Passphrase',
  //     mnemonic: 'win magic exhibit there dirt unable choose squeeze forum cup blouse grab arctic enough real'
  //   },
  //   Alice: {
  //     spendingPassphrase: 'Secure Passphrase',
  //     mnemonic: 'impulse return veteran bone mom filter act risk help actual lecture tag below wall diesel'
  //   }
  // }

  const localApiEndpoint = 'http://localhost:8080'

  let cardano: ReturnType<typeof CardanoSDK>
  let connection: ReturnType<typeof cardano.connect>
  beforeEach(() => {
    cardano = CardanoSDK()
    connection = cardano.connect(CardanoWalletProvider(localApiEndpoint))
  })

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
        const mnemonic = generateMnemonic(256)
        const newWalletName = faker.name.findName()

        await connection.createWallet({ mnemonic, name: newWalletName, passphrase: 'Secure Passphrase' })

        const wallets = await connection.listWallets()
        const newWallet = wallets.find(w => w.name === newWalletName)
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
        // it - Fails for account with no funds
        // it - Works for funds
      })

      describe('getNextReceivingAddress', () => {
        // it - No txs for a new account
        // it - Has tx after tx created
      })

      describe('getNextReceivingAddress', () => {
        // it - gets an address for a new account
        // it - address changes after tx submitted
      })
    })
  })
})
