/* eslint-disable func-style */
/* eslint-disable @typescript-eslint/ban-ts-comment */
import {
  GetPassword,
  KeyAgent,
  KeyAgentDependencies,
  KeyAgentType,
  SerializableInMemoryKeyAgentData,
  SerializableKeyAgentData,
  SerializableLedgerKeyAgentData,
  SerializableTrezorKeyAgentData
} from './types';
import { InMemoryKeyAgent } from './InMemoryKeyAgent';
import { InvalidSerializableDataError } from './errors';
import { LedgerKeyAgent } from './LedgerKeyAgent';
import { STAKE_KEY_DERIVATION_PATH } from './util';
import { TrezorKeyAgent } from './TrezorKeyAgent';

// TODO: use this type as 2nd parameter of restoreKeyAgent
export interface RestoreInMemoryKeyAgentProps {
  /**
   * Required for InMemoryKeyAgent
   */
  getPassword?: GetPassword;
}

export function restoreKeyAgent(
  data: SerializableInMemoryKeyAgentData,
  dependencies: KeyAgentDependencies,
  getPassword: GetPassword
): Promise<KeyAgent>;
export function restoreKeyAgent(
  data: SerializableKeyAgentData,
  dependencies: KeyAgentDependencies,
  getPassword?: GetPassword
): Promise<KeyAgent>;
export function restoreKeyAgent(
  data: SerializableLedgerKeyAgentData,
  dependencies: KeyAgentDependencies
): Promise<KeyAgent>;
export function restoreKeyAgent(
  data: SerializableTrezorKeyAgentData,
  dependencies: KeyAgentDependencies
): Promise<KeyAgent>;
/**
 * Restore key agent from serializable data
 *
 * @throws InvalidSerializableDataError, AuthenticationError
 */
export async function restoreKeyAgent<T extends SerializableKeyAgentData>(
  data: T,
  dependencies: KeyAgentDependencies,
  getPassword?: GetPassword
): Promise<KeyAgent> {
  for (const address of data.knownAddresses) address.stakeKeyDerivationPath ||= STAKE_KEY_DERIVATION_PATH;

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
      return new InMemoryKeyAgent({ ...data, getPassword }, dependencies);
    }
    case KeyAgentType.Ledger: {
      return new LedgerKeyAgent(data, dependencies);
    }
    case KeyAgentType.Trezor: {
      return new TrezorKeyAgent(data, dependencies);
    }
    default:
      throw new InvalidSerializableDataError(
        // @ts-ignore
        `Restoring key agent of __typename '${data.__typename}' is not implemented`
      );
  }
}
