import * as Crypto from '@cardano-sdk/crypto';
import { AccountKeyDerivationPath, GroupedAddress, TxInId, TxInKeyPathMap } from '../types';
import { Cardano } from '@cardano-sdk/core';
import { DREP_KEY_DERIVATION_PATH } from './key';
import { isNotNil } from '@cardano-sdk/util';
import isEqual from 'lodash/isEqual';
import uniqBy from 'lodash/uniqBy';
import uniqWith from 'lodash/uniqWith';

export type StakeKeySignerData = {
  poolId: Cardano.PoolId;
  rewardAccount: Cardano.RewardAccount;
  stakeKeyHash: Crypto.Ed25519KeyHashHex;
  derivationPath: AccountKeyDerivationPath;
};

/** Return type of functions that inspect transaction parts for signatures */
type SignatureCheck = {
  /** Signature derivation paths */
  derivationPaths: AccountKeyDerivationPath[];
  /** Whether foreign signatures (not owned by wallet) are needed */
  requiresForeignSignatures: boolean;
};

/** Checks whether the transaction withdrawals contain foreign signatures and returns known derivation paths  */
const checkWithdrawals = (
  { withdrawals }: Pick<Cardano.TxBody, 'withdrawals'>,
  accounts: StakeKeySignerData[]
): SignatureCheck => {
  const signatureCheck: SignatureCheck = { derivationPaths: [], requiresForeignSignatures: false };
  if (withdrawals) {
    for (const withdrawal of withdrawals) {
      const account = accounts.find((acct) => acct.rewardAccount === withdrawal.stakeAddress);
      if (account) {
        signatureCheck.derivationPaths.push(account.derivationPath);
      } else {
        signatureCheck.requiresForeignSignatures = true;
      }
    }
  }

  return signatureCheck;
};

const checkStakeKeyHashCertificate = (
  certificate: Cardano.Certificate,
  accounts: StakeKeySignerData[]
): SignatureCheck => {
  const signatureCheck: SignatureCheck = { derivationPaths: [], requiresForeignSignatures: false };
  switch (certificate.__typename) {
    case Cardano.CertificateType.VoteDelegation:
    case Cardano.CertificateType.StakeVoteDelegation:
    case Cardano.CertificateType.StakeRegistrationDelegation:
    case Cardano.CertificateType.VoteRegistrationDelegation:
    case Cardano.CertificateType.StakeVoteRegistrationDelegation:
    case Cardano.CertificateType.Registration:
    case Cardano.CertificateType.Unregistration:
    case Cardano.CertificateType.StakeDeregistration:
    case Cardano.CertificateType.StakeDelegation: {
      const account = accounts.find(
        (acct) =>
          certificate.stakeCredential.type === Cardano.CredentialType.KeyHash &&
          acct.stakeKeyHash === (certificate.stakeCredential.hash as unknown as Crypto.Ed25519KeyHashHex)
      );
      if (account) {
        signatureCheck.derivationPaths = [account.derivationPath];
      } else {
        signatureCheck.requiresForeignSignatures = true;
      }
    }
  }
  return signatureCheck;
};

const checkPoolRegistrationCertificate = (
  certificate: Cardano.Certificate,
  accounts: StakeKeySignerData[]
): SignatureCheck => {
  const signatureCheck: SignatureCheck = { derivationPaths: [], requiresForeignSignatures: false };
  if (certificate.__typename === Cardano.CertificateType.PoolRegistration) {
    for (const owner of certificate.poolParameters.owners) {
      const account = accounts.find((acct) => acct.rewardAccount === owner);
      if (account) {
        signatureCheck.derivationPaths.push(account.derivationPath);
      } else {
        signatureCheck.requiresForeignSignatures = true;
      }
    }
  }
  return signatureCheck;
};

const checkPoolRetirementCertificate = (
  certificate: Cardano.Certificate,
  accounts: StakeKeySignerData[]
): SignatureCheck => {
  const signatureCheck: SignatureCheck = { derivationPaths: [], requiresForeignSignatures: false };
  if (certificate.__typename === Cardano.CertificateType.PoolRetirement) {
    const account = accounts.find((acct) => acct.poolId === certificate.poolId);
    if (account) {
      signatureCheck.derivationPaths.push(account.derivationPath);
    } else {
      signatureCheck.requiresForeignSignatures = true;
    }
  }
  return signatureCheck;
};

const checkMirCertificate = (certificate: Cardano.Certificate, accounts: StakeKeySignerData[]): SignatureCheck => {
  const signatureCheck: SignatureCheck = { derivationPaths: [], requiresForeignSignatures: false };
  if (certificate.__typename === Cardano.CertificateType.MIR) {
    if (certificate.kind === Cardano.MirCertificateKind.ToStakeCreds) {
      const account = accounts.find(
        (acct) => Crypto.Hash28ByteBase16(acct.stakeKeyHash) === certificate.stakeCredential!.hash
      );
      if (account) {
        signatureCheck.derivationPaths.push(account.derivationPath);
      } else {
        signatureCheck.requiresForeignSignatures = true;
      }
    } else {
      signatureCheck.requiresForeignSignatures = true;
    }
  }
  return signatureCheck;
};

