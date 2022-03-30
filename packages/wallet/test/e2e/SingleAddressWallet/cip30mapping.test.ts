import * as CSL from '@emurgo/cardano-serialization-lib-nodejs';
import { Cardano, coreToCsl, parseCslAddress } from '@cardano-sdk/core';
import { InitializeTxResult, SingleAddressWallet } from '../../../src';
import { RequestAccess, WalletApi, WalletProperties } from '@cardano-sdk/cip30';
import {
  assetProvider,
  keyAgentReady,
  stakePoolSearchProvider,
  timeSettingsProvider,
  txSubmitProvider,
  walletProvider
} from '../config'; // or wasm, or load dynamically in beforeAll
import { createCip30WalletApiFromWallet } from '../../../src/util';
import { firstValueFrom } from 'rxjs';
export const properties: WalletProperties = { apiVersion: '0.1.0', icon: 'imageLink', name: 'testWallet' };

export const requestAccess: RequestAccess = async () => true;

const createTxInternals = async (wallet: SingleAddressWallet): Promise<InitializeTxResult> => {
  const outputs = [
    {
      address: Cardano.Address(
        'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
      ),
      value: { coins: 1_111_111n }
    }
  ];
  const txProps = {
    outputs: new Set<Cardano.TxOut>(outputs)
  };
  return await wallet.initializeTx(txProps);
};

describe.skip('cip30 e2e', () => {
  let wallet: SingleAddressWallet;
  let mappedWallet: WalletApi;

  beforeAll(async () => {
    // CREATE A WALLET
    const keyAgent = await keyAgentReady;
    wallet = new SingleAddressWallet(
      { name: 'Test Wallet' },
      {
        assetProvider,
        keyAgent,
        stakePoolSearchProvider,
        timeSettingsProvider,
        txSubmitProvider,
        walletProvider
      }
    );

    mappedWallet = createCip30WalletApiFromWallet(wallet, {
      keyAgent,
      logger: console
    });
  });

  afterAll(() => {
    wallet.shutdown();
  });

  it('should correctly pull wallet balance correctly from the provider before starting the test', async () => {
    await firstValueFrom(wallet.balance.total$);
    expect(wallet.balance.total$.value?.coins).toBeGreaterThanOrEqual(0n);
  });

  describe('API Methods', () => {
    test('api.getNetworkId', async () => {
      const cip30NetworkId = await mappedWallet.getNetworkId();
      expect(cip30NetworkId).toEqual(Number(process.env.NETWORK_ID));
    });

    test('api.getUtxos', async () => {
      const utxos = await mappedWallet.getUtxos();
      expect(() => coreToCsl.utxo(utxos!)).not.toThrow();
    });

    test('api.getBalance', async () => {
      const balanceCborBytes = Buffer.from(await mappedWallet.getBalance(), 'hex');
      expect(() => CSL.Value.from_bytes(balanceCborBytes)).not.toThrow();
    });

    test('api.getUsedAddresses', async () => {
      const cipUsedAddressess = await mappedWallet.getUsedAddresses();
      const [{ address: walletUsedAddresses }] = await firstValueFrom(wallet.addresses$);
      const parsedAddress = parseCslAddress(walletUsedAddresses.toString());

      expect(cipUsedAddressess).toEqual([Buffer.from(parsedAddress!.to_bytes()).toString('hex')]);
    });

    test('api.getUnusedAddresses', async () => {
      const cipUsedAddressess = await mappedWallet.getUnusedAddresses();
      expect(cipUsedAddressess).toEqual([]);
    });

    test('api.getChangeAddress', async () => {
      const cipChangeAddress = await mappedWallet.getChangeAddress();
      const [{ address }] = await firstValueFrom(wallet.addresses$);
      const parsedAddress = parseCslAddress(address.toString());

      expect(cipChangeAddress).toEqual(Buffer.from(parsedAddress!.to_bytes()).toString('hex'));
    });

    test('api.getRewardAddresses', async () => {
      const cipRewardAddresses = await mappedWallet.getRewardAddresses();
      const [{ rewardAccount }] = await firstValueFrom(wallet.addresses$);
      const parsedAddress = parseCslAddress(rewardAccount.toString());

      expect(cipRewardAddresses).toEqual([Buffer.from(parsedAddress!.to_bytes()).toString('hex')]);
    });

    test('api.signTx', async () => {
      const txInternals = await createTxInternals(wallet);
      const finalizedTx = await wallet.finalizeTx(txInternals);

      const cslTx = coreToCsl.tx(finalizedTx).to_bytes();

      const signatures = Buffer.from(await mappedWallet.signTx(Buffer.from(cslTx).toString('hex')), 'hex');
      expect(() => CSL.TransactionWitnessSet.from_bytes(signatures)).not.toThrow();
    });

    test('api.signData', async () => {
      const [{ address }] = await firstValueFrom(wallet.addresses$);

      expect(async () => await mappedWallet.signData(address, Cardano.util.HexBlob('abc123').toString())).not.toThrow();
    });

    test('api.submitTx', async () => {
      const txInternals = await createTxInternals(wallet);
      const finalizedTx = await wallet.finalizeTx(txInternals);

      const cslTx = coreToCsl.tx(finalizedTx).to_bytes();
      expect(async () => await mappedWallet.submitTx(Buffer.from(cslTx).toString('hex'))).not.toThrow();
    });

    test.todo('errorStates');
  });
});
