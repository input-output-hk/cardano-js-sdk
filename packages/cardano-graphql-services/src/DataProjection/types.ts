import { Asset } from '../Schema';
import { Schema as Ogmios } from '@cardano-ogmios/client';
import dgraph from 'dgraph-js';

export type ModuleState = null | 'initializing' | 'initialized';

export interface LastBlockQuery {
  slot: {
    number: number;
  };
  hash: string;
}

export type DQL = string;
type Variable = 'Asset' | 'Block';

export type QueryVariables = {
  $assetIds?: string[];
  $slotNo?: number;
};
export interface QueryResult {
  query: DQL;
  variables?: QueryVariables;
}
export interface RollBackwardContext {
  point: Ogmios.PointOrOrigin;
  tip: Ogmios.TipOrOrigin;
}

export interface RollForwardContext {
  txn: dgraph.Txn;
  block: Ogmios.Block;
}

export interface Upsert {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  mutations: { [k: string]: any };
  variables?: {
    defines: Variable[];
    dependencies?: Variable[];
    dql: DQL;
  };
}

export interface CombinedQueryResult {
  assets: Asset[];
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
  query?: (ctx: RollForwardContext) => Promise<QueryResult>;
  process?: (parameters: ProcessParameters) => Promise<Partial<ProcessingResult>>;
  rollBackward: (ctx: RollBackwardContext) => Promise<Upsert>;
  rollForward: (ctx: RollForwardContext, processingResult: CombinedProcessingResult[]) => Promise<Upsert>;
}
