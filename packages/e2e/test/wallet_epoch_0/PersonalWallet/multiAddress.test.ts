/* eslint-disable sonarjs/no-duplicate-string */
import { AddressType, GroupedAddress, util } from '@cardano-sdk/key-management';
import { BaseWallet } from '@cardano-sdk/wallet';
import { Cardano } from '@cardano-sdk/core';
import {
  KeyAgentFactoryProps,
  bip32Ed25519Factory,
  createStandaloneKeyAgent,
  firstValueFromTimed,
  getWallet,
  normalizeTxBody,
  walletReady
} from '../../../src';
import { createLogger } from '@cardano-sdk/util-dev';
import { filter, map, take } from 'rxjs';
import { getEnv, walletVariables } from '../../../src/environment';
import { isNotNil } from '@cardano-sdk/util';

const env = getEnv(walletVariables);
const logger = createLogger();
const PAYMENT_INDICES_TO_GENERATE = 30;
const PAYMENT_ADDRESSES_TO_GENERATE = PAYMENT_INDICES_TO_GENERATE * 2; // External + Internal address for each payment derivation index
const COINS_PER_ADDRESS = 3_000_000n;

describe('PersonalWallet/multiAddress', () => {
  let wallet: BaseWallet;

  beforeAll(async () => {
    wallet = (await getWallet({ env, idx: 0, logger, name: 'Wallet' })).wallet;
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
      await bip32Ed25519Factory.create(env.KEY_MANAGEMENT_PARAMS.bip32Ed25519, null, logger)
    );

    let txBuilder = wallet.createTxBuilder();

    const addressesToBeDiscovered = new Array<GroupedAddress>();

    // Deposit some tADA at some generated addresses from the previously generated mnemonics.
    for (let i = 0; i < PAYMENT_INDICES_TO_GENERATE; ++i) {
      const [addressExternal, addressInternal] = await Promise.all([
        multiAddressKeyAgent.deriveAddress(
          {
            index: i,
            type: AddressType.External
          },
          0
        ),
        multiAddressKeyAgent.deriveAddress(
          {
            index: i,
            type: AddressType.Internal
          },
          0
        )
      ]);

      addressesToBeDiscovered.push(addressExternal, addressInternal);

      txBuilder.addOutput(txBuilder.buildOutput().address(addressExternal.address).coin(3_000_000n).toTxOut());
      txBuilder.addOutput(txBuilder.buildOutput().address(addressInternal.address).coin(3_000_000n).toTxOut());
    }

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
    const rewardAddresses = await firstValueFromTimed(newWallet.wallet.delegation.rewardAccounts$);

    // Let's check if all addresses has been discovered.
    expect(walletAddresses).toEqual(addressesToBeDiscovered);

    // All addresses are built using the same stake key. Check that there is a single reward account
    const expectedRewardAccount = walletAddresses[0].rewardAccount;
    expect(rewardAddresses).toEqual([
      expect.objectContaining<Partial<Cardano.RewardAccountInfo>>({ address: expectedRewardAccount })
    ]);

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
