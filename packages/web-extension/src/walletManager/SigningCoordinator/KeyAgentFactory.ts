import { Bip32Ed25519 } from '@cardano-sdk/crypto';
import { InMemoryKeyAgent, InMemoryKeyAgentProps } from '@cardano-sdk/key-management';
import { LedgerKeyAgent, LedgerKeyAgentProps } from '@cardano-sdk/hardware-ledger';
import { Logger } from 'ts-log';
import { TrezorKeyAgent, TrezorKeyAgentProps } from '@cardano-sdk/hardware-trezor';

export type KeyAgentFactoryDependencies = {
  logger: Logger;
  getBip32Ed25519: () => Promise<Bip32Ed25519>;
};

export const createKeyAgentFactory = ({ logger, getBip32Ed25519 }: KeyAgentFactoryDependencies) => ({
  InMemory: async (props: InMemoryKeyAgentProps) =>
    new InMemoryKeyAgent(props, { bip32Ed25519: await getBip32Ed25519(), logger }),
  Ledger: async (props: LedgerKeyAgentProps) =>
    new LedgerKeyAgent(props, { bip32Ed25519: await getBip32Ed25519(), logger }),
  Trezor: async (props: TrezorKeyAgentProps) =>
    new TrezorKeyAgent(props, { bip32Ed25519: await getBip32Ed25519(), logger })
});

export type KeyAgentFactory = ReturnType<typeof createKeyAgentFactory>;
