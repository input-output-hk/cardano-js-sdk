import { Cardano } from '@cardano-sdk/core';
import { unifiedProjectorOperator } from '../utils/index.js';
import uniq from 'lodash/uniq.js';
import type { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import type { WithUtxo } from './withUtxo.js';

export interface Address {
  address: Cardano.PaymentAddress;
  type: Cardano.AddressType;
  /** Applicable only for base/grouped, enterprise and pointer addresses */
  paymentCredentialHash?: Hash28ByteBase16;
  /** Hash28ByteBase16 for base/grouped addresses. Pointer for pointer addresses. */
  stakeCredential?: Hash28ByteBase16 | Cardano.Pointer;
}

export interface WithAddresses {
  addresses: Address[];
}

/** Collect all unique addresses from produced utxo */
export const withAddresses = unifiedProjectorOperator<WithUtxo, WithAddresses>((evt) => ({
  ...evt,
  addresses: uniq(evt.utxo.produced.map(([_, txOut]) => txOut.address)).map((address): Address => {
    const parsed = Cardano.Address.fromString(address)!;
    let paymentCredentialHash: Hash28ByteBase16 | undefined;
    let stakeCredentialHash: Hash28ByteBase16 | undefined;
    let pointer: Cardano.Pointer | undefined;
    const type = parsed.getType();
    switch (type) {
      case Cardano.AddressType.BasePaymentKeyStakeKey:
      case Cardano.AddressType.BasePaymentKeyStakeScript:
      case Cardano.AddressType.BasePaymentScriptStakeKey:
      case Cardano.AddressType.BasePaymentScriptStakeScript: {
        const baseAddress = parsed.asBase()!;
        paymentCredentialHash = baseAddress.getPaymentCredential().hash;
        stakeCredentialHash = baseAddress.getStakeCredential().hash;
        break;
      }
      case Cardano.AddressType.EnterpriseKey:
      case Cardano.AddressType.EnterpriseScript: {
        const enterpriseAddress = parsed.asEnterprise()!;
        paymentCredentialHash = enterpriseAddress.getPaymentCredential().hash;
        break;
      }
      case Cardano.AddressType.PointerKey:
      case Cardano.AddressType.PointerScript: {
        const pointerAddress = parsed.asPointer()!;
        paymentCredentialHash = pointerAddress.getPaymentCredential().hash;
        pointer = pointerAddress.getStakePointer();
        break;
      }
    }
    return {
      address,
      paymentCredentialHash,
      stakeCredential: stakeCredentialHash || pointer,
      type
    };
  })
}));
