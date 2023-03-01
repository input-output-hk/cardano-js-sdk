import * as Crypto from '@cardano-sdk/crypto';
import {
  AccountAddressDerivationPath,
  AccountKeyDerivationPath,
  GroupedAddress,
  KeyAgent,
  KeyAgentDependencies,
  KeyRole,
  SerializableKeyAgentData,
  SignBlobResult,
  SignTransactionOptions
} from './types';
import { CML, Cardano } from '@cardano-sdk/core';
import { HexBlob, usingAutoFree } from '@cardano-sdk/util';
import { STAKE_KEY_DERIVATION_PATH } from './util';

export abstract class KeyAgentBase implements KeyAgent {
  readonly #serializableData: SerializableKeyAgentData;
  readonly #bip32Ed25519: Crypto.Bip32Ed25519;
  protected readonly inputResolver: Cardano.util.InputResolver;

  get knownAddresses(): GroupedAddress[] {
    return this.#serializableData.knownAddresses;
  }
  set knownAddresses(addresses: GroupedAddress[]) {
    this.#serializableData.knownAddresses = addresses;
  }
  get serializableData(): SerializableKeyAgentData {
    return this.#serializableData;
  }
  get extendedAccountPublicKey(): Crypto.Bip32PublicKeyHex {
    return this.serializableData.extendedAccountPublicKey;
  }
  get chainId(): Cardano.ChainId {
    return this.serializableData.chainId;
  }
  get accountIndex(): number {
    return this.serializableData.accountIndex;
  }
  get bip32Ed25519(): Crypto.Bip32Ed25519 {
    return this.#bip32Ed25519;
  }

  abstract signBlob(derivationPath: AccountKeyDerivationPath, blob: HexBlob): Promise<SignBlobResult>;
  abstract exportRootPrivateKey(): Promise<Crypto.Bip32PrivateKeyHex>;
  abstract signTransaction(
    txInternals: Cardano.TxBodyWithHash,
    signTransactionOptions?: SignTransactionOptions
  ): Promise<Cardano.Signatures>;

  constructor(serializableData: SerializableKeyAgentData, { inputResolver, bip32Ed25519 }: KeyAgentDependencies) {
    this.#serializableData = serializableData;
    this.inputResolver = inputResolver;
    this.#bip32Ed25519 = bip32Ed25519;
  }

  /**
   * See https://github.com/cardano-foundation/CIPs/tree/master/CIP-1852#specification
   */
  async deriveAddress({ index, type }: AccountAddressDerivationPath): Promise<GroupedAddress> {
    const knownAddress = this.knownAddresses.find((addr) => addr.type === type && addr.index === index);
    if (knownAddress) return knownAddress;
    const derivedPublicPaymentKey = await this.derivePublicKey({
      index,
      role: type as unknown as KeyRole
    });

    const derivedPublicPaymentKeyHash = await this.#bip32Ed25519.getPubKeyHash(derivedPublicPaymentKey);

    // Possible optimization: memoize/cache stakeKeyCredential, because it's always the same
    const publicStakeKey = await this.derivePublicKey(STAKE_KEY_DERIVATION_PATH);
    const publicStakeKeyHash = await this.#bip32Ed25519.getPubKeyHash(publicStakeKey);

    const groupedAddress = usingAutoFree((scope) => {
      const stakeKeyCredential = scope.manage(
        CML.StakeCredential.from_keyhash(
          scope.manage(CML.Ed25519KeyHash.from_bytes(Buffer.from(publicStakeKeyHash, 'hex')))
        )
      );

      const address = scope.manage(
        scope
          .manage(
            CML.BaseAddress.new(
              this.chainId.networkId,
              scope.manage(
                CML.StakeCredential.from_keyhash(
                  scope.manage(CML.Ed25519KeyHash.from_bytes(Buffer.from(derivedPublicPaymentKeyHash, 'hex')))
                )
              ),
              stakeKeyCredential
            )
          )
          .to_address()
      );

      const rewardAccount = scope.manage(
        scope.manage(CML.RewardAddress.new(this.chainId.networkId, stakeKeyCredential)).to_address()
      );
      return {
        accountIndex: this.accountIndex,
        address: Cardano.PaymentAddress(address.to_bech32()),
        index,
        networkId: this.chainId.networkId,
        rewardAccount: Cardano.RewardAccount(rewardAccount.to_bech32()),
        stakeKeyDerivationPath: STAKE_KEY_DERIVATION_PATH,
        type
      };
    });

    this.knownAddresses = [...this.knownAddresses, groupedAddress];
    return groupedAddress;
  }

  async derivePublicKey(derivationPath: AccountKeyDerivationPath): Promise<Crypto.Ed25519PublicKeyHex> {
    const childKey = await this.#bip32Ed25519.derivePublicKey(this.extendedAccountPublicKey, [
      derivationPath.role,
      derivationPath.index
    ]);

    return await this.#bip32Ed25519.getRawPublicKey(childKey);
  }
}
