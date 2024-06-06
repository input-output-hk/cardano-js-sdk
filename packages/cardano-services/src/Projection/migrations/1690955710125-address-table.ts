import { AddressEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddressTableMigrations1690955710125 implements MigrationInterface {
  static entity = AddressEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      "CREATE TYPE \"public\".\"address_type_enum\" AS ENUM('0', '1', '2', '3', '4', '5', '6', '7', '8', '14', '15')"
    );
    await queryRunner.query(
      'CREATE TABLE "address" ("address" character varying NOT NULL, "type" "public"."address_type_enum" NOT NULL, "payment_credential_hash" character(56), "stake_credential_hash" character(56), CONSTRAINT "PK_address_address" PRIMARY KEY ("address"))'
    );
    await queryRunner.query(
      'CREATE INDEX "IDX_address_payment_credential_hash" ON "address" ("payment_credential_hash") '
    );
    await queryRunner.query('CREATE INDEX "IDX_address_stake_credential_hash" ON "address" ("stake_credential_hash") ');
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP INDEX "public"."IDX_address_stake_credential_hash"');
    await queryRunner.query('DROP INDEX "public"."IDX_address_payment_credential_hash"');
    await queryRunner.query('DROP TABLE "address"');
    await queryRunner.query('DROP TYPE "public"."address_type_enum"');
  }
}
