import { Asset, CSL, Cardano, SerializationFailure, util } from '..';
import { BootstrapWitness } from '@cardano-ogmios/schema';
import { SerializationError } from '../errors';
export const txRequiredExtraSignatures = (
  signatures: CSL.Ed25519KeyHashes | undefined
): Cardano.Ed25519KeyHash[] | undefined => {
  if (!signatures) return;
  const requiredSignatures: Cardano.Ed25519KeyHash[] = [];
  for (let i = 0; i < signatures.len(); i++) {
    const signature = signatures.get(i);
    const cardanoSignature = Cardano.Ed25519KeyHash(Buffer.from(signature.to_bytes()).toString('hex'));
    requiredSignatures.push(cardanoSignature);
  }
  return requiredSignatures;
};

export const txWithdrawals = (withdrawals?: CSL.Withdrawals): Cardano.Withdrawal[] | undefined => {
  if (!withdrawals) return;
  const result: Cardano.Withdrawal[] = [];
  const keys = withdrawals.keys();
  for (let i = 0; i < keys.len(); i++) {
    const key = keys.get(i);
    const value = withdrawals.get(key);
    const rewardAccount = Cardano.RewardAccount(key.to_address().toString());
    result.push({ quantity: BigInt(value!.to_str()), stakeAddress: rewardAccount });
  }
  return result;
};

export const value = (cslValue: CSL.Value): Cardano.Value => {
  const result: Cardano.Value = {
    coins: BigInt(cslValue.coin().to_str())
  };
  const multiasset = cslValue.multiasset();
  if (!multiasset) {
    return result;
  }
  result.assets = new Map();
  const scriptHashes = multiasset.keys();
  for (let scriptHashIdx = 0; scriptHashIdx < scriptHashes.len(); scriptHashIdx++) {
    const scriptHash = scriptHashes.get(scriptHashIdx);
    const assets = multiasset.get(scriptHash)!;
    const assetKeys = assets.keys();
    for (let assetIdx = 0; assetIdx < assetKeys.len(); assetIdx++) {
      const assetName = assetKeys.get(assetIdx);
      const assetAmount = BigInt(assets.get(assetName)!.to_str());
      if (assetAmount > 0n) {
        result.assets.set(Asset.util.createAssetId(scriptHash, assetName), assetAmount);
      }
    }
  }
  return result;
};

export const txIn = (input: CSL.TransactionInput, address?: Cardano.Address): Cardano.TxIn => ({
  address,
  index: input.index(),
  txId: Cardano.TransactionId.fromHexBlob(util.bytesToHex(input.transaction_id().to_bytes()))
});

export const txOut = (output: CSL.TransactionOutput): Cardano.TxOut => {
  const dataHashBytes = output.data_hash()?.to_bytes();
  return {
    address: Cardano.Address(output.address().to_bech32()),
    datum: dataHashBytes ? Cardano.Hash32ByteBase16.fromHexBlob(util.bytesToHex(dataHashBytes)) : undefined,
    value: value(output.amount())
  };
};

export const txOutputs = (outputs: CSL.TransactionOutputs): Cardano.TxOut[] => {
  const result: Cardano.TxOut[] = [];
  for (let i = 0; i < outputs.len(); i++) {
    result.push(txOut(outputs.get(i)));
  }
  return result;
};

export const txInputs = (inputs: CSL.TransactionInputs, address?: Cardano.Address): Cardano.TxIn[] => {
  const result: Cardano.TxIn[] = [];
  for (let i = 0; i < inputs.len(); i++) {
    result.push(txIn(inputs.get(i), address));
  }
  return result;
};

const stakeRegistration = (certificate: CSL.StakeRegistration): Cardano.StakeAddressCertificate => ({
  __typename: Cardano.CertificateType.StakeKeyRegistration,
  rewardAccount: Cardano.RewardAccount(Buffer.from(certificate.to_bytes()).toString())
});

const stakeDeregistration = (certificate: CSL.StakeDeregistration): Cardano.StakeAddressCertificate => ({
  __typename: Cardano.CertificateType.StakeKeyDeregistration,
  rewardAccount: Cardano.RewardAccount(Buffer.from(certificate.to_bytes()).toString())
});

