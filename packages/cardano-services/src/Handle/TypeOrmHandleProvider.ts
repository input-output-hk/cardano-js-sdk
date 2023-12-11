import {
  Cardano,
  HandleProvider,
  HandleResolution,
  Point,
  ProviderError,
  ProviderFailure,
  ResolveHandlesArgs
} from '@cardano-sdk/core';
import { HandleEntity, HandleMetadataEntity, NftMetadataEntity } from '@cardano-sdk/projection-typeorm';
import { In } from 'typeorm';
import { InMemoryCache } from '../InMemoryCache';
import { TypeormProvider, TypeormProviderDependencies } from '../util/TypeormProvider';

export type TypeOrmHandleProviderDependencies = TypeormProviderDependencies;

export const emptyStringHandleResolutionRequestError = () =>
  new ProviderError(ProviderFailure.BadRequest, undefined, "Empty string handle can't be resolved");

export class TypeOrmHandleProvider extends TypeormProvider implements HandleProvider {
  inMemoryCache: InMemoryCache;

  constructor(deps: TypeOrmHandleProviderDependencies) {
    super('TypeOrmHandleProvider', deps);
    this.inMemoryCache = new InMemoryCache(0);
  }

  async resolveHandles(args: ResolveHandlesArgs) {
    const { handles } = args;

    for (const handle of handles) if (!handle) throw emptyStringHandleResolutionRequestError();

    return this.withDataSource(async (dataSource) => {
      const queryRunner = dataSource.createQueryRunner();
      const query = 'SELECT hash, slot FROM block WHERE slot = (SELECT MAX(slot) FROM block)';
      const resolvedAt = <Point>(await queryRunner.query(query))[0];

      await queryRunner.release();

      const mapEntity = async (entity: HandleEntity | undefined): Promise<HandleResolution | null> => {
        if (!entity) return null;
        if (!entity.cardanoAddress) {
          this.logger.warn(`${entity.handle} has no associated address, which could be the result of a double mint.`);
          return null;
        }

        const {
          cardanoAddress,
          handle,
          hasDatum,
          parentHandle,
          policyId,
          defaultForPaymentCredential,
          defaultForStakeCredential,
          asset
        } = entity;

        const nftMetadataRepo = dataSource.getRepository(NftMetadataEntity);
        const handleMetadataRepo = dataSource.getRepository(HandleMetadataEntity);
        const [nftMetadataEntity, handleMetadataEntity] = await Promise.all([
          nftMetadataRepo.findOne({
            order: { id: 'DESC' },
            select: { id: true, image: true },
            where: { userTokenAssetId: asset!.id }
          }),
          handleMetadataRepo.findOne({
            order: { id: 'DESC' },
            select: { backgroundImage: true, id: true, profilePicImage: true },
            where: { handle }
          })
        ]);

        return {
          backgroundImage: handleMetadataEntity?.backgroundImage || undefined,
          cardanoAddress,
          defaultForPaymentCredential: defaultForPaymentCredential || undefined,
          defaultForStakeCredential: defaultForStakeCredential || undefined,
          handle: handle!,
          hasDatum: !!hasDatum,
          image: nftMetadataEntity?.image,
          parentHandle: parentHandle?.handle,
          policyId: policyId!,
          profilePic: handleMetadataEntity?.profilePicImage || undefined,
          resolvedAt
        };
      };

      const entities = await dataSource.getRepository(HandleEntity).find({
        loadRelationIds: { disableMixedMap: true },
        where: { handle: In(handles) }
      });

      return Promise.all(handles.map((handle) => mapEntity(entities.find((entity) => entity.handle === handle))));
    });
  }

  async getPolicyIds(): Promise<Cardano.PolicyId[]> {
    return this.withDataSource(async (dataSource) => {
      const columnName = 'policy_id';
      const fetchPolicyIdsFromDB = async () => {
        const distinctPolicyIds = await dataSource
          .getRepository(HandleEntity)
          .createQueryBuilder('handle')
          .select(`DISTINCT ${columnName}`, columnName)
          .getRawMany();
        const policyIds = distinctPolicyIds.map((row) => row[columnName]);

        if (policyIds.length === 0) {
          throw new Error('Value from the database is 0');
        }

        return policyIds;
      };

      try {
        return this.inMemoryCache.get('policyIds', fetchPolicyIdsFromDB);
      } catch (error) {
        if (error instanceof Error && error.message === 'Value from the database is 0') {
          return [];
        }
        throw error;
      }
    });
  }
}
