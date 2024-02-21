import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { SignTransactionContext, SignTransactionOptions, TransactionSigner } from '../types';
import { deepEquals } from '@cardano-sdk/util';
import { ownSignatureKeyPaths } from './ownSignatureKeyPaths';

import uniqWith from 'lodash/uniqWith';

const randomHexChar = () => Math.floor(Math.random() * 16).toString(16);
const randomPublicKey = () => Crypto.Ed25519PublicKeyHex(Array.from({ length: 64 }).map(randomHexChar).join(''));

export interface StubSignTransactionProps {
  txBody: Cardano.TxBody;
  extraSigners?: TransactionSigner[];
  dRepPublicKey?: Crypto.Ed25519PublicKeyHex;
  context: SignTransactionContext;
  signTransactionOptions?: SignTransactionOptions;
}

export const stubSignTransaction = async ({
  txBody,
  extraSigners,
  dRepPublicKey,
  context: { knownAddresses, txInKeyPathMap },
  signTransactionOptions: { additionalKeyPaths = [] } = {}
}: StubSignTransactionProps): Promise<Cardano.Signatures> => {
  const mockSignature = Crypto.Ed25519SignatureHex(
    // eslint-disable-next-line max-len
    'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'
  );
  const dRepKeyHash = dRepPublicKey ? (await Crypto.Ed25519PublicKey.fromHex(dRepPublicKey).hash()).hex() : undefined;
  const signatureKeyPaths = uniqWith(
    [...ownSignatureKeyPaths(txBody, knownAddresses, txInKeyPathMap, dRepKeyHash), ...additionalKeyPaths],
    deepEquals
  );

  const totalSignature = signatureKeyPaths.length + (extraSigners?.length || 0);
  const signatureMap = new Map();

  for (let i = 0; i < totalSignature; ++i) signatureMap.set(randomPublicKey(), mockSignature);

  return signatureMap;
};
