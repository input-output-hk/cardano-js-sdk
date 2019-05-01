import { Bip44AccountPrivate } from 'cardano-wallet'

export type Key = Bip44AccountPrivate
  | LedgerNetworkInterface
  | TrezorNetworkInterface

export type LedgerNetworkInterface = any
export type TrezorNetworkInterface = any