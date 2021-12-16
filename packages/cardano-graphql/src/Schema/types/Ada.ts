import { Block } from './Block';
import { Cardano } from '@cardano-sdk/core';
import { Field, Int, ObjectType } from 'type-graphql';

@ObjectType()
export class CoinSupply {
  @Field(() => String)
  circulating: Cardano.Lovelace;
  @Field(() => String)
  max: Cardano.Lovelace;
  @Field(() => String)
  total: Cardano.Lovelace;
}

@ObjectType()
export class Ada {
  @Field(() => Int)
  sinceBlockNo: number;
  @Field(() => Block)
  sinceBlock: Block;
  @Field(() => CoinSupply)
  supply: CoinSupply;
}
