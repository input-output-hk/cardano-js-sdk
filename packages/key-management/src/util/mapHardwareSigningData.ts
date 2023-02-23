// Based on Nami implementation
// https://github.com/Berry-Pool/nami-wallet/blob/39fb256af9547f801f57a673a5f02d0c7cef42c2/src/api/util.js#L636
/* eslint-disable sonarjs/cognitive-complexity,  max-depth, max-statements, complexity */
import * as ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import * as trezor from 'trezor-connect';
import { BIP32Path } from '@cardano-sdk/crypto';
import { CML, Cardano, cmlToCore } from '@cardano-sdk/core';
import { CardanoKeyConst, GroupedAddress } from '../types';
import { HwMappingError } from '../errors';
import { ManagedFreeableScope, isNotNil, usingAutoFree } from '@cardano-sdk/util';
import { STAKE_KEY_DERIVATION_PATH, harden } from './key';
import concat from 'lodash/concat';
import uniq from 'lodash/uniq';

export interface TxToLedgerProps {
  cslTxBody: CML.TransactionBody;
  chainId: Cardano.ChainId;
  inputResolver: Cardano.util.InputResolver;
  knownAddresses: GroupedAddress[];
}

export interface TxToTrezorProps {
  cslTxBody: CML.TransactionBody;
  chainId: Cardano.ChainId;
  accountIndex: number;
  inputResolver: Cardano.util.InputResolver;
  knownAddresses: GroupedAddress[];
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
  usingAutoFree((scope) => {
    const address = scope.manage(CML.Address.from_bech32(rewardAccount));
    const rewardAddress = scope.manage(CML.RewardAddress.from_address(address));
    const paymentCred = scope.manage(rewardAddress!.payment_cred());
    const keyHash = scope.manage(paymentCred.to_keyhash());
    return Buffer.from(keyHash!.to_bytes()).toString('hex');
  });

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
  return knownAddresses.find(({ address }) => address === outputAddressBech32);
};

