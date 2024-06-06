import { PoolRewardsEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class PoolRewardsTableMigrations1698175956871 implements MigrationInterface {
  static entity = PoolRewardsEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE TABLE "pool_rewards" ("id" SERIAL NOT NULL, "stake_pool_id" character(56) NOT NULL, "epoch_length" integer NOT NULL, "epoch_no" integer NOT NULL, "delegators" integer NOT NULL, "pledge" bigint NOT NULL, "active_stake" numeric(20,0) NOT NULL, "member_active_stake" numeric(20,0) NOT NULL, "leader_rewards" numeric(20,0) NOT NULL, "member_rewards" numeric(20,0) NOT NULL, "rewards" numeric(20,0) NOT NULL, "version" integer NOT NULL, CONSTRAINT "UQ_pool_rewards_epoch_no_stake_pool_id}" UNIQUE ("epoch_no", "stake_pool_id"), CONSTRAINT "PK_pool_rewards_id" PRIMARY KEY ("id"))'
    );
    await queryRunner.query(
      'ALTER TABLE "pool_rewards" ADD CONSTRAINT "FK_pool_rewards_stake_pool_id" FOREIGN KEY ("stake_pool_id") REFERENCES "stake_pool"("id") ON DELETE NO ACTION ON UPDATE NO ACTION'
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "pool_rewards" DROP CONSTRAINT "FK_pool_rewards_stake_pool_id"');
    await queryRunner.query('DROP TABLE "pool_rewards"');
  }
}
