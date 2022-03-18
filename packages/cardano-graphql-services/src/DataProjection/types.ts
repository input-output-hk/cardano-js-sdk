import { Asset } from '@cardano-sdk/core';
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
  data: {
    assets: Asset.AssetInfo[];
  };
}

export interface ProcessingResult {
  assets: Asset.AssetInfo[];
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