const stakeDelegation = (certificate: CSL.StakeDelegation): Cardano.StakeDelegationCertificate => ({
  __typename: Cardano.CertificateType.StakeDelegation,
  poolId: Cardano.PoolId(certificate.pool_keyhash().toString()), // TODO: is this correct??
  rewardAccount: Cardano.RewardAccount(Buffer.from(certificate.to_bytes()).toString())
});

const createCardanoRelays = (relays: CSL.Relays): Cardano.Relay[] => {
  const result: Cardano.Relay[] = [];
  for (let i = 0; i < relays.len(); i++) {
    const relay = relays.get(i);
    const relayByAddress = relay.as_single_host_addr();
    const relayByName = relay.as_single_host_name();
    const relayByNameMultihost = relay.as_multi_host_name();

    if (relayByAddress) {
      // RelayByAddress
      result.push({
        __typename: 'RelayByAddress',
        ipv4: relayByAddress.ipv4()?.ip().toString(),
        ipv6: relayByAddress.ipv6()?.ip().toString(),
        port: relayByAddress.port()
      });
    }
    if (relayByName) {
      // RelayByName
      result.push({
        __typename: 'RelayByName',
        hostname: relayByName.dns_name().record(),
        port: relayByName.port()
      });
    }
    if (relayByNameMultihost) {
      // RelayByNameMultihost
      result.push({
        __typename: 'RelayByNameMultihost',
        dnsName: relayByNameMultihost.dns_name().record()
      });
    }
  }
  return result;
};

const createCardanoOwners = (owners: CSL.Ed25519KeyHashes): Cardano.RewardAccount[] => {
  const result: Cardano.RewardAccount[] = [];
  for (let i = 0; i < owners.len(); i++) {
    const owner = owners.get(i);
    result.push(Cardano.RewardAccount(Buffer.from(owner.to_bytes()).toString()));
  }
  return result;
};

const jsonMetadata = (poolMetadata?: CSL.PoolMetadata): Cardano.PoolMetadataJson | undefined => {
  if (!poolMetadata) return;
  return {
    hash: Cardano.util.Hash32ByteBase16(poolMetadata.pool_metadata_hash().to_bytes().toString()),
    url: poolMetadata.url().url()
  };
};

const poolRegistration = (certificate: CSL.PoolRegistration): Cardano.PoolRegistrationCertificate => {
  const { reward_account, pledge, cost, margin, operator, pool_metadata, pool_owners, relays, vrf_keyhash } =
    certificate.pool_params();

  return {
    __typename: Cardano.CertificateType.PoolRegistration,
    epoch: null,
    poolId: Cardano.PoolId(Buffer.from(operator().to_bytes()).toString()), // TODO: make optional
    poolParameters: {
      cost: BigInt(cost.toString()),
      id: Cardano.PoolId(Buffer.from(operator().to_bytes()).toString()),
      margin: {
        denominator: Number(margin().denominator().to_str()),
        numerator: Number(margin().numerator().to_str())
      },
      metadataJson: jsonMetadata(pool_metadata()),
      owners: createCardanoOwners(pool_owners()),
      pledge: BigInt(pledge.toString()),
      relays: createCardanoRelays(relays()),
      rewardAccount: Cardano.RewardAccount(reward_account().to_address().to_bech32()),
      vrf: Cardano.VrfVkHex(Buffer.from(vrf_keyhash().to_bytes()).toString())
    }
  } as unknown as Cardano.PoolRegistrationCertificate; // TODO: this is because epoch not provided
};

const poolRetirement = (certificate: CSL.PoolRetirement): Cardano.PoolRetirementCertificate => ({
  __typename: Cardano.CertificateType.PoolRetirement,
  epoch: certificate.epoch(),
  poolId: Cardano.PoolId(certificate.pool_keyhash().toString())
});

const genesisKeyDelegaation = (certificate: CSL.GenesisKeyDelegation): Cardano.GenesisKeyDelegationCertificate => ({
  __typename: Cardano.CertificateType.GenesisKeyDelegation,
  genesisDelegateHash: Cardano.util.Hash32ByteBase16(
    Buffer.from(certificate.genesis_delegate_hash().to_bytes()).toString()
  ),
  genesisHash: Cardano.util.Hash32ByteBase16(Buffer.from(certificate.genesishash().to_bytes()).toString()),
  vrfKeyHash: Cardano.util.Hash32ByteBase16(Buffer.from(certificate.vrf_keyhash().to_bytes()).toString())
});

