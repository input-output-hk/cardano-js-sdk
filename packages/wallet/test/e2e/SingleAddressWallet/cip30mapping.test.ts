import * as CSL from '@emurgo/cardano-serialization-lib-nodejs';
import { Cardano, parseCslAddress } from '@cardano-sdk/core';
import { RequestAccess, WalletApi, WalletProperties } from '@cardano-sdk/cip30';
import { SingleAddressWallet } from '../../../src';
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
import cbor from 'cbor';
export const properties: WalletProperties = { apiVersion: '0.1.0', icon: 'imageLink', name: 'testWallet' };

export const requestAccess: RequestAccess = async () => true;

const createTxInternals = async (wallet: SingleAddressWallet) => {
  const outputs = [
    {
      address: Cardano.Address(
        'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
      ),
      value: { coins: 11_111_111n }
    }
  ];
  const txProps = {
    outputs: new Set<Cardano.TxOut>(outputs)
  };
  return await wallet.initializeTx(txProps);
};

describe('cip30 e2e', () => {
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

  it('should correctly pull wallet balance correctly from blockfrost before starting the test', async () => {
    await firstValueFrom(wallet.balance.total$);
    expect(wallet.balance.total$.value?.coins).toBeGreaterThanOrEqual(0n);
  });

  describe('API Methods', () => {
    test('api.getNetworkId', async () => {
      const cip30NetworkId = await mappedWallet.getNetworkId();
      expect(cip30NetworkId).toEqual(Number(process.env.NETWORK_ID));
    });

    test.skip('api.getUtxos', async () => {
      expect(async () => await mappedWallet.getUtxos()).not.toThrow();
    });

    test('api.getBalance', async () => {
      const balanceCborBytes = Buffer.from(await mappedWallet.getBalance(), 'hex');
      expect(() => CSL.Value.from_bytes(balanceCborBytes)).not.toThrow();
    });

    test.skip('api.getUsedAddresses', async () => {
      const cipUsedAddressess = await mappedWallet.getUsedAddresses();
      const [{ address: walletUsedAddresses }] = await firstValueFrom(wallet.addresses$);

      const encodedWallet = CSL.Address.from_bech32(cipUsedAddressess[0]);

      expect(encodedWallet).toEqual(walletUsedAddresses);
    });

    test('api.getUnusedAddresses', async () => {
      const cipUsedAddressess = await mappedWallet.getUnusedAddresses();
      expect(cipUsedAddressess).toEqual([]);
    });

    test('api.getChangeAddress', async () => {
      const cipChangeAddress = await mappedWallet.getChangeAddress();
      const [{ address }] = await firstValueFrom(wallet.addresses$);
      const parsedAddress = parseCslAddress(address as unknown as string);
      if (!parsedAddress) {
        throw new Error('No wallet address');
      }

      expect(cipChangeAddress).toEqual(Buffer.from(parsedAddress.to_bytes()).toString('hex'));
    });

    test('api.getRewardAddresses', async () => {
      const cipRewardAddresses = await mappedWallet.getRewardAddresses();
      const walletRewardAddresses = await wallet.addresses$.value?.filter((s) => s.rewardAccount);

      expect(cipRewardAddresses).toEqual(walletRewardAddresses);
    });

    test('api.signTx', async () => {
      const txInternals = await createTxInternals(wallet);
      expect(await mappedWallet.signTx(cbor.encode(txInternals).toString('hex'))).not.toThrow();
    });

    test('api.signData', async () => {
      const [{ address }] = await firstValueFrom(wallet.addresses$);

      expect(await mappedWallet.signData(address, '')).not.toThrow();
    });

    test('api.submitTx', async () => {
      const txInternals = await createTxInternals(wallet);
      expect(await mappedWallet.submitTx(cbor.encode(txInternals).toString('hex'))).not.toThrow();
    });

    test.todo('errorStates');
  });
});
