import { Asset, Cardano } from '@cardano-sdk/core';
import { AssetEntity } from './Asset.entity';
import { BlockEntity } from './Block.entity';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { OnDeleteCascadeRelationOptions, OnDeleteSetNullRelationOptions } from './util';
import { sanitizeString, serializableObj } from './transformers';

export enum NftMetadataType {
  CIP25 = 'CIP-0025',
  CIP68 = 'CIP-0068'
}

@Entity()
export class NftMetadataEntity {
  @PrimaryGeneratedColumn()
  id?: number;
  @Column({ transformer: sanitizeString })
  name?: string;
  @Column({ nullable: true, transformer: sanitizeString, type: 'varchar' })
  description?: string | null;
  @Column({ transformer: sanitizeString })
  image?: Asset.Uri;
  @Column({ nullable: true, transformer: sanitizeString, type: 'varchar' })
  mediaType?: string | null;
  @Column({ nullable: true, type: 'jsonb' })
  files?: Asset.NftMetadataFile[] | null;
  @Column({ enum: NftMetadataType, type: 'enum' })
  type: NftMetadataType;
  @Column({ nullable: true, transformer: [serializableObj], type: 'jsonb' })
  otherProperties?: Map<string, Cardano.Metadatum> | null;
  @ManyToOne(() => AssetEntity, OnDeleteCascadeRelationOptions)
  @JoinColumn()
  /** Same as userTokenAsset for cip25 Reference NFT for cip68 */
  parentAsset?: AssetEntity;
  @ManyToOne(() => AssetEntity, OnDeleteSetNullRelationOptions)
  userTokenAsset?: AssetEntity | null;
  @Column('varchar', { nullable: true })
  userTokenAssetId?: Cardano.AssetId | null;
  @ManyToOne(() => BlockEntity, OnDeleteCascadeRelationOptions)
  createdAt?: BlockEntity;
}
