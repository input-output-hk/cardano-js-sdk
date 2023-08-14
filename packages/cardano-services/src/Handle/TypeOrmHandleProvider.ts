import {
  Cardano,
  HandleProvider,
  HandleResolution,
  Point,
  ProviderError,
  ProviderFailure,
  ResolveHandlesArgs
} from '@cardano-sdk/core';
import { HandleEntity } from '@cardano-sdk/projection-typeorm';
import { In } from 'typeorm';
import { InMemoryCache } from '../InMemoryCache';
import { TypeormProvider, TypeormProviderDependencies } from '../util/TypeormProvider';

export type TypeOrmHandleProviderDependencies = TypeormProviderDependencies;

const handleFields = ['cardanoAddress', 'handle', 'hasDatum', 'policyId'] as const;

type HandleFields = typeof handleFields[number];
type PartialHandleEntity = {
  [k in HandleFields]: Required<HandleEntity>[k];
};

const handleSelect = <{ [k in HandleFields]: true }>Object.fromEntries(handleFields.map((_) => [_, true]));

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

      const mapEntity = (entity: PartialHandleEntity | undefined): HandleResolution | null => {
        if (!entity) return null;

        const { cardanoAddress, handle, hasDatum, policyId } = entity;

        return { cardanoAddress, handle, hasDatum, policyId, resolvedAt };
      };

      const findOptions = { select: handleSelect, where: { handle: In(handles) } };
      const entities = await dataSource.getRepository<PartialHandleEntity>(HandleEntity).find(findOptions);

      return handles.map((handle) => mapEntity(entities.find((entity) => entity.handle === handle)));
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
