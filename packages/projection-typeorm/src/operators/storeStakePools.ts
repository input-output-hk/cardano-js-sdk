import { Cardano, ChainSyncEventType, EraSummary, epochSlotsCalc } from '@cardano-sdk/core';
import { In, Not, QueryRunner, Repository } from 'typeorm';
import { Mappers, ProjectionEvent } from '@cardano-sdk/projection';
import {
  MaxCertificatePointerIdCertificateIndex as MaxCertificatePointerIdCertIndex,
  MaxCertificatePointerIdTxIndex,
  certificatePointerToId,
  typeormOperator
} from './util';
import { PoolRegistrationEntity, PoolRetirementEntity, StakePoolEntity } from '../entity';
import { WithTypeormContext } from './withTypeormTransaction';
import omit from 'lodash/omit';

type Event = ProjectionEvent<WithTypeormContext & Mappers.WithStakePools>;

const insertMissingStakePools = async ({ stakePools: { updates }, queryRunner }: Event) => {
  if (updates.length === 0) return;
  const stakePoolsRepository = queryRunner.manager.getRepository(StakePoolEntity);
  const existingStakePoolEntities = await stakePoolsRepository.find({
    select: { id: true },
    where: { id: In(updates.map((update) => update.poolParameters.id)) }
  });
  await stakePoolsRepository.insert(
    updates
      .filter(
        (update) => !existingStakePoolEntities.some((existingEntity) => existingEntity.id === update.poolParameters.id)
      )
      .map(({ poolParameters: { id } }) =>
        stakePoolsRepository.create({ id, status: Cardano.StakePoolStatus.Activating })
      )
  );
};

const insertPoolUpdates = async ({ block: { header }, stakePools: { updates }, queryRunner }: Event) => {
  if (updates.length === 0) return;
  const poolUpdatesRepository = queryRunner.manager.getRepository(PoolRegistrationEntity);
  const poolUpdateEntities = updates.map(({ poolParameters, source }) =>
    poolUpdatesRepository.create({
      id: certificatePointerToId(source),
      ...omit(poolParameters, ['id', 'metadataJson']),
      block: {
        slot: header.slot
      },
      marginPercent: poolParameters.margin.numerator / poolParameters.margin.denominator,
      metadataHash: poolParameters.metadataJson?.hash,
      metadataUrl: poolParameters.metadataJson?.url,
      stakePool: {
        id: poolParameters.id
      }
    })
  );
  await poolUpdatesRepository.insert(poolUpdateEntities);
};

const insertPoolRetirements = async ({ stakePools: { retirements }, queryRunner, block: { header } }: Event) => {
  if (retirements.length === 0) return;
  const poolRetirementsRepository = queryRunner.manager.getRepository(PoolRetirementEntity);
  const poolRetirementEntities = retirements.map(({ epoch, poolId, source }) =>
    poolRetirementsRepository.create({
      block: {
        slot: header.slot
      },
      id: certificatePointerToId(source),
      retireAtEpoch: epoch,
      stakePool: { id: poolId }
    })
  );
  await poolRetirementsRepository.insert(poolRetirementEntities);
};

const findPoolRegistrationId = async (
  registrationsRepository: Repository<PoolRegistrationEntity>,
  id: Cardano.PoolId,
  query: 'first' | 'last'
): Promise<bigint | null> => {
  const result = await registrationsRepository.find({
    order: { id: query === 'first' ? 'ASC' : 'DESC' },
    select: { id: true },
    take: 1,
    where: { stakePool: { id } }
  });
  return result.length > 0 ? BigInt(result[0].id!) : null;
};

