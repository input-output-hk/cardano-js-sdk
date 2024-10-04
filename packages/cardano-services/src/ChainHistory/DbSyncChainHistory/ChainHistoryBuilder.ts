// cSpell:ignore descr timelock

import * as Queries from './queries';
import {
  AuthorizeCommitteeHotCertModel,
  CertificateModel,
  DelegationCertModel,
  DrepCertModel,
  MirCertModel,
  MultiAssetModel,
  PoolRegisterCertModel,
  PoolRetireCertModel,
  ProposalProcedureModel,
  RedeemerModel,
  ResignCommitteeColdCertModel,
  ScriptModel,
  StakeCertModel,
  StakeRegistrationDelegationCertModel,
  StakeVoteDelegationCertModel,
  StakeVoteRegistrationDelegationCertModel,
  TransactionDataMap,
  TxIdModel,
  TxInput,
  TxInputModel,
  TxOutMultiAssetModel,
  TxOutScriptMap,
  TxOutTokenMap,
  TxOutput,
  TxOutputModel,
  TxTokenMap,
  VoteDelegationCertModel,
  VoteRegistrationDelegationCertModel,
  VotingProceduresModel,
  WithCertIndex,
  WithCertType,
  WithdrawalModel
} from './types';
import { Cardano, jsonToNativeScript } from '@cardano-sdk/core';
import { DB_MAX_SAFE_INTEGER, findTxsByAddresses } from './queries';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { Logger } from 'ts-log';
import { Pool, QueryResult } from 'pg';
import { Range, hexStringToBuffer } from '@cardano-sdk/util';
import { extractCompoundCertificates } from './util';
import {
  mapAnchor,
  mapCertificate,
  mapPlutusScript,
  mapProtocolParametersUpdateAction,
  mapRedeemer,
  mapTxId,
  mapTxInModel,
  mapTxOutModel,
  mapTxOutTokenMap,
  mapTxTokenMap,
  mapWithdrawal
} from './mappers';
import omit from 'lodash/omit.js';
import orderBy from 'lodash/orderBy.js';

const {
  CredentialType,
  FractionUtils,
  GovernanceActionType,
  NetworkId: { Mainnet, Testnet },
  RewardAccount,
  VoterType
} = Cardano;

type DbSyncCredential = { keyHash: Hash28ByteBase16; scriptHash: Hash28ByteBase16 };

const credentialFromDbSync: (source: DbSyncCredential) => Cardano.Credential = ({ keyHash, scriptHash }) => ({
  hash: keyHash || scriptHash,
  type: keyHash ? CredentialType.KeyHash : CredentialType.ScriptHash
});

const mapWithdrawals: (source: [{ credential: DbSyncCredential; network: string }, number]) => {
  rewardAccount: Cardano.RewardAccount;
  coin: Cardano.Lovelace;
} = ([{ credential, network }, coin]) => ({
  coin: BigInt(coin),
  rewardAccount: RewardAccount.fromCredential(
    credentialFromDbSync(credential),
    network === 'Mainnet' ? Mainnet : Testnet
  )
});

