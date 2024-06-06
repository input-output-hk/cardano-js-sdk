import { Address, AddressType } from '../Address/Address.js';
import { InvalidStringError } from '@cardano-sdk/util';
import type { Credential } from '../Address/Address.js';
import type { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import type { PaymentAddress } from '../Address/PaymentAddress.js';
import type { Pointer } from '../Address/PointerAddress.js';

type PaymentId = { credential: Credential } | { byronRoot: Hash28ByteBase16 };
type StakeId = { credential: Credential } | { pointer: Pointer };
type AddressKeyIDs = { paymentId?: PaymentId; stakeId?: StakeId };

/** Payment ID is either - payment credential - Byron address root hash Stake ID is either - stake credential - pointer */
// eslint-disable-next-line complexity
const getAddressKeyIDs = (input: Address | PaymentAddress): AddressKeyIDs => {
  const address = typeof input === 'string' ? Address.fromString(input) : input;
  if (!address) {
    throw new InvalidStringError('Expected either bech32 or base58 address');
  }
  switch (address.getType()) {
    case AddressType.BasePaymentKeyStakeKey:
    case AddressType.BasePaymentKeyStakeScript:
    case AddressType.BasePaymentScriptStakeKey:
    case AddressType.BasePaymentScriptStakeScript: {
      const baseAddr = address.asBase()!;
      return {
        paymentId: { credential: baseAddr.getPaymentCredential() },
        stakeId: { credential: baseAddr.getStakeCredential() }
      };
    }
    case AddressType.Byron:
      return {
        paymentId: { byronRoot: address.asByron()!.getRoot() }
      };
    case AddressType.EnterpriseKey:
    case AddressType.EnterpriseScript: {
      const enterpriseAddr = address.asEnterprise()!;
      return {
        paymentId: { credential: enterpriseAddr.getPaymentCredential() }
      };
    }
    case AddressType.PointerKey:
    case AddressType.PointerScript: {
      const pointerAddr = address.asPointer()!;
      return {
        paymentId: { credential: pointerAddr.getPaymentCredential() },
        stakeId: { pointer: pointerAddr.getStakePointer() }
      };
    }
    case AddressType.RewardKey:
    case AddressType.RewardScript: {
      const rewardAddr = address.asReward()!;
      return {
        stakeId: { credential: rewardAddr.getPaymentCredential() }
      };
    }
  }
};

const isPaymentIdPresentAndEquals = (id1: PaymentId | undefined, id2: PaymentId | undefined) => {
  if (!id1 || !id2) return false;
  if ('credential' in id1 && 'credential' in id2) {
    return id1.credential.hash === id2.credential.hash;
  }
  if ('byronRoot' in id1 && 'byronRoot' in id2) {
    return id1.byronRoot === id2.byronRoot;
  }
  return false;
};

const isStakeIdPresentAndEquals = (id1: StakeId | undefined, id2: StakeId | undefined) => {
  if (!id1 || !id2) return false;
  if ('credential' in id1 && 'credential' in id2) {
    return id1.credential.hash === id2.credential.hash;
  }
  if ('pointer' in id1 && 'pointer' in id2) {
    return (
      id1.pointer.slot === id2.pointer.slot &&
      id1.pointer.txIndex === id2.pointer.txIndex &&
      id1.pointer.certIndex === id2.pointer.certIndex
    );
  }
  return false;
};

export const addressesShareAnyKey = (address1: PaymentAddress, address2: PaymentAddress) => {
  if (address1 === address2) return true;
  const ids1 = getAddressKeyIDs(address1);
  const ids2 = getAddressKeyIDs(address2);
  return (
    isPaymentIdPresentAndEquals(ids1.paymentId, ids2.paymentId) || isStakeIdPresentAndEquals(ids1.stakeId, ids2.stakeId)
  );
};
