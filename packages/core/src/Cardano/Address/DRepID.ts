import * as BaseEncoding from '@scure/base';
import { Address, AddressType, Credential, CredentialType } from './Address';
import { EnterpriseAddress } from './EnterpriseAddress';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { OpaqueString, typedBech32 } from '@cardano-sdk/util';

const MAX_BECH32_LENGTH_LIMIT = 1023;
const CIP_105_DREP_ID_LENGTH = 28;
const CIP_129_DREP_ID_LENGTH = 29;

/** DRepID as bech32 string */
export type DRepID = OpaqueString<'DRepID'>;

// CIP-105 is deprecated, however we still need to support it since several providers and tooling
// stills uses this format.
export const DRepID = (value: string): DRepID => {
  try {
    return typedBech32(value, ['drep'], 47);
  } catch {
    return typedBech32(value, ['drep', 'drep_script'], 45);
  }
};

DRepID.isValid = (value: string): boolean => {
  try {
    DRepID(value);
    return true;
  } catch {
    return false;
  }
};

DRepID.cip105FromCredential = (credential: Credential): DRepID => {
  let prefix = 'drep';
  if (credential.type === CredentialType.ScriptHash) {
    prefix = 'drep_script';
  }

  const words = BaseEncoding.bech32.toWords(Buffer.from(credential.hash, 'hex'));

  return BaseEncoding.bech32.encode(prefix, words, MAX_BECH32_LENGTH_LIMIT) as DRepID;
};

DRepID.cip129FromCredential = (credential: Credential): DRepID => {
  // The CIP-129 header is defined by 2 nibbles, where the first 4 bits represent the kind of governance credential
  // (CC Hot, CC Cold and DRep), and the last 4 bits are the credential type (offset by 2 to ensure that governance
  // identifiers remain distinct and are not inadvertently processed as addresses).
  let header = '22'; // DRep-PubKeyHash header in hex [00100010]
  if (credential.type === CredentialType.ScriptHash) {
    header = '23'; // DRep-ScriptHash header in hex [00100011]
  }

  const cip129payload = `${header}${credential.hash}`;
  const words = BaseEncoding.bech32.toWords(Buffer.from(cip129payload, 'hex'));

  return BaseEncoding.bech32.encode('drep', words, MAX_BECH32_LENGTH_LIMIT) as DRepID;
};

DRepID.toCredential = (drepId: DRepID): Credential => {
  const { words } = BaseEncoding.bech32.decode(drepId, MAX_BECH32_LENGTH_LIMIT);
  const payload = BaseEncoding.bech32.fromWords(words);

  if (payload.length !== CIP_105_DREP_ID_LENGTH && payload.length !== CIP_129_DREP_ID_LENGTH) {
    throw new Error('Invalid DRepID payload');
  }

  if (payload.length === CIP_105_DREP_ID_LENGTH) {
    const isScriptHash = drepId.includes('drep_script');

    return {
      hash: Hash28ByteBase16(Buffer.from(payload).toString('hex')),
      type: isScriptHash ? CredentialType.ScriptHash : CredentialType.KeyHash
    };
  }

  // CIP-129
  const header = payload[0];
  const hash = payload.slice(1);
  const isDrepGovCred = (header & 0x20) === 0x20; // 0b00100000
  const isScriptHash = (header & 0x03) === 0x03; // 0b00000011

  if (!isDrepGovCred) {
    throw new Error('Invalid governance credential type');
  }

  return {
    hash: Hash28ByteBase16(Buffer.from(hash).toString('hex')),
    type: isScriptHash ? CredentialType.ScriptHash : CredentialType.KeyHash
  };
};

// Use these if you need to ensure the ID is in a specific format.
DRepID.toCip105DRepID = (drepId: DRepID): DRepID => {
  const credential = DRepID.toCredential(drepId);
  return DRepID.cip105FromCredential(credential);
};

DRepID.toCip129DRepID = (drepId: DRepID): DRepID => {
  const credential = DRepID.toCredential(drepId);
  return DRepID.cip129FromCredential(credential);
};

DRepID.toAddress = (drepId: DRepID): EnterpriseAddress | undefined => {
  const credential = DRepID.toCredential(drepId);
  return new Address({
    paymentPart: credential,
    type: credential.type === CredentialType.KeyHash ? AddressType.EnterpriseKey : AddressType.EnterpriseScript
  }).asEnterprise();
};