// eslint-disable-next-line complexity, @typescript-eslint/no-explicit-any
export const getGovernanceAction = (description: any): Cardano.GovernanceAction => {
  const { contents, tag } = description;
  const governanceActionId =
    contents && contents[0] ? { actionIndex: contents[0].govActionIx, id: contents[0].txId } : null;

  if (!tag) throw new Error('Missing "tag" in governance action proposal description');
  if (typeof tag !== 'string') throw new Error('Wrong "tag" type in governance action proposal description');

  switch (tag) {
    case 'HardForkInitiation':
      return {
        __typename: GovernanceActionType.hard_fork_initiation_action,
        governanceActionId,
        protocolVersion: contents[1]
      };

    case 'InfoAction':
      return { __typename: GovernanceActionType.info_action };

    case 'UpdateCommittee':
      return {
        __typename: GovernanceActionType.update_committee,
        governanceActionId,
        membersToBeAdded: new Set(
          Object.entries(contents[2]).map(([key, value]) => ({
            coldCredential: credentialFromDbSync(Object.fromEntries([key.split('-')])),
            epoch: value as Cardano.EpochNo
          }))
        ),
        membersToBeRemoved: new Set(contents[1].map(credentialFromDbSync)),
        newQuorumThreshold: typeof contents[3] === 'number' ? FractionUtils.toFraction(contents[3]) : contents[3]
      };

    case 'NewConstitution':
      return {
        __typename: GovernanceActionType.new_constitution,
        constitution: { scriptHash: null, ...contents[1] },
        governanceActionId
      };

    case 'NoConfidence':
      return { __typename: GovernanceActionType.no_confidence, governanceActionId };

    case 'ParameterChange':
      // {"contents":[{"govActionIx":0,"txId":"950d4b364840a27afeba929324d51dec0fac80b00cf7ca37905de08e3eae5ca6"},{"committeeMinSize":5},null],"tag":"ParameterChange"}
      return {
        __typename: GovernanceActionType.parameter_change_action,
        governanceActionId,
        policyHash: contents[2],
        protocolParamUpdate: mapProtocolParametersUpdateAction(contents[1])
      };

    case 'TreasuryWithdrawals':
      // {"contents":[[[{"credential":{"keyHash":"248f556b733c3ef24899ae0609d3796198d5470192304c4894dd85cb"},"network":"Testnet"},1000000000]],null],"tag":"TreasuryWithdrawals"}
      return {
        __typename: GovernanceActionType.treasury_withdrawals_action,
        policyHash: contents[1],
        withdrawals: new Set(contents[0].map(mapWithdrawals))
      };
  }

  throw new Error(`Unknown GovernanceActionType '${tag}' with description "${JSON.stringify(description)}"`);
};

type PartialVotingProceduresModel = Pick<
  VotingProceduresModel,
  'committee_has_script' | 'committee_voter' | 'drep_has_script' | 'drep_voter' | 'pool_voter' | 'voter_role'
>;

export const getVoter = (txId: Cardano.TransactionId, model: PartialVotingProceduresModel): Cardano.Voter => {
  const { committee_has_script, committee_voter, drep_has_script, drep_voter, pool_voter, voter_role } = model;
  let hash: Hash28ByteBase16;

  switch (voter_role) {
    case 'ConstitutionalCommittee':
      if (!(committee_voter instanceof Buffer)) throw new Error(`Unexpected committee_voter for tx "${txId}"`);

      hash = committee_voter.toString('hex') as Hash28ByteBase16;

      return committee_has_script
        ? { __typename: VoterType.ccHotScriptHash, credential: { hash, type: CredentialType.ScriptHash } }
        : { __typename: VoterType.ccHotKeyHash, credential: { hash, type: CredentialType.KeyHash } };

    case 'DRep':
      if (!(drep_voter instanceof Buffer)) throw new Error(`Unexpected drep_voter for tx "${txId}"`);

      hash = drep_voter.toString('hex') as Hash28ByteBase16;

      return drep_has_script
        ? { __typename: VoterType.dRepScriptHash, credential: { hash, type: CredentialType.ScriptHash } }
        : { __typename: VoterType.dRepKeyHash, credential: { hash, type: CredentialType.KeyHash } };

    case 'SPO':
      if (!(pool_voter instanceof Buffer)) throw new Error(`Unexpected pool_voter for tx "${txId}"`);

      hash = pool_voter.toString('hex') as Hash28ByteBase16;

      return { __typename: VoterType.stakePoolKeyHash, credential: { hash, type: CredentialType.KeyHash } };
  }

  throw new Error(`Unknown voter_role "${voter_role}" for tx "${txId}"`);
};

