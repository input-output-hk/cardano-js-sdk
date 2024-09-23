import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { TransactionEntity } from '../entity';
import { WithBlock } from '@cardano-sdk/projection';
import { WithTxCredentials } from './storeCredentials';
import { typeormOperator } from './util';

export const willStoreTransactions = ({ block: { body } }: WithBlock) => body.length > 0;

export const storeTransactions = typeormOperator<WithTxCredentials>(async (evt) => {
  const {
    block: { body: txs, header },
    credentialsByTx,
    eventType,
    queryRunner
  } = evt;

  // produced txs will be automatically deleted via block cascade
  if (txs.length === 0 || eventType !== ChainSyncEventType.RollForward) return;

  const transactionEntities = new Array<TransactionEntity>();
  for (const tx of txs) {
    const credentials = credentialsByTx[tx.id] || [];
    const txEntity: TransactionEntity = {
      block: header,
      cbor: tx.cbor,
      credentials,
      txId: tx.id
    };
    transactionEntities.push(txEntity);
  }

  await queryRunner.manager
    .createQueryBuilder()
    .insert()
    .into(TransactionEntity)
    .values(transactionEntities)
    .orIgnore()
    .execute();

  // Bulk insert relationships
  await queryRunner.manager
    .createQueryBuilder()
    .insert()
    .into('transaction_credentials')
    .values(
      Object.entries(credentialsByTx).reduce(
        (arr, [txId, credentials]) => [
          ...arr,
          ...credentials.map((credential) => ({
            credential_id: credential.credentialHash!,
            transaction_id: txId as Cardano.TransactionId
          }))
        ],
        new Array<{ transaction_id: Cardano.TransactionId; credential_id: Hash28ByteBase16 }>()
      )
    )
    .orIgnore()
    .execute();
});
