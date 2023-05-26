import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { HandleEntity } from '../entity';
import { In, QueryRunner, Repository } from 'typeorm';
import { Mappers } from '@cardano-sdk/projection';
import { typeormOperator } from './util';

type HandleEventParams = {
  handles: Mappers.Handle[];
  mint: Mappers.Mint[];
  queryRunner: QueryRunner;
  block: Cardano.Block;
};

const getExistingHandles = async (
  handleRepository: Repository<HandleEntity>,
  handles: Mappers.Handle[]
): Promise<Set<string | undefined>> => {
  const existingHandles = await handleRepository.find({
    select: { handle: true },
    where: { handle: In(handles.map((handle) => handle.handle)) }
  });
  return new Set(existingHandles.map(({ handle }) => handle));
};

const rollForward = async ({ mint, handles, queryRunner, block: { header } }: HandleEventParams) => {
  const handleRepository = queryRunner.manager.getRepository(HandleEntity);
  const existingHandlesSet = await getExistingHandles(handleRepository, handles);

  for (const _ of mint) {
    await Promise.all(
      handles.map(({ handle, address, assetId, policyId, datum }) =>
        existingHandlesSet.has(handle)
          ? handleRepository.update({ handle }, { cardanoAddress: null })
          : handleRepository.insert({
              asset: assetId,
              cardanoAddress: address,
              handle,
              hasDatum: !!datum,
              policyId,
              resolvedAt: {
                slot: header.slot
              }
            })
      )
    );
  }
};

const rollBackward = async ({ handles, queryRunner }: HandleEventParams) => {
  const handleRepository = queryRunner.manager.getRepository(HandleEntity);
  const existingHandlesSet = await getExistingHandles(handleRepository, handles);

  for (const { assetId, handle } of handles) {
    if (existingHandlesSet.has(handle)) {
      const ownerAddresses = await queryRunner.query(`
        SELECT o.address FROM tokens t JOIN output o ON o.id = t.output_id WHERE o.consumed_at_slot IS NULL AND t.asset_id = '${assetId}'
    `);
      // TODO: if there are multiple distinct addresses, then it's an invalid handle and should be set to null
      await handleRepository.update({ handle }, { cardanoAddress: ownerAddresses[0].address });
    } else {
      await handleRepository.delete({ handle });
    }
  }
};

export const storeHandles = typeormOperator<Mappers.WithHandles & Mappers.WithMint & Mappers.WithUtxo>(
  async ({ mint, handles, queryRunner, eventType, block }) => {
    const handleEventParams = { block, handles, mint, queryRunner };

    try {
      eventType === ChainSyncEventType.RollForward
        ? await rollForward(handleEventParams)
        : await rollBackward(handleEventParams);
    } catch (error) {
      throw new Error((error as Error).message);
    }
  }
);
