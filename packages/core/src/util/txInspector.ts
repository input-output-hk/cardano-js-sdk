import * as Crypto from '@cardano-sdk/crypto';
import {
  AssetFingerprint,
  AssetId,
  AssetName,
  Certificate,
  CertificateType,
  HydratedTx,
  HydratedTxIn,
  Lovelace,
  Metadatum,
  PolicyId,
  PoolRegistrationCertificate,
  PoolRetirementCertificate,
  Script,
  ScriptType,
  StakeAddressCertificate,
  StakeDelegationCertificate,
  TokenMap,
  Value
} from '../Cardano/types';
import { BigIntMath } from '@cardano-sdk/util';
import { PaymentAddress, RewardAccount, inputsWithAddresses, isAddressWithin } from '../Cardano';
import { coalesceValueQuantities } from './coalesceValueQuantities';
import { nativeScriptPolicyId } from './nativeScript';
import { removeNegativesFromTokenMap } from '../Asset/util';
import { resolveInputValue } from '../Cardano/util/resolveInputValue';
import { subtractValueQuantities } from './subtractValueQuantities';
type Inspector<Inspection> = (tx: HydratedTx) => Inspection;
type Inspectors = { [k: string]: Inspector<unknown> };
type TxInspector<T extends Inspectors> = (tx: HydratedTx) => {
  [k in keyof T]: ReturnType<T[k]>;
};

// Inspection result types
export type SendReceiveValueInspection = Value;
export type DelegationInspection = StakeDelegationCertificate[];
export type StakeRegistrationInspection = StakeAddressCertificate[];
export type PoolRegistrationInspection = PoolRegistrationCertificate[];
export type PoolRetirementInspection = PoolRetirementCertificate[];

export type WithdrawalInspection = Lovelace;
export interface SentInspection {
  inputs: HydratedTxIn[];
  certificates: Certificate[];
}
export type SignedCertificatesInspection = Certificate[];

export interface MintedAsset {
  script?: Script;
  policyId: PolicyId;
  fingerprint: AssetFingerprint;
  assetName: AssetName;
  quantity: bigint;
}

export type AssetsMintedInspection = MintedAsset[];

export type MetadataInspection = Metadatum;

// Inspector types
interface SentInspectorArgs {
  addresses?: PaymentAddress[];
  rewardAccounts?: RewardAccount[];
}
export type SentInspector = (args: SentInspectorArgs) => Inspector<SentInspection>;
export type TotalAddressInputsValueInspector = (
  ownAddresses: PaymentAddress[],
  getHistoricalTxs: () => HydratedTx[]
) => Inspector<SendReceiveValueInspection>;
export type SendReceiveValueInspector = (ownAddresses: PaymentAddress[]) => Inspector<SendReceiveValueInspection>;
export type DelegationInspector = Inspector<DelegationInspection>;
export type StakeRegistrationInspector = Inspector<StakeRegistrationInspection>;
export type WithdrawalInspector = Inspector<WithdrawalInspection>;
export type SignedCertificatesInspector = (
  rewardAccounts: RewardAccount[],
  certificateTypes?: CertificateType[]
) => Inspector<SignedCertificatesInspection>;
export type AssetsMintedInspector = Inspector<AssetsMintedInspection>;
export type MetadataInspector = Inspector<MetadataInspection>;
export type PoolRegistrationInspector = Inspector<PoolRegistrationInspection>;
export type PoolRetirementInspector = Inspector<PoolRetirementInspection>;

/**
 * Inspects a transaction for values (coins + assets) in inputs
 * containing any of the provided addresses.
 *
 * @param {PaymentAddress[]} ownAddresses own wallet's addresses
 * @param {() => HydratedTx[]} getHistoricalTxs wallet's historical transactions
 * @returns {Value} total value in inputs
 */
export const totalAddressInputsValueInspector: TotalAddressInputsValueInspector =
  (ownAddresses, getHistoricalTxs) => (tx) => {
    const receivedInputs = tx.body.inputs.filter((input) => isAddressWithin(ownAddresses)(input));
    const receivedInputsValues = receivedInputs
      .map((input) => resolveInputValue(input, getHistoricalTxs()))
      .filter((value): value is Value => !!value);

    return coalesceValueQuantities(receivedInputsValues);
  };

/**
 * Inspects a transaction for values (coins + assets) in outputs
 * containing any of the provided addresses.
 *
 * @param {PaymentAddress[]} ownAddresses own wallet's addresses
 * @returns {Value} total value in outputs
 */
export const totalAddressOutputsValueInspector: SendReceiveValueInspector = (ownAddresses) => (tx) => {
  const receivedOutputs = tx.body.outputs.filter((out) => isAddressWithin(ownAddresses)(out));
  return coalesceValueQuantities(receivedOutputs.map((output) => output.value));
};

