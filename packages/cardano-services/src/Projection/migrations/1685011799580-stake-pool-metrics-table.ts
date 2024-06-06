import { CurrentPoolMetricsEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class PoolMetricsMigrations1685011799580 implements MigrationInterface {
  static entity = CurrentPoolMetricsEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE TABLE "current_pool_metrics" ("stake_pool_id" character(56) NOT NULL, "slot" integer NOT NULL, "minted_blocks" integer NOT NULL, "live_delegators" integer NOT NULL, "active_stake" bigint NOT NULL, "live_stake" bigint NOT NULL, "live_pledge" bigint NOT NULL, "live_saturation" numeric NOT NULL, "active_size" numeric NOT NULL, "live_size" numeric NOT NULL, "apy" numeric NOT NULL, CONSTRAINT "PK_current_pool_metrics_stake_pool_id" PRIMARY KEY ("stake_pool_id"))'
    );
    await queryRunner.query(
      'ALTER TABLE "current_pool_metrics" ADD CONSTRAINT "FK_current_pool_metrics_stake_pool_id" FOREIGN KEY ("stake_pool_id") REFERENCES "stake_pool"("id") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'ALTER TABLE "current_pool_metrics" DROP CONSTRAINT "FK_current_pool_metrics_stake_pool_id"'
    );
    await queryRunner.query('DROP TABLE "current_pool_metrics"');
  }
}
