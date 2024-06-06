import { PoolDelistedEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class PoolDelistedTableMigration1695899010515 implements MigrationInterface {
  static entity = PoolDelistedEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "pool_delisted"
                             (

                                 "stake_pool_id" character(56) NOT NULL,
                                 CONSTRAINT "PK_pool_delisted_stake_pool_id" PRIMARY KEY ("stake_pool_id")
                             )`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP TABLE "pool_delisted"');
  }
}
