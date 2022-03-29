import { Asset } from '../Schema';
import { Schema as Ogmios, Schema } from '@cardano-ogmios/client';
import dgraph from 'dgraph-js';

export type ModuleState = null | 'initializing' | 'initialized';

export interface LastBlockQuery {
  lastestBlock: [
    {
      'Block.hash': Schema.DigestBlake2BBlockHeader;
      'Block.slot': {
        number: Schema.Slot;
      };
    }
  ];
}

export type DQL = string;
type Variable = 'asset' | 'block';

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

export interface AssetResult {
  'Asset.assetId': Asset['assetId'];
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
  assets: AssetResult[];
}

export interface ProcessingResult {
  assets: Asset[];
}

export interface CombinedProcessingResult {
  func: Partial<ProcessingResult>;
  id: string;
}

export interface BlockHandler {
  id: string;
  query?: (ctx: RollForwardContext) => Promise<QueryResult>;
  process?: (ctx: RollForwardContext, queryResult: CombinedQueryResult) => Promise<Partial<ProcessingResult>>;
  rollBackward: (ctx: RollBackwardContext) => Promise<Upsert>;
  rollForward: (ctx: RollForwardContext, processingResult?: CombinedProcessingResult[]) => Promise<Upsert>;
}
