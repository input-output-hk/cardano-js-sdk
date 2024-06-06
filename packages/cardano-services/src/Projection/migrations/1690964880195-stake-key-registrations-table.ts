import { StakeKeyRegistrationEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class StakeKeyRegistrationsTableMigrations1690964880195 implements MigrationInterface {
  static entity = StakeKeyRegistrationEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE TABLE "stake_key_registration" ("id" bigint NOT NULL, "stake_key_hash" character(56) NOT NULL, "block_slot" integer NOT NULL, CONSTRAINT "PK_stake_key_registration_id" PRIMARY KEY ("id"))'
    );
    await queryRunner.query(
      'CREATE INDEX "IDX_stake_key_registration_stake_key_hash" ON "stake_key_registration" ("stake_key_hash") '
    );
    await queryRunner.query(
      'ALTER TABLE "stake_key_registration" ADD CONSTRAINT "FK_stake_key_registration_block_slot" FOREIGN KEY ("block_slot") REFERENCES "block"("slot") ON DELETE CASCADE ON UPDATE NO ACTION'
    );

    await queryRunner.query('ALTER TABLE "address" ADD "registration_id" bigint');
    await queryRunner.query(
      'ALTER TABLE "address" ADD CONSTRAINT "FK_address_registration_id" FOREIGN KEY ("registration_id") REFERENCES "stake_key_registration"("id") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "address" DROP CONSTRAINT "FK_address_registration_id"');
    await queryRunner.query('ALTER TABLE "address" DROP COLUMN "registration_id"');

    await queryRunner.query(
      'ALTER TABLE "stake_key_registration" DROP CONSTRAINT "FK_stake_key_registration_block_slot"'
    );
    await queryRunner.query('DROP INDEX "public"."IDX_stake_key_registration_stake_key_hash"');
    await queryRunner.query('DROP TABLE "stake_key_registration"');
  }
}
