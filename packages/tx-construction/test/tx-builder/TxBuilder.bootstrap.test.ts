import { AddressType, Bip32Account, InMemoryKeyAgent, util } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { GenericTxBuilder } from '../../src/index.js';
import { SodiumBip32Ed25519 } from '@cardano-sdk/crypto';
import { dummyLogger } from 'ts-log';
import { logger, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { mockTxEvaluator } from './mocks.js';
import type { OutputValidation, TxBuilderProviders } from '../../src/index.js';

describe.each([
  ['TxBuilderGeneric', false],
  ['TxBuilderGeneric - bip32Account', true]
])('%s', (_, useBip32Account) => {
  it('awaits for non-empty knownAddresses', async () => {
    // Initialize the TxBuilder
    const output = mocks.utxo[0][1];
    const rewardAccount = mocks.rewardAccount;
    const knownAddresses = [
      {
        accountIndex: 0,
        address: mocks.utxo[0][1].address,
        index: 0,
        networkId: Cardano.NetworkId.Testnet,
        rewardAccount,
        type: AddressType.External
      }
    ];
    const inputResolver: Cardano.InputResolver = {
      resolveInput: async (txIn) =>
        mocks.utxo.find(
          ([hydratedTxIn]) => txIn.txId === hydratedTxIn.txId && txIn.index === hydratedTxIn.index
        )?.[1] || null
    };
    const keyAgent = util.createAsyncKeyAgent(
      await InMemoryKeyAgent.fromBip39MnemonicWords(
        {
          chainId: Cardano.ChainIds.Preview,
          getPassphrase: async () => Buffer.from([]),
          mnemonicWords: util.generateMnemonicWords()
        },
        { bip32Ed25519: new SodiumBip32Ed25519(), logger }
      )
    );
    const txBuilderProviders: jest.Mocked<TxBuilderProviders> = {
      addresses: {
        add: jest.fn(),
        get: jest.fn().mockResolvedValue(knownAddresses)
      },
      genesisParameters: jest.fn().mockResolvedValue(mocks.genesisParameters),
      protocolParameters: jest.fn().mockResolvedValue(mocks.protocolParameters),
      rewardAccounts: jest.fn().mockResolvedValue([
        {
          address: rewardAccount,
          keyStatus: Cardano.StakeCredentialStatus.Unregistered,
          rewardBalance: mocks.rewardAccountBalance
        }
      ]),
      tip: jest.fn().mockResolvedValue(mocks.ledgerTip),
      utxoAvailable: jest.fn().mockResolvedValue(mocks.utxo)
    };
    const outputValidator = {
      validateOutput: jest.fn().mockResolvedValue({ coinMissing: 0n } as OutputValidation)
    };

    const builderParams = {
      bip32Account: useBip32Account ? await Bip32Account.fromAsyncKeyAgent(keyAgent) : undefined,
      inputResolver,
      logger: dummyLogger,
      outputValidator,
      txBuilderProviders,
      txEvaluator: mockTxEvaluator,
      witnesser: util.createBip32Ed25519Witnesser(keyAgent)
    };
    const txBuilder = new GenericTxBuilder(builderParams);

    // Build and sign a tx
    const signedTxReady = txBuilder.addOutput(output).build().sign();
    const signedTx = await signedTxReady;
    expect(signedTx.tx.witness.signatures.size).toBe(1);
  });
});
