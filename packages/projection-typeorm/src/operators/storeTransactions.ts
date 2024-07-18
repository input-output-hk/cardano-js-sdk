import { ChainSyncEventType } from '@cardano-sdk/core';
import { TransactionEntity } from '../entity';
import { typeormOperator } from './util';

export const storeTransactions = typeormOperator(async (evt) => {
  const {
    block: { body: txs },
    eventType,
    queryRunner
  } = evt;

  // produced txs will be automatically deleted via block cascade
  if (txs.length === 0 || eventType !== ChainSyncEventType.RollForward) return;

  const transactionEntities = txs.map(
    (tx): TransactionEntity => ({
      txId: tx.id,
      cbor: tx.cbor ? Buffer.from(tx.cbor.__opaqueString, 'hex') : undefined,
      block: evt.block.header,
      credentials: [] // FIXME
    })
  );

  await queryRunner.manager
    .createQueryBuilder()
    .insert()
    .into(TransactionEntity)
    .values(transactionEntities)
    .orIgnore()
    .execute();
});