/**
 * Inspects a transaction for certificates signed with the reward accounts provided.
 * Is possible to specify the types of certificates to be taken into account
 *
 * @param {RewardAccount[]} rewardAccounts array of reward accounts that might have signed certificates
 * @param {CertificateType[]} [certificateTypes] certificates of these types will be checked. All if not provided
 */
export const signedCertificatesInspector: SignedCertificatesInspector =
  (rewardAccounts: RewardAccount[], certificateTypes?: CertificateType[]) => (tx) => {
    if (!tx.body.certificates || tx.body.certificates.length === 0) return [];
    const certificates = certificateTypes
      ? tx.body.certificates?.filter((certificate) => certificateTypes.includes(certificate.__typename))
      : tx.body.certificates;

    return certificates.filter((certificate) => {
      if ('stakeCredential' in certificate && certificate.stakeCredential) {
        const credHash = Crypto.Ed25519KeyHashHex(certificate.stakeCredential.hash);
        return rewardAccounts.some((account) => RewardAccount.toHash(account) === credHash);
      }

      if ('poolParameters' in certificate) return rewardAccounts.includes(certificate.poolParameters.rewardAccount);
      return false;
    });
  };

/**
 * Inspects a transaction to see if any of the addresses provided are included in a transaction input
 * or if any of the rewards accounts are included in a certificate
 *
 * @param {SentInspectorArgs} args array of addresses and/or reward accounts
 * @returns {SentInspection} certificates and inputs that include the addresses or reward accounts
 */
export const sentInspector: SentInspector =
  ({ addresses, rewardAccounts }) =>
  (tx) => ({
    certificates: rewardAccounts?.length ? signedCertificatesInspector(rewardAccounts)(tx) : [],
    inputs: addresses?.length ? inputsWithAddresses(tx, addresses) : []
  });

/**
 * Inspects a transaction for net value (coins + assets) sent by the provided addresses.
 *
 * @param {PaymentAddress[]} ownAddresses own wallet's addresses
 * @param historicalTxs A list of historical transaction
 * @returns {Value} net value sent
 */
export const valueSentInspector: TotalAddressInputsValueInspector = (ownAddresses, historicalTxs) => (tx) => {
  let assets: TokenMap = new Map();
  if (sentInspector({ addresses: ownAddresses })(tx).inputs.length === 0) return { coins: 0n };
  const totalOutputValue = totalAddressOutputsValueInspector(ownAddresses)(tx);
  const totalInputValue = totalAddressInputsValueInspector(ownAddresses, historicalTxs)(tx);
  const diff = subtractValueQuantities([totalInputValue, totalOutputValue]);

  if (diff.assets) assets = removeNegativesFromTokenMap(diff.assets);
  return {
    assets: assets.size > 0 ? assets : undefined,
    coins: diff.coins < 0n ? 0n : diff.coins
  };
};

/**
 * Inspects a transaction for net value (coins + assets) received by the provided addresses.
 *
 * @param {PaymentAddress[]} ownAddresses own wallet's addresses
 * @param historicalTxs A list of historical transaction
 * @returns {Value} net value received
 */
export const valueReceivedInspector: TotalAddressInputsValueInspector = (ownAddresses, historicalTxs) => (tx) => {
  let assets: TokenMap = new Map();
  const totalOutputValue = totalAddressOutputsValueInspector(ownAddresses)(tx);
  const totalInputValue = totalAddressInputsValueInspector(ownAddresses, historicalTxs)(tx);
  const diff = subtractValueQuantities([totalOutputValue, totalInputValue]);

  if (diff.assets) assets = removeNegativesFromTokenMap(diff.assets);
  return {
    assets: assets.size > 0 ? assets : undefined,
    coins: diff.coins < 0n ? 0n : diff.coins
  };
};

/**
 * Generic certificate inspector.
 *
 * @param type The type name of the certificate.
 */
const certificateInspector =
  <
    T extends DelegationInspection | StakeRegistrationInspection | PoolRegistrationInspection | PoolRetirementInspection
  >(
    type: CertificateType
  ): Inspector<T> =>
  (tx) =>
    (tx.body.certificates?.filter((cert) => cert.__typename === type) as T) ?? [];

/**
 * Inspects a transaction for a stake delegation certificate.
 *
 * @param {HydratedTx} tx transaction to inspect
 * @returns {DelegationInspection} array of delegation certificates
 */
export const delegationInspector: DelegationInspector = certificateInspector<DelegationInspection>(
  CertificateType.StakeDelegation
);

/**
 * Inspects a transaction for a stake key deregistration certificate.
 *
 * @param {HydratedTx} tx transaction to inspect
 * @returns {StakeRegistrationInspection} array of stake key deregistration certificates
 */
export const stakeKeyDeregistrationInspector: StakeRegistrationInspector =
  certificateInspector<StakeRegistrationInspection>(CertificateType.StakeDeregistration);

