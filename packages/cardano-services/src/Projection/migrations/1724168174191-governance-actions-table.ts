import { GovernanceActionEntity } from '@cardano-sdk/projection-typeorm';
import { MigrationInterface, QueryRunner } from 'typeorm';

export class GovernanceActionMigration1724168174191 implements MigrationInterface {
  static entity = GovernanceActionEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE TABLE "governance_action" ("id" SERIAL NOT NULL, "tx_id" character varying NOT NULL, "index" smallint NOT NULL, "stake_credential_hash" character varying NOT NULL, "anchor_url" character varying NOT NULL, "anchor_hash" character(64), "deposit" bigint NOT NULL, "action" character varying NOT NULL, "block_slot" integer NOT NULL, CONSTRAINT "PK_governance_action_id" PRIMARY KEY ("id"))'
    );
    await queryRunner.query(
      'ALTER TABLE "governance_action" ADD CONSTRAINT "FK_governance_action_block_slot" FOREIGN KEY ("block_slot") REFERENCES "block"("slot") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "governance_action" DROP CONSTRAINT "FK_governance_action_block_slot"');
    await queryRunner.query('DROP TABLE "governance_action"');
  }
}
