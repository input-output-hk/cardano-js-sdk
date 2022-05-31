// Based on Nami implementation
// https://github.com/Berry-Pool/nami-wallet/blob/39fb256af9547f801f57a673a5f02d0c7cef42c2/src/api/util.js#L636
/* eslint-disable sonarjs/cognitive-complexity,  max-depth, max-statements, complexity */
import {
  AddressType,
  AssetGroup,
  BIP32Path,
  Certificate,
  CertificateType,
  HARDENED,
  KeyPathStakeCredentialParams,
  PoolKey,
  PoolKeyType,
  PoolOwner,
  PoolOwnerType,
  PoolRewardAccount,
  PoolRewardAccountType,
  Relay,
  RelayType,
  ScriptStakeCredentialParams,
  SignTransactionRequest,
  StakeCredentialParamsType,
  Token,
  TransactionSigningMode,
  TxAuxiliaryData,
  TxAuxiliaryDataType,
  TxInput,
  TxOutput,
  TxOutputDestination,
  TxOutputDestinationType,
  Withdrawal,
  utils
} from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { CSL, Cardano, cslToCore } from '@cardano-sdk/core';
import { GroupedAddress, ResolveInputAddress } from '../types';
import { HwMappingError } from '../errors';
import { concat, uniq } from 'lodash-es';
import { isNotNil } from '@cardano-sdk/util';

export interface TxToLedgerProps {
  cslTxBody: CSL.TransactionBody;
  networkId: Cardano.NetworkId;
  accountIndex: number;
  inputAddressResolver: ResolveInputAddress;
  knownAddresses: GroupedAddress[];
}

export interface LedgerCertificates {
  certs: Certificate[] | null;
  signingMode?: TransactionSigningMode;
}

export interface LedgerMintBundle {
  mintAssetsGroup: AssetGroup[] | null;
  additionalWitnessPaths: BIP32Path[];
}

const sortTokensCanonically = (tokens: Token[]) => {
  tokens.sort((a, b) => {
    if (a.assetNameHex.length === b.assetNameHex.length) {
      return a.assetNameHex > b.assetNameHex ? 1 : -1;
    } else if (a.assetNameHex.length > b.assetNameHex.length) return 1;
    return -1;
  });
};

const getRewardAccountKeyHash = (rewardAccount: Cardano.RewardAccount) =>
  Buffer.from(
    CSL.RewardAddress.from_address(CSL.Address.from_bech32(rewardAccount.toString()))!
      .payment_cred()!
      .to_keyhash()!
      .to_bytes()
  ).toString('hex');

const bytesToIp = (bytes?: Uint8Array) => {
  if (!bytes) return null;
  if (bytes.length === 4) {
    return bytes.join('.');
  } else if (bytes.length === 16) {
    let ipv6 = '';
    for (let i = 0; i < bytes.length; i += 2) {
      ipv6 += `${bytes[i].toString(16) + bytes[i + 1].toString(16)}:`;
    }
    ipv6 = ipv6.slice(0, -1);
    return ipv6;
  }
  return null;
};

const prepareLedgerInputs = (
  inputs: CSL.TransactionInputs,
  inputAddressResolver: ResolveInputAddress,
  knownAddresses: GroupedAddress[]
): TxInput[] => {
  const ledgerInputs = [];
  for (let i = 0; i < inputs.len(); i++) {
    const input = inputs.get(i);
    const coreInput = cslToCore.txIn(input);
    const paymentAddress = inputAddressResolver(coreInput);

    let paymentKeyPath = null;
    if (paymentAddress) {
      const knownAddress = knownAddresses.find(({ address }) => address === paymentAddress);
      if (knownAddress) {
        paymentKeyPath = [
          HARDENED + 1852,
          HARDENED + 1815,
          HARDENED + knownAddress.accountIndex,
          knownAddress.type,
          knownAddress.index
        ];
      }
    }
    ledgerInputs.push({
      outputIndex: input.index(),
      path: paymentKeyPath,
      txHashHex: Buffer.from(input.transaction_id().to_bytes()).toString('hex')
    });
  }
  return ledgerInputs;
};

