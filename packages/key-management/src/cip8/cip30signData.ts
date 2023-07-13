import * as Crypto from '@cardano-sdk/crypto';
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
import { AsyncKeyAgent, KeyRole } from '../types';
import { Cardano, util } from '@cardano-sdk/core';
import { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import { ComposableError, HexBlob } from '@cardano-sdk/util';
import { CoseLabel } from './util';
import { STAKE_KEY_DERIVATION_PATH } from '../util';
import { filter, firstValueFrom } from 'rxjs';

export interface Cip30SignDataRequest {
  keyAgent: AsyncKeyAgent;
  signWith: Cardano.PaymentAddress | Cardano.RewardAccount;
  payload: HexBlob;
}

export enum Cip30DataSignErrorCode {
  ProofGeneration = 1,
  AddressNotPK = 2,
  UserDeclined = 3
}

export class Cip30DataSignError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(public readonly code: Cip30DataSignErrorCode, public readonly info: string, innerError?: InnerError) {
    super(`DataSignError code: ${code}`, innerError);
  }
}

const getAddressBytes = (signWith: Cardano.PaymentAddress | Cardano.RewardAccount) => {
  const address = Cardano.Address.fromString(signWith);

  if (!address) {
    throw new Cip30DataSignError(Cip30DataSignErrorCode.AddressNotPK, 'Invalid address');
  }

  return Buffer.from(address.toBytes(), 'hex');
};

const getDerivationPath = async (signWith: Cardano.PaymentAddress | Cardano.RewardAccount, keyAgent: AsyncKeyAgent) => {
  const isRewardAccount = signWith.startsWith('stake');

  const knownAddresses = await firstValueFrom(
    keyAgent.knownAddresses$.pipe(filter((addresses) => addresses.length > 0))
  );

  if (isRewardAccount) {
    const knownRewardAddress = knownAddresses.find(({ rewardAccount }) => rewardAccount === signWith);

    if (!knownRewardAddress)
      throw new Cip30DataSignError(Cip30DataSignErrorCode.ProofGeneration, 'Unknown reward address');

    return knownRewardAddress.stakeKeyDerivationPath || STAKE_KEY_DERIVATION_PATH;
  }

  const knownAddress = knownAddresses.find(({ address }) => address === signWith);

  if (!knownAddress) {
    throw new Cip30DataSignError(Cip30DataSignErrorCode.ProofGeneration, 'Unknown address');
  }

  return { index: knownAddress.index, role: knownAddress.type as number as KeyRole };
};

const createSigStructureHeaders = (addressBytes: Uint8Array) => {
  const protectedHeaders = HeaderMap.new();
  protectedHeaders.set_key_id(addressBytes);
  protectedHeaders.set_header(CoseLabel.address, CBORValue.new_bytes(addressBytes));
  protectedHeaders.set_algorithm_id(Label.from_algorithm_id(AlgorithmId.EdDSA));
  return protectedHeaders;
};

const signSigStructure = (
  keyAgent: AsyncKeyAgent,
  derivationPath: AccountKeyDerivationPath,
  sigStructure: SigStructure
) => {
  try {
    return keyAgent.signBlob(derivationPath, util.bytesToHex(sigStructure.to_bytes()));
  } catch (error) {
    throw new Cip30DataSignError(Cip30DataSignErrorCode.UserDeclined, 'Failed to sign', error);
  }
};

const createCoseKey = (addressBytes: Uint8Array, publicKey: Crypto.Ed25519PublicKeyHex) => {
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
  const derivationPath = await getDerivationPath(signWith, keyAgent);

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
