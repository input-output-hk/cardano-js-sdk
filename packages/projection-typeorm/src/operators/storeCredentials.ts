import { Cardano, ChainSyncEventType, TxBodyCBOR } from '@cardano-sdk/core';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { Mappers } from '@cardano-sdk/projection';
import { credentialsFromAddress } from '@cardano-sdk/projection/src/operators/Mappers/util';
import { CredentialEntity, CredentialType, OutputEntity } from '../entity';
import { typeormOperator } from './util';

export const storeCredentials = typeormOperator<Mappers.WithUtxo & Mappers.WithAddresses>(async (evt) => {
  const {
    block: { body: txs },
    eventType,
    queryRunner
  } = evt;

  // produced credentials will be automatically deleted via block cascade
  if (txs.length === 0 || eventType !== ChainSyncEventType.RollForward) return;

  const utxoRepository = queryRunner.manager.getRepository(OutputEntity);
  const txIdToCredentials = new Map<Cardano.TransactionId, Map<Hash28ByteBase16, CredentialType>>();

  const addCredential = (
    { paymentCredentialHash, stakeCredential }: Mappers.Address,
    map: Map<Hash28ByteBase16, CredentialType>
  ) => {
    if (paymentCredentialHash) {
      map.set(paymentCredentialHash, CredentialType.PAYMENT);
    }
    if (stakeCredential && !('slot' in stakeCredential)) {
      // FIXME: Support pointer stake credentials
      map.set(stakeCredential, CredentialType.STAKE);
    }
  };

  // get input & output credentials by tx
  for (const tx of evt.block.body) {
    const txCredentials = new Map<Hash28ByteBase16, CredentialType>();

    // get tx input address
    const txInOutputs = await Promise.all(
      tx.body.inputs.map(
        async ({ txId, index: outputIndex }) =>
          await utxoRepository.findOne({ select: { address: true }, where: { outputIndex, txId } })
      )
    );

    // add tx input credentials to involved tx credentials
    for (const txOut of txInOutputs) {
      if (txOut && txOut.address) {
        addCredential(credentialsFromAddress(txOut.address), txCredentials);
      }
    }

    // add tx output credentials to involved tx credentials
    for (const txOut of tx.body.outputs) {
      addCredential(credentialsFromAddress(txOut.address), txCredentials);
    }

    const credentialEntities = Array.from(txCredentials).map(
      ([credentialHash, credentialType]): CredentialEntity => ({
        credentialHash: Buffer.from(credentialHash, 'hex'),
        credentialType
      })
    );

    await queryRunner.manager
      .createQueryBuilder()
      .insert()
      .into(CredentialEntity)
      .values(credentialEntities)
      .orIgnore()
      .execute();

    // store tx credentials for transaction entities
    txIdToCredentials.set(tx.id, txCredentials);
  }

  return { txIdToCredentials };
});