const prepareLedgerOutputs = (
  outputs: CSL.TransactionOutputs,
  accountIndex: number,
  knownAddresses: GroupedAddress[]
): TxOutput[] => {
  const ledgerOutputs = [];
  for (let i = 0; i < outputs.len(); i++) {
    const output = outputs.get(i);
    const multiAsset = output.amount().multiasset();
    const tokenBundle = [];
    if (multiAsset) {
      for (let j = 0; j < multiAsset.keys().len(); j++) {
        const policy = multiAsset.keys().get(j);
        const assets = multiAsset.get(policy);
        const tokens = [];
        if (assets) {
          for (let k = 0; k < assets.keys().len(); k++) {
            const assetName = assets.keys().get(k);
            const amount = assets.get(assetName);
            if (assetName && amount) {
              tokens.push({
                amount: amount.to_str(),
                assetNameHex: Buffer.from(assetName.name()).toString('hex')
              });
            }
          }
        }
        sortTokensCanonically(tokens);
        tokenBundle.push({
          policyIdHex: Buffer.from(policy.to_bytes()).toString('hex'),
          tokens
        });
      }
    }
    const outputAddress = Buffer.from(output.address().to_bytes());
    const isDeviceOwned = knownAddresses.some(
      ({ address }) => address.toString() === utils.bech32_encodeAddress(outputAddress)
    );
    const destination: TxOutputDestination = isDeviceOwned
      ? {
          params: {
            params: {
              spendingPath: [HARDENED + 1852, HARDENED + 1815, HARDENED + accountIndex, 0, 0],
              stakingPath: [HARDENED + 1852, HARDENED + 1815, HARDENED + accountIndex, 2, 0]
            },
            type: AddressType.BASE_PAYMENT_KEY_STAKE_KEY
          },
          type: TxOutputDestinationType.DEVICE_OWNED
        }
      : {
          params: {
            addressHex: outputAddress.toString('hex')
          },
          type: TxOutputDestinationType.THIRD_PARTY
        };
    const outputDataHash = output.data_hash();
    const datumHashHex = outputDataHash ? Buffer.from(outputDataHash.to_bytes()).toString('hex') : null;
    const outputRes = {
      amount: output.amount().coin().to_str(),
      datumHashHex,
      destination,
      tokenBundle
    };
    ledgerOutputs.push(outputRes);
  }
  return ledgerOutputs;
};

