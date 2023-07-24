/* eslint-disable sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, AsyncKeyAgent, GroupedAddress, SignBlobResult, util } from '@cardano-sdk/key-management';
import { BehaviorSubject, firstValueFrom } from 'rxjs';
import { Cardano } from '@cardano-sdk/core';
import { GenericTxBuilder, OutputValidation } from '../../src';
import { dummyLogger } from 'ts-log';
import { generateRandomHexString, mockProviders as mocks } from '@cardano-sdk/util-dev';
import delay from 'delay';

class StubKeyAgent implements AsyncKeyAgent {
  knownAddresses$ = new BehaviorSubject<GroupedAddress[]>([]);

  constructor(private inputResolver: Cardano.InputResolver) {}

  deriveAddress(): Promise<GroupedAddress> {
    throw new Error('Method not implemented.');
  }
  derivePublicKey(): Promise<Crypto.Ed25519PublicKeyHex> {
    throw new Error('Method not implemented.');
  }
  signBlob(): Promise<SignBlobResult> {
    throw new Error('Method not implemented.');
  }
  async signTransaction(txInternals: Cardano.TxBodyWithHash): Promise<Cardano.Signatures> {
    const signatures = new Map<Crypto.Ed25519PublicKeyHex, Crypto.Ed25519SignatureHex>();
    const knownAddresses = await firstValueFrom(this.knownAddresses$);
    for (const _ of await util.ownSignatureKeyPaths(txInternals.body, knownAddresses, this.inputResolver)) {
      signatures.set(
        Crypto.Ed25519PublicKeyHex(generateRandomHexString(64)),
        Crypto.Ed25519SignatureHex(generateRandomHexString(128))
      );
    }
    return signatures;
  }
  getChainId(): Promise<Cardano.ChainId> {
    throw new Error('Method not implemented.');
  }
  getBip32Ed25519(): Promise<Crypto.Bip32Ed25519> {
    throw new Error('Method not implemented.');
  }
  getExtendedAccountPublicKey(): Promise<Crypto.Bip32PublicKeyHex> {
    throw new Error('Method not implemented.');
  }
  async setKnownAddresses(addresses: GroupedAddress[]): Promise<void> {
    this.knownAddresses$.next(addresses);
  }
  shutdown(): void {
    throw new Error('Method not implemented.');
  }
}

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
