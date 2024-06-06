/* eslint-disable @typescript-eslint/no-explicit-any */
import type { MigrationInterface, QueryRunner } from 'typeorm';

export abstract class ProjectionMigration implements MigrationInterface {
  abstract up(queryRunner: QueryRunner): Promise<any>;
  abstract down(queryRunner: QueryRunner): Promise<any>;
  static entity: Function;
}
