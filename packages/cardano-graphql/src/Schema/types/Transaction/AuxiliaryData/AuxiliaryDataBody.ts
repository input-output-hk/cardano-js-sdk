/* eslint-disable no-use-before-define */
import { AnyMetadatum, Metadatum } from './Metadatum';
import { AuxiliaryData } from './AuxiliaryData';
import { Directive, Field, ObjectType } from 'type-graphql';
import { Script } from './Script';

@ObjectType()
export class AuxiliaryDataBody {
  @Field(() => [Metadatum], { nullable: true })
  blob?: AnyMetadatum[];
  @Directive('@hasInverse(field: auxiliaryDataBody)')
  @Field(() => [Script], { nullable: true })
  scripts?: Script[];
  @Field(() => AuxiliaryData)
  auxiliaryData: AuxiliaryData;
}
