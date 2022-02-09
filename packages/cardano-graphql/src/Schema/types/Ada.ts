import { Block } from './Block';
import { Cardano } from '@cardano-sdk/core';
import { Field, Int, ObjectType } from 'type-graphql';
import { Int64 } from './util';

@ObjectType()
export class CoinSupply {
  @Field(() => Int64)
  circulating: Cardano.Lovelace;
  @Field(() => Int64)
  max: Cardano.Lovelace;
  @Field(() => Int64)
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
