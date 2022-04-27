import {
  Address,
  Certificate,
  CertificateType,
  Ed25519KeyHash,
  Lovelace,
  RewardAccount,
  StakeAddressCertificate,
  StakeDelegationCertificate,
  TokenMap,
  TxAlonzo,
  TxIn,
  Value
} from '../Cardano';
import { BigIntMath } from './BigIntMath';
import { coalesceValueQuantities, resolveInputValue, subtractValueQuantities } from '../Cardano/util';
import { inputsWithAddresses, isAddressWithin } from '../Address/util';
import { removeNegativesFromTokenMap } from '../Asset/util';

type Inspector<Inspection> = (tx: TxAlonzo) => Inspection;
type Inspectors = { [k: string]: Inspector<unknown> };
type TxInspector<T extends Inspectors> = (tx: TxAlonzo) => {
  [k in keyof T]: ReturnType<T[k]>;
};

// Inspection result types
export type SendReceiveValueInspection = Value;
export type DelegationInspection = StakeDelegationCertificate[];
export type StakeKeyRegistrationInspection = StakeAddressCertificate[];
export type WithdrawalInspection = Lovelace;
export interface SentInspection {
  inputs: TxIn[];
  certificates: Certificate[];
}

// Inspector types
interface SentInspectorArgs {
  addresses?: Address[];
  rewardAccounts?: RewardAccount[];
}
export type SentInspector = (args: SentInspectorArgs) => Inspector<SentInspection>;
export type TotalAddressInputsValueInspector = (
  ownAddresses: Address[],
  getHistoricalTxs: () => TxAlonzo[]
) => Inspector<SendReceiveValueInspection>;
export type SendReceiveValueInspector = (ownAddresses: Address[]) => Inspector<SendReceiveValueInspection>;
export type DelegationInspector = Inspector<DelegationInspection>;
export type StakeKeyRegistrationInspector = Inspector<StakeKeyRegistrationInspection>;
export type WithdrawalInspector = Inspector<WithdrawalInspection>;

/**
 * Inspects a transaction for values (coins + assets) in inputs
 * containing any of the provided addresses.
 *
 * @param {Address[]} ownAddresses own wallet's addresses
 * @param {() => TxAlonzo[]} getHistoricalTxs wallet's historical transactions
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
 * @param {Address[]} ownAddresses own wallet's addresses
 * @returns {Value} total value in outputs
 */
export const totalAddressOutputsValueInspector: SendReceiveValueInspector = (ownAddresses) => (tx) => {
  const receivedOutputs = tx.body.outputs.filter((out) => isAddressWithin(ownAddresses)(out));
  return coalesceValueQuantities(receivedOutputs.map((output) => output.value));
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
  (tx: TxAlonzo) => {
    const inputs = addresses?.length ? inputsWithAddresses(tx, addresses) : [];

    const stakeKeyHashes = rewardAccounts?.map((account) => Ed25519KeyHash.fromRewardAccount(account));
    const stakeKeyCerts =
      stakeKeyHashes && tx.body.certificates
        ? tx.body.certificates.filter((cert) => 'stakeKeyHash' in cert && stakeKeyHashes.includes(cert.stakeKeyHash))
        : [];
    const rewardAccountCerts =
      rewardAccounts && tx.body.certificates
        ? tx.body.certificates?.filter(
            (cert) =>
              ('rewardAccount' in cert && rewardAccounts.includes(cert.rewardAccount)) ||
              ('poolParameters' in cert && rewardAccounts.includes(cert.poolParameters.rewardAccount))
          )
        : [];
    const certificates = [...stakeKeyCerts, ...rewardAccountCerts];

    return { certificates, inputs };
  };

/**
 * Inspects a transaction for net value (coins + assets) sent by the provided addresses.
 *
 * @param {Address[]} ownAddresses own wallet's addresses
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
 * @param {Address[]} ownAddresses own wallet's addresses
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
 * Inspects a transaction for a stake delegation certificate.
 *
 * @param {TxAlonzo} tx transaction to inspect
 * @returns {DelegationInspection} array of delegation certificates
 */
export const delegationInspector: DelegationInspector = (tx: TxAlonzo) =>
  (tx.body.certificates?.filter(
    (cert) => cert.__typename === CertificateType.StakeDelegation
  ) as StakeDelegationCertificate[]) ?? [];

/**
 * Inspects a transaction for a stake key registration certificate.
 *
 * @param {TxAlonzo} tx transaction to inspect
 * @returns {StakeKeyRegistrationInspection} array of stake key registration certificates
 */
export const stakeKeyRegistrationInspector: StakeKeyRegistrationInspector = (tx: TxAlonzo) =>
  (tx.body.certificates?.filter(
    (cert) => cert.__typename === CertificateType.StakeKeyRegistration
  ) as StakeAddressCertificate[]) ?? [];

/**
 * Inspects a transaction for a stake key deregistration certificate.
 *
 * @param {TxAlonzo} tx transaction to inspect
 * @returns {StakeKeyRegistrationInspection} array of stake key deregistration certificates
 */
export const stakeKeyDeregistrationInspector: StakeKeyRegistrationInspector = (tx: TxAlonzo) =>
  (tx.body.certificates?.filter(
    (cert) => cert.__typename === CertificateType.StakeKeyDeregistration
  ) as StakeAddressCertificate[]) ?? [];

/**
 * Inspects a transaction for withdrawals.
 *
 * @param {TxAlonzo} tx transaction to inspect
 * @returns {WithdrawalInspection} accumulated withdrawal quantities
 */
export const withdrawalInspector: WithdrawalInspector = (tx: TxAlonzo) =>
  tx.body.withdrawals?.length ? BigIntMath.sum(tx.body.withdrawals.map(({ quantity }) => quantity)) : 0n;

/**
 * Returns a function to convert lower level transaction data to a higher level object, using the provided inspectors.
 *
 * @param {Inspectors} inspectors inspector functions scoped to a domain concept.
 */
export const createTxInspector =
  <T extends Inspectors>(inspectors: T): TxInspector<T> =>
  (tx: TxAlonzo) =>
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
