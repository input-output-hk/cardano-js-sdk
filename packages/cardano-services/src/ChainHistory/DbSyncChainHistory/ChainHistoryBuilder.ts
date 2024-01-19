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
  StakeCertModel,
  StakeRegistrationDelegationCertModel,
  StakeVoteDelegationCertModel,
  StakeVoteRegistrationDelegationCertModel,
  TransactionDataMap,
  TxIdModel,
  TxInput,
  TxInputModel,
  TxOutMultiAssetModel,
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
import { Cardano } from '@cardano-sdk/core';
import { DB_MAX_SAFE_INTEGER, findTxsByAddresses } from './queries';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { Logger } from 'ts-log';
import { Pool, QueryResult } from 'pg';
import { Range, hexStringToBuffer } from '@cardano-sdk/util';
import { extractCompoundCertificates } from './util';
import {
  mapAnchor,
  mapCertificate,
  mapRedeemer,
  mapTxId,
  mapTxInModel,
  mapTxOutModel,
  mapTxOutTokenMap,
  mapTxTokenMap,
  mapWithdrawal
} from './mappers';
import omit from 'lodash/omit';
import orderBy from 'lodash/orderBy';

const { CredentialType, GovernanceActionType, VoterType } = Cardano;

const getGovernanceAction = ({ description, type }: ProposalProcedureModel): Cardano.GovernanceAction => {
  // Once db-sync includes https://github.com/input-output-hk/cardano-db-sync/issues/1553
  // remove 'as Cardano.*' from return statements to get advantage from types
  switch (type) {
    case 'HardForkInitiation':
      return { __typename: GovernanceActionType.hard_fork_initiation_action } as Cardano.HardForkInitiationAction;
    case 'InfoAction':
      return { __typename: GovernanceActionType.info_action };
    case 'NewCommittee':
      return { __typename: GovernanceActionType.update_committee } as Cardano.UpdateCommittee;
    case 'NewConstitution':
      return { __typename: GovernanceActionType.new_constitution } as Cardano.NewConstitution;
    case 'NoConfidence':
      return { __typename: GovernanceActionType.no_confidence } as Cardano.NoConfidence;
    case 'ParameterChange':
      return { __typename: GovernanceActionType.parameter_change_action } as Cardano.ParameterChangeAction;
    case 'TreasuryWithdrawals':
      return { __typename: GovernanceActionType.treasury_withdrawals_action } as Cardano.TreasuryWithdrawalsAction;
  }

  throw new Error(`Unknown GovernanceActionType '${type}' with description "${description}"`);
};

const getVoter = (
  txId: Cardano.TransactionId,
  { committee_voter, drep_has_script, drep_voter, pool_voter, voter_role }: VotingProceduresModel
): Cardano.Voter => {
  let hash: Hash28ByteBase16;

  switch (voter_role) {
    case 'ConstitutionalCommittee':
      if (!(committee_voter instanceof Buffer)) throw new Error(`Unexpected committee_voter for tx "${txId}"`);

      hash = committee_voter.toString('hex') as Hash28ByteBase16;

      // With current db-sync version it is not possible to distinguish type between
      // CredentialType.ScriptHash and CredentialType.KeyHash
      // Once https://github.com/input-output-hk/cardano-db-sync/issues/1571 it will be included in db-sync
      // we should probably improve the query and following statement as well
      return { __typename: VoterType.ccHotKeyHash, credential: { hash, type: CredentialType.KeyHash } };

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
      name: `tx_${collateral ? 'collateral' : 'inputs'}_by_tx_ids`,
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

  public async queryTransactionOutputsByIds(ids: string[]): Promise<TxOutput[]> {
    this.#logger.debug('About to find outputs for transactions with ids:', ids);
    const result: QueryResult<TxOutputModel> = await this.#db.query({
      name: 'tx_outputs_by_tx_ids',
      text: Queries.findTxOutputsByIds,
      values: [ids]
    });
    if (result.rows.length === 0) return [];

    const txOutIds = result.rows.flatMap((txOut) => BigInt(txOut.id));
    const multiAssets = await this.queryMultiAssetsByTxOut(txOutIds);
    return result.rows.map((txOut) => mapTxOutModel(txOut, multiAssets.get(txOut.id)));
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
    for (const redeemer of result.rows) {
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

    this.#logger.fatal(rows);

    const result = new Map<Cardano.TransactionId, Cardano.ProposalProcedure[]>();

    for (const row of rows) {
      const { data_hash, deposit, tx_id, url, view } = row;
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
        governanceAction: getGovernanceAction(row),
        rewardAccount: Cardano.RewardAccount(view)
      });
    }

    return result;
  }

  public async queryCertificatesByIds(ids: string[]): Promise<TransactionDataMap<Cardano.CertificatePostConway[]>> {
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
        (cert): WithCertType<DrepCertModel> => ({
          ...cert,
          type: cert.deposit === null ? 'updateDrep' : BigInt(cert.deposit) >= 0n ? 'registerDrep' : 'unregisterDrep'
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

    const indexedCertsMap: TransactionDataMap<WithCertIndex<Cardano.CertificatePostConway>[]> = new Map();
    for (const cert of allCerts) {
      const txId = cert.tx_id.toString('hex') as unknown as Cardano.TransactionId;
      const currentCerts = indexedCertsMap.get(txId) ?? [];
      const newCert = mapCertificate(cert);
      if (newCert) indexedCertsMap.set(txId, [...currentCerts, newCert]);
    }

    const certsMap: TransactionDataMap<Cardano.CertificatePostConway[]> = new Map();
    for (const [txId] of indexedCertsMap) {
      const currentCerts = indexedCertsMap.get(txId) ?? [];
      const certs = orderBy(currentCerts, ['cert_index']).map(
        (cert) => omit(cert, 'cert_index') as Cardano.CertificatePostConway
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
