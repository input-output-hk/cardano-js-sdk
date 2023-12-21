import { InMemoryKeyAgent, InMemoryKeyAgentProps, KeyAgentDependencies } from '@cardano-sdk/key-management';
import { LedgerKeyAgent, LedgerKeyAgentProps } from '@cardano-sdk/hardware-ledger';
import { TrezorKeyAgent, TrezorKeyAgentProps } from '@cardano-sdk/hardware-trezor';

export const createKeyAgentFactory = (dependencies: KeyAgentDependencies) => ({
  InMemory: (props: InMemoryKeyAgentProps) => new InMemoryKeyAgent(props, dependencies),
  Ledger: (props: LedgerKeyAgentProps) => new LedgerKeyAgent(props, dependencies),
  Trezor: (props: TrezorKeyAgentProps) => new TrezorKeyAgent(props, dependencies)
});

export type KeyAgentFactory = ReturnType<typeof createKeyAgentFactory>;
