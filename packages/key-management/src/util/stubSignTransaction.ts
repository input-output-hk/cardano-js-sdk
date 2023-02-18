import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress, SignTransactionOptions, TransactionSigner } from '../types';
import { deepEquals } from '@cardano-sdk/util';
import { ownSignatureKeyPaths } from './ownSignatureKeyPaths';

import uniqWith from 'lodash/uniqWith';

const randomHexChar = () => Math.floor(Math.random() * 16).toString(16);
const randomPublicKey = () => Crypto.Ed25519PublicKeyHex(Array.from({ length: 64 }).map(randomHexChar).join(''));

export const stubSignTransaction = async (
  txBody: Cardano.TxBody,
  knownAddresses: GroupedAddress[],
  inputResolver: Cardano.InputResolver,
  extraSigners?: TransactionSigner[],
  { additionalKeyPaths = [] }: SignTransactionOptions = {}
): Promise<Cardano.Signatures> => {
  const mockSignature = Crypto.Ed25519SignatureHex(
    // eslint-disable-next-line max-len
    'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'
  );
  const signatureKeyPaths = uniqWith(
    [...(await ownSignatureKeyPaths(txBody, knownAddresses, inputResolver)), ...additionalKeyPaths],
    deepEquals
  );

  const totalSignature = signatureKeyPaths.length + (extraSigners?.length || 0);
  const signatureMap = new Map();

  for (let i = 0; i < totalSignature; ++i) signatureMap.set(randomPublicKey(), mockSignature);

  return signatureMap;
};
