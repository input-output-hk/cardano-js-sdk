import { AppDataSource } from './pg/data-source';

export * from './types';
export * from './inMemory';
export * from './util';

AppDataSource.initialize().catch((error) => console.error(error));
