import {
  Address,
  CertificateType,
  Lovelace,
  StakeAddressCertificate,
  StakeDelegationCertificate,
  TxAlonzo,
  Value
} from '../Cardano';
import { BigIntMath } from './BigIntMath';
import { coalesceValueQuantities } from '../Cardano/util';
import { isAddressWithin, isOutgoing } from '../Address/util';

type Inspector<Inspection> = (tx: TxAlonzo) => Inspection;
type Inspectors = { [k: string]: Inspector<unknown> };
type TxInspector<T extends Inspectors> = (tx: TxAlonzo) => {
  [k in keyof T]: ReturnType<T[k]>;
};

// Inspectors result types
export type SendReceiveValueInspection = Value;
export type DelegationInspection = StakeDelegationCertificate[];
export type StakeKeyRegistrationInspection = StakeAddressCertificate[];
export type WithdrawalInspection = Lovelace;

/**
 * Inspects a transaction for value (coins + assets) sent by the provided addresses.
 *
 * @param {Address[]} ownAddresses own wallet's addresses
 * @returns {Value} total value sent
 */
export const valueSentInspector =
  (ownAddresses: Address[]): Inspector<Value> =>
  (tx: TxAlonzo): SendReceiveValueInspection => {
    if (!isOutgoing(tx, ownAddresses)) return { coins: 0n };
    const sentOutputs = tx.body.outputs.filter((out) => !isAddressWithin(ownAddresses)(out));
    return coalesceValueQuantities(sentOutputs.map((output) => output.value));
  };

/**
 * Inspects a transaction for value (coins + assets) received by the provided addresses.
 *
 * @param {Address[]} ownAddresses own wallet's addresses
 * @returns {Value} total value received
 */
export const valueReceivedInspector =
  (ownAddresses: Address[]): Inspector<Value> =>
  (tx: TxAlonzo): SendReceiveValueInspection => {
    if (isOutgoing(tx, ownAddresses)) return { coins: 0n };
    const receivedOutputs = tx.body.outputs.filter((out) => isAddressWithin(ownAddresses)(out));
    return coalesceValueQuantities(receivedOutputs.map((output) => output.value));
  };

/**
 * Inspects a transaction for a stake delegation certificate.
 *
 * @param {TxAlonzo} tx transaction to inspect
 * @returns {DelegationInspection} array of delegation certificates
 */
export const delegationInspector: Inspector<DelegationInspection> = (tx: TxAlonzo) =>
  (tx.body.certificates?.filter(
    (cert) => cert.__typename === CertificateType.StakeDelegation
  ) as StakeDelegationCertificate[]) ?? [];

/**
 * Inspects a transaction for a stake key registration certificate.
 *
 * @param {TxAlonzo} tx transaction to inspect
 * @returns {StakeKeyRegistrationInspection} array of stake key registration certificates
 */
export const stakeKeyRegistrationInspector: Inspector<StakeKeyRegistrationInspection> = (tx: TxAlonzo) =>
  (tx.body.certificates?.filter(
    (cert) => cert.__typename === CertificateType.StakeKeyRegistration
  ) as StakeAddressCertificate[]) ?? [];

/**
 * Inspects a transaction for a stake key deregistration certificate.
 *
 * @param {TxAlonzo} tx transaction to inspect
 * @returns {StakeKeyRegistrationInspection} array of stake key deregistration certificates
 */
export const stakeKeyDeregistrationInspector: Inspector<StakeKeyRegistrationInspection> = (tx: TxAlonzo) =>
  (tx.body.certificates?.filter(
    (cert) => cert.__typename === CertificateType.StakeKeyDeregistration
  ) as StakeAddressCertificate[]) ?? [];

/**
 * Inspects a transaction for withdrawals.
 *
 * @param {TxAlonzo} tx transaction to inspect
 * @returns {WithdrawalInspection} accumulated withdrawal quantities
 */
export const withdrawalInspector: Inspector<WithdrawalInspection> = (tx: TxAlonzo) =>
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
