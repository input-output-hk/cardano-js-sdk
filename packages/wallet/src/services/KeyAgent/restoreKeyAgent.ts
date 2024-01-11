/* eslint-disable func-style */
/* eslint-disable @typescript-eslint/ban-ts-comment */
import { Cardano } from '@cardano-sdk/core';
import {
  GetPassphrase,
  InMemoryKeyAgent,
  KeyAgent,
  KeyAgentDependencies,
  KeyAgentType,
  SerializableInMemoryKeyAgentData,
  SerializableKeyAgentData,
  SerializableLedgerKeyAgentData,
  SerializableTrezorKeyAgentData,
  errors
} from '@cardano-sdk/key-management';
import { LedgerKeyAgent } from '@cardano-sdk/hardware-ledger';
import { Logger } from 'ts-log';
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';

// TODO: use this type as 2nd parameter of restoreKeyAgent
export interface RestoreInMemoryKeyAgentProps {
  /** Required for InMemoryKeyAgent */
  getPassphrase?: GetPassphrase;
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
    })()
});

export function restoreKeyAgent(
  data: SerializableInMemoryKeyAgentData,
  dependencies: KeyAgentDependencies,
  getPassphrase: GetPassphrase
): Promise<KeyAgent>;
export function restoreKeyAgent(
  data: SerializableKeyAgentData,
  dependencies: KeyAgentDependencies,
  getPassphrase?: GetPassphrase
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
  getPassphrase?: GetPassphrase
): Promise<KeyAgent> {
  // migrateSerializableData
  const data = migrateSerializableData(dataArg, dependencies.logger);
  switch (data.__typename) {
    case KeyAgentType.InMemory: {
      if (!data.encryptedRootPrivateKeyBytes || data.encryptedRootPrivateKeyBytes.length !== 156) {
        throw new errors.InvalidSerializableDataError(
          'Expected encrypted root private key in "agentData" for InMemoryKeyAgent"'
        );
      }
      if (!getPassphrase) {
        throw new errors.InvalidSerializableDataError(
          'Expected "getPassphrase" in RestoreKeyAgentProps for InMemoryKeyAgent"'
        );
      }
      return new InMemoryKeyAgent({ ...data, getPassphrase }, dependencies);
    }
    case KeyAgentType.Ledger: {
      return new LedgerKeyAgent(data, dependencies);
    }
    case KeyAgentType.Trezor: {
      return new TrezorKeyAgent(data, dependencies);
    }
    default:
      throw new errors.InvalidSerializableDataError(
        // @ts-ignore
        `Restoring key agent of __typename '${data.__typename}' is not implemented`
      );
  }
}
