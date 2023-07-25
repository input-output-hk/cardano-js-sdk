import { Asset, Cardano } from '@cardano-sdk/core';
import { AssetEntity } from './Asset.entity';
import { BlockEntity } from './Block.entity';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { OnDeleteCascadeRelationOptions, OnDeleteSetNullRelationOptions } from './util';
import { serializableObj } from './transformers';

export enum NftMetadataType {
  CIP25 = 'CIP-0025',
  CIP68 = 'CIP-0068'
}

@Entity()
export class NftMetadataEntity {
  @PrimaryGeneratedColumn()
  id?: number;
  @Column()
  name?: string;
  @Column({ nullable: true })
  description?: string;
  @Column()
  image?: string;
  @Column({ nullable: true })
  mediaType?: string;
  @Column({ nullable: true, type: 'jsonb' })
  files?: Asset.NftMetadataFile[];
  @Column({ enum: NftMetadataType })
  type: NftMetadataType;
  @Column({ nullable: true, transformer: [serializableObj], type: 'jsonb' })
  otherProperties?: Map<string, Cardano.Metadatum>;
  @ManyToOne(() => AssetEntity, OnDeleteCascadeRelationOptions)
  @JoinColumn()
  /**
   * Same as userTokenAsset for cip25
   * Reference NFT for cip68
   */
  parentAsset?: AssetEntity;
  @ManyToOne(() => AssetEntity, OnDeleteSetNullRelationOptions)
  userTokenAsset?: AssetEntity;
  @ManyToOne(() => BlockEntity, OnDeleteCascadeRelationOptions)
  createdAt?: BlockEntity;
}
