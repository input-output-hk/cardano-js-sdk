/* eslint-disable sonarjs/no-duplicate-string */
import { AddressType, GroupedAddress, util } from '@cardano-sdk/key-management';
import { KeyAgentFactoryProps, getWallet } from '../../../src';
import { PersonalWallet } from '@cardano-sdk/wallet';
import { createLogger } from '@cardano-sdk/util-dev';
import { createStandaloneKeyAgent, firstValueFromTimed, normalizeTxBody, walletReady } from '../../util';
import { filter, map, take } from 'rxjs';
import { getEnv, walletVariables } from '../../../src/environment';
import { isNotNil } from '@cardano-sdk/util';

const env = getEnv(walletVariables);
const logger = createLogger();
const PAYMENT_ADDRESSES_TO_GENERATE = 60;
const COINS_PER_ADDRESS = 3_000_000n;

describe('PersonalWallet/multiAddress', () => {
  let wallet: PersonalWallet;

  beforeAll(async () => {
    wallet = (await getWallet({ env, idx: 0, logger, name: 'Wallet', polling: { interval: 50 } })).wallet;
  });

  afterAll(() => {
    wallet.shutdown();
  });

  // eslint-disable-next-line max-statements
  it('can discover and spend UTXOs from a multi address wallet', async () => {
    await walletReady(wallet);
    const genesis = await firstValueFromTimed(wallet.genesisParameters$);

    // Create a random set of mnemonics for a brand-new wallet
    const mnemonics = util.generateMnemonicWords();
    const multiAddressKeyAgent = await createStandaloneKeyAgent(
      mnemonics,
      genesis,
      await wallet.keyAgent.getBip32Ed25519()
    );

    let txBuilder = wallet.createTxBuilder();

    let addressesToBeDiscovered = new Array<GroupedAddress>();

    // Let's add the 5 stake keys.
    for (let i = 0; i < 5; ++i) {
      addressesToBeDiscovered.push(
        await multiAddressKeyAgent.deriveAddress(
          {
            index: 0,
            type: AddressType.External
          },
          i
        )
      );
    }

    // Deposit some tADA at some generated addresses from the previously generated mnemonics.
    for (let i = 0; i < PAYMENT_ADDRESSES_TO_GENERATE; ++i) {
      const address = await multiAddressKeyAgent.deriveAddress(
        {
          index: i,
          type: AddressType.External
        },
        0
      );

      addressesToBeDiscovered.push(address);
      txBuilder.addOutput(txBuilder.buildOutput().address(address.address).coin(3_000_000n).toTxOut());
    }

    // Remove duplicates
    addressesToBeDiscovered = [...new Set(addressesToBeDiscovered)];

    const { tx: signedTx } = await txBuilder.build().sign();

    await wallet.submitTx(signedTx);

    // Search chain history to see if the transaction is there.
    const txFoundInHistory = await firstValueFromTimed(
      wallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === signedTx.id)),
        filter(isNotNil),
        take(1)
      )
    );

    expect(txFoundInHistory.id).toEqual(signedTx.id);
    expect(normalizeTxBody(txFoundInHistory.body)).toEqual(normalizeTxBody(signedTx.body));

    // Create a new wallet using the mnemonics previously generated.
    const mnemonicString = mnemonics.join(' ');

    const customKeyParams: KeyAgentFactoryProps = {
      accountIndex: 0,
      chainId: env.KEY_MANAGEMENT_PARAMS.chainId,
      mnemonic: mnemonicString,
      passphrase: 'some_passphrase'
    };

    const newWallet = await getWallet({
      customKeyParams,
      env,
      idx: 0,
      logger,
      name: 'New Multi Address Wallet',
      polling: { interval: 500 }
    });

    await walletReady(newWallet.wallet);
    const walletAddresses = await firstValueFromTimed(newWallet.wallet.addresses$);

    // Let's check if all addresses has been discovered.
    expect(walletAddresses).toEqual(addressesToBeDiscovered);

    const totalBalance = await firstValueFromTimed(newWallet.wallet.balance.utxo.total$);
    const expectedAmount = PAYMENT_ADDRESSES_TO_GENERATE * Number(COINS_PER_ADDRESS);

    expect(Number(totalBalance.coins)).toEqual(expectedAmount);

    // Now lets see if the wallet can spend from all these addresses.
    txBuilder = newWallet.wallet.createTxBuilder();

    const fundingWalletAddresses = await firstValueFromTimed(wallet.addresses$);

    const { tx: returnAdaSignedTx } = await txBuilder
      .addOutput(
        txBuilder
          .buildOutput()
          .address(fundingWalletAddresses[0].address)
          .coin(totalBalance.coins - 1_500_000n) // Let's leave some behind for fees.
          .toTxOut()
      )
      .build()
      .sign();
    await newWallet.wallet.submitTx(returnAdaSignedTx);

    // Search chain history to see if the transaction is there.
    const returnAdaTxFoundInHistory = await firstValueFromTimed(
      newWallet.wallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === returnAdaSignedTx.id)),
        filter(isNotNil),
        take(1)
      )
    );

    expect(returnAdaTxFoundInHistory.id).toEqual(returnAdaSignedTx.id);
    expect(normalizeTxBody(returnAdaTxFoundInHistory.body)).toEqual(normalizeTxBody(returnAdaSignedTx.body));

    const endingBalance = await firstValueFromTimed(newWallet.wallet.balance.utxo.total$);
    const expectedEndingBalance = 1_500_000n - returnAdaTxFoundInHistory.body.fee;

    expect(endingBalance.coins).toEqual(expectedEndingBalance);
  });
});
