// Based on Nami implementation
// https://github.com/Berry-Pool/nami-wallet/blob/39fb256af9547f801f57a673a5f02d0c7cef42c2/src/api/util.js#L636
/* eslint-disable sonarjs/cognitive-complexity,  max-depth, max-statements, complexity */
import * as ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import * as trezor from 'trezor-connect';
import { Address, CSL, Cardano, cslToCore } from '@cardano-sdk/core';
import { BIP32Path, CardanoKeyConst, GroupedAddress } from '../types';
import { HwMappingError } from '../errors';
import { STAKE_KEY_DERIVATION_PATH, harden } from '../util';
import { isNotNil } from '@cardano-sdk/util';
import concat from 'lodash/concat';
import uniq from 'lodash/uniq';

export interface TxToLedgerProps {
  cslTxBody: CSL.TransactionBody;
  networkId: Cardano.NetworkId;
  inputResolver: Address.util.InputResolver;
  knownAddresses: GroupedAddress[];
  protocolMagic: Cardano.NetworkMagic;
}

export interface TxToTrezorProps {
  cslTxBody: CSL.TransactionBody;
  networkId: Cardano.NetworkId;
  accountIndex: number;
  inputResolver: Address.util.InputResolver;
  knownAddresses: GroupedAddress[];
  protocolMagic: Cardano.NetworkMagic;
}

export interface LedgerCertificates {
  certs: ledger.Certificate[] | null;
  signingMode?: ledger.TransactionSigningMode;
}

export interface LedgerMintBundle {
  mintAssetsGroup: ledger.AssetGroup[] | null;
  additionalWitnessPaths: BIP32Path[];
}

export interface TrezorMintBundle {
  mintAssetsGroup: trezor.CardanoAssetGroup[];
  additionalWitnessPaths: BIP32Path[];
}

export interface TrezorCertificates {
  certs: trezor.CardanoCertificate[];
  signingMode?: trezor.CardanoTxSigningMode;
}

const sortTokensCanonically = (tokens: trezor.CardanoToken[] | ledger.Token[]) => {
  tokens.sort((a, b) => {
    const assetNameA = 'assetNameBytes' in a ? a.assetNameBytes : a.assetNameHex;
    const assetNameB = 'assetNameBytes' in b ? b.assetNameBytes : b.assetNameHex;
    if (assetNameA.length === assetNameB.length) {
      return assetNameA > assetNameB ? 1 : -1;
    } else if (assetNameA.length > assetNameB.length) return 1;
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

const matchGroupedAddress = (knownAddresses: GroupedAddress[], outputAddress: Buffer): GroupedAddress | undefined => {
  const outputAddressBech32 = ledger.utils.bech32_encodeAddress(outputAddress);
  return knownAddresses.find(({ address }) => address.toString() === outputAddressBech32);
};

const prepareTrezorInputs = async (
  inputs: CSL.TransactionInputs,
  inputResolver: Address.util.InputResolver,
  knownAddresses: GroupedAddress[]
): Promise<trezor.CardanoInput[]> => {
  const trezorInputs = [];
  for (let i = 0; i < inputs.len(); i++) {
    const input = inputs.get(i);
    const coreInput = cslToCore.txIn(input);
    const paymentAddress = await inputResolver.resolveInputAddress(coreInput);

    let trezorInput = {
      prev_hash: Buffer.from(input.transaction_id().to_bytes()).toString('hex'),
      prev_index: input.index()
    } as trezor.CardanoInput;

    let paymentKeyPath = null;
    if (paymentAddress) {
      const knownAddress = knownAddresses.find(({ address }) => address === paymentAddress);
      if (knownAddress) {
        paymentKeyPath = [
          harden(CardanoKeyConst.PURPOSE),
          harden(CardanoKeyConst.COIN_TYPE),
          harden(knownAddress.accountIndex),
          knownAddress.type,
          knownAddress.index
        ];
        trezorInput = {
          ...trezorInput,
          path: paymentKeyPath
        };
      }
    }
    trezorInputs.push(trezorInput);
  }
  return trezorInputs;
};

const prepareTrezorOutputs = (
  outputs: CSL.TransactionOutputs,
  knownAddresses: GroupedAddress[]
): trezor.CardanoOutput[] => {
  const trezorOutputs = [];
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
                assetNameBytes: Buffer.from(assetName.name()).toString('hex')
              });
            }
          }
        }
        sortTokensCanonically(tokens);
        tokenBundle.push({
          policyId: Buffer.from(policy.to_bytes()).toString('hex'),
          tokenAmounts: tokens
        });
      }
    }
    const outputAddress = Buffer.from(output.address().to_bytes());
    const ownAddress = matchGroupedAddress(knownAddresses, outputAddress);
    const destination = ownAddress
      ? {
          addressParameters: {
            addressType: trezor.CardanoAddressType.BASE,
            // eslint-disable-next-line max-len
            path: `m/${CardanoKeyConst.PURPOSE}'/${CardanoKeyConst.COIN_TYPE}'/${ownAddress.accountIndex}'/${ownAddress.type}/${ownAddress.index}`,
            // eslint-disable-next-line max-len
            stakingPath: `m/${CardanoKeyConst.PURPOSE}'/${CardanoKeyConst.COIN_TYPE}'/${ownAddress.accountIndex}'/${STAKE_KEY_DERIVATION_PATH.role}/${STAKE_KEY_DERIVATION_PATH.index}`
          }
        }
      : {
          address: output.address().to_bech32()
        };
    const outputRes = {
      ...destination,
      amount: output.amount().coin().to_str(),
      tokenBundle
    };
    trezorOutputs.push(outputRes);
  }
  return trezorOutputs;
};

