import { Field, ObjectType } from 'type-graphql';

@ObjectType()
export class AssetSupply {
  @Field(() => String)
  circulating: bigint;
  @Field(() => String)
  max: bigint;
  @Field(() => String, { nullable: true })
  total?: bigint;
}

@ObjectType()
export class Ada {
  @Field(() => AssetSupply)
  supply: AssetSupply;
}