export class ChainHistoryBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }

  public async queryTransactionInputsByIds(ids: string[], collateral = false): Promise<TxInput[]> {
    this.#logger.debug(`About to find inputs (collateral: ${collateral}) for transactions with ids:`, ids);
    const result: QueryResult<TxInputModel> = await this.#db.query({
      name: `tx_${collateral ? 'collateral_' : ''}inputs_by_tx_ids`,
      text: collateral ? Queries.findTxCollateralsByIds : Queries.findTxInputsByIds,
      values: [ids]
    });
    return result.rows.length > 0 ? result.rows.map(mapTxInModel) : [];
  }

  public async queryMultiAssetsByTxOut(txOutIds: BigInt[]): Promise<TxOutTokenMap> {
    this.#logger.debug('About to find multi assets for tx outs:', txOutIds);
    const result: QueryResult<TxOutMultiAssetModel> = await this.#db.query({
      name: 'tx_multi_assets_by_tx_out_ids',
      text: Queries.findMultiAssetByTxOut,
      values: [txOutIds]
    });
    return mapTxOutTokenMap(result.rows);
  }

  public async queryReferenceScriptsByTxOut(txOutModel: TxOutputModel[]): Promise<TxOutScriptMap> {
    const txScriptMap: TxOutScriptMap = new Map();

    for (const model of txOutModel) {
      if (model.reference_script_id) {
        const result: QueryResult<ScriptModel> = await this.#db.query({
          name: 'tx_reference_scripts_by_tx_out_ids',
          text: Queries.findReferenceScriptsById,
          values: [[model.reference_script_id]]
        });

        if (result.rowCount === 0) continue;

        const [row] = result.rows;

        // There can only be one refScript per output.
        txScriptMap.set(model.id, row.bytes ? mapPlutusScript(row) : jsonToNativeScript(row.json));
      }
    }

    return txScriptMap;
  }

  public async queryTransactionOutputsByIds(ids: string[], collateral = false): Promise<TxOutput[]> {
    this.#logger.debug(`About to find outputs (collateral: ${collateral}) for transactions with ids:`, ids);
    const result: QueryResult<TxOutputModel> = await this.#db.query({
      name: `tx_${collateral ? 'collateral_' : ''}outputs_by_tx_ids`,
      text: collateral ? Queries.findCollateralOutputsByTxIds : Queries.findTxOutputsByIds,
      values: [ids]
    });
    if (result.rows.length === 0) return [];

    const txOutIds = result.rows.flatMap((txOut) => BigInt(txOut.id));
    // In case of collateralReturn requests (collateral = true) assets in the output can't be read as for regular outputs:
    // db-sync stores assets from collateral outputs in collateral_tx_out.multi_assets_descr column rather than in
    // ma_tx_out table like for regular outputs. To have a complete collateralReturn, given column should be read and parsed.
    const multiAssets = collateral ? new Map() : await this.queryMultiAssetsByTxOut(txOutIds);
    const referenceScripts = await this.queryReferenceScriptsByTxOut(result.rows);

    return result.rows.map((txOut) =>
      mapTxOutModel(txOut, {
        assets: multiAssets.get(txOut.id),
        script: referenceScripts.get(txOut.id)
      })
    );
  }

  public async queryTxMintByIds(ids: string[]): Promise<TxTokenMap> {
    this.#logger.debug('About to find tx mint for transactions with ids:', ids);
    const result: QueryResult<MultiAssetModel> = await this.#db.query({
      name: 'tx_mint_by_tx_ids',
      text: Queries.findTxMintByIds,
      values: [ids]
    });
    return mapTxTokenMap(result.rows);
  }

  public async queryTxRecordIdsByTxHashes(ids: Cardano.TransactionId[]): Promise<string[]> {
    this.#logger.debug('About to find tx mint for transactions with ids:', ids);
    const byteHashes = ids.map((id) => hexStringToBuffer(id));
    const result: QueryResult<{ id: string }> = await this.#db.query({
      name: 'tx_record_ids_by_tx_hashes',
      text: Queries.findTxRecordIdsByTxHashes,
      values: [byteHashes]
    });
    return result.rows.length > 0 ? result.rows.map(({ id }) => id) : [];
  }

  public async queryWithdrawalsByTxIds(ids: string[]): Promise<TransactionDataMap<Cardano.Withdrawal[]>> {
    this.#logger.debug('About to find withdrawals for transactions with ids:', ids);
    const result: QueryResult<WithdrawalModel> = await this.#db.query({
      name: 'tx_withdrawals_by_tx_ids',
      text: Queries.findWithdrawalsByTxIds,
      values: [ids]
    });
    const withdrawalMap: TransactionDataMap<Cardano.Withdrawal[]> = new Map();
    for (const withdrawal of result.rows) {
      const txId = withdrawal.tx_id.toString('hex') as unknown as Cardano.TransactionId;
      const currentWithdrawals = withdrawalMap.get(txId) ?? [];
      withdrawalMap.set(txId, [...currentWithdrawals, mapWithdrawal(withdrawal)]);
    }
    return withdrawalMap;
  }

  public async queryRedeemersByIds(ids: string[]): Promise<TransactionDataMap<Cardano.Redeemer[]>> {
    this.#logger.debug('About to find redeemers for transactions with ids:', ids);
    const result: QueryResult<RedeemerModel> = await this.#db.query({
      name: 'tx_redeemers_by_tx_ids',
      text: Queries.findRedeemersByTxIds,
      values: [ids]
    });
    const redeemerMap: TransactionDataMap<Cardano.Redeemer[]> = new Map();
    for (const redeemer of result.rows
      .map(({ id, ...rest }) => ({ id: BigInt(id), ...rest }))
      .sort((a, b) => Number(a.id - b.id))) {
      const txId = redeemer.tx_id.toString('hex') as unknown as Cardano.TransactionId;
      const currentRedeemers = redeemerMap.get(txId) ?? [];
      redeemerMap.set(txId, [...currentRedeemers, mapRedeemer(redeemer)]);
    }
    return redeemerMap;
  }

  public async queryVotingProceduresByIds(ids: string[]): Promise<TransactionDataMap<Cardano.VotingProcedures>> {
    const { rows } = await this.#db.query<VotingProceduresModel>({
      name: 'voting_procedures',
      text: Queries.findVotingProceduresByTxIds,
      values: [ids]
    });

    const result = new Map<Cardano.TransactionId, Cardano.VotingProcedures>();

    for (const row of rows) {
      const { data_hash, governance_action_index, governance_action_tx_id, tx_id, url, vote } = row;
      const txId = tx_id.toString('hex') as Cardano.TransactionId;
      const voter = getVoter(txId, row);

      const procedures = (() => {
        const value = result.get(txId);
        if (value) return value;
        const empty: Cardano.VotingProcedures = [];
        result.set(txId, empty);
        return empty;
      })();

      const procedure = (() => {
        const value = procedures.find(
          ({ voter: { __typename, credential } }) =>
            __typename === voter.__typename && credential.hash === voter.credential.hash
        );
        if (value) return value;
        const newProcedure: Cardano.VotingProcedures[number] = { voter, votes: [] };
        procedures.push(newProcedure);
        return newProcedure;
      })();

      procedure.votes.push({
        actionId: {
          actionIndex: governance_action_index,
          id: governance_action_tx_id.toString('hex') as Cardano.TransactionId
        },
        votingProcedure: { anchor: data_hash ? mapAnchor(url, data_hash.toString('hex')) : null, vote }
      });
    }

    return result;
  }

  public async queryProposalProceduresByIds(ids: string[]): Promise<TransactionDataMap<Cardano.ProposalProcedure[]>> {
    const { rows } = await this.#db.query<ProposalProcedureModel>({
      name: 'proposal_procedures',
      text: Queries.findProposalProceduresByTxIds,
      values: [ids]
    });

    const result = new Map<Cardano.TransactionId, Cardano.ProposalProcedure[]>();

    for (const row of rows) {
      const { data_hash, deposit, description, tx_id, url, view } = row;
      const txId = tx_id.toString('hex') as Cardano.TransactionId;

      const actions = (() => {
        const value = result.get(txId);
        if (value) return value;
        const empty: Cardano.ProposalProcedure[] = [];
        result.set(txId, empty);
        return empty;
      })();

      actions.push({
        anchor: mapAnchor(url, data_hash.toString('hex'))!,
        deposit: BigInt(deposit),
        governanceAction: getGovernanceAction(description),
        rewardAccount: Cardano.RewardAccount(view)
      });
    }

    return result;
  }

  public async queryCertificatesByIds(ids: string[]): Promise<TransactionDataMap<Cardano.Certificate[]>> {
    this.#logger.debug('About to find certificates for transactions with ids:', ids);

    const values = [ids];
    const [
      poolRetireCerts,
      poolRegisterCerts,
      mirCerts,
      stakeCerts,
      delegationCerts,
      drepCerts,
      voteDelegationCerts,
      committeeRegistration,
      committeeDeregistration
    ] = await Promise.all([
      this.#db.query<PoolRetireCertModel>({
        name: 'pool_retire_certs_by_tx_ids',
        text: Queries.findPoolRetireCertsTxIds,
        values
      }),
      this.#db.query<PoolRegisterCertModel>({
        name: 'pool_registration_certs_by_tx_ids',
        text: Queries.findPoolRegisterCertsByTxIds,
        values
      }),
      this.#db.query<MirCertModel>({ name: 'pool_mir_certs_by_tx_ids', text: Queries.findMirCertsByTxIds, values }),
      this.#db.query<StakeCertModel>({
        name: 'pool_stake_certs_by_tx_ids',
        text: Queries.findStakeCertsByTxIds,
        values
      }),
      this.#db.query<DelegationCertModel>({
        name: 'pool_delegation_certs_by_tx_ids',
        text: Queries.findDelegationCertsByTxIds,
        values
      }),
      this.#db.query<DrepCertModel>({ name: 'drep_certs_by_tx_ids', text: Queries.findDrepCertsByTxIds, values }),
      this.#db.query<VoteDelegationCertModel>({
        name: 'vote_delegation_certs_by_tx_ids',
        text: Queries.findVoteDelegationCertsByTxIds,
        values
      }),
      this.#db.query<AuthorizeCommitteeHotCertModel>({
        name: 'committee_register_by_tx_ids',
        text: Queries.findCommitteeRegistrationByTxIds,
        values
      }),
      this.#db.query<ResignCommitteeColdCertModel>({
        name: 'committee_resign_by_tx_ids',
        text: Queries.findCommitteeResignByTxIds,
        values
      })
    ]);

    let stakeCertsArr: StakeCertModel[];
    let delegationCertsArr: DelegationCertModel[];
    let voteDelegationCertsArr: VoteDelegationCertModel[];
    let stakeVoteDelegationCertsArr: StakeVoteDelegationCertModel[];
    let stakeRegistrationDelegationCertsArr: StakeRegistrationDelegationCertModel[];
    let voteRegistrationDelegationCertsArr: VoteRegistrationDelegationCertModel[];
    let stakeVoteRegistrationDelegationCertsArr: StakeVoteRegistrationDelegationCertModel[];

    // eslint-disable-next-line prefer-const
    [delegationCertsArr, stakeCertsArr, stakeRegistrationDelegationCertsArr] = extractCompoundCertificates(
      delegationCerts.rows,
      stakeCerts.rows
    );
    // eslint-disable-next-line prefer-const
    [voteDelegationCertsArr, stakeRegistrationDelegationCertsArr, stakeVoteRegistrationDelegationCertsArr] =
      extractCompoundCertificates(voteDelegationCerts.rows, stakeRegistrationDelegationCertsArr);
    // eslint-disable-next-line prefer-const
    [delegationCertsArr, voteDelegationCertsArr, stakeVoteDelegationCertsArr] = extractCompoundCertificates(
      delegationCertsArr,
      voteDelegationCertsArr
    );
    // eslint-disable-next-line prefer-const
    [stakeCertsArr, voteDelegationCertsArr, voteRegistrationDelegationCertsArr] = extractCompoundCertificates(
      stakeCertsArr,
      voteDelegationCertsArr
    );

    // There is currently no way to get GenesisKeyDelegationCertificate from db-sync
    const allCerts: WithCertType<CertificateModel>[] = [
      ...poolRetireCerts.rows.map((cert): WithCertType<PoolRetireCertModel> => ({ ...cert, type: 'retire' })),
      ...poolRegisterCerts.rows.map((cert): WithCertType<PoolRegisterCertModel> => ({ ...cert, type: 'register' })),
      ...mirCerts.rows.map((cert): WithCertType<MirCertModel> => ({ ...cert, type: 'mir' })),
      ...stakeCertsArr.map((cert): WithCertType<StakeCertModel> => ({ ...cert, type: 'stake' })),
      ...delegationCertsArr.map((cert): WithCertType<DelegationCertModel> => ({ ...cert, type: 'delegation' })),
      ...drepCerts.rows.map(
        ({ deposit, ...cert }): WithCertType<DrepCertModel> => ({
          ...cert,
          ...(deposit === null
            ? { deposit, type: 'updateDrep' }
            : deposit.startsWith('-')
            ? { deposit: deposit.slice(1), type: 'unregisterDrep' }
            : { deposit, type: 'registerDrep' })
        })
      ),
      ...voteDelegationCertsArr.map(
        (cert): WithCertType<VoteDelegationCertModel> => ({ ...cert, type: 'voteDelegation' })
      ),
      ...stakeVoteDelegationCertsArr.map(
        (cert): WithCertType<StakeVoteDelegationCertModel> => ({ ...cert, type: 'stakeVoteDelegation' })
      ),
      ...stakeRegistrationDelegationCertsArr.map(
        (cert): WithCertType<StakeRegistrationDelegationCertModel> => ({ ...cert, type: 'stakeRegistrationDelegation' })
      ),
      ...stakeVoteRegistrationDelegationCertsArr.map(
        (cert): WithCertType<StakeVoteRegistrationDelegationCertModel> => ({
          ...cert,
          type: 'stakeVoteRegistrationDelegation'
        })
      ),
      ...voteRegistrationDelegationCertsArr.map(
        (cert): WithCertType<VoteRegistrationDelegationCertModel> => ({
          ...cert,
          type: 'voteRegistrationDelegation'
        })
      ),
      ...committeeRegistration.rows.map(
        (cert): WithCertType<AuthorizeCommitteeHotCertModel> => ({
          ...cert,
          type: 'authorizeCommitteeHot'
        })
      ),
      ...committeeDeregistration.rows.map(
        (cert): WithCertType<ResignCommitteeColdCertModel> => ({
          ...cert,
          type: 'resignCommitteeCold'
        })
      )
    ];
    if (allCerts.length === 0) return new Map();

    const indexedCertsMap: TransactionDataMap<WithCertIndex<Cardano.Certificate>[]> = new Map();
    for (const cert of allCerts) {
      const txId = cert.tx_id.toString('hex') as unknown as Cardano.TransactionId;
      const currentCerts = indexedCertsMap.get(txId) ?? [];
      const newCert = mapCertificate(cert);
      if (newCert) indexedCertsMap.set(txId, [...currentCerts, newCert]);
    }

    const certsMap: TransactionDataMap<Cardano.Certificate[]> = new Map();
    for (const [txId] of indexedCertsMap) {
      const currentCerts = indexedCertsMap.get(txId) ?? [];
      const certs = orderBy(currentCerts, ['cert_index']).map(
        (cert) => omit(cert, 'cert_index') as Cardano.Certificate
      );
      certsMap.set(txId, certs);
    }
    return certsMap;
  }

  /**
   * Gets the `tx.id` of the transactions interesting the given set of addresses
   *
   * @param addresses the set of addresses to get transactions
   * @param blockRange optional: the block range within transactions are requested
   * @returns the `tx.id` array
   */
  public async queryTxIdsByAddresses(addresses: Cardano.PaymentAddress[], blockRange?: Range<Cardano.BlockNo>) {
    const rangeForQuery: Range<Cardano.BlockNo> | undefined = blockRange
      ? {
          lowerBound: blockRange.lowerBound ?? (0 as Cardano.BlockNo),
          upperBound: blockRange.upperBound ?? (DB_MAX_SAFE_INTEGER as Cardano.BlockNo)
        }
      : undefined;
    const kind = rangeForQuery ? 'withRange' : 'withoutRange';
    const q = findTxsByAddresses;

    const result = await this.#db.query<TxIdModel>({
      name: `tx_ids_by_addresses${rangeForQuery ? '_with_range' : ''}`,
      text: `${q.WITH}${q[kind].WITH}${q.SELECT}${q[kind].FROM}${q.ORDER}`,
      values: rangeForQuery ? [addresses, rangeForQuery.lowerBound, rangeForQuery.upperBound] : [addresses]
    });

    return result.rows.map(mapTxId);
  }
}
