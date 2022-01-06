/* eslint-disable func-style */
/* eslint-disable sonarjs/no-small-switch */
import {
  GetPassword,
  KeyAgent,
  KeyAgentType,
  SerializableInMemoryKeyAgentData,
  SerializableKeyAgentData
} from './types';
import { InMemoryKeyAgent } from './InMemoryKeyAgent';
import { InvalidSerializableDataError } from './errors';

export interface RestoreInMemoryKeyAgentProps {
  /**
   * Required for InMemoryKeyAgent
   */
  getPassword?: GetPassword;
}

export function restoreKeyAgent(data: SerializableInMemoryKeyAgentData, getPassword: GetPassword): Promise<KeyAgent>;
export function restoreKeyAgent(data: SerializableKeyAgentData, getPassword?: GetPassword): Promise<KeyAgent>;
/**
 * Restore key agent from serializable data
 *
 * @throws InvalidSerializableDataError, AuthenticationError
 */
export async function restoreKeyAgent<T extends SerializableKeyAgentData>(
  data: T,
  getPassword?: GetPassword
): Promise<KeyAgent> {
  switch (data.__typename) {
    case KeyAgentType.InMemory: {
      if (!data.encryptedRootPrivateKeyBytes || data.encryptedRootPrivateKeyBytes.length !== 156) {
        throw new InvalidSerializableDataError(
          'Expected encrypted root private key in "agentData" for InMemoryKeyAgent"'
        );
      }
      if (!getPassword) {
        throw new InvalidSerializableDataError('Expected "getPassword" in RestoreKeyAgentProps for InMemoryKeyAgent"');
      }
      return new InMemoryKeyAgent({
        accountIndex: data.accountIndex,
        encryptedRootPrivateKey: new Uint8Array(data.encryptedRootPrivateKeyBytes),
        getPassword,
        networkId: data.networkId
      });
    }
    default:
      throw new InvalidSerializableDataError(
        `Restoring key agent of __typename '${data.__typename}' is not implemented`
      );
  }
}
