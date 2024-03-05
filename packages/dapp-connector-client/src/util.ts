import type { Cip30Wallet } from '@cardano-sdk/dapp-connector';

export type CardanoNamespace = Partial<Record<string, Cip30Wallet>>;

export const getCardanoNamespace = () =>
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  (window as any).cardano as undefined | CardanoNamespace;
