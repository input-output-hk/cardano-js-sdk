import { Schema as Ogmios } from '@cardano-ogmios/client';
import dgraph from 'dgraph-js';

export type ModuleState = null | 'initializing' | 'initialized';

export type DQL = string;
type Variable = string;

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

export interface BlockHandler {
  id: string;
  query?: (ctx: RollForwardContext) => Promise<DQL>;
  // process?: (ctx: RollForwardContext, queryResult?: CombinedQueryResult) => Promise<Partial<CombinedProcessingResult>>;
  process?: (ctx: RollForwardContext, queryResult?: any) => Promise<Partial<any>>;
  rollBackward: (ctx: RollBackwardContext) => Promise<Upsert>;
  // rollForward: (ctx: RollForwardContext, processingResult: CombinedProcessingResult) => Promise<Upsert>;
  rollForward: (ctx: RollForwardContext, processingResult?: any) => Promise<Upsert>;
}
