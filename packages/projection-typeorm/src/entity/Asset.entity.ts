import { BlockEntity } from './Block.entity';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, ManyToOne, OneToOne, PrimaryColumn } from 'typeorm';
import { NftMetadataEntity } from './NftMetadata.entity';
import { OnDeleteCascadeRelationOptions, OnDeleteSetNullRelationOptions } from './util';
import { parseBigInt } from './transformers';

@Entity()
export class AssetEntity {
  @PrimaryColumn('varchar')
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