const prepareTrezorCertificates = (
  certificates: CSL.Certificates,
  rewardAccountKeyPath: BIP32Path,
  rewardAccountKeyHash: string
): TrezorCertificates => {
  let signingMode;
  const certs = [];
  for (let i = 0; i < certificates.len(); i++) {
    const cert = certificates.get(i);
    const certificate = {} as trezor.CardanoCertificate;
    if (cert.kind() === 0) {
      const credential = cert.as_stake_registration()?.stake_credential();
      const credentialScriptHash = credential?.to_scripthash();
      certificate.type = trezor.CardanoCertificateType.STAKE_REGISTRATION;

      if (credential?.kind() === 0) {
        certificate.path = rewardAccountKeyPath;
      } else if (credential && credentialScriptHash) {
        certificate.scriptHash = Buffer.from(credentialScriptHash.to_bytes()).toString('hex');
      }
    } else if (cert.kind() === 1) {
      const credential = cert.as_stake_deregistration()?.stake_credential();
      const credentialScriptHash = credential?.to_scripthash();
      certificate.type = trezor.CardanoCertificateType.STAKE_DEREGISTRATION;

      if (credential?.kind() === 0) {
        certificate.path = rewardAccountKeyPath;
      } else if (credential && credentialScriptHash) {
        certificate.scriptHash = Buffer.from(credentialScriptHash.to_bytes()).toString('hex');
      }
    } else if (cert.kind() === 2) {
      const delegation = cert.as_stake_delegation();
      const delegationPoolKeyHash = delegation?.pool_keyhash();
      const credential = delegation?.stake_credential();
      const credentialScriptHash = credential?.to_scripthash();
      certificate.type = trezor.CardanoCertificateType.STAKE_DELEGATION;
      if (credential?.kind() === 0) {
        certificate.path = rewardAccountKeyPath;
      } else if (credentialScriptHash) {
        certificate.scriptHash = Buffer.from(credentialScriptHash.to_bytes()).toString('hex');
      }
      // Always apply pool key hash to cert type STAKE_DELEGATION
      if (delegationPoolKeyHash) {
        certificate.pool = Buffer.from(delegationPoolKeyHash.to_bytes()).toString('hex');
      }
    } else if (cert.kind() === 3) {
      const params = cert.as_pool_registration()?.pool_params();
      if (!params) {
        throw new HwMappingError('Missing pool registration pool parameters.');
      }
      certificate.type = trezor.CardanoCertificateType.STAKE_POOL_REGISTRATION;
      const owners = params?.pool_owners();
      const poolOwners = [] as trezor.CardanoPoolOwner[];

      if (owners) {
        for (let j = 0; j < owners.len(); j++) {
          const keyHash = Buffer.from(owners.get(j).to_bytes()).toString('hex');
          if (keyHash === rewardAccountKeyHash) {
            signingMode = trezor.CardanoTxSigningMode.POOL_REGISTRATION_AS_OWNER;
            poolOwners.push({
              stakingKeyPath: rewardAccountKeyPath
            });
          } else {
            poolOwners.push({
              stakingKeyHash: keyHash
            });
          }
        }
      }
      const relays = params?.relays();
      const trezorRelays = [] as trezor.CardanoPoolRelay[];

      if (relays) {
        for (let k = 0; k < relays.len(); k++) {
          const relay = relays.get(k);
          if (relay.kind() === 0) {
            const singleHostAddr = relay.as_single_host_addr();
            const type = trezor.CardanoPoolRelayType.SINGLE_HOST_IP;
            const port = singleHostAddr?.port();
            const ipv4Address = singleHostAddr?.ipv4() ? bytesToIp(singleHostAddr.ipv4()?.ip()) : null;
            const ipv6Address = singleHostAddr?.ipv6() ? bytesToIp(singleHostAddr.ipv6()?.ip()) : null;
            trezorRelays.push({
              ipv4Address: ipv4Address || undefined,
              ipv6Address: ipv6Address || undefined,
              port,
              type
            });
          } else if (relay.kind() === 1) {
            const type = trezor.CardanoPoolRelayType.SINGLE_HOST_NAME;
            const singleHostName = relay.as_single_host_name();
            if (singleHostName) {
              const port = singleHostName.port();
              const hostName = singleHostName.dns_name().record();
              trezorRelays.push({
                hostName,
                port,
                type
              });
            }
          } else if (relay.kind() === 2) {
            const type = trezor.CardanoPoolRelayType.MULTIPLE_HOST_NAME;
            const multiHostName = relay.as_multi_host_name();
            const hostName = multiHostName?.dns_name().record();
            if (hostName) {
              trezorRelays.push({
                hostName,
                type
              });
            }
          }
        }
      }
      const cost = params?.cost().to_str();
      const margin = params?.margin();
      const pledge = params?.pledge().to_str();
      const poolId = Buffer.from(params.operator().to_bytes()).toString('hex');
      const poolMetadata = params.pool_metadata();
      if (!poolMetadata) {
        throw new HwMappingError('Missing pool metadata.');
      }
      const metadata = {
        hash: Buffer.from(poolMetadata.pool_metadata_hash().to_bytes()).toString('hex'),
        url: poolMetadata.url().url()
      };
      const rewardAccount = params.reward_account().to_address().to_bech32();
      const vrfKeyHash = Buffer.from(params.vrf_keyhash().to_bytes()).toString('hex');

      certificate.poolParameters = {
        cost,
        margin: {
          denominator: margin.denominator().to_str(),
          numerator: margin.numerator().to_str()
        },
        metadata,
        owners: poolOwners,
        pledge,
        poolId,
        relays: trezorRelays,
        rewardAccount,
        vrfKeyHash
      };
    }
    certs.push(certificate);
  }
  return {
    certs,
    signingMode
  };
};

