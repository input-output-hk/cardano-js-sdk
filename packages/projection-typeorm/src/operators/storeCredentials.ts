/* eslint-disable sonarjs/cognitive-complexity */
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { CredentialEntity, CredentialType } from '../entity';
import { Mappers } from '@cardano-sdk/projection';
// import { Repository } from 'typeorm';
import { typeormOperator } from './util';

import * as Crypto from '@cardano-sdk/crypto';
import { CredentialManager } from '../CredentialManager';

export interface WithTxCredentials {
  credentialsByTx: Record<Cardano.TransactionId, CredentialEntity[]>;
}

export const willStoreCredentials = ({ utxoByTx }: Mappers.WithUtxo) => Object.keys(utxoByTx).length > 0;

// const addInputCredentials = async (
//   utxoByTx: Record<Cardano.TransactionId, Mappers.WithConsumedTxIn & Mappers.WithProducedUTxO>,
//   utxoRepository: Repository<OutputEntity>,
//   manager: CredentialManager
// ) => {
//   for (const txHash of Object.keys(utxoByTx) as Cardano.TransactionId[]) {
//     const txInLookups: { outputIndex: number; txId: Cardano.TransactionId }[] = [];

//     for (const txIn of utxoByTx[txHash]!.consumed) {
//       const cachedCredentials = manager.getCachedCredential(txIn);
//       if (cachedCredentials.length > 0) {
//         for (const credential of cachedCredentials) {
//           manager.addCredential(txHash, { hash: credential.hash, type: credential.type ?? undefined });
//         }
//         manager.deleteCachedCredential(txIn); // can only be consumed once so chances are it won't have to be resolved again
//       } else {
//         txInLookups.push({ outputIndex: txIn.index, txId: txIn.txId });
//       }
//     }

//     if (txInLookups.length > 0) {
//       const outputEntities = await utxoRepository.find({
//         select: { address: true, outputIndex: true, txId: true },
//         where: txInLookups
//       });

//       for (const hydratedTxIn of outputEntities) {
//         if (hydratedTxIn.address) {
//           manager.addCredentialFromAddress(txHash, Mappers.credentialsFromAddress(hydratedTxIn.address!));
//         }
//       }
//     }
//   }
// };

const addWitnessCredentials = async (txs: Cardano.OnChainTx<Cardano.TxBody>[], manager: CredentialManager) => {
  for (const tx of txs) {
    const pubKeys = Object.keys(tx.witness.signatures) as Crypto.Ed25519PublicKeyHex[];
    for (const pubKey of pubKeys) {
      const credential = await Crypto.Ed25519PublicKey.fromHex(pubKey).hash();
      manager.addCredential(tx.id, {
        hash: Crypto.Hash28ByteBase16(credential.hex()),
        type: CredentialType.PaymentKey
      });
    }
  }
};

const addOutputCredentials = (
  addressesByTx: Record<Cardano.TransactionId, Mappers.Address[]>,
  manager: CredentialManager
) => {
  for (const txId of Object.keys(addressesByTx) as Cardano.TransactionId[]) {
    for (const [index, address] of addressesByTx[txId].entries()) {
      manager.addCredentialFromAddress(txId, address, index);
    }
  }
};

const addCertificateCredentials = (
  credentialsByTx: Record<Cardano.TransactionId, Cardano.Credential[]>,
  manager: CredentialManager
) => {
  for (const txId of Object.keys(credentialsByTx) as Cardano.TransactionId[]) {
    for (const credential of credentialsByTx[txId]) {
      manager.addCredential(txId, {
        hash: credential.hash,
        type: credential.type === 0 ? CredentialType.StakeKey : CredentialType.StakeScript
      });
    }
  }
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
    utxo: { consumed: consumedUTxOs }
  } = evt;

  const manager = new CredentialManager();

  // produced credentials will be automatically deleted via block cascade
  if (txs.length === 0 || eventType !== ChainSyncEventType.RollForward) {
    return { credentialsByTx: Object.fromEntries(manager.txToCredentials) };
  }

  // const utxoRepository = queryRunner.manager.getRepository(OutputEntity);
  // await addInputCredentials(utxoByTx, utxoRepository, manager);
  addOutputCredentials(addressesByTx, manager);
  addCertificateCredentials(stakeCredentialsByTx, manager);
  addWitnessCredentials(txs, manager);

  // insert new credentials & ignore conflicts of existing ones
  await queryRunner.manager
    .createQueryBuilder()
    .insert()
    .into(CredentialEntity)
    .values([...manager.txToCredentials.values()].flat())
    .orIgnore()
    .execute();

  for (const consumed of consumedUTxOs) {
    manager.deleteCachedCredential(consumed);
  }

  return { credentialsByTx: Object.fromEntries(manager.txToCredentials) };
});
