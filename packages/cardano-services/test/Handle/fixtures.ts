import { HandleEntity, HandleMetadataEntity, createDataSource } from '@cardano-sdk/projection-typeorm';
import { firstValueFrom } from 'rxjs';
import { getEntities } from '../../src/index.js';
import { logger } from '@cardano-sdk/util-dev';
import type { DataSource } from 'typeorm';
import type { Observable } from 'rxjs';
import type { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';

const queryHandle = (dataSource: DataSource) => dataSource.createQueryBuilder().from(HandleEntity, 'h');

export const createHandleFixtures = async (connectionConfig$: Observable<PgConnectionConfig>) => {
  const entities = getEntities(['handle', 'handleMetadata']);
  const dataSource = createDataSource({ connectionConfig: await firstValueFrom(connectionConfig$), entities, logger });
  await dataSource.initialize();

  const cip25HandleEntity = await queryHandle(dataSource)
    .innerJoin(HandleMetadataEntity, 'm', 'm.handle=h.handle')
    .where('h.cardano_address IS NOT NULL AND m.output_id IS NULL')
    .getRawOne<HandleEntity>();
  const handleWithProfileAndBackgroundPicsEntity = await queryHandle(dataSource)
    .innerJoin(HandleMetadataEntity, 'm', 'm.handle=h.handle')
    .where('h.cardano_address IS NOT NULL AND m.background_image IS NOT NULL AND m.profile_pic_image IS NOT NULL')
    .getRawOne<HandleEntity>();

  await dataSource.destroy();
  return {
    cip25Handle: cip25HandleEntity!.handle!,
    handleWithProfileAndBackgroundPics: handleWithProfileAndBackgroundPicsEntity!.handle!
  };
};

type PromiseT<P> = P extends Promise<infer T> ? T : never;
export type HandleFixtures = PromiseT<ReturnType<typeof createHandleFixtures>>;
