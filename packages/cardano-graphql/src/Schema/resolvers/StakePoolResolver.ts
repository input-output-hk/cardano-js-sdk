import { ArrayMinSize } from 'class-validator';
import { Args, ArgsType, Field, Query, Resolver } from 'type-graphql';
import { Inject, Service } from 'typedi';
import { ServiceType, StakePool, StakePoolSearchService } from '../types';

@ArgsType()
class QueryStakePoolArgs {
  @ArrayMinSize(1)
  @Field(() => [String], { description: 'an array of partial pool data: bech32 ID, name, ticker' })
  fragments: string[];
}

@Service()
@Resolver(() => StakePool)
export class StakePoolResolver {
  #stakePoolSearchService: StakePoolSearchService;
  constructor(@Inject(ServiceType.StakePoolSearch) stakePoolSearchService: StakePoolSearchService) {
    this.#stakePoolSearchService = stakePoolSearchService;
  }

  @Query(() => [StakePool], { description: 'Query stake pools that match any fragment' })
  async queryStakePools(
    @Args()
    { fragments }: QueryStakePoolArgs
  ): Promise<StakePool[]> {
    return this.#stakePoolSearchService.queryStakePools(fragments);
  }
}