const prepareTrezorWithdrawals = (
  withdrawals: CSL.Withdrawals,
  rewardAccountKeyPath: BIP32Path
): trezor.CardanoWithdrawal[] => {
  const trezorWithdrawals = [];
  for (let i = 0; i < withdrawals.keys().len(); i++) {
    const withdrawal = {} as trezor.CardanoWithdrawal;
    const rewardAddress = withdrawals.keys().get(i);
    const paymentCredentials = rewardAddress.payment_cred();
    const paymentCredentialsScriptHash = paymentCredentials.to_scripthash();
    if (rewardAddress.payment_cred().kind() === 0) {
      withdrawal.path = rewardAccountKeyPath;
    } else if (paymentCredentialsScriptHash) {
      withdrawal.scriptHash = Buffer.from(paymentCredentialsScriptHash.to_bytes()).toString('hex');
    }
    const withdrawalAmount = withdrawals.get(rewardAddress);
    if (!withdrawalAmount) {
      throw new HwMappingError('Withdrawal amount is not defined.');
    }
    withdrawal.amount = withdrawalAmount.to_str();
    trezorWithdrawals.push(withdrawal);
  }
  return trezorWithdrawals;
};

const prepareTrezorMintBundle = (
  mint: CSL.Mint,
  paymentKeyPaths: (string | number[])[],
  rewardAccountKeyPath: BIP32Path
): TrezorMintBundle => {
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
          assetNameBytes: Buffer.from(assetName.name()).toString('hex')
        });
      }
    }
    sortTokensCanonically(tokens);
    mintAssetsGroup.push({
      policyId: Buffer.from(policy.to_bytes()).toString('hex'),
      tokenAmounts: tokens
    });
  }

  if (paymentKeyPaths) concat(additionalWitnessPaths, paymentKeyPaths);
  if (rewardAccountKeyPath) additionalWitnessPaths.push(rewardAccountKeyPath);

  return {
    additionalWitnessPaths,
    mintAssetsGroup
  };
};

