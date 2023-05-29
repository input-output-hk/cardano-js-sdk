import { Asset, Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { HandleEntity } from '../entity';
import { In, QueryRunner, Repository } from 'typeorm';
import { Mappers } from '@cardano-sdk/projection';
import { WithMintedAssetSupplies } from './storeAssets';
import { typeormOperator } from './util';

type HandleEventParams = {
  handles: Mappers.Handle[];
  mint: Mappers.Mint[];
  queryRunner: QueryRunner;
  block: Cardano.Block;
  totalSupplies: Partial<Record<Cardano.AssetId, bigint>>;
};

const getExistingHandles = async (
  handleRepository: Repository<HandleEntity>,
  handles: Mappers.Handle[]
): Promise<Set<string | undefined>> => {
  const existingHandles = await handleRepository.find({
    select: { handle: true },
    where: { handle: In(handles.map(({ handle }) => handle)) }
  });
  return new Set(existingHandles.map(({ handle }) => handle));
};

const convertAssetIdToHandle = (assetId: Cardano.AssetId) =>
  Buffer.from(Asset.util.assetNameFromAssetId(assetId), 'hex').toString('utf8');

const getOwnerAddresses = async (queryRunner: QueryRunner, assetId: string) =>
  queryRunner.manager
    .createQueryBuilder('tokens', 't')
    .innerJoinAndSelect('output', 'o', 'o.id = t.output_id')
    .select('address')
    .distinct()
    .where('o.consumed_at_slot IS NULL')
    .andWhere('t.asset_id = :assetId', { assetId })
    .getRawMany();

const rollForward = async ({ mint, handles, queryRunner, block: { header } }: HandleEventParams) => {
  const handleRepository = queryRunner.manager.getRepository(HandleEntity);
  const existingHandlesSet = await getExistingHandles(handleRepository, handles);

  // TODO: iterate over handles
  // TODO: optimize by checking totalSupplies:
  // - if it's exactly === 1, then just set handle address without querying anything else
  // - if it's >1, then just set handle address to null because it's invalid (without querying anything else)
  for (const { quantity, assetId } of mint) {
    if (quantity < 0) {
      // burning a handle
      const ownerAddresses = await getOwnerAddresses(queryRunner, assetId);
      const burnedHandle = convertAssetIdToHandle(Cardano.AssetId(assetId));
      await handleRepository.update(
        { handle: burnedHandle },
        { cardanoAddress: ownerAddresses.length === 1 ? ownerAddresses[0].address : null }
      );
    } else {
      // minting a handle
      await Promise.all(
        handles.map(({ handle, address, assetId: _assetId, policyId, datum }) =>
          existingHandlesSet.has(handle)
            ? handleRepository.update({ handle }, { cardanoAddress: null })
            : handleRepository.insert({
                asset: _assetId,
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
  }
};

// TODO: check totalSupplies before querying existing addresses.
// If it's !== 1 then set to null (without making any other queries)
// If it's === 1 then query the owner through unspent OutputEntity (like it is now)
const handleMintingRollback = async (handles: Mappers.Handle[], queryRunner: QueryRunner) => {
  const handleRepository = queryRunner.manager.getRepository(HandleEntity);
  const existingHandlesSet = await getExistingHandles(handleRepository, handles);

  for (const { assetId, handle } of handles) {
    if (existingHandlesSet.has(handle)) {
      const ownerAddresses = await getOwnerAddresses(queryRunner, assetId);
      await handleRepository.update(
        { handle },
        { cardanoAddress: ownerAddresses.length === 1 ? ownerAddresses[0].address : null }
      );
    } else {
      await handleRepository.delete({ handle });
    }
  }
};

const rollBackward = async ({ handles, queryRunner, mint }: HandleEventParams) => {
  const handleRepository = queryRunner.manager.getRepository(HandleEntity);
  for (const { quantity, assetId } of mint) {
    if (quantity < 0) {
      const burnedHandle = convertAssetIdToHandle(Cardano.AssetId(assetId));
      await handleRepository.update({ handle: burnedHandle }, { cardanoAddress: null });
    } else {
      await handleMintingRollback(handles, queryRunner);
    }
  }
};

export const storeHandles = typeormOperator<Mappers.WithHandles & Mappers.WithMint & WithMintedAssetSupplies>(
  async ({ mint, handles, queryRunner, eventType, block, mintedAssetTotalSupplies }) => {
    const handleEventParams: HandleEventParams = {
      block,
      handles,
      mint,
      queryRunner,
      totalSupplies: mintedAssetTotalSupplies
    };

    try {
      eventType === ChainSyncEventType.RollForward
        ? await rollForward(handleEventParams)
        : await rollBackward(handleEventParams);
    } catch (error) {
      throw new Error((error as Error).message);
    }
  }
);
