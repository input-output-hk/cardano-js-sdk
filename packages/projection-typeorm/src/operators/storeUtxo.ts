import { Cardano, ChainSyncEventType, PlutusData } from '@cardano-sdk/core';
import { Mappers } from '@cardano-sdk/projection';
import { OutputEntity, TokensEntity } from '../entity';
import { typeormOperator } from './util';

const serializeDatumIfExists = (datum: Cardano.PlutusData | undefined) =>
  datum ? PlutusData.fromCore(datum).toCbor() : undefined;

export const storeUtxo = typeormOperator<Mappers.WithUtxo>(
  async ({ utxo: { consumed, produced }, block: { header }, eventType, queryRunner }) => {
    const utxoRepository = queryRunner.manager.getRepository(OutputEntity);
    const tokensRepository = queryRunner.manager.getRepository(TokensEntity);
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
  }
);
