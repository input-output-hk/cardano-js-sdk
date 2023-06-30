/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, coreToCml } from '@cardano-sdk/core';
import { CreateTrezorKeyAgentProps } from '@cardano-sdk/key-management/dist/cjs/TrezorKeyAgent';
import { TrezorKeyAgent as DeprecatedTrezorKeyAgent, KeyAgentDependencies, errors } from '@cardano-sdk/key-management';
import { ManagedFreeableScope } from '@cardano-sdk/util';
import { txToTrezor } from './transformers/tx';
import TrezorConnect from 'trezor-connect';

const transportTypedError = (error?: any) =>
  new errors.AuthenticationError(
    'Trezor transport failed',
    new errors.TransportError('Trezor transport failed', error)
  );

export class TrezorKeyAgent extends DeprecatedTrezorKeyAgent {
  async signTransaction(tx: Cardano.TxBodyWithHash): Promise<Cardano.Signatures> {
    const scope = new ManagedFreeableScope();
    try {
      await this.isTrezorInitialized;
      const cslTxBody = coreToCml.txBody(scope, tx.body);
      const trezorTxData = await txToTrezor({
        accountIndex: this.accountIndex,
        cardanoTxBody: tx.body,
        chainId: this.chainId,
        cslTxBody,
        inputResolver: this.inputResolver,
        knownAddresses: this.knownAddresses
      });

      const result = await TrezorConnect.cardanoSignTransaction(trezorTxData);
      if (!result.success) {
        throw new errors.TransportError('Failed to export extended account public key', result.payload);
      }

      const signedData = result.payload;
      return new Map<Crypto.Ed25519PublicKeyHex, Crypto.Ed25519SignatureHex>(
        await Promise.all(
          signedData.witnesses.map(async (witness) => {
            const publicKey = Crypto.Ed25519PublicKeyHex(witness.pubKey);
            const signature = Crypto.Ed25519SignatureHex(witness.signature);
            return [publicKey, signature] as const;
          })
        )
      );
    } catch (error: any) {
      if (error.innerError.code === 'Failure_ActionCancelled') {
        throw new errors.AuthenticationError('Transaction signing aborted', error);
      }
      throw transportTypedError(error);
    } finally {
      scope.dispose();
    }
  }

  /**
   * @throws AuthenticationError
   */
  static async createWithDevice(
    { chainId, accountIndex = 0, trezorConfig }: CreateTrezorKeyAgentProps,
    dependencies: KeyAgentDependencies
  ) {
    const isTrezorInitialized = await TrezorKeyAgent.initializeTrezorTransport(trezorConfig);
    const extendedAccountPublicKey = await TrezorKeyAgent.getXpub({ accountIndex });
    return new TrezorKeyAgent(
      {
        accountIndex,
        chainId,
        extendedAccountPublicKey,
        isTrezorInitialized,
        knownAddresses: [],
        trezorConfig
      },
      dependencies
    );
  }
}
