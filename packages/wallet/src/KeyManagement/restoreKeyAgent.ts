/* eslint-disable func-style */
/* eslint-disable sonarjs/no-small-switch */
import {
  GetPassword,
  KeyAgent,
  KeyAgentType,
  SerializableInMemoryKeyAgentData,
  SerializableKeyAgentData,
  SerializableLedgerKeyAgentData
} from './types';
import { InMemoryKeyAgent } from './InMemoryKeyAgent';

export interface RestoreInMemoryKeyAgentProps {
  /**
   * Required for InMemoryKeyAgent
   */
  getPassword?: GetPassword;
}

export function restoreKeyAgent(data: SerializableLedgerKeyAgentData): Promise<KeyAgent>;
export function restoreKeyAgent(data: SerializableInMemoryKeyAgentData, getPassword: GetPassword): Promise<KeyAgent>;
export function restoreKeyAgent(data: SerializableKeyAgentData, getPassword?: GetPassword): Promise<KeyAgent>;
/**
 * Restore key agent from serializable data
 */
export async function restoreKeyAgent<T extends SerializableKeyAgentData>(
  data: T,
  getPassword?: GetPassword
): Promise<KeyAgent> {
  switch (data.__typename) {
    case KeyAgentType.InMemory: {
      if (!data.encryptedRootPrivateKeyBytes || data.encryptedRootPrivateKeyBytes.length !== 156) {
        throw new Error('Expected encrypted root private key in "agentData" for InMemoryKeyAgent"');
      }
      if (!getPassword) {
        throw new Error('Expected "getPassowrd" in RestoreKeyAgentProps for InMemoryKeyAgent"');
      }
      const keyAgent = new InMemoryKeyAgent({
        accountIndex: data.accountIndex,
        encryptedRootPrivateKey: new Uint8Array(data.encryptedRootPrivateKeyBytes),
        getPassword,
        networkId: data.networkId
      });
      await keyAgent.getExtendedAccountPublicKey(); // attempt to decrypt the key
      return keyAgent;
    }
    default:
      throw new Error('Not implemented');
  }
}
