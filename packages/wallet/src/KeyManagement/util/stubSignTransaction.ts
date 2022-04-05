import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress, InputAddressResolver } from '../types';
import { ownSignatureKeyPaths } from './ownSignatureKeyPaths';

const randomHexChar = () => Math.floor(Math.random() * 16).toString(16);
const randomPublicKey = () => Cardano.Ed25519PublicKey(Array.from({ length: 64 }).map(randomHexChar).join(''));

export const stubSignTransaction = (
  txBody: Cardano.NewTxBodyAlonzo,
  knownAddresses: GroupedAddress[],
  inputAddressResolver: InputAddressResolver
): Cardano.Signatures =>
  new Map(
    ownSignatureKeyPaths(txBody, knownAddresses, inputAddressResolver).map(() => [
      randomPublicKey(),
      Cardano.Ed25519Signature(
        // eslint-disable-next-line max-len
        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'
      )
    ])
  );