const undoUpdateLatestRetirementAndRetiringStatus = async ({
  queryRunner,
  epochNo,
  eraSummaries,
  stakePools: { retirements }
}: Event) => {
  if (retirements.length === 0) return;
  const retirementsRepository = queryRunner.manager.getRepository(PoolRetirementEntity);
  const poolsRepository = queryRunner.manager.getRepository(StakePoolEntity);
  const registrationsRepository = queryRunner.manager.getRepository(PoolRegistrationEntity);
  const { firstSlot } = epochSlotsCalc(epochNo, eraSummaries);
  const epochStartId = certificatePointerToId({
    certIndex: Cardano.CertIndex(0),
    slot: firstSlot,
    txIndex: Cardano.TxIndex(0)
  });
  return Promise.all(
    retirements.map(async ({ poolId }) => {
      const lastRetirementResult = await retirementsRepository.find({
        order: { id: 'DESC' },
        select: { id: true },
        take: 1,
        where: { stakePool: { id: poolId } }
      });
      const lastRetirement: PoolRetirementEntity | undefined = lastRetirementResult[0];

      const firstRegistrationId = await findPoolRegistrationId(registrationsRepository, poolId, 'first');
      if (!firstRegistrationId) {
        // stake pool will be deleted in undoUpdateLatestRegistration
        return;
      }
      const status = await (async () => {
        if (!lastRetirement)
          return firstRegistrationId > epochStartId
            ? Cardano.StakePoolStatus.Activating
            : Cardano.StakePoolStatus.Active;
        const lastRegistrationId = await findPoolRegistrationId(registrationsRepository, poolId, 'last');
        return lastRegistrationId! > lastRetirement.id!
          ? Cardano.StakePoolStatus.Active
          : Cardano.StakePoolStatus.Retiring;
      })();

      await poolsRepository.update(poolId, {
        lastRetirement,
        status
      });
    })
  );
};

const undoUpdateLatestRegistration = ({ queryRunner, stakePools: { updates } }: Event) => {
  const poolsRepository = queryRunner.manager.getRepository(StakePoolEntity);
  const registrationsRepository = queryRunner.manager.getRepository(PoolRegistrationEntity);
  return Promise.all(
    updates.map(async ({ poolParameters: { id } }) => {
      const lastRegistrationId = await findPoolRegistrationId(registrationsRepository, id, 'last');
      await (lastRegistrationId
        ? poolsRepository.update(id, { lastRegistration: { id: lastRegistrationId } })
        : poolsRepository.delete(id));
    })
  );
};

const undoUpdateLatestCertificatesAndDeletePoolsWithZeroRegistrations = (evt: Event) =>
  Promise.all([undoUpdateLatestRegistration(evt), undoUpdateLatestRetirementAndRetiringStatus(evt)]);

const computeCertificateIdRange = (epochNo: Cardano.EpochNo, eraSummaries: EraSummary[]) => {
  const { firstSlot, lastSlot } = epochSlotsCalc(epochNo, eraSummaries);
  const minId = certificatePointerToId({
    certIndex: Cardano.CertIndex(0),
    slot: firstSlot,
    txIndex: Cardano.TxIndex(0)
  });
  const maxId = certificatePointerToId({
    certIndex: MaxCertificatePointerIdCertIndex,
    slot: lastSlot,
    txIndex: MaxCertificatePointerIdTxIndex
  });
  return { maxId, minId };
};

// Perf: we could add 'StakePoolEntity.firstPoolRegistration' to make this more efficient
const updatePoolStatusWhere = async (
  where: {
    firstRegisteredInEpoch: Cardano.EpochNo;
    currentStatus: Cardano.StakePoolStatus;
  },
  newStatus: Cardano.StakePoolStatus,
  dependencies: {
    queryRunner: QueryRunner;
    eraSummaries: EraSummary[];
  }
) => {
  if (where.firstRegisteredInEpoch < 0) return;
  const { minId, maxId } = computeCertificateIdRange(where.firstRegisteredInEpoch, dependencies.eraSummaries);
  const subQuery =
    newStatus === Cardano.StakePoolStatus.Active
      ? `
    WHERE sp.status='${where.currentStatus}' AND r1.id >= ${minId} AND r1.id <= ${maxId}
    AND (sp.last_retirement_id IS NULL OR sp.last_retirement_id < r1.id)
  `
      : `
    LEFT OUTER JOIN pool_registration r2 ON (sp.id = r2.stake_pool_id AND r1.id > r2.id)
    WHERE r2.id IS NULL AND sp.status='${where.currentStatus}' AND r1.id >= ${minId} AND r1.id <= ${maxId}
  `;
  const queryResult: Array<{ id: Cardano.PoolId }> = await dependencies.queryRunner.query(`
    SELECT sp.id
    FROM stake_pool sp
    JOIN pool_registration r1 ON (sp.id = r1.stake_pool_id)
    ${subQuery}
  `);
  if (queryResult.length > 0) {
    const stakePoolsRepository = dependencies.queryRunner.manager.getRepository(StakePoolEntity);
    await stakePoolsRepository.update(
      queryResult.map((pool) => pool.id),
      { status: newStatus }
    );
  }
};