const prepareLedgerCertificates = (
  certificates: CSL.Certificates,
  knownAddresses: GroupedAddress[],
  rewardAccountKeyPath: BIP32Path,
  rewardAccountKeyHash: string
): LedgerCertificates => {
  let signingMode;
  const certs = [];
  for (let i = 0; i < certificates.len(); i++) {
    const cert = certificates.get(i);
    const certificate = {} as Certificate;
    if (cert.kind() === 0) {
      const credential = cert.as_stake_registration()?.stake_credential();
      const credentialScriptHash = credential?.to_scripthash();
      certificate.type = CertificateType.STAKE_REGISTRATION;

      if (credential?.kind() === 0) {
        certificate.params = {
          stakeCredential: {
            keyPath: rewardAccountKeyPath,
            type: StakeCredentialParamsType.KEY_PATH
          }
        };
      } else if (credential && credentialScriptHash) {
        const scriptHashHex = Buffer.from(credentialScriptHash.to_bytes()).toString('hex');
        certificate.params = {
          stakeCredential: {
            scriptHashHex,
            type: StakeCredentialParamsType.SCRIPT_HASH
          }
        };
      }
    } else if (cert.kind() === 1) {
      const credential = cert.as_stake_deregistration()?.stake_credential();
      const credentialScriptHash = credential?.to_scripthash();
      certificate.type = CertificateType.STAKE_DEREGISTRATION;

      if (credential?.kind() === 0) {
        certificate.params = {
          stakeCredential: {
            keyPath: rewardAccountKeyPath,
            type: StakeCredentialParamsType.KEY_PATH
          }
        };
      } else if (credential && credentialScriptHash) {
        const scriptHashHex = Buffer.from(credentialScriptHash.to_bytes()).toString('hex');
        certificate.params = {
          stakeCredential: {
            scriptHashHex,
            type: StakeCredentialParamsType.SCRIPT_HASH
          }
        };
      }
    } else if (cert.kind() === 2) {
      const delegation = cert.as_stake_delegation();
      const delegationPoolKeyHash = delegation?.pool_keyhash();
      const credential = delegation?.stake_credential();
      const credentialScriptHash = credential?.to_scripthash();
      certificate.type = CertificateType.STAKE_DELEGATION;
      if (credential?.kind() === 0) {
        certificate.params = {
          stakeCredential: {
            keyPath: rewardAccountKeyPath,
            type: StakeCredentialParamsType.KEY_PATH
          }
        };
      } else if (credentialScriptHash) {
        const scriptHashHex = Buffer.from(credentialScriptHash.to_bytes()).toString('hex');
        certificate.params = {
          stakeCredential: {
            scriptHashHex,
            type: StakeCredentialParamsType.SCRIPT_HASH
          }
        };
      }
      // Always apply pool key hash to cert type STAKE_DELEGATION
      if (delegationPoolKeyHash) {
        certificate.params = {
          ...certificate.params,
          poolKeyHashHex: Buffer.from(delegationPoolKeyHash.to_bytes()).toString('hex')
        };
      }
    } else if (cert.kind() === 3) {
      const params = cert.as_pool_registration()?.pool_params();
      if (!params) {
        throw new HwMappingError('Missing pool registration pool parameters.');
      }
      certificate.type = CertificateType.STAKE_POOL_REGISTRATION;
      const owners = params?.pool_owners();
      const poolOwners = [] as PoolOwner[];

      if (owners) {
        for (let j = 0; j < owners.len(); j++) {
          const keyHash = Buffer.from(owners.get(j).to_bytes()).toString('hex');
          if (keyHash === rewardAccountKeyHash) {
            signingMode = TransactionSigningMode.POOL_REGISTRATION_AS_OWNER;
            poolOwners.push({
              params: {
                stakingPath: rewardAccountKeyPath
              },
              type: PoolOwnerType.DEVICE_OWNED
            });
          } else {
            poolOwners.push({
              params: {
                stakingKeyHashHex: keyHash
              },
              type: PoolOwnerType.THIRD_PARTY
            });
          }
        }
      }
      const relays = params?.relays();
      const ledgerRelays = [] as Relay[];

      if (relays) {
        for (let k = 0; k < relays.len(); k++) {
          const relay = relays.get(k);
          if (relay.kind() === 0) {
            const singleHostAddr = relay.as_single_host_addr();
            const type = RelayType.SINGLE_HOST_IP_ADDR;
            const portNumber = singleHostAddr?.port();
            const ipv4 = singleHostAddr?.ipv4() ? bytesToIp(singleHostAddr.ipv4()?.ip()) : null;
            const ipv6 = singleHostAddr?.ipv6() ? bytesToIp(singleHostAddr.ipv6()?.ip()) : null;
            ledgerRelays.push({ params: { ipv4, ipv6, portNumber }, type });
          } else if (relay.kind() === 1) {
            const type = RelayType.SINGLE_HOST_HOSTNAME;
            const singleHostName = relay.as_single_host_name();
            if (singleHostName) {
              const portNumber = singleHostName.port();
              const dnsName = singleHostName.dns_name().record();
              ledgerRelays.push({
                params: { dnsName, portNumber },
                type
              });
            }
          } else if (relay.kind() === 2) {
            const type = RelayType.MULTI_HOST;
            const multiHostName = relay.as_multi_host_name();
            const dnsName = multiHostName?.dns_name().record();
            if (dnsName) {
              ledgerRelays.push({
                params: { dnsName },
                type
              });
            }
          }
        }
      }
      const cost = params?.cost().to_str();
      const margin = params?.margin();
      const pledge = params?.pledge().to_str();

      const operator = Buffer.from(params.operator().to_bytes()).toString('hex');
      let poolKey: PoolKey;
      if (operator === rewardAccountKeyHash) {
        signingMode = TransactionSigningMode.POOL_REGISTRATION_AS_OPERATOR;
        poolKey = {
          params: { path: rewardAccountKeyPath },
          type: PoolKeyType.DEVICE_OWNED
        };
      } else {
        poolKey = {
          params: { keyHashHex: operator },
          type: PoolKeyType.THIRD_PARTY
        };
      }

      const poolMetadata = params.pool_metadata();
      const metadata = poolMetadata
        ? {
            metadataHashHex: Buffer.from(poolMetadata.pool_metadata_hash().to_bytes()).toString('hex'),
            metadataUrl: poolMetadata.url().url()
          }
        : null;

      const rewardAccountBytes = Buffer.from(params.reward_account().to_address().to_bytes());
      const isDeviceOwned = knownAddresses.some(
        ({ address }) => address.toString() === utils.bech32_encodeAddress(rewardAccountBytes)
      );
      const rewardAccount: PoolRewardAccount = isDeviceOwned
        ? {
            params: { path: rewardAccountKeyPath },
            type: PoolRewardAccountType.DEVICE_OWNED
          }
        : {
            params: { rewardAccountHex: rewardAccountBytes.toString('hex') },
            type: PoolRewardAccountType.THIRD_PARTY
          };
      const vrfKeyHashHex = Buffer.from(params.vrf_keyhash().to_bytes()).toString('hex');

      certificate.params = {
        cost,
        margin: {
          denominator: margin.denominator().to_str(),
          numerator: margin.numerator().to_str()
        },
        metadata,
        pledge,
        poolKey,
        poolOwners,
        relays: ledgerRelays,
        rewardAccount,
        vrfKeyHashHex
      };
    }
    certs.push(certificate);
  }
  return {
    certs,
    signingMode
  };
};

