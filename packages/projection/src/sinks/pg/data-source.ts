import 'reflect-metadata';
import { DataSource } from 'typeorm';
import { StabilityWindowBlockEntity } from './entity/StabilityWindowBlock.entity';
import { StabilityWindowBlockSubscriber } from './entity/StabilityWindowBlock.subscriber';

export const AppDataSource = new DataSource({
  database: 'test',
  entities: [StabilityWindowBlockEntity],
  host: 'mhvm',
  logging: true,
  migrations: [],
  password: 'test',
  port: 5432,
  subscribers: [StabilityWindowBlockSubscriber],
  synchronize: true, // to be updated once migrations are in place
  type: 'postgres',
  username: 'test'
});
