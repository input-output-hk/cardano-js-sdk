/* eslint-disable sonarjs/cognitive-complexity, complexity, max-statements */
import * as Crypto from '@cardano-sdk/crypto';
import { AccountBalanceInterval } from './AccountBalanceInterval';
import { Address, CredentialType, RewardAddress } from '../../Cardano/Address';
import { CborReader, CborReaderState, CborWriter } from '../CBOR';
import { CborSet, Credential, DeserializationOptions } from '../Common';
import { Certificate } from '../Certificates';
import { Guards } from './Guards';
import { HexBlob } from '@cardano-sdk/util';
import { PlutusData } from '../PlutusData';
import { ProposalProcedure } from './ProposalProcedure';
import { SerializationError, SerializationFailure } from '../../errors';
import { Slot } from '../../Cardano/types/Block';
import { TransactionInput } from './TransactionInput';
import { TransactionOutput } from './TransactionOutput';
import { VotingProcedures } from './VotingProcedures';
import { hexToBytes } from '../../util/misc';
import { multiAssetsToTokenMap, sortCanonically, tokenMapToMultiAsset } from './Utils';
import type * as Cardano from '../../Cardano';

type TransactionInputSet = CborSet<ReturnType<TransactionInput['toCore']>, TransactionInput>;

const TOP_LEVEL_ONLY_KEYS = new Set([2n, 13n, 16n, 17n, 23n]);

/**
 * The body of a Dijkstra sub transaction (CIP-0118 nested transactions).
 *
 * A sub transaction body reuses the top level transaction body keys but excludes fee (2),
 * collateral inputs (13), collateral return (16), total collateral (17) and sub transactions
 * (23) - the enclosing transaction pays the fee and posts collateral for the whole batch - and
 * adds key 24 required_top_level_guards: guards the enclosing transaction must carry, each with
 * an optional plutus datum.
 *
 * Unlike the permissive top level decoder, decoding mirrors the ledger decoderByKey exactly:
 * keys 0 and 1 are required and any key outside the CDDL sub_transaction_body key set is
 * rejected rather than skipped.
 */
export class SubTransactionBody {
  // Required fields
  #inputs: TransactionInputSet;
  #outputs: Array<TransactionOutput>;

  // Optional fields
  #ttl: Cardano.Slot | undefined;
  #certs: CborSet<ReturnType<Certificate['toCore']>, Certificate> | undefined;
  #withdrawals: Map<Cardano.RewardAccount, Cardano.Lovelace> | undefined;
  #auxiliaryDataHash: Crypto.Hash32ByteBase16 | undefined;
  #validityStartInterval: Cardano.Slot | undefined;
  #mint: Cardano.TokenMap | undefined;
  #scriptDataHash: Crypto.Hash32ByteBase16 | undefined;
  #guards: Guards | undefined;
  #networkId: Cardano.NetworkId | undefined;
  #referenceInputs: TransactionInputSet | undefined;
  #votingProcedures: VotingProcedures | undefined;
  #proposalProcedures: CborSet<ReturnType<ProposalProcedure['toCore']>, ProposalProcedure> | undefined;
  #currentTreasuryValue: Cardano.Lovelace | undefined;
  #donation: Cardano.Lovelace | undefined;
  #requiredTopLevelGuards: Map<Credential, PlutusData | null> | undefined;
  #directDeposits: Map<Cardano.RewardAccount, Cardano.Lovelace> | undefined;
  #accountBalanceIntervals: Map<Credential, AccountBalanceInterval> | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the SubTransactionBody class.
   *
   * @param inputs A list of references to UTxOs (Unspent Transaction Outputs) that the sub transaction intends to spend.
   * @param outputs A list of outputs where ownership of the value will be assigned by address.
   */
  constructor(inputs: TransactionInputSet, outputs: Array<TransactionOutput>) {
    this.#inputs = inputs;
    this.#outputs = outputs;
  }

