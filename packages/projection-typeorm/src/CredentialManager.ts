import { Cardano } from '@cardano-sdk/core';
import { CredentialEntity, CredentialType, credentialEntityComparator } from './entity';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { LRUCache } from 'lru-cache';
import { Mappers } from '@cardano-sdk/projection';
import uniqWith from 'lodash/uniqWith.js';

export interface Credential {
  hash: Hash28ByteBase16;
  type?: CredentialType;
}

type AddressPart = 'payment' | 'stake';
const credentialTypeMap: { [key: number]: { payment: CredentialType | null; stake: CredentialType } } = {
  [Cardano.AddressType.BasePaymentKeyStakeKey]: { payment: CredentialType.PaymentKey, stake: CredentialType.StakeKey },
  [Cardano.AddressType.EnterpriseKey]: { payment: CredentialType.PaymentKey, stake: CredentialType.StakeKey },
  [Cardano.AddressType.BasePaymentKeyStakeScript]: {
    payment: CredentialType.PaymentKey,
    stake: CredentialType.StakeScript
  },
  [Cardano.AddressType.BasePaymentScriptStakeKey]: {
    payment: CredentialType.PaymentScript,
    stake: CredentialType.StakeKey
  },
  [Cardano.AddressType.BasePaymentScriptStakeScript]: {
    payment: CredentialType.PaymentScript,
    stake: CredentialType.StakeScript
  },
  [Cardano.AddressType.EnterpriseScript]: { payment: CredentialType.PaymentScript, stake: CredentialType.StakeScript },
  [Cardano.AddressType.RewardKey]: { payment: null, stake: CredentialType.StakeKey },
  [Cardano.AddressType.RewardScript]: { payment: null, stake: CredentialType.StakeScript }
};

const credentialsByTxInCache = new LRUCache<string, Credential[]>({
  max: 1_000_000
});

export class CredentialManager {
  txToCredentials = new Map<Cardano.TransactionId, CredentialEntity[]>();

  getCachedCredential(txIn: Cardano.TxIn): Credential[] {
    return credentialsByTxInCache.get(`${txIn.txId}#${txIn.index}`) ?? [];
  }

  deleteCachedCredential(txIn: Cardano.TxIn) {
    credentialsByTxInCache.delete(`${txIn.txId}#${txIn.index}`);
  }

  addCredential(txId: Cardano.TransactionId, { hash: credentialHash, type: credentialType }: Credential) {
    this.txToCredentials.set(
      txId,
      uniqWith(
        [...(this.txToCredentials.get(txId) || []), { credentialHash, credentialType }],
        credentialEntityComparator
      )
    );
  }

  // This function caches credentials only if outputIndex is set.
  addCredentialFromAddress(
    txId: Cardano.TransactionId,
    { paymentCredentialHash, stakeCredential, type }: Mappers.Address,
    outputIndex?: number
  ) {
    const cacheKey = `${txId}#${outputIndex}`;
    const paymentCredentialType = this.credentialTypeFromAddressType(type, 'payment');

    if (paymentCredentialHash && paymentCredentialType) {
      this.addCredential(txId, { hash: paymentCredentialHash, type: paymentCredentialType });
      if (outputIndex) {
        credentialsByTxInCache.set(cacheKey, [
          ...(credentialsByTxInCache.get(cacheKey) || []),
          { hash: paymentCredentialHash, type: paymentCredentialType }
        ]);
      }
    }

    if (stakeCredential) {
      const stakeCredentialType = this.credentialTypeFromAddressType(type, 'stake');
      // FIXME: support pointers
      if (stakeCredentialType && typeof stakeCredential === 'string') {
        this.addCredential(txId, { hash: stakeCredential, type: stakeCredentialType });

        if (outputIndex) {
          credentialsByTxInCache.set(cacheKey, [
            ...(credentialsByTxInCache.get(cacheKey) || []),
            { hash: stakeCredential, type: stakeCredentialType }
          ]);
        }
      }
    }
  }

  credentialTypeFromAddressType(type: Cardano.AddressType, part: AddressPart) {
    const credential = credentialTypeMap[type];
    if (!credential) {
      // FIXME: map byron address, pointer script, pointer key type
      return null;
    }
    return credential[part];
  }
}
