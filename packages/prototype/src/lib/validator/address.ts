import * as cbor from 'cbor'
import { ChainSettings } from '../../Cardano/ChainSettings'

export interface AddressIntrospection<T>
  { kind?: T
  , chainSettings?: ChainSettings
  }

/*
  Byron Era
*/

const BYRON_TESTNET_MAGIC = 1097911063

export enum ByronAddressKind
  { spendingAddress = 0
  , scriptAddress = 1
  , redeemAddress = 2
  , stakingAddress = 3
  }

export enum ByronAddressAttributes
  { stakeDistribution = 0
  , derivationPath = 1
  , networkMagic = 2
  }

/** @see https://github.com/input-output-hk/cardano-wallet/wiki/About-Address-Format---Byron */
export function decodeByronAddress (bytes : Buffer) : (AddressIntrospection<ByronAddressKind>|null) {
  try {
    let [payload] = cbor.decode(bytes)
    let [, attributes, kind] = cbor.decode(payload.value)

    // Somehow, 'cbor.decode' returns an empty object '{}' when empty,
    // but a 'Map' otherwise. Following line cope with the inconsistency.
    if (!Object.is(Object.getPrototypeOf(attributes), Map.prototype)) {
      attributes = new Map()
    }

    let protocolMagic = attributes.get(ByronAddressAttributes.networkMagic)
    if (protocolMagic === undefined) {
      return { kind, chainSettings: ChainSettings.mainnet }
    } else if (cbor.decode(protocolMagic) === BYRON_TESTNET_MAGIC) {
      return { kind, chainSettings: ChainSettings.testnet }
    }

    return null
  } catch (e) {
    return null
  }
}

/*
  Jormungandr Era
*/

const PUBKEY_LENGTH = 32 // in bytes

export enum JormungandrAddressKind
  { singleAddress = 3
  , groupedAddress = 4
  , accountAddress = 5
  , multisigAddress = 6
  }

/** @see https://github.com/input-output-hk/implementation-decisions/blob/master/text/0001-address.md */
export function decodeJormungandrAddress (bytes : Buffer) : (AddressIntrospection<JormungandrAddressKind>|null) {
  let kind = bytes[0] & 0b01111111
  let chainSettings = (bytes[0] & 0b10000000) ? ChainSettings.testnet : ChainSettings.mainnet

  switch (kind) {
    case JormungandrAddressKind.singleAddress:
      if (bytes.byteLength !== (1 + PUBKEY_LENGTH)) {
        return null
      }
      break

    case JormungandrAddressKind.groupedAddress:
      if (bytes.byteLength !== (1 + 2 * PUBKEY_LENGTH)) {
        return null
      }
      break

    case JormungandrAddressKind.accountAddress:
      if (bytes.byteLength !== (1 + PUBKEY_LENGTH)) {
        return null
      }
      break

    case JormungandrAddressKind.multisigAddress:
      if (bytes.byteLength !== (1 + PUBKEY_LENGTH)) {
        return null
      }
      break

    default:
      return null
  }

  return { kind, chainSettings }
}