/**
 * Inspect certificates against own stake credentials. Determines the signature derivation paths, and wether there
 * are certificates it cannot sign (foreign signatures).
 */
export const checkStakeCredentialCertificates = (
  accounts: StakeKeySignerData[],
  { certificates }: Pick<Cardano.TxBody, 'certificates'>
): SignatureCheck => {
  const signatureCheck: SignatureCheck = { derivationPaths: [], requiresForeignSignatures: false };

  if (!certificates?.length) {
    return signatureCheck;
  }

  for (const certificate of certificates) {
    const stakeKeyHashCheck = checkStakeKeyHashCertificate(certificate, accounts);
    signatureCheck.requiresForeignSignatures ||= stakeKeyHashCheck.requiresForeignSignatures;
    signatureCheck.derivationPaths.push(...stakeKeyHashCheck.derivationPaths);

    const poolOwnerCheck = checkPoolRegistrationCertificate(certificate, accounts);
    signatureCheck.requiresForeignSignatures ||= poolOwnerCheck.requiresForeignSignatures;
    signatureCheck.derivationPaths.push(...poolOwnerCheck.derivationPaths);

    const poolIdCheck = checkPoolRetirementCertificate(certificate, accounts);
    signatureCheck.requiresForeignSignatures ||= poolIdCheck.requiresForeignSignatures;
    signatureCheck.derivationPaths.push(...poolIdCheck.derivationPaths);

    const mirCheck = checkMirCertificate(certificate, accounts);
    signatureCheck.requiresForeignSignatures ||= mirCheck.requiresForeignSignatures;
    signatureCheck.derivationPaths.push(...mirCheck.derivationPaths);

    // StakeRegistration and GenesisKeyDelegation do not require signing
  }

  signatureCheck.derivationPaths = uniqWith(signatureCheck.derivationPaths, isEqual);
  return signatureCheck;
};

const getSignersData = (groupedAddresses: GroupedAddress[]): StakeKeySignerData[] =>
  uniqBy(groupedAddresses, 'rewardAccount')
    .map((groupedAddress) => {
      const stakeKeyHash = Cardano.RewardAccount.toHash(groupedAddress.rewardAccount);
      const poolId = Cardano.PoolId.fromKeyHash(stakeKeyHash);
      return {
        derivationPath: groupedAddress.stakeKeyDerivationPath,
        poolId,
        rewardAccount: groupedAddress.rewardAccount,
        stakeKeyHash
      };
    })
    .filter((acct): acct is StakeKeySignerData => acct.derivationPath !== undefined);

/**
 * Gets whether withdrawals or any certificate in the provided certificate list requires a stake key signature.
 *
 * @param groupedAddresses The known grouped addresses.
 * @param txBody The transaction body.
 */
const getStakeCredentialKeyPaths = (groupedAddresses: GroupedAddress[], txBody: Cardano.TxBody) => {
  let requiresForeignSignatures = false;
  const paths: AccountKeyDerivationPath[] = [];
  const uniqueAccounts = getSignersData(groupedAddresses);

  const withdrawalCheck = checkWithdrawals(txBody, uniqueAccounts);
  requiresForeignSignatures ||= withdrawalCheck.requiresForeignSignatures;
  paths.push(...withdrawalCheck.derivationPaths);

  const stakeCredentialCertificatesCheck = checkStakeCredentialCertificates(uniqueAccounts, txBody);
  requiresForeignSignatures ||= stakeCredentialCertificatesCheck.requiresForeignSignatures;
  paths.push(...stakeCredentialCertificatesCheck.derivationPaths);

  return { derivationPaths: new Set(paths), requiresForeignSignatures };
};

/**
 * Depending on transaction `voting_procedures = { + voter => { + gov_action_id => voting_procedure } }`
 * ; Constitutional Committee Hot KeyHash: 0
 * ; Constitutional Committee Hot ScriptHash: 1
 * ; DRep KeyHash: 2
 * ; DRep ScriptHash: 3
 * ; StakingPool KeyHash: 4
 * voter =
 *   [ 0, addr_keyhash
 *   // 1, scripthash
 *   // 2, addr_keyhash
 *   // 3, scripthash
 *   // 4, addr_keyhash
 *   ]
 */
export const getVotingProcedureKeyPaths = ({
  groupedAddresses,
  dRepKeyHash,
  txBody
}: {
  groupedAddresses: GroupedAddress[];
  dRepKeyHash?: Crypto.Ed25519KeyHashHex;
  txBody: Cardano.TxBody;
}): SignatureCheck => {
  const signatureCheck: SignatureCheck = { derivationPaths: [], requiresForeignSignatures: false };

  const accounts = getSignersData(groupedAddresses);

  for (const { voter } of txBody.votingProcedures || []) {
    switch (voter.__typename) {
      case Cardano.VoterType.dRepKeyHash: {
        if (dRepKeyHash && voter.credential.hash === Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(dRepKeyHash)) {
          signatureCheck.derivationPaths.push(DREP_KEY_DERIVATION_PATH);
        } else {
          signatureCheck.requiresForeignSignatures = true;
        }
        break;
      }
      case Cardano.VoterType.stakePoolKeyHash: {
        const account = accounts.find(
          (acct) => Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(acct.stakeKeyHash) === voter.credential.hash
        );
        if (account) {
          signatureCheck.derivationPaths.push(account.derivationPath);
        } else {
          signatureCheck.requiresForeignSignatures = true;
        }
        break;
      }
      default:
        // case Cardano.VoterType.ccHotKeyHash:
        // case Cardano.VoterType.ccHotScriptHash:
        // case Cardano.VoterType.dRepScriptHash:
        signatureCheck.requiresForeignSignatures = true;
        break;
    }
  }

  return signatureCheck;
};