/**
 * Inspects a transaction for a stake key registration certificate.
 *
 * @param {HydratedTx} tx transaction to inspect
 * @returns {StakeRegistrationInspection} array of stake key registration certificates
 */
export const stakeKeyRegistrationInspector: StakeRegistrationInspector =
  certificateInspector<StakeRegistrationInspection>(CertificateType.StakeRegistration);

/**
 * Inspects a transaction for pool registration certificates.
 *
 * @param {HydratedTx} tx transaction to inspect.
 * @returns {PoolRegistrationInspection} array of pool registration certificates.
 */
export const poolRegistrationInspector: PoolRegistrationInspector = certificateInspector<PoolRegistrationInspection>(
  CertificateType.PoolRegistration
);

/**
 * Inspects a transaction for pool retirement certificates.
 *
 * @param {HydratedTx} tx transaction to inspect.
 * @returns {PoolRetirementInspection} array of pool retirement certificates.
 */
export const poolRetirementInspector: PoolRetirementInspector = certificateInspector<PoolRetirementInspection>(
  CertificateType.PoolRetirement
);

/**
 * Inspects a transaction for withdrawals.
 *
 * @param {HydratedTx} tx transaction to inspect
 * @returns {WithdrawalInspection} accumulated withdrawal quantities
 */
export const withdrawalInspector: WithdrawalInspector = (tx) =>
  tx.body.withdrawals?.length ? BigIntMath.sum(tx.body.withdrawals.map(({ quantity }) => quantity)) : 0n;

/**
 * Matching criteria functor definition. This functor encodes a selection criteria for minted/burned assets.
 * For example to get all minted assets the following criteria could be provided:
 *  (quantity: bigint) => quantity > 0.
 */
export interface MatchQuantityCriteria {
  (quantity: bigint): boolean;
}

/**
 * Inspects a transaction for minted/burned assets that match a given quantity criteria.
 *
 * @param matchQuantityCriteria A functor that represents a selection criteria for minted/burned assets. Will
 * return <tt>true</tt> if the given criteria was met; otherwise; <tt>false</tt>.
 * @returns A collection with the assets that match the given criteria.
 */
export const mintInspector =
  (matchQuantityCriteria: MatchQuantityCriteria): AssetsMintedInspector =>
  (tx) => {
    const assets: AssetsMintedInspection = [];
    const scriptMap = new Map();

    if (!tx.body.mint) return assets;

    // Scripts can be embedded in transaction auxiliary data and/or the transaction witness set. If this transaction
    // was built by this client the script will be present in the witness set, however, if this transaction was
    // queried from a remote repository that doesn't fetch the witness data of the transaction we can still check
    // if the script is present in the auxiliary data.
    const scripts = [...(tx.auxiliaryData?.scripts || []), ...(tx.witness?.scripts || [])];

    for (const script of scripts) {
      switch (script.__type) {
        case ScriptType.Native: {
          const policyId = nativeScriptPolicyId(script);
          if (scriptMap.has(policyId)) continue;
          scriptMap.set(policyId, script);
          break;
        }
        case ScriptType.Plutus: // TODO: Add support for plutus minting scripts.
        default:
        // scripts of unknown type will be ignored.
      }
    }

    for (const [key, value] of tx.body.mint!.entries()) {
      const [policyId, assetName] = [AssetId.getPolicyId(key), AssetId.getAssetName(key)];

      const mintedAsset: MintedAsset = {
        assetName,
        fingerprint: AssetFingerprint.fromParts(policyId, assetName),
        policyId,
        quantity: value,
        script: scriptMap.get(policyId)
      };

      if (matchQuantityCriteria(mintedAsset.quantity)) assets.push(mintedAsset);
    }

    return assets;
  };

/** Inspect the transaction and retrieves all assets minted (quantity greater than 0). */
export const assetsMintedInspector: AssetsMintedInspector = mintInspector((quantity: bigint) => quantity > 0);

/** Inspect the transaction and retrieves all assets burned (quantity less than 0). */
export const assetsBurnedInspector: AssetsMintedInspector = mintInspector((quantity: bigint) => quantity < 0);

/**
 * Inspects a transaction for its metadata.
 *
 * @param {HydratedTx} tx transaction to inspect.
 */
export const metadataInspector: MetadataInspector = (tx) => tx.auxiliaryData?.blob ?? new Map();

/**
 * Returns a function to convert lower level transaction data to a higher level object, using the provided inspectors.
 *
 * @param {Inspectors} inspectors inspector functions scoped to a domain concept.
 */
export const createTxInspector =
  <T extends Inspectors>(inspectors: T): TxInspector<T> =>
  (tx) =>
    Object.keys(inspectors).reduce(
      (result, key) => {
        const inspector = inspectors[key];
        result[key as keyof T] = inspector(tx) as ReturnType<T[keyof T]>;
        return result;
      },
      {} as {
        [k in keyof T]: ReturnType<T[k]>;
      }
    );
