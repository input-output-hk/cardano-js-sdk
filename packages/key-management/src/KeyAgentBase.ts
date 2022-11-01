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
import { CML, Cardano, util } from '@cardano-sdk/core';
import { STAKE_KEY_DERIVATION_PATH } from './util';

export abstract class KeyAgentBase implements KeyAgent {
  readonly #serializableData: SerializableKeyAgentData;
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
  get extendedAccountPublicKey(): Cardano.Bip32PublicKey {
    return this.serializableData.extendedAccountPublicKey;
  }
  get networkId(): Cardano.NetworkId {
    return this.serializableData.networkId;
  }
  get accountIndex(): number {
    return this.serializableData.accountIndex;
  }
  abstract signBlob(derivationPath: AccountKeyDerivationPath, blob: Cardano.util.HexBlob): Promise<SignBlobResult>;
  abstract exportRootPrivateKey(): Promise<Cardano.Bip32PrivateKey>;
  abstract signTransaction(
    txInternals: Cardano.TxBodyWithHash,
    signTransactionOptions?: SignTransactionOptions
  ): Promise<Cardano.Signatures>;

  constructor(serializableData: SerializableKeyAgentData, { inputResolver }: KeyAgentDependencies) {
    this.#serializableData = serializableData;
    this.inputResolver = inputResolver;
  }

  /**
   * See https://github.com/cardano-foundation/CIPs/tree/master/CIP-1852#specification
   */
  async deriveAddress({ index, type }: AccountAddressDerivationPath): Promise<GroupedAddress> {
    const knownAddress = this.knownAddresses.find((addr) => addr.type === type && addr.index === index);
    if (knownAddress) return knownAddress;
    const derivedPublicPaymentKey = await this.deriveCmlPublicKey({
      index,
      role: type as unknown as KeyRole
    });

    // Possible optimization: memoize/cache stakeKeyCredential, because it's always the same
    const publicStakeKey = await this.deriveCmlPublicKey(STAKE_KEY_DERIVATION_PATH);
    const stakeKeyCredential = CML.StakeCredential.from_keyhash(publicStakeKey.hash());

    const address = CML.BaseAddress.new(
      this.networkId,
      CML.StakeCredential.from_keyhash(derivedPublicPaymentKey.hash()),
      stakeKeyCredential
    ).to_address();

    const rewardAccount = CML.RewardAddress.new(this.networkId, stakeKeyCredential).to_address();
    const groupedAddress = {
      accountIndex: this.accountIndex,
      address: Cardano.Address(address.to_bech32()),
      index,
      networkId: this.networkId,
      rewardAccount: Cardano.RewardAccount(rewardAccount.to_bech32()),
      type
    };
    this.knownAddresses = [...this.knownAddresses, groupedAddress];
    return groupedAddress;
  }

  async derivePublicKey(derivationPath: AccountKeyDerivationPath): Promise<Cardano.Ed25519PublicKey> {
    const cslPublicKey = await this.deriveCmlPublicKey(derivationPath);
    return Cardano.Ed25519PublicKey.fromHexBlob(util.bytesToHex(cslPublicKey.as_bytes()));
  }

  protected async deriveCmlPublicKey({ index, role: type }: AccountKeyDerivationPath): Promise<CML.PublicKey> {
    const accountPublicKeyBytes = Buffer.from(this.extendedAccountPublicKey, 'hex');
    const accountPublicKey = CML.Bip32PublicKey.from_bytes(accountPublicKeyBytes);
    return accountPublicKey.derive(type).derive(index).to_raw_key();
  }
}
