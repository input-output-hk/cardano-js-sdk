import { Cardano, ChainSyncEventType, Serialization } from '@cardano-sdk/core';
import { Mappers } from '@cardano-sdk/projection';
import { ObjectLiteral } from 'typeorm';
import { OutputEntity, TokensEntity } from '../entity';
import { typeormOperator } from './util';

const serializeDatumIfExists = (datum: Cardano.PlutusData | undefined) =>
  datum ? Serialization.PlutusData.fromCore(datum).toCbor() : undefined;

export interface WithStoredProducedUtxo {
  storedProducedUtxo: Map<Mappers.ProducedUtxo, ObjectLiteral>;
}

export const willStoreUtxo = ({ utxo: { produced, consumed } }: Mappers.WithUtxo) =>
  produced.length > 0 || consumed.length > 0;

export const storeUtxo = typeormOperator<Mappers.WithUtxo, WithStoredProducedUtxo>(
  async ({ utxo: { consumed, produced }, block: { header }, eventType, queryRunner }) => {
    const utxoRepository = queryRunner.manager.getRepository(OutputEntity);
    const tokensRepository = queryRunner.manager.getRepository(TokensEntity);
    const storedProducedUtxo = new Map<Mappers.ProducedUtxo, ObjectLiteral>();
    if (eventType === ChainSyncEventType.RollForward) {
      if (produced.length > 0) {
        const { identifiers } = await utxoRepository.insert(
          produced.map(
            ([{ index, txId }, { scriptReference, address, value, datum, datumHash }]): OutputEntity => ({
              address,
              block: { slot: header.slot },
              coins: value.coins,
              datum: serializeDatumIfExists(datum),
              datumHash,
              outputIndex: index,
              scriptReference,
              txId
            })
          )
        );
        for (const [idx, identifier] of identifiers.entries()) {
          storedProducedUtxo.set(produced[idx], identifier);
        }
        const tokens = produced.flatMap(
          (
            [
              _,
              {
                value: { assets }
              }
            ],
            producedIndex
          ) =>
            [...(assets?.entries() || [])].map(
              ([assetId, quantity]): TokensEntity => ({
                asset: { id: assetId },
                output: identifiers[producedIndex],
                quantity
              })
            )
        );
        if (tokens.length > 0) {
          await tokensRepository.insert(tokens);
        }
      }
      for (const { index, txId } of consumed) {
        await utxoRepository.update({ outputIndex: index, txId }, { consumedAtSlot: header.slot });
      }
    } else {
      // produced utxo will be automatically deleted via block cascade
      for (const { index, txId } of consumed) {
        await utxoRepository.update({ outputIndex: index, txId }, { consumedAtSlot: null });
      }
    }

    return { storedProducedUtxo };
  }
);
