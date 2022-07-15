import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress } from '../types';
import { InputResolver } from '../../services';
import { ownSignatureKeyPaths } from './ownSignatureKeyPaths';

const randomHexChar = () => Math.floor(Math.random() * 16).toString(16);
const randomPublicKey = () => Cardano.Ed25519PublicKey(Array.from({ length: 64 }).map(randomHexChar).join(''));

export const stubSignTransaction = async (
  txBody: Cardano.NewTxBodyAlonzo,
  knownAddresses: GroupedAddress[],
  inputResolver: InputResolver
): Promise<Cardano.Signatures> =>
  new Map(
    (await ownSignatureKeyPaths(txBody, knownAddresses, inputResolver)).map(() => [
      randomPublicKey(),
      Cardano.Ed25519Signature(
        // eslint-disable-next-line max-len
        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'
      )
    ])
  );
