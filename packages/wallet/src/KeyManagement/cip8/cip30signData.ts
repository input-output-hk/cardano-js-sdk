import { AccountKeyDerivationPath } from '..';
import {
  AlgorithmId,
  CBORValue,
  COSEKey,
  KeyType as COSEKeyType,
  COSESign1Builder,
  CurveType,
  HeaderMap,
  Headers,
  Label,
  ProtectedHeaderMap,
  SigStructure
} from '@emurgo/cardano-message-signing-nodejs';
import { Cardano, parseCslAddress, util } from '@cardano-sdk/core';
import { CoseKeyCborHex, CoseSign1CborHex } from './types';
import { CoseLabel } from './util';
import { CustomError } from 'ts-custom-error';
import { KeyAgent, KeyType } from '../types';
import { STAKE_KEY_DERIVATION_PATH } from '../util';

/**
 * DataSignature type as described in CIP-0030.
 */
export interface Cip30DataSignature {
  key: CoseKeyCborHex;
  signature: CoseSign1CborHex;
}

export interface Cip30SignDataRequest {
  keyAgent: KeyAgent;
  signWith: Cardano.Address | Cardano.RewardAccount;
  payload: Cardano.util.HexBlob;
}

export enum Cip30DataSignErrorCode {
  ProofGeneration = 1,
  AddressNotPK = 2,
  UserDeclined = 3
}

export class Cip30DataSignError extends CustomError {
  constructor(
    public readonly code: Cip30DataSignErrorCode,
    public readonly info: string,
    public readonly innerError: unknown = null
  ) {
    super(`DataSignError code: ${code}`);
  }
}

const getAddressBytes = (signWith: Cardano.Address | Cardano.RewardAccount) => {
  const cslAddress = parseCslAddress(signWith.toString());
  if (!cslAddress) {
    throw new Cip30DataSignError(Cip30DataSignErrorCode.AddressNotPK, 'Invalid address');
  }
  return cslAddress.to_bytes();
};

const getDerivationPath = (signWith: Cardano.Address | Cardano.RewardAccount, keyAgent: KeyAgent) => {
  const isRewardAccount = signWith.startsWith('stake');
  if (isRewardAccount) {
    return STAKE_KEY_DERIVATION_PATH;
  }
  const knownAddress = keyAgent.knownAddresses.find(({ address }) => address === signWith);
  if (!knownAddress) {
    throw new Cip30DataSignError(Cip30DataSignErrorCode.ProofGeneration, 'Unknown address');
  }
  return { index: knownAddress.index, type: knownAddress.type as number as KeyType };
};

const createSigStructureHeaders = (addressBytes: Uint8Array) => {
  const protectedHeaders = HeaderMap.new();
  protectedHeaders.set_key_id(addressBytes);
  protectedHeaders.set_header(CoseLabel.address, CBORValue.new_bytes(addressBytes));
  protectedHeaders.set_algorithm_id(Label.from_algorithm_id(AlgorithmId.EdDSA));
  return protectedHeaders;
};

const signSigStructure = (keyAgent: KeyAgent, derivationPath: AccountKeyDerivationPath, sigStructure: SigStructure) => {
  try {
    return keyAgent.signBlob(derivationPath, util.bytesToHex(sigStructure.to_bytes()));
  } catch (error) {
    throw new Cip30DataSignError(Cip30DataSignErrorCode.UserDeclined, 'Failed to sign', error);
  }
};

const createCoseKey = (addressBytes: Uint8Array, publicKey: Cardano.Ed25519PublicKey) => {
  const coseKey = COSEKey.new(Label.from_key_type(COSEKeyType.OKP));
  coseKey.set_key_id(addressBytes);
  coseKey.set_algorithm_id(Label.from_algorithm_id(AlgorithmId.EdDSA));
  coseKey.set_header(CoseLabel.crv, CBORValue.from_label(Label.from_curve_type(CurveType.Ed25519)));
  coseKey.set_header(CoseLabel.x, CBORValue.new_bytes(Buffer.from(publicKey, 'hex')));
  return coseKey;
};

/**
 * Sign data with 1 address.
 * Using CIP-0008 signature structure, with COSE headers/parameters as described in CIP-0030.
 *
 * @throws {Cip30DataSignError}
 */
export const cip30signData = async ({
  keyAgent,
  signWith,
  payload
}: Cip30SignDataRequest): Promise<Cip30DataSignature> => {
  const addressBytes = getAddressBytes(signWith);
  const derivationPath = getDerivationPath(signWith, keyAgent);

  const builder = COSESign1Builder.new(
    Headers.new(ProtectedHeaderMap.new(createSigStructureHeaders(addressBytes)), HeaderMap.new()),
    Buffer.from(payload, 'hex'),
    false
  );
  const sigStructure = builder.make_data_to_sign();
  const { signature, publicKey } = await signSigStructure(keyAgent, derivationPath, sigStructure);
  const coseSign1 = builder.build(Buffer.from(signature, 'hex'));

  const coseKey = createCoseKey(addressBytes, publicKey);

  return {
    key: util.bytesToHex(coseKey.to_bytes()),
    signature: util.bytesToHex(coseSign1.to_bytes())
  };
};
