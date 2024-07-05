--
-- PostgreSQL database dump
--

-- Dumped from database version 12.16
-- Dumped by pg_dump version 12.16

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: cexplorer; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE cexplorer WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE cexplorer OWNER TO postgres;

\connect cexplorer

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: addr29type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.addr29type AS bytea;


ALTER DOMAIN public.addr29type OWNER TO postgres;

--
-- Name: asset32type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.asset32type AS bytea;


ALTER DOMAIN public.asset32type OWNER TO postgres;

--
-- Name: govactiontype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.govactiontype AS ENUM (
    'ParameterChange',
    'HardForkInitiation',
    'TreasuryWithdrawals',
    'NoConfidence',
    'NewCommittee',
    'NewConstitution',
    'InfoAction'
);


ALTER TYPE public.govactiontype OWNER TO postgres;

--
-- Name: hash28type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.hash28type AS bytea;


ALTER DOMAIN public.hash28type OWNER TO postgres;

--
-- Name: hash32type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.hash32type AS bytea;


ALTER DOMAIN public.hash32type OWNER TO postgres;

--
-- Name: int65type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.int65type AS numeric(20,0);


ALTER DOMAIN public.int65type OWNER TO postgres;

--
-- Name: lovelace; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.lovelace AS numeric(20,0);


ALTER DOMAIN public.lovelace OWNER TO postgres;

--
-- Name: word128type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.word128type AS numeric(39,0);


ALTER DOMAIN public.word128type OWNER TO postgres;

--
-- Name: outsum; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.outsum AS public.word128type;


ALTER DOMAIN public.outsum OWNER TO postgres;

--
-- Name: rewardtype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.rewardtype AS ENUM (
    'leader',
    'member',
    'reserves',
    'treasury',
    'refund'
);


ALTER TYPE public.rewardtype OWNER TO postgres;

--
-- Name: scriptpurposetype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.scriptpurposetype AS ENUM (
    'spend',
    'mint',
    'cert',
    'reward'
);


ALTER TYPE public.scriptpurposetype OWNER TO postgres;

--
-- Name: scripttype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.scripttype AS ENUM (
    'multisig',
    'timelock',
    'plutusV1',
    'plutusV2',
    'plutusV3'
);


ALTER TYPE public.scripttype OWNER TO postgres;

--
-- Name: syncstatetype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.syncstatetype AS ENUM (
    'lagging',
    'following'
);


ALTER TYPE public.syncstatetype OWNER TO postgres;

--
-- Name: txindex; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.txindex AS smallint;


ALTER DOMAIN public.txindex OWNER TO postgres;

--
-- Name: vote; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.vote AS ENUM (
    'Yes',
    'No',
    'Abstain'
);


ALTER TYPE public.vote OWNER TO postgres;

--
-- Name: voterrole; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.voterrole AS ENUM (
    'ConstitutionalCommittee',
    'DRep',
    'SPO'
);


ALTER TYPE public.voterrole OWNER TO postgres;

--
-- Name: word31type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.word31type AS integer;


ALTER DOMAIN public.word31type OWNER TO postgres;

--
-- Name: word63type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.word63type AS bigint;


ALTER DOMAIN public.word63type OWNER TO postgres;

--
-- Name: word64type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.word64type AS numeric(20,0);


ALTER DOMAIN public.word64type OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ada_pots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ada_pots (
    id bigint NOT NULL,
    slot_no public.word63type NOT NULL,
    epoch_no public.word31type NOT NULL,
    treasury public.lovelace NOT NULL,
    reserves public.lovelace NOT NULL,
    rewards public.lovelace NOT NULL,
    utxo public.lovelace NOT NULL,
    deposits public.lovelace NOT NULL,
    fees public.lovelace NOT NULL,
    block_id bigint NOT NULL
);


ALTER TABLE public.ada_pots OWNER TO postgres;

--
-- Name: ada_pots_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ada_pots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ada_pots_id_seq OWNER TO postgres;

--
-- Name: ada_pots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ada_pots_id_seq OWNED BY public.ada_pots.id;


--
-- Name: block; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.block (
    id bigint NOT NULL,
    hash public.hash32type NOT NULL,
    epoch_no public.word31type,
    slot_no public.word63type,
    epoch_slot_no public.word31type,
    block_no public.word31type,
    previous_id bigint,
    slot_leader_id bigint NOT NULL,
    size public.word31type NOT NULL,
    "time" timestamp without time zone NOT NULL,
    tx_count bigint NOT NULL,
    proto_major public.word31type NOT NULL,
    proto_minor public.word31type NOT NULL,
    vrf_key character varying,
    op_cert public.hash32type,
    op_cert_counter public.word63type
);


ALTER TABLE public.block OWNER TO postgres;

--
-- Name: block_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.block_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.block_id_seq OWNER TO postgres;

--
-- Name: block_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.block_id_seq OWNED BY public.block.id;


--
-- Name: collateral_tx_in; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collateral_tx_in (
    id bigint NOT NULL,
    tx_in_id bigint NOT NULL,
    tx_out_id bigint NOT NULL,
    tx_out_index public.txindex NOT NULL
);


ALTER TABLE public.collateral_tx_in OWNER TO postgres;

--
-- Name: collateral_tx_in_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collateral_tx_in_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.collateral_tx_in_id_seq OWNER TO postgres;

--
-- Name: collateral_tx_in_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collateral_tx_in_id_seq OWNED BY public.collateral_tx_in.id;


--
-- Name: collateral_tx_out; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collateral_tx_out (
    id bigint NOT NULL,
    tx_id bigint NOT NULL,
    index public.txindex NOT NULL,
    address character varying NOT NULL,
    address_has_script boolean NOT NULL,
    payment_cred public.hash28type,
    stake_address_id bigint,
    value public.lovelace NOT NULL,
    data_hash public.hash32type,
    multi_assets_descr character varying NOT NULL,
    inline_datum_id bigint,
    reference_script_id bigint
);


ALTER TABLE public.collateral_tx_out OWNER TO postgres;

--
-- Name: collateral_tx_out_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collateral_tx_out_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.collateral_tx_out_id_seq OWNER TO postgres;

--
-- Name: collateral_tx_out_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collateral_tx_out_id_seq OWNED BY public.collateral_tx_out.id;


--
-- Name: committee_de_registration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.committee_de_registration (
    id bigint NOT NULL,
    tx_id bigint NOT NULL,
    cert_index integer NOT NULL,
    cold_key public.hash28type NOT NULL,
    voting_anchor_id bigint
);


ALTER TABLE public.committee_de_registration OWNER TO postgres;

--
-- Name: committee_de_registration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.committee_de_registration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.committee_de_registration_id_seq OWNER TO postgres;

--
-- Name: committee_de_registration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.committee_de_registration_id_seq OWNED BY public.committee_de_registration.id;


--
-- Name: committee_registration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.committee_registration (
    id bigint NOT NULL,
    tx_id bigint NOT NULL,
    cert_index integer NOT NULL,
    cold_key public.hash28type NOT NULL,
    hot_key public.hash28type NOT NULL
);


ALTER TABLE public.committee_registration OWNER TO postgres;

--
-- Name: committee_registration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.committee_registration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.committee_registration_id_seq OWNER TO postgres;

--
-- Name: committee_registration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.committee_registration_id_seq OWNED BY public.committee_registration.id;


--
-- Name: constitution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.constitution (
    id bigint NOT NULL,
    gov_action_proposal_id bigint NOT NULL,
    voting_anchor_id bigint NOT NULL,
    script_hash public.hash28type
);


ALTER TABLE public.constitution OWNER TO postgres;

--
-- Name: constitution_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.constitution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.constitution_id_seq OWNER TO postgres;

--
-- Name: constitution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.constitution_id_seq OWNED BY public.constitution.id;


--
-- Name: cost_model; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cost_model (
    id bigint NOT NULL,
    costs jsonb NOT NULL,
    hash public.hash32type NOT NULL
);


ALTER TABLE public.cost_model OWNER TO postgres;

--
-- Name: cost_model_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cost_model_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cost_model_id_seq OWNER TO postgres;

--
-- Name: cost_model_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cost_model_id_seq OWNED BY public.cost_model.id;


--
-- Name: datum; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.datum (
    id bigint NOT NULL,
    hash public.hash32type NOT NULL,
    tx_id bigint NOT NULL,
    value jsonb,
    bytes bytea NOT NULL
);


ALTER TABLE public.datum OWNER TO postgres;

--
-- Name: datum_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.datum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.datum_id_seq OWNER TO postgres;

--
-- Name: datum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.datum_id_seq OWNED BY public.datum.id;


--
-- Name: delegation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.delegation (
    id bigint NOT NULL,
    addr_id bigint NOT NULL,
    cert_index integer NOT NULL,
    pool_hash_id bigint NOT NULL,
    active_epoch_no bigint NOT NULL,
    tx_id bigint NOT NULL,
    slot_no public.word63type NOT NULL,
    redeemer_id bigint
);


ALTER TABLE public.delegation OWNER TO postgres;

--
-- Name: delegation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.delegation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.delegation_id_seq OWNER TO postgres;

--
-- Name: delegation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.delegation_id_seq OWNED BY public.delegation.id;


--
-- Name: delegation_vote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.delegation_vote (
    id bigint NOT NULL,
    addr_id bigint NOT NULL,
    cert_index integer NOT NULL,
    drep_hash_id bigint NOT NULL,
    tx_id bigint NOT NULL,
    redeemer_id bigint
);


ALTER TABLE public.delegation_vote OWNER TO postgres;

--
-- Name: delegation_vote_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.delegation_vote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.delegation_vote_id_seq OWNER TO postgres;

--
-- Name: delegation_vote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.delegation_vote_id_seq OWNED BY public.delegation_vote.id;


--
-- Name: delisted_pool; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.delisted_pool (
    id bigint NOT NULL,
    hash_raw public.hash28type NOT NULL
);


ALTER TABLE public.delisted_pool OWNER TO postgres;

--
-- Name: delisted_pool_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.delisted_pool_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.delisted_pool_id_seq OWNER TO postgres;

--
-- Name: delisted_pool_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.delisted_pool_id_seq OWNED BY public.delisted_pool.id;


--
-- Name: drep_distr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drep_distr (
    id bigint NOT NULL,
    hash_id bigint NOT NULL,
    amount bigint NOT NULL,
    epoch_no public.word31type NOT NULL,
    active_until public.word31type
);


ALTER TABLE public.drep_distr OWNER TO postgres;

--
-- Name: drep_distr_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.drep_distr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.drep_distr_id_seq OWNER TO postgres;

--
-- Name: drep_distr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.drep_distr_id_seq OWNED BY public.drep_distr.id;


--
-- Name: drep_hash; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drep_hash (
    id bigint NOT NULL,
    raw public.hash28type,
    view character varying NOT NULL,
    has_script boolean NOT NULL
);


ALTER TABLE public.drep_hash OWNER TO postgres;

--
-- Name: drep_hash_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.drep_hash_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.drep_hash_id_seq OWNER TO postgres;

--
-- Name: drep_hash_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.drep_hash_id_seq OWNED BY public.drep_hash.id;


--
-- Name: drep_registration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drep_registration (
    id bigint NOT NULL,
    tx_id bigint NOT NULL,
    cert_index integer NOT NULL,
    deposit bigint,
    drep_hash_id bigint NOT NULL,
    voting_anchor_id bigint
);


ALTER TABLE public.drep_registration OWNER TO postgres;

--
-- Name: drep_registration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.drep_registration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.drep_registration_id_seq OWNER TO postgres;

--
-- Name: drep_registration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.drep_registration_id_seq OWNED BY public.drep_registration.id;


--
-- Name: epoch; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.epoch (
    id bigint NOT NULL,
    out_sum public.word128type NOT NULL,
    fees public.lovelace NOT NULL,
    tx_count public.word31type NOT NULL,
    blk_count public.word31type NOT NULL,
    no public.word31type NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL
);


ALTER TABLE public.epoch OWNER TO postgres;

--
-- Name: epoch_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.epoch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.epoch_id_seq OWNER TO postgres;

--
-- Name: epoch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.epoch_id_seq OWNED BY public.epoch.id;


--
-- Name: epoch_param; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.epoch_param (
    id bigint NOT NULL,
    epoch_no public.word31type NOT NULL,
    min_fee_a public.word31type NOT NULL,
    min_fee_b public.word31type NOT NULL,
    max_block_size public.word31type NOT NULL,
    max_tx_size public.word31type NOT NULL,
    max_bh_size public.word31type NOT NULL,
    key_deposit public.lovelace NOT NULL,
    pool_deposit public.lovelace NOT NULL,
    max_epoch public.word31type NOT NULL,
    optimal_pool_count public.word31type NOT NULL,
    influence double precision NOT NULL,
    monetary_expand_rate double precision NOT NULL,
    treasury_growth_rate double precision NOT NULL,
    decentralisation double precision NOT NULL,
    protocol_major public.word31type NOT NULL,
    protocol_minor public.word31type NOT NULL,
    min_utxo_value public.lovelace NOT NULL,
    min_pool_cost public.lovelace NOT NULL,
    nonce public.hash32type,
    cost_model_id bigint,
    price_mem double precision,
    price_step double precision,
    max_tx_ex_mem public.word64type,
    max_tx_ex_steps public.word64type,
    max_block_ex_mem public.word64type,
    max_block_ex_steps public.word64type,
    max_val_size public.word64type,
    collateral_percent public.word31type,
    max_collateral_inputs public.word31type,
    block_id bigint NOT NULL,
    extra_entropy public.hash32type,
    coins_per_utxo_size public.lovelace,
    pvt_motion_no_confidence double precision,
    pvt_committee_normal double precision,
    pvt_committee_no_confidence double precision,
    pvt_hard_fork_initiation double precision,
    dvt_motion_no_confidence double precision,
    dvt_committee_normal double precision,
    dvt_committee_no_confidence double precision,
    dvt_update_to_constitution double precision,
    dvt_hard_fork_initiation double precision,
    dvt_p_p_network_group double precision,
    dvt_p_p_economic_group double precision,
    dvt_p_p_technical_group double precision,
    dvt_p_p_gov_group double precision,
    dvt_treasury_withdrawal double precision,
    committee_min_size public.word64type,
    committee_max_term_length public.word64type,
    gov_action_lifetime public.word64type,
    gov_action_deposit public.word64type,
    drep_deposit public.word64type,
    drep_activity public.word64type
);


ALTER TABLE public.epoch_param OWNER TO postgres;

--
-- Name: epoch_param_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.epoch_param_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.epoch_param_id_seq OWNER TO postgres;

--
-- Name: epoch_param_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.epoch_param_id_seq OWNED BY public.epoch_param.id;


--
-- Name: epoch_stake; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.epoch_stake (
    id bigint NOT NULL,
    addr_id bigint NOT NULL,
    pool_id bigint NOT NULL,
    amount public.lovelace NOT NULL,
    epoch_no public.word31type NOT NULL
);


ALTER TABLE public.epoch_stake OWNER TO postgres;

--
-- Name: epoch_stake_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.epoch_stake_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.epoch_stake_id_seq OWNER TO postgres;

--
-- Name: epoch_stake_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.epoch_stake_id_seq OWNED BY public.epoch_stake.id;


--
-- Name: epoch_stake_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.epoch_stake_progress (
    id bigint NOT NULL,
    epoch_no public.word31type NOT NULL,
    completed boolean NOT NULL
);


ALTER TABLE public.epoch_stake_progress OWNER TO postgres;

--
-- Name: epoch_stake_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.epoch_stake_progress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.epoch_stake_progress_id_seq OWNER TO postgres;

--
-- Name: epoch_stake_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.epoch_stake_progress_id_seq OWNED BY public.epoch_stake_progress.id;


--
-- Name: epoch_sync_time; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.epoch_sync_time (
    id bigint NOT NULL,
    no bigint NOT NULL,
    seconds public.word63type NOT NULL,
    state public.syncstatetype NOT NULL
);


ALTER TABLE public.epoch_sync_time OWNER TO postgres;

--
-- Name: epoch_sync_time_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.epoch_sync_time_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.epoch_sync_time_id_seq OWNER TO postgres;

--
-- Name: epoch_sync_time_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.epoch_sync_time_id_seq OWNED BY public.epoch_sync_time.id;


--
-- Name: extra_key_witness; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.extra_key_witness (
    id bigint NOT NULL,
    hash public.hash28type NOT NULL,
    tx_id bigint NOT NULL
);


ALTER TABLE public.extra_key_witness OWNER TO postgres;

--
-- Name: extra_key_witness_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.extra_key_witness_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.extra_key_witness_id_seq OWNER TO postgres;

--
-- Name: extra_key_witness_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.extra_key_witness_id_seq OWNED BY public.extra_key_witness.id;


--
-- Name: extra_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.extra_migrations (
    id bigint NOT NULL,
    token character varying NOT NULL,
    description character varying
);


ALTER TABLE public.extra_migrations OWNER TO postgres;

--
-- Name: extra_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.extra_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.extra_migrations_id_seq OWNER TO postgres;

--
-- Name: extra_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.extra_migrations_id_seq OWNED BY public.extra_migrations.id;


--
-- Name: gov_action_proposal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gov_action_proposal (
    id bigint NOT NULL,
    tx_id bigint NOT NULL,
    index bigint NOT NULL,
    prev_gov_action_proposal bigint,
    deposit public.lovelace NOT NULL,
    return_address bigint NOT NULL,
    expiration public.word31type,
    voting_anchor_id bigint,
    type public.govactiontype NOT NULL,
    description character varying NOT NULL,
    param_proposal bigint,
    ratified_epoch public.word31type,
    enacted_epoch public.word31type,
    dropped_epoch public.word31type,
    expired_epoch public.word31type
);


ALTER TABLE public.gov_action_proposal OWNER TO postgres;

--
-- Name: gov_action_proposal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.gov_action_proposal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gov_action_proposal_id_seq OWNER TO postgres;

--
-- Name: gov_action_proposal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.gov_action_proposal_id_seq OWNED BY public.gov_action_proposal.id;


--
-- Name: instant_reward; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.instant_reward (
    addr_id bigint NOT NULL,
    type public.rewardtype NOT NULL,
    amount public.lovelace NOT NULL,
    spendable_epoch bigint NOT NULL,
    earned_epoch bigint GENERATED ALWAYS AS (
CASE
    WHEN (spendable_epoch >= 1) THEN (spendable_epoch - 1)
    ELSE (0)::bigint
END) STORED NOT NULL
);


ALTER TABLE public.instant_reward OWNER TO postgres;

--
-- Name: ma_tx_mint; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ma_tx_mint (
    id bigint NOT NULL,
    quantity public.int65type NOT NULL,
    tx_id bigint NOT NULL,
    ident bigint NOT NULL
);


ALTER TABLE public.ma_tx_mint OWNER TO postgres;

--
-- Name: ma_tx_mint_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ma_tx_mint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ma_tx_mint_id_seq OWNER TO postgres;

--
-- Name: ma_tx_mint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ma_tx_mint_id_seq OWNED BY public.ma_tx_mint.id;


--
-- Name: ma_tx_out; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ma_tx_out (
    id bigint NOT NULL,
    quantity public.word64type NOT NULL,
    tx_out_id bigint NOT NULL,
    ident bigint NOT NULL
);


ALTER TABLE public.ma_tx_out OWNER TO postgres;

--
-- Name: ma_tx_out_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ma_tx_out_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ma_tx_out_id_seq OWNER TO postgres;

--
-- Name: ma_tx_out_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ma_tx_out_id_seq OWNED BY public.ma_tx_out.id;


--
-- Name: meta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meta (
    id bigint NOT NULL,
    start_time timestamp without time zone NOT NULL,
    network_name character varying NOT NULL,
    version character varying NOT NULL
);


ALTER TABLE public.meta OWNER TO postgres;

--
-- Name: meta_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.meta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.meta_id_seq OWNER TO postgres;

--
-- Name: meta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.meta_id_seq OWNED BY public.meta.id;


--
-- Name: multi_asset; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.multi_asset (
    id bigint NOT NULL,
    policy public.hash28type NOT NULL,
    name public.asset32type NOT NULL,
    fingerprint character varying NOT NULL
);


ALTER TABLE public.multi_asset OWNER TO postgres;

--
-- Name: multi_asset_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.multi_asset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.multi_asset_id_seq OWNER TO postgres;

--
-- Name: multi_asset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.multi_asset_id_seq OWNED BY public.multi_asset.id;


--
-- Name: new_committee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.new_committee (
    id bigint NOT NULL,
    gov_action_proposal_id bigint NOT NULL,
    deleted_members character varying NOT NULL,
    added_members character varying NOT NULL,
    quorum_numerator bigint NOT NULL,
    quorum_denominator bigint NOT NULL
);


ALTER TABLE public.new_committee OWNER TO postgres;

--
-- Name: new_committee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.new_committee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.new_committee_id_seq OWNER TO postgres;

--
-- Name: new_committee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.new_committee_id_seq OWNED BY public.new_committee.id;


--
-- Name: off_chain_pool_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.off_chain_pool_data (
    id bigint NOT NULL,
    pool_id bigint NOT NULL,
    ticker_name character varying NOT NULL,
    hash public.hash32type NOT NULL,
    json jsonb NOT NULL,
    bytes bytea NOT NULL,
    pmr_id bigint NOT NULL
);


ALTER TABLE public.off_chain_pool_data OWNER TO postgres;

--
-- Name: off_chain_pool_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.off_chain_pool_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.off_chain_pool_data_id_seq OWNER TO postgres;

--
-- Name: off_chain_pool_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.off_chain_pool_data_id_seq OWNED BY public.off_chain_pool_data.id;


--
-- Name: off_chain_pool_fetch_error; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.off_chain_pool_fetch_error (
    id bigint NOT NULL,
    pool_id bigint NOT NULL,
    fetch_time timestamp without time zone NOT NULL,
    pmr_id bigint NOT NULL,
    fetch_error character varying NOT NULL,
    retry_count public.word31type NOT NULL
);


ALTER TABLE public.off_chain_pool_fetch_error OWNER TO postgres;

--
-- Name: off_chain_pool_fetch_error_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.off_chain_pool_fetch_error_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.off_chain_pool_fetch_error_id_seq OWNER TO postgres;

--
-- Name: off_chain_pool_fetch_error_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.off_chain_pool_fetch_error_id_seq OWNED BY public.off_chain_pool_fetch_error.id;


--
-- Name: off_chain_vote_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.off_chain_vote_data (
    id bigint NOT NULL,
    voting_anchor_id bigint NOT NULL,
    hash bytea NOT NULL,
    json jsonb NOT NULL,
    bytes bytea NOT NULL,
    warning character varying
);


ALTER TABLE public.off_chain_vote_data OWNER TO postgres;

--
-- Name: off_chain_vote_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.off_chain_vote_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.off_chain_vote_data_id_seq OWNER TO postgres;

--
-- Name: off_chain_vote_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.off_chain_vote_data_id_seq OWNED BY public.off_chain_vote_data.id;


--
-- Name: off_chain_vote_fetch_error; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.off_chain_vote_fetch_error (
    id bigint NOT NULL,
    voting_anchor_id bigint NOT NULL,
    fetch_error character varying NOT NULL,
    fetch_time timestamp without time zone NOT NULL,
    retry_count public.word31type NOT NULL
);


ALTER TABLE public.off_chain_vote_fetch_error OWNER TO postgres;

--
-- Name: off_chain_vote_fetch_error_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.off_chain_vote_fetch_error_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.off_chain_vote_fetch_error_id_seq OWNER TO postgres;

--
-- Name: off_chain_vote_fetch_error_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.off_chain_vote_fetch_error_id_seq OWNED BY public.off_chain_vote_fetch_error.id;


--
-- Name: param_proposal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.param_proposal (
    id bigint NOT NULL,
    epoch_no public.word31type,
    key public.hash28type,
    min_fee_a public.word64type,
    min_fee_b public.word64type,
    max_block_size public.word64type,
    max_tx_size public.word64type,
    max_bh_size public.word64type,
    key_deposit public.lovelace,
    pool_deposit public.lovelace,
    max_epoch public.word64type,
    optimal_pool_count public.word64type,
    influence double precision,
    monetary_expand_rate double precision,
    treasury_growth_rate double precision,
    decentralisation double precision,
    entropy public.hash32type,
    protocol_major public.word31type,
    protocol_minor public.word31type,
    min_utxo_value public.lovelace,
    min_pool_cost public.lovelace,
    cost_model_id bigint,
    price_mem double precision,
    price_step double precision,
    max_tx_ex_mem public.word64type,
    max_tx_ex_steps public.word64type,
    max_block_ex_mem public.word64type,
    max_block_ex_steps public.word64type,
    max_val_size public.word64type,
    collateral_percent public.word31type,
    max_collateral_inputs public.word31type,
    registered_tx_id bigint NOT NULL,
    coins_per_utxo_size public.lovelace,
    pvt_motion_no_confidence double precision,
    pvt_committee_normal double precision,
    pvt_committee_no_confidence double precision,
    pvt_hard_fork_initiation double precision,
    dvt_motion_no_confidence double precision,
    dvt_committee_normal double precision,
    dvt_committee_no_confidence double precision,
    dvt_update_to_constitution double precision,
    dvt_hard_fork_initiation double precision,
    dvt_p_p_network_group double precision,
    dvt_p_p_economic_group double precision,
    dvt_p_p_technical_group double precision,
    dvt_p_p_gov_group double precision,
    dvt_treasury_withdrawal double precision,
    committee_min_size public.word64type,
    committee_max_term_length public.word64type,
    gov_action_lifetime public.word64type,
    gov_action_deposit public.word64type,
    drep_deposit public.word64type,
    drep_activity public.word64type
);


ALTER TABLE public.param_proposal OWNER TO postgres;

--
-- Name: param_proposal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.param_proposal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.param_proposal_id_seq OWNER TO postgres;

--
-- Name: param_proposal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.param_proposal_id_seq OWNED BY public.param_proposal.id;


--
-- Name: pool_hash; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_hash (
    id bigint NOT NULL,
    hash_raw public.hash28type NOT NULL,
    view character varying NOT NULL
);


ALTER TABLE public.pool_hash OWNER TO postgres;

--
-- Name: pool_hash_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_hash_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_hash_id_seq OWNER TO postgres;

--
-- Name: pool_hash_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_hash_id_seq OWNED BY public.pool_hash.id;


--
-- Name: pool_metadata_ref; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_metadata_ref (
    id bigint NOT NULL,
    pool_id bigint NOT NULL,
    url character varying NOT NULL,
    hash public.hash32type NOT NULL,
    registered_tx_id bigint NOT NULL
);


ALTER TABLE public.pool_metadata_ref OWNER TO postgres;

--
-- Name: pool_metadata_ref_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_metadata_ref_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_metadata_ref_id_seq OWNER TO postgres;

--
-- Name: pool_metadata_ref_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_metadata_ref_id_seq OWNED BY public.pool_metadata_ref.id;


--
-- Name: pool_owner; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_owner (
    id bigint NOT NULL,
    addr_id bigint NOT NULL,
    pool_update_id bigint NOT NULL
);


ALTER TABLE public.pool_owner OWNER TO postgres;

--
-- Name: pool_owner_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_owner_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_owner_id_seq OWNER TO postgres;

--
-- Name: pool_owner_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_owner_id_seq OWNED BY public.pool_owner.id;


--
-- Name: pool_relay; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_relay (
    id bigint NOT NULL,
    update_id bigint NOT NULL,
    ipv4 character varying,
    ipv6 character varying,
    dns_name character varying,
    dns_srv_name character varying,
    port integer
);


ALTER TABLE public.pool_relay OWNER TO postgres;

--
-- Name: pool_relay_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_relay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_relay_id_seq OWNER TO postgres;

--
-- Name: pool_relay_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_relay_id_seq OWNED BY public.pool_relay.id;


--
-- Name: pool_retire; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_retire (
    id bigint NOT NULL,
    hash_id bigint NOT NULL,
    cert_index integer NOT NULL,
    announced_tx_id bigint NOT NULL,
    retiring_epoch public.word31type NOT NULL
);


ALTER TABLE public.pool_retire OWNER TO postgres;

--
-- Name: pool_retire_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_retire_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_retire_id_seq OWNER TO postgres;

--
-- Name: pool_retire_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_retire_id_seq OWNED BY public.pool_retire.id;


--
-- Name: pool_update; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_update (
    id bigint NOT NULL,
    hash_id bigint NOT NULL,
    cert_index integer NOT NULL,
    vrf_key_hash public.hash32type NOT NULL,
    pledge public.lovelace NOT NULL,
    active_epoch_no bigint NOT NULL,
    meta_id bigint,
    margin double precision NOT NULL,
    fixed_cost public.lovelace NOT NULL,
    registered_tx_id bigint NOT NULL,
    reward_addr_id bigint NOT NULL
);


ALTER TABLE public.pool_update OWNER TO postgres;

--
-- Name: pool_update_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_update_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_update_id_seq OWNER TO postgres;

--
-- Name: pool_update_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_update_id_seq OWNED BY public.pool_update.id;


--
-- Name: pot_transfer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pot_transfer (
    id bigint NOT NULL,
    cert_index integer NOT NULL,
    treasury public.int65type NOT NULL,
    reserves public.int65type NOT NULL,
    tx_id bigint NOT NULL
);


ALTER TABLE public.pot_transfer OWNER TO postgres;

--
-- Name: pot_transfer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pot_transfer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pot_transfer_id_seq OWNER TO postgres;

--
-- Name: pot_transfer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pot_transfer_id_seq OWNED BY public.pot_transfer.id;


--
-- Name: redeemer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.redeemer (
    id bigint NOT NULL,
    tx_id bigint NOT NULL,
    unit_mem public.word63type NOT NULL,
    unit_steps public.word63type NOT NULL,
    fee public.lovelace,
    purpose public.scriptpurposetype NOT NULL,
    index public.word31type NOT NULL,
    script_hash public.hash28type,
    redeemer_data_id bigint NOT NULL
);


ALTER TABLE public.redeemer OWNER TO postgres;

--
-- Name: redeemer_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.redeemer_data (
    id bigint NOT NULL,
    hash public.hash32type NOT NULL,
    tx_id bigint NOT NULL,
    value jsonb,
    bytes bytea NOT NULL
);


ALTER TABLE public.redeemer_data OWNER TO postgres;

--
-- Name: redeemer_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.redeemer_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.redeemer_data_id_seq OWNER TO postgres;

--
-- Name: redeemer_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.redeemer_data_id_seq OWNED BY public.redeemer_data.id;


--
-- Name: redeemer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.redeemer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.redeemer_id_seq OWNER TO postgres;

--
-- Name: redeemer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.redeemer_id_seq OWNED BY public.redeemer.id;


--
-- Name: reference_tx_in; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reference_tx_in (
    id bigint NOT NULL,
    tx_in_id bigint NOT NULL,
    tx_out_id bigint NOT NULL,
    tx_out_index public.txindex NOT NULL
);


ALTER TABLE public.reference_tx_in OWNER TO postgres;

--
-- Name: reference_tx_in_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reference_tx_in_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reference_tx_in_id_seq OWNER TO postgres;

--
-- Name: reference_tx_in_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reference_tx_in_id_seq OWNED BY public.reference_tx_in.id;


--
-- Name: reserve; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reserve (
    id bigint NOT NULL,
    addr_id bigint NOT NULL,
    cert_index integer NOT NULL,
    amount public.int65type NOT NULL,
    tx_id bigint NOT NULL
);


ALTER TABLE public.reserve OWNER TO postgres;

--
-- Name: reserve_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reserve_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reserve_id_seq OWNER TO postgres;

--
-- Name: reserve_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reserve_id_seq OWNED BY public.reserve.id;


--
-- Name: reserved_pool_ticker; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reserved_pool_ticker (
    id bigint NOT NULL,
    name character varying NOT NULL,
    pool_hash public.hash28type NOT NULL
);


ALTER TABLE public.reserved_pool_ticker OWNER TO postgres;

--
-- Name: reserved_pool_ticker_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reserved_pool_ticker_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reserved_pool_ticker_id_seq OWNER TO postgres;

--
-- Name: reserved_pool_ticker_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reserved_pool_ticker_id_seq OWNED BY public.reserved_pool_ticker.id;


--
-- Name: reverse_index; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reverse_index (
    id bigint NOT NULL,
    block_id bigint NOT NULL,
    min_ids character varying NOT NULL
);


ALTER TABLE public.reverse_index OWNER TO postgres;

--
-- Name: reverse_index_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reverse_index_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reverse_index_id_seq OWNER TO postgres;

--
-- Name: reverse_index_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reverse_index_id_seq OWNED BY public.reverse_index.id;


--
-- Name: reward; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reward (
    addr_id bigint NOT NULL,
    type public.rewardtype NOT NULL,
    amount public.lovelace NOT NULL,
    spendable_epoch bigint NOT NULL,
    pool_id bigint NOT NULL,
    earned_epoch bigint GENERATED ALWAYS AS (
CASE
    WHEN (type = 'refund'::public.rewardtype) THEN spendable_epoch
    ELSE
    CASE
        WHEN (spendable_epoch >= 2) THEN (spendable_epoch - 2)
        ELSE (0)::bigint
    END
END) STORED NOT NULL
);


ALTER TABLE public.reward OWNER TO postgres;

--
-- Name: schema_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_version (
    id bigint NOT NULL,
    stage_one bigint NOT NULL,
    stage_two bigint NOT NULL,
    stage_three bigint NOT NULL
);


ALTER TABLE public.schema_version OWNER TO postgres;

--
-- Name: schema_version_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.schema_version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.schema_version_id_seq OWNER TO postgres;

--
-- Name: schema_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schema_version_id_seq OWNED BY public.schema_version.id;


--
-- Name: script; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.script (
    id bigint NOT NULL,
    tx_id bigint NOT NULL,
    hash public.hash28type NOT NULL,
    type public.scripttype NOT NULL,
    json jsonb,
    bytes bytea,
    serialised_size public.word31type
);


ALTER TABLE public.script OWNER TO postgres;

--
-- Name: script_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.script_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.script_id_seq OWNER TO postgres;

--
-- Name: script_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.script_id_seq OWNED BY public.script.id;


--
-- Name: slot_leader; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slot_leader (
    id bigint NOT NULL,
    hash public.hash28type NOT NULL,
    pool_hash_id bigint,
    description character varying NOT NULL
);


ALTER TABLE public.slot_leader OWNER TO postgres;

--
-- Name: slot_leader_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slot_leader_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.slot_leader_id_seq OWNER TO postgres;

--
-- Name: slot_leader_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slot_leader_id_seq OWNED BY public.slot_leader.id;


--
-- Name: stake_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stake_address (
    id bigint NOT NULL,
    hash_raw public.addr29type NOT NULL,
    view character varying NOT NULL,
    script_hash public.hash28type
);


ALTER TABLE public.stake_address OWNER TO postgres;

--
-- Name: stake_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stake_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stake_address_id_seq OWNER TO postgres;

--
-- Name: stake_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stake_address_id_seq OWNED BY public.stake_address.id;


--
-- Name: stake_deregistration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stake_deregistration (
    id bigint NOT NULL,
    addr_id bigint NOT NULL,
    cert_index integer NOT NULL,
    epoch_no public.word31type NOT NULL,
    tx_id bigint NOT NULL,
    redeemer_id bigint
);


ALTER TABLE public.stake_deregistration OWNER TO postgres;

--
-- Name: stake_deregistration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stake_deregistration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stake_deregistration_id_seq OWNER TO postgres;

--
-- Name: stake_deregistration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stake_deregistration_id_seq OWNED BY public.stake_deregistration.id;


--
-- Name: stake_registration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stake_registration (
    id bigint NOT NULL,
    addr_id bigint NOT NULL,
    cert_index integer NOT NULL,
    epoch_no public.word31type NOT NULL,
    tx_id bigint NOT NULL
);


ALTER TABLE public.stake_registration OWNER TO postgres;

--
-- Name: stake_registration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stake_registration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stake_registration_id_seq OWNER TO postgres;

--
-- Name: stake_registration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stake_registration_id_seq OWNED BY public.stake_registration.id;


--
-- Name: treasury; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.treasury (
    id bigint NOT NULL,
    addr_id bigint NOT NULL,
    cert_index integer NOT NULL,
    amount public.int65type NOT NULL,
    tx_id bigint NOT NULL
);


ALTER TABLE public.treasury OWNER TO postgres;

--
-- Name: treasury_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.treasury_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.treasury_id_seq OWNER TO postgres;

--
-- Name: treasury_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.treasury_id_seq OWNED BY public.treasury.id;


--
-- Name: treasury_withdrawal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.treasury_withdrawal (
    id bigint NOT NULL,
    gov_action_proposal_id bigint NOT NULL,
    stake_address_id bigint NOT NULL,
    amount public.lovelace NOT NULL
);


ALTER TABLE public.treasury_withdrawal OWNER TO postgres;

--
-- Name: treasury_withdrawal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.treasury_withdrawal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.treasury_withdrawal_id_seq OWNER TO postgres;

--
-- Name: treasury_withdrawal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.treasury_withdrawal_id_seq OWNED BY public.treasury_withdrawal.id;


--
-- Name: tx; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tx (
    id bigint NOT NULL,
    hash public.hash32type NOT NULL,
    block_id bigint NOT NULL,
    block_index public.word31type NOT NULL,
    out_sum public.lovelace NOT NULL,
    fee public.lovelace NOT NULL,
    deposit bigint,
    size public.word31type NOT NULL,
    invalid_before public.word64type,
    invalid_hereafter public.word64type,
    valid_contract boolean NOT NULL,
    script_size public.word31type NOT NULL
);


ALTER TABLE public.tx OWNER TO postgres;

--
-- Name: tx_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tx_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tx_id_seq OWNER TO postgres;

--
-- Name: tx_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tx_id_seq OWNED BY public.tx.id;


--
-- Name: tx_in; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tx_in (
    id bigint NOT NULL,
    tx_in_id bigint NOT NULL,
    tx_out_id bigint NOT NULL,
    tx_out_index public.txindex NOT NULL,
    redeemer_id bigint
);


ALTER TABLE public.tx_in OWNER TO postgres;

--
-- Name: tx_in_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tx_in_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tx_in_id_seq OWNER TO postgres;

--
-- Name: tx_in_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tx_in_id_seq OWNED BY public.tx_in.id;


--
-- Name: tx_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tx_metadata (
    id bigint NOT NULL,
    key public.word64type NOT NULL,
    json jsonb,
    bytes bytea NOT NULL,
    tx_id bigint NOT NULL
);


ALTER TABLE public.tx_metadata OWNER TO postgres;

--
-- Name: tx_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tx_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tx_metadata_id_seq OWNER TO postgres;

--
-- Name: tx_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tx_metadata_id_seq OWNED BY public.tx_metadata.id;


--
-- Name: tx_out; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tx_out (
    id bigint NOT NULL,
    tx_id bigint NOT NULL,
    index public.txindex NOT NULL,
    address character varying NOT NULL,
    address_has_script boolean NOT NULL,
    payment_cred public.hash28type,
    stake_address_id bigint,
    value public.lovelace NOT NULL,
    data_hash public.hash32type,
    inline_datum_id bigint,
    reference_script_id bigint
);


ALTER TABLE public.tx_out OWNER TO postgres;

--
-- Name: tx_out_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tx_out_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tx_out_id_seq OWNER TO postgres;

--
-- Name: tx_out_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tx_out_id_seq OWNED BY public.tx_out.id;


--
-- Name: utxo_byron_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.utxo_byron_view AS
 SELECT tx_out.id,
    tx_out.tx_id,
    tx_out.index,
    tx_out.address,
    tx_out.address_has_script,
    tx_out.payment_cred,
    tx_out.stake_address_id,
    tx_out.value,
    tx_out.data_hash,
    tx_out.inline_datum_id,
    tx_out.reference_script_id
   FROM (public.tx_out
     LEFT JOIN public.tx_in ON (((tx_out.tx_id = tx_in.tx_out_id) AND ((tx_out.index)::smallint = (tx_in.tx_out_index)::smallint))))
  WHERE (tx_in.tx_in_id IS NULL);


ALTER TABLE public.utxo_byron_view OWNER TO postgres;

--
-- Name: utxo_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.utxo_view AS
 SELECT tx_out.id,
    tx_out.tx_id,
    tx_out.index,
    tx_out.address,
    tx_out.address_has_script,
    tx_out.payment_cred,
    tx_out.stake_address_id,
    tx_out.value,
    tx_out.data_hash,
    tx_out.inline_datum_id,
    tx_out.reference_script_id
   FROM (((public.tx_out
     LEFT JOIN public.tx_in ON (((tx_out.tx_id = tx_in.tx_out_id) AND ((tx_out.index)::smallint = (tx_in.tx_out_index)::smallint))))
     LEFT JOIN public.tx ON ((tx.id = tx_out.tx_id)))
     LEFT JOIN public.block ON ((tx.block_id = block.id)))
  WHERE ((tx_in.tx_in_id IS NULL) AND (block.epoch_no IS NOT NULL));


ALTER TABLE public.utxo_view OWNER TO postgres;

--
-- Name: voting_anchor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.voting_anchor (
    id bigint NOT NULL,
    tx_id bigint NOT NULL,
    url character varying NOT NULL,
    data_hash bytea NOT NULL
);


ALTER TABLE public.voting_anchor OWNER TO postgres;

--
-- Name: voting_anchor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.voting_anchor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.voting_anchor_id_seq OWNER TO postgres;

--
-- Name: voting_anchor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.voting_anchor_id_seq OWNED BY public.voting_anchor.id;


--
-- Name: voting_procedure; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.voting_procedure (
    id bigint NOT NULL,
    tx_id bigint NOT NULL,
    index integer NOT NULL,
    gov_action_proposal_id bigint NOT NULL,
    voter_role public.voterrole NOT NULL,
    committee_voter bytea,
    drep_voter bigint,
    pool_voter bigint,
    vote public.vote NOT NULL,
    voting_anchor_id bigint
);


ALTER TABLE public.voting_procedure OWNER TO postgres;

--
-- Name: voting_procedure_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.voting_procedure_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.voting_procedure_id_seq OWNER TO postgres;

--
-- Name: voting_procedure_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.voting_procedure_id_seq OWNED BY public.voting_procedure.id;


--
-- Name: withdrawal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.withdrawal (
    id bigint NOT NULL,
    addr_id bigint NOT NULL,
    amount public.lovelace NOT NULL,
    redeemer_id bigint,
    tx_id bigint NOT NULL
);


ALTER TABLE public.withdrawal OWNER TO postgres;

--
-- Name: withdrawal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.withdrawal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.withdrawal_id_seq OWNER TO postgres;

--
-- Name: withdrawal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.withdrawal_id_seq OWNED BY public.withdrawal.id;


--
-- Name: ada_pots id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ada_pots ALTER COLUMN id SET DEFAULT nextval('public.ada_pots_id_seq'::regclass);


--
-- Name: block id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.block ALTER COLUMN id SET DEFAULT nextval('public.block_id_seq'::regclass);


--
-- Name: collateral_tx_in id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collateral_tx_in ALTER COLUMN id SET DEFAULT nextval('public.collateral_tx_in_id_seq'::regclass);


--
-- Name: collateral_tx_out id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collateral_tx_out ALTER COLUMN id SET DEFAULT nextval('public.collateral_tx_out_id_seq'::regclass);


--
-- Name: committee_de_registration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.committee_de_registration ALTER COLUMN id SET DEFAULT nextval('public.committee_de_registration_id_seq'::regclass);


--
-- Name: committee_registration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.committee_registration ALTER COLUMN id SET DEFAULT nextval('public.committee_registration_id_seq'::regclass);


--
-- Name: constitution id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.constitution ALTER COLUMN id SET DEFAULT nextval('public.constitution_id_seq'::regclass);


--
-- Name: cost_model id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_model ALTER COLUMN id SET DEFAULT nextval('public.cost_model_id_seq'::regclass);


--
-- Name: datum id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.datum ALTER COLUMN id SET DEFAULT nextval('public.datum_id_seq'::regclass);


--
-- Name: delegation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delegation ALTER COLUMN id SET DEFAULT nextval('public.delegation_id_seq'::regclass);


--
-- Name: delegation_vote id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delegation_vote ALTER COLUMN id SET DEFAULT nextval('public.delegation_vote_id_seq'::regclass);


--
-- Name: delisted_pool id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delisted_pool ALTER COLUMN id SET DEFAULT nextval('public.delisted_pool_id_seq'::regclass);


--
-- Name: drep_distr id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drep_distr ALTER COLUMN id SET DEFAULT nextval('public.drep_distr_id_seq'::regclass);


--
-- Name: drep_hash id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drep_hash ALTER COLUMN id SET DEFAULT nextval('public.drep_hash_id_seq'::regclass);


--
-- Name: drep_registration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drep_registration ALTER COLUMN id SET DEFAULT nextval('public.drep_registration_id_seq'::regclass);


--
-- Name: epoch id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch ALTER COLUMN id SET DEFAULT nextval('public.epoch_id_seq'::regclass);


--
-- Name: epoch_param id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_param ALTER COLUMN id SET DEFAULT nextval('public.epoch_param_id_seq'::regclass);


--
-- Name: epoch_stake id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_stake ALTER COLUMN id SET DEFAULT nextval('public.epoch_stake_id_seq'::regclass);


--
-- Name: epoch_stake_progress id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_stake_progress ALTER COLUMN id SET DEFAULT nextval('public.epoch_stake_progress_id_seq'::regclass);


--
-- Name: epoch_sync_time id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_sync_time ALTER COLUMN id SET DEFAULT nextval('public.epoch_sync_time_id_seq'::regclass);


--
-- Name: extra_key_witness id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extra_key_witness ALTER COLUMN id SET DEFAULT nextval('public.extra_key_witness_id_seq'::regclass);


--
-- Name: extra_migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extra_migrations ALTER COLUMN id SET DEFAULT nextval('public.extra_migrations_id_seq'::regclass);


--
-- Name: gov_action_proposal id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gov_action_proposal ALTER COLUMN id SET DEFAULT nextval('public.gov_action_proposal_id_seq'::regclass);


--
-- Name: ma_tx_mint id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ma_tx_mint ALTER COLUMN id SET DEFAULT nextval('public.ma_tx_mint_id_seq'::regclass);


--
-- Name: ma_tx_out id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ma_tx_out ALTER COLUMN id SET DEFAULT nextval('public.ma_tx_out_id_seq'::regclass);


--
-- Name: meta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meta ALTER COLUMN id SET DEFAULT nextval('public.meta_id_seq'::regclass);


--
-- Name: multi_asset id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.multi_asset ALTER COLUMN id SET DEFAULT nextval('public.multi_asset_id_seq'::regclass);


--
-- Name: new_committee id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.new_committee ALTER COLUMN id SET DEFAULT nextval('public.new_committee_id_seq'::regclass);


--
-- Name: off_chain_pool_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_pool_data ALTER COLUMN id SET DEFAULT nextval('public.off_chain_pool_data_id_seq'::regclass);


--
-- Name: off_chain_pool_fetch_error id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_pool_fetch_error ALTER COLUMN id SET DEFAULT nextval('public.off_chain_pool_fetch_error_id_seq'::regclass);


--
-- Name: off_chain_vote_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_data ALTER COLUMN id SET DEFAULT nextval('public.off_chain_vote_data_id_seq'::regclass);


--
-- Name: off_chain_vote_fetch_error id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_fetch_error ALTER COLUMN id SET DEFAULT nextval('public.off_chain_vote_fetch_error_id_seq'::regclass);


--
-- Name: param_proposal id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.param_proposal ALTER COLUMN id SET DEFAULT nextval('public.param_proposal_id_seq'::regclass);


--
-- Name: pool_hash id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_hash ALTER COLUMN id SET DEFAULT nextval('public.pool_hash_id_seq'::regclass);


--
-- Name: pool_metadata_ref id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata_ref ALTER COLUMN id SET DEFAULT nextval('public.pool_metadata_ref_id_seq'::regclass);


--
-- Name: pool_owner id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_owner ALTER COLUMN id SET DEFAULT nextval('public.pool_owner_id_seq'::regclass);


--
-- Name: pool_relay id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_relay ALTER COLUMN id SET DEFAULT nextval('public.pool_relay_id_seq'::regclass);


--
-- Name: pool_retire id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_retire ALTER COLUMN id SET DEFAULT nextval('public.pool_retire_id_seq'::regclass);


--
-- Name: pool_update id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_update ALTER COLUMN id SET DEFAULT nextval('public.pool_update_id_seq'::regclass);


--
-- Name: pot_transfer id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pot_transfer ALTER COLUMN id SET DEFAULT nextval('public.pot_transfer_id_seq'::regclass);


--
-- Name: redeemer id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.redeemer ALTER COLUMN id SET DEFAULT nextval('public.redeemer_id_seq'::regclass);


--
-- Name: redeemer_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.redeemer_data ALTER COLUMN id SET DEFAULT nextval('public.redeemer_data_id_seq'::regclass);


--
-- Name: reference_tx_in id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reference_tx_in ALTER COLUMN id SET DEFAULT nextval('public.reference_tx_in_id_seq'::regclass);


--
-- Name: reserve id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reserve ALTER COLUMN id SET DEFAULT nextval('public.reserve_id_seq'::regclass);


--
-- Name: reserved_pool_ticker id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reserved_pool_ticker ALTER COLUMN id SET DEFAULT nextval('public.reserved_pool_ticker_id_seq'::regclass);


--
-- Name: reverse_index id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reverse_index ALTER COLUMN id SET DEFAULT nextval('public.reverse_index_id_seq'::regclass);


--
-- Name: schema_version id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_version ALTER COLUMN id SET DEFAULT nextval('public.schema_version_id_seq'::regclass);


--
-- Name: script id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.script ALTER COLUMN id SET DEFAULT nextval('public.script_id_seq'::regclass);


--
-- Name: slot_leader id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slot_leader ALTER COLUMN id SET DEFAULT nextval('public.slot_leader_id_seq'::regclass);


--
-- Name: stake_address id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_address ALTER COLUMN id SET DEFAULT nextval('public.stake_address_id_seq'::regclass);


--
-- Name: stake_deregistration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_deregistration ALTER COLUMN id SET DEFAULT nextval('public.stake_deregistration_id_seq'::regclass);


--
-- Name: stake_registration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_registration ALTER COLUMN id SET DEFAULT nextval('public.stake_registration_id_seq'::regclass);


--
-- Name: treasury id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.treasury ALTER COLUMN id SET DEFAULT nextval('public.treasury_id_seq'::regclass);


--
-- Name: treasury_withdrawal id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.treasury_withdrawal ALTER COLUMN id SET DEFAULT nextval('public.treasury_withdrawal_id_seq'::regclass);


--
-- Name: tx id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tx ALTER COLUMN id SET DEFAULT nextval('public.tx_id_seq'::regclass);


--
-- Name: tx_in id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tx_in ALTER COLUMN id SET DEFAULT nextval('public.tx_in_id_seq'::regclass);


--
-- Name: tx_metadata id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tx_metadata ALTER COLUMN id SET DEFAULT nextval('public.tx_metadata_id_seq'::regclass);


--
-- Name: tx_out id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tx_out ALTER COLUMN id SET DEFAULT nextval('public.tx_out_id_seq'::regclass);


--
-- Name: voting_anchor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voting_anchor ALTER COLUMN id SET DEFAULT nextval('public.voting_anchor_id_seq'::regclass);


--
-- Name: voting_procedure id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voting_procedure ALTER COLUMN id SET DEFAULT nextval('public.voting_procedure_id_seq'::regclass);


--
-- Name: withdrawal id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.withdrawal ALTER COLUMN id SET DEFAULT nextval('public.withdrawal_id_seq'::regclass);


--
-- Data for Name: ada_pots; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ada_pots (id, slot_no, epoch_no, treasury, reserves, rewards, utxo, deposits, fees, block_id) FROM stdin;
1	1019	1	0	8999989979999988	0	126000009958632631	44000000	17367381	103
2	2011	2	89999901536737	8909990095830632	0	126000009958632631	44000000	0	206
3	3026	3	179099802495043	8732681292923613	88208901948713	126000009954284688	44000000	4347943	328
4	4001	4	266426615859073	8558900938760552	174662447095687	126000009937375190	56000000	4909498	435
5	5007	5	352015625737628	8413359255205241	234615125681941	126000009937375190	56000000	0	540
6	6013	6	436149218289680	8271254140712861	292586647622269	126000009920418178	56000000	16957012	641
7	7004	7	516380385150295	8134520837074561	349088801356966	126000009920418178	56000000	0	730
8	8011	8	587964168516551	8005781311338241	406240979636815	126000013482074827	58000000	433566	816
9	9004	9	656813887837416	7892866817487249	450305754600508	126000013482074827	58000000	0	912
10	10013	10	731796122603544	7768693850756613	499487719962372	126000022231754119	58000000	16923352	1022
11	11002	11	809483062803445	7644856628273507	545638019168929	126000022231754119	58000000	0	1139
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (id, hash, epoch_no, slot_no, epoch_slot_no, block_no, previous_id, slot_leader_id, size, "time", tx_count, proto_major, proto_minor, vrf_key, op_cert, op_cert_counter) FROM stdin;
1	\\x4db6034949e494dd9f58d4b0a86d76a1d1f9c63f7ec7eb3e63303b0c960243c3	\N	\N	\N	\N	\N	1	0	2024-06-05 10:32:07	11	0	0	\N	\N	\N
2	\\x5368656c6c65792047656e6573697320426c6f636b2048617368200000000000	\N	\N	\N	\N	1	2	0	2024-06-05 10:32:07	23	0	0	\N	\N	\N
3	\\x66d83029c4eb71fab57488e08f057d7d72d9cf88d7e9b9e0d931a4229642f767	0	0	0	0	1	3	4	2024-06-05 10:32:07	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
4	\\x5097263e8fcf52df2f0443a14d354c338748d0153c411c13f35e34e399d90eef	0	20	20	1	3	4	2875	2024-06-05 10:32:11	11	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
5	\\xf3416e10a6ec367716fe11c0eaa8b5430a3f5930c01a7bbda2e2367af27ad8b1	0	25	25	2	4	5	4	2024-06-05 10:32:12	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
6	\\xb3b396b6f981a7ce7c4f4d5b516020497cec546fac9f884aa4232f48c00f8452	0	30	30	3	5	6	4	2024-06-05 10:32:13	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
7	\\xd8e70556c96b9d7f57a9762716681fc7c8b9d85bd8cee25c9a43a33c8df5693a	0	31	31	4	6	7	4	2024-06-05 10:32:13.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
8	\\x833eb46cfa2bdaf146575796fbb9e5e310dc21d3ea5ba7570ec69a5cc83d1884	0	40	40	5	7	6	4	2024-06-05 10:32:15	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
9	\\x512f595a9668d2774dc5d00bd753bbf9c5f3f81992a5f406bf84dc766d909932	0	44	44	6	8	3	4	2024-06-05 10:32:15.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
10	\\xcdcf780e8b2561f2039e2f1c166ea5169ef890e3f9ebd502b7c87d2b3959eb33	0	45	45	7	9	5	4	2024-06-05 10:32:16	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
11	\\xc6ec5b84e2c8bc5e34642591f29e0d3be44546fe02fed25ab69ffd087fcb6959	0	46	46	8	10	3	4	2024-06-05 10:32:16.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
12	\\x024bbbf8beb4b3cb68e25f9880236a580955299bcbef004188f3bc478d31dcad	0	48	48	9	11	12	4	2024-06-05 10:32:16.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
13	\\x5b6f11936d111cf00dd06ad0666270b02a6460ab366d1410e468a1767a94388c	0	53	53	10	12	13	4	2024-06-05 10:32:17.6	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
14	\\xbcf2ed2877707551b5c36a2e208b49a76e86e0bff65c4c4295075df793e1330d	0	58	58	11	13	14	4	2024-06-05 10:32:18.6	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
15	\\x99be2978653bf26f158c9e5a3125f975e92bed601cab8a1448e14027251cd47b	0	60	60	12	14	12	4	2024-06-05 10:32:19	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
16	\\xbaff86b33fcec0940bbdffc8bbab284a2539d3b984cd6a3d5474886a46a7ae89	0	61	61	13	15	16	4	2024-06-05 10:32:19.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
17	\\x1736d52bb92e5688b700503cdf5d8173e7f8064ed997f2a9f68eb3a78768fc0c	0	68	68	14	16	16	4	2024-06-05 10:32:20.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
18	\\xcdf1508928977fe6e10c4cec86b13a5bdeccc3475129b26d42958f846ea1d4fe	0	70	70	15	17	12	4	2024-06-05 10:32:21	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
19	\\x5ae97b88ac256346925ba7e19815d78c1eaa5903012bed20309cd27b9d9aefb7	0	76	76	16	18	3	4	2024-06-05 10:32:22.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
20	\\x1eea501506ed2a16a885acee6f4a4eb5f36145b6706c66b033e16cd1ac1d8ea6	0	83	83	17	19	13	3931	2024-06-05 10:32:23.6	11	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
21	\\x6cb97c420733667151ca0715131c5a47e6a223c4e1c8cdcc1297ed45eac028ff	0	94	94	18	20	21	4	2024-06-05 10:32:25.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
22	\\x1770efe5f0a9bf766d9cca9b09aaeb46996ef48dcd427c455f64ce0603512098	0	102	102	19	21	3	4	2024-06-05 10:32:27.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
23	\\x40db1baba06af33b5fc2bcc3ee83093cc6d419f6943535b5ca2e47332dbbfe58	0	111	111	20	22	16	4	2024-06-05 10:32:29.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
24	\\xca359b55d9b3e5b9213b821e69c5769c817d580f04dc7957e573abab1204cfdb	0	122	122	21	23	14	4	2024-06-05 10:32:31.4	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
25	\\x5ceda66218b2d3202c108aa220f088e26da6482d0b95001c4a88f19461186dae	0	125	125	22	24	5	4	2024-06-05 10:32:32	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
26	\\x6a445eff597ff3feedb9fc175aec7a359f22757459d4dbed56a3c8c06e78db10	0	134	134	23	25	3	4	2024-06-05 10:32:33.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
27	\\x951023ddb9f14109f9c85755e81b50871e0b40ba8a2ae5662fa42e008b7b131e	0	135	135	24	26	16	4	2024-06-05 10:32:34	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
28	\\xc2c3e8fa9ffd8f915ff185f680dbea5887397f70fa3059f4616ad1c77b8c9ed4	0	144	144	25	27	12	2831	2024-06-05 10:32:35.8	11	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
29	\\x3dded526cd67783a6748061fa13ed18e0cf5a1334eea5f1173c7a10ade0fcaa0	0	154	154	26	28	13	3689	2024-06-05 10:32:37.8	11	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
30	\\xf6f62d0db17e273086b35300b84690e8b7eb8be31e55b26332e1cfb64e92a201	0	155	155	27	29	21	4	2024-06-05 10:32:38	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
31	\\x692d30c12f6e69f41801d25c2f905950a3ac9a1897ba72f357ef51c8f910d76f	0	160	160	28	30	12	4	2024-06-05 10:32:39	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
32	\\x7a9de8d7e72bd6b2248841fe1f6130cf721a7b1c2d444f9e81f6b2a6472e8058	0	176	176	29	31	5	4019	2024-06-05 10:32:42.2	11	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
33	\\x7977b28dc40632d60c49bb70cfdeb5b6ed1bb55d6bc69ba0330fb1a5a66a0a36	0	182	182	30	32	21	4	2024-06-05 10:32:43.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
34	\\x8e6b748e438caf6cf0fd1abbd3d196d2e0df1f7f028332056b39263e55de7fa9	0	187	187	31	33	16	4327	2024-06-05 10:32:44.4	11	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
35	\\xff684d18dc52b0ac6b0055f26fdcd43b5f79f6f68c6b527e49281cb813763074	0	209	209	32	34	12	6956	2024-06-05 10:32:48.8	11	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
36	\\x624a76823ffae2ba50eea44c40ea28bfd2ad790d20cec925fb840c4aa1d7f875	0	218	218	33	35	3	4	2024-06-05 10:32:50.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
37	\\xa34a870a0922682798ea48f73613827ee7a18ec38d61c73f31512cf834778f86	0	226	226	34	36	13	1576	2024-06-05 10:32:52.2	4	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
38	\\xcf073b1b70b5dd1352d1e4bc806796df83557f073ec45ee4b1616e2c4776128e	0	235	235	35	37	6	1744	2024-06-05 10:32:54	4	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
39	\\x1051576495dbc8c686f577c04084d649268d3054bf111480bfe68bc88b340042	0	256	256	36	38	14	267	2024-06-05 10:32:58.2	1	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
40	\\xf47ed5d6a1d8abc39e63da04bec200592f7166f750fd8566e05a72db9ffb6e0e	0	272	272	37	39	40	348	2024-06-05 10:33:01.4	1	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
41	\\x83c6a3b452664d7bf96706ac4655afd5ad6149e5b9fc4a29957dc54837f3403e	0	279	279	38	40	14	4	2024-06-05 10:33:02.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
42	\\x2c0db53c90bb6dedc8f9d2c17a7c6e831583b9c586a9d3c2d891fad67d6eea5c	0	280	280	39	41	6	4	2024-06-05 10:33:03	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
43	\\x1f29f81038ac58685db6a70218ee28f381754c178dcd557b84cdcf557f79a55a	0	301	301	40	42	4	243	2024-06-05 10:33:07.2	1	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
44	\\x35d1fb45fc02793f0dfe22b01ed53b369431ea49293f784c51880308b899b457	0	318	318	41	43	14	341	2024-06-05 10:33:10.6	1	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
45	\\xb8aa7b831b6024c5dfbe38ecc05723c8d7b15fe296d95e63f9ebb7d00fa06ce9	0	333	333	42	44	7	282	2024-06-05 10:33:13.6	1	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
46	\\xc2486ced800d1ecd9b65322b3888b242bdfc4d4d29c4fcec5d192758fe7919a8	0	334	334	43	45	7	4	2024-06-05 10:33:13.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
47	\\x12705d24ff7cd8eedd5701f6b747207f066fb6d3b5e2c6bb31020f4d6727b1df	0	357	357	44	46	40	256	2024-06-05 10:33:18.4	1	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
48	\\xba872990da35e60d6c7c7ce6dbe1c6eb1341d0c7d35c08b14ad6c6c6e251c0f8	0	380	380	45	47	7	2443	2024-06-05 10:33:23	1	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
49	\\xc04e294742568b619ef5b871970e0065cc4bde5aba61fa89f915df19ad06c537	0	381	381	46	48	16	4	2024-06-05 10:33:23.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
50	\\x122915bae2bbc8dbd03c103199481252a48a76f3a7cbaca3d7d5e598e3ec65e4	0	403	403	47	49	6	244	2024-06-05 10:33:27.6	1	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
51	\\x3e95a89b1bb992248a520d74b847619486c2182a80092a9dda8de5c00a176d11	0	417	417	48	50	14	2611	2024-06-05 10:33:30.4	1	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
52	\\x40ed207ebd1cd6ad11655c4c4f74c8b5e7531351e0ffe6ea77c21921596897ce	0	433	433	49	51	14	465	2024-06-05 10:33:33.6	1	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
53	\\x5390720ad0c2c267ea2e3348dcc12c55d2240040a72ece65c20f69420632b2a7	0	439	439	50	52	3	541	2024-06-05 10:33:34.8	1	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
54	\\x215a9dba1e59f3ec31878761b51d2d7611aa69be095b5484debf8e1dc099c4dd	0	460	460	51	53	7	1751	2024-06-05 10:33:39	1	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
55	\\x245b24e8513ce967d0b5980060803cd8015e3320ec7a7a62b93fe4b29f43a06f	0	465	465	52	54	6	669	2024-06-05 10:33:40	1	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
56	\\x3d2c5de0cc3fbf692e7b884970c16905ed4c9b2cbe20b77a9224c08059b00505	0	466	466	53	55	40	4	2024-06-05 10:33:40.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
57	\\x6e25e36ae009e4df9f4203faf0bca2f7b4ea8657139d9ad381733469ea2b83f6	0	468	468	54	56	3	4	2024-06-05 10:33:40.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
58	\\xbcc9315b53ad1656beccf27a0d1827756e940163a9eef74c9ddf2df01554e1f8	0	469	469	55	57	4	4	2024-06-05 10:33:40.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
59	\\x6a868b9fe8ac50316bcccabb12d996c623b4f828b5a60e459e6b73920caeec60	0	470	470	56	58	16	4	2024-06-05 10:33:41	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
60	\\xf53f915a553d24f9f1751a58c0f30d559ab5815acbde8013c092dfd823d14e18	0	495	495	57	59	6	4	2024-06-05 10:33:46	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
61	\\x34b87ba45602a9f808e75ff87605a0c867d62e731ca2344dff9fdf9871a3903d	0	503	503	58	60	3	4	2024-06-05 10:33:47.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
62	\\xb603a8107edd9705452947541d309dfb13d7ba816a4d0db7b534fcc01f1c2556	0	511	511	59	61	7	4	2024-06-05 10:33:49.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
63	\\x85a412d29da981c0b90613a0405cf2ceff5d978880260867f250b10ce5cec449	0	522	522	60	62	16	4	2024-06-05 10:33:51.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
64	\\x40d997892d8161005ef967077adcb54c81010132c61a78e021c1d32e1084d34d	0	531	531	61	63	7	4	2024-06-05 10:33:53.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
65	\\x6ff0a047b810f9462a5d2e565ab560b1d442a9955f155bd2f213965c76cbb2a0	0	534	534	62	64	13	4	2024-06-05 10:33:53.8	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
66	\\x99f0a1fc959c58a8605abb94f79b4b0b69824514c08f44549161b5b2b9eac086	0	550	550	63	65	5	4	2024-06-05 10:33:57	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
67	\\xa1bbd668ff193443471ff7b3e39ed1a1bccbb8b16e103a6b72f46571db8ed6ad	0	579	579	64	66	5	4	2024-06-05 10:34:02.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
68	\\x1a8416205935405d22527172b34c924033e9cc975a3ebf205f4dace2cff566f9	0	585	585	65	67	40	4	2024-06-05 10:34:04	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
69	\\x0b328f5c569090badc87463bf3ba42ca0b795329910ae37a436dba4f739bc615	0	586	586	66	68	13	4	2024-06-05 10:34:04.2	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
70	\\x49940e22d8170d7d80dd9d12257c14b65eb67315d98eeba8e066b980df107367	0	591	591	67	69	14	4	2024-06-05 10:34:05.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
71	\\x4e25c4d24d23bd8e187c42c79a4ab0d61360a97ec337cebafffe1a5da043eec1	0	596	596	68	70	40	4	2024-06-05 10:34:06.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
72	\\xb664d1fe615491907e4c3e8f44f6b7194d1453dd0e10fb7844fa3d16c158a591	0	627	627	69	71	21	4	2024-06-05 10:34:12.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
73	\\xb11bbd02dc3fd23f1cf06b5997ce580f4ef1dfc67a2925c3d3730981582284b8	0	632	632	70	72	4	4	2024-06-05 10:34:13.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
74	\\x913d13a0bb19ec1890e85a7858627e7ecc2548ab448f3d6bb4970996e2cad3d8	0	643	643	71	73	7	4	2024-06-05 10:34:15.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
75	\\xcdb4e5e751613cb6511eaff1f857453af998bac3823c7bcc4ba7267b1826cd59	0	673	673	72	74	21	4	2024-06-05 10:34:21.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
76	\\xeed5f93685c41e1c052083dd8dfc0a750db76aff438faa3f74ff34c443dd32d8	0	677	677	73	75	7	4	2024-06-05 10:34:22.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
77	\\xef0cf8fdbb3349d164dfd8246c45a326d673102975f2112ce1e2bd5773a98ea3	0	687	687	74	76	5	4	2024-06-05 10:34:24.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
78	\\x6ef6270faef3dc26b275bb286fc8ea865552cc9cdf8fc187f5312491534ef493	0	696	696	75	77	14	4	2024-06-05 10:34:26.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
79	\\x072224b086cddc0fc43d9499089695105dadabb4269d1ffe97092aa62a3cf5b8	0	705	705	76	78	12	4	2024-06-05 10:34:28	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
80	\\x72f2a4e13145c1c3eea5d92f9b1c33f79211e24e6360baab12a1adb5a057d9e6	0	713	713	77	79	21	4	2024-06-05 10:34:29.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
81	\\xbc361809500768415cf99c528af9137d133d0a9a40492b96f287b68459fabd36	0	724	724	78	80	14	4	2024-06-05 10:34:31.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
82	\\x0586cc5d0b0fbecb7ac2069392fec3ce6666ba7fb8cb1bdcb10eef4a17427bcc	0	735	735	79	81	40	4	2024-06-05 10:34:34	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
83	\\x42bd32d2c4f153a957aa260d511f188340607a8703e7491f536dc5d9671c6b20	0	737	737	80	82	4	4	2024-06-05 10:34:34.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
84	\\x2e32d4c04bb2d94a8a83b309c9610312d4a9a88022e72c6b3ed9da509ea2843f	0	770	770	81	83	3	4	2024-06-05 10:34:41	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
85	\\x2526041babfde11c7685a42cd7658981d966b962230c08cbc07d415d1cd584db	0	781	781	82	84	14	4	2024-06-05 10:34:43.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
86	\\xfc9e1cf5f1dbaf260fc2fda16942154ca89d5ca3280e68c8e6413dd492ed9e15	0	784	784	83	85	6	4	2024-06-05 10:34:43.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
87	\\x59419710a0889c088df4079637ef28d67bf94c7d63864a9f5f442acd6ea59c7d	0	787	787	84	86	5	4	2024-06-05 10:34:44.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
88	\\x18113eb021f92417f066348b9620778290415a4a4a31f607f133717665cedc70	0	789	789	85	87	40	4	2024-06-05 10:34:44.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
89	\\xe300db2103aeb8f57ee8d0d4e98393e4b5efb1b9aad0f1f3ab7e6895273bad83	0	795	795	86	88	3	4	2024-06-05 10:34:46	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
90	\\xa1fe7fb265c7b315e67510fca1cfc36afa2aaaa308ea56c867db1f2ce5fa23bd	0	803	803	87	89	12	4	2024-06-05 10:34:47.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
91	\\xf2d40df65b92dc2679c83baf4fa5ca907bc546f6ff4067f5c03a741ea9d2c26c	0	806	806	88	90	13	4	2024-06-05 10:34:48.2	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
92	\\x06794b69a83d3df878f12a86b3ce016b9841c11b9c3afeabbfdaddad215e49ae	0	822	822	89	91	40	4	2024-06-05 10:34:51.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
93	\\x4e5183d959159fc074740097e708cf08123fb46e79f3a5282651af1d3f70b026	0	837	837	90	92	12	4	2024-06-05 10:34:54.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
94	\\x8086919b69e036cb24dc147a872e11d559f1839ba90f27622fc47cd69c651464	0	839	839	91	93	5	4	2024-06-05 10:34:54.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
95	\\x4094cdcca5ed201a31129fb59b0238897bbd498211296bafc60ede587b136ab7	0	859	859	92	94	14	4	2024-06-05 10:34:58.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
96	\\x39794e1850518a39ea657942a3bd9f609cacf78c9ab86a3570366a58a5b18cb7	0	891	891	93	95	5	4	2024-06-05 10:35:05.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
97	\\x2b357b92541bfa3883eeccfa83e5ca022a9fc6f1b6a2b3fdf419259c41ee078c	0	911	911	94	96	40	4	2024-06-05 10:35:09.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
98	\\xbf5ed4ba2222a0ef40ce0a9ddc20c8cd86d24a867eecab47043f75a308c1a2d7	0	914	914	95	97	4	4	2024-06-05 10:35:09.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
99	\\x1289c2abbe9e98f304f52907e5d8d39f36848020ce3d3274a94a9b3490c8f821	0	955	955	96	98	40	4	2024-06-05 10:35:18	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
100	\\xa4af4fde332f48b83c0f4fb0dcb60ddbd3ae61e26963968bbcb0bdffabad6041	0	983	983	97	99	7	4	2024-06-05 10:35:23.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
101	\\x77e5c0a4ecaf18ed23e2ee6ef777edf577c5d6ab68f6b4b519f976df9ef0ac41	0	997	997	98	100	5	4	2024-06-05 10:35:26.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
102	\\xa0bd8ff19b5366a8c03c6f388aba202939125a7013c8044d71e550aaf9cf32b5	0	999	999	99	101	14	4	2024-06-05 10:35:26.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
103	\\x7d4876b6600091aa30a8747dc94730a33626824d31a852d208671cff6f36e7d0	1	1019	19	100	102	4	4	2024-06-05 10:35:30.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
104	\\x0ec771f3f736d285a215731d793d28a4e04e38b872e1bc42a063eaba14fe294c	1	1029	29	101	103	7	4	2024-06-05 10:35:32.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
105	\\xf3d31eb3640420ed93d945ed5c67a025a58398b742e3c3ea72e46e8767408b95	1	1031	31	102	104	40	4	2024-06-05 10:35:33.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
106	\\xc9666a4cc73adcf4b2c2ad8ca445080df13b5a19b83c3a1b3db6264ec3ea0747	1	1037	37	103	105	16	4	2024-06-05 10:35:34.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
107	\\xa9bb144a5f4740deed676639df526de292aec825920ecd26907bf488f6656a5d	1	1044	44	104	106	3	4	2024-06-05 10:35:35.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
108	\\xe25936601ac9bb74b3bf7b1d047218e3a997c1e19540bc3b083ebf51b1b3e4b1	1	1046	46	105	107	13	4	2024-06-05 10:35:36.2	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
109	\\x87e2be08986b5523b39b1223cc5e8267e39064bcc921555d1730194890a34650	1	1048	48	106	108	5	4	2024-06-05 10:35:36.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
110	\\x00b5d4d332ec67c2220c1de9a300d4107a9ebfa113de071dd74495132e4722c2	1	1053	53	107	109	5	4	2024-06-05 10:35:37.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
111	\\x7e4b038c0fca71f70f610116ed5e12f48df4944cffe93cbebc9ec9d7d07c16c4	1	1069	69	108	110	21	4	2024-06-05 10:35:40.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
112	\\x3db3b6eba3816fdf6f8328be0f5b3287325d38bcbf6ae6908ca27585e615c232	1	1075	75	109	111	5	4	2024-06-05 10:35:42	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
113	\\x0b2344df4b88facaec681577f7ff656b2620155b5136335bc89c7de6dd685aa1	1	1088	88	110	112	21	4	2024-06-05 10:35:44.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
114	\\x7225cf5be918c536cb1aeadfa9e345d11c4669b0144066ecd39878684bc353ee	1	1093	93	111	113	6	4	2024-06-05 10:35:45.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
115	\\x134538a97920d1b6021ffeb9abdc3fb1ca2967c99623f46e0ee9468df86546ba	1	1105	105	112	114	5	4	2024-06-05 10:35:48	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
116	\\x29a00c7205ff0a6fa2a14d941ab3fa9b9fcbae1be8874369128ca6f01e5aceda	1	1110	110	113	115	6	4	2024-06-05 10:35:49	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
117	\\x5f848a34eb2b69a13afcba349a6e761aaab1ae6cc002dc12d51f4e424fff6f51	1	1128	128	114	116	6	4	2024-06-05 10:35:52.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
118	\\x9a04820381114492b3bb08531d58d9eba44fc840c7971fa295b82be591947eda	1	1130	130	115	117	13	4	2024-06-05 10:35:53	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
119	\\x60e49df5ff0ff74a9ea0bd504b84481ff084b51e5935808cb9340bbc4830f506	1	1136	136	116	118	40	4	2024-06-05 10:35:54.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
120	\\x8e9746d36f484b444e628c5e2d05dbfb186bd3df97e509961540ef29c2e8f9f5	1	1147	147	117	119	21	4	2024-06-05 10:35:56.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
121	\\x4a0a7c8dec8fe69e004a3c444afaf013ad76b2e4e5d3d308a7737352534a8b99	1	1155	155	118	120	21	4	2024-06-05 10:35:58	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
122	\\x42e44d626c17d4c5e2f8d073bd37b7526ca07d5732dc504eaa6d23f6d62f04c1	1	1161	161	119	121	40	4	2024-06-05 10:35:59.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
123	\\xf38af353c5e5746c6ec1fcd50c499b8ad844e7628dc5332822dc3ef5bd37012e	1	1164	164	120	122	14	4	2024-06-05 10:35:59.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
124	\\x5dfc5d53a4020a0858089d5d1c3c44d03e0b047f3eb3a0c62cca902647c4743b	1	1178	178	121	123	6	4	2024-06-05 10:36:02.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
125	\\xe77be662227b7c38d9be8d5439e3df0c22b83a1caf1c2ac12db086058a2fe7bd	1	1228	228	122	124	12	4	2024-06-05 10:36:12.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
126	\\x86efc6db59f1175f670adf4ca04a15915412e0369268eb47d9432d67f3c4e344	1	1240	240	123	125	40	4	2024-06-05 10:36:15	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
129	\\xa5c391f4b2d72fc013cae6a59353e5137eb823df0ab03de8b92dcc4f1ccecc8a	1	1241	241	124	126	40	4	2024-06-05 10:36:15.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
130	\\xdfc1ad75d1189d1562ec261ddddbdd691cc0920503d21799cfb6f30ceed37d43	1	1245	245	125	129	3	4	2024-06-05 10:36:16	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
131	\\x9c6b0a02d8a3f3a6c9265bbae8bb8849c662a689e72aeb11e4495c64c546df04	1	1264	264	126	130	12	4	2024-06-05 10:36:19.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
132	\\x28c7ce74dcab47cb957ee94cff3c5e29b5205cbb313ea197b8225344189f1a3b	1	1265	265	127	131	4	4	2024-06-05 10:36:20	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
133	\\xdb8e644035c3efa0df2eac2c45895bfba979a4836cc364c0a841a543dc8109c8	1	1285	285	128	132	3	4	2024-06-05 10:36:24	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
134	\\x3a8e6b7c714270d2e8d80242fd0a2bd5ec1abfceae2f9750ffacadaa93950854	1	1288	288	129	133	16	4	2024-06-05 10:36:24.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
135	\\xf27a6756d59cffaba1eb403d3f4983249d890c003af2a1bc375ae59716cdff4a	1	1293	293	130	134	7	4	2024-06-05 10:36:25.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
136	\\xad00dca562767d76b16aabc41bb1e810f84a2f7b0b5dfd59f0af5f9d2ebd1aea	1	1294	294	131	135	6	4	2024-06-05 10:36:25.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
137	\\x1248b5684db055298fd57729af48f3869b885e2cf799c4e10f205310e5b1705b	1	1296	296	132	136	14	4	2024-06-05 10:36:26.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
138	\\xcb107d7f50477de1242749c56360d0aa33ec93723757221c5e1f0567808b0391	1	1311	311	133	137	13	4	2024-06-05 10:36:29.2	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
139	\\x5f2c1715d40a9a262b894f1d74e80386b3b98cd638371b0787539c4dad18d6f3	1	1315	315	134	138	5	4	2024-06-05 10:36:30	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
140	\\x0932304bce98e4e54d92783ae8f212314e530947b99fd9bccd380a54ceca2ba3	1	1316	316	135	139	21	4	2024-06-05 10:36:30.2	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
141	\\x129fc70328d7dc1a36f4717eccdfd78cf6dc3066ca0c957e4e49cd56dad7e1a0	1	1322	322	136	140	5	4	2024-06-05 10:36:31.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
142	\\xe8d019aa128e528b7b1cae76b7878f45304bfefccf7ff0e33e92cb6524a26c70	1	1339	339	137	141	14	4	2024-06-05 10:36:34.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
143	\\xa56c69ea22a01b5896e6b13d87060bde8de67532a833fc65da08c63a6d3c2a88	1	1350	350	138	142	3	4	2024-06-05 10:36:37	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
144	\\xab9df23d1f47fc416bcc79e3bd55a524244120149c0cdb41d47a5fdf4c4efb55	1	1376	376	139	143	4	4	2024-06-05 10:36:42.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
145	\\xce2d088d2d37f2e7d129c05222702e58bf5a66beeebdb89ccfb09290e89b5bfc	1	1383	383	140	144	13	4	2024-06-05 10:36:43.6	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
146	\\x2f36a5e8a352382d25b606012bc1bf7bb33f6c6f894b7eba128d1c550099f1a8	1	1384	384	141	145	3	4	2024-06-05 10:36:43.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
147	\\xbc4e034a5bd9d799d4627061e91517ed2edccc0e9577ad50913fd0471e8a64ee	1	1386	386	142	146	7	4	2024-06-05 10:36:44.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
148	\\x13467c32e397b9bc06a42ec0583d37cb58bc9e679e9d5b644569c6b10e7377bc	1	1397	397	143	147	12	4	2024-06-05 10:36:46.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
149	\\x11a9cfe54c06e9ec6317dca82a4ebdbf06b4b026968246061933e7be83db8134	1	1422	422	144	148	5	4	2024-06-05 10:36:51.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
150	\\x5dece74ab6501a7aa0f763cca9c9388ae8ee8f6696fb85c071d4509484ea6e72	1	1432	432	145	149	40	4	2024-06-05 10:36:53.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
151	\\x388738f974415a48167cf3ef32ac54fa8ae2195a35d417a0c6c91ff4632c0d01	1	1439	439	146	150	6	4	2024-06-05 10:36:54.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
152	\\x4cda536447211bbf9c4ac8529ca8f12caf2109f3f065008bb2351b6fadbf81dd	1	1442	442	147	151	40	4	2024-06-05 10:36:55.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
153	\\x8c9c388c40a61924eab2727da80b8855f83cb48f7b505d5fd5c855c8cf718245	1	1454	454	148	152	16	4	2024-06-05 10:36:57.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
154	\\x6b53457c74c16e817280a47b7ed2ce40a8e19439967a467d594cdd32f1c54b94	1	1457	457	149	153	14	4	2024-06-05 10:36:58.4	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
155	\\x355314ac6837c089c4572901046382b58441375f40a75ba08c57f07f0175ce2f	1	1469	469	150	154	12	4	2024-06-05 10:37:00.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
156	\\x2b635bdda4cb8bc1e69145a4d25240121f5fe81f1e7aa5a9b92a414d94b823ea	1	1474	474	151	155	6	4	2024-06-05 10:37:01.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
157	\\x771c2364e04f74e0c718422fd9b60f281affa0d951326258db5b4740fb07f1ca	1	1486	486	152	156	21	4	2024-06-05 10:37:04.2	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
158	\\xeb510d07c704fe3b5a8c5dc41ce7b5f44eba0ecc6ceb4ca8ccd1adc7e09c30bd	1	1505	505	153	157	16	4	2024-06-05 10:37:08	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
159	\\xe880fa9e3b5e7a429fe0f76efd4760dc677a72e5594b9fdbd6f282b79bcbcc2f	1	1552	552	154	158	7	4	2024-06-05 10:37:17.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
160	\\x7896b7f4a6a784c065b71afde3a56b2564de0cdc4717ee762a89348fff059bee	1	1559	559	155	159	3	4	2024-06-05 10:37:18.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
161	\\xa6a15f0c3b10ac07c71a807a49999d2e6f7f67e986ad7ee7815bbe873d3abec2	1	1563	563	156	160	21	4	2024-06-05 10:37:19.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
162	\\x8d3b090c4a7a7ca9495463cca4efc3442efeeac4960ea7b17572fa9949a7d9e6	1	1565	565	157	161	7	4	2024-06-05 10:37:20	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
163	\\x022cec1d122a553cd9634b8b313173ea47df4cef84908000859ca6c0d929c6e8	1	1618	618	158	162	16	4	2024-06-05 10:37:30.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
164	\\x601fc0a3c269d00dcc890a2c48b2cfecdaeef3fa25dc8fd58e793752033d920b	1	1623	623	159	163	6	4	2024-06-05 10:37:31.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
165	\\x53ab6be067e8791540db30409db7abfec98f4584894a4faecdae3b97d0a1e126	1	1626	626	160	164	12	4	2024-06-05 10:37:32.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
166	\\xa294d42b274a88879836a0f955cb6b4fbe6b29ae1a41b6d7f14bcb753d3b9555	1	1633	633	161	165	12	4	2024-06-05 10:37:33.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
167	\\xd27342a9266b49913849a2c3b5a052bfc471d9431e8447fb6609092b554e1ce9	1	1641	641	162	166	40	4	2024-06-05 10:37:35.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
168	\\x9dd850f8c80591eab28bf3c59fddd9df8420e47ea5dda4bd2dc5b8b3e5b8c7f7	1	1647	647	163	167	21	4	2024-06-05 10:37:36.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
169	\\x739ba8697e39050057d94443e342c3023194b66321fc6e83ea0e3c4e9a28456f	1	1655	655	164	168	12	4	2024-06-05 10:37:38	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
170	\\x89381c418be4f1ee7e145ca850e614f14d849264c58002ab586e6f19a13fda57	1	1657	657	165	169	14	4	2024-06-05 10:37:38.4	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
171	\\xdae2b4ca7bd92a9c110eb24f21dd9e9ead4a1b7528823759eabb733cb192a8da	1	1658	658	166	170	4	4	2024-06-05 10:37:38.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
172	\\x0698dd2fbaf6b2e989c7661b4e27dd8283367a0a00466d22955f93b8e0a57671	1	1701	701	167	171	12	4	2024-06-05 10:37:47.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
173	\\x92a37ee7c1ab82ad9bf74d4273ef6b172d13ff084601cfb93de0f5b60fb9c9f7	1	1719	719	168	172	21	4	2024-06-05 10:37:50.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
174	\\x4cedc81106252135e9c69fa4c7fd9bb85385fa847eb086db98a50be7bed73507	1	1740	740	169	173	40	4	2024-06-05 10:37:55	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
175	\\xfac94d2b3e10375c45a597db404f2c78c2fda658dd308bcf846459ed068a5d2e	1	1761	761	170	174	3	4	2024-06-05 10:37:59.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
176	\\xee37d30657ccb97523e9bc826e1ac75203a45dc42e054488fe40d600913f2e10	1	1766	766	171	175	14	4	2024-06-05 10:38:00.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
177	\\x701dc28987eaabc40d1b271d22dad92db0a98e8bbf132f9f4a0be8f320a35690	1	1768	768	172	176	4	4	2024-06-05 10:38:00.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
178	\\x656664d08fd96b4f7e0ddbc3e2dd90e28a43dc3671549079992ecc4894e677bf	1	1775	775	173	177	21	4	2024-06-05 10:38:02	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
179	\\x707988877de6c4f5fca5377ea2b32893e248af443cd7e05902859ad8cf9fa315	1	1784	784	174	178	4	4	2024-06-05 10:38:03.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
180	\\xdc19c6a28dcea7db8e25be2ef23b2231f3cca7558c8d7ab25f6c64120cff2354	1	1785	785	175	179	5	4	2024-06-05 10:38:04	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
181	\\x9093c80b3f7381d16e470b5deafe7b6d1362ef82acc06db2e6b9694807979b9e	1	1810	810	176	180	13	4	2024-06-05 10:38:09	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
182	\\x3c5f2d227857c42396223dd18422ea72bbaf4948bc8c7d09e8bef3641c637136	1	1814	814	177	181	3	4	2024-06-05 10:38:09.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
183	\\xf501798bdf9668fb357a2550a0fe310f200925ac9a553f1319be82da3cbcf79a	1	1815	815	178	182	16	4	2024-06-05 10:38:10	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
184	\\x11463ad014fad286e9a4ce7ed8557aef574e41d200b4afab87bd4f6af060d7cf	1	1824	824	179	183	3	4	2024-06-05 10:38:11.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
185	\\xa2aecabd371119b2a5b6b63f5eb6cf268ceffe5b6b4c6ecb7d41f73f4b7bbef1	1	1834	834	180	184	4	4	2024-06-05 10:38:13.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
186	\\x967e5620d9333ca8752a97b3aee00be673c90252a0eb2fc6a34219dc77dd44fc	1	1841	841	181	185	14	4	2024-06-05 10:38:15.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
187	\\x168395bf6e2164e0312cac2ab82577643fa8f0162ec341c8bf5c4d1e2088982b	1	1861	861	182	186	6	4	2024-06-05 10:38:19.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
188	\\x479160b40612b39d6f9a8a27454d1040475deb10b9797c0f3861d026c3ec3113	1	1868	868	183	187	7	4	2024-06-05 10:38:20.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
189	\\x3f1761f97b86f73052425381155992e56b2c78490585a83d2f220cbca7a7f4e6	1	1871	871	184	188	6	4	2024-06-05 10:38:21.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
190	\\xd3a7de10bce60a43fd656a9b04bcf7f2b23adeb13efa1ef75e2d1c20a5e376dc	1	1873	873	185	189	14	4	2024-06-05 10:38:21.6	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
191	\\x2b3f8713fe7cef9ec227a5d9e6df159de2f6823a45bd3406757829f8959118a3	1	1878	878	186	190	21	4	2024-06-05 10:38:22.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
192	\\xd6e533a34d601fe0b733816442fc6ae0c599e554848a2f5823c322209bf20b99	1	1886	886	187	191	7	4	2024-06-05 10:38:24.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
193	\\xf291aec3016ba532f21fbb26dec4690be5618bfcc74dfd33c56646e71b843673	1	1895	895	188	192	14	4	2024-06-05 10:38:26	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
194	\\xd9940794d4165637fd3db0d2d794c23fb59be8d3784f30f13247d16a9c6d3d84	1	1910	910	189	193	3	4	2024-06-05 10:38:29	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
195	\\x70c6b55fed73fc04e1106d8d64c88352b034690fa5cc45eec86421bd13256141	1	1911	911	190	194	6	4	2024-06-05 10:38:29.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
196	\\xbc3f25960c27834f06234746ab742a227e242ecd8a820f207ca8c03ff19c09a7	1	1913	913	191	195	6	4	2024-06-05 10:38:29.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
197	\\x89c348152b1f3807a0dc51c64c77d749fbdc3f4f65a2872d8f4e407aee261a93	1	1918	918	192	196	16	4	2024-06-05 10:38:30.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
198	\\xe2b51ba5d9e6929e25c496d4fb5ad3d27d925ff368b8229480093ed48d2dd475	1	1931	931	193	197	4	4	2024-06-05 10:38:33.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
199	\\x2c80d80e0ab8c6bc8f6515d3fba254213067c27fa4edad2c690bcff4e868b5d8	1	1944	944	194	198	7	4	2024-06-05 10:38:35.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
200	\\xbc22b7e2b03a36c699474e7d4ab4e9b6ce4d60924b16c7eda0532cb07b4ac3c0	1	1954	954	195	199	21	4	2024-06-05 10:38:37.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
201	\\xc93d96a1a1cfd7bd59eaed97087b6a0e59a7bc36eb6ee3ce459942f7942465ea	1	1958	958	196	200	12	4	2024-06-05 10:38:38.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
202	\\x83ee3e00c932888963be46ffafc45c6d57e49bbd10677405d4d585343f9ee1b2	1	1962	962	197	201	3	4	2024-06-05 10:38:39.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
203	\\x9c64975848fdfbb263cc70547cce240b19eeb8dc2ecbbded71f8c15e1dfabc9e	1	1971	971	198	202	40	4	2024-06-05 10:38:41.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
204	\\x5f5f1fb6b4ce88174fc2f42356930ef6535233c87ec05bdcb51039f0d07f3225	1	1992	992	199	203	40	4	2024-06-05 10:38:45.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
205	\\xa72b770bd95d979b3afe4ce45d9c9f7948e2fb5c5e191d11c37b9b442a6fded7	1	1994	994	200	204	4	4	2024-06-05 10:38:45.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
206	\\xb1812966e8056c6e4b80c22988fa18da1ff3609b2edb6e8150cf84a87ae671ed	2	2011	11	201	205	3	4	2024-06-05 10:38:49.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
207	\\xff2a392c02aa010340ea9089eb45a6ef9260d65727e32efce1e53b21b24a1f4b	2	2040	40	202	206	16	4	2024-06-05 10:38:55	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
208	\\xe25e77fb915fefdc5aaf9e72464dbbc60a8c6c653a7df4b23c8d1363de202c81	2	2052	52	203	207	3	4	2024-06-05 10:38:57.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
209	\\xc194d12b6e4070e891a22c0ff97013c43fae992383c2e68fdb1dcd1643dc6bfa	2	2070	70	204	208	40	4	2024-06-05 10:39:01	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
210	\\x7a36b65583cb5ff134b62eb473464d1e2c6f8a717c4d9fc6c7848f8f4a064d62	2	2071	71	205	209	14	4	2024-06-05 10:39:01.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
211	\\x95b219f20c6d746ffeb52ce4fc4f17b3f9897c9091f0a38d3f338012774f03f5	2	2072	72	206	210	6	4	2024-06-05 10:39:01.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
212	\\xd9a5e4643861045ffd19bf5ff745723a2d9a1ff7bcc215524e9d59fc991e8bfd	2	2074	74	207	211	16	4	2024-06-05 10:39:01.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
213	\\x2ab5662286bbecb03f35db2dfb33f66c0935a3337011990bf39217084d44fae0	2	2079	79	208	212	21	4	2024-06-05 10:39:02.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
214	\\x0acdf62e88d3fc54502aa94964d850865fff0bf1f907786ac7cbf896e6a360a1	2	2099	99	209	213	6	4	2024-06-05 10:39:06.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
215	\\x1a97c887e984b49704f9be080ed208566ca8028a69d18705e08dbd6d4ef7afdc	2	2103	103	210	214	16	4	2024-06-05 10:39:07.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
216	\\xc751ac211ddbd901ec37684196bd57aed1a1ce9ec3a6c6485f6c26e6d2df97b2	2	2109	109	211	215	13	4	2024-06-05 10:39:08.8	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
217	\\x59dd51dedc5b79e2e5646c642c41adb10894f4598fe1832365971cc7baa009da	2	2118	118	212	216	7	4	2024-06-05 10:39:10.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
218	\\xf39f1c39345eb8820331d2c24c9712f7502397d0961b41b5a304c8c567cb27fd	2	2124	124	213	217	3	4	2024-06-05 10:39:11.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
219	\\x41542be5d08d146407c4b862f2125d40e61aecdf91c21138f313442917eed0ad	2	2128	128	214	218	21	4	2024-06-05 10:39:12.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
220	\\x21a53c9ba272c6442ae98d6579d9cfec1141278d49bc0285c7b09a8f623042af	2	2141	141	215	219	12	4	2024-06-05 10:39:15.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
221	\\xb4146325d2f7f4ce9369a4aa81426857cef69130789004a73623353b29d908b1	2	2144	144	216	220	21	4	2024-06-05 10:39:15.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
222	\\xe9e09a6f6217fd6d7a728815956bb7f90f4580435ef6f67a8d93403130c48950	2	2158	158	217	221	21	4	2024-06-05 10:39:18.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
223	\\x770ed06ade29d5dd3b6c3bd14e365dae0a9188821fc0794a6550a4a1df92cfa9	2	2161	161	218	222	3	4	2024-06-05 10:39:19.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
224	\\x69f38afced9aef95e33ce0fd6945c2e136fa116082a4d22f4fb1e69a19ecd1f0	2	2172	172	219	223	6	4	2024-06-05 10:39:21.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
225	\\x63a442a3a38d2835eb2baff677dc013f9e7967393f832a6dcf2ab4f19aaba63a	2	2185	185	220	224	21	4	2024-06-05 10:39:24	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
227	\\x7e1c32e7ef734a085924a6d30276f9dcd5b21dfb94fd829d00b930f7cdcd296c	2	2189	189	221	225	14	4	2024-06-05 10:39:24.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
228	\\x325de8a5cb77c5a05371321017aedc02e8a6228419d732cb81747cd28c166c73	2	2192	192	222	227	3	4	2024-06-05 10:39:25.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
229	\\x506877b821d3108062f819388022523bff4e3a657af56f4d2a37dbe0adf83c32	2	2196	196	223	228	5	4	2024-06-05 10:39:26.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
230	\\x6d1389f213efd7a90cf4d8633e7760b79978b9ff7eb61db0bd8890a54516d2af	2	2202	202	224	229	6	4	2024-06-05 10:39:27.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
231	\\x400a3d4af01dba8ace5fc1f1befbdee34734076e7737fb06398524dca963a38e	2	2211	211	225	230	6	4	2024-06-05 10:39:29.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
232	\\x1bf125d4c6ceee8ebe317297d422520cba15462d8b081646657ede7f221c2e38	2	2218	218	226	231	12	4	2024-06-05 10:39:30.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
233	\\xf195355842fb791018f4cbff67a7b200d6518435f4b63545956832f8428ac790	2	2221	221	227	232	13	284	2024-06-05 10:39:31.2	1	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
234	\\x4c2dabe77ec84cefa79e01902102c94651c0e4a41a3340b84e47298cb3df39c7	2	2235	235	228	233	13	1704	2024-06-05 10:39:34	1	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
235	\\x689f5395dd0366a17f73ce367765e88f3160d3b66e8ddbc2951631d9b55c86a9	2	2238	238	229	234	5	4	2024-06-05 10:39:34.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
236	\\x6286fbcb05cc38215af401810bfaef85bd917c0045206034361e5903ac097e8d	2	2239	239	230	235	3	4	2024-06-05 10:39:34.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
237	\\x086e4577d997e4474b2c79d2c524903aa7fedb807bac3d80cb11368c1025d259	2	2242	242	231	236	16	4	2024-06-05 10:39:35.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
238	\\xe4b71deeaaa306d1cf05a8265e33647cb5fe5a5f7f2cf6f040609511708158e3	2	2248	248	232	237	3	1415	2024-06-05 10:39:36.6	1	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
239	\\xf44cf5f03b3c268b6d9b9ebd43d197027da7e771e0512fe4ef7d19a37f0f6fac	2	2251	251	233	238	14	4	2024-06-05 10:39:37.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
240	\\x3937efac08ba69b782e1b62dc1d17493f717c7c0d4694d5674cdf7d6bd04f564	2	2269	269	234	239	3	4	2024-06-05 10:39:40.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
241	\\x41021ddec4d36db0f60c1b3d3f98a876f8e0eda3300f95ca1ec88d4dd4f951b4	2	2273	273	235	240	40	4	2024-06-05 10:39:41.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
242	\\x7ab7d9e2c51505d06819748c93a82bcb54ce6b87a5aa4cd626049245c2f335ef	2	2293	293	236	241	6	1545	2024-06-05 10:39:45.6	1	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
243	\\x421b6a37b31ad8974d9afdcbf0eb4358f3ab924ce8ebfce38458fd9ed0315cab	2	2297	297	237	242	21	4	2024-06-05 10:39:46.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
244	\\x4eef54ed38203de512032d4af25bb2591a971c964b022505c421dd5e6472e5bb	2	2298	298	238	243	3	4	2024-06-05 10:39:46.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
245	\\x5899358a246b5844d15b397598f3431099e989468e30d10facb34bf6c8e1a6d2	2	2303	303	239	244	13	4	2024-06-05 10:39:47.6	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
246	\\x54ed55324ea3ab146bd43f2e3b2ba38ca66ec702320b6fe576e28725a5c72a7d	2	2321	321	240	245	6	716	2024-06-05 10:39:51.2	1	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
247	\\x50c56e64b17814df03fad65aae752864755e555af3d5e83887ff1d3fb9f0ae32	2	2325	325	241	246	3	4	2024-06-05 10:39:52	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
248	\\x1addd8433c38eda663d0c71e5b42aba107a26cff2748c3a16d0e2c38fcc0f852	2	2327	327	242	247	13	4	2024-06-05 10:39:52.4	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
249	\\xfd09767df932a0111e2d0a8dc93ee34ed899704c27d3e2798f468ef04c237e3b	2	2330	330	243	248	12	4	2024-06-05 10:39:53	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
250	\\x9dc9d7a26e1e2b94c2c5af5f547baad8673393ccf0059087c5f4c5e914a0f1ee	2	2342	342	244	249	7	511	2024-06-05 10:39:55.4	1	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
251	\\x4d47351f4f799ee0950f0072078788c246c9f73d968c992f01486025767149a9	2	2371	371	245	250	21	4	2024-06-05 10:40:01.2	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
252	\\xd92ba10a873ecd6feec29e8ae39e3de72fdc6ab31f3875f0b983bf7a451d086f	2	2380	380	246	251	13	4	2024-06-05 10:40:03	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
253	\\xcd97712f3265be2ba6f1ba73438de6178540897563504e45305ba613ae3a3209	2	2400	400	247	252	3	4	2024-06-05 10:40:07	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
254	\\xbfd76530c96a9cd2c240fdb0a4e7eaf5880c9605f2f793dcd7d73595f84a66e4	2	2407	407	248	253	16	397	2024-06-05 10:40:08.4	1	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
255	\\x90d91d14c88a62120ed661295d5aaac0464f731b20a7bf8279fcad713b3c5d61	2	2409	409	249	254	16	4	2024-06-05 10:40:08.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
256	\\xfd30f44a76e73bf463c07a5712624317e71560d10d208cfe89fbedf6c54df8e6	2	2426	426	250	255	5	4	2024-06-05 10:40:12.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
257	\\x807ea14f0ccfc3263c2fe8b03ed7b0dd594dc88005f16c23c01adcb459ae954e	2	2438	438	251	256	21	4	2024-06-05 10:40:14.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
258	\\x4ce76790d018bccdfd7028622826460f0edb31ea5cbfcb188375edd4e919b963	2	2440	440	252	257	6	366	2024-06-05 10:40:15	1	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
259	\\x3df93a74415e16ab9496cf79309202e66a533059657a78792843954579fb0a3e	2	2442	442	253	258	13	4	2024-06-05 10:40:15.4	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
260	\\x80ebb183865fd95c9001a5e5d41ecd192768f3a598ee83779249fc4e8ef05958	2	2460	460	254	259	13	4	2024-06-05 10:40:19	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
261	\\x60eb833c6bc5a82418a4bacccc2c7783333c556b49b50b789f0d5a0000f186d5	2	2462	462	255	260	6	4	2024-06-05 10:40:19.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
262	\\x5c051fe688d743d61860cc5aba5a28794f275a1d4013f0e06e2d8e0147b854eb	2	2482	482	256	261	40	401	2024-06-05 10:40:23.4	1	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
263	\\xc98b839a46728418709ca8f1b8b624a8a3e3a469b7eea8d196dd689ab0f0f9a7	2	2495	495	257	262	13	4	2024-06-05 10:40:26	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
264	\\x3dde58f1138be0b257a2c62b66a4c7c0e12884eb39dd23418d6eafd04cb516f3	2	2500	500	258	263	40	4	2024-06-05 10:40:27	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
265	\\x845f150af6f19776a3bedc50d793fe211634640b110a717b35412f5ce137d00c	2	2511	511	259	264	7	4	2024-06-05 10:40:29.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
266	\\x09282cfdb1202dc711c2ce26f16e2c6cce33f354cf7a59c77bd9d6a736525e04	2	2520	520	260	265	12	749	2024-06-05 10:40:31	1	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
267	\\x467f65e4ef12e6e14385602360f0a1bffa51136ac5562948c535886117979969	2	2521	521	261	266	4	4	2024-06-05 10:40:31.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
268	\\x23c9f360e8202a4f7b1429ab2875e028acf910a5dbff95bd032411110a231b7a	2	2525	525	262	267	12	4	2024-06-05 10:40:32	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
269	\\x13bfb0575cee0c2fed271259f7c208c49c7eb798e6872e34bf636bbfc17f6c43	2	2528	528	263	268	6	4	2024-06-05 10:40:32.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
270	\\x8dc98b4064c0b04ab2c00b33d98b8d2236bf869a7a8de4ecb6e1f9f4f4036411	2	2540	540	264	269	21	749	2024-06-05 10:40:35	1	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
271	\\xac76b2f4bfd9dc0575018f11aab58de3cc1e4b0ba30334b53c721efca23a45ee	2	2545	545	265	270	40	4	2024-06-05 10:40:36	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
272	\\xeb7868829852d9ae9a39dad43fa7947eab7becc46632f8da2ddf24f728e95a73	2	2552	552	266	271	6	4	2024-06-05 10:40:37.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
273	\\x5d82012f98fc3cc70fda60f45124708c0b2a7dc03192d7066b59cff8187a5e4f	2	2576	576	267	272	4	4	2024-06-05 10:40:42.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
274	\\xc810c337924f2a4f9eea9557ba4088ab9e2b637a41f6d722630fb82e5c82112b	2	2579	579	268	273	13	336	2024-06-05 10:40:42.8	1	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
275	\\x33cb3db55002a5df63220d9a2ff85f67f2e588689055f1d2bcf69f09083e0b99	2	2584	584	269	274	7	4	2024-06-05 10:40:43.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
276	\\xcfc92f89dda7aaadcb07060ffbc56db837e48dca5cee3df3f1881a40b03f9fd2	2	2585	585	270	275	16	4	2024-06-05 10:40:44	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
277	\\x4d8c93574b2e750dae4cffec8bc3b1e4f6ffa887b6607547a334f767819697fd	2	2589	589	271	276	14	4	2024-06-05 10:40:44.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
278	\\x5aec60c7f57d1bc3a404aa207615adae1a297f72d417942e8f36bfe349f2f045	2	2591	591	272	277	14	745	2024-06-05 10:40:45.2	1	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
279	\\x91e6b89fdc48cc547582aff9bff7fcab2144b2a6bcc48cca8289e6387d77aa9a	2	2606	606	273	278	40	4	2024-06-05 10:40:48.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
280	\\x03ccdffa50ab461db6238935da47f276fb380cc708cbf604908e2fbe23f23c03	2	2636	636	274	279	16	4	2024-06-05 10:40:54.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
281	\\xd5cba9b0b361e643e19eec54e5c64f74e2900e1d4de6bdbbdea7c7d79fa5943a	2	2645	645	275	280	12	4	2024-06-05 10:40:56	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
282	\\xda484ed8a3e99f5783e9675e4c6df05af4fb364e7c79569e94884a2808defff1	2	2661	661	276	281	5	300	2024-06-05 10:40:59.2	1	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
283	\\x41fc015c6cef615c115211c886cbbff1c53c9ee0278421f0c9cef75ad919e2d2	2	2665	665	277	282	40	4	2024-06-05 10:41:00	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
284	\\x29de59385c0d3b7e9188ab9e51b7dddd8101bfafab8b97627966f9e031a38432	2	2678	678	278	283	3	4	2024-06-05 10:41:02.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
285	\\xbd63b0bb8733e86a9131dee93a1a12ca88e27ca6242b431367a3eb36b1844a1a	2	2682	682	279	284	40	4	2024-06-05 10:41:03.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
286	\\x4367e29d07b799474d428d8c5ab8372573be7fb20ea7fdbef8d6ed373df5bce1	2	2687	687	280	285	40	785	2024-06-05 10:41:04.4	1	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
287	\\xd3e5f08b30fa4e07e3f99b564400756c5f2c67491f32f76dc567c55c25eb8b81	2	2688	688	281	286	13	4	2024-06-05 10:41:04.6	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
288	\\xc40051be26989d0287abaf5a185e143420127263930882d5e4f7ffddcc80f438	2	2692	692	282	287	40	4	2024-06-05 10:41:05.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
289	\\xbc6545fe67ee931d89225cedf5536eeacd2347f8b777088197846fda7fa953ce	2	2703	703	283	288	12	4	2024-06-05 10:41:07.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
290	\\x72f0a63faf78bc3e809c21083d30475f6cc53788b45edca419635e57489944a4	2	2720	720	284	289	21	342	2024-06-05 10:41:11	1	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
291	\\x4d2c57ccfbe5528661ddc6f521c0cf65ea1d3bda02cd6fdeb0f4b0ca2af5742a	2	2754	754	285	290	40	4	2024-06-05 10:41:17.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
292	\\x249effde0256125a29447a7491c85723d4476595fd189f525e537b9488abf90b	2	2760	760	286	291	14	4	2024-06-05 10:41:19	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
293	\\xd127c5dc5cbba9f65d210cba6bcd4aa22a96ea0f0d89c0630b03978ea8d513f0	2	2763	763	287	292	14	4	2024-06-05 10:41:19.6	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
294	\\x1aa8af8b3942ba6529c32bb03eba2c1faba6a272543844d144f75da62c3d562f	2	2766	766	288	293	5	300	2024-06-05 10:41:20.2	1	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
295	\\x51bbfd715d0f888926726b6d4da9a4ad86fadb2beb48db567d43bd0db27c8703	2	2767	767	289	294	3	4	2024-06-05 10:41:20.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
297	\\xec652bb49e6a83961f6dc3314b1cafe9e3626013b9d6e40af90114bd9b947cbc	2	2774	774	290	295	21	4	2024-06-05 10:41:21.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
298	\\xf9df3d0634ec81c1ed595bf9a419bfad4d74824bd4fba3007f80c748829fb9c3	2	2809	809	291	297	40	4	2024-06-05 10:41:28.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
299	\\x1f03a867a07481c3e2209aaca6117937de0c1eb4e0232158786893fc012ddc58	2	2811	811	292	298	16	4	2024-06-05 10:41:29.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
300	\\xd3ee95be2315a173c2b1adbc3abbef037021786bc457a28f8c73d05eb625caaa	2	2822	822	293	299	40	1140	2024-06-05 10:41:31.4	1	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
301	\\xb7e8ff2e5170adde26ff440d114fbbf1970cc0d5cd4b69a3000b935dd397c7d1	2	2832	832	294	300	7	4	2024-06-05 10:41:33.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
302	\\x8898c4530b2b3a460ae6e33a4552ab173bee17ee65e713f1d07ef1b54275b674	2	2837	837	295	301	13	4	2024-06-05 10:41:34.4	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
303	\\xb58b1c063f69987ac718186288698d8d7d1849e77cf75fd35a00a95139b2d1d4	2	2843	843	296	302	14	4	2024-06-05 10:41:35.6	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
304	\\x3283fd55fea8041b02adb2eb7262dc78bf7ee5e74594b5495b81d295d3f26e22	2	2856	856	297	303	14	558	2024-06-05 10:41:38.2	1	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
305	\\x5dbfd241892b75bbcd0720fba44c4cc345891e56bb56dd020b996efdd4caff69	2	2857	857	298	304	40	4	2024-06-05 10:41:38.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
306	\\xffc86a8154f8b902cb97bac5dff40246414771180772d681676a6bfd9f8ad8ca	2	2860	860	299	305	21	4	2024-06-05 10:41:39	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
308	\\x61a9f7ac3bac7ca2a89dd10085a2b308e359210c8ffb46c1929d58d47fc37506	2	2864	864	300	306	13	4	2024-06-05 10:41:39.8	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
309	\\x43525a55c751f23fe533379ebf65124ed0828395e4f35e02b54bbc8648e81ffc	2	2884	884	301	308	21	811	2024-06-05 10:41:43.8	1	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
310	\\x85269c6e8d19b47f6cee8526ee0c7c5bb45d828fe14a55e2c957f4b07162e254	2	2909	909	302	309	14	4	2024-06-05 10:41:48.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
311	\\xb86e003c561be06b2154c10f9b078896c139e3a3760b714348a6209c35e96e84	2	2918	918	303	310	14	4	2024-06-05 10:41:50.6	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
312	\\x31f42be29399aed2c44436edbd34be27b59e05a7f66e3dfa5b76cd991532a384	2	2926	926	304	311	12	4	2024-06-05 10:41:52.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
313	\\x6bf58537b3bee7401b09930931eb4ba4014a4d2f9c85debf9ece4c182ae482a1	2	2930	930	305	312	14	763	2024-06-05 10:41:53	1	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
314	\\x653b34a500db8cda70a345c60c2a2432b08b3864a29dd89fa66f5f371b7f93d4	2	2935	935	306	313	40	4	2024-06-05 10:41:54	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
315	\\x180fdcd576efd63839ba7498e3e373838435fd3d66c192025ffd8cfd362fb74b	2	2940	940	307	314	4	4	2024-06-05 10:41:55	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
316	\\xdfa816f7905eafcd13b43941adca6d098e13dd86c114a79003f9f8cfe518abcb	2	2943	943	308	315	5	4	2024-06-05 10:41:55.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
317	\\x0437f7fcb997d4dce41c0617a77a656491a27a348a3ddd3f69227ebb6ec5940e	2	2945	945	309	316	6	745	2024-06-05 10:41:56	1	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
318	\\xd3744efd501765058ad8f75c6d7881c059855ed251a9b8fc62be007470a92b84	2	2962	962	310	317	40	4	2024-06-05 10:41:59.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
319	\\x0b132e0d8897bbfc0face5aea1f9089a413ea63c46027dfd79552d9c301d545e	2	2964	964	311	318	12	4	2024-06-05 10:41:59.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
320	\\xd92d58570a88eee14e1f202ee1efbe68517ade4031fe9a3896907fdb04623861	2	2966	966	312	319	5	4	2024-06-05 10:42:00.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
321	\\xb4794ef3ae1ca9dbada0af880c3a151cff9e0b3e1fb75ed40ba83b8124239a32	2	2980	980	313	320	16	575	2024-06-05 10:42:03	1	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
322	\\x10ffe08537c8ff8a426f42ce8cc7e101e4718857756a742e45c4d50dc6c5bfc1	2	2981	981	314	321	21	4	2024-06-05 10:42:03.2	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
323	\\x77f855472ab4c2e94dba17a5a317a2a9f4d25436d70e2060371f050b7dfd201c	2	2987	987	315	322	6	4	2024-06-05 10:42:04.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
324	\\x8600e30a1facd591c6af64d33525053378e1e5412a29abfceef4e0fbc72f1f98	2	2988	988	316	323	6	4	2024-06-05 10:42:04.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
325	\\x0016c9f8b2617b8e3921a6fed4b459326ea86eb87c3175b1c4ab4d2ede0815a1	2	2992	992	317	324	7	4	2024-06-05 10:42:05.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
326	\\x21eeb2f06f6bb110c2ccb31c1d37f988d558b658a3132bb24137e0aa2b152fc2	2	2994	994	318	325	21	4	2024-06-05 10:42:05.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
327	\\x0a5e37ea4d6a6eb443baa4210dccea35283728f44f25b24101beb98364540263	2	2997	997	319	326	13	4	2024-06-05 10:42:06.4	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
328	\\xc32f6f2dbadbcbaa63a32e1f836fb4aaebf7615a44dd468106c6cfcf3d2d0bbb	3	3026	26	320	327	6	4	2024-06-05 10:42:12.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
329	\\x7ceb30664084b3358cbd6fbb0fe08e57cf7c99fabc346911eafebeb19ee1bac0	3	3030	30	321	328	12	644	2024-06-05 10:42:13	1	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
330	\\x887e59562ae01cd7352c3ff5acd96a03cac991283b56b3717e6cff0ce8d69831	3	3041	41	322	329	13	4	2024-06-05 10:42:15.2	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
331	\\x9549f8c96759426a6ae3ab74971b50a321e79102a193ab6dc62c35092ce0839e	3	3052	52	323	330	6	4	2024-06-05 10:42:17.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
332	\\x659af727d39cade30870529f4c8562943a41a93f6b61f9fd84bc059db43d1bc3	3	3057	57	324	331	13	4	2024-06-05 10:42:18.4	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
333	\\x47ade04d417581449742582ccfe08b773ea0102ea9f019e2ac76e75b0506ff35	3	3058	58	325	332	13	535	2024-06-05 10:42:18.6	1	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
334	\\xf0d4996a4bc3047b542e87bfefb98dcdddd972c1bb856700c1f097ae5c6a5926	3	3061	61	326	333	6	4	2024-06-05 10:42:19.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
335	\\x984441a3263bd60348008010c452aa2ab63f2654daf5ce7f269d957a54b314d5	3	3070	70	327	334	6	4	2024-06-05 10:42:21	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
336	\\xed5928e17a464629d3a3f1875ae23b88aab77d1cb8f2d2f8e2837194a0f9a1a7	3	3074	74	328	335	6	4	2024-06-05 10:42:21.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
337	\\x0b72539b77eb8ea8aeb53a784efbc5c68f716dc298baf66309464be394af0e12	3	3079	79	329	336	16	4	2024-06-05 10:42:22.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
338	\\x32e158dd253232dd989d9967ba22e60c740c37998f80cb3929580a9d6209576a	3	3115	115	330	337	7	537	2024-06-05 10:42:30	1	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
339	\\x4f0b6bae106427c621b65860c738393b6e1c704d38321d8938976f613fe67b29	3	3117	117	331	338	3	4	2024-06-05 10:42:30.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
340	\\x9a0f4f308964e5ada90fff01a4d348942504d1d7a43b902ccfffbfb31b05209e	3	3120	120	332	339	13	4	2024-06-05 10:42:31	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
341	\\xa9cd064ee62fadf9efedd6025053d021f401733fb860edd6be2207f4f21072b2	3	3126	126	333	340	40	4	2024-06-05 10:42:32.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
342	\\x4b0e0f107d87edb62f3cf34f7213be176aaa914c4913788fcedeeddc349ab602	3	3159	159	334	341	7	397	2024-06-05 10:42:38.8	1	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
343	\\x71b2f3980f239a5c8cf1376290abc00ca57f3dc219da3b9aa95ab270c8239ec7	3	3167	167	335	342	6	4	2024-06-05 10:42:40.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
344	\\x27ce3b8afd8c8f44d47b4f30d796c73cb6f8c2029ca3f38c960afb502bc2ed97	3	3170	170	336	343	4	4	2024-06-05 10:42:41	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
345	\\x232f82cae33a3eaa16648f27db6fa70fed236cd45af9900424a446e196534b8c	3	3190	190	337	344	21	4	2024-06-05 10:42:45	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
346	\\xae141a4a7abad7d444d8920fb9e4bf83908dce37abe3703507fc9d39beda0318	3	3195	195	338	345	21	4	2024-06-05 10:42:46	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
347	\\xb323f8496ea44b69defe5ecef170d4e4da3f205d3eb6388d544f664978a7a228	3	3214	214	339	346	7	8236	2024-06-05 10:42:49.8	1	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
348	\\x27bfcce341893ee709a9ab7b323861d79a7b3ceb242843cb9e861d72dcee6695	3	3220	220	340	347	12	8410	2024-06-05 10:42:51	1	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
349	\\xbea75f435009f009b1f624bc63462fcd5cc1eb5afa5ee78ee35dda5a483b571d	3	3231	231	341	348	12	2847	2024-06-05 10:42:53.2	2	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
350	\\xa24c173b6c6d7548c414e0ebe62104a89c704673c9b297dde599ef2fa91de60c	3	3241	241	342	349	13	4	2024-06-05 10:42:55.2	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
351	\\x9cb2b04ac4640e6f100ab52f66f804cb186045eeaffa477185b2574d5bd24343	3	3245	245	343	350	7	4	2024-06-05 10:42:56	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
352	\\xb84d680f72d4cc792abae0d6e1ba2e7f87ee4c5bccaed6de13d32949ceafc82b	3	3252	252	344	351	16	4	2024-06-05 10:42:57.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
353	\\x378e8cd127e369c9d5c3acc3fd195d573650c18a85f014dc4bbb929b4d5c2737	3	3260	260	345	352	40	4	2024-06-05 10:42:59	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
354	\\x68145eaaf93143e21c561bbb3bfd122a15ba05728c3f2780380aedcad467b41d	3	3282	282	346	353	4	4	2024-06-05 10:43:03.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
355	\\x49efa36e23d6a6ebb4dea35c6862307934956d08dda5a40a05e49c520b7bec5d	3	3287	287	347	354	7	4	2024-06-05 10:43:04.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
356	\\xc190d97f3a24738b423d00df4009967ff5b85f7957a71ddd772ec3e7bf8d52ed	3	3291	291	348	355	7	337	2024-06-05 10:43:05.2	1	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
357	\\xf4aa61f49357afd003b088f97f18dcc979e96c94247b59179b82bc6e774b055a	3	3297	297	349	356	40	4	2024-06-05 10:43:06.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
358	\\xddf47c24629dbeac5a3f0c19da4efaffa8d109e1ec2c661a5f02b925d7b0b6e8	3	3312	312	350	357	5	293	2024-06-05 10:43:09.4	1	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
359	\\xba15db4c90a9e384c89dff86cc1d38f9d8d6c0e5edb0e6d9b6f1f28fe21792d1	3	3345	345	351	358	3	293	2024-06-05 10:43:16	1	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
360	\\x9ab0cb35093dda91b2fae45bd64ab5fb557bf201bcbdff060bbfa7a75abcff35	3	3349	349	352	359	12	592	2024-06-05 10:43:16.8	1	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
361	\\xbd6962e3594b2d3b370b178fbb800e9a8ae660df955aba2239873784a95241c5	3	3365	365	353	360	14	4	2024-06-05 10:43:20	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
362	\\x95a55dba9d3257b666011d99b5a09a9c647eebb3cf1009d3a116eb1bd303fd9f	3	3368	368	354	361	3	4	2024-06-05 10:43:20.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
363	\\xe6a20938a9bd9d11f061237e540958a6d950f043d02ff9545b1609c48f9a1900	3	3378	378	355	362	6	4	2024-06-05 10:43:22.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
364	\\xa8837454b700fd1c92b5991c16c6f5d9a914edac78fca4391f8133e25645cc81	3	3385	385	356	363	21	4	2024-06-05 10:43:24	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
365	\\x6b783ed46f2f511f4b56397cce8e2257435ab9d65ae8b5e1d88aa2955f814407	3	3397	397	357	364	12	4	2024-06-05 10:43:26.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
366	\\xd04222698627dee7c30a4efc2e97f338708433739fb8698a61a09c1b8b314ede	3	3411	411	358	365	21	4	2024-06-05 10:43:29.2	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
367	\\xc7293582a0449d50dc824350265149254d37fa3568cd97b9759fbba26c5a14cd	3	3419	419	359	366	6	4	2024-06-05 10:43:30.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
368	\\x03e78f9e53fea2627f6fdd04ab2d224e9c1c26e5ed2e0bb83c8eada3011452a5	3	3457	457	360	367	40	293	2024-06-05 10:43:38.4	1	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
369	\\x694f2beb216710aaafe8b06cec8ac6549f9d496e4d878bc427dffa8d197b06ec	3	3466	466	361	368	21	692	2024-06-05 10:43:40.2	1	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
370	\\x1967563b7c26d59d042215e4daec2d81a5c14569a6f3d6193da7998a7214e5cc	3	3474	474	362	369	13	563	2024-06-05 10:43:41.8	1	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
371	\\x590135ab3a58e372dd6d5ccd50759248072c8926c7bfe8ffde107a69dd1e1fc8	3	3479	479	363	370	3	4	2024-06-05 10:43:42.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
372	\\x6ebc99bf5eded46294a5a09ceb0a05bb216a523e6e69b5161a551b9c85776026	3	3491	491	364	371	4	293	2024-06-05 10:43:45.2	1	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
373	\\x8b29202dec1a924da84cc30a9312dcfa5151f6a85ca8b8bdee52347e78519afd	3	3493	493	365	372	40	4	2024-06-05 10:43:45.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
374	\\xee1dc2443e259a157aa627b28ee8606d985f5be5d38496467a184a8b334a6ed7	3	3500	500	366	373	6	4	2024-06-05 10:43:47	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
375	\\x821eb000c3ac0813ca9b931c18348d88a720246c8c11a4cec9d25264f9802cda	3	3525	525	367	374	16	4	2024-06-05 10:43:52	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
376	\\xb44a0f164565099078e69cbb335eae4548bdc3113461fa5614d4779be53768cd	3	3541	541	368	375	12	3850	2024-06-05 10:43:55.2	1	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
377	\\x0e9399d4110d12738e253014b8553518ef2161ddd054f68ffac6797898b9a7cc	3	3544	544	369	376	13	4	2024-06-05 10:43:55.8	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
378	\\x1d610197bb414ef332a377b31e0ea0f840c1c1e3d5cad47917a86583e940dd7f	3	3553	553	370	377	7	4	2024-06-05 10:43:57.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
379	\\x912280a78b072b38658104fb7860d43a42a9eb20716f910749784e9894d3f69c	3	3560	560	371	378	12	4	2024-06-05 10:43:59	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
380	\\xf990614cd9974d894ebf18dc59755df97bfc9784c261c430461cb56cc959d783	3	3578	578	372	379	16	2398	2024-06-05 10:44:02.6	1	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
381	\\x5932debaacf6689996646c2e4a0ccb992b6e9c0e6781de4b745e33558a45c2fd	3	3581	581	373	380	5	4	2024-06-05 10:44:03.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
382	\\xaa52bb84646a38345b16f1dc60251e6fc8feb4ecc64ba88511a36c698375e8dd	3	3586	586	374	381	3	4	2024-06-05 10:44:04.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
383	\\xeaac9c335c829f9fb0736e6d142cc629d6132e68a1b78186703d1b5b424c685c	3	3605	605	375	382	6	4	2024-06-05 10:44:08	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
384	\\x8e7c8365846008c7119b0bb7ff42eab8ebec45e1964634daa7714e20a65deb7a	3	3613	613	376	383	5	1051	2024-06-05 10:44:09.6	1	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
385	\\x04efa8d52da0ecf89f865bd2f2d5a06dbbc80acd4977544244445b60d909ed38	3	3635	635	377	384	4	4	2024-06-05 10:44:14	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
386	\\x0d23dafc1d9767f100620e0b801775cdd43f6044ed94d6bb6d14b317c4192aeb	3	3639	639	378	385	6	4	2024-06-05 10:44:14.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
387	\\x82ea03539ba7d138ecef57de63730e93d30f3ddf4c63301a2f2e230e4706f146	3	3648	648	379	386	5	4	2024-06-05 10:44:16.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
388	\\x606652aa2671bb11a04925c0cd4d7f8476d3e5c31a1111fa8eebab2997384537	3	3655	655	380	387	21	4	2024-06-05 10:44:18	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
389	\\x46a9571a3e9004f2f539452cefecfab9e12133969d0d5826eb497b3d1e31bff7	3	3658	658	381	388	6	612	2024-06-05 10:44:18.6	1	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
390	\\xa780071cbd7e95b44181f734cd845c74dc3923358b0fc968bada6229a6a270ab	3	3661	661	382	389	12	361	2024-06-05 10:44:19.2	1	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
391	\\xf016d1044c299dc456bb0b6e917cd1700c77364d253dd904c95558b935a3281e	3	3671	671	383	390	14	4	2024-06-05 10:44:21.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
392	\\x32363224a683b0491a6a20c9894f7c1616516ad964d782f202eb13691da51b6e	3	3676	676	384	391	3	4	2024-06-05 10:44:22.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
393	\\x7aba2378e25bc355c98710da948b45085af3586c1414b709f10d09220486de3b	3	3679	679	385	392	14	4	2024-06-05 10:44:22.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
394	\\x6665d5369311b8a9f05232979cce2f8692d525026aa13eb0fbea4e7f8812ee4c	3	3684	684	386	393	14	4	2024-06-05 10:44:23.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
395	\\x5a70c21259bcd3f0ed1fdf7a74bfb7873767e4838188bbc9cd6e851f0ecb2821	3	3686	686	387	394	5	4	2024-06-05 10:44:24.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
397	\\xafa8bad15806ae9bc8a9efbdedda095d060e45a3f11b18a3b9cb0518cd13a49c	3	3687	687	388	395	6	4	2024-06-05 10:44:24.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
398	\\xf960ec7b8783154ef8f926a611a415fb97896420753a9ebfcdf8bb6820c9357d	3	3692	692	389	397	13	4	2024-06-05 10:44:25.4	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
399	\\x6e662bda5644ca6982532392dbffe60f5e37cfc48e7e069e351413f16132b503	3	3716	716	390	398	3	603	2024-06-05 10:44:30.2	1	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
400	\\x9e63893c4865f02d053b975771d224ef8009505e0af17fdab040119aed00f906	3	3717	717	391	399	13	4	2024-06-05 10:44:30.4	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
401	\\xd7f19646610f357c158f6221f7defc38ca256015deabeb663378ea184973d135	3	3721	721	392	400	14	4	2024-06-05 10:44:31.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
402	\\x8c3c36a30f53e6683e9af23b517ff88ceb7eb180c89edf1e8409f39584bb25d8	3	3727	727	393	401	16	4	2024-06-05 10:44:32.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
403	\\x54d3b89420ba9da93d226563e17b9335aafb2c36448aa3ffe3660d8443894341	3	3732	732	394	402	6	4	2024-06-05 10:44:33.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
404	\\x91b9b2b419f79e244ab13ea5853402f290eb5995ceb8e0c22b530bbe290661ca	3	3733	733	395	403	3	4	2024-06-05 10:44:33.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
405	\\x41a7bfe6938d307fe9e6f8255eeea81111a696c8146e43e0a65edeeedb869839	3	3742	742	396	404	4	4	2024-06-05 10:44:35.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
406	\\x5818c5fe730c7ae7175af3a55aa576d1ce9e06f72518736b1fb0706d402340ce	3	3762	762	397	405	40	4	2024-06-05 10:44:39.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
407	\\xabc086ce770767a124817d2f48b6097ad8be021eada5273059824b33ed8a6349	3	3768	768	398	406	7	4	2024-06-05 10:44:40.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
408	\\x68113b75f077f4f5332b8e70edec32f06304fdc84cef58dcd1f52a77eb7f4346	3	3774	774	399	407	7	4	2024-06-05 10:44:41.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
409	\\xcbc4fc1fbc9f79a63c96d8a2af159ae90c6eb7f2c0d1ce842ef6fd2b288bbc60	3	3777	777	400	408	40	4	2024-06-05 10:44:42.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
410	\\xa03bbfd0d939dde074cdbdc51e63099e1bdbbe02aee29f69a34f6176f2cf45c0	3	3778	778	401	409	40	4	2024-06-05 10:44:42.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
411	\\x9812b07380860bb56f0087b5b5d312e48a6d4c297cc3af9bcd76833bd4b9921e	3	3782	782	402	410	7	4	2024-06-05 10:44:43.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
412	\\xc6f1f9969f7c1aa425a18b30c5b084b00da57959faa2974a3591cb91712022ac	3	3799	799	403	411	6	4	2024-06-05 10:44:46.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
413	\\xe3bad8cfffdbcc0f90df4515cfafc984faa16b0c98dddc3b547f7a87f367d38d	3	3807	807	404	412	16	4	2024-06-05 10:44:48.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
414	\\x497098e9dd5942132782223a45f06489e75167044221748ddaca15a8f7f74961	3	3819	819	405	413	7	4	2024-06-05 10:44:50.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
415	\\xe0eaf95237c4cdcf94c1dde26f1a87d51047b12fd6e39d86c4041e17ff982730	3	3837	837	406	414	4	4	2024-06-05 10:44:54.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
416	\\xb74e3cca8d4f0b67af908cd72da503fd0b8ecd807984353cd910efe4df8e5730	3	3846	846	407	415	14	4	2024-06-05 10:44:56.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
417	\\x5550c3f73e59aeb45068f69d057c8176f540808b437d32f59872f9ef3fd9d1dd	3	3862	862	408	416	13	4	2024-06-05 10:44:59.4	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
418	\\xa8973056917dc3901d4acc1177e237dad87fa473403135e41ba54d00b6ad1787	3	3879	879	409	417	40	4	2024-06-05 10:45:02.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
419	\\x5497807052fbb466ffea38690c1274a48d2246a90e859e5fdd0b3deb0ae9eb0a	3	3881	881	410	418	13	4	2024-06-05 10:45:03.2	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
420	\\x1acf4099e396100b739b2755cc47e2aa485866c90672d57969abe51ffd8884a0	3	3890	890	411	419	13	4	2024-06-05 10:45:05	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
421	\\x56e9aa6088471c09028b9eccb22c75faf6a1f4261dc9610cbaf3bad3bddd26b9	3	3894	894	412	420	4	4	2024-06-05 10:45:05.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
422	\\x3086df7d0f6ece8239e1b625e93ac5c8cfd66993b80257abb4910e88c231158a	3	3909	909	413	421	40	4	2024-06-05 10:45:08.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
423	\\xa1da417aef1fa621a09d35206f35d89043862478e8dae6cf05b6af36d917e5c1	3	3912	912	414	422	5	4	2024-06-05 10:45:09.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
424	\\x8f30e9aa73bf3b74f5dca1f09e102467256157a63945e86b02e4692e3d908c07	3	3925	925	415	423	13	4	2024-06-05 10:45:12	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
425	\\xd014c68b201655a2df22b634a29049eae2bf741671aeade963b98bd425ece453	3	3926	926	416	424	40	4	2024-06-05 10:45:12.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
426	\\x9a7051f979deb05b4b827f66f1c9bddab62067a600bedb9e04563b19685a3413	3	3934	934	417	425	21	4	2024-06-05 10:45:13.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
427	\\xeff998be4d8b21b0e912a926d315c51d2c7951d3d4943a16464378d1f681f55b	3	3938	938	418	426	12	4	2024-06-05 10:45:14.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
428	\\x6bece73ff75c5201197330c9cf25cbb23eb2c7f63205e1c08ade1551fba18ea7	3	3962	962	419	427	14	4	2024-06-05 10:45:19.4	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
429	\\x0cf6433ac3eebb9d2764d0cbf23389b5132237ac82e7a8660f5fe2e65096b369	3	3971	971	420	428	16	4	2024-06-05 10:45:21.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
430	\\x9f302c4f560671b63e916825da31c4f07bbfb3d2b2907bbea951e8cb351ea02f	3	3973	973	421	429	13	4	2024-06-05 10:45:21.6	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
431	\\xecba48b4a5f47568f654b01716108af415c7f59425404f0440bde0bfedda66d5	3	3979	979	422	430	40	4	2024-06-05 10:45:22.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
432	\\x88cfe25852b127257f411095e2f7b1af9a8941243a16648ddf9baa77b2b1bbbf	3	3984	984	423	431	5	4	2024-06-05 10:45:23.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
433	\\xdf6f142a04cb75b172272a17d58582394ab0125fdda047c4d47b1a6477e2e5d0	3	3985	985	424	432	12	4	2024-06-05 10:45:24	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
434	\\xd1a1fcd0fb2c6caa57bff674b93e5547bae06749e694693e654dea029243acff	3	3989	989	425	433	4	4	2024-06-05 10:45:24.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
435	\\xb97188a40ee6dc4e4958295a92e5dadf12265364e576b1fcc01b5bbde61caaae	4	4001	1	426	434	13	4	2024-06-05 10:45:27.2	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
436	\\x057d28635e26cd21e23b31fd34c5b69f73e852a84c39d86ce219f5ca2acc3fb8	4	4003	3	427	435	6	4	2024-06-05 10:45:27.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
437	\\x7ed2864c0d3280ab61b59ec82f8b56261463a99d1c0bddddf79215901a677d02	4	4011	11	428	436	12	4	2024-06-05 10:45:29.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
438	\\x486f4c65f59bf601283a019e0779792623d48587d40202b9dafde7be29ec6cd1	4	4014	14	429	437	6	4	2024-06-05 10:45:29.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
439	\\x3fba2e1c15aaf9cdba1c7ef988605174aa12f5d4dd8c882a68d2855895e8afba	4	4015	15	430	438	13	4	2024-06-05 10:45:30	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
440	\\x14f57b894aad3bab5cc0891cfb28adf584c99be556f370654e943d72803a8d07	4	4022	22	431	439	7	4	2024-06-05 10:45:31.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
441	\\x1aece282b0002d093d9828647b6993e885f82a51237070da783f63877bee0f8c	4	4066	66	432	440	21	4	2024-06-05 10:45:40.2	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
442	\\x64d8b556e65110a0bda3980d47bec00e524959fc7f0ecacbd5e58e2bec51d2fc	4	4077	77	433	441	13	4	2024-06-05 10:45:42.4	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
443	\\xaf016a6fcd9869c939a273bca645aa3e50b252bb44041485cf8f906e500913e4	4	4086	86	434	442	12	4	2024-06-05 10:45:44.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
444	\\x4c6b566246affd2a85b376bcf9169027d5caac0c63f9c0b5974e2de1f993040a	4	4088	88	435	443	6	4	2024-06-05 10:45:44.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
446	\\xbd96bc53938f94b784ac3ce7b6893b67dfa769f577c1f4194e513b98c167b447	4	4091	91	436	444	40	4	2024-06-05 10:45:45.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
447	\\xfc5da358b6c13c9d8bfaaa84959bc5a2c2ebd2181cc6fb27bbbfcd43fd729bfb	4	4116	116	437	446	14	4	2024-06-05 10:45:50.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
448	\\x14544c593455ffe33bd6c99b5748599bbe3f62f60a5948071cefbf3277cc4287	4	4131	131	438	447	7	4	2024-06-05 10:45:53.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
449	\\x4a3b86bab30b38acd2ef0a8f4cd4f8cd6c6c3acba38165f14e1d8e4ac712870e	4	4132	132	439	448	21	4	2024-06-05 10:45:53.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
450	\\x534123faa93b6c494bcdecd4982116018b8ee0a979b12305a89bbe711e4b5cde	4	4139	139	440	449	6	4	2024-06-05 10:45:54.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
451	\\x310ccd389026eec0cee4379c671242bcb9336ae7406d1e372c46aece215b50a8	4	4151	151	441	450	12	4	2024-06-05 10:45:57.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
452	\\x09feed1bb8cfe2a981a168a22bbc8de45be4a6b8d9b0c7dd9db822e9caa3706b	4	4162	162	442	451	14	4	2024-06-05 10:45:59.4	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
453	\\xf895c4372ef61fda59c51c0073580573503d31208d08c5c64ef5a5e8585081af	4	4163	163	443	452	16	4	2024-06-05 10:45:59.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
454	\\xd551c90d245d60ac5e3e4951c8faa5aec17224abc12d9cf1f478650721214192	4	4175	175	444	453	5	4	2024-06-05 10:46:02	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
455	\\xb2884826af95e13a60a6366f212bf4d280686c5cf29ce4b7475b32c7692d29fc	4	4181	181	445	454	40	4	2024-06-05 10:46:03.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
456	\\x96b895536b89c56888543011568b892d141321d81289527fddde5f814c420f3a	4	4186	186	446	455	12	4	2024-06-05 10:46:04.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
457	\\x0c0b91c0dc7b0751b54712254ad064ea8d17247969da1c289b346b9311f8b9c1	4	4201	201	447	456	7	4	2024-06-05 10:46:07.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
458	\\xd2fe7a0ac1a16f7e20066aad620488e0e4fb7fcfdbb9f439a486f43be7278e83	4	4207	207	448	457	40	4	2024-06-05 10:46:08.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
459	\\x7f11ab37502b4f3bc3811634f491549b790a214f27f2a676854aab8397a9973d	4	4219	219	449	458	21	4	2024-06-05 10:46:10.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
460	\\x2cc968ffbac8dde91f0d01ff1ea3d24a65c000b10bd99f9daec72c4597167f22	4	4222	222	450	459	14	4	2024-06-05 10:46:11.4	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
461	\\x352233cf73890573e95fb4ffe9e9e5152cd7769b0ba2b6c361b854365d80d7c0	4	4249	249	451	460	16	4	2024-06-05 10:46:16.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
462	\\xdebd39828f0ebbe4065dc662e2fa8bdfe529fa37475585ec8addb627eb439d56	4	4250	250	452	461	5	4	2024-06-05 10:46:17	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
463	\\x1d57d85bc4e160e7a899352856cb5d45f262a5eb664107a4a49e42c4e863e546	4	4266	266	453	462	12	4	2024-06-05 10:46:20.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
464	\\x3631e04b73465347c256bec1c754b176f9468801a3c30a5ac5ad4579167f2cab	4	4274	274	454	463	5	4	2024-06-05 10:46:21.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
465	\\x96a09e5c80b24b2974734dab04aafa186792b26e1c5a743e5edadb6101de3955	4	4277	277	455	464	6	4	2024-06-05 10:46:22.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
466	\\x6bd78b3dae0b2c29dd70eafaec98e81c3dc033eae754fdf046946e8211d97d63	4	4293	293	456	465	5	4	2024-06-05 10:46:25.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
467	\\x3677098845eca5589127df40e73244b31345d36fe86d5761efa56404bb76b912	4	4306	306	457	466	21	4	2024-06-05 10:46:28.2	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
468	\\x7bb1a3f354cc35a6fbbc2d8dcb65cd0c4ef67e3300374a2e4da97d03d36b86af	4	4307	307	458	467	21	4	2024-06-05 10:46:28.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
469	\\x6104a32415431b0d182b64f0c7353683c69b736fe7dd5218c51e1c8822c1b02b	4	4321	321	459	468	6	4	2024-06-05 10:46:31.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
470	\\x2331b918f2778f3ed72b1b64d11b0758eadb134ce9c26aae201b12cf1e86943e	4	4331	331	460	469	12	4	2024-06-05 10:46:33.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
471	\\x1639fc3d74291e67ea890a0784d41f6477959d268aecc66d4b519ab679f8de66	4	4334	334	461	470	14	4	2024-06-05 10:46:33.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
472	\\xcd2e4186cc5c8ea73438fc529a7e4d62e6b74bc50be68d62a27859b05567626b	4	4335	335	462	471	6	4	2024-06-05 10:46:34	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
473	\\x4c3a43a9b397862f388e42c695d8d8c1b2b069b4975ef19436f78277d581d798	4	4349	349	463	472	7	4	2024-06-05 10:46:36.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
474	\\x2efd2339fddad6d54130cf736da2282aa272e2952691c61fbb08d8bc3dcbd481	4	4384	384	464	473	14	4	2024-06-05 10:46:43.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
475	\\xe3e789abd8dc313b7ccc625ebbfd3c6762f5ee97728bab4e394782b463c9fcd5	4	4393	393	465	474	5	4	2024-06-05 10:46:45.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
476	\\x86162a08ccf660a44c108b1284a93e4c76ba91fb08337e6ef10e9b80ff5f34c6	4	4396	396	466	475	6	4	2024-06-05 10:46:46.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
477	\\x1ae7a10c724e2a11b898d644f7e6d2f571459d9a34d9153087f7919eb7538fab	4	4397	397	467	476	12	4	2024-06-05 10:46:46.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
478	\\xa7f86c72364baad4123262ea983cbe98838b23bbe5abb51c5e5443405f818c63	4	4401	401	468	477	12	4	2024-06-05 10:46:47.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
479	\\x9d9642b2b6206398a76a784465bd2b4e265e37555e4c49196b6de6c1f36747ae	4	4413	413	469	478	5	4	2024-06-05 10:46:49.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
480	\\xf899a136104f84c840f47a4110abca400c598b1ea97b14bcd9bb59df81970461	4	4427	427	470	479	16	4	2024-06-05 10:46:52.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
481	\\x63695ee98b709d0938f31131baf8ae75ea72ce149f5ca7ebf4bd71e952945ee8	4	4456	456	471	480	7	4	2024-06-05 10:46:58.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
482	\\x2559f27050847fa0d5a8ac6461c5a25afae9a27af5e531774bc810f7f2b9b560	4	4458	458	472	481	6	4	2024-06-05 10:46:58.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
483	\\xbc1adb6d2332fd960e16a1d953cc1562d1c86361a295c3750e70e5d5eab31f81	4	4468	468	473	482	16	4	2024-06-05 10:47:00.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
484	\\x87b81790fcce6d7f32b288cc07d53ac21e6803f5e896631cad5fb07c31f749a4	4	4473	473	474	483	14	4	2024-06-05 10:47:01.6	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
485	\\x169014410467ee031721f35e2a98ab91e0c74c901cd8ef39b9fc47b0f47aa795	4	4486	486	475	484	14	4	2024-06-05 10:47:04.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
486	\\x0cb1f67af3d5241f60675c18bd75d927411869dea0f8433192cf618544f0bf47	4	4519	519	476	485	6	4	2024-06-05 10:47:10.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
487	\\xbbbdf41bff0f36443c645be49b81c413bd538fd0e8e26186dcc278d8f026a5dd	4	4520	520	477	486	7	4	2024-06-05 10:47:11	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
489	\\x8a4a1a7ad919373e8f322ef3df3f86015a1ce6897f318a574500a7d1894ff36e	4	4560	560	478	487	6	4	2024-06-05 10:47:19	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
490	\\x172408880472353e714f2f7bcfc632e20dbbac30f3572084a70647fa102d4104	4	4561	561	479	489	40	4	2024-06-05 10:47:19.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
491	\\xe56141c510751a05bd70e21daf3e847e6a0e13f686f66442bd5d2f6da44c6d46	4	4567	567	480	490	5	4	2024-06-05 10:47:20.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
492	\\x4f9ccf96275aa79542c5c1255614b389b2253b10de85489142f89af7d691b173	4	4569	569	481	491	40	4	2024-06-05 10:47:20.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
493	\\xfe7a896a802578ef9c86efddc23211da496228eaa6649f6b9cb9d45aedcacc6e	4	4571	571	482	492	5	4	2024-06-05 10:47:21.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
494	\\xecc8d39a7470468c33a3a57f2091203194fa9401034fd3cf69dbb6c9227b4435	4	4573	573	483	493	6	4	2024-06-05 10:47:21.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
495	\\xca654441d11b39a1aa3bf61a0b6d8cbb9a996c2a1545ddd925c3c986d05e26b7	4	4576	576	484	494	4	4	2024-06-05 10:47:22.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
496	\\xc32d3023d183a364b53fda3081ff7973115fcf67e0210458b10ed11df903d130	4	4579	579	485	495	5	4	2024-06-05 10:47:22.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
497	\\x2f8d0ca204ba9420f6d48b8ff5c58037cd21e9a0bd92f34744edecbd4ea093bd	4	4593	593	486	496	6	4	2024-06-05 10:47:25.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
498	\\x721c2e99e744c73fb1aabd2dd32c30858d87825ce2f42d26e55f82961aa51184	4	4595	595	487	497	7	4	2024-06-05 10:47:26	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
499	\\xc30fc79f73686cc8255aed51cf6cc8aaee4e5071308daf44704229091625aaf8	4	4598	598	488	498	13	4	2024-06-05 10:47:26.6	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
500	\\x9c52b0e1adaa04175a685392598395b0e39e641a367811c6b0b6e1aa00026024	4	4601	601	489	499	21	4	2024-06-05 10:47:27.2	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
501	\\x7ea541b2bf9c0aceb90da262c5c143f69be327743718808fe4fc4fe76287c0e1	4	4627	627	490	500	7	4	2024-06-05 10:47:32.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
502	\\x2c9bc6d3fef5209d4ceee58c29c66a0511dac2c20b610903ce67dd8ae5464c35	4	4630	630	491	501	6	4	2024-06-05 10:47:33	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
503	\\x96d39f7917c1463ca06581ce311681538ec6a9b656b9e1d7f79ff3231bbb3654	4	4635	635	492	502	14	4	2024-06-05 10:47:34	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
504	\\xcdb3e9b803d5dfa652ab7f83e6c56e4713d82b0daab85e74f00f2fe994158b6a	4	4638	638	493	503	21	4	2024-06-05 10:47:34.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
506	\\x9a2612f81cd69c64429d5557b00cf85ba1d4698ed42c79f1561a17ff00a02a84	4	4640	640	494	504	13	4	2024-06-05 10:47:35	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
507	\\x5e82695937604dc74cabd6c1ab3ec61bcd3d32fc7952db15f7bedfe1f9012cab	4	4644	644	495	506	21	4	2024-06-05 10:47:35.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
508	\\x67d4881843ed567fdbb0ed7c613cc3b12cddb66a8dd03a3249c259bd2e22f757	4	4662	662	496	507	14	4	2024-06-05 10:47:39.4	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
509	\\x37f2f0d9a1bad8cce87c90c60747533fdff3f59df09e5b5e868e066a3da3a7d5	4	4666	666	497	508	6	4	2024-06-05 10:47:40.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
510	\\xe62287ab1b54f1368eeec4e4bf4a5a7f2ba9663cc0bf93f30b83b8f64a3736e4	4	4668	668	498	509	13	4	2024-06-05 10:47:40.6	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
511	\\xe8d8b4dfe80d37589d5864cc5b866e9bebab70733fc8966bb7d395e5b47e5bb9	4	4677	677	499	510	5	4	2024-06-05 10:47:42.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
512	\\x7cf9f4a6acb67ab4eb53db7cec47ceea1eb7005225cac381cae48e5b286cda95	4	4680	680	500	511	6	4	2024-06-05 10:47:43	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
513	\\x74e734d69ec4f896950bfabbe058d857f2468811369814e1c980ac9998a6ab1e	4	4686	686	501	512	13	4	2024-06-05 10:47:44.2	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
514	\\x5723f32b00566c7a6868d639a7b030506fa893fc7d4740011e8715e81774721f	4	4697	697	502	513	4	4	2024-06-05 10:47:46.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
515	\\x8423b4bf95f09aff4e7d56d41c53f92f054408b780f6925793cd1283a78a9fda	4	4701	701	503	514	12	4	2024-06-05 10:47:47.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
516	\\x5e3ed67698559615b7a77323f190546ebfaba264cd9b46b2861538ccdcee43bd	4	4703	703	504	515	14	4	2024-06-05 10:47:47.6	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
517	\\x7c582719c794a020127a577324bd882eb9ca73498f9a79647c1db09f38e0286d	4	4717	717	505	516	14	4	2024-06-05 10:47:50.4	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
518	\\x11e3e667f10c66f073b13b9e915233769911c8700093f3e53e62fc51408ff8ef	4	4746	746	506	517	40	4	2024-06-05 10:47:56.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
519	\\xa07c5f052d2300dcd47268987988c2262c0e4352d00b96d5541a22f7e59e8005	4	4750	750	507	518	13	4	2024-06-05 10:47:57	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
520	\\x0117c5faa6dffd68e00342dfd49919bcfa95d779bf75772942b98c89635b235a	4	4758	758	508	519	40	4	2024-06-05 10:47:58.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
521	\\xabd2165a7fbecce8df367299d91e57d5c5324d3b0ae69845631f932c783153b4	4	4762	762	509	520	21	4	2024-06-05 10:47:59.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
522	\\x971a105c48d48c3db6095be62f6ba2ebc7bfb421a30b47c0f102f8461f2cc526	4	4774	774	510	521	12	4	2024-06-05 10:48:01.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
523	\\xe5a45ce8c0c8e391a7fad34d07cd530d707a51f7b3578fdd40bdc12146352304	4	4778	778	511	522	21	4	2024-06-05 10:48:02.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
524	\\x0e66915a4bef9c2e18e0e63a888066e09ac75cf6794c7481737696fb2b079e24	4	4783	783	512	523	4	4	2024-06-05 10:48:03.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
525	\\xafeee435ca5a0cb2dfcd1df31003c3063e26f9b52cb55357b8e835b38d99151e	4	4817	817	513	524	3	4	2024-06-05 10:48:10.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
526	\\x233151d4b9ed6cf6d1f6af2606aacf2e3ce54f5241f54402eedf706d623c878f	4	4818	818	514	525	3	4	2024-06-05 10:48:10.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
527	\\x00f8527d674ebfcb49a7a935641be7c0f0963f2244bb65df2695f47828a5673a	4	4823	823	515	526	40	4	2024-06-05 10:48:11.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
528	\\x0df9d3ffc0588cb52ecf78919f4ea4621600129d31071b77ff3c067d875c7312	4	4829	829	516	527	12	4	2024-06-05 10:48:12.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
529	\\x1244482ee60c3d1c307a09354f6fb4cb706726adf5b12e85017363eea963768c	4	4865	865	517	528	12	4	2024-06-05 10:48:20	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
530	\\x73527e2f198d61aab8b4a87dc6e31b7c6af00ac60ffb1887e9aaf3b95ddb54bd	4	4877	877	518	529	16	4	2024-06-05 10:48:22.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
531	\\x12a316bf9e90fda6ad70204f60969f381ce8ff8ec0e1ac9fab998ee4327d7e3c	4	4886	886	519	530	14	4	2024-06-05 10:48:24.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
532	\\x1d09c42ce79f6136d41e9b55bc8611c9c64262e65a21c47b23ea2919c702cb13	4	4904	904	520	531	16	4	2024-06-05 10:48:27.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
533	\\x5902093c4a8f0f660fb0b0dacf809af2f557cec2e6bb01c516a99ccfd7cafae6	4	4934	934	521	532	4	4	2024-06-05 10:48:33.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
534	\\xfb6447c5352e2376d8d07187a762cf89392f13b90e9bfb8b7a4aab7107e4294a	4	4941	941	522	533	13	4	2024-06-05 10:48:35.2	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
535	\\x852e4dc5ccec30174bb89c7377b8742fadbf28329646c5f9765ceedb4e2d2e45	4	4965	965	523	534	14	4	2024-06-05 10:48:40	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
536	\\x171594705e3f732aeb04d0a24248f9acdfd4f649ea4282992ee1c4181b06ff94	4	4970	970	524	535	3	4	2024-06-05 10:48:41	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
537	\\xc4a2e64ae4b2f48e9e580afa315ae89269e873d4fa8cc251c97faa250d4fa704	4	4983	983	525	536	40	4	2024-06-05 10:48:43.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
538	\\xa629b1a720fbbb10466e1e8e18bc6c3cac3e245fc1cd2556f0b7a312e7488123	4	4990	990	526	537	6	4	2024-06-05 10:48:45	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
539	\\xa52187ef5f24942cba9f7a6d290eb43c44ccd2cb659f8766f34bd71d35e62036	4	4991	991	527	538	16	4	2024-06-05 10:48:45.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
540	\\x2d3f565dddf4c699f46a84ac7ee9639d988baa79513b257de8fd48b8906346bb	5	5007	7	528	539	16	4	2024-06-05 10:48:48.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
541	\\x9dc42abb6e10657f7817230b0994db00dde4d467ad7604931a0b74c0dff30e2b	5	5017	17	529	540	40	22586	2024-06-05 10:48:50.4	72	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
542	\\xbfb8cff705e3ca42fd18cf41f510d976c8b0119ae313a839e446ec509aabe443	5	5041	41	530	541	6	8974	2024-06-05 10:48:55.2	28	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
543	\\xfdd095c7c8baba1ca411bbcb66d1bf214f8153571f0304920bcb0571473a5f0b	5	5049	49	531	542	16	4	2024-06-05 10:48:56.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
544	\\x866663d567f12f936d452542f1e865e460321f3898e3863b5c4267175fcda960	5	5059	59	532	543	13	4	2024-06-05 10:48:58.8	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
545	\\xba92e2d0e6d5e38640831a45ee6a0d47ff94c430645d4ef694dc0494e2da1e1c	5	5065	65	533	544	7	4	2024-06-05 10:49:00	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
546	\\x10ca8586c5543cd37b9075fc0ff6b7f441b1f29b96932629c89b3cb5c305f942	5	5098	98	534	545	4	4	2024-06-05 10:49:06.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
547	\\xfb341063fe11eef8c2383c49b0ce939547636c3adba58e43149032f721a80b9a	5	5129	129	535	546	21	4	2024-06-05 10:49:12.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
548	\\x6c18561473b31a936483877146aab0cf3461a0b72fa1c5234b6d1b55fd704cec	5	5130	130	536	547	40	4	2024-06-05 10:49:13	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
549	\\xb7aaf813bb6a50c24379b390bf3bd41ab044119d28c9b24a0ec1a78bb2cf8c19	5	5136	136	537	548	4	4	2024-06-05 10:49:14.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
550	\\xb14958b9441d8ec5444e14758ae4d27cdcc3ef5cb995cadda10f0337444759da	5	5139	139	538	549	3	4	2024-06-05 10:49:14.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
551	\\xd173b32e7fe1b1f8f0f1498428f5cc64cf377cf4d10f3ef42b3b381dae813488	5	5141	141	539	550	40	4	2024-06-05 10:49:15.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
552	\\xa45d12ab21cf42b9305c7f2ee2af947fe6254e47f729f1feef1bc600c16eff6c	5	5170	170	540	551	40	4	2024-06-05 10:49:21	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
553	\\x8aad97f106319b466bfc887181fe19a47773e0d862b50146ad7693df7a06f6e5	5	5171	171	541	552	5	4	2024-06-05 10:49:21.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
554	\\x03453c319145cc65a82cf243a8563a29858661b37e2316025d4b89834194d1cd	5	5182	182	542	553	14	4	2024-06-05 10:49:23.4	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
555	\\x7c0ea0047257c0ae5fe47f65015d5715abac3c112d563cdb8800c20fbc225e32	5	5192	192	543	554	7	4	2024-06-05 10:49:25.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
556	\\xc50d459ce2efe59a55a8b725094dce94b7dab38216c4226b213638f3716e56ad	5	5204	204	544	555	16	4	2024-06-05 10:49:27.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
557	\\x8e95fd31e2c7404e367656dab78c0e0722e75141b872d7b5f6f49e17654e8b68	5	5206	206	545	556	3	4	2024-06-05 10:49:28.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
558	\\xde86699e193605d061e97bbb71daea54dea433171d0a00bf10573b0ddab2fb5c	5	5215	215	546	557	7	4	2024-06-05 10:49:30	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
559	\\x91cab77507eed46b84fbcaeade7cdf70f4f55fd269869c16c96cd555d05c9bee	5	5216	216	547	558	5	4	2024-06-05 10:49:30.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
560	\\x6f0be12dc800518cfdc0541a834b38b6241a7bf4ac0f7639f410e45bc26b7e71	5	5222	222	548	559	3	4	2024-06-05 10:49:31.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
561	\\x947d27be06d6d43fd1ee1d6cb159849dc3fb5c8aeaaf24331dbaffcc5daa20ce	5	5231	231	549	560	4	4	2024-06-05 10:49:33.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
562	\\x0f3a62e72f13cb268c4da5e13afcb029fc77cfdce44faa050e5eb6693d8805c9	5	5239	239	550	561	14	4	2024-06-05 10:49:34.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
563	\\x03bbb5b0cb469c0f4ac0c14130ea2700b52ff26f5d015e61c42e905b0d676aaf	5	5240	240	551	562	12	4	2024-06-05 10:49:35	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
564	\\x9b77a136c6369a31f619d9c43016c4cfb4dd4f34fc2006c3c7d60a66366e5bce	5	5249	249	552	563	16	4	2024-06-05 10:49:36.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
565	\\x200cb8687ca6baac54d3f4b49ab56b09314ea0491216d8ac32ed97e9b1b8ba22	5	5271	271	553	564	5	4	2024-06-05 10:49:41.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
566	\\xf698a629b50aba71e4aac7866b36c84f329bfc3abd24911f3d737afb50b8c6c9	5	5275	275	554	565	14	4	2024-06-05 10:49:42	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
567	\\xf7caec16be3d58a342e706966a21b4379748bd26067c8c1a05bc2788c51f8e45	5	5318	318	555	566	12	4	2024-06-05 10:49:50.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
568	\\xe556aeec0d7cb9f221f07a9a8f6ba28c1501aec3118b29ab0f896d502fd8eeec	5	5332	332	556	567	13	4	2024-06-05 10:49:53.4	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
569	\\xefed1182e832a26786dbb152efbdbd525cac38bb2659f1190b9b3924fdacc263	5	5336	336	557	568	7	4	2024-06-05 10:49:54.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
570	\\x999c094109c6fa933ff6c5cf836b8aa12ee9f190ee38f064fe80818f8e9f6552	5	5343	343	558	569	4	4	2024-06-05 10:49:55.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
571	\\x429b996d08e27086c41860a5a271c9e3166294dcf4dbd5baebb4fd41a161c9f8	5	5347	347	559	570	14	4	2024-06-05 10:49:56.4	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
572	\\xa3e82456fdc83aa5483015a9fca69a1b50170de29e9d002a5446b3b85f699024	5	5354	354	560	571	16	4	2024-06-05 10:49:57.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
573	\\xb0481f7cc18547cbbb6a7a3c70c18cd473d9497d0df5ae214ed3a9a807225b96	5	5364	364	561	572	16	4	2024-06-05 10:49:59.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
574	\\x19a8b33c2a782d4acbf5b13216ee0f118ea7c789d105600f5d0e027a3c52b731	5	5375	375	562	573	4	4	2024-06-05 10:50:02	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
575	\\x756d51fae61c115f1c868a55b0da322748e0b47558db08ee96531e0d4fc1878c	5	5395	395	563	574	16	4	2024-06-05 10:50:06	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
576	\\x663add4e97be51b17a71c36280440f2d87a7010a41aefd0793f27e579a956d08	5	5396	396	564	575	16	4	2024-06-05 10:50:06.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
577	\\x69fa23c6f059bd5532f41f32d8a242a098a936b87e36b2026ff11a892c89626f	5	5422	422	565	576	3	4	2024-06-05 10:50:11.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
578	\\x944ff01e0ce87894e5872af741835a053eda694fd497046509adce554603a229	5	5424	424	566	577	13	4	2024-06-05 10:50:11.8	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
579	\\x47f46780de746b0ffc10792766923d34e615db729d764a0fc436e1484cad5e50	5	5425	425	567	578	7	4	2024-06-05 10:50:12	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
581	\\xbb762314ecfad657fefadf9b5b9a5801614f24755bbeb2a3b30ba90306162665	5	5429	429	568	579	12	4	2024-06-05 10:50:12.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
582	\\xaf369f84ff7beb95fbd8bc9757efb57351bb9e44294f934672995e30d7b12f2c	5	5443	443	569	581	12	4	2024-06-05 10:50:15.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
583	\\x0efbbb0cd7a9098cee74f2ded03a20e04eca1bac01f5fc1f8d55acae97c8ff4e	5	5448	448	570	582	16	4	2024-06-05 10:50:16.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
584	\\xf8623cf53d2fa2119f4317f1286d8f82442747ba7fef443f00add1a16595bbbc	5	5456	456	571	583	14	4	2024-06-05 10:50:18.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
585	\\xa7da3eff1fae096bb5b24cc26019e74e32233d0b9a5c8c458a5088ae1d6dae64	5	5482	482	572	584	5	4	2024-06-05 10:50:23.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
586	\\x393453886ea3d14ac3982638bcacd1db9626c1447bc842cc93d8b8d236053c07	5	5484	484	573	585	40	4	2024-06-05 10:50:23.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
587	\\x29c9142d6b4971b945e2a61aa5196573dfd99ed6e9c35e5d99a87463daf45dde	5	5487	487	574	586	21	4	2024-06-05 10:50:24.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
588	\\xd0cde78101dc1aa3676eabef8313ddb39745756d5ea787402f8cf6b6de44ceaa	5	5531	531	575	587	4	4	2024-06-05 10:50:33.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
589	\\x51e57442828f1de5bd0800e61b5c84c39eb53bae76d871fc664530d0a1507d52	5	5534	534	576	588	16	4	2024-06-05 10:50:33.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
590	\\xb1b422b6ab76f11bd9e5cc4a4b4b4492281d49391802c19e4d7b083d9c7ab686	5	5537	537	577	589	5	4	2024-06-05 10:50:34.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
591	\\x3821fbcf7d0db3c4e310a647a53a05f61b5bd3fce73fa79762dfea6d8b6ac30b	5	5540	540	578	590	4	4	2024-06-05 10:50:35	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
592	\\x9e21f1a9907bea57f01b925551a83cc7cd7eea1ab7b297c791d2660f045013fe	5	5552	552	579	591	5	4	2024-06-05 10:50:37.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
593	\\x0f7eff75fa17f6464fdec6d32167e02c8cbce3fb8328ffebb02a5702e673abe3	5	5567	567	580	592	12	4	2024-06-05 10:50:40.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
594	\\x3ce5a0774fb0522c579d4f7fa85e57982e639a6caca6d07505568612c656a027	5	5593	593	581	593	16	4	2024-06-05 10:50:45.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
595	\\xcd9147117c4c31e6f283f92db088e3379dd2475151f43b29afbb56ec2fe3d019	5	5595	595	582	594	14	4	2024-06-05 10:50:46	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
596	\\x0d7ebf17e0c349d2912fb5e45109ab0771d8ae33312724b872908d1d51d57165	5	5598	598	583	595	3	4	2024-06-05 10:50:46.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
597	\\x24eead8a75cc9cf456d29718edafd0521b4547ba3fa7e1f4c31846bb65887676	5	5601	601	584	596	12	4	2024-06-05 10:50:47.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
598	\\x21d91a624c865901744d6da640cbea3680c65c626ffa4d41a708554182e58e2a	5	5612	612	585	597	5	4	2024-06-05 10:50:49.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
599	\\x5b9668052faac96abe97c8a2336fe954d69dc4656c9aa25d66a2f09615e15192	5	5629	629	586	598	12	4	2024-06-05 10:50:52.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
600	\\x3441643c49e02c51ea8c4c6d49c078d32d1988e6167a00ab6e88d7c4b3091f56	5	5636	636	587	599	21	4	2024-06-05 10:50:54.2	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
601	\\xda6ca9e19c17b5905350400550b9789e6d6a22ed9c983a4a938cc1b5f4564b1f	5	5638	638	588	600	14	4	2024-06-05 10:50:54.6	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
602	\\x10ca59e977a18cda85a765fe26b890d18ec5fb5dee6ad297f93a39c17e0edfda	5	5642	642	589	601	13	4	2024-06-05 10:50:55.4	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
603	\\xd379d612c3419cb2c7a361116bbd9838a9429dd7c0eb913dff91a5da7b190a8f	5	5644	644	590	602	21	4	2024-06-05 10:50:55.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
604	\\xef6653c05366bc2f1bd81958ca6bf2eed176c1acde695429c91c8d7c5d829d7f	5	5664	664	591	603	40	4	2024-06-05 10:50:59.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
605	\\xd0c8963bdfae93847b0e2d5db61425ed4ebae0636e66a9fcb511b63ff3afdee3	5	5669	669	592	604	6	4	2024-06-05 10:51:00.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
606	\\xf29f511b6cf8f83c0aedcf13b64ec2ab07524ea64e8da416861cc6c7f64a7f61	5	5672	672	593	605	14	4	2024-06-05 10:51:01.4	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
607	\\x0cd8a0799682688b37d26446615c8d5bbb73afe895010a8f75d6418628daa376	5	5673	673	594	606	12	4	2024-06-05 10:51:01.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
608	\\xae15d67ecbd8313e697f51d6eb50501a592755c44b0aec81597d76a1aa64bc77	5	5691	691	595	607	6	4	2024-06-05 10:51:05.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
609	\\xf6705fe0a8dce3a7011c27dd8fab8515dd6463eef7f0bbe30a81b10c9448d18c	5	5701	701	596	608	3	4	2024-06-05 10:51:07.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
610	\\xfca3adf9e4a535d69b72574d0f9c15f62432da116c9fd0ebec5bcd7f48b0118d	5	5703	703	597	609	40	4	2024-06-05 10:51:07.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
611	\\x143825c6fc933624f9aefe025b681305a22813c5ebdf8f0bb925476c4602942c	5	5731	731	598	610	16	4	2024-06-05 10:51:13.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
612	\\xc636bd9b8b0d98bc385c35c91b8bd8f3673e6594c2e56b80e64b6f0222de4080	5	5746	746	599	611	16	4	2024-06-05 10:51:16.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
613	\\x7da739fc4180732af7efee121fef855678cc3db10a1eb176f536288f865e5d80	5	5753	753	600	612	40	4	2024-06-05 10:51:17.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
614	\\xc42ff15c142d2d51c1710718513399d8ad7ba03930f60ecca0c35517a1003431	5	5786	786	601	613	4	4	2024-06-05 10:51:24.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
615	\\xd1ed1ef6fd40062508e5c22abfeb6506ffb2220276920e112fea0542bab5c1c8	5	5787	787	602	614	4	4	2024-06-05 10:51:24.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
616	\\xfaa77900e359453d3818acf762564cbb57e1aef8b95b12939de1c84da48034e4	5	5794	794	603	615	3	4	2024-06-05 10:51:25.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
617	\\x139062017310dd4a93ecc12fff77bba3060b2dd4600ed1f3013f5a309e724a9e	5	5830	830	604	616	16	4	2024-06-05 10:51:33	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
618	\\x5d806f5bccc1ea1fa32425236e856157f9ebb76e491902aa1c3219612caeb413	5	5836	836	605	617	4	4	2024-06-05 10:51:34.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
619	\\xcea17309a2b250f29264c8ee431fb26e02f9edd89ae1b0d89e4157f5500f022a	5	5843	843	606	618	5	4	2024-06-05 10:51:35.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
620	\\x3d5d76868943c08222a489fbe0df5d74eb7ad26a05cbbc61406af0b8f8e203cf	5	5851	851	607	619	5	4	2024-06-05 10:51:37.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
621	\\xfe49781642b2aabc799187a9e4a76baf166c2bd3cfbdbf3804fc3389522db58a	5	5854	854	608	620	3	4	2024-06-05 10:51:37.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
622	\\xd23f48f77142a019175bbe5af8aa2df1d441a84f7c7112ca6a3d7e03b8152771	5	5862	862	609	621	5	4	2024-06-05 10:51:39.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
623	\\x84d51c5dd50d5b0e7875017370099945b8e53370d45e55a7243889118e869b57	5	5869	869	610	622	21	4	2024-06-05 10:51:40.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
624	\\xbc2d491560942ae4d4f1245c27c7386ecd948528b707820a9b7904f3b7fce665	5	5873	873	611	623	12	4	2024-06-05 10:51:41.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
626	\\x5e0020715f47a8e7c5bcc60a40042846f345135d9ef8b668a8daa9d5d7476688	5	5875	875	612	624	12	4	2024-06-05 10:51:42	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
627	\\x372c53ba3a5997f75aecc2c04d834d0c948e2994f79ac1ba1ec3e1be1280259f	5	5885	885	613	626	14	4	2024-06-05 10:51:44	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
628	\\x4ec6bcd653f93d34963d92d228c66a344c1af58e4c047c69cd160d87c353094d	5	5888	888	614	627	7	4	2024-06-05 10:51:44.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
630	\\x5b9cbcd78748e72fcc07bf3753ce2d5919102ad58793b2474e1ee84f9891c095	5	5891	891	615	628	5	4	2024-06-05 10:51:45.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
631	\\x743ab06103157b48e69e179505ec57378085b5855288474be49f4eee3470604d	5	5904	904	616	630	3	4	2024-06-05 10:51:47.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
632	\\x55f31a3b9661275ee2d8877f63441d4dd860e8b892ef392480da4485c18cd724	5	5921	921	617	631	4	4	2024-06-05 10:51:51.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
633	\\xb2393ee35dfc651c857650e8768a96e65cf2ddd52b11ccb53101eb583bc69564	5	5932	932	618	632	12	4	2024-06-05 10:51:53.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
635	\\x3f177689cc3f5a7d10c15c653a8534a1d22370f95da0202e30a9818bf07d7ecd	5	5947	947	619	633	4	4	2024-06-05 10:51:56.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
636	\\x730b7af11138469c7392ec0375e98c5173cdf01d505f907b6ec3efe8d60db11a	5	5949	949	620	635	3	4	2024-06-05 10:51:56.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
637	\\x4c6b655afea55bea4a7deecaf28e601f63a1e7eb530ee7ac12119d8c31895315	5	5959	959	621	636	5	4	2024-06-05 10:51:58.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
638	\\xc078e8503990b29a012eb9dfbbf4a758b180a2dcd25609f28c77f98f9d271fa6	5	5969	969	622	637	12	4	2024-06-05 10:52:00.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
639	\\xcdcecd836200a523b4a5a1409e1fbcb6cd2a4cca84f5923af9685fc31d06c44d	5	5974	974	623	638	7	4	2024-06-05 10:52:01.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
640	\\x655dc6a168cff8cc111d26a802887c4769a55e3d057e2e88db54f2107b85c963	5	5999	999	624	639	4	4	2024-06-05 10:52:06.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
641	\\x00e28ce07ed1e06c5d019f485de633ae786f4042a7d30b2ab01a4a8aec26b304	6	6013	13	625	640	7	4	2024-06-05 10:52:09.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
642	\\x8e5521c3869c51cadc291a3a02d9745ce86493adc7292274c69daa937752a58c	6	6044	44	626	641	14	4	2024-06-05 10:52:15.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
643	\\xabb8c86925922a8df5f524b62c29186f925a2bb756329953cc86bef756b61798	6	6052	52	627	642	12	4	2024-06-05 10:52:17.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
644	\\x29a3f9ea76fe934260f13aee34c86a880a198bf310556f8a5237d83e63195387	6	6084	84	628	643	40	4	2024-06-05 10:52:23.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
645	\\xde91742721ad8fc7b790e290f94da29e0bfce0fbaee46831571e3c03b1482e1b	6	6103	103	629	644	6	4	2024-06-05 10:52:27.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
646	\\xd64aff804294ae2e2669fb33259ee31cf861a4bd0ebe1a308bace4f2cd3548f1	6	6113	113	630	645	16	4	2024-06-05 10:52:29.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
647	\\x216294359e3d7d2ed4712b26471e692cb6b289e10cad480143676005785ae4c6	6	6114	114	631	646	6	4	2024-06-05 10:52:29.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
648	\\x27f28f4192faa703825964f81556e800b2cc1dd63518535e5d9fef9ccc169798	6	6118	118	632	647	16	4	2024-06-05 10:52:30.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
649	\\x1e5ace19ab1ad797ce7dab61f60d9f3709d4f3c3c0fb0d1d2e245826feab82e8	6	6146	146	633	648	6	4	2024-06-05 10:52:36.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
650	\\x5193258eee86df8d6600ce6d0a17f7d37bf490f90d88ac3e03d8efc5d8e08890	6	6186	186	634	649	4	4	2024-06-05 10:52:44.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
651	\\x1a138d27ca6b71f9209ac12984f87c87f5f3e7c0faab51118e6713185e3d95bf	6	6218	218	635	650	6	4	2024-06-05 10:52:50.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
652	\\xd642613813d9331480c965ca1eac51f08366e78c624577b166466803e47ae248	6	6235	235	636	651	13	4	2024-06-05 10:52:54	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
653	\\x4910fd5076ed00ed8da6447ecf831de2cb6a7314ddc9ed45a212c3a273171207	6	6244	244	637	652	40	4	2024-06-05 10:52:55.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
654	\\x572dc9b87fe1e8432ffede907ab56fd96e56c3c871e9c85a9852c79b9e4c251a	6	6261	261	638	653	40	4	2024-06-05 10:52:59.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
655	\\x948fc3393964c46bcd25eafa60d224be0ac2d1e00350d53a16890a191b5a0560	6	6263	263	639	654	4	4	2024-06-05 10:52:59.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
656	\\x5a48e22c1f24fd6e3ce06479babd00edfd2c954959ebecb86f71819a47551212	6	6274	274	640	655	13	4	2024-06-05 10:53:01.8	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
657	\\x21caa7df7bea34852e1fddc37e43511b04bc2dd5b16e4c2481357cf78a6ef21e	6	6283	283	641	656	21	4	2024-06-05 10:53:03.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
658	\\xc0a4927a8f775f7bd3b0684635402121d7010f75183d81f2703729ed82a46d15	6	6287	287	642	657	16	4	2024-06-05 10:53:04.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
659	\\x69b3e3aeb33ea1248ddb6631b6cd1d34fb4189d86be7b1f0b4c06074e0aa5c9b	6	6290	290	643	658	6	4	2024-06-05 10:53:05	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
660	\\x05803112ec26003d7ed0b93bc66ffedc00495f5db864a50fafc3cb97bfbac66b	6	6309	309	644	659	7	4	2024-06-05 10:53:08.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
661	\\x283c2b784a43756fa4a58ede7c5907b42a85e6f20af7a88441c4249a9c10da26	6	6381	381	645	660	40	4	2024-06-05 10:53:23.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
662	\\x487291c9e85a98a9515a368dcb60fbda08b19e3cb1af5212265d1fcd3f9b575c	6	6383	383	646	661	40	4	2024-06-05 10:53:23.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
663	\\x2562f157a8c699c9019e0029521a975a7cef32d6a3815c711cff9cb8b088b3d8	6	6394	394	647	662	7	4	2024-06-05 10:53:25.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
664	\\x42b645891d0a699c38a5afdd9208ae01703336864b9b60c95cab8893a0d965da	6	6395	395	648	663	16	4	2024-06-05 10:53:26	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
665	\\x71b9c107ce197614062cebbd1328c1ab0421ec4676148c154855c8046ae0a540	6	6400	400	649	664	13	4	2024-06-05 10:53:27	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
666	\\xe0849633f3d3adf098a50f2547c8dc51ed23095912c67bd6d1f5cf6313c66cc3	6	6410	410	650	665	4	4	2024-06-05 10:53:29	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
667	\\x17cb7852d2cddbf4c9c63b056dbfa74699bda611d5217fed9a622122722906cb	6	6417	417	651	666	7	4	2024-06-05 10:53:30.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
668	\\x3b98ee4770572d34a13421a0ee4f5d0568aeef4c1048f94db6f67b12243ce328	6	6420	420	652	667	16	4	2024-06-05 10:53:31	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
669	\\xb7784855dd8d6ecc5e275781b974c8d094c90bde4a5f028fbc688c3a33b78c41	6	6422	422	653	668	13	4	2024-06-05 10:53:31.4	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
670	\\xb92e103fa76e53fa69821327799ca582e6985bcce4713ad4d0c04b008dced9ec	6	6431	431	654	669	7	4	2024-06-05 10:53:33.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
671	\\x6c0d02c8e24dc1c71dd995018b29f32e3af2cb1273a7a4ba0f674ce63f6ef12b	6	6437	437	655	670	4	4	2024-06-05 10:53:34.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
672	\\x3136dbb81fefb3e304516dff3c67cc9bdf6e5c93e33576dd786fe1b002a7c0a5	6	6440	440	656	671	40	4	2024-06-05 10:53:35	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
673	\\x738eb0855a8ed356b1d4ec5034d9c1e5c32dc9ce8568a579a0bdd6c210b876b8	6	6451	451	657	672	13	4	2024-06-05 10:53:37.2	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
674	\\x32aedc7a81c79586ce001a6a6fd1f3a979656e2b13e72c11ca9eaaafa66ffc06	6	6465	465	658	673	16	4	2024-06-05 10:53:40	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
675	\\x13d66ab77d3ea721dc87d50732d4c6a4dc2e219128cf470f76fae457e269574f	6	6477	477	659	674	4	4	2024-06-05 10:53:42.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
676	\\x79bda08567a888e68b699868c17db2128b17fdfc6ee5ec928ee770a2a93de343	6	6491	491	660	675	40	4	2024-06-05 10:53:45.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
677	\\xa1cd2b12b8592ca77a499d2e5854c38cbf423f1a9bce89327be774c9aa5df506	6	6517	517	661	676	21	4	2024-06-05 10:53:50.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
678	\\xacec7fd574df9fa62cb5d9ebef2db30709daac8eae1801d29fb2fa801f8daf9f	6	6518	518	662	677	3	4	2024-06-05 10:53:50.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
679	\\x2c2ec23b5e11a5225f278a354a755acbd3c756a12eed42f3a2961a406350c118	6	6519	519	663	678	5	4	2024-06-05 10:53:50.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
680	\\x572389cb553fee8e421a87e0a41f0cd4fa94f1cea05881e4c0f6fcbacd82b452	6	6522	522	664	679	5	4	2024-06-05 10:53:51.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
681	\\x34bd93d42e24a20069bbb273fd4c66adf72f37fdc5636aac79ad28c47b286f71	6	6534	534	665	680	40	4	2024-06-05 10:53:53.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
682	\\xb5190bafb2318623b978c1bf6eb3a6fd9b65dba1740710f1df9c6ecc136d46ca	6	6540	540	666	681	16	4	2024-06-05 10:53:55	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
683	\\xb5cc54c9653fb9ebb6cf0aed8ecac1adee7e408ce7f4c41a6987ea57bf8c21e9	6	6545	545	667	682	40	4	2024-06-05 10:53:56	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
684	\\xbc3261c78c39547a31a3713e097f788fe46d829a248bbba7f182ee93f7e854a6	6	6555	555	668	683	5	4	2024-06-05 10:53:58	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
685	\\x971cdf4d5d1b1ac4ae06bde2013941672d8210f53f8d781a43641760d8f27504	6	6566	566	669	684	3	4	2024-06-05 10:54:00.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
687	\\xc03dc10fbd44acbf4421d61434d6aaf0f6af6fa6fdfe0ab9e71f126e4a2469f3	6	6571	571	670	685	12	4	2024-06-05 10:54:01.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
688	\\x5721fd5b1409a3fd52ff19e1cc4eb3784cefa69979cc07673ebda72d3952adbb	6	6573	573	671	687	6	4	2024-06-05 10:54:01.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
689	\\xdb09f23d9d014e72b0d6f274b0f5a533b49e1f473d1e4a3c6ed45a9fff17b157	6	6581	581	672	688	3	4	2024-06-05 10:54:03.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
690	\\x483416b98a94f6f8977e6ccd09f74d9fd02acc7416374a2fa1c425e5f7dc85fe	6	6590	590	673	689	3	4	2024-06-05 10:54:05	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
691	\\x79af0efca992dcda3da54d1ae4ff0cccd1e7a7712487c50e9c2ccca779812941	6	6592	592	674	690	16	4	2024-06-05 10:54:05.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
692	\\xf6875ebbc41fdb8886c54745c7b9674f09e353dbee922f8f5cbccf956481d80c	6	6603	603	675	691	14	4	2024-06-05 10:54:07.6	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
693	\\x3cb284d75d69bab4abee7cf703fb3fb14a287d1bf9d1a61e23a1867aab5d20e6	6	6626	626	676	692	3	4	2024-06-05 10:54:12.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
694	\\x30176811e1f7892b15ac3fe1b9498b77a3922fadcd4be6ba43a4a28c0e5479dc	6	6631	631	677	693	4	4	2024-06-05 10:54:13.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
695	\\x30f6af6f66cc641c56b8bff9804103837be50ba5b65389812709d25d3b10f8ff	6	6641	641	678	694	21	4	2024-06-05 10:54:15.2	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
696	\\xc7b41c1a467199f74e4f1306214cdb2df07623131c6cd676d884393d23935240	6	6660	660	679	695	3	4	2024-06-05 10:54:19	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
697	\\x1eef49b7835f2375082959de7f668e3400f47e07a3979ce7668f13e7415890ea	6	6665	665	680	696	40	4	2024-06-05 10:54:20	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
698	\\xdfffb8e8277d29cd7fa6441aefa860b4cf7495076de58f29eb88b969ab901b60	6	6667	667	681	697	16	4	2024-06-05 10:54:20.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
699	\\xdc289bb58559e480385e7709074fab4c3fdcd8e4cf4bd586e8ae6c5ce8e3288b	6	6674	674	682	698	3	4	2024-06-05 10:54:21.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
700	\\x01add37405a2d46351b345664898fe1044632cff249f7d489fcf1757717f3ea1	6	6676	676	683	699	12	4	2024-06-05 10:54:22.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
701	\\x1f20a4e11e89a1623613da9c16fe8dea9f387febfa039fb9974d583125bb25e3	6	6691	691	684	700	16	4	2024-06-05 10:54:25.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
702	\\x86fbc89034a55178a30eaf425706ccbf46752501ef908d8a9b220bbef3e52965	6	6704	704	685	701	14	4	2024-06-05 10:54:27.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
703	\\x455bba02b1571c387593677eb5f05b658e19a2c08cd0f0ec4e16056ec4ba8962	6	6716	716	686	702	12	4	2024-06-05 10:54:30.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
704	\\x66f371e616437477e6446678bb2472734f5b77d00fb773e757f6ce592d3ebe01	6	6723	723	687	703	40	4	2024-06-05 10:54:31.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
705	\\x1ef9e327ba6bd07e4acf72d9479968a6f3445ed74377734b95781d42b62cdac8	6	6729	729	688	704	13	4	2024-06-05 10:54:32.8	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
706	\\x2897af3ed8b855639c082005e73e7a6764455c8b74dcc9a9fa70796d95ef999c	6	6775	775	689	705	16	4	2024-06-05 10:54:42	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
707	\\xf55216d4e8afecfaa87816b39d3f20fc30c7c3eabc069d1cb0123e55979efaa8	6	6784	784	690	706	3	4	2024-06-05 10:54:43.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
708	\\xfcd07707299abf115c9201643e53cbd132cbcc8ffadcc4ffb619b8d9c19e8a2f	6	6812	812	691	707	4	4	2024-06-05 10:54:49.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
709	\\xe63048bfe5644d29bdf09f826682064731864ea2be1858146df2071d8108f397	6	6817	817	692	708	6	4	2024-06-05 10:54:50.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
710	\\xac652cfb8d57e6e263728652b87730a6782fe650e86be69aacd4b0e3b42a0af5	6	6819	819	693	709	14	4	2024-06-05 10:54:50.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
711	\\x7fedbc5795caaf6f0dec503110ed3146cf5d84774d9a57eea6b2a5343516499a	6	6824	824	694	710	4	4	2024-06-05 10:54:51.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
712	\\x153456eaec0c7e4e1f5c251c1d9646fe98207e347c9a0dafa65dde394da351d2	6	6829	829	695	711	14	4	2024-06-05 10:54:52.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
713	\\x2e68f7cb0106163c88147fa312c2d8d2bcd4a92777a66c680be10ab9b8417669	6	6830	830	696	712	5	4	2024-06-05 10:54:53	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
714	\\x91b39c641ad8fd284d1ed914873998bfca47dc8d883857dfb666807bcfafb5ac	6	6846	846	697	713	16	4	2024-06-05 10:54:56.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
715	\\xd5b7527fc1df81209489b2f64c2aa889434e2cb4a7bd181ea0d0c0ac2622589a	6	6857	857	698	714	4	4	2024-06-05 10:54:58.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
716	\\x6e17f33ab95961530b121700d4d0db2294f2d210b6b0524ac0c89c155293d2ca	6	6862	862	699	715	40	4	2024-06-05 10:54:59.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
717	\\x80c024d7a9c9bf19a84eac42897ea88f01b8de0f0b862a25e2d19a9a8822660c	6	6870	870	700	716	6	4	2024-06-05 10:55:01	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
718	\\xb8512a3a7e126fbbc00574be829c8cfdb20139c3c10cedcb7386ee23e51a7a01	6	6881	881	701	717	14	4	2024-06-05 10:55:03.2	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
719	\\xea23d9cad96bcc8a7ea5e1ecd4689757b30f68a91d4913526a22b7910f245962	6	6890	890	702	718	16	4	2024-06-05 10:55:05	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
720	\\xc45d7b2d816932d0294c2e75213a7ba49d1d16740e468ebb3a7d78ce5c30c776	6	6902	902	703	719	13	4	2024-06-05 10:55:07.4	0	9	0	vrf_vk1jhu3e8zwnkgg6qyy87ng2x5nv9lvjfzzj7ad8hq5n4czul95yymq6xe7rv	\\x19ef2d309c7456a4b5191b0db3da6c841dbff1c9b270387fcdaa671174a90c58	0
721	\\xdf39827d03de1b35af60101d75a62398506ee910907aab2f0e282de0f92fd384	6	6905	905	704	720	21	4	2024-06-05 10:55:08	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
722	\\xf5e48ec7827fd14ae2827ebc55830a1122627b1cd4d423f1adc9af099e0586dd	6	6920	920	705	721	7	4	2024-06-05 10:55:11	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
723	\\xf06fe5d2f4a8bbd16aafb2a889e4d4ad30d4ef9c93773088d81fcf0133b8f803	6	6934	934	706	722	14	4	2024-06-05 10:55:13.8	0	9	0	vrf_vk1599exzfy4n73aeksnvg9we6ecpqgsuqumjdlul2h2rcaqgjczvvq7vqqph	\\xe7ae53eb4b2f5587d90399d78c6cdd3797eb5457ef87e34a464a9d7544ef7d03	0
724	\\x87e54e1f755acd2cdba7993b11f1da12e03fea69c540617e51ec30fee993cec1	6	6942	942	707	723	16	4	2024-06-05 10:55:15.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
725	\\x6d521823c926d744c4efe91aae3ef9f8c233f8d5a5febd7ada060556c57de129	6	6945	945	708	724	5	4	2024-06-05 10:55:16	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
726	\\x56833243709df5d6b3fe7044cfc97f46bb19aefe983840c3db5e7528768ea941	6	6953	953	709	725	16	4	2024-06-05 10:55:17.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
727	\\xbdd9e67381e8a25f7495bd077777efddba352e788bdd0eadb650a0af3f108e82	6	6968	968	710	726	21	4	2024-06-05 10:55:20.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
728	\\xb550f7c31a039e91006904629e9610332b6251af7280100911fd9215cffd4b0f	6	6971	971	711	727	5	4	2024-06-05 10:55:21.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
729	\\x39667b8efa3511b74e7a73d758601f13c4d0c3887dd22c2c81bede7c9ef195f0	6	6974	974	712	728	7	4	2024-06-05 10:55:21.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
730	\\x206f1ab642cbf6b78dced8c09c6373936cd53333c92b02b432a7071e65f4b80e	7	7004	4	713	729	7	4	2024-06-05 10:55:27.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
731	\\x75bd7b2ef01ae4804204bac2cf3b408e4497a4e862b0a7c08d947c01d4eb86d7	7	7032	32	714	730	3	428	2024-06-05 10:55:33.4	1	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
732	\\x59d361a697ffcef37762b9985556078166666c49037f0b4f74b41242db4101ce	7	7035	35	715	731	5	4	2024-06-05 10:55:34	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
733	\\x6049706e16ea9670c171921df9a1fbcb7936e4c04016c8535316e4ace4080c94	7	7036	36	716	732	5	4	2024-06-05 10:55:34.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
734	\\x711529e1d9b953e9ff02be2fe681ef0ae9d176da1addfc422d77f3d85800ac9f	7	7039	39	717	733	3	4	2024-06-05 10:55:34.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
735	\\x79c01649cec3fb8e001087e5ac10649fffd0462cebe171818f1916235a8a0480	7	7071	71	718	734	16	2363	2024-06-05 10:55:41.2	1	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
736	\\x5a8f1f5f6609f020fe2b5a434ad724cbb0005733dfc932470b62da5712e09af6	7	7077	77	719	735	4	4	2024-06-05 10:55:42.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
737	\\x6521ad3d7322431d200e0520a30ebb8da078aa442e066e3ae77db464207c5b8f	7	7084	84	720	736	6	4	2024-06-05 10:55:43.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
738	\\x11d5737ab2d707f186c636f207e7df0f16e36392ec265e898cfddcb24b077ad7	7	7109	109	721	737	5	4	2024-06-05 10:55:48.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
739	\\x1f4c28273fa4a8e702946507fd2ab6be0b360c24a89eb02511818bbf1694bc65	7	7154	154	722	738	3	4	2024-06-05 10:55:57.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
740	\\x24652610f8a6a16de3fba61e7b6bcbc5f77a5dcca293cd14418b92ffeb58d5a2	7	7196	196	723	739	4	4	2024-06-05 10:56:06.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
741	\\xd0210201e3d34bf404a714c1b7e2815807ebe86687a8eee5d942e388113ac87c	7	7215	215	724	740	21	4	2024-06-05 10:56:10	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
742	\\xdbe7cbc8869c01302a10b52577593c06353c2e2611e58d0756a09c24c6f03556	7	7233	233	725	741	6	4	2024-06-05 10:56:13.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
743	\\x7838f85224a57874acea1ea12aa50735229d41b59bb28a9954ef86a9d7166432	7	7276	276	726	742	3	4	2024-06-05 10:56:22.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
744	\\x81ca26ec1f432d4b5d9fb82edc3f88bdaa7b64c6a46d50f9484327a59eb67dfc	7	7279	279	727	743	21	4	2024-06-05 10:56:22.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
745	\\x05babcf65d86ce8733a044f1f64c8bd476b66c52e811997b95c4cc0f37dbd189	7	7284	284	728	744	12	4	2024-06-05 10:56:23.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
746	\\x96ea2f4ce52969ec558cb935446cfd174b46b40f75fc181e41fd9b1e19249c66	7	7285	285	729	745	21	4	2024-06-05 10:56:24	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
747	\\x204aaa05349e6a75617d710f5370d6d2b112c7a14bfbc283bfec35a49cf2d575	7	7294	294	730	746	21	4	2024-06-05 10:56:25.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
748	\\xd7682e7d55193e3815bc36c1c8ee5118b367b9ef0f2ebd75c97305f59dfaed3c	7	7310	310	731	747	16	4	2024-06-05 10:56:29	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
749	\\xa59108a68de7b1bac7c157e7f3f5cdc2c7dfbdc102d08c66eda9aeab428530f3	7	7312	312	732	748	21	4	2024-06-05 10:56:29.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
750	\\x8486260b1ce7775028a9af1415206b2bfd64dcc07ff02eb302bb2199cbd0f5f8	7	7315	315	733	749	4	4	2024-06-05 10:56:30	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
751	\\x5af8556a65005604c6c6be92835f2a3cb820865ef41eb9ccfd36d53137df73af	7	7344	344	734	750	7	4	2024-06-05 10:56:35.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
752	\\xc490ef8e35c227cc3e5527627cf6e042862447a35c36bb85dae57a32041a4a66	7	7352	352	735	751	5	4	2024-06-05 10:56:37.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
753	\\x3ac98ab5a61819d0fd27504f08e6d037c5a051e9dc2b9c724489211ccd7a14a0	7	7366	366	736	752	12	4	2024-06-05 10:56:40.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
754	\\xfc93707e7be0995f5d2aaaee874de59fd7cb92fc1138d2ced0c3f628d9f28622	7	7373	373	737	753	7	4	2024-06-05 10:56:41.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
755	\\x56f7d1b4a112f0cbf952b8da2af9aebbca5bb656e922fbe6c578da5c6a87d8eb	7	7378	378	738	754	40	4	2024-06-05 10:56:42.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
756	\\x0183c653588a2fe7a7c1e437080ae2903e53becb9a4733f267bd2d5070bfba2e	7	7388	388	739	755	40	4	2024-06-05 10:56:44.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
757	\\x3b76ccf3e3ffb509ef0d33749ded8d8ddee25e7171ce5dbd06147ac403720c2b	7	7393	393	740	756	6	4	2024-06-05 10:56:45.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
758	\\x02b5733f06799b08173ae7d346bcf056fbd26658ae73d0a365c53a491e9c13b8	7	7402	402	741	757	3	4	2024-06-05 10:56:47.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
759	\\xdf887f9ab52d566c35e02cb3bbb335c0afd74b2f30025e80b9c6672af61e4cd5	7	7404	404	742	758	40	4	2024-06-05 10:56:47.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
760	\\x9726d6c072b27741a3eacae171a7a148c585088d86c1a87a3142a2563720be4d	7	7416	416	743	759	6	4	2024-06-05 10:56:50.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
761	\\xbd69570c3b50552af3538258dfc79ffcdcae32729502bd7658cce96aa91da6f1	7	7423	423	744	760	5	4	2024-06-05 10:56:51.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
762	\\x5d6a126cd37163a5e62c071c3914d14bbff28a99bda8b612c0c5b6be3e445e89	7	7426	426	745	761	16	4	2024-06-05 10:56:52.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
763	\\x94a44913fc2f798d9aec475e4301c63f8b482a7a790529735544472614f433e5	7	7455	455	746	762	6	4	2024-06-05 10:56:58	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
764	\\x0bac5b2ecfac641fdc2d312eba191b9a28cecea0b4e378be9d71b8a1e15d39b8	7	7463	463	747	763	40	4	2024-06-05 10:56:59.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
765	\\xd3f284bf9d6dedbc933a0faa0ee6eac11724a074f376a5d3261bde18f0338c07	7	7467	467	748	764	7	4	2024-06-05 10:57:00.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
766	\\x3423eb71f19fce11a6c3a0dd523757e2fcc321d13899a8d7a490d8eae8caf687	7	7485	485	749	765	12	4	2024-06-05 10:57:04	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
767	\\xeaff895697112d569e3307cdf0e4c5f4c75c1c5846e6e420420c86c3054a4b44	7	7489	489	750	766	12	4	2024-06-05 10:57:04.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
768	\\x50249eefffc78697ec99b0bec71ec92dea82e2f334f5c0b444ec3c4db649ec55	7	7498	498	751	767	21	4	2024-06-05 10:57:06.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
769	\\xfda4fc280408cac6d6975a6f2a1bf3f441c0c0dd4b905c797fbcca5ebb441e73	7	7509	509	752	768	7	4	2024-06-05 10:57:08.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
770	\\xabe4af41dad34d217db42b891a5d43ddaa0d626256ca17c12310eca11d6e9aa8	7	7517	517	753	769	4	4	2024-06-05 10:57:10.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
771	\\x0ed670b24068821b9cf7e91c6be2f7926378cc7ed90c8ede11d691d28887d1e9	7	7519	519	754	770	6	4	2024-06-05 10:57:10.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
772	\\x51f67480672a0e7dc18e719ff58d23950315d0ac9f283dd1c805de9becc8996a	7	7526	526	755	771	4	4	2024-06-05 10:57:12.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
773	\\xeb6c7ce2ec74e3e3971f44e4390e79ab2257f71b852fef074be24ec2bb469ef0	7	7527	527	756	772	40	4	2024-06-05 10:57:12.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
774	\\x4b3f9dc1168093f7feb5eda4875a007a869729f350f0753c5542d0844f89aaa3	7	7530	530	757	773	6	4	2024-06-05 10:57:13	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
775	\\x25a1873faea1036b6bd4885aa633db44b35b0a9f1f13d2eeec448f543b3cae69	7	7565	565	758	774	40	4	2024-06-05 10:57:20	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
776	\\x28a90c6defffe00a1bc2207e4928618bc77a70c30955442ef9b12ecb23ab3a4d	7	7578	578	759	775	7	4	2024-06-05 10:57:22.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
777	\\x4b9a22ebb41696530deee6dda7eee9445da5551c84e0f2f3408c2786c1cb3abd	7	7592	592	760	776	6	4	2024-06-05 10:57:25.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
778	\\x2a6ffc67e5ae82a35d3370cb4fabb62a328952835ee9a73d01df7da88b113bc9	7	7596	596	761	777	4	4	2024-06-05 10:57:26.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
779	\\x17bdb807cb33abbf4f5c2ccf61f935d2d606b0f4829052b99fa63260b7990d5a	7	7604	604	762	778	7	4	2024-06-05 10:57:27.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
780	\\x66bb0dba38ab371077fc564cbdca36a7ede686c5c53281c7b04c4fee485a5ca8	7	7622	622	763	779	6	4	2024-06-05 10:57:31.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
781	\\xf558aade005a208491531d3121ee1b5e138363c15c9a221225346d71b61f29a6	7	7633	633	764	780	3	4	2024-06-05 10:57:33.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
782	\\x50647f650d3c33a0001d4b97ff62a5661802700a62ef6ab38705cb7ee14160e1	7	7649	649	765	781	16	4	2024-06-05 10:57:36.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
783	\\xdfb84d767eb15b86f3eae07ec780a10c147051d31aaf1df70fd06b30144f8960	7	7666	666	766	782	3	4	2024-06-05 10:57:40.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
784	\\x0f982f9f9e8d953e070bb3f959384099bdd27924bed2d2d1f3fbaa0c86001a3c	7	7668	668	767	783	4	4	2024-06-05 10:57:40.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
785	\\xfd0103218eaf54c9ffa01b4f341658fa32e228acbdabcc961cd4a30aed0f688b	7	7679	679	768	784	6	4	2024-06-05 10:57:42.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
786	\\xc2d3dfd0aba61ec0c62df067643a538ecbf2248852e07a2db35f827d5135a7e0	7	7690	690	769	785	6	4	2024-06-05 10:57:45	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
787	\\x68962b554f5c4b6d7eb8a58350a708bf27198749d2f7cf56e1e55c8c22442b95	7	7708	708	770	786	12	4	2024-06-05 10:57:48.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
788	\\xef43b53022d59aacf5a15b1472c7299abc46a941290b0ddd31e6fe0a21deee04	7	7709	709	771	787	16	4	2024-06-05 10:57:48.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
789	\\x615e4b3abcdfcda0e2bc63438bd7049a69b45f2944a7bde2e658587571f8460b	7	7713	713	772	788	7	4	2024-06-05 10:57:49.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
790	\\x9b172d3bb74a22132f382f48bad8bc63030c768aade695006f416054399ad626	7	7721	721	773	789	16	4	2024-06-05 10:57:51.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
791	\\x2ba20b232cd74ee751e9c3c4a6d08c4744ae0098a0ae409be7bef2c7ce933b38	7	7726	726	774	790	6	4	2024-06-05 10:57:52.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
792	\\xa171a34ec525f09b10083c2a8f59cace2f57eea8f56e96aadd6cc2514c545e63	7	7729	729	775	791	3	4	2024-06-05 10:57:52.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
793	\\x7f56cba0ac356dfa839845ce629a2a0f07417fbe09c45f8ad1d8059958bb4e4f	7	7737	737	776	792	7	4	2024-06-05 10:57:54.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
794	\\x0ec25295c049dd6916dccf0526fbeaa7bde3b1b72602ed3170a90f271a69c04b	7	7756	756	777	793	3	4	2024-06-05 10:57:58.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
795	\\xd9ace80efda90cad02462b7cfc8a74d8e9491ec40c6f72971991087be83e755d	7	7761	761	778	794	6	4	2024-06-05 10:57:59.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
796	\\x9ea873ff33e810fede9b301b5aa03f157d8f23b4b3bebc85e7d07b5c24fbacee	7	7785	785	779	795	40	4	2024-06-05 10:58:04	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
797	\\xa9f3dbe21f5cbcd5aa4c83c53515929373e13feaef92fba9c86b5f04f33994ef	7	7792	792	780	796	4	4	2024-06-05 10:58:05.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
798	\\xa077c67a81ba47e78ba1eb315975d91788a5fe44a2e7098905c8ce866dc9595f	7	7799	799	781	797	7	4	2024-06-05 10:58:06.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
799	\\xcd7f0d49e6cb3ed06f62941458c630dca8a4f8ecfb8e3a79efd6e63a0e62966a	7	7805	805	782	798	21	4	2024-06-05 10:58:08	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
800	\\x09134e177e181a022f274a4cee2dcc8a138293187369161984a14cace159e403	7	7809	809	783	799	40	4	2024-06-05 10:58:08.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
801	\\x6cf7f64d29f906da741e1779bad678946ab2693132440e58428c19949571a5dd	7	7828	828	784	800	7	4	2024-06-05 10:58:12.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
802	\\x799de62f57fb8031358f13f20196039e9cf7d804c55a4cfb0b0bba736072f0f8	7	7849	849	785	801	16	4	2024-06-05 10:58:16.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
803	\\x28bdf47826675814c54b10892a832763706b6c4786f19ef14d4f068359501e53	7	7867	867	786	802	12	4	2024-06-05 10:58:20.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
804	\\xf989df0decc1f566a72e70df405b42e5d45c2294bd43c73b3d9d27cecfb24ef8	7	7874	874	787	803	6	4	2024-06-05 10:58:21.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
805	\\x75f58501a29fc942ab3e6d1aa7a61697a69528caace705fee5fc6402ee4f762e	7	7886	886	788	804	5	4	2024-06-05 10:58:24.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
806	\\xac124aa25d322c94a252397051c330da943bb67081a08b786845c6a273a15256	7	7897	897	789	805	12	4	2024-06-05 10:58:26.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
807	\\xa7b826404a308f5449b4f2b4811d7b3af83d0a0ed3792d2fbb9c25bc0385376d	7	7899	899	790	806	5	4	2024-06-05 10:58:26.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
808	\\x915cb0bf9c4332cc0f2a8a71642b6ed6516534e667e8ef96f34ec06b6cd15cd9	7	7901	901	791	807	12	4	2024-06-05 10:58:27.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
809	\\xf9a37d5c0f6ef99a4add81f1ec9dc313b1a7da08ca7471cc6fe8ca63c23f4221	7	7905	905	792	808	21	4	2024-06-05 10:58:28	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
810	\\x6637f201afd1f523feaae70322b26a15615fb0ae0bd1bd3dea91df869ac9d9fa	7	7909	909	793	809	5	4	2024-06-05 10:58:28.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
811	\\xe27846035c90459786cc961a408f49093a80c1bb0fc3e9762e52b9b8f0cfaf52	7	7912	912	794	810	5	4	2024-06-05 10:58:29.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
812	\\x44281519831ed424b259567a2e39e8013c55a08536326eb2c9bb0dcf56fcf164	7	7919	919	795	811	7	4	2024-06-05 10:58:30.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
813	\\xa511ffe01fc2b367942c9ca98c1033e20e07efa0e742667395942185b3bb10dd	7	7922	922	796	812	40	4	2024-06-05 10:58:31.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
814	\\xc5d3c6e4dcd522c8e373b9240fdb87c1f54564659f8b94be6c475ffc12a1c33e	7	7923	923	797	813	12	4	2024-06-05 10:58:31.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
815	\\xf3ee7ed04271d3d0b40abbddfa97a51e2bda7aebec95f0af00f642edfe6db18e	7	7946	946	798	814	40	4	2024-06-05 10:58:36.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
816	\\x6ca76d80d5415ff011c599bfd3fd8d8e53669a3841096993ca9bbbf3194f98f2	8	8011	11	799	815	7	4	2024-06-05 10:58:49.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
817	\\x4ab90caaf64f7d6de6a0170b4601a9313ba87454f0ea607eae52bf00ce6c09a2	8	8015	15	800	816	6	4	2024-06-05 10:58:50	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
818	\\xc72e22270d1e890ff74223808012bfe6dceb2a2475ad40487d4f3095b1919c11	8	8016	16	801	817	4	4	2024-06-05 10:58:50.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
819	\\x826015f6c02c9ed1bca88d5fed319c3516c95de1bd8dd9f59df38ee40166b79d	8	8021	21	802	818	7	4	2024-06-05 10:58:51.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
820	\\x3f8f8d309dc1e8c43725e243ca7c9d9550a50468d3f62b6251d9f33f1cd2f1d9	8	8048	48	803	819	21	4	2024-06-05 10:58:56.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
821	\\xe9f0a586672fa3eab31e0994ff8fd4ebbd90969eeb21bbe8293ed5e4c38560f8	8	8055	55	804	820	7	4	2024-06-05 10:58:58	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
822	\\x186c884dcdbde520d72887de59d7d6f770e5bd6468468ed30e367a863eb7519f	8	8063	63	805	821	6	4	2024-06-05 10:58:59.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
823	\\xc66dc522416fadce4304029463dc4674e9aaef25d6f44436f4215469ce9a0b6d	8	8065	65	806	822	6	4	2024-06-05 10:59:00	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
824	\\xb1f8e5fe6d571b5ab12e8aaf1d3aa851d66838804516ce78a417282232c9d3ae	8	8067	67	807	823	40	4	2024-06-05 10:59:00.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
825	\\x0735ec1da2cbb8ad0b8d102851b5b26982eb0ba7d4e1d6f350ee6af37c44ff2c	8	8078	78	808	824	12	4	2024-06-05 10:59:02.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
826	\\x509413f9178bbb4e5364e9be64cf5f0f89e55498567c7e4c376545efaf36a659	8	8110	110	809	825	5	4	2024-06-05 10:59:09	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
827	\\x7e274b042da65a253d7dcb54efd5bf6b4e7bed83b3bb6f7b05cc91cb910c5a2e	8	8120	120	810	826	21	4	2024-06-05 10:59:11	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
828	\\xd74cbc92d81bb49304b9dd8403d80a321a7ef30af7bfb7717c5791d63b98cc79	8	8151	151	811	827	5	4	2024-06-05 10:59:17.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
829	\\x7e6be2acd0086d5ff8debe483fa73e34413a57e6989b327c59b535538a4cf03c	8	8154	154	812	828	16	4	2024-06-05 10:59:17.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
830	\\xf79d15f80c7c0ba325f561ee423acfc236d1808b3134a049b6a2835aee14585e	8	8155	155	813	829	7	4	2024-06-05 10:59:18	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
831	\\x46b0317090e1c2a44c69570ae2a4487a59ae841e911992a9899a027190964828	8	8159	159	814	830	3	4	2024-06-05 10:59:18.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
832	\\xcf817fb9697977b40a7833ae8775b521ba3827b0cb174fd8183787676abd9a57	8	8177	177	815	831	5	4	2024-06-05 10:59:22.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
833	\\x70cf6f9c30dabdba4042bf2385a009b8c52c275304728b523aba3100d30a1d31	8	8189	189	816	832	7	4	2024-06-05 10:59:24.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
834	\\x136a0beeae14741bba799569454d6d41b5c0c3a2785d279e59e255bf470ce64d	8	8191	191	817	833	7	4	2024-06-05 10:59:25.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
835	\\x4182d78350ecffac3834945b1667dba40e55a9cd186ac0eb107da341f95b41ca	8	8198	198	818	834	12	4	2024-06-05 10:59:26.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
836	\\x003d27fd469796c542a3b9e210f95ea282c19e75097337494fff90b024da3520	8	8199	199	819	835	7	4	2024-06-05 10:59:26.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
837	\\x3e5b99a310ec8025ad9143095c06285dff82440f05c933a22a4852ab69ff23ed	8	8214	214	820	836	40	4	2024-06-05 10:59:29.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
838	\\xec29e80b9325f9aba4d06eb53d6b8de3426a0d82f5169c2217ab056288653bbd	8	8231	231	821	837	3	4	2024-06-05 10:59:33.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
839	\\x34b8d00e757a06f3e81c5213c5f3315b55bccc663e807911ce88d75170ad501f	8	8241	241	822	838	4	4	2024-06-05 10:59:35.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
840	\\x1bef9be5bb1f5b7d80db77b34fe7dbc6841c056672e22c3aeee0ec770ccd7758	8	8246	246	823	839	3	4	2024-06-05 10:59:36.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
841	\\xb5ff7c23b32dc199d12bb23c7cad4f83a6611be45162ed6871ed8cef5d9a3a94	8	8270	270	824	840	12	4	2024-06-05 10:59:41	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
842	\\x13198d75d502559dd79b5cdeae710dd52f099cdc99035c99e09eb8e81e57f6f8	8	8273	273	825	841	4	4	2024-06-05 10:59:41.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
843	\\xd6d753df12e58a8c26c9245307f20da1d9da26ea150fa64f401e1992ec5d9b95	8	8280	280	826	842	16	4	2024-06-05 10:59:43	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
844	\\x2edf8b58032504143a531715d336fd97509b1991a716c084e0b59bc7b884595f	8	8282	282	827	843	40	4	2024-06-05 10:59:43.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
845	\\x95950fe5ea4f69f4b74219f95de19afa2e01d40d20f1ce6e3a2372b696871cd6	8	8297	297	828	844	12	4	2024-06-05 10:59:46.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
846	\\x1ff80cc5bb13a2aa7f5c72dee3ed054faee96703f592b8780bf1bff4b3b9bd70	8	8304	304	829	845	3	4	2024-06-05 10:59:47.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
848	\\x5f0df97c1022012a1b1b332d21d0a3d7e02b8fccac2a413bb9ce1dfb75ccaaf4	8	8312	312	830	846	21	4	2024-06-05 10:59:49.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
849	\\x9f89bb07c6e901b22236b602003d09a30baee58c8305b07fc5832123914141dd	8	8320	320	831	848	40	4	2024-06-05 10:59:51	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
850	\\xd110b94b2dd54c49b33f81966950ce5561a704ffc82ef578f0904dd26289042c	8	8340	340	832	849	16	4	2024-06-05 10:59:55	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
851	\\x2c3790bde634e276847c99a1a405cd478a4d490901df7991abfc43dc79626bf0	8	8344	344	833	850	3	4	2024-06-05 10:59:55.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
852	\\x5d6187b485001f5b3eed71fd528c0d59f2fe8ceff90d9cb35a76baf2369d4c40	8	8348	348	834	851	12	4	2024-06-05 10:59:56.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
853	\\x6839d9e7d8d4a6915e79e050f9448fd5dcc3b64c0cff4afe7bf4ba822024490f	8	8361	361	835	852	16	4	2024-06-05 10:59:59.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
854	\\xba0ab461f39a324f9a2774ab88272c91e2b1ef0f6c3975b0052d1a6ae0fcd5d7	8	8380	380	836	853	5	4	2024-06-05 11:00:03	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
855	\\x92c3f37476df635ca6a6fbb5e2cf26fb926579745f09574045c9dd238e738f0f	8	8390	390	837	854	16	4	2024-06-05 11:00:05	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
856	\\x8d0b64df37a2756543f37c4d42ec167910f71611b8c10e56be993346dc8c4a76	8	8400	400	838	855	3	4	2024-06-05 11:00:07	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
857	\\x5dc294caf197a1bfecb3174e55e44a44a1f198966e628632ed2f1518e0ebf72f	8	8404	404	839	856	7	4	2024-06-05 11:00:07.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
858	\\x997330faf1020f779f057808cda331b859f95a164a408d265d39a00f54d412a3	8	8413	413	840	857	21	4	2024-06-05 11:00:09.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
859	\\x3ea831b34c27b8c41da40cbeabd0836c1028c9817ff57b1447bda5be8b5c0129	8	8429	429	841	858	6	4	2024-06-05 11:00:12.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
860	\\xe65ea21f24c5f8051f903812b4936d66e35ba674dee10c842e33ccfb08e40086	8	8475	475	842	859	12	4	2024-06-05 11:00:22	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
861	\\xbcebb6aab67f84722b7ff413d96924363b92db3e9306f06762df045799f2ff1d	8	8485	485	843	860	21	4	2024-06-05 11:00:24	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
862	\\x7c274459e8106f57f8de6d46dfb1551313b13de98ccb945837d4d7e8261a6b64	8	8486	486	844	861	3	4	2024-06-05 11:00:24.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
863	\\xe0dfb8041978626889fb0d0bf76c36aaa42877a5f685ece9c451cbaf2f38c115	8	8510	510	845	862	16	4	2024-06-05 11:00:29	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
864	\\xc7f1cac1055fcd9dc7d7145b352d42ab530905c9c8806e62542041f2f7ccd851	8	8529	529	846	863	12	4	2024-06-05 11:00:32.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
865	\\x9eb39a6cb4fe9a1aed81d8adc0cdb8e657485fc16e6e2676629b5c3bc43d6a11	8	8533	533	847	864	12	4	2024-06-05 11:00:33.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
866	\\x531ef7ecaf964dea74c79a33dee93813ee33cf759855aaffe19653b2b522defa	8	8571	571	848	865	40	4	2024-06-05 11:00:41.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
867	\\xf64012a229fe1492e45c13d790be953e7991dcb78608d442c9e8e932c2146baf	8	8580	580	849	866	12	4	2024-06-05 11:00:43	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
868	\\xb3172a58868d02809744b37c1fe669e3b1f215cc719f5f838f1342376d757a1a	8	8593	593	850	867	16	4	2024-06-05 11:00:45.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
869	\\x94fa6c2a4d0d9aee7594c3e7932b009bd813b1fd3a456adf433978eb000535aa	8	8595	595	851	868	40	4	2024-06-05 11:00:46	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
870	\\x69bace022dfcdc5f02a642e9c4c2366edc1f6e701bada927f156cf4d43e796d5	8	8605	605	852	869	21	4	2024-06-05 11:00:48	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
871	\\x3130a4b0c98f4dccaf25f1879ddf54c7f60b146b56f696bf4161deda75c937d2	8	8609	609	853	870	5	4	2024-06-05 11:00:48.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
872	\\xce9e441eecbae32a828ddacb7f88e15cfdb1b8113d9e1b8ef8d1177cab2f89e7	8	8616	616	854	871	40	4	2024-06-05 11:00:50.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
873	\\x41ef2b7d709a9dc6d702af6b49f55a2a8fb0544fd421db82376f58d4eeb470e8	8	8619	619	855	872	16	4	2024-06-05 11:00:50.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
874	\\x808554b1f1120b13a14301ec586d9516395b85783ce8800fbaf9943f222b2080	8	8620	620	856	873	40	4	2024-06-05 11:00:51	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
875	\\xd80b49eaf6df8dc8402b898f4f1445094697ccb652f8ce0103b4ae6d67146e88	8	8625	625	857	874	40	4	2024-06-05 11:00:52	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
876	\\xcba7e1be8f21b359a94d4a949540af9ec45011efe3244eb866aa44af448a6bd8	8	8631	631	858	875	6	4	2024-06-05 11:00:53.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
877	\\xdf95d6bea3ef1306277ec72974b3bfa3d4eb2b386f37d61e468f27a45d8c65fe	8	8635	635	859	876	6	4	2024-06-05 11:00:54	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
878	\\x08b4fc9ff2ca0b3185cf53ba46c75c7d75a70a76c804bcb6f2d4e21f1587fe41	8	8656	656	860	877	4	4	2024-06-05 11:00:58.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
879	\\xeea582c15919b86423af2ab6fdd65ee3e2345edcb7021b30c921beaeee436730	8	8687	687	861	878	40	4	2024-06-05 11:01:04.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
880	\\xdc60e7bc02f9547a2c76a95d205a697d9a7587601218a51f4098a2a842393686	8	8692	692	862	879	40	4	2024-06-05 11:01:05.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
881	\\x52857cd9ea7d0f3a4509109e6552e0223ea30a5909acb220df5da7dcf53eb61f	8	8706	706	863	880	3	4	2024-06-05 11:01:08.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
882	\\xa0909555aa36eb0ca59ea8417aaff59bcb100b957134af7c9c978e4f762df2a8	8	8712	712	864	881	4	4	2024-06-05 11:01:09.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
883	\\x7735bfd59bcaf49faf9d624ab971953a1afb7ec686dd3a5e0b47aa7dff74438e	8	8718	718	865	882	40	4	2024-06-05 11:01:10.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
884	\\xfdceb081e71c7196d536cd13f68aea1d6e9e9dc9f4d715e6b6c37854a86451fb	8	8723	723	866	883	7	4	2024-06-05 11:01:11.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
885	\\xdc602d0bb7cfc8e84a97f6bbeb5e7c4a00584526a9980b84bc96f753f6f13a7c	8	8726	726	867	884	3	4	2024-06-05 11:01:12.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
886	\\xba1d32fc0dbf1c6249ed65b563dd36391b9871035f4c842587496527ca9cedcf	8	8729	729	868	885	3	4	2024-06-05 11:01:12.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
887	\\xdb58537a4d3316f008129663b4f408bdbe1cc12ea770b3d9c93878d0ebb86eb0	8	8733	733	869	886	16	4	2024-06-05 11:01:13.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
888	\\x8f1f7226b0e3e272fcc548938fa29b0e2c7257bdfcfd45ea02efe9eac47d9725	8	8739	739	870	887	4	4	2024-06-05 11:01:14.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
889	\\xf6a43ad6291a4d21f0f99fab82896909a9dbb1dba181e8eec9325be4e4bee0b1	8	8740	740	871	888	7	4	2024-06-05 11:01:15	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
890	\\x6b36ffaa0d387990ce02dc89e4d1c724876aafc5c222f7249f1be4008bf8448e	8	8756	756	872	889	6	4	2024-06-05 11:01:18.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
891	\\x3f4ee8a6693c98e0cb89b58b7f614390f5bfec7e89853c7ede1c03e045a8c760	8	8757	757	873	890	21	4	2024-06-05 11:01:18.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
892	\\xd8c39a37aacf815f67ca8b4b18e6527de0eaeafd5d84d390a6a093489d312aca	8	8759	759	874	891	5	4	2024-06-05 11:01:18.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
893	\\xa7f450472631c0443ce88b040bb1f49df9936adf72058a844795e338410791fc	8	8761	761	875	892	7	4	2024-06-05 11:01:19.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
894	\\xe5e355c5c72ce6036576dbddcce55d96783f9fe133e1f9da3cfdf234932af97f	8	8764	764	876	893	4	4	2024-06-05 11:01:19.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
895	\\xc61238c0dfa7bc526e27681a0985473884ad10aee6d7412f49530f92d1ca54ef	8	8782	782	877	894	3	4	2024-06-05 11:01:23.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
896	\\x209004b949bcacf9b6a3702bdc56a716e3ec2a3a2590765a5c0a1149c8ba998b	8	8805	805	878	895	5	4	2024-06-05 11:01:28	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
897	\\xf5fe3736b780402155fbe86c63424d2b4626141d0d582f62b21e05c15fc0753b	8	8818	818	879	896	7	4	2024-06-05 11:01:30.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
898	\\x079963fbd30f68fdfe8af61dfd1c19953f94b40b31178e184c5eb902cd57091f	8	8820	820	880	897	21	4	2024-06-05 11:01:31	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
899	\\x890bbbdd48f29027578551b7842fe26459dc118ce57f7d6e8d37647fb7db48b8	8	8821	821	881	898	16	4	2024-06-05 11:01:31.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
900	\\x4a6e3f3052d9611dc06d71cdd566217ee5309b113881248652261f2446b81419	8	8843	843	882	899	40	4	2024-06-05 11:01:35.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
901	\\x86e55953a6aed234b52b8923e2b34d95abb3f3e62d6983b5f84905c1c113cc67	8	8861	861	883	900	21	4	2024-06-05 11:01:39.2	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
902	\\xe0042d8f40cfb8601e61051ba01c8e7182700bb39fc703d7aa75a277645b029e	8	8863	863	884	901	4	4	2024-06-05 11:01:39.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
903	\\xb06fa856cc86a63efd9689aa0215a8c991be114353080ef846dcd1616e88971f	8	8871	871	885	902	3	4	2024-06-05 11:01:41.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
904	\\x012e4a7e1d2ab7e8ac4bbebbbc5c631ced4fb456a0271d0c2076d59a193fbe7e	8	8877	877	886	903	16	4	2024-06-05 11:01:42.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
905	\\xcd9447e6d4e9adf8dc9c3e705ee9ff604bc839d97a4b5aeac83b4bb350402294	8	8898	898	887	904	5	4	2024-06-05 11:01:46.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
906	\\xf294ebef3af6b9df82c6c890b9fce80d57e084bc8bba34ca9dbcfbee22f07296	8	8902	902	888	905	4	4	2024-06-05 11:01:47.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
907	\\x25d42a2f522ef73dc9feb79b9f932273fe5584ac5a954b777a08c20dc77db832	8	8906	906	889	906	5	4	2024-06-05 11:01:48.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
908	\\x81b0d00a99c4c9c5348136e767b2d7788b635b6b821eea6d24634cf97ea8d616	8	8935	935	890	907	7	4	2024-06-05 11:01:54	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
909	\\xbb614947e57157cefbb27fb076e8ab3b06cc28211c4582fc65828a4dbab4ceb7	8	8936	936	891	908	6	4	2024-06-05 11:01:54.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
910	\\x71afab779d851271a230dcda32c8e59c1065a02cd81f586b087c54ddcad3751b	8	8969	969	892	909	40	4	2024-06-05 11:02:00.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
911	\\xf91e3c801bf285646d7e43b081d8b162bb75b718237d04f7880e1402c975f2fd	8	8977	977	893	910	6	4	2024-06-05 11:02:02.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
912	\\xc2a03672aa8d7806214bca57e931fa4a70073635ad1920990e1b753c7331ab81	9	9004	4	894	911	21	4	2024-06-05 11:02:07.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
913	\\xdb370da87692b29748715e10be3ada0a9fbe0e20f3362eaf7abc06ba560f5b4a	9	9020	20	895	912	6	30789	2024-06-05 11:02:11	100	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
914	\\x2edfe3384d439a1efe948b31a7b6f7ad3a81f9e6545dc902ed692ec0e0bba5c3	9	9038	38	896	913	40	4	2024-06-05 11:02:14.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
915	\\x66c20366303a1f19df5287aa5f06f4ed6b6d62164b850c639d7196934ce47c76	9	9064	64	897	914	7	4	2024-06-05 11:02:19.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
916	\\x95f6f98bd32ce6af8b9994f9c34bffd8d8f5a07b37fc17aceed7b5ea1fda26a2	9	9072	72	898	915	7	4	2024-06-05 11:02:21.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
917	\\x014d78b5f0fd1f67c3a613b386e78fa62468f821f36051588ffcdf6c000e5eea	9	9075	75	899	916	6	4	2024-06-05 11:02:22	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
918	\\x6f70c6ee7f5659e63fe18a38c10aafbfbd05dc4c502004716bc2e2fc8b05286d	9	9093	93	900	917	16	4	2024-06-05 11:02:25.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
919	\\x186f44b52b4a50443ad7acaa49256e7b487196f29fdd811cd099a54ee2aec2d4	9	9096	96	901	918	6	4	2024-06-05 11:02:26.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
920	\\x78b0ceb1997f0bf251aa5985f561a98c9fea28e0b95945af555a474be7358d65	9	9113	113	902	919	7	4	2024-06-05 11:02:29.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
921	\\x77f39b86210c5afc434d3c5a6b935efc16438509d68348b7ccffcaf86c4d6fb8	9	9142	142	903	920	7	4	2024-06-05 11:02:35.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
922	\\x3d6845f416c7fdd86ae74939f603aa2372a92e80169a7459f4bc4887fc8005ed	9	9150	150	904	921	21	4	2024-06-05 11:02:37	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
923	\\xb727d34853e8dbd2750165dd27e3a9c1a0a152b4965e2684c5af85ac32d086a8	9	9158	158	905	922	7	4	2024-06-05 11:02:38.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
924	\\xfa7e843740ca9747c2aa10f538462429133bbd5a939a2b64793fa2ef62f00ef5	9	9163	163	906	923	21	4	2024-06-05 11:02:39.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
925	\\x1c50409926c169275452e543b54d414396c5a4d8e3b29436883c5be7ebaa5ba4	9	9167	167	907	924	5	4	2024-06-05 11:02:40.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
926	\\xefccab7f24adf6f3d728542397f5c550aefb8de2faff104ed9e57d81b244a2b2	9	9178	178	908	925	21	4	2024-06-05 11:02:42.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
927	\\x2d1ad563e88ebff735c121e0434abc745d0563b3fed8b7e6e2ec2f9bb616a409	9	9179	179	909	926	21	4	2024-06-05 11:02:42.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
928	\\x5dedcbd439f2f21c81d41ddf06e63b74a23ad41128bf97c896600716f9ff0842	9	9180	180	910	927	4	4	2024-06-05 11:02:43	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
929	\\x09752846abebd1ec92f041ae2b579859c8b409da950cf65460bc1cbe81e9fac9	9	9182	182	911	928	12	4	2024-06-05 11:02:43.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
930	\\x201d97dc16b02121df19965669d60b35bea4ae4bc1cae2feb164807e2df0e114	9	9184	184	912	929	12	4	2024-06-05 11:02:43.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
931	\\xcf1d0f8ea89ce989adbe61d18d51455e2eb8ba8e03f6476a9471b91023d1ad4e	9	9188	188	913	930	5	4	2024-06-05 11:02:44.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
932	\\x5603aeb69789aeeff3f95f466338f9e9db45115b8f4a6e0a394e0e15f5ce149b	9	9201	201	914	931	5	4	2024-06-05 11:02:47.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
933	\\xe6ed72257cbfdbbb6c36777adf0407ed7a41273410cfd2cca76bfb3df3e33d74	9	9202	202	915	932	6	4	2024-06-05 11:02:47.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
934	\\x4c5ffcde1ce7e910a6177094b0d161e47eda3e3775ce1cf3ceaf1e691e8ef9a2	9	9205	205	916	933	16	4	2024-06-05 11:02:48	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
935	\\x205d7fafc84393ceb62e43c55534f61550e65b1c0ad06ea37817adceca050685	9	9247	247	917	934	7	4	2024-06-05 11:02:56.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
936	\\x20ec9efef73581b5a0948f776d1abe441ffe8724e52d55f87ec10d39faf4012b	9	9248	248	918	935	7	4	2024-06-05 11:02:56.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
937	\\x73cd1b35dc5acafea12009b25a8626d53d4afcff6cabda81dd6da9eb3d6e1eb3	9	9249	249	919	936	5	4	2024-06-05 11:02:56.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
938	\\xb260d0e34afd0b4b30c6ddf29b67e65f680764bceb84ce48f61e882865f62431	9	9253	253	920	937	21	4	2024-06-05 11:02:57.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
939	\\x8394141a9c9d2a20353fd61706c18792a01cd2be9f05257a55ea38aa44b362b9	9	9265	265	921	938	4	4	2024-06-05 11:03:00	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
940	\\x5439aedddd7cb7cc18779b661c8178b8a1665a4465aad5caedb1a3f96e57988d	9	9268	268	922	939	4	4	2024-06-05 11:03:00.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
941	\\xf9aadad4a93187af8ac012e4c7b2e0288dee30deeefe2ae1507556fc5a0e74bf	9	9283	283	923	940	12	4	2024-06-05 11:03:03.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
942	\\xeb49969899ff731bde886b425a62b5405ff58852fb44c4f5eb5374dd2ca1f555	9	9287	287	924	941	21	4	2024-06-05 11:03:04.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
943	\\xdcc245369cd351ee7460d51526cffe84973bdf871c214251c85d8e7fe1ed4836	9	9292	292	925	942	12	4	2024-06-05 11:03:05.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
944	\\x3546006abb1db0d1fffe69b2a1a239eba244e5e7b90f599f5c6d2e0df905ba21	9	9294	294	926	943	16	4	2024-06-05 11:03:05.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
945	\\x9ac68f12037666505efd6b563641842f995d60eb3655eba4072a21bcade96575	9	9300	300	927	944	7	4	2024-06-05 11:03:07	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
946	\\xbdce8bf77a4975b5b2da6915c7c8a91817a1b624b2e6f263130e31153f28d2e0	9	9314	314	928	945	3	4	2024-06-05 11:03:09.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
947	\\xe8a71a2d64da552dab1b036884fc860ae23838e323dff5ecbb403a0caa743417	9	9315	315	929	946	7	4	2024-06-05 11:03:10	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
948	\\x2826cb7d0607eb8a3ea4476f8076ffc014fcfc06de399e7a686924bb5c1e9c32	9	9319	319	930	947	3	4	2024-06-05 11:03:10.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
949	\\x8902895f01636cbfeb1bfcc20d264e97bbea9afe462d4f947cfc539874b8a462	9	9325	325	931	948	5	4	2024-06-05 11:03:12	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
950	\\xc4d0a2303ba7290c24cd64154225be2bc23707da311c5d85b5144c3fb897fe3d	9	9328	328	932	949	16	4	2024-06-05 11:03:12.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
951	\\x83ccddd230d27ed3043297ceb619a657e6ce0b7803633f50cfe5b64c8e112775	9	9354	354	933	950	16	4	2024-06-05 11:03:17.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
952	\\xfe14d1be413e1fee1b7c032fcdff9d49e1e4ea7bc1e2b511dc89ddc07c33f71a	9	9372	372	934	951	5	4	2024-06-05 11:03:21.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
953	\\x400ba3e79f722e314c41c56bb0eee73d65fadbdbe5d3a66b26337c740653602f	9	9373	373	935	952	4	4	2024-06-05 11:03:21.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
954	\\x87f6b10a205fab723630c0041ce8d77e4d1556ab898f4b04c3eccec19ab5f9c3	9	9380	380	936	953	6	4	2024-06-05 11:03:23	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
955	\\x2016533030554556c4563bdccd6cc34cde55d329173d94b82af06874123d424f	9	9393	393	937	954	7	4	2024-06-05 11:03:25.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
956	\\x703001330e362e32e267f8faa25b8ea9236e821cb115369f246ea8e2070ca4b3	9	9394	394	938	955	21	4	2024-06-05 11:03:25.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
957	\\x47ad4774f454edc2f6157fb174cbd509ecbebfd12e1b03f89ae9e1d120354417	9	9399	399	939	956	5	4	2024-06-05 11:03:26.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
958	\\xd33172e059f1e4414d0f9e159d33df09b5974805ff4341637582ae7fe0160a0a	9	9425	425	940	957	12	4	2024-06-05 11:03:32	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
959	\\x1de60fca9a8665e9650b746417db50aae3dc2f0ed3598583aeb0cbbaa12352db	9	9427	427	941	958	7	4	2024-06-05 11:03:32.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
960	\\xdbd165599305459b975c494ee767121071c95ed0fea0813a90195ce2b282e088	9	9433	433	942	959	4	4	2024-06-05 11:03:33.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
961	\\xb50e1fd2257d29e9e3a832e1aa587e0a0c3f051e4e2f60796298674a004399b0	9	9435	435	943	960	12	4	2024-06-05 11:03:34	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
962	\\x1d275c504c0ca6251ee45b1669a47755c726b611d371310476908fa6e5a9f821	9	9444	444	944	961	5	4	2024-06-05 11:03:35.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
963	\\xa0bc97a25b83373b3a3ab21a7b601c3751016c6e16897dfc21c7fa46561049d6	9	9450	450	945	962	12	4	2024-06-05 11:03:37	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
964	\\xd05d31d166a3b4612f772c9eeb7c980618eaa231a15d09c0dbb29812cf0d01db	9	9460	460	946	963	16	4	2024-06-05 11:03:39	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
965	\\x52ac3f09e9bafc9b29974f571575d35f267b279557b336ea3dd53e8b8662ec8b	9	9473	473	947	964	21	4	2024-06-05 11:03:41.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
966	\\xf0a46501bb974fe874bf01b8743e27879e29a370179da56d98b50994826dbfa4	9	9477	477	948	965	3	4	2024-06-05 11:03:42.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
967	\\x096cf99ea8e1f7a087782b900e73947b88e986fa7848374da2b172b96aa05eef	9	9489	489	949	966	6	4	2024-06-05 11:03:44.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
968	\\xbad522e84f40256a6f88539dbf8b2dbe569cd916255d235f3be05f58dfd7b892	9	9491	491	950	967	7	4	2024-06-05 11:03:45.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
969	\\xb3a49e859fd8f234fdab088662b810018b21d092ab7afefaa128773b137e9746	9	9492	492	951	968	6	4	2024-06-05 11:03:45.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
970	\\x9ec0b6fe095814dcc49d6d9ee593f19ca510cb1d795839b8ee584ae2b83ea710	9	9518	518	952	969	16	4	2024-06-05 11:03:50.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
971	\\x6db012798454ec6b697d718af942b181743826e9c662499cb7b2ab0fb002de42	9	9519	519	953	970	4	4	2024-06-05 11:03:50.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
972	\\x98f7156ec3e3e8b83eec92142da609c9438a8da2f4f48dba034c11149d6700e0	9	9536	536	954	971	16	4	2024-06-05 11:03:54.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
973	\\xa815f9910cbdee06bae51e743eb0aa04049346c97c9f9820c7029c424a649283	9	9547	547	955	972	21	4	2024-06-05 11:03:56.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
974	\\x1df4bbdcfc076b4d4ec1943d1166cf676d1706c4e807c69b141c6ab63ba1547f	9	9561	561	956	973	21	4	2024-06-05 11:03:59.2	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
975	\\x18d38981b85007076fa316aae5e196eb575849ac0e178fff4d171ecb298c6600	9	9569	569	957	974	12	4	2024-06-05 11:04:00.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
976	\\xbcb865af626747894ccb4c7ba9b9df37f7b57f43b9f4bca1dc1bc5d94a9ef83a	9	9576	576	958	975	4	4	2024-06-05 11:04:02.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
977	\\xce7d80401f56c25baf5800c172045cfc79bef4612a30e2dbf64f29b180a1dbcd	9	9578	578	959	976	6	4	2024-06-05 11:04:02.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
978	\\x23cd68d267a65fd37ec7e8b0c0bda03cb13459a799bcc8d8cb8523b67373b6aa	9	9584	584	960	977	7	4	2024-06-05 11:04:03.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
979	\\xb06edb7e29176cd98c810dfcd289460d5b54d58667a2014a861b00150589115d	9	9587	587	961	978	6	4	2024-06-05 11:04:04.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
980	\\x7beac2313f3064ef54feb7e7dc6aa498d912383268c1567fbf9203120c322f02	9	9597	597	962	979	7	4	2024-06-05 11:04:06.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
981	\\x83706677033431c6b13d487c14c5b3c40bf489af2e04e3790aff17a42833449e	9	9599	599	963	980	4	4	2024-06-05 11:04:06.8	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
982	\\x4e57d69fbe1faa76cae7d0e00bb5d34a400cdda08ed75be4a385c7040a536e8f	9	9601	601	964	981	6	4	2024-06-05 11:04:07.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
983	\\x82b7458a7a946498d4270d784e7a49628e7360374bc20950254410d3ec9a0721	9	9602	602	965	982	21	4	2024-06-05 11:04:07.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
984	\\x3542e98655a6aa8ef1ee991b5becf281b4746406d98c3b1e52440248bb44c60f	9	9605	605	966	983	40	4	2024-06-05 11:04:08	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
985	\\x0e20415f8a2512da56fe953e917879c93117db4da9bfd6db816c900efec2437c	9	9626	626	967	984	7	4	2024-06-05 11:04:12.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
986	\\x46023d12e9a8eee3f02f17c8f7ba9ca589a3aaf9d293e717d01804f55d238b72	9	9650	650	968	985	12	4	2024-06-05 11:04:17	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
987	\\xfa78a5a868347a87a07fe3b523654f3b9afe5cf9ba1661a97450b021961da0c0	9	9671	671	969	986	4	4	2024-06-05 11:04:21.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
988	\\xd97f359d627a633d617ba380ed3e25c8b5e778d118c8d0f5cd542bbe263c7100	9	9688	688	970	987	5	4	2024-06-05 11:04:24.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
989	\\xc713bb79ba9b975d0e43260d436687dfcf606b2c15a0f1645e22b4aa1793c87c	9	9698	698	971	988	7	4	2024-06-05 11:04:26.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
990	\\xdc298990b7476e367a25971b08a3e2a768ba2816a8734a903ed884c7ba7fc421	9	9700	700	972	989	5	4	2024-06-05 11:04:27	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
991	\\x1d51adad8b8cc54cf41d7a6bd531f29418f2fee029db467c99cb047235f68f36	9	9728	728	973	990	40	4	2024-06-05 11:04:32.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
992	\\x0eb385076a27ba9f392300cadb447a99aa865eb27c1a15068c600b95a0f509a1	9	9743	743	974	991	6	4	2024-06-05 11:04:35.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
993	\\xbd499a4737ffc2e087ea4a2034ab7accdf7aae58cdef505123135f6cb5e10932	9	9770	770	975	992	3	4	2024-06-05 11:04:41	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
994	\\xd2b9cd03ac6f293fbf4d4905a473a1f42ffebe029af2bfd72dddbb7ed2861d77	9	9796	796	976	993	12	4	2024-06-05 11:04:46.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
996	\\xd9e64e6a877bf51f1cba4842eab0c5cd4ce7c3d2dd56b1a1a868c15538f674c4	9	9798	798	977	994	7	4	2024-06-05 11:04:46.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
997	\\x48f87b20bb4b1c0c2bc4bb75aee7fa706cd8a2c035920f58797832cce8fbba4c	9	9803	803	978	996	4	4	2024-06-05 11:04:47.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
998	\\x046b93ecc4b8b6a030e0ec62abe2c489a9e5881c379cf28577bf6dda84bfcb59	9	9818	818	979	997	4	4	2024-06-05 11:04:50.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
999	\\xf8d4195ffaacaeb9e566c1fd6850e45ccb7c1f126b2f70d813632f1ff1ae0c6f	9	9822	822	980	998	12	4	2024-06-05 11:04:51.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1000	\\xd824a1518a2ed6b7a178fce20202b17a66de35b6e041033dea31139fbf462d42	9	9823	823	981	999	5	4	2024-06-05 11:04:51.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
1001	\\x48c47b1b8a1f2172169e55301f799fdf1684f99b2bf1e1b8bfff1d1e9440e8a7	9	9825	825	982	1000	7	4	2024-06-05 11:04:52	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1002	\\x481944d82fae367e0486af78fe771095572eb7ccd964f2998349eb5c27b05dd6	9	9826	826	983	1001	4	4	2024-06-05 11:04:52.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
1003	\\x185a432b40f40723e6f6e6d4f97548e4c6790b5eefb0f475483c8f7957a5e21a	9	9831	831	984	1002	12	4	2024-06-05 11:04:53.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1004	\\x63eb132af69fe8b6db84e6465609ab864a52b1352594937dea3a0ac963e81120	9	9837	837	985	1003	7	4	2024-06-05 11:04:54.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1005	\\xa624b35a9f887609eef62d9d027e2d8a3e2e8f8072f36128add9c7d7241c9d8c	9	9841	841	986	1004	6	4	2024-06-05 11:04:55.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1006	\\x4dd5f801373f8c203b5e859bf27e4b671370c0b8a816b480d9e3fbe286d51652	9	9852	852	987	1005	4	4	2024-06-05 11:04:57.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
1007	\\xd3292ebfce287b315874a7789add2f271a1f1249af5e71ecd14ce8ff55edb212	9	9882	882	988	1006	3	4	2024-06-05 11:05:03.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1008	\\x37e46c31f42f4e753fd0063fa5ad2d4a9cc7fdeb99814624ae4c386eae144292	9	9890	890	989	1007	40	4	2024-06-05 11:05:05	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1009	\\x09b4851ee46bb46188da9ad48d7ad1c25bfb5be2b0bf59eed3540230491716f9	9	9899	899	990	1008	21	4	2024-06-05 11:05:06.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
1010	\\x7d97ceb27a32eeb4e8228edcdef0c88ac8fcfe671f070bd27034833db976c61e	9	9904	904	991	1009	5	4	2024-06-05 11:05:07.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
1011	\\x76450a981d6eb6ea21f8c814b04495445af1bccc33e2fa5ba62f8eed4b574497	9	9917	917	992	1010	21	4	2024-06-05 11:05:10.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
1012	\\x5a904e622dfa17e911f3691e256b7e26e223b95e8cad7fd3919b82d609b25901	9	9920	920	993	1011	12	4	2024-06-05 11:05:11	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1013	\\x73eb6cb78eb95ee1a0bbf81d055c71b792ee990b1c198c9a16f788897ef96a62	9	9927	927	994	1012	3	4	2024-06-05 11:05:12.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1014	\\x020bbd613d8d3fe8d2751c4dd83b7059416f81abd4a2925e69fa958444996a20	9	9931	931	995	1013	12	4	2024-06-05 11:05:13.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1015	\\xb82a589016b399b895be0524050c23eeddbdee3ca5d7cf92d89530a33b928057	9	9942	942	996	1014	12	4	2024-06-05 11:05:15.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1016	\\x4da2c8d1fc683110089786951c2ba24be100ba039437fb855c497ecc6561a4ad	9	9947	947	997	1015	12	4	2024-06-05 11:05:16.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1017	\\x967fd7a399b5af2edf13c3714e6aa131a8a884fe4cd45af64d6196c17ff38c7f	9	9951	951	998	1016	40	4	2024-06-05 11:05:17.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1018	\\xf8f0487ca2cfed383416284ab8c73f21ec5fb34208820c74958bcb3ced890c34	9	9952	952	999	1017	21	4	2024-06-05 11:05:17.4	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
1019	\\x91c2c372cd5da1f6777437f04b6435cdb791c00896191a34d3691fd278bb7707	9	9978	978	1000	1018	40	4	2024-06-05 11:05:22.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1020	\\x65f97d6a63203e6068c1fc23fb5528a5c837cfa9ed661627ab9a3d8151167875	9	9983	983	1001	1019	12	4	2024-06-05 11:05:23.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1021	\\x0a9c5f1f9f512a82f5178f9d802d50b4b34a86490bfbb45ad81f1bd22947a2ce	9	9999	999	1002	1020	7	4	2024-06-05 11:05:26.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1022	\\x20b705822c51decf368c1118800b947f9ea05dc0d2f16717aa799b625120be8a	10	10013	13	1003	1021	12	4	2024-06-05 11:05:29.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1023	\\x79e730772dff0752c665f146e4e8b06c38fcc4ee455c4c8dac9439fa2227317c	10	10022	22	1004	1022	16	4	2024-06-05 11:05:31.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1024	\\x88e507776c09bf2c772087048ee49a978ea3ed4a4b411c2e0dacf9945d39ee61	10	10031	31	1005	1023	6	4	2024-06-05 11:05:33.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1025	\\xf0bdb4a9465708b7bf267ffa54e1a3fefaf9d18e7fe8e2b17abb1f3cbf5fcc5f	10	10041	41	1006	1024	4	4	2024-06-05 11:05:35.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
1026	\\xe42188804b7b908a866139da55ba6239fa000e63860e30705a2432da60dfff3d	10	10052	52	1007	1025	3	4	2024-06-05 11:05:37.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1027	\\x083f1a07d3d77281f8609fb61aa7d92378208a226676db53ad4a6712aec149fe	10	10074	74	1008	1026	7	4	2024-06-05 11:05:41.8	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1028	\\xc01c8fe065c96057e61e74ae89329dbe0cd985fa8f46c0c222c4a7ccc5af3f8f	10	10075	75	1009	1027	40	4	2024-06-05 11:05:42	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1029	\\x62a3ca37364fbf86d5c1ce1c9480316a61924d841c00c1df38d5e5d7bed489dc	10	10076	76	1010	1028	6	4	2024-06-05 11:05:42.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1030	\\xbb2bbede8036e59040e240a52fd3ca79ed2a6451e328ebbcfbe2d9b950caafcd	10	10084	84	1011	1029	12	4	2024-06-05 11:05:43.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1031	\\xdf40f0e14c14fc791c563047a49d5dc591717c87921049e5578c13b927fa5b94	10	10087	87	1012	1030	6	4	2024-06-05 11:05:44.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1032	\\x0d82cb06893d5c4f6b270044d063b03cd05bfb4c935709acb8278caec82bd254	10	10091	91	1013	1031	40	4	2024-06-05 11:05:45.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1033	\\x6d01d61e6e32c23af6eeecbbf3a9f3989fb47e846d4ed45a8293472d8f41e283	10	10100	100	1014	1032	5	4	2024-06-05 11:05:47	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
1034	\\xae7a4b56cb049dc8e2772aacbf916855e6988702084554c3a2cd66b9739defbc	10	10108	108	1015	1033	21	4	2024-06-05 11:05:48.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
1035	\\xf031978e775e848b6fcb3dc14400e26cb4b6512c28fd71ea7d868c8e037eb811	10	10120	120	1016	1034	4	4	2024-06-05 11:05:51	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
1036	\\x170272b47126b9f77c04020043e424fdaea905e83e1bfe1fe0824ba812e071f5	10	10121	121	1017	1035	16	4	2024-06-05 11:05:51.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1037	\\x0d374ea944f871efa4535ffbe11da8a3c6ca7a338e50dbafd04ed0bdc8e57b86	10	10123	123	1018	1036	21	4	2024-06-05 11:05:51.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
1038	\\xb0f011fbf0a9dfc762b76369b4d29e573a2dd00dd26530bf44914652c03bbc52	10	10127	127	1019	1037	6	4	2024-06-05 11:05:52.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1039	\\x72d1cf4d0aef496c71613e4f6ac2645fd07e0685b32236b634732c1a40ebc471	10	10135	135	1020	1038	3	4	2024-06-05 11:05:54	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1040	\\xf5734542aee92e6d58f7a7c7be77398d26bc41bdbb982d62d2c1b8b797fce41d	10	10141	141	1021	1039	5	4	2024-06-05 11:05:55.2	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
1041	\\x9b7ebb2b17c6886e2e967a50edbce8658f7beb41a02a236cf91eac5065138338	10	10143	143	1022	1040	21	4	2024-06-05 11:05:55.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
1042	\\x4ed2ff72f562009b4fca81f3013d330b765d0ccd20f5ded47ff44e93de44ab8b	10	10146	146	1023	1041	3	4	2024-06-05 11:05:56.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1043	\\xeb2bad3e5749d170e70a4e3a75f6f15ecc99abf591de21b07cfb0bc6171f9936	10	10147	147	1024	1042	4	4	2024-06-05 11:05:56.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
1044	\\xcda1e3428142167b293b5c61355a1de28de67e3962e7b57f7c9d06084946adc8	10	10165	165	1025	1043	5	4	2024-06-05 11:06:00	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
1045	\\x099d996b82b58ceeb63437ada55b496e93588e5e59689736d5b5565bd9bfd129	10	10166	166	1026	1044	16	4	2024-06-05 11:06:00.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1046	\\xf058ee3ef04e5fbbe4a3a32f32e53d04582b232c32ef58fe816d8db8df0685d8	10	10168	168	1027	1045	12	4	2024-06-05 11:06:00.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1047	\\x905d3b63876c0e28ddd88a0750805ae134f00ee71806849df33ecd6f8922ee1b	10	10172	172	1028	1046	5	4	2024-06-05 11:06:01.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
1048	\\x65f9ea7460dad414c484858537ce5132faf4387379952d0bc23215d13a130d5b	10	10190	190	1029	1047	40	4	2024-06-05 11:06:05	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1049	\\x78ba0560380096f596d97421f459a1238fdcecca871b0efa575afadd996b5b91	10	10198	198	1030	1048	16	4	2024-06-05 11:06:06.6	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1050	\\xbab012e06aedacca1349b2cc005c2b6616e4eb1a94bbd64d173397fb0852e7a4	10	10202	202	1031	1049	6	4	2024-06-05 11:06:07.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1051	\\x124c74f06ee1cb3e72306fe20cb477db1fcaeb8bc33380c0a10bdee1689132d2	10	10208	208	1032	1050	12	4	2024-06-05 11:06:08.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1052	\\x126ca14facec30e01054632f99312ff0f8b06436b1a3cef30755ffa67157b448	10	10224	224	1033	1051	6	4	2024-06-05 11:06:11.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1053	\\x1d80d7041b55226591bfe5813599b9f90ccbc2db60c3631bc325ccef84ec215c	10	10228	228	1034	1052	6	4	2024-06-05 11:06:12.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1054	\\x7d0ceb50194cb103390b25500d7a5383895e36fdcaf05160be919b13badcec1e	10	10230	230	1035	1053	6	4	2024-06-05 11:06:13	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1056	\\xa2c57905efbce8ca15fc8446dfb8f84aeec89a9ccbd5639de34cb81ea9476ce7	10	10236	236	1036	1054	4	4	2024-06-05 11:06:14.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
1057	\\x6e207e14f5d2ad7b9c75368cd7fd06eed65121e9e3abeec6bb490e0362da8f94	10	10244	244	1037	1056	12	4	2024-06-05 11:06:15.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1058	\\xc91f89c7479ac2000af5020091576bd810621ef44f4d0f20179fc17799952b1c	10	10251	251	1038	1057	7	4	2024-06-05 11:06:17.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1059	\\x148932d7ffcfd80e61710c12ddcecf8f21656a48166aa797ff1bb038f77e7a91	10	10254	254	1039	1058	16	4	2024-06-05 11:06:17.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1060	\\x3b01e43c6b766b5e83c223a6201273351b676985bae3f8deaa0339353bad1965	10	10258	258	1040	1059	3	4	2024-06-05 11:06:18.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1061	\\xc1d4efbe4f0b9e8518bd31526d54018c37ff4d782a0e45b8a472fc74b4ff22fa	10	10272	272	1041	1060	6	4	2024-06-05 11:06:21.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1062	\\xba7caf3e9a8003bbfa5542c9a9e922da919a045f95ee149ffc728a03e093375c	10	10276	276	1042	1061	7	4	2024-06-05 11:06:22.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1063	\\x1718112623d8a5a518a342d8ce0461dddf49d3e823aa50e2904bd8b6e441551c	10	10311	311	1043	1062	21	4	2024-06-05 11:06:29.2	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
1064	\\x7723863ca688c87fd4c3b0da1d28fcfa8c80f8f780155ce9fe65aee41780446f	10	10313	313	1044	1063	21	4	2024-06-05 11:06:29.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
1065	\\xe327eed3a9b5e5303a06ee59e7218b1b22d50f0c54a8675d68ebb4f8609ddec6	10	10347	347	1045	1064	16	4	2024-06-05 11:06:36.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1066	\\x26189ce4db8f77c9621e82acab3318523c908a97be1449186ad38c8f109abc71	10	10348	348	1046	1065	40	4	2024-06-05 11:06:36.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1067	\\x44fa55611872033c6923e19ffcd7bdaf0a95cc717a40a973a5cb88b66de7b0b3	10	10356	356	1047	1066	4	4	2024-06-05 11:06:38.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
1068	\\x25c7ec2d28326e2f35a11280fd5691b434d3328627b02f8d0d71fa2fc2203c2d	10	10368	368	1048	1067	12	4	2024-06-05 11:06:40.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1069	\\x4e2f28591b7ad87819392923baf9bf3ca04a3c8867d91b5a41922bac1c76ea3e	10	10381	381	1049	1068	12	4	2024-06-05 11:06:43.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1070	\\xf6804cbbf4e9cccab8d0b2b9366ad54eb0867a6e42dce9eb2bbc296975ac49b0	10	10382	382	1050	1069	40	4	2024-06-05 11:06:43.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1071	\\x5252ee699bbd4507ddc9bc1b95d5a0ae2c939425b9e4e82507c8789c104d1e77	10	10383	383	1051	1070	3	4	2024-06-05 11:06:43.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1072	\\x5003459f2c61785e4ece5d53710d9a306d054e2aeb52733d7c53bff36cf16015	10	10385	385	1052	1071	6	4	2024-06-05 11:06:44	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1073	\\x9a95a622daa57cc357cb5d1d4c15ee4fcec06cdcd6d2b5e349e74fa5b5850558	10	10388	388	1053	1072	21	4	2024-06-05 11:06:44.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
1074	\\xffff65918b41a7caa2ee706caae1d6f015ea5b3fc2e8dc4e3f8a306eed40246f	10	10400	400	1054	1073	12	4	2024-06-05 11:06:47	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1076	\\x86ec5aeca99be252f38c966aa5dc5813982bfd254004176ccbcc50ed9921a453	10	10401	401	1055	1074	6	4	2024-06-05 11:06:47.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1077	\\xf65a3b8e2241a6b50aa579d8306672f4fb7f0f6d344dbee79eee6a51db077538	10	10403	403	1056	1076	12	4	2024-06-05 11:06:47.6	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1078	\\x720562fc02c75fee4c0432c39dfe83cd46aeae05f18360cc73d70652c130350e	10	10436	436	1057	1077	7	4	2024-06-05 11:06:54.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1079	\\x51daf14afbd9e0408e59b9d1724128589fda5c214b3ddfe107539285cd0cc159	10	10439	439	1058	1078	5	4	2024-06-05 11:06:54.8	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
1080	\\x3dd97affa3fe26eaf2261c830a5ac38fed3952618313c12726eedab63992a048	10	10440	440	1059	1079	12	4	2024-06-05 11:06:55	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1081	\\x6310784789e97f8ce8017a397548b5080017f26f984d9830a34c4d25e183e7fd	10	10447	447	1060	1080	12	4	2024-06-05 11:06:56.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1082	\\x2e052e8493946caa4cbc405b24c8a99bf378eb4d982c6838331f46de2266b155	10	10451	451	1061	1081	7	4	2024-06-05 11:06:57.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1083	\\x34e492828d68c4c33e4b5f6cb3ec81798694416d7764326407afb79ae5d3c0c1	10	10457	457	1062	1082	6	4	2024-06-05 11:06:58.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1084	\\xd52f7dc29fb1768f64bfb665682a673f2f247788b2334d9fb15c6af0efcaa845	10	10469	469	1063	1083	40	4	2024-06-05 11:07:00.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1085	\\x1d12d8ae5bfc65ef94ba661bfa90fb0b50ae25e2d86cf2f8d5cc35de7cf3ec28	10	10473	473	1064	1084	40	4	2024-06-05 11:07:01.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1086	\\x86c028f4ca2eb72ee44a139e83d1b0c5c2a377a323832509d0e627546776ddba	10	10480	480	1065	1085	7	4	2024-06-05 11:07:03	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1087	\\x01272c263c5cf4d939bdc952ac31237b54eef66df29d2fd01b3ad45306f833fb	10	10481	481	1066	1086	40	4	2024-06-05 11:07:03.2	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1088	\\x64590269ab597ce03cb5beb5e82983e279ef3687f61519d3e3a5dc8796c76de0	10	10482	482	1067	1087	16	4	2024-06-05 11:07:03.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1089	\\xa0d1334037f988630ac131e6cbc1a77d8d6fee3bc104616c9c885de54149de8b	10	10491	491	1068	1088	16	4	2024-06-05 11:07:05.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1090	\\xde982c8cedfdea11727c1dfea43672d8cacb982823d7bd71f146d8de9755a161	10	10495	495	1069	1089	21	4	2024-06-05 11:07:06	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
1091	\\x591d1b1ae1bbf03b649e756e0a801585d88d3188c0e8115a526d512675a053c1	10	10498	498	1070	1090	40	4	2024-06-05 11:07:06.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1092	\\xfe960e5423c93fb907646e581257327da674908e652c7221015cbf11f8b0abcd	10	10513	513	1071	1091	5	4	2024-06-05 11:07:09.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
1093	\\x9d87f83a1e8bd734e8dad8829d781b139334bc5b297e63b01490005d025e3a9d	10	10524	524	1072	1092	21	4	2024-06-05 11:07:11.8	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
1094	\\x488176413c09c96ffd64ad659e6db2214841c44e5403cd7b5f33ff6e8b933a4a	10	10537	537	1073	1093	12	4	2024-06-05 11:07:14.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1095	\\x61a1985965779751a8faeb32f261c7fb09a9d8a7833ed055a2303a6d9a6dd6da	10	10541	541	1074	1094	16	4	2024-06-05 11:07:15.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1096	\\x2ea46ec2b59ec533be6250388d2beef93b7694a65546c00f77158ab4205fc510	10	10553	553	1075	1095	40	4	2024-06-05 11:07:17.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1097	\\xd2cddf5b93f6f398eab5e54463c56d67496faa0d9a12a20602898175a216d9bc	10	10561	561	1076	1096	6	4	2024-06-05 11:07:19.2	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1098	\\xd9a05e7a61a706ab066a4eadfc1d5d6c85de29585f0ea50adbd0910e3f6f40c3	10	10578	578	1077	1097	3	4	2024-06-05 11:07:22.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1099	\\x5b76dc16edefdc2c0cf72b40c3b4a806c8ba60d06e2546c9a6464315eef661e0	10	10585	585	1078	1098	40	4	2024-06-05 11:07:24	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1100	\\x9920e679b5280d0c2b8dd83919b4fdcaf4d8c25a3db6cd86314c95cb1a52b7da	10	10612	612	1079	1099	7	4	2024-06-05 11:07:29.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1101	\\xd2a41956c59f8bdb75e0f21e0ee29a199fe5c6b42c40a6eb8e1bcc5021b5b557	10	10630	630	1080	1100	7	4	2024-06-05 11:07:33	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1102	\\x35a5d4472ef0a1d6a2586fe053e1165df898260c80af18ad34f5cf843b44c0ce	10	10631	631	1081	1101	4	4	2024-06-05 11:07:33.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
1103	\\xc051d1bf2bcf7ed6cd41923f2a3871af1c408bd81afd0304da03b0d1d7495075	10	10632	632	1082	1102	16	4	2024-06-05 11:07:33.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1104	\\xa55398070148442ab022cffa6aaabafee5cb0f9243b689315ecb96762d929ffe	10	10639	639	1083	1103	6	4	2024-06-05 11:07:34.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1105	\\x176ded062d842814a76df01a47942f1e8b5b7404f0a3db2ad0275edfaae0da83	10	10656	656	1084	1104	16	4	2024-06-05 11:07:38.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1106	\\x8e22d00144e3cc408b0a9b9630f811af49eb48ed22e20dbdc6ec59c93e4cd517	10	10672	672	1085	1105	7	4	2024-06-05 11:07:41.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1107	\\x12d5544e820b31491b1e5fee7cdbb988a3b7e8cd0b81aeb5024bd85292b9ebca	10	10698	698	1086	1106	4	4	2024-06-05 11:07:46.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
1108	\\x80bfc801454b88f99cd782d6fa7c637b7a60b24d3f2acf3d3d0c313f651b671b	10	10717	717	1087	1107	5	4	2024-06-05 11:07:50.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
1109	\\x0f17fe1f0260d6a9a7ef19e7c7f24f24700e628223f0fe43a58cacf9c4132f9c	10	10725	725	1088	1108	3	4	2024-06-05 11:07:52	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1110	\\x1706e9b8780dd1c774b23cc0e2553b85eb75d7f934ac65a41d5f5a8e63d85b56	10	10758	758	1089	1109	3	4	2024-06-05 11:07:58.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1111	\\x4a66902001e13a209915f6653cc3b48724e66d7a8fdd6e7b1f0d2e5cb3011666	10	10776	776	1090	1110	4	4	2024-06-05 11:08:02.2	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
1112	\\xbc0d70bccff074a779a056529ce2b1f1cc53550267b78ef940fa4373e67802dc	10	10780	780	1091	1111	6	4	2024-06-05 11:08:03	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1113	\\x33951839cbf23f6efe839fa627768883f68bcb795a2faa66201ccb4f1bcba0e2	10	10788	788	1092	1112	4	4	2024-06-05 11:08:04.6	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
1114	\\xf7134a212f288d205eec55f46c6fcf38c64c6e42928195e5660290bec0e0e7cf	10	10790	790	1093	1113	3	4	2024-06-05 11:08:05	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1115	\\xb831134b189f43970ea712f44954253463186808734dbd8a5282049e555a50e4	10	10791	791	1094	1114	16	4	2024-06-05 11:08:05.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1116	\\x8fe645d64146c6f617f02578f9d187a327d2703519c2a3fa0d22f095c074b773	10	10797	797	1095	1115	6	4	2024-06-05 11:08:06.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1117	\\xd0a80dc9168f8e92dfdf97890f4d6538233920d6ca74b21935fbcc67cd6a92d1	10	10807	807	1096	1116	3	4	2024-06-05 11:08:08.4	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1118	\\x50ed6025e9a5b8d52a423a43daf2adb678a24945de8c5dcf784b385e5d3b99ce	10	10821	821	1097	1117	7	4	2024-06-05 11:08:11.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1119	\\x113e961409737a731873e6ff5d30621ae99e3af6d59ae8289587566467624faa	10	10825	825	1098	1118	3	4	2024-06-05 11:08:12	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1120	\\xfba3d38ed7900c59c68f15785dd9fae3dce0b012e5da71cd3cfeb1f8837edb41	10	10827	827	1099	1119	6	4	2024-06-05 11:08:12.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1122	\\x5464d782032dd3b6fbb12c2a2c75ee2b81772b60da4940b524aea9a4894d67b2	10	10831	831	1100	1120	12	4	2024-06-05 11:08:13.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1123	\\x08ff5dd6335df5d0c046d696269ef197674f4a201fe2e8a746df3fe3d71c24b4	10	10832	832	1101	1122	16	4	2024-06-05 11:08:13.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1124	\\x1a8c6ba60706f8d1818d1fc469cafc956fdef347f43811b50e8f9a37469c2ae4	10	10860	860	1102	1123	3	4	2024-06-05 11:08:19	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1125	\\xfa05223d8712e3137fb983047bf222fa16b8736c11e750b228ee0587fd4d01fb	10	10868	868	1103	1124	40	4	2024-06-05 11:08:20.6	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1126	\\xedf8cd6e26e6e92d0a90533b177c007bf526f9e5fa1e4b62c16461925cc9047b	10	10872	872	1104	1125	40	4	2024-06-05 11:08:21.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1127	\\xe67309cf58ddbd173ea22fe5f575f85f6e98248d1de8254cdd8eeb950bc36404	10	10888	888	1105	1126	6	4	2024-06-05 11:08:24.6	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1128	\\xd24d9b706a9dc59af850a2e631b1dad7f662d7aaed8594da257ad76064208ea2	10	10890	890	1106	1127	3	4	2024-06-05 11:08:25	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1129	\\xcdaca7feac51cbbfb8eee02fa69ed1ff2ffeead0a2166881fbb6853f57af6434	10	10892	892	1107	1128	5	4	2024-06-05 11:08:25.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
1130	\\x79551dd422847748b27a19abdb10d8fd1581241ffd57cb2411fa111c508feea0	10	10928	928	1108	1129	7	4	2024-06-05 11:08:32.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1131	\\x97446f6f0c49ba98be0f07696b193527d7391ea2ee7fa4b798cf2e90b2156ce9	10	10934	934	1109	1130	40	4	2024-06-05 11:08:33.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1132	\\x99d130d10d7078444d0268f814f46ee19928928eb19485008e95ebbdb4442586	10	10936	936	1110	1131	12	4	2024-06-05 11:08:34.2	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1133	\\x096167eeef9775ef8a5a1f44464682c639f370f72be02e7d396226b58120e516	10	10940	940	1111	1132	3	4	2024-06-05 11:08:35	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1134	\\x79d18c75bac1fc66d9c8444199d9daf966b8ad9356a98ab45562d725c8ea2463	10	10954	954	1112	1133	40	4	2024-06-05 11:08:37.8	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1135	\\xa85d4bb7823c5399a4c2d28ad95b9633ed9d836347f6e864006c06a3023e3b33	10	10975	975	1113	1134	5	4	2024-06-05 11:08:42	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
1136	\\xc78e39ca7897db2cfec1fe291b42b1606772e704acc30aa2e9a59fe9114e8525	10	10979	979	1114	1135	12	4	2024-06-05 11:08:42.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1137	\\x2f895a310dc26a6e69c5a6bd3ae5e195d56fa25c78214ce61adf2e5029994e4b	10	10990	990	1115	1136	7	4	2024-06-05 11:08:45	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1138	\\x505976eeaf3a948b2dea9134df0d2cb9fcdaab438c0db6ac2eb907d15d86804a	10	10994	994	1116	1137	16	4	2024-06-05 11:08:45.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1139	\\x2fbb702b294893f05829e0c4e9382dd14388781d24fd714b06d074a376bb5aa9	11	11002	2	1117	1138	40	4	2024-06-05 11:08:47.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1140	\\x30b80d66dc92f934c880946093677ede592483136d5f404189dbccb18c775dbe	11	11019	19	1118	1139	21	573	2024-06-05 11:08:50.8	1	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
1141	\\x32ee006f0bf93e29497d44eccbfa20e21bf9f5520b7f5cf7712a2e45465fabb9	11	11021	21	1119	1140	16	4	2024-06-05 11:08:51.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1142	\\x25e64740a322d9d3395101c344b8f54488af05869792be19f49ce12ecbf735c5	11	11037	37	1120	1141	6	4	2024-06-05 11:08:54.4	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1143	\\x353e57c7ca8ef70d011aafdb00b882350f61a5aee4f03719a9f09c4d2e022016	11	11041	41	1121	1142	16	4	2024-06-05 11:08:55.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1144	\\x102f96a69c64d1ec47cf716b141e7a060963550dd68058c3c81b9b0bbb9bbe47	11	11057	57	1122	1143	16	4	2024-06-05 11:08:58.4	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1145	\\xa19ec67dd906820b315792863cf6a11440c2ca42d2fe182d6bb2180a6c123455	11	11059	59	1123	1144	3	4	2024-06-05 11:08:58.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1146	\\x3903bf9f3afc4a9632cd32666f8a6d2eb738a9d6c70129c47fb1078c10ae5de4	11	11075	75	1124	1145	7	4	2024-06-05 11:09:02	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1147	\\x0d0486b5d21e2703c3c74621f5acf34084c1e97a337275b1b9ef301f7330e1b7	11	11083	83	1125	1146	12	554	2024-06-05 11:09:03.6	1	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1148	\\x8f3608935496fb08a5afd8f7b6fa34793ce79420014035d1b2b835ed1886739a	11	11092	92	1126	1147	5	4	2024-06-05 11:09:05.4	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
1149	\\x189cd1fda905072cb709a5a0755cb928d25aa7bb91528fbeec888e79a40e0c5d	11	11115	115	1127	1148	6	4	2024-06-05 11:09:10	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1150	\\x810047101e77d979cfd64f3aff9a71020e89ba0df8f3e674ed4d487c5c3e93af	11	11123	123	1128	1149	3	4	2024-06-05 11:09:11.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1151	\\xbb5614fec29c3bce95a076bafda12709bdbbf4336b592d1ac8a8fa5df9b8bc15	11	11173	173	1129	1150	7	329	2024-06-05 11:09:21.6	1	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1152	\\x1187d2ec224c905f028827db0ff716d55a0f8a93a71ba910611f875097033444	11	11175	175	1130	1151	3	4	2024-06-05 11:09:22	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1153	\\x6cc913e01a017d81209f385aad103189240f7ea41604a3693178a1f2a730b4f5	11	11184	184	1131	1152	12	4	2024-06-05 11:09:23.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1154	\\xfc96f4f40046a1e86b911c8d8e7c0b13c032c64e27a7f79548bb06021b7da9c2	11	11185	185	1132	1153	40	4	2024-06-05 11:09:24	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1155	\\xa5d45f66918fb12a103dbd711e6954e739a282467605d7b3fae735a41e0073dd	11	11195	195	1133	1154	6	496	2024-06-05 11:09:26	1	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1156	\\xbdfb519fb87a0ed517acbf1919e15eba1d3e917397b7994683f5ff44f0c1b3bd	11	11200	200	1134	1155	21	4	2024-06-05 11:09:27	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
1158	\\x74c709b49a9c9e5620f8ebe1702a5d705b4b2cff4a4336bedc0d24898033a453	11	11202	202	1135	1156	7	4	2024-06-05 11:09:27.4	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1159	\\x8df05f870d372bcd075a64a129aa22ee4fbbee1aa215733712f6ad27d2926528	11	11215	215	1136	1158	7	4	2024-06-05 11:09:30	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1160	\\x933d74d0ad67fd02bf462d81a7e00a1f1c85a3fc2b27819106965c1a25c51186	11	11234	234	1137	1159	7	753	2024-06-05 11:09:33.8	1	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1161	\\x2cff49c6f626d6b2a59a3d40bf7e1b78e1862e8e9502d0d7c645fc077b320246	11	11245	245	1138	1160	7	4	2024-06-05 11:09:36	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1162	\\x0874c186410df6aca639c7cc40452ca088efd3c28f31c1093e0ddeff914143de	11	11252	252	1139	1161	40	4	2024-06-05 11:09:37.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1163	\\x09e4c6e87b55147a970205b3d1ba92bca1c02964d728f1f474ebbf86109c6bae	11	11261	261	1140	1162	3	4	2024-06-05 11:09:39.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1164	\\xa5c6696af35712971f8a61f8b6ff4135f1ea4824b8e1362c426da9e4f58f49a0	11	11273	273	1141	1163	5	433	2024-06-05 11:09:41.6	1	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
1165	\\x04fe266174dd7c114b81fd666e6c14c54410efb2051bf1a51c3ef368a16d393e	11	11286	286	1142	1164	7	4	2024-06-05 11:09:44.2	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1166	\\x99d7de2c30591ee03ff006fbad6f7ca11d1f26dc2cd188207f105814921ce63b	11	11288	288	1143	1165	3	4	2024-06-05 11:09:44.6	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1167	\\x1ddcc407a8df99be5151b4464d3619a75fb4a3c4c43b83a28047c00e6016b7b4	11	11291	291	1144	1166	16	4	2024-06-05 11:09:45.2	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1168	\\xe6aa6af486380e7de272ab7edbead5d5d7486f6daa6d4cc327352020339cc16c	11	11296	296	1145	1167	12	564	2024-06-05 11:09:46.2	1	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1169	\\xa9dc07fdc76a909449e4a10ae35b6355c4cd53bd423fc927f207fbb51df97174	11	11298	298	1146	1168	7	4	2024-06-05 11:09:46.6	0	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1170	\\xc710e4a207fe017454a6270c6622438eb2a6c455c17a322eb55602668222c75c	11	11302	302	1147	1169	4	4	2024-06-05 11:09:47.4	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
1171	\\x700f9aabf9a6df98d1684889a0b6b75b13999d9ad3800d6357ad28df2953540b	11	11304	304	1148	1170	16	4	2024-06-05 11:09:47.8	0	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1172	\\xda42a9cec0b0ef55ebc8bc33f3629d287767533d8b3b40b7890a06a73a2baad4	11	11314	314	1149	1171	12	4	2024-06-05 11:09:49.8	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1173	\\x3bae38fe2aa0ab746cac59d359ce48dfb9b67169ffaada0c11458eafe9fec975	11	11328	328	1150	1172	16	1704	2024-06-05 11:09:52.6	1	9	0	vrf_vk1tm0ydglg24gew5s48tsaggd3hn2af9ta5a7rw50745vqsl73unysg4c7g6	\\x3d8f54841efe4de7b315ece3e3ee4640cd85e73106c6c0446dcb41fed2b1fb39	0
1174	\\x1d2a3cacef32a49f5b1a426ef6f0baaa122f7313939161b845bd70210346d0ae	11	11330	330	1151	1173	4	4	2024-06-05 11:09:53	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
1175	\\x8754c69a26338590f4bbf4d097d0eecd4ada452a0f8ff3d15ca8945d6e2dcc7f	11	11332	332	1152	1174	12	4	2024-06-05 11:09:53.4	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1176	\\x7a8d155d52a5e698e8e1807d27429fa9b5f1ceed0e72298eaa4f94e101ce5ec2	11	11340	340	1153	1175	3	4	2024-06-05 11:09:55	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1177	\\x73389caa648f9d50777abb4e33f3032444ccd9c3504efbebb6e9fa9a1f227e11	11	11343	343	1154	1176	12	1415	2024-06-05 11:09:55.6	1	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1178	\\xc24fac376a2c0c845462b98e86f15fe841285b4cbe7a0f5c29822b53629f38d3	11	11350	350	1155	1177	12	4	2024-06-05 11:09:57	0	9	0	vrf_vk1p0g3qls4xhkhefg4a0zvh4r66uglex84q27raufxk3vavsgcz6ysju499s	\\x003bb9aeaa90f7e488f73e1f2fd24a4fe4857fb8724145d7fa4aec11833499fd	0
1179	\\x350add3aa2738aaf97a4c5c365712c6528d50653bd917b8176aff82640e354d5	11	11355	355	1156	1178	4	4	2024-06-05 11:09:58	0	9	0	vrf_vk1gqgu6e67dj05ef0z8aruunx4q8az9vclcx59ch2gjflczwqv905syvglr8	\\x42772ac9351b942d1425aa20b17bb9e67ccf88f5924b27991fbb03cb6293bd56	0
1180	\\xfe5a13f9c249590cf3eb9e1ff729d828038b6ece043dd1ce5125df71e5f81747	11	11368	368	1157	1179	5	4	2024-06-05 11:10:00.6	0	9	0	vrf_vk1u85j0kzrxmw5cwjmsxaj2agzu3e43fc2h50jy9d66gwr44ke0lzs4msrny	\\x7c2913e966f020045d589ea2b51548edc9541e67aa19337e884b7220b0d42513	0
1181	\\xea485fd6dc7034704bffa1fb1b0e9d3e83240becabc062cfc25e69405414aa55	11	11372	372	1158	1180	3	1502	2024-06-05 11:10:01.4	1	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1182	\\x036d349d4128a4a48476dcb4a51cbf793ea8e77a5c085c33e6e51672027b8d84	11	11374	374	1159	1181	6	4	2024-06-05 11:10:01.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1183	\\x56e1f71328ccd45da731205db57a6bfdd4e873aacb04a167d07ac3cd7acffedb	11	11384	384	1160	1182	3	4	2024-06-05 11:10:03.8	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1184	\\x4dfaaa4f5929117ded31aaf72141fa98182ee9a8e20118fa74bbb10d56bb1e32	11	11416	416	1161	1183	3	4	2024-06-05 11:10:10.2	0	9	0	vrf_vk1cap047k2az4zhec0rm55n5sl4nvq9amzf0kk4x54uvxpxwd3a8pq8ygrzx	\\x0db3ced0d9bf6f0b27f28e2e422c534af628e9ea3d67c5ed7b45cb2d9e2cc5b1	0
1185	\\xbde1a379812a4482bda1cee050edee06d95a03467ad13d1450c17ccfc8497563	11	11426	426	1162	1184	7	716	2024-06-05 11:10:12.2	1	9	0	vrf_vk1wpa53afz6yd6mjcx2cgxmc9fjfn0xk0frw2735rxnjdjel7qe48s3qvv0j	\\xc0cc50a16e450c01760cc079e644b4916309dd3a5fa4236891e2c1ee079ff3b4	0
1186	\\x21b08c508025b680d3b929779863fbee6629f040a0aecf0333b3f0fc1f5e675e	11	11427	427	1163	1185	40	4	2024-06-05 11:10:12.4	0	9	0	vrf_vk1eg7gyr2m3jhaz2da2jnqnckshp62k5nfjmlmxs4700h5jj4xy07qvffrpk	\\x686279e54bdb870dc99e0b62aae10a59c64f39b37c82aa0bfc0180772250d703	0
1187	\\xe783ccfe32d394c9a7de5c34cb80b797f4e3fe42743d0770b57aa04bf147daf5	11	11449	449	1164	1186	6	4	2024-06-05 11:10:16.8	0	9	0	vrf_vk16jn38yrqum5w4z6206gsn5k3kr5fanc956c0k74eps8tr2gddkjsy3p5lk	\\x360d5c751cd099386f9198dd0046031c34cddb259543c29496dca3488ed6c6d0	0
1188	\\x7dd151d99e9f8fff8535696cacaa06fd410085a5438b38b31d4eba3579a295d1	11	11453	453	1165	1187	21	4	2024-06-05 11:10:17.6	0	9	0	vrf_vk1mw2ythk6al9s260a4adhgq744kp22m9qx55m0scvpgt99dznxgeqyg3d39	\\xb17b1e4d896e097ecbd62409d6215581878c1602c5a7e8dbf04d5f25fd5bce09	0
\.


--
-- Data for Name: collateral_tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collateral_tx_in (id, tx_in_id, tx_out_id, tx_out_index) FROM stdin;
1	121	120	1
2	128	127	1
\.


--
-- Data for Name: collateral_tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collateral_tx_out (id, tx_id, index, address, address_has_script, payment_cred, stake_address_id, value, data_hash, multi_assets_descr, inline_datum_id, reference_script_id) FROM stdin;
1	121	1	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	3681317478711293	\N	fromList []	\N	\N
2	128	1	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	3681316876418310	\N	fromList []	\N	\N
\.


--
-- Data for Name: committee_de_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.committee_de_registration (id, tx_id, cert_index, cold_key, voting_anchor_id) FROM stdin;
\.


--
-- Data for Name: committee_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.committee_registration (id, tx_id, cert_index, cold_key, hot_key) FROM stdin;
\.


--
-- Data for Name: constitution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.constitution (id, gov_action_proposal_id, voting_anchor_id, script_hash) FROM stdin;
\.


--
-- Data for Name: cost_model; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cost_model (id, costs, hash) FROM stdin;
1	{"PlutusV1": [197209, 0, 1, 1, 396231, 621, 0, 1, 150000, 1000, 0, 1, 150000, 32, 2477736, 29175, 4, 29773, 100, 29773, 100, 29773, 100, 29773, 100, 29773, 100, 29773, 100, 100, 100, 29773, 100, 150000, 32, 150000, 32, 150000, 32, 150000, 1000, 0, 1, 150000, 32, 150000, 1000, 0, 8, 148000, 425507, 118, 0, 1, 1, 150000, 1000, 0, 8, 150000, 112536, 247, 1, 150000, 10000, 1, 136542, 1326, 1, 1000, 150000, 1000, 1, 150000, 32, 150000, 32, 150000, 32, 1, 1, 150000, 1, 150000, 4, 103599, 248, 1, 103599, 248, 1, 145276, 1366, 1, 179690, 497, 1, 150000, 32, 150000, 32, 150000, 32, 150000, 32, 150000, 32, 150000, 32, 148000, 425507, 118, 0, 1, 1, 61516, 11218, 0, 1, 150000, 32, 148000, 425507, 118, 0, 1, 1, 148000, 425507, 118, 0, 1, 1, 2477736, 29175, 4, 0, 82363, 4, 150000, 5000, 0, 1, 150000, 32, 197209, 0, 1, 1, 150000, 32, 150000, 32, 150000, 32, 150000, 32, 150000, 32, 150000, 32, 150000, 32, 3345831, 1, 1], "PlutusV2": [205665, 812, 1, 1, 1000, 571, 0, 1, 1000, 24177, 4, 1, 1000, 32, 117366, 10475, 4, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 100, 100, 23000, 100, 19537, 32, 175354, 32, 46417, 4, 221973, 511, 0, 1, 89141, 32, 497525, 14068, 4, 2, 196500, 453240, 220, 0, 1, 1, 1000, 28662, 4, 2, 245000, 216773, 62, 1, 1060367, 12586, 1, 208512, 421, 1, 187000, 1000, 52998, 1, 80436, 32, 43249, 32, 1000, 32, 80556, 1, 57667, 4, 1000, 10, 197145, 156, 1, 197145, 156, 1, 204924, 473, 1, 208896, 511, 1, 52467, 32, 64832, 32, 65493, 32, 22558, 32, 16563, 32, 76511, 32, 196500, 453240, 220, 0, 1, 1, 69522, 11687, 0, 1, 60091, 32, 196500, 453240, 220, 0, 1, 1, 196500, 453240, 220, 0, 1, 1, 1159724, 392670, 0, 2, 806990, 30482, 4, 1927926, 82523, 4, 265318, 0, 4, 0, 85931, 32, 205665, 812, 1, 1, 41182, 32, 212342, 32, 31220, 32, 32696, 32, 43357, 32, 32247, 32, 38314, 32, 35892428, 10, 9462713, 1021, 10, 38887044, 32947, 10]}	\\xb653ac9f38223cd1115e0ba72b538f06f656307c254ea48deb721b3c98acf290
\.


--
-- Data for Name: datum; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.datum (id, hash, tx_id, value, bytes) FROM stdin;
1	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	121	{"int": 12}	\\x0c
2	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	122	{"int": 42}	\\x182a
3	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	127	{"fields": [], "constructor": 0}	\\xd87980
4	\\x81cb2989cbf6c49840511d8d3451ee44f58dde2c074fc749d05deb51eeb33741	132	{"fields": [{"map": [{"k": {"bytes": "636f7265"}, "v": {"map": [{"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "707265666978"}, "v": {"bytes": "24"}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 0}}, {"k": {"bytes": "7465726d736f66757365"}, "v": {"bytes": "68747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f"}}, {"k": {"bytes": "68616e646c65456e636f64696e67"}, "v": {"bytes": "7574662d38"}}]}}, {"k": {"bytes": "6e616d65"}, "v": {"bytes": "283130302968616e646c653638"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f736f6d652d68617368"}}, {"k": {"bytes": "77656273697465"}, "v": {"bytes": "68747470733a2f2f63617264616e6f2e6f72672f"}}, {"k": {"bytes": "6465736372697074696f6e"}, "v": {"bytes": "5468652048616e646c65205374616e64617264"}}, {"k": {"bytes": "6175676d656e746174696f6e73"}, "v": {"list": []}}]}, {"int": 1}, {"map": []}], "constructor": 0}	\\xd8799fa644636f7265a5426f67004670726566697841244776657273696f6e004a7465726d736f66757365583668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f4e68616e646c65456e636f64696e67457574662d38446e616d654d283130302968616e646c65363845696d61676550697066733a2f2f736f6d652d6861736847776562736974655468747470733a2f2f63617264616e6f2e6f72672f4b6465736372697074696f6e535468652048616e646c65205374616e646172644d6175676d656e746174696f6e738001a0ff
5	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	134	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "24706861726d65727332"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "6261736963"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 9}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c6574746572732c6e756d62657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "62675f696d616765"}, "v": {"bytes": "697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f"}}, {"k": {"bytes": "7066705f696d616765"}, "v": {"bytes": "697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b524244"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": "697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b"}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879"}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "01e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c980"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "312e31352e30"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "7066705f6173736574"}, "v": {"bytes": "e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e044503036383136"}}, {"k": {"bytes": "62675f6173736574"}, "v": {"bytes": "9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65"}}]}], "constructor": 0}	\\xd8799faa446e616d654a24706861726d6572733245696d6167655838697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e677468094a636861726163746572734f6c6574746572732c6e756d62657273516e756d657269635f6d6f64696669657273404776657273696f6e0101b34862675f696d6167655835697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f497066705f696d6167655835697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b52424446706f7274616c404864657369676e65725838697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b47736f6369616c73404676656e646f72404764656661756c74004e7374616e646172645f696d6167655838697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879536c6173745f7570646174655f61646472657373583901e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d4c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f686173685820bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de537374616e646172645f696d6167655f686173685820b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c9804b7376675f76657273696f6e46312e31352e304c6167726565645f7465726d7340546d6967726174655f7369675f726571756972656400446e7366770045747269616c00497066705f61737365745823e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e0445030363831364862675f6173736574582c9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65ff
6	\\xff1a404ece117cc4482d26b072e30b5a6b3cd055a22debda3f90d704957e273a	135	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "24686e646c"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d73627162317366736356365970"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "636f6d6d6f6e"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 4}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c657474657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d73627162317366736356365970"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": ""}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "00f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df40"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "32646465376163633062376532333931626633326133646537643566313763356365663231633336626432333564636663643738376463663439656661363339"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "32646465376163633062376532333931626633326133646537643566313763356365663231633336626432333564636663643738376463663439656661363339"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "322e302e31"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}]}], "constructor": 0}	\\xd8799faa446e616d654524686e646c45696d6167655838697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d73627162317366736356365970496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d626572004672617269747946636f6d6d6f6e466c656e677468044a63686172616374657273476c657474657273516e756d657269635f6d6f64696669657273404776657273696f6e0101af4e7374616e646172645f696d6167655838697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d7362716231736673635636597046706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f61646472657373583900f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df404c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f68617368584032646465376163633062376532333931626633326133646537643566313763356365663231633336626432333564636663643738376463663439656661363339537374616e646172645f696d6167655f686173685840326464653761636330623765323339316266333261336465376435663137633563656632316333366264323335646366636437383764636634396566613633394b7376675f76657273696f6e45322e302e314c6167726565645f7465726d7340546d6967726174655f7369675f72657175697265640045747269616c00446e73667700ff
7	\\x29294f077464c36e67b304ad22547fb3dfa946623b0b2cbae8acea7fb299353c	136	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "2473756240686e646c"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d3534726472455032776366"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "6261736963"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 8}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c657474657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d3534726472455032776366"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": ""}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "00f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df40"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "34333831373362613630333931353466646232643137383763363765633636333863393462643331633835336630643964356166343365626462313864623934"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "34333831373362613630333931353466646232643137383763363765633636333863393462643331633835336630643964356166343365626462313864623934"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "322e302e31"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}]}], "constructor": 0}	\\xd8799faa446e616d65492473756240686e646c45696d6167655838697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d3534726472455032776366496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e677468084a63686172616374657273476c657474657273516e756d657269635f6d6f64696669657273404776657273696f6e0101af4e7374616e646172645f696d6167655838697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d353472647245503277636646706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f61646472657373583900f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df404c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f68617368584034333831373362613630333931353466646232643137383763363765633636333863393462643331633835336630643964356166343365626462313864623934537374616e646172645f696d6167655f686173685840343338313733626136303339313534666462326431373837633637656336363338633934626433316338353366306439643561663433656264623138646239344b7376675f76657273696f6e45322e302e314c6167726565645f7465726d7340546d6967726174655f7369675f72657175697265640045747269616c00446e73667700ff
\.


--
-- Data for Name: delegation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delegation (id, addr_id, cert_index, pool_hash_id, active_epoch_no, tx_id, slot_no, redeemer_id) FROM stdin;
1	5	1	1	2	34	0	\N
2	2	3	9	2	34	0	\N
3	7	5	4	2	34	0	\N
4	10	7	3	2	34	0	\N
5	3	9	7	2	34	0	\N
6	9	11	6	2	34	0	\N
7	11	13	5	2	34	0	\N
8	6	15	2	2	34	0	\N
9	4	17	11	2	34	0	\N
10	1	19	10	2	34	0	\N
11	8	21	8	2	34	0	\N
12	20	0	9	2	79	176	\N
13	12	0	1	2	80	176	\N
14	16	0	5	2	81	176	\N
15	18	0	7	2	82	176	\N
16	13	0	2	2	83	176	\N
17	19	0	8	2	84	176	\N
18	21	0	10	2	85	176	\N
19	22	0	11	2	86	176	\N
20	15	0	4	2	87	176	\N
21	14	0	3	2	88	176	\N
22	17	0	6	2	89	176	\N
23	42	0	9	2	90	187	\N
24	40	0	5	2	91	187	\N
25	37	0	2	2	92	187	\N
26	34	0	3	2	93	187	\N
27	43	0	10	2	94	187	\N
28	44	0	6	2	95	187	\N
29	36	0	4	2	96	187	\N
30	41	0	1	2	97	187	\N
31	39	0	7	2	98	187	\N
32	35	0	11	2	99	187	\N
33	38	0	8	2	100	187	\N
34	41	0	1	2	112	226	\N
35	44	0	6	2	113	226	\N
36	43	0	10	2	114	226	\N
37	42	0	9	2	115	226	\N
38	75	1	8	5	169	3466	\N
39	77	1	5	5	172	3541	\N
40	78	3	8	5	172	3541	\N
41	79	5	2	5	172	3541	\N
42	80	7	3	5	172	3541	\N
43	81	9	4	5	172	3541	\N
44	77	0	5	5	174	3613	\N
45	78	1	5	5	174	3613	\N
46	79	2	5	5	174	3613	\N
47	80	3	5	5	174	3613	\N
48	81	4	5	5	174	3613	\N
49	68	1	8	5	175	3658	\N
50	68	1	5	5	177	3716	\N
51	89	1	8	9	279	7071	\N
52	70	0	12	13	383	11195	\N
53	67	0	13	13	386	11296	\N
\.


--
-- Data for Name: delegation_vote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delegation_vote (id, addr_id, cert_index, drep_hash_id, tx_id, redeemer_id) FROM stdin;
\.


--
-- Data for Name: delisted_pool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delisted_pool (id, hash_raw) FROM stdin;
\.


--
-- Data for Name: drep_distr; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drep_distr (id, hash_id, amount, epoch_no, active_until) FROM stdin;
\.


--
-- Data for Name: drep_hash; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drep_hash (id, raw, view, has_script) FROM stdin;
\.


--
-- Data for Name: drep_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drep_registration (id, tx_id, cert_index, deposit, drep_hash_id, voting_anchor_id) FROM stdin;
\.


--
-- Data for Name: epoch; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch (id, out_sum, fees, tx_count, blk_count, no, start_time, end_time) FROM stdin;
4	0	0	0	101	1	2024-06-05 10:35:30.8	2024-06-05 10:38:45.8
14	0	0	0	102	4	2024-06-05 10:45:27.2	2024-06-05 10:48:45.2
24	0	0	0	95	8	2024-06-05 10:58:49.2	2024-06-05 11:02:02.4
21	0	0	0	88	6	2024-06-05 10:52:09.6	2024-06-05 10:55:21.8
10	41002014298321	4909498	22	106	3	2024-06-05 10:42:12.2	2024-06-05 10:45:24.8
1	213550434838462453	17367381	98	100	0	2024-06-05 10:32:07	2024-06-05 10:35:26.8
32	21647584376226	2125783	11	49	11	2024-06-05 11:08:47.4	2024-06-05 11:10:17.6
22	5006020135146	433566	2	86	7	2024-06-05 10:55:27.8	2024-06-05 10:58:36.2
30	0	0	0	114	10	2024-06-05 11:05:29.6	2024-06-05 11:08:45.8
19	55990652887703	16957012	100	97	5	2024-06-05 10:48:48.4	2024-06-05 10:52:06.8
8	69999366065401	4347943	23	119	2	2024-06-05 10:38:49.2	2024-06-05 10:42:06.4
26	24439536670433	16923352	100	109	9	2024-06-05 11:02:07.8	2024-06-05 11:05:26.8
\.


--
-- Data for Name: epoch_param; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_param (id, epoch_no, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, nonce, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, block_id, extra_entropy, coins_per_utxo_size, pvt_motion_no_confidence, pvt_committee_normal, pvt_committee_no_confidence, pvt_hard_fork_initiation, dvt_motion_no_confidence, dvt_committee_normal, dvt_committee_no_confidence, dvt_update_to_constitution, dvt_hard_fork_initiation, dvt_p_p_network_group, dvt_p_p_economic_group, dvt_p_p_technical_group, dvt_p_p_gov_group, dvt_treasury_withdrawal, committee_min_size, committee_max_term_length, gov_action_lifetime, gov_action_deposit, drep_deposit, drep_activity) FROM stdin;
1	1	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	7	0	0	0	\\xeb1f7f8be144071c0b204cc5477bf44354340807185ab31562c878941df34f30	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	103	\N	4310	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2	2	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	7	0	0	0	\\xe329a2f1a33357402146626324e5aff7b31c75cc45ff5761c86c88f147e17cd2	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	206	\N	4310	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3	3	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	7	0	0	0	\\xe664e032b1a60b139b90d4754b941674c1ba105473a67995a6e0e957bb63937b	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	328	\N	4310	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4	4	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	7	0	0	0	\\x374543127ba1a8f9ee8733c7c9993c89c87baa98feeceafcdab47a2ca36e136d	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	435	\N	4310	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5	5	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	7	0	0	0	\\x46e9940498e2fd47c6624f944db94a0e897b0a98ebb5a68214c24d46266c68d5	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	540	\N	4310	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
6	6	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	7	0	0	0	\\x5b42fd8aad561d4f130180e0ebecdcc04d484856e5ed746b868829f7d3970e8e	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	641	\N	4310	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
7	7	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	7	0	0	0	\\x15544135feded883ffd62ed4b4e9ca5fa0500999ab2a058d36176fee89daefc2	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	730	\N	4310	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8	8	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	7	0	0	0	\\x300b2f0f9392903986bdb428ac29b394a0edbefc5559af7de5b08c13b06215af	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	816	\N	4310	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
9	9	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	7	0	0	0	\\xb553815e0c4d96bc18ac7f6a61a57d40751f1554ef49e96ec7718e3013b25e7d	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	912	\N	4310	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
10	10	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	7	0	0	0	\\xa55f9c2c7403d1f385e0b9860f6935a6edfde4fcc0954e1f8d2bc3be1c9f5caf	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1022	\N	4310	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
11	11	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	7	0	0	0	\\x81ba25c96d39bd5ed0e5eb2f9b12c93084f2b33a8526e47ac0eb8a8c52535aba	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1139	\N	4310	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: epoch_stake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_stake (id, addr_id, pool_id, amount, epoch_no) FROM stdin;
1	5	1	7772727272727272	1
2	2	9	7772727272727272	1
3	7	4	7772727272727272	1
4	10	3	7772727272727280	1
5	3	7	7772727272727272	1
6	9	6	7772727272727272	1
7	11	5	7772727272727272	1
8	6	2	7772727272727272	1
9	4	11	7772727272727272	1
10	1	10	7772727272727272	1
11	8	8	7772727272727272	1
12	5	1	7772727272727272	2
13	2	9	7772727272727272	2
14	18	7	500000000	2
15	12	1	300000000	2
16	7	4	7772727272727272	2
17	42	9	499997289684	2
18	41	1	499997289684	2
19	14	3	500000000	2
20	10	3	7772727272727280	2
21	20	9	300000000	2
22	3	7	7772727272727272	2
23	44	6	499997286868	2
24	43	10	499997286868	2
25	13	2	500000000	2
26	37	2	499997463677	2
27	9	6	7772727272727272	2
28	16	5	500000000	2
29	39	7	499997463677	2
30	21	10	500000000	2
31	17	6	500000000	2
32	34	3	499997463677	2
33	38	8	499997463677	2
34	35	11	499997466449	2
35	11	5	7772727272727272	2
36	15	4	200000000	2
37	6	2	7772727272727272	2
38	4	11	7772727272727272	2
39	1	10	7772727272727272	2
40	8	8	7772727272727272	2
41	40	5	499997463677	2
42	22	11	600000000	2
43	36	4	499997463677	2
44	19	8	500000000	2
45	5	1	7772727272727272	3
46	2	9	7772727272727272	3
47	18	7	500000000	3
48	12	1	300000000	3
49	7	4	7772727272727272	3
50	42	9	499997289684	3
51	41	1	499997289684	3
52	14	3	500000000	3
53	10	3	7772727272727280	3
54	20	9	300000000	3
55	3	7	7772727272727272	3
56	44	6	499997286868	3
57	43	10	499997286868	3
58	13	2	500000000	3
59	37	2	499997463677	3
60	9	6	7772727272727272	3
61	16	5	500000000	3
62	39	7	499997463677	3
63	21	10	500000000	3
64	17	6	500000000	3
65	34	3	499997463677	3
66	38	8	499997463677	3
67	35	11	499997466449	3
68	11	5	7772727272727272	3
69	15	4	200000000	3
70	6	2	7772727272727272	3
71	4	11	7772727272727272	3
72	1	10	7772727272727272	3
73	8	8	7772727272727272	3
74	40	5	499997463677	3
75	22	11	600000000	3
76	36	4	499997463677	3
77	19	8	500000000	3
78	5	1	7777094050051465	4
79	2	9	7779714116445982	4
80	18	7	500000000	4
81	12	1	300000000	4
82	7	4	7780587471910821	4
83	42	9	499997289684	4
84	41	1	499997289684	4
85	14	3	500000000	4
86	10	3	7779714116445990	4
87	20	9	300000000	4
88	3	7	7783207538305337	4
89	44	6	499997286868	4
90	43	10	499997286868	4
91	13	2	500000000	4
92	37	2	499997463677	4
93	9	6	7780587471910821	4
94	16	5	500000000	4
95	39	7	499997463677	4
96	21	10	500000000	4
97	17	6	500000000	4
98	34	3	499997463677	4
99	38	8	499997463677	4
100	35	11	499997466449	4
101	11	5	7782334182840498	4
102	15	4	200000000	4
103	6	2	7778840760981143	4
104	4	11	7782334182840498	4
105	1	10	7780587471910821	4
106	8	8	7783207538305337	4
107	40	5	499997463677	4
108	22	11	600000000	4
109	36	4	499997463677	4
110	19	8	500000000	4
111	5	1	7787264400941061	5
112	80	5	0	5
113	2	9	7784799291890780	5
114	18	7	500654233	5
115	12	1	300392539	5
116	7	4	7787125554793489	5
117	42	9	500324404459	5
118	41	1	500651519235	5
119	14	3	500280385	5
120	79	5	0	5
121	10	3	7784072838031327	5
122	20	9	300196269	5
123	3	7	7793377888671125	5
124	77	5	0	5
125	44	6	500137478906	5
126	43	10	500558055023	5
127	13	2	500467309	5
128	37	2	500464770638	5
129	9	6	7782766832703588	5
130	78	5	0	5
131	16	5	500747694	5
132	39	7	500651693422	5
133	21	10	500560771	5
134	17	6	500140192	5
135	34	3	500277847853	5
136	38	8	500698424118	5
137	35	11	500604965486	5
138	11	5	7793957440401399	5
139	81	5	989212833	5
140	15	4	200168231	5
141	6	2	7786105296956705	5
142	4	11	7791778079365738	5
143	1	10	7789304915081892	5
144	8	8	7794104342268681	5
145	40	5	500745154815	5
146	22	11	600729002	5
147	68	5	4998906859265	5
148	36	4	500418039974	5
149	19	8	500700963	5
189	5	1	7787264400941061	6
190	80	5	0	6
191	2	9	7784799291890780	6
192	18	7	1799421669839	6
193	12	1	300392539	6
194	7	4	7787125554793489	6
195	42	9	500324404459	6
196	41	1	500651519235	6
197	14	3	1319791191824	6
198	79	5	0	6
199	10	3	7791546125922520	6
200	20	9	300196269	6
201	3	7	7803568847833720	6
202	77	5	0	6
203	44	6	500487098697	6
204	43	10	500863968581	6
205	13	2	840152774582	6
206	37	2	500770686491	6
207	9	6	7788201860766888	6
208	78	5	0	6
209	16	5	1439697060175	6
210	39	7	501307248873	6
211	21	10	840186868061	6
212	17	6	960074848527	6
213	34	3	500758583231	6
214	38	8	501004338878	6
215	35	11	500954585393	6
216	11	5	7802110148235305	6
217	81	5	989212833	6
218	15	4	200168231	6
219	6	2	7790860922075949	6
220	4	11	7797213107288942	6
221	1	10	7794060506203542	6
222	8	8	7798859950389020	6
223	40	5	501269595348	6
224	22	11	960175494899	6
225	68	5	4998906859265	6
226	36	4	500418039974	6
227	19	8	840170008234	6
228	80	5	0	7
229	2	9	7784799291890780	7
230	18	7	3881410385660	7
231	7	4	7787125554793489	7
232	42	9	500324404459	7
233	14	3	2300161941065	7
234	79	5	0	7
235	10	3	7797098990909781	7
236	20	9	300196269	7
237	3	7	7815363754460755	7
238	77	5	0	7
239	44	6	500665487544	7
240	13	2	1698097889645	7
241	37	2	501083024370	7
242	9	6	7790977815893771	7
243	78	5	0	7
244	16	5	2542201547476	7
245	39	7	502064960056	7
246	17	6	1450370972938	7
247	34	3	501115462464	7
248	38	8	501450042891	7
249	35	11	501088311698	7
250	11	5	7808355059767007	7
251	81	5	989212833	7
252	15	4	200168231	7
253	6	2	7795720199974500	7
254	4	11	7799294523426895	7
255	8	8	7805797999266319	7
256	40	5	501670816865	7
257	22	11	1327898012676	7
258	68	5	4998889902253	7
259	36	4	500418039974	7
260	19	8	2065000752826	7
261	80	5	0	8
262	2	9	7784799291890780	8
263	18	7	4250030731865	8
264	7	4	7787125554793489	8
265	42	9	500324404459	8
266	14	3	3160841453054	8
267	79	5	0	8
268	10	3	7801973649430957	8
269	20	9	300196269	8
270	3	7	7817450201494295	8
271	77	5	0	8
272	44	6	501247364826	8
273	13	2	3418659236523	8
274	37	2	501709536615	8
275	9	6	7800032556655938	8
276	78	5	0	8
277	16	5	3523911413935	8
278	39	7	502198994778	8
279	17	6	3048759770347	8
280	34	3	501428753940	8
281	38	8	501673428404	8
282	35	11	501535287383	8
283	11	5	7813911948149746	8
284	81	5	989918115	8
285	15	4	200168231	8
286	6	2	7805467320251127	8
287	4	11	7806251576573149	8
288	8	8	7809275321973571	8
289	40	5	502027835100	8
290	22	11	2556082782869	8
291	68	5	5002453992468	8
292	36	4	500418039974	8
293	19	8	2679075620239	8
294	80	5	0	9
295	2	9	7784799291890780	9
296	18	7	5216668021655	9
297	7	4	7787125554793489	9
298	42	9	500324404459	9
299	14	3	4007746362709	9
300	79	5	0	9
301	10	3	7806764848859753	9
302	20	9	300196269	9
303	3	7	7822916791367399	9
304	77	5	0	9
305	44	6	501643439972	9
306	13	2	5232698894133	9
307	37	2	502369620751	9
308	9	6	7806195978650495	9
309	78	5	0	9
310	16	5	4972719916395	9
311	39	7	502550172704	9
312	17	6	4137776233698	9
313	34	3	501736681814	9
314	38	8	501893093279	9
315	35	11	501886866688	9
316	11	5	7822103799598486	9
317	81	5	990956742	9
318	15	4	200168231	9
319	6	2	7815736738653015	9
320	4	11	7811723806688992	9
321	8	8	7812694724693843	9
322	40	5	502554144775	9
323	22	11	3523015280996	9
324	89	8	2501225909061	9
325	68	5	2506474268691	9
326	36	4	500418039974	9
327	19	8	3283361772606	9
328	80	5	0	10
329	2	9	7784799291890780	10
330	18	7	6579353589052	10
331	7	4	7787125554793489	10
332	42	9	500324404459	10
333	14	3	5177441224087	10
334	79	5	0	10
335	10	3	7813377479809416	10
336	20	9	300196269	10
337	3	7	7830610442249357	10
338	77	5	0	10
339	44	6	501927012044	10
340	13	2	5915017560448	10
341	37	2	502617633905	10
342	9	6	7810608712865972	10
343	78	5	0	10
344	16	5	5945630908538	10
345	39	7	503044418735	10
346	17	6	4917900520961	10
347	34	3	502161672136	10
348	38	8	502175987894	10
349	35	11	502205486888	10
350	11	5	7827598952941799	10
351	81	5	991652903	10
352	15	4	200168231	10
353	6	2	7819595263210950	10
354	4	11	7816683037872396	10
355	8	8	7817098390140470	10
356	40	5	502907197120	10
357	22	11	4399613308012	10
358	89	8	2501225909061	10
359	68	5	2509992252485	10
360	36	4	500418039974	10
361	19	8	4062289687716	10
362	80	5	0	11
363	2	9	7784799291890780	11
364	18	7	7443697084392	11
365	7	4	7787125554793489	11
366	42	9	500324404459	11
367	14	3	6427448910329	11
368	79	5	0	11
369	10	3	7820439120133082	11
370	20	9	300196269	11
371	3	7	7835488130035925	11
372	77	5	0	11
373	44	6	502241259554	11
374	13	2	6972438455003	11
375	37	2	503001502812	11
376	9	6	7815498795064554	11
377	78	5	0	11
378	16	5	7289135970998	11
379	39	7	503357765138	11
380	17	6	5783550319691	11
381	34	3	502615520055	11
382	38	8	502489788437	11
383	35	11	502624116686	11
384	11	5	7835181797595250	11
385	81	5	992613547	11
386	15	4	200168231	11
387	6	2	7825567396472970	11
388	4	11	7823198889516105	11
389	8	8	7821983151231213	11
390	40	5	503394379354	11
391	22	11	5552443419344	11
392	89	8	2501180413743	11
393	68	5	2514875349529	11
394	36	4	500418039974	11
395	19	8	4926723235790	11
396	80	5	0	12
397	2	9	7784799291890780	12
398	18	7	8484925096908	12
399	7	4	7787125554793489	12
400	42	9	500324404459	12
401	14	3	8164945289383	12
402	79	5	0	12
403	10	3	7830248520262537	12
404	20	9	300196269	12
405	3	7	7841359675533865	12
406	77	5	0	12
407	44	6	502651011248	12
408	13	2	7667324279291	12
409	37	2	503253329270	12
410	9	6	7821875041169660	12
411	78	5	0	12
412	16	5	7809723084863	12
413	39	7	503734957722	12
414	17	6	6913208779842	12
415	34	3	503245965055	12
416	38	8	502961832313	12
417	35	11	502813075340	12
418	11	5	7838116016384680	12
419	81	5	992985273	12
420	15	4	200168231	12
421	6	2	7829485247431669	12
422	4	11	7826139976285482	12
423	8	8	7829331199561373	12
424	40	5	503582896900	12
425	22	11	6073442551310	12
426	89	8	2503532883602	12
427	68	5	2515815575340	12
428	36	4	500418039974	12
429	19	8	6227959137132	12
\.


--
-- Data for Name: epoch_stake_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_stake_progress (id, epoch_no, completed) FROM stdin;
1	1	t
2	2	t
3	3	t
4	4	t
5	5	t
7	6	t
8	7	t
9	8	t
10	9	t
11	10	t
12	11	t
13	12	t
\.


--
-- Data for Name: epoch_sync_time; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_sync_time (id, no, seconds, state) FROM stdin;
1	0	11	following
2	1	169	following
3	2	204	following
4	3	196	following
5	4	202	following
6	5	202	following
7	6	199	following
8	7	202	following
9	8	199	following
10	9	202	following
11	10	198	following
\.


--
-- Data for Name: extra_key_witness; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.extra_key_witness (id, hash, tx_id) FROM stdin;
\.


--
-- Data for Name: extra_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.extra_migrations (id, token, description) FROM stdin;
1	StakeDistrEnded	The epoch_stake table has been migrated. It is now populated earlier during the previous era. Also the epoch_stake_progress table is introduced.
\.


--
-- Data for Name: gov_action_proposal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.gov_action_proposal (id, tx_id, index, prev_gov_action_proposal, deposit, return_address, expiration, voting_anchor_id, type, description, param_proposal, ratified_epoch, enacted_epoch, dropped_epoch, expired_epoch) FROM stdin;
\.


--
-- Data for Name: instant_reward; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.instant_reward (addr_id, type, amount, spendable_epoch) FROM stdin;
\.


--
-- Data for Name: ma_tx_mint; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ma_tx_mint (id, quantity, tx_id, ident) FROM stdin;
1	13500000000000000	129	1
2	13500000000000000	129	2
3	13500000000000000	129	3
4	13500000000000000	129	4
5	2	131	5
6	1	131	6
7	1	131	7
8	1	132	8
9	1	134	9
10	1	134	10
11	1	134	11
12	1	135	12
13	1	136	13
14	1	137	14
15	-1	140	14
16	-1	140	9
17	-1	140	12
18	-1	140	10
19	-1	140	13
20	-1	141	11
21	1	142	11
22	1	143	11
23	-2	144	11
24	2	145	11
25	-2	146	11
26	2	147	11
27	-1	148	11
28	-1	149	11
29	1	150	15
30	1	150	16
31	1	150	17
32	-1	151	16
33	1	152	18
34	1	153	19
35	1	154	20
36	-1	155	18
37	-1	155	19
38	-1	155	20
39	-1	155	15
40	-1	155	17
41	10	156	21
42	-10	157	21
43	1	158	22
44	-1	159	22
45	1	387	9
46	1	387	10
47	1	387	11
48	1	388	12
49	1	389	13
50	1	390	14
\.


--
-- Data for Name: ma_tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ma_tx_out (id, quantity, tx_out_id, ident) FROM stdin;
1	13500000000000000	157	1
2	13500000000000000	157	2
3	13500000000000000	157	3
4	13500000000000000	157	4
5	2	165	5
6	1	165	6
7	1	165	7
8	1	167	8
9	1	171	9
10	1	171	10
11	1	171	11
12	1	173	12
13	1	175	13
14	1	176	9
15	1	176	12
16	1	176	10
17	1	176	11
18	1	177	14
19	1	178	11
20	1	179	14
21	1	179	9
22	1	179	12
23	1	179	10
24	1	179	13
25	1	181	14
26	1	181	9
27	1	181	12
28	1	181	10
29	1	181	13
30	1	184	11
31	1	186	11
32	2	189	11
33	2	192	11
34	1	194	11
35	1	196	15
36	1	196	16
37	1	196	17
38	1	199	15
39	1	199	17
40	1	200	18
41	1	201	15
42	1	201	17
43	1	202	19
44	1	203	15
45	1	203	17
46	1	204	20
47	1	205	19
48	10	207	21
49	1	210	22
50	1	828	8
51	13500000000000000	828	1
52	13500000000000000	828	2
53	13500000000000000	828	3
54	13500000000000000	828	4
55	2	830	5
56	1	830	6
57	1	830	7
58	2	832	5
59	1	832	6
60	1	832	7
61	1	833	9
62	1	833	10
63	1	833	11
64	1	835	12
65	1	837	13
66	1	839	14
\.


--
-- Data for Name: meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meta (id, start_time, network_name, version) FROM stdin;
1	2024-06-05 10:32:07	testnet	Version {versionBranch = [13,2,0,2], versionTags = []}
\.


--
-- Data for Name: multi_asset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.multi_asset (id, policy, name, fingerprint) FROM stdin;
1	\\x658bb6cd932d93cdadc82af7bd677454d7eec473a333254ae2a520fc	\\x	asset1utznuknpc256mth3fplfc925qhpe2k6wdn5nu7
2	\\x658bb6cd932d93cdadc82af7bd677454d7eec473a333254ae2a520fc	\\x74425443	asset19p0rqw3k2v8vgyw67mw2f0qw0dknzqtfuvd44k
3	\\x658bb6cd932d93cdadc82af7bd677454d7eec473a333254ae2a520fc	\\x74455448	asset1m6fxtl2e760663cp9xctzy85f0mr2yt8wxdg52
4	\\x658bb6cd932d93cdadc82af7bd677454d7eec473a333254ae2a520fc	\\x744d494e	asset1xrs9sd9xxtm5u26da4lk80vz7q4n0ghqg0vgzm
5	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x646f75626c6568616e646c65	asset1fft9svnyg59cd25v68czjlgpkhkftkuzrjsgv5
6	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x68656c6c6f68616e646c65	asset128lx4yyq873l0nsccvh6wl8ztrss7ckt8u2uuw
7	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x7465737468616e646c65	asset1rjn5efmc9704ftasgac0tlpq9ezcquqh4awd3u
8	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x283232322968616e646c653638	asset1ju4qkyl4p9xszrgfxfmu909q90luzqu0nyh4u8
9	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x000643b068616e646c6532	asset1vjzkdxns6ze7ph4880h3m3zghvesral9ryp2zq
10	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x000de14068616e646c6532	asset1050jtqadfpvyfta8l86yrxgj693xws6l0qa87c
11	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x68616e646c6531	asset1q0g92m9xjj3nevsw26hfl7uf74av7yce5l56jv
12	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x000de14068616e646c	asset1we79wndeyvn4qfj8ty20d0q5ng6purl4vvts9a
13	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x000de1407375624068616e646c	asset1z7ety469aym7j5knvpkevnth4n4y9ma4uedh6h
14	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x000000007669727475616c4068616e646c	asset1d7u59dapth4x73dh8gd85q9lt9dlda4mrm6mlg
15	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d303031	asset1p7xl6rzm50j2p6q2z7kd5wz3ytyjtxts8g8drz
16	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d303032	asset1ftcuk4459tu0kfkf2s6m034q8uudr20w7wcxej
17	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d66696c6573	asset1xac6dlxa7226c65wp8u5d4mrz5hmpaeljvcr29
18	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d76312d686578	asset1v2z720699zh5x5mzk23gv829akydgqz2zy9f6l
19	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d76312d75746638	asset16unjfedceaaven5ypjmxf5m2qd079td0g8hldp
20	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d7632	asset1yc673t4h5w5gfayuedepzfrzmtuj3s9hay9kes
21	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	\\x3030303030	asset1ul4zmmx2h8rqz9wswvc230w909pq2q0hne02q0
22	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x	asset1qrmynj6uhyk2hn9pc3yh0p80rg598n4yy77ays
\.


--
-- Data for Name: new_committee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.new_committee (id, gov_action_proposal_id, deleted_members, added_members, quorum_numerator, quorum_denominator) FROM stdin;
\.


--
-- Data for Name: off_chain_pool_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.off_chain_pool_data (id, pool_id, ticker_name, hash, json, bytes, pmr_id) FROM stdin;
1	3	SP1	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	{"name": "stake pool - 1", "ticker": "SP1", "homepage": "https://stakepool1.com", "description": "This is the stake pool 1 description."}	\\x7b0a2020226e616d65223a20227374616b6520706f6f6c202d2031222c0a2020227469636b6572223a2022535031222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2031206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c312e636f6d220a7d0a	1
2	6	SP11	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	{"name": "Stake Pool - 10 + 1", "ticker": "SP11", "homepage": "https://stakepool11.com", "description": "This is the stake pool 11 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130202b2031222c0a2020227469636b6572223a202253503131222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203131206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31312e636f6d220a7d0a	2
3	10	SP10	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	{"name": "Stake Pool - 10", "ticker": "SP10", "homepage": "https://stakepool10.com", "description": "This is the stake pool 10 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130222c0a2020227469636b6572223a202253503130222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203130206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31302e636f6d220a7d0a	3
4	5	SP6a7	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	{"name": "", "ticker": "SP6a7", "homepage": "https://stakepool7.com", "description": "This is the stake pool 7 description."}	\\x7b0a2020226e616d65223a2022222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2037206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c372e636f6d220a7d0a	4
5	7	SP6a7	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	{"name": "Stake Pool - 6", "ticker": "SP6a7", "homepage": "https://stakepool6.com", "description": "This is the stake pool 6 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2036222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2036206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c362e636f6d220a7d0a	5
6	8	SP5	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	{"name": "Same Name", "ticker": "SP5", "homepage": "https://stakepool5.com", "description": "This is the stake pool 5 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535035222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2035206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c352e636f6d220a7d0a	6
7	2	SP4	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	{"name": "Same Name", "ticker": "SP4", "homepage": "https://stakepool4.com", "description": "This is the stake pool 4 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535034222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2034206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c342e636f6d220a7d0a	7
8	4	SP3	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	{"name": "Stake Pool - 3", "ticker": "SP3", "homepage": "https://stakepool3.com", "description": "This is the stake pool 3 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2033222c0a2020227469636b6572223a2022535033222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2033206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c332e636f6d220a7d0a	8
\.


--
-- Data for Name: off_chain_pool_fetch_error; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.off_chain_pool_fetch_error (id, pool_id, fetch_time, pmr_id, fetch_error, retry_count) FROM stdin;
\.


--
-- Data for Name: off_chain_vote_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.off_chain_vote_data (id, voting_anchor_id, hash, json, bytes, warning) FROM stdin;
\.


--
-- Data for Name: off_chain_vote_fetch_error; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.off_chain_vote_fetch_error (id, voting_anchor_id, fetch_error, fetch_time, retry_count) FROM stdin;
\.


--
-- Data for Name: param_proposal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.param_proposal (id, epoch_no, key, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, entropy, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, registered_tx_id, coins_per_utxo_size, pvt_motion_no_confidence, pvt_committee_normal, pvt_committee_no_confidence, pvt_hard_fork_initiation, dvt_motion_no_confidence, dvt_committee_normal, dvt_committee_no_confidence, dvt_update_to_constitution, dvt_hard_fork_initiation, dvt_p_p_network_group, dvt_p_p_economic_group, dvt_p_p_technical_group, dvt_p_p_gov_group, dvt_treasury_withdrawal, committee_min_size, committee_max_term_length, gov_action_lifetime, gov_action_deposit, drep_deposit, drep_activity) FROM stdin;
\.


--
-- Data for Name: pool_hash; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_hash (id, hash_raw, view) FROM stdin;
1	\\x06bca93c3f987e1f1978f712cd2549e923b1422cd7d8aa191c0411ea	pool1q672j0plnplp7xtc7ufv6f2fay3mzs3v6lv25xguqsg75sn6mc7
2	\\x15bbe95e0a926881dd3a6bac4a39c62bd35fbe6e2db352904bd9d55e	pool1zka7jhs2jf5grhf6dwky5wwx90f4l0nw9ke49yztm824uylj4yc
3	\\x2f86c2b5a057fdee5faa531e62ed1a5037e2753b88b4970bcf76f36a	pool197rv9ddq2l77uha22v0x9mg62qm7yafm3z6fwz70wmek5gz5ssx
4	\\x4532e25b9f4bf6997bea1c9ea509204347d9575935875b7b38995ba5	pool1g5ewykulf0mfj7l2rj022zfqgdraj46exkr4k7ecn9d62wxvman
5	\\x5184abbee848085c6810c24cc15283ab7a0430fa692376e2475f1942	pool12xz2h0hgfqy9c6qscfxvz55r4daqgv86dy3hdcj8tuv5y4n5pac
6	\\x5cd1879df37c8d196d07575bb2620e2b5d4c93bbea5049412febf6a8	pool1tngc080n0jx3jmg82admycsw9dw5eyamafgyjsf0a0m2s7re988
7	\\x6f4427e14d792f4df872ae659cadd8e124ba4706078995e793e1c512	pool1dazz0c2d0yh5m7rj4ejeetwcuyjt53cxq7yeteunu8z3yyw3y77
8	\\x87ad04cc317b495d3fb91eea91bf60581ac7fdd121cb41a4f0cb2ada	pool1s7ksfnp30dy460aerm4fr0mqtqdv0lw3y895rf8sev4d5zsgtjr
9	\\x9d062a9ae2b19c6821c677ebe2d5857f2b18f9f321e348ab7462ed21	pool1n5rz4xhzkxwxsgwxwl4794v90u43370ny83532m5vtkjzh4y2cp
10	\\xcbe612d9d64d2b4f7473da7e2438b1971eced2d13c85f11d38212fb2	pool1e0np9kwkf5457arnmflzgw93ju0va5k38jzlz8fcyyhmy9jxyh5
11	\\xd53828e79047ca469f154b2c4531a35b2f8910eb97edad19f6a8d6fe	pool165uz3eusgl9yd8c4fvky2vdrtvhcjy8tjlk66x0k4rt0u8d3495
12	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
13	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_metadata_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata_ref (id, pool_id, url, hash, registered_tx_id) FROM stdin;
1	3	http://file-server/SP1.json	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	102
2	6	http://file-server/SP11.json	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	103
3	10	http://file-server/SP10.json	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	104
4	5	http://file-server/SP7.json	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	105
5	7	http://file-server/SP6.json	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	106
6	8	http://file-server/SP5.json	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	109
7	2	http://file-server/SP4.json	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	110
8	4	http://file-server/SP3.json	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	111
\.


--
-- Data for Name: pool_owner; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_owner (id, addr_id, pool_update_id) FROM stdin;
1	20	12
2	14	13
3	17	14
4	21	15
5	16	16
6	18	17
7	12	18
8	22	19
9	19	20
10	13	21
11	15	22
12	70	23
13	67	24
\.


--
-- Data for Name: pool_relay; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_relay (id, update_id, ipv4, ipv6, dns_name, dns_srv_name, port) FROM stdin;
1	12	127.0.0.1	\N	\N	\N	3009
2	13	127.0.0.1	\N	\N	\N	3001
3	14	127.0.0.1	\N	\N	\N	30011
4	15	127.0.0.1	\N	\N	\N	30010
5	16	127.0.0.1	\N	\N	\N	3007
6	17	127.0.0.1	\N	\N	\N	3006
7	18	127.0.0.1	\N	\N	\N	3008
8	19	127.0.0.1	\N	\N	\N	3002
9	20	127.0.0.1	\N	\N	\N	3005
10	21	127.0.0.1	\N	\N	\N	3004
11	22	127.0.0.1	\N	\N	\N	3003
12	23	127.0.0.1	\N	\N	\N	6000
13	24	127.0.0.2	\N	\N	\N	6000
\.


--
-- Data for Name: pool_retire; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retire (id, hash_id, cert_index, announced_tx_id, retiring_epoch) FROM stdin;
1	10	0	116	5
2	6	0	117	18
3	9	0	118	18
4	1	0	119	5
\.


--
-- Data for Name: pool_update; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_update (id, hash_id, cert_index, vrf_key_hash, pledge, active_epoch_no, meta_id, margin, fixed_cost, registered_tx_id, reward_addr_id) FROM stdin;
1	1	0	\\x85b988cbd400c9f84b744d287327c4d36f3ec8ad12461382139b8b9540578744	0	2	\N	0	0	34	12
2	2	1	\\xd12ac77924a0fab8b10eb0ea260556ada88e0850e51d4b48eee415bc817c1df6	0	2	\N	0	0	34	13
3	3	2	\\x567da93ad3ed04a28e559878cf2e72932366efe53bce54b0044f847bb4d4791a	0	2	\N	0	0	34	14
4	4	3	\\x2882c102412d6fac04ce192e36b70718a5723ab406ea0967e3b450fac7f2c349	0	2	\N	0	0	34	15
5	5	4	\\x2156437e9145b84062b9c7629c08996a7fcb3ddf5bee19000c8f3170de96d9b3	0	2	\N	0	0	34	16
6	6	5	\\xdde7f6f4dc1c531b45eb1632293111717e4629b0f35d9eb7766b673d4671db4c	0	2	\N	0	0	34	17
7	7	6	\\xb8debecc4521620cfed5179cb7aa16f4ee1e62d9c5e20088d3a61e51d4968857	0	2	\N	0	0	34	18
8	8	7	\\x1b28634be5fe444e977d64aa59bed0e758e84f0e828c96bdb2d8121896c19d28	0	2	\N	0	0	34	19
9	9	8	\\x523d3c8a85b931cd1a7bf6a295278dac3cba40da49b3ba7aa310cb0ee5162905	0	2	\N	0	0	34	20
10	10	9	\\x6c1619c9266fa7b19c1d6c6e6b839b6a369985e38b374687ef6d75086bfe3408	0	2	\N	0	0	34	21
11	11	10	\\xdc41cb1efeed74ceefd31d5f522b01741655490e9b025145def1164661c7a32d	0	2	\N	0	0	34	22
12	9	0	\\x523d3c8a85b931cd1a7bf6a295278dac3cba40da49b3ba7aa310cb0ee5162905	500000000	3	\N	0.15	390000000	101	20
13	3	0	\\x567da93ad3ed04a28e559878cf2e72932366efe53bce54b0044f847bb4d4791a	400000000	3	1	0.15	390000000	102	14
14	6	0	\\xdde7f6f4dc1c531b45eb1632293111717e4629b0f35d9eb7766b673d4671db4c	400000000	3	2	0.15	390000000	103	17
15	10	0	\\x6c1619c9266fa7b19c1d6c6e6b839b6a369985e38b374687ef6d75086bfe3408	400000000	3	3	0.15	410000000	104	21
16	5	0	\\x2156437e9145b84062b9c7629c08996a7fcb3ddf5bee19000c8f3170de96d9b3	410000000	3	4	0.15	390000000	105	16
17	7	0	\\xb8debecc4521620cfed5179cb7aa16f4ee1e62d9c5e20088d3a61e51d4968857	410000000	3	5	0.15	400000000	106	18
18	1	0	\\x85b988cbd400c9f84b744d287327c4d36f3ec8ad12461382139b8b9540578744	500000000	3	\N	0.15	380000000	107	12
19	11	0	\\xdc41cb1efeed74ceefd31d5f522b01741655490e9b025145def1164661c7a32d	500000000	3	\N	0.15	390000000	108	22
20	8	0	\\x1b28634be5fe444e977d64aa59bed0e758e84f0e828c96bdb2d8121896c19d28	410000000	3	6	0.15	390000000	109	19
21	2	0	\\xd12ac77924a0fab8b10eb0ea260556ada88e0850e51d4b48eee415bc817c1df6	420000000	3	7	0.15	370000000	110	13
22	4	0	\\x2882c102412d6fac04ce192e36b70718a5723ab406ea0967e3b450fac7f2c349	600000000	3	8	0.15	390000000	111	15
23	12	0	\\x2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	500000000000000	13	\N	0.2	1000	381	70
24	13	0	\\x641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	50000000	13	\N	0.2	1000	384	67
\.


--
-- Data for Name: pot_transfer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pot_transfer (id, cert_index, treasury, reserves, tx_id) FROM stdin;
\.


--
-- Data for Name: redeemer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.redeemer (id, tx_id, unit_mem, unit_steps, fee, purpose, index, script_hash, redeemer_data_id) FROM stdin;
1	121	1700	476468	133	spend	0	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	1
2	128	656230	203682571	52550	spend	0	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	2
\.


--
-- Data for Name: redeemer_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.redeemer_data (id, hash, tx_id, value, bytes) FROM stdin;
1	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	121	{"int": 12}	\\x0c
2	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	128	{"int": 42}	\\x182a
\.


--
-- Data for Name: reference_tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reference_tx_in (id, tx_in_id, tx_out_id, tx_out_index) FROM stdin;
1	128	122	0
\.


--
-- Data for Name: reserve; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reserve (id, addr_id, cert_index, amount, tx_id) FROM stdin;
\.


--
-- Data for Name: reserved_pool_ticker; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reserved_pool_ticker (id, name, pool_hash) FROM stdin;
\.


--
-- Data for Name: reverse_index; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reverse_index (id, block_id, min_ids) FROM stdin;
1	3	::
2	4	1:34:
3	5	::
4	6	::
5	7	::
6	8	::
7	9	::
8	10	::
9	11	::
10	12	::
11	13	::
12	14	::
13	15	::
14	16	::
15	17	::
16	18	::
17	19	::
18	20	12:56:
19	21	::
20	22	::
21	23	::
22	24	::
23	25	::
24	26	::
25	27	::
26	28	23:67:
27	29	34:89:
28	30	::
29	31	::
30	32	45:100:
31	33	::
32	34	56:111:
33	35	67:122:
34	36	::
35	37	78:133:
36	38	82:137:
37	39	86:141:
38	40	87:143:
39	41	::
40	42	::
41	43	88:144:
42	44	89:146:
43	45	90:148:
44	46	::
45	47	91:150:
46	48	92:152:
47	49	::
48	50	93:154:
49	51	94:156:
50	52	96:157:1
51	53	97:159:
52	54	98:165:5
53	55	99:167:8
54	56	::
55	57	::
56	58	::
57	59	::
58	60	::
59	61	::
60	62	::
61	63	::
62	64	::
63	65	::
64	66	::
65	67	::
66	68	::
67	69	::
68	70	::
69	71	::
70	72	::
71	73	::
72	74	::
73	75	::
74	76	::
75	77	::
76	78	::
77	79	::
78	80	::
79	81	::
80	82	::
81	83	::
82	84	::
83	85	::
84	86	::
85	87	::
86	88	::
87	89	::
88	90	::
89	91	::
90	92	::
91	93	::
92	94	::
93	95	::
94	96	::
95	97	::
96	98	::
97	99	::
98	100	::
99	101	::
100	102	::
101	103	::
102	104	::
103	105	::
104	106	::
105	107	::
106	108	::
107	109	::
108	110	::
109	111	::
110	112	::
111	113	::
112	114	::
113	115	::
114	116	::
115	117	::
116	118	::
117	119	::
118	120	::
119	121	::
120	122	::
121	123	::
122	124	::
123	125	::
124	126	::
127	129	::
128	130	::
129	131	::
130	132	::
131	133	::
132	134	::
133	135	::
134	136	::
135	137	::
136	138	::
137	139	::
138	140	::
139	141	::
140	142	::
141	143	::
142	144	::
143	145	::
144	146	::
145	147	::
146	148	::
147	149	::
148	150	::
149	151	::
150	152	::
151	153	::
152	154	::
153	155	::
154	156	::
155	157	::
156	158	::
157	159	::
158	160	::
159	161	::
160	162	::
161	163	::
162	164	::
163	165	::
164	166	::
165	167	::
166	168	::
167	169	::
168	170	::
169	171	::
170	172	::
171	173	::
172	174	::
173	175	::
174	176	::
175	177	::
176	178	::
177	179	::
178	180	::
179	181	::
180	182	::
181	183	::
182	184	::
183	185	::
184	186	::
185	187	::
186	188	::
187	189	::
188	190	::
189	191	::
190	192	::
191	193	::
192	194	::
193	195	::
194	196	::
195	197	::
196	198	::
197	199	::
198	200	::
199	201	::
200	202	::
201	203	::
202	204	::
203	205	::
204	206	::
205	207	::
206	208	::
207	209	::
208	210	::
209	211	::
210	212	::
211	213	::
212	214	::
213	215	::
214	216	::
215	217	::
216	218	::
217	219	::
218	220	::
219	221	::
220	222	::
221	223	::
222	224	::
223	225	::
225	227	::
226	228	::
227	229	::
228	230	::
229	231	::
230	232	::
231	233	100:169:
232	234	101:171:9
233	235	::
234	236	::
235	237	::
236	238	102:173:12
237	239	::
238	240	::
239	241	::
240	242	103:175:13
241	243	::
242	244	::
243	245	::
244	246	105:177:18
245	247	::
246	248	::
247	249	::
248	250	106:178:19
249	251	::
250	252	::
251	253	::
252	254	109:180:25
253	255	::
254	256	::
255	257	::
256	258	110:182:
257	259	::
258	260	::
259	261	::
260	262	111:183:
261	263	::
262	264	::
263	265	::
264	266	112:184:30
265	267	::
266	268	::
267	269	::
268	270	113:186:31
269	271	::
270	272	::
271	273	::
272	274	114:188:
273	275	::
274	276	::
275	277	::
276	278	116:189:32
277	279	::
278	280	::
279	281	::
280	282	117:191:
281	283	::
282	284	::
283	285	::
284	286	118:192:33
285	287	::
286	288	::
287	289	::
288	290	120:194:34
289	291	::
290	292	::
291	293	::
292	294	121:195:
293	295	::
295	297	::
296	298	::
297	299	::
298	300	122:196:35
299	301	::
300	302	::
301	303	::
302	304	124:198:38
303	305	::
304	306	::
306	308	::
307	309	126:200:40
308	310	::
309	311	::
310	312	::
311	313	128:202:43
312	314	::
313	315	::
314	316	::
315	317	129:204:46
316	318	::
317	319	::
318	320	::
319	321	131:206:
320	322	::
321	323	::
322	324	::
323	325	::
324	326	::
325	327	::
326	328	::
327	329	135:207:48
328	330	::
329	331	::
330	332	::
331	333	136:209:
332	334	::
333	335	::
334	336	::
335	337	::
336	338	137:210:49
337	339	::
338	340	::
339	341	::
340	342	139:212:
341	343	::
342	344	::
343	345	::
344	346	::
345	347	140:213:
346	348	142:333:
347	349	202:335:
348	350	::
349	351	::
350	352	::
351	353	::
352	354	::
353	355	::
354	356	265:339:
355	357	::
356	358	266:341:
357	359	267:343:
358	360	268:345:
359	361	::
360	362	::
361	363	::
362	364	::
363	365	::
364	366	::
365	367	::
366	368	269:347:
367	369	270:349:
368	370	271:351:
369	371	::
370	372	272:352:
371	373	::
372	374	::
373	375	::
374	376	273:354:
375	377	::
376	378	::
377	379	::
378	380	274:389:
379	381	::
380	382	::
381	383	::
382	384	309:398:
383	385	::
384	386	::
385	387	::
386	388	::
387	389	310:399:
388	390	311:401:
389	391	::
390	392	::
391	393	::
392	394	::
393	395	::
395	397	::
396	398	::
397	399	312:402:
398	400	::
399	401	::
400	402	::
401	403	::
402	404	::
403	405	::
404	406	::
405	407	::
406	408	::
407	409	::
408	410	::
409	411	::
410	412	::
411	413	::
412	414	::
413	415	::
414	416	::
415	417	::
416	418	::
417	419	::
418	420	::
419	421	::
420	422	::
421	423	::
422	424	::
423	425	::
424	426	::
425	427	::
426	428	::
427	429	::
428	430	::
429	431	::
430	432	::
431	433	::
432	434	::
433	435	::
434	436	::
435	437	::
436	438	::
437	439	::
438	440	::
439	441	::
440	442	::
441	443	::
442	444	::
444	446	::
445	447	::
446	448	::
447	449	::
448	450	::
449	451	::
450	452	::
451	453	::
452	454	::
453	455	::
454	456	::
455	457	::
456	458	::
457	459	::
458	460	::
459	461	::
460	462	::
461	463	::
462	464	::
463	465	::
464	466	::
465	467	::
466	468	::
467	469	::
468	470	::
469	471	::
470	472	::
471	473	::
472	474	::
473	475	::
474	476	::
475	477	::
476	478	::
477	479	::
478	480	::
479	481	::
480	482	::
481	483	::
482	484	::
483	485	::
484	486	::
485	487	::
487	489	::
488	490	::
489	491	::
490	492	::
491	493	::
492	494	::
493	495	::
494	496	::
495	497	::
496	498	::
497	499	::
498	500	::
499	501	::
500	502	::
501	503	::
502	504	::
504	506	::
505	507	::
506	508	::
507	509	::
508	510	::
509	511	::
510	512	::
511	513	::
512	514	::
513	515	::
514	516	::
515	517	::
516	518	::
517	519	::
518	520	::
519	521	::
520	522	::
521	523	::
522	524	::
523	525	::
524	526	::
525	527	::
526	528	::
527	529	::
528	530	::
529	531	::
530	532	::
531	533	::
532	534	::
533	535	::
534	536	::
535	537	::
536	538	::
537	539	::
538	540	::
539	541	314:403:
540	542	441:547:
541	543	::
542	544	::
543	545	::
544	546	::
545	547	::
546	548	::
547	549	::
548	550	::
549	551	::
550	552	::
551	553	::
552	554	::
553	555	::
554	556	::
555	557	::
556	558	::
557	559	::
558	560	::
559	561	::
560	562	::
561	563	::
562	564	::
563	565	::
564	566	::
565	567	::
566	568	::
567	569	::
568	570	::
569	571	::
570	572	::
571	573	::
572	574	::
573	575	::
574	576	::
575	577	::
576	578	::
577	579	::
579	581	::
580	582	::
581	583	::
582	584	::
583	585	::
584	586	::
585	587	::
586	588	::
587	589	::
588	590	::
589	591	::
590	592	::
591	593	::
592	594	::
593	595	::
594	596	::
595	597	::
596	598	::
597	599	::
598	600	::
599	601	::
600	602	::
601	603	::
602	604	::
603	605	::
604	606	::
605	607	::
606	608	::
607	609	::
608	610	::
609	611	::
610	612	::
611	613	::
612	614	::
613	615	::
614	616	::
615	617	::
616	618	::
617	619	::
618	620	::
619	621	::
620	622	::
621	623	::
622	624	::
624	626	::
625	627	::
626	628	::
628	630	::
629	631	::
630	632	::
631	633	::
633	635	::
634	636	::
635	637	::
636	638	::
637	639	::
638	640	::
639	641	::
640	642	::
641	643	::
642	644	::
643	645	::
644	646	::
645	647	::
646	648	::
647	649	::
648	650	::
649	651	::
650	652	::
651	653	::
652	654	::
653	655	::
654	656	::
655	657	::
656	658	::
657	659	::
658	660	::
659	661	::
660	662	::
661	663	::
662	664	::
663	665	::
664	666	::
665	667	::
666	668	::
667	669	::
668	670	::
669	671	::
670	672	::
671	673	::
672	674	::
673	675	::
674	676	::
675	677	::
676	678	::
677	679	::
678	680	::
679	681	::
680	682	::
681	683	::
682	684	::
683	685	::
685	687	::
686	688	::
687	689	::
688	690	::
689	691	::
690	692	::
691	693	::
692	694	::
693	695	::
694	696	::
695	697	::
696	698	::
697	699	::
698	700	::
699	701	::
700	702	::
701	703	::
702	704	::
703	705	::
704	706	::
705	707	::
706	708	::
707	709	::
708	710	::
709	711	::
710	712	::
711	713	::
712	714	::
713	715	::
714	716	::
715	717	::
716	718	::
717	719	::
718	720	::
719	721	::
720	722	::
721	723	::
722	724	::
723	725	::
724	726	::
725	727	::
726	728	::
727	729	::
728	730	::
729	731	496:603:
730	732	::
731	733	::
732	734	::
733	735	497:605:
734	736	::
735	737	::
736	738	::
737	739	::
738	740	::
739	741	::
740	742	::
741	743	::
742	744	::
743	745	::
744	746	::
745	747	::
746	748	::
747	749	::
748	750	::
749	751	::
750	752	::
751	753	::
752	754	::
753	755	::
754	756	::
755	757	::
756	758	::
757	759	::
758	760	::
759	761	::
760	762	::
761	763	::
762	764	::
763	765	::
764	766	::
765	767	::
766	768	::
767	769	::
768	770	::
769	771	::
770	772	::
771	773	::
772	774	::
773	775	::
774	776	::
775	777	::
776	778	::
777	779	::
778	780	::
779	781	::
780	782	::
781	783	::
782	784	::
783	785	::
784	786	::
785	787	::
786	788	::
787	789	::
788	790	::
789	791	::
790	792	::
791	793	::
792	794	::
793	795	::
794	796	::
795	797	::
796	798	::
797	799	::
798	800	::
799	801	::
800	802	::
801	803	::
802	804	::
803	805	::
804	806	::
805	807	::
806	808	::
807	809	::
808	810	::
809	811	::
810	812	::
811	813	::
812	814	::
813	815	::
814	816	::
815	817	::
816	818	::
817	819	::
818	820	::
819	821	::
820	822	::
821	823	::
822	824	::
823	825	::
824	826	::
825	827	::
826	828	::
827	829	::
828	830	::
829	831	::
830	832	::
831	833	::
832	834	::
833	835	::
834	836	::
835	837	::
836	838	::
837	839	::
838	840	::
839	841	::
840	842	::
841	843	::
842	844	::
843	845	::
844	846	::
846	848	::
847	849	::
848	850	::
849	851	::
850	852	::
851	853	::
852	854	::
853	855	::
854	856	::
855	857	::
856	858	::
857	859	::
858	860	::
859	861	::
860	862	::
861	863	::
862	864	::
863	865	::
864	866	::
865	867	::
866	868	::
867	869	::
868	870	::
869	871	::
870	872	::
871	873	::
872	874	::
873	875	::
874	876	::
875	877	::
876	878	::
877	879	::
878	880	::
879	881	::
880	882	::
881	883	::
882	884	::
883	885	::
884	886	::
885	887	::
886	888	::
887	889	::
888	890	::
889	891	::
890	892	::
891	893	::
892	894	::
893	895	::
894	896	::
895	897	::
896	898	::
897	899	::
898	900	::
899	901	::
900	902	::
901	903	::
902	904	::
903	905	::
904	906	::
905	907	::
906	908	::
907	909	::
908	910	::
909	911	::
910	912	::
911	913	521:619:
912	914	::
913	915	::
914	916	::
915	917	::
916	918	::
917	919	::
918	920	::
919	921	::
920	922	::
921	923	::
922	924	::
923	925	::
924	926	::
925	927	::
926	928	::
927	929	::
928	930	::
929	931	::
930	932	::
931	933	::
932	934	::
933	935	::
934	936	::
935	937	::
936	938	::
937	939	::
938	940	::
939	941	::
940	942	::
941	943	::
942	944	::
943	945	::
944	946	::
945	947	::
946	948	::
947	949	::
948	950	::
949	951	::
950	952	::
951	953	::
952	954	::
953	955	::
954	956	::
955	957	::
956	958	::
957	959	::
958	960	::
959	961	::
960	962	::
961	963	::
962	964	::
963	965	::
964	966	::
965	967	::
966	968	::
967	969	::
968	970	::
969	971	::
970	972	::
971	973	::
972	974	::
973	975	::
974	976	::
975	977	::
976	978	::
977	979	::
978	980	::
979	981	::
980	982	::
981	983	::
982	984	::
983	985	::
984	986	::
985	987	::
986	988	::
987	989	::
988	990	::
989	991	::
990	992	::
991	993	::
992	994	::
994	996	::
995	997	::
996	998	::
997	999	::
998	1000	::
999	1001	::
1000	1002	::
1001	1003	::
1002	1004	::
1003	1005	::
1004	1006	::
1005	1007	::
1006	1008	::
1007	1009	::
1008	1010	::
1009	1011	::
1010	1012	::
1011	1013	::
1012	1014	::
1013	1015	::
1014	1016	::
1015	1017	::
1016	1018	::
1017	1019	::
1018	1020	::
1019	1021	::
1020	1022	::
1021	1023	::
1022	1024	::
1023	1025	::
1024	1026	::
1025	1027	::
1026	1028	::
1027	1029	::
1028	1030	::
1029	1031	::
1030	1032	::
1031	1033	::
1032	1034	::
1033	1035	::
1034	1036	::
1035	1037	::
1036	1038	::
1037	1039	::
1038	1040	::
1039	1041	::
1040	1042	::
1041	1043	::
1042	1044	::
1043	1045	::
1044	1046	::
1045	1047	::
1046	1048	::
1047	1049	::
1048	1050	::
1049	1051	::
1050	1052	::
1051	1053	::
1052	1054	::
1054	1056	::
1055	1057	::
1056	1058	::
1057	1059	::
1058	1060	::
1059	1061	::
1060	1062	::
1061	1063	::
1062	1064	::
1063	1065	::
1064	1066	::
1065	1067	::
1066	1068	::
1067	1069	::
1068	1070	::
1069	1071	::
1070	1072	::
1071	1073	::
1072	1074	::
1074	1076	::
1075	1077	::
1076	1078	::
1077	1079	::
1078	1080	::
1079	1081	::
1080	1082	::
1081	1083	::
1082	1084	::
1083	1085	::
1084	1086	::
1085	1087	::
1086	1088	::
1087	1089	::
1088	1090	::
1089	1091	::
1090	1092	::
1091	1093	::
1092	1094	::
1093	1095	::
1094	1096	::
1095	1097	::
1096	1098	::
1097	1099	::
1098	1100	::
1099	1101	::
1100	1102	::
1101	1103	::
1102	1104	::
1103	1105	::
1104	1106	::
1105	1107	::
1106	1108	::
1107	1109	::
1108	1110	::
1109	1111	::
1110	1112	::
1111	1113	::
1112	1114	::
1113	1115	::
1114	1116	::
1115	1117	::
1116	1118	::
1117	1119	::
1118	1120	::
1120	1122	::
1121	1123	::
1122	1124	::
1123	1125	::
1124	1126	::
1125	1127	::
1126	1128	::
1127	1129	::
1128	1130	::
1129	1131	::
1130	1132	::
1131	1133	::
1132	1134	::
1133	1135	::
1134	1136	::
1135	1137	::
1136	1138	::
1137	1139	::
1138	1140	674:819:
1139	1141	::
1140	1142	::
1141	1143	::
1142	1144	::
1143	1145	::
1144	1146	::
1145	1147	675:821:
1146	1148	::
1147	1149	::
1148	1150	::
1149	1151	676:823:
1150	1152	::
1151	1153	::
1152	1154	::
1153	1155	677:825:
1154	1156	::
1156	1158	::
1157	1159	::
1158	1160	679:827:50
1159	1161	::
1160	1162	::
1161	1163	::
1162	1164	682:829:55
1163	1165	::
1164	1166	::
1165	1167	::
1166	1168	684:831:58
1167	1169	::
1168	1170	::
1169	1171	::
1170	1172	::
1171	1173	686:833:61
1172	1174	::
1173	1175	::
1174	1176	::
1175	1177	687:835:64
1176	1178	::
1177	1179	::
1178	1180	::
1179	1181	688:837:65
1180	1182	::
1181	1183	::
1182	1184	::
1183	1185	691:839:66
1184	1186	::
1185	1187	::
1186	1188	::
\.


--
-- Data for Name: reward; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward (addr_id, type, amount, spendable_epoch, pool_id) FROM stdin;
5	member	4366777324193	3	1
2	member	6986843718710	3	9
7	member	7860199183549	3	4
10	member	6986843718710	3	3
3	member	10480265578065	3	7
9	member	7860199183549	3	6
11	member	9606910113226	3	5
6	member	6113488253871	3	2
4	member	9606910113226	3	11
1	member	7860199183549	3	10
8	member	10480265578065	3	8
18	leader	0	3	7
12	leader	0	3	1
14	leader	0	3	3
20	leader	0	3	9
13	leader	0	3	2
16	leader	0	3	5
21	leader	0	3	10
17	leader	0	3	6
15	leader	0	3	4
22	leader	0	3	11
19	leader	0	3	8
5	member	10170350889596	4	1
2	member	5085175444798	4	9
18	member	654233	4	7
12	member	392539	4	1
7	member	6538082882668	4	4
42	member	327114775	4	9
41	member	654229551	4	1
14	member	280385	4	3
10	member	4358721585337	4	3
20	member	196269	4	9
3	member	10170350365788	4	7
44	member	140192038	4	6
43	member	560768155	4	10
13	member	467309	4	2
37	member	467306961	4	2
9	member	2179360792767	4	6
16	member	747694	4	5
39	member	654229745	4	7
21	member	560771	4	10
17	member	140192	4	6
34	member	280384176	4	3
38	member	700960441	4	8
35	member	607499037	4	11
11	member	11623257560901	4	5
15	member	168231	4	4
6	member	7264535975562	4	2
4	member	9443896525240	4	11
1	member	8717443171071	4	10
8	member	10896803963344	4	8
40	member	747691138	4	5
22	member	729002	4	11
36	member	420576297	4	4
19	member	700963	4	8
18	leader	0	4	7
12	leader	0	4	1
14	leader	0	4	3
20	leader	0	4	9
13	leader	0	4	2
16	leader	0	4	5
21	leader	0	4	10
17	leader	0	4	6
15	leader	0	4	4
22	leader	0	4	11
19	leader	0	4	8
10	member	7473287891193	5	3
3	member	10190959162595	5	7
44	member	349619791	5	6
43	member	305913558	5	10
37	member	305915853	5	2
9	member	5435028063300	5	6
39	member	655555451	5	7
34	member	480735378	5	3
38	member	305914760	5	8
35	member	349619907	5	11
11	member	8152707833906	5	5
6	member	4755625119244	5	2
4	member	5435027923204	5	11
1	member	4755591121650	5	10
8	member	4755608120339	5	8
40	member	524440533	5	5
18	leader	1798921015606	5	7
12	leader	0	5	1
14	leader	1319290911439	5	3
20	leader	0	5	9
13	leader	839652307273	5	2
16	leader	1439196312481	5	5
21	leader	839686307290	5	10
17	leader	959574708335	5	6
15	leader	0	5	4
22	leader	959574765897	5	11
19	leader	839669307271	5	8
10	member	5552864987261	6	3
3	member	11794906627035	6	7
44	member	178388847	6	6
43	member	579810590	6	10
37	member	312337879	6	2
9	member	2775955126883	6	6
39	member	757711183	6	7
34	member	356879233	6	3
38	member	445704013	6	8
35	member	133726305	6	11
11	member	6244911531702	6	5
6	member	4859277898551	6	2
4	member	2081416137953	6	11
1	member	9022582990488	6	10
8	member	6938048877299	6	8
40	member	401221517	6	5
18	leader	2081988715821	6	7
12	leader	0	6	1
14	leader	980370749241	6	3
20	leader	0	6	9
13	leader	857945115063	6	2
16	leader	1102504487301	6	5
21	leader	1592733529383	6	10
17	leader	490296124411	6	6
15	leader	0	6	4
22	leader	367722517777	6	11
19	leader	1224830744592	6	8
10	member	4874658521176	7	3
3	member	2086447033540	7	7
44	member	581877282	7	6
43	member	402492672	7	10
37	member	626512245	7	2
9	member	9054740762167	7	6
39	member	134034722	7	7
34	member	313291476	7	3
38	member	223385513	7	8
35	member	446975685	7	11
11	member	5556888382739	7	5
81	member	705282	7	5
6	member	9747120276627	7	2
4	member	6957053146254	7	11
1	member	6263285786413	7	10
8	member	3477322707252	7	8
40	member	357018235	7	5
68	member	3564090215	7	5
18	leader	368620346205	7	7
12	leader	0	7	1
14	leader	860679511989	7	3
20	leader	0	7	9
13	leader	1720561346878	7	2
16	leader	981709866459	7	5
21	leader	1105767228656	7	10
17	leader	1598388797409	7	6
15	leader	0	7	4
22	leader	1228184770193	7	11
19	leader	614074867413	7	8
10	member	4791199428796	8	3
3	member	5466589873104	8	7
44	member	396075146	8	6
43	member	307830807	8	10
37	member	660084136	8	2
9	member	6163421994557	8	6
39	member	351177926	8	7
34	member	307927874	8	3
38	member	219664875	8	8
35	member	351579305	8	11
11	member	8191851448740	8	5
81	member	1038627	8	5
6	member	10269418401888	8	2
4	member	5472230115843	8	11
1	member	4790226662186	8	10
8	member	3419402720272	8	8
40	member	526309675	8	5
68	member	5248618850	8	5
18	leader	966637289790	8	7
12	leader	0	8	1
14	leader	846904909655	8	3
20	leader	0	8	9
13	leader	1814039657610	8	2
16	leader	1448808502460	8	5
21	leader	846405944097	8	10
17	leader	1089016463351	8	6
15	leader	0	8	4
22	leader	966932498127	8	11
19	leader	604286152367	8	8
10	member	6612630949663	9	3
3	member	7693650881958	9	7
44	member	283572072	9	6
37	member	248013154	9	2
9	member	4412734215477	9	6
39	member	494246031	9	7
34	member	424990322	9	3
38	member	282894615	9	8
35	member	318620200	9	11
11	member	5495153343313	9	5
81	member	696161	9	5
6	member	3858524557935	9	2
4	member	4959231183404	9	11
8	member	4403665446627	9	8
40	member	353052345	9	5
68	member	3517983794	9	5
18	leader	1362685567397	9	7
14	leader	1169694861378	9	3
20	leader	0	9	9
13	leader	682318666315	9	2
16	leader	972910992143	9	5
17	leader	780124287263	9	6
15	leader	0	9	4
22	leader	876598027016	9	11
19	leader	778927915110	9	8
10	member	7061640323666	10	3
3	member	4877687786568	10	7
44	member	314247510	10	6
37	member	383868907	10	2
9	member	4890082198582	10	6
39	member	313346403	10	7
34	member	453847919	10	3
38	member	313800543	10	8
35	member	418629798	10	11
11	member	7582844653451	10	5
81	member	960644	10	5
6	member	5972133262020	10	2
4	member	6515851643709	10	11
8	member	4884761090743	10	8
40	member	487182234	10	5
68	member	4854525078	10	5
18	leader	864343495340	10	7
14	leader	1250007686242	10	3
20	leader	0	10	9
13	leader	1057420894555	10	2
16	leader	1343505062460	10	5
17	leader	865649798730	10	6
15	leader	0	10	4
22	leader	1152830111332	10	11
19	leader	864433548074	10	8
10	member	9809400129455	11	3
3	member	5871545497940	11	7
44	member	409751694	11	6
37	member	251826458	11	2
9	member	6376246105106	11	6
39	member	377192584	11	7
34	member	630445000	11	3
38	member	472043876	11	8
35	member	188958654	11	11
11	member	2934218789430	11	5
81	member	371726	11	5
6	member	3917850958699	11	2
4	member	2941086769377	11	11
8	member	7348048330160	11	8
40	member	188517546	11	5
89	member	2352469859	11	8
68	member	940225811	11	5
18	leader	1041228012516	11	7
14	leader	1737496379054	11	3
20	leader	0	11	9
13	leader	694885824288	11	2
16	leader	520587113865	11	5
17	leader	1129658460151	11	6
15	leader	0	11	4
22	leader	520999131966	11	11
19	leader	1301235901342	11	8
\.


--
-- Data for Name: schema_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_version (id, stage_one, stage_two, stage_three) FROM stdin;
1	11	33	6
\.


--
-- Data for Name: script; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.script (id, tx_id, hash, type, json, bytes, serialised_size) FROM stdin;
1	121	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	plutusV1	\N	\\x4d01000033222220051200120011	14
2	123	\\x477e52b3116b62fe8cd34a312615f5fcd678c94e1d6cdb86c1a3964c	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "e09d36c79dec9bd1b3d9e152247701cd0bb860b5ebfd1de8abb6735a"}, {"type": "sig", "keyHash": "a687dcc24e00dd3caafbeb5e68f97ca8ef269cb6fe971345eb951756"}, {"type": "sig", "keyHash": "0bd1d702b2e6188fe0857a6dc7ffb0675229bab58c86638ffa87ed6d"}]}	\N	\N
3	124	\\x120125c6dea2049988eb0dc8ddcc4c56dd48628d45206a2d0bc7e55b	timelock	{"type": "all", "scripts": [{"slot": 1000, "type": "after"}, {"type": "sig", "keyHash": "966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37"}]}	\N	\N
4	126	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	plutusV2	\N	\\x5908920100003233223232323232332232323232323232323232332232323232322223232533532323232325335001101d13357389211e77726f6e67207573616765206f66207265666572656e636520696e7075740001c3232533500221533500221333573466e1c00800408007c407854cd4004840784078d40900114cd4c8d400488888888888802d40044c08526221533500115333533550222350012222002350022200115024213355023320015021001232153353235001222222222222300e00250052133550253200150233355025200100115026320013550272253350011502722135002225335333573466e3c00801c0940904d40b00044c01800c884c09526135001220023333573466e1cd55cea80224000466442466002006004646464646464646464646464646666ae68cdc39aab9d500c480008cccccccccccc88888888888848cccccccccccc00403403002c02802402001c01801401000c008cd405c060d5d0a80619a80b80c1aba1500b33501701935742a014666aa036eb94068d5d0a804999aa80dbae501a35742a01066a02e0446ae85401cccd5406c08dd69aba150063232323333573466e1cd55cea801240004664424660020060046464646666ae68cdc39aab9d5002480008cc8848cc00400c008cd40b5d69aba15002302e357426ae8940088c98c80c0cd5ce01901a01709aab9e5001137540026ae854008c8c8c8cccd5cd19b8735573aa004900011991091980080180119a816bad35742a004605c6ae84d5d1280111931901819ab9c03203402e135573ca00226ea8004d5d09aba2500223263202c33573805c06005426aae7940044dd50009aba1500533501775c6ae854010ccd5406c07c8004d5d0a801999aa80dbae200135742a00460426ae84d5d1280111931901419ab9c02a02c026135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d55cf280089baa00135742a00860226ae84d5d1280211931900d19ab9c01c01e018375a00a6666ae68cdc39aab9d375400a9000100e11931900c19ab9c01a01c016101b132632017335738921035054350001b135573ca00226ea800448c88c008dd6000990009aa80d911999aab9f0012500a233500930043574200460066ae880080608c8c8cccd5cd19b8735573aa004900011991091980080180118061aba150023005357426ae8940088c98c8050cd5ce00b00c00909aab9e5001137540024646464646666ae68cdc39aab9d5004480008cccc888848cccc00401401000c008c8c8c8cccd5cd19b8735573aa0049000119910919800801801180a9aba1500233500f014357426ae8940088c98c8064cd5ce00d80e80b89aab9e5001137540026ae854010ccd54021d728039aba150033232323333573466e1d4005200423212223002004357426aae79400c8cccd5cd19b875002480088c84888c004010dd71aba135573ca00846666ae68cdc3a801a400042444006464c6403666ae7007407c06406005c4d55cea80089baa00135742a00466a016eb8d5d09aba2500223263201533573802e03202626ae8940044d5d1280089aab9e500113754002266aa002eb9d6889119118011bab00132001355018223233335573e0044a010466a00e66442466002006004600c6aae754008c014d55cf280118021aba200301613574200222440042442446600200800624464646666ae68cdc3a800a400046a02e600a6ae84d55cf280191999ab9a3370ea00490011280b91931900819ab9c01201400e00d135573aa00226ea80048c8c8cccd5cd19b875001480188c848888c010014c01cd5d09aab9e500323333573466e1d400920042321222230020053009357426aae7940108cccd5cd19b875003480088c848888c004014c01cd5d09aab9e500523333573466e1d40112000232122223003005375c6ae84d55cf280311931900819ab9c01201400e00d00c00b135573aa00226ea80048c8c8cccd5cd19b8735573aa004900011991091980080180118029aba15002375a6ae84d5d1280111931900619ab9c00e01000a135573ca00226ea80048c8cccd5cd19b8735573aa002900011bae357426aae7940088c98c8028cd5ce00600700409baa001232323232323333573466e1d4005200c21222222200323333573466e1d4009200a21222222200423333573466e1d400d2008233221222222233001009008375c6ae854014dd69aba135744a00a46666ae68cdc3a8022400c4664424444444660040120106eb8d5d0a8039bae357426ae89401c8cccd5cd19b875005480108cc8848888888cc018024020c030d5d0a8049bae357426ae8940248cccd5cd19b875006480088c848888888c01c020c034d5d09aab9e500b23333573466e1d401d2000232122222223005008300e357426aae7940308c98c804ccd5ce00a80b80880800780700680600589aab9d5004135573ca00626aae7940084d55cf280089baa0012323232323333573466e1d400520022333222122333001005004003375a6ae854010dd69aba15003375a6ae84d5d1280191999ab9a3370ea0049000119091180100198041aba135573ca00c464c6401866ae700380400280244d55cea80189aba25001135573ca00226ea80048c8c8cccd5cd19b875001480088c8488c00400cdd71aba135573ca00646666ae68cdc3a8012400046424460040066eb8d5d09aab9e500423263200933573801601a00e00c26aae7540044dd500089119191999ab9a3370ea00290021091100091999ab9a3370ea00490011190911180180218031aba135573ca00846666ae68cdc3a801a400042444004464c6401466ae7003003802001c0184d55cea80089baa0012323333573466e1d40052002200623333573466e1d40092000200623263200633573801001400800626aae74dd5000a4c244004244002921035054310012333333357480024a00c4a00c4a00c46a00e6eb400894018008480044488c0080049400848488c00800c4488004448c8c00400488cc00cc0080080041	2197
5	129	\\x658bb6cd932d93cdadc82af7bd677454d7eec473a333254ae2a520fc	timelock	{"type": "sig", "keyHash": "cb45c40f5ecff33e1f60e17d761acf3a6557c7d50f2e07de7c3c8a69"}	\N	\N
6	131	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	timelock	{"type": "sig", "keyHash": "5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967"}	\N	\N
7	150	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}]}	\N	\N
8	156	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}, {"type": "sig", "keyHash": "3178bf14adf78294ac2d03d60b9edfb7323d3d719e98b4b0b3ca34cd"}]}	\N	\N
9	167	\\xe0c3297f1738f41feb0329d1a2eef497d133131e4604f0b64c0729f0	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "d514ed4fc583018d8dabd5953a2414272a349760a9481e99a9830b6a"}, {"type": "sig", "keyHash": "2736f5703f6a97878f0b73b060b17f377f640ab27ca4dbaab053771b"}, {"type": "sig", "keyHash": "09bb0e720ee9d09ac77b5c8a4595ad55cb3811fe78c171a6e2264f54"}]}	\N	\N
10	169	\\x9c7cb98b7706e342046cf710a2f1b3f1d58cefde177fa6a78ce22c2d	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "b78ee633cec45679e6ee1f10ed3c4bbff2c0857255b0c6a7d8facf81"}, {"type": "sig", "keyHash": "49cfed0f683f0970428d379e10d5b5009d003f8c9bed32a66b457341"}, {"type": "sig", "keyHash": "41a3abd587384d814d079d636843ceedcde636f5b34e48d2587c7ec1"}]}	\N	\N
\.


--
-- Data for Name: slot_leader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slot_leader (id, hash, pool_hash_id, description) FROM stdin;
1	\\x4db6034949e494dd9f58d4b0a86d76a1d1f9c63f7ec7eb3e63303b0c	\N	Genesis slot leader
2	\\x5368656c6c65792047656e6573697320536c6f744c65616465722048	\N	Shelley Genesis slot leader
16	\\x15bbe95e0a926881dd3a6bac4a39c62bd35fbe6e2db352904bd9d55e	2	Pool-15bbe95e0a926881
12	\\x4532e25b9f4bf6997bea1c9ea509204347d9575935875b7b38995ba5	4	Pool-4532e25b9f4bf699
4	\\x5cd1879df37c8d196d07575bb2620e2b5d4c93bbea5049412febf6a8	6	Pool-5cd1879df37c8d19
5	\\x9d062a9ae2b19c6821c677ebe2d5857f2b18f9f321e348ab7462ed21	9	Pool-9d062a9ae2b19c68
3	\\xd53828e79047ca469f154b2c4531a35b2f8910eb97edad19f6a8d6fe	11	Pool-d53828e79047ca46
7	\\x2f86c2b5a057fdee5faa531e62ed1a5037e2753b88b4970bcf76f36a	3	Pool-2f86c2b5a057fdee
40	\\x5184abbee848085c6810c24cc15283ab7a0430fa692376e2475f1942	5	Pool-5184abbee848085c
6	\\x6f4427e14d792f4df872ae659cadd8e124ba4706078995e793e1c512	7	Pool-6f4427e14d792f4d
21	\\x87ad04cc317b495d3fb91eea91bf60581ac7fdd121cb41a4f0cb2ada	8	Pool-87ad04cc317b495d
13	\\x06bca93c3f987e1f1978f712cd2549e923b1422cd7d8aa191c0411ea	1	Pool-06bca93c3f987e1f
14	\\xcbe612d9d64d2b4f7473da7e2438b1971eced2d13c85f11d38212fb2	10	Pool-cbe612d9d64d2b4f
\.


--
-- Data for Name: stake_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_address (id, hash_raw, view, script_hash) FROM stdin;
5	\\xe009c2e124bbb70a5625cd02cae9b4d79f861842e475fc0c4538643779	stake_test1uqyu9cfyhwms5439e5pv46d5670cvxzzu36lcrz98pjrw7gwxlyht	\N
2	\\xe020b1e71989c215db920e394a409a863f6578cd91ed12ad4ccf43b80d	stake_test1uqstrece38pptkujpcu55sy6sclk27xdj8k39t2veapmsrgx6y5v4	\N
7	\\xe039dd4825f697ea809962849a10506f8a487a50ee183d06a8779ec2c2	stake_test1uqua6jp976t74qyev2zf5yzsd79ys7jsacvr6p4gw70v9ssafjw4c	\N
10	\\xe04f7864d648d3ec6a160019a778d32bd54eaedf7d42d4921f2c379f41	stake_test1up8hsexkfrf7c6skqqv6w7xn9025atkl04pdfysl9sme7sgvyxmn2	\N
3	\\xe069763bca2c96c0eba648ee07c44c2eb0a0cfb746fc6858f79958ce7d	stake_test1up5hvw729jtvp6axfrhq03zv96c2pnahgm7xsk8hn9vvulgu2ak6p	\N
9	\\xe08ca2b6318b06728b1310b2ac24eea5d2fd2feac89b9b3cf122f62c62	stake_test1uzx29d333vr89zcnzze2cf8w5hf06tl2ezdek083ytmzccsjfva8j	\N
11	\\xe0cd29262859a56cb7b19071bd9af63cedd1b585bb7b6f703adaeb3f98	stake_test1urxjjf3gtxjkeda3jpcmmxhk8nkardv9hdak7up6mt4nlxqw8r3z8	\N
6	\\xe0dbd50fa66bfa0d54269212f1715dc9892d243274486fb7c906680c74	stake_test1urda2raxd0aq64pxjgf0zu2aexyj6fpjw3yxld7fqe5qcaqcnmyqp	\N
4	\\xe0dd26cd3e29eca332568e04b49399e7cc59ab3ee5ecbbaddbc2de74f7	stake_test1urwjdnf798k2xvjk3cztfyueulx9n2e7uhkthtwmct08facg4n858	\N
1	\\xe0df75aeaa897d3c45131bc3486550f2077a9b7c1c79e9457e327fc900	stake_test1ur0htt42397nc3gnr0p5se2s7grh4xmur3u7j3t7xflujqqn8sydj	\N
8	\\xe0dfa2242273f3c26c2113f6b1c4724aa7f0614574666f293099fcb93a	stake_test1ur06yfpzw0euymppz0mtr3rjf2nlqc29w3nx72fsn87tjws7ykc2v	\N
34	\\xe0b8192f646eb33b5ed26f27ed570315f8321915aded032459c52f69ac	stake_test1uzupjtmyd6enkhkjdun764crzhuryxg44hksxfzec5hkntqv42qwe	\N
35	\\xe0c454524cec7e26f76cfc1bdeca76904f1ad38f380af46ff4ca88f158	stake_test1urz9g5jva3lzdamvlsdaajnkjp8345u08q90gml5e2y0zkqhxqfu2	\N
36	\\xe0f6849c2fed4afdc01fae40e59b4006fdce9d77d46f1903c33fb1439f	stake_test1urmgf8p0a490msql4eqwtx6qqm7ua8th63h3jq7r87c588cvqzrfc	\N
37	\\xe0845c441bb94717101e31e3b5ac871e99d319b69de7b55ea615496e32	stake_test1uzz9c3qmh9r3wyq7x83mtty8r6vaxxdknhnm2h4xz4ykuvs78nmkc	\N
38	\\xe0b9c3e7f9f9f92a6a71765a3fa060cb3c3277db860913ba025ede546d	stake_test1uzuu8elel8uj56n3wedrlgrqev7rya7mscy38wsztm09gmgc4afs6	\N
39	\\xe0928da3f49fa0daaa1d4da225715d8348e1b6b01446006a6c9c10638e	stake_test1uzfgmgl5n7sd42safk3z2u2asdywrd4sz3rqq6nvnsgx8rsrt727z	\N
40	\\xe0e409ef6aa0b3f69fc844456383f820b34a9a1fb63d82785c7756dc2f	stake_test1urjqnmm25zeld87gg3zk8qlcyze54xslkc7cy7zuwatdctckw8449	\N
41	\\xe0492ec5fda72b950606de447be140d9bd7383a0302ec2ec79ae2bd596	stake_test1upyja30a5u4e2psxmez8hc2qmx7h8qaqxqhv9mre4c4at9s3zluwd	\N
42	\\xe04731c37cda0a6218ef11654c29989da81133120b2154e1a494b5b330	stake_test1uprnrsmumg9xyx80z9j5c2vcnk5pzvcjpvs4fcdyjj6mxvqnmkmmt	\N
43	\\xe07de096d591646d565b8c9c955a20f47bb969b873f499cfc32eb5243a	stake_test1up77p9k4j9jx64jm3jwf2k3q73amj6dcw06fnn7r966jgwsnea7w6	\N
44	\\xe0784b0b6bbfb948b3fc521fc7eb7e2e37644a0b165e332e9ccae4dac6	stake_test1upuykzmth7u53vlu2g0u06m79cmkgjstze0rxt5uetjd43sqcg6m5	\N
18	\\xe0267eee1cb3de407a2dabcdbc739c8ab9a37275817bff87f552a57416	stake_test1uqn8amsuk00yq73d40xmcuuu32u6xun4s9allpl422jhg9sngsrx7	\N
16	\\xe09198dbc510390d8a7561398d9a79c56987d8a4e91806f2eeee51018f	stake_test1uzge3k79zqusmzn4vyucmxnec45c0k9yayvqduhwaegsrrca8ktc5	\N
13	\\xe07fec78d6d9b51ef3eda37164dba9c0beb2685eecd93d94ea6bd68817	stake_test1upl7c7xkmx63auld5dckfkafczlty6z7anvnm982d0tgs9csjjhya	\N
12	\\xe039a689342937be3f0bc39f82e2334d72cb371ff2facbdaeedd96e884	stake_test1uqu6dzf59ymmu0ctcw0c9c3nf4evkdcl7tavhkhwmktw3pq6a8zem	\N
19	\\xe0fddb1aa0187849fbdb7c3797bc72efc5df1627ecdd647912e0609f90	stake_test1ur7akx4qrpuyn77m0sme00rjalza7938anwkg7gjupsflyqcw50wp	\N
15	\\xe0ced8d3983d03e25e0dfa0d763dcf7b653bfb87a8ab1bfa93e25ad9ed	stake_test1ur8d35uc85p7yhsdlgxhv0w00djnh7u84z43h75nufddnmg9r28s5	\N
17	\\xe0afb020305113c404a0d857ea1c1f6dbbb93155e4fc76b378e4e93484	stake_test1uzhmqgps2yfugp9qmpt758qldkamjv24un78dvmcun5nfpqtkrtnf	\N
22	\\xe0e9a2e9118eb622da8dbd6b4aad678f23be20dc454b0e34d8314e8438	stake_test1ur5696g336mz9k5dh4454tt83u3mugxug49sudxcx98ggwqjqlfsg	\N
21	\\xe09ff709efab2a0cd8945de3a9138d5dca7d9490c6aa98d0217712149d	stake_test1uz0lwz004v4qeky5th36jyudth98m9ysc64f35ppwufpf8gym7gng	\N
20	\\xe05e7afd6ea838271f0e4982bcb4c825228ee21ad91f4f5e89d8285ac2	stake_test1up084ltw4quzw8cwfxptedxgy53gacs6my057h5fmq594ssl9qkqt	\N
14	\\xe04bdaa220a120ee6f20449b7de9ee58f462fb851f28a5054176a4faa3	stake_test1up9a4g3q5yswumeqgjdhm60wtr6x97u9ru522p2pw6j04gcna7tsj	\N
69	\\xe01bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	stake_test1uqdlrcfc7tuta27fv0y5es5wark5kst5gcql9md02zepalg9yxxuz	\N
71	\\xe09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j	\N
72	\\xe07d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	stake_test1up73dx2qeg7gv59739gpmycmxzffyqk3ha2ctmh9ghdgneqmy000q	\N
73	\\xe01081c31685a00207ed828ac74329586a1223615c798949df1559937a	stake_test1uqggrscksksqyplds29vwseftp4pygmpt3ucjjwlz4vex7s9w6mpu	\N
74	\\xf0e0c3297f1738f41feb0329d1a2eef497d133131e4604f0b64c0729f0	stake_test17rsvx2tlzuu0g8ltqv5arghw7jtazvcnrerqfu9kfsrjnuqg62tfe	\\xe0c3297f1738f41feb0329d1a2eef497d133131e4604f0b64c0729f0
75	\\xf09c7cb98b7706e342046cf710a2f1b3f1d58cefde177fa6a78ce22c2d	stake_test17zw8ewvtwurwxssydnm3pgh3k0catr80mcthlf483n3zctgd3sz75	\\x9c7cb98b7706e342046cf710a2f1b3f1d58cefde177fa6a78ce22c2d
77	\\xe072263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	stake_test1upezv0agh8cq09rt33ardnh8pdstd3lwpa5s64g2pne0uqgcygw6k	\N
78	\\xe08de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	stake_test1uzx79ge8d7gkx27vu3k9xgj9zlra0fvat5d5lxcnzm9n7hc8yk6td	\N
79	\\xe04f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	stake_test1up85ec98csnkgus5dw3x8u25mlkgu8m63hvw650ukldv04q6rf54k	\N
80	\\xe00ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	stake_test1uq8lxxfr92332xgqp66eenhpw7z04q09czgjf6uvnku20fq023mfy	\N
81	\\xe0ce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	stake_test1ur89gkdpkj42jwy3smuznfxcjdas0jz64xtckt9s8kz8h3gj4h8zv	\N
68	\\xe0f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	stake_test1urc4mvzl2cp4gedl3yq2px7659krmzuzgnl2dpjjgsydmqqxgamj7	\N
89	\\xe0f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	stake_test1urcqjef42euycw37mup524mf4j5wqlwylwwm9wzjp4v42ksjgsgcy	\N
70	\\xe0e0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	\N
67	\\xe0a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	\N
\.


--
-- Data for Name: stake_deregistration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_deregistration (id, addr_id, cert_index, epoch_no, tx_id, redeemer_id) FROM stdin;
1	75	0	3	170	\N
2	68	0	3	176	\N
\.


--
-- Data for Name: stake_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_registration (id, addr_id, cert_index, epoch_no, tx_id) FROM stdin;
1	5	0	0	34
2	2	2	0	34
3	7	4	0	34
4	10	6	0	34
5	3	8	0	34
6	9	10	0	34
7	11	12	0	34
8	6	14	0	34
9	4	16	0	34
10	1	18	0	34
11	8	20	0	34
12	34	0	0	46
13	35	0	0	47
14	36	0	0	48
15	37	0	0	49
16	38	0	0	50
17	39	0	0	51
18	40	0	0	52
19	41	0	0	53
20	42	0	0	54
21	43	0	0	55
22	44	0	0	56
23	18	0	0	68
24	16	0	0	69
25	13	0	0	70
26	12	0	0	71
27	19	0	0	72
28	15	0	0	73
29	17	0	0	74
30	22	0	0	75
31	21	0	0	76
32	20	0	0	77
33	14	0	0	78
34	75	0	3	169
35	77	0	3	172
36	78	2	3	172
37	79	4	3	172
38	80	6	3	172
39	81	8	3	172
40	68	0	3	175
41	68	0	3	177
42	89	0	7	279
43	70	0	11	382
44	67	0	11	385
\.


--
-- Data for Name: treasury; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.treasury (id, addr_id, cert_index, amount, tx_id) FROM stdin;
\.


--
-- Data for Name: treasury_withdrawal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.treasury_withdrawal (id, gov_action_proposal_id, stake_address_id, amount) FROM stdin;
\.


--
-- Data for Name: tx; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx (id, hash, block_id, block_index, out_sum, fee, deposit, size, invalid_before, invalid_hereafter, valid_contract, script_size) FROM stdin;
1	\\x676b1649a1dfc5bfa554eec7e2edf5d485c99fb2e3471f40e418765185078757	1	0	910909092	0	0	0	\N	\N	t	0
2	\\xe040d9dcb7eca9b1b8feeefe4cd793dd9324ff45187d5870eb8354137e00a6a3	1	0	910909092	0	0	0	\N	\N	t	0
3	\\x502b1fc9b0838f72fdf6980b8efd12b48dab89a9619226fb68d20042ebaffc0f	1	0	910909092	0	0	0	\N	\N	t	0
4	\\x2b76baa43e250b11630293e4ac063a5e8d97d27854da1aa8e467258bc3dfa324	1	0	910909092	0	0	0	\N	\N	t	0
5	\\x2dbf92040b6cab4676fb3b412a4bb29c07b18e8ed399cc7cf24b7af1bc184646	1	0	910909092	0	0	0	\N	\N	t	0
6	\\xe3336f66f36d21eb560e53844c2822eeabad80914bc8568d148cfb333465d221	1	0	910909092	0	0	0	\N	\N	t	0
7	\\xfb3859405f67a642524af06c83637c4bc2e88d30bfb465ac20f4c345b3ebe0a5	1	0	910909092	0	0	0	\N	\N	t	0
8	\\x31a6c9f623ba984b002a32e47b26a7b26ef0da75822ec956d1fb6fd3233363ca	1	0	910909092	0	0	0	\N	\N	t	0
9	\\xe9cc0c8496646a7a99d458c7608e064e9184a3d6f14f40a86833b8439db091ed	1	0	910909092	0	0	0	\N	\N	t	0
10	\\x94f9b6ff7adea43a82a0926c85c1cc0b0f7de3e401160632b8ec28baf52a1d70	1	0	910909092	0	0	0	\N	\N	t	0
11	\\x681c497bca1f47e28bdba8032410007ad83934d5498fca7ca6d32c8a1c476893	1	0	910909092	0	0	0	\N	\N	t	0
12	\\x034e5d380c6ccf3e9d571f1aa8101d9fa0ec27ae04f6843a4c990ab92d17cc4f	2	0	3681818181818181	0	0	0	\N	\N	t	0
13	\\x0aa57c31454f65fbe15214ead051a14ed4cf639ffd2f54a3ab86cc6fa383e3bb	2	0	3681818181818181	0	0	0	\N	\N	t	0
14	\\x23c87a1fef76d9d4ba4ce06f51e8c8bb100f9931baa2cc064f467eb4cf51304c	2	0	3681818181818190	0	0	0	\N	\N	t	0
15	\\x2b0f5dc49e0817be818a1e15462a318e135cc60b97cab1a66015bfdf0dabb4be	2	0	7772727272727272	0	0	0	\N	\N	t	0
16	\\x361b5fe79bd28a981421070cfd60c783eb96127054cf988f3f6dc739e16d78ce	2	0	3681818181818181	0	0	0	\N	\N	t	0
17	\\x3c70bfd3ef7d5c2634655eb18602ea518e136954238acbd42e008feb45719e28	2	0	7772727272727272	0	0	0	\N	\N	t	0
18	\\x4e6fc95e6d5c6e180a9c7743c6a34e32fca576111a41ab6a97c5442e7f0f7cd1	2	0	7772727272727272	0	0	0	\N	\N	t	0
19	\\x5f0d0f32275f3c4d8bb069a26ba8897e800d3e858e01ca01b2fbb5855717ecd1	2	0	3681818181818181	0	0	0	\N	\N	t	0
20	\\x6e6656c1ec36583029232132f4f7b64359b2a843b7fc020719deb292bcb1ccb8	2	0	3681818181818181	0	0	0	\N	\N	t	0
21	\\x71982cc7c6c9d4d364e82b72243c52e1e9cca226808bb8bfc0d747b813aa3cd7	2	0	3681818181818181	0	0	0	\N	\N	t	0
22	\\x7a90698210e52a242d9b498a5ce9f484a2c08dd7ceaaacab0e2036e3a63d6f64	2	0	7772727272727272	0	0	0	\N	\N	t	0
23	\\x7d4b671ca6b2ba59cf0229c5fbf745c2bd3466e3bd75bdc331e0fb36a98594c2	2	0	7772727272727272	0	0	0	\N	\N	t	0
24	\\x89ea0f85bdb4abd7773546cb732c3d32eb053970b5b6dfdbb3f838f574adc64e	2	0	3681818181818181	0	0	0	\N	\N	t	0
25	\\xa0b2b0cbf94f25fb34d01e2f4c651e87fd7196c8903fbe03941cefacd1f2b537	2	0	7772727272727272	0	0	0	\N	\N	t	0
26	\\xb171f4c26b6522c96bae0528c79393c556706d1d84a8088f8b291caaed1349c1	2	0	3681818181818181	0	0	0	\N	\N	t	0
27	\\xb34a317e1b0b08cbdba4ee79822ed23f2be166262b09254d901f90168e1f1319	2	0	7772727272727272	0	0	0	\N	\N	t	0
28	\\xb4beb84dea093c99fcf050f6d7df6a75f4170d0774b583ba58ce8653f7d34ba7	2	0	7772727272727272	0	0	0	\N	\N	t	0
29	\\xc72e5424ce7a957c0c208a5c73118fb70f8efa63c668c7c0a2740f9b58d1fa14	2	0	3681818181818181	0	0	0	\N	\N	t	0
30	\\xce96f476e4a9b715210f850f90d82f2032717c4abd90f4c3407fb6f4bf2e5084	2	0	3681818181818181	0	0	0	\N	\N	t	0
31	\\xd6bacc53c19115ff8e7d8f8d53f69b1e4dbdd7bf3cc1ec32993e10cf7c2d32b3	2	0	7772727272727272	0	0	0	\N	\N	t	0
32	\\xf08c2de2155fc6488b56f897f4930133bb9f5ab38625955f6c14a114d5b5d256	2	0	7772727272727280	0	0	0	\N	\N	t	0
33	\\xfa81390544fe4030acdbaca9471377b056ca61f01a49eeefe41dd8d17e0e91fc	2	0	7772727272727272	0	0	0	\N	\N	t	0
34	\\x5368656c6c65792047656e65736973205374616b696e67205478204861736820	2	0	0	0	0	0	\N	\N	t	0
35	\\x570cf402a372a744510e37ed4ca5c69dc31b72341707629aabe2fa9d9ff47953	4	0	3681818181651228	166953	0	263	\N	\N	t	0
36	\\xece4b0020a470a696d96a5100a8054be7783a8cf22743b96dd445b0af8768dc7	4	1	3681818181651228	166953	0	263	\N	\N	t	0
37	\\x602e1d72f5e9b4bb9332f92716a7b0e4849deb85fa48b6a29dfc0f01e7361a6e	4	2	3681818181651228	166953	0	263	\N	\N	t	0
38	\\xdc24ad6f7468942de910e9f55c5e9677a21eda5129944e943309e5f0b7bf2731	4	3	3681818181651228	166953	0	263	\N	\N	t	0
39	\\x2b3460f422f1ee451e224866d8ef082ba076f00d4b7d5b0d7d7ff7e1087a61ea	4	4	3681818181651237	166953	0	263	\N	\N	t	0
40	\\x5f929c6fbead424489232825975e097e803cc7f9e82a3473e41013b34a3afbdc	4	5	3681818181651228	166953	0	263	\N	\N	t	0
41	\\x6b11250d9a24f1de494a314bf48b0569ceae51fbbb0aca75a09be7afa7fef277	4	6	3681818181651228	166953	0	263	\N	\N	t	0
42	\\x9e34954af94ba83faba378e50c043b5df6f31292af2f84be9b1107ba817d8a9e	4	7	3681818181651228	166953	0	263	\N	\N	t	0
43	\\xc596ab786ebfd03feed7f8fdc62051adddacd5d7e896434038180f0fd8d54d37	4	8	3681818181651228	166953	0	263	\N	\N	t	0
44	\\x88172f25a64841cea9e494db372505eaa2f02959140c0ab48bc97b320e20e51d	4	9	3681818181651228	166953	0	263	\N	\N	t	0
45	\\x89b51ba037c384cdb65a7b074891728c20015d8422061a99245dce9386352b2b	4	10	3681818181651228	166953	0	263	\N	\N	t	0
46	\\x63430fe8f3a3097cf1e91b6770e5de994043eb5d36794f754987899db9d85e85	20	0	499997828823	171177	2000000	359	\N	\N	t	0
47	\\xab08be1c6f649cf595d31dccd00a0b9d5c1946780b477b65e68e01dbc7f78b61	20	1	499997828823	171177	2000000	359	\N	\N	t	0
48	\\x96057529d51cb8603b3988475722438fe02c10b9bae6fe1fefcc836354f7ed33	20	2	499997828823	171177	2000000	359	\N	\N	t	0
49	\\x3f44597f43ea8c39117be00d53cfe4db23043990ccf20fc0b10148f3115b234d	20	3	499997828823	171177	2000000	359	\N	\N	t	0
50	\\xa3f2759f0a50b2ce60225e497eaf233831e6ef65e187e0078485c45b7635db20	20	4	499997828823	171177	2000000	359	\N	\N	t	0
51	\\x1d73001061b3a0f18ca085ac343a04a258b8ca71fecf1983d2013aaa717fe35a	20	5	499997828823	171177	2000000	359	\N	\N	t	0
52	\\xb07491bc64fc4e80a18b7ae50b85c23cde6ba5ea4b4a139f38a7bcb1d7e9a184	20	6	499997828823	171177	2000000	359	\N	\N	t	0
53	\\x056668963fd1115ecccd0a8ee5419d740de1d87bd5c00df55f862705568dea63	20	7	499997828823	171177	2000000	359	\N	\N	t	0
54	\\x3def80a951d7791b17a070a3b87c58c390f08e6816fe37e148e3235d63e82318	20	8	499997828823	171177	2000000	359	\N	\N	t	0
55	\\xd882de9fc26d7d7315dcc974810ac2ff8522d216fd0356dd4c26d39c3e15be18	20	9	499997828823	171177	2000000	359	\N	\N	t	0
56	\\x1e130fe5ecf0872c49a4d135fe2427988c8943982902addbe107bf44a7763ea1	20	10	499997828823	171177	2000000	359	\N	\N	t	0
57	\\xd5a87894f06cb8ff90e54798282aeaf6ab55404b70c7b36d60b5e76367231376	28	0	3681318181484451	166777	0	259	\N	\N	t	0
58	\\xc50f9e35bf17966b4737aab0e703d1e96c243e83cc4f4669b0af687f70b65135	28	1	3681318181484451	166777	0	259	\N	\N	t	0
59	\\xca3ad1f39ec33121e6914de276fb4ba20cc17c435162e9bdda3ad85d60cfd5c9	28	2	3681318181484451	166777	0	259	\N	\N	t	0
60	\\x5e4e620a30b4233275c0bd50a845df3778c18227af3c637d7c99834b07a9deff	28	3	3681318181484451	166777	0	259	\N	\N	t	0
61	\\xc9d3f273896a6310333e873719285c43c1f420970d640d862ee57fb05f54f7ce	28	4	3681318181484451	166777	0	259	\N	\N	t	0
62	\\xd6646114f21ddeebe136ba858565ee52b0bfe975354cc3f2ac0ca96ef497aaab	28	5	3681318181484451	166777	0	259	\N	\N	t	0
63	\\x1f0df3fe877424159f2f7c9e3ef9628325cda5e5f6f28b66a397b47aa9c4d247	28	6	3681318181484451	166777	0	259	\N	\N	t	0
64	\\x37d88f1555cf914d4e15cbceafe4e1372b7db45c5bbbe416771ea375cbe32887	28	7	3681318181484451	166777	0	259	\N	\N	t	0
65	\\x1947a6481fdb13f3fe7038ae2c8c6c8c86ef50c7d451b943cab2f89dab18ab32	28	8	3681318181484451	166777	0	259	\N	\N	t	0
66	\\x53e715d9e184230daddd334c44e93250e52a2c80b900ff9bfc4e7d0395cf9002	28	9	3681318181484451	166777	0	259	\N	\N	t	0
67	\\xf0c61ac9938f970db3a408455a35c34ebcbfcd11dbf89c6a59d8d00df0ea5bc7	28	10	3681318181484460	166777	0	259	\N	\N	t	0
68	\\xd51cc229bfea01e47fa58fa6de9a572abd4b6efb4e977439226fb46ba6dfcdec	29	0	3681317679310238	174213	2000000	337	\N	5000000	t	0
69	\\xf732e5f49b836823db4d56a9c9ab73b1aeba045f6734c7a9304792a15af127cb	29	1	3681317679310238	174213	2000000	337	\N	5000000	t	0
70	\\x1c065b7e0a8656fa8e02dcd233847e8c51ddd05fdcf05dc099b3fb31e0b51386	29	2	3681317679310238	174213	2000000	337	\N	5000000	t	0
71	\\x5809a08ca3c3f0bfb13582e91c5383c5b289f7922f9a017c6254c75d58d1a427	29	3	3681317879310238	174213	2000000	337	\N	5000000	t	0
72	\\x6770b61c0ed2462bbb00e5aeb1f6e852b086d92d675f284c2c9847550f80cd1c	29	4	3681317679310247	174213	2000000	337	\N	5000000	t	0
73	\\x855f7f0c87158a545ae1c3b93363f7c132300a6870a3588ebef4be22f06fa127	29	5	3681317979310238	174213	2000000	337	\N	5000000	t	0
74	\\x5de2eed989ad04050dc3358c62dbeca3eab906127eb5a10862c00134a018e2e9	29	6	3681317679310238	174213	2000000	337	\N	5000000	t	0
75	\\x5b8c528ab1725d11dc0ae566f0a590de8e8d6e1452472aa9f2f2a5bca89a7d05	29	7	3681317579310238	174213	2000000	337	\N	5000000	t	0
76	\\x789c21955b2d27d0560ba0c67045efae11231779545e57fc93040f85c5dbccb6	29	8	3681317679310238	174213	2000000	337	\N	5000000	t	0
77	\\x5f41b90585c6e59711945e39e6f529f9be5a1cff65b7c2f6d2ff31bfc65e49df	29	9	3681317879310238	174213	2000000	337	\N	5000000	t	0
78	\\x98579f99617704e1130571dcdc3fe1e6356d5aadc5ddfe134acdd9da925024b0	29	10	3681317679310238	174213	2000000	337	\N	5000000	t	0
79	\\x643e436bac94acc4e23b925eba5c3c028979a84a6aaa6676ab564563f3fcf93d	32	0	3681317879134705	175533	0	367	\N	5000000	t	0
80	\\x5ca990025fea349b6b8fdc263616195934905ff49d56cbdeeff680c83b6e0d70	32	1	3681317879134705	175533	0	367	\N	5000000	t	0
81	\\xff83e1bcf1023d7ca68e16803caa4cd64b213819056c715e72ae90c4b1048f8e	32	2	3681317679134705	175533	0	367	\N	5000000	t	0
82	\\xfed04d3554f25d679a6fa1042aeff7754834ac3d7a3142f5814f11a21e0bd76e	32	3	3681317679134705	175533	0	367	\N	5000000	t	0
83	\\xd0e41bae154c6a25482869677415d9676a288c31d744b711f88eb60c168d0ddd	32	4	3681317679134705	175533	0	367	\N	5000000	t	0
84	\\x554e14ba655c3200dc0aa57ba84f3d515d920575a57813f7cb2df09ef88d3c7c	32	5	3681317679134714	175533	0	367	\N	5000000	t	0
85	\\x81b1ab94f38e4114dfada04a5c6b02158f2dc090e80230175264371d7aeb437c	32	6	3681317679134705	175533	0	367	\N	5000000	t	0
86	\\x7e9521225631077432ec6b04f414c01dbf80792287c6becb1c376f8053e46b73	32	7	3681317579134705	175533	0	367	\N	5000000	t	0
87	\\x5aa8d1352871cc383160ea0195951714fcd4afbc9cebd33079d656766224628a	32	8	3681317979134705	175533	0	367	\N	5000000	t	0
88	\\xa5657e4c44e1206d68fec05d40d1e59a2a1cfaea2be4a7c650c387b7b152134c	32	9	3681317679134705	175533	0	367	\N	5000000	t	0
89	\\xbd1a42ff2dff695eb6df643410855693d64e6b22ca3f81dd4f169f1552e0580a	32	10	3681317679134705	175533	0	367	\N	5000000	t	0
90	\\x3f13e7be2f37a6a43f83f2b3d8cd0ba1a27bb960d38aced6e4169bca475ebdd7	34	0	499997652058	176765	0	395	\N	5000000	t	0
91	\\xae9ed03894728de7cbebfd48b7a585ef084c7d4ed7ff8c1e900daa210d320e3f	34	1	499997652058	176765	0	395	\N	5000000	t	0
92	\\x5ff7e0e2539c849afd5e98103720f7d76b2dfcc6d8fc1811499fa8774b3c7ee4	34	2	499997652058	176765	0	395	\N	5000000	t	0
93	\\x30e410e1b72e9b3dad68d3a8141a4cac3ddf90bc00588f5eb850be1cf893d03f	34	3	499997652058	176765	0	395	\N	5000000	t	0
94	\\x331856501de7882c694fbfac4cafa9cfab33d039dd51b3e5a86fbc53d599d3d5	34	4	499997652058	176765	0	395	\N	5000000	t	0
95	\\xc347c55b6824cff5330bb6f48e25473ad90b24673699d0a9408a8bf2eb15f992	34	5	499997652058	176765	0	395	\N	5000000	t	0
96	\\x8afd8672729a3ac657c782c049a5fcc83b52807898962f0286f1da0fe9bb4a2f	34	6	499997652058	176765	0	395	\N	5000000	t	0
97	\\xdf3b863ead20b6935548cb8a6bf360a75217b03725d7f4286a3e1da2432663bf	34	7	499997652058	176765	0	395	\N	5000000	t	0
98	\\x4461227ef32c4b87a73ba644a4e8d351087110f9b7a0a8c85896e1df441dccf6	34	8	499997652058	176765	0	395	\N	5000000	t	0
99	\\x0c19033891894ebbfe5e0d96b063fbf65705bc3bdeab40dde483656dd1333745	34	9	499997652058	176765	0	395	\N	5000000	t	0
100	\\x157659e9cd8534164d6dd8dbeba771f4c7dab347462d54666eb8620f2f7f197a	34	10	499997652058	176765	0	395	\N	5000000	t	0
101	\\x32e8602c395bd267d1d42686306534560ae92c63a21a2f3f5a04bedc4a0da977	35	0	499997466449	185609	0	588	\N	500000	t	0
102	\\xc17f3cca7358f9f8096f3405b6cb7763fcf3e7d0dde525187940b1ee6752b43c	35	1	499997463677	188381	0	651	\N	500000	t	0
103	\\x438ccf50b0bc7f5203c42b44256ce1392c56a2280e376a5dc224b6c174a65f06	35	2	499997463633	188425	0	652	\N	500000	t	0
104	\\x6fb47a0d681fba6f65094f3820695647ceb6380dce6a74d471826736b4380e95	35	3	499997463633	188425	0	652	\N	500000	t	0
105	\\x3258f7e6c6b8d7720a190662881872e2997d2cb8cddd1a921a2304f9aa3270fd	35	4	499997463677	188381	0	651	\N	500000	t	0
106	\\xb43acccb5a2a24e13a3a4066b667e074d230ff208748f5e630cf281229ede717	35	5	499997463677	188381	0	651	\N	500000	t	0
107	\\x0cd65231bdff5f334f176962dda9b664510ca1403ce3fe2e11cec6554206f7ee	35	6	499997466449	185609	0	588	\N	500000	t	0
108	\\x7d9a95e098d5d564a322a7c018ad930717694f74b386bf27d41635b6893a7741	35	7	499997466449	185609	0	588	\N	500000	t	0
109	\\x468405574769537e15e44b1ed41f5e3837173c45ccba3ffdb1248b2e2563fde8	35	8	499997463677	188381	0	651	\N	500000	t	0
110	\\x98145b924fa406c80cd9e307ee42caf25cf54d13dde6de78bbac74d87395dac4	35	9	499997463677	188381	0	651	\N	500000	t	0
111	\\x721af98b4931fb326f6acf8d88733dfe3daa977eb5855504ffce96f3cc73801f	35	10	499997463677	188381	0	651	\N	500000	t	0
112	\\x09673e2748457d57bbdb33b351db446357c71f4511a793abb9f9d02a4a0f04e9	37	0	499997289684	176765	0	395	\N	5000000	t	0
113	\\x083370305bcb920878e67c64ffa419de57a73d1fbadce83eb433e02e1b161f56	37	1	499997286868	176765	0	395	\N	5000000	t	0
114	\\x9e40c88eec97b01f6aaf737af3bd7445bceb17dd3e56cb47eecb68f1e3dff4e3	37	2	499997286868	176765	0	395	\N	5000000	t	0
115	\\x3c6fa5b57b493c91c09e3dbed095af1912058b78e8ef5dd5ee2483085d6c4096	37	3	499997289684	176765	0	395	\N	5000000	t	0
116	\\xf94f9031b6ef614fd53163d5e465a84e00b003bc52653736f2a227958a54a303	38	0	3681317678956092	178613	0	437	\N	500000	t	0
117	\\xda0b07317b90297e711bcf029c5fcf7ad76c3a3eb3c316d9debc67baf340948d	38	1	3681317678956092	178613	0	437	\N	500000	t	0
118	\\x52ab28f5b3ce9b14752e20056d5655cdf382d26743fdf7ec9a01435b95429b52	38	2	3681317878956092	178613	0	437	\N	500000	t	0
119	\\xd5927c606e469c6e47d61a6fb1035db75d0fce2e5b1a650b9b69b003ad6b0e7a	38	3	3681317878956092	178613	0	437	\N	500000	t	0
120	\\xb21704fa7b74fa55f985565c253928aa7ebd3ffbcea98d82be581703e36a306c	39	0	3681317578967664	167041	0	265	\N	\N	t	0
121	\\xc819e907a09e5356856a340d0526247877abb368978be37eb78c0dce50ea6ce5	40	0	99829086	170914	0	346	\N	\N	t	14
122	\\xc26f23afe4e50fb1ea504d186c93cf3e672e0aa5a91e55aff7b55cfc6f85ca3f	43	0	3681317478801679	165985	0	241	\N	\N	t	0
123	\\x0d7e4b4055daaca58f4f35165f8a075dacc1affcc35737e61f75198f8c45a199	44	0	3681317378631382	170297	0	339	\N	\N	t	0
124	\\x421ab0152f29c87dac6e90333575dd1ed692d6ae1cef7c662e6029ac2abe5805	45	0	3681317278463681	167701	0	280	\N	\N	t	0
125	\\xa1a52db4a98f0fdb1be2192cc2ec81e5049c0a07bb06db35259fc90f8d5a0f44	47	0	3681317178297124	166557	0	254	\N	\N	t	0
126	\\x0bea2d67cb63dce3b128c62ed471559fe2992506fce0f830159150367a240aac	48	0	3681317078034339	262785	0	2441	\N	\N	t	0
127	\\x39ae00bac197193b161a0ac46ebbf79c1898d593244b2efacf803fee3babc097	50	0	3681316977868310	166029	0	242	\N	\N	t	0
128	\\x183d345f0414333c804981bf66cd9197c942b04d4007055c12546f8dd5b0df3f	51	0	3681316977541139	327171	0	2609	\N	\N	t	2197
129	\\x20bab943eb11253b401e683f962e7d9ed8d59b494bbaea3927d392da4284c04a	52	0	3681317678958952	175753	0	463	\N	\N	t	0
130	\\x1e542f00681a90a2c057de3c55ce435746d564392387eed3c61be8c3a150ea7f	53	0	3681317978955608	179097	0	539	\N	\N	t	0
131	\\xc02c1338ba64139f1678e7f98f62ab61cc9c21e2af4cb3c95d1153c9d04afe92	54	0	4999999767751	232249	0	1747	\N	\N	t	0
132	\\xe5b6ce2a0796f4c0aa1951c1b59c03f0d8f6d4483832344d688f09460e8a6449	55	0	4999989583022	184729	0	667	\N	\N	t	0
133	\\x0aedd3775779f56eb12b7753c3b472560a2c0e0311e2d8b43438f2c46ebf42d3	233	0	4999979415013	168009	0	282	\N	3651	t	0
134	\\x475db4bce044ce713dc490fef1bba8cdbdd723bf947b3eee96a42c2dd6149bd7	234	0	4999976180168	234845	0	1700	\N	3661	t	0
135	\\x7faa7a8343b5b4e169bc201e07c27c35f6572f19fed332129d304d473211cdd4	238	0	4999965958039	222129	0	1411	\N	3682	t	0
136	\\x513d2788fe0731fd3c081ede71c881cc6ef3529ab035f052171e03079421e933	242	0	19772151	227849	0	1541	\N	3713	t	0
137	\\x1312e586e17e5c3fbabcf4ec2719ed1a7d195a68c023ced96ccec5201968ae70	246	0	4999955766666	191373	0	712	\N	3743	t	0
138	\\x6f7392e6d046a2bf6930a9226b14477507b531443f6f9c999fd23dea87798ccc	250	0	4999975360820	177997	0	509	\N	3770	t	0
139	\\xc2620d9c02a006358b3574a60118386a63bd7ccebeffb4a2ce65d74f8016c5bf	254	0	4999955187839	172981	0	395	\N	3840	t	0
140	\\xbf07c97a0722fbbad47a956df57d6c16da5a8c20cdfc6e7f9b4e98a82527c03a	258	0	4999935011778	176061	0	364	\N	3878	t	0
141	\\x19095ec821c0914e20feb59c585bc8fbfd09818652b6d7b791ffbaf14e294fd4	262	0	19826843	173157	0	399	\N	3902	t	0
142	\\x38ff96c49850679c27706acc59c275edee474e01d4b45a8fa45fbb044686efe0	266	0	4999934818953	192825	0	745	\N	3951	t	0
143	\\x6913de3a7411cb49bc1f818e3b485b98a3df38718b6cc4158053763cfd343b0f	270	0	4999924626128	192825	0	745	\N	3968	t	0
144	\\x0a52106f43432cd90fce80df0bdda83ad022cbdd2fbd0c53694299fb50e9780e	274	0	19825259	174741	0	334	\N	4016	t	0
145	\\xe7f6c88a4dfdaae83bf065438a0f036fc6c68523d611d26f54df1b4096c32f2a	278	0	19632610	192649	0	741	\N	4029	t	0
146	\\x2e81b9815f04142966947df8dda43654292da6cf3aedbf7ca39c725ca8fbb9fd	282	0	9826843	173157	0	298	\N	4085	t	0
147	\\x63c1cadf0b7cdb2b7c61d3b6299e2a9e43bc97adb9d7fe990c622701f83e3aec	286	0	4999924258562	194409	0	781	\N	4122	t	0
148	\\x68d5e6544c739eaf585ae4f1720e6a52148cfaaf485255008132c95bb5467235	290	0	9824995	175005	0	340	\N	4143	t	0
149	\\xf941094557bbc901be022c18a90149f23d019a367f85b35b977c50ed06d5a060	294	0	9651838	173157	0	298	\N	4203	t	0
150	\\x9f716492e37956ceb85d868e16c603a85598a8ca7292782920cebd77dfc103c8	300	0	4999923685587	205585	0	1136	\N	4251	t	0
151	\\x18896bec7313aa65a7fa9fcb83203e03519820d0ca40befde1cb7e3e77978a79	304	0	19471773	180065	0	556	\N	4283	t	0
152	\\xc95eabba01e5ccba585501478068c24ddda37406bd8fc3ed8f1ff5ac24e45a79	309	0	4999922966251	191109	0	807	\N	4304	t	0
153	\\x134c21f6de2af64f4b76c8e4a08bb83258d19026770fc782024c18b454f3f1a3	313	0	4999912777254	188997	0	759	\N	4366	t	0
154	\\x46f117617503c885b41df5e0ab75fe3d75d196297e5ade94117e71e6e37184d8	317	0	19811795	188205	0	741	\N	4383	t	0
155	\\x0127210e733651745ff6baf4d580a0d3bb74658dac55b0731e87a86b6a1c0ba7	321	0	4999932408236	180813	0	573	\N	4406	t	0
156	\\xd119dd107063832a89ab3c75906ec5bbd137ea76d9e0e2369f48bcb3ab7484ab	329	0	4999932224387	183849	0	642	\N	4466	t	0
157	\\xb981bffe585e13d141577de028dec8413b32bb445ef18dabef011e487d62caa5	333	0	2820947	179053	0	533	\N	4497	t	0
158	\\x8f82127578e2bd69ce8d921f67b453d2a4bdad4f012529f3926a3fcccf9cb6b3	338	0	4999931866193	179141	0	535	\N	4519	t	0
159	\\x65648f2785d24eab16c86b6cf1cd50d6ad84e32b5ca67cc741e8bdf39ac87e72	342	0	2827019	172981	0	395	\N	4566	t	0
160	\\x90c73d1a7a0d553d589c3349e150d793516ad18ba62b0acae1760abfb0fa4d2a	347	0	4999931175315	517897	0	8234	\N	4630	t	0
161	\\x16a49e78fe0a65e1b0eb2197807d0d6126ffd391f3d8cdaaee0bc78764904a7e	348	0	179474447	525553	0	8408	\N	4654	t	0
162	\\x333ed961eee5c0ecedcad8ce104de8e49e0a6574a6706757d7b9fd573f411602	349	0	4999929409010	266305	0	2516	\N	4660	t	0
163	\\xb2b31eb543c7140ec7252fe2ef376f4106371bcbf65649eb6dec4ed743b01102	349	1	4999929238845	170165	0	331	\N	4660	t	0
164	\\x64c599bf48478657e574c59ee4c79ba345326beb2258e03022b8142594f5706c	356	0	2999957634936	170253	0	333	\N	4722	t	0
165	\\x696c5209508298cd9eca61d6dc8cc5e25b9d4b38365f2dafeea1ab5b7f7198f7	358	0	1999971265251	168405	0	291	\N	4737	t	0
166	\\x42c70e459291cd0cf9250e067465b59691236f65de3f8e61917cba9e7df84bbe	359	0	1999961096846	168405	0	291	\N	4752	t	0
167	\\x5da17e9b239d6484259d410a6877d9b0e81cd4cbae4eadd2e59242e1df545c4c	360	0	9818439	181561	0	590	\N	4785	t	0
168	\\x03c11dffe960723a0a7a538a0976e96cf4ab5d085d2f0ce54eb2a396674f5445	368	0	1999950928441	168405	0	291	\N	4859	t	0
169	\\x4498775188d550eb5ec8413d596032cba6ceaa559e5823fe474e761a4bde636d	369	0	7814039	185961	2000000	690	\N	4897	t	0
170	\\x4a05ab8ab2a1e67dd61e89a1d8bc9cb960d10ce76ea3f6d7a57ea6d181ee49c5	370	0	8633754	180285	-2000000	561	\N	4906	t	0
171	\\x28a93a34edad364bdfc2117385730a6a72475427c21f84b246af6061344ce47f	372	0	2999956496781	168405	0	291	\N	4919	t	0
172	\\x2f7e5f2278f3621cd5eae087b7947a07955ee1c813453b3a6921c5ad72892aa0	376	0	989675351	324649	10000000	3846	\N	4965	t	0
173	\\x4f6760eb6e67cc11a6ba1fb5e4b1352e3f720b6e37f2c87edcb1e66a113d672c	380	0	989414590	260761	0	2394	\N	5000	t	0
174	\\xc3283c90fe29f0965776c8304d78ad319dd613cd67d13f36c809f0bee7ed0019	384	0	494375158	201757	0	1049	\N	5045	t	0
175	\\x4b110d9b9f61d43053ee7ffa42c05e3e28984ee040c3967fec82886713a416a3	389	0	1999938746088	182353	2000000	608	\N	5088	t	0
176	\\x2bff884c7c4f70321582baf27e90144fd8379c7a8795e40e019e0eeb0163f75e	390	0	2798353	171397	-2000000	359	\N	5098	t	0
177	\\x73d7a3c7398f3682516c9a74f693d138c13ab2f497236bc5316ca3c8ce59ba3d	399	0	1999936564131	181957	2000000	599	\N	5132	t	0
178	\\x61c77b0f97872c6a97a64070c72d68ee9b9f84ee926444d999b2563e96210dd0	541	0	1999936395726	168405	0	291	\N	6447	t	0
179	\\xfb6b294319df8ded662f455258ce3e0ffe3ac41da28d56269595d42f9c372121	541	1	2998956328376	168405	0	291	\N	6447	t	0
180	\\x4c0bfff82794251efc297f0a80b98a30352f9380c594da75ad947148bb462d9d	541	2	2998953956740	169989	0	327	\N	6447	t	0
181	\\xab3e763dd55125a78cab227f27212e89f7dce6baf19f30196d1891cfbdd9bc10	541	3	1999931227321	168405	0	291	\N	6447	t	0
182	\\xa61928dc0cb7ac9f6a3f8b1533512519d948e4a5fb9828c4b5a41a8a14878860	541	4	1999926058916	168405	0	291	\N	6447	t	0
183	\\x53d01433b6152f057b3e0e1f50d8370bc241239dfbbc83eac224788e5467dd07	541	5	10828603	171397	0	359	\N	6447	t	0
184	\\x4ab42e7277b639c436f2fc644805321cef54d284c1ab3a9bff57acb420a0c7bd	541	6	9830187	169813	0	323	\N	6447	t	0
185	\\x9953fa8ff0681bbb49ac2e3711fe8bbab02ceb5e6289d7c2894d9fac3062feb6	541	7	10658790	169813	0	323	\N	6447	t	0
186	\\xd2aad512de10ca07e931269cadb263007f9ed6eb9a31944cc5d6b2191f5c0b8d	541	8	9660374	169813	0	323	\N	6447	t	0
187	\\xa1f5943797a5d9ead6daff84686852f0b9473b67e71e816dd2e2b665611fe010	541	9	1999920890511	168405	0	291	\N	6447	t	0
188	\\x401fc83622d312460e002d7486a5c8a180a8b8db5903c7598bffb86f402d6819	541	10	10488977	169813	0	323	\N	6447	t	0
189	\\xf780e0d2b941cb22573e97961dee12669393f80eb2ff0dd027fba1b48dd38cf2	541	11	9490561	169813	0	323	\N	6447	t	0
190	\\x37785fc7628f1a0fc44d210d7de37d3533b7b34e499817316f0a96967e4502b3	541	12	10319164	169813	0	323	\N	6447	t	0
191	\\x4b9f1812d7b18f9803607a1c15e9085cfc018d2886210ef49285bee989524a19	541	13	9831771	168229	0	287	\N	6447	t	0
192	\\x081d23b323100481c44a6d780381d5810b332be2947461a1a2bdbfba0572d2a6	541	14	9830187	169813	0	323	\N	6447	t	0
193	\\xfd08688853cb11530b9418c6a49b514dc096ab730d259f833889442331c3cd92	541	15	9320748	169813	0	323	\N	6447	t	0
194	\\x13e5759fbf3fa28709c21423e6a5d8dff4fe2377abbcc1ae09874fcbdb61050f	541	16	1999915722106	168405	0	291	\N	6447	t	0
195	\\x04cd3fa4824254a33f08f20325ec016f7228f35e848a666be65023e1d39df177	541	17	9150935	169813	0	323	\N	6447	t	0
196	\\x9636193f7ca3e10c42bf76e270295d4e50589df22fbe3b5265e4889d8ffef944	541	18	9830187	169813	0	323	\N	6447	t	0
197	\\x09c4dd02324aa8d2d429c71a02e30c3c47a1036a7a76dacd20686799081cd2f4	541	19	1999910553701	168405	0	291	\N	6447	t	0
198	\\x30895e06b8f29f2bd26601f51fb9bafec9044122bc58e4bc7bd863ef660a312f	541	20	1999905385296	168405	0	291	\N	6447	t	0
199	\\x516b06fb590ebea1050783cc8a4666a012e1d6a946deda967cb8fe1fce51b1ef	541	21	10149351	169813	0	323	\N	6447	t	0
200	\\xa9af62e4f61335017efc7616ae699e5bc5f18db2f6007d1535318958fe864039	541	22	1999900216891	168405	0	291	\N	6447	t	0
201	\\x66e4a253b2f32e3adeca793e63c9858b58fd2228671d66c73014184974efdbbd	541	23	9660374	169813	0	323	\N	6447	t	0
202	\\x58b22c1f03968f05400cf6432a6fc7b46cf3aca1a1a1386c1c2f8be97b8dee12	541	24	9490561	169813	0	323	\N	6447	t	0
203	\\xe073213895de1ce16d52d576a974b1cec3ddc648da1bcaccc2981f6ce782fd53	541	25	1999895048486	168405	0	291	\N	6447	t	0
204	\\x3dffa9fadcc4a93810733e01af8fe631ecbc72bd82772995d71599eeef0e3c0a	541	26	9661958	169813	0	323	\N	6447	t	0
205	\\x5481768e76395b884237c1ab6b7a0c7d6717e6e0583e0e69c3dff77b51ed11c2	541	27	9830187	169813	0	323	\N	6447	t	0
206	\\x9805088de1ef2a6da6691aa9d61973d96feb5ff24759033932c934a5146f05de	541	28	9830187	169813	0	323	\N	6447	t	0
207	\\xaa7c6683759881e8ffdd7706698e4ceaa7a0d2a6c65e1f13279c38741633afe0	541	29	9979538	169813	0	323	\N	6447	t	0
208	\\x0152217307f98c05d408bb4a5ccaae924e351c35380ff05be9e3a51548f0ac00	541	30	8471683	169813	0	323	\N	6447	t	0
209	\\x4f34a8354cbdc9a011be115a1ffd72e4dc0143f184555912b7c72f198d414c53	541	31	9492145	169813	0	323	\N	6447	t	0
210	\\x91a739f0ade042a9e7cb901b3d01e00d44b6f7a99bf78d3dcaa03e1338412855	541	32	9830187	169813	0	323	\N	6447	t	0
211	\\x9504eb9da48131c8eaf96c4631442d126eb6d60c6c462103276b9e0f1847dec9	541	33	9322332	169813	0	323	\N	6447	t	0
212	\\x803bc90118e4451e773392a2e60a26d6cdd8f71deba178ce1d9ba9ddf25a7f4f	541	34	9660374	169813	0	323	\N	6447	t	0
213	\\x1635524ee2dc5f74cd6bd359fb21465085864278fa3be0f267903319bf8eb917	541	35	2998948788335	168405	0	291	\N	6447	t	0
214	\\x2c32f26dbdd15b3a8910be8f8abb816a57410b0ef4d0ab6a81a158875a17825e	541	36	1999889880081	168405	0	291	\N	6447	t	0
215	\\x3b8e4f1b15c57a51789a2fd05a48559ee7af4bcd728ce08bd4d710771cd5734c	541	37	9830187	169813	0	323	\N	6447	t	0
216	\\x8569f81b91eda36da285f4c7387aad5c009a0c6cd5b7d98e4a3edd356267d566	541	38	8132057	169813	0	323	\N	6447	t	0
217	\\xa9f1043a398d92bb038a14b716012c662a9d3d48169838fe86965072d355cf4d	541	39	7792431	169813	0	323	\N	6447	t	0
218	\\x5f987666c04b64013732e8c9bc0c08400c286bd4e4e068b06b483f46e855f8c5	541	40	7622618	169813	0	323	\N	6447	t	0
219	\\x49b49c552a071c0125d7f166ac302676ce838b14c8098c0511c80e718463830b	541	41	9639912	169813	0	323	\N	6447	t	0
220	\\x97fe5f7731f3f53127463183cef67915041e0d0b4d9788217797aefde5893819	541	42	9470099	169813	0	323	\N	6447	t	0
221	\\x0a371a759e63958df7e4eeb7f131b115c1c5a141a63a6924ad69186699d14aed	541	43	9830187	169813	0	323	\N	6447	t	0
222	\\xa8a534743e7d113218ce7c96ecef82cc1d90c7a753847eecf9ca2b193fb5e7c9	541	44	9660374	169813	0	323	\N	6447	t	0
223	\\xbca016e5390fe15a10b1ade3164f39cb0b834a4e940b402c634eaf15dd7a7720	541	45	9300286	169813	0	323	\N	6447	t	0
224	\\x42826f48b0c4e03d8a5796491ac5ac1502f19f394e0b64c7ca294baf38d16ac6	541	46	2998943619930	168405	0	291	\N	6447	t	0
225	\\x68910c17018629eaf16ae7c4b0160dfd5d1fe8165d1ecf03c0f2df6c145a83c6	541	47	11773553	171397	0	359	\N	6447	t	0
226	\\x35c03abbaed635808987e79c8162ae2275635125ca8cf3d8e60b7d4649ab5932	541	48	2998938451525	168405	0	291	\N	6447	t	0
227	\\x134da4c1c7c71cae52f6cce83505fa0b3ef8d8f351af09e0245e1f01a1780dc9	541	49	9830187	169813	0	323	\N	6447	t	0
228	\\xdd4f6b6954ae57c6b4bc65e6b7dee206a7dc49e316779a18f0f1470a1bd22a34	541	50	11603740	169813	0	323	\N	6447	t	0
229	\\x660ce39422d1bc3760c9bc40b5564ef69146ed0d1f94aa8f67b7d604a5a05f64	541	51	9830187	169813	0	323	\N	6447	t	0
230	\\xd75b20500c3d9e4d19cadeba76eae5f5673c250ebcf51b40a3935f20ed79d6b3	541	52	9660374	169813	0	323	\N	6447	t	0
231	\\xb5586263ffcfb0b41571eff55ff59b8e730fb22f31e6431f12e691b9f38f1676	541	53	1999884711676	168405	0	291	\N	6447	t	0
232	\\xb632c10642e9bd62f484d96603b28b35f43306b53b71aabf1f54112a72fa87ff	541	54	9830187	169813	0	323	\N	6447	t	0
233	\\x3c225a93ad71f3f0e107c49fb4c5a9579e72cfce93a69f3308246d3e72c07fe4	541	55	9320748	169813	0	323	\N	6447	t	0
234	\\x1b48971f9fb617c62a099a50e4354b016e1c0b886e033c24b65fbc78c9ac2f84	541	56	9660374	169813	0	323	\N	6447	t	0
235	\\x8bc164f76fa9a0ced561ea1aa7af22229e9dda5a05885181ec6d73752525280c	541	57	2998937581822	169989	0	327	\N	6447	t	0
236	\\x352c0eadec3bb7d3dcd6ba1debe1f89301a69863db5d907ab2bb345c49fef86a	541	58	9830187	169813	0	323	\N	6447	t	0
237	\\x8f1e5d9de72ffb403202e2454765b89ef0c3d3df7c80e84740815e2ecdaa9cd8	541	59	9830187	169813	0	323	\N	6447	t	0
238	\\x16b127ac376a8d44efa2821f7c2531a9da61ed938fc80fee7292b9e5258050d8	541	60	9490561	169813	0	323	\N	6447	t	0
239	\\xbca6f1b411481f5f93fd42ed4b763f8acc9ae492eef73ddd5ff3e49f7f1c87f9	541	61	1999879543271	168405	0	291	\N	6447	t	0
240	\\x064d08dfc04b91e55634c343c3357b1b6de4f5c5c6a981dd878ccbe54d0e9d1e	541	62	8981122	169813	0	323	\N	6447	t	0
241	\\x62a1c3ba7b9012fc65c5905ef253ba926828923409bc2329ce0c3ae66c51aabb	541	63	9830187	169813	0	323	\N	6447	t	0
242	\\x8d3121d4dfc9825a7029d21f2837b05a9cc8bebf1b70e8ac9262e0c8bd62ae38	541	64	2998932413417	168405	0	291	\N	6447	t	0
243	\\x259c898b4836141e7ab0294aedb1861b078a48c127bc92b2ead4163448b02dec	541	65	9660374	169813	0	323	\N	6447	t	0
244	\\xa99e0549fddf3025b70284a48471c2cbe7a9b8ae85803c42ed1c8e13e5cf0a1a	541	66	8811309	169813	0	323	\N	6447	t	0
245	\\x684185e04849456ea6b30143a2c4916a15185221d89a861eaf6cb75683c8119d	541	67	2998927245012	168405	0	291	\N	6447	t	0
246	\\xd5f4422e437448707c92527d26df1427a0c81c45637f9a62303be7a9e6877e1e	541	68	9830187	169813	0	323	\N	6447	t	0
247	\\x0ded90368516f0958c1e56b42bc4803eb88e228b8037797e8ac9d15b5ea5b5d1	541	69	9660374	169813	0	323	\N	6447	t	0
248	\\xb12ff597b1448be11dc4f6a22684f5612ddc0cf6b0265f0162057a7e03d52f92	541	70	11433927	169813	0	323	\N	6447	t	0
249	\\x943ac4b16088f8f6879b06cbcbcb07909481e7167a5ae703ddeaaab13aaf0d68	541	71	9830187	169813	0	323	\N	6447	t	0
250	\\x278f5edc1f69c7f87d3dbae02134eb8bc51301610666f5f31a62c364857fa932	542	0	10075423	169813	0	323	\N	6447	t	0
251	\\x2c0df2b822602bbadede08ec3f152935c9603153431bfd57cb885d03584b1a7c	542	1	1999874374866	168405	0	291	\N	6447	t	0
252	\\x4a812a3f1eb73ad4bf6427260cf77ec20c616299dc76627e2c1521e13b8998e5	542	2	9660374	169813	0	323	\N	6447	t	0
253	\\x5d064c52db6fa24aa2b4ea649e11f16240eee426bfac06f0eca14cd4e2677bcc	542	3	9830187	169813	0	323	\N	6447	t	0
254	\\x9d4b300bf5bf57adf14a4a9eaf0fd6dca519a3889072f3f5fd5c62b76ade3a43	542	4	9320748	169813	0	323	\N	6447	t	0
255	\\xcc87036350a6f3773b8bd2294f6ba0a3faad61d58cb72a71811083a7ca405b3c	542	5	9830187	169813	0	323	\N	6447	t	0
256	\\x91d2d0d20b06fd385fcecc5d6fa7fae1eeaf613ad039159bb3ae619df095c3d9	542	6	9830187	169813	0	323	\N	6447	t	0
257	\\xf9edbedb42b4430c0ea14fa2fa20aa8e97f6b2ba2c98585fa5d6e3ad24db5e2c	542	7	9320748	169813	0	323	\N	6457	t	0
258	\\x35b38bb4987fe71ec7de1c02d682fe932f0180611847a123f8309a6e6d382012	542	8	9735797	169813	0	323	\N	6457	t	0
259	\\x59ea6a98d329b84d9571ca3f092cde85ffae26981dc99d2a78579563a9fcc759	542	9	8981122	169813	0	323	\N	6457	t	0
260	\\x7ce65ee3b41985e34f4a59df2c17dfe6d652aad846d51d053b57ccaf499be652	542	10	9830187	169813	0	323	\N	6457	t	0
261	\\xf6e1a1236d534ceb5245a5a1dcc73a4c15396d9e2a022aa92f9971787fd3a167	542	11	1999869206461	168405	0	291	\N	6457	t	0
262	\\xa0adecc9b03eb803439e0f5accd780b31814bb09df70aaff25a011a75327548c	542	12	9830187	169813	0	323	\N	6457	t	0
263	\\xce28dd282c288b14fcdf7f80a3f0918c9f2d63b4114b5c147b287bf8b8bbf570	542	13	9660374	169813	0	323	\N	6457	t	0
264	\\x28abddd0c8fc4ea6fa0431c8dbe1a8dbbcb8888aeb1409498f22b107bed0cf66	542	14	9660374	169813	0	323	\N	6457	t	0
265	\\xd2ec7d415b95e3559b0665028f5a4bdb067709dc785e3cf17d2fdda2812c2a83	542	15	8886732	169813	0	323	\N	6457	t	0
266	\\xf559973cf3a4ae5f909569e065b400e2b71e90aba7c382c7896446ac579f022c	542	16	9830187	169813	0	323	\N	6457	t	0
267	\\xf381626ced6a9c6187056112638cc342cc42fc1f159abd8d400b792a665d1405	542	17	9830187	169813	0	323	\N	6457	t	0
268	\\x774bb1aab9b7c3c98856996a5319780dd633a055d9805e4df49094bad89abefe	542	18	1999868696846	169989	0	327	\N	6457	t	0
269	\\x36ad2f3737c1ea1bf5d74107581bea1e6b177be9aad1996bd541243570366b99	542	19	9490561	169813	0	323	\N	6457	t	0
270	\\x506b2c0a60ae849be1ab04278aa77e42cea0cd95e08d7dd6d7c69e515f40ea99	542	20	9320748	169813	0	323	\N	6457	t	0
271	\\x6eb483432078f6aaca6c7f24c031ac935d8795adaf7f6bd18e95c34b7332a99b	542	21	9490561	169813	0	323	\N	6457	t	0
272	\\x5b455ecf3cfa702a5168031e37a9161c281da3ab42db9ea1a96aacce99dce080	542	22	7698041	169813	0	323	\N	6457	t	0
273	\\x60ad19d0306ab26798440545f21d6d3fa494f93246873f7209aa8d247be24ac8	542	23	1999868017418	169989	0	327	\N	6457	t	0
274	\\xb0cace4329ddbe858b9f9ccfe7a8faaef7defa9a208dd4d2cda443ca50b8299c	542	24	9830187	169813	0	323	\N	6457	t	0
275	\\x159ded1529816359c29c921b9555ea97e1474c1de545dcc2338ffbd87dfc2d93	542	25	12187018	171397	0	359	\N	6457	t	0
276	\\xd72d6afee5dc93625fd23cc31d028acde71d74d1bbb5fbdfc1fbb247ff1ed461	542	26	9830187	169813	0	323	\N	6457	t	0
277	\\x90e271403406b0c7102baaf0463b146075f7c533fc71037525d987a46823097c	542	27	12017205	169813	0	323	\N	6457	t	0
278	\\xaf594ee22bc788407d9e4577b9ef6673f610153be679acb33c0ad18a174f72a7	731	0	3568576244	174345	0	426	\N	8444	t	0
279	\\xcc08d86514eebeb56a596951182746fa04f5b284cd9219ff69bfb00b04c21623	735	0	5002451558902	259221	2000000	2359	\N	8479	t	0
280	\\xa21d03a9eb64d814b4c86335967635cd7cbf610e49f7acb071ff68aaf0c6285d	913	0	1259379123257	174697	0	434	\N	10444	t	0
281	\\x1d91f02cc8ae04f69c483150aa6b5f1ee093e2c1b58fd7241ecc509c2f1ea7bd	913	1	39081486424	168405	0	291	\N	10444	t	0
282	\\xbd3c74c23b24048fe6680f8593b08eccf2d2a873db0a4dc2a4f9a4d2ee69c5b3	913	2	1259373954852	168405	0	291	\N	10444	t	0
283	\\xa5237a8dfa3daec03c7963ea7fe7113da81ade9ed0f6195fcf85a78e8e54005f	913	3	1259368786447	168405	0	291	\N	10444	t	0
284	\\x14bd283da842d59083eae8e4d476887f9af2a4a2a3ccbff274721c9756ab8ee6	913	4	625311307276	169989	0	327	\N	10444	t	0
285	\\x5e5fed07430a4c98922cfc425e056611c17f37dfa9a9ee470a5fb8f72fafd879	913	5	625306138871	168405	0	291	\N	10444	t	0
286	\\x98e0b03162e201001a4b6a9a7c796555da9a1069aef55fa1cd8ce6803492ab44	913	6	78163141253	168405	0	291	\N	10444	t	0
287	\\x608275d25b6f046fd831d3808cf8c5b785eeee2ef4a0a65b75ba968075ba44be	913	7	9830187	169813	0	323	\N	10444	t	0
288	\\xa4eac9f6045b4f5bb5c258713b667c6b37612aaeb969460681bca179e836c5fd	913	8	78163141253	168405	0	291	\N	10444	t	0
289	\\xedad2b8a7966d34912ec5b4cb9485d874fa920e9a598692b2ad464469b3fc4ec	913	9	156326450911	168405	0	291	\N	10444	t	0
290	\\xa4e07a646e65ed391f55fb9c8e8c3f1dfe81df5ab7ff9f1af97e4eebd5a7c0b2	913	10	312658068644	169989	0	327	\N	10444	t	0
291	\\xe8751a9d40558cda8fa65dc08f4f2db187c565c7eaefd5b8d0ed6309cece232d	913	11	625305968882	169989	0	327	\N	10444	t	0
292	\\xa3f4dbdf4005174ac3d63cb1ad53b534b3d94613e697236a0ec382d488aa0efb	913	12	625300800477	168405	0	291	\N	10444	t	0
293	\\x719e349c41650944b46cb0e4e0f3a0698efe32b8e0314d81826d2886693ad11b	913	13	156326450911	168405	0	291	\N	10444	t	0
294	\\x7decb70e99ad8628de340338a572959bd9bd06022baea6bb6b5cc1e5f3caaad2	913	14	9830187	169813	0	323	\N	10444	t	0
295	\\x92c7c9b8c162d81ec4c673b9ea53454d0b438401b9a5a5b40360a5dfa1c04f6b	913	15	78157972848	168405	0	291	\N	10444	t	0
296	\\x22bced831c901872fb0cef71ca2919507314d1a0e72f9cc47b48421e13c1e359	913	16	625311307277	169989	0	327	\N	10444	t	0
297	\\x7216115b12ee74216fa1ca3097912284ea57cb76643f62115268a3519667ba3a	913	17	39076318019	168405	0	291	\N	10444	t	0
298	\\xd87538ff4bd65281033d750e8b800adda6ffb433fde78bf83a5708f329537ce8	913	18	1250612786126	168405	0	291	\N	10444	t	0
299	\\xa6bc775dc071c064a520eb922818802f25cbffbc2aa821bd89a2f5da650b9118	913	19	39081486424	168405	0	291	\N	10444	t	0
300	\\x3cf969e4a6c14a2c9dc953cdf457f82b66b15375d3ad8e64c691c5a124fa79af	913	20	625311137288	169989	0	327	\N	10444	t	0
301	\\x7a9e937736c25c02d6a15efcd44a1280a2903eb745da6e0018ec1c129cfe2cf0	913	21	78152804443	168405	0	291	\N	10444	t	0
302	\\x64f35594c3ba7d40e9bc3078fa03190eaa92a4157d350a8bcc6ffd15214dd1b9	913	22	9830187	169813	0	323	\N	10444	t	0
303	\\x2d7faf2e4d5fec716191343b66319904d5391ba7f606503559be78f0a676006c	913	23	156321282506	168405	0	291	\N	10444	t	0
304	\\xe88dfad988a18b800c14605f15d3f9f37f520be653720019e723c430cc6f5c62	913	24	1250612616137	169989	0	327	\N	10444	t	0
305	\\xa58710d43f5bb1fad520b39c6b0713bfb428be2850d9dc5152eff369d535d3a8	913	25	9660374	169813	0	323	\N	10444	t	0
306	\\x4d5090d5612c0cf2d867136f9dbc1f72b0288c517ba51254918668cd99186192	913	26	625295632072	168405	0	291	\N	10444	t	0
307	\\x40697443dc0e37e420a9d7b4e1105e57821f70c93c78655369242eb703beaad3	913	27	625290463667	168405	0	291	\N	10444	t	0
308	\\xc47a4a8e199ad061b77a434e2878b7eac3e0cadf41710c61c14c6dc11b5f5c4e	913	28	39081486424	168405	0	291	\N	10444	t	0
309	\\x39cbfa07965123f353c79c4ea5412abecd84b219331d3068f0867cfd34ff99d8	913	29	625305968883	168405	0	291	\N	10444	t	0
310	\\xe66c3efb5a5469752710def33abd16363396faca3a0cf835be72c3d321e93bd7	913	30	1259363618042	168405	0	291	\N	10444	t	0
311	\\xba3dcb2b9aab6b9cc6f104fabaac5c6b9b3bd2c07acbe2573f24c6eab4fdcc66	913	31	39081486424	168405	0	291	\N	10444	t	0
312	\\xbd8cf1f2f87cd6a10eaa28e3e48355231458bccbc0e700cbac34c4c63059c310	913	32	9830187	169813	0	323	\N	10444	t	0
313	\\x366195cdd726042dcb5f1e15a00d57c6148068a9bf5f7ff77f14c3e735693d1f	913	33	9660374	169813	0	323	\N	10444	t	0
314	\\x8bcdd4bacbfbf9d7d8b97933d5587d000d9373dae63c914d8e822fbb713916c9	913	34	39076318019	168405	0	291	\N	10444	t	0
315	\\xe3800e14fa8ec426f17f74ddcac28139f82da4efb8c1a739e6258867f6953a49	913	35	9830187	169813	0	323	\N	10444	t	0
316	\\x6438467cc0d51ef2494582f6ced6b403928a6e8a2eb391c0219724c37faff27b	913	36	39071149614	168405	0	291	\N	10444	t	0
317	\\x110bba6dd2701d9d0c1823d380036dac3cbd2676206b7a87ad17c1927929903d	913	37	156316114101	168405	0	291	\N	10444	t	0
318	\\x6c9d6c2de5142bc6b0d7a94088e1af21e88983292f43358b5a69beff7c7e9068	913	38	78157972848	168405	0	291	\N	10444	t	0
319	\\x78b48dce0f2ec1493fee071de9eae21b3eeeb274e856ab5ee5d30a996542a534	913	39	39076318019	168405	0	291	\N	10444	t	0
320	\\xa006862ee5345ae2e32353bc037a045fa6f4cac9db4b2860ba294a32dd1c63f3	913	40	9660374	169813	0	323	\N	10444	t	0
321	\\x5835ed2bacc758aa0465de2415400cfe9dd56cc2ec29caaf7fa2655f5d0685d7	913	41	9830187	169813	0	323	\N	10444	t	0
322	\\x0fc76ebdd925ba842ecb8baed09b1b9338b5a0e1bea1897e10d78cc0adf69dc2	913	42	9660374	169813	0	323	\N	10444	t	0
323	\\x6a41740ba8d02d85aec74ff15cfcbf5e942940dcb4a3f31be64d5c4c15d4df8a	913	43	9830187	169813	0	323	\N	10444	t	0
324	\\x670cda2ff3d9db8fdf020f69e25496c7530c3238b220656a73251e4f8dd718e9	913	44	39071149614	168405	0	291	\N	10444	t	0
325	\\xa039ca4b44c73721abca4e6299502be9657f2b47328a6ff8493d40562032eaa9	913	45	312653070228	168405	0	291	\N	10444	t	0
326	\\x3ceb1a22f437949a22d6c9e62dd0e761d1eb561a424050889dd72addeb0474b8	913	46	39065981209	168405	0	291	\N	10444	t	0
327	\\x508f1a9b80a08fbb0548977aafcbb1b4263d990ba5e1c8520b86c6ec9422041b	913	47	156321282506	168405	0	291	\N	10444	t	0
328	\\x3426c0d52c62325494622475438bc8ec91dd94b41fc0fd40b9bf21e2f02b4cdc	913	48	78152804443	168405	0	291	\N	10444	t	0
329	\\x2ea8cf322e60985518c46a7ec7f132f57095c8bac3dd0faa07f9445d382d40b4	913	49	156310945696	168405	0	291	\N	10444	t	0
330	\\x2912fe277444df88bd91d55dab596026f691eb761fc4384ecc0888606ba859b9	913	50	312657898655	169989	0	327	\N	10444	t	0
331	\\x3c6b616f9c62264d0baf13dd966ec5b7e1b7b1a4400b56ea130415a5da6a0dd3	913	51	9490561	169813	0	323	\N	10444	t	0
332	\\x75b6ecd085974a2b7f4ee181fa3de8eb7245bec26325256492891c28ba13cddd	913	52	9150935	169813	0	323	\N	10444	t	0
333	\\x3a7c4089087a108ead29eae0e65a3489de4bf9f836ed5965495eb0db8854590c	913	53	9660374	169813	0	323	\N	10444	t	0
334	\\x4bb4236469191e97a39f098cec2e374e6206f8233ab914d97489c3d771e1d466	913	54	9830187	169813	0	323	\N	10444	t	0
335	\\x28c5370ce3db5d091e4f72cf88f6d97c896608041e0f75984e745e4ee736d706	913	55	1259358449637	168405	0	291	\N	10444	t	0
336	\\x1915aed05e18e806ec180f87ad7cd4433324700440db72cbf2e7048b8328ccca	913	56	9830187	169813	0	323	\N	10444	t	0
337	\\xe4ab303c4712397e81f328f3d6d155c8ce32f8a226d4ac328c21d8767e6ff053	913	57	39076318019	168405	0	291	\N	10444	t	0
338	\\x313774414f1885021744417233fe9e3b4fd4921f11133bef547a9d9302acdf88	913	58	156305777291	168405	0	291	\N	10444	t	0
339	\\x4b630b96963fc79012ef52b679be20ffe4493ab7349e5ef5f883750ca5670c1e	913	59	1259353281232	168405	0	291	\N	10444	t	0
340	\\xd8379a4f9913cbdf082366cb1b125e3385d3910db32fe0b0da1a6133a03c74a8	913	60	9830187	169813	0	323	\N	10444	t	0
341	\\xa01b4fac158f2bced690fb874ebc6781c28bada531c4c305ce4c687a7eeabff2	913	61	9490561	169813	0	323	\N	10444	t	0
342	\\x401a7c71888b3c1310ec19ef90aee340e99cccc45a3c755eda7a89c47afb27eb	913	62	9320748	169813	0	323	\N	10444	t	0
343	\\x14b8fc570b15dccd7369efbb01d756aa2493a4ee3b458f4877fc9b20d4f2814b	913	63	1250607447732	168405	0	291	\N	10444	t	0
344	\\x942aba8966d78299e872c033a07360f3bfa4f9355376ebb6759eed7ce7067663	913	64	39076148030	169989	0	327	\N	10444	t	0
345	\\xde924f437d15fade3ef07bdd8928a2ae72c00a3ae9feb4601bfd8f3dbdb2c719	913	65	9830187	169813	0	323	\N	10444	t	0
346	\\xe5e7e94305b48e30599139c8374e3671c1268761d3b0a687c87caa54e0da59aa	913	66	78147636038	168405	0	291	\N	10444	t	0
347	\\x00582d5a33cbbf77b629949062945e30e08a25468934e0e0f7727dd5bffb5308	913	67	9830187	169813	0	323	\N	10444	t	0
348	\\x07752ab7c62e13c9c6267834b1d08a2f6323f2e8bdc279565a71229415a7c654	913	68	156300608886	168405	0	291	\N	10444	t	0
349	\\x076fcb750b18824596287b0771c53cdf0172eef385771b9ac7526d20b40ebbc6	913	69	8641496	169813	0	323	\N	10444	t	0
350	\\x53151ab1ebad8008a31d7388d05bc349566124274075d09ab44084d56af05551	913	70	1250602279327	168405	0	291	\N	10444	t	0
351	\\x6c6ea2837d72c00ac72a1ef3a738b8bd28a1ab99e13d49c435e41c35b3cc022c	913	71	9830187	169813	0	323	\N	10444	t	0
352	\\x6c55471b268493e3898c8b27351aeced28ef7bc83f8f75c11747a474bd49bc3a	913	72	9830187	169813	0	323	\N	10444	t	0
353	\\x3637a0ed44f65c20670703551315279c92b9163eb080a2b038ea796b4df8d293	913	73	9490561	169813	0	323	\N	10444	t	0
354	\\x89bcc506e22aae575c26a0984293f63851a08f25a10d99398cc8be633c33d915	913	74	1250597110922	168405	0	291	\N	10444	t	0
355	\\x4842f858a9978f6f42d5c679acc092c8343e9d7a32cdf9acae8db3044ad4cc79	913	75	9830187	169813	0	323	\N	10444	t	0
356	\\x13721dbba62c18c62a6e56b9b733c147997258edc92c7656b749e8668fb622ff	913	76	9660374	169813	0	323	\N	10444	t	0
357	\\x0e7f45fadbfe3d82500e888583ed5eebb0f46a0e36d8a1bcb1039ba746ad4ab2	913	77	156316114101	168405	0	291	\N	10444	t	0
358	\\xa02f4ac94efea7afcd9371ce1937bde4970df5201218d730e5f9cc14be1aa29f	913	78	9660374	169813	0	323	\N	10444	t	0
359	\\xf229f552d23329c25afc5d1c03258aee6467448da119095f865a43b49c5721e6	913	79	9830187	169813	0	323	\N	10444	t	0
360	\\x7d7900cbc1b95b73d02faca8e8e8463e80adcf06874817c314f55ac32fe618e0	913	80	39074619537	169989	0	327	\N	10444	t	0
361	\\x96b6239627347cf084a4f879c2fac74812bb77653ae5fba7fc032cd0893767a0	913	81	9320748	169813	0	323	\N	10444	t	0
362	\\xad71a801481ea2a948c70579ce2126fc9aa4fea5baeba2419628b424f4941f55	913	82	9830187	169813	0	323	\N	10444	t	0
363	\\x79ae6ec40aeb0fea210a75a59348d8868c0662a52bf177a7f9fc747bfbc8c75b	913	83	312652730250	168405	0	291	\N	10444	t	0
364	\\x1062d7c06052fbe9c0d044e85dcbefbf50832612dbdedc268d20c176c5441268	913	84	9150935	169813	0	323	\N	10444	t	0
365	\\xda057bee6bc9b1c7f898ee715eea8ada5095990c127f1702ad40945675266567	913	85	39065811220	169989	0	327	\N	10444	t	0
366	\\x1e3bce0b925a797c031e457853d7455b9032d2231c4581e59760ce783a71c698	913	86	9830187	169813	0	323	\N	10444	t	0
367	\\x02c68fae295d14e3fc5f638108e10c54e4dce7907bee7caf25928f5715bd6e13	913	87	312647561845	168405	0	291	\N	10444	t	0
368	\\x515d4ab977baac164cbc32cb51431f0bf711f5f4897d80ea06d6e686539cb279	913	88	9660374	169813	0	323	\N	10444	t	0
369	\\x23e59cfa9ace0e82c0cc9307ea8439271360a8501940bbe4c48e67d11d280775	913	89	625289954052	169989	0	327	\N	10444	t	0
370	\\x4d5da49dc3e33268c696e1c436f413d1e80b7c13279d4167852cfc10c646ec5a	913	90	9830187	169813	0	323	\N	10444	t	0
371	\\x96653c9aae8f392f288606c5bbc830423418465b6495a66ad2b8fb9f49ad9e42	913	91	9660374	169813	0	323	\N	10444	t	0
372	\\x148f6897986c8dc0963afa04bcde1e621b5b7a45ddd6476be403418b7210e892	913	92	9830187	169813	0	323	\N	10444	t	0
373	\\x3feca998aeb0b2dc6cc41ce6f654dc496eb0cf73e078a92ea4d291e1eb5677a4	913	93	9830187	169813	0	323	\N	10444	t	0
374	\\x43d88edaf60f27b056bf4e28c3404b2f224fb8866d46aa0b9a40e10257b9275a	913	94	9660374	169813	0	323	\N	10444	t	0
375	\\x2f76b47036ae0cd553bc8749ce10428b94c19e6cc51cd1ae7d68b327594224e1	913	95	9830187	169813	0	323	\N	10444	t	0
376	\\x49d7e186a08ebd3dfd229868092c57f02f12f3119a53b6c46c21227be4b6cc98	913	96	156310945696	168405	0	291	\N	10444	t	0
377	\\xffa7964ed663c83b20626f7dc7f4693f44da7dfe0b9be41861b1054467f007fd	913	97	156295440481	168405	0	291	\N	10444	t	0
378	\\xbcb57ab66f6fe8c777dc6365c1a9547a346f898758300bbd43844b6535b6e413	913	98	9830187	169813	0	323	\N	10444	t	0
379	\\xaf35790001660e1b2a2d82e769c7c7e95df5514b54ef8c4e55b0ebfd1021c93d	913	99	9490561	169813	0	323	\N	10444	t	0
380	\\x9c25c71fc7d6aa023893983ece1cb5b9cd4e47c6150a7022c729455f6d80eeef	1140	0	8152040023	180725	0	571	\N	12442	t	0
381	\\x2598d6f7d6c5f66b8f53965483350556cdd1ed079226e8ec9751496eafa217b2	1147	0	4999499820111	179889	500000000	552	\N	12515	t	0
382	\\x85fe05f4f0a38f33fbc25dd12b5261c804b8d703950c88f55b186216b3b7cc9f	1151	0	4999494650122	169989	2000000	327	\N	12563	t	0
383	\\xa43b751052b83b079592da92b86abdd223f5ef58c28edddd4723d309a0eb0f5d	1155	0	4999494472785	177337	0	494	\N	12625	t	0
384	\\x17e3c5ae4d7e08b0ecffdc392e0c69b726cdc8dc5c09d356bcea1c20c4a1884b	1160	0	4999519811355	188645	500000000	751	\N	12642	t	0
385	\\x35399fa0cd6720e5eb219da244177d33056f517a0d6c1b1d8f631598ec10a6c1	1164	0	10825435	174565	2000000	431	\N	12701	t	0
386	\\x2e157b145d760931f89afdb4508125cef35f5e04a951e22a304510b1b2e14eee	1168	0	10645106	180329	0	562	\N	12731	t	0
387	\\x904f89b36fb7a800b9c9fd3e017f91695a10dc0d3fa5d539494ed9f1fa3cf5bd	1173	0	312647835383	234845	0	1700	\N	12744	t	0
388	\\xfd4115749133e1c7e75512fa54a245348b18150210d6eae3ab6722bbd96c1db1	1177	0	1250591888793	222129	0	1411	\N	12780	t	0
389	\\x69aa725b07ebbeb99508ae0ef2c2996c5d37b5e20ffa75d321d89b15af501f14	1181	0	14774043	225957	0	1498	\N	12808	t	0
390	\\xf0040db4f2aafd0961058dfac29c879b0f2a92086808c72989551841dc88a80b	1185	0	78147613070	191373	0	712	\N	12856	t	0
\.


--
-- Data for Name: tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_in (id, tx_in_id, tx_out_id, tx_out_index, redeemer_id) FROM stdin;
1	35	12	0	\N
2	36	13	0	\N
3	37	24	0	\N
4	38	16	0	\N
5	39	14	0	\N
6	40	21	0	\N
7	41	19	0	\N
8	42	26	0	\N
9	43	30	0	\N
10	44	20	0	\N
11	45	29	0	\N
12	46	35	0	\N
13	47	36	0	\N
14	48	37	0	\N
15	49	38	0	\N
16	50	39	0	\N
17	51	40	0	\N
18	52	41	0	\N
19	53	42	0	\N
20	54	43	0	\N
21	55	44	0	\N
22	56	45	0	\N
23	57	37	1	\N
24	58	43	1	\N
25	59	42	1	\N
26	60	44	1	\N
27	61	35	1	\N
28	62	36	1	\N
29	63	38	1	\N
30	64	40	1	\N
31	65	41	1	\N
32	66	45	1	\N
33	67	39	1	\N
34	68	64	1	\N
35	69	65	1	\N
36	70	63	1	\N
37	71	59	1	\N
38	72	67	1	\N
39	73	57	1	\N
40	74	66	1	\N
41	75	62	1	\N
42	76	60	1	\N
43	77	58	1	\N
44	78	61	1	\N
45	79	77	0	\N
46	80	71	0	\N
47	81	69	0	\N
48	82	68	0	\N
49	83	70	0	\N
50	84	72	0	\N
51	85	76	0	\N
52	86	75	0	\N
53	87	73	0	\N
54	88	78	0	\N
55	89	74	0	\N
56	90	54	0	\N
57	91	52	0	\N
58	92	49	0	\N
59	93	46	0	\N
60	94	55	0	\N
61	95	56	0	\N
62	96	48	0	\N
63	97	53	0	\N
64	98	51	0	\N
65	99	47	0	\N
66	100	50	0	\N
67	101	90	0	\N
68	102	93	0	\N
69	103	95	0	\N
70	104	94	0	\N
71	105	91	0	\N
72	106	98	0	\N
73	107	97	0	\N
74	108	99	0	\N
75	109	100	0	\N
76	110	92	0	\N
77	111	96	0	\N
78	112	107	0	\N
79	113	103	0	\N
80	114	104	0	\N
81	115	101	0	\N
82	116	85	0	\N
83	117	89	0	\N
84	118	79	0	\N
85	119	80	0	\N
86	120	86	0	\N
87	121	120	0	1
88	122	120	1	\N
89	123	122	1	\N
90	124	123	1	\N
91	125	124	1	\N
92	126	125	1	\N
93	127	126	1	\N
94	128	127	0	2
95	128	127	1	\N
96	129	88	0	\N
97	130	87	0	\N
98	131	130	0	\N
99	132	131	1	\N
100	133	132	1	\N
101	134	133	1	\N
102	135	134	1	\N
103	136	134	0	\N
104	136	135	0	\N
105	137	135	1	\N
106	138	137	0	\N
107	138	136	0	\N
108	138	136	1	\N
109	139	138	1	\N
110	140	139	1	\N
111	141	138	0	\N
112	142	140	0	\N
113	143	142	1	\N
114	144	142	0	\N
115	144	143	0	\N
116	145	144	0	\N
117	146	145	0	\N
118	147	146	0	\N
119	147	143	1	\N
120	148	147	0	\N
121	149	148	0	\N
122	150	147	1	\N
123	150	145	1	\N
124	151	150	0	\N
125	151	149	0	\N
126	152	151	1	\N
127	152	150	1	\N
128	153	152	1	\N
129	154	153	0	\N
130	154	151	0	\N
131	155	153	1	\N
132	155	154	0	\N
133	155	154	1	\N
134	155	152	0	\N
135	156	155	0	\N
136	157	156	0	\N
137	158	157	0	\N
138	158	156	1	\N
139	159	158	0	\N
140	160	159	0	\N
141	160	158	1	\N
142	161	160	0	\N
143	161	160	1	\N
144	161	160	2	\N
145	161	160	3	\N
146	161	160	4	\N
147	161	160	5	\N
148	161	160	6	\N
149	161	160	7	\N
150	161	160	8	\N
151	161	160	9	\N
152	161	160	10	\N
153	161	160	11	\N
154	161	160	12	\N
155	161	160	13	\N
156	161	160	14	\N
157	161	160	15	\N
158	161	160	16	\N
159	161	160	17	\N
160	161	160	18	\N
161	161	160	19	\N
162	161	160	20	\N
163	161	160	21	\N
164	161	160	22	\N
165	161	160	23	\N
166	161	160	24	\N
167	161	160	25	\N
168	161	160	26	\N
169	161	160	27	\N
170	161	160	28	\N
171	161	160	29	\N
172	161	160	30	\N
173	161	160	31	\N
174	161	160	32	\N
175	161	160	33	\N
176	161	160	34	\N
177	161	160	35	\N
178	161	160	36	\N
179	161	160	37	\N
180	161	160	38	\N
181	161	160	39	\N
182	161	160	40	\N
183	161	160	41	\N
184	161	160	42	\N
185	161	160	43	\N
186	161	160	44	\N
187	161	160	45	\N
188	161	160	46	\N
189	161	160	47	\N
190	161	160	48	\N
191	161	160	49	\N
192	161	160	50	\N
193	161	160	51	\N
194	161	160	52	\N
195	161	160	53	\N
196	161	160	54	\N
197	161	160	55	\N
198	161	160	56	\N
199	161	160	57	\N
200	161	160	58	\N
201	161	160	59	\N
202	162	161	0	\N
203	162	160	60	\N
204	162	160	61	\N
205	162	160	62	\N
206	162	160	63	\N
207	162	160	64	\N
208	162	160	65	\N
209	162	160	66	\N
210	162	160	67	\N
211	162	160	68	\N
212	162	160	69	\N
213	162	160	70	\N
214	162	160	71	\N
215	162	160	72	\N
216	162	160	73	\N
217	162	160	74	\N
218	162	160	75	\N
219	162	160	76	\N
220	162	160	77	\N
221	162	160	78	\N
222	162	160	79	\N
223	162	160	80	\N
224	162	160	81	\N
225	162	160	82	\N
226	162	160	83	\N
227	162	160	84	\N
228	162	160	85	\N
229	162	160	86	\N
230	162	160	87	\N
231	162	160	88	\N
232	162	160	89	\N
233	162	160	90	\N
234	162	160	91	\N
235	162	160	92	\N
236	162	160	93	\N
237	162	160	94	\N
238	162	160	95	\N
239	162	160	96	\N
240	162	160	97	\N
241	162	160	98	\N
242	162	160	99	\N
243	162	160	100	\N
244	162	160	101	\N
245	162	160	102	\N
246	162	160	103	\N
247	162	160	104	\N
248	162	160	105	\N
249	162	160	106	\N
250	162	160	107	\N
251	162	160	108	\N
252	162	160	109	\N
253	162	160	110	\N
254	162	160	111	\N
255	162	160	112	\N
256	162	160	113	\N
257	162	160	114	\N
258	162	160	115	\N
259	162	160	116	\N
260	162	160	117	\N
261	162	160	118	\N
262	162	160	119	\N
263	163	162	0	\N
264	163	162	1	\N
265	164	163	0	\N
266	165	163	1	\N
267	166	165	1	\N
268	167	166	0	\N
269	168	166	1	\N
270	169	168	0	\N
271	170	169	1	\N
272	171	164	1	\N
273	172	171	0	\N
274	173	172	0	\N
275	173	172	1	\N
276	173	172	2	\N
277	173	172	3	\N
278	173	172	4	\N
279	173	172	5	\N
280	173	172	6	\N
281	173	172	7	\N
282	173	172	8	\N
283	173	172	9	\N
284	173	172	10	\N
285	173	172	11	\N
286	173	172	12	\N
287	173	172	13	\N
288	173	172	14	\N
289	173	172	15	\N
290	173	172	16	\N
291	173	172	17	\N
292	173	172	18	\N
293	173	172	19	\N
294	173	172	20	\N
295	173	172	21	\N
296	173	172	22	\N
297	173	172	23	\N
298	173	172	24	\N
299	173	172	25	\N
300	173	172	26	\N
301	173	172	27	\N
302	173	172	28	\N
303	173	172	29	\N
304	173	172	30	\N
305	173	172	31	\N
306	173	172	32	\N
307	173	172	33	\N
308	173	172	34	\N
309	174	173	0	\N
310	175	168	1	\N
311	176	164	0	\N
312	177	169	0	\N
313	177	175	1	\N
314	178	177	0	\N
315	179	171	1	\N
316	180	176	0	\N
317	180	179	1	\N
318	181	178	1	\N
319	182	181	1	\N
320	183	167	0	\N
321	183	181	0	\N
322	183	179	0	\N
323	184	180	0	\N
324	184	178	0	\N
325	185	183	0	\N
326	185	183	1	\N
327	186	184	0	\N
328	186	184	1	\N
329	187	182	1	\N
330	188	185	1	\N
331	188	186	0	\N
332	189	185	0	\N
333	189	186	1	\N
334	190	188	1	\N
335	190	182	0	\N
336	191	165	0	\N
337	192	190	0	\N
338	192	191	0	\N
339	193	189	0	\N
340	193	189	1	\N
341	194	187	1	\N
342	195	194	0	\N
343	195	193	1	\N
344	196	195	0	\N
345	196	193	0	\N
346	197	194	1	\N
347	198	197	1	\N
348	199	198	0	\N
349	199	190	1	\N
350	200	198	1	\N
351	201	192	1	\N
352	201	199	0	\N
353	202	201	1	\N
354	202	187	0	\N
355	203	200	1	\N
356	204	197	0	\N
357	204	191	1	\N
358	205	188	0	\N
359	205	201	0	\N
360	206	205	0	\N
361	206	196	0	\N
362	207	204	0	\N
363	207	199	1	\N
364	208	195	1	\N
365	208	202	1	\N
366	209	204	1	\N
367	209	202	0	\N
368	210	206	0	\N
369	210	200	0	\N
370	211	209	1	\N
371	211	210	0	\N
372	212	205	1	\N
373	212	207	0	\N
374	213	180	1	\N
375	214	203	1	\N
376	215	211	0	\N
377	215	203	0	\N
378	216	208	1	\N
379	216	215	1	\N
380	217	216	1	\N
381	217	196	1	\N
382	218	216	0	\N
383	218	217	1	\N
384	219	210	1	\N
385	219	207	1	\N
386	220	219	1	\N
387	220	217	0	\N
388	221	213	0	\N
389	221	220	0	\N
390	222	221	1	\N
391	222	212	0	\N
392	223	218	0	\N
393	223	220	1	\N
394	224	213	1	\N
395	225	209	0	\N
396	225	218	1	\N
397	225	211	1	\N
398	226	224	1	\N
399	227	208	0	\N
400	227	223	0	\N
401	228	226	0	\N
402	228	225	1	\N
403	229	214	0	\N
404	229	224	0	\N
405	230	227	1	\N
406	230	219	0	\N
407	231	214	1	\N
408	232	231	0	\N
409	232	228	0	\N
410	233	206	1	\N
411	233	230	1	\N
412	234	229	0	\N
413	234	229	1	\N
414	235	226	1	\N
415	235	223	1	\N
416	236	234	0	\N
417	236	222	0	\N
418	237	225	0	\N
419	237	230	0	\N
420	238	221	0	\N
421	238	234	1	\N
422	239	231	1	\N
423	240	236	1	\N
424	240	233	1	\N
425	241	236	0	\N
426	241	215	0	\N
427	242	235	1	\N
428	243	192	0	\N
429	243	237	1	\N
430	244	240	1	\N
431	244	239	0	\N
432	245	242	1	\N
433	246	235	0	\N
434	246	237	0	\N
435	247	243	0	\N
436	247	232	1	\N
437	248	245	0	\N
438	248	228	1	\N
439	249	227	0	\N
440	249	232	0	\N
441	250	244	1	\N
442	250	248	1	\N
443	251	239	1	\N
444	252	241	1	\N
445	252	246	0	\N
446	253	233	0	\N
447	253	244	0	\N
448	254	238	1	\N
449	254	242	0	\N
450	255	252	0	\N
451	255	241	0	\N
452	256	240	0	\N
453	256	249	0	\N
454	257	252	1	\N
455	257	246	1	\N
456	258	250	1	\N
457	258	256	1	\N
458	259	253	1	\N
459	259	254	1	\N
460	260	250	0	\N
461	260	257	0	\N
462	261	251	1	\N
463	262	238	0	\N
464	262	260	0	\N
465	263	260	1	\N
466	263	248	0	\N
467	264	254	0	\N
468	264	262	1	\N
469	265	258	1	\N
470	265	257	1	\N
471	266	262	0	\N
472	266	255	0	\N
473	267	263	0	\N
474	267	266	0	\N
475	268	263	1	\N
476	268	261	1	\N
477	269	243	1	\N
478	269	268	0	\N
479	270	264	1	\N
480	270	249	1	\N
481	271	247	1	\N
482	271	258	0	\N
483	272	259	1	\N
484	272	265	1	\N
485	273	271	1	\N
486	273	268	1	\N
487	274	269	0	\N
488	274	270	0	\N
489	275	272	1	\N
490	275	255	1	\N
491	275	267	1	\N
492	276	259	0	\N
493	276	271	0	\N
494	277	247	0	\N
495	277	275	1	\N
496	278	212	1	\N
497	279	275	0	\N
498	279	264	0	\N
499	279	251	0	\N
500	279	269	1	\N
501	279	270	1	\N
502	279	272	0	\N
503	279	253	0	\N
504	279	273	0	\N
505	279	273	1	\N
506	279	245	1	\N
507	279	277	0	\N
508	279	277	1	\N
509	279	256	0	\N
510	279	222	1	\N
511	279	278	0	\N
512	279	278	1	\N
513	279	274	0	\N
514	279	274	1	\N
515	279	265	0	\N
516	279	276	0	\N
517	279	276	1	\N
518	279	267	0	\N
519	279	266	1	\N
520	279	261	0	\N
521	280	279	0	\N
522	281	279	10	\N
523	282	280	1	\N
524	283	282	1	\N
525	284	282	0	\N
526	284	279	3	\N
527	285	284	1	\N
528	286	279	8	\N
529	287	284	0	\N
530	287	285	0	\N
531	288	279	9	\N
532	289	279	7	\N
533	290	281	0	\N
534	290	279	4	\N
535	291	285	1	\N
536	291	288	0	\N
537	292	291	1	\N
538	293	279	6	\N
539	294	292	0	\N
540	294	289	0	\N
541	295	288	1	\N
542	296	283	0	\N
543	296	279	2	\N
544	297	281	1	\N
545	298	279	1	\N
546	299	279	13	\N
547	300	296	1	\N
548	300	298	0	\N
549	301	295	1	\N
550	302	287	0	\N
551	302	286	0	\N
552	303	289	1	\N
553	304	299	0	\N
554	304	298	1	\N
555	305	302	1	\N
556	305	291	0	\N
557	306	292	1	\N
558	307	306	1	\N
559	308	279	11	\N
560	309	300	1	\N
561	310	283	1	\N
562	311	279	12	\N
563	312	296	0	\N
564	312	300	0	\N
565	313	287	1	\N
566	313	310	0	\N
567	314	308	1	\N
568	315	280	0	\N
569	315	304	0	\N
570	316	314	1	\N
571	317	303	1	\N
572	318	286	1	\N
573	319	311	1	\N
574	320	316	0	\N
575	320	315	1	\N
576	321	306	0	\N
577	321	318	0	\N
578	322	317	0	\N
579	322	294	1	\N
580	323	301	0	\N
581	323	314	0	\N
582	324	319	1	\N
583	325	279	5	\N
584	326	316	1	\N
585	327	293	1	\N
586	328	318	1	\N
587	329	317	1	\N
588	330	327	0	\N
589	330	290	1	\N
590	331	309	0	\N
591	331	305	1	\N
592	332	331	1	\N
593	332	312	1	\N
594	333	323	1	\N
595	333	295	0	\N
596	334	329	0	\N
597	334	290	0	\N
598	335	310	1	\N
599	336	303	0	\N
600	336	319	0	\N
601	337	299	1	\N
602	338	329	1	\N
603	339	335	1	\N
604	340	328	0	\N
605	340	325	0	\N
606	341	320	1	\N
607	341	305	0	\N
608	342	322	1	\N
609	342	340	1	\N
610	343	304	1	\N
611	344	339	0	\N
612	344	297	1	\N
613	345	338	0	\N
614	345	324	0	\N
615	346	328	1	\N
616	347	333	0	\N
617	347	331	0	\N
618	348	338	1	\N
619	349	333	1	\N
620	349	332	1	\N
621	350	343	1	\N
622	351	332	0	\N
623	351	308	0	\N
624	352	351	0	\N
625	352	337	0	\N
626	353	313	1	\N
627	353	307	0	\N
628	354	350	1	\N
629	355	353	0	\N
630	355	297	0	\N
631	356	321	1	\N
632	356	293	0	\N
633	357	327	1	\N
634	358	312	0	\N
635	358	345	1	\N
636	359	343	0	\N
637	359	341	0	\N
638	360	349	1	\N
639	360	344	1	\N
640	361	360	0	\N
641	361	341	1	\N
642	362	322	0	\N
643	362	356	0	\N
644	363	330	1	\N
645	364	326	0	\N
646	364	361	1	\N
647	365	349	0	\N
648	365	326	1	\N
649	366	342	0	\N
650	366	365	0	\N
651	367	363	1	\N
652	368	334	1	\N
653	368	345	0	\N
654	369	307	1	\N
655	369	358	1	\N
656	370	336	0	\N
657	370	311	0	\N
658	371	334	0	\N
659	371	362	1	\N
660	372	366	0	\N
661	372	363	0	\N
662	373	364	0	\N
663	373	370	0	\N
664	374	336	1	\N
665	374	346	0	\N
666	375	372	0	\N
667	375	371	0	\N
668	376	357	1	\N
669	377	348	1	\N
670	378	368	0	\N
671	378	358	0	\N
672	379	375	1	\N
673	379	378	1	\N
674	380	294	0	\N
675	381	130	2	\N
676	382	381	1	\N
677	383	381	0	\N
678	383	382	1	\N
679	384	130	4	\N
680	384	129	0	\N
681	384	132	0	\N
682	385	384	0	\N
683	385	131	0	\N
684	386	385	0	\N
685	386	385	1	\N
686	387	325	1	\N
687	388	354	1	\N
688	389	348	0	\N
689	389	374	0	\N
690	389	354	0	\N
691	390	301	1	\N
\.


--
-- Data for Name: tx_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_metadata (id, key, json, bytes, tx_id) FROM stdin;
1	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "testhandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "testhandle", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": "ipfs://some-hash", "website": "https://cardano.org/", "mediaType": "image/jpeg", "description": "The Handle Standard", "augmentations": []}, "hellohandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "hellohandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "doublehandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "doublehandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a460a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656067776562736974657468747470733a2f2f63617264616e6f2e6f72672f6c646f75626c6568616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656c646f75626c6568616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6b68656c6c6f68616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656b68656c6c6f68616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6a7465737468616e646c65a86d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e646172646566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e7965696d61676570697066733a2f2f736f6d652d68617368696d65646961547970656a696d6167652f6a706567646e616d656a7465737468616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f	131
2	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	134
3	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16568616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65662468616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	135
4	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"sub@handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$sub@handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a1697375624068616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656a247375624068616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	136
5	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"virtual@handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$virtual@handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16d7669727475616c4068616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656e247669727475616c4068616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	137
6	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	142
7	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	143
8	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	145
9	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	147
10	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"NFT-001": {"name": "One", "image": ["ipfs://some_hash1"], "version": "1.0"}, "NFT-002": {"name": "Two", "image": ["ipfs://some_hash2"], "version": "1.0"}, "NFT-files": {"id": "1", "name": "NFT with files", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": ["ipfs://somehash"], "version": "1.0", "mediaType": "image/png", "description": ["NFT with different types of files"]}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a3674e46542d303031a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65634f6e656776657273696f6e63312e30674e46542d303032a365696d6167658171697066733a2f2f736f6d655f6861736832646e616d656354776f6776657273696f6e63312e30694e46542d66696c6573a76b6465736372697074696f6e8178214e4654207769746820646966666572656e74207479706573206f662066696c65736566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e79626964613165696d616765816f697066733a2f2f736f6d6568617368696d656469615479706569696d6167652f706e67646e616d656e4e465420776974682066696c65736776657273696f6e63312e30	150
11	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"4349502d303032352d76312d686578": {"name": "CIP-0025-v1-hex", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1781e343334393530326433303330333233353264373633313264363836353738a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656f4349502d303032352d76312d6865786776657273696f6e63312e30	152
12	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"CIP-0025-v1-utf8": {"name": "CIP-0025-v1-utf8", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1704349502d303032352d76312d75746638a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65704349502d303032352d76312d757466386776657273696f6e63312e30	153
13	721	{"0x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"0x4349502d303032352d7632": {"name": "CIP-0025-v2", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a1581c17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029a14b4349502d303032352d7632a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656b4349502d303032352d76326776657273696f6e63312e30	154
14	123	"1234"	\\xa1187b6431323334	164
15	6862	{"name": "Test Portfolio", "pools": [{"id": "5184abbee848085c6810c24cc15283ab7a0430fa692376e2475f1942", "weight": 1}, {"id": "87ad04cc317b495d3fb91eea91bf60581ac7fdd121cb41a4f0cb2ada", "weight": 1}, {"id": "15bbe95e0a926881dd3a6bac4a39c62bd35fbe6e2db352904bd9d55e", "weight": 1}, {"id": "2f86c2b5a057fdee5faa531e62ed1a5037e2753b88b4970bcf76f36a", "weight": 1}, {"id": "4532e25b9f4bf6997bea1c9ea509204347d9575935875b7b38995ba5", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783835313834616262656538343830383563363831306332346363313532383361623761303433306661363932333736653234373566313934326677656967687401a2626964783838376164303463633331376234393564336662393165656139316266363035383161633766646431323163623431613466306362326164616677656967687401a2626964783831356262653935653061393236383831646433613662616334613339633632626433356662653665326462333532393034626439643535656677656967687401a2626964783832663836633262356130353766646565356661613533316536326564316135303337653237353362383862343937306263663736663336616677656967687401a2626964783834353332653235623966346266363939376265613163396561353039323034333437643935373539333538373562376233383939356261356677656967687401	172
16	6862	{"name": "Test Portfolio", "pools": [{"id": "5184abbee848085c6810c24cc15283ab7a0430fa692376e2475f1942", "weight": 0}, {"id": "87ad04cc317b495d3fb91eea91bf60581ac7fdd121cb41a4f0cb2ada", "weight": 0}, {"id": "15bbe95e0a926881dd3a6bac4a39c62bd35fbe6e2db352904bd9d55e", "weight": 0}, {"id": "2f86c2b5a057fdee5faa531e62ed1a5037e2753b88b4970bcf76f36a", "weight": 0}, {"id": "4532e25b9f4bf6997bea1c9ea509204347d9575935875b7b38995ba5", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783835313834616262656538343830383563363831306332346363313532383361623761303433306661363932333736653234373566313934326677656967687400a2626964783838376164303463633331376234393564336662393165656139316266363035383161633766646431323163623431613466306362326164616677656967687400a2626964783831356262653935653061393236383831646433613662616334613339633632626433356662653665326462333532393034626439643535656677656967687400a2626964783832663836633262356130353766646565356661613533316536326564316135303337653237353362383862343937306263663736663336616677656967687400a2626964783834353332653235623966346266363939376265613163396561353039323034333437643935373539333538373562376233383939356261356677656967687401	173
17	6862	{"pools": [{"id": "87ad04cc317b495d3fb91eea91bf60581ac7fdd121cb41a4f0cb2ada", "weight": 1}]}	\\xa1191acea165706f6f6c7381a2626964783838376164303463633331376234393564336662393165656139316266363035383161633766646431323163623431613466306362326164616677656967687401	175
18	6862	{"name": "Test Portfolio", "pools": [{"id": "5184abbee848085c6810c24cc15283ab7a0430fa692376e2475f1942", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7381a2626964783835313834616262656538343830383563363831306332346363313532383361623761303433306661363932333736653234373566313934326677656967687401	177
19	6862	{"name": "Test Portfolio", "pools": [{"id": "5184abbee848085c6810c24cc15283ab7a0430fa692376e2475f1942", "weight": 1}, {"id": "87ad04cc317b495d3fb91eea91bf60581ac7fdd121cb41a4f0cb2ada", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7382a2626964783835313834616262656538343830383563363831306332346363313532383361623761303433306661363932333736653234373566313934326677656967687401a2626964783838376164303463633331376234393564336662393165656139316266363035383161633766646431323163623431613466306362326164616677656967687401	279
20	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	387
21	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16568616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65662468616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	388
22	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"sub@handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$sub@handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a1697375624068616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656a247375624068616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	389
23	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"virtual@handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$virtual@handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16d7669727475616c4068616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656e247669727475616c4068616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	390
\.


--
-- Data for Name: tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_out (id, tx_id, index, address, address_has_script, payment_cred, stake_address_id, value, data_hash, inline_datum_id, reference_script_id) FROM stdin;
1	1	0	5oP9ib6ym3XY9RP3mrXSoeF3imTHWJP9Di4gH1FjFWNEVXT4QU32f7xdzotQRX6KeM	f	\N	\N	910909092	\N	\N	\N
2	2	0	5oP9ib6ym3XZWjxBdmkiXaQVoPh9ZvYNpUhpuTDdTjZ4o7kE93Jr6gUVF4ZtThLXHC	f	\N	\N	910909092	\N	\N	\N
3	3	0	5oP9ib6ym3Xa5osNLsib2ySPn9FAzaSEvGqM7zwcLHEZJJQ2zF5KXcCQCPppP1D2qf	f	\N	\N	910909092	\N	\N	\N
4	4	0	5oP9ib6ym3XcRB22tekzdXMY5Y6s7qGy7NDNgVzzku8YxFbTGfvzEr915FWuyr56E2	f	\N	\N	910909092	\N	\N	\N
5	5	0	5oP9ib6ym3Xcpn4KCJRumP26hzvh7o51o2EQ82mxFoyKnmhyLR4jFEdBtwdnH361q7	f	\N	\N	910909092	\N	\N	\N
6	6	0	5oP9ib6ym3Xcr868d2unvYPkutkCttRFN7YVr6dGawdq4ifULJ5fozPU5wd9VdB7AQ	f	\N	\N	910909092	\N	\N	\N
7	7	0	5oP9ib6ym3XfmyNZm2MmZNyJi3Zd8XYWuM1dP4WqX6BuNrFbNvLPVAipWCjZji9wMy	f	\N	\N	910909092	\N	\N	\N
8	8	0	5oP9ib6ym3XfzT9hp2corYtkLDnjKT85uLtFGYx6tC91NtMUjPftasumsEp6ye1RSh	f	\N	\N	910909092	\N	\N	\N
9	9	0	5oP9ib6ym3Xh5FGN8XDQqtFtM1QP5F8E84eWL61dhi2NKLoojKmhmw9ktKGgo9ShGp	f	\N	\N	910909092	\N	\N	\N
10	10	0	5oP9ib6ym3XhPyPuWSgkTv9isjkuExHVY4hjEh7tC4YK8UMzuAcH44KHa3ahUnNrrr	f	\N	\N	910909092	\N	\N	\N
11	11	0	5oP9ib6ym3XhXyUmBDhXDc24eF2Qgpb8T1D21wyxeW6EJ9iwrEqgP2dPvo7Gv9ZHCt	f	\N	\N	910909092	\N	\N	\N
12	12	0	addr_test1vr95t3q0tm8lx0slvrsh6as6euax2478658jup770s7g56g57nmhv	f	\\xcb45c40f5ecff33e1f60e17d761acf3a6557c7d50f2e07de7c3c8a69	\N	3681818181818181	\N	\N	\N
13	13	0	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	3681818181818181	\N	\N	\N
14	14	0	addr_test1vreuz7kh8glzxtwasy82emj2smkuz0sk5cnht3d23pjhencyz725z	f	\\xf3c17ad73a3e232ddd810eacee4a86edc13e16a62775c5aa88657ccf	\N	3681818181818190	\N	\N	\N
15	15	0	addr_test1qps7nymeyn6m7ct9w07cjcalvv28qqcp0c8e2zfukdn3f0wlwkh24zta83z3xx7rfpj4pus802dhc8rea9zhuvnleyqql452zj	f	\\x61e9937924f5bf616573fd8963bf63147003017e0f95093cb36714bd	\N	7772727272727272	\N	\N	\N
16	16	0	addr_test1vp2q7scw3qt2zl39uyj6c2wsvl35t035nca35unps35qquq4es7em	f	\\x540f430e8816a17e25e125ac29d067e345be349e3b1a726184680070	\N	3681818181818181	\N	\N	\N
17	17	0	addr_test1qp7nfugf8geaq66uvdtuz03kcu3ktk8hz884cxvqe5sm06pqk8n3nzwzzhdeyr3effqf4p3lv4uvmy0dz2k5en6rhqxsqjha92	f	\\x7d34f1093a33d06b5c6357c13e36c72365d8f711cf5c1980cd21b7e8	\N	7772727272727272	\N	\N	\N
18	18	0	addr_test1qrdqx27jm44we2tn97dsm7pw3x28hqt4t4sghsgxryerlsrfwcau5tykcr46vj8wqlzyct4s5r8mw3hudpv00x2cee7stku8sn	f	\\xda032bd2dd6aeca9732f9b0df82e89947b81755d608bc10619323fc0	\N	7772727272727272	\N	\N	\N
19	19	0	addr_test1vpcqg5xegtsq7acfqs3r4xfu8ute3kga5zzmraqtxtnt8wghs472n	f	\\x700450d942e00f770904223a993c3f1798d91da085b1f40b32e6b3b9	\N	3681818181818181	\N	\N	\N
20	20	0	addr_test1vrwplgwhccdk7cyzpddh0rzagnxvks9j3g4fy6hdgm86skclzdjnr	f	\\xdc1fa1d7c61b6f60820b5b778c5d44cccb40b28a2a926aed46cfa85b	\N	3681818181818181	\N	\N	\N
21	21	0	addr_test1vqxhu0vtune9x4p4w2377udyga4j3axatr7xr7nccc32t4cn7gklc	f	\\x0d7e3d8be4f253543572a3ef71a4476b28f4dd58fc61fa78c622a5d7	\N	3681818181818181	\N	\N	\N
22	22	0	addr_test1qzgejjd0ycwqaxqn2dsytwucdf5ptsnp0qm57vpk6n4rtxkaymxnu20v5ve9drsykjfene7vtx4nae0vhwkahsk7wnms0mq9gq	f	\\x919949af261c0e9813536045bb986a6815c26178374f3036d4ea359a	\N	7772727272727272	\N	\N	\N
23	23	0	addr_test1qrfhgvm9nq2edvw703gmv5lwrhmrspln345c98x40dr3zysfctsjfwahpftztngzet5mf4ulscvy9er4lsxy2wryxaus9hpns0	f	\\xd3743365981596b1de7c51b653ee1df63807f38d69829cd57b471112	\N	7772727272727272	\N	\N	\N
24	24	0	addr_test1vp34pvuv4gtq43z4v2dj4x4fenmrplscyvgh8rqhrzsyp3gfafw93	f	\\x6350b38caa160ac455629b2a9aa9ccf630fe182311738c1718a040c5	\N	3681818181818181	\N	\N	\N
25	25	0	addr_test1qr8pufyas5um2m2zj9rlnrkz7ndxgvu40epru8h8rtvpkmwm6586v6l6p42zdysj79c4mjvf95jryazgd7mujpngp36qh8egfh	f	\\xce1e249d8539b56d429147f98ec2f4da6433957e423e1ee71ad81b6d	\N	7772727272727272	\N	\N	\N
26	26	0	addr_test1vp6kspxdxx66twgdq6qt4yrt3znuqn6l6q5lzal4dg8vafg2x8dyx	f	\\x756804cd31b5a5b90d0680ba906b88a7c04f5fd029f177f56a0ecea5	\N	3681818181818181	\N	\N	\N
27	27	0	addr_test1qr4kn25wczv0e8eh0xlwpxzqwqp30dludy5lr5005yxkvt3em4yzta5ha2qfjc5yngg9qmu2fpa9pmsc85r2sau7ctpqsyqhhl	f	\\xeb69aa8ec098fc9f3779bee09840700317b7fc6929f1d1efa10d662e	\N	7772727272727272	\N	\N	\N
28	28	0	addr_test1qrwmjpmkv8qn0sn9z72sss3gt460n76j3944av5a65lytvxl5gjzyulncfkzzylkk8z8yj487ps52arxdu5npx0uhyaq79678d	f	\\xddb9077661c137c26517950842285d74f9fb52896b5eb29dd53e45b0	\N	7772727272727272	\N	\N	\N
29	29	0	addr_test1vq3s53exzvrkmg43s05f8nqe35ucz4w9dw85d7j3wkwefjsuvrn90	f	\\x230a472613076da2b183e893cc198d398155c56b8f46fa51759d94ca	\N	3681818181818181	\N	\N	\N
30	30	0	addr_test1vr5gnhm5cj2yj3fn2sweeucn5gamcsutpqcepyc6y9kr6fctuvna8	f	\\xe889df74c494494533541d9cf313a23bbc438b083190931a216c3d27	\N	3681818181818181	\N	\N	\N
31	31	0	addr_test1qzzku3p5966979muq46ph2pah5pjqw905aj6q2yacxf4hluv52mrrzcxw293xy9j4sjwafwjl5h74jymnv70zghk933q5ag9ff	f	\\x856e44342eb45f177c05741ba83dbd032038afa765a0289dc1935bff	\N	7772727272727272	\N	\N	\N
32	32	0	addr_test1qq0e3qu7hynlhtq7had5nmttfw6tqhnphv5q0d89avkxvxz00pjdvjxna34pvqqe5audx274f6hd7l2z6jfp7tphnaqs5sae4f	f	\\x1f98839eb927fbac1ebf5b49ed6b4bb4b05e61bb2807b4e5eb2c6618	\N	7772727272727280	\N	\N	\N
33	33	0	addr_test1qp26zwsjhhke7f9g4y3wl4pnww6glgrv6093eknkdfrnhj7d9ynzskd9djmmryr3hkd0v08d6x6ctwmmdacr4kht87vqvvyxw8	f	\\x55a13a12bded9f24a8a922efd43373b48fa06cd3cb1cda766a473bcb	\N	7772727272727272	\N	\N	\N
34	35	0	addr_test1qqrklkyrd7zaf8rf9jkzykmme076a20uulrlmh0x53z8wldcryhkgm4n8d0dyme8a4tsx90cxgv3tt0dqvj9n3f0dxkqeegjrg	f	\\x076fd8836f85d49c692cac225b7bcbfdaea9fce7c7fddde6a444777d	34	500000000000	\N	\N	\N
35	35	1	addr_test1vr95t3q0tm8lx0slvrsh6as6euax2478658jup770s7g56g57nmhv	f	\\xcb45c40f5ecff33e1f60e17d761acf3a6557c7d50f2e07de7c3c8a69	\N	3681318181651228	\N	\N	\N
36	36	0	addr_test1qzm7xgxujn2jewdgqm8dlpeu3aswmcydrl896j2e67mw7gwy23fyemr7ymmkelqmmm98dyz0rtfc7wq273hlfj5g79vqu5xwlr	f	\\xb7e320dc94d52cb9a806cedf873c8f60ede08d1fce5d4959d7b6ef21	35	500000000000	\N	\N	\N
37	36	1	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	3681318181651228	\N	\N	\N
38	37	0	addr_test1qzkzkk36cpwjj2upz75nlt6dylwg9l5z72ahyq8sp8rypfhksjwzlm22lhqpltjqukd5qphae6wh04r0rypux0a3gw0svr5mqz	f	\\xac2b5a3ac05d292b8117a93faf4d27dc82fe82f2bb7200f009c640a6	36	500000000000	\N	\N	\N
39	37	1	addr_test1vp34pvuv4gtq43z4v2dj4x4fenmrplscyvgh8rqhrzsyp3gfafw93	f	\\x6350b38caa160ac455629b2a9aa9ccf630fe182311738c1718a040c5	\N	3681318181651228	\N	\N	\N
40	38	0	addr_test1qqyxfjhx7kzgeatzrktkg5f4kwu4ckx68m0frnu9dxwdgcvyt3zphw28zugpuv0rkkkgw85e6vvmd808k402v92fdceq6ttdx5	f	\\x0864cae6f5848cf5621d97645135b3b95c58da3ede91cf85699cd461	37	500000000000	\N	\N	\N
41	38	1	addr_test1vp2q7scw3qt2zl39uyj6c2wsvl35t035nca35unps35qquq4es7em	f	\\x540f430e8816a17e25e125ac29d067e345be349e3b1a726184680070	\N	3681318181651228	\N	\N	\N
42	39	0	addr_test1qr84elgjje8vdejwhzfuka6rfg5gd0vml52cf6qmjrt85u4ec0nln70e9f48zaj687sxpjeuxfmahpsfzwaqyhk723ksgsyt0m	f	\\xcf5cfd12964ec6e64eb893cb77434a2886bd9bfd1584e81b90d67a72	38	500000000000	\N	\N	\N
43	39	1	addr_test1vreuz7kh8glzxtwasy82emj2smkuz0sk5cnht3d23pjhencyz725z	f	\\xf3c17ad73a3e232ddd810eacee4a86edc13e16a62775c5aa88657ccf	\N	3681318181651237	\N	\N	\N
44	40	0	addr_test1qzdx4h9wmz84xuaxfecprf5flf72rajcxn6p8zlk4rxl4luj3k3lf8aqm24p6ndzy4c4mq6guxmtq9zxqp4xe8qsvw8qfd4g55	f	\\x9a6adcaed88f5373a64e7011a689fa7ca1f65834f4138bf6a8cdfaff	39	500000000000	\N	\N	\N
45	40	1	addr_test1vqxhu0vtune9x4p4w2377udyga4j3axatr7xr7nccc32t4cn7gklc	f	\\x0d7e3d8be4f253543572a3ef71a4476b28f4dd58fc61fa78c622a5d7	\N	3681318181651228	\N	\N	\N
46	41	0	addr_test1qpxxxyl6wwp7vmx6eek0aycjyzfaqadcx9ygqdqmxeafrf0yp8hk4g9n760us3z9vwplsg9nf2dpld3asfu9ca6kmshszuyvd6	f	\\x4c6313fa7383e66cdace6cfe93122093d075b8314880341b367a91a5	40	500000000000	\N	\N	\N
47	41	1	addr_test1vpcqg5xegtsq7acfqs3r4xfu8ute3kga5zzmraqtxtnt8wghs472n	f	\\x700450d942e00f770904223a993c3f1798d91da085b1f40b32e6b3b9	\N	3681318181651228	\N	\N	\N
48	42	0	addr_test1qpu89xe4hclv09lqgc5flrdftcem4cgjmkdgppz06xp8kh2f9mzlmfetj5rqdhjy00s5pkdawwp6qvpwctk8nt3t6ktqv2z803	f	\\x78729b35be3ec797e046289f8da95e33bae112dd9a80844fd1827b5d	41	500000000000	\N	\N	\N
49	42	1	addr_test1vp6kspxdxx66twgdq6qt4yrt3znuqn6l6q5lzal4dg8vafg2x8dyx	f	\\x756804cd31b5a5b90d0680ba906b88a7c04f5fd029f177f56a0ecea5	\N	3681318181651228	\N	\N	\N
50	43	0	addr_test1qrtg6kumetz88vvwj53th0lqlu5j6ej5yugfqupv8x88u268x8pheks2vgvw7yt9fs5e38dgzye3yzep2ns6f994kvcqn78d0d	f	\\xd68d5b9bcac473b18e9522bbbfe0ff292d6654271090702c398e7e2b	42	500000000000	\N	\N	\N
51	43	1	addr_test1vr5gnhm5cj2yj3fn2sweeucn5gamcsutpqcepyc6y9kr6fctuvna8	f	\\xe889df74c494494533541d9cf313a23bbc438b083190931a216c3d27	\N	3681318181651228	\N	\N	\N
52	44	0	addr_test1qps47m4fp98hlwadvprrnnzkg7edr4sjc43nzwgepvlt2qmauztdtytyd4t9hryuj4dzparmh95msul5n88uxt44ysaqx08vsq	f	\\x615f6ea9094f7fbbad604639cc5647b2d1d612c5633139190b3eb503	43	500000000000	\N	\N	\N
53	44	1	addr_test1vrwplgwhccdk7cyzpddh0rzagnxvks9j3g4fy6hdgm86skclzdjnr	f	\\xdc1fa1d7c61b6f60820b5b778c5d44cccb40b28a2a926aed46cfa85b	\N	3681318181651228	\N	\N	\N
54	45	0	addr_test1qr6ll3d8smn5jghve2wywtyls8ygm00acvkr437wsve4r6ncfv9kh0aefzelc5slcl4hut3hv39qk9j7xvhfejhymtrqakuy27	f	\\xf5ffc5a786e74922ecca9c472c9f81c88dbdfdc32c3ac7ce833351ea	44	500000000000	\N	\N	\N
55	45	1	addr_test1vq3s53exzvrkmg43s05f8nqe35ucz4w9dw85d7j3wkwefjsuvrn90	f	\\x230a472613076da2b183e893cc198d398155c56b8f46fa51759d94ca	\N	3681318181651228	\N	\N	\N
56	46	0	addr_test1qqrklkyrd7zaf8rf9jkzykmme076a20uulrlmh0x53z8wldcryhkgm4n8d0dyme8a4tsx90cxgv3tt0dqvj9n3f0dxkqeegjrg	f	\\x076fd8836f85d49c692cac225b7bcbfdaea9fce7c7fddde6a444777d	34	499997828823	\N	\N	\N
57	47	0	addr_test1qzm7xgxujn2jewdgqm8dlpeu3aswmcydrl896j2e67mw7gwy23fyemr7ymmkelqmmm98dyz0rtfc7wq273hlfj5g79vqu5xwlr	f	\\xb7e320dc94d52cb9a806cedf873c8f60ede08d1fce5d4959d7b6ef21	35	499997828823	\N	\N	\N
58	48	0	addr_test1qzkzkk36cpwjj2upz75nlt6dylwg9l5z72ahyq8sp8rypfhksjwzlm22lhqpltjqukd5qphae6wh04r0rypux0a3gw0svr5mqz	f	\\xac2b5a3ac05d292b8117a93faf4d27dc82fe82f2bb7200f009c640a6	36	499997828823	\N	\N	\N
59	49	0	addr_test1qqyxfjhx7kzgeatzrktkg5f4kwu4ckx68m0frnu9dxwdgcvyt3zphw28zugpuv0rkkkgw85e6vvmd808k402v92fdceq6ttdx5	f	\\x0864cae6f5848cf5621d97645135b3b95c58da3ede91cf85699cd461	37	499997828823	\N	\N	\N
60	50	0	addr_test1qr84elgjje8vdejwhzfuka6rfg5gd0vml52cf6qmjrt85u4ec0nln70e9f48zaj687sxpjeuxfmahpsfzwaqyhk723ksgsyt0m	f	\\xcf5cfd12964ec6e64eb893cb77434a2886bd9bfd1584e81b90d67a72	38	499997828823	\N	\N	\N
61	51	0	addr_test1qzdx4h9wmz84xuaxfecprf5flf72rajcxn6p8zlk4rxl4luj3k3lf8aqm24p6ndzy4c4mq6guxmtq9zxqp4xe8qsvw8qfd4g55	f	\\x9a6adcaed88f5373a64e7011a689fa7ca1f65834f4138bf6a8cdfaff	39	499997828823	\N	\N	\N
62	52	0	addr_test1qpxxxyl6wwp7vmx6eek0aycjyzfaqadcx9ygqdqmxeafrf0yp8hk4g9n760us3z9vwplsg9nf2dpld3asfu9ca6kmshszuyvd6	f	\\x4c6313fa7383e66cdace6cfe93122093d075b8314880341b367a91a5	40	499997828823	\N	\N	\N
63	53	0	addr_test1qpu89xe4hclv09lqgc5flrdftcem4cgjmkdgppz06xp8kh2f9mzlmfetj5rqdhjy00s5pkdawwp6qvpwctk8nt3t6ktqv2z803	f	\\x78729b35be3ec797e046289f8da95e33bae112dd9a80844fd1827b5d	41	499997828823	\N	\N	\N
64	54	0	addr_test1qrtg6kumetz88vvwj53th0lqlu5j6ej5yugfqupv8x88u268x8pheks2vgvw7yt9fs5e38dgzye3yzep2ns6f994kvcqn78d0d	f	\\xd68d5b9bcac473b18e9522bbbfe0ff292d6654271090702c398e7e2b	42	499997828823	\N	\N	\N
65	55	0	addr_test1qps47m4fp98hlwadvprrnnzkg7edr4sjc43nzwgepvlt2qmauztdtytyd4t9hryuj4dzparmh95msul5n88uxt44ysaqx08vsq	f	\\x615f6ea9094f7fbbad604639cc5647b2d1d612c5633139190b3eb503	43	499997828823	\N	\N	\N
66	56	0	addr_test1qr6ll3d8smn5jghve2wywtyls8ygm00acvkr437wsve4r6ncfv9kh0aefzelc5slcl4hut3hv39qk9j7xvhfejhymtrqakuy27	f	\\xf5ffc5a786e74922ecca9c472c9f81c88dbdfdc32c3ac7ce833351ea	44	499997828823	\N	\N	\N
67	57	0	addr_test1qp34pvuv4gtq43z4v2dj4x4fenmrplscyvgh8rqhrzsyp3wwmrfes0gruf0qm7sdwc7u77m980ac029tr0af8cj6m8ksg4yeky	f	\\x6350b38caa160ac455629b2a9aa9ccf630fe182311738c1718a040c5	15	200000000	\N	\N	\N
68	57	1	addr_test1vp34pvuv4gtq43z4v2dj4x4fenmrplscyvgh8rqhrzsyp3gfafw93	f	\\x6350b38caa160ac455629b2a9aa9ccf630fe182311738c1718a040c5	\N	3681317981484451	\N	\N	\N
69	58	0	addr_test1qr5gnhm5cj2yj3fn2sweeucn5gamcsutpqcepyc6y9kr6f670t7ka2pcyu0sujvzhj6vsffz3m3p4kglfa0gnkpgttpqgy4yg3	f	\\xe889df74c494494533541d9cf313a23bbc438b083190931a216c3d27	20	300000000	\N	\N	\N
70	58	1	addr_test1vr5gnhm5cj2yj3fn2sweeucn5gamcsutpqcepyc6y9kr6fctuvna8	f	\\xe889df74c494494533541d9cf313a23bbc438b083190931a216c3d27	\N	3681317881484451	\N	\N	\N
71	59	0	addr_test1qp6kspxdxx66twgdq6qt4yrt3znuqn6l6q5lzal4dg8vaffe56yng2fhhclshsulst3rxntjevm3luh6e0dwahvkazzql5y3dr	f	\\x756804cd31b5a5b90d0680ba906b88a7c04f5fd029f177f56a0ecea5	12	300000000	\N	\N	\N
72	59	1	addr_test1vp6kspxdxx66twgdq6qt4yrt3znuqn6l6q5lzal4dg8vafg2x8dyx	f	\\x756804cd31b5a5b90d0680ba906b88a7c04f5fd029f177f56a0ecea5	\N	3681317881484451	\N	\N	\N
73	60	0	addr_test1qrwplgwhccdk7cyzpddh0rzagnxvks9j3g4fy6hdgm86skul7uy7l2e2pnvfgh0r4yfc6hw20k2fp342nrgzzacjzjwsvupuj2	f	\\xdc1fa1d7c61b6f60820b5b778c5d44cccb40b28a2a926aed46cfa85b	21	500000000	\N	\N	\N
74	60	1	addr_test1vrwplgwhccdk7cyzpddh0rzagnxvks9j3g4fy6hdgm86skclzdjnr	f	\\xdc1fa1d7c61b6f60820b5b778c5d44cccb40b28a2a926aed46cfa85b	\N	3681317681484451	\N	\N	\N
75	61	0	addr_test1qr95t3q0tm8lx0slvrsh6as6euax2478658jup770s7g562tm23zpgfqaehjq3ym0h57uk85vtac28eg55z5za4yl23sf6ntvh	f	\\xcb45c40f5ecff33e1f60e17d761acf3a6557c7d50f2e07de7c3c8a69	14	500000000	\N	\N	\N
76	61	1	addr_test1vr95t3q0tm8lx0slvrsh6as6euax2478658jup770s7g56g57nmhv	f	\\xcb45c40f5ecff33e1f60e17d761acf3a6557c7d50f2e07de7c3c8a69	\N	3681317681484451	\N	\N	\N
77	62	0	addr_test1qzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8a0f5t53rr4kytdgm0ttf2kk0rerhcsdc32tpc6dsv2wssuq7x08pw	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	22	600000000	\N	\N	\N
78	62	1	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	3681317581484451	\N	\N	\N
79	63	0	addr_test1qp2q7scw3qt2zl39uyj6c2wsvl35t035nca35unps35qqurla3uddkd4rme7mgm3vnd6ns97kf59amxe8k2w567k3qts44jec0	f	\\x540f430e8816a17e25e125ac29d067e345be349e3b1a726184680070	13	500000000	\N	\N	\N
80	63	1	addr_test1vp2q7scw3qt2zl39uyj6c2wsvl35t035nca35unps35qquq4es7em	f	\\x540f430e8816a17e25e125ac29d067e345be349e3b1a726184680070	\N	3681317681484451	\N	\N	\N
81	64	0	addr_test1qqxhu0vtune9x4p4w2377udyga4j3axatr7xr7nccc32t4ex0mhpev77gpazm27dh3eeez4e5de8tqtml7rl2549wstq08gqah	f	\\x0d7e3d8be4f253543572a3ef71a4476b28f4dd58fc61fa78c622a5d7	18	500000000	\N	\N	\N
82	64	1	addr_test1vqxhu0vtune9x4p4w2377udyga4j3axatr7xr7nccc32t4cn7gklc	f	\\x0d7e3d8be4f253543572a3ef71a4476b28f4dd58fc61fa78c622a5d7	\N	3681317681484451	\N	\N	\N
83	65	0	addr_test1qpcqg5xegtsq7acfqs3r4xfu8ute3kga5zzmraqtxtnt8wv3nrdu2ypepk982cfe3kd8n3tfslv2f6gcqmewamj3qx8s9usd0q	f	\\x700450d942e00f770904223a993c3f1798d91da085b1f40b32e6b3b9	16	500000000	\N	\N	\N
84	65	1	addr_test1vpcqg5xegtsq7acfqs3r4xfu8ute3kga5zzmraqtxtnt8wghs472n	f	\\x700450d942e00f770904223a993c3f1798d91da085b1f40b32e6b3b9	\N	3681317681484451	\N	\N	\N
85	66	0	addr_test1qq3s53exzvrkmg43s05f8nqe35ucz4w9dw85d7j3wkwefj40kqsrq5gncsz2pkzhagwp7mdmhyc4te8uw6eh3e8fxjzqg6p3x5	f	\\x230a472613076da2b183e893cc198d398155c56b8f46fa51759d94ca	17	500000000	\N	\N	\N
86	66	1	addr_test1vq3s53exzvrkmg43s05f8nqe35ucz4w9dw85d7j3wkwefjsuvrn90	f	\\x230a472613076da2b183e893cc198d398155c56b8f46fa51759d94ca	\N	3681317681484451	\N	\N	\N
87	67	0	addr_test1qreuz7kh8glzxtwasy82emj2smkuz0sk5cnht3d23pjhenlamvd2qxrcf8aaklphj7789m79mutz0mxav3u39crqn7gqnt4rmz	f	\\xf3c17ad73a3e232ddd810eacee4a86edc13e16a62775c5aa88657ccf	19	500000000	\N	\N	\N
88	67	1	addr_test1vreuz7kh8glzxtwasy82emj2smkuz0sk5cnht3d23pjhencyz725z	f	\\xf3c17ad73a3e232ddd810eacee4a86edc13e16a62775c5aa88657ccf	\N	3681317681484460	\N	\N	\N
89	68	0	addr_test1vqxhu0vtune9x4p4w2377udyga4j3axatr7xr7nccc32t4cn7gklc	f	\\x0d7e3d8be4f253543572a3ef71a4476b28f4dd58fc61fa78c622a5d7	\N	3681317679310238	\N	\N	\N
90	69	0	addr_test1vpcqg5xegtsq7acfqs3r4xfu8ute3kga5zzmraqtxtnt8wghs472n	f	\\x700450d942e00f770904223a993c3f1798d91da085b1f40b32e6b3b9	\N	3681317679310238	\N	\N	\N
91	70	0	addr_test1vp2q7scw3qt2zl39uyj6c2wsvl35t035nca35unps35qquq4es7em	f	\\x540f430e8816a17e25e125ac29d067e345be349e3b1a726184680070	\N	3681317679310238	\N	\N	\N
92	71	0	addr_test1vp6kspxdxx66twgdq6qt4yrt3znuqn6l6q5lzal4dg8vafg2x8dyx	f	\\x756804cd31b5a5b90d0680ba906b88a7c04f5fd029f177f56a0ecea5	\N	3681317879310238	\N	\N	\N
93	72	0	addr_test1vreuz7kh8glzxtwasy82emj2smkuz0sk5cnht3d23pjhencyz725z	f	\\xf3c17ad73a3e232ddd810eacee4a86edc13e16a62775c5aa88657ccf	\N	3681317679310247	\N	\N	\N
94	73	0	addr_test1vp34pvuv4gtq43z4v2dj4x4fenmrplscyvgh8rqhrzsyp3gfafw93	f	\\x6350b38caa160ac455629b2a9aa9ccf630fe182311738c1718a040c5	\N	3681317979310238	\N	\N	\N
95	74	0	addr_test1vq3s53exzvrkmg43s05f8nqe35ucz4w9dw85d7j3wkwefjsuvrn90	f	\\x230a472613076da2b183e893cc198d398155c56b8f46fa51759d94ca	\N	3681317679310238	\N	\N	\N
96	75	0	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	3681317579310238	\N	\N	\N
97	76	0	addr_test1vrwplgwhccdk7cyzpddh0rzagnxvks9j3g4fy6hdgm86skclzdjnr	f	\\xdc1fa1d7c61b6f60820b5b778c5d44cccb40b28a2a926aed46cfa85b	\N	3681317679310238	\N	\N	\N
98	77	0	addr_test1vr5gnhm5cj2yj3fn2sweeucn5gamcsutpqcepyc6y9kr6fctuvna8	f	\\xe889df74c494494533541d9cf313a23bbc438b083190931a216c3d27	\N	3681317879310238	\N	\N	\N
99	78	0	addr_test1vr95t3q0tm8lx0slvrsh6as6euax2478658jup770s7g56g57nmhv	f	\\xcb45c40f5ecff33e1f60e17d761acf3a6557c7d50f2e07de7c3c8a69	\N	3681317679310238	\N	\N	\N
100	79	0	addr_test1vr5gnhm5cj2yj3fn2sweeucn5gamcsutpqcepyc6y9kr6fctuvna8	f	\\xe889df74c494494533541d9cf313a23bbc438b083190931a216c3d27	\N	3681317879134705	\N	\N	\N
101	80	0	addr_test1vp6kspxdxx66twgdq6qt4yrt3znuqn6l6q5lzal4dg8vafg2x8dyx	f	\\x756804cd31b5a5b90d0680ba906b88a7c04f5fd029f177f56a0ecea5	\N	3681317879134705	\N	\N	\N
102	81	0	addr_test1vpcqg5xegtsq7acfqs3r4xfu8ute3kga5zzmraqtxtnt8wghs472n	f	\\x700450d942e00f770904223a993c3f1798d91da085b1f40b32e6b3b9	\N	3681317679134705	\N	\N	\N
103	82	0	addr_test1vqxhu0vtune9x4p4w2377udyga4j3axatr7xr7nccc32t4cn7gklc	f	\\x0d7e3d8be4f253543572a3ef71a4476b28f4dd58fc61fa78c622a5d7	\N	3681317679134705	\N	\N	\N
104	83	0	addr_test1vp2q7scw3qt2zl39uyj6c2wsvl35t035nca35unps35qquq4es7em	f	\\x540f430e8816a17e25e125ac29d067e345be349e3b1a726184680070	\N	3681317679134705	\N	\N	\N
105	84	0	addr_test1vreuz7kh8glzxtwasy82emj2smkuz0sk5cnht3d23pjhencyz725z	f	\\xf3c17ad73a3e232ddd810eacee4a86edc13e16a62775c5aa88657ccf	\N	3681317679134714	\N	\N	\N
106	85	0	addr_test1vrwplgwhccdk7cyzpddh0rzagnxvks9j3g4fy6hdgm86skclzdjnr	f	\\xdc1fa1d7c61b6f60820b5b778c5d44cccb40b28a2a926aed46cfa85b	\N	3681317679134705	\N	\N	\N
107	86	0	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	3681317579134705	\N	\N	\N
108	87	0	addr_test1vp34pvuv4gtq43z4v2dj4x4fenmrplscyvgh8rqhrzsyp3gfafw93	f	\\x6350b38caa160ac455629b2a9aa9ccf630fe182311738c1718a040c5	\N	3681317979134705	\N	\N	\N
109	88	0	addr_test1vr95t3q0tm8lx0slvrsh6as6euax2478658jup770s7g56g57nmhv	f	\\xcb45c40f5ecff33e1f60e17d761acf3a6557c7d50f2e07de7c3c8a69	\N	3681317679134705	\N	\N	\N
110	89	0	addr_test1vq3s53exzvrkmg43s05f8nqe35ucz4w9dw85d7j3wkwefjsuvrn90	f	\\x230a472613076da2b183e893cc198d398155c56b8f46fa51759d94ca	\N	3681317679134705	\N	\N	\N
111	90	0	addr_test1qrtg6kumetz88vvwj53th0lqlu5j6ej5yugfqupv8x88u268x8pheks2vgvw7yt9fs5e38dgzye3yzep2ns6f994kvcqn78d0d	f	\\xd68d5b9bcac473b18e9522bbbfe0ff292d6654271090702c398e7e2b	42	499997652058	\N	\N	\N
112	91	0	addr_test1qpxxxyl6wwp7vmx6eek0aycjyzfaqadcx9ygqdqmxeafrf0yp8hk4g9n760us3z9vwplsg9nf2dpld3asfu9ca6kmshszuyvd6	f	\\x4c6313fa7383e66cdace6cfe93122093d075b8314880341b367a91a5	40	499997652058	\N	\N	\N
113	92	0	addr_test1qqyxfjhx7kzgeatzrktkg5f4kwu4ckx68m0frnu9dxwdgcvyt3zphw28zugpuv0rkkkgw85e6vvmd808k402v92fdceq6ttdx5	f	\\x0864cae6f5848cf5621d97645135b3b95c58da3ede91cf85699cd461	37	499997652058	\N	\N	\N
114	93	0	addr_test1qqrklkyrd7zaf8rf9jkzykmme076a20uulrlmh0x53z8wldcryhkgm4n8d0dyme8a4tsx90cxgv3tt0dqvj9n3f0dxkqeegjrg	f	\\x076fd8836f85d49c692cac225b7bcbfdaea9fce7c7fddde6a444777d	34	499997652058	\N	\N	\N
115	94	0	addr_test1qps47m4fp98hlwadvprrnnzkg7edr4sjc43nzwgepvlt2qmauztdtytyd4t9hryuj4dzparmh95msul5n88uxt44ysaqx08vsq	f	\\x615f6ea9094f7fbbad604639cc5647b2d1d612c5633139190b3eb503	43	499997652058	\N	\N	\N
116	95	0	addr_test1qr6ll3d8smn5jghve2wywtyls8ygm00acvkr437wsve4r6ncfv9kh0aefzelc5slcl4hut3hv39qk9j7xvhfejhymtrqakuy27	f	\\xf5ffc5a786e74922ecca9c472c9f81c88dbdfdc32c3ac7ce833351ea	44	499997652058	\N	\N	\N
117	96	0	addr_test1qzkzkk36cpwjj2upz75nlt6dylwg9l5z72ahyq8sp8rypfhksjwzlm22lhqpltjqukd5qphae6wh04r0rypux0a3gw0svr5mqz	f	\\xac2b5a3ac05d292b8117a93faf4d27dc82fe82f2bb7200f009c640a6	36	499997652058	\N	\N	\N
118	97	0	addr_test1qpu89xe4hclv09lqgc5flrdftcem4cgjmkdgppz06xp8kh2f9mzlmfetj5rqdhjy00s5pkdawwp6qvpwctk8nt3t6ktqv2z803	f	\\x78729b35be3ec797e046289f8da95e33bae112dd9a80844fd1827b5d	41	499997652058	\N	\N	\N
119	98	0	addr_test1qzdx4h9wmz84xuaxfecprf5flf72rajcxn6p8zlk4rxl4luj3k3lf8aqm24p6ndzy4c4mq6guxmtq9zxqp4xe8qsvw8qfd4g55	f	\\x9a6adcaed88f5373a64e7011a689fa7ca1f65834f4138bf6a8cdfaff	39	499997652058	\N	\N	\N
120	99	0	addr_test1qzm7xgxujn2jewdgqm8dlpeu3aswmcydrl896j2e67mw7gwy23fyemr7ymmkelqmmm98dyz0rtfc7wq273hlfj5g79vqu5xwlr	f	\\xb7e320dc94d52cb9a806cedf873c8f60ede08d1fce5d4959d7b6ef21	35	499997652058	\N	\N	\N
121	100	0	addr_test1qr84elgjje8vdejwhzfuka6rfg5gd0vml52cf6qmjrt85u4ec0nln70e9f48zaj687sxpjeuxfmahpsfzwaqyhk723ksgsyt0m	f	\\xcf5cfd12964ec6e64eb893cb77434a2886bd9bfd1584e81b90d67a72	38	499997652058	\N	\N	\N
122	101	0	addr_test1qrtg6kumetz88vvwj53th0lqlu5j6ej5yugfqupv8x88u268x8pheks2vgvw7yt9fs5e38dgzye3yzep2ns6f994kvcqn78d0d	f	\\xd68d5b9bcac473b18e9522bbbfe0ff292d6654271090702c398e7e2b	42	499997466449	\N	\N	\N
123	102	0	addr_test1qqrklkyrd7zaf8rf9jkzykmme076a20uulrlmh0x53z8wldcryhkgm4n8d0dyme8a4tsx90cxgv3tt0dqvj9n3f0dxkqeegjrg	f	\\x076fd8836f85d49c692cac225b7bcbfdaea9fce7c7fddde6a444777d	34	499997463677	\N	\N	\N
124	103	0	addr_test1qr6ll3d8smn5jghve2wywtyls8ygm00acvkr437wsve4r6ncfv9kh0aefzelc5slcl4hut3hv39qk9j7xvhfejhymtrqakuy27	f	\\xf5ffc5a786e74922ecca9c472c9f81c88dbdfdc32c3ac7ce833351ea	44	499997463633	\N	\N	\N
125	104	0	addr_test1qps47m4fp98hlwadvprrnnzkg7edr4sjc43nzwgepvlt2qmauztdtytyd4t9hryuj4dzparmh95msul5n88uxt44ysaqx08vsq	f	\\x615f6ea9094f7fbbad604639cc5647b2d1d612c5633139190b3eb503	43	499997463633	\N	\N	\N
126	105	0	addr_test1qpxxxyl6wwp7vmx6eek0aycjyzfaqadcx9ygqdqmxeafrf0yp8hk4g9n760us3z9vwplsg9nf2dpld3asfu9ca6kmshszuyvd6	f	\\x4c6313fa7383e66cdace6cfe93122093d075b8314880341b367a91a5	40	499997463677	\N	\N	\N
127	106	0	addr_test1qzdx4h9wmz84xuaxfecprf5flf72rajcxn6p8zlk4rxl4luj3k3lf8aqm24p6ndzy4c4mq6guxmtq9zxqp4xe8qsvw8qfd4g55	f	\\x9a6adcaed88f5373a64e7011a689fa7ca1f65834f4138bf6a8cdfaff	39	499997463677	\N	\N	\N
128	107	0	addr_test1qpu89xe4hclv09lqgc5flrdftcem4cgjmkdgppz06xp8kh2f9mzlmfetj5rqdhjy00s5pkdawwp6qvpwctk8nt3t6ktqv2z803	f	\\x78729b35be3ec797e046289f8da95e33bae112dd9a80844fd1827b5d	41	499997466449	\N	\N	\N
129	108	0	addr_test1qzm7xgxujn2jewdgqm8dlpeu3aswmcydrl896j2e67mw7gwy23fyemr7ymmkelqmmm98dyz0rtfc7wq273hlfj5g79vqu5xwlr	f	\\xb7e320dc94d52cb9a806cedf873c8f60ede08d1fce5d4959d7b6ef21	35	499997466449	\N	\N	\N
130	109	0	addr_test1qr84elgjje8vdejwhzfuka6rfg5gd0vml52cf6qmjrt85u4ec0nln70e9f48zaj687sxpjeuxfmahpsfzwaqyhk723ksgsyt0m	f	\\xcf5cfd12964ec6e64eb893cb77434a2886bd9bfd1584e81b90d67a72	38	499997463677	\N	\N	\N
131	110	0	addr_test1qqyxfjhx7kzgeatzrktkg5f4kwu4ckx68m0frnu9dxwdgcvyt3zphw28zugpuv0rkkkgw85e6vvmd808k402v92fdceq6ttdx5	f	\\x0864cae6f5848cf5621d97645135b3b95c58da3ede91cf85699cd461	37	499997463677	\N	\N	\N
132	111	0	addr_test1qzkzkk36cpwjj2upz75nlt6dylwg9l5z72ahyq8sp8rypfhksjwzlm22lhqpltjqukd5qphae6wh04r0rypux0a3gw0svr5mqz	f	\\xac2b5a3ac05d292b8117a93faf4d27dc82fe82f2bb7200f009c640a6	36	499997463677	\N	\N	\N
133	112	0	addr_test1qpu89xe4hclv09lqgc5flrdftcem4cgjmkdgppz06xp8kh2f9mzlmfetj5rqdhjy00s5pkdawwp6qvpwctk8nt3t6ktqv2z803	f	\\x78729b35be3ec797e046289f8da95e33bae112dd9a80844fd1827b5d	41	499997289684	\N	\N	\N
134	113	0	addr_test1qr6ll3d8smn5jghve2wywtyls8ygm00acvkr437wsve4r6ncfv9kh0aefzelc5slcl4hut3hv39qk9j7xvhfejhymtrqakuy27	f	\\xf5ffc5a786e74922ecca9c472c9f81c88dbdfdc32c3ac7ce833351ea	44	499997286868	\N	\N	\N
135	114	0	addr_test1qps47m4fp98hlwadvprrnnzkg7edr4sjc43nzwgepvlt2qmauztdtytyd4t9hryuj4dzparmh95msul5n88uxt44ysaqx08vsq	f	\\x615f6ea9094f7fbbad604639cc5647b2d1d612c5633139190b3eb503	43	499997286868	\N	\N	\N
136	115	0	addr_test1qrtg6kumetz88vvwj53th0lqlu5j6ej5yugfqupv8x88u268x8pheks2vgvw7yt9fs5e38dgzye3yzep2ns6f994kvcqn78d0d	f	\\xd68d5b9bcac473b18e9522bbbfe0ff292d6654271090702c398e7e2b	42	499997289684	\N	\N	\N
137	116	0	addr_test1vrwplgwhccdk7cyzpddh0rzagnxvks9j3g4fy6hdgm86skclzdjnr	f	\\xdc1fa1d7c61b6f60820b5b778c5d44cccb40b28a2a926aed46cfa85b	\N	3681317678956092	\N	\N	\N
138	117	0	addr_test1vq3s53exzvrkmg43s05f8nqe35ucz4w9dw85d7j3wkwefjsuvrn90	f	\\x230a472613076da2b183e893cc198d398155c56b8f46fa51759d94ca	\N	3681317678956092	\N	\N	\N
139	118	0	addr_test1vr5gnhm5cj2yj3fn2sweeucn5gamcsutpqcepyc6y9kr6fctuvna8	f	\\xe889df74c494494533541d9cf313a23bbc438b083190931a216c3d27	\N	3681317878956092	\N	\N	\N
140	119	0	addr_test1vp6kspxdxx66twgdq6qt4yrt3znuqn6l6q5lzal4dg8vafg2x8dyx	f	\\x756804cd31b5a5b90d0680ba906b88a7c04f5fd029f177f56a0ecea5	\N	3681317878956092	\N	\N	\N
141	120	0	addr_test1wpnlxv2xv9a9ucvnvzqakwepzl9ltx7jzgm53av2e9ncv4sysemm8	t	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	\N	100000000	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	\N	\N
142	120	1	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	3681317478967664	\N	\N	\N
143	121	0	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	99829086	\N	\N	\N
144	122	0	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	100000000	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	2	\N
145	122	1	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	3681317378801679	\N	\N	\N
146	123	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	2
147	123	1	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	3681317278631382	\N	\N	\N
148	124	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	3
149	124	1	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	3681317178463681	\N	\N	\N
150	125	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	1
151	125	1	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	3681317078297124	\N	\N	\N
152	126	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	4
153	126	1	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	3681316978034339	\N	\N	\N
154	127	0	addr_test1wzem0yuxjqyrmzvrsr8xfqhumyy555ngyjxw7wrg2pav90q8cagu2	t	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	\N	100000000	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	3	\N
155	127	1	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	3681316877868310	\N	\N	\N
156	128	0	addr_test1vzmryd0hecvax6cp3cflle7l6ypeqh43def0a4680jrf8agukezfd	f	\\xb63235f7ce19d36b018e13ffe7dfd103905eb16e52fed7477c8693f5	\N	3681316977541139	\N	\N	\N
157	129	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	10000000	\N	\N	\N
158	129	1	addr_test1vr95t3q0tm8lx0slvrsh6as6euax2478658jup770s7g56g57nmhv	f	\\xcb45c40f5ecff33e1f60e17d761acf3a6557c7d50f2e07de7c3c8a69	\N	3681317668958952	\N	\N	\N
159	130	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000000000	\N	\N	\N
160	130	1	addr_test1qrml5hwl9s7ydm2djyup95ud6s74skkl4zzf8zk657s8thgm78sn3uhch64ujc7ffnpga68dfdqhg3sp7tk6759jrm7spy03k9	f	\\xf7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd	69	5000000000000	\N	\N	\N
161	130	2	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	5000000000000	\N	\N	\N
162	130	3	addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k	f	\\x594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0	71	5000000000000	\N	\N	\N
163	130	4	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	5000000000000	\N	\N	\N
164	130	5	addr_test1vp34pvuv4gtq43z4v2dj4x4fenmrplscyvgh8rqhrzsyp3gfafw93	f	\\x6350b38caa160ac455629b2a9aa9ccf630fe182311738c1718a040c5	\N	3656317978955608	\N	\N	\N
165	131	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	10000000	\N	\N	\N
166	131	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999989767751	\N	\N	\N
167	132	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	10000000	\\x81cb2989cbf6c49840511d8d3451ee44f58dde2c074fc749d05deb51eeb33741	4	\N
168	132	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999979583022	\N	\N	\N
169	133	0	5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg	f	\N	\N	3000000	\N	\N	\N
170	133	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999976415013	\N	\N	\N
171	134	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	5	\N
172	134	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999966180168	\N	\N	\N
173	135	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\\xff1a404ece117cc4482d26b072e30b5a6b3cd055a22debda3f90d704957e273a	6	\N
174	135	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999955958039	\N	\N	\N
175	136	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\\x29294f077464c36e67b304ad22547fb3dfa946623b0b2cbae8acea7fb299353c	7	\N
176	136	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	9772151	\N	\N	\N
177	137	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999955766666	\N	\N	\N
178	138	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	72	20000000	\N	\N	\N
179	138	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999955360820	\N	\N	\N
180	139	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	72	20000000	\N	\N	\N
181	139	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999935187839	\N	\N	\N
182	140	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999935011778	\N	\N	\N
183	141	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	72	19826843	\N	\N	\N
184	142	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
185	142	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999924818953	\N	\N	\N
186	143	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
187	143	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999914626128	\N	\N	\N
188	144	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	19825259	\N	\N	\N
189	145	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
190	145	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	9632610	\N	\N	\N
191	146	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	9826843	\N	\N	\N
192	147	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
193	147	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999914258562	\N	\N	\N
194	148	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	9824995	\N	\N	\N
195	149	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	9651838	\N	\N	\N
196	150	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
197	150	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999913685587	\N	\N	\N
198	151	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
199	151	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	9471773	\N	\N	\N
200	152	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
201	152	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999912966251	\N	\N	\N
202	153	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
203	153	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999902777254	\N	\N	\N
204	154	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
205	154	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	9811795	\N	\N	\N
206	155	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999932408236	\N	\N	\N
207	156	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	3000000	\N	\N	\N
208	156	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999929224387	\N	\N	\N
209	157	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2820947	\N	\N	\N
210	158	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	3000000	\N	\N	\N
211	158	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999928866193	\N	\N	\N
212	159	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2827019	\N	\N	\N
213	160	0	addr_test1qr5rc6prrt3qze2854wcudwtlugfr32rfk5gtj54swwlysqss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq90e4zn	f	\\xe83c68231ae2016547a55d8e35cbff1091c5434da885ca95839df240	73	3000000	\N	\N	\N
214	160	1	addr_test1qpyp9j5gfmvkmzcrdkk9spvumezejl3y0qvx9jmgwtlcrdqss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqeu2282	f	\\x4812ca884ed96d8b036dac58059cde45997e24781862cb6872ff81b4	73	3000000	\N	\N	\N
215	160	2	addr_test1qr9pamzepyj64hvjdaed4wzqc87zvywwyl000x0eqygze0gss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqkr9rzh	f	\\xca1eec590925aadd926f72dab840c1fc2611ce27def799f901102cbd	73	3000000	\N	\N	\N
216	160	3	addr_test1qpzkw4jua640hz4t7d4appjfls0fl9xra4nzxaswjccefqgss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq97jhpn	f	\\x4567565ceeaafb8aabf36bd08649fc1e9f94c3ed6623760e96319481	73	3000000	\N	\N	\N
217	160	4	addr_test1qzzuyhvw5507peykcm78h0l2d8943gpj44mkdc5ga4d96kqss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqpwymkw	f	\\x85c25d8ea51fe0e496c6fc7bbfea69cb58a032ad7766e288ed5a5d58	73	3000000	\N	\N	\N
218	160	5	addr_test1qr9lpd5hel2qel0j7mp9ggxrueyg4juu7s08rrfz20ltgxqss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqn627pt	f	\\xcbf0b697cfd40cfdf2f6c25420c3e6488acb9cf41e718d2253feb418	73	3000000	\N	\N	\N
219	160	6	addr_test1qptynzuc95h6jgu9nwdyuu0shaaz8j54t3fdyy7rzpgu9wgss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqe00cpm	f	\\x56498b982d2fa923859b9a4e71f0bf7a23ca955c52d213c31051c2b9	73	3000000	\N	\N	\N
220	160	7	addr_test1qpcul8mxtzw4uff6umvjn8r36paugt00qrdm0fkva2r7gkcss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq74hmm6	f	\\x71cf9f66589d5e253ae6d9299c71d07bc42def00dbb7a6ccea87e45b	73	3000000	\N	\N	\N
221	160	8	addr_test1qq92ylad204n54tsuaa4hx2m2j9krz8dtyt83g6qsfw4mpqss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqva2d6u	f	\\x0aa27fad53eb3a5570e77b5b995b548b6188ed591678a340825d5d84	73	3000000	\N	\N	\N
222	160	9	addr_test1qrkhvkljaufpqhckxssdgv2u2uxm6q2ce8z9n4dvxthkzfcss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqragqsa	f	\\xed765bf2ef12105f163420d4315c570dbd0158c9c459d5ac32ef6127	73	3000000	\N	\N	\N
223	160	10	addr_test1qz9tpv2kv53xdmmpy5l4ckpq8tyurrg3qvll62hlxf65u9qss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqa06xj3	f	\\x8ab0b156652266ef61253f5c58203ac9c18d11033ffd2aff32754e14	73	3000000	\N	\N	\N
224	160	11	addr_test1qqnfdfj87lwt62tpvdjtyv5zq7fazed8lk9psdksnjdjs4qss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqk0y93j	f	\\x2696a647f7dcbd29616364b232820793d165a7fd8a1836d09c9b2854	73	3000000	\N	\N	\N
225	160	12	addr_test1qzpfpwu74khfxh78uguvpc8xn63l07sa0plag7u7t647v8css8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqwmtw93	f	\\x8290bb9eadae935fc7e238c0e0e69ea3f7fa1d787fd47b9e5eabe61f	73	3000000	\N	\N	\N
226	160	13	addr_test1qzfynawr0wuwmhzvv46sxu3fc8zuacznsgvk5wxdqkq96mqss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq7eq44f	f	\\x9249f5c37bb8eddc4c6575037229c1c5cee05382196a38cd05805d6c	73	3000000	\N	\N	\N
227	160	14	addr_test1qzqnnz9tvsttetffjttmuzfg63rk2ll4fr2y0v3jvvjty2qss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqsgwujk	f	\\x813988ab6416bcad2992d7be0928d447657ff548d447b2326324b228	73	3000000	\N	\N	\N
228	160	15	addr_test1qztdqpejwgrs43vpeeth8rjr8mjzwcf4fkym2fxms58428qss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqx6l87w	f	\\x96d0073272070ac581ce57738e433ee42761354d89b524db850f551c	73	3000000	\N	\N	\N
229	160	16	addr_test1qzs9nac23f4nzeyhesu47u086rkmyn5w95q2l9krtds3e5css8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq5jgecl	f	\\xa059f70a8a6b316497cc395f71e7d0edb24e8e2d00af96c35b611cd3	73	3000000	\N	\N	\N
230	160	17	addr_test1qpjr43kceyxl9gehaha8snh5y5tvczssyusgwg26lc3j2tgss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqjuflgp	f	\\x643ac6d8c90df2a337edfa784ef42516cc0a10272087215afe23252d	73	3000000	\N	\N	\N
231	160	18	addr_test1qzmc4uugwqkknaqp500q5t5pt900eg035p9druvmcsnl3fcss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqjphvmt	f	\\xb78af388702d69f401a3de0a2e81595efca1f1a04ad1f19bc427f8a7	73	3000000	\N	\N	\N
232	160	19	addr_test1qqsu4rm953x2mklcddevy5j3pna2qpj2qw40a5ux03cca8qss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqvrcapk	f	\\x21ca8f65a44caddbf86b72c252510cfaa0064a03aafed3867c718e9c	73	3000000	\N	\N	\N
233	160	20	addr_test1qzwdtdjl8jhtxupzl4rs2uv5vc5zu0swny7qkl6cpc8jflcss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqc66n0a	f	\\x9cd5b65f3caeb37022fd4705719466282e3e0e993c0b7f580e0f24ff	73	3000000	\N	\N	\N
234	160	21	addr_test1qqq99sa7cjjw7xglu3vr5u7g0gl4a9zhz2l80lwnvx3lpegss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqpmnspv	f	\\x0052c3bec4a4ef191fe4583a73c87a3f5e945712be77fdd361a3f0e5	73	3000000	\N	\N	\N
235	160	22	addr_test1qp98p83hstv4y6xhzyx33m3kcs5v8x8ztta8lea36qxknfsss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq775g8l	f	\\x4a709e3782d95268d7110d18ee36c428c398e25afa7fe7b1d00d69a6	73	3000000	\N	\N	\N
236	160	23	addr_test1qr8qhds5mfhuawnuyc0gajflva90pj6546c2r679kufd8kgss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqpjxqm0	f	\\xce0bb614da6fceba7c261e8ec93f674af0cb54aeb0a1ebc5b712d3d9	73	3000000	\N	\N	\N
237	160	24	addr_test1qr44jtuz6xmhwjpsraanraxfglcfq6hgdnr53r5yemlte4sss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq25k3ea	f	\\xeb592f82d1b77748301f7b31f4c947f0906ae86cc7488e84cefebcd6	73	3000000	\N	\N	\N
238	160	25	addr_test1qzulsdavxjdfaa227rqtjxp8pxfl5xgy0n9ts5l3w5gytwcss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqdhnmue	f	\\xb9f837ac349a9ef54af0c0b918270993fa19047ccab853f1751045bb	73	3000000	\N	\N	\N
239	160	26	addr_test1qz4wr6kau525gjpghck557x6e65qqe5alxfqlpnpckfttvcss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq43eda2	f	\\xaae1eadde515444828be2d4a78dacea800669df9920f8661c592b5b3	73	3000000	\N	\N	\N
240	160	27	addr_test1qq3wse73gs2fed6s9kcun0pc49v06j8euhl2yypmnh4xsncss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqa6p594	f	\\x22e867d144149cb7502db1c9bc38a958fd48f9e5fea2103b9dea684f	73	3000000	\N	\N	\N
241	160	28	addr_test1qz2hgwfp6emakcj76u2ywkp5m8hls3g5n6rr0ppjh2dpergss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqcfe257	f	\\x95743921d677db625ed714475834d9eff845149e86378432ba9a1c8d	73	3000000	\N	\N	\N
242	160	29	addr_test1qzn9qep0uss0vkmf5x4dntx5ylsm9nm8lsy2g34p9j0y7ngss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqdphj2q	f	\\xa650642fe420f65b69a1aad9acd427e1b2cf67fc08a446a12c9e4f4d	73	3000000	\N	\N	\N
243	160	30	addr_test1qqw6yst5sxwyzw5jmzf9k4jt5ftqfwyjfy85qac7zfxcdxgss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq24xuzx	f	\\x1da24174819c413a92d8925b564ba25604b892490f40771e124d8699	73	3000000	\N	\N	\N
244	160	31	addr_test1qpg576dljt528tqyz0h2864n4qnaccqkav6dkptnnfyypdcss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq866fkf	f	\\x514f69bf92e8a3ac0413eea3eab3a827dc6016eb34db05739a4840b7	73	3000000	\N	\N	\N
245	160	32	addr_test1qzguccywzex0vmhqyp0qsk2942l2ylxzvd3t5rpz8cdg8msss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqmmpyx3	f	\\x91cc608e164cf66ee0205e085945aabea27cc26362ba0c223e1a83ee	73	3000000	\N	\N	\N
246	160	33	addr_test1qqkezlafg9cje36sj848m4huwxer30r4uud2j27tpkp5hjsss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqkhmmu7	f	\\x2d917fa941712cc75091ea7dd6fc71b238bc75e71aa92bcb0d834bca	73	3000000	\N	\N	\N
247	160	34	addr_test1qza899t6e0aauhc2ruyxx37v2cvnduyj7yrfchhfptf246sss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqwjrjqp	f	\\xba72957acbfbde5f0a1f086347cc561936f092f1069c5ee90ad2aaea	73	3000000	\N	\N	\N
248	160	35	addr_test1qr28j9cfn6lste5rp6e4ypvfvu3qp305tgy7ugreal082hcss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq4fg4ts	f	\\xd47917099ebf05e6830eb3520589672200c5f45a09ee2079efde755f	73	3000000	\N	\N	\N
249	160	36	addr_test1qrs8ycqyhrlt4zyjzjxwyppzpg2dfw9c9fjl9eytq38dq0qss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq0ex5yc	f	\\xe0726004b8feba8892148ce204220a14d4b8b82a65f2e48b044ed03c	73	3000000	\N	\N	\N
250	160	37	addr_test1qpq68c8mutcs0x9keda77eprjddmjvh3wk4t7jc7l84vcqsss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq8g6ns2	f	\\x41a3e0fbe2f10798b6cb7bef6423935bb932f175aabf4b1ef9eacc02	73	3000000	\N	\N	\N
251	160	38	addr_test1qrvupvlnphve4vpgz3kt08k632custwp0f23pgpqx0mxgnqss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqdqmgm6	f	\\xd9c0b3f30dd99ab028146cb79eda8ab1c82dc17a5510a02033f6644c	73	3000000	\N	\N	\N
252	160	39	addr_test1qq5gkfs2khaktgwwyy5ldaagc5cssunra7xctld7jhyf2pcss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq43g6wm	f	\\x288b260ab5fb65a1ce2129f6f7a8c531087263ef8d85fdbe95c89507	73	3000000	\N	\N	\N
253	160	40	addr_test1qqm5femtpmzv45ucmlqa6n8cvknhlgrxr0vuf9sdvacdx4sss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq4tjanp	f	\\x3744e76b0ec4cad398dfc1dd4cf865a77fa0661bd9c4960d6770d356	73	3000000	\N	\N	\N
254	160	41	addr_test1qze0h7n9gc9drrah3f5l7ldss6jv9fzyhwdutr9wvvnaumqss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqwzgm7s	f	\\xb2fbfa65460ad18fb78a69ff7db086a4c2a444bb9bc58cae6327de6c	73	3000000	\N	\N	\N
255	160	42	addr_test1qqq4mu9jk98q5t9sr2yzq34mhfg8e96v2vha4t4v6fadjpgss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqss4ggs	f	\\x015df0b2b14e0a2cb01a882046bbba507c974c532fdaaeacd27ad905	73	3000000	\N	\N	\N
256	160	43	addr_test1qrfrfar7wu8kpx3c09z60yglvs23z64sdfkzz3msfwslx9gss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq3sxusc	f	\\xd234f47e770f609a387945a7911f6415116ab06a6c2147704ba1f315	73	3000000	\N	\N	\N
257	160	44	addr_test1qpp5s6hsraezxjzzg3zhdtkfc2nr85784gm58feljz3rdtcss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqjvekfl	f	\\x43486af01f72234842444576aec9c2a633d3c7aa3743a73f90a236af	73	3000000	\N	\N	\N
258	160	45	addr_test1qrahh68r8q06vj8qh9u8zhxlfrdplkfh5cgnu2347jczypgss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqzweusw	f	\\xfb7be8e3381fa648e0b978715cdf48da1fd937a6113e2a35f4b02205	73	3000000	\N	\N	\N
259	160	46	addr_test1qqhhw2pnv9tr77qjgtfvhhlua5zr37z7detexk7att97z8sss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqk8mlul	f	\\x2f77283361563f781242d2cbdffced0438f85e6e57935bdd5acbe11e	73	3000000	\N	\N	\N
260	160	47	addr_test1qz0alu88cghpddcaxsk0vf9kcmpmfm2w7tzeyktcyy97gscss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqhfztvv	f	\\x9fdff0e7c22e16b71d342cf624b6c6c3b4ed4ef2c5925978210be443	73	3000000	\N	\N	\N
261	160	48	addr_test1qzf9n5ztut53kwnkmpehw0jvgx7gmkpq692722wr607jflsss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqsyshyp	f	\\x9259d04be2e91b3a76d873773e4c41bc8dd820d155e529c3d3fd24fe	73	3000000	\N	\N	\N
262	160	49	addr_test1qrh5f2ck59e7kdqvyjt98zhzlgqe0xs50qfq0yw535asdmgss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqyafrv9	f	\\xef44ab16a173eb340c2496538ae2fa01979a1478120791d48d3b06ed	73	3000000	\N	\N	\N
263	160	50	addr_test1qq7fwgxxdn2n7unl2f2ug0jvan277xp7g06h8utg8v4sdxsss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqf9dzf0	f	\\x3c9720c66cd53f727f5255c43e4cecd5ef183e43f573f1683b2b069a	73	3000000	\N	\N	\N
264	160	51	addr_test1qqqw8uwczmmq963e8xvfcssd2kmvwhsgy9kkdsntl36chmqss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq9jvjt0	f	\\x00e3f1d816f602ea3939989c420d55b6c75e08216d66c26bfc758bec	73	3000000	\N	\N	\N
265	160	52	addr_test1qrnagzf0k7n9j69nujrfra8dyyfp2ce0qn0u9q38y2lk8tcss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqfqh530	f	\\xe7d4092fb7a65968b3e48691f4ed211215632f04dfc2822722bf63af	73	3000000	\N	\N	\N
266	160	53	addr_test1qpug7atnlrfs8w8638vqpegl7rxznc7kal8wd5xvaq4un4css8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq7a0d3d	f	\\x788f7573f8d303b8fa89d800e51ff0cc29e3d6efcee6d0cce82bc9d7	73	3000000	\N	\N	\N
267	160	54	addr_test1qq3x03e2yzamcv3clmxa5pujqt5tr25e85p80y0xddz56mgss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqtf58vk	f	\\x2267c72a20bbbc3238fecdda079202e8b1aa993d027791e66b454d6d	73	3000000	\N	\N	\N
268	160	55	addr_test1qqqqsp4rpk86ee9e4qxs7t852tk930peh30ev4f5u4jkxrgss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqpxr6gd	f	\\x000806a30d8face4b9a80d0f2cf452ec58bc39bc5f965534e565630d	73	3000000	\N	\N	\N
269	160	56	addr_test1qptxraa67n2r2khq556fastlkd7fnz0z9qnw3zmmca8ejmgss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqgxgv34	f	\\x5661f7baf4d4355ae0a5349ec17fb37c9989e22826e88b7bc74f996d	73	3000000	\N	\N	\N
270	160	57	addr_test1qr4pngrr44sg7pmjqam5jxhep2exkv5wsfyf62sz6707e2css8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqrrc8z3	f	\\xea19a063ad608f07720777491af90ab26b328e82489d2a02d79fecab	73	3000000	\N	\N	\N
271	160	58	addr_test1qzrdrsmu8t7qt5jpw8lpwppfyfrey394p5ggrnra666mwrqss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqh6ncam	f	\\x86d1c37c3afc05d24171fe17042922479244b50d1081cc7dd6b5b70c	73	3000000	\N	\N	\N
272	160	59	addr_test1qp6ytm4mxl25dhylusltf0ctjrfx92txv4k07nmszfhe8hqss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaqrek9yr	f	\\x7445eebb37d546dc9fe43eb4bf0b90d262a966656cff4f70126f93dc	73	3000000	\N	\N	\N
273	160	60	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	97434160038	\N	\N	\N
274	160	61	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
275	160	62	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
276	160	63	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
277	160	64	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
278	160	65	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
279	160	66	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
280	160	67	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
281	160	68	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
282	160	69	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
283	160	70	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
284	160	71	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
285	160	72	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
286	160	73	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
287	160	74	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
288	160	75	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
289	160	76	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
290	160	77	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
291	160	78	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
292	160	79	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
293	160	80	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
294	160	81	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
295	160	82	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
296	160	83	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
297	160	84	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
298	160	85	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
299	160	86	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
300	160	87	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
301	160	88	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
302	160	89	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
303	160	90	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
304	160	91	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
305	160	92	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
306	160	93	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
307	160	94	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
308	160	95	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
309	160	96	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
310	160	97	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
311	160	98	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
312	160	99	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
313	160	100	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
314	160	101	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
315	160	102	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
316	160	103	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
317	160	104	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
318	160	105	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
319	160	106	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
320	160	107	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
321	160	108	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
322	160	109	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
323	160	110	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
324	160	111	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
325	160	112	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
326	160	113	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
327	160	114	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
328	160	115	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
329	160	116	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
330	160	117	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
331	160	118	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
332	160	119	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090118903	\N	\N	\N
333	161	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	178500000	\N	\N	\N
334	161	1	addr_test1qr5rc6prrt3qze2854wcudwtlugfr32rfk5gtj54swwlysqss8p3dpdqqgr7mq52capjjkr2zg3kzhre39ya792ejdaq90e4zn	f	\\xe83c68231ae2016547a55d8e35cbff1091c5434da885ca95839df240	73	974447	\N	\N	\N
335	162	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999957805189	\N	\N	\N
336	162	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999971603821	\N	\N	\N
337	163	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999957805189	\N	\N	\N
338	163	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999971433656	\N	\N	\N
339	164	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	969750	\N	\N	\N
340	164	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999956665186	\N	\N	\N
341	165	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
342	165	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999961265251	\N	\N	\N
343	166	0	addr_test1xrsvx2tlzuu0g8ltqv5arghw7jtazvcnrerqfu9kfsrjnu8qcv5h79ec7s07kqef6x3waayh6ye3x8jxqnctvnq898cqt48v23	t	\\xe0c3297f1738f41feb0329d1a2eef497d133131e4604f0b64c0729f0	74	10000000	\N	\N	\N
344	166	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999951096846	\N	\N	\N
345	167	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1000000	\N	\N	\N
346	167	1	addr_test1xrsvx2tlzuu0g8ltqv5arghw7jtazvcnrerqfu9kfsrjnu8qcv5h79ec7s07kqef6x3waayh6ye3x8jxqnctvnq898cqt48v23	t	\\xe0c3297f1738f41feb0329d1a2eef497d133131e4604f0b64c0729f0	74	8818439	\N	\N	\N
347	168	0	addr_test1xzw8ewvtwurwxssydnm3pgh3k0catr80mcthlf483n3zctvu0juckacxudpqgm8hzz30rvl36kxwlhsh07n20r8z9sks4xdwjz	t	\\x9c7cb98b7706e342046cf710a2f1b3f1d58cefde177fa6a78ce22c2d	75	10000000	\N	\N	\N
348	168	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999940928441	\N	\N	\N
349	169	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1000000	\N	\N	\N
350	169	1	addr_test1xzw8ewvtwurwxssydnm3pgh3k0catr80mcthlf483n3zctvu0juckacxudpqgm8hzz30rvl36kxwlhsh07n20r8z9sks4xdwjz	t	\\x9c7cb98b7706e342046cf710a2f1b3f1d58cefde177fa6a78ce22c2d	75	6814039	\N	\N	\N
351	170	0	addr_test1xzw8ewvtwurwxssydnm3pgh3k0catr80mcthlf483n3zctvu0juckacxudpqgm8hzz30rvl36kxwlhsh07n20r8z9sks4xdwjz	t	\\x9c7cb98b7706e342046cf710a2f1b3f1d58cefde177fa6a78ce22c2d	75	8633754	\N	\N	\N
352	171	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	77	1000000000	\N	\N	\N
353	171	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2998956496781	\N	\N	\N
354	172	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	77	98675351	\N	\N	\N
355	172	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	78	99000000	\N	\N	\N
356	172	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	99000000	\N	\N	\N
357	172	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	80	99000000	\N	\N	\N
358	172	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	99000000	\N	\N	\N
359	172	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	77	49500000	\N	\N	\N
360	172	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	78	49500000	\N	\N	\N
361	172	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	49500000	\N	\N	\N
362	172	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	80	49500000	\N	\N	\N
363	172	9	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	49500000	\N	\N	\N
364	172	10	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	77	24750000	\N	\N	\N
365	172	11	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	78	24750000	\N	\N	\N
366	172	12	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	24750000	\N	\N	\N
367	172	13	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	80	24750000	\N	\N	\N
368	172	14	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	24750000	\N	\N	\N
369	172	15	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	77	12375000	\N	\N	\N
370	172	16	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	78	12375000	\N	\N	\N
371	172	17	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	12375000	\N	\N	\N
372	172	18	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	80	12375000	\N	\N	\N
373	172	19	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	12375000	\N	\N	\N
374	172	20	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	77	6187500	\N	\N	\N
375	172	21	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	78	6187500	\N	\N	\N
376	172	22	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	6187500	\N	\N	\N
377	172	23	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	80	6187500	\N	\N	\N
378	172	24	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	6187500	\N	\N	\N
379	172	25	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	77	3093750	\N	\N	\N
380	172	26	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	77	3093750	\N	\N	\N
381	172	27	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	78	3093750	\N	\N	\N
382	172	28	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	78	3093750	\N	\N	\N
383	172	29	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	3093750	\N	\N	\N
384	172	30	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	3093750	\N	\N	\N
385	172	31	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	80	3093750	\N	\N	\N
386	172	32	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	80	3093750	\N	\N	\N
387	172	33	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	3093750	\N	\N	\N
388	172	34	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	3093750	\N	\N	\N
389	173	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	494576915	\N	\N	\N
390	173	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	247418838	\N	\N	\N
391	173	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	123709419	\N	\N	\N
392	173	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	61854709	\N	\N	\N
393	173	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	30927355	\N	\N	\N
394	173	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	15463677	\N	\N	\N
395	173	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	7731839	\N	\N	\N
396	173	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	3865919	\N	\N	\N
397	173	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	3865919	\N	\N	\N
398	174	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	494375158	\N	\N	\N
399	175	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	72	1000000	\N	\N	\N
400	175	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999937746088	\N	\N	\N
401	176	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2798353	\N	\N	\N
402	177	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999936564131	\N	\N	\N
403	178	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
404	178	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999931395726	\N	\N	\N
405	179	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
406	179	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2998951328376	\N	\N	\N
407	180	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
408	180	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2998948956740	\N	\N	\N
409	181	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
410	181	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999926227321	\N	\N	\N
411	182	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
412	182	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999921058916	\N	\N	\N
413	183	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
414	183	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5828603	\N	\N	\N
415	184	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
416	184	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
417	185	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
418	185	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5658790	\N	\N	\N
419	186	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
420	186	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
421	187	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
422	187	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999915890511	\N	\N	\N
423	188	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
424	188	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5488977	\N	\N	\N
425	189	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
426	189	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4490561	\N	\N	\N
427	190	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
428	190	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5319164	\N	\N	\N
429	191	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
430	191	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4831771	\N	\N	\N
431	192	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
432	192	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
433	193	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
434	193	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4320748	\N	\N	\N
435	194	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
436	194	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999910722106	\N	\N	\N
437	195	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
438	195	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4150935	\N	\N	\N
439	196	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
440	196	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
441	197	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
442	197	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999905553701	\N	\N	\N
443	198	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
444	198	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999900385296	\N	\N	\N
445	199	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
446	199	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5149351	\N	\N	\N
447	200	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
448	200	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999895216891	\N	\N	\N
449	201	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
450	201	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
451	202	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
452	202	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4490561	\N	\N	\N
453	203	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
454	203	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999890048486	\N	\N	\N
455	204	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
456	204	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4661958	\N	\N	\N
457	205	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
458	205	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
459	206	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
460	206	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
461	207	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
462	207	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4979538	\N	\N	\N
463	208	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
464	208	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	3471683	\N	\N	\N
465	209	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
466	209	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4492145	\N	\N	\N
467	210	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
468	210	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
469	211	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
470	211	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4322332	\N	\N	\N
471	212	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
472	212	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
473	213	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
474	213	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2998943788335	\N	\N	\N
475	214	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
476	214	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999884880081	\N	\N	\N
477	215	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
478	215	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
479	216	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
480	216	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	3132057	\N	\N	\N
481	217	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
482	217	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2792431	\N	\N	\N
483	218	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
484	218	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2622618	\N	\N	\N
485	219	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
486	219	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4639912	\N	\N	\N
487	220	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
488	220	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4470099	\N	\N	\N
489	221	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
490	221	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
491	222	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
492	222	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
493	223	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
494	223	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4300286	\N	\N	\N
495	224	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
496	224	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2998938619930	\N	\N	\N
497	225	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
498	225	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	6773553	\N	\N	\N
499	226	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
500	226	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2998933451525	\N	\N	\N
501	227	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
502	227	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
503	228	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
504	228	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	6603740	\N	\N	\N
505	229	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
506	229	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
507	230	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
508	230	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
509	231	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
510	231	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999879711676	\N	\N	\N
511	232	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
512	232	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
513	233	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
514	233	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4320748	\N	\N	\N
515	234	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
516	234	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
517	235	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
518	235	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2998932581822	\N	\N	\N
519	236	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
520	236	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
521	237	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
522	237	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
523	238	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
524	238	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4490561	\N	\N	\N
525	239	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
526	239	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999874543271	\N	\N	\N
527	240	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
528	240	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	3981122	\N	\N	\N
529	241	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
530	241	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
531	242	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
532	242	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2998927413417	\N	\N	\N
533	243	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
534	243	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
535	244	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
536	244	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	3811309	\N	\N	\N
537	245	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
538	245	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2998922245012	\N	\N	\N
539	246	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
540	246	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
541	247	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
542	247	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
543	248	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
544	248	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	6433927	\N	\N	\N
545	249	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
546	249	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
547	250	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
548	250	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5075423	\N	\N	\N
549	251	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
550	251	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999869374866	\N	\N	\N
551	252	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
552	252	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
553	253	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
554	253	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
555	254	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
556	254	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4320748	\N	\N	\N
557	255	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
558	255	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
559	256	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
560	256	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
561	257	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
562	257	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4320748	\N	\N	\N
563	258	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
564	258	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4735797	\N	\N	\N
565	259	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
566	259	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	3981122	\N	\N	\N
567	260	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
568	260	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
569	261	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
570	261	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999864206461	\N	\N	\N
571	262	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
572	262	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
573	263	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
574	263	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
575	264	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
576	264	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
577	265	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
578	265	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	3886732	\N	\N	\N
579	266	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
580	266	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
581	267	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
582	267	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
583	268	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
584	268	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999863696846	\N	\N	\N
585	269	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
586	269	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4490561	\N	\N	\N
587	270	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
588	270	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4320748	\N	\N	\N
589	271	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
590	271	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4490561	\N	\N	\N
591	272	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
592	272	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2698041	\N	\N	\N
593	273	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
594	273	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999863017418	\N	\N	\N
595	274	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
596	274	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
597	275	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
598	275	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	7187018	\N	\N	\N
599	276	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
600	276	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
601	277	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
602	277	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	7017205	\N	\N	\N
603	278	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
604	278	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	3563576244	\N	\N	\N
605	279	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250612695310	\N	\N	\N
606	279	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	1250612954531	\N	\N	\N
607	279	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625306477266	\N	\N	\N
608	279	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	625306477265	\N	\N	\N
609	279	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312653238633	\N	\N	\N
610	279	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	312653238633	\N	\N	\N
611	279	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156326619316	\N	\N	\N
612	279	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	156326619316	\N	\N	\N
613	279	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78163309658	\N	\N	\N
614	279	9	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	78163309658	\N	\N	\N
615	279	10	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39081654829	\N	\N	\N
616	279	11	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39081654829	\N	\N	\N
617	279	12	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	39081654829	\N	\N	\N
618	279	13	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	39081654829	\N	\N	\N
619	280	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
620	280	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1259374123257	\N	\N	\N
621	281	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
622	281	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39076486424	\N	\N	\N
623	282	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
624	282	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1259368954852	\N	\N	\N
625	283	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
626	283	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1259363786447	\N	\N	\N
627	284	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
628	284	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	625306307276	\N	\N	\N
629	285	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
630	285	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	625301138871	\N	\N	\N
631	286	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
632	286	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78158141253	\N	\N	\N
633	287	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
634	287	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
635	288	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
636	288	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	78158141253	\N	\N	\N
637	289	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
638	289	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	156321450911	\N	\N	\N
639	290	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
640	290	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312653068644	\N	\N	\N
641	291	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
642	291	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	625300968882	\N	\N	\N
643	292	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
644	292	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	625295800477	\N	\N	\N
645	293	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
646	293	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156321450911	\N	\N	\N
647	294	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
648	294	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
649	295	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
650	295	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	78152972848	\N	\N	\N
651	296	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
652	296	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625306307277	\N	\N	\N
653	297	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
654	297	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39071318019	\N	\N	\N
655	298	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
656	298	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	1250607786126	\N	\N	\N
657	299	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
658	299	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	39076486424	\N	\N	\N
659	300	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
660	300	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625306137288	\N	\N	\N
661	301	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
662	301	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	78147804443	\N	\N	\N
663	302	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
664	302	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
665	303	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
666	303	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	156316282506	\N	\N	\N
667	304	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
668	304	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	1250607616137	\N	\N	\N
669	305	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
670	305	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4660374	\N	\N	\N
671	306	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
672	306	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	625290632072	\N	\N	\N
673	307	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
674	307	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	625285463667	\N	\N	\N
675	308	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
676	308	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39076486424	\N	\N	\N
677	309	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
678	309	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625300968883	\N	\N	\N
679	310	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
680	310	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1259358618042	\N	\N	\N
681	311	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
682	311	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	39076486424	\N	\N	\N
683	312	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
684	312	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
685	313	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
686	313	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4660374	\N	\N	\N
687	314	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
688	314	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39071318019	\N	\N	\N
689	315	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
690	315	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
691	316	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
692	316	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39066149614	\N	\N	\N
693	317	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
694	317	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	156311114101	\N	\N	\N
695	318	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
696	318	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78152972848	\N	\N	\N
697	319	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
698	319	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	39071318019	\N	\N	\N
699	320	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
700	320	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4660374	\N	\N	\N
701	321	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
702	321	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
703	322	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
704	322	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4660374	\N	\N	\N
705	323	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
706	323	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
707	324	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
708	324	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	39066149614	\N	\N	\N
709	325	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
710	325	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	312648070228	\N	\N	\N
711	326	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
712	326	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39060981209	\N	\N	\N
713	327	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
714	327	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156316282506	\N	\N	\N
715	328	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
716	328	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78147804443	\N	\N	\N
717	329	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
718	329	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	156305945696	\N	\N	\N
719	330	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
720	330	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312652898655	\N	\N	\N
721	331	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
722	331	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4490561	\N	\N	\N
723	332	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
724	332	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4150935	\N	\N	\N
725	333	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
726	333	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4660374	\N	\N	\N
727	334	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
728	334	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
729	335	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
730	335	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1259353449637	\N	\N	\N
731	336	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
732	336	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
733	337	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
734	337	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	39071318019	\N	\N	\N
735	338	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
736	338	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	156300777291	\N	\N	\N
737	339	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
738	339	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1259348281232	\N	\N	\N
739	340	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
740	340	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
741	341	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
742	341	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4490561	\N	\N	\N
743	342	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
744	342	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4320748	\N	\N	\N
745	343	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
746	343	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	1250602447732	\N	\N	\N
747	344	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
748	344	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39071148030	\N	\N	\N
749	345	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
750	345	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
751	346	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
752	346	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78142636038	\N	\N	\N
753	347	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
754	347	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
755	348	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
756	348	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	156295608886	\N	\N	\N
757	349	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
758	349	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	3641496	\N	\N	\N
759	350	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
760	350	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	1250597279327	\N	\N	\N
761	351	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
762	351	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
763	352	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
764	352	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
765	353	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
766	353	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4490561	\N	\N	\N
767	354	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
768	354	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	1250592110922	\N	\N	\N
769	355	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
770	355	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
771	356	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
772	356	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4660374	\N	\N	\N
773	357	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
774	357	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156311114101	\N	\N	\N
775	358	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
776	358	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4660374	\N	\N	\N
777	359	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
778	359	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
779	360	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
780	360	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39069619537	\N	\N	\N
781	361	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
782	361	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4320748	\N	\N	\N
783	362	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
784	362	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
785	363	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
786	363	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312647730250	\N	\N	\N
787	364	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
788	364	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4150935	\N	\N	\N
789	365	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
790	365	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39060811220	\N	\N	\N
791	366	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
792	366	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
793	367	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
794	367	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312642561845	\N	\N	\N
795	368	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
796	368	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4660374	\N	\N	\N
797	369	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
798	369	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	625284954052	\N	\N	\N
799	370	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
800	370	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
801	371	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
802	371	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4660374	\N	\N	\N
803	372	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
804	372	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
805	373	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
806	373	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
807	374	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
808	374	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4660374	\N	\N	\N
809	375	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
810	375	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
811	376	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
812	376	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156305945696	\N	\N	\N
813	377	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
814	377	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	156290440481	\N	\N	\N
815	378	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
816	378	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4830187	\N	\N	\N
817	379	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
818	379	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4490561	\N	\N	\N
819	380	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
820	380	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	8147040023	\N	\N	\N
821	381	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	3000000	\N	\N	\N
822	381	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	4999496820111	\N	\N	\N
823	382	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	3000000	\N	\N	\N
824	382	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	4999491650122	\N	\N	\N
825	383	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	3000000	\N	\N	\N
826	383	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	4999491472785	\N	\N	\N
827	384	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	3000000	\N	\N	\N
828	384	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	4999516811355	\N	\N	\N
829	385	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	3000000	\N	\N	\N
830	385	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	7825435	\N	\N	\N
831	386	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	3000000	\N	\N	\N
832	386	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	7645106	\N	\N	\N
833	387	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	5	\N
834	387	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	312637835383	\N	\N	\N
835	388	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\\xff1a404ece117cc4482d26b072e30b5a6b3cd055a22debda3f90d704957e273a	6	\N
836	388	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	1250581888793	\N	\N	\N
837	389	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\\x29294f077464c36e67b304ad22547fb3dfa946623b0b2cbae8acea7fb299353c	7	\N
838	389	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	4774043	\N	\N	\N
839	390	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	89	78147613070	\N	\N	\N
\.


--
-- Data for Name: voting_anchor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.voting_anchor (id, tx_id, url, data_hash) FROM stdin;
\.


--
-- Data for Name: voting_procedure; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.voting_procedure (id, tx_id, index, gov_action_proposal_id, voter_role, committee_voter, drep_voter, pool_voter, vote, voting_anchor_id) FROM stdin;
\.


--
-- Data for Name: withdrawal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.withdrawal (id, addr_id, amount, redeemer_id, tx_id) FROM stdin;
1	68	3564090215	\N	278
2	68	8766602644	\N	280
3	89	2352469859	\N	380
4	68	5794750889	\N	380
\.


--
-- Name: ada_pots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ada_pots_id_seq', 11, true);


--
-- Name: block_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.block_id_seq', 1188, true);


--
-- Name: collateral_tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collateral_tx_in_id_seq', 2, true);


--
-- Name: collateral_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collateral_tx_out_id_seq', 2, true);


--
-- Name: committee_de_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.committee_de_registration_id_seq', 1, false);


--
-- Name: committee_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.committee_registration_id_seq', 1, false);


--
-- Name: constitution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.constitution_id_seq', 1, false);


--
-- Name: cost_model_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cost_model_id_seq', 11, true);


--
-- Name: datum_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.datum_id_seq', 7, true);


--
-- Name: delegation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delegation_id_seq', 53, true);


--
-- Name: delegation_vote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delegation_vote_id_seq', 1, false);


--
-- Name: delisted_pool_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delisted_pool_id_seq', 1, false);


--
-- Name: drep_distr_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drep_distr_id_seq', 1, false);


--
-- Name: drep_hash_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drep_hash_id_seq', 1, false);


--
-- Name: drep_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drep_registration_id_seq', 1, false);


--
-- Name: epoch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_id_seq', 32, true);


--
-- Name: epoch_param_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_param_id_seq', 11, true);


--
-- Name: epoch_stake_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_stake_id_seq', 429, true);


--
-- Name: epoch_stake_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_stake_progress_id_seq', 13, true);


--
-- Name: epoch_sync_time_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_sync_time_id_seq', 11, true);


--
-- Name: extra_key_witness_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.extra_key_witness_id_seq', 1, false);


--
-- Name: extra_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.extra_migrations_id_seq', 1, true);


--
-- Name: gov_action_proposal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.gov_action_proposal_id_seq', 1, false);


--
-- Name: ma_tx_mint_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_mint_id_seq', 50, true);


--
-- Name: ma_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_out_id_seq', 66, true);


--
-- Name: meta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meta_id_seq', 1, true);


--
-- Name: multi_asset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.multi_asset_id_seq', 22, true);


--
-- Name: new_committee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.new_committee_id_seq', 1, false);


--
-- Name: off_chain_pool_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_pool_data_id_seq', 8, true);


--
-- Name: off_chain_pool_fetch_error_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_pool_fetch_error_id_seq', 1, false);


--
-- Name: off_chain_vote_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_vote_data_id_seq', 1, false);


--
-- Name: off_chain_vote_fetch_error_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_vote_fetch_error_id_seq', 1, false);


--
-- Name: param_proposal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.param_proposal_id_seq', 1, false);


--
-- Name: pool_hash_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_hash_id_seq', 13, true);


--
-- Name: pool_metadata_ref_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_metadata_ref_id_seq', 8, true);


--
-- Name: pool_owner_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_owner_id_seq', 13, true);


--
-- Name: pool_relay_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_relay_id_seq', 13, true);


--
-- Name: pool_retire_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_retire_id_seq', 4, true);


--
-- Name: pool_update_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_update_id_seq', 24, true);


--
-- Name: pot_transfer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pot_transfer_id_seq', 1, false);


--
-- Name: redeemer_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.redeemer_data_id_seq', 2, true);


--
-- Name: redeemer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.redeemer_id_seq', 2, true);


--
-- Name: reference_tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reference_tx_in_id_seq', 1, true);


--
-- Name: reserve_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reserve_id_seq', 1, false);


--
-- Name: reserved_pool_ticker_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reserved_pool_ticker_id_seq', 1, false);


--
-- Name: reverse_index_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reverse_index_id_seq', 1186, true);


--
-- Name: schema_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schema_version_id_seq', 1, true);


--
-- Name: script_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.script_id_seq', 10, true);


--
-- Name: slot_leader_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slot_leader_id_seq', 1188, true);


--
-- Name: stake_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_address_id_seq', 92, true);


--
-- Name: stake_deregistration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_deregistration_id_seq', 2, true);


--
-- Name: stake_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_registration_id_seq', 44, true);


--
-- Name: treasury_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.treasury_id_seq', 1, false);


--
-- Name: treasury_withdrawal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.treasury_withdrawal_id_seq', 1, false);


--
-- Name: tx_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_id_seq', 390, true);


--
-- Name: tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_in_id_seq', 691, true);


--
-- Name: tx_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_metadata_id_seq', 23, true);


--
-- Name: tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_out_id_seq', 839, true);


--
-- Name: voting_anchor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.voting_anchor_id_seq', 1, false);


--
-- Name: voting_procedure_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.voting_procedure_id_seq', 1, false);


--
-- Name: withdrawal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.withdrawal_id_seq', 4, true);


--
-- Name: ada_pots ada_pots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ada_pots
    ADD CONSTRAINT ada_pots_pkey PRIMARY KEY (id);


--
-- Name: block block_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.block
    ADD CONSTRAINT block_pkey PRIMARY KEY (id);


--
-- Name: collateral_tx_in collateral_tx_in_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collateral_tx_in
    ADD CONSTRAINT collateral_tx_in_pkey PRIMARY KEY (id);


--
-- Name: collateral_tx_out collateral_tx_out_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collateral_tx_out
    ADD CONSTRAINT collateral_tx_out_pkey PRIMARY KEY (id);


--
-- Name: committee_de_registration committee_de_registration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.committee_de_registration
    ADD CONSTRAINT committee_de_registration_pkey PRIMARY KEY (id);


--
-- Name: committee_registration committee_registration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.committee_registration
    ADD CONSTRAINT committee_registration_pkey PRIMARY KEY (id);


--
-- Name: constitution constitution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.constitution
    ADD CONSTRAINT constitution_pkey PRIMARY KEY (id);


--
-- Name: cost_model cost_model_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_model
    ADD CONSTRAINT cost_model_pkey PRIMARY KEY (id);


--
-- Name: datum datum_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.datum
    ADD CONSTRAINT datum_pkey PRIMARY KEY (id);


--
-- Name: delegation delegation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delegation
    ADD CONSTRAINT delegation_pkey PRIMARY KEY (id);


--
-- Name: delegation_vote delegation_vote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delegation_vote
    ADD CONSTRAINT delegation_vote_pkey PRIMARY KEY (id);


--
-- Name: delisted_pool delisted_pool_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delisted_pool
    ADD CONSTRAINT delisted_pool_pkey PRIMARY KEY (id);


--
-- Name: drep_distr drep_distr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drep_distr
    ADD CONSTRAINT drep_distr_pkey PRIMARY KEY (id);


--
-- Name: drep_hash drep_hash_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drep_hash
    ADD CONSTRAINT drep_hash_pkey PRIMARY KEY (id);


--
-- Name: drep_registration drep_registration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drep_registration
    ADD CONSTRAINT drep_registration_pkey PRIMARY KEY (id);


--
-- Name: epoch_param epoch_param_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_param
    ADD CONSTRAINT epoch_param_pkey PRIMARY KEY (id);


--
-- Name: epoch epoch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch
    ADD CONSTRAINT epoch_pkey PRIMARY KEY (id);


--
-- Name: epoch_stake epoch_stake_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_stake
    ADD CONSTRAINT epoch_stake_pkey PRIMARY KEY (id);


--
-- Name: epoch_stake_progress epoch_stake_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_stake_progress
    ADD CONSTRAINT epoch_stake_progress_pkey PRIMARY KEY (id);


--
-- Name: epoch_sync_time epoch_sync_time_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_sync_time
    ADD CONSTRAINT epoch_sync_time_pkey PRIMARY KEY (id);


--
-- Name: extra_key_witness extra_key_witness_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extra_key_witness
    ADD CONSTRAINT extra_key_witness_pkey PRIMARY KEY (id);


--
-- Name: extra_migrations extra_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extra_migrations
    ADD CONSTRAINT extra_migrations_pkey PRIMARY KEY (id);


--
-- Name: gov_action_proposal gov_action_proposal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gov_action_proposal
    ADD CONSTRAINT gov_action_proposal_pkey PRIMARY KEY (id);


--
-- Name: ma_tx_mint ma_tx_mint_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ma_tx_mint
    ADD CONSTRAINT ma_tx_mint_pkey PRIMARY KEY (id);


--
-- Name: ma_tx_out ma_tx_out_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ma_tx_out
    ADD CONSTRAINT ma_tx_out_pkey PRIMARY KEY (id);


--
-- Name: meta meta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meta
    ADD CONSTRAINT meta_pkey PRIMARY KEY (id);


--
-- Name: multi_asset multi_asset_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.multi_asset
    ADD CONSTRAINT multi_asset_pkey PRIMARY KEY (id);


--
-- Name: new_committee new_committee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.new_committee
    ADD CONSTRAINT new_committee_pkey PRIMARY KEY (id);


--
-- Name: off_chain_pool_data off_chain_pool_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_pool_data
    ADD CONSTRAINT off_chain_pool_data_pkey PRIMARY KEY (id);


--
-- Name: off_chain_pool_fetch_error off_chain_pool_fetch_error_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_pool_fetch_error
    ADD CONSTRAINT off_chain_pool_fetch_error_pkey PRIMARY KEY (id);


--
-- Name: off_chain_vote_data off_chain_vote_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_data
    ADD CONSTRAINT off_chain_vote_data_pkey PRIMARY KEY (id);


--
-- Name: off_chain_vote_fetch_error off_chain_vote_fetch_error_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_fetch_error
    ADD CONSTRAINT off_chain_vote_fetch_error_pkey PRIMARY KEY (id);


--
-- Name: param_proposal param_proposal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.param_proposal
    ADD CONSTRAINT param_proposal_pkey PRIMARY KEY (id);


--
-- Name: pool_hash pool_hash_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_hash
    ADD CONSTRAINT pool_hash_pkey PRIMARY KEY (id);


--
-- Name: pool_metadata_ref pool_metadata_ref_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata_ref
    ADD CONSTRAINT pool_metadata_ref_pkey PRIMARY KEY (id);


--
-- Name: pool_owner pool_owner_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_owner
    ADD CONSTRAINT pool_owner_pkey PRIMARY KEY (id);


--
-- Name: pool_relay pool_relay_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_relay
    ADD CONSTRAINT pool_relay_pkey PRIMARY KEY (id);


--
-- Name: pool_retire pool_retire_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_retire
    ADD CONSTRAINT pool_retire_pkey PRIMARY KEY (id);


--
-- Name: pool_update pool_update_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_update
    ADD CONSTRAINT pool_update_pkey PRIMARY KEY (id);


--
-- Name: pot_transfer pot_transfer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pot_transfer
    ADD CONSTRAINT pot_transfer_pkey PRIMARY KEY (id);


--
-- Name: redeemer_data redeemer_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.redeemer_data
    ADD CONSTRAINT redeemer_data_pkey PRIMARY KEY (id);


--
-- Name: redeemer redeemer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.redeemer
    ADD CONSTRAINT redeemer_pkey PRIMARY KEY (id);


--
-- Name: reference_tx_in reference_tx_in_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reference_tx_in
    ADD CONSTRAINT reference_tx_in_pkey PRIMARY KEY (id);


--
-- Name: reserve reserve_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reserve
    ADD CONSTRAINT reserve_pkey PRIMARY KEY (id);


--
-- Name: reserved_pool_ticker reserved_pool_ticker_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reserved_pool_ticker
    ADD CONSTRAINT reserved_pool_ticker_pkey PRIMARY KEY (id);


--
-- Name: reverse_index reverse_index_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reverse_index
    ADD CONSTRAINT reverse_index_pkey PRIMARY KEY (id);


--
-- Name: schema_version schema_version_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_version
    ADD CONSTRAINT schema_version_pkey PRIMARY KEY (id);


--
-- Name: script script_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.script
    ADD CONSTRAINT script_pkey PRIMARY KEY (id);


--
-- Name: slot_leader slot_leader_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slot_leader
    ADD CONSTRAINT slot_leader_pkey PRIMARY KEY (id);


--
-- Name: stake_address stake_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_address
    ADD CONSTRAINT stake_address_pkey PRIMARY KEY (id);


--
-- Name: stake_deregistration stake_deregistration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_deregistration
    ADD CONSTRAINT stake_deregistration_pkey PRIMARY KEY (id);


--
-- Name: stake_registration stake_registration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_registration
    ADD CONSTRAINT stake_registration_pkey PRIMARY KEY (id);


--
-- Name: treasury treasury_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.treasury
    ADD CONSTRAINT treasury_pkey PRIMARY KEY (id);


--
-- Name: treasury_withdrawal treasury_withdrawal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.treasury_withdrawal
    ADD CONSTRAINT treasury_withdrawal_pkey PRIMARY KEY (id);


--
-- Name: tx_in tx_in_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tx_in
    ADD CONSTRAINT tx_in_pkey PRIMARY KEY (id);


--
-- Name: tx_metadata tx_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tx_metadata
    ADD CONSTRAINT tx_metadata_pkey PRIMARY KEY (id);


--
-- Name: tx_out tx_out_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tx_out
    ADD CONSTRAINT tx_out_pkey PRIMARY KEY (id);


--
-- Name: tx tx_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tx
    ADD CONSTRAINT tx_pkey PRIMARY KEY (id);


--
-- Name: block unique_block; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.block
    ADD CONSTRAINT unique_block UNIQUE (hash);


--
-- Name: cost_model unique_cost_model; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_model
    ADD CONSTRAINT unique_cost_model UNIQUE (hash);


--
-- Name: datum unique_datum; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.datum
    ADD CONSTRAINT unique_datum UNIQUE (hash);


--
-- Name: delisted_pool unique_delisted_pool; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delisted_pool
    ADD CONSTRAINT unique_delisted_pool UNIQUE (hash_raw);


--
-- Name: drep_distr unique_drep_distr; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drep_distr
    ADD CONSTRAINT unique_drep_distr UNIQUE (hash_id, epoch_no);


--
-- Name: drep_hash unique_drep_hash; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drep_hash
    ADD CONSTRAINT unique_drep_hash UNIQUE (raw);


--
-- Name: epoch unique_epoch; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch
    ADD CONSTRAINT unique_epoch UNIQUE (no);


--
-- Name: epoch_stake unique_epoch_stake; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_stake
    ADD CONSTRAINT unique_epoch_stake UNIQUE (epoch_no, addr_id, pool_id);


--
-- Name: epoch_stake_progress unique_epoch_stake_progress; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_stake_progress
    ADD CONSTRAINT unique_epoch_stake_progress UNIQUE (epoch_no);


--
-- Name: epoch_sync_time unique_epoch_sync_time; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_sync_time
    ADD CONSTRAINT unique_epoch_sync_time UNIQUE (no);


--
-- Name: instant_reward unique_instant_reward; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instant_reward
    ADD CONSTRAINT unique_instant_reward UNIQUE (addr_id, earned_epoch, type);


--
-- Name: meta unique_meta; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meta
    ADD CONSTRAINT unique_meta UNIQUE (start_time);


--
-- Name: multi_asset unique_multi_asset; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.multi_asset
    ADD CONSTRAINT unique_multi_asset UNIQUE (policy, name);


--
-- Name: off_chain_pool_data unique_off_chain_pool_data; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_pool_data
    ADD CONSTRAINT unique_off_chain_pool_data UNIQUE (pool_id, hash);


--
-- Name: off_chain_pool_fetch_error unique_off_chain_pool_fetch_error; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_pool_fetch_error
    ADD CONSTRAINT unique_off_chain_pool_fetch_error UNIQUE (pool_id, fetch_time, retry_count);


--
-- Name: off_chain_vote_data unique_off_chain_vote_data; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_data
    ADD CONSTRAINT unique_off_chain_vote_data UNIQUE (voting_anchor_id, hash);


--
-- Name: off_chain_vote_fetch_error unique_off_chain_vote_fetch_error; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_fetch_error
    ADD CONSTRAINT unique_off_chain_vote_fetch_error UNIQUE (voting_anchor_id, retry_count);


--
-- Name: pool_hash unique_pool_hash; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_hash
    ADD CONSTRAINT unique_pool_hash UNIQUE (hash_raw);


--
-- Name: pool_metadata_ref unique_pool_metadata_ref; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata_ref
    ADD CONSTRAINT unique_pool_metadata_ref UNIQUE (pool_id, url, hash);


--
-- Name: redeemer_data unique_redeemer_data; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.redeemer_data
    ADD CONSTRAINT unique_redeemer_data UNIQUE (hash);


--
-- Name: reserved_pool_ticker unique_reserved_pool_ticker; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reserved_pool_ticker
    ADD CONSTRAINT unique_reserved_pool_ticker UNIQUE (name);


--
-- Name: reward unique_reward; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reward
    ADD CONSTRAINT unique_reward UNIQUE (addr_id, type, earned_epoch, pool_id);


--
-- Name: script unique_script; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.script
    ADD CONSTRAINT unique_script UNIQUE (hash);


--
-- Name: slot_leader unique_slot_leader; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slot_leader
    ADD CONSTRAINT unique_slot_leader UNIQUE (hash);


--
-- Name: stake_address unique_stake_address; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_address
    ADD CONSTRAINT unique_stake_address UNIQUE (hash_raw);


--
-- Name: tx unique_tx; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tx
    ADD CONSTRAINT unique_tx UNIQUE (hash);


--
-- Name: tx_out unique_txout; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tx_out
    ADD CONSTRAINT unique_txout UNIQUE (tx_id, index);


--
-- Name: voting_anchor unique_voting_anchor; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voting_anchor
    ADD CONSTRAINT unique_voting_anchor UNIQUE (data_hash, url);


--
-- Name: voting_anchor voting_anchor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voting_anchor
    ADD CONSTRAINT voting_anchor_pkey PRIMARY KEY (id);


--
-- Name: voting_procedure voting_procedure_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voting_procedure
    ADD CONSTRAINT voting_procedure_pkey PRIMARY KEY (id);


--
-- Name: withdrawal withdrawal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.withdrawal
    ADD CONSTRAINT withdrawal_pkey PRIMARY KEY (id);


--
-- Name: collateral_tx_out_inline_datum_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX collateral_tx_out_inline_datum_id_idx ON public.collateral_tx_out USING btree (inline_datum_id);


--
-- Name: collateral_tx_out_reference_script_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX collateral_tx_out_reference_script_id_idx ON public.collateral_tx_out USING btree (reference_script_id);


--
-- Name: collateral_tx_out_stake_address_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX collateral_tx_out_stake_address_id_idx ON public.collateral_tx_out USING btree (stake_address_id);


--
-- Name: idx_block_block_no; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_block_block_no ON public.block USING btree (block_no);


--
-- Name: idx_block_epoch_no; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_block_epoch_no ON public.block USING btree (epoch_no);


--
-- Name: idx_block_previous_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_block_previous_id ON public.block USING btree (previous_id);


--
-- Name: idx_block_slot_leader_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_block_slot_leader_id ON public.block USING btree (slot_leader_id);


--
-- Name: idx_block_slot_no; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_block_slot_no ON public.block USING btree (slot_no);


--
-- Name: idx_block_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_block_time ON public.block USING btree ("time");


--
-- Name: idx_collateral_tx_in_tx_out_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_collateral_tx_in_tx_out_id ON public.collateral_tx_in USING btree (tx_out_id);


--
-- Name: idx_datum_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_datum_tx_id ON public.datum USING btree (tx_id);


--
-- Name: idx_delegation_active_epoch_no; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegation_active_epoch_no ON public.delegation USING btree (active_epoch_no);


--
-- Name: idx_delegation_addr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegation_addr_id ON public.delegation USING btree (addr_id);


--
-- Name: idx_delegation_pool_hash_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegation_pool_hash_id ON public.delegation USING btree (pool_hash_id);


--
-- Name: idx_delegation_redeemer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegation_redeemer_id ON public.delegation USING btree (redeemer_id);


--
-- Name: idx_delegation_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegation_tx_id ON public.delegation USING btree (tx_id);


--
-- Name: idx_epoch_no; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_epoch_no ON public.epoch USING btree (no);


--
-- Name: idx_epoch_param_block_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_epoch_param_block_id ON public.epoch_param USING btree (block_id);


--
-- Name: idx_epoch_param_cost_model_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_epoch_param_cost_model_id ON public.epoch_param USING btree (cost_model_id);


--
-- Name: idx_epoch_stake_addr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_epoch_stake_addr_id ON public.epoch_stake USING btree (addr_id);


--
-- Name: idx_epoch_stake_epoch_no; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_epoch_stake_epoch_no ON public.epoch_stake USING btree (epoch_no);


--
-- Name: idx_epoch_stake_pool_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_epoch_stake_pool_id ON public.epoch_stake USING btree (pool_id);


--
-- Name: idx_extra_key_witness_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_extra_key_witness_tx_id ON public.extra_key_witness USING btree (tx_id);


--
-- Name: idx_ma_tx_mint_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ma_tx_mint_tx_id ON public.ma_tx_mint USING btree (tx_id);


--
-- Name: idx_ma_tx_out_tx_out_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ma_tx_out_tx_out_id ON public.ma_tx_out USING btree (tx_out_id);


--
-- Name: idx_off_chain_pool_data_pmr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_off_chain_pool_data_pmr_id ON public.off_chain_pool_data USING btree (pmr_id);


--
-- Name: idx_off_chain_pool_fetch_error_pmr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_off_chain_pool_fetch_error_pmr_id ON public.off_chain_pool_fetch_error USING btree (pmr_id);


--
-- Name: idx_param_proposal_cost_model_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_param_proposal_cost_model_id ON public.param_proposal USING btree (cost_model_id);


--
-- Name: idx_param_proposal_registered_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_param_proposal_registered_tx_id ON public.param_proposal USING btree (registered_tx_id);


--
-- Name: idx_pool_metadata_ref_pool_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pool_metadata_ref_pool_id ON public.pool_metadata_ref USING btree (pool_id);


--
-- Name: idx_pool_metadata_ref_registered_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pool_metadata_ref_registered_tx_id ON public.pool_metadata_ref USING btree (registered_tx_id);


--
-- Name: idx_pool_relay_update_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pool_relay_update_id ON public.pool_relay USING btree (update_id);


--
-- Name: idx_pool_retire_announced_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pool_retire_announced_tx_id ON public.pool_retire USING btree (announced_tx_id);


--
-- Name: idx_pool_retire_hash_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pool_retire_hash_id ON public.pool_retire USING btree (hash_id);


--
-- Name: idx_pool_update_active_epoch_no; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pool_update_active_epoch_no ON public.pool_update USING btree (active_epoch_no);


--
-- Name: idx_pool_update_hash_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pool_update_hash_id ON public.pool_update USING btree (hash_id);


--
-- Name: idx_pool_update_meta_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pool_update_meta_id ON public.pool_update USING btree (meta_id);


--
-- Name: idx_pool_update_registered_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pool_update_registered_tx_id ON public.pool_update USING btree (registered_tx_id);


--
-- Name: idx_pool_update_reward_addr; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pool_update_reward_addr ON public.pool_update USING btree (reward_addr_id);


--
-- Name: idx_reserve_addr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reserve_addr_id ON public.reserve USING btree (addr_id);


--
-- Name: idx_reserve_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reserve_tx_id ON public.reserve USING btree (tx_id);


--
-- Name: idx_reserved_pool_ticker_pool_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reserved_pool_ticker_pool_hash ON public.reserved_pool_ticker USING btree (pool_hash);


--
-- Name: idx_reward_addr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reward_addr_id ON public.reward USING btree (addr_id);


--
-- Name: idx_reward_earned_epoch; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reward_earned_epoch ON public.reward USING btree (earned_epoch);


--
-- Name: idx_reward_pool_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reward_pool_id ON public.reward USING btree (pool_id);


--
-- Name: idx_reward_spendable_epoch; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reward_spendable_epoch ON public.reward USING btree (spendable_epoch);


--
-- Name: idx_script_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_script_tx_id ON public.script USING btree (tx_id);


--
-- Name: idx_slot_leader_pool_hash_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_slot_leader_pool_hash_id ON public.slot_leader USING btree (pool_hash_id);


--
-- Name: idx_stake_address_hash_raw; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stake_address_hash_raw ON public.stake_address USING btree (hash_raw);


--
-- Name: idx_stake_address_view; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stake_address_view ON public.stake_address USING hash (view);


--
-- Name: idx_stake_deregistration_addr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stake_deregistration_addr_id ON public.stake_deregistration USING btree (addr_id);


--
-- Name: idx_stake_deregistration_redeemer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stake_deregistration_redeemer_id ON public.stake_deregistration USING btree (redeemer_id);


--
-- Name: idx_stake_deregistration_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stake_deregistration_tx_id ON public.stake_deregistration USING btree (tx_id);


--
-- Name: idx_stake_registration_addr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stake_registration_addr_id ON public.stake_registration USING btree (addr_id);


--
-- Name: idx_stake_registration_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stake_registration_tx_id ON public.stake_registration USING btree (tx_id);


--
-- Name: idx_treasury_addr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_treasury_addr_id ON public.treasury USING btree (addr_id);


--
-- Name: idx_treasury_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_treasury_tx_id ON public.treasury USING btree (tx_id);


--
-- Name: idx_tx_block_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tx_block_id ON public.tx USING btree (block_id);


--
-- Name: idx_tx_in_redeemer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tx_in_redeemer_id ON public.tx_in USING btree (redeemer_id);


--
-- Name: idx_tx_in_tx_in_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tx_in_tx_in_id ON public.tx_in USING btree (tx_in_id);


--
-- Name: idx_tx_in_tx_out_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tx_in_tx_out_id ON public.tx_in USING btree (tx_out_id);


--
-- Name: idx_tx_metadata_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tx_metadata_tx_id ON public.tx_metadata USING btree (tx_id);


--
-- Name: idx_tx_out_address; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tx_out_address ON public.tx_out USING hash (address);


--
-- Name: idx_tx_out_payment_cred; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tx_out_payment_cred ON public.tx_out USING btree (payment_cred);


--
-- Name: idx_tx_out_stake_address_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tx_out_stake_address_id ON public.tx_out USING btree (stake_address_id);


--
-- Name: idx_tx_out_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tx_out_tx_id ON public.tx_out USING btree (tx_id);


--
-- Name: idx_withdrawal_addr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_withdrawal_addr_id ON public.withdrawal USING btree (addr_id);


--
-- Name: idx_withdrawal_redeemer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_withdrawal_redeemer_id ON public.withdrawal USING btree (redeemer_id);


--
-- Name: idx_withdrawal_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_withdrawal_tx_id ON public.withdrawal USING btree (tx_id);


--
-- Name: pool_owner_pool_update_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pool_owner_pool_update_id_idx ON public.pool_owner USING btree (pool_update_id);


--
-- Name: redeemer_data_tx_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX redeemer_data_tx_id_idx ON public.redeemer_data USING btree (tx_id);


--
-- Name: redeemer_redeemer_data_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX redeemer_redeemer_data_id_idx ON public.redeemer USING btree (redeemer_data_id);


--
-- Name: reference_tx_in_tx_out_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX reference_tx_in_tx_out_id_idx ON public.reference_tx_in USING btree (tx_out_id);


--
-- Name: tx_out_inline_datum_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tx_out_inline_datum_id_idx ON public.tx_out USING btree (inline_datum_id);


--
-- Name: tx_out_reference_script_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tx_out_reference_script_id_idx ON public.tx_out USING btree (reference_script_id);


--
-- PostgreSQL database dump complete
--

