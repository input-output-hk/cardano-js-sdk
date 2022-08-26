import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress, SignTransactionOptions, TransactionSigner } from '../types';
import { InputResolver, deepEquals } from '../../services';
import { ownSignatureKeyPaths } from './ownSignatureKeyPaths';
import uniqWith from 'lodash/uniqWith';

const randomHexChar = () => Math.floor(Math.random() * 16).toString(16);
const randomPublicKey = () => Cardano.Ed25519PublicKey(Array.from({ length: 64 }).map(randomHexChar).join(''));

export const stubSignTransaction = async (
  txBody: Cardano.NewTxBodyAlonzo,
  knownAddresses: GroupedAddress[],
  inputResolver: InputResolver,
  extraSigners?: TransactionSigner[],
  { additionalKeyPaths = [] }: SignTransactionOptions = {}
): Promise<Cardano.Signatures> => {
  const mockSignature = Cardano.Ed25519Signature(
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
