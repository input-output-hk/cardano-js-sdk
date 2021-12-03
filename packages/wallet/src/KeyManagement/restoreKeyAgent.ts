/* eslint-disable func-style */
/* eslint-disable sonarjs/no-small-switch */
import {
  GetPassword,
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
  getPassword?: GetPassword;
}

export function restoreKeyAgent(data: SerializableLedgerKeyAgentData): KeyAgentBase;
export function restoreKeyAgent(data: SerializableInMemoryKeyAgentData, getPassword: GetPassword): InMemoryKeyAgent;
export function restoreKeyAgent(data: SerializableKeyAgentData, getPassword?: GetPassword): InMemoryKeyAgent;
/**
 * Restore key agent from serializable data
 */
export function restoreKeyAgent<T extends SerializableKeyAgentData>(data: T, getPassword?: GetPassword): KeyAgentBase {
  switch (data.__typename) {
    case KeyAgentType.InMemory:
      if (!data.encryptedRootPrivateKeyBytes || data.encryptedRootPrivateKeyBytes.length !== 64) {
        throw new Error('Expected encrypted root private key in "agentData" for InMemoryKeyAgent"');
      }
      if (!getPassword) {
        throw new Error('Expected "getPassowrd" in RestoreKeyAgentProps for InMemoryKeyAgent"');
      }
      return new InMemoryKeyAgent({
        accountIndex: data.accountIndex,
        encryptedRootPrivateKey: new Uint8Array(data.encryptedRootPrivateKeyBytes),
        getPassword,
        networkId: data.networkId
      });
    default:
      throw new Error('Not implemented');
  }
}
