import { Cardano } from '@cardano-sdk/core';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { WithUtxo } from './withUtxo';
import { credentialsFromAddress } from './util';
import { unifiedProjectorOperator } from '../utils';
import uniq from 'lodash/uniq.js';

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
  addressesByTx: Record<Cardano.TransactionId, Address[]>;
}

/** Collect all unique addresses from produced utxo */
export const withAddresses = unifiedProjectorOperator<WithUtxo, WithAddresses>((evt) => {
  const addressesByTx = {
    ...Object.entries(evt.utxoByTx).reduce(
      (map, [txId, utxo]) => ({
        ...map,
        [txId]: uniq(utxo.produced.map(([_, txOut]) => txOut.address)).map(credentialsFromAddress)
      }),
      new Map<Cardano.TransactionId, Address[]>()
    )
  } as Record<Cardano.TransactionId, Address[]>;

  return {
    ...evt,
    addresses: uniq(Object.values(addressesByTx).flat()),
    addressesByTx
  };
});
