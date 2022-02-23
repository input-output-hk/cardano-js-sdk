import {
  AccountAddressDerivationPath,
  AccountKeyDerivationPath,
  GroupedAddress,
  KeyAgent,
  KeyType,
  SerializableKeyAgentData,
  SignBlobResult
} from './types';
import { CSL, Cardano } from '@cardano-sdk/core';
import { STAKE_KEY_DERIVATION_PATH, ownSignatureKeyPaths } from './util';
import { TxInternals } from '../Transaction';
import AppAda from '@cardano-foundation/ledgerjs-hw-app-cardano';

export abstract class KeyAgentBase implements KeyAgent {
  abstract get networkId(): Cardano.NetworkId;
  abstract get accountIndex(): number;
  abstract get serializableData(): SerializableKeyAgentData;
  abstract get knownAddresses(): GroupedAddress[];
  abstract getExtendedAccountPublicKey(deviceConnection?: AppAda): Promise<Cardano.Bip32PublicKey>;
  abstract signBlob(derivationPath: AccountKeyDerivationPath, blob: Cardano.util.HexBlob): Promise<SignBlobResult>;
  abstract derivePublicKey(derivationPath: AccountKeyDerivationPath): Promise<Cardano.Ed25519PublicKey>;
  abstract exportRootPrivateKey(): Promise<Cardano.Bip32PrivateKey>;

  /**
   * See https://github.com/cardano-foundation/CIPs/tree/master/CIP-1852#specification
   */
  async deriveAddress({ index, type }: AccountAddressDerivationPath): Promise<GroupedAddress> {
    const derivedPublicPaymentKey = await this.deriveCslPublicKey({
      index,
      type: type as unknown as KeyType
    });

    // Possible optimization: memoize/cache stakeKeyCredential, because it's always the same
    const publicStakeKey = await this.deriveCslPublicKey(STAKE_KEY_DERIVATION_PATH);
    const stakeKeyCredential = CSL.StakeCredential.from_keyhash(publicStakeKey.hash());

    const address = CSL.BaseAddress.new(
      this.networkId,
      CSL.StakeCredential.from_keyhash(derivedPublicPaymentKey.hash()),
      stakeKeyCredential
    ).to_address();

    const rewardAccount = CSL.RewardAddress.new(this.networkId, stakeKeyCredential).to_address();
    const groupedAddress = {
      accountIndex: this.accountIndex,
      address: Cardano.Address(address.to_bech32()),
      index,
      networkId: this.networkId,
      rewardAccount: Cardano.RewardAccount(rewardAccount.to_bech32()),
      type
    };
    this.knownAddresses.push(groupedAddress);
    return groupedAddress;
  }

  async signTransaction({ body, hash }: TxInternals): Promise<Cardano.Signatures> {
    // Possible optimization is casting strings to OpaqueString types directly and skipping validation
    const blob = Cardano.util.HexBlob(hash.toString());
    const derivationPaths = ownSignatureKeyPaths(body, this.knownAddresses);
    return new Map<Cardano.Ed25519PublicKey, Cardano.Ed25519Signature>(
      await Promise.all(
        derivationPaths.map(async ({ role, index }) => {
          const { publicKey, signature } = await this.signBlob({ index, type: role }, blob);
          return [publicKey, signature] as const;
        })
      )
    );
  }

  protected async deriveCslPublicKey(derivationPath: AccountKeyDerivationPath): Promise<CSL.PublicKey> {
    const hexPublicKey = await this.derivePublicKey(derivationPath);
    return CSL.PublicKey.from_bytes(Buffer.from(hexPublicKey, 'hex'));
  }
}
