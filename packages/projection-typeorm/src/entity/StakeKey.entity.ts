import { Ed25519KeyHashHex } from '@cardano-sdk/crypto';
import { Entity, PrimaryColumn } from 'typeorm';

@Entity()
export class StakeKeyEntity {
  @PrimaryColumn({ length: 56, type: 'char' })
  hash?: Ed25519KeyHashHex;
}