const prepareLedgerInputs = async (
  inputs: CSL.TransactionInputs,
  inputResolver: Address.util.InputResolver,
  knownAddresses: GroupedAddress[]
): Promise<ledger.TxInput[]> => {
  const ledgerInputs = [];
  for (let i = 0; i < inputs.len(); i++) {
    const input = inputs.get(i);
    const coreInput = cslToCore.txIn(input);
    const paymentAddress = await inputResolver.resolveInputAddress(coreInput);

    let paymentKeyPath = null;
    if (paymentAddress) {
      const knownAddress = knownAddresses.find(({ address }) => address === paymentAddress);
      if (knownAddress) {
        paymentKeyPath = [
          harden(CardanoKeyConst.PURPOSE),
          harden(CardanoKeyConst.COIN_TYPE),
          harden(knownAddress.accountIndex),
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

const prepareLedgerOutputs = (outputs: CSL.TransactionOutputs, knownAddresses: GroupedAddress[]): ledger.TxOutput[] => {
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
    const ownAddress = matchGroupedAddress(knownAddresses, outputAddress);
    const destination: ledger.TxOutputDestination = ownAddress
      ? {
          params: {
            params: {
              spendingPath: [
                harden(CardanoKeyConst.PURPOSE),
                harden(CardanoKeyConst.COIN_TYPE),
                harden(ownAddress.accountIndex),
                ownAddress.type,
                ownAddress.index
              ],
              stakingPath: [
                harden(CardanoKeyConst.PURPOSE),
                harden(CardanoKeyConst.COIN_TYPE),
                harden(ownAddress.accountIndex),
                STAKE_KEY_DERIVATION_PATH.role,
                STAKE_KEY_DERIVATION_PATH.index
              ]
            },
            type: ledger.AddressType.BASE_PAYMENT_KEY_STAKE_KEY
          },
          type: ledger.TxOutputDestinationType.DEVICE_OWNED
        }
      : {
          params: {
            addressHex: outputAddress.toString('hex')
          },
          type: ledger.TxOutputDestinationType.THIRD_PARTY
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
    const certificate = {} as ledger.Certificate;
    if (cert.kind() === 0) {
      const credential = cert.as_stake_registration()?.stake_credential();
      const credentialScriptHash = credential?.to_scripthash();
      certificate.type = ledger.CertificateType.STAKE_REGISTRATION;

      if (credential?.kind() === 0) {
        certificate.params = {
          stakeCredential: {
            keyPath: rewardAccountKeyPath,
            type: ledger.StakeCredentialParamsType.KEY_PATH
          }
        };
      } else if (credential && credentialScriptHash) {
        const scriptHashHex = Buffer.from(credentialScriptHash.to_bytes()).toString('hex');
        certificate.params = {
          stakeCredential: {
            scriptHashHex,
            type: ledger.StakeCredentialParamsType.SCRIPT_HASH
          }
        };
      }
    } else if (cert.kind() === 1) {
      const credential = cert.as_stake_deregistration()?.stake_credential();
      const credentialScriptHash = credential?.to_scripthash();
      certificate.type = ledger.CertificateType.STAKE_DEREGISTRATION;

      if (credential?.kind() === 0) {
        certificate.params = {
          stakeCredential: {
            keyPath: rewardAccountKeyPath,
            type: ledger.StakeCredentialParamsType.KEY_PATH
          }
        };
      } else if (credential && credentialScriptHash) {
        const scriptHashHex = Buffer.from(credentialScriptHash.to_bytes()).toString('hex');
        certificate.params = {
          stakeCredential: {
            scriptHashHex,
            type: ledger.StakeCredentialParamsType.SCRIPT_HASH
          }
        };
      }
    } else if (cert.kind() === 2) {
      const delegation = cert.as_stake_delegation();
      const delegationPoolKeyHash = delegation?.pool_keyhash();
      const credential = delegation?.stake_credential();
      const credentialScriptHash = credential?.to_scripthash();
      certificate.type = ledger.CertificateType.STAKE_DELEGATION;
      if (credential?.kind() === 0) {
        certificate.params = {
          stakeCredential: {
            keyPath: rewardAccountKeyPath,
            type: ledger.StakeCredentialParamsType.KEY_PATH
          }
        };
      } else if (credentialScriptHash) {
        const scriptHashHex = Buffer.from(credentialScriptHash.to_bytes()).toString('hex');
        certificate.params = {
          stakeCredential: {
            scriptHashHex,
            type: ledger.StakeCredentialParamsType.SCRIPT_HASH
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
      certificate.type = ledger.CertificateType.STAKE_POOL_REGISTRATION;
      const owners = params?.pool_owners();
      const poolOwners = [] as ledger.PoolOwner[];

      if (owners) {
        for (let j = 0; j < owners.len(); j++) {
          const keyHash = Buffer.from(owners.get(j).to_bytes()).toString('hex');
          if (keyHash === rewardAccountKeyHash) {
            signingMode = ledger.TransactionSigningMode.POOL_REGISTRATION_AS_OWNER;
            poolOwners.push({
              params: {
                stakingPath: rewardAccountKeyPath
              },
              type: ledger.PoolOwnerType.DEVICE_OWNED
            });
          } else {
            poolOwners.push({
              params: {
                stakingKeyHashHex: keyHash
              },
              type: ledger.PoolOwnerType.THIRD_PARTY
            });
          }
        }
      }
      const relays = params?.relays();
      const ledgerRelays = [] as ledger.Relay[];

      if (relays) {
        for (let k = 0; k < relays.len(); k++) {
          const relay = relays.get(k);
          if (relay.kind() === 0) {
            const singleHostAddr = relay.as_single_host_addr();
            const type = ledger.RelayType.SINGLE_HOST_IP_ADDR;
            const portNumber = singleHostAddr?.port();
            const ipv4 = singleHostAddr?.ipv4() ? bytesToIp(singleHostAddr.ipv4()?.ip()) : null;
            const ipv6 = singleHostAddr?.ipv6() ? bytesToIp(singleHostAddr.ipv6()?.ip()) : null;
            ledgerRelays.push({ params: { ipv4, ipv6, portNumber }, type });
          } else if (relay.kind() === 1) {
            const type = ledger.RelayType.SINGLE_HOST_HOSTNAME;
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
            const type = ledger.RelayType.MULTI_HOST;
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
      let poolKey: ledger.PoolKey;
      if (operator === rewardAccountKeyHash) {
        signingMode = ledger.TransactionSigningMode.POOL_REGISTRATION_AS_OPERATOR;
        poolKey = {
          params: { path: rewardAccountKeyPath },
          type: ledger.PoolKeyType.DEVICE_OWNED
        };
      } else {
        poolKey = {
          params: { keyHashHex: operator },
          type: ledger.PoolKeyType.THIRD_PARTY
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
        ({ address }) => address.toString() === ledger.utils.bech32_encodeAddress(rewardAccountBytes)
      );
      const rewardAccount: ledger.PoolRewardAccount = isDeviceOwned
        ? {
            params: { path: rewardAccountKeyPath },
            type: ledger.PoolRewardAccountType.DEVICE_OWNED
          }
        : {
            params: { rewardAccountHex: rewardAccountBytes.toString('hex') },
            type: ledger.PoolRewardAccountType.THIRD_PARTY
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

const prepareLedgerWithdrawals = (
  withdrawals: CSL.Withdrawals,
  rewardAccountKeyPath: BIP32Path
): ledger.Withdrawal[] => {
  const ledgerWithdrawals = [];
  for (let i = 0; i < withdrawals.keys().len(); i++) {
    const withdrawal = { stakeCredential: {} } as ledger.Withdrawal;
    const rewardAddress = withdrawals.keys().get(i);
    const paymentCredentials = rewardAddress.payment_cred();
    const paymentCredentialsScriptHash = paymentCredentials.to_scripthash();
    if (rewardAddress.payment_cred().kind() === 0) {
      const stakeCredential: ledger.KeyPathStakeCredentialParams = {
        keyPath: rewardAccountKeyPath,
        type: ledger.StakeCredentialParamsType.KEY_PATH
      };
      withdrawal.stakeCredential = stakeCredential;
    } else if (paymentCredentialsScriptHash) {
      const stakeCredential: ledger.ScriptStakeCredentialParams = {
        scriptHashHex: Buffer.from(paymentCredentialsScriptHash.to_bytes()).toString('hex'),
        type: ledger.StakeCredentialParamsType.SCRIPT_HASH
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
  inputResolver: inputAddressResolver,
  knownAddresses,
  protocolMagic
}: TxToLedgerProps): Promise<ledger.SignTransactionRequest> => {
  const accountAddress = knownAddresses[0];
  const rewardAccount = accountAddress.rewardAccount;
  const rewardAccountKeyHash = getRewardAccountKeyHash(rewardAccount);
  const rewardAccountKeyPath = [
    harden(CardanoKeyConst.PURPOSE),
    harden(CardanoKeyConst.COIN_TYPE),
    harden(accountAddress.accountIndex),
    STAKE_KEY_DERIVATION_PATH.role,
    STAKE_KEY_DERIVATION_PATH.index
  ];

  // TX - Inputs
  const ledgerInputs = await prepareLedgerInputs(cslTxBody.inputs(), inputAddressResolver, knownAddresses);

  // TX - Outputs
  const ledgerOutputs = prepareLedgerOutputs(cslTxBody.outputs(), knownAddresses);

  // TX - Withdrawals
  const cslWithdrawals = cslTxBody.withdrawals();
  const ledgerWithdrawals = cslWithdrawals ? prepareLedgerWithdrawals(cslWithdrawals, rewardAccountKeyPath) : null;

  // TX - Certificates
  const cslCertificates = cslTxBody.certs();
  const ledgerCertificatesData = cslCertificates
    ? prepareLedgerCertificates(cslCertificates, knownAddresses, rewardAccountKeyPath, rewardAccountKeyHash.toString())
    : null;
  const signingMode = ledgerCertificatesData?.signingMode || ledger.TransactionSigningMode.ORDINARY_TRANSACTION;

  // TX - Fee
  const fee = cslTxBody.fee().to_str();

  // TX - TTL
  const ttl = cslTxBody.ttl();

  // TX - validityStartInterval
  const validityStartInterval = cslTxBody.validity_start_interval();

  // TX  - auxiliaryData
  const txBodyAuxDataHash = cslTxBody.auxiliary_data_hash();
  const auxiliaryData: ledger.TxAuxiliaryData | null = txBodyAuxDataHash
    ? {
        params: {
          hashHex: Buffer.from(txBodyAuxDataHash.to_bytes()).toString('hex')
        },
        type: ledger.TxAuxiliaryDataType.ARBITRARY_HASH
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
      protocolMagic
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

export const txToTrezor = async ({
  cslTxBody,
  networkId,
  inputResolver: inputAddressResolver,
  knownAddresses,
  protocolMagic
}: TxToTrezorProps): Promise<trezor.CardanoSignTransaction> => {
  const accountAddress = knownAddresses[0];
  const rewardAccount = accountAddress.rewardAccount;
  const rewardAccountKeyHash = getRewardAccountKeyHash(rewardAccount);
  const rewardAccountKeyPath = [
    harden(CardanoKeyConst.PURPOSE),
    harden(CardanoKeyConst.COIN_TYPE),
    harden(accountAddress.accountIndex),
    STAKE_KEY_DERIVATION_PATH.role,
    STAKE_KEY_DERIVATION_PATH.index
  ];

  // TX - Inputs
  const trezorInputs = await prepareTrezorInputs(cslTxBody.inputs(), inputAddressResolver, knownAddresses);

  // TX - Outputs
  const trezorOutputs = prepareTrezorOutputs(cslTxBody.outputs(), knownAddresses);

  // TX - Withdrawals
  const cslWithdrawals = cslTxBody.withdrawals();
  const trezorWithdrawals = cslWithdrawals ? prepareTrezorWithdrawals(cslWithdrawals, rewardAccountKeyPath) : undefined;

  // TX - Certificates
  const cslCertificates = cslTxBody.certs();
  let trezorCertificatesData;
  if (cslCertificates) {
    trezorCertificatesData = prepareTrezorCertificates(
      cslCertificates,
      rewardAccountKeyPath,
      rewardAccountKeyHash.toString()
    );
  }
  const signingMode = trezorCertificatesData?.signingMode || trezor.CardanoTxSigningMode.ORDINARY_TRANSACTION;

  // TX - Fee
  const fee = cslTxBody.fee().to_str();

  // TX - TTL
  let ttl;
  const cslTTL = cslTxBody.ttl();
  if (cslTTL) {
    ttl = cslTTL.toString();
  }

  const validityIntervalStart = cslTxBody.validity_start_interval();

  // TX  - auxiliaryData
  const txBodyAuxDataHash = cslTxBody.auxiliary_data_hash();
  let auxiliaryData;
  if (txBodyAuxDataHash) {
    auxiliaryData = {
      hash: Buffer.from(txBodyAuxDataHash.to_bytes()).toString('hex')
    };
  }

  // TX - Mint (assets bundle)
  const cslMint = cslTxBody.multiassets();
  let trezorMintBundle = null;
  if (cslMint) {
    const paymentKeyPaths = uniq(trezorInputs.map((trezorInput) => trezorInput.path).filter(isNotNil));
    trezorMintBundle = prepareTrezorMintBundle(cslMint, paymentKeyPaths, rewardAccountKeyPath);
  }

  return {
    additionalWitnessRequests: trezorMintBundle?.additionalWitnessPaths,
    auxiliaryData,
    certificates: trezorCertificatesData?.certs,
    fee,
    inputs: trezorInputs,
    mint: trezorMintBundle?.mintAssetsGroup,
    networkId,
    outputs: trezorOutputs,
    protocolMagic,
    signingMode,
    ttl,
    validityIntervalStart: validityIntervalStart?.toString(),
    withdrawals: trezorWithdrawals
  };
};