export const txCertificates = (certificates?: CSL.Certificates): Cardano.Certificate[] | undefined => {
  if (!certificates) return;
  const result: Cardano.Certificate[] = [];
  for (let i = 0; i < certificates.len(); i++) {
    const cslCertificate = certificates.get(i);
    const certificateKind = CSL.CertificateKind[cslCertificate.kind()];

    switch (certificateKind) {
      case CSL.CertificateKind.StakeRegistration.toString():
        result.push(stakeRegistration(cslCertificate.as_stake_registration()!));
        break;
      case CSL.CertificateKind.StakeDeregistration.toString():
        result.push(stakeDeregistration(cslCertificate.as_stake_deregistration()!));
        break;
      case CSL.CertificateKind.StakeDelegation.toString():
        result.push(stakeDelegation(cslCertificate.as_stake_delegation()!));
        break;
      case CSL.CertificateKind.PoolRegistration.toString():
        result.push(poolRegistration(cslCertificate.as_pool_registration()!));
        break;
      case CSL.CertificateKind.PoolRetirement.toString():
        result.push(poolRetirement(cslCertificate.as_pool_retirement()!));
        break;
      case CSL.CertificateKind.GenesisKeyDelegation.toString():
        result.push(genesisKeyDelegaation(cslCertificate.as_genesis_key_delegation()!));
        break;
      case CSL.CertificateKind.MoveInstantaneousRewardsCert.toString():
        throw new Error('not yet implemented'); // TODO: support this certificate type
      default:
        throw new SerializationError(SerializationFailure.InvalidType);
    }
  }
  return result;
};

export const txTokenMap = (assets?: CSL.Mint): Cardano.TokenMap | undefined => {
  if (!assets) return;
  const assetMap: Cardano.TokenMap = new Map();
  const keys = assets.keys();
  for (let i = 0; i < keys.len(); i++) {
    const mintAssets = assets.get(keys.get(i));
    if (!mintAssets) continue;
    const mintKeys = mintAssets.keys();
    for (let k = 0; k < mintKeys.len(); k++) {
      const assetName = mintKeys.get(k);
      const assetValue = mintAssets.get(assetName);
      const assetId = Cardano.AssetId(assetName.toString());
      if (!assetValue) continue;
      assetMap.set(assetId, BigInt(assetValue.toString()));
    }
  }
  return assetMap;
};

export const txBody = (body: () => CSL.TransactionBody): Cardano.TxBodyAlonzo => {
  const { script_data_hash } = body();

  const cslCollaterals = body().collateral();

  return {
    certificates: txCertificates(body().certs()),
    collaterals: cslCollaterals && txInputs(cslCollaterals),
    fee: BigInt(body().fee().to_str()),
    inputs: txInputs(body().inputs()),
    mint: txTokenMap(body().multiassets()),
    outputs: txOutputs(body().outputs()),
    requiredExtraSignatures: txRequiredExtraSignatures(body().required_signers()),
    scriptIntegrityHash:
      script_data_hash && Cardano.util.Hash28ByteBase16(Buffer.from(script_data_hash()!.to_bytes()).toString()),
    validityInterval: body().validity_start_interval,
    withdrawals: txWithdrawals(body().withdrawals())
  };
};

export const txBootstrap = (bootstraps?: CSL.BootstrapWitnesses): BootstrapWitness[] | undefined => {
  if (!bootstraps) return;
  const result: BootstrapWitness[] = [];
  for (let i = 0; i < bootstraps.len(); i++) {
    const bootstrap = bootstraps.get(i);
    result.push({
      addressAttributes: bootstrap.attributes().toString(),
      chainCode: bootstrap.chain_code().toString(),
      key: bootstrap.vkey.toString(),
      signature: bootstrap.signature.toString()
    });
  }
  return result;
};

export const txRedeemers = (redeemers?: CSL.Redeemers): Cardano.Redeemer[] | undefined => {
  if (!redeemers) return;
  const result: Cardano.Redeemer[] = [];
  for (let j = 0; j < redeemers.len(); j++) {
    const reedeemer = redeemers.get(j);
    const index = reedeemer.index();
    const data = reedeemer.data();
    const exUnits = reedeemer.ex_units();

    /**
     * CSL.RedeemerTagKind = Spend, Mint, Cert, Reward
     * should we modify Cardano.Redeemer.purpose to match or just map reward to withdrawal ??
     */
    const redeemerTagKind = reedeemer.tag().kind();

    result.push({
      executionUnits: { memory: Number(exUnits.mem()), steps: Number(exUnits.steps()) },
      index: Number(index),
      purpose: Object.values(Cardano.RedeemerPurpose)[redeemerTagKind],
      scriptHash: Cardano.Hash28ByteBase16(Buffer.from(data.to_bytes()).toString())
    });
  }
  return result;
};

