/* eslint-disable func-style */
/* eslint-disable @typescript-eslint/ban-ts-comment */
import { Cardano } from '@cardano-sdk/core';
import {
  GetPassword,
  GroupedAddress,
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
import { Logger } from 'ts-log';
import { STAKE_KEY_DERIVATION_PATH } from './util';
import { TrezorKeyAgent } from './TrezorKeyAgent';

// TODO: use this type as 2nd parameter of restoreKeyAgent
export interface RestoreInMemoryKeyAgentProps {
  /**
   * Required for InMemoryKeyAgent
   */
  getPassword?: GetPassword;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const migrateSerializableData = <T extends SerializableKeyAgentData>(data: any, logger: Logger): T => ({
  ...data,
  chainId:
    data.chainId ||
    (() => {
      logger.info('Migrating serializable data due to missing "chainId"');
      return {
        ...data,
        chainId:
          data.networkId === Cardano.NetworkId.Mainnet
            ? Cardano.ChainIds.Mainnet
            : (() => {
                logger.warn('Assuming "Preprod" network is used');
                return Cardano.ChainIds.Preprod;
              })()
      };
    })(),
  knownAddresses: data.knownAddresses.map((address: GroupedAddress) => ({
    ...address,
    stakeKeyDerivationPath: address.stakeKeyDerivationPath || STAKE_KEY_DERIVATION_PATH
  }))
});

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
  dataArg: T,
  dependencies: KeyAgentDependencies,
  getPassword?: GetPassword
): Promise<KeyAgent> {
  // migrateSerializableData
  const data = migrateSerializableData(dataArg, dependencies.logger);
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