const activateOnRollover = async ({ queryRunner, crossEpochBoundary, eraSummaries, epochNo }: Event) => {
  if (!crossEpochBoundary) return;
  await updatePoolStatusWhere(
    {
      currentStatus: Cardano.StakePoolStatus.Activating,
      firstRegisteredInEpoch: Cardano.EpochNo(epochNo - 2)
    },
    Cardano.StakePoolStatus.Active,
    { eraSummaries, queryRunner }
  );
};

const undoActivateOnRollover = async ({ queryRunner, eraSummaries, crossEpochBoundary, epochNo }: Event) => {
  if (!crossEpochBoundary) return;
  await updatePoolStatusWhere(
    {
      currentStatus: Cardano.StakePoolStatus.Active,
      firstRegisteredInEpoch: Cardano.EpochNo(epochNo - 1)
    },
    Cardano.StakePoolStatus.Activating,
    { eraSummaries, queryRunner }
  );
};

const findPoolsRetiringAtEpoch = (repository: Repository<StakePoolEntity>, epochNo: Cardano.EpochNo) =>
  repository.find({
    relations: { lastRetirement: true },
    select: { id: true },
    where: { lastRetirement: { retireAtEpoch: epochNo } }
  });

// Perf: could probably do it in a single UPDATE query
const retireOnRollover = async ({ queryRunner, crossEpochBoundary, epochNo }: Event) => {
  if (!crossEpochBoundary) return;
  const stakePoolsRepository = queryRunner.manager.getRepository(StakePoolEntity);
  const retiredPools = await findPoolsRetiringAtEpoch(stakePoolsRepository, epochNo);
  if (retiredPools.length > 0) {
    await stakePoolsRepository.update(
      retiredPools.map(({ id }) => id!),
      { status: Cardano.StakePoolStatus.Retired }
    );
  }
};

const undoRetireOnRollover = async ({ queryRunner, crossEpochBoundary, epochNo }: Event) => {
  if (!crossEpochBoundary) return;
  const stakePoolsRepository = queryRunner.manager.getRepository(StakePoolEntity);
  const retiredPools = await findPoolsRetiringAtEpoch(stakePoolsRepository, Cardano.EpochNo(epochNo + 1));
  if (retiredPools.length > 0) {
    await stakePoolsRepository.update(
      retiredPools.map(({ id }) => id!),
      { status: Cardano.StakePoolStatus.Retiring }
    );
  }
};

const updateLatestCertificates = async ({ queryRunner, stakePools: { updates, retirements } }: Event) => {
  const stakePoolsRepository = queryRunner.manager.getRepository(StakePoolEntity);
  await Promise.all([
    Promise.all(
      updates.map(({ poolParameters: { id }, source }) =>
        stakePoolsRepository.update(id, {
          lastRegistration: { id: certificatePointerToId(source) }
        })
      )
    ),
    Promise.all(
      retirements.map(({ poolId, source }) =>
        // Perf: if it's impossible to submit a retirement certificate for an already retired pool,
        // then we can just update by poolId without checking status
        stakePoolsRepository.update(
          {
            id: poolId,
            status: Not(Cardano.StakePoolStatus.Retired)
          },
          {
            lastRetirement: { id: certificatePointerToId(source) },
            status: Cardano.StakePoolStatus.Retiring
          }
        )
      )
    )
  ]);
};

const reactivateRetired = async ({ queryRunner, stakePools: { updates } }: Event) => {
  if (updates.length === 0) return;
  // TODO: after adding a test for this,
  // update to repository syntax using `lastRegistration: { id: GreaterThan(Raw(last_retirement_id)) }`
  await queryRunner.manager.query(`
    UPDATE stake_pool
    SET status='activating'
    WHERE status='retired' AND last_registration_id > last_retirement_id;
  `);
};

const rollForward = async (evt: Event) => {
  await Promise.all([activateOnRollover(evt), retireOnRollover(evt)]);
  await insertMissingStakePools(evt);
  await Promise.all([insertPoolUpdates(evt), insertPoolRetirements(evt)]);
  await updateLatestCertificates(evt);
  await reactivateRetired(evt);
};

const rollBackward = async (evt: Event) => {
  // PoolUpdates and PoolRetirements are already deleted via Block cascade
  await Promise.all([undoActivateOnRollover(evt), undoRetireOnRollover(evt)]);
  await undoUpdateLatestCertificatesAndDeletePoolsWithZeroRegistrations(evt);
};

export const storeStakePools = typeormOperator<Mappers.WithStakePools>(async (evt) => {
  await (evt.eventType === ChainSyncEventType.RollForward ? rollForward(evt) : rollBackward(evt));
});
