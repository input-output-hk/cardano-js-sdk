import { AssetEntity, HandleEntity, HandleMetadataEntity } from '../entity';
import { Cardano, ChainSyncEventType, Handle } from '@cardano-sdk/core';
import { In, QueryRunner } from 'typeorm';
import { Mappers } from '@cardano-sdk/projection';
import { WithMintedAssetSupplies } from './storeAssets';
import { typeormOperator } from './util';
import sortBy from 'lodash/sortBy.js';

type HandleWithTotalSupply = Mappers.HandleOwnership & { totalSupply: bigint };

type HandleEventParams = {
  handles: Array<HandleWithTotalSupply>;
  queryRunner: QueryRunner;
  block: Cardano.Block;
} & Mappers.WithHandleMetadata;

const getOwner = async (
  queryRunner: QueryRunner,
  assetId: string
): Promise<{ cardanoAddress: Cardano.PaymentAddress | null; hasDatum: boolean }> => {
  const rows = await queryRunner.manager
    .createQueryBuilder('tokens', 't')
    .innerJoinAndSelect('output', 'o', 'o.id = t.output_id')
    .select('address, o.datum')
    .distinct()
    .where('o.consumed_at_slot IS NULL')
    .andWhere('t.asset_id = :assetId', { assetId })
    .getRawMany();
  if (rows.length !== 1)
    return {
      cardanoAddress: null,
      hasDatum: false
    };
  return {
    cardanoAddress: rows[0].address,
    hasDatum: !!rows[0].datum
  };
};

const getSupply = async (queryRunner: QueryRunner, assetId: Cardano.AssetId) => {
  const asset = await queryRunner.manager
    .getRepository(AssetEntity)
    .findOne({ select: { supply: true }, where: { id: assetId } });
  if (!asset) return 0n;
  return asset.supply!;
};

export interface DefaultHandleParamsQueryResponse {
  handle: NonNullable<HandleEntity['handle']>;
  og: HandleMetadataEntity['og'];
  parent_handle_handle?: HandleEntity['handle'] | null;
  sameStakeCredential: boolean;
  samePaymentCredential: boolean;
  firstMintSlot: Cardano.Slot;
}

/**
 * @returns handles sorted by 'default_in_wallet' rules (default-first):
 * - OG
 * - shortest if no OG
 * - oldest if same length
 * - alphabetical if same age
 */
export const sortHandles = (
  handles: Omit<DefaultHandleParamsQueryResponse, 'sameStakeCredential' | 'samePaymentCredential'>[]
) => {
  if (handles.length <= 1) return handles;
  return sortBy(
    handles,
    (h) => !h.og,
    (h) => h.handle.length,
    (h) => h.firstMintSlot,
    (h) => h.handle
  );
};

export const queryHandlesByAddressCredentials = (
  queryRunner: QueryRunner,
  address: Cardano.PaymentAddress
): Promise<DefaultHandleParamsQueryResponse[]> =>
  queryRunner.manager
    .createQueryBuilder('address', 'input_address')
    .where('input_address.address=:address', { address })
    .innerJoin(
      'address',
      'a',
      `a.payment_credential_hash=input_address.payment_credential_hash 
        OR (input_address.stake_credential_hash IS NOT NULL AND a.stake_credential_hash=input_address.stake_credential_hash)`
    )
    .innerJoin('handle', 'h', 'a.address=h.cardano_address')
    .leftJoin('handle_metadata', 'm', 'm.handle=h.handle')
    .innerJoin('asset', 'asset', 'asset.id=h.asset_id')
    .select(
      `h.handle, h.parent_handle_handle, COALESCE(m.og, FALSE) as og,
      asset.first_mint_block_slot as "firstMintSlot",
      COALESCE((input_address.stake_credential_hash=a.stake_credential_hash), FALSE) as "sameStakeCredential",
      (input_address.payment_credential_hash=a.payment_credential_hash) as "samePaymentCredential"`
    )
    .getRawMany();

const hasStakeCredential = (address: Cardano.PaymentAddress) => {
  const decoded = Cardano.Address.fromString(address);
  return !!(decoded?.asBase()?.getStakeCredential() || decoded?.asPointer()?.getStakePointer());
};

const includeIfNotPresent = (
  dbHandles: DefaultHandleParamsQueryResponse[],
  { handle, isOG, address }: { handle: Handle; isOG: boolean; address: Cardano.PaymentAddress },
  skipIfNoStakeCredential = false
) => {
  const sameStakeCredential = hasStakeCredential(address);
  if (skipIfNoStakeCredential && !sameStakeCredential) {
    return dbHandles;
  }
  if (!dbHandles.some((h) => h.handle === handle)) {
    return [
      ...dbHandles,
      {
        firstMintSlot: Cardano.Slot(Number.POSITIVE_INFINITY),
        handle,
        og: isOG,
        samePaymentCredential: true,
        sameStakeCredential
      }
    ];
  }
  return dbHandles;
};

