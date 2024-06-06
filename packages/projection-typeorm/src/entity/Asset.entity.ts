import { BlockEntity } from './Block.entity.js';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, ManyToOne, OneToOne, PrimaryColumn } from 'typeorm';
import { NftMetadataEntity } from './NftMetadata.entity.js';
import { OnDeleteCascadeRelationOptions, OnDeleteSetNullRelationOptions } from './util.js';
import { parseBigInt } from './transformers.js';

@Entity()
export class AssetEntity {
  @PrimaryColumn()
  id?: Cardano.AssetId;
  @Column({
    transformer: parseBigInt,
    type: 'decimal'
  })
  supply?: bigint;
  @ManyToOne(() => BlockEntity, OnDeleteCascadeRelationOptions)
  @JoinColumn()
  firstMintBlock?: BlockEntity;
  @OneToOne(() => NftMetadataEntity, OnDeleteSetNullRelationOptions)
  @JoinColumn()
  nftMetadata?: NftMetadataEntity | null;
}
