import * as Crypto from '@cardano-sdk/crypto';
import {
  AccountAddressDerivationPath,
  AccountKeyDerivationPath,
  AddressManager,
  AsyncKeyAgent,
  GroupedAddress
} from '../types';
import { Observable } from 'rxjs';

/** An address manager that uses a {@link AsyncKeyAgent} to derive addresses. */
export class Bip32Ed25519AddressManager implements AddressManager {
  knownAddresses$: Observable<GroupedAddress[]>;
  #keyAgent: AsyncKeyAgent;

  /**
   * Initializes a new instance of the Bip32Ed25519AddressManager class.
   *
   * @param keyAgent The key agent that will be used to derive addresses.
   */
  constructor(keyAgent: AsyncKeyAgent) {
    this.#keyAgent = keyAgent;
    this.knownAddresses$ = keyAgent.knownAddresses$;
  }

  async setKnownAddresses(addresses: GroupedAddress[]): Promise<void> {
    return this.#keyAgent.setKnownAddresses(addresses);
  }

  async derivePublicKey(derivationPath: AccountKeyDerivationPath): Promise<Crypto.Ed25519PublicKeyHex> {
    return this.#keyAgent.derivePublicKey(derivationPath);
  }

  async deriveAddress(
    paymentKeyDerivationPath: AccountAddressDerivationPath,
    stakeKeyDerivationIndex: number,
    pure?: boolean
  ): Promise<GroupedAddress> {
    return this.#keyAgent.deriveAddress(paymentKeyDerivationPath, stakeKeyDerivationIndex, pure);
  }

  shutdown(): void {
    this.#keyAgent.shutdown();
  }
}

/**
 * Creates a new instance of the Bip32Ed25519AddressManager class.
 *
 * @param keyAgent The key agent that will be used to derive addresses.
 */
export const createBip32Ed25519AddressManager = (keyAgent: AsyncKeyAgent): Bip32Ed25519AddressManager =>
  new Bip32Ed25519AddressManager(keyAgent);
