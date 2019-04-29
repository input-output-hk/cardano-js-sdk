import * as cardanoNodeBindings from 'cardano-wallet'
import * as cardanoBrowserBindings from 'cardano-wallet-browser'

export function getBindingsForEnvironment() {
  const isBrowser = new Function('try {return this===window;}catch(e){ return false;}')

  return isBrowser
    ? cardanoBrowserBindings
    : cardanoNodeBindings
}