  /**
   * Serializes a SubTransactionBody into CBOR format.
   *
   * @returns The SubTransactionBody in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // sub_transaction_body =
    //   {   0  : set<transaction_input>
    //   ,   1  : [* transaction_output]
    //   , ? 3  : slot
    //   , ? 4  : certificates
    //   , ? 5  : withdrawals
    //   , ? 7  : auxiliary_data_hash
    //   , ? 8  : slot
    //   , ? 9  : mint
    //   , ? 11 : script_data_hash
    //   , ? 14 : guards
    //   , ? 15 : network_id
    //   , ? 18 : nonempty_set<transaction_input>
    //   , ? 19 : voting_procedures
    //   , ? 20 : proposal_procedures
    //   , ? 21 : coin
    //   , ? 22 : positive_coin
    //   , ? 24 : required_top_level_guards
    //   , ? 25 : direct_deposits
    //   , ? 26 : account_balance_intervals
    //   }
    writer.writeStartMap(this.#getMapSize());

    writer.writeInt(0n);
    writer.writeEncodedValue(hexToBytes(this.#inputs.toCbor()));

    writer.writeInt(1n);
    writer.writeStartArray(this.#outputs.length);

    for (const output of this.#outputs) {
      writer.writeEncodedValue(Buffer.from(output.toCbor(), 'hex'));
    }

    if (this.#ttl !== undefined) {
      writer.writeInt(3n);
      writer.writeInt(this.#ttl);
    }

    if (this.#certs !== undefined && this.#certs.size() > 0) {
      writer.writeInt(4n);
      writer.writeEncodedValue(hexToBytes(this.#certs.toCbor()));
    }

    if (this.#withdrawals !== undefined && this.#withdrawals.size > 0) {
      writer.writeInt(5n);
      // Create a new map with address bytes to avoid logic duplication and address checks
      const withdrawalsWithAddressBytes = new Map();
      for (const [key, value] of this.#withdrawals) {
        const rewardAddress = RewardAddress.fromAddress(Address.fromBech32(key));
        if (!rewardAddress) {
          throw new SerializationError(SerializationFailure.InvalidAddress, `Invalid withdrawal address: ${key}`);
        }
        const rewardAddressBytes = rewardAddress.toAddress().toBytes();
        withdrawalsWithAddressBytes.set(rewardAddressBytes, value);
      }

      // Sort withdrawals by address bytes, canonically
      const sortedCanonically = [...withdrawalsWithAddressBytes].sort((a, b) => (a > b ? 1 : -1));

      writer.writeStartMap(sortedCanonically.length);

      for (const [key, value] of sortedCanonically) {
        writer.writeByteString(Buffer.from(key, 'hex'));
        writer.writeInt(value);
      }
    }

    if (this.#auxiliaryDataHash !== undefined) {
      writer.writeInt(7n);
      writer.writeByteString(Buffer.from(this.#auxiliaryDataHash, 'hex'));
    }

    if (this.#validityStartInterval !== undefined) {
      writer.writeInt(8n);
      writer.writeInt(this.#validityStartInterval);
    }

    if (this.#mint !== undefined && this.#mint.size > 0) {
      writer.writeInt(9n);

      const multiassets = tokenMapToMultiAsset(this.#mint);

      writer.writeStartMap(multiassets.size);
      const sortedMultiAssets = new Map([...multiassets!.entries()].sort(sortCanonically));

      for (const [scriptHash, assets] of sortedMultiAssets.entries()) {
        writer.writeByteString(Buffer.from(scriptHash, 'hex'));

        const sortedAssets = new Map([...assets!.entries()].sort(sortCanonically));

        writer.writeStartMap(sortedAssets.size);
        for (const [assetName, quantity] of sortedAssets.entries()) {
          writer.writeByteString(Buffer.from(assetName, 'hex'));
          writer.writeInt(quantity);
        }
      }
    }

    if (this.#scriptDataHash !== undefined) {
      writer.writeInt(11n);
      writer.writeByteString(Buffer.from(this.#scriptDataHash, 'hex'));
    }

    if (this.#guards !== undefined && this.#guards.size() > 0) {
      writer.writeInt(14n);
      writer.writeEncodedValue(hexToBytes(this.#guards.toCbor()));
    }

    if (this.#networkId !== undefined) {
      writer.writeInt(15n);
      writer.writeInt(this.#networkId);
    }

    if (this.#referenceInputs !== undefined && this.#referenceInputs.size() > 0) {
      writer.writeInt(18n);
      writer.writeEncodedValue(hexToBytes(this.#referenceInputs.toCbor()));
    }

    if (this.#votingProcedures !== undefined) {
      writer.writeInt(19n);
      writer.writeEncodedValue(Buffer.from(this.#votingProcedures.toCbor(), 'hex'));
    }

    if (this.#proposalProcedures !== undefined && this.#proposalProcedures.size() > 0) {
      writer.writeInt(20n);
      writer.writeEncodedValue(hexToBytes(this.#proposalProcedures.toCbor()));
    }

    if (this.#currentTreasuryValue !== undefined) {
      writer.writeInt(21n);
      writer.writeInt(this.#currentTreasuryValue);
    }

    if (this.#donation !== undefined) {
      writer.writeInt(22n);
      writer.writeInt(this.#donation);
    }

    if (this.#requiredTopLevelGuards !== undefined && this.#requiredTopLevelGuards.size > 0) {
      writer.writeInt(24n);

      const guardsWithCredentialBytes = new Map<HexBlob, PlutusData | null>();
      for (const [credential, datum] of this.#requiredTopLevelGuards) {
        guardsWithCredentialBytes.set(credential.toCbor(), datum);
      }

      const sortedCanonically = [...guardsWithCredentialBytes].sort((a, b) => (a[0] > b[0] ? 1 : -1));

      writer.writeStartMap(sortedCanonically.length);

      for (const [credentialBytes, datum] of sortedCanonically) {
        writer.writeEncodedValue(hexToBytes(credentialBytes));

        if (datum === null) {
          writer.writeNull();
        } else {
          writer.writeEncodedValue(hexToBytes(datum.toCbor()));
        }
      }
    }

    if (this.#directDeposits !== undefined && this.#directDeposits.size > 0) {
      writer.writeInt(25n);

      const depositsWithAddressBytes = new Map();
      for (const [key, value] of this.#directDeposits) {
        const rewardAddress = RewardAddress.fromAddress(Address.fromBech32(key));
        if (!rewardAddress) {
          throw new SerializationError(SerializationFailure.InvalidAddress, `Invalid direct deposit address: ${key}`);
        }
        depositsWithAddressBytes.set(rewardAddress.toAddress().toBytes(), value);
      }

      const sortedCanonically = [...depositsWithAddressBytes].sort((a, b) => (a > b ? 1 : -1));

      writer.writeStartMap(sortedCanonically.length);

      for (const [key, value] of sortedCanonically) {
        writer.writeByteString(Buffer.from(key, 'hex'));
        writer.writeInt(value);
      }
    }

    if (this.#accountBalanceIntervals !== undefined && this.#accountBalanceIntervals.size > 0) {
      writer.writeInt(26n);

      const intervalsWithCredentialBytes = new Map<HexBlob, AccountBalanceInterval>();
      for (const [credential, interval] of this.#accountBalanceIntervals) {
        intervalsWithCredentialBytes.set(credential.toCbor(), interval);
      }

      const sortedCanonically = [...intervalsWithCredentialBytes].sort((a, b) => (a[0] > b[0] ? 1 : -1));

      writer.writeStartMap(sortedCanonically.length);

      for (const [credentialBytes, interval] of sortedCanonically) {
        writer.writeEncodedValue(hexToBytes(credentialBytes));
        writer.writeEncodedValue(hexToBytes(interval.toCbor()));
      }
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the SubTransactionBody from a CBOR byte array.
   *
   * Key admission is strict regardless of options, mirroring the ledger decoderByKey: keys 0
   * and 1 are required, the top-level-only keys 2, 13, 16, 17 and 23 are rejected, and any
   * other key outside the CDDL sub_transaction_body key set is rejected rather than skipped.
   *
   * @param cbor The CBOR encoded SubTransactionBody object.
   * @param options Deserialization options forwarded to nested output decoding.
   * @returns The new SubTransactionBody instance.
   */
  static fromCbor(cbor: HexBlob, options?: DeserializationOptions): SubTransactionBody {
    const reader = new CborReader(cbor);

    const inputs = CborSet.fromCore([], TransactionInput.fromCore);
    const outputs: Array<TransactionOutput> = new Array<TransactionOutput>();
    const body = new SubTransactionBody(inputs, outputs);

    let hasInputs = false;
    let hasOutputs = false;

    reader.readStartMap();

    while (reader.peekState() !== CborReaderState.EndMap) {
      const key = reader.readInt();

      switch (key) {
        case 0n: {
          const inputsBytes = reader.readEncodedValue();
          body.setInputs(CborSet.fromCbor(HexBlob.fromBytes(inputsBytes), TransactionInput.fromCbor));
          hasInputs = true;
          break;
        }
        case 1n: {
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            body.outputs().push(TransactionOutput.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), options));
          }

          reader.readEndArray();
          hasOutputs = true;

          break;
        }
        case 3n:
          body.setTtl(Slot(Number(reader.readInt())));
          break;
        case 4n: {
          body.setCerts(CborSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), Certificate.fromCbor));
          break;
        }
        case 5n: {
          reader.readStartMap();

          body.setWithdrawals(new Map<Cardano.RewardAccount, Cardano.Lovelace>());

          while (reader.peekState() !== CborReaderState.EndMap) {
            const account = Address.fromBytes(
              HexBlob.fromBytes(reader.readByteString())
            ).toBech32() as Cardano.RewardAccount;

            const amount = reader.readInt();
            body.withdrawals()!.set(account, amount);
          }

          reader.readEndMap();
          break;
        }
        case 7n:
          body.setAuxiliaryDataHash(HexBlob.fromBytes(reader.readByteString()) as unknown as Crypto.Hash32ByteBase16);
          break;
        case 8n:
          body.setValidityStartInterval(Slot(Number(reader.readInt())));
          break;
        case 9n: {
          const multiassets = new Map<Crypto.Hash28ByteBase16, Map<Cardano.AssetName, bigint>>();

          reader.readStartMap();
          while (reader.peekState() !== CborReaderState.EndMap) {
            const scriptHash = HexBlob.fromBytes(reader.readByteString()) as unknown as Crypto.Hash28ByteBase16;

            if (!multiassets.has(scriptHash)) multiassets.set(scriptHash, new Map<Cardano.AssetName, bigint>());

            reader.readStartMap();
            while (reader.peekState() !== CborReaderState.EndMap) {
              const assetName = Buffer.from(reader.readByteString()).toString('hex') as unknown as Cardano.AssetName;
              const quantity = reader.readInt();

              multiassets.get(scriptHash)!.set(assetName, quantity);
            }
            reader.readEndMap();
          }
          reader.readEndMap();

          body.setMint(multiAssetsToTokenMap(multiassets));
          break;
        }
        case 11n:
          body.setScriptDataHash(HexBlob.fromBytes(reader.readByteString()) as unknown as Crypto.Hash32ByteBase16);
          break;
        case 14n:
          body.setGuards(Guards.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          break;
        case 15n:
          body.setNetworkId(Number(reader.readInt()) as Cardano.NetworkId);
          break;
        case 18n:
          body.setReferenceInputs(
            CborSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), TransactionInput.fromCbor)
          );
          break;
        case 19n:
          body.setVotingProcedures(VotingProcedures.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          break;
        case 20n:
          body.setProposalProcedures(
            CborSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), ProposalProcedure.fromCbor)
          );
          break;
        case 21n:
          body.setCurrentTreasuryValue(reader.readInt());
          break;
        case 22n:
          body.setDonation(reader.readInt());
          break;
        case 24n: {
          reader.readStartMap();

          const requiredTopLevelGuards = new Map<Credential, PlutusData | null>();

          while (reader.peekState() !== CborReaderState.EndMap) {
            const credential = Credential.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

            if (reader.peekState() === CborReaderState.Null) {
              reader.readNull();
              requiredTopLevelGuards.set(credential, null);
            } else {
              requiredTopLevelGuards.set(credential, PlutusData.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
            }
          }

          reader.readEndMap();

          if (requiredTopLevelGuards.size === 0)
            throw new SerializationError(
              SerializationFailure.InvalidType,
              'required_top_level_guards (sub transaction body key 24) must be a non-empty map'
            );

          body.setRequiredTopLevelGuards(requiredTopLevelGuards);
          break;
        }
        case 25n: {
          reader.readStartMap();

          const directDeposits = new Map<Cardano.RewardAccount, Cardano.Lovelace>();

          while (reader.peekState() !== CborReaderState.EndMap) {
            const account = Address.fromBytes(
              HexBlob.fromBytes(reader.readByteString())
            ).toBech32() as Cardano.RewardAccount;

            directDeposits.set(account, reader.readInt());
          }

          reader.readEndMap();

          if (directDeposits.size === 0)
            throw new SerializationError(
              SerializationFailure.InvalidType,
              'direct_deposits (sub transaction body key 25) must be a non-empty map'
            );

          body.setDirectDeposits(directDeposits);
          break;
        }
        case 26n: {
          reader.readStartMap();

          const accountBalanceIntervals = new Map<Credential, AccountBalanceInterval>();

          while (reader.peekState() !== CborReaderState.EndMap) {
            const credential = Credential.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
            const interval = AccountBalanceInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

            accountBalanceIntervals.set(credential, interval);
          }

          reader.readEndMap();

          if (accountBalanceIntervals.size === 0)
            throw new SerializationError(
              SerializationFailure.InvalidType,
              'account_balance_intervals (sub transaction body key 26) must be a non-empty map'
            );

          body.setAccountBalanceIntervals(accountBalanceIntervals);
          break;
        }
        default:
          throw new SerializationError(
            SerializationFailure.UnknownField,
            TOP_LEVEL_ONLY_KEYS.has(key)
              ? `Top-level-only transaction body map key not allowed in sub transaction body: ${key}`
              : `Unknown sub transaction body map key: ${key}`
          );
      }
    }

    reader.readEndMap();

    if (!hasInputs)
      throw new SerializationError(SerializationFailure.InvalidType, 'Sub transaction body missing required key: 0');
    if (!hasOutputs)
      throw new SerializationError(SerializationFailure.InvalidType, 'Sub transaction body missing required key: 1');

    body.#originalBytes = cbor;

    return body;
  }

  /**
   * Creates a Core SubTransactionBody object from the current SubTransactionBody object.
   *
   * @returns The Core SubTransactionBody object.
   */
  toCore(): Cardano.SubTransactionBody {
    const guardCredentials = this.#guards?.credentials();
    const guardKeyHashes =
      this.#guards?.keyHashes() ??
      guardCredentials
        ?.filter((credential) => credential.type === CredentialType.KeyHash)
        .map((credential) => Crypto.Ed25519KeyHashHex(credential.hash));

    return {
      accountBalanceIntervals: this.#accountBalanceIntervals
        ? [...this.#accountBalanceIntervals].map(([credential, interval]) => ({
            credential: credential.toCore(),
            interval: interval.toCore()
          }))
        : undefined,
      auxiliaryDataHash: this.#auxiliaryDataHash,
      certificates: this.#certs?.values() ? this.#certs.toCore() : undefined,
      directDeposits: this.#directDeposits
        ? [...this.#directDeposits].map(([stakeAddress, quantity]) => ({ quantity, stakeAddress }))
        : undefined,
      donation: this.#donation,
      guards: guardCredentials,
      inputs: this.#inputs.toCore(),
      mint: this.#mint,
      networkId: this.#networkId,
      outputs: this.#outputs.map((output) => output.toCore()),
      proposalProcedures: this.#proposalProcedures?.values() ? this.#proposalProcedures.toCore() : undefined,
      referenceInputs: this.#referenceInputs?.size() ? this.#referenceInputs.toCore() : undefined,
      requiredExtraSignatures: guardKeyHashes && guardKeyHashes.length > 0 ? guardKeyHashes : undefined,
      requiredTopLevelGuards: this.#requiredTopLevelGuards
        ? [...this.#requiredTopLevelGuards].map(([credential, datum]) => ({
            credential: credential.toCore(),
            datum: datum === null ? null : datum.toCore()
          }))
        : undefined,
      scriptIntegrityHash: this.#scriptDataHash,
      treasuryValue: this.#currentTreasuryValue,
      validityInterval:
        this.#ttl !== undefined || this.#validityStartInterval !== undefined
          ? {
              invalidBefore: this.#validityStartInterval,
              invalidHereafter: this.#ttl
            }
          : undefined,
      votingProcedures: this.#votingProcedures ? this.#votingProcedures.toCore() : undefined,
      withdrawals: this.#withdrawals
        ? [...this.#withdrawals].map(([stakeAddress, quantity]) => ({ quantity, stakeAddress }))
        : undefined
    };
  }

  /**
   * Creates a SubTransactionBody object from the given Core SubTransactionBody object.
   *
   * @param coreSubTransactionBody The core SubTransactionBody object.
   */
  static fromCore(coreSubTransactionBody: Cardano.SubTransactionBody): SubTransactionBody {
    const body = new SubTransactionBody(
      CborSet.fromCore(coreSubTransactionBody.inputs, TransactionInput.fromCore),
      coreSubTransactionBody.outputs.map((output) => TransactionOutput.fromCore(output))
    );

    if (coreSubTransactionBody.auxiliaryDataHash) body.setAuxiliaryDataHash(coreSubTransactionBody.auxiliaryDataHash);

    if (coreSubTransactionBody.certificates)
      body.setCerts(CborSet.fromCore(coreSubTransactionBody.certificates, Certificate.fromCore));

    if (coreSubTransactionBody.mint) body.setMint(coreSubTransactionBody.mint);

    if (coreSubTransactionBody.networkId !== undefined) body.setNetworkId(coreSubTransactionBody.networkId);

    if (coreSubTransactionBody.referenceInputs)
      body.setReferenceInputs(CborSet.fromCore(coreSubTransactionBody.referenceInputs, TransactionInput.fromCore));

    if (coreSubTransactionBody.guards) body.setGuards(Guards.fromCredentials(coreSubTransactionBody.guards));
    else if (coreSubTransactionBody.requiredExtraSignatures)
      body.setGuards(Guards.fromKeyHashes(coreSubTransactionBody.requiredExtraSignatures));

    if (coreSubTransactionBody.scriptIntegrityHash) body.setScriptDataHash(coreSubTransactionBody.scriptIntegrityHash);

    if (coreSubTransactionBody.validityInterval) {
      if (coreSubTransactionBody.validityInterval.invalidHereafter !== undefined)
        body.setTtl(coreSubTransactionBody.validityInterval.invalidHereafter);
      if (coreSubTransactionBody.validityInterval.invalidBefore !== undefined)
        body.setValidityStartInterval(coreSubTransactionBody.validityInterval.invalidBefore);
    }

    if (coreSubTransactionBody.withdrawals) {
      body.setWithdrawals(new Map<Cardano.RewardAccount, Cardano.Lovelace>());

      for (const coreWithdrawal of coreSubTransactionBody.withdrawals) {
        body.withdrawals()!.set(coreWithdrawal.stakeAddress, coreWithdrawal.quantity);
      }
    }

    if (coreSubTransactionBody.requiredTopLevelGuards) {
      const requiredTopLevelGuards = new Map<Credential, PlutusData | null>();

      for (const entry of coreSubTransactionBody.requiredTopLevelGuards) {
        requiredTopLevelGuards.set(
          Credential.fromCore(entry.credential),
          entry.datum === null ? null : PlutusData.fromCore(entry.datum)
        );
      }

      body.setRequiredTopLevelGuards(requiredTopLevelGuards);
    }

    if (coreSubTransactionBody.directDeposits) {
      body.setDirectDeposits(new Map<Cardano.RewardAccount, Cardano.Lovelace>());

      for (const coreDeposit of coreSubTransactionBody.directDeposits) {
        body.directDeposits()!.set(coreDeposit.stakeAddress, coreDeposit.quantity);
      }
    }

    if (coreSubTransactionBody.accountBalanceIntervals) {
      const accountBalanceIntervals = new Map<Credential, AccountBalanceInterval>();

      for (const entry of coreSubTransactionBody.accountBalanceIntervals) {
        accountBalanceIntervals.set(
          Credential.fromCore(entry.credential),
          AccountBalanceInterval.fromCore(entry.interval)
        );
      }

      body.setAccountBalanceIntervals(accountBalanceIntervals);
    }

    if (coreSubTransactionBody.donation !== undefined) body.setDonation(coreSubTransactionBody.donation);
    if (coreSubTransactionBody.treasuryValue !== undefined)
      body.setCurrentTreasuryValue(coreSubTransactionBody.treasuryValue);
    if (coreSubTransactionBody.votingProcedures)
      body.setVotingProcedures(VotingProcedures.fromCore(coreSubTransactionBody.votingProcedures));
    if (coreSubTransactionBody.proposalProcedures)
      body.setProposalProcedures(
        CborSet.fromCore(coreSubTransactionBody.proposalProcedures, ProposalProcedure.fromCore)
      );

    return body;
  }

  /**
   * Sets the list of references to UTxOs (Unspent Transaction Outputs) that the sub transaction intends to spend.
   *
   * @param inputs the list of references to UTxOs.
   */
  setInputs(inputs: TransactionInputSet) {
    this.#inputs = inputs;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the list of references to UTxOs (Unspent Transaction Outputs) that the sub transaction intends to spend.
   *
   * @returns The list of references to UTxOs.
   */
  inputs() {
    return this.#inputs;
  }

  /**
   * Sets the list of outputs where the value will go.
   *
   * @param outputs The list of outputs.
   */
  setOutputs(outputs: Array<TransactionOutput>) {
    this.#outputs = outputs;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the list of outputs where the value will go.
   *
   * @returns The list of outputs.
   */
  outputs(): Array<TransactionOutput> {
    return this.#outputs;
  }

  /**
   * Sets the slot number until which the sub transaction is valid.
   *
   * @param ttl The slot number until which the sub transaction is valid.
   */
  setTtl(ttl: Cardano.Slot) {
    this.#ttl = ttl;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the slot number until which the sub transaction is valid.
   *
   * @returns The slot number until which the sub transaction is valid.
   */
  ttl(): Cardano.Slot | undefined {
    return this.#ttl;
  }

  /**
   * Sets the certificates to be issued by this sub transaction.
   *
   * @param certs The certificates to be issued by this sub transaction.
   */
  setCerts(certs: CborSet<ReturnType<Certificate['toCore']>, Certificate>): void {
    this.#certs = certs;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the certificates to be issued by this sub transaction.
   *
   * @returns The certificates to be issued by this sub transaction.
   */
  certs() {
    return this.#certs;
  }

  /**
   * Sets the list of withdrawals. This specifies from which staking addresses rewards should be withdrawn.
   *
   * @param withdrawals The list of withdrawals.
   */
  setWithdrawals(withdrawals: Map<Cardano.RewardAccount, Cardano.Lovelace>): void {
    this.#withdrawals = withdrawals;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the list of withdrawals. This specifies from which staking addresses rewards should be withdrawn.
   *
   * @returns The list of withdrawals.
   */
  withdrawals(): Map<Cardano.RewardAccount, Cardano.Lovelace> | undefined {
    return this.#withdrawals;
  }

  /**
   * Sets the hash of the auxiliary data of the sub transaction, such as transaction metadata.
   *
   * @param auxiliaryDataHash The hash of the auxiliary data of the sub transaction.
   */
  setAuxiliaryDataHash(auxiliaryDataHash: Crypto.Hash32ByteBase16): void {
    this.#auxiliaryDataHash = auxiliaryDataHash;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the hash of the auxiliary data of the sub transaction, such as transaction metadata.
   *
   * @returns The hash of the auxiliary data of the sub transaction.
   */
  auxiliaryDataHash(): Crypto.Hash32ByteBase16 | undefined {
    return this.#auxiliaryDataHash;
  }

  /**
   * Sets the validity interval start for this sub transaction. This specifies the earliest
   * slot in which the sub transaction is valid.
   *
   * @param validityStartInterval The earliest slot in which the sub transaction is valid.
   */
  setValidityStartInterval(validityStartInterval: Cardano.Slot): void {
    this.#validityStartInterval = validityStartInterval;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the validity interval start for this sub transaction. This specifies the earliest
   * slot in which the sub transaction is valid.
   *
   * @returns The earliest slot in which the sub transaction is valid.
   */
  validityStartInterval(): Cardano.Slot | undefined {
    return this.#validityStartInterval;
  }

  /**
   * Sets details about the tokens being minted or burned in the sub transaction.
   *
   * @param mint The list of tokens being minted or burned.
   */
  setMint(mint: Cardano.TokenMap): void {
    // We need to segregate the token map as a multiasset to be able to sort it correctly in canonical form.
    this.#mint = multiAssetsToTokenMap(new Map([...tokenMapToMultiAsset(mint!).entries()].sort(sortCanonically)));

    this.#originalBytes = undefined;
  }

  /**
   * Gets details about the tokens being minted or burned in the sub transaction.
   *
   * @returns The list of tokens being minted or burned.
   */
  mint(): Cardano.TokenMap | undefined {
    return this.#mint;
  }

  /**
   * Sets the script data integrity hash.
   *
   * @param scriptDataHash The script data integrity hash.
   */
  setScriptDataHash(scriptDataHash: Crypto.Hash32ByteBase16): void {
    this.#scriptDataHash = scriptDataHash;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the script data integrity hash.
   *
   * @returns The script data integrity hash.
   */
  scriptDataHash(): Crypto.Hash32ByteBase16 | undefined {
    return this.#scriptDataHash;
  }

  /**
   * Sets the guards on body key 14. Guards are credentials that must approve the sub
   * transaction, in either the key hash set or credential ordered set wire form.
   *
   * @param guards The guards that must approve the sub transaction.
   */
  setGuards(guards: Guards): void {
    this.#guards = guards;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the guards of body key 14.
   *
   * @returns The guards, or undefined when key 14 is absent.
   */
  guards(): Guards | undefined {
    return this.#guards;
  }

  /**
   * Sets the network id on this sub transaction. This is an identifier used to distinguish
   * between different networks.
   *
   * @param networkId The id of the network this sub transaction is intended for.
   */
  setNetworkId(networkId: Cardano.NetworkId): void {
    this.#networkId = networkId;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the network id on this sub transaction. This is an identifier used to distinguish
   * between different networks.
   *
   * @returns The id of the network this sub transaction is intended for.
   */
  networkId(): Cardano.NetworkId | undefined {
    return this.#networkId;
  }

  /**
   * Reference inputs allows looking at an output without spending it. This facilitates access to information
   * stored on the blockchain without the need of spending and recreating UTxOs.
   *
   * @param referenceInputs The reference inputs.
   */
  setReferenceInputs(referenceInputs: TransactionInputSet): void {
    this.#referenceInputs = referenceInputs;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the reference inputs of this sub transaction.
   *
   * @returns the reference inputs.
   */
  referenceInputs() {
    return this.#referenceInputs;
  }

  /**
   * Sets the voting procedures of this sub transaction.
   *
   * @param votingProcedures the voting procedures.
   */
  setVotingProcedures(votingProcedures: VotingProcedures): void {
    this.#votingProcedures = votingProcedures;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the voting procedures of this sub transaction.
   *
   * @returns the voting procedures.
   */
  votingProcedures(): VotingProcedures | undefined {
    return this.#votingProcedures;
  }

  /**
   * Sets the proposal procedures of this sub transaction.
   *
   * @param proposalProcedure the proposal procedures.
   */
  setProposalProcedures(proposalProcedure: CborSet<ReturnType<ProposalProcedure['toCore']>, ProposalProcedure>): void {
    this.#proposalProcedures = proposalProcedure;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the proposal procedures of this sub transaction.
   *
   * @returns the proposal procedures.
   */
  proposalProcedures() {
    return this.#proposalProcedures;
  }

  /**
   * Sets the current treasury value of this sub transaction.
   *
   * @param currentTreasuryValue the current treasury value.
   */
  setCurrentTreasuryValue(currentTreasuryValue: Cardano.Lovelace): void {
    this.#currentTreasuryValue = currentTreasuryValue;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the current treasury value of this sub transaction.
   *
   * @returns the current treasury value.
   */
  currentTreasuryValue(): Cardano.Lovelace | undefined {
    return this.#currentTreasuryValue;
  }

  /**
   * Sets the current treasury donation of this sub transaction.
   *
   * @param donation The treasury donation.
   */
  setDonation(donation: Cardano.Lovelace): void {
    this.#donation = donation;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the current treasury donation of this sub transaction.
   *
   * @returns The treasury donation.
   */
  donation(): Cardano.Lovelace | undefined {
    return this.#donation;
  }

  /**
   * Sets the required top level guards (body key 24). Each entry names a guard the enclosing
   * transaction must carry, mapped to the plutus datum it must be supplied with, or null when
   * the guard carries no datum (CBOR nil on the wire, used for key hash and native script
   * guards).
   *
   * @param requiredTopLevelGuards The map of guard credentials to their optional datum.
   */
  setRequiredTopLevelGuards(requiredTopLevelGuards: Map<Credential, PlutusData | null>): void {
    this.#requiredTopLevelGuards = requiredTopLevelGuards;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the required top level guards (body key 24). Each entry names a guard the enclosing
   * transaction must carry, mapped to the plutus datum it must be supplied with, or null when
   * the guard carries no datum.
   *
   * @returns The map of guard credentials to their optional datum.
   */
  requiredTopLevelGuards(): Map<Credential, PlutusData | null> | undefined {
    return this.#requiredTopLevelGuards;
  }

  /**
   * Sets the direct deposits (body key 25). Each entry deposits coin directly into a reward
   * account without a withdrawal-style witness.
   *
   * @param directDeposits The map of reward accounts to deposited coin.
   */
  setDirectDeposits(directDeposits: Map<Cardano.RewardAccount, Cardano.Lovelace>): void {
    this.#directDeposits = directDeposits;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the direct deposits (body key 25). Each entry deposits coin directly into a reward
   * account without a withdrawal-style witness.
   *
   * @returns The map of reward accounts to deposited coin.
   */
  directDeposits(): Map<Cardano.RewardAccount, Cardano.Lovelace> | undefined {
    return this.#directDeposits;
  }

  /**
   * Sets the account balance intervals (body key 26). Each entry asserts that the balance of the
   * account with the given credential lies in a half-open range at validation time.
   *
   * @param accountBalanceIntervals The map of credentials to balance intervals.
   */
  setAccountBalanceIntervals(accountBalanceIntervals: Map<Credential, AccountBalanceInterval>): void {
    this.#accountBalanceIntervals = accountBalanceIntervals;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the account balance intervals (body key 26). Each entry asserts that the balance of the
   * account with the given credential lies in a half-open range at validation time.
   *
   * @returns The map of credentials to balance intervals.
   */
  accountBalanceIntervals(): Map<Credential, AccountBalanceInterval> | undefined {
    return this.#accountBalanceIntervals;
  }

  /**
   * Gets the size of the serialized map.
   *
   * @private
   */
  #getMapSize(): number {
    let mapSize = 2;

    if (this.#ttl !== undefined) ++mapSize;
    if (this.#certs !== undefined && this.#certs.size() > 0) ++mapSize;
    if (this.#withdrawals !== undefined && this.#withdrawals.size > 0) ++mapSize;
    if (this.#auxiliaryDataHash !== undefined) ++mapSize;
    if (this.#validityStartInterval !== undefined) ++mapSize;
    if (this.#mint !== undefined && this.#mint.size > 0) ++mapSize;
    if (this.#scriptDataHash !== undefined) ++mapSize;
    if (this.#guards !== undefined && this.#guards.size() > 0) ++mapSize;
    if (this.#networkId !== undefined) ++mapSize;
    if (this.#referenceInputs !== undefined && this.#referenceInputs.size() > 0) ++mapSize;
    if (this.#votingProcedures !== undefined) ++mapSize;
    if (this.#proposalProcedures !== undefined && this.#proposalProcedures.size() > 0) ++mapSize;
    if (this.#currentTreasuryValue !== undefined) ++mapSize;
    if (this.#donation !== undefined) ++mapSize;
    if (this.#requiredTopLevelGuards !== undefined && this.#requiredTopLevelGuards.size > 0) ++mapSize;
    if (this.#directDeposits !== undefined && this.#directDeposits.size > 0) ++mapSize;
    if (this.#accountBalanceIntervals !== undefined && this.#accountBalanceIntervals.size > 0) ++mapSize;

    return mapSize;
  }
}
