import { Cardano } from '@cardano-sdk/core';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { WithUtxo } from './withUtxo';
import { unifiedProjectorOperator } from '../utils';
import uniq from 'lodash/uniq.js';
import { credentialsFromAddress } from './util';

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
  addresses: uniq(evt.utxo.produced.map(([_, txOut]) => txOut.address)).map(credentialsFromAddress)
}));
