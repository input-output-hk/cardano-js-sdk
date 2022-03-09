import { Schema as Ogmios } from '@cardano-ogmios/client';
import dgraph from 'dgraph-js';

export type ModuleState = null | 'initializing' | 'initialized';

export type DQL = string;
type Variable = string;

export type QueryVariables = {
  $assetIds?: string;
};
export interface QueryResult<Variables> {
  query: DQL;
  variables?: Variables;
}
export interface RollBackwardContext {
  point: Ogmios.Point;
  tip: Ogmios.Tip;
}

export interface RollForwardContext {
  txn: dgraph.Txn;
  block: Ogmios.Block;
}

export interface Upsert {
  mutations: { [k: string]: any };
  variables?: {
    defines: Variable[];
    dependencies?: Variable[];
    dql: DQL;
  };
}

// export interface CombinedQueryResult {}

// export interface CombinedProcessingResult {}

export interface BlockHandler {
  id: string;
  query?: (ctx: RollForwardContext) => Promise<QueryResult<QueryVariables>>;
  // process?: (ctx: RollForwardContext, queryResult?: CombinedQueryResult) => Promise<Partial<CombinedProcessingResult>>;
  process?: (ctx: RollForwardContext, queryResult?: any) => Promise<Partial<any>>;
  rollBackward: (ctx: RollBackwardContext) => Promise<Upsert>;
  // rollForward: (ctx: RollForwardContext, processingResult: CombinedProcessingResult) => Promise<Upsert>;
  rollForward: (ctx: RollForwardContext, processingResult?: any) => Promise<Upsert>;
}
