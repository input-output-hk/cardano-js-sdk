import { CurrentPoolMetricsEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CurrentStakePollMetricsAttributesMigrations1698174358997 implements MigrationInterface {
  static entity = CurrentPoolMetricsEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "current_pool_metrics" DROP COLUMN "apy"');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ADD "last_ros" numeric');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ADD "ros" numeric');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "slot" DROP NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "minted_blocks" DROP NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "live_delegators" DROP NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "active_stake" DROP NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "live_stake" DROP NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "live_pledge" DROP NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "live_saturation" DROP NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "active_size" DROP NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "live_size" DROP NOT NULL');
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "live_size" SET NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "active_size" SET NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "live_saturation" SET NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "live_pledge" SET NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "live_stake" SET NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "active_stake" SET NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "live_delegators" SET NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "minted_blocks" SET NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ALTER COLUMN "slot" SET NOT NULL');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" DROP COLUMN "ros"');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" DROP COLUMN "last_ros"');
    await queryRunner.query('ALTER TABLE "current_pool_metrics" ADD "apy" numeric NOT NULL');
  }
}
