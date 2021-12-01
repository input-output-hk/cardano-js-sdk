/* eslint-disable func-style */
/* eslint-disable sonarjs/no-small-switch */
import {
  Authenticate,
  KeyAgentType,
  SerializableInMemoryKeyAgentData,
  SerializableKeyAgentData,
  SerializableLedgerKeyAgentData
} from './types';
import { InMemoryKeyAgent } from './InMemoryKeyAgent';
import { KeyAgentBase } from './KeyAgentBase';

export interface RestoreInMemoryKeyAgentProps {
  /**
   * Required for InMemoryKeyAgent
   */
  authenticate?: Authenticate;
}

export function restoreKeyAgent(data: SerializableLedgerKeyAgentData): KeyAgentBase;
export function restoreKeyAgent(data: SerializableInMemoryKeyAgentData, authenticate: Authenticate): InMemoryKeyAgent;
/**
 * Restore key agent from serializable data
 */
export function restoreKeyAgent<T extends SerializableKeyAgentData>(
  data: T,
  authenticate?: Authenticate
): KeyAgentBase {
  switch (data.__typename) {
    case KeyAgentType.InMemory:
      if (!data.encryptedRootPrivateKeyBytes || data.encryptedRootPrivateKeyBytes.length !== 64) {
        throw new Error('Expected encrypted root private key in "agentData" for InMemoryKeyAgent"');
      }
      if (!authenticate) {
        throw new Error('Expected "authenticate" in RestoreKeyAgentProps for InMemoryKeyAgent"');
      }
      return new InMemoryKeyAgent({
        accountIndex: data.accountIndex,
        authenticate,
        encryptedRootPrivateKey: new Uint8Array(data.encryptedRootPrivateKeyBytes),
        networkId: data.networkId
      });
    default:
      throw new Error('Not implemented');
  }
}
