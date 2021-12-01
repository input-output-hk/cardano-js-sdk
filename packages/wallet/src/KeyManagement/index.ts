import { InMemoryKeyAgent } from './InMemoryKeyAgent';
import { KeyAgent } from './types';

export * as errors from './errors';
export * from './KeyAgentBase';
export * from './InMemoryKeyAgent';
export * from './restoreKeyAgent';
export * as util from './util';
export * from './emip3';
export * from './types';

// TODO: remove
export type KeyManager = KeyAgent;
export type InMemoryKeyManager = InMemoryKeyAgent;
