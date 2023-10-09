/* eslint-disable sonarjs/no-duplicate-string */
import { AddressType } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { GenericTxBuilder, OutputValidation } from '../../src';
import { StubKeyAgent, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { dummyLogger } from 'ts-log';
import delay from 'delay';

describe('TxBuilder bootstrap', () => {
  it('awaits for non-empty knownAddresses$', async () => {
    // Initialize the TxBuilder
    const output = mocks.utxo[0][1];
    const rewardAccount = mocks.rewardAccount;
    const inputResolver: Cardano.InputResolver = {
      resolveInput: async (txIn) =>
        mocks.utxo.find(
          ([hydratedTxIn]) => txIn.txId === hydratedTxIn.txId && txIn.index === hydratedTxIn.index
        )?.[1] || null
    };
    const keyAgent = new StubKeyAgent(inputResolver);
    const txBuilderProviders = {
      genesisParameters: jest.fn().mockResolvedValue(mocks.genesisParameters),
      protocolParameters: jest.fn().mockResolvedValue(mocks.protocolParameters),
      rewardAccounts: jest.fn().mockResolvedValue([
        {
          address: rewardAccount,
          keyStatus: Cardano.StakeKeyStatus.Unregistered,
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
      inputResolver,
      keyAgent,
      logger: dummyLogger,
      outputValidator,
      txBuilderProviders
    };
    const txBuilder = new GenericTxBuilder(builderParams);

    // Build and sign a tx
    const signedTxReady = txBuilder.addOutput(output).build().sign();
    await delay(1);
    // keyAgent knownAddresses are initially [],
    // but then eventually resolves to some addresses
    // eslint-disable-next-line @typescript-eslint/no-floating-promises
    keyAgent.setKnownAddresses([
      {
        accountIndex: 0,
        address: mocks.utxo[0][1].address,
        index: 0,
        networkId: Cardano.NetworkId.Testnet,
        rewardAccount: mocks.rewardAccount,
        type: AddressType.External
      }
    ]);
    const signedTx = await signedTxReady;
    expect(signedTx.tx.witness.signatures.size).toBe(1);
  });
});
