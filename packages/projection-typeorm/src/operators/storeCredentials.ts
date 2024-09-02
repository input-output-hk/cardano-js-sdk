import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { CredentialEntity, CredentialType, OutputEntity, credentialEntityComparator } from '../entity';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { Mappers } from '@cardano-sdk/projection';
import { Repository } from 'typeorm';
import { typeormOperator } from './util';
import uniqWith from 'lodash/uniqWith.js';

export interface WithTxCredentials {
  credentialsByTx: Record<Cardano.TransactionId, CredentialEntity[]>;
}

const addressByTxInCache = {} as Record<string, Mappers.Address>;

export const removeTxInFromCache = (txIn: string) => {
  delete addressByTxInCache[txIn];
};

export const willStoreCredentials = ({ utxoByTx }: Mappers.WithUtxo) => Object.keys(utxoByTx).length > 0;

const addInputCredentials = async (
  utxoByTx: Record<Cardano.TransactionId, Mappers.WithConsumedTxIn & Mappers.WithProducedUTxO>,
  utxoRepository: Repository<OutputEntity>,
  addCredentialFromAddress: (txId: Cardano.TransactionId, address: Mappers.Address) => void
) => {
  for (const txHash of Object.keys(utxoByTx) as Cardano.TransactionId[]) {
    const txInLookups: { outputIndex: number; txId: Cardano.TransactionId }[] = [];
    for (const txIn of utxoByTx[txHash]!.consumed) {
      const cacheKey = `${txIn.txId}#${txIn.index}`;
      if (addressByTxInCache[cacheKey] === undefined) {
        txInLookups.push({ outputIndex: txIn.index, txId: txIn.txId });
      } else {
        addCredentialFromAddress(txHash, addressByTxInCache[cacheKey]);
      }
    }

    const outputEntities = await utxoRepository.find({
      select: { address: true, outputIndex: true, txId: true },
      where: txInLookups
    });

    for (const hydratedTxIn of outputEntities) {
      if (hydratedTxIn.address) {
        addressByTxInCache[`${hydratedTxIn.txId!}#${hydratedTxIn.outputIndex!}`] = Mappers.credentialsFromAddress(
          hydratedTxIn.address!
        );
        addCredentialFromAddress(txHash, Mappers.credentialsFromAddress(hydratedTxIn.address));
      }
    }
  }
};

const addOutputCredentials = (
  addressesByTx: Record<Cardano.TransactionId, Mappers.Address[]>,
  addCredentialFromAddress: (txId: Cardano.TransactionId, address: Mappers.Address) => void
) => {
  for (const txId of Object.keys(addressesByTx) as Cardano.TransactionId[]) {
    for (const address of addressesByTx[txId]) {
      addCredentialFromAddress(txId, address);
    }
  }
};

const addCertificateCredentials = (
  credentialsByTx: Record<Cardano.TransactionId, Cardano.Credential[]>,
  addCredential: (
    txId: Cardano.TransactionId,
    credentialHash: Hash28ByteBase16,
    credentialType: CredentialType
  ) => Map<Cardano.TransactionId, CredentialEntity[]>
) => {
  for (const txId of Object.keys(credentialsByTx) as Cardano.TransactionId[]) {
    for (const credential of credentialsByTx[txId]) {
      addCredential(
        txId,
        credential.hash,
        credential.type === 0 ? CredentialType.StakeKey : CredentialType.StakeScript
      );
    }
  }
};

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

export const storeCredentials = typeormOperator<
  Mappers.WithUtxo & Mappers.WithAddresses & Mappers.WithCertificates,
  WithTxCredentials
>(async (evt) => {
  const {
    addressesByTx,
    block: { body: txs },
    eventType,
    queryRunner,
    stakeCredentialsByTx,
    utxoByTx
  } = evt;

  const txToCredentials = new Map<Cardano.TransactionId, CredentialEntity[]>();

  // produced credentials will be automatically deleted via block cascade
  if (txs.length === 0 || eventType !== ChainSyncEventType.RollForward) {
    return { credentialsByTx: Object.fromEntries(txToCredentials) };
  }
  const utxoRepository = queryRunner.manager.getRepository(OutputEntity);
  const addCredential = (
    txId: Cardano.TransactionId,
    credentialHash: Hash28ByteBase16,
    credentialType: CredentialType
  ) =>
    txToCredentials.set(
      txId,
      uniqWith([...(txToCredentials.get(txId) || []), { credentialHash, credentialType }], credentialEntityComparator)
    );

  const credentialTypeFromAddressType = (type: Cardano.AddressType, part: AddressPart) => {
    const credential = credentialTypeMap[type];
    if (!credential) {
      // FIXME: map byron address, pointer script, pointer key type
      return null;
    }
    return credential[part];
  };

  const addCredentialFromAddress = (
    txId: Cardano.TransactionId,
    { paymentCredentialHash, stakeCredential, type }: Mappers.Address
  ) => {
    const paymentCredentialType = credentialTypeFromAddressType(type, 'payment');
    if (paymentCredentialHash && paymentCredentialType) {
      addCredential(txId, paymentCredentialHash, paymentCredentialType);
    }

    if (stakeCredential) {
      const stakeCredentialType = credentialTypeFromAddressType(type, 'stake');
      // FIXME: support pointers
      if (stakeCredentialType && typeof stakeCredential === 'string') {
        addCredential(txId, stakeCredential, stakeCredentialType);
      }
    }
  };

  await addInputCredentials(utxoByTx, utxoRepository, addCredentialFromAddress);
  addOutputCredentials(addressesByTx, addCredentialFromAddress);
  addCertificateCredentials(stakeCredentialsByTx, addCredential);

  // insert new credentials & ignore conflicts of existing ones
  await queryRunner.manager
    .createQueryBuilder()
    .insert()
    .into(CredentialEntity)
    .values([...txToCredentials.values()].flat())
    .orIgnore()
    .execute();

  return { credentialsByTx: Object.fromEntries(txToCredentials) };
});
