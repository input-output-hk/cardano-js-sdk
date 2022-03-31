import { Cardano, CSL } from '@cardano-sdk/core';
import { HwMappingError } from '../errors'
import {
  AddressType,
  Certificate,
  CertificateType,
  HARDENED,
  StakeCredentialParamsType,
  PoolKey,
  PoolKeyType,
  PoolRewardAccount,
  PoolRewardAccountType,
  PoolOwner,
  PoolOwnerType,
  Relay,
  RelayType,
  TransactionSigningMode,
  TxAuxiliaryDataType,
  TxOutputDestinationType,
  TxOutputDestination,
  Withdrawal,
  BIP32Path,
  SignTransactionRequest,
  TxAuxiliaryData,
} from '@cardano-foundation/ledgerjs-hw-app-cardano';

export interface AccountKeys {
  payment: {
    hash: Cardano.Ed25519PublicKey,
    path: BIP32Path,
  };
  stake: {
    hash: Cardano.Ed25519PublicKey,
    path: BIP32Path,
  };
}

export interface TxToLedgerProps {
  tx: CSL.Transaction,
  networkId: Cardano.NetworkId;
  keys: AccountKeys;
  addressHex: string,
  index: number,
};

const bytesToIp = (bytes?: Uint8Array) => {
  if (!bytes) return null;
  // return "192.168.0.1"
  if (bytes.length === 4) {
    return bytes.join('.');
  } else if (bytes.length === 16) {
    let ipv6 = '';
    for (let i = 0; i < bytes.length; i += 2) {
      ipv6 += bytes[i].toString(16) + bytes[i + 1].toString(16) + ':';
    }
    ipv6 = ipv6.slice(0, -1);
    return ipv6;
  }
  return null;
};

