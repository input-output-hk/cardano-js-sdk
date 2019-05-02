import { Bip44AccountPrivate } from 'cardano-wallet'

export type KeyInterface = Bip44AccountPrivate
  | LedgerNetworkInterface
  | TrezorNetworkInterface

export type LedgerNetworkInterface = any
export type TrezorNetworkInterface = any
