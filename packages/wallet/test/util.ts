import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { GroupedAddress, InMemoryKeyAgent, WitnessedTx, util } from '@cardano-sdk/key-management';
import { Observable, catchError, filter, firstValueFrom, throwError, timeout } from 'rxjs';
import { ObservableWallet, OutgoingTx, WalletUtil } from '../src';
import { SodiumBip32Ed25519 } from '@cardano-sdk/crypto';
import { logger } from '@cardano-sdk/util-dev';
import { testAsyncKeyAgent } from '../../key-management/test/mocks';

const SECOND = 1000;
const MINUTE = 60 * SECOND;
export const TX_TIMEOUT = 7 * MINUTE;
const SYNC_TIMEOUT = 3 * MINUTE;
export const FAST_OPERATION_TIMEOUT = 15 * SECOND;

export const firstValueFromTimed = <T>(
  observable$: Observable<T>,
  timeoutMessage = 'Timed out',
  timeoutAfter = FAST_OPERATION_TIMEOUT
) =>
  firstValueFrom(
    observable$.pipe(
      timeout(timeoutAfter),
      catchError(() => throwError(() => new Error(timeoutMessage)))
    )
  );

export const waitForWalletStateSettle = (wallet: ObservableWallet) =>
  firstValueFromTimed(
    wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)),
    'Took too long to load',
    SYNC_TIMEOUT
  );

export const toOutgoingTx = (tx: Cardano.Tx): OutgoingTx => ({
  body: { ...tx.body },
  cbor: Serialization.TxCBOR.serialize(tx),
  id: tx.id
});

export const toSignedTx = (tx: Cardano.Tx): WitnessedTx => ({
  cbor: Serialization.TxCBOR.serialize(tx),
  context: {
    handleResolutions: []
  },
  tx
});

export const dummyCbor = Serialization.TxCBOR('123');

/**
 * Construct a type 6 or 7 address for a DRepKey using a hash of a public DRep Key.
 *
 * @param dRepKey The public DRep key to hash and use in the address
 * @param type The type of credential to use in the address.
 * @returns A a type 6 address for keyHash credential type, or a type 7 address for script credential type.
 */
export const buildDRepAddressFromDRepKey = async (
  dRepKey: Crypto.Ed25519PublicKeyHex,
  type: Cardano.CredentialType = Cardano.CredentialType.KeyHash
) => {
  const drepKeyHash = Crypto.Ed25519PublicKey.fromHex(dRepKey).hash().hex();
  const drepId = Cardano.DRepID.cip129FromCredential({
    hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(drepKeyHash),
    type
  });
  return Cardano.DRepID.toAddress(drepId);
};

export const createAsyncKeyAgent = async () =>
  util.createAsyncKeyAgent(
    await InMemoryKeyAgent.fromBip39MnemonicWords(
      {
        chainId: Cardano.ChainIds.Preview,
        getPassphrase: async () => Buffer.from([]),
        mnemonicWords: util.generateMnemonicWords()
      },
      {
        bip32Ed25519: await SodiumBip32Ed25519.create(),
        logger
      }
    )
  );

export const signTx = async ({
  tx,
  addresses$,
  walletUtil
}: {
  tx: Cardano.TxBodyWithHash;
  addresses$: Observable<GroupedAddress[]>;
  walletUtil: WalletUtil;
}): Promise<Cardano.Tx> => {
  const keyAgent = await testAsyncKeyAgent();
  const knownAddresses = await firstValueFrom(addresses$);
  const witnesser = util.createBip32Ed25519Witnesser(keyAgent);

  const signed = await witnesser.witness(
    new Serialization.Transaction(
      Serialization.TransactionBody.fromCore(tx.body),
      Serialization.TransactionWitnessSet.fromCore({ signatures: new Map() })
    ),
    {
      knownAddresses,
      txInKeyPathMap: await util.createTxInKeyPathMap(tx.body, knownAddresses, walletUtil)
    }
  );

  return signed.tx;
};
