// cSpell:ignore cardano deleg deregistration drep unreg unregistration utxos

import { Cardano, jsonToNativeScript } from '@cardano-sdk/core';
import { Ed25519PublicKeyHex, Ed25519SignatureHex, Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { MetadataDbModel } from '@cardano-sdk/cardano-services-client';
import { Pool } from 'pg';
import { VoterRole } from '../ChainHistory/DbSyncChainHistory/types';
import { getGovernanceAction } from '../ChainHistory';
import { mapAnchor } from '../ChainHistory/DbSyncChainHistory/mappers';

interface ActionModel {
  deposit: string;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  description: any;
  hash: string;
  url: string;
  view: Cardano.RewardAccount;
}

interface OutputModel {
  address: Cardano.PaymentAddress;
  value: string;
  datum: string | null;
  hash: Cardano.DatumHash | null;
  assets: [Cardano.AssetId, string][];
  script: Cardano.Script | { __type: '_native'; json: Object };
}

const redeemerPurposeMap = {
  cert: Cardano.RedeemerPurpose.certificate,
  mint: Cardano.RedeemerPurpose.mint,
  propose: Cardano.RedeemerPurpose.propose,
  reward: Cardano.RedeemerPurpose.withdrawal,
  spend: Cardano.RedeemerPurpose.spend,
  vote: Cardano.RedeemerPurpose.vote
} as const;

interface RedeemerModel {
  index: number;
  purpose: keyof typeof redeemerPurposeMap;
  mem: number;
  steps: number;
}

interface VoteModel {
  role: VoterRole;
  cVoter: Hash28ByteBase16;
  cScript: boolean;
  dVoter: Hash28ByteBase16;
  dScript: boolean;
  pVoter: Hash28ByteBase16;
  vote: Cardano.Vote;
  index: number;
  tx: Cardano.TransactionId;
  url: string;
  hash: string;
}

interface TxModel {
  id: Cardano.TransactionId;
  index: number;
  size: number;
  fee: number;
  before: Cardano.Slot | null;
  hereafter: Cardano.Slot | null;
  valid: boolean;
  block: Cardano.BlockNo;
  hash: Cardano.BlockId;
  slot: Cardano.Slot;
  collateral: OutputModel;
  actions: ActionModel[];
  commRet: [number, Hash28ByteBase16, boolean, string, string][];
  commReg: [number, Hash28ByteBase16, boolean, Hash28ByteBase16, boolean][];
  spRetire: [number, Cardano.EpochNo, Cardano.PoolId][];
  spReg: [number, Cardano.PoolId, number, Cardano.RewardAccount, number, number, number, Cardano.VrfVkHex][];
  deRep: [string | null, number, Cardano.CredentialType, Hash28ByteBase16, string, string][];
  votes: VoteModel[];
  vDele: [number, Cardano.CredentialType, Hash28ByteBase16 | null, string, Cardano.RewardAccount][];
  unReg: [number, number, Cardano.RewardAccount][];
  reg: [number, number, Cardano.RewardAccount][];
  sDele: [number, Cardano.RewardAccount, Cardano.PoolId][];
  mint: [Cardano.AssetId, string][];
  withdrawals: { quantity: string; stakeAddress: Cardano.RewardAccount }[];
  redeemers: RedeemerModel[];
  collaterals: Cardano.HydratedTxIn[];
  metadata: MetadataDbModel[];
  inputs: Cardano.HydratedTxIn[];
  outputs: OutputModel[];
}

/**
 * Transaction Query Builder.
 *
 * Helper class to build the complex query;
 * - avoids some code repetition
 * - helps the read
 * - helps in case of refactoring
 */
class TQB {
  constructor(public query: string) {}

  /** Adds an indentation level to the query to nest it into an outer query. */
  indent() {
    return new TQB(
      this.query
        .split('\n')
        .map((line) => `  ${line}`)
        .join('\n')
    );
  }

  /**
   * Nests this query into an outer query with aggregation.
   *
   * Certificates doesn't need to be ordered as their index is a relevant part to build compound certificates;
   * they are ordered after extracting the compound certificates: that's why the `order` parameter is optional.
   *
   * @param attribute The attribute name of the resulting JSON
   * @param element The element from the row; the ones which will be aggregated into an array
   * @param joins The list of the LEFT JOINs
   * @param order The value used to order the elements in the array
   */
  nest(attribute: string, element: string, joins: string[], order?: string) {
    const leftJoins = joins.map((join) => ` LEFT JOIN ${join}`).join('');
    const orderBy = order ? ` ORDER BY ${order}` : '';

    return new TQB(`\
SELECT tid, JSONB_SET(JSONB_AGG(tx)->0, '{${attribute}}', JSONB_AGG(${element}${orderBy})) AS tx FROM (
${this.indent().query}
) t${leftJoins} GROUP BY tid`);
  }
}

const innerQuery = (collateral: boolean) => `\
SELECT tx.id AS tid, JSON_BUILD_OBJECT(
  'id', ENCODE((ARRAY_AGG(tx.hash))[1], 'hex'),
  'index', (ARRAY_AGG(block_index))[1],
  'size', (ARRAY_AGG(tx.size))[1],
  'fee', (ARRAY_AGG(fee))[1],
  'before', (ARRAY_AGG(invalid_before))[1],
  'hereafter', (ARRAY_AGG(invalid_hereafter))[1],
  'valid', (ARRAY_AGG(valid_contract))[1],
  'block', (ARRAY_AGG(block_no))[1],
  'hash', ENCODE((ARRAY_AGG(b.hash))[1], 'hex'),
  'slot', (ARRAY_AGG(slot_no))[1]${
    collateral
      ? // eslint-disable-next-line sonarjs/no-nested-template-literals
        `,
  'collateral', JSONB_BUILD_OBJECT(
    'address', (ARRAY_AGG(address))[1],
    'value', (ARRAY_AGG(value))[1],
    'hash', ENCODE((ARRAY_AGG(data_hash))[1], 'hex'),
    'assets', JSONB_BUILD_ARRAY(JSONB_BUILD_ARRAY(NULL)),
    'script',  CASE WHEN (ARRAY_AGG(bytes))[1] IS NULL THEN NULL ELSE JSONB_BUILD_OBJECT(
      '__type', 'plutus',
      'bytes', ENCODE((ARRAY_AGG(bytes))[1], 'hex'),
      'version', CASE WHEN (ARRAY_AGG(type))[1] = 'plutusV1' THEN 0 WHEN (ARRAY_AGG(type))[1] = 'plutusV2' THEN 1 ELSE 2 END
    ) END
  )`
      : ''
  }
) AS tx
FROM tx JOIN block b ON tx.block_id = b.id${
  collateral
    ? ' LEFT JOIN collateral_tx_out ON tx_id = tx.id LEFT JOIN script s ON s.id = reference_script_id AND s.bytes IS NOT NULL'
    : ''
} WHERE tx.id = ANY($1) GROUP BY tx.id`;

/* eslint-disable sonarjs/no-duplicate-string */
const tqb = new TQB(innerQuery(true))
  .nest(
    'actions',
    `\
JSONB_BUILD_OBJECT(
  'deposit', deposit::TEXT,
  'description', description,
  'hash', ENCODE(data_hash, 'hex'),
  'url', url,
  'view', view
)`,
    [
      'gov_action_proposal g ON tx_id = tid',
      'voting_anchor v ON voting_anchor_id = v.id',
      'stake_address s ON return_address = s.id'
    ],
    'g.id'
  )
  .nest('commRet', "JSONB_BUILD_ARRAY(cert_index, ENCODE(raw, 'hex'), has_script, url, ENCODE(data_hash, 'hex'))", [
    'committee_de_registration ON tx_id = tid',
    'committee_hash ON cold_key_id = committee_hash.id',
    'voting_anchor ON voting_anchor.id = voting_anchor_id'
  ])
  .nest(
    'commReg',
    "JSONB_BUILD_ARRAY(cert_index, ENCODE(c1.raw, 'hex'), c1.has_script, ENCODE(c2.raw, 'hex'), c2.has_script)",
    [
      'committee_registration ON tx_id = tid',
      'committee_hash AS c1 ON cold_key_id = c1.id',
      'committee_hash AS c2 ON hot_key_id = c2.id'
    ]
  )
  .nest('spRetire', 'JSONB_BUILD_ARRAY(cert_index, retiring_epoch, view)', [
    'pool_retire ON announced_tx_id = tid',
    'pool_hash p ON p.id = hash_id'
  ])
  .nest(
    'spReg',
    `\
JSONB_BUILD_ARRAY(
  cert_index,
  p.view,
  CASE WHEN deposit IS NULL THEN 0 ELSE deposit::INTEGER END,
  s.view,
  pledge,
  fixed_cost,
  margin,
  ENCODE(vrf_key_hash, 'hex')
)`,
    [
      'pool_update ON registered_tx_id = tid',
      'pool_hash p ON p.id = hash_id',
      'stake_address s ON s.id = reward_addr_id'
    ]
  )
  .nest(
    'deRep',
    "JSONB_BUILD_ARRAY(deposit::TEXT, cert_index, CASE WHEN has_script THEN 1 ELSE 0 END, ENCODE(raw, 'hex'), url, ENCODE(data_hash, 'hex'))",
    [
      'drep_registration ON tx_id = tid',
      'drep_hash ON drep_hash.id = drep_hash_id',
      'voting_anchor ON voting_anchor.id = voting_anchor_id'
    ]
  )
  .nest(
    'votes',
    `\
JSONB_BUILD_OBJECT(
  'role', voter_role,
  'cVoter', ENCODE(c.raw, 'hex'),
  'cScript', c.has_script,
  'dVoter', ENCODE(d.raw, 'hex'),
  'dScript', d.has_script,
  'pVoter', ENCODE(p.hash_raw, 'hex'),
  'vote', CASE WHEN vote = 'No' THEN 0 WHEN vote = 'Yes' THEN 1 WHEN vote = 'Abstain' THEN 2 END,
  'index', g.index::INTEGER,
  'tx', ENCODE(hash, 'hex'),
  'url', a.url,
  'hash', ENCODE(a.data_hash, 'hex')
)`,
    [
      'voting_procedure v ON v.tx_id = tid',
      'gov_action_proposal g ON gov_action_proposal_id = g.id',
      'tx ON g.tx_id = tx.id',
      'drep_hash d ON drep_voter = d.id',
      'pool_hash p ON pool_voter = p.id',
      'voting_anchor a ON v.voting_anchor_id = a.id',
      'committee_hash c ON c.id = committee_voter'
    ],
    'v.index'
  )
  .nest(
    'vDele',
    "JSONB_BUILD_ARRAY(cert_index, CASE WHEN has_script THEN 1 ELSE 0 END, ENCODE(raw, 'hex'), drep_hash.view, stake_address.view)",
    [
      'delegation_vote ON tx_id = tid',
      'drep_hash ON drep_hash.id = drep_hash_id',
      'stake_address ON stake_address.id = addr_id'
    ]
  )
  .nest(
    'unReg',
    `\
JSONB_BUILD_ARRAY(cert_index, (
  SELECT sr.deposit FROM stake_registration AS sr
  WHERE sr.addr_id = sd.addr_id AND sr.tx_id < sd.tx_id
  ORDER BY sr.tx_id DESC LIMIT 1
), view)`,
    ['stake_deregistration sd ON tx_id = tid', 'stake_address ON stake_address.id = addr_id']
  )
  .nest('reg', 'JSONB_BUILD_ARRAY(cert_index, deposit, view)', [
    'stake_registration ON tx_id = tid',
    'stake_address ON stake_address.id = addr_id'
  ])
  .nest('sDele', 'JSONB_BUILD_ARRAY(cert_index, addr.view, pool.view)', [
    'delegation ON tx_id = tid',
    'pool_hash AS pool ON pool.id = pool_hash_id',
    'stake_address AS addr ON addr.id = addr_id'
  ])
  .nest(
    'mint',
    "JSONB_BUILD_ARRAY(ENCODE(policy || name, 'hex'), quantity::TEXT)",
    ['ma_tx_mint ON tx_id = tid', 'multi_asset ON ident = multi_asset.id'],
    'ma_tx_mint.id'
  )
  .nest(
    'withdrawals',
    "JSONB_BUILD_OBJECT('quantity', amount::TEXT, 'stakeAddress', view)",
    ['withdrawal ON tx_id = tid', 'stake_address ON stake_address.id = addr_id'],
    'withdrawal.id'
  )
  .nest(
    'redeemers',
    "JSONB_BUILD_OBJECT('index', index, 'purpose', purpose, 'mem', unit_mem, 'steps', unit_steps)",
    ['redeemer ON tx_id = tid'],
    'id'
  )
  .nest(
    'collaterals',
    "JSONB_BUILD_OBJECT('address', address, 'txId', ENCODE(hash, 'hex'), 'index', index)",
    [
      'collateral_tx_in c ON tx_in_id = tid',
      'tx_out ON tx_out_id = tx_id AND tx_out_index = index',
      'tx ON tx_id = tx.id'
    ],
    'c.id'
  )
  .nest(
    'metadata',
    "JSONB_BUILD_ARRAY(key::TEXT, ENCODE(bytes, 'hex'))",
    ['tx_metadata ON tx_metadata.tx_id = tid'],
    'id'
  );
/* eslint-enable sonarjs/no-duplicate-string */

const buildQuery = (qb: TQB) => `\
SELECT tid, JSONB_SET(JSONB_AGG(tx)->0, '{outputs}', JSONB_AGG(out ORDER BY oid)) AS tx FROM (
  SELECT tid, JSONB_AGG(tx)->0 AS tx, o.id AS oid, JSONB_BUILD_OBJECT(
    'address', o.address,
    'value', o.value::TEXT,
    'datum', ENCODE((ARRAY_AGG(d.bytes))[1], 'hex'),
    'hash', ENCODE(o.data_hash, 'hex'),
    'assets', JSONB_AGG(JSONB_BUILD_ARRAY(ENCODE(policy || name, 'hex'), quantity::TEXT) ORDER BY m.id),
    'script',  CASE WHEN (ARRAY_AGG(s.json))[1] IS NOT NULL THEN JSONB_BUILD_OBJECT(
      '__type', '_native',
      'json', (ARRAY_AGG(s.json))[1]
    ) WHEN (ARRAY_AGG(s.bytes))[1] IS NOT NULL THEN JSONB_BUILD_OBJECT(
      '__type', 'plutus',
      'bytes', ENCODE((ARRAY_AGG(s.bytes))[1], 'hex'),
      'version', CASE WHEN (ARRAY_AGG(type))[1] = 'plutusV1' THEN 0 WHEN (ARRAY_AGG(type))[1] = 'plutusV2' THEN 1 ELSE 2 END
    ) ELSE NULL END
  ) AS out FROM (
${
  qb
    .nest(
      'inputs',
      "JSONB_BUILD_OBJECT('address', address, 'txId', ENCODE(hash, 'hex'), 'index', index)",
      ['tx_in ON tx_in_id = tid', 'tx_out ON tx_out_id = tx_id AND tx_out_index = index', 'tx ON tx_id = tx.id'],
      'tx_in.id'
    )
    .indent()
    .indent().query
}
  ) t LEFT JOIN tx_out o ON o.tx_id = tid LEFT JOIN ma_tx_out m ON m.tx_out_id = o.id LEFT JOIN multi_asset a ON m.ident = a.id
  LEFT JOIN script s ON s.id = reference_script_id LEFT JOIN datum d ON d.id = inline_datum_id GROUP BY tid, o.id
) t GROUP BY tid`;

const getTransactions = buildQuery(tqb);
const getUtxos = buildQuery(new TQB(innerQuery(false)));

const mapActions = (actions: ActionModel[]) =>
  actions[0].description
    ? actions.map(({ deposit, description, hash, url, view }) => ({
        anchor: mapAnchor(url, hash)!,
        deposit: BigInt(deposit),
        governanceAction: getGovernanceAction(description),
        rewardAccount: view
      }))
    : undefined;

const mapAsset = (asset: [Cardano.AssetId, string]) => [asset[0], BigInt(asset[1])] as const;

/**
 * Extracts the _compound certificates_ from two lists of _base certificates_.
 * This is required because **db-sync** stores _compound certificates_ splitting them in _base certificate records_.
 *
 * As an example:
 *
 * `stake_vote_deleg_cert` certificates are stored as a `stake_delegation` certificate record plus a `vote_deleg_cert`
 * certificate record splitting `stake_vote_deleg_cert` properties: the `pool_keyhash` is stored in the first record
 * and the `drep` is stored in the latter record.
 *
 * To make the lower amount of queries as possible, we perform one single query on each certificate table, next we use
 * this function to merge them results.
 *
 * @param certs1 The first list _base certificates_.
 * @param certs2 The second list of _base certificates_.
 * @param merge The function to merge two _base certificates_ into a _compound certificate_.
 * @returns The two lists of _base certificates_ (pruned by the ones used to create the _compound certificates_) and the list of _compound certificates_.
 */
const compound = <
  C1 extends Cardano.HydratedCertificate,
  C2 extends Cardano.HydratedCertificate,
  C3 extends Cardano.HydratedCertificate
>(
  certs1: (readonly [number, C1])[],
  certs2: (readonly [number, C2])[],
  merge: (c1: C1, c2: C2) => C3
) => {
  const result1: (readonly [number, C1])[] = [];
  const result: (readonly [number, C3])[] = [];
  const foundIndexes2: number[] = [];

  // Iterate over certificates in the first list.
  for (const c1 of certs1) {
    // Check if in the second list there is a certificate with the same certificate index: i.e. they are two sources of the same _compound certificate_.
    const c2index = certs2.findIndex((c2) => c1[0] === c2[0]);

    // In negative case, push the certificate from the first list in the return first list.
    if (c2index === -1) result1.push(c1);
    // In affirmative case, push the merged certificate in the return merged list.
    else {
      foundIndexes2.push(c2index);
      result.push([c1[0], merge(c1[1], certs2[c2index][1])]);
    }
  }

  // Finally create the return second list filtering the second list from the ones used to create the return merged list.
  const result2 = certs2.filter((_, c2index) => !foundIndexes2.includes(c2index));

  return [result1, result2, result] as const;
};

// eslint-disable-next-line complexity, max-statements, sonarjs/cognitive-complexity
const mapCertificates = (tx: TxModel) => {
  const { deRep, reg, sDele, unReg, vDele, spReg, spRetire, commReg, commRet } = tx;
  const result: Cardano.HydratedCertificate[] = [];

  let sRegDel: (readonly [number, Cardano.StakeRegistrationDelegationCertificate])[];
  let sVotRegDel: (readonly [number, Cardano.StakeVoteRegistrationDelegationCertificate])[];
  let sVotDel: (readonly [number, Cardano.StakeVoteDelegationCertificate])[];
  let vRegDel: (readonly [number, Cardano.VoteRegistrationDelegationCertificate])[];

  const mapStakeReg = (cert: TxModel['reg'][number]) => ({
    __typename: Cardano.CertificateType.Registration as const,
    deposit: BigInt(cert[1]),
    stakeCredential: Cardano.Address.fromBech32(cert[2]).asReward()!.getPaymentCredential()
  });
  let sReg = (reg[0][2] ? reg : []).map((cert) => [cert[0], mapStakeReg(cert)] as const);

  const mapStakeDeleg = (cert: TxModel['sDele'][number]) => ({
    __typename: Cardano.CertificateType.StakeDelegation as const,
    poolId: cert[2],
    stakeCredential: Cardano.Address.fromBech32(cert[1]).asReward()!.getPaymentCredential()
  });
  let sDel = (sDele[0][1] ? sDele : []).map((cert) => [cert[0], mapStakeDeleg(cert)] as const);

  const mapVoteDeleg = (cert: TxModel['vDele'][number]) => ({
    __typename: Cardano.CertificateType.VoteDelegation as const,
    dRep: (cert[2]
      ? { hash: cert[2], type: cert[1] }
      : cert[3] === 'drep_always_abstain'
      ? { __typename: 'AlwaysAbstain' }
      : { __typename: 'AlwaysNoConfidence' }) as Cardano.DelegateRepresentative,
    stakeCredential: Cardano.Address.fromBech32(cert[4]).asReward()!.getPaymentCredential()
  });
  let vDel = (vDele[0][0] !== null ? vDele : []).map((cert) => [cert[0], mapVoteDeleg(cert)] as const);

  [sDel, sReg, sRegDel] = compound(sDel, sReg, ({ poolId }, { deposit, stakeCredential }) => ({
    __typename: Cardano.CertificateType.StakeRegistrationDelegation,
    deposit,
    poolId,
    stakeCredential
  }));

  // eslint-disable-next-line prefer-const
  [vDel, sRegDel, sVotRegDel] = compound(vDel, sRegDel, ({ dRep, stakeCredential }, { poolId, deposit }) => ({
    __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
    dRep,
    deposit,
    poolId,
    stakeCredential
  }));

  // eslint-disable-next-line prefer-const
  [sDel, vDel, sVotDel] = compound(sDel, vDel, ({ poolId }, { dRep, stakeCredential }) => ({
    __typename: Cardano.CertificateType.StakeVoteDelegation,
    dRep,
    poolId,
    stakeCredential
  }));

  // eslint-disable-next-line prefer-const
  [sReg, vDel, vRegDel] = compound(sReg, vDel, ({ deposit }, { dRep, stakeCredential }) => ({
    __typename: Cardano.CertificateType.VoteRegistrationDelegation,
    dRep,
    deposit,
    stakeCredential
  }));

  for (const cert of sReg) result[cert[0]] = cert[1];
  for (const cert of sDel) result[cert[0]] = cert[1];
  for (const cert of vDel) result[cert[0]] = cert[1];
  for (const cert of sRegDel) result[cert[0]] = cert[1];
  for (const cert of sVotDel) result[cert[0]] = cert[1];
  for (const cert of vRegDel) result[cert[0]] = cert[1];
  for (const cert of sVotRegDel) result[cert[0]] = cert[1];

  if (unReg[0][2])
    for (const cert of unReg)
      result[cert[0]] = {
        __typename: Cardano.CertificateType.Unregistration as const,
        deposit: BigInt(cert[1]),
        stakeCredential: Cardano.Address.fromBech32(cert[2]).asReward()!.getPaymentCredential()
      };

  if (deRep[0][3])
    for (const [dep, ...cert] of deRep) {
      const update = dep === null;
      const unreg = !update && dep.startsWith('-');
      const deposit = BigInt(update ? 0 : unreg ? dep.slice(1) : dep);
      const anchor = mapAnchor(cert[3], cert[4]);

      result[cert[0]] = {
        ...(update
          ? { __typename: Cardano.CertificateType.UpdateDelegateRepresentative as const, anchor }
          : unreg
          ? { __typename: Cardano.CertificateType.UnregisterDelegateRepresentative as const, deposit }
          : { __typename: Cardano.CertificateType.RegisterDelegateRepresentative as const, anchor, deposit }),
        dRepCredential: { hash: cert[2], type: cert[1] }
      };
    }

  if (spReg[0][1])
    for (const cert of spReg)
      result[cert[0]] = {
        __typename: Cardano.CertificateType.PoolRegistration as const,
        deposit: BigInt(cert[2]),
        poolParameters: {
          cost: BigInt(cert[5]),
          id: cert[1],
          margin: Cardano.FractionUtils.toFraction(cert[6]),
          owners: [],
          pledge: BigInt(cert[4]),
          relays: [],
          rewardAccount: cert[3],
          vrf: cert[7]
        }
      };

  if (spRetire[0][2])
    for (const cert of spRetire)
      result[cert[0]] = {
        __typename: Cardano.CertificateType.PoolRetirement as const,
        epoch: cert[1],
        poolId: cert[2]
      };

  const getCredentialType = (hasScript: boolean) =>
    hasScript ? Cardano.CredentialType.ScriptHash : Cardano.CredentialType.KeyHash;

  if (commReg[0][1])
    for (const cert of commReg)
      result[cert[0]] = {
        __typename: Cardano.CertificateType.AuthorizeCommitteeHot,
        coldCredential: { hash: cert[1], type: getCredentialType(cert[2]) },
        hotCredential: { hash: cert[3], type: getCredentialType(cert[4]) }
      };

  if (commRet[0][1])
    for (const cert of commRet)
      result[cert[0]] = {
        __typename: Cardano.CertificateType.ResignCommitteeCold,
        anchor: mapAnchor(cert[3], cert[4]),
        coldCredential: { hash: cert[1], type: getCredentialType(cert[2]) }
      };

  return result.length > 0 ? result : undefined;
};

const mapOutput = (output: OutputModel) => {
  const assets = output.assets[0][0] ? new Map(output.assets.map(mapAsset)) : undefined;
  const result: Cardano.TxOut = {
    address: output.address,
    value: { coins: BigInt(output.value) }
  };

  if (assets) result.value.assets = assets;
  // Let's do this forcing to perform the deserialization on client side
  if (output.datum) result.datum = output.datum as unknown as Cardano.PlutusData;
  if (output.hash) result.datumHash = output.hash;
  if (output.script)
    result.scriptReference =
      output.script.__type === '_native' ? jsonToNativeScript(output.script.json) : output.script;

  return result;
};

// TODO: unfortunately this is not nullable and not implemented.
// Remove this and select the actual redeemer data from `redeemer_data` table.
const stubRedeemerData = Buffer.from('not implemented');

const mapRedeemer = (redeemer: RedeemerModel): Cardano.Redeemer => ({
  data: stubRedeemerData,
  executionUnits: { memory: redeemer.mem, steps: redeemer.steps },
  index: redeemer.index,
  purpose: redeemerPurposeMap[redeemer.purpose]
});

export const mapVoter = ({ role, cVoter, cScript, dVoter, dScript, pVoter }: VoteModel): Cardano.Voter => {
  switch (role) {
    case 'ConstitutionalCommittee':
      return cScript
        ? {
            __typename: Cardano.VoterType.ccHotScriptHash,
            credential: { hash: cVoter, type: Cardano.CredentialType.ScriptHash }
          }
        : {
            __typename: Cardano.VoterType.ccHotKeyHash,
            credential: { hash: cVoter, type: Cardano.CredentialType.KeyHash }
          };

    case 'DRep':
      return dScript
        ? {
            __typename: Cardano.VoterType.dRepScriptHash,
            credential: { hash: dVoter, type: Cardano.CredentialType.ScriptHash }
          }
        : {
            __typename: Cardano.VoterType.dRepKeyHash,
            credential: { hash: dVoter, type: Cardano.CredentialType.KeyHash }
          };

    case 'SPO':
      return {
        __typename: Cardano.VoterType.stakePoolKeyHash,
        credential: { hash: pVoter, type: Cardano.CredentialType.KeyHash }
      };
  }
};

const mapVotes = (votes: VoteModel[]): Cardano.VotingProcedures => {
  const procedures: Cardano.VotingProcedures = [];
  let lastStringified = '';
  let lastVotes: Cardano.VotingProcedureVote[] = [];

  for (const vote of votes) {
    const voter = mapVoter(vote);
    const stringified = JSON.stringify(voter);
    const procedure: Cardano.VotingProcedureVote = {
      actionId: { actionIndex: vote.index, id: vote.tx },
      votingProcedure: { anchor: vote.url ? mapAnchor(vote.url, vote.hash) : null, vote: vote.vote }
    };

    if (stringified !== lastStringified) {
      lastStringified = stringified;
      procedures.push({ voter, votes: (lastVotes = [procedure]) });
    } else lastVotes.push(procedure);
  }

  return procedures;
};

const mapWithdrawals = (withdrawals: TxModel['withdrawals']) =>
  withdrawals[0].stakeAddress
    ? (withdrawals || []).map(({ quantity, stakeAddress }) => ({
        quantity: BigInt(quantity),
        stakeAddress
      }))
    : undefined;

const signatures = new Map<Ed25519PublicKeyHex, Ed25519SignatureHex>();

// eslint-disable-next-line complexity
const mapTx = (tx: TxModel): Cardano.HydratedTx => {
  const collateralReturn = tx.collateral.address ? mapOutput(tx.collateral) : undefined;
  const collaterals = tx.collaterals[0].txId ? tx.collaterals : [];
  const fee = BigInt(tx.fee);
  const inputs = tx.inputs[0].address ? tx.inputs : [];
  const outputs = tx.outputs[0].address ? tx.outputs.map(mapOutput) : [];

  return {
    // Let's do this forcing to perform the deserialization on client side
    auxiliaryData: tx.metadata[0][1] ? (tx.metadata as unknown as Cardano.AuxiliaryData) : undefined,
    blockHeader: { blockNo: tx.block, hash: tx.hash, slot: tx.slot },
    body: {
      ...(tx.valid
        ? { collateralReturn, collaterals, fee, inputs, outputs }
        : {
            collateralReturn: outputs[0],
            collaterals: inputs,
            fee: 0n,
            inputs: [],
            outputs: [],
            totalCollateral: fee
          }),
      certificates: mapCertificates(tx),
      mint: tx.mint[0][0] ? new Map(tx.mint.map(mapAsset)) : undefined,
      proposalProcedures: mapActions(tx.actions),
      validityInterval: { invalidBefore: tx.before || undefined, invalidHereafter: tx.hereafter || undefined },
      votingProcedures: tx.votes[0].role ? mapVotes(tx.votes) : undefined,
      withdrawals: mapWithdrawals(tx.withdrawals)
    },
    id: tx.id,
    index: tx.index,
    inputSource: tx.valid ? Cardano.InputSource.inputs : Cardano.InputSource.collaterals,
    txSize: tx.size,
    witness: { redeemers: tx.redeemers[0].purpose ? tx.redeemers.map(mapRedeemer) : undefined, signatures }
  };
};

const actions = [{}] as ActionModel[];
const collateral = {} as OutputModel;
const collaterals = [{}] as Cardano.HydratedTxIn[];
const commReg = [[]] as unknown as TxModel['commReg'];
const commRet = [[]] as unknown as TxModel['commRet'];
const deRep = [[]] as unknown as TxModel['deRep'];
const metadata = [[]] as unknown as MetadataDbModel[];
const mint = [[]] as unknown as TxModel['mint'];
const redeemers = [{}] as RedeemerModel[];
const reg = [[]] as unknown as TxModel['reg'];
const sDele = [[]] as unknown as TxModel['sDele'];
const spReg = [[]] as unknown as TxModel['spReg'];
const spRetire = [[]] as unknown as TxModel['spRetire'];
const unReg = [[]] as unknown as TxModel['unReg'];
const vDele = [[null]] as unknown as TxModel['vDele'];
const votes = [{}] as VoteModel[];
const withdrawals = [{}] as TxModel['withdrawals'];

export const transactionsByIds = async (ids: string[], db: Pool) => {
  const { rows } = await db.query<{ tx: TxModel }>({ name: 'get_txs', text: getTransactions, values: [ids] });

  return rows.map(({ tx }) => mapTx(tx));
};

export const partialTransactionsByIds = async (ids: string[], db: Pool) => {
  const { rows } = await db.query<{ tx: TxModel }>({ name: 'get_utxos', text: getUtxos, values: [ids] });

  return rows
    .map(({ tx }) => ({
      tx: {
        ...tx,
        actions,
        collateral,
        collaterals,
        commReg,
        commRet,
        deRep,
        metadata,
        mint,
        redeemers,
        reg,
        sDele,
        spReg,
        spRetire,
        unReg,
        vDele,
        votes,
        withdrawals
      }
    }))
    .map(({ tx }) => mapTx(tx));
};
