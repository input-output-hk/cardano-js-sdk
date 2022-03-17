import { Asset } from '@cardano-graphql/client-ts';
import { Schema as Ogmios } from '@cardano-ogmios/client';
import dgraph from 'dgraph-js';

export type ModuleState = null | 'initializing' | 'initialized';

export type DQL = string;
type Variable = string;

export type QueryVariables = {
  $assetIds?: string[];
  $slotNo?: number;
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

export interface CombinedQueryResult {
  data: {
    assets: Asset[];
  };
}

export interface ProcessingResult {
  assets: Asset[];
}

export interface CombinedProcessingResult {
  func: Partial<ProcessingResult>;
  id: string;
}

export interface ProcessParameters {
  ctx?: RollForwardContext;
  queryResult?: CombinedQueryResult;
}

export interface BlockHandler {
  id: string;
  query?: (ctx: RollForwardContext) => Promise<QueryResult<QueryVariables>>;
  process?: (parameters: ProcessParameters) => Promise<Partial<ProcessingResult>>;
  rollBackward: (ctx: RollBackwardContext) => Promise<Upsert>;
  rollForward: (ctx: RollForwardContext, processingResult: CombinedProcessingResult[]) => Promise<Upsert>;
}
