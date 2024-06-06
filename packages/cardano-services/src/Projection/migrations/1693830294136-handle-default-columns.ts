import { HandleEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class HandleDefaultMigrations1693830294136 implements MigrationInterface {
  static entity = HandleEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "handle" ADD "default_for_stake_credential" character varying');
    await queryRunner.query('ALTER TABLE "handle" ADD "default_for_payment_credential" character varying');
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "handle" DROP COLUMN "default_for_payment_credential"');
    await queryRunner.query('ALTER TABLE "handle" DROP COLUMN "default_for_stake_credential"');
  }
}
