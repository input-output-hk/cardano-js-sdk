/* eslint-disable no-use-before-define */
import { AuxiliaryData } from './AuxiliaryData';
import { Directive, Field, ObjectType } from 'type-graphql';
import { KeyValueMetadatum } from './Metadatum';
import { Script } from './Script';

@ObjectType()
export class AuxiliaryDataBody {
  @Field(() => [KeyValueMetadatum], { nullable: true })
  blob?: KeyValueMetadatum[];
  @Directive('@hasInverse(field: auxiliaryDataBody)')
  @Field(() => [Script], { nullable: true })
  scripts?: Script[];
  @Field(() => AuxiliaryData)
  auxiliaryData: AuxiliaryData;
}
