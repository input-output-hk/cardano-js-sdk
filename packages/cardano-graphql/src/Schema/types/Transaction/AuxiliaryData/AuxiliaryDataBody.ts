/* eslint-disable no-use-before-define */
import { AuxiliaryData } from './AuxiliaryData';
import { AuxiliaryScript } from './AuxiliaryScript';
import { Directive, Field, ObjectType } from 'type-graphql';
import { KeyValueMetadatum } from './Metadatum';

@ObjectType()
export class AuxiliaryDataBody {
  @Field(() => [KeyValueMetadatum], { nullable: true })
  blob?: KeyValueMetadatum[];
  @Directive('@hasInverse(field: auxiliaryDataBody)')
  @Field(() => [AuxiliaryScript], { nullable: true })
  scripts?: AuxiliaryScript[];
  @Field(() => AuxiliaryData)
  auxiliaryData: AuxiliaryData;
}