const prepareLedgerWithdrawals = (withdrawals: CSL.Withdrawals, rewardAccountKeyPath: BIP32Path): Withdrawal[] => {
  const ledgerWithdrawals = [];
  for (let i = 0; i < withdrawals.keys().len(); i++) {
    const withdrawal = { stakeCredential: {} } as Withdrawal;
    const rewardAddress = withdrawals.keys().get(i);
    const paymentCredentials = rewardAddress.payment_cred();
    const paymentCredentialsScriptHash = paymentCredentials.to_scripthash();
    if (rewardAddress.payment_cred().kind() === 0) {
      const stakeCredential: KeyPathStakeCredentialParams = {
        keyPath: rewardAccountKeyPath,
        type: StakeCredentialParamsType.KEY_PATH
      };
      withdrawal.stakeCredential = stakeCredential;
    } else if (paymentCredentialsScriptHash) {
      const stakeCredential: ScriptStakeCredentialParams = {
        scriptHashHex: Buffer.from(paymentCredentialsScriptHash.to_bytes()).toString('hex'),
        type: StakeCredentialParamsType.SCRIPT_HASH
      };
      withdrawal.stakeCredential = stakeCredential;
    }
    const withdrawalAmount = withdrawals.get(rewardAddress);
    if (!withdrawalAmount) {
      throw new HwMappingError('Withdrawal amount is not defined.');
    }
    ledgerWithdrawals.push({
      ...withdrawal,
      amount: withdrawalAmount.to_str()
    });
  }
  return ledgerWithdrawals;
};

const prepareLedgerMintBundle = (
  mint: CSL.Mint,
  paymentKeyPaths: BIP32Path[],
  rewardAccountKeyPath: BIP32Path
): LedgerMintBundle => {
  const additionalWitnessPaths: BIP32Path[] = [];
  const mintAssetsGroup = [];

  for (let j = 0; j < mint.keys().len(); j++) {
    const policy = mint.keys().get(j);
    const assets = mint.get(policy);
    const tokens = [];
    if (assets) {
      for (let k = 0; k < assets.keys().len(); k++) {
        const assetName = assets.keys().get(k);
        const amount = assets.get(assetName);
        const positiveAmount = amount?.as_positive()?.to_str();
        const negativeAmount = amount?.as_negative()?.to_str();
        if (!amount || !positiveAmount || !negativeAmount) {
          throw new HwMappingError('Missing token amount.');
        }
        tokens.push({
          amount: amount.is_positive() ? positiveAmount : `-${negativeAmount}`,
          assetNameHex: Buffer.from(assetName.name()).toString('hex')
        });
      }
    }
    sortTokensCanonically(tokens);
    mintAssetsGroup.push({
      policyIdHex: Buffer.from(policy.to_bytes()).toString('hex'),
      tokens
    });
  }

  if (paymentKeyPaths) concat(additionalWitnessPaths, paymentKeyPaths);
  if (rewardAccountKeyPath) additionalWitnessPaths.push(rewardAccountKeyPath);

  return {
    additionalWitnessPaths,
    mintAssetsGroup
  };
};

