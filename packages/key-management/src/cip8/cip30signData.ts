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
  ProtectedHeaderMap
} from '@emurgo/cardano-message-signing-nodejs';
import { Cardano, util } from '@cardano-sdk/core';
import { ComposableError } from '@cardano-sdk/util';
import { CoseLabel } from './util.js';
import { DREP_KEY_DERIVATION_PATH, STAKE_KEY_DERIVATION_PATH } from '../util/index.js';
import type * as Crypto from '@cardano-sdk/crypto';
import type { AccountKeyDerivationPath, GroupedAddress, KeyRole, MessageSender } from '../types.js';
import type { Bip32Ed25519Witnesser } from '../util/index.js';
import type { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import type { HexBlob } from '@cardano-sdk/util';
import type { SigStructure } from '@emurgo/cardano-message-signing-nodejs';

export interface Cip30SignDataRequest {
  knownAddresses: GroupedAddress[];
  witnesser: Bip32Ed25519Witnesser;
  signWith: Cardano.PaymentAddress | Cardano.RewardAccount | Cardano.DRepID;
  payload: HexBlob;
  sender?: MessageSender;
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

const getAddressBytes = (signWith: Cardano.PaymentAddress | Cardano.RewardAccount | Cardano.DRepID) => {
  const address = Cardano.Address.fromString(signWith);

  if (!address) {
    throw new Cip30DataSignError(Cip30DataSignErrorCode.AddressNotPK, 'Invalid address');
  }

  return Buffer.from(address.toBytes(), 'hex');
};

const getDerivationPath = async (
  signWith: Cardano.PaymentAddress | Cardano.RewardAccount | Cardano.DRepID,
  knownAddresses: GroupedAddress[]
) => {
  if (Cardano.DRepID.isValid(signWith)) {
    return DREP_KEY_DERIVATION_PATH;
  }

  const isRewardAccount = signWith.startsWith('stake');

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
  witnesser: Bip32Ed25519Witnesser,
  derivationPath: AccountKeyDerivationPath,
  sigStructure: SigStructure,
  address?: Cardano.PaymentAddress | Cardano.RewardAccount | Cardano.DRepID,
  sender?: MessageSender
) => {
  try {
    const payload = util.bytesToHex(sigStructure.payload());
    return witnesser.signBlob(derivationPath, util.bytesToHex(sigStructure.to_bytes()), { address, payload, sender });
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
  knownAddresses,
  witnesser,
  signWith,
  payload,
  sender
}: Cip30SignDataRequest): Promise<Cip30DataSignature> => {
  if (Cardano.DRepID.isValid(signWith) && !Cardano.DRepID.canSign(signWith)) {
    throw new Cip30DataSignError(Cip30DataSignErrorCode.AddressNotPK, 'Invalid address');
  }
  const addressBytes = getAddressBytes(signWith);
  const derivationPath = await getDerivationPath(signWith, knownAddresses);

  const builder = COSESign1Builder.new(
    Headers.new(ProtectedHeaderMap.new(createSigStructureHeaders(addressBytes)), HeaderMap.new()),
    Buffer.from(payload, 'hex'),
    false
  );
  const sigStructure = builder.make_data_to_sign();
  const { signature, publicKey } = await signSigStructure(witnesser, derivationPath, sigStructure, signWith, sender);
  const coseSign1 = builder.build(Buffer.from(signature, 'hex'));

  const coseKey = createCoseKey(addressBytes, publicKey);

  return {
    key: util.bytesToHex(coseKey.to_bytes()),
    signature: util.bytesToHex(coseSign1.to_bytes())
  };
};