/**
 * Search for the key hashes provided in the requiredSigners in our current set of known addresses.
 *
 * @param groupedAddresses The known grouped addresses.
 * @param keyHashes The list of required signers key hashes (or undefined if none).
 * @returns A set of derivation paths if any of the key hashes is found.
 */
const getRequiredSignersKeyPaths = (
  groupedAddresses: GroupedAddress[],
  keyHashes?: Crypto.Ed25519KeyHashHex[]
): AccountKeyDerivationPath[] => {
  const paths: AccountKeyDerivationPath[] = [];

  if (!keyHashes) return paths;

  for (const keyHash of keyHashes) {
    for (const address of groupedAddresses) {
      const paymentCredential = Cardano.Address.fromBech32(address.address)?.asBase()?.getPaymentCredential().hash;
      const stakeCredential = Cardano.RewardAccount.toHash(address.rewardAccount);

      if (paymentCredential && paymentCredential.toString() === keyHash) {
        paths.push({ index: address.index, role: Number(address.type) });
      }

      if (stakeCredential && address.stakeKeyDerivationPath && stakeCredential.toString() === keyHash) {
        paths.push(address.stakeKeyDerivationPath);
      }
    }
  }

  return paths;
};

/** Check if there are certificates that require DRep credentials and if we own them */
export const getDRepCredentialKeyPaths = ({
  dRepKeyHash,
  txBody
}: {
  dRepKeyHash?: Crypto.Ed25519KeyHashHex;
  txBody: Cardano.TxBody;
}): SignatureCheck => {
  const signature: SignatureCheck = { derivationPaths: [], requiresForeignSignatures: false };

  for (const certificate of txBody.certificates || []) {
    if (
      certificate.__typename === Cardano.CertificateType.UnregisterDelegateRepresentative ||
      certificate.__typename === Cardano.CertificateType.UpdateDelegateRepresentative ||
      certificate.__typename === Cardano.CertificateType.RegisterDelegateRepresentative
    ) {
      if (
        certificate.dRepCredential.type === Cardano.CredentialType.ScriptHash ||
        !dRepKeyHash ||
        certificate.dRepCredential.hash !== Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(dRepKeyHash)
      ) {
        // Scripts are foreign
        signature.requiresForeignSignatures = true;
      } else {
        // There's only one drep key that the wallet owns.
        signature.derivationPaths = [DREP_KEY_DERIVATION_PATH];
      }
    }
  }

  return signature;
};

// TODO: test
export const createTxInKeyPathMap = async (
  txBody: Cardano.TxBody,
  knownAddresses: GroupedAddress[],
  inputResolver: Cardano.InputResolver
) => {
  const result: TxInKeyPathMap = {};
  const txInputs = [...txBody.inputs, ...(txBody.collaterals ? txBody.collaterals : [])];
  await Promise.all(
    txInputs.map(async (txIn) => {
      const resolution = await inputResolver.resolveInput(txIn);
      if (!resolution) return;
      const ownAddress = knownAddresses.find(({ address }) => address === resolution.address);
      if (!ownAddress) return;
      result[TxInId(txIn)] = { index: ownAddress.index, role: Number(ownAddress.type) };
    })
  );

  return result;
};

/**
 * Assumes that a single stake key is used for all addresses (index=0)
 *
 * @returns {AccountKeyDerivationPath[]} derivation paths for keys to sign transaction with
 */
export const ownSignatureKeyPaths = (
  txBody: Cardano.TxBody,
  knownAddresses: GroupedAddress[],
  txInKeyPathMap: TxInKeyPathMap,
  dRepKeyHash?: Crypto.Ed25519KeyHashHex
): AccountKeyDerivationPath[] => {
  // TODO: add `proposal_procedure` witnesses.

  const paymentKeyPaths = Object.values(txInKeyPathMap).filter(isNotNil);
  return uniqWith(
    [
      ...paymentKeyPaths,
      ...getStakeCredentialKeyPaths(knownAddresses, txBody).derivationPaths,
      ...getDRepCredentialKeyPaths({ dRepKeyHash, txBody }).derivationPaths,
      ...getRequiredSignersKeyPaths(knownAddresses, txBody.requiredExtraSignatures),
      ...getVotingProcedureKeyPaths({ dRepKeyHash, groupedAddresses: knownAddresses, txBody }).derivationPaths
    ],
    isEqual
  );
};