export const txToLedger = async ({
  cslTxBody,
  networkId,
  accountIndex,
  inputAddressResolver,
  knownAddresses
}: TxToLedgerProps): Promise<SignTransactionRequest> => {
  const rewardAccount = knownAddresses[0].rewardAccount;
  const rewardAccountKeyHash = getRewardAccountKeyHash(rewardAccount);
  const rewardAccountKeyPath = [HARDENED + 1852, HARDENED + 1815, HARDENED + accountIndex, 2, 0];

  // TX - Inputs
  const ledgerInputs = prepareLedgerInputs(cslTxBody.inputs(), inputAddressResolver, knownAddresses);

  // TX - Outputs
  const ledgerOutputs = prepareLedgerOutputs(cslTxBody.outputs(), accountIndex, knownAddresses);

  // TX - Withdrawals
  const cslWithdrawals = cslTxBody.withdrawals();
  const ledgerWithdrawals = cslWithdrawals ? prepareLedgerWithdrawals(cslWithdrawals, rewardAccountKeyPath) : null;

  // TX - Certificates
  const cslCertificates = cslTxBody.certs();
  const ledgerCertificatesData = cslCertificates
    ? prepareLedgerCertificates(cslCertificates, knownAddresses, rewardAccountKeyPath, rewardAccountKeyHash.toString())
    : null;
  const signingMode = ledgerCertificatesData?.signingMode || TransactionSigningMode.ORDINARY_TRANSACTION;

  // TX - Fee
  const fee = cslTxBody.fee().to_str();

  // TX - TTL
  const ttl = cslTxBody.ttl();

  // TX - validityStartInterval
  const validityStartInterval = cslTxBody.validity_start_interval();

  // TX  - auxiliaryData
  const txBodyAuxDataHash = cslTxBody.auxiliary_data_hash();
  const auxiliaryData: TxAuxiliaryData | null = txBodyAuxDataHash
    ? {
        params: {
          hashHex: Buffer.from(txBodyAuxDataHash.to_bytes()).toString('hex')
        },
        type: TxAuxiliaryDataType.ARBITRARY_HASH
      }
    : null;

  // TX - Mint (assets bundle)
  const cslMint = cslTxBody.multiassets();
  let ledgerMintBundle = null;
  if (cslMint) {
    const paymentKeyPaths = uniq(ledgerInputs.map((ledgerInput) => ledgerInput.path).filter(isNotNil));
    ledgerMintBundle = prepareLedgerMintBundle(cslMint, paymentKeyPaths, rewardAccountKeyPath);
  }
  const additionalWitnessPaths = ledgerMintBundle?.additionalWitnessPaths || [];

  const ledgerTx = {
    auxiliaryData,
    certificates: ledgerCertificatesData?.certs,
    fee,
    inputs: ledgerInputs,
    mint: ledgerMintBundle?.mintAssetsGroup,
    network: {
      networkId,
      protocolMagic: networkId === 1 ? 764_824_073 : 42
    },
    outputs: ledgerOutputs,
    ttl,
    validityStartInterval,
    withdrawals: ledgerWithdrawals
  };

  for (const key of Object.keys(ledgerTx)) {
    const objKey = key as keyof typeof ledgerTx;
    !ledgerTx[objKey] && ledgerTx[objKey] !== 0 && delete ledgerTx[objKey];
  }

  return {
    additionalWitnessPaths,
    signingMode,
    tx: ledgerTx
  };
};
