import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, Serialization, TxCBOR } from '@cardano-sdk/core';
import { GroupedAddress, InMemoryKeyAgent, WitnessedTx, util } from '@cardano-sdk/key-management';
import { HexBlob } from '@cardano-sdk/util';
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
  cbor: TxCBOR.serialize(tx),
  id: tx.id
});

export const toSignedTx = (tx: Cardano.Tx): WitnessedTx => ({
  cbor: TxCBOR.serialize(tx),
  context: {
    handleResolutions: []
  },
  tx
});

export const dummyCbor = TxCBOR('123');

/** Construct a type 6 address for a DRepKey using an appropriate Network Tag and a hash of a public DRep Key. */
export const buildDRepIDFromDRepKey = (
  dRepKey: Crypto.Ed25519PublicKeyHex,
  networkId: Cardano.NetworkId = Cardano.NetworkId.Testnet,
  addressType: Cardano.AddressType = Cardano.AddressType.EnterpriseKey
) => {
  const dRepKeyBytes = Buffer.from(dRepKey, 'hex');
  const dRepIdHex = Crypto.blake2b(28).update(dRepKeyBytes).digest('hex');
  const paymentAddress = Cardano.EnterpriseAddress.packParts({
    networkId,
    paymentPart: {
      hash: Crypto.Hash28ByteBase16(dRepIdHex),
      type: Cardano.CredentialType.KeyHash
    },
    type: addressType
  });
  return HexBlob.toTypedBech32<Cardano.DRepID>('drep', HexBlob.fromBytes(paymentAddress));
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
        bip32Ed25519: new SodiumBip32Ed25519(),
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
