import { HandleEntity } from '@cardano-sdk/projection-typeorm';
import { MigrationInterface, QueryRunner } from 'typeorm';

export class HandleParentMigration1700556589063 implements MigrationInterface {
  static entity = HandleEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "handle" ADD COLUMN "parent_handle_handle" character varying');
    await queryRunner.query(
      'ALTER TABLE "handle" ADD CONSTRAINT "FK_handle_parent_handle_handle" FOREIGN KEY ("parent_handle_handle") REFERENCES "handle"("handle") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "handle" DROP CONSTRAINT "FK_handle_parent_handle_handle"');
    await queryRunner.query('ALTER TABLE "handle" DROP COLUMN "parent_handle_handle"');
  }
}