const getDefaultInWalletAndUpdateOtherHandles = async (
  queryRunner: QueryRunner,
  handle: Handle,
  isOG: boolean,
  address: Cardano.PaymentAddress
): Promise<Required<Pick<HandleEntity, 'defaultForPaymentCredential' | 'defaultForStakeCredential'>>> => {
  const allWalletHandles: Array<DefaultHandleParamsQueryResponse> = await queryHandlesByAddressCredentials(
    queryRunner,
    address
  );
  const byStakeCredential = sortHandles(
    includeIfNotPresent(
      allWalletHandles.filter((h) => h.sameStakeCredential),
      { address, handle, isOG },
      true
    )
  );
  const byPaymentCredential = sortHandles(
    includeIfNotPresent(
      allWalletHandles.filter((h) => h.samePaymentCredential),
      { address, handle, isOG }
    )
  );

  const handleRepo = queryRunner.manager.getRepository(HandleEntity);
  if (byPaymentCredential[0].handle === handle) {
    await handleRepo.update(
      { handle: In(byPaymentCredential.map((h) => h.handle)) },
      { defaultForPaymentCredential: handle }
    );
  }
  if (byStakeCredential[0]?.handle === handle) {
    await handleRepo.update(
      { handle: In(byStakeCredential.map((h) => h.handle)) },
      { defaultForStakeCredential: handle }
    );
  }

  return {
    defaultForPaymentCredential: byPaymentCredential[0].handle,
    defaultForStakeCredential: byStakeCredential[0]?.handle
  };
};

const rollForward = async ({ handles, queryRunner, handleMetadata }: HandleEventParams) => {
  const handleRepository = queryRunner.manager.getRepository(HandleEntity);

  for (const { assetId, handle, policyId, latestOwnerAddress, datum, totalSupply, parentHandle } of handles) {
    if (totalSupply === 1n) {
      if (typeof parentHandle === 'string' && !(await handleRepository.exist({ where: { handle: parentHandle } }))) {
        // Can't rely on (or catch) the error, because there is no easy way to resume a failed postgres transaction
        return;
      }
      // if !address then it's burning it, otherwise transferring
      const { cardanoAddress, hasDatum } = latestOwnerAddress
        ? { cardanoAddress: latestOwnerAddress, hasDatum: !!datum }
        : await getOwner(queryRunner, assetId);
      const isOG = handleMetadata.find((m) => m.handle === handle)?.og || false;
      const defaultInWallet = cardanoAddress
        ? await getDefaultInWalletAndUpdateOtherHandles(queryRunner, handle, isOG, cardanoAddress)
        : {};
      await handleRepository.upsert(
        {
          asset: assetId,
          cardanoAddress,
          handle,
          hasDatum,
          parentHandle,
          policyId,
          ...defaultInWallet
        },
        { conflictPaths: { handle: true } }
      );
    } else {
      // Handles must be non-fungible, so while we cannot stop the double mint or treat it as an error, we can invalidate the previous address.
      await handleRepository.update({ handle }, { cardanoAddress: null });
    }
  }
};

const rollBackward = async ({ handles, queryRunner }: HandleEventParams) => {
  const handleRepository = queryRunner.manager.getRepository(HandleEntity);
  for (const { assetId, handle, totalSupply } of handles) {
    const newOwnerAddressAndDatum =
      totalSupply === 1n ? await getOwner(queryRunner, assetId) : { cardanoAddress: null, hasDatum: false };
    await handleRepository.update({ handle }, newOwnerAddressAndDatum);
  }
};

const withTotalSupplies = (
  queryRunner: QueryRunner,
  handles: Mappers.HandleOwnership[],
  mintedAssetTotalSupplies: WithMintedAssetSupplies['mintedAssetTotalSupplies']
): Promise<HandleWithTotalSupply[]> =>
  Promise.all(
    handles.map(
      async (handle): Promise<HandleWithTotalSupply> => ({
        ...handle,
        totalSupply: mintedAssetTotalSupplies[handle.assetId] || (await getSupply(queryRunner, handle.assetId))
      })
    )
  );

export const willStoreHandles = ({ handles }: Mappers.WithHandles) => handles.length > 0;

export const storeHandles = typeormOperator<Mappers.WithHandles & WithMintedAssetSupplies & Mappers.WithHandleMetadata>(
  async ({ handles, queryRunner, eventType, block, mintedAssetTotalSupplies, handleMetadata }) => {
    const handleEventParams: HandleEventParams = {
      block,
      handleMetadata,
      handles: await withTotalSupplies(queryRunner, handles, mintedAssetTotalSupplies),
      queryRunner
    };

    eventType === ChainSyncEventType.RollForward
      ? await rollForward(handleEventParams)
      : await rollBackward(handleEventParams);
  }
);
