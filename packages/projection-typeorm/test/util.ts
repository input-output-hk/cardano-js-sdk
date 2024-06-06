import { Cardano } from '@cardano-sdk/core';
import { NEVER, concat, of } from 'rxjs';
import { createDataSource } from '../src/index.js';
import { generateRandomHexString, logger } from '@cardano-sdk/util-dev';
import type { BlockEntity, CreateDataSourceProps } from '../src/index.js';

export const connectionConfig = {
  database: 'projection',
  host: '127.0.0.1',
  password: 'doNoUseThisSecret!',
  port: 5432,
  username: 'postgres'
};

export const connectionConfig$ = concat(of(connectionConfig), NEVER);

export const initializeDataSource = async (
  props: Pick<CreateDataSourceProps, 'entities' | 'extensions' | 'devOptions'>
) => {
  const dataSource = createDataSource({
    connectionConfig,
    devOptions: props.devOptions || { dropSchema: true, synchronize: true },
    logger,
    ...props
  });
  await dataSource.initialize();
  return dataSource;
};

export const createBlockHeader = (height: number): Cardano.PartialBlockHeader => ({
  blockNo: Cardano.BlockNo(height),
  hash: Cardano.BlockId(generateRandomHexString(64)),
  slot: Cardano.Slot(height * 20)
});

export const createBlockEntity = (header: Cardano.PartialBlockHeader): BlockEntity => ({
  hash: header.hash,
  height: header.blockNo,
  slot: header.slot
});
