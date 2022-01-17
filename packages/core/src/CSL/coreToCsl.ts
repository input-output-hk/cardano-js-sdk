import * as Asset from '../Asset';
import * as Cardano from '../Cardano';
import {
  Address,
  Assets,
  BigNum,
  Certificates,
  Ed25519Signature,
  MultiAsset,
  PublicKey,
  RewardAddress,
  Transaction,
  TransactionBody,
  TransactionHash,
  TransactionInput,
  TransactionInputs,
  TransactionOutput,
  TransactionOutputs,
  TransactionUnspentOutput,
  TransactionWitnessSet,
  Value,
  Vkey,
  Vkeywitness,
  Vkeywitnesses,
  Withdrawals
} from '@emurgo/cardano-serialization-lib-nodejs';

import * as certificate from './certificate';
import { SerializationError } from '../errors';
import { SerializationFailure } from '..';
import { coreToCsl, parseCslAddress } from '.';
export * as certificate from './certificate';

export const tokenMap = (assets: Cardano.TokenMap) => {
  const multiasset = MultiAsset.new();
  for (const assetId of assets.keys()) {
    const { scriptHash, assetName } = Asset.util.parseAssetId(assetId);
    const assetsObj = Assets.new();
    const amount = BigNum.from_str(assets.get(assetId)!.toString());
    assetsObj.insert(assetName, amount);
    multiasset.insert(scriptHash, assetsObj);
  }
  return multiasset;
};

export const value = ({ coins, assets }: Cardano.Value): Value => {
  const result = Value.new(BigNum.from_str(coins.toString()));
  if (!assets) {
    return result;
  }
  if (assets.size > 0) {
    result.set_multiasset(tokenMap(assets));
  }
  return result;
};

export const txIn = (core: Cardano.TxIn): TransactionInput =>
  TransactionInput.new(TransactionHash.from_bytes(Buffer.from(core.txId, 'hex')), core.index);

export const txOut = (core: Cardano.TxOut): TransactionOutput =>
  TransactionOutput.new(parseCslAddress(core.address.toString())!, value(core.value));

export const utxo = (core: Cardano.Utxo[]): TransactionUnspentOutput[] =>
  core.map((item) => TransactionUnspentOutput.new(txIn(item[0]), txOut(item[1])));

export const txBody = ({
  inputs,
  outputs,
  fee,
  validityInterval,
  certificates,
  withdrawals
}: Cardano.TxBodyAlonzo): TransactionBody => {
  const cslInputs = TransactionInputs.new();
  for (const input of inputs) {
    cslInputs.add(txIn(input));
  }
  const cslOutputs = TransactionOutputs.new();
  for (const output of outputs) {
    cslOutputs.add(txOut(output));
  }
  const cslBody = TransactionBody.new(
    cslInputs,
    cslOutputs,
    BigNum.from_str(fee.toString()),
    validityInterval.invalidHereafter
  );
  if (validityInterval.invalidBefore) {
    cslBody.set_validity_start_interval(validityInterval.invalidBefore);
  }
  if (certificates?.length) {
    const certs = Certificates.new();
    for (const cert of certificates) {
      certs.add(certificate.create(cert));
    }
    cslBody.set_certs(certs);
  }
  if (withdrawals?.length) {
    const cslWithdrawals = Withdrawals.new();
    for (const { stakeAddress, quantity } of withdrawals) {
      const cslAddress = RewardAddress.from_address(Address.from_bech32(stakeAddress.toString()));
      if (!cslAddress) {
        throw new SerializationError(
          SerializationFailure.InvalidAddress,
          `Invalid withdrawal address: ${stakeAddress}`
        );
      }
      cslWithdrawals.insert(cslAddress, BigNum.from_str(quantity.toString()));
    }
    cslBody.set_withdrawals(cslWithdrawals);
  }
  return cslBody;
};

export const tx = ({ body, witness }: Cardano.NewTxAlonzo): Transaction => {
  const witnessSet = TransactionWitnessSet.new();
  const vkeyWitnesses = Vkeywitnesses.new();
  for (const [vkey, signature] of witness.signatures.entries()) {
    const publicKey = PublicKey.from_bytes(Buffer.from(vkey, 'hex'));
    const vkeyWitness = Vkeywitness.new(Vkey.new(publicKey), Ed25519Signature.from_hex(signature.toString()));
    vkeyWitnesses.add(vkeyWitness);
  }
  witnessSet.set_vkeys(vkeyWitnesses);
  return Transaction.new(coreToCsl.txBody(body), witnessSet);
};