const prepareTrezorInputs = async (
  inputs: CML.TransactionInputs,
  inputResolver: Cardano.util.InputResolver,
  knownAddresses: GroupedAddress[]
): Promise<trezor.CardanoInput[]> => {
  const scope = new ManagedFreeableScope();
  const trezorInputs = [];
  for (let i = 0; i < inputs.len(); i++) {
    const input = scope.manage(inputs.get(i));
    const inputTxId = scope.manage(input.transaction_id());
    const coreInput = cmlToCore.txIn(input);
    const paymentAddress = await inputResolver.resolveInputAddress(coreInput);

    let trezorInput = {
      prev_hash: Buffer.from(inputTxId.to_bytes()).toString('hex'),
      prev_index: Number(scope.manage(input.index()).to_str())
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
  scope.dispose();
  return trezorInputs;
};

const prepareTrezorOutputs = (
  outputs: CML.TransactionOutputs,
  knownAddresses: GroupedAddress[]
): trezor.CardanoOutput[] =>
  usingAutoFree((scope) => {
    const trezorOutputs = [];
    for (let i = 0; i < outputs.len(); i++) {
      const output = scope.manage(outputs.get(i));
      const outputAmount = scope.manage(output.amount());
      const outputAddress = scope.manage(output.address());
      const multiAsset = scope.manage(outputAmount.multiasset());
      const tokenBundle = [];
      if (multiAsset) {
        const multiAssetKeys = scope.manage(multiAsset.keys());
        for (let j = 0; j < multiAssetKeys.len(); j++) {
          const policy = scope.manage(multiAssetKeys.get(j));
          const assets = scope.manage(multiAsset.get(policy));
          const tokens = [];
          if (assets) {
            const assetsKeys = scope.manage(assets.keys());
            for (let k = 0; k < assetsKeys.len(); k++) {
              const assetName = scope.manage(assetsKeys.get(k));
              const amount = scope.manage(assets.get(assetName));
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

      const outputAddressBytes = Buffer.from(outputAddress.to_bytes());
      const ownAddress = matchGroupedAddress(knownAddresses, outputAddressBytes);
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
            address: outputAddress.to_bech32()
          };
      const outputRes = {
        ...destination,
        amount: scope.manage(outputAmount.coin()).to_str(),
        tokenBundle
      };
      trezorOutputs.push(outputRes);
    }
    return trezorOutputs;
  });

const prepareTrezorCertificates = (
  certificates: CML.Certificates,
  rewardAccountKeyPath: BIP32Path,
  rewardAccountKeyHash: string
): TrezorCertificates =>
  usingAutoFree((scope) => {
    let signingMode;
    const certs = [];
    for (let i = 0; i < certificates.len(); i++) {
      const cert = scope.manage(certificates.get(i));
      const certificate = {} as trezor.CardanoCertificate;
      if (cert.kind() === 0) {
        const stakeRegistration = scope.manage(cert.as_stake_registration());
        const credential = scope.manage(stakeRegistration?.stake_credential());
        const credentialScriptHash = scope.manage(credential?.to_scripthash());
        certificate.type = trezor.CardanoCertificateType.STAKE_REGISTRATION;

        if (credential?.kind() === 0) {
          certificate.path = rewardAccountKeyPath;
        } else if (credential && credentialScriptHash) {
          certificate.scriptHash = Buffer.from(credentialScriptHash.to_bytes()).toString('hex');
        }
      } else if (cert.kind() === 1) {
        const stakeDeregistration = scope.manage(cert.as_stake_deregistration());
        const credential = scope.manage(stakeDeregistration?.stake_credential());
        const credentialScriptHash = scope.manage(credential?.to_scripthash());
        certificate.type = trezor.CardanoCertificateType.STAKE_DEREGISTRATION;

        if (credential?.kind() === 0) {
          certificate.path = rewardAccountKeyPath;
        } else if (credential && credentialScriptHash) {
          certificate.scriptHash = Buffer.from(credentialScriptHash.to_bytes()).toString('hex');
        }
      } else if (cert.kind() === 2) {
        const delegation = scope.manage(cert.as_stake_delegation());
        const delegationPoolKeyHash = scope.manage(delegation?.pool_keyhash());
        const credential = scope.manage(delegation?.stake_credential());
        const credentialScriptHash = scope.manage(credential?.to_scripthash());
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
        const poolRegistration = scope.manage(cert.as_pool_registration());
        const params = scope.manage(poolRegistration?.pool_params());
        if (!params) {
          throw new HwMappingError('Missing pool registration pool parameters.');
        }
        certificate.type = trezor.CardanoCertificateType.STAKE_POOL_REGISTRATION;
        const owners = scope.manage(params?.pool_owners());
        const poolOwners = [] as trezor.CardanoPoolOwner[];

        if (owners) {
          for (let j = 0; j < owners.len(); j++) {
            const owner = scope.manage(owners.get(j));
            const keyHash = Buffer.from(owner.to_bytes()).toString('hex');
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
        const relays = scope.manage(params?.relays());
        const trezorRelays = [] as trezor.CardanoPoolRelay[];

        if (relays) {
          for (let k = 0; k < relays.len(); k++) {
            const relay = scope.manage(relays.get(k));
            if (relay.kind() === 0) {
              const singleHostAddr = scope.manage(relay.as_single_host_addr());
              const type = trezor.CardanoPoolRelayType.SINGLE_HOST_IP;
              const port = singleHostAddr?.port();
              const ipv4 = scope.manage(singleHostAddr?.ipv4());
              const ipv4Address = ipv4 ? bytesToIp(ipv4?.ip()) : null;
              const ipv6 = scope.manage(singleHostAddr?.ipv6());
              const ipv6Address = ipv6 ? bytesToIp(ipv6?.ip()) : null;
              trezorRelays.push({
                ipv4Address: ipv4Address || undefined,
                ipv6Address: ipv6Address || undefined,
                port,
                type
              });
            } else if (relay.kind() === 1) {
              const type = trezor.CardanoPoolRelayType.SINGLE_HOST_NAME;
              const singleHostName = scope.manage(relay.as_single_host_name());
              if (singleHostName) {
                const port = singleHostName.port();
                const hostName = scope.manage(singleHostName.dns_name()).record();
                trezorRelays.push({
                  hostName,
                  port,
                  type
                });
              }
            } else if (relay.kind() === 2) {
              const type = trezor.CardanoPoolRelayType.MULTIPLE_HOST_NAME;
              const multiHostName = scope.manage(relay.as_multi_host_name());
              const hostName = scope.manage(multiHostName?.dns_name())?.record();
              if (hostName) {
                trezorRelays.push({
                  hostName,
                  type
                });
              }
            }
          }
        }
        const cost = scope.manage(params?.cost()).to_str();
        const margin = scope.manage(params?.margin());
        const pledge = scope.manage(params?.pledge()).to_str();
        const poolId = Buffer.from(scope.manage(params.operator()).to_bytes()).toString('hex');
        const poolMetadata = scope.manage(params.pool_metadata());
        if (!poolMetadata) {
          throw new HwMappingError('Missing pool metadata.');
        }
        const metadata = {
          hash: Buffer.from(scope.manage(poolMetadata.pool_metadata_hash()).to_bytes()).toString('hex'),
          url: scope.manage(poolMetadata.url()).url()
        };
        const rewardAccount = scope.manage(params.reward_account());
        const rewardAccountBech32 = scope.manage(rewardAccount.to_address()).to_bech32();
        const vrfKeyHash = Buffer.from(scope.manage(params.vrf_keyhash()).to_bytes()).toString('hex');

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
          rewardAccount: rewardAccountBech32,
          vrfKeyHash
        };
      }
      certs.push(certificate);
    }
    return {
      certs,
      signingMode
    };
  });

const prepareTrezorWithdrawals = (
  withdrawals: CML.Withdrawals,
  rewardAccountKeyPath: BIP32Path
): trezor.CardanoWithdrawal[] =>
  usingAutoFree((scope) => {
    const trezorWithdrawals = [];
    const withdrawalsKeys = scope.manage(withdrawals.keys());
    for (let i = 0; i < withdrawalsKeys.len(); i++) {
      const withdrawal = {} as trezor.CardanoWithdrawal;
      const rewardAddress = scope.manage(withdrawalsKeys.get(i));
      const paymentCredentials = scope.manage(rewardAddress.payment_cred());
      const paymentCredentialsScriptHash = scope.manage(paymentCredentials.to_scripthash());
      if (paymentCredentials.kind() === 0) {
        withdrawal.path = rewardAccountKeyPath;
      } else if (paymentCredentialsScriptHash) {
        withdrawal.scriptHash = Buffer.from(paymentCredentialsScriptHash.to_bytes()).toString('hex');
      }
      const withdrawalAmount = scope.manage(withdrawals.get(rewardAddress));
      if (!withdrawalAmount) {
        throw new HwMappingError('Withdrawal amount is not defined.');
      }
      withdrawal.amount = withdrawalAmount.to_str();
      trezorWithdrawals.push(withdrawal);
    }
    return trezorWithdrawals;
  });

const prepareTrezorMintBundle = (
  mint: CML.Mint,
  paymentKeyPaths: (string | number[])[],
  rewardAccountKeyPath: BIP32Path
): TrezorMintBundle =>
  usingAutoFree((scope) => {
    const additionalWitnessPaths: BIP32Path[] = [];
    const mintAssetsGroup = [];
    const mintKeys = scope.manage(mint.keys());
    for (let j = 0; j < mintKeys.len(); j++) {
      const policy = scope.manage(mintKeys.get(j));
      const assets = scope.manage(mint.get(policy));
      const tokens = [];
      if (assets) {
        const assetsKeys = scope.manage(assets.keys());
        for (let k = 0; k < assetsKeys.len(); k++) {
          const assetName = scope.manage(assetsKeys.get(k));
          const amount = scope.manage(assets.get(assetName));
          const positiveAmount = scope.manage(amount?.as_positive())?.to_str();
          const negativeAmount = scope.manage(amount?.as_negative())?.to_str();
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
  });

const prepareLedgerInputs = async (
  inputs: CML.TransactionInputs,
  inputResolver: Cardano.util.InputResolver,
  knownAddresses: GroupedAddress[]
): Promise<ledger.TxInput[]> => {
  const scope = new ManagedFreeableScope();
  const ledgerInputs = [];
  for (let i = 0; i < inputs.len(); i++) {
    const input = scope.manage(inputs.get(i));
    const coreInput = cmlToCore.txIn(input);
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
      outputIndex: Number(scope.manage(input.index()).to_str()),
      path: paymentKeyPath,
      txHashHex: Buffer.from(scope.manage(input.transaction_id()).to_bytes()).toString('hex')
    });
  }
  scope.dispose();
  return ledgerInputs;
};

const prepareLedgerOutputs = (outputs: CML.TransactionOutputs, knownAddresses: GroupedAddress[]): ledger.TxOutput[] =>
  usingAutoFree((scope) => {
    const ledgerOutputs = [];
    for (let i = 0; i < outputs.len(); i++) {
      const output = scope.manage(outputs.get(i));
      const outputAmount = scope.manage(output.amount());
      const multiAsset = scope.manage(outputAmount.multiasset());
      const tokenBundle = [];
      if (multiAsset) {
        const multiAssetKeys = scope.manage(multiAsset.keys());
        for (let j = 0; j < multiAssetKeys.len(); j++) {
          const policy = scope.manage(multiAssetKeys.get(j));
          const assets = scope.manage(multiAsset.get(policy));
          const tokens = [];
          if (assets) {
            const assetsKeys = scope.manage(assets.keys());
            for (let k = 0; k < assetsKeys.len(); k++) {
              const assetName = scope.manage(assetsKeys.get(k));
              const amount = scope.manage(assets.get(assetName));
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
      const outputAddress = Buffer.from(scope.manage(output.address()).to_bytes());
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
      const outputDataHash = scope.manage(scope.manage(output.datum())?.as_data_hash());
      const datumHashHex = outputDataHash ? Buffer.from(outputDataHash.to_bytes()).toString('hex') : null;
      const outputRes = {
        amount: scope.manage(outputAmount.coin()).to_str(),
        datumHashHex,
        destination,
        tokenBundle
      };
      ledgerOutputs.push(outputRes);
    }
    return ledgerOutputs;
  });

const prepareLedgerCertificates = (
  certificates: CML.Certificates,
  knownAddresses: GroupedAddress[],
  rewardAccountKeyPath: BIP32Path,
  rewardAccountKeyHash: string
): LedgerCertificates =>
  usingAutoFree((scope) => {
    let signingMode;
    const certs = [];
    for (let i = 0; i < certificates.len(); i++) {
      const cert = scope.manage(certificates.get(i));
      const certificate = {} as ledger.Certificate;
      if (cert.kind() === 0) {
        const stakeRegistration = scope.manage(cert.as_stake_registration());
        const credential = scope.manage(stakeRegistration?.stake_credential());
        const credentialScriptHash = scope.manage(credential?.to_scripthash());
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
        const stakeDeregistration = scope.manage(cert.as_stake_deregistration());
        const credential = scope.manage(stakeDeregistration?.stake_credential());
        const credentialScriptHash = scope.manage(credential?.to_scripthash());
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
        const delegation = scope.manage(cert.as_stake_delegation());
        const delegationPoolKeyHash = scope.manage(delegation?.pool_keyhash());
        const credential = scope.manage(delegation?.stake_credential());
        const credentialScriptHash = scope.manage(credential?.to_scripthash());
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
        const poolRegistration = scope.manage(cert.as_pool_registration());
        const params = scope.manage(poolRegistration?.pool_params());
        if (!params) {
          throw new HwMappingError('Missing pool registration pool parameters.');
        }
        certificate.type = ledger.CertificateType.STAKE_POOL_REGISTRATION;
        const owners = scope.manage(params?.pool_owners());
        const poolOwners = [] as ledger.PoolOwner[];

        if (owners) {
          for (let j = 0; j < owners.len(); j++) {
            const keyHash = Buffer.from(scope.manage(owners.get(j)).to_bytes()).toString('hex');
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
        const relays = scope.manage(params?.relays());
        const ledgerRelays = [] as ledger.Relay[];

        if (relays) {
          for (let k = 0; k < relays.len(); k++) {
            const relay = scope.manage(relays.get(k));
            if (relay.kind() === 0) {
              const singleHostAddr = scope.manage(relay.as_single_host_addr());
              const type = ledger.RelayType.SINGLE_HOST_IP_ADDR;
              const portNumber = singleHostAddr?.port();
              const ipv4 = scope.manage(singleHostAddr?.ipv4());
              const ipv6 = scope.manage(singleHostAddr?.ipv6());
              const ipv4Address = ipv4 ? bytesToIp(ipv4.ip()) : null;
              const ipv6Address = ipv6 ? bytesToIp(ipv6.ip()) : null;
              ledgerRelays.push({ params: { ipv4: ipv4Address, ipv6: ipv6Address, portNumber }, type });
            } else if (relay.kind() === 1) {
              const type = ledger.RelayType.SINGLE_HOST_HOSTNAME;
              const singleHostName = scope.manage(relay.as_single_host_name());
              if (singleHostName) {
                const portNumber = singleHostName.port();
                const dnsName = scope.manage(singleHostName.dns_name()).record();
                ledgerRelays.push({
                  params: { dnsName, portNumber },
                  type
                });
              }
            } else if (relay.kind() === 2) {
              const type = ledger.RelayType.MULTI_HOST;
              const multiHostName = scope.manage(relay.as_multi_host_name());
              const dnsName = scope.manage(multiHostName?.dns_name())?.record();
              if (dnsName) {
                ledgerRelays.push({
                  params: { dnsName },
                  type
                });
              }
            }
          }
        }
        const cost = scope.manage(params?.cost()).to_str();
        const margin = scope.manage(params?.margin());
        const pledge = scope.manage(params?.pledge()).to_str();

        const operator = Buffer.from(scope.manage(params.operator()).to_bytes()).toString('hex');
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

        const poolMetadata = scope.manage(params.pool_metadata());
        const metadata = poolMetadata
          ? {
              metadataHashHex: Buffer.from(scope.manage(poolMetadata.pool_metadata_hash()).to_bytes()).toString('hex'),
              metadataUrl: scope.manage(poolMetadata.url()).url()
            }
          : null;

        const poolRewardAccount = scope.manage(params.reward_account());
        const rewardAccountBytes = Buffer.from(scope.manage(poolRewardAccount.to_address()).to_bytes());
        const isDeviceOwned = knownAddresses.some(
          ({ address }) => address === ledger.utils.bech32_encodeAddress(rewardAccountBytes)
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
        const vrfKeyHashHex = Buffer.from(scope.manage(params.vrf_keyhash()).to_bytes()).toString('hex');

        certificate.params = {
          cost,
          margin: {
            denominator: scope.manage(margin.denominator()).to_str(),
            numerator: scope.manage(margin.numerator()).to_str()
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
  });

const prepareLedgerWithdrawals = (withdrawals: CML.Withdrawals, rewardAccountKeyPath: BIP32Path): ledger.Withdrawal[] =>
  usingAutoFree((scope) => {
    const ledgerWithdrawals = [];
    const withdrawalsKeys = scope.manage(withdrawals.keys());
    for (let i = 0; i < withdrawalsKeys.len(); i++) {
      const withdrawal = { stakeCredential: {} } as ledger.Withdrawal;
      const rewardAddress = scope.manage(withdrawalsKeys.get(i));
      const paymentCredentials = scope.manage(rewardAddress.payment_cred());
      const paymentCredentialsScriptHash = scope.manage(paymentCredentials.to_scripthash());
      if (paymentCredentials.kind() === 0) {
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
      const withdrawalAmount = scope.manage(withdrawals.get(rewardAddress));
      if (!withdrawalAmount) {
        throw new HwMappingError('Withdrawal amount is not defined.');
      }
      ledgerWithdrawals.push({
        ...withdrawal,
        amount: withdrawalAmount.to_str()
      });
    }
    return ledgerWithdrawals;
  });

const prepareLedgerMintBundle = (
  mint: CML.Mint,
  paymentKeyPaths: BIP32Path[],
  rewardAccountKeyPath: BIP32Path
): LedgerMintBundle =>
  usingAutoFree((scope) => {
    const additionalWitnessPaths: BIP32Path[] = [];
    const mintAssetsGroup = [];

    const mintKeys = scope.manage(mint.keys());
    for (let j = 0; j < mintKeys.len(); j++) {
      const policy = scope.manage(mintKeys.get(j));
      const assets = scope.manage(mint.get(policy));
      const tokens = [];
      if (assets) {
        const assetsKeys = assets.keys();
        for (let k = 0; k < assetsKeys.len(); k++) {
          const assetName = scope.manage(assetsKeys.get(k));
          const amount = scope.manage(assets.get(assetName));
          const positiveAmount = scope.manage(amount?.as_positive())?.to_str();
          const negativeAmount = scope.manage(amount?.as_negative())?.to_str();
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
  });

export const txToLedger = async ({
  cslTxBody,
  chainId,
  inputResolver: inputAddressResolver,
  knownAddresses
}: TxToLedgerProps): Promise<ledger.SignTransactionRequest> => {
  const scope = new ManagedFreeableScope();
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
  const ledgerInputs = await prepareLedgerInputs(
    scope.manage(cslTxBody.inputs()),
    inputAddressResolver,
    knownAddresses
  );

  // TX - Outputs
  const ledgerOutputs = prepareLedgerOutputs(scope.manage(cslTxBody.outputs()), knownAddresses);

  // TX - Withdrawals
  const cslWithdrawals = scope.manage(cslTxBody.withdrawals());
  const ledgerWithdrawals = cslWithdrawals ? prepareLedgerWithdrawals(cslWithdrawals, rewardAccountKeyPath) : null;

  // TX - Certificates
  const cslCertificates = scope.manage(cslTxBody.certs());
  const ledgerCertificatesData = cslCertificates
    ? prepareLedgerCertificates(cslCertificates, knownAddresses, rewardAccountKeyPath, rewardAccountKeyHash)
    : null;
  const signingMode = ledgerCertificatesData?.signingMode || ledger.TransactionSigningMode.ORDINARY_TRANSACTION;

  // TX - Fee
  const fee = scope.manage(cslTxBody.fee()).to_str();

  // TX - TTL
  const ttl = Number(scope.manage(cslTxBody.ttl())?.to_str());

  // TX - validityStartInterval
  const validityIntervalStart = Number(scope.manage(cslTxBody.validity_start_interval())?.to_str());

  // TX  - auxiliaryData
  const txBodyAuxDataHash = scope.manage(cslTxBody.auxiliary_data_hash());
  const auxiliaryData: ledger.TxAuxiliaryData | null = txBodyAuxDataHash
    ? {
        params: {
          hashHex: Buffer.from(txBodyAuxDataHash.to_bytes()).toString('hex')
        },
        type: ledger.TxAuxiliaryDataType.ARBITRARY_HASH
      }
    : null;

  // TX - Mint (assets bundle)
  const cslMint = scope.manage(cslTxBody.multiassets());
  let ledgerMintBundle = null;
  if (cslMint) {
    const paymentKeyPaths = uniq(ledgerInputs.map((ledgerInput) => ledgerInput.path).filter(isNotNil));
    ledgerMintBundle = prepareLedgerMintBundle(cslMint, paymentKeyPaths, rewardAccountKeyPath);
  }
  const additionalWitnessPaths = ledgerMintBundle?.additionalWitnessPaths || [];

  const ledgerTx: ledger.Transaction = {
    auxiliaryData,
    certificates: ledgerCertificatesData?.certs,
    fee,
    inputs: ledgerInputs,
    mint: ledgerMintBundle?.mintAssetsGroup,
    network: {
      networkId: chainId.networkId,
      protocolMagic: chainId.networkMagic
    },
    outputs: ledgerOutputs,
    ttl,
    validityIntervalStart,
    withdrawals: ledgerWithdrawals
  };

  for (const key of Object.keys(ledgerTx)) {
    const objKey = key as keyof typeof ledgerTx;
    !ledgerTx[objKey] && ledgerTx[objKey] !== 0 && delete ledgerTx[objKey];
  }
  scope.dispose();
  return {
    additionalWitnessPaths,
    signingMode,
    tx: ledgerTx
  };
};

export const txToTrezor = async ({
  cslTxBody,
  chainId,
  inputResolver: inputAddressResolver,
  knownAddresses
}: TxToTrezorProps): Promise<trezor.CardanoSignTransaction> => {
  const scope = new ManagedFreeableScope();
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
  const trezorInputs = await prepareTrezorInputs(
    scope.manage(cslTxBody.inputs()),
    inputAddressResolver,
    knownAddresses
  );

  // TX - Outputs
  const trezorOutputs = prepareTrezorOutputs(scope.manage(cslTxBody.outputs()), knownAddresses);

  // TX - Withdrawals
  const cslWithdrawals = scope.manage(cslTxBody.withdrawals());
  const trezorWithdrawals = cslWithdrawals ? prepareTrezorWithdrawals(cslWithdrawals, rewardAccountKeyPath) : undefined;

  // TX - Certificates
  const cslCertificates = scope.manage(cslTxBody.certs());
  let trezorCertificatesData;
  if (cslCertificates) {
    trezorCertificatesData = prepareTrezorCertificates(cslCertificates, rewardAccountKeyPath, rewardAccountKeyHash);
  }
  const signingMode = trezorCertificatesData?.signingMode || trezor.CardanoTxSigningMode.ORDINARY_TRANSACTION;

  // TX - Fee
  const fee = scope.manage(cslTxBody.fee()).to_str();

  // TX - TTL
  let ttl;
  const cslTTL = cslTxBody.ttl();
  if (cslTTL) {
    ttl = cslTTL.toString();
  }

  const validityIntervalStart = cslTxBody.validity_start_interval()?.to_str();

  // TX  - auxiliaryData
  const txBodyAuxDataHash = scope.manage(cslTxBody.auxiliary_data_hash());
  let auxiliaryData;
  if (txBodyAuxDataHash) {
    auxiliaryData = {
      hash: Buffer.from(txBodyAuxDataHash.to_bytes()).toString('hex')
    };
  }

  // TX - Mint (assets bundle)
  const cslMint = scope.manage(cslTxBody.multiassets());
  let trezorMintBundle = null;
  if (cslMint) {
    const paymentKeyPaths = uniq(trezorInputs.map((trezorInput) => trezorInput.path).filter(isNotNil));
    trezorMintBundle = prepareTrezorMintBundle(cslMint, paymentKeyPaths, rewardAccountKeyPath);
  }
  scope.dispose();
  return {
    additionalWitnessRequests: trezorMintBundle?.additionalWitnessPaths,
    auxiliaryData,
    certificates: trezorCertificatesData?.certs,
    fee,
    inputs: trezorInputs,
    mint: trezorMintBundle?.mintAssetsGroup,
    networkId: chainId.networkId,
    outputs: trezorOutputs,
    protocolMagic: chainId.networkMagic,
    signingMode,
    ttl,
    validityIntervalStart,
    withdrawals: trezorWithdrawals
  };
};