export const txToLedger = async ({ tx, networkId, keys, addressHex, index }: TxToLedgerProps): Promise<SignTransactionRequest> => {
  let signingMode = TransactionSigningMode.ORDINARY_TRANSACTION;
  const inputs = tx.body().inputs();
  const ledgerInputs = [];
  for (let i = 0; i < inputs.len(); i++) {
    const input = inputs.get(i);
    ledgerInputs.push({
      txHashHex: Buffer.from(input.transaction_id().to_bytes()).toString('hex'),
      outputIndex: input.index(),
      path: keys.payment.path,
    });
  }

  const outputs = tx.body().outputs();
  const ledgerOutputs = [];
  for (let i = 0; i < outputs.len(); i++) {
    const output = outputs.get(i);
    const multiAsset = output.amount().multiasset();
    let tokenBundle = [];
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
                assetNameHex: Buffer.from(assetName.name()).toString('hex'),
                amount: amount.to_str(),
              });
            }
          }
        } 
        // sort canonical
        tokens.sort((a, b) => {
          if (a.assetNameHex.length == b.assetNameHex.length) {
            return a.assetNameHex > b.assetNameHex ? 1 : -1;
          } else if (a.assetNameHex.length > b.assetNameHex.length) return 1;
          else return -1;
        });
        tokenBundle.push({
          policyIdHex: Buffer.from(policy.to_bytes()).toString('hex'),
          tokens,
        });
      }
    }
    const outputAddress = Buffer.from(output.address().to_bytes()).toString(
      'hex'
    );
    const isChangeAddress = outputAddress === addressHex
    const destination: TxOutputDestination =
      isChangeAddress
        ? {
            type: TxOutputDestinationType.DEVICE_OWNED,
            params: {
              type: AddressType.BASE_PAYMENT_KEY_STAKE_KEY, 
              params: {
                spendingPath: [
                  HARDENED + 1852,
                  HARDENED + 1815,
                  HARDENED + index,
                  0,
                  0,
                ],
                stakingPath: [
                  HARDENED + 1852,
                  HARDENED + 1815,
                  HARDENED + index,
                  2,
                  0,
                ],
              },
            },
          }
        : {
            type: TxOutputDestinationType.THIRD_PARTY,
            params: {
              addressHex: outputAddress,
            },
          };
    const outputRes = {
      amount: output.amount().coin().to_str(),
      tokenBundle,
      destination,
    };
    ledgerOutputs.push(outputRes);
  }
  let ledgerCertificates = null;
  const certificates = tx.body().certs();
  if (certificates) {
    ledgerCertificates = [];
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
              type: StakeCredentialParamsType.KEY_PATH,
              keyPath: keys.stake.path,
            },
          };
        } else if (credential && credentialScriptHash) {          
          const scriptHash = Buffer.from(
            credentialScriptHash.to_bytes()
          ).toString('hex');
          certificate.params = {
            stakeCredential: {
              type: StakeCredentialParamsType.SCRIPT_HASH,
              scriptHash,
            },
          };
        }
      } else if (cert.kind() === 1) {
        const credential = cert.as_stake_deregistration()?.stake_credential();
        const credentialScriptHash = credential?.to_scripthash();
        certificate.type = CertificateType.STAKE_DEREGISTRATION;
        if (credential?.kind() === 0) {
          certificate.params = {
            stakeCredential: {
              type: StakeCredentialParamsType.KEY_PATH,
              keyPath: keys.stake.path,
            },
          };
        } else if (credential && credentialScriptHash) {
          const scriptHash = Buffer.from(
            credentialScriptHash.to_bytes()
          ).toString('hex');
          certificate.params = {
            stakeCredential: {
              type: StakeCredentialParamsType.SCRIPT_HASH,
              scriptHash,
            },
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
              type: StakeCredentialParamsType.KEY_PATH,
              keyPath: keys.stake.path,
            },
          };
        } else if (credential && credentialScriptHash) {
          const scriptHash = Buffer.from(
            credentialScriptHash.to_bytes()
          ).toString('hex');
          certificate.params = {
            stakeCredential: {
              type: StakeCredentialParamsType.SCRIPT_HASH,
              scriptHash,
            },
          };
        } else if (delegationPoolKeyHash) {
          certificate.params = {
            ...certificate.params,
            poolKeyHashHex: Buffer.from(
              delegationPoolKeyHash.to_bytes()
            ).toString('hex')
          }
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
          for (let i = 0; i < owners.len(); i++) {
            const keyHash = Buffer.from(owners.get(i).to_bytes()).toString('hex');
            if (keyHash == keys.stake.hash.toString()) {
              signingMode = TransactionSigningMode.POOL_REGISTRATION_AS_OWNER;
              poolOwners.push({
                type: PoolOwnerType.DEVICE_OWNED,
                params: {
                  stakingPath: keys.stake.path,
                }
              });
            } else {
              poolOwners.push({
                type: PoolOwnerType.THIRD_PARTY,
                params: {
                  stakingKeyHashHex: keyHash,
                }
              });
            }
          }
        }
        const relays = params?.relays();
        const ledgerRelays = [] as Relay[];

        if (relays) {
          for (let i = 0; i < relays.len(); i++) {
            const relay = relays.get(i);
            if (relay.kind() === 0) {
              const singleHostAddr = relay.as_single_host_addr();
              const type = RelayType.SINGLE_HOST_IP_ADDR;
              const portNumber = singleHostAddr?.port();
              const ipv4 = singleHostAddr?.ipv4()
                ? bytesToIp(singleHostAddr.ipv4()?.ip())
                : null;
              const ipv6 = singleHostAddr?.ipv6()
                ? bytesToIp(singleHostAddr.ipv6()?.ip())
                : null;
              ledgerRelays.push({ type, params: { portNumber, ipv4, ipv6 } });
            } else if (relay.kind() === 1) {
              const type = RelayType.SINGLE_HOST_HOSTNAME;
              const singleHostName = relay.as_single_host_name();
              if (singleHostName) {
                const portNumber = singleHostName.port();
                const dnsName = singleHostName.dns_name().record();
                ledgerRelays.push({
                  type,
                  params: { portNumber, dnsName },
                });
              }
            } else if (relay.kind() === 2) {
              const type = RelayType.MULTI_HOST;
              const multiHostName = relay.as_multi_host_name();
              const dnsName = multiHostName?.dns_name().record();
              if (dnsName) {
                ledgerRelays.push({
                  type,
                  params: { dnsName },
                });
              }
            }
          }
        }
        const cost = params?.cost().to_str();
        const margin = params?.margin();
        const pledge = params?.pledge().to_str();

        const operator = Buffer.from(params.operator().to_bytes()).toString(
          'hex'
        );
        let poolKey: PoolKey;
        if (operator == keys.stake.hash.toString()) {
          signingMode = TransactionSigningMode.POOL_REGISTRATION_AS_OPERATOR;
          poolKey = {
            type: PoolKeyType.DEVICE_OWNED,
            params: { path: keys.stake.path },
          };
        } else {
          poolKey = {
            type: PoolKeyType.THIRD_PARTY,
            params: { keyHashHex: operator },
          };
        }

        const poolMetadata = params.pool_metadata();
        const metadata = poolMetadata
          ? {
              metadataUrl: poolMetadata.url().url(),
              metadataHashHex: Buffer.from(
                poolMetadata.pool_metadata_hash().to_bytes()
              ).toString('hex'),
            }
          : null;
        const rewardAccountHex = Buffer.from(
          params.reward_account().to_address().to_bytes()
        ).toString('hex');
        let rewardAccount: PoolRewardAccount;
        if (rewardAccountHex == addressHex) {
          rewardAccount = {
            type: PoolRewardAccountType.DEVICE_OWNED,
            params: { path: keys.stake.path },
          };
        } else {
          rewardAccount = {
            type: PoolRewardAccountType.THIRD_PARTY,
            params: { rewardAccountHex },
          };
        }
        const vrfKeyHashHex = Buffer.from(
          params.vrf_keyhash().to_bytes()
        ).toString('hex');

        certificate.params = {
          poolKey,
          vrfKeyHashHex,
          pledge,
          cost,
          margin: {
            numerator: margin.numerator().to_str(),
            denominator: margin.denominator().to_str(),
          },
          rewardAccount,
          poolOwners,
          relays: ledgerRelays,
          metadata,
        };
      }
      ledgerCertificates.push(certificate);
    }
  }

  const fee = tx.body().fee().to_str();
  const ttl = tx.body().ttl();
  const withdrawals = tx.body().withdrawals();
  let ledgerWithdrawals = null;
  if (withdrawals) {
    ledgerWithdrawals = [];
    for (let i = 0; i < withdrawals.keys().len(); i++) {
      const withdrawal = { stakeCredential: {} } as Withdrawal; 
      const rewardAddress = withdrawals.keys().get(i);
      const paymentCredentials = rewardAddress.payment_cred()
      const paymentCredentialsScriptHash = paymentCredentials.to_scripthash()
      if (rewardAddress.payment_cred().kind() === 0) {
        withdrawal.stakeCredential.type = StakeCredentialParamsType.KEY_PATH;
        // @ts-ignore
        withdrawal.stakeCredential.keyPath = keys.stake.path;
      } else if (paymentCredentialsScriptHash){
        withdrawal.stakeCredential.type = StakeCredentialParamsType.SCRIPT_HASH;
        // @ts-ignore
        withdrawal.stakeCredential.scriptHash = Buffer.from(
          paymentCredentialsScriptHash.to_bytes()
        ).toString('hex');
      }
      const withdrawalAmount = withdrawals.get(rewardAddress);
      if (!withdrawalAmount) {
        throw new HwMappingError('Withdrawal amount is not defined.')
      }
      ledgerWithdrawals.push({
        ...withdrawal,
        amount: withdrawalAmount.to_str()
      });
    }
  }
  const txBodyAuxDataHash = tx.body().auxiliary_data_hash();
  const auxiliaryData: TxAuxiliaryData | null = txBodyAuxDataHash
    ? {
        type: TxAuxiliaryDataType.ARBITRARY_HASH,
        params: {
          hashHex: Buffer.from(
            txBodyAuxDataHash.to_bytes()
          ).toString('hex'),
        },
      }
    : null;
  const validityStartInterval = tx.body().validity_start_interval();

  const mint = tx.body().multiassets();
  let additionalWitnessPaths = [];
  let mintBundle = null;
  if (mint) {
    mintBundle = [];
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
            throw new HwMappingError('Missing token amount.')
          }

          tokens.push({
            assetNameHex: Buffer.from(assetName.name()).toString('hex'),
            amount: amount.is_positive() ? positiveAmount : negativeAmount,
          });
        }
      }
      // Canonical sorting
      tokens.sort((a, b) => {
        if (a.assetNameHex.length == b.assetNameHex.length) {
          return a.assetNameHex > b.assetNameHex ? 1 : -1;
        } else if (a.assetNameHex.length > b.assetNameHex.length) return 1;
        else return -1;
      });
      mintBundle.push({
        policyIdHex: Buffer.from(policy.to_bytes()).toString('hex'),
        tokens,
      });
    }
    if (keys.payment.path) additionalWitnessPaths.push(keys.payment.path);
    if (keys.stake.path) additionalWitnessPaths.push(keys.stake.path);
  }

  const ledgerTx = {
    network: {
      protocolMagic: networkId === 1 ? 764824073 : 42,
      networkId,
    },
    inputs: ledgerInputs,
    outputs: ledgerOutputs,
    fee,
    ttl,
    certificates: ledgerCertificates,
    withdrawals: ledgerWithdrawals,
    auxiliaryData,
    validityStartInterval,
    mint: mintBundle,
  };

  Object.keys(ledgerTx).forEach(
    (key) => {
      const objKey = key as keyof typeof ledgerTx;
      return !ledgerTx[objKey] && ledgerTx[objKey] != 0 && delete ledgerTx[objKey]
    }
  );

  return {
    signingMode,
    tx: ledgerTx,
    additionalWitnessPaths,
  };
};