export const txWitnessSet = (witnessSet: CSL.TransactionWitnessSet): Cardano.Witness => {
  const vkeys: CSL.Vkeywitnesses | undefined = witnessSet.vkeys()!;
  const redeemers: CSL.Redeemers | undefined = witnessSet.redeemers();
  const bootstraps: CSL.BootstrapWitnesses | undefined = witnessSet.bootstraps();

  const txSignatures: Cardano.Signatures = new Map();
  if (vkeys) {
    for (let i = 0; i < vkeys!.len(); i++) {
      const witness = vkeys.get(i);
      txSignatures.set(
        Cardano.Ed25519PublicKey(witness.vkey().public_key().to_bech32()),
        Cardano.Ed25519Signature(witness.signature().to_bech32())
      );
    }
  }

  return {
    // TODO: add support for scripts
    bootstrap: txBootstrap(bootstraps),
    // TODO: implement datums
    redeemers: txRedeemers(redeemers),
    signatures: txSignatures
  };
};

const txMetaDatum = (transactionMetadatum: CSL.TransactionMetadatum): Cardano.Metadatum => {
  const metadatumKind = CSL.TransactionMetadatumKind[transactionMetadatum.kind()];
  switch (metadatumKind) {
    case CSL.TransactionMetadatumKind.Bytes.toString():
      return transactionMetadatum.as_text();
    case CSL.TransactionMetadatumKind.Int.toString(): {
      const int = transactionMetadatum.as_int().as_i32()!;
      return BigInt(int);
    }
    case CSL.TransactionMetadatumKind.MetadataList.toString(): {
      const list = transactionMetadatum.as_list();
      const metaDatumList: Cardano.Metadatum[] = [];
      for (let j = 0; j < list.len(); j++) {
        const listItem = list.get(j);
        metaDatumList.push(txMetaDatum(listItem));
      }
      return metaDatumList;
    }
    case CSL.TransactionMetadatumKind.MetadataMap.toString(): {
      const txMap = transactionMetadatum.as_map();
      const metdatumMap = new Map();
      for (let i = 0; i < txMap.keys().len(); i++) {
        const metadaatumItem = txMap.keys().get(i);
        metdatumMap.set(metadaatumItem, metadaatumItem);
      }
      return metdatumMap;
    }
    case CSL.TransactionMetadatumKind.Text.toString():
      return transactionMetadatum.as_text();
    default:
      throw new SerializationError(SerializationFailure.InvalidType);
  }
};

export const txMetadata = (auxiliaryMetadata?: CSL.GeneralTransactionMetadata): Cardano.TxMetadata | undefined => {
  if (!auxiliaryMetadata) return;
  const auxiliaryMetadataMap: Cardano.TxMetadata = new Map();

  for (let i = 0; i < auxiliaryMetadata.len(); i++) {
    const transactionMetadatum = auxiliaryMetadata.get(CSL.BigNum.from_str(i.toString()));
    if (transactionMetadatum) {
      auxiliaryMetadataMap.set(BigInt(i), txMetaDatum(transactionMetadatum));
    }
  }
  return auxiliaryMetadataMap;
};

export const txAuxiliaryData = (auxiliaryData?: CSL.AuxiliaryData): Cardano.AuxiliaryData | undefined => {
  if (!auxiliaryData) return;
  // TODO: create hash
  const auxiliaryMetadata = auxiliaryData.metadata();
  return {
    body: {
      blob: txMetadata(auxiliaryMetadata)
    }
  };
};

export const newTx = (_input: CSL.Transaction): Cardano.NewTxAlonzo => {
  const transactionHash = Cardano.TransactionId.fromHexBlob(
    util.bytesToHex(CSL.hash_transaction(_input.body()).to_bytes())
  );
  const auxiliary_data = _input.auxiliary_data();

  const witnessSet = _input.witness_set();

  return {
    auxiliaryData: txAuxiliaryData(auxiliary_data),
    body: txBody(_input.body),
    id: transactionHash,
    witness: txWitnessSet(witnessSet)
  };
};
