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
-- Name: anchortype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.anchortype AS ENUM (
    'gov_action',
    'other'
);


ALTER TYPE public.anchortype OWNER TO postgres;

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
    'reward',
    'vote',
    'propose'
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
    voting_anchor_id bigint,
    cold_key_id bigint NOT NULL
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
-- Name: committee_hash; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.committee_hash (
    id bigint NOT NULL,
    raw public.hash28type NOT NULL,
    has_script boolean NOT NULL
);


ALTER TABLE public.committee_hash OWNER TO postgres;

--
-- Name: committee_hash_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.committee_hash_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.committee_hash_id_seq OWNER TO postgres;

--
-- Name: committee_hash_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.committee_hash_id_seq OWNED BY public.committee_hash.id;


--
-- Name: committee_registration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.committee_registration (
    id bigint NOT NULL,
    tx_id bigint NOT NULL,
    cert_index integer NOT NULL,
    cold_key_id bigint NOT NULL,
    hot_key_id bigint NOT NULL
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
    drep_activity public.word64type,
    pvtpp_security_group double precision
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
    description jsonb NOT NULL,
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
-- Name: new_committee_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.new_committee_info (
    id bigint NOT NULL,
    gov_action_proposal_id bigint NOT NULL,
    quorum_numerator bigint NOT NULL,
    quorum_denominator bigint NOT NULL
);


ALTER TABLE public.new_committee_info OWNER TO postgres;

--
-- Name: new_committee_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.new_committee_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.new_committee_info_id_seq OWNER TO postgres;

--
-- Name: new_committee_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.new_committee_info_id_seq OWNED BY public.new_committee_info.id;


--
-- Name: new_committee_member; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.new_committee_member (
    id bigint NOT NULL,
    gov_action_proposal_id bigint NOT NULL,
    committee_hash_id bigint NOT NULL,
    expiration_epoch public.word31type NOT NULL
);


ALTER TABLE public.new_committee_member OWNER TO postgres;

--
-- Name: new_committee_member_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.new_committee_member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.new_committee_member_id_seq OWNER TO postgres;

--
-- Name: new_committee_member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.new_committee_member_id_seq OWNED BY public.new_committee_member.id;


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
-- Name: off_chain_vote_author; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.off_chain_vote_author (
    id bigint NOT NULL,
    off_chain_vote_data_id bigint NOT NULL,
    name character varying,
    witness_algorithm character varying NOT NULL,
    public_key character varying NOT NULL,
    signature character varying NOT NULL,
    warning character varying
);


ALTER TABLE public.off_chain_vote_author OWNER TO postgres;

--
-- Name: off_chain_vote_author_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.off_chain_vote_author_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.off_chain_vote_author_id_seq OWNER TO postgres;

--
-- Name: off_chain_vote_author_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.off_chain_vote_author_id_seq OWNED BY public.off_chain_vote_author.id;


--
-- Name: off_chain_vote_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.off_chain_vote_data (
    id bigint NOT NULL,
    voting_anchor_id bigint NOT NULL,
    hash bytea NOT NULL,
    json jsonb NOT NULL,
    bytes bytea NOT NULL,
    warning character varying,
    language character varying NOT NULL,
    comment character varying,
    title character varying,
    abstract character varying,
    motivation character varying,
    rationale character varying,
    is_valid boolean
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
-- Name: off_chain_vote_external_update; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.off_chain_vote_external_update (
    id bigint NOT NULL,
    off_chain_vote_data_id bigint NOT NULL,
    title character varying NOT NULL,
    uri character varying NOT NULL
);


ALTER TABLE public.off_chain_vote_external_update OWNER TO postgres;

--
-- Name: off_chain_vote_external_update_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.off_chain_vote_external_update_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.off_chain_vote_external_update_id_seq OWNER TO postgres;

--
-- Name: off_chain_vote_external_update_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.off_chain_vote_external_update_id_seq OWNED BY public.off_chain_vote_external_update.id;


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
-- Name: off_chain_vote_reference; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.off_chain_vote_reference (
    id bigint NOT NULL,
    off_chain_vote_data_id bigint NOT NULL,
    label character varying NOT NULL,
    uri character varying NOT NULL,
    hash_digest character varying,
    hash_algorithm character varying
);


ALTER TABLE public.off_chain_vote_reference OWNER TO postgres;

--
-- Name: off_chain_vote_reference_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.off_chain_vote_reference_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.off_chain_vote_reference_id_seq OWNER TO postgres;

--
-- Name: off_chain_vote_reference_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.off_chain_vote_reference_id_seq OWNED BY public.off_chain_vote_reference.id;


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
    drep_activity public.word64type,
    pvtpp_security_group double precision
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
    data_hash bytea NOT NULL,
    type public.anchortype NOT NULL
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
    drep_voter bigint,
    pool_voter bigint,
    vote public.vote NOT NULL,
    voting_anchor_id bigint,
    committee_voter bigint
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
-- Name: committee_hash id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.committee_hash ALTER COLUMN id SET DEFAULT nextval('public.committee_hash_id_seq'::regclass);


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
-- Name: new_committee_info id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.new_committee_info ALTER COLUMN id SET DEFAULT nextval('public.new_committee_info_id_seq'::regclass);


--
-- Name: new_committee_member id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.new_committee_member ALTER COLUMN id SET DEFAULT nextval('public.new_committee_member_id_seq'::regclass);


--
-- Name: off_chain_pool_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_pool_data ALTER COLUMN id SET DEFAULT nextval('public.off_chain_pool_data_id_seq'::regclass);


--
-- Name: off_chain_pool_fetch_error id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_pool_fetch_error ALTER COLUMN id SET DEFAULT nextval('public.off_chain_pool_fetch_error_id_seq'::regclass);


--
-- Name: off_chain_vote_author id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_author ALTER COLUMN id SET DEFAULT nextval('public.off_chain_vote_author_id_seq'::regclass);


--
-- Name: off_chain_vote_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_data ALTER COLUMN id SET DEFAULT nextval('public.off_chain_vote_data_id_seq'::regclass);


--
-- Name: off_chain_vote_external_update id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_external_update ALTER COLUMN id SET DEFAULT nextval('public.off_chain_vote_external_update_id_seq'::regclass);


--
-- Name: off_chain_vote_fetch_error id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_fetch_error ALTER COLUMN id SET DEFAULT nextval('public.off_chain_vote_fetch_error_id_seq'::regclass);


--
-- Name: off_chain_vote_reference id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_reference ALTER COLUMN id SET DEFAULT nextval('public.off_chain_vote_reference_id_seq'::regclass);


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
1	1005	1	0	8999989979999988	0	126000010007633001	0	12367011	137
2	2024	2	89999901036700	8909990091330299	0	126000010002617363	0	5015638	252
3	3008	3	179099802451566	8732681292530357	88208902400714	126000010002617363	0	0	334
4	4004	4	250707789050314	8590181616853617	159100591478706	126000010002617363	0	0	433
5	5012	5	334891568895479	8446467878898109	218630549589049	126000003996683947	6000000000	5933416	528
7	6003	6	413443720762573	8316902586626153	269643695927327	126000003992999802	6000000000	3684145	629
8	7003	7	494117676221261	8174474574372017	331397756406920	126000003992999802	6000000000	0	749
9	8010	8	575862421964981	8032565415121578	391562169913639	126000003976110330	6000000000	16889472	833
10	9011	9	642532716599437	7921014530153609	436442777136624	126000003976110330	6000000000	0	932
11	10015	10	720950760447957	7792575911113609	486459817697068	126000007510131184	6000000000	610182	1043
12	11008	11	798876519620111	7665011353925981	536098616322724	126000007510131184	6000000000	0	1139
13	12001	12	872460628617800	7541183084524060	586336220864315	126000014045764313	6000000000	20229512	1241
14	13009	13	947872461485991	7419403386854334	632704105895362	126000014045764313	6000000000	0	1336
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (id, hash, epoch_no, slot_no, epoch_slot_no, block_no, previous_id, slot_leader_id, size, "time", tx_count, proto_major, proto_minor, vrf_key, op_cert, op_cert_counter) FROM stdin;
1	\\x888f329ccb0f8c1691ad701e931f3a13449060c2290aee9a3053eadf2aa1429c	\N	\N	\N	\N	\N	1	0	2024-03-27 11:31:34	11	0	0	\N	\N	\N
2	\\x5368656c6c65792047656e6573697320426c6f636b2048617368200000000000	\N	\N	\N	\N	1	2	0	2024-03-27 11:31:34	23	0	0	\N	\N	\N
3	\\x1467c6b226f49dd918ce1a782609122f66e85610ea62b4ad41b42b7db9ae951a	0	6	6	0	1	3	4	2024-03-27 11:31:35.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
4	\\x22671a62ece06aaeed69c73bd590281b716323cc4d1040c1627d491d4d5e61f4	0	11	11	1	3	4	4	2024-03-27 11:31:36.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
5	\\xc03b367eeb1736dbffa9cb33e4ed0b3ac2bd08e863f7b824932e83bf302de923	0	15	15	2	4	5	805	2024-03-27 11:31:37	3	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
6	\\xbab8d6d365515ba4ffb40d162942a81ab7c74f65b7cbc3d52cc829aad6996fc9	0	20	20	3	5	3	2140	2024-03-27 11:31:38	8	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
7	\\x7827723a5cada7492c67e8284f813ee51a03e3ebd8ee9284e2243f375955647e	0	37	37	4	6	7	4	2024-03-27 11:31:41.4	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
8	\\x301b713d254e7c40bb086a73b70a72f68f13f876fabfc57d0fea65c29efd677c	0	49	49	5	7	8	4	2024-03-27 11:31:43.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
9	\\x8e0a500dc0f16da36ef6931ca00ed23ec329603e554522d0a21758eb1a145d68	0	68	68	6	8	9	4	2024-03-27 11:31:47.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
10	\\x98e020ab20cfbc6acb624f54a9df0e8ad7a27e79ff40a106df1202108b72436f	0	74	74	7	9	4	2573	2024-03-27 11:31:48.8	7	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
11	\\xc889cf25dd169219986d18a996f401846d88e38da940822fa550a73e44340492	0	75	75	8	10	4	738	2024-03-27 11:31:49	2	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
12	\\xa3929bb7e92b0e89932fe3d3ed06c0631981e0cfdb755087beb098d837697a00	0	79	79	9	11	5	738	2024-03-27 11:31:49.8	2	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
13	\\xf9172cc58520fa20a502dc8abd8ae571aa0aa8cd5bee5c87b83b35d678439252	0	82	82	10	12	8	4	2024-03-27 11:31:50.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
14	\\x0d98de121388394d7b7bb7290d9f21245a0c1a343f4fbeb9a15d14b947434624	0	87	87	11	13	8	4	2024-03-27 11:31:51.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
15	\\xd036913a1a7a74265731c880955a97ed3cfb20d50fe03e842f8c6a3fe761ce25	0	100	100	12	14	5	4	2024-03-27 11:31:54	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
16	\\x0898a618d1ccab57b666da8d73ade109d7cf716bb8127ff552305ada0576790d	0	105	105	13	15	9	4	2024-03-27 11:31:55	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
17	\\x298f262012ca9121db0e4d2fc0369088125e038ba9fab7c74f872d74a28bfc16	0	107	107	14	16	17	4	2024-03-27 11:31:55.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
18	\\xdf6f7b7d0ba9608a72f16182b940fa069fb61a3fb751ea32091db5dc414c1881	0	114	114	15	17	8	4	2024-03-27 11:31:56.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
19	\\x135fbbf492f4b4d71a52cb0cc06974abe0caee965d21830e87ed2a0415ea4f7c	0	122	122	16	18	17	4	2024-03-27 11:31:58.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
20	\\x777654756e535554c15a64fd8e842621d84d6a164bc2e832a77dd1dda1e80522	0	126	126	17	19	3	4	2024-03-27 11:31:59.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
21	\\xb67bd4e5ca1a95656c14fee448e89892afe064c81fbb9991780bce6c14912dd5	0	130	130	18	20	4	267	2024-03-27 11:32:00	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
22	\\x0145b4ab066c666abbba970d0a38d08a47957e853188211d6532e3786f2c3d70	0	134	134	19	21	9	4	2024-03-27 11:32:00.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
23	\\x834a05ebd65acbce0f8e711fc40e66447b44a2d5029f9d0b14607da818ae323a	0	150	150	20	22	17	339	2024-03-27 11:32:04	1	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
24	\\x0874343f2b9e0f4d24f0acf1485370807c636eb59f49f91e699ce085756dff7c	0	152	152	21	23	24	4	2024-03-27 11:32:04.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
25	\\xa0b21c1bd88f05b74879d0d51596be1bb308b34b69f7001504fc64c1f8a48532	0	170	170	22	24	7	369	2024-03-27 11:32:08	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
26	\\xe3e6374473af63d1c473bb1f4764cec1a8384085df9287375db89ef0e96b4239	0	178	178	23	25	8	4	2024-03-27 11:32:09.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
27	\\xc7606d909fda246444647b70b700b08c5e12c6fcb934ac251233702a57e49937	0	179	179	24	26	9	4	2024-03-27 11:32:09.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
28	\\xee06d41bfceffc975c7cb4bdb4d400b4b27644c42c306f1289f4d13adfdc16e4	0	193	193	25	27	28	397	2024-03-27 11:32:12.6	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
29	\\xa10c04090e225cb519e4c9fce53ea4e503df54b6e2d11eb8c765a35b65c3035b	0	195	195	26	28	29	4	2024-03-27 11:32:13	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
30	\\x361e46300de48fca0adfbd4915fd1cf2d934c12bce315725b4d599f74e405d98	0	201	201	27	29	9	4	2024-03-27 11:32:14.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
31	\\xcd1a979b45d50946e38968a36604abf6183e8c7dd18a2a90af903f89c11b784e	0	217	217	28	30	4	653	2024-03-27 11:32:17.4	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
32	\\x46af11505c33a9cb0e7eeda302b1e53383d8329cadbeaf604897b82ff3a89a0e	0	226	226	29	31	32	267	2024-03-27 11:32:19.2	1	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
33	\\xeec00651c5e72d0d805c10a15d97e161a6f04d49098e39e38856cb40d110c895	0	230	230	30	32	3	4	2024-03-27 11:32:20	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
34	\\xbdd6fa12a1ee3eb310cce02b8bdee06ec0771020eac187c09f48d05f7ee44a63	0	236	236	31	33	4	339	2024-03-27 11:32:21.2	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
35	\\x322c04aeabb5b165cbab143586b823f9d9a6e7ab068a61fdf41ab246e740122e	0	247	247	32	34	28	369	2024-03-27 11:32:23.4	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
36	\\x6ca8438247332215cc8d6c9993af7719c89a09d412cd8fe0e561a7013c0206d8	0	263	263	33	35	28	397	2024-03-27 11:32:26.6	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
37	\\x3e85a73e2f73d31ec5a32cd7e7d41760ce6ca8d00f1a77830f05ee128f77ca4e	0	285	285	34	36	3	590	2024-03-27 11:32:31	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
38	\\xc91b254ab447493f9b5f3175a4ddbcb71c9ea4b263c66ac4bb0dee5a16e8311e	0	291	291	35	37	9	4	2024-03-27 11:32:32.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
39	\\xe2380ab1761f2edb4f53a94cbb86f749b271acf204c2b48ddb3317b48e911b3d	0	295	295	36	38	3	267	2024-03-27 11:32:33	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
40	\\x577081d931889aaf1938b60e0e6f328a2905312dbac9dcae31305f5343c208c7	0	298	298	37	39	28	4	2024-03-27 11:32:33.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
41	\\xdf7d3c5ab855809da3dde23fb7a8fe2d619b68079c3a31084433372075613490	0	301	301	38	40	32	4	2024-03-27 11:32:34.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
42	\\xedd3754c42e6ccd4bf65afd95911b392cf4b3b7f85758641ecac9d6aa62eaa37	0	311	311	39	41	28	339	2024-03-27 11:32:36.2	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
43	\\xd9556eee02666e25a28f7795a997377a88d6540b7fabc5fa22fef24c35991556	0	312	312	40	42	3	4	2024-03-27 11:32:36.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
44	\\xe3ee675fcf96544ddf9acc74eb8774bde9c66ccd02ab29ac027dc5e933917711	0	318	318	41	43	3	4	2024-03-27 11:32:37.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
45	\\x609007124fc7d32d3de5db81227857da4aa174a89e37764ecbe905ca7bbf4e06	0	320	320	42	44	28	4	2024-03-27 11:32:38	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
46	\\x659ac791dbc17702711348f19be88cc12d9586545e53bf389ac13c6022302a97	0	382	382	43	45	3	369	2024-03-27 11:32:50.4	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
47	\\xedd48087d81f792a19a7f90c6d85d1108a55a1da2d2ffcd8416c6c38795e837b	0	383	383	44	46	9	4	2024-03-27 11:32:50.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
48	\\x8ac8aceefb98003673aa49bb716b372b7c3866745e0c5d749e4e19866bfbc824	0	384	384	45	47	8	4	2024-03-27 11:32:50.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
49	\\x1cb1fa0c7a6fe3bd6e790ca59e1594eef174a390af10e17ae7b18d59ad9df267	0	389	389	46	48	24	4	2024-03-27 11:32:51.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
50	\\xba6c531bcf6df9fbeaf26d92826d99e71a312ebfe76946f849e1011a3e7e8e93	0	392	392	47	49	32	4	2024-03-27 11:32:52.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
51	\\xcec6d0192671687724eb8152634495309f2939cee21e63f1e5de429963aa1157	0	403	403	48	50	3	397	2024-03-27 11:32:54.6	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
52	\\xdfd91b2256b0ca7dd539875c6ad84712dd29c8f57b2fbb26e3ee4e454f4570a3	0	404	404	49	51	3	4	2024-03-27 11:32:54.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
53	\\x01226f92286ad6b3df9e7181db86e6e8f6ac4d1538f72dc70da087ef1367eb67	0	405	405	50	52	28	4	2024-03-27 11:32:55	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
54	\\x201e737a14031e02ec2429b2288bf455fa2188d5a0ec2a05e70eb69eeeedb1b2	0	409	409	51	53	8	4	2024-03-27 11:32:55.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
55	\\x95fc797dd34da7cec07cbdc80e33863f6edcb8f9f21eca3541ec7583cdb3220d	0	411	411	52	54	7	4	2024-03-27 11:32:56.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
56	\\x5643196af738a78d702bb5414df4c2bd0a58baf24717011b4ec204d756a47045	0	415	415	53	55	28	653	2024-03-27 11:32:57	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
57	\\x1159aeecd33fac680e2dc38effc3f01f8873dd4d5d347a8cd8ef4583da7ddf69	0	417	417	54	56	3	4	2024-03-27 11:32:57.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
58	\\xde891a7a6adef2383a0710ea275fe0e886c3036660b013f7d6aadcc523cf675a	0	427	427	55	57	3	267	2024-03-27 11:32:59.4	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
59	\\xb4219833b5195650e6153187cf88cd6f124a46cc16e7b6ffc4ad4a94d5920c3d	0	430	430	56	58	32	4	2024-03-27 11:33:00	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
60	\\x8c63cdee7ea0bac359dc8de3fb3f224e1b81fbc8c486315538d6d5e800669c79	0	431	431	57	59	32	4	2024-03-27 11:33:00.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
61	\\x3632c725ec38828a327199fe63804d8a2e2b17a8d41582140335fd8de55332d1	0	441	441	58	60	8	339	2024-03-27 11:33:02.2	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
62	\\xa7733f5cf165329b1da42ca749d0d3dce3278fa23a047ce02b18ee5f00cf3d30	0	444	444	59	61	3	4	2024-03-27 11:33:02.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
63	\\xa2e5e8efed7bf6d185b88f92f85e988224dbf1b4aca54f72baa98ab1b1045795	0	447	447	60	62	4	4	2024-03-27 11:33:03.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
64	\\xe575bc80a737c42c61d8de1d0ca16028143219bd1bea6f4d6718ea939e1a1f65	0	449	449	61	63	9	4	2024-03-27 11:33:03.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
65	\\x3015b45e881a37bc712c20187173a895a103569e779dba836f2c728057f7bb05	0	452	452	62	64	7	369	2024-03-27 11:33:04.4	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
66	\\x720cdbf2cd65dfa7e00fb4efb3dd972603d06bf9dd1c52eb9ab8f725467f41ec	0	454	454	63	65	4	4	2024-03-27 11:33:04.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
67	\\xda11dfd6eb12bba2be165e1fd5e22b5e6b1169e2339a6b1a6216e31a735274ea	0	480	480	64	66	5	397	2024-03-27 11:33:10	1	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
68	\\x6c59e25ae5bd2a339b4e46099f4c7a507352c34c025faa2d5af2704708f7445c	0	489	489	65	67	8	4	2024-03-27 11:33:11.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
69	\\x8a935d9db493003f9102cdea40f1321ea85ad0b32bef54dce52b342405ec8d43	0	503	503	66	68	9	653	2024-03-27 11:33:14.6	1	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
70	\\xdad1260b887cd400b089eb2c303844a15d9cff5148135b13f6cfa9dd0da18048	0	506	506	67	69	3	4	2024-03-27 11:33:15.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
71	\\x6a06dd3912a0f849bb61af77813ae5c904ff4b0885e6628e6fc13098d14b1afe	0	508	508	68	70	7	4	2024-03-27 11:33:15.6	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
72	\\xc47228c2615d961e9d537a666d93c3b05eab77ffd90aa75f968aee076618dc21	0	518	518	69	71	9	267	2024-03-27 11:33:17.6	1	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
73	\\x481957308c66d37252fa2c23684ea33e2cc02e065130b494435bed2f7f4559e5	0	520	520	70	72	7	4	2024-03-27 11:33:18	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
74	\\x62529b76fd70cfa86d278933cea153d8930cd88c6287b26a7b7a2ea5fb38e1ac	0	522	522	71	73	7	4	2024-03-27 11:33:18.4	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
75	\\x11002d3c434dfbe9521e42e868343c23f93dbbd4fc37dfcfa97da1505582e896	0	525	525	72	74	4	4	2024-03-27 11:33:19	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
76	\\xb77a0d35a6e76ca5b466b6ed5ecd0d6dc5b0f9e59561961c3538873b64894c37	0	535	535	73	75	28	339	2024-03-27 11:33:21	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
77	\\x45e702f954c2f06df23438c614dfe3f8ecb259cb9c80a6d80f8433f449fce5ca	0	544	544	74	76	28	369	2024-03-27 11:33:22.8	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
78	\\x551667ad08d8f4816c21166b562da63360c55b618b20cf7c26ecee7625bb7613	0	546	546	75	77	7	4	2024-03-27 11:33:23.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
79	\\x1d313961c1a212c24195683c110576eda3adfbdba55ab6770a399f15bddc5180	0	554	554	76	78	7	397	2024-03-27 11:33:24.8	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
80	\\xe29614b91d4c41f70104deed2a93df8d82daf7de3e35c4b1667d901c8b71775a	0	567	567	77	79	7	653	2024-03-27 11:33:27.4	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
81	\\xf7006978bde82da97cd6d7a9c902aa0c9f195eaeb175af1ba2eceddea405d826	0	581	581	78	80	8	267	2024-03-27 11:33:30.2	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
82	\\x94acaeff04c3af0fefde8b4422f72a33944a3f6e3bfd507415156cbda20caac7	0	587	587	79	81	24	4	2024-03-27 11:33:31.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
83	\\xdee45b1f97024dc4e9fe094e0cf778971452d79a2e23a8a01f0b5140e04090eb	0	605	605	80	82	3	339	2024-03-27 11:33:35	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
84	\\xd8fd22f6e59fc7f733530e83cb4c51de6f28188b52e1cdd5c61d9eae2264d49a	0	614	614	81	83	17	369	2024-03-27 11:33:36.8	1	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
85	\\x98369bde0b3a5b4907cd65c2c34d8cec2ef8ef2b9cd968f7a15883d479de1a70	0	615	615	82	84	5	4	2024-03-27 11:33:37	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
86	\\xea68214e93d2aa8d51a7734758a2b7670654bb742f13424a1d0301b9afa3efaf	0	616	616	83	85	17	4	2024-03-27 11:33:37.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
87	\\xab219936755979868956005225233984d966e676ee39806fd5d55846ac81afac	0	621	621	84	86	29	4	2024-03-27 11:33:38.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
88	\\x6e9a17e901312086bc43a10bcebb6dbd89ef21525fe7060762e5a1c936f10b48	0	625	625	85	87	8	397	2024-03-27 11:33:39	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
89	\\x124f635a3fbbf618ef0793025cfec647bcb0ac95506e5e67ca668cdf8c75db35	0	637	637	86	88	4	653	2024-03-27 11:33:41.4	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
90	\\x1a51bfd2139169db544d729a099e3307f74025098ff074d68d0a85802c499b03	0	649	649	87	89	24	267	2024-03-27 11:33:43.8	1	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
91	\\x797359728db7646927ab5daa06ee6b62a0badc5bd56dca30e95cf5d74764239c	0	651	651	88	90	8	4	2024-03-27 11:33:44.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
92	\\x2d6e58d2b8994b26a94505dd8edfa386a9ae5ae3bc8a15c9d18209b594165e5a	0	653	653	89	91	7	4	2024-03-27 11:33:44.6	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
93	\\xfc89e427c1775ad1333de253b9f65196c3bf36bfcca93ce638757342eb572c44	0	654	654	90	92	28	4	2024-03-27 11:33:44.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
94	\\x824ba178543aff4f93d953bed759c26538ae8720e1861335324a3571090ebe16	0	656	656	91	93	28	4	2024-03-27 11:33:45.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
95	\\x3cb653464f2a147b61d4b7c13f5b277ccd7e528e2b5b3e4b5166b609fbc0c70b	0	662	662	92	94	4	339	2024-03-27 11:33:46.4	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
96	\\xf3dc112c17654238f894d678e971cecf32a936360a7adef8eda37373a063b0fe	0	672	672	93	95	5	4	2024-03-27 11:33:48.4	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
97	\\x18ed8c4e3d77574460c625e20bee4e80f47f386eb44c4e8433b9317fc4ae3c9b	0	675	675	94	96	29	369	2024-03-27 11:33:49	1	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
98	\\xc4e37c8bd9002bda2ee616677efd79c130b7448a30f937ffdd4bc32744d7ac41	0	686	686	95	97	5	397	2024-03-27 11:33:51.2	1	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
99	\\xfb2bc9a68ef8db6d7d076751ee4af6c304ba8447026967cbef6fa317461c66ac	0	687	687	96	98	9	4	2024-03-27 11:33:51.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
100	\\xc09877530d3b3dba489634aa60038b72a57eb16664475dbdbe1220a842db03ab	0	733	733	97	99	7	653	2024-03-27 11:34:00.6	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
101	\\x691f5762b70ba94e2c1085aeefaeaf41b73230a87c818cb76839f1af4362df6d	0	737	737	98	100	29	4	2024-03-27 11:34:01.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
102	\\x6f44c17bbee038de9860e4839e51933ee3141b4d4e716add4a33dee4dbae4e4a	0	738	738	99	101	8	4	2024-03-27 11:34:01.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
103	\\x9a3c0b8987042c9a74846b17ebdb6d1c9ac75562409a896f28fd54f019638b87	0	747	747	100	102	5	267	2024-03-27 11:34:03.4	1	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
104	\\xb2c64ae49160672c4eee83110468877ea01cff97a993c3cb13f19bcbe66e77c4	0	753	753	101	103	3	4	2024-03-27 11:34:04.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
105	\\xb5380e551949237432a44c3e4e256c40d25f77fa1b7507fec2b1198195dc6252	0	757	757	102	104	24	4	2024-03-27 11:34:05.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
106	\\xb388fe1e1852803685bc392131134214c217dd36b9216c474a107c3dbb8472ad	0	763	763	103	105	5	339	2024-03-27 11:34:06.6	1	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
107	\\xfa35540c42c5e5e789395b7b0ca62c889b7cfeae8c0098fbe3e3bf31406e545a	0	769	769	104	106	32	4	2024-03-27 11:34:07.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
108	\\x62eacfacadea75979653b26fc5a4da86d0e2d1069d2b876c96034e1966b43408	0	780	780	105	107	17	369	2024-03-27 11:34:10	1	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
109	\\x0ab931f2a6b11af2b588bf071a5d089e2953885e5312cbc4a8ba8e33e216ba0f	0	783	783	106	108	8	4	2024-03-27 11:34:10.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
110	\\x87708dd57f69dcbb46d80df1286800c4c727f49b4861327788c6a07b8bdb464c	0	785	785	107	109	4	4	2024-03-27 11:34:11	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
111	\\x605b383b0424a4220f3c860be0974c77edcb158d7938d5b13bc1492766f3d3ff	0	786	786	108	110	9	4	2024-03-27 11:34:11.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
112	\\x2a2b5a2fd24791815de4813202335a73df4544b671fefd65bfb343041596f8d2	0	818	818	109	111	7	397	2024-03-27 11:34:17.6	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
113	\\xbb75ed8c81d76886f62e8b2ce2b3611e4750ca0f69774e40be405df01324398b	0	821	821	110	112	7	4	2024-03-27 11:34:18.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
114	\\xdf6ca5d8fc8b47b72a3d97f4794382f9896f89245b974c179e46d6ab4b2f200c	0	824	824	111	113	5	4	2024-03-27 11:34:18.8	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
115	\\x7116faf811332c897694292bd103010433355ee6dca09a8d7542e2c9561d4c32	0	830	830	112	114	29	590	2024-03-27 11:34:20	1	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
116	\\xb38b0477056b259fab93af941d0fd32ea71461508fe1143afc2bde85d9d5ffbe	0	835	835	113	115	29	4	2024-03-27 11:34:21	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
117	\\xc049ca39ba07d997b183556dd4d53d9379a702913b18bd7d1c3b39accd2645ec	0	838	838	114	116	24	397	2024-03-27 11:34:21.6	1	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
118	\\xe40ef72a36d01034f95009bddef633627ad7dea4d6a4a3d8764e1b303ea57193	0	841	841	115	117	29	4	2024-03-27 11:34:22.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
119	\\xf32b742c162ba58acb66029ab9b7fbd3136a1c6126342d1c651636000c44badf	0	851	851	116	118	7	439	2024-03-27 11:34:24.2	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
120	\\x3bdee8e548f3d90b3a4a7d36f8076c5c5f85e4889ffc8bc047b98b005f59966c	0	897	897	117	119	24	267	2024-03-27 11:34:33.4	1	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
121	\\xa2d82082ea63803c42a78e9394ec4fbb48e6f0aaa06c1d593987219774ff53ee	0	902	902	118	120	5	4	2024-03-27 11:34:34.4	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
122	\\x17e1d557b356d993661f6dedef39815f06bbf94f4185a1076e9c037b465fa807	0	904	904	119	121	24	4	2024-03-27 11:34:34.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
123	\\x0d1c0f2a8344f924dcd4c410c7bb161edf8cbaa1f8599dd9858299d9c0f6b335	0	911	911	120	122	8	339	2024-03-27 11:34:36.2	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
124	\\xc07b947e1882f270d848921fdebe1bcb7bd6b69a83d5dfac924bf6137d5ece4e	0	917	917	121	123	7	4	2024-03-27 11:34:37.4	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
125	\\x54d864afe97f914239e7d25c655f1b3e0e148e0a36a13feb7f1af6ab33257865	0	922	922	122	124	7	369	2024-03-27 11:34:38.4	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
126	\\xb0c81bb978533b9171ed624eb2b4baa85025ee8db45eef4fc9d59830d528f520	0	924	924	123	125	28	4	2024-03-27 11:34:38.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
127	\\x528e10853f58dee325cba5b42812fda7784b6a6dfb2a9f2a90f80cfd6c3ca3c3	0	927	927	124	126	17	4	2024-03-27 11:34:39.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
128	\\x9a8df98b2efeb1ab19598d5c00ea8f5fadfb79a2684d8a160e45dcf9904144d0	0	928	928	125	127	7	4	2024-03-27 11:34:39.6	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
129	\\xf1a8e240af59d62a6fa53b7d79ba0e67e6cb146ffa5b762d286feadea6795010	0	929	929	126	128	8	4	2024-03-27 11:34:39.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
130	\\x94ec4032a86d710da7d2714a809ed36c2a4d0ff4cd6eef840955510c3aafd8e0	0	938	938	127	129	7	397	2024-03-27 11:34:41.6	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
131	\\x1f98c92573beea596f9396a15dcd08ca746dd97f6055d13ed8ff579ba507c570	0	940	940	128	130	4	4	2024-03-27 11:34:42	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
132	\\x729efb28b6e1c1cd27301484db33ec2c3b5d3a3759a4801a3429da6c2e9be1ea	0	946	946	129	131	32	4	2024-03-27 11:34:43.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
133	\\x734cc5aca9c56c9fb8039842df654ba2d72e92bd4f40f9f1730fb6a3b2f83fb2	0	966	966	130	132	17	590	2024-03-27 11:34:47.2	1	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
134	\\x6f6779782e0e322624be82cd333c16fc7e816efdef3809a42e93b113b1fbcdc2	0	982	982	131	133	32	397	2024-03-27 11:34:50.4	1	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
135	\\x55a1d8eb8140f7f82baf2d50a8e4f361ee82a9bea9411a0273e4b315030b8cc8	0	986	986	132	134	7	4	2024-03-27 11:34:51.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
136	\\x3d374bfadc566862dbcdc1b4cffae191b5dcb50e4f655a0d297a4ab2ef29fcf0	0	997	997	133	135	3	439	2024-03-27 11:34:53.4	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
137	\\x6309aee216acba4e77e48035fd817c0da634744aa992ebf47cbab3dadc865f17	1	1005	5	134	136	29	4	2024-03-27 11:34:55	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
138	\\x3d76c3b78a2220a9be7091e28e3d3d37a0aa3a643650dd3ec118919d03a6b448	1	1009	9	135	137	9	267	2024-03-27 11:34:55.8	1	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
139	\\x1ba08f987c6721bfa9019e13657e34d254b92f87bf1fc4896fc8beb9a1258043	1	1012	12	136	138	28	4	2024-03-27 11:34:56.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
140	\\x50d114de5dd9223e9de2652e397a437b6f5637caf3c8eb3da5e9eb44722c8fe3	1	1015	15	137	139	24	4	2024-03-27 11:34:57	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
141	\\x23f8c69a1a29d8ecea1578b5767d16273cc274625ab13ca4e443d2d5ec447cf2	1	1026	26	138	140	7	339	2024-03-27 11:34:59.2	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
142	\\x4597bd870414494ca58fd8a494edf70fed45b9855ccf27f8f45530c9464bad19	1	1029	29	139	141	24	4	2024-03-27 11:34:59.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
143	\\xb83cd048eaeff6dcd219ca6deda2a0d02db05f8d9ffc7405c5a2d621694e589f	1	1032	32	140	142	9	4	2024-03-27 11:35:00.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
144	\\x1b5223a5f0908f03238c96f25c1d8ac85e89f1ff10cf30b239a1ffd7152915a0	1	1043	43	141	143	28	369	2024-03-27 11:35:02.6	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
145	\\x45e957df496af3b3811f78b82d0432e987a29c9f336bf75b379059233065d4d7	1	1055	55	142	144	4	397	2024-03-27 11:35:05	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
146	\\x2b79da12aa1535062e2caa57c1c98733b0bd633aa4addb9f654067df5a13bbbe	1	1089	89	143	145	29	654	2024-03-27 11:35:11.8	1	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
147	\\x94ff34834d00566a68629e66399e626431d76c58359777f544ad60f1816b05e4	1	1107	107	144	146	24	397	2024-03-27 11:35:15.4	1	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
148	\\x8e3dbe7f1e444e9273ec7ff0586e0425c303030de82f48184d8a73e14a2481c9	1	1111	111	145	147	32	4	2024-03-27 11:35:16.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
149	\\x9ecc3e54b0b53d07074e1dc7765e99793d272ba9af631dd61b1a3107a0b4791e	1	1115	115	146	148	5	439	2024-03-27 11:35:17	1	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
150	\\xdcc3559816d5400ac60865b6eb2af769fd85de1449561461174ccb9444d31b3d	1	1116	116	147	149	7	4	2024-03-27 11:35:17.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
151	\\xe758a771e876805a032b63c3e67cb4694203296af0afe1e7009598e9aa4c0ab9	1	1131	131	148	150	3	267	2024-03-27 11:35:20.2	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
152	\\x623bd4a1e3d1f097f3d261364341906bfde55b7f3ccc27d223df5739c7d9aa89	1	1138	138	149	151	3	4	2024-03-27 11:35:21.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
153	\\xc06b54e572efdd189203114fb2f9eee2a20cd22b215b161faeff2e884ea61fc8	1	1163	163	150	152	4	339	2024-03-27 11:35:26.6	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
154	\\x5ddee56c9b63e067caa70942feb93a4194c5f65ac11bf683310de646a5c48647	1	1221	221	151	153	3	369	2024-03-27 11:35:38.2	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
155	\\x6cf5aaa8918675486d6ce4d48d83314d758401d5b57962cbc07e90e3ea3473cd	1	1253	253	152	154	3	397	2024-03-27 11:35:44.6	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
156	\\x4d10697734650de51eadc1d06b05034c93fe48748cbf9ea751384120fea45acc	1	1267	267	153	155	17	654	2024-03-27 11:35:47.4	1	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
157	\\x61780cf216eb590a0e94e9faece89e108dc2147f63c625b9ace07e10ae3cc679	1	1278	278	154	156	5	397	2024-03-27 11:35:49.6	1	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
158	\\xf5fc3918626f18b0e8f6f85ec8c16d7bde75153f451a474eba28b79be4bd94df	1	1290	290	155	157	3	439	2024-03-27 11:35:52	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
159	\\xb58ccb03dab2737e7842ac5b1956c3cada360cf6c5a837910a18eb8810d422a9	1	1300	300	156	158	9	273	2024-03-27 11:35:54	1	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
160	\\xd48d343e365a593be85cef25e72c66df3bfe8372955722e8c187383606f089a7	1	1313	313	157	159	32	363	2024-03-27 11:35:56.6	1	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
161	\\x7e85c9802bb73c3698bedac28b96116332b4374ae733197dc69e7afb8242a387	1	1325	325	158	160	24	249	2024-03-27 11:35:59	1	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
162	\\x6cd711221ca5fbefd707c6691ed1ebc513e762ce6619ffa082bec3f5ed5acb54	1	1348	348	159	161	17	347	2024-03-27 11:36:03.6	1	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
163	\\x3362ce1b0d4c8690e32088556ce3646c6061c56ad57309cddb109e7ee897c1ab	1	1357	357	160	162	9	4	2024-03-27 11:36:05.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
164	\\x23d0bfc213807f6666717f87eebc9543fb5e49f5e1670891243698e996aa940f	1	1358	358	161	163	8	288	2024-03-27 11:36:05.6	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
165	\\xb52f1d74d4c769f5d4532e4bc1ca6d7d93012dd9660350e13c6a54b364a5d860	1	1364	364	162	164	17	4	2024-03-27 11:36:06.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
166	\\x70430ed4129dcc3a1d04289136200186f99481ec89af5dc4a65510f77c2254f8	1	1369	369	163	165	29	262	2024-03-27 11:36:07.8	1	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
167	\\x6f8fd9ee19f4c83f21918dd8ad4950a60b077b493a16602f4c5ccab6b6d5c86f	1	1392	392	164	166	4	2449	2024-03-27 11:36:12.4	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
168	\\x1860b3a0652d51ca69edac9da1b9f13ad98ea428c091c33be663dd1b7c15b2e8	1	1396	396	165	167	17	4	2024-03-27 11:36:13.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
169	\\xc9211ed562034dda0bb80412af04738f0a33ffe14fecda53f8d6f4a2476e29f0	1	1405	405	166	168	5	250	2024-03-27 11:36:15	1	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
170	\\xb28a18e135c73f6180b5223196c7f2ea6ee479bbbd37b07cad8b4ba3eec8ee55	1	1436	436	167	169	29	2626	2024-03-27 11:36:21.2	1	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
171	\\xeea58d8452b14e14934ce8e5d5104968f0311d33a715699666d391dd6ba32869	1	1445	445	168	170	5	474	2024-03-27 11:36:23	1	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
172	\\x4692de35dcab8c481f2431fc82e8850eb2a85cd3d5d943e227cd280efe0fe53b	1	1466	466	169	171	3	547	2024-03-27 11:36:27.2	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
173	\\xf99b4fea3ec48ce26549ef118357fb914f97f74ca29188a688ab1594435d8d2d	1	1470	470	170	172	3	1760	2024-03-27 11:36:28	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
174	\\x9d1b891b4df2e3e605e4105be4ffaad489ef9992c1db6f8e0e61959f10dcba27	1	1471	471	171	173	28	4	2024-03-27 11:36:28.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
175	\\x19d4920a173baae3676fbf2b30fbbb59d43ad476e2cb1c4f2f6fb7263a585895	1	1482	482	172	174	29	678	2024-03-27 11:36:30.4	1	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
176	\\xef2345b5f088c6a3b8d7d320f9fab5a95c9f18b11ac55d604a522a5385af416b	1	1487	487	173	175	24	4	2024-03-27 11:36:31.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
177	\\xd18d71165669639576552f20c44eb7880cceaf517252296fddf524b787ae1b26	1	1492	492	174	176	3	4	2024-03-27 11:36:32.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
178	\\x97a941793884c6d529a6f6c961b66f134e17eb2e7e159d2385c8e43875277d87	1	1495	495	175	177	24	4	2024-03-27 11:36:33	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
179	\\x22566990fbcf593afb889affb0a405613b9761cc299f81044db71e0356c63fc4	1	1498	498	176	178	17	4	2024-03-27 11:36:33.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
180	\\xefe4793e9527a8658a849e45db68e88b88d39dd5785553cc2a5e959e38c63c61	1	1505	505	177	179	5	4	2024-03-27 11:36:35	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
181	\\xdac15de00dac41945e79cb37e9799f3cf31f5e7072c82791cee158f4ba6a0e46	1	1524	524	178	180	4	4	2024-03-27 11:36:38.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
182	\\x4ddb78f1390ba0f6d462c94705e3470feb7026bd06dc3419547de1c60edd054e	1	1525	525	179	181	7	4	2024-03-27 11:36:39	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
183	\\x96714d24fb4591aec7493d377637f884a17b693ccfd86a307acb16fb06a4f381	1	1527	527	180	182	5	4	2024-03-27 11:36:39.4	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
184	\\xfef5ba70d564768342af1de9feb58f0d2573421c130734d2fe6648972ae4485b	1	1530	530	181	183	8	4	2024-03-27 11:36:40	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
185	\\x8772bda7b8cf2583e6f75d27b14b498f815382240a7e64cb09785e7fba96920e	1	1539	539	182	184	32	4	2024-03-27 11:36:41.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
186	\\xbc2d7ec15998a6d6c082115d88bbaf233391e4855a4b3f2df4889abcef0210ee	1	1545	545	183	185	28	4	2024-03-27 11:36:43	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
187	\\x4d01d3324d6696e98b0f42ff8c3c6fb3da78a743108209cebaa9becb23c987cc	1	1559	559	184	186	5	4	2024-03-27 11:36:45.8	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
188	\\xf5d4186f4cdc1b40ff633aebea8036d23170e1a042cfb865c1d254ecb2faad09	1	1592	592	185	187	4	4	2024-03-27 11:36:52.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
189	\\xf4980446723f10f786a3097f53dfecc953f90c4c6a364ccc9c2763eba125cbd4	1	1595	595	186	188	17	4	2024-03-27 11:36:53	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
190	\\x6259688492ca6a07f32637d38c6db5d49411b182c695519e46eca56a6de834cb	1	1596	596	187	189	7	4	2024-03-27 11:36:53.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
191	\\x5b48f1dccf198169d1bb69c385d533e54e3aecab34379a2cd31a93357566a1d9	1	1602	602	188	190	3	4	2024-03-27 11:36:54.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
192	\\x88c7c741dc7699baed2ae01d3cf773957d9dc58cc6a048fc036d2ec56f6f61b7	1	1607	607	189	191	3	4	2024-03-27 11:36:55.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
193	\\xb6c9e99ed90ebf270a3c37970f87d956a439670661d34d0062e0ad273dae69a9	1	1609	609	190	192	9	4	2024-03-27 11:36:55.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
194	\\x1d116d6772b82526fc961ea3796f24915c9b3437e9b90018f62de7712d6ca319	1	1611	611	191	193	5	4	2024-03-27 11:36:56.2	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
195	\\x0d3d2658772243a7c32382d4f6b5e94bbbe7c8992fa348e2b435eb17edc84cf0	1	1613	613	192	194	29	4	2024-03-27 11:36:56.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
196	\\xe0ad51c0f3d738392fafaa9252986d72a6980c7bf85db6c78fdf03f4062cd846	1	1617	617	193	195	7	4	2024-03-27 11:36:57.4	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
197	\\x27507cdcb00ffcb1ad464ae356d7d2086043356a0de21781111246bd493b88e2	1	1634	634	194	196	4	4	2024-03-27 11:37:00.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
198	\\x954817d395a42d1ec04429e46f0fd7dc656aec0bf677a807ae99f2d1c39586b5	1	1662	662	195	197	17	4	2024-03-27 11:37:06.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
199	\\x2b995f2add3530dc07529ebcfc873b064ce3661b24163ba87a9626dd7efb2ae3	1	1666	666	196	198	3	4	2024-03-27 11:37:07.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
200	\\x85c35e38207f415c77422cbfefdbd1f108194266dc6df22162575f5fdef445df	1	1681	681	197	199	17	4	2024-03-27 11:37:10.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
201	\\xe32be8a1b23f11ddc544c21e6a9690283940cc3c6a50e2c9f997b27bc6cffc7f	1	1683	683	198	200	9	4	2024-03-27 11:37:10.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
202	\\xefb01d197bc103bce7e79b8828175d9b9d580f0eb376c2c3aab9a4d8e6dcc975	1	1699	699	199	201	9	4	2024-03-27 11:37:13.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
203	\\xdb0987854136dd6720b92fe15dfe252b4679ff2d560b64ad18a9a7adcdd7361e	1	1703	703	200	202	4	4	2024-03-27 11:37:14.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
204	\\x4ffc5062338e0a37eb7c9e20a75f80ca58c0d4239afafb87befb86d2814f8426	1	1706	706	201	203	9	4	2024-03-27 11:37:15.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
205	\\x61a2dc9bff7c23d1188b903924ecb6862f40fcb9180fb070e01574fddf51b694	1	1720	720	202	204	28	4	2024-03-27 11:37:18	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
206	\\xea45f26fb5035069f0dc2e6350e650afa94a993babffb474aea28112568a42ab	1	1721	721	203	205	3	4	2024-03-27 11:37:18.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
207	\\x7d2e5d023b0da4cef39001d708373b566e22ca0ec9da7054d66d54fc9fabc573	1	1722	722	204	206	9	4	2024-03-27 11:37:18.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
208	\\x92294a5ceba78404ae70aa1dd6bdf89eb44bf3d2094d1868257d2210ee835c87	1	1726	726	205	207	9	4	2024-03-27 11:37:19.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
209	\\xa8e6bd97d8ec0d06de72ed43bd5ca3e0c6ef55616acc93090ff2593702ff3984	1	1737	737	206	208	24	4	2024-03-27 11:37:21.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
210	\\x970d7704f892a108433a9ac0ca275da1a8c5839e702c4778d299caf375aefabf	1	1751	751	207	209	8	4	2024-03-27 11:37:24.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
211	\\x79ff81009ea9c0da78f3bf906df3cc6b6e20759f18b16bd7ca7c7c8a9d9e562f	1	1757	757	208	210	29	4	2024-03-27 11:37:25.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
212	\\xb8f38b26020d9564110afe79244837a043271b15eb6a2ecc43544582b51473ab	1	1760	760	209	211	7	4	2024-03-27 11:37:26	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
213	\\xe8a933894e08640a7abf46eab693d9dd05ed6bd36b1fa8715db107cf5b3c8d4a	1	1778	778	210	212	29	4	2024-03-27 11:37:29.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
214	\\x3c7d92e83c1224d9a0300a59d9bb0ce7f5a3879d4c2fd2481e5e34ca210c179a	1	1782	782	211	213	17	4	2024-03-27 11:37:30.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
215	\\x1248014427896c456d3c8bd148951e9f1124c72704c1d83117281884865c7c59	1	1796	796	212	214	9	4	2024-03-27 11:37:33.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
216	\\x1ecdba4f17010818fc20d519a6d6f089df55deb8345cc52886cd0571196e42ac	1	1797	797	213	215	3	4	2024-03-27 11:37:33.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
217	\\x09487ab624fcfb7dbeb3c9a2502ba7112354a54fd3f5443fc3f6af128ba477cd	1	1801	801	214	216	5	4	2024-03-27 11:37:34.2	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
218	\\xe795dc7ec2569d77981004055ada0e07dd572dc8c1c24de6ae3e4b7e5e4966cf	1	1804	804	215	217	24	4	2024-03-27 11:37:34.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
219	\\x3c1a67eb7eb3f8b85c52dc20573072c7d5555d8b02887a2caea403603cf097a1	1	1824	824	216	218	28	4	2024-03-27 11:37:38.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
220	\\xb0064078f5baeb9c3a0c77bb1471a95e31dddfc7cef0be083731bb668f3a55fd	1	1838	838	217	219	4	4	2024-03-27 11:37:41.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
221	\\x6bb90b8cb263a0cb77d157865f7cd9ca6e4615b6fcb1c702bf036d8a7a319c09	1	1840	840	218	220	17	4	2024-03-27 11:37:42	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
222	\\x2d8fd2fae04dc9742fd3dd9592dd3cc3209676fbbef2e950ed752929b6c7632e	1	1846	846	219	221	9	4	2024-03-27 11:37:43.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
223	\\x883259e7d93473b589f61eceba950f053be0664eb8422d1be8c469c911e24494	1	1866	866	220	222	24	4	2024-03-27 11:37:47.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
224	\\x8b5ad21c8e27729e492eee17474373fec2f97e99bd2a0b3b30b49481c385c586	1	1869	869	221	223	28	4	2024-03-27 11:37:47.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
225	\\xdf2d5f9deb0bc63f61bdc2bc264a225542734a6eb94751000dfc334931d1e8eb	1	1871	871	222	224	32	4	2024-03-27 11:37:48.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
226	\\xf15e12cb06633f3df2c26afd3516c8d040331d0316c6fec21007ff69dda933a2	1	1879	879	223	225	7	4	2024-03-27 11:37:49.8	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
227	\\x92b0372317511c5d9795bb8835f447757d4dfd1ad2bf4acfcf116d8c23de82c4	1	1885	885	224	226	3	4	2024-03-27 11:37:51	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
228	\\x229b31145d7afb61d4a9bca1a0fd56f54a901ca349ee626a4e15e8d24b54cac3	1	1892	892	225	227	17	4	2024-03-27 11:37:52.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
229	\\x696bbe28d5c07566bf09485209f04c828523d4fef10728f6a29fd655f61f08e9	1	1903	903	226	228	9	4	2024-03-27 11:37:54.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
230	\\x2b152eac0f74d39bb3d696417b93788ee62d055525846852a4d0a5f3452e7efa	1	1909	909	227	229	5	4	2024-03-27 11:37:55.8	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
231	\\x659716efb5f836da317c65cd5eecad65d9a7470e59c7f937c813707b7aa19a6f	1	1916	916	228	230	8	4	2024-03-27 11:37:57.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
232	\\xe3ad7da7fb2249c6b357703ff219f07c636d7cbae34d23ec581e4c5118039411	1	1922	922	229	231	3	4	2024-03-27 11:37:58.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
233	\\x7f93d31299ba792eb5b0da58f0d2c5bb52e7ad39a6d54531fd6f3d5f5d612a33	1	1923	923	230	232	3	4	2024-03-27 11:37:58.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
234	\\xf722de7002fd02405543f79518c02c2db27a2d21c0ce104b7568226db5d2b16c	1	1925	925	231	233	7	4	2024-03-27 11:37:59	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
235	\\x2a5964f7f6bb29995522edd4e62c121d8c6040cb20ebd3d83d0b755c9f0aae67	1	1929	929	232	234	3	4	2024-03-27 11:37:59.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
236	\\x53dd2407180becfa801fa91ab293bf5962361bb50f2da6edcb0a29e94ae24bd1	1	1932	932	233	235	29	4	2024-03-27 11:38:00.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
237	\\xbcbf09a1cf0a12dfe81fc22e9c90144ef855642b1bee2c272e94b36444255751	1	1935	935	234	236	32	4	2024-03-27 11:38:01	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
238	\\x2134d7c887f67490cec643738a2942bccffc185d4fdfb183853feca05334c021	1	1936	936	235	237	5	4	2024-03-27 11:38:01.2	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
239	\\x593ac41fc9b1189a3fce2431a93d3b431e53aa2a9103c168d5856d1912027879	1	1939	939	236	238	29	4	2024-03-27 11:38:01.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
240	\\xe197397d0a25203f380a05b26c7b270a5367a1e387d5cf2fcd660237bf9a7988	1	1940	940	237	239	8	4	2024-03-27 11:38:02	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
241	\\x6515a0bdeef7286e614e42ecc481e9a57f5a85b23134133866816b18203b19e2	1	1943	943	238	240	4	4	2024-03-27 11:38:02.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
242	\\x6ec096c7b60ab9ae969d96d8e2d1e9beae2d9f76ab6db7a6525cc00e36529a0d	1	1958	958	239	241	32	4	2024-03-27 11:38:05.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
243	\\x8540d76a027fc753bb8d4a0642655d88de4f214e6ab082a5d6937812d574413a	1	1960	960	240	242	8	4	2024-03-27 11:38:06	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
244	\\xc688b7ddc58e82843ce9c3bac7f669c914f69e199292f58d18809ad28718cdaa	1	1968	968	241	243	7	4	2024-03-27 11:38:07.6	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
245	\\x7e20fee8c77b93c02c79aa0fcc9a557443ea23bb8922082e3e9df05426e3913c	1	1975	975	242	244	29	4	2024-03-27 11:38:09	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
246	\\x77ce0b0c5cab9d1c75d9c46332c1e785fcb62bd8dd32bceeb186fb05fc26f36d	1	1979	979	243	245	3	4	2024-03-27 11:38:09.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
247	\\x7c8a4ab784410e178265484f138de36af4acd4999dbae78f3e55d52229e0ab36	1	1980	980	244	246	7	4	2024-03-27 11:38:10	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
248	\\x7ce7126592703ff2db0464ac7067f06608a95083113ff3c589b1055e69d8be06	1	1982	982	245	247	9	4	2024-03-27 11:38:10.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
249	\\x0621e31979ad695e8070dc0f3ef42c274d2d38ef1f22c62f2d8c35df90f1ef95	1	1986	986	246	248	24	4	2024-03-27 11:38:11.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
250	\\x81a0674ef233d3134d166778cc58d05b88357e7afd4832543215140acd515571	1	1991	991	247	249	8	4	2024-03-27 11:38:12.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
251	\\x70bf20f5170409ec32650079d54aec99e5881f770e10bf276d17ae62458ba591	1	1994	994	248	250	3	4	2024-03-27 11:38:12.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
252	\\x1fe4fd5906dd2922b4052bad6d32188c038f484c78b07ab883a9a06498d659d1	2	2024	24	249	251	17	4	2024-03-27 11:38:18.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
253	\\x5b5006693740d2ea22c8ee4712c7f13838f423de29f1f9b7c8a04ed4e610ac2d	2	2044	44	250	252	32	4	2024-03-27 11:38:22.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
254	\\xf859bba4e8f138df1cf701b7bc6f50f16117160b88d4c929ad504e1efd5001f0	2	2048	48	251	253	24	4	2024-03-27 11:38:23.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
255	\\x661a2a3a3abbf4ad0058f2b3fcd0e182529b6c7225e5cb073cc4e5fac9bb2fca	2	2054	54	252	254	9	4	2024-03-27 11:38:24.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
256	\\xef843f6d37264bc62c44c18e6037dd4be68ba30a27bbe21437ce9986c7e3c6e2	2	2060	60	253	255	28	4	2024-03-27 11:38:26	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
257	\\x03e1d28465e0ee252f8a90d45ef7244c7e5d4f601cd83a302b5a74dba0dd1a0d	2	2063	63	254	256	3	4	2024-03-27 11:38:26.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
258	\\xb9ec41520aca00c4dff404602351be5ddfbe4c5a5bb3656ba99fe38bfb2d8752	2	2070	70	255	257	28	4	2024-03-27 11:38:28	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
259	\\xe08870acf55feb0e39299afdd15cb87268a4ba0e64e043ab7408ca8aa26edc0e	2	2083	83	256	258	3	4	2024-03-27 11:38:30.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
260	\\x9b660dabd849abbe970b041c8a708f9bf5db76913ab2ff9fdf51deb5f009579f	2	2104	104	257	259	9	4	2024-03-27 11:38:34.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
261	\\x6be6bad59afe101d9cd4f3a5c35c03cb5baf9b6ac0e291b1f41516b5492e94c4	2	2105	105	258	260	29	4	2024-03-27 11:38:35	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
262	\\x9f9554396fb9d1e0c5e5737efa7e4477159d6db5a62df64b01c3874ff9b05da6	2	2126	126	259	261	29	4	2024-03-27 11:38:39.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
263	\\xa6d419767f3e7f4b648ab13d937ccc7367e9c8b409e9c5e6cb9d5dff83dbb605	2	2187	187	260	262	5	4	2024-03-27 11:38:51.4	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
264	\\xd30f461be6bb1070c087817eddd0ac7f8415a3ced7ec31e23024a8c44776ba37	2	2202	202	261	263	4	4	2024-03-27 11:38:54.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
265	\\x52023a28859d57d33efcba3144f7031ef4b300e1c99ebf1b3e34f286ca098552	2	2222	222	262	264	9	4	2024-03-27 11:38:58.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
266	\\x9a68259b8fedfbd705f4ce39782815c1e72eda01f3b2d57001f17795b1b6bc09	2	2241	241	263	265	29	4	2024-03-27 11:39:02.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
267	\\xfdd2f9613150947c58e05ddbee9717cb6430d654e3fe79c8ac672ceb8a7fbf72	2	2243	243	264	266	17	4	2024-03-27 11:39:02.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
268	\\x5cc81c25b2428fb7c22a7abb83b9b11891e459d673576703bfcf41b2b9e4e78e	2	2244	244	265	267	8	4	2024-03-27 11:39:02.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
269	\\x92049cf0ec8b7166967508350f6734d4eabe668b25a73ae390c3863f8c8ed243	2	2256	256	266	268	3	4	2024-03-27 11:39:05.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
270	\\x0f261e07b35dbd5db941902008263df1e6008bee0410271fed77504ec845b926	2	2262	262	267	269	4	4	2024-03-27 11:39:06.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
271	\\x76670933ce94e4762c456781042e6d3257a0b00b5a77272a9040674df20c6b78	2	2264	264	268	270	24	4	2024-03-27 11:39:06.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
272	\\xfd794ce1c1a2a40802b4e23a651e8d093abeb1fdda50215f415956947e195cdf	2	2274	274	269	271	4	4	2024-03-27 11:39:08.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
273	\\xf872661bd0792816fa3f0fa70ddecba767cc8bad93fd4aedf4613d6d5b083dee	2	2279	279	270	272	17	4	2024-03-27 11:39:09.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
274	\\x23c8bbc3878b4b71e85239c5d14a71f577d50a6504f61e315de07b32c9947ccf	2	2292	292	271	273	3	4	2024-03-27 11:39:12.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
275	\\xbfeab379cc044631087c02fc2ce9c206119b75a8e77f20132ff60b2f98d4e268	2	2297	297	272	274	29	4	2024-03-27 11:39:13.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
276	\\xc575e65fec2861079f6267df4d3f3ad2ef7498e82486762f841ba1103c96d341	2	2314	314	273	275	8	4	2024-03-27 11:39:16.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
277	\\x863b5efddb65a8e5f8749ce6025caba4a673071613651a3a06a74b18f0207a89	2	2316	316	274	276	28	4	2024-03-27 11:39:17.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
278	\\x97dc2d8ea9aa97a0fbcac3a7e1f768888a1312c5ad9a14032e3160799c37b16b	2	2317	317	275	277	4	4	2024-03-27 11:39:17.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
279	\\x89d548be9e95a438eb2655d084d25948aaae256e2a12af41d539eb10a02ef4c3	2	2328	328	276	278	29	4	2024-03-27 11:39:19.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
280	\\xbae9b8b13c6efb93a50531f50fc66f2632c830a75ae0a586336ed1331758ae3d	2	2340	340	277	279	9	4	2024-03-27 11:39:22	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
281	\\x18b581ac0c6c6815b4e24492809fa4b120696668a3283f4a726f8e12227b33a6	2	2341	341	278	280	8	4	2024-03-27 11:39:22.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
282	\\xaff9889fd220cdcb3410d8275523d8f9b61b62af0151d8c5418273fabb325751	2	2350	350	279	281	5	4	2024-03-27 11:39:24	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
283	\\xd0a3bbc32ae613d84548b5f5faaa8fd91fc9d46e809a16e29c10e01771e9d541	2	2355	355	280	282	4	4	2024-03-27 11:39:25	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
284	\\x9868b15560ba6f84e0db9d19244adcde608212b45483970b75edaa702f52e720	2	2358	358	281	283	9	4	2024-03-27 11:39:25.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
285	\\x6de0bd892d4f7069cd8b58d9e37a0c897cb9ca95d1fee3774524dcd634e68808	2	2362	362	282	284	5	4	2024-03-27 11:39:26.4	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
286	\\x6cc222e5a5aac67235333bac923c1d1a1ba7597447c993a72fbde0a73705313a	2	2376	376	283	285	4	4	2024-03-27 11:39:29.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
287	\\x1f3c8ae054e8c3b44c526a082b20c7a60ac69c141d801782325daf1099b7fa4f	2	2388	388	284	286	9	4	2024-03-27 11:39:31.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
288	\\x3355ef8e0fa01b5d33b26fa31d5eb6e3cbb04fe76577d5ef48da1b23bc7dc66f	2	2390	390	285	287	3	4	2024-03-27 11:39:32	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
289	\\x5e1c84f40591d73b2055c782e967a1c8da6e763df86f8c10e3d73b6bb49d1a58	2	2398	398	286	288	5	4	2024-03-27 11:39:33.6	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
290	\\xe09018a7a05eecc3bafcfea6e9b8f6842318b23e66f42d13adb32094296a4f2b	2	2400	400	287	289	3	4	2024-03-27 11:39:34	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
291	\\x795ac15f40822344d1cbd66241d57ac963a363a005b089c3ea14a2d3045f3795	2	2422	422	288	290	28	4	2024-03-27 11:39:38.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
292	\\x8818954110c2d8d77545cf396adbbff3dfd35221936bc90ef5727cbe382d230e	2	2424	424	289	291	4	4	2024-03-27 11:39:38.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
293	\\x528cb27ef46435581d8ad601684f4ce4f69f37d6a908af8d731af3557cbcc0d3	2	2440	440	290	292	29	4	2024-03-27 11:39:42	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
294	\\x23bc40b359dbd48362986df39e67f5b0bfd69ee42957a78ef23fb0e40c47eee3	2	2484	484	291	293	8	4	2024-03-27 11:39:50.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
295	\\xec4565c800cc3dcdd1aeea16f663016568791c2acbab1fae423cb77fcfc654e1	2	2488	488	292	294	9	4	2024-03-27 11:39:51.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
296	\\x41d46dea06f6af6d2e8a2fe1a978f26c260dfe620e2eef253262e6b2509df1b1	2	2505	505	293	295	17	4	2024-03-27 11:39:55	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
297	\\xfeb96044ad9333854468357ce38eae2d0f489e718635eebb39723db8226aab6e	2	2509	509	294	296	7	4	2024-03-27 11:39:55.8	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
298	\\x8f27be487aff05ff2821f92c00fdfcfb3b9020f70bc5ea92c5e73bc948517c35	2	2522	522	295	297	29	4	2024-03-27 11:39:58.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
299	\\x72cff2986bc10f31bd03cb138d8b66a6f3bc679ebaf6b90323779257573ddbae	2	2524	524	296	298	8	4	2024-03-27 11:39:58.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
300	\\x7c5bc0d80da93282b6b07f089492954d739b3318cc75faca37315eaf3b9200a1	2	2529	529	297	299	29	4	2024-03-27 11:39:59.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
301	\\x8c143c7b189069b49b3c15e06bfec7d686a533c55d893f1278419b549e4d80c9	2	2548	548	298	300	17	4	2024-03-27 11:40:03.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
302	\\x2fa30f0579a29ba6d27fd10274a541d4a38975a67f156613b176ac321181e83c	2	2554	554	299	301	24	4	2024-03-27 11:40:04.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
303	\\x323dc28717f9814b524d1cc9374d66a8e7427f1f6995eb431105852cde166b31	2	2555	555	300	302	24	4	2024-03-27 11:40:05	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
304	\\x2eb71155218ca378e72fa62862842341413fe4f67352f89969f40db7f22ab504	2	2559	559	301	303	3	4	2024-03-27 11:40:05.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
305	\\x618a03bd6b120c2ea0f73782436f64a0841dc02fc3385bbfc765225eaa6e9934	2	2569	569	302	304	8	4	2024-03-27 11:40:07.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
306	\\xe3c3ba24c6c0c0e65b0d0a4d5f29223b25e8514ba9009d4a5157d668deb5f323	2	2583	583	303	305	32	4	2024-03-27 11:40:10.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
307	\\x4d1ceb0236557de51181cda5b1d7c09a9a2ffc0d72ddc5ac826fcba1e0bebd35	2	2591	591	304	306	17	4	2024-03-27 11:40:12.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
308	\\x8519f09e9fbb7c5903bf80c45cc02b38cf45fa8ebc4cce290ba470824f2937b6	2	2592	592	305	307	5	4	2024-03-27 11:40:12.4	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
309	\\xb00924fd2aa49d415758f9e9d9c518023bf555b8c8f7da8c0f9e4c39f494b33a	2	2602	602	306	308	28	4	2024-03-27 11:40:14.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
310	\\xebee401c00c2a9c5df3668947b88cc286f8e214142a175f02522da7521b1ccc2	2	2603	603	307	309	28	4	2024-03-27 11:40:14.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
311	\\x72a27989653d5e7f3dc44759eaa86d21053ce2bd983ae25330dfcd8301b3bae8	2	2641	641	308	310	7	4	2024-03-27 11:40:22.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
312	\\x9b4fc5310e7bcf2f65668c57a70b15a43f446f9c5381f306ba02ab44da3ba3fb	2	2667	667	309	311	4	4	2024-03-27 11:40:27.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
313	\\xaf63242324509991d6e4f8bdd2b7b8995d1bc29124ac8a98bee4e53b0b4265eb	2	2680	680	310	312	7	4	2024-03-27 11:40:30	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
314	\\x667554ed201523698249e4ef42b745e072e144bedc25e7382e1336e9b659fb92	2	2693	693	311	313	9	4	2024-03-27 11:40:32.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
315	\\x7ee3e4c4c6cc73cd952ed092526ba507a7feef48dced551c1f8c8e6274a2de36	2	2699	699	312	314	8	4	2024-03-27 11:40:33.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
316	\\x925ce41fd5fc5cdb99e90eab58caa8e3bb5279c5a7def2d53a4edc72536663ae	2	2742	742	313	315	8	4	2024-03-27 11:40:42.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
317	\\x961f7416f8c63a92638c2b66c25e38f9d806e6802c1eafb9aa83aafff916af0d	2	2743	743	314	316	7	4	2024-03-27 11:40:42.6	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
318	\\x98830ee97c9f865ae8e7c272f24315d1fc45d0f8569754dd9d90008cda786106	2	2745	745	315	317	9	4	2024-03-27 11:40:43	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
319	\\x0e7986ff619065df535a2511c8344f4d52865e04519ab637bd1daabe19e16aac	2	2758	758	316	318	4	4	2024-03-27 11:40:45.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
320	\\xae8826c9be7cab5e092350ab91a6c7d8263a6c9f6bd3dbb355d517cf6674f8a6	2	2761	761	317	319	7	4	2024-03-27 11:40:46.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
321	\\xb3f9e55ad28e9052b41c29fbaa081cc946e457046185058d98a3527b935566a8	2	2765	765	318	320	32	4	2024-03-27 11:40:47	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
322	\\xef41e8508c8fbbd7fd541a73cb314efb02c2d2695eb0e59872ef0aa8b656a910	2	2801	801	319	321	32	4	2024-03-27 11:40:54.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
323	\\x4fd4507894534bad185d902b8689a3f717eefb29381d9cef1a803335df1d8ba8	2	2826	826	320	322	9	4	2024-03-27 11:40:59.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
324	\\x5f1381b9f14b4f95e58a937587cc6286e6f409429b0a542f64fdd53a9bdb6eea	2	2833	833	321	323	24	4	2024-03-27 11:41:00.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
325	\\xa3f7760a78662131a6b43da2152aaf45378bf29a877d29e8f5e10753d72c0a3c	2	2842	842	322	324	32	4	2024-03-27 11:41:02.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
326	\\x36304f3687202c18ffbedccde6e0fb2e9740ab6631c65494073f887f9418b300	2	2857	857	323	325	3	4	2024-03-27 11:41:05.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
327	\\xb34c51423ef1f86b6342cda730541677ddb20bec2e5719e22857a2f16f330009	2	2887	887	324	326	4	4	2024-03-27 11:41:11.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
328	\\xf3568ea5cdbcbd2b65acfa952664125e9c004264b782ff94844c9334538c5b77	2	2905	905	325	327	32	4	2024-03-27 11:41:15	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
329	\\x5d868f352371e22a467ae00cba66189e986dacbe7b687020bb7b9c831252cee1	2	2911	911	326	328	32	4	2024-03-27 11:41:16.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
330	\\xc77acef9ba073c3cb5162279b52e2e37bfce06e0353f787b5f13aee3620b5c2b	2	2952	952	327	329	28	4	2024-03-27 11:41:24.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
331	\\xec92a70347cbfee86fed05d530aa89fe52607b92efb09dbbd50d1035b249ca2c	2	2977	977	328	330	28	4	2024-03-27 11:41:29.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
332	\\xd346ef3fd5a33f2020228d3c6ea91cad234eca03b98282b3eb2a120d056ed9cc	2	2987	987	329	331	8	4	2024-03-27 11:41:31.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
333	\\x1ec977454f77f7aa56bba00457de55260715050de9d6a15a66afa3a970313f35	2	2998	998	330	332	3	4	2024-03-27 11:41:33.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
334	\\xe9c2a82c6ff85602ed720acadd7d3a71478ed64fb05dfda80796af73aa1a0b2b	3	3008	8	331	333	17	4	2024-03-27 11:41:35.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
335	\\x06ca9be58c3e3d61083e81fab736542d26d95afedf0b6cc8f9e01b366c0bf2e9	3	3013	13	332	334	28	4	2024-03-27 11:41:36.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
336	\\x7b8e9bcf3a5aad728fb0dc3fbd6c11b1e80889daee6c571de1b990eaa2e5689b	3	3014	14	333	335	28	4	2024-03-27 11:41:36.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
337	\\x22ee4b589e64056532ca56cdaf72e1845bafc81bc77166703617229ec241bfde	3	3017	17	334	336	17	4	2024-03-27 11:41:37.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
338	\\x47629ae0457e936efaab65a072eee1c16cf0e8777982b7d0c67a34a3d10804ff	3	3019	19	335	337	4	4	2024-03-27 11:41:37.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
339	\\x7dd12691c019e7722c24430f17c2923216106adf07fe1a4724ebe25163efa7e7	3	3021	21	336	338	32	4	2024-03-27 11:41:38.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
340	\\xc781e681efe1cd66654b192478f999b98fcd5bd80acac2a7e56e01a8fc3b2ed8	3	3022	22	337	339	8	4	2024-03-27 11:41:38.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
341	\\x8cdeabb7e99684e46dd666c39d7fe5bf5d3af2cc1e84727afa8aaca26b3db37e	3	3025	25	338	340	3	4	2024-03-27 11:41:39	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
342	\\xdbad4257b11152032744fad50419ba1f277c0c3c7e2e9b2126cfb7a2c1f00c93	3	3048	48	339	341	32	4	2024-03-27 11:41:43.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
343	\\xbda16a1359a1589eed4092a93be6728a113fe6e0a78e09947c96787680e8f72b	3	3057	57	340	342	17	4	2024-03-27 11:41:45.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
344	\\x91028d56986aeb28176d5793bb591445e5c0ed9b85296cd9bc82e1c4c145a429	3	3096	96	341	343	7	4	2024-03-27 11:41:53.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
345	\\x8ce34ceac1cda0344b10683b7d0c9d25294cb89f6db8802027851bc21d0842d3	3	3098	98	342	344	28	4	2024-03-27 11:41:53.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
346	\\x329147845bee7b30b3bebda9de6503c884cbedb8e64a6fd054804d53067e84df	3	3099	99	343	345	29	4	2024-03-27 11:41:53.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
347	\\x97186b39f08454d9e6349502bce6ad2c260b898b9424981bb5af17f0c49f8fa5	3	3107	107	344	346	7	4	2024-03-27 11:41:55.4	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
348	\\x4b14cdb02e088f33211d8f6d1f62e3456741722c63de4fe36ca0fcb39b5f66f5	3	3109	109	345	347	29	4	2024-03-27 11:41:55.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
349	\\xb51a6469716565e16da926e80e5e685408779c1542eab8a9075dad4d8f8d8b66	3	3114	114	346	348	24	4	2024-03-27 11:41:56.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
350	\\x9a7b1b0611b4d6508acd348af9a162a7574735bc8400651e990f1125b1ae176e	3	3116	116	347	349	17	4	2024-03-27 11:41:57.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
351	\\x4ab6b89815469a16f1dbfa716490542f4dd772b43f937c0d64fe7c1ff9dd8c16	3	3133	133	348	350	28	4	2024-03-27 11:42:00.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
352	\\x0ce3abcb84ba49e894ea0b63e57ef9fe9dca1589049cb44ed26008523a70e919	3	3135	135	349	351	24	4	2024-03-27 11:42:01	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
353	\\x0aacdb5d054ef8d1c1143f51aa27e8526714c69ec65b7eb2b4b5e1a160c12f12	3	3146	146	350	352	32	4	2024-03-27 11:42:03.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
354	\\x38edab393d5710f12126516151319c7f18ab79b7b7ea2c90a4cf7efe847edd55	3	3147	147	351	353	8	4	2024-03-27 11:42:03.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
355	\\x7a0f575ed2cf94952889f6e32f7c1c0f1b91fbe454fd47ac2c26fcb868c3a853	3	3157	157	352	354	4	4	2024-03-27 11:42:05.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
356	\\xfa8eee3d46149348613151f515776fbc68cfca68c840614de4ca3f6379fe2643	3	3159	159	353	355	3	4	2024-03-27 11:42:05.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
357	\\xe65d90fae757151ef42c2ed9a10f191bd9c98c8f722e466101f7bbb795817ae1	3	3163	163	354	356	3	4	2024-03-27 11:42:06.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
358	\\x61c7a786511c4e86c567592992c9319cdbe3043c093e2b8ec46b0ab0574f8951	3	3166	166	355	357	28	4	2024-03-27 11:42:07.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
359	\\xe28fbacafe2c83bda0ded02863c6d4505c09b5534d339545b6aa9a3c35ab89af	3	3196	196	356	358	17	4	2024-03-27 11:42:13.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
360	\\xc2b123b0e0fb9157912bb0068df19fa8ae8c53874786721321159a0fdceb53fb	3	3203	203	357	359	29	4	2024-03-27 11:42:14.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
361	\\xb3c409660d3163624af56ea9460509095e7ad61321132c714e6e5652b738b310	3	3211	211	358	360	5	4	2024-03-27 11:42:16.2	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
362	\\x604db945c8bc7e42afe0fc9bab63ed2f594376f4a11bb0679966fb778b95dc9d	3	3218	218	359	361	3	4	2024-03-27 11:42:17.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
363	\\xf4f1a44f96fb17940c4475c958c0f6cd6404b53d1a287ae11865b40869197f4a	3	3224	224	360	362	8	4	2024-03-27 11:42:18.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
364	\\x4942764b412a1ef77d4d6adbdc45e696c2953ab95f3538fc93e015265bae529c	3	3227	227	361	363	8	4	2024-03-27 11:42:19.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
365	\\x36050d51074eb928fc02b81ecedcf5b4279b5baa65d96666d7a2c1f5e0a72a64	3	3252	252	362	364	32	4	2024-03-27 11:42:24.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
366	\\x50f9bf4de9cb410150bf215534f8b346d2a8738c26ebac996e4a09c6eaea3701	3	3269	269	363	365	32	4	2024-03-27 11:42:27.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
367	\\x36f888177ca3cedbfd354d9bfc9b0cc9afd3ae9384e89eb77df2cb2da33eac54	3	3274	274	364	366	8	4	2024-03-27 11:42:28.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
368	\\x6e7f347e8a1915dc5bfd39dc92f676959cc4bea0b8f653a9477918e24ea652aa	3	3289	289	365	367	24	4	2024-03-27 11:42:31.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
369	\\xf1d474f268600a13027b39b16969ad403557894fa0d2410eab3852fe119920b7	3	3298	298	366	368	7	4	2024-03-27 11:42:33.6	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
370	\\x1de0a859fd11178352a5fa64bdce38076aae2f4e51b2ee810908c273388da227	3	3317	317	367	369	32	4	2024-03-27 11:42:37.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
371	\\x34b912be3b6e8b81c99f62ad3d26e5c478baf226d1fa92c632f00873c5f22773	3	3326	326	368	370	29	4	2024-03-27 11:42:39.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
372	\\xee590048ebc3b016002cc24d6a6b596d2126991c0429b0bbe2105c75d7022236	3	3334	334	369	371	24	4	2024-03-27 11:42:40.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
373	\\x0c02c48fbcbe794f6cbd445d99e4bbd58969238363c7f693a9881d9644fab11b	3	3338	338	370	372	5	4	2024-03-27 11:42:41.6	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
374	\\xd1b19d888eff4544db6abec562dc4758c0b40739db44db892922595868372ef9	3	3358	358	371	373	4	4	2024-03-27 11:42:45.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
375	\\x74142023e6745511d8401a973dac1a4aa80095373e1931d39168cc53c0c8a960	3	3363	363	372	374	24	4	2024-03-27 11:42:46.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
376	\\x28d55254badd4bb696d765e638b42c0ce41e0d6c89021924dacb92e76d574b96	3	3396	396	373	375	3	4	2024-03-27 11:42:53.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
377	\\x93217cf1ad8e91ffe94de3af75bb26287755a11528b786984c3fba2aa4a05a9d	3	3407	407	374	376	4	4	2024-03-27 11:42:55.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
378	\\xa58fc9d55a509b4ab248af54c232ad8a02af25b38a3385c4b54fcb5bb5be4c4c	3	3413	413	375	377	32	4	2024-03-27 11:42:56.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
379	\\xe7df690eb69d18808af850d558cfcd9d0341b295c2b9fe7e7a39e27c7f65bd21	3	3414	414	376	378	4	4	2024-03-27 11:42:56.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
380	\\x47a341da1fa4032f2f985c73f0466b669b7c320ef5d8f3add2cf01ce6504a75d	3	3424	424	377	379	5	4	2024-03-27 11:42:58.8	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
381	\\x0ed630514f85b3cf3d4b97c12dea743ab1e712d3e94af5b2089aaba1cf20fca4	3	3434	434	378	380	3	4	2024-03-27 11:43:00.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
382	\\xf056687d225f3c49801976c852df44c4424bcb1ce2e46ad4971c4f946fd941c4	3	3463	463	379	381	7	4	2024-03-27 11:43:06.6	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
383	\\x6d22a3de1d7a770514f7712f9f5a36315302e6c55e1114eba63bef386331400a	3	3468	468	380	382	3	4	2024-03-27 11:43:07.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
384	\\x2720737e896367405c7540474d5f85be1aadc311cfc30c75ae9379958eafe73c	3	3471	471	381	383	8	4	2024-03-27 11:43:08.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
385	\\x7989fd88b420325431d96a9de66da1c57ef6b01598c9570560adb3928a307e8f	3	3482	482	382	384	5	4	2024-03-27 11:43:10.4	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
386	\\x7be8ba11720f25a90556e40221204ee678402178feb9820ee3087ea1ac2c5a8c	3	3522	522	383	385	3	4	2024-03-27 11:43:18.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
387	\\x878ca18ac8da0be248ef29d30d2f4b5fb3ea30217b52ce9703fc5dda0fe8e399	3	3523	523	384	386	17	4	2024-03-27 11:43:18.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
388	\\xc05bb07890cd64a53efe6f3df6a4822021eabe437fad2eed9894244c1c9b0204	3	3540	540	385	387	4	4	2024-03-27 11:43:22	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
389	\\x1ba9e608415beff041e94acb9115d94a7095895bfc319ba9a5aa9a6d9c0dda14	3	3545	545	386	388	24	4	2024-03-27 11:43:23	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
390	\\x1edcc591469397e702a9d9cf5ea1913781b23f28addb1c5a4c6a377155e57664	3	3562	562	387	389	3	4	2024-03-27 11:43:26.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
391	\\x7e7dd8490275e116a74471e3ed59f5527a2dbe5a999e1df26fa0b492a1526259	3	3574	574	388	390	9	4	2024-03-27 11:43:28.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
392	\\xc55eaf1da594f4bcc40247e9e6332b1a980ac03b2b77f9920507e1e3ffbf0e65	3	3580	580	389	391	5	4	2024-03-27 11:43:30	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
393	\\xef2d984e171dbbb99e50b2f241e9db41bcf0c694cfc9ba41fe78401651664d58	3	3589	589	390	392	3	4	2024-03-27 11:43:31.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
394	\\xa3a54e53492e0b56e3350e020bd51efdde256d73ce55fcd5411787f71f0f6dc8	3	3594	594	391	393	17	4	2024-03-27 11:43:32.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
395	\\xdf33775e6544ab33e14d60524bdb6f6c08f654336fbcd67fc4dfdcf676bd9d47	3	3610	610	392	394	29	4	2024-03-27 11:43:36	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
396	\\x0519c7bc848d3bc3834395388d850af51a3e616e2cd339367525afbbdcfd7221	3	3616	616	393	395	5	4	2024-03-27 11:43:37.2	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
397	\\x407790953259e4df6cabf87fc9eb40a88f5c29f0f87677b7277b2b0449bf4b1a	3	3617	617	394	396	29	4	2024-03-27 11:43:37.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
398	\\xa414d9daa52f9f16e715cc73c39097d02afd689af26b3af6bb9f96864dc8774a	3	3626	626	395	397	32	4	2024-03-27 11:43:39.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
399	\\xdeb6e6ab637b26c2adcef5bffe3bb5fae44bd0e3709e065ac1eca8f3cca87d96	3	3635	635	396	398	24	4	2024-03-27 11:43:41	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
400	\\xd9a7b8aebc69ed488fe9dd8bea2ee7a0dcc63e4d06d2cdf43c4fbf4d2ce19ed3	3	3654	654	397	399	5	4	2024-03-27 11:43:44.8	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
401	\\xca278647c5b5e9921b46ea16d5fc74d55e1ff4bf986209ca572d4a3a4f43beaf	3	3679	679	398	400	3	4	2024-03-27 11:43:49.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
402	\\x9d7ff784c361feab4d8ee08dcdfcf60374150fd576c6df4e7245a10d3d19a192	3	3697	697	399	401	3	4	2024-03-27 11:43:53.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
403	\\x8009a1321f73ddbdf9f68879fa2726641ec7a1d83ea521819bcb8b8bc3e9d796	3	3700	700	400	402	5	4	2024-03-27 11:43:54	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
404	\\xea6e06df5cf9aebafa768e6453c98a4cf3228808bebd96198b029d13f46f7f2a	3	3711	711	401	403	4	4	2024-03-27 11:43:56.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
405	\\x8f4006ea76f9e7336bcb252d40b49caa1b565f43b360d1f38795fccbb596af2a	3	3713	713	402	404	3	4	2024-03-27 11:43:56.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
406	\\xbbeb90c6d9dff4fd05d979a46c25f98384d4c214ebbf0853337a4743b8f51c5d	3	3726	726	403	405	7	4	2024-03-27 11:43:59.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
407	\\x054bd2b71b39621b39e18bd7051b4e2e1c1c04da811a8ede3862d938d872e5f8	3	3729	729	404	406	3	4	2024-03-27 11:43:59.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
408	\\x7fec6784101673fab7ea51270733e0b37498a95a1e4c71b70f14598189c5cbe2	3	3745	745	405	407	3	4	2024-03-27 11:44:03	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
409	\\xfccfca30f912d3794d48b349ef880e752fc25a34d2da3fcc755e99b1a876b67e	3	3751	751	406	408	5	4	2024-03-27 11:44:04.2	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
411	\\x01ea8f14d677d0086fd4e80609efa68037312b051938494b526c5f7ba3a0c1b8	3	3754	754	407	409	32	4	2024-03-27 11:44:04.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
412	\\x65fd2861d65bd7589c21080c0d3023c568e004db3ac48569a069d95ba668758f	3	3765	765	408	411	29	4	2024-03-27 11:44:07	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
413	\\x3472cad1a19e26f433489c5e63adf4793498a13de256547675a77efc06a7b844	3	3770	770	409	412	8	4	2024-03-27 11:44:08	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
414	\\x1ef151e1a24c462762d048a53227de536a1d46d33ef3b1930c2ab75eca6ab2a1	3	3793	793	410	413	9	4	2024-03-27 11:44:12.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
415	\\xfad09d42a137c5cd31fe4476db409faaa2340c3e2fc60ed626ea7653aeea46ff	3	3808	808	411	414	9	4	2024-03-27 11:44:15.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
416	\\xe48b3a3cbcb81d04c29f38e8255d5f1d9c66eb248e7028064f00ada0d5b99d86	3	3809	809	412	415	9	4	2024-03-27 11:44:15.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
417	\\xa7684c93551bdc60c1b134f31d1911c4240376395292b020dc12579869b27e74	3	3812	812	413	416	4	4	2024-03-27 11:44:16.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
418	\\xdc8811db8350739d5e4660e1447cd5ba3904bf8ebee8b634a4c7c62c37eaac3d	3	3822	822	414	417	32	4	2024-03-27 11:44:18.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
419	\\x767ed47eaa5b4ec27777e6c9180412e169c42fdb8865555cdee3841e4ed9bfdd	3	3836	836	415	418	28	4	2024-03-27 11:44:21.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
420	\\xf6b0fdbf65db9852422743b448d7643264ad79b73d6be7c9d87846ceb8ef92c3	3	3839	839	416	419	32	4	2024-03-27 11:44:21.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
421	\\xda668a34302736f0483aae7fda730553cffc9eae5485df2cdb8d83adf6ce7562	3	3850	850	417	420	32	4	2024-03-27 11:44:24	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
422	\\x82068b6133a935ce6f5466c05df9fbbe010a55499ec2fc6ad0a346f4480421d2	3	3858	858	418	421	3	4	2024-03-27 11:44:25.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
423	\\x7c4d31168c87c9cc2b27d37837a61d5079c9d6e57f71c771ec1c507b7bcb1b69	3	3865	865	419	422	5	4	2024-03-27 11:44:27	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
424	\\x3bb7abcc516ab82731b5a34b01fbb9753a22dbe3384e62039a1499835f008b99	3	3889	889	420	423	9	4	2024-03-27 11:44:31.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
425	\\x11ce84d65074d1946f0d372d8d83838595729f8d1026803063cacb4499d64b34	3	3898	898	421	424	5	4	2024-03-27 11:44:33.6	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
426	\\x1e45a11b9174f305f0e3e73bf9a291dfd70895c27b60a423c41d4b1936e8822a	3	3906	906	422	425	9	4	2024-03-27 11:44:35.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
427	\\x15f4f4d2b7e760cbd5281c44823178d7b457a4cfc7fcfd02bd0f5d08174ea5f5	3	3907	907	423	426	4	4	2024-03-27 11:44:35.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
428	\\xd780e6d214b363e8f8ac7a6e98ff03553f4cfde4ae606539d4bb92ea2d6119ab	3	3926	926	424	427	28	4	2024-03-27 11:44:39.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
429	\\xf1767c115839acc759503a1db828e5ec6c804abc14c73c292c87c5645074d973	3	3948	948	425	428	4	4	2024-03-27 11:44:43.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
430	\\xfa08ec09dad1a10f4edba62c12f586ed036afab8fac47d5e5515221641016e5a	3	3975	975	426	429	29	4	2024-03-27 11:44:49	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
431	\\x4ad6e6a96eed63683089d12ebe949338a2fe24cb60cafb2f12906c164c05ef84	3	3989	989	427	430	17	4	2024-03-27 11:44:51.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
432	\\x6142969b35a44675a9a1e1f6d43cebdc58959fa903865e7cbbd0328ef9c12865	3	3994	994	428	431	9	4	2024-03-27 11:44:52.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
433	\\x3a19bda267712642ba0db36e8a9aa589fbe1dff9ef5c809f2f696579837ea919	4	4004	4	429	432	3	4	2024-03-27 11:44:54.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
434	\\x2382b0db44384b7a1b7b36b7c18da043bfefe8b4adcbc871002ad649c54f74d5	4	4027	27	430	433	29	4	2024-03-27 11:44:59.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
435	\\x82a9414ae81cbaba32c5870ea730bc89abff32625fc9ebadc5db79f3f3e66e11	4	4028	28	431	434	9	4	2024-03-27 11:44:59.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
436	\\x5b95228771b4973065526529f4502f331e3fef1e818e95f0f04aae359ba39311	4	4035	35	432	435	7	4	2024-03-27 11:45:01	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
437	\\x0279846e8fad87d0f91f6f6b1bb75ca820dcb51ce443eb994e2144118e4e3611	4	4039	39	433	436	29	4	2024-03-27 11:45:01.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
438	\\x57f9eb644e0b19e0a6b03b689f108c47db56a8d3b54dab7c0976d4eb94534e49	4	4061	61	434	437	5	4	2024-03-27 11:45:06.2	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
439	\\x886aa49eda1dbebb040edc91492486da8767f1af4ac9b934dee5674e36e34dae	4	4108	108	435	438	29	626	2024-03-27 11:45:15.6	2	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
440	\\x80dc7254a42e8567557257ba2c989f096d15e54b48df21c4c3572d6775c4d7a1	4	4115	115	436	439	9	4	2024-03-27 11:45:17	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
441	\\x0a889a595bbd2a31ae4dd64c6ca8dcf13458acace75f63f4eb943bde87e49780	4	4120	120	437	440	17	4	2024-03-27 11:45:18	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
442	\\x32a0ae61a354c0410e694bde90524a6f3a57c4766480d2fae8adf7571ee81fae	4	4122	122	438	441	17	4	2024-03-27 11:45:18.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
443	\\x554c7c065d7c581fad78221bf5a6866624b5b2e07ab26a78b61459379796bcf4	4	4128	128	439	442	17	4	2024-03-27 11:45:19.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
444	\\xb28143923c3284e0da251560e09a0d6c11f2261116d8ed51b42fc40cbb416423	4	4130	130	440	443	8	4	2024-03-27 11:45:20	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
445	\\x8b011efcc06b5da73871010af132c50100bde82d7860fa040d1542d3c6b1e612	4	4133	133	441	444	9	4	2024-03-27 11:45:20.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
446	\\x0a749642367ea7aea04e5d9dc6900fc190ee943de8ba9c1a626bee59e92d333f	4	4158	158	442	445	4	299	2024-03-27 11:45:25.6	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
447	\\xd508681fa213c91ba1533ecff58830fc61ed2370b735da4b116956d96a47119a	4	4189	189	443	446	28	4	2024-03-27 11:45:31.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
448	\\x0cbf20a6b92819ad5c0ce77b218783df7aa692da0fe74f98bfc14327a63eabd1	4	4195	195	444	447	29	431	2024-03-27 11:45:33	1	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
449	\\x09d196e637fed3b4c3f6ac82298c0c79eb84ecd93b0235d1d431e510f404dd33	4	4201	201	445	448	7	4	2024-03-27 11:45:34.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
450	\\x229e20df884e50d68fc62c3d730402469cafcf6749be638373fc7bcbaf4c4e4c	4	4215	215	446	449	3	405	2024-03-27 11:45:37	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
451	\\x367b3c3a699b325cfe51eacd052359d77f8ee8d6506f59c90eedf10954e72ab6	4	4245	245	447	450	29	4	2024-03-27 11:45:43	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
452	\\xc661229d62e9c659c02726359e21a5a66795d8b8e3d91b62a4e6ac8999d784f4	4	4254	254	448	451	4	375	2024-03-27 11:45:44.8	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
453	\\x749066bcc5097215daddd7f3c3cd614c212d948914b7dcd5d58ca7810b05db68	4	4259	259	449	452	28	4	2024-03-27 11:45:45.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
454	\\x015d9cab6180dbf4772b003b74932cbaca5ce41e4ddfe1eede106db7ddbc7be5	4	4278	278	450	453	17	407	2024-03-27 11:45:49.6	1	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
455	\\x1033eb7bf79420bc56f38a0ee194dfea9707453ef062e7fd764fed6be19015e9	4	4303	303	451	454	8	4	2024-03-27 11:45:54.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
456	\\x7d51b86b04deae4c1c2ff193a47521a1341a7ef5b4ec41f7f0d976edfedd8f70	4	4314	314	452	455	28	375	2024-03-27 11:45:56.8	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
457	\\x14517bec3a3ad01cb5f6a61e0e54439bd94538987841e9d69c4940588333b963	4	4315	315	453	456	7	4	2024-03-27 11:45:57	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
458	\\xc5bef0c4485b072fdf9cfb5b532f022b4f50a082bba7d085adf0b8602dbaf935	4	4326	326	454	457	24	437	2024-03-27 11:45:59.2	1	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
459	\\x6da744078d2d19decb56c71afc42b9e1b933d3c74e4b63e888da7f2a3b8b23d4	4	4330	330	455	458	32	4	2024-03-27 11:46:00	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
460	\\x50763289e4e926cf8f796c4d66adba95abac113aa8d5a3e64b71b32ce7c067e1	4	4337	337	456	459	28	375	2024-03-27 11:46:01.4	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
461	\\x882ff5b924563e385dcaaf3cba873a26014158be6b72934e578d49b11ba5dec7	4	4338	338	457	460	29	4	2024-03-27 11:46:01.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
462	\\xe2ab3c7264242ebbcf287a341655fd106523f6e3c0d537f96031726a05e714dc	4	4364	364	458	461	8	371	2024-03-27 11:46:06.8	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
463	\\xc33d08f123728676ab98fa4317b39f6c5e79d067b4812bb63a80938544e90e35	4	4370	370	459	462	28	4	2024-03-27 11:46:08	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
464	\\x9aa6398303913a3cb0fe02b8fd0499433c6e5de3645558c74df4266e09a96a08	4	4396	396	460	463	5	375	2024-03-27 11:46:13.2	1	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
465	\\xb83a79dd813ddfd0a54e98f642031cbcba83acd3e57d0f91f55b101ccf259580	4	4398	398	461	464	9	4	2024-03-27 11:46:13.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
466	\\x7c147e35ea58dc7b454960c2e0317932039060fe70653f61bebac7c962da0488	4	4400	400	462	465	4	375	2024-03-27 11:46:14	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
467	\\x9b3ed37dcb3cfb079a737feb7815cb35fc6d20ffc4d2ca0a9b12be516cabb4d3	4	4438	438	463	466	24	4	2024-03-27 11:46:21.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
468	\\x2a98c9465f5173caa933d165e80f26003e1c5304b9ae842034e7616fc57a979f	4	4443	443	464	467	24	375	2024-03-27 11:46:22.6	1	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
469	\\x831b49b03c4f77524138813f83e30dbb1f3da6cec40a559f5f66c60f55bf6df9	4	4444	444	465	468	17	4	2024-03-27 11:46:22.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
470	\\xae9cb7ddc286deae84494c51992cb3844819968c883ede240d1c340c1b9317dc	4	4451	451	466	469	7	406	2024-03-27 11:46:24.2	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
471	\\x617f6952d556d598d330234b303ac0fe51dfa9c20569ebcff7207a57d8a24f23	4	4455	455	467	470	28	4	2024-03-27 11:46:25	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
472	\\x1df804281a68f13a3ab2110264eea53f597f819a1c53d3fb74c72a4807519371	4	4464	464	468	471	8	375	2024-03-27 11:46:26.8	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
473	\\x1078e8933fa0ab152ebd993e05797f01e80a8369cdeebd93dbf6492d7bb0c177	4	4489	489	469	472	32	4	2024-03-27 11:46:31.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
474	\\xfb09dfa41052fa75637accfa290009aa473352309f3c406336519caa559916d5	4	4497	497	470	473	7	375	2024-03-27 11:46:33.4	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
475	\\xb3d62a0b485bf87183597718c6bbd5e6d833b18b8d154e98f6dddae2ed820cf6	4	4499	499	471	474	24	4	2024-03-27 11:46:33.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
476	\\x3d10ab329a7b9a3c658fce95e4a79ddfd5ebf2740d6a13051d339143de491c40	4	4509	509	472	475	7	436	2024-03-27 11:46:35.8	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
477	\\xe5c4eda60d177db541217ee873d48003759bd6e751865f9161e963394a19a9f1	4	4523	523	473	476	9	4	2024-03-27 11:46:38.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
479	\\x254ea18adb5a56b72b7dcaaddc2366c2065d064417bfeb4e000a16ee1831252a	4	4532	532	474	477	24	918	2024-03-27 11:46:40.4	1	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
480	\\xb14fa4d475ae5fc485fcaf9658931aac623a1564fe47f9f63544b10ab85cef7d	4	4580	580	475	479	7	4	2024-03-27 11:46:50	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
481	\\xf82910dbee7944ad7d5c4fa8e2f7b36ec50e39fcccf9738a4752ad4d78f8d2a1	4	4618	618	476	480	24	375	2024-03-27 11:46:57.6	1	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
482	\\x550aab35ab1a633bda067e8e4a7affcc9461dcc4e53c9fafe8a1d2d05a1a6359	4	4620	620	477	481	7	4	2024-03-27 11:46:58	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
483	\\xb86b192fbfd8949001916d75cf0694dee25773a6e86d91066d27878256e0fed7	4	4623	623	478	482	28	460	2024-03-27 11:46:58.6	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
484	\\x0166c7eab28d26cebe07c60c1c0ffb7de4c7733d6998bb400bb01fc747b56ce4	4	4642	642	479	483	29	4	2024-03-27 11:47:02.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
485	\\x661be9ea922a481773fe16188bc59ed30feaf4f44abaaa6c03f6e54fb5b1f859	4	4649	649	480	484	24	375	2024-03-27 11:47:03.8	1	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
486	\\x562afdc4a962fa0c0935e0c5e8d067f1cebb0988c034d36457759977965a9723	4	4654	654	481	485	32	4	2024-03-27 11:47:04.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
487	\\x2aaa5758b86d0b03920a5285e8e99cc9eb96730071ab7ba84bb01476fb533516	4	4657	657	482	486	17	4	2024-03-27 11:47:05.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
488	\\xc832802809c37746f0ee4c641ec441567bef9320b2597cd839eea1875b1cad7f	4	4671	671	483	487	29	1104	2024-03-27 11:47:08.2	1	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
490	\\xfa1f2d722c0d137139914881abd1760779052a1c044e4c47cc7015cbac8010ae	4	4696	696	484	488	7	4	2024-03-27 11:47:13.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
491	\\x4fdd95705997bae8f97b94ae81756d2f0723e6010fc3bc09435d376452b55e6d	4	4712	712	485	490	29	4	2024-03-27 11:47:16.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
492	\\xbd684e3944dea0bc1d155554b65703e36d23da846fcc88e51c522f57beae0cf0	4	4719	719	486	491	24	4	2024-03-27 11:47:17.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
493	\\xf905220a9889f0974c490f4e1b53acb6dd0d0c9e820fb3519149bba131cea350	4	4727	727	487	492	3	562	2024-03-27 11:47:19.4	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
494	\\xa446e51a2fa5ab535bc91b56e3bdfa9b9241e53e7e868911da814129320ccd33	4	4728	728	488	493	3	4	2024-03-27 11:47:19.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
495	\\x3b13a43177a8dcb9fe5fe31663f34cd22c60f54596db9209c74604dd4203e834	4	4749	749	489	494	8	4	2024-03-27 11:47:23.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
496	\\x8897d6bfef6864f00f33c724901a4a7bbace21a2f91d13282ed9dd0426bdcd28	4	4751	751	490	495	8	4	2024-03-27 11:47:24.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
497	\\x16242106a0dce021c73aa6836cf0ff6f3541f12bd189f54bcc3b247c8d84eb63	4	4763	763	491	496	8	722	2024-03-27 11:47:26.6	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
498	\\x665e2984cd0bbdf4609eaea2f86dbebfc03249bb098164c9976f48026d14f3cd	4	4766	766	492	497	7	4	2024-03-27 11:47:27.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
499	\\xc5a45bbadefaa802016df1da4bb318d6bbfe81e7b97b3df7d2a12d95c2642157	4	4785	785	493	498	3	4	2024-03-27 11:47:31	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
500	\\x61c10b7f4365c73101f2bef1ce5a976e72089688bdd9deada06a76f18b7b7ca3	4	4787	787	494	499	24	4	2024-03-27 11:47:31.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
501	\\x5e1e76d288bc02aa59e2642ae401cea265d8c6f0a578c8045147ba99b7facf5f	4	4801	801	495	500	32	763	2024-03-27 11:47:34.2	1	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
502	\\x553a095df6631098d8b6316ebe1c68d3003ac27c58c0e8226f101fed22c82684	4	4804	804	496	501	32	4	2024-03-27 11:47:34.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
503	\\xf62dc4c587d3c1f74213009ff82921dba24917e03bfe424e5aa9684b8d1d7441	4	4806	806	497	502	32	4	2024-03-27 11:47:35.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
504	\\x4dfdccd0e5161120bb93038ec0a582bfe5db06e7054c19617d29ffd1aef924f3	4	4809	809	498	503	24	4	2024-03-27 11:47:35.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
505	\\x509b9659e1bbf0b7e83b15c51b51fb734ee4d6cb1c55b2bbea8235bdf2a2bf46	4	4817	817	499	504	8	662	2024-03-27 11:47:37.4	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
506	\\x90cbca38ee79962c4b55a0b4204f72f2601d11fc5be02f9cc80b072ede421397	4	4821	821	500	505	29	4	2024-03-27 11:47:38.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
507	\\x9b3d849086eb2f1f8a6cbe177fb7a45a70d7dba5f4ef22ed5c087d4a49d0e507	4	4828	828	501	506	24	4	2024-03-27 11:47:39.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
508	\\x3805071f2f88a0526fa9fcc46775875286ff0faf1db39497d5eec2d91eb6f4ae	4	4833	833	502	507	28	4	2024-03-27 11:47:40.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
509	\\x3650b2d0a1b70e504d8ef2e4b95b676258d93a7395cc78f5e11723d18834a76c	4	4841	841	503	508	17	575	2024-03-27 11:47:42.2	1	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
510	\\x7734eb31c05edd56c783aa84124921a3c9e2d16d0343eb852b585a2aef432b29	4	4855	855	504	509	5	4	2024-03-27 11:47:45	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
511	\\x6acee9a6945d3f6171c011be8d3053a937e0152f1b39ebd52bf4a5aac8821f5c	4	4866	866	505	510	9	4	2024-03-27 11:47:47.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
512	\\x3ee480ce4a92c6f3833074fa9c401a50ba3075c5de806c6ec3866c3a1e428024	4	4868	868	506	511	17	4	2024-03-27 11:47:47.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
513	\\xd2b11b26f8def256866360c2a1dbfe123892e3bd997346eb04ce9792e94af2ac	4	4870	870	507	512	3	4	2024-03-27 11:47:48	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
514	\\x4223aa3cdb4034b9373bdc3f2f9a1352bd692e1c52ec952e4d0881be9d9d6208	4	4877	877	508	513	9	4	2024-03-27 11:47:49.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
515	\\x21dd61ad4cd8a598877924a9ae7c6a95c315cc75263cce5a2a083e721c741e7e	4	4880	880	509	514	28	329	2024-03-27 11:47:50	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
516	\\x80e198173713d0d348342ed010258a6c13e956163e7fbc1b2ef5b509e9f6157f	4	4896	896	510	515	17	4	2024-03-27 11:47:53.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
517	\\xbcb27481ba432aa932b20d8720b44da588b8eb543e2e90d544effb88ed5f0c2e	4	4899	899	511	516	17	4	2024-03-27 11:47:53.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
518	\\xe399e78e5d8627030bf4ed1388c3d29fa93c0fb4b45b0d3924dd2396e864075e	4	4903	903	512	517	7	4	2024-03-27 11:47:54.6	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
519	\\xc28219943f74eab70d1ff137ee6c14f67fabb766334d8fbc2aefab05059d57d5	4	4914	914	513	518	3	3850	2024-03-27 11:47:56.8	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
520	\\x63a7bb1fc8fbe080e57ffb4e6b71d8de1fe0ac8bb3431b7479bdce566be12c28	4	4920	920	514	519	3	4	2024-03-27 11:47:58	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
521	\\x5330a03f8df6e1c1bdefbe685118d037505a91199caec1802dc0e7dcb4300166	4	4956	956	515	520	28	4	2024-03-27 11:48:05.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
522	\\x6ac976d9e1746d471b829db0b46f506360d7dc73e92eb7b1a99ee6f168449695	4	4961	961	516	521	4	4	2024-03-27 11:48:06.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
523	\\xbb14fd4128e5090c8e16d3994036eafbfd658e314a195e5f1e2f7a3cd933630b	4	4967	967	517	522	3	2398	2024-03-27 11:48:07.4	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
524	\\x0ff4d81052617828b3c8e32a09795bda120c78334b5f670344bc5adf21716298	4	4968	968	518	523	8	4	2024-03-27 11:48:07.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
525	\\x3037076b8f39b21fa17bbd69660913a1f48ab7c3c1600429a8415c38af86c863	4	4975	975	519	524	24	4	2024-03-27 11:48:09	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
526	\\x1ec54c5c78aa06d54f840e329951360ea23cdbc3fdc877222c4db1695639cc36	4	4986	986	520	525	17	4	2024-03-27 11:48:11.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
527	\\xfca63fc10fa1fa898d11e155ca7dab12c44c78e1d3c1245b99eb07871f788d59	4	4996	996	521	526	5	1859	2024-03-27 11:48:13.2	1	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
528	\\x8ed9f4a71e473604d6397638d217f89b3fed7ae68935d255beef7427cad1e0f8	5	5012	12	522	527	9	4	2024-03-27 11:48:16.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
529	\\x3eb34aeabfe993efbd5dad4002843f46ad32eace81791459d0ce470ecf53db4e	5	5017	17	523	528	4	4	2024-03-27 11:48:17.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
530	\\xdc6ba0df56ad5fc4705ed680492e40fe57ccf4bd2d9703b34af0c4a4fe27f7fa	5	5023	23	524	529	9	4	2024-03-27 11:48:18.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
531	\\x01793cf4f737ee1786b2340e458cd38c7dc555d8d2465c98e8c2e04eb027c844	5	5027	27	525	530	32	4	2024-03-27 11:48:19.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
532	\\x5a13165ef4b898a465c594a71075aede72399ef0242adc42e7d49e629ef75450	5	5034	34	526	531	4	501	2024-03-27 11:48:20.8	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
533	\\xbdae48baef2b232cdbe8e7c98e3cad3382593002c649d469d6dd2a9a8c4159ef	5	5061	61	527	532	3	4	2024-03-27 11:48:26.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
534	\\xbb2e793aacc9926f6903570b5bc21ac84494cba0eef9a7f29a6263e99131d640	5	5070	70	528	533	24	4	2024-03-27 11:48:28	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
535	\\xdd9bef730fb0d4e2ac215848960ba240ecc115eace01504da7989cd700e13c7e	5	5076	76	529	534	28	4	2024-03-27 11:48:29.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
536	\\x7ece809a3a3bb7c7db8d045d03abce51d34602b448646085e7ba77b0c3b794a6	5	5085	85	530	535	29	397	2024-03-27 11:48:31	1	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
537	\\x338a3ca7415a906c16566c61c9148adfcd3b19dad4013eebbdda78fd909c36d1	5	5090	90	531	536	5	4	2024-03-27 11:48:32	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
538	\\x82b38aa0ddc0364c30bacb56663c862b73b80f8834fc350a981875361867f158	5	5112	112	532	537	24	4	2024-03-27 11:48:36.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
539	\\x7c61ef5500c09ab2b1807e39b46cc8ae90228d7d06f4ad19c9d941e0c1fbcdcd	5	5151	151	533	538	28	4	2024-03-27 11:48:44.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
540	\\xfc8a62ef345d034760e671ae3a488ef7d191e92851e90899067627bf3edd27ba	5	5175	175	534	539	7	644	2024-03-27 11:48:49	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
541	\\x2d660c6e5827e3bd5636cd2dcdf302a78a3589af3f058c05407f5daa603ddc6b	5	5181	181	535	540	8	4	2024-03-27 11:48:50.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
542	\\xc26a18832413bc278f9dbc06313404f1e97ca0632632bacc9a8135fed3a02f56	5	5192	192	536	541	24	4	2024-03-27 11:48:52.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
543	\\xc7be602aa53ac903630edf7a1aaacf3676e6a0feabbbfa05d03dd4c0a2028c5b	5	5196	196	537	542	32	4	2024-03-27 11:48:53.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
544	\\x0b0ba3abdf13419a3477e00cb21fca0766abc7378c07c316c0f4a2372527d05f	5	5201	201	538	543	32	535	2024-03-27 11:48:54.2	1	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
545	\\xdea473a292d312154b516c77ddd97de14134e5493620434a6e4a0233e6ecc388	5	5215	215	539	544	3	4	2024-03-27 11:48:57	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
547	\\x6b29352fcd3dc8403c0fa404a937caa9904e117692b3fa6e79ae69231f1e01f2	5	5222	222	540	545	29	4	2024-03-27 11:48:58.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
548	\\xd384d2e06faaaa163d49030bbc82a6862c9fff4dbc935f4ccd9d6e73a04acec2	5	5242	242	541	547	4	4	2024-03-27 11:49:02.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
549	\\x0bcc22c1300c54e52513dcb25434fc7abeabfb61a82e88063c6a2fadb2ddb8df	5	5249	249	542	548	29	4	2024-03-27 11:49:03.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
550	\\xf64f719e97ed372f4777084ad8d8cbc73b303cce0e02addebcc049122b776c3a	5	5253	253	543	549	8	4	2024-03-27 11:49:04.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
551	\\x6ce158c8e668504816e8c3c4782e2b3e8064004900aabcc88458f3c0cd859d5f	5	5261	261	544	550	8	8200	2024-03-27 11:49:06.2	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
552	\\xd2dc4d77764285f261e208d5b18cf80c473a5afe5df7d431167b2ccc5b93c8a9	5	5264	264	545	551	28	4	2024-03-27 11:49:06.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
553	\\x5924c16daa94dccb78fcd6b2d4ee8f14e10042718acd02bf547836ad9da028d5	5	5266	266	546	552	4	4	2024-03-27 11:49:07.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
554	\\x4b039b8fd8cd49636435ccd99818afaae110d13a55d09c566d5a1fe80cd02d9d	5	5283	283	547	553	29	8410	2024-03-27 11:49:10.6	1	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
555	\\x4545c339301263a13addc25e74dc6c11e41328ca1b7bcc40fd2cda87e1c74d11	5	5289	289	548	554	5	4	2024-03-27 11:49:11.8	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
556	\\x4e0acfe7e66fea59e56b344673f56b6b85d442c8d9d2f0db4ef31c05ac51b324	5	5298	298	549	555	3	613	2024-03-27 11:49:13.6	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
557	\\x5ec035d101f53cf72b32dba869db9aaa54558d69c5981f386f6d9b911263cb03	5	5299	299	550	556	9	4	2024-03-27 11:49:13.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
558	\\x8b78f94d6f0143ddde614dbc4bc3c88334f353e1099fd880c2dc9947db142808	5	5308	308	551	557	28	366	2024-03-27 11:49:15.6	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
559	\\xe0f7ce671ca373a39bee9f0e260a689584f24bd14e945d013ea9e1c61305ee93	5	5311	311	552	558	28	4	2024-03-27 11:49:16.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
560	\\x26cdbf8f4e516d385ab8b896479be8f8757127435439b21550fbf8b0b94af52c	5	5337	337	553	559	8	330	2024-03-27 11:49:21.4	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
561	\\xa9f923356b4e8fcc3908cf3209875bdb497e8c040af2542e62ece69a74c146e3	5	5346	346	554	560	29	4	2024-03-27 11:49:23.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
562	\\xee114897e50e8d93bff89e9509ff67de3334a0dcab7719e78c1396a293a6284c	5	5347	347	555	561	5	4	2024-03-27 11:49:23.4	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
563	\\x9910824257dc44a32bd6d482b1eb061a2ea3b2171fc12e973c7bd7487021d45f	5	5348	348	556	562	7	4	2024-03-27 11:49:23.6	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
564	\\xba255305d3975a41b5b5ba1710ca23ffa242aee0d8625588e053d62b0b8d260a	5	5349	349	557	563	7	338	2024-03-27 11:49:23.8	1	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
565	\\x740c4463d1d586e709ccec7feb8d948277946193656f5b0b29b9b3b624fd5b56	5	5353	353	558	564	32	4	2024-03-27 11:49:24.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
566	\\x6d6b674edb23e5947fcb1fbbdb61c2877d0a362f871cdded130a23ba07215839	5	5361	361	559	565	9	4	2024-03-27 11:49:26.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
567	\\xa1386ddd6c9893d30a85eadf14cc2c32fb29012894e77c467a70aeed6a6c3e80	5	5364	364	560	566	9	4	2024-03-27 11:49:26.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
568	\\x053669d5b88b4d3692febea3cde3315129935b8d8f95093a6d65e4f6c1855b77	5	5372	372	561	567	8	4	2024-03-27 11:49:28.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
569	\\x3f187b3ad9471da718d6e05393663a65342f0bf0eaa3f0b01cbe87b55a5ac577	5	5378	378	562	568	5	4	2024-03-27 11:49:29.6	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
570	\\x15771e457ddfbe7de0805dbe81e2f4c12fb7d4809874b69ad119d69ee9b01ad1	5	5386	386	563	569	4	294	2024-03-27 11:49:31.2	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
571	\\x7e851a3c63116b8f0cb8970f8f59a8cce18f3eac5bb3ccdd2295bb52b7a8f924	5	5429	429	564	570	4	692	2024-03-27 11:49:39.8	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
572	\\xa6509a3851076f910ffcf90ac63101545f95ead8f10a10f020af98842d865695	5	5470	470	565	571	28	563	2024-03-27 11:49:48	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
573	\\x36c13a19d65ed5ec09a4f19fcac801795d6ef9c9a276c76413da5e1cf32c523f	5	5471	471	566	572	9	4	2024-03-27 11:49:48.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
574	\\x891f7f5d351f955ab33cca581978db13fd23fdc540b83bb65324130463d99131	5	5481	481	567	573	32	4	2024-03-27 11:49:50.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
575	\\x31f7784bac7921aff80d4aa035f0c44d30608a58f892baa874d84deb7f27d296	5	5493	493	568	574	9	4	2024-03-27 11:49:52.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
576	\\x7938abab3893fd23991733986215a7cbcd80feb513c2b776318257cb406a4fb4	5	5501	501	569	575	8	294	2024-03-27 11:49:54.2	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
577	\\xb805c8fe9d566f902ac756718cae846a0a044b582a9eefb780ad24eb6c147586	5	5514	514	570	576	8	592	2024-03-27 11:49:56.8	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
578	\\xd03bbb3e184d5fe02af3f8067f6cc5617176c3a5a3186009f79ba3d2dddee577	5	5515	515	571	577	7	4	2024-03-27 11:49:57	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
579	\\xd523004a018ceb22ec87abbaf1bf9fe910f81664d430725500a724f286f4fbd7	5	5520	520	572	578	24	4	2024-03-27 11:49:58	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
580	\\xf61134bd6f556c33938d23ce60e2beb00094a3fdb53dd50507904237a78abedf	5	5524	524	573	579	4	4	2024-03-27 11:49:58.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
581	\\x7ec610301b8a5388f8d1c02630c784ff79dd51d8d045411816690ae55bae4ff4	5	5525	525	574	580	9	4	2024-03-27 11:49:59	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
582	\\xaac10ec013de2847fc1221b7582899189ccec159e7e98bec0f6fd10a3d1f8b12	5	5532	532	575	581	24	4	2024-03-27 11:50:00.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
583	\\x9c6736442d866ddc37b6f22122481849af2395dc526c81f52f25ec75dcc98b54	5	5552	552	576	582	9	320	2024-03-27 11:50:04.4	1	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
584	\\x6ff0d691e9b164a0e0bb6dcd2d39d08ffb8496854d8d7ce8a9a032068c5d61ce	5	5564	564	577	583	24	4	2024-03-27 11:50:06.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
585	\\xa5534af96887a0bcadb801fd330f75832cdb16f1d9437b86286f0ffffc38f2f0	5	5565	565	578	584	5	4	2024-03-27 11:50:07	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
586	\\x75e7062b1d5b098788f86300bf9c01380150598464c65452c58b812882aabc7e	5	5597	597	579	585	28	4	2024-03-27 11:50:13.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
587	\\x9f883697b135cd730942a74cf687c352d15ff7537a79b6f1b72c12f1a32b2a79	5	5604	604	580	586	7	4	2024-03-27 11:50:14.8	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
588	\\x70e5a51b271fbfa84e26a3ecf14a002caf5f36d197af03e0290ef70efd1eaaf5	5	5606	606	581	587	3	4	2024-03-27 11:50:15.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
589	\\x596e6ed4fe655d8c805d63d4eef1c44c6525237b29dd161d9504f625a6bd65b9	5	5607	607	582	588	5	4	2024-03-27 11:50:15.4	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
590	\\xbc5405010e0184c29588041cc09a4c451a5d0c818cf784a2c9d71b0c9c3d7b02	5	5625	625	583	589	32	563	2024-03-27 11:50:19	1	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
591	\\x5d3bc58f4b279e90ae136f721c9e87b42ea6df7fea37f60a3b420928a04ce454	5	5632	632	584	590	8	4	2024-03-27 11:50:20.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
592	\\x3f47e5b3ac641b4d35a5dd1e81b12039d15d07c608d507a2de362e3d8a8d6b8f	5	5635	635	585	591	9	4	2024-03-27 11:50:21	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
593	\\x3fd7a3d5d2ddf3a511de188470314d61794089105dbfdc903836f04655ffc06a	5	5639	639	586	592	29	4	2024-03-27 11:50:21.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
594	\\x89a183b0531d31a1befea99b6790a986dfbc5247867f3961aac1bcb2ed582508	5	5642	642	587	593	29	4	2024-03-27 11:50:22.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
596	\\x89d4bedb8e0d95596870176d709fb3cd8ed2ba7a0a9d807f39cfe65afe7feee7	5	5650	650	588	594	29	4	2024-03-27 11:50:24	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
597	\\x2042a105bfccac27cc90fdea71c7e395048d40b7d16d5561005c4f36480fddf7	5	5667	667	589	596	17	4	2024-03-27 11:50:27.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
598	\\xa1840e0807c31146aaa5c2e1a7ab0d3acb09f3ea8bad7199d839ab7cfcc3d9a6	5	5672	672	590	597	32	4	2024-03-27 11:50:28.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
599	\\x2cfb7486665d876ffef7c9404fcb170ad9fbdd8491a990a1a47ada8c3dfcd179	5	5679	679	591	598	29	4	2024-03-27 11:50:29.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
600	\\x1b301a393468f1a6b87eb3148e242e416605a92779acbbdf5f37d02f61802d83	5	5683	683	592	599	24	4	2024-03-27 11:50:30.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
601	\\xc09526a007688a4ef8e61e9e73cd203b62c79e3d40ae9c2bf3d56a29de8af277	5	5710	710	593	600	29	4	2024-03-27 11:50:36	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
602	\\xf8f72f6383d9a32f8b7ccecd5ab8eab8e931152510559a7028e7e69e42d753a1	5	5718	718	594	601	17	4	2024-03-27 11:50:37.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
604	\\xe57b5653b2f2f4795c7797dffafb957b9bf07e329f8df829abff0b6ee4578a9f	5	5723	723	595	602	5	4	2024-03-27 11:50:38.6	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
605	\\xca470bbde62437f741e00998f28cc854cf527124c44c58ab2ad5ccc86e89df88	5	5736	736	596	604	4	4	2024-03-27 11:50:41.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
606	\\x1e43a231c7f89224cde08287099ea43e5fefaf78a33b5d918dc3a9c44122b3cb	5	5744	744	597	605	29	4	2024-03-27 11:50:42.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
607	\\x9ff15502acc487ed3d3a68e4f8d5d1dafce5de8f25558af50de4845c11f90052	5	5764	764	598	606	3	4	2024-03-27 11:50:46.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
608	\\x27e923c2ed21d39b3adbb4d5b9698275d79e1231c0701707b0d80ac53a79b9df	5	5765	765	599	607	32	4	2024-03-27 11:50:47	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
609	\\x536af21604454662dd92800d477a1acb0f80c1bcd43e9cc06ccb814b5c086a97	5	5776	776	600	608	7	4	2024-03-27 11:50:49.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
610	\\x43c07bceac6691bcee433dd0b90ae318f13af9fa49850ad07e131462f2bc03c5	5	5780	780	601	609	4	4	2024-03-27 11:50:50	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
611	\\x2ee40b7805b6bf73974863752dbe0a4fa78d5a514bf60456ce6b64e8c8de4521	5	5783	783	602	610	9	4	2024-03-27 11:50:50.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
612	\\x413e62c873e082f7ff720eb770a789fb3b8f898bb2a539185895b048547e917e	5	5826	826	603	611	32	4	2024-03-27 11:50:59.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
613	\\xa5adf6f48f98755201b0fed04dcab3e2e25c8134cbef8f750ef84a79c53892aa	5	5827	827	604	612	32	4	2024-03-27 11:50:59.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
614	\\x8667804164c36650b3e7605c4d7a6232939cf597912f975ed1f715b2c864cccd	5	5838	838	605	613	8	4	2024-03-27 11:51:01.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
615	\\x3fa5f83d08aa649dc548f686c4848d0c0384f31de51ee89621b1a3ad89a36e02	5	5843	843	606	614	7	4	2024-03-27 11:51:02.6	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
616	\\x68a25a58d11ffb20b1e7af82c6ce8087851dc6ae9f053422a388b69e22515cc6	5	5859	859	607	615	3	4	2024-03-27 11:51:05.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
617	\\xe111e56e42c03b63c2272b3244504eb187defdb33db0e8a73bb234720ed1a7c8	5	5867	867	608	616	17	4	2024-03-27 11:51:07.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
618	\\xdd72bbf36504f4afcd0ba073e5cc85f92e1c7bdd089f00504297d85cd9ceb99e	5	5876	876	609	617	32	4	2024-03-27 11:51:09.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
619	\\xc51c1235a709c9fb5df14d20345117b58383e07fb42e733ede1f88fd914da6de	5	5891	891	610	618	7	4	2024-03-27 11:51:12.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
620	\\xd5eecd298977f175cdaa701d4468b6da6391cc918fb5118c9dbeea8b70132c3a	5	5900	900	611	619	5	4	2024-03-27 11:51:14	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
621	\\x5b3c70c1c823e0b868e31114809b2c9177f45667140f2ac3f82f36e671aebb66	5	5919	919	612	620	28	4	2024-03-27 11:51:17.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
622	\\xdf26ed3e5c61d59e9fcd7eaad33a8d81f24ff2b250369cdd8dc0d73d41d19679	5	5928	928	613	621	9	4	2024-03-27 11:51:19.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
623	\\x91bfe221e52e2dab2476b5223104437ef60e2442c839f091378a8d46b2a18e20	5	5930	930	614	622	17	4	2024-03-27 11:51:20	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
624	\\xa6f7f02e9abb49d9cc80fd2db4cffd063cbd8549dc4170f2a1e33905de8169ed	5	5932	932	615	623	29	4	2024-03-27 11:51:20.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
625	\\x1df6a2cb2bb69f6c7e82deb064411b6d71c678013233c1d88589372c52e3c9e3	5	5934	934	616	624	28	4	2024-03-27 11:51:20.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
626	\\x4dff2b1b5bdc2ae083c563ea48deadacbf0088a145259f0d5adaaa7c1cb837ca	5	5944	944	617	625	3	4	2024-03-27 11:51:22.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
627	\\x35e4a446f1aa201afa757e15892df68b7318e296c8bc9ed97e2813a51e526547	5	5983	983	618	626	29	4	2024-03-27 11:51:30.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
629	\\x1040f741b39dfa425283553b9eab7c2ce9194e2715c3707f499d819412567e24	6	6003	3	619	627	7	4	2024-03-27 11:51:34.6	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
630	\\xf80fe57e6ce80a1b7fabfd4098333f9662144a12f664afe5e4fd8dc0afb7fe2d	6	6008	8	620	629	4	4	2024-03-27 11:51:35.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
631	\\x10ee4fd7efeb206ff68ecac39ad2bcd1cc541818630fc8d1341711f3aca40621	6	6011	11	621	630	8	4	2024-03-27 11:51:36.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
632	\\x67f29612800146518b306ed9c97096adab50bedaa9c01c039e27036a22b16c57	6	6014	14	622	631	7	4	2024-03-27 11:51:36.8	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
633	\\x4847334247e8d5a728dc82168d306af73d000b0a364e9c4e18adce1505092b84	6	6028	28	623	632	32	4	2024-03-27 11:51:39.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
634	\\x3f4bb26db0e257d0671d405b39583d8e0334cf85bd99682628768346919bae18	6	6035	35	624	633	29	4	2024-03-27 11:51:41	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
635	\\xf45e7058f3691da42a97a88422813af7997946f6de785fddbdd705bf298b8a27	6	6038	38	625	634	28	4	2024-03-27 11:51:41.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
636	\\xf901dceca10cffb70aecd38d856de3459ebbf1bc44670403aa2cedc3666878e4	6	6047	47	626	635	7	4	2024-03-27 11:51:43.4	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
637	\\x1dd384ff38809dc9be86c979b949f2494301c93b2e76c74b852f12d51eea29a9	6	6075	75	627	636	7	4	2024-03-27 11:51:49	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
638	\\x9f03d6578621bdbfb1cb7bec0b21645dea339d04735ca8bee72295cc9974fcdf	6	6082	82	628	637	7	4	2024-03-27 11:51:50.4	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
639	\\x39a59be7eb1f6c9c342c2b1efe7fa4b4aee707f4f719f21cbb743a27837888f1	6	6098	98	629	638	8	4	2024-03-27 11:51:53.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
640	\\x993ff60188e705fb5ee3d57e2d8d3c064b92582dd59e6c1896dced4df8e206c4	6	6109	109	630	639	5	4	2024-03-27 11:51:55.8	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
641	\\x91c30d5dca3019a4ad40d108e87884702ebc3dc5735ffa383171ac993501cdbd	6	6120	120	631	640	24	4	2024-03-27 11:51:58	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
642	\\x398b333ea5c2fa18a5fe514c262d62ca64a1408a76083479cf4d2aedb545d754	6	6123	123	632	641	8	4	2024-03-27 11:51:58.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
643	\\xe2e42dd3f590bd2b82bebbd4830c0ac530c82567bb0b0842642ec93bca756cf3	6	6138	138	633	642	5	4	2024-03-27 11:52:01.6	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
644	\\xa6a8a4ea0700b20c8b55f1b3dbc11bd74d07ff2b9297d50dd68ca5ef6fecf04c	6	6148	148	634	643	3	4	2024-03-27 11:52:03.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
645	\\x04bd1cb41cff523f99c9f06743ea954be1b07a1fd9bc08774d09f30b6e20d266	6	6155	155	635	644	9	4	2024-03-27 11:52:05	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
646	\\x6b10649e8dae4f42ce4451ed9f0bf0a258c04fb77dbaddaad434631b80b2116c	6	6158	158	636	645	29	4	2024-03-27 11:52:05.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
647	\\x805405826634dbf1194ba863fc82d78346633e7d3e7cbc4ea522b4b2463d884b	6	6169	169	637	646	29	4	2024-03-27 11:52:07.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
648	\\x187105b75666dc8d520c807627c9eceab7b2ec61317b195e64e4a5829703784c	6	6175	175	638	647	32	4	2024-03-27 11:52:09	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
649	\\x13090935f4b63999c5ce2cda5eeb61a78c14ad3426d48031c94d995a687edb0b	6	6181	181	639	648	29	4	2024-03-27 11:52:10.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
650	\\x87b3463b3db0be79c7d1d9e966669d01c735e1913959e29d595142ee63290990	6	6186	186	640	649	5	4	2024-03-27 11:52:11.2	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
651	\\x1b6cd1891cd50ce84264887ddec2d422a3ee975fa0ac126a66f666d7a9e1e62d	6	6214	214	641	650	24	4	2024-03-27 11:52:16.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
652	\\x21f560fe7a7ef2885558729ae4f7e3f50e92b77b95409e2046ad181e0d8a2412	6	6215	215	642	651	5	4	2024-03-27 11:52:17	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
653	\\xaab8a084549802d640358da2c54848738831d8b5b404ad1fed4c332ac50be83d	6	6217	217	643	652	4	4	2024-03-27 11:52:17.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
654	\\xcf273474d228fe48586ece8ffd17ef2301b416790c92c73747cbbef7becb3ebc	6	6255	255	644	653	32	4	2024-03-27 11:52:25	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
655	\\x7fe1ff2137470920dc4d2a9808fb416145c48cd611545ee316d10b93738e98d4	6	6258	258	645	654	4	4	2024-03-27 11:52:25.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
656	\\x786392a0b12414321411556b846ae91cfa401ae76821dfc8a71335666f3f0685	6	6275	275	646	655	7	4	2024-03-27 11:52:29	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
657	\\xd6f63be9a1a73bfd10f59d5e7547fb29cd617d99def3ac2f381ac82650f20edf	6	6281	281	647	656	29	4	2024-03-27 11:52:30.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
658	\\x1994d98c057f67cc56bb6d19afe3bca6ef133fc444cd4c1aa09740a2142681fd	6	6293	293	648	657	5	4	2024-03-27 11:52:32.6	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
659	\\xeb65fc9660d28d06495ab7c403f34e2b538a381516a99e39607293dd6f6e21ea	6	6307	307	649	658	17	4	2024-03-27 11:52:35.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
660	\\x805e76a2f926112759c9893002279dcc3076edf328099c44a86d24b0ae6b2e50	6	6316	316	650	659	32	4	2024-03-27 11:52:37.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
661	\\x35e71ff2dfece377fa3f325451a0c5a0faf96407a9ad6c02b22885aba479cbc2	6	6323	323	651	660	5	4	2024-03-27 11:52:38.6	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
662	\\x469175866b2619ffd7595c6bd3cd6b17a449403074fd888719deb9817e69820a	6	6333	333	652	661	7	4	2024-03-27 11:52:40.6	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
663	\\x0e5223a93d6c6b9bf13451f63a1ced6f806f6cf801b3237eca5f31dc1058c755	6	6350	350	653	662	4	4	2024-03-27 11:52:44	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
664	\\x41bc53bcd65389a9346aef4277466e7e371cbf448ed94fae2dd41cd172e8c159	6	6358	358	654	663	5	4	2024-03-27 11:52:45.6	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
665	\\x6e62ef99da678ef88a57c5e80218b21f4482b1aa2d545e8dadf69be3bc5f6035	6	6366	366	655	664	29	4	2024-03-27 11:52:47.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
666	\\x33c973b5ecb4c7318b1b57a72a88c3f763f599df11a0345df7a1e7983e7e71a3	6	6369	369	656	665	7	4	2024-03-27 11:52:47.8	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
667	\\xf301d64a99803c50f82595cd2cde1b7edba43c4661e19e298007be3fca799493	6	6383	383	657	666	7	4	2024-03-27 11:52:50.6	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
668	\\x534ef95b07bbe6755c825002aafdc1e35c67a50342b4bc8dd340d4a323d3c847	6	6384	384	658	667	29	4	2024-03-27 11:52:50.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
669	\\x8101765a3ad78ae11780b25c2a6f1a6689994a00b266ea3aafe4b39dbdc62b3e	6	6385	385	659	668	17	4	2024-03-27 11:52:51	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
670	\\x8efda1a47e57310f4cba497140b00028431bc2c2a35fe9127e305d1e2312fd3d	6	6390	390	660	669	4	4	2024-03-27 11:52:52	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
671	\\x574f4c858c95bcf6c077bb2addc9e30830ced4da00f0f50a550de97e722e805e	6	6395	395	661	670	7	4	2024-03-27 11:52:53	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
673	\\x4e57b28a88a665cb12d31a9811b511ede0d7b9cb78dd3fd46d1e38860b4fe813	6	6397	397	662	671	28	4	2024-03-27 11:52:53.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
674	\\xc9c95e4c2c5a8ee45e4a70929a58d2246c1a1dd29adcb82891c41632d6e2aac3	6	6398	398	663	673	8	4	2024-03-27 11:52:53.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
675	\\xa09679023aca6b8060cfc14ec7b9f1423be996cd89a6705a7c1a95ddcb176907	6	6408	408	664	674	28	4	2024-03-27 11:52:55.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
676	\\x202d551069b2b816f11bef34ac4ffdd10f90b88c0934d2ed3fb16e5697234ff1	6	6412	412	665	675	28	4	2024-03-27 11:52:56.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
677	\\x4169e2ce9ac22cc0ca7e05083a9f74c87f398b9d886e0d70002f3a4227497042	6	6414	414	666	676	7	4	2024-03-27 11:52:56.8	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
678	\\x05573f8d9e26ee7bd523616efcd3a21222c62fa03493feeabba22483db9a8ab0	6	6416	416	667	677	8	4	2024-03-27 11:52:57.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
679	\\x9338263990b43720270b92be2cb4bc8a9a1fb47a44383d00df1360c73ca2d9b9	6	6428	428	668	678	8	4	2024-03-27 11:52:59.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
680	\\x3b32101dd0292b548b3fca7bca29197db1365285bfecb1f3378436f2bb448553	6	6437	437	669	679	29	4	2024-03-27 11:53:01.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
681	\\xf8d492c5f5942b141fffd18d1797fdf4213ff18ebe5d95d218a8151fd6c141c2	6	6476	476	670	680	3	4	2024-03-27 11:53:09.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
682	\\x00fdcb32ca3bbc6418dbabfd16fcbf63cd3b681a3068cc0afdc7604fb992747c	6	6482	482	671	681	24	4	2024-03-27 11:53:10.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
683	\\xe7983a02b109f62f72b3fdddb3956c9d507f613a257e819a8e4f796d2da89faf	6	6494	494	672	682	4	4	2024-03-27 11:53:12.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
685	\\x68052e8fc793b696ee928de45f6250e0411bec0085a9bdecf0749eb9cfd1b5ba	6	6495	495	673	683	9	4	2024-03-27 11:53:13	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
686	\\x945f2a4aa2dc90170a6cb3b8938b62db1401dd32926cb295b0a7118020c424ef	6	6503	503	674	685	28	4	2024-03-27 11:53:14.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
687	\\x399673a99c8f620f4a2ddd7ded5638920e97acba531620ef52f3c330fdb7b3b9	6	6522	522	675	686	7	4	2024-03-27 11:53:18.4	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
688	\\xab52538a87ed8b5d283d5bcc89cffc73c3002493f9f3e2de91be668b357c4b31	6	6523	523	676	687	4	4	2024-03-27 11:53:18.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
689	\\x302ebdd8b0350c522c9b24f2995a84e41a59da470a4319e00b7b133282457e2f	6	6524	524	677	688	9	4	2024-03-27 11:53:18.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
690	\\x9d4b763b9c496f7c11940e744f136d46648912dae5eae532859290563ab55d11	6	6530	530	678	689	32	4	2024-03-27 11:53:20	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
691	\\x5511b1d54149987fcda4d45072101ef6e8d256d8255092707256482b06748d19	6	6550	550	679	690	17	4	2024-03-27 11:53:24	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
692	\\x57f77183442eb1d620adc9a3b878ffa9e75e0860a2f77a493377ba4b97a75a2a	6	6552	552	680	691	32	4	2024-03-27 11:53:24.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
693	\\x7f6026a73f1a86c8ff33487b51a43dfa7c4e6df27f14bd69fa010a9834b4ab8e	6	6555	555	681	692	5	4	2024-03-27 11:53:25	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
694	\\x7101588bc0b6209294ddcf35d61072fe97e95f32d8ca2457f74852f24a17e84e	6	6556	556	682	693	29	4	2024-03-27 11:53:25.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
695	\\x4f48a764a90d5bfe23e84e2aa8595778d1f5383e983f84270e3b85674db10c4a	6	6557	557	683	694	3	4	2024-03-27 11:53:25.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
696	\\xc85bb2dbcabed904b09c6581d45e95b9eb6a993d3446c8cb2fc86bf49877dcbd	6	6566	566	684	695	29	4	2024-03-27 11:53:27.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
697	\\x67fe982bee268f3ca7ae2309289b79218cd9e9ed2487a4d592af3f3dfa9bd6ae	6	6572	572	685	696	4	4	2024-03-27 11:53:28.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
698	\\xedbcb2aca282413e00d12d74277f16a6a25abbcdb8dbc4937d4b0c693c637d8e	6	6592	592	686	697	29	4	2024-03-27 11:53:32.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
699	\\x80a9a10d8cd0975f59425d139d923118e64443bb75b34a87a9325fa5b70569c7	6	6596	596	687	698	28	4	2024-03-27 11:53:33.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
700	\\x9465107953eeed98e03433182ad5db2b848ea2f988d3de65426317c6f7b98622	6	6611	611	688	699	24	4	2024-03-27 11:53:36.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
701	\\x911b0cab87efc10aaf9768a7462d818e2ad66c568cf855ea9adaf1c77749d3d9	6	6625	625	689	700	24	4	2024-03-27 11:53:39	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
702	\\xaad441a73fc1e0adff3aca5618fd900cc85950c888552bb7d482b3b2519bd9c7	6	6651	651	690	701	8	4	2024-03-27 11:53:44.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
703	\\xf4bc88953a08ed1fd6ba87f17b6c2bf9b91e33cc6c7386bfc4b155a8b625fb86	6	6681	681	691	702	9	4	2024-03-27 11:53:50.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
704	\\x765d9ada9af138d940138c8838c58c0d0008a4f3455818c73d7c8f1bea94b503	6	6688	688	692	703	28	4	2024-03-27 11:53:51.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
705	\\x23bb9b4e864756e04529a091e545ba79ee8b7216ec4f0c876d0c1dd15232612a	6	6689	689	693	704	29	4	2024-03-27 11:53:51.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
706	\\xc9c46b7c04e8ab5eb3cb16866eeb90bc6215fdbc652aae7b109df125ac97bb46	6	6690	690	694	705	28	4	2024-03-27 11:53:52	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
707	\\x5bfb6fe01b0e4e60d34f3f6e43fb640c3ab2aec4b522c6da1fe5a566bbba437c	6	6694	694	695	706	9	4	2024-03-27 11:53:52.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
708	\\xcf760d44a3e9612d77fccb9cb4516b36920911e6144d4730e1512fd3c51e04b4	6	6699	699	696	707	5	4	2024-03-27 11:53:53.8	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
709	\\x7243b4bd37bc71575083f65be37b3c607789918ac9f751acec13b9fa3e2f0dbd	6	6703	703	697	708	3	4	2024-03-27 11:53:54.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
710	\\xbdc54e2853974e5521b65f1cab1e9c608cf2af594b85711dfb4aeba718728cc3	6	6716	716	698	709	29	4	2024-03-27 11:53:57.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
711	\\x96bd5d6c4ca807360ce65266a04d9b420917d8fb4d01f21eb84b9751fcba420a	6	6731	731	699	710	28	4	2024-03-27 11:54:00.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
712	\\x79977ebaa97aa344d72e5b932ce4a195339269096685932acb0a2473483d2847	6	6732	732	700	711	8	4	2024-03-27 11:54:00.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
713	\\x5ba087e6b3ffe67b87eae9de5f6cfa2f3bcd1480cc2bb543d9feb7e13d7d68b3	6	6740	740	701	712	5	4	2024-03-27 11:54:02	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
714	\\x10de523ef8bc689ada5b9758d7efe38fe8491a8cb7401ff7967aae84ecaffeaf	6	6745	745	702	713	8	4	2024-03-27 11:54:03	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
715	\\xd30b80bc9d96595899ef19d9917f4f9a08ac89cadbf31ca862e67261efc5ba92	6	6784	784	703	714	9	4	2024-03-27 11:54:10.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
716	\\x825457cbd0ebd1e5c51d5dbc58d7af25ccd508bf632684b840181394cd09e559	6	6788	788	704	715	7	4	2024-03-27 11:54:11.6	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
717	\\xfac0b519160b15b0b289bbead5cc33c675ae09c60a6e2c73d40899f18fd0e8b1	6	6795	795	705	716	32	4	2024-03-27 11:54:13	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
718	\\x1c8c6ebf5af16f2969c12621347206cf24038119870f07061eda085b66b7969a	6	6797	797	706	717	28	4	2024-03-27 11:54:13.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
719	\\xcd5ee389b139a6a27a6324bd453b8aaf3789b43c25af6f7c5496833cb5869c6e	6	6799	799	707	718	4	4	2024-03-27 11:54:13.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
720	\\x27169725a735a43217bb4e30e2d4f73c99ba799fecd2c4fc96266482a6753c87	6	6801	801	708	719	9	4	2024-03-27 11:54:14.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
721	\\x4220eb112a1bbaac57201e83c181714a505955fb5a158fb0cfdcce1adade274f	6	6803	803	709	720	29	4	2024-03-27 11:54:14.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
722	\\xfb76b434667d59639c354c5c7e544d6daf2ae57f0c24d46ba6421a33a94117ea	6	6809	809	710	721	28	4	2024-03-27 11:54:15.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
723	\\x980bd5b96297b9ebe3eb796b5ad5e961a49caad8a1c1541b96f14b8144fb7db0	6	6817	817	711	722	29	4	2024-03-27 11:54:17.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
724	\\x333c7ca6e26678e365cbdfbaec7b6b64c3a30b94e455dc4b0808348f4b1263f3	6	6820	820	712	723	8	4	2024-03-27 11:54:18	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
725	\\x979a74bb513fd8270bd6106d1b8155c27ec5e68161cda830c4c5e2609567a00a	6	6826	826	713	724	32	4	2024-03-27 11:54:19.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
726	\\x36f572af8c71d76d546656d841b16bf2a9aa408edbde92634c8d5a2b6bde57e6	6	6830	830	714	725	32	4	2024-03-27 11:54:20	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
727	\\x10f6569e8549757e17c218ddfc9ab72d47336b099bd813e135282c56db78e72d	6	6835	835	715	726	3	4	2024-03-27 11:54:21	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
728	\\x07ce644567bc5d02e996fc0511c18b35ec86263ce8e627dffc4b87bfbc8927d8	6	6836	836	716	727	24	4	2024-03-27 11:54:21.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
729	\\xdc51f387a4f8d14a9b5bd2a00e9e4e3a0cc54ca1888e23b76dd3404baf5160d7	6	6840	840	717	728	3	4	2024-03-27 11:54:22	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
730	\\x1485a351bd72a9a60be91075c54c2cdf1ffd727c7ca9ac6f9380d2e266180986	6	6847	847	718	729	9	4	2024-03-27 11:54:23.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
731	\\x0d2f1ca1c0f77854eb86a7d3b2630b1cab7bbd25abb6cf583c3d9d1a052b18d7	6	6851	851	719	730	5	4	2024-03-27 11:54:24.2	0	9	0	vrf_vk1dekzxdv8s5qptyy5xdg5vg4p3ly5cz44lkv7gplhp6muh9zufvysvafez6	\\x92f6e1f353816203e06a70bba5d1aa24879ab2fa7cddda727898bcf6ab6d7f84	0
732	\\xeb5d9c11a565ce6bdf3691f2eb08c776db3d478e2526bbe9b6c836d57928c98d	6	6855	855	720	731	32	4	2024-03-27 11:54:25	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
734	\\xcb6f9b4552fc6deb28af0f14074804dc5d5b61614854d28f8bba35d3afab4f88	6	6856	856	721	732	7	4	2024-03-27 11:54:25.2	0	9	0	vrf_vk1ngrnggahqsyjdfzydlvxcu5uzdpjxsfesacfmzsaupn8wkwktdvqky6t3p	\\x506d70fa9b9e338bf10883af11e7a310826fc4de3effaea7231be7da97b3419a	0
735	\\xefcb4e0b491a9bcb069dce74395c4e1bec8e869fca284805cb1b2387fdba12d6	6	6868	868	722	734	29	4	2024-03-27 11:54:27.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
736	\\x2b4c073dcf4537bc1d856d1a1a1ca7f14c50d6b8b9488a2e1b278f04373b9226	6	6877	877	723	735	3	4	2024-03-27 11:54:29.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
737	\\xde7c6698f126540138e3a499bb8a2dfc02c8a1d9f96220c8f94805fcc99752f1	6	6883	883	724	736	9	4	2024-03-27 11:54:30.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
738	\\xdb5c5bd19b227146350f2b6b0f5fd5b4384b3d3e840264f74aea549943a72362	6	6885	885	725	737	4	4	2024-03-27 11:54:31	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
739	\\x24789f5d5a636cf091e6b5a8617a24de8b6333da79afef335e4e705caf607988	6	6888	888	726	738	32	4	2024-03-27 11:54:31.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
740	\\x2324b878a448bf415161dab405c77052a1042faa47f2854033fae2a192fd3dae	6	6889	889	727	739	32	4	2024-03-27 11:54:31.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
741	\\xd5d55ec044133bc13e3f974f2c6e67375a9e1baace3b4241577e010564b8bad1	6	6907	907	728	740	17	4	2024-03-27 11:54:35.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
742	\\x3727c5e081bbc6a59f57a0f27c7091bd29a54c86ff9d6153a45470e5ec904ad9	6	6938	938	729	741	28	4	2024-03-27 11:54:41.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
743	\\x0e8adf34134ade7c603095e6d96c430d7beab840dfabb962eb8dc0e3894ccf9f	6	6941	941	730	742	24	4	2024-03-27 11:54:42.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
744	\\xad1ad8a9b4d9a1fdf2307b4cc8cf021207266d59b3e130b47b4d5d9c1b536e36	6	6952	952	731	743	17	4	2024-03-27 11:54:44.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
745	\\x9df8d3752f9d3503ad2d8dff812e591ff18f422472b61432a1e3866dfecf6361	6	6957	957	732	744	28	4	2024-03-27 11:54:45.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
746	\\x6b8da084025fc9022d805deb991419b82bb50807d2b22c8cbb4a5811619115ac	6	6973	973	733	745	3	4	2024-03-27 11:54:48.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
747	\\x59b33bd0d66539c7554190f803e7347e90d347cf5a84022fa0c95c2dfe3d6147	6	6984	984	734	746	32	4	2024-03-27 11:54:50.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
748	\\xe7e5d68d3b9e36379d7387fe1f5a41289b939033563fe3de8eb0bc30d957d0e4	6	6992	992	735	747	24	4	2024-03-27 11:54:52.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
749	\\x586098f7889fce70009fbfd1e8a7ff640f8a89b4f48000d9701ba0d604facd0f	7	7003	3	736	748	9	4	2024-03-27 11:54:54.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
750	\\x00f33aaa6e0d6e67ebcc28066db58c6bc83173d854ac22404649eeece34c9ef7	7	7009	9	737	749	17	5581	2024-03-27 11:54:55.8	19	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
751	\\x5c2b5de07687cdf89f23c8fe132e56816b7000f9c8257dc6d47a0d9e257cc76b	7	7024	24	738	750	8	24442	2024-03-27 11:54:58.8	81	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
752	\\xc72b0925e2bd2767f6269b864b9dcde03cfd0b54f6ffb069b5b0e56bfc9a88fa	7	7026	26	739	751	28	4	2024-03-27 11:54:59.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
753	\\xbe650735740908a4e28acb65834c1eaa468503179f4917de977fa5639cb9ce2f	7	7039	39	740	752	3	4	2024-03-27 11:55:01.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
754	\\xc942ecd322f81545d3fe6d664fb183710968eeda71485848620eee8548b3ffbb	7	7071	71	741	753	4	4	2024-03-27 11:55:08.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
755	\\xb5f8f4f9e51ba63b064ee61d79f7a3936008af31b1cd04ea1f358f3719bd37b2	7	7089	89	742	754	32	4	2024-03-27 11:55:11.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
757	\\xe3bb074039faa9013d65a2852bdb2673bdb477e8f9f9e28f5b7cb8606ce81696	7	7096	96	743	755	32	4	2024-03-27 11:55:13.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
758	\\x5020a6594abad1d35cba4f19d3533bb5727675ccaf0bcb3c44c277e3d37cafb0	7	7104	104	744	757	24	4	2024-03-27 11:55:14.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
759	\\xb97d6adc40bdddb3d89033ea35607413ae8f3ed3a9c7e80850ac6b55b23046f7	7	7105	105	745	758	32	4	2024-03-27 11:55:15	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
760	\\xd437a413af9a3e7b8d0a1595f3cc2204b97cd0e7093460988c3277084e19b1c9	7	7113	113	746	759	28	4	2024-03-27 11:55:16.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
761	\\x24907fbd91b0f074bcca60f3d5f42019aec9d5721d18be0f0b2b25fe7882b0a0	7	7117	117	747	760	17	4	2024-03-27 11:55:17.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
762	\\xb2cbe506196f3425de961560134968ec371ab9b85f0ef40cd9dad70f58968a62	7	7122	122	748	761	29	4	2024-03-27 11:55:18.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
763	\\x5c741848fa9644003facd0734f3ca5fbd2ce5398ecafd570d698942d45423e09	7	7131	131	749	762	9	4	2024-03-27 11:55:20.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
764	\\x2e99db9eec86287e43b0c47391605d869420f7952a6cce10fc534acaf6462cfe	7	7136	136	750	763	4	4	2024-03-27 11:55:21.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
765	\\xa772872a9e8fcb1c72afd63d39b9af851589b10f2b0dd78c5056172b54a58ce3	7	7140	140	751	764	28	4	2024-03-27 11:55:22	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
766	\\x1a229f174784b3495616f6db875b03ffc24d104003ea294af681e0e15e093168	7	7153	153	752	765	32	4	2024-03-27 11:55:24.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
767	\\x228338af7ff4d8db29cd5aa389c0eb8d56a94b7703a57e249edec1ccd47ee378	7	7159	159	753	766	9	4	2024-03-27 11:55:25.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
768	\\x22068572439bd185f6e6cce24f496809f494c1c5410252399b901d5a1c7956b0	7	7171	171	754	767	29	4	2024-03-27 11:55:28.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
769	\\x7d464cbcceb0b547a1bcf9701a98d86178bfbda8f891f700d8626be3954d96a1	7	7172	172	755	768	32	4	2024-03-27 11:55:28.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
770	\\x0a4674e73a185ac70de61d45c9296d9752ee9117e07367efb4463275db4846c2	7	7175	175	756	769	28	4	2024-03-27 11:55:29	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
771	\\xbdc01d9709189fcd18debfe76de07f411e14b2ea2efb21f339a8ac08dce58190	7	7204	204	757	770	29	4	2024-03-27 11:55:34.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
772	\\xf06f421eaac7fa0b0f292b00a7d0522f325b4220844b454bee7f74f75c55e00d	7	7213	213	758	771	24	4	2024-03-27 11:55:36.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
773	\\xbbe0dff7081e69578edfc4259bd2adfaa1bcbe78022c5d1254b62d6d11fa03f0	7	7235	235	759	772	28	4	2024-03-27 11:55:41	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
774	\\x4fb7e3c1a2e135fa87a6efdb5e41894ea11b48c081478ab38db70e9d1fdd42ec	7	7246	246	760	773	4	4	2024-03-27 11:55:43.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
775	\\xb9cc6e2a0bbe85daa6b25453f6c97107c0fdf2e14781fd10259a1871340f4da7	7	7248	248	761	774	8	4	2024-03-27 11:55:43.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
776	\\xc0fea15f0dc1aa138c8ba70293550061a37345f70f37ede6e998044cd29300e4	7	7255	255	762	775	32	4	2024-03-27 11:55:45	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
777	\\x178f85a102363821c54f99e5ed2327a16a948ca23ebbc2372fd712372553129b	7	7261	261	763	776	29	4	2024-03-27 11:55:46.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
778	\\xc7773f7cf9bae4c510ca1f3338a65f76d89242bd7b9162325adfce432cf91ee9	7	7275	275	764	777	17	4	2024-03-27 11:55:49	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
779	\\x02b0b04f37145f6c2da6ddeaf2b44c5d84c6344d018f14f5ab65a5e6f19e979b	7	7290	290	765	778	3	4	2024-03-27 11:55:52	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
780	\\x4916661bc371142e1faf971c26ac318686afc004041607af5cceceaf982bff9c	7	7295	295	766	779	32	4	2024-03-27 11:55:53	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
781	\\x45f365ffcd25ade4da31601a181c53bf393be2d5f234382895eb13c31aeee925	7	7304	304	767	780	28	4	2024-03-27 11:55:54.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
782	\\x6b064213e3f0a3e988d00c1e20ecd92ffe80e748a7c09aacb7bdf66b4313c790	7	7325	325	768	781	28	4	2024-03-27 11:55:59	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
783	\\xbf9f175a9dfc1fd42738c8178a2ba4d1ccf18c19e1457c2769017fda263d3dd5	7	7332	332	769	782	8	4	2024-03-27 11:56:00.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
784	\\x0a059219d3162e1348ed621f514c62d45e9242bfaf6397d7b02309204d516b8e	7	7340	340	770	783	9	4	2024-03-27 11:56:02	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
785	\\xaac517f08df2ca820c399b96c5df47bf23d72f7c8cb21b8b389265fda7003780	7	7358	358	771	784	28	4	2024-03-27 11:56:05.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
786	\\x1e89b47b529dec093b64174ac281f48d6e6fc1304c4f5c9b4245357ebf8541dc	7	7363	363	772	785	4	4	2024-03-27 11:56:06.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
787	\\x6fa1cf238f56ba5d068cbbd72138729bb2d43e2f10dd427a1cb6457f4b39607d	7	7386	386	773	786	3	4	2024-03-27 11:56:11.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
788	\\x932a7462e865e10a15117263c06f054813916b19af6f54b186861133bde1a9c4	7	7387	387	774	787	4	4	2024-03-27 11:56:11.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
789	\\x429d371ae83f165b2845c1b307f44bec6484ba9cf20af76314acdc0b2c963585	7	7402	402	775	788	17	4	2024-03-27 11:56:14.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
790	\\x424726b5347d347d0ac09b2d3b26456bd1520b76b899fa3eb0db2aefd05b4ecb	7	7415	415	776	789	17	4	2024-03-27 11:56:17	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
791	\\xc0c154847b4402b320e7e3f712eb6876086d7a6ea0c853360fa1376e61fd7d4a	7	7418	418	777	790	4	4	2024-03-27 11:56:17.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
792	\\xf7a987556f7aab044e41a7f0a9e04540ad6ef1b1e5a94e9cad8bf2e35ca8b0ef	7	7421	421	778	791	24	4	2024-03-27 11:56:18.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
793	\\xb6e34003226ef810c695522180f1a309b3ea6310ea34a4667d3c79165ab6396a	7	7428	428	779	792	9	4	2024-03-27 11:56:19.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
794	\\xff080355d91993238365bafddd35e64f9905cd04db5433dfba85a2b3bf05975c	7	7433	433	780	793	3	4	2024-03-27 11:56:20.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
795	\\xaa913978d5fb3e624b2d78098074b964943ff82c5bdb4e6b924bdfc826bad7b9	7	7436	436	781	794	24	4	2024-03-27 11:56:21.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
796	\\xf3c45f2171ce76dce4f529e9274b6b872aafa6868cc096dd7ebed9c48457e03e	7	7471	471	782	795	9	4	2024-03-27 11:56:28.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
797	\\x791a841545df0a43e391ed3b43ec7e5576e90909bd28119ac9fbc60f3082b7bd	7	7477	477	783	796	4	4	2024-03-27 11:56:29.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
798	\\x0fa29971a49ee02b398aebac43151306d52ccd934f4d020b49332dd8f55e1020	7	7486	486	784	797	4	4	2024-03-27 11:56:31.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
799	\\x9365774ef7a54c98b40d1ddc5cf021fe66868ec548d00d0837c1b8b27bb00fcb	7	7490	490	785	798	32	4	2024-03-27 11:56:32	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
800	\\x97ff3ce99a3a0b8e6aaf338dfab2c9b461b863c16f8a3bba67256bcc34f7fe5f	7	7499	499	786	799	29	4	2024-03-27 11:56:33.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
801	\\xfc5f07b7f24c19fa5a6c86ba0298aa464794906f2e567e8191be406974b06225	7	7526	526	787	800	29	4	2024-03-27 11:56:39.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
802	\\x921e0c5bc6819b83ded65e547d48728c33fa67a9d3832320ff8cd1ab7d515ba3	7	7528	528	788	801	28	4	2024-03-27 11:56:39.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
803	\\x84f632bf89eb307801f396ec6dd836696ab9c12e5e8a81f3e9ef134ffcf05354	7	7539	539	789	802	3	4	2024-03-27 11:56:41.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
804	\\x7e865467a4a474ea08327bf3e94bc15dae169c79df7e618c31b36fa2fd224581	7	7577	577	790	803	28	4	2024-03-27 11:56:49.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
805	\\xd5b67d4bebcff79ab5c2a4271ac69bd2dd6c33a9ca9fc25932eb5e36607b0dc5	7	7603	603	791	804	8	4	2024-03-27 11:56:54.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
806	\\xabf6a58509f50b0610816774bca01253ede0630aa9de25a59e7866818cfe42e0	7	7627	627	792	805	4	4	2024-03-27 11:56:59.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
807	\\xbaf43f6d28366196fa25373cfe03377721b7a9955b1a2ba5e569435a46a4b541	7	7638	638	793	806	8	4	2024-03-27 11:57:01.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
808	\\x67ac00d8fe8a17b36e3abf7d6a4a5e21c31bc5ed0d331ff1a98d91ef7f64595c	7	7642	642	794	807	32	4	2024-03-27 11:57:02.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
809	\\xde23b17338ee85ee5f09795174e441c6dc71b2b1570051a8074246747ccc42a0	7	7669	669	795	808	32	4	2024-03-27 11:57:07.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
810	\\x6917ffd5b2f203a6a4c1efc453eba9fcc5264f45bf8636ea99fc786c8484acf0	7	7713	713	796	809	3	4	2024-03-27 11:57:16.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
811	\\x11137d5038966f26d8e1d8e0d5b9b63bcf686801865e7bb47ca3083c655c203c	7	7723	723	797	810	32	4	2024-03-27 11:57:18.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
812	\\x20613a0c2894d0c9b472f8c7ff6f57b9854986f139f864652e826ae63392ea64	7	7732	732	798	811	8	4	2024-03-27 11:57:20.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
813	\\x1aa5546ec897ff59933ab93411b5e62795d8191cc69f06eb577d813810ad5d8b	7	7734	734	799	812	9	4	2024-03-27 11:57:20.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
814	\\x73b00e5f3c129ebd877c2cd14307c018506aa8f4e0ee61345f64cb5020d8e186	7	7768	768	800	813	8	4	2024-03-27 11:57:27.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
815	\\xd93241050e67e7a802ae268c8b053d620b532bae71fa81fb3622510e75149b97	7	7782	782	801	814	24	4	2024-03-27 11:57:30.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
816	\\x746f8445eb5aea64a99020edee68b56544694550c174896e744c89f1f74d6fd0	7	7784	784	802	815	8	4	2024-03-27 11:57:30.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
817	\\x9a7d402b2343aa695513c23b17ddde44e3a52b6f8449076e040fe91188084abd	7	7790	790	803	816	9	4	2024-03-27 11:57:32	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
818	\\xf1e83973364aaaf69e22df4a76994f4c96e439e787ea8881e111e939a5225617	7	7797	797	804	817	4	4	2024-03-27 11:57:33.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
819	\\x907c9ac9915b359f435e84e82d4cd1b45755cfd51c5baaa99c76ef218597d535	7	7799	799	805	818	29	4	2024-03-27 11:57:33.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
820	\\x57eae0235adbeed92da0dbfcb06be97add79144e436d8d0082bdd6a2270ddde4	7	7808	808	806	819	32	4	2024-03-27 11:57:35.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
821	\\xfc606961bb3a6f5e07377047e52f97071b401eeda77ecd0ee716a7133ad3203f	7	7814	814	807	820	29	4	2024-03-27 11:57:36.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
822	\\x7e2c474924e46a30a037c65cff443caaa6feef54650b713223c2fb49d2980de5	7	7838	838	808	821	32	4	2024-03-27 11:57:41.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
823	\\xb8930a39c89b7f88012234d9d2ed787d9871d6f492626dce4889b27f8b49cb82	7	7843	843	809	822	32	4	2024-03-27 11:57:42.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
824	\\x9123c0d32e333d62e41aaac5604175b6487539edb0b40878f23c8f2ab1992bbc	7	7851	851	810	823	29	4	2024-03-27 11:57:44.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
825	\\x9696a62f9a353e21653b128612dfe4c0ddb8c8062cad67be58253ca57c00c41f	7	7863	863	811	824	8	4	2024-03-27 11:57:46.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
826	\\x08f6d542389bb12effd32e9555ad451dd55ec6af9dc37cc445e1b22919919a42	7	7876	876	812	825	9	4	2024-03-27 11:57:49.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
827	\\x8039553e5f92d8e15a52cb8ee85d75e9016ebd536148c2831155a4cdaeabbae3	7	7920	920	813	826	8	4	2024-03-27 11:57:58	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
828	\\x47fce013d23d8d3fac030d71b7921889673f154b1913b9dc9d9f6022a68cedbf	7	7959	959	814	827	3	4	2024-03-27 11:58:05.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
829	\\x81025cddf5563eab92d4b8885e4f6ac56a8c47eff8c16f9d1a11ef3ef6dd6eb1	7	7964	964	815	828	28	4	2024-03-27 11:58:06.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
830	\\xc8f0aafa4313465d0e406e81e6e7661d40b5c50cb97219a6487f47dc229ac46a	7	7965	965	816	829	24	4	2024-03-27 11:58:07	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
831	\\xabdf4554229b623730735faca993a476d4ba0fedade8beb9241782b4659e8af2	7	7980	980	817	830	29	4	2024-03-27 11:58:10	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
832	\\x4bce0095391c62f6841669056ecf53c6f7e7059705623e0e0525c9c2ee5473eb	7	7996	996	818	831	24	4	2024-03-27 11:58:13.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
833	\\x460337910bd42502726bda2a2d06400edc56f602b6a8a128ec686e72e995056b	8	8010	10	819	832	8	4	2024-03-27 11:58:16	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
834	\\x0a2e42700d99d5d69346adf5d73bf1f9cbf67a0ab4efa4e848125e5ea7a66c20	8	8018	18	820	833	32	4	2024-03-27 11:58:17.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
835	\\x7c501a99df8673a39711768867c642dd352fec2349d94dc6d5a06eb21724e7c9	8	8026	26	821	834	3	4	2024-03-27 11:58:19.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
836	\\x23edfd2942e7a63e3f20fde55501ff3e1b1284ea8c68a788601764907267fac5	8	8043	43	822	835	17	4	2024-03-27 11:58:22.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
837	\\xd556d4ad53fe28223784960559042c454d34fa0dd288bb5d20c15aaa94505e57	8	8053	53	823	836	28	4	2024-03-27 11:58:24.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
838	\\x5f34a4acf1840aa8e8d9a6cb97d2dfc17b0a635c1b45fb283494c70a24876735	8	8068	68	824	837	24	4	2024-03-27 11:58:27.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
839	\\x299d8b13ed30aba0c9a9d3ba88510f87f4643087da478b9d61d2d4835b7494c4	8	8071	71	825	838	8	4	2024-03-27 11:58:28.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
840	\\x71ad74e8f3604b67513cb881bc3d5b5d1028d3db4b6f22215952be2ef83648e9	8	8083	83	826	839	17	4	2024-03-27 11:58:30.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
841	\\x42ba62257805e72d780a156d813c4e4d80f9e54247ed88728237f338b22b01f0	8	8118	118	827	840	4	4	2024-03-27 11:58:37.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
842	\\x042ab37b3651d688d4cf55b4496ccf755d2f4effd0509e0a27a7625d27e033d1	8	8126	126	828	841	17	4	2024-03-27 11:58:39.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
843	\\xabc3bcafec313c39fc152401d394e9d1197fec1705eabeba9b0e13be49115d39	8	8132	132	829	842	4	4	2024-03-27 11:58:40.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
844	\\x409bfa7bf9e2f0f8e36b099da9294883749c1c77b599804953e95560c1f61035	8	8138	138	830	843	28	4	2024-03-27 11:58:41.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
845	\\xceeb7e4d8643721bed8ee3e903d4138fbd573835119e09769501bebf988ca905	8	8139	139	831	844	3	4	2024-03-27 11:58:41.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
846	\\x71a1095d3da0ffe0a560892234d0c6c519f76da043b6569ef1564549243e9e45	8	8165	165	832	845	29	4	2024-03-27 11:58:47	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
847	\\xbb0cae3c2f2061e2f5d2e86ac2fd21135cd85b25f506f3791fb8f6fa9f25db1c	8	8171	171	833	846	24	4	2024-03-27 11:58:48.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
848	\\xd8f622f64c04b82740c8c36d3269c33c6d1312ec8920bd65d713ff15552ff72e	8	8179	179	834	847	24	4	2024-03-27 11:58:49.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
849	\\x02e90523e731ee68d008c563f5ad0bc8bc597d89dde1eb0b5962e7967e1ab4eb	8	8187	187	835	848	28	4	2024-03-27 11:58:51.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
850	\\x77959626de9ce3d46f31f5259938b70f18ada404ad3e92da4e50b9e9f0764664	8	8189	189	836	849	17	4	2024-03-27 11:58:51.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
851	\\x52fe4f49021c5e7ff0fd836b6083d96f7a7a3817491c6c3695b290efdde5a708	8	8192	192	837	850	17	4	2024-03-27 11:58:52.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
852	\\x8914daa78ea9768ce23fb77240082a1c55c2e8663808090fa0bfb9b1a6969cf2	8	8197	197	838	851	3	4	2024-03-27 11:58:53.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
853	\\x7e47273ccae0c71540738021012777e3f4948d0ae9b0dd50a903e51bc4231a31	8	8216	216	839	852	28	4	2024-03-27 11:58:57.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
854	\\x17c49412b8b09665520f44df0299fc37eb8f16689a53918e8620ef34f79f078d	8	8221	221	840	853	32	4	2024-03-27 11:58:58.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
855	\\xa99775a40e377418ba82eb43ae0e3ea76edd9f8159c5961afe6ff4d11bc4fed4	8	8234	234	841	854	3	4	2024-03-27 11:59:00.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
856	\\xcb2910930a9d3ff7ec359711eaef3353ba4937006f9d384452a970b5daaa8ee3	8	8238	238	842	855	17	4	2024-03-27 11:59:01.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
857	\\xb6e0fa21031c6b9091592eb2078582f58bc42ceae7eed4010ccd11231c19b4bb	8	8241	241	843	856	8	4	2024-03-27 11:59:02.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
858	\\x66cb05199839affcddb78f19c9dd9a96ed97bb0f0ab0ea2fae0c13d57b3f7d78	8	8253	253	844	857	8	4	2024-03-27 11:59:04.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
859	\\x5f1bebb6143e84d3dcaa432a8bf66b2cd81aac914c63efd35d556645b77bb21d	8	8254	254	845	858	24	4	2024-03-27 11:59:04.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
860	\\x496a3bc10cbe4f3c3229da88b21cf285820eacd9c12fc4aa76bfe87617933e4a	8	8263	263	846	859	17	4	2024-03-27 11:59:06.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
861	\\x0ac3d95528256cffc6bbd363d0ad5f11efbb49cd6bafcf17b87199dcd084d9a5	8	8273	273	847	860	9	4	2024-03-27 11:59:08.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
862	\\x6e154750ccf864e74dbbd3a621cfde0dd8c9f9851d2bbca4a2c8960ad103b096	8	8293	293	848	861	8	4	2024-03-27 11:59:12.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
863	\\xc2a895ca2f6f3a405f1ecaeda6f309854e5cb812abbd82cd3b6ca45b78c46f8b	8	8294	294	849	862	29	4	2024-03-27 11:59:12.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
864	\\x0ab41255ea679f80d1db68802717674d3bb9f3ecfc7c95a1179f9918a6dac44a	8	8303	303	850	863	8	4	2024-03-27 11:59:14.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
865	\\x9eac74cb8c39b21551be13f33e5d2156d6f4c8d5b96ac8e11be9690345077572	8	8308	308	851	864	17	4	2024-03-27 11:59:15.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
866	\\x684239a5c6f6ffda0748a11cb24a15a56ffc905c5b5faa7bb14086eeb857a7d0	8	8314	314	852	865	28	4	2024-03-27 11:59:16.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
867	\\xe5ce05c9cbb1c3082d51cf20482d89373b976e39a84d94310049a313cc2aa529	8	8329	329	853	866	17	4	2024-03-27 11:59:19.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
868	\\x015ac07096f4dfb8c90bd02c104d6c7c2aa57d555a75d7484cfc652b521c5b7d	8	8335	335	854	867	3	4	2024-03-27 11:59:21	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
869	\\xd1d6669b83a7a63ae77edd94b1dcfb11dc7879718d1c20c2585be2d07413b8b4	8	8338	338	855	868	29	4	2024-03-27 11:59:21.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
870	\\x1113cf2833460004dfcd0f056dbac3a2ac765ed3b66b323b31fd86cb8ef311fc	8	8344	344	856	869	32	4	2024-03-27 11:59:22.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
871	\\x27fab60f8e18a98a7d0ccc146834e7912c9947eaeb3385ccc88bdee55f00375c	8	8357	357	857	870	9	4	2024-03-27 11:59:25.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
872	\\x823864151ad29a36141e5f3d8b58d8d0692a6147d4e888bdf4a4706e3280506a	8	8364	364	858	871	9	4	2024-03-27 11:59:26.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
873	\\xf6eb2690a9726053ae1484d850bd780b3142bf942f080874fe91d637370735e0	8	8365	365	859	872	32	4	2024-03-27 11:59:27	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
874	\\x2f1322a54936e3cad2d09e7f2ac0d57da873257f6daeeb9ee252bf1f8da00e3d	8	8366	366	860	873	4	4	2024-03-27 11:59:27.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
875	\\x508f19ebe6473ce752303dccfb1e83d891e0a679ec5615c80a5f939fbe304837	8	8372	372	861	874	17	4	2024-03-27 11:59:28.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
876	\\x050c2302d5f631c1fec4eafd1157f615047b3e4457abd7b773ccd8961126cfaa	8	8384	384	862	875	17	4	2024-03-27 11:59:30.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
877	\\x7232bd016934facd36760b7c8c2c65b2d27802f413b275ef1d2b6d9eb79e70c7	8	8395	395	863	876	17	4	2024-03-27 11:59:33	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
878	\\xaafd3d10a73ebfb09d67633d9fd9c170fb8edb300e485cf3f793897eaaab80bd	8	8401	401	864	877	3	4	2024-03-27 11:59:34.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
879	\\xb1b9b420f0cd3ab43203e895c11d0d11911c80fe9c5f4893d3f4d7f002df2b02	8	8413	413	865	878	4	4	2024-03-27 11:59:36.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
880	\\x42c0eb27c84c9c5b2b6c4980415e49052da664e7f9f10d86f033a3e0adb59bd0	8	8423	423	866	879	24	4	2024-03-27 11:59:38.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
881	\\x187e6f69ee0dd8075a2a0ec302428b63d64774b59a50a17b187f563ddfa93f6f	8	8432	432	867	880	9	4	2024-03-27 11:59:40.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
882	\\x971e517a4c58907d63709a105f55a77f12b391ed7793d3c9e1d2824dd00107a3	8	8437	437	868	881	8	4	2024-03-27 11:59:41.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
883	\\x716b51bf3b732c9111b8317a0de143b57c3f9626860d2656ea45aafe4bf96297	8	8448	448	869	882	9	4	2024-03-27 11:59:43.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
884	\\xc76066dce444733f2d7ade8291b74ced48be63b1cfcfa49591a57b1e7872673d	8	8455	455	870	883	24	4	2024-03-27 11:59:45	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
885	\\x9eb31e0626c3afc07f414a20f907dbb950de9e5abb299d0548294016e9a259ef	8	8492	492	871	884	29	4	2024-03-27 11:59:52.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
886	\\x84301e39014dd2ab96c7e09d3ad3ad0ad1209f9e483815668c5cc8dc557f778d	8	8497	497	872	885	3	4	2024-03-27 11:59:53.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
887	\\xf8899c7deca3171df10842177cfff9aa720a38ad7fccca3de485830fb5133f98	8	8526	526	873	886	4	4	2024-03-27 11:59:59.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
888	\\xe7383d95d2bdb2f49db65834189c909ae6624bc2434632ce241bd80aa918dab6	8	8539	539	874	887	28	4	2024-03-27 12:00:01.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
889	\\x8f3eedc25fcc0e4766fb9aa0dd84f7c1184dc69771f653a3acc346c722d06cf6	8	8552	552	875	888	29	4	2024-03-27 12:00:04.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
890	\\x4d3ef029fb6af9c97f63817af5cefd1060ab99817060553a37026fef83372ac6	8	8569	569	876	889	24	4	2024-03-27 12:00:07.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
891	\\x3a6ed94b3216f491d0ff1242247c8efd79e3d29ffcdaae3027d6492c67f8165b	8	8579	579	877	890	3	4	2024-03-27 12:00:09.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
892	\\x2523055f508c4c5d6db0c3251f9985bec88d16c4fc469012ed71332e8f52e0ae	8	8592	592	878	891	8	4	2024-03-27 12:00:12.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
893	\\x4394e4706bdabe01576f76685f0ded58c15e2ee204c0929a0941165c7938ef3a	8	8594	594	879	892	28	4	2024-03-27 12:00:12.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
894	\\x67f64581a0f677b8429d7f420da75b964ed80176dd2b3784f8506c119a4a2287	8	8595	595	880	893	28	4	2024-03-27 12:00:13	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
895	\\xd539633b5830505f85c7929fcac7856da75636e77a4e600a2c0da76f296edc6c	8	8596	596	881	894	32	4	2024-03-27 12:00:13.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
896	\\x6256a32184d8cd86cdd66c35e77fb8055551c19d3f6ee5e4f78ee18566a5c5af	8	8605	605	882	895	9	4	2024-03-27 12:00:15	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
897	\\x9a4a4114fcd1475ea6ef9cfb100d63edfc26872346b1ad37e4993ed6b277b661	8	8617	617	883	896	28	4	2024-03-27 12:00:17.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
898	\\xdb6cbf99cabac2f2e6fd7da74866881f77618544f1092620af9105eff9c7e9c4	8	8619	619	884	897	24	4	2024-03-27 12:00:17.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
899	\\x5e7c6885662c7341e2015a1393ca6119c610ee09addfc6a5ce074b1ce32266e2	8	8631	631	885	898	8	4	2024-03-27 12:00:20.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
900	\\xfc850213a77e7de91ec902fdf999e2c26c17c39dbc69d4561ca3c5c8e38c317a	8	8638	638	886	899	29	4	2024-03-27 12:00:21.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
901	\\x6af9974c1742b73158bdae47b5928724dd65686504683f3dd9a9ea7a0c1b5e53	8	8660	660	887	900	29	4	2024-03-27 12:00:26	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
902	\\x5416a53f098df206a2cec3026f83667caf6cbe42c50a1241656022a753874597	8	8665	665	888	901	9	4	2024-03-27 12:00:27	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
903	\\x46cb7638fb3e905a968e3a197ada4e221ffad2d032f6e24f8df3bc9a251a5946	8	8683	683	889	902	29	4	2024-03-27 12:00:30.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
904	\\x1e742a4c6732c5bb8e6ee4ffd02dccd0e0e7d9b23bf5c398a08a926a63af88fb	8	8700	700	890	903	24	4	2024-03-27 12:00:34	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
905	\\x91c5f0e7db9e980dff16aea4157ccbbecb7deeec2747b110179dae24436aa985	8	8702	702	891	904	4	4	2024-03-27 12:00:34.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
906	\\x3892bb65f59635f0da0201e1c2202bd617382b8e57495d3a9f54dd40b25fb378	8	8715	715	892	905	9	4	2024-03-27 12:00:37	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
907	\\x43729f7021ba25c3797f29f9b225951e76144b34676e14793d1624806c5ffd06	8	8740	740	893	906	17	4	2024-03-27 12:00:42	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
908	\\xafdffc93f3f818a37dcf859da69c9ad3521de44a2751b125920406e257ea09f5	8	8742	742	894	907	17	4	2024-03-27 12:00:42.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
909	\\x53e736c2f0d21e7e270cfad6b02fda7648255255f75893235157f00f03340bde	8	8743	743	895	908	8	4	2024-03-27 12:00:42.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
910	\\xbceec195fb977ea14b20ac61f3a70a50b9a483f76dfc920ea20929b82fc2c099	8	8748	748	896	909	24	4	2024-03-27 12:00:43.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
911	\\xad159a1102f7a76de3cd8191a7eed519c428bd4911d743d4a42e6607b195df7b	8	8757	757	897	910	29	4	2024-03-27 12:00:45.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
912	\\x55b97e9785cff21c8d04f450651f7d8abfbc7ec5c88670eae6e72aa3d51732c3	8	8762	762	898	911	17	4	2024-03-27 12:00:46.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
913	\\xa845e2d09585931712db7d00e90da928e682ff20860fd23e7a340cb299460eff	8	8771	771	899	912	17	4	2024-03-27 12:00:48.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
914	\\xa5834a8f45013d492955744fac6c78955eba7d1e5cae59cd4dd4714c5a177323	8	8779	779	900	913	24	4	2024-03-27 12:00:49.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
915	\\x0eea89ca366350d4c7c933d0ba0bade083262096cf5fbd3ae936c24a9e094850	8	8790	790	901	914	28	4	2024-03-27 12:00:52	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
916	\\x44d940a76537ab9e875cbfed2d60616ce6f2e4916c1c32f05e7c350814603250	8	8797	797	902	915	8	4	2024-03-27 12:00:53.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
917	\\x91475d027b4a5bda10824080271be118fab3c48a0115c5a74f91a0ac970d86f9	8	8806	806	903	916	17	4	2024-03-27 12:00:55.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
918	\\x07a0ceab0421ee037be1bf7575d93296ef6aba703d4917058bb0d872e483f7d9	8	8818	818	904	917	8	4	2024-03-27 12:00:57.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
919	\\x818f470d3951c3e86d93581e9859c8309948df45395ec21123da2a63d80c8b52	8	8826	826	905	918	8	4	2024-03-27 12:00:59.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
920	\\x9df479347b8ad1d62a1623e40a8a5f93ccf998bb706853dce83723ce71b4808a	8	8845	845	906	919	28	4	2024-03-27 12:01:03	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
921	\\x670e0f353a63355055d5da558c489a51337f009845228624dd9af89830ee68f3	8	8846	846	907	920	29	4	2024-03-27 12:01:03.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
922	\\x62a5c31c13ccc25fffa0cb59387899a9fc0c9db093796bb543485ee4e3fad43a	8	8869	869	908	921	8	4	2024-03-27 12:01:07.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
923	\\x71e1fdb8adb88124a7954edf07f0346981cfd2a9e854871324e904335747d492	8	8872	872	909	922	4	4	2024-03-27 12:01:08.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
924	\\x6a2668d46d023294b6891414f1ff435c5440412c45862649a10e7482d5cdc323	8	8895	895	910	923	29	4	2024-03-27 12:01:13	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
925	\\xdccd922fc0aac8195d9291b477bcabffb0e5702ea9539c084800743085ec1bc3	8	8897	897	911	924	32	4	2024-03-27 12:01:13.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
926	\\x870be5f6e196fb6c4a26a664429f61d796ce2f325f8b97712290a15e7f5d5cd9	8	8906	906	912	925	28	4	2024-03-27 12:01:15.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
927	\\xf9f0c6a7cd49af21063e21bd67f1f4cf2d93a8ed451d65a3c66ecd05f6c83aa8	8	8920	920	913	926	24	4	2024-03-27 12:01:18	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
928	\\x18a13dd6d253be577407a9514d01025986eede25abb0fc15ae1567a604d504be	8	8922	922	914	927	9	4	2024-03-27 12:01:18.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
929	\\x44979b8296aca8d6793b965af112fb44939e86c1f8918ec0bd97b5cd0aadc11a	8	8942	942	915	928	9	4	2024-03-27 12:01:22.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
930	\\x452dfa57501e3dbb36d3982af8ab1c06cdee629461c0f24d29eec9d1f5c37309	8	8980	980	916	929	3	4	2024-03-27 12:01:30	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
931	\\x2a91c3c0b1d95076978f1d44e9591e96a34a5aba36f06529803e82f16a6d6bba	8	8982	982	917	930	28	4	2024-03-27 12:01:30.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
932	\\x2ccb4fc1b168f6958d97931985bf197297c7a673497ce355711e88b1a34b8d73	9	9011	11	918	931	8	4	2024-03-27 12:01:36.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
933	\\x95af9906cb7fd3e993910742c8946e087a63d64aae66180666e6594d845c7bae	9	9015	15	919	932	3	433	2024-03-27 12:01:37	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
934	\\x74e927c649cf14e1114b0e39645840d3d68c053dacf9bf500baef3a3b09d7035	9	9025	25	920	933	4	4	2024-03-27 12:01:39	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
935	\\x1f7d89c08302dfe856e9d95b0d4f9801bc3708f0d95b5649a338216c8368f049	9	9026	26	921	934	9	4	2024-03-27 12:01:39.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
936	\\xe9ac8aa743e883f7d0dcf6fe8915b8940138130aecb7cd7d247870c6e8fa068e	9	9027	27	922	935	24	4	2024-03-27 12:01:39.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
937	\\xe741b40f2bd7022edb9c9b6df1f5c4a182793624c8532de7fdc397a3d51bc04d	9	9033	33	923	936	24	4	2024-03-27 12:01:40.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
938	\\x37fd8cc420f9136c9ea5e60bcb6fbcb605fd9cf196823f4cd1621bf5805e39c2	9	9038	38	924	937	4	6372	2024-03-27 12:01:41.6	1	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
939	\\x0bd48054085450a1acea38b389e151d92f1fd9647e016c36eeae86e9d4acc1f5	9	9045	45	925	938	17	4	2024-03-27 12:01:43	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
940	\\xb8b9b3603e9db056d784d9331ca2c6d0d90f6236cd3d041d2e1ba6f1ad9a86ae	9	9049	49	926	939	3	4	2024-03-27 12:01:43.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
941	\\x4a7dcc40bb2b449b4256e9c9c133cae56ccc5a925c0bbc6fcbbaeb144cc32373	9	9065	65	927	940	29	4	2024-03-27 12:01:47	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
942	\\x0327dde7164db4b38f5daae3ded8bfe228dc1124182d9f365a8d6dc1c57d1116	9	9070	70	928	941	17	4	2024-03-27 12:01:48	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
943	\\xa8c2c0a7927e952a4614e6431de89093063e7ea269d78351e91967451d3a04a2	9	9077	77	929	942	4	4	2024-03-27 12:01:49.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
944	\\xc16625c925e74f30e492700b8052467545b2f067d15f99f1df6e6878dcc93df9	9	9081	81	930	943	17	4	2024-03-27 12:01:50.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
945	\\x4725bee21cba8d65d138f934149861e416dd3a82612d8f3a6a1b02ba65215102	9	9098	98	931	944	29	4	2024-03-27 12:01:53.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
946	\\x1eb35ff1a41bd03c72048cd88363815af634c4ad499ffa5eb0dbd586d38a6d2e	9	9109	109	932	945	28	4	2024-03-27 12:01:55.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
947	\\xb535a83c759e851097b56fc7c797b46cf2d6aa5603ff85d7ad4eaabf1e903f8d	9	9124	124	933	946	17	4	2024-03-27 12:01:58.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
948	\\xe56c4007ae3ecf246087290b98dbfc9a836cee9a89d592c09bba56c353234a93	9	9129	129	934	947	4	4	2024-03-27 12:01:59.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
949	\\xc234d2a611175f09a66614924a15e9106d46cdcc5571518f2aa6053a1ca2945d	9	9133	133	935	948	17	4	2024-03-27 12:02:00.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
950	\\x8ac71910827efcb40da439b3297ce48ba3cd7923bc316cb9307eb539a5cc770a	9	9139	139	936	949	24	4	2024-03-27 12:02:01.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
951	\\x3509a14bfcacb8591831b700cf3d8e552a727c62e3f77a1bf5e1cce924924cdf	9	9153	153	937	950	17	4	2024-03-27 12:02:04.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
952	\\x5f25d677f9ac1b2be3926fd5a07b5a5b1b16277c66eb10b1a7d689768d04871d	9	9164	164	938	951	28	4	2024-03-27 12:02:06.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
953	\\x24fbcdec0020412e0e4786995a7447dc97914a24bb3ecd742d0038ca4647062f	9	9182	182	939	952	17	4	2024-03-27 12:02:10.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
954	\\x7f1612067f89b42b353e03a1a40982451e56e76a97351f9fd6fb4a18fce72e19	9	9189	189	940	953	28	4	2024-03-27 12:02:11.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
955	\\x05868a736f80ccc7909f5da09a7167f84c10a3c28905a01aadc57a022287e426	9	9192	192	941	954	8	4	2024-03-27 12:02:12.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
956	\\x92bb2c7083e7f122a2f96605ddc50adb679de74d5b702c028771f69151b5201d	9	9203	203	942	955	29	4	2024-03-27 12:02:14.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
957	\\x4d970868edd25dcec087b7050c87a798f5ffed9f33be9968128ed4b8956bdfda	9	9219	219	943	956	8	4	2024-03-27 12:02:17.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
958	\\x0c62ebde5dda7f1711f6df58c16f7e98e889ccd77adf4d319a772b0b30a00998	9	9264	264	944	957	17	4	2024-03-27 12:02:26.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
959	\\x7493ad49d3b5dda9dc6ce38a8f8028408708dcfc961c63be2982937c222fc2c7	9	9269	269	945	958	9	4	2024-03-27 12:02:27.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
960	\\xb466cb2b52e930028e41045e1197210aa19e467b77867f4769d75ca4aa18e287	9	9277	277	946	959	9	4	2024-03-27 12:02:29.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
961	\\xc00c2c18cc73dcc4dfefc35492646ce7a5087bcc9e9837daa73684180f155fa9	9	9287	287	947	960	8	4	2024-03-27 12:02:31.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
962	\\x2ed7d398574fa0e51871730833c3645b0e0217bb20d7d14cc52630c751b1f876	9	9289	289	948	961	28	4	2024-03-27 12:02:31.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
963	\\x111474aa08e95c242c9cc89b5f8d6559f0cfc551ad856d023b2b433096791187	9	9290	290	949	962	9	4	2024-03-27 12:02:32	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
964	\\x6b6879fa5991d9864990eefc48588195db73c6ceb1363d13d8e7de5c755d10b5	9	9291	291	950	963	4	4	2024-03-27 12:02:32.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
965	\\xbf27bdb3c00f8551735afd6cc7a9595c4c892de008935f1ce0decd5f9c4eb981	9	9295	295	951	964	29	4	2024-03-27 12:02:33	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
966	\\xf7fe781ef1a7b6a3669dbd3e0a48abe1e1718229000f941d22d24307ced0f732	9	9306	306	952	965	3	4	2024-03-27 12:02:35.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
967	\\x9d566c650244647575fb53c170ff1467ea547736fcc43fb012237ec927f7dd5b	9	9308	308	953	966	8	4	2024-03-27 12:02:35.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
968	\\x6828f1f51c4634fc00a95d48b494b14103b54d4d5f538374adc376aedd9de7af	9	9309	309	954	967	8	4	2024-03-27 12:02:35.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
969	\\x872ac69367449d96cbd3e4245c1314289866dc96d050700e4778fa4776efa356	9	9310	310	955	968	17	4	2024-03-27 12:02:36	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
970	\\x348d402d47b938a899bbbc3eacdb2151a969b5d6facce5dc68dd503d13a09fac	9	9315	315	956	969	17	4	2024-03-27 12:02:37	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
971	\\xf3e208572f2a04fa7922ec8637215894ddf0b683da03eb670c2f7e4a8b8c21a6	9	9324	324	957	970	29	4	2024-03-27 12:02:38.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
972	\\xab219b9b4b973122e66c85c87d3881d0880fc032fce8c02c37c98b9c8149ec83	9	9325	325	958	971	4	4	2024-03-27 12:02:39	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
973	\\x7ca694cb938b2b9a9a9209e41ac3dd57cec1629b72f6ab456d961d944f206af4	9	9330	330	959	972	29	4	2024-03-27 12:02:40	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
974	\\x75adce21f14ab27cf948e8abfe2f088918b0f2341da6c93c9fa450878dd43f23	9	9331	331	960	973	4	4	2024-03-27 12:02:40.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
975	\\x955976d7bb286eb7dfd73d43fb1602bb31d0ef5040f788411ee4023c718bd1b2	9	9338	338	961	974	29	4	2024-03-27 12:02:41.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
976	\\x38d46a4e9061d66f456996a58c55226c62014d507d95bac1f97695bde104b3e7	9	9345	345	962	975	3	4	2024-03-27 12:02:43	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
978	\\x1f2b83463b9ee155242cacd62fe75cae92e69bfe4248bf8363670ebaef1d599a	9	9348	348	963	976	29	4	2024-03-27 12:02:43.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
979	\\x5be9f1955f20b0b733d9c68ed9520a55fd9922146606cb5a08153f1a137be0a1	9	9356	356	964	978	4	4	2024-03-27 12:02:45.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
980	\\x414712ee933ef08470e26a16138839de0ba345cdb33b023799e598f691109548	9	9364	364	965	979	32	4	2024-03-27 12:02:46.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
981	\\x7130c0b9f13a57b7ac3f38b83942ac72c6cd1ce7cb7184a1abe52ac7f17cbb7d	9	9365	365	966	980	24	4	2024-03-27 12:02:47	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
982	\\xc488975e886f451e8f19394a4a8a8d093ff095dc558c6d6ac41b4639f01a9fc1	9	9372	372	967	981	29	4	2024-03-27 12:02:48.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
983	\\xb732dc4dcce22bcd52fadddc762a5f8f7250e54fe9501f5b86ff6138be4c8446	9	9374	374	968	982	8	4	2024-03-27 12:02:48.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
985	\\xb80f2db0c959cc73870e4d17d2d68a696530d19743765bfb380d0d826cccc932	9	9397	397	969	983	32	4	2024-03-27 12:02:53.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
986	\\x68485b22e8cecc3ca9fa8d27b0281d956c2f13059c885841055b8ef8768b995c	9	9403	403	970	985	17	4	2024-03-27 12:02:54.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
987	\\x225138c6f858d0f7ef7f5d7e0a1af7bd921038aa60cf88c6cd16f9c76e66fce3	9	9405	405	971	986	4	4	2024-03-27 12:02:55	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
988	\\x5a0789325b1b0f03460f1458912bd4b236dc63d9ee9820356716a2093e4427e8	9	9406	406	972	987	3	4	2024-03-27 12:02:55.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
989	\\x1b943189aebf8c257611ab34d325cf359b89c52dfcfc4e33fb819fb6a7add4f3	9	9409	409	973	988	3	4	2024-03-27 12:02:55.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
990	\\x2619fcbd1bc54ec5ac89e06cd814e2200035cb0afa1c99fb304d3a2c52d04fb5	9	9410	410	974	989	32	4	2024-03-27 12:02:56	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
991	\\x6ad50e8b18e3c26a9a44eb9eeaec94fee218409ae16d47c5ea660386516d5a27	9	9428	428	975	990	3	4	2024-03-27 12:02:59.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
992	\\xcd461033a7c6a79e7d2fbbafb7e991f3eeee64282a643bdf7f90fa993faf4879	9	9431	431	976	991	8	4	2024-03-27 12:03:00.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
993	\\x852ac392aa9afc2880e4458b3bf8aec195b7246bc9c318e0321625fcbf145b5c	9	9440	440	977	992	32	4	2024-03-27 12:03:02	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
994	\\xc0d03944a2101653468fd297ba93c3183f1d4e4520fcd657591d43c6d6f5c211	9	9451	451	978	993	28	4	2024-03-27 12:03:04.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
995	\\x7977c643c2a6fe38a7cee07eb63e51d15013291f6dd6c84ec2c15d6e2e306c07	9	9485	485	979	994	24	4	2024-03-27 12:03:11	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
996	\\xdb051041ba4d106f37ac85d0d0b8e51c6e3b93b6c9299a3767dbc6a04732d258	9	9504	504	980	995	9	4	2024-03-27 12:03:14.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
997	\\xc6683b2daaa7ef9522038b89cf0663835a38eeddb4db9eb466ee9c241511b62d	9	9524	524	981	996	24	4	2024-03-27 12:03:18.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
998	\\xfe2e6c41239ad4038f78254dceb81d735df61bd85b91b60966653ab12eed0272	9	9530	530	982	997	8	4	2024-03-27 12:03:20	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
999	\\x14905b12d0e4dbf4a6d1b6d905fe82da6640e56bda38837595721f7205e691c6	9	9533	533	983	998	24	4	2024-03-27 12:03:20.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1000	\\x66539c935dac4399946fa7571ed135704bca42a4a985a8803de6c79ab4f574c6	9	9536	536	984	999	28	4	2024-03-27 12:03:21.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1001	\\x1047cb241ccebe3643857ec4bd9cc373fa551668f4df8267ed61f421a9cc5bf5	9	9538	538	985	1000	29	4	2024-03-27 12:03:21.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1002	\\x24d03e11c8d155878ca32be8a2c9d5006d111c99b70df8e29b4596cb21a71bce	9	9539	539	986	1001	28	4	2024-03-27 12:03:21.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1003	\\x00db30ee9d76cf1926064d74101015f797863f38f27191c11d207baa06736001	9	9542	542	987	1002	32	4	2024-03-27 12:03:22.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1004	\\x958d4c4088c5388cf98e4474bf59d7e0c01703d4c8eee3e4713e728881eeadcf	9	9543	543	988	1003	32	4	2024-03-27 12:03:22.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1005	\\x08cf6d5a2d04b1ff1481dab3eb7c67426711bee35110b97ef82194d67f0b5628	9	9567	567	989	1004	4	4	2024-03-27 12:03:27.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1006	\\x174e515cb153ef7f9a41ee287176adf1ba8bac58dadf7bd8c52ae4861529eb3e	9	9569	569	990	1005	4	4	2024-03-27 12:03:27.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1007	\\xcb5a54f8abcfc5cb18123af0c1d3ad0121fc0879e08237c28428a7d6bb9a0a08	9	9575	575	991	1006	9	4	2024-03-27 12:03:29	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1008	\\xf32ae319b0a80f7dc898e80cbdbd316fccf1fe1496300a30a0e81bbb68ba52e7	9	9592	592	992	1007	9	4	2024-03-27 12:03:32.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1009	\\x62abf7813d0ba7c83ef0a6ec9dad0644903a1b82da72dab56f0dac642bf2e3a9	9	9597	597	993	1008	9	4	2024-03-27 12:03:33.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1010	\\xb7de434577cfcd73d63a65081cbea7aaba93335366c163b8bf31cf88902ba61b	9	9634	634	994	1009	9	4	2024-03-27 12:03:40.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1011	\\xcd14e706ced3064584ac1d98fc423a264d8ccab8473265cac3f7dc7ec09d0a45	9	9639	639	995	1010	3	4	2024-03-27 12:03:41.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1012	\\xf82287c8c349d9d2b97a564138fd0b96b37121b7b37cc4ffd3da9c64d067ec5b	9	9645	645	996	1011	17	4	2024-03-27 12:03:43	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1013	\\xaa5f5336c0a5d37ac70346ca18c79d4916af0405cc6fa0fbefc83d8fb81458c4	9	9650	650	997	1012	29	4	2024-03-27 12:03:44	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1014	\\x1e6bdab291ad2a6af1c42b9fbc4d3dda3a1dfc09babe3a8ee45fa01a8695cde7	9	9653	653	998	1013	29	4	2024-03-27 12:03:44.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1015	\\x8dbc38d82a27e6472ecd7859160ec248ae5cef3ba0419e35ee503d3374e687f2	9	9654	654	999	1014	8	4	2024-03-27 12:03:44.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1016	\\x18d5e93ad93932a10bcde5b499a39d8449822db4d9eac152efbd8d7ca3e613e1	9	9674	674	1000	1015	9	4	2024-03-27 12:03:48.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1017	\\x035d3be0ef128dbaadfe92b9c0de2345cc5a80a68e46a75be0cf6452771d9783	9	9712	712	1001	1016	28	4	2024-03-27 12:03:56.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1019	\\x417cafe621e3bf02fcb72020978c2eebb096b18fa4e07dce11f2fe2cd2cb37d6	9	9713	713	1002	1017	17	4	2024-03-27 12:03:56.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1020	\\xc00dd07b484f502403a1e251482929f31952c9b4bf601dc48d782a4ac1e3d96c	9	9724	724	1003	1019	17	4	2024-03-27 12:03:58.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1021	\\xafb2edfbe4dcfb78a1ec06f63111c1e3238b735907cb3cc0743d87971305f5ce	9	9728	728	1004	1020	28	4	2024-03-27 12:03:59.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1022	\\xe1f821876a06950dd428a714f29691b4594f6fbb873c2fa7f0636898cd8caf1e	9	9730	730	1005	1021	24	4	2024-03-27 12:04:00	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1023	\\x9aaa2526294c2c5175d48124ec59c562793e13afcbfa6aa9f1961b8b58e451a3	9	9743	743	1006	1022	3	4	2024-03-27 12:04:02.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1024	\\xb298464c373ebc4e49a9010d8df40bbb028f9af02b166c89f396a6ff1c660f92	9	9751	751	1007	1023	3	4	2024-03-27 12:04:04.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1025	\\x68515970c1130b00998660f0197bb10c89e77d748a15c31ac6cf650b1b8c61e6	9	9756	756	1008	1024	29	4	2024-03-27 12:04:05.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1026	\\x4f1aac3d9d1ba2e5a51ca5608bcf800be4c97bd480af953a9a4dba527fe83cca	9	9760	760	1009	1025	28	4	2024-03-27 12:04:06	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1027	\\x2f61cbf1685cba621d79b601416aca7138230e2a5c6db1515ff5cad130aedd69	9	9778	778	1010	1026	29	4	2024-03-27 12:04:09.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1028	\\xb68b211739a4466b28d2d54914f5622467c2dee136d2227eb14100d919a50789	9	9788	788	1011	1027	9	4	2024-03-27 12:04:11.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1029	\\xa563208c2cd9293a2f17a1573c4a93d1db2b3c65e8511f268c7af44ff33e2ff2	9	9812	812	1012	1028	4	4	2024-03-27 12:04:16.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1030	\\x4cd0b0c516e37723900bd87ba2543ea97301b8c3f525649e93d92c52ef2ffc70	9	9824	824	1013	1029	9	4	2024-03-27 12:04:18.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1031	\\xc995c999eca6b66f1260008dd690d5822117fd8a760291458203b6abab5c6642	9	9843	843	1014	1030	9	4	2024-03-27 12:04:22.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1032	\\xd9125a4ce49970f77c4527f54600372ae58f30fa349dd92e943b1e0469636dd0	9	9868	868	1015	1031	17	4	2024-03-27 12:04:27.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1033	\\x4c0cd2c22d62211a0c9d7cc22c2d37249b2b129b4d715b6a2b9ad211f5276a2f	9	9882	882	1016	1032	3	4	2024-03-27 12:04:30.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1034	\\xeb7e530b934f43227450dec9a7dfa1dc8b889b282fc6195ce0bac2e6546c333b	9	9886	886	1017	1033	32	4	2024-03-27 12:04:31.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1035	\\x005e5924184b6ce0cc4ab56fb97d81e89de679e7ad96cc1ff70637bc43493710	9	9900	900	1018	1034	3	4	2024-03-27 12:04:34	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1036	\\x41f5a64f0b83cd13c1dbc1c2655aa15346ee93107ef4e3d4e69f49fd9c5e21bc	9	9901	901	1019	1035	4	4	2024-03-27 12:04:34.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1037	\\x65e383b4f26caf6e7c5ad6a1f6cf0a7a2fb21e631c081e7b973ac153fb10a13c	9	9903	903	1020	1036	3	4	2024-03-27 12:04:34.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1038	\\xcf88a823b467ebe9f01efcd4ed06559d4b436f8a1c7b6edd35af6b6bae193343	9	9905	905	1021	1037	28	4	2024-03-27 12:04:35	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1039	\\x8d68f4602753b89c71ea2c95dcb9d3b59f4833636e7dcaec297ea62e41960ae2	9	9909	909	1022	1038	24	4	2024-03-27 12:04:35.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1040	\\x4ea7153bf64c1063771cf9942b4598d034ef92a94a5c52221b7122b331d3ae67	9	9910	910	1023	1039	3	4	2024-03-27 12:04:36	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1041	\\xfb0e95c376ebdfb42ac9e7b72616cfcdbe83cb2fce2fcd07851cb98698bb57c4	9	9919	919	1024	1040	32	4	2024-03-27 12:04:37.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1042	\\xeae2af7000c65f68a124c781bdbd101bb558c8539e84a0121fa26a8e62000415	9	9972	972	1025	1041	32	4	2024-03-27 12:04:48.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1043	\\xebb13f4fd7648fa93a0653f5f59e37d2fddae454268124450383547c3c6505a8	10	10015	15	1026	1042	24	4	2024-03-27 12:04:57	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1044	\\xda1da10d1a8fc59dda06526548b09f22ae9ee5544a5d4fa72c098f668d1814b5	10	10037	37	1027	1043	29	4	2024-03-27 12:05:01.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1045	\\xdf3923e57728f22c81c10fdbfa6a2ff4269f6867b3d89872e71ee810c41d577f	10	10041	41	1028	1044	32	4	2024-03-27 12:05:02.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1046	\\xf5f7dcc493e5fe71c7dec80baa168a3db28d233a1fc3df72010573fb65fc93f3	10	10045	45	1029	1045	28	4	2024-03-27 12:05:03	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1047	\\x56fdf85444facd83ec84f3c27822013794e98657fb47c5380628abfa125c544b	10	10054	54	1030	1046	32	4	2024-03-27 12:05:04.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1048	\\x778148b96d3c3288c1af4d5374dcf77430cc241dc915d5fc790e93f80905a435	10	10061	61	1031	1047	24	4	2024-03-27 12:05:06.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1049	\\x7b410eeaecb44ad9c46021f7453bcfc6334b397ceaac90592a5cbac80e6004ab	10	10065	65	1032	1048	4	4	2024-03-27 12:05:07	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1050	\\x6a45f109a3703b7174639b8a68833fd1f6b8f939427a9d0384b1a1e8a1dd16a5	10	10075	75	1033	1049	4	4	2024-03-27 12:05:09	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1051	\\x841b6745e7a09e066dbc713d3675ca5bded1bbc244cb72dd6ba877a99714b189	10	10084	84	1034	1050	3	4	2024-03-27 12:05:10.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1052	\\xfadd5069f48d3ca3277f17cef721220ca9caa082d2f0217160cfe4f98b0267c5	10	10098	98	1035	1051	28	4	2024-03-27 12:05:13.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1053	\\x87bd2c89a546ef8eab4992a6d80a056bac3b4ae826aef3c63cba6dc40b8c7ad4	10	10101	101	1036	1052	28	4	2024-03-27 12:05:14.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1054	\\x2d985be6a5b5b225bc521b31bcbf849c5d8e1847425d8c0e7de85235a5991057	10	10123	123	1037	1053	9	4	2024-03-27 12:05:18.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1055	\\x8696587f191721c1a59a65649f03839c1c645e1b90ffd455f37cc3ca91262e17	10	10127	127	1038	1054	28	4	2024-03-27 12:05:19.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1056	\\x7f5829b7eb750632a2881f75d396558c168e7f533a70e58dd6adabe8fae6aa92	10	10135	135	1039	1055	29	4	2024-03-27 12:05:21	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1057	\\x30979ae52e697dc970b0fece49dd859e503afdabbec53a37a1514cabd3e25411	10	10159	159	1040	1056	8	4	2024-03-27 12:05:25.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1058	\\x79f547eeae1d0785aaf15f89bf1ff141fb53be4a24299b8de8233942314d1042	10	10170	170	1041	1057	17	4	2024-03-27 12:05:28	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1059	\\x7134da25d8e9ef07a2bbbdbdeb1ea12ce3806525af30c7db328e1a874a6adbab	10	10192	192	1042	1058	9	4	2024-03-27 12:05:32.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1060	\\x405830cfae286fcc1b33766c976b10e68a727f28ea3093b2e15e4a4bf9eb4ac0	10	10206	206	1043	1059	24	4	2024-03-27 12:05:35.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1061	\\xcba3772e5b2fa3c45a296ca788210edd889b67732d3874a9aeeaafab19fc7a54	10	10210	210	1044	1060	32	4	2024-03-27 12:05:36	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1062	\\xd37b5ec6f9301f67b60ced6758c6d37a01284e62a584661ccfe8367dc16f5a07	10	10214	214	1045	1061	29	4	2024-03-27 12:05:36.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1063	\\x293ce44d68a29f10186a9f374d4efc36e7512b8b268ff938e2978cd6c5e5601d	10	10221	221	1046	1062	9	4	2024-03-27 12:05:38.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1064	\\xe28f2ba38a290c6430efd78e9926ebd63d1cbeab7aa39ee042d948c511ab6f55	10	10247	247	1047	1063	9	4	2024-03-27 12:05:43.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1065	\\xcda8fc3fda7e57e47c410ee2b0abf8f13a4869c2e0b8bc13f0fb5177bc07440e	10	10248	248	1048	1064	3	4	2024-03-27 12:05:43.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1066	\\x2c17afc85b30dd6f35123b2e8fa45d4d469fa551b5b891fb2962e3291a582679	10	10258	258	1049	1065	3	4	2024-03-27 12:05:45.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1067	\\x6ffa868c8341c505029f8838237804648ba1305964765cab2a0db444670ab88b	10	10266	266	1050	1066	28	4	2024-03-27 12:05:47.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1068	\\xaabee9bdc2491292803d99e5af6812c3f0eccfa8777781066a16bd29a8e200fc	10	10280	280	1051	1067	8	4	2024-03-27 12:05:50	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1069	\\xbc1473ab217b27e377861da80940b28263a12a9b93d5194514b5ba68c31f6866	10	10281	281	1052	1068	9	4	2024-03-27 12:05:50.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1070	\\xba78054983defff6260f9ea59dccab3d75a2a30a7d0461e314bf6251ab10ba0e	10	10311	311	1053	1069	17	4	2024-03-27 12:05:56.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1071	\\x1ad221e05cd577163753d7486e1756f7548e6bda1f6ea5a5ca59d3c16e0ad4dc	10	10312	312	1054	1070	4	4	2024-03-27 12:05:56.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1072	\\xf6a034140494f50583340328cdccbd10c1bb6ccf7cd22151e76b5f5ef54bd34d	10	10323	323	1055	1071	4	4	2024-03-27 12:05:58.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1073	\\xff3231424761c1f868fbfeb861ea8b35d5b3816c4d296758b0057ff77c6b3b07	10	10324	324	1056	1072	8	4	2024-03-27 12:05:58.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1074	\\xe9f24b268de9ddfb91ee1f2f7058ab90b22fe7017358ecfd43f769435e990601	10	10330	330	1057	1073	29	4	2024-03-27 12:06:00	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1075	\\xea81f9b6a55bd032072e4d518aa9af5bb1c2fa8e41944c8829f4988cc9e19a2b	10	10335	335	1058	1074	3	4	2024-03-27 12:06:01	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1076	\\x876b0a4dc85c4e414601aeaa43896a6593f02c72739892252ed8fd0cf8731fc9	10	10341	341	1059	1075	17	4	2024-03-27 12:06:02.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1077	\\x2e0ec106f34c83f18c2a2d3afa887a7aefd4e7df48955df224bd69deabe371a5	10	10342	342	1060	1076	17	4	2024-03-27 12:06:02.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1078	\\x8210bf3adeb28b8b3ddadb7c35de93515c9ac5d14ecad1dc6e74ad69def3898f	10	10349	349	1061	1077	8	4	2024-03-27 12:06:03.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1079	\\x6be68d4a1d7adc36acb991d9ab56cf63f8db8c96d126426f7d086f2769220d58	10	10356	356	1062	1078	8	4	2024-03-27 12:06:05.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1080	\\xe24e5d10f244ba55507443cb96442f598eca308fcc9f7959d3398dbe665c57c4	10	10413	413	1063	1079	32	4	2024-03-27 12:06:16.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1081	\\xe4ea3e0f1d76369aea3b76255f039940c8128f814a277b4305a9fe21fefecc66	10	10416	416	1064	1080	4	4	2024-03-27 12:06:17.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1082	\\x296d606825e0ebc9d279f47785e5f373a90122a42eccb82efd387e428187cd2a	10	10438	438	1065	1081	9	4	2024-03-27 12:06:21.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1083	\\x463c02df15d6a6c6372c987fae18dde6831082f122cfb44a67098490c8044aeb	10	10440	440	1066	1082	32	4	2024-03-27 12:06:22	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1084	\\xd83708d54907c94ee3ee6e499e3a94d248163a914acb911a901022d0e25c8f22	10	10444	444	1067	1083	4	4	2024-03-27 12:06:22.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1085	\\x21b4c2f6fbfc68d2cf28d562dc7f9bb3bd4efbad9090cd31efcc2f8fdc63ce8e	10	10458	458	1068	1084	29	4	2024-03-27 12:06:25.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1086	\\xea44cd3e458f8bd8fce19b2c104e51715881df2c15f43fb92951d8a161418f8a	10	10460	460	1069	1085	24	4	2024-03-27 12:06:26	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1087	\\x349d78fd1f864e7ff084a3c87accc0a325c825848bb2706001283cc770ef2375	10	10463	463	1070	1086	8	4	2024-03-27 12:06:26.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1088	\\xcfd69a59acb201d7392b9defda60cf3e91a133bd02584e457fbf6b3eef832e57	10	10464	464	1071	1087	32	4	2024-03-27 12:06:26.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1089	\\xaff32804757e4ea8e09557d9b3dc8a1c9988229f53542dd14e80e5270e8376b6	10	10473	473	1072	1088	28	4	2024-03-27 12:06:28.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1090	\\x3a31d15104709970850828e6ebc11e0f4283ab59c9aeda96dad4c2ffbd823ad3	10	10483	483	1073	1089	28	4	2024-03-27 12:06:30.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1091	\\x940fa166fa4f3b77d200abfd23d347ab46ba5915136e2cf3bb8f2f7caf64eb69	10	10489	489	1074	1090	28	4	2024-03-27 12:06:31.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1092	\\x85cf848cb0d3cf2a2723f3523f19cd1a84f6e2bf3ad30c6a10bb78571695ea57	10	10499	499	1075	1091	17	4	2024-03-27 12:06:33.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1093	\\xab72a53f5f10a1de9dcfb1d2659e6880e93058d45b1f13cca09dea7769523457	10	10508	508	1076	1092	29	4	2024-03-27 12:06:35.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1094	\\x90671f225bfb8f639f9e8d98f51dcbdef8f8938346a43eedf03b7a942a4af670	10	10529	529	1077	1093	29	4	2024-03-27 12:06:39.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1095	\\x0ea71f1ef03c8b3bbd9cebc6e4c22bd2a558ae8a0d82c427afed6a199de3a5d7	10	10570	570	1078	1094	29	4	2024-03-27 12:06:48	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1096	\\x38727ce7d45655f8e8e50be1b2312d17a61686e46db954268c2f021ef727d12c	10	10571	571	1079	1095	28	4	2024-03-27 12:06:48.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1097	\\x4bf39b67651193a31fdb58a825b31c772ce53d161ff0edabccae6e5dcf0d6f7c	10	10578	578	1080	1096	32	4	2024-03-27 12:06:49.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1098	\\x29c2d22ae9b1c9a800fba00fe2da12d6072210497d5f6548598c6591adf33930	10	10590	590	1081	1097	8	4	2024-03-27 12:06:52	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1099	\\x93a3a08a5d5ab640352ad268b6a102ee7d5a23e06b46db6872613c51661e92b9	10	10613	613	1082	1098	17	4	2024-03-27 12:06:56.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1100	\\xdedd9b5573aaf41df2553738ce524570547f5f880f758ff355006237af564a14	10	10621	621	1083	1099	8	4	2024-03-27 12:06:58.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1101	\\x5d61e58a143757aaf22005f82d0e712a888008dde6f4b6201ad92eb6ef7eb888	10	10641	641	1084	1100	17	4	2024-03-27 12:07:02.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1102	\\x0fc8987f44de7729b91b5cd824b2d13cbd16c9f77213cc443908af199d9c9a2d	10	10663	663	1085	1101	9	4	2024-03-27 12:07:06.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1103	\\xb86c1d2797f9c66d6b1221bde1ec20c623529eebb8d3a8cc1f3dde90598a0dc6	10	10669	669	1086	1102	3	4	2024-03-27 12:07:07.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1104	\\xad178c7fd65905e98c00cad9b9886c828f85aae9668b7aa0c63090d42fe38637	10	10672	672	1087	1103	3	4	2024-03-27 12:07:08.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1105	\\x03635f9331fd396a0c979943e1125ff1522e76f7cc7459e3a289e6171730575f	10	10678	678	1088	1104	24	4	2024-03-27 12:07:09.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1106	\\x02b201f02bed1d124d3e95c38ac145fc80ce915d725aa362cc740eee83af1189	10	10695	695	1089	1105	32	4	2024-03-27 12:07:13	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1107	\\x15bad67fb440260ccd765311473e8a948a979f7f7238968fe09775738152cb37	10	10700	700	1090	1106	17	4	2024-03-27 12:07:14	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1108	\\x496730df273828c93a3a52dfb9fd4627dda72a9d3269713c315542d44f9f9473	10	10703	703	1091	1107	32	4	2024-03-27 12:07:14.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1109	\\xc0b0c49841e658238256f09a832b7662c707433c40262406200913df16da1ffd	10	10707	707	1092	1108	8	4	2024-03-27 12:07:15.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1110	\\xf7f5d991fdc2b201651978bb7c315d2667b3fbd957e780c15ed9cc248f150ea1	10	10708	708	1093	1109	17	4	2024-03-27 12:07:15.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1111	\\x7569331d17de21e3512a9e8a0b542f27bd3b00af4dc4f1d7a68f76189af550ab	10	10719	719	1094	1110	29	4	2024-03-27 12:07:17.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1112	\\xfe9c24bd4ee75f957c1f39e2e672dc6e586a86fc714dce4427cd35fc4befe30d	10	10720	720	1095	1111	9	4	2024-03-27 12:07:18	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1113	\\x09bcfe81cd688fb393f5ec6febc1dccb5fdeb2509b05553ca8956579ea886cdf	10	10730	730	1096	1112	8	4	2024-03-27 12:07:20	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1114	\\xe6060b793a0b9bd02943f10728b976570cf57903dafff9193a9a92547a028d2c	10	10736	736	1097	1113	29	4	2024-03-27 12:07:21.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1115	\\x80c59b9c07627ba1bf22fa4d65d59a0d735be0e17d5635ce44364d820dd52ea3	10	10748	748	1098	1114	4	4	2024-03-27 12:07:23.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1116	\\xb40eababe7ae0254d7dbc5d93b052cd5632e49f05143c2ac6231e845f77f0f4a	10	10756	756	1099	1115	4	4	2024-03-27 12:07:25.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1117	\\xf91681c8941ed986744ece461a53a68effd1b191c062c2c6a520f149cea11c17	10	10760	760	1100	1116	8	4	2024-03-27 12:07:26	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1118	\\xb8902274be835ed82baf29f9eeea0e095c664510a7a89a2b55c159e8c54b9cbe	10	10761	761	1101	1117	17	4	2024-03-27 12:07:26.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1119	\\xbbcf5ff77c1142f97eca999910a18ca4b44b69cdfd60346c0380e4b2f8df83b3	10	10764	764	1102	1118	17	4	2024-03-27 12:07:26.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1120	\\xfa1b37709537bbc31b4e1178dc5e7d941ddffe262649fd666733537101518f85	10	10768	768	1103	1119	3	4	2024-03-27 12:07:27.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1121	\\x16aec80bb94af69416cab3b3f04aa1202006732ad4ff261bd1a2a2a69db463dc	10	10773	773	1104	1120	8	4	2024-03-27 12:07:28.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1122	\\x625424e30e04be5e363fedc78302719cfd7dda9965df901f4797ca30d4bff020	10	10790	790	1105	1121	17	4	2024-03-27 12:07:32	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1123	\\xa71546544aa9491ba1fd7b8a62968391b7bb4f5f130dcaff4c41e221e389d052	10	10794	794	1106	1122	17	4	2024-03-27 12:07:32.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1124	\\xc11387d31b86b52df949d6d09487c06cade5264c13bfa7b8f9316a35dc678813	10	10801	801	1107	1123	32	4	2024-03-27 12:07:34.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1125	\\x897e5c2ba354310f5056dcd8e751bbf8102aeed8c50a3aff35a5b08b5905f7ae	10	10831	831	1108	1124	29	4	2024-03-27 12:07:40.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1126	\\xe384174641931b0aec298d34dc3fd4947a6c6725d9f4cc83ee51141d6755f277	10	10842	842	1109	1125	17	4	2024-03-27 12:07:42.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1127	\\xb33c82815dca2bee2a1a485c20ea62c6b13b4762c806df4c9045988c1c25a1f2	10	10851	851	1110	1126	8	4	2024-03-27 12:07:44.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1128	\\x4af6e890783284dd81e1d2d4db86d857d8893bfd79d26e6f3a24530b6ae66669	10	10865	865	1111	1127	8	4	2024-03-27 12:07:47	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1129	\\xb18180050a720ad81421eabdcfc10601fe0a8bbdbbca75be39f62aebf4a327ad	10	10869	869	1112	1128	29	4	2024-03-27 12:07:47.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1130	\\x7c431d9a8ad4e9268e6f22744de5e36d3caa82743d3628146efafcad1bee2428	10	10875	875	1113	1129	9	4	2024-03-27 12:07:49	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1131	\\x1d2f8044d6a8f0c76a22aea8589f4d3c72229bdb470865089f5478c3f1099e8e	10	10889	889	1114	1130	3	4	2024-03-27 12:07:51.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1132	\\xc31bfd10045bff7cafe345aac39ad2a33c1ead915c697caa33b4ae47eec8c758	10	10898	898	1115	1131	29	4	2024-03-27 12:07:53.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1133	\\xb366e7eaf3381dbd1022e5f830e939b0e7702e4f3c8cc6b0cff4aa024d5f52e3	10	10906	906	1116	1132	4	4	2024-03-27 12:07:55.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1134	\\x7e62098b7cc5247e060b0b87102a9aacc7ea20e17fcf3378c85f1c4dab03a0e5	10	10917	917	1117	1133	4	4	2024-03-27 12:07:57.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1135	\\x851b948996b997acce384a0a8aad334459219abab331acf5de713648d3c2b8d0	10	10938	938	1118	1134	3	4	2024-03-27 12:08:01.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1136	\\xa3dbfc7b3b868887205159f842d24d210f3d844699800f4fdb57e495fbc536d4	10	10967	967	1119	1135	3	4	2024-03-27 12:08:07.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1137	\\xfb559d50b1e031913e5281e67c87f9896f83d4e006cd388d8393309cf461b2a9	10	10976	976	1120	1136	4	4	2024-03-27 12:08:09.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1138	\\x8e2b51bc5bc0bdaf8947f691b2bf0382ee4f4f760ec40970d3cbeb766680801d	10	10998	998	1121	1137	29	4	2024-03-27 12:08:13.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1139	\\x358b0e5332326b10d6520240200d732c90d8035b503a6a8148c01ce715aae096	11	11008	8	1122	1138	8	4	2024-03-27 12:08:15.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1140	\\x1d4689cb4b3c79f78c7f05296e44ddca7ddd6b6e98c28f38b01d0860e228b3f0	11	11010	10	1123	1139	17	2447	2024-03-27 12:08:16	2	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1141	\\x82d971ed09be1ffa71d1b977631e6f21d89abc64adce88166b136c31eade39a5	11	11014	14	1124	1140	32	10604	2024-03-27 12:08:16.8	10	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1142	\\x8f437db1d4fd41ab5cf7a29c86b55717bd4c77256c198eb13fbe9f74985f443a	11	11034	34	1125	1141	29	45586	2024-03-27 12:08:20.8	43	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1143	\\x40b0fa7a640cafa52c0c41653a1ea7112db7302742013afe85bdec29e9e66e04	11	11038	38	1126	1142	8	2124	2024-03-27 12:08:21.6	2	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1144	\\xc95f4b85544337c12d3fc559787916022a334f6ab139ade75d1b99bb3f602743	11	11039	39	1127	1143	3	4	2024-03-27 12:08:21.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1145	\\xdeb4c93a2e6d42a6ef7a755a8e5fa1eb8a47db17cc06550b3a8b45b3aaeb92bc	11	11046	46	1128	1144	9	15904	2024-03-27 12:08:23.2	15	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1146	\\x65e5ee0a64720beb9c40b0bbf2f1e5caeaa92175d92f3e95fc6a4de84cb386ae	11	11071	71	1129	1145	29	29686	2024-03-27 12:08:28.2	28	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1147	\\x333791bb1417be3d6c010b1e26376a31e8c2e27c926cadcd62c4ed6495cb4233	11	11074	74	1130	1146	29	4	2024-03-27 12:08:28.8	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1148	\\xfcd1788b2464e5168651de26a35fbaa4eacd85bfdfce3b29aca9e6c023f1439d	11	11075	75	1131	1147	28	4	2024-03-27 12:08:29	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1149	\\x9a24ffb309026c769dca7e32a9cb88b9d514339a6a8fe4e2c5cb6fa3416bd27f	11	11088	88	1132	1148	24	4	2024-03-27 12:08:31.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1150	\\xee7958803b218248845a36071765233aab16059246ba000e96e0881ab938e9a1	11	11097	97	1133	1149	28	4	2024-03-27 12:08:33.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1151	\\x77a15687d975960034e66f7768e0f941e8632be1c4c7656097871d1c707313ca	11	11100	100	1134	1150	29	4	2024-03-27 12:08:34	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1152	\\x81e243cd5af02b1071b9cc6dfb097594021f5b2c88269f8b27fd86cbffb9d768	11	11101	101	1135	1151	29	4	2024-03-27 12:08:34.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1153	\\x265dab304332ffaa405f5d1c1a3d50e3ba73fd640094b2cff18ff4d7b34ba2f4	11	11102	102	1136	1152	24	4	2024-03-27 12:08:34.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1155	\\x1ae65d91bf27af4b945bb12af5b91d6de4568fd5302ad57a09e89d451bf0b5e7	11	11117	117	1137	1153	4	4	2024-03-27 12:08:37.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1156	\\x0e95d7cab34d30c5d107015513cc1990e3a435f31ef74af0b412dc6b996f2fc9	11	11119	119	1138	1155	17	4	2024-03-27 12:08:37.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1157	\\x653e7082339752054ca15836088de00b50f4f7879fa25bf11fdaa1905bf3098c	11	11122	122	1139	1156	9	4	2024-03-27 12:08:38.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1158	\\xf214d43f4a615f7a1f594b173e30765bcc5f708d2ce101b87dc32ba38801d8f7	11	11124	124	1140	1157	9	4	2024-03-27 12:08:38.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1159	\\x9dec82384d003b3779855f07abed703445534428aeb54f4e15bd64f8ad2ebb7b	11	11127	127	1141	1158	9	4	2024-03-27 12:08:39.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1160	\\xf26ef0f52190e3828bedbc81e05be7d7a4c09c06d1ceb230c87a760b0e60e58e	11	11129	129	1142	1159	3	4	2024-03-27 12:08:39.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1161	\\x07e669ae70766d98f49ad323e83b73e24c83079902b25a4f3102fd5bb7179d9c	11	11152	152	1143	1160	3	4	2024-03-27 12:08:44.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1162	\\xe8aaa1b3a6e0e6aa60b2a72a38e1583eb796419a6b56285bb88b52475db699c2	11	11156	156	1144	1161	29	4	2024-03-27 12:08:45.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1163	\\x53bff1070ffb776acb3878f431f75695666326c496f3dba343ad8a07131fe8ca	11	11180	180	1145	1162	8	4	2024-03-27 12:08:50	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1164	\\x999da44fc72b0e49c2fdbacb9988808ec604090cabe124bc2693dac171ecc79b	11	11218	218	1146	1163	29	4	2024-03-27 12:08:57.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1165	\\x6fe889b8a6edfd0005e05588f938aafca8f099dbed404d598eec2285f4224522	11	11236	236	1147	1164	9	4	2024-03-27 12:09:01.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1166	\\x58c762ababa42eb3b07aa1c675041249054d9a37c4d875dd8d24683c1b4dbe7b	11	11274	274	1148	1165	28	4	2024-03-27 12:09:08.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1167	\\xa6ea09ab10f7f601bd1aa830fdaa353abcff182089b05f33c4297bf7232d24e5	11	11303	303	1149	1166	29	4	2024-03-27 12:09:14.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1168	\\x89f6fe30ef97d8c3861463dd49208808ad8d39c3e8d5d1cf8b3511a8baf50c27	11	11329	329	1150	1167	9	4	2024-03-27 12:09:19.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1169	\\xfe7ce180f02cb410033e3e5475f7180d9ca8f391d20680cc8b5e2ba5759a04d9	11	11336	336	1151	1168	8	4	2024-03-27 12:09:21.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1170	\\x31fa77c94dce7c66c9e5425b40d3531b762a7819565f45e4d634144886dbf14b	11	11337	337	1152	1169	9	4	2024-03-27 12:09:21.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1171	\\x69fdc7c6f08dad504dcb622c3c3c56647befcf0ee3f73621d0058c79a17f3234	11	11340	340	1153	1170	17	4	2024-03-27 12:09:22	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1172	\\x6895034e87dfe810e1a6067b7049e36178246d61188ced391d307008760828bc	11	11344	344	1154	1171	24	4	2024-03-27 12:09:22.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1173	\\x16b3db5634f345687b679146fb67ad0b2c9ceac1ce2945117cbac9e7849c5879	11	11355	355	1155	1172	29	4	2024-03-27 12:09:25	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1174	\\xf256bd75b308cf613175a4daba49b8fcd9bba59224bd5df3d0588dbb198d7cea	11	11366	366	1156	1173	8	4	2024-03-27 12:09:27.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1175	\\x3f78764ad246e89efe43d58c64aca24f7b4bf5e1e63c32eb54474d737206f9ff	11	11381	381	1157	1174	29	4	2024-03-27 12:09:30.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1176	\\x08ab4bfd5e4765f8a5aefa9772ddf38c86415993a5944c06fd68b5d4d69ec1c7	11	11386	386	1158	1175	29	4	2024-03-27 12:09:31.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1177	\\x5c7840856b013b2763e1a88d5a5379865150e94a12502915d791e3ca7383547d	11	11388	388	1159	1176	9	4	2024-03-27 12:09:31.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1178	\\x39c9f814a760b5660b58decfc78005558d3a1a769e097954f112eca13ece4c41	11	11391	391	1160	1177	17	4	2024-03-27 12:09:32.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1179	\\xba2d45fad18b1c12d56edb5b3e5b999c1f306ea32e0bcfde83f889cb7b5cd9d8	11	11403	403	1161	1178	4	4	2024-03-27 12:09:34.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1180	\\xc378d21a6ad831bb403eb55980ecb59158f1857276fff1b18680ea1e24554901	11	11416	416	1162	1179	32	4	2024-03-27 12:09:37.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1181	\\x67a398bb33672336edb21e4d1abc1335fb0eb7d8ad4ba0b9334cf64aed37cad7	11	11422	422	1163	1180	8	4	2024-03-27 12:09:38.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1182	\\xdecd08c5d457ebbf650cd2fd46b9c7a61b6df1ba5d29197d7243d5c592222381	11	11468	468	1164	1181	24	4	2024-03-27 12:09:47.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1183	\\x463f0a48bba57c49efff33ae90d3e0c417ab520b353baf59f6fdcfe28e942e76	11	11481	481	1165	1182	17	4	2024-03-27 12:09:50.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1184	\\x654b001537af0624906184278b8f65d8917547eeaeadff3f54dfed1275c0179f	11	11488	488	1166	1183	29	4	2024-03-27 12:09:51.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1185	\\x5d37e9d7b5b5ec80f65fa35a471b4ee7c9019189a8cafde198cdd74cf5761954	11	11492	492	1167	1184	4	4	2024-03-27 12:09:52.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1186	\\xbcae05aa1084da3cfbd47ec8b710abbae5d95ecde492a2d314a0a25a1791db3f	11	11498	498	1168	1185	24	4	2024-03-27 12:09:53.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1187	\\xf7c33303ac0176981c80d5ac5b8a4c4d5440b46296d7720c94661dc7d31f100d	11	11522	522	1169	1186	28	4	2024-03-27 12:09:58.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1188	\\xde98aa67515bd0f8af669fc502fbef24d2cc126c578147f7de855cc64b3bf00b	11	11525	525	1170	1187	17	4	2024-03-27 12:09:59	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1189	\\x913dd089c0b7532a74cd4ac4d2ad054db6ee1a9271bef4e5638ec9a06c13b1df	11	11530	530	1171	1188	17	4	2024-03-27 12:10:00	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1190	\\xc9aca65e850116bffc44a0c8b153a13c421f845158fb120d5d6d2c8020411ad2	11	11535	535	1172	1189	3	4	2024-03-27 12:10:01	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1191	\\x202ff6796e451af69a85ab6a93f5be90360b96d338d7efaf3e59d5f18946a631	11	11570	570	1173	1190	3	4	2024-03-27 12:10:08	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1192	\\x5b50876cb8c60bf9d96bf3dd1d8b3390a2d0dc828baf40b8a8c74c691d7961da	11	11581	581	1174	1191	9	4	2024-03-27 12:10:10.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1193	\\xf6397414a377bb7227b0e75fe98ca36693122caa13eaf4d4fd409cac56d2a1c0	11	11585	585	1175	1192	8	4	2024-03-27 12:10:11	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1194	\\x5d588e22b383457506e9127ab74492538274a1d11ebabecf3bc1e34fd41ce243	11	11586	586	1176	1193	24	4	2024-03-27 12:10:11.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1195	\\xf4cc2a94a85cc69774680aa6c065773a6e0b8fc3de781ce723299f1ba01f476b	11	11595	595	1177	1194	24	4	2024-03-27 12:10:13	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1196	\\x008a3a1f5effb06e5016e1d33e73a866a29112ce8c547321056403747cdee91e	11	11596	596	1178	1195	32	4	2024-03-27 12:10:13.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1197	\\xdf7d027063b8d674a2ce96e0a7541cdbb48137ecc5065294c0205ea1762ad8ed	11	11603	603	1179	1196	9	4	2024-03-27 12:10:14.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1198	\\xefa424993cff55e352212c84e204245ada94c091b63f17417bf076a82390ca50	11	11610	610	1180	1197	17	4	2024-03-27 12:10:16	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1199	\\x097c1dd452167f2c17f360b2ada7d89a2b62fba770fe7bfaacc710a4044fed2e	11	11620	620	1181	1198	9	4	2024-03-27 12:10:18	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1200	\\x6be40eee37571ab991ad718ab9a97e2813f0e4f7c84850bcef97880550df5581	11	11621	621	1182	1199	8	4	2024-03-27 12:10:18.2	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1201	\\x8b559d261385b7a849cefcd295fb458d1aa71896facc874506b1c12822e7fa78	11	11636	636	1183	1200	28	4	2024-03-27 12:10:21.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1202	\\xf94a3a51771575339ba2dfb360f20dac900147cba28cf14c7616f67956596737	11	11678	678	1184	1201	3	4	2024-03-27 12:10:29.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1203	\\x81fee82938f15259b7a8699633fd98355b2ad4684f794a034d7473e4b502f4b1	11	11693	693	1185	1202	24	4	2024-03-27 12:10:32.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1204	\\x23c8720b57a547d42d8498fd14f0c9e38ac31fd2c382bbcf15e01b6d15e01607	11	11695	695	1186	1203	32	4	2024-03-27 12:10:33	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1205	\\x74edc2ab721a9d28449120b8938cd6b96c33e14f640a33d11905667b8a629a44	11	11703	703	1187	1204	17	4	2024-03-27 12:10:34.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1206	\\xc58959857f8b95ed794d10d7d4a63ecfd83443903d94c33b5181021b473598c7	11	11720	720	1188	1205	3	4	2024-03-27 12:10:38	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1207	\\x1f34621691f3627950503e189893ab181e87f66c8194282de07969dca8412430	11	11721	721	1189	1206	3	4	2024-03-27 12:10:38.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1208	\\x0794d0b82d34381cdef3361b4ab61e1f43d07e192a5b24bb698ba97a1c5ddc87	11	11747	747	1190	1207	29	4	2024-03-27 12:10:43.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1209	\\x2c0acde08f9b4df379e34757b6b7506dac81d0164afab911d69dfc254fa1411e	11	11774	774	1191	1208	8	4	2024-03-27 12:10:48.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1210	\\x2fc4665f6cf9afa07372e096c387b6c2406f8ac2826705fcce4e4be493021cff	11	11778	778	1192	1209	8	4	2024-03-27 12:10:49.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1211	\\xc0a7772e35cf6fa850661f9979c73194388bf7840f4088a697224eb344be1ce2	11	11781	781	1193	1210	28	4	2024-03-27 12:10:50.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1212	\\xf7aef6c2cb7f75e48f1fca80d8027265882ad4e0efd598f63c0a027c8162a7f8	11	11782	782	1194	1211	24	4	2024-03-27 12:10:50.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1213	\\xb412487ee34c69d83cbb8bd6d6192a9a67a6d6a0af12070bd00ffd73877039a0	11	11783	783	1195	1212	32	4	2024-03-27 12:10:50.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1214	\\xac2cc06d5bd77836586073d2bb735f51d9dcf83f6f8d72d5cceff8de6c2448e1	11	11789	789	1196	1213	8	4	2024-03-27 12:10:51.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1215	\\x94799d4abad937cd53ecd1c93b082d26a9501b96573927a68d5bfe308b3e86e9	11	11800	800	1197	1214	8	4	2024-03-27 12:10:54	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1216	\\xc1fb0c64947df598220b4b34bb3c26387b29c02a5aee20b4a62b53ed92174931	11	11828	828	1198	1215	32	4	2024-03-27 12:10:59.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1217	\\x338799bc1af7328bc903abaa0d9ac1b829cb6e7cf5a6a644d1eb6dfcea60d2f1	11	11837	837	1199	1216	8	4	2024-03-27 12:11:01.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1218	\\x54e321fec94957678883bd5afdb5b94c49dfc13586ba2115076e0f7fe1c74ea0	11	11838	838	1200	1217	17	4	2024-03-27 12:11:01.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1219	\\x59bf3aefc0e42026999caaabfdb2909762b8f24378ec280089e40ac6cdade345	11	11856	856	1201	1218	29	4	2024-03-27 12:11:05.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1220	\\x075dd84a2af5b3ffc2a40f21936cac6a5bb4796c3c3b0a22ec60a460ee756d90	11	11858	858	1202	1219	28	4	2024-03-27 12:11:05.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1221	\\xfd19d781a7f464cc7f95c1a7e4ab5e832bf89589040cfffea05cae13df1b2a8b	11	11871	871	1203	1220	9	4	2024-03-27 12:11:08.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1222	\\x417f011534e65717ba404d5eba7b8f553aa116222c739b2775a239eefad90720	11	11887	887	1204	1221	4	4	2024-03-27 12:11:11.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1223	\\x581e206d06d36c215362e9cfe7bcdf204f6100966e1504f0e055dd21d2490337	11	11895	895	1205	1222	3	4	2024-03-27 12:11:13	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1224	\\xc723d361352b711246d31c657fb72df882e9aa57205f34609043c7f4b8fc256e	11	11903	903	1206	1223	28	4	2024-03-27 12:11:14.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1225	\\x40258a7326dbe000760a114edc624b30d9ef090318ed75c253f64300d61b803f	11	11911	911	1207	1224	3	4	2024-03-27 12:11:16.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1226	\\x22de6fe7afe4e723c6e3210d74f9b8ba276570a27cc6e2fd88faec61ad467fa2	11	11914	914	1208	1225	17	4	2024-03-27 12:11:16.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1227	\\xf9781f27750fd8d6937bce5882ed69479db3107865f872fcbd2c3c1a4c20f4e5	11	11919	919	1209	1226	8	4	2024-03-27 12:11:17.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1228	\\x8d3876e79da4db3c70e3f14db20ffac5e11402b077bf332b936fe0a749506abc	11	11920	920	1210	1227	17	4	2024-03-27 12:11:18	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1229	\\x9dda17ad9d3c647e9b96a42e3089a198779c263d0ea59c254cdc42619ff9fdb5	11	11921	921	1211	1228	3	4	2024-03-27 12:11:18.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1230	\\x1aa47b96c4b02b62c5f51796a75739ecfd93f0f08c6dd6a9bc83f7a3a1aaf84f	11	11944	944	1212	1229	28	4	2024-03-27 12:11:22.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1231	\\x4ab6feaef720b6e2fb2d0edae7bc405bc0974ffbf23ef9dc138a2067b2170992	11	11957	957	1213	1230	17	4	2024-03-27 12:11:25.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1232	\\x1160aee01e549c6cbfb2b43130eafbe0c8e28207e73ed26bad685a32cac21c15	11	11960	960	1214	1231	28	4	2024-03-27 12:11:26	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1233	\\x0344d31e8b19444e6f88f6d0533d5f785aa360898fdbe64af06a25dcf0e7401b	11	11964	964	1215	1232	9	4	2024-03-27 12:11:26.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1234	\\x0cd6d85e6116de64c08a145438f6cbd62b106d8ea452b7f34f0ea7067413ce6b	11	11970	970	1216	1233	24	4	2024-03-27 12:11:28	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1235	\\x3fe3bc9845cd4888e7de0f6e3e03aae6af3fd764dd8476f2248f6a55b4f98088	11	11979	979	1217	1234	8	4	2024-03-27 12:11:29.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1237	\\x4c93226f86c6121dadfee626b2f598a1b3c98d89ba3ccee634a046e91a4ef3b9	11	11982	982	1218	1235	24	4	2024-03-27 12:11:30.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1238	\\xca72497634c6ca05916253a2623f142ff1a700de6463f97ebe294f8ab9d02c77	11	11987	987	1219	1237	24	4	2024-03-27 12:11:31.4	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1239	\\x4c5f972eb44174f82dc7698624b40aeb12ba16b32098947316769f209ec79868	11	11988	988	1220	1238	29	4	2024-03-27 12:11:31.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1240	\\x7b10cddf8a918ff20d4e2acd76c375142b6712ab472972c587537e846b53f4bf	11	11998	998	1221	1239	3	4	2024-03-27 12:11:33.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1241	\\xc036ddf0aacd448c027a15b531762fe39f82451b5354912daf82c5a1d1508ecb	12	12001	1	1222	1240	3	4	2024-03-27 12:11:34.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1242	\\xf354cc28834f7f0718f75053a1193ea403de8130ac647facd8e5a0b93848bbc3	12	12025	25	1223	1241	17	4	2024-03-27 12:11:39	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1243	\\x4b4f7e159c746add9b90d808b6d4edb51694b51079d7fc25c86241c857d69c81	12	12028	28	1224	1242	17	4	2024-03-27 12:11:39.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1244	\\x52293fb231dad9e3028c4cbce0159e0d50896902c3134608e90032e8656f3871	12	12045	45	1225	1243	17	4	2024-03-27 12:11:43	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1245	\\x2d78df3e1a22dc0a81a6a7536f50806374cf2c1429d65482bfa1dadb8b9a0a4a	12	12056	56	1226	1244	24	4	2024-03-27 12:11:45.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1246	\\x8e0630999870cfa5b3f199e2afce739d171abcc166ac8209b822328498272a5a	12	12077	77	1227	1245	9	4	2024-03-27 12:11:49.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1247	\\x24ac0b275d9c2e877bebd436dcfe5ef418d295ff6887f88d2a9f1fad7d977b2c	12	12101	101	1228	1246	24	4	2024-03-27 12:11:54.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1248	\\xf266468df804f1d64c667a4b5beea2662c61f3995ec3e423d46928e530dd399b	12	12129	129	1229	1247	28	4	2024-03-27 12:11:59.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1249	\\xd166de166da343b94520c060bd83b5c82d67d448369cb2930f5cd89e85cabb8e	12	12147	147	1230	1248	8	4	2024-03-27 12:12:03.4	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1250	\\xd2f56ffc4f622a3ba6a5e6a08e6a12a0123e0ba144ab0dd060c41d54a417cac0	12	12167	167	1231	1249	3	4	2024-03-27 12:12:07.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1251	\\xb6bc80adb34346a3f2b8d38414801eb19a3bcd06788298dddf05c26d1922ca0d	12	12189	189	1232	1250	24	4	2024-03-27 12:12:11.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1252	\\x097d6075027e9fcbad920cb8500ed4cf3669606c56562dedf26d6bbba0d29ca7	12	12208	208	1233	1251	32	4	2024-03-27 12:12:15.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1253	\\x056a94c6d0de4274a75acc51f9cc57d8a9d8995cc354e24c850aa1642f7ed628	12	12221	221	1234	1252	17	4	2024-03-27 12:12:18.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1254	\\x9e181e43d161ec43a5ca0120745f6869cb1d70206f1ca31bed8331c76c9a3e2d	12	12230	230	1235	1253	17	4	2024-03-27 12:12:20	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1255	\\x0ef32ee1e387e46d2fe6278e21fa425eac8c82e709e2fbca12ea3ac7396f66ed	12	12268	268	1236	1254	28	4	2024-03-27 12:12:27.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1256	\\x5019ed814c9fa09ab935bb34d7a7915498f7bca0bf3e92b09cb92e8bdeff5a8c	12	12280	280	1237	1255	9	4	2024-03-27 12:12:30	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1257	\\xc64f3f7201502ebb1a9ebfd106086d0c01538502b48e5a8983589cecd90740b2	12	12282	282	1238	1256	17	4	2024-03-27 12:12:30.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1258	\\xbcc84ff82645fc64463e715337e3431dc0e27b511b2fcf9a29f3175a34893296	12	12288	288	1239	1257	28	4	2024-03-27 12:12:31.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1259	\\xdde98743b916e1c08b5c4d6dae8e28f17ee11c0b1a8514dca22316ea148d7f74	12	12294	294	1240	1258	9	4	2024-03-27 12:12:32.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1260	\\x24bb557383d4bd4e9fb48eb44d0766b25b60e1815f96792361edef50a1a2e42d	12	12302	302	1241	1259	9	4	2024-03-27 12:12:34.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1261	\\xe61fac27989e3259c200f9b58a0ff4322fccf430966a5eff2404fc205b8a4cf6	12	12308	308	1242	1260	24	4	2024-03-27 12:12:35.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1262	\\xa34b8ffee253a81452d4dbfc4631bb844628491aa69a27f46eba904098f9544d	12	12318	318	1243	1261	4	4	2024-03-27 12:12:37.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1263	\\xeede96379d8e461269b7882d00a76bc9361ef5e9f4caa93053cb1cdc97d1e87d	12	12325	325	1244	1262	17	4	2024-03-27 12:12:39	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1264	\\xf8d6295085d7f89b028fd1dd3f60f39eaeba0ebc5d02aca8d4a332a91383c46c	12	12327	327	1245	1263	9	4	2024-03-27 12:12:39.4	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1265	\\xc549cb3a774595d293b3283dba5fc007c5c612072f59cc2018d31236c1e36c57	12	12346	346	1246	1264	29	4	2024-03-27 12:12:43.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1266	\\x453967450084aa65683ef2785b06e51ad9c08da2c830d1381223e330554033b1	12	12354	354	1247	1265	24	4	2024-03-27 12:12:44.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1267	\\xb26c8fb775f82343ca3b1c72edf0c4397b2f8b1b2cabc30e25e70fb7d1965243	12	12355	355	1248	1266	9	4	2024-03-27 12:12:45	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1268	\\x74e88b50a6972dc538f3250c7acba80457eb5c9c2107820bf241b3f11e4df2f7	12	12356	356	1249	1267	24	4	2024-03-27 12:12:45.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1269	\\xe34bdd00f2bc41e86b5900e6547ea52db7497e7c402a8bf747123214210f8530	12	12366	366	1250	1268	28	4	2024-03-27 12:12:47.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1270	\\x6add9ee0744c651c5903282eaff2ca4d628105cd5fcaa992d88b1bf2acafc09f	12	12369	369	1251	1269	28	4	2024-03-27 12:12:47.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1271	\\x91e565a5e3fd04fb564f2a8e3c4d89e1eb1730025a63fa617e1bd43af985a5e9	12	12375	375	1252	1270	24	4	2024-03-27 12:12:49	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1272	\\xfe4c87ce9fcfa9306cb1eb95ff0750a8d29544fd3296286377bc33d937837948	12	12384	384	1253	1271	24	4	2024-03-27 12:12:50.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1273	\\x68b1908f679ac58648c37a4a85e5751a92e97b94e0e60ce1607d909daca2cac8	12	12394	394	1254	1272	28	4	2024-03-27 12:12:52.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1274	\\x4614afb4757d183ed59be74c32f3205aaff5b04a5e2682c1d38eac9494372a6e	12	12403	403	1255	1273	24	4	2024-03-27 12:12:54.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1275	\\x7e21fe72ba654f27a0a26459de16707dec78d8e43526a322ed63ce4261c8192d	12	12419	419	1256	1274	9	4	2024-03-27 12:12:57.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1276	\\x8c015198fbdf8924b1b164714579a63606963d1fc97fee88da360765f88bf439	12	12439	439	1257	1275	4	4	2024-03-27 12:13:01.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1277	\\x92038799ec47c3430ce28f8e93208fb79c9d193553527c6a983a2789d6e693ff	12	12464	464	1258	1276	9	4	2024-03-27 12:13:06.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1278	\\xa015f7e074bc0c27781940385bc1f78db4bb9f8754bbc86f4f91174a1f0ae2e5	12	12469	469	1259	1277	9	4	2024-03-27 12:13:07.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1279	\\x3eb8ba71e1ec0cde840a4004dc898b21f94c276f6adf68af6e15f8f5d1b8cc93	12	12471	471	1260	1278	17	4	2024-03-27 12:13:08.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1280	\\xfe068b547855cdacf6d3ccd3eaf9eb008ce02b1ca3c62877393bd83b54f6e5d9	12	12495	495	1261	1279	28	4	2024-03-27 12:13:13	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1281	\\x954579fdcfa44a7b29fc6b3941b8c27f068d1c0388728b80ef7f78a8a4c0085d	12	12496	496	1262	1280	32	4	2024-03-27 12:13:13.2	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1282	\\xa91a41e895019a973e999a7c78467efd0da7413a45060180265b84a800408beb	12	12505	505	1263	1281	8	4	2024-03-27 12:13:15	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1283	\\x90a134f39e2819156a1eef94797fdc44d682d01e3d90eedc2a53d99363e9da43	12	12508	508	1264	1282	9	4	2024-03-27 12:13:15.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1284	\\x9a00ae7766e633a30cbaa4125933920d786ae2d239399c37b2d43645cbc023b9	12	12529	529	1265	1283	8	4	2024-03-27 12:13:19.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1285	\\xcb98c278e8308a64b489a6188b43e410d20366a0fcc75536580b0febcc0ef66b	12	12547	547	1266	1284	29	4	2024-03-27 12:13:23.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1286	\\xc334048f15ecc75595f298841adffc97a0d836a6170de19df0b1d4bea2af5f16	12	12548	548	1267	1285	4	4	2024-03-27 12:13:23.6	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1287	\\x9a8d0378a2c510869fe6a1da064ce1e9d1acd3d93b729cb14091802960e33015	12	12560	560	1268	1286	17	4	2024-03-27 12:13:26	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1288	\\x730566a8a644503adfcd7deaafe71da7b55f115b84da03b4020fe8a1b161f18a	12	12563	563	1269	1287	32	4	2024-03-27 12:13:26.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1289	\\xacf4b255077a4bff56618ba7c22288994b94a2ed1c04aa0eb11e60d60d5deb69	12	12590	590	1270	1288	8	4	2024-03-27 12:13:32	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1290	\\x863b47db28feaeea9d20d06192b61b5f014e34906153dd4a32963fc690ddbbef	12	12610	610	1271	1289	28	4	2024-03-27 12:13:36	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1291	\\x85fcb59878875750ce22909191e235ea130cffd7e2504f2c8cef95d6c04307bd	12	12611	611	1272	1290	28	4	2024-03-27 12:13:36.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1292	\\x8408bfef63edfd7f179ae6aeefe2c06ef25b62bf73272216be1fe6ebc193055e	12	12620	620	1273	1291	28	4	2024-03-27 12:13:38	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1293	\\xb8d106b2b0b735a6af508614162f2069cc760d220feebbdaec198c93b4a37cc1	12	12626	626	1274	1292	4	4	2024-03-27 12:13:39.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1294	\\xb28f49056fc4e03a2dfeda16252a147808f55d0e104bbcf12047295ae5e5de5f	12	12661	661	1275	1293	24	4	2024-03-27 12:13:46.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1295	\\x9e4b43753e096e71bdd9242e2dbb04ad445bd23028b891790b873909e4c6e74c	12	12667	667	1276	1294	32	4	2024-03-27 12:13:47.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1296	\\x518581ae5f8cd0e66f548e2862dbc4836a21d5729f892bef0a3d6fc99118468a	12	12671	671	1277	1295	17	4	2024-03-27 12:13:48.2	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1297	\\xacba093c81d454c183191eac793218707c9ae1d8a412be883b54dc1a6e7e25d7	12	12675	675	1278	1296	32	4	2024-03-27 12:13:49	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1298	\\x7f9ac9142947d4bf5a38fa4f689c315f71395a7c0d1dee9c7eb52a3cfab0ded6	12	12682	682	1279	1297	28	4	2024-03-27 12:13:50.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1299	\\x17f2f8ca2b650e757b8a696b69b77724798d7ef01bc99aa5ca532faf0f91c97d	12	12688	688	1280	1298	3	4	2024-03-27 12:13:51.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1300	\\xdf6a84c38acc0c4547f126114b04548b3140ebd72ab3d9dfb26c98a85c4cf9ef	12	12690	690	1281	1299	8	4	2024-03-27 12:13:52	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1301	\\xe59c0db94b942b5ae1036a961b7e4e630deca197041d14b32898bdf29c01341e	12	12695	695	1282	1300	8	4	2024-03-27 12:13:53	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1302	\\x4895409b7d50b2ebec60cf937ec5bbc1c0bd3909dbc4b12d178177879a97d5ba	12	12702	702	1283	1301	3	4	2024-03-27 12:13:54.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1303	\\x9770c34d11e49ad5626799f8f338ae678aad054fb78859579694b841895941ed	12	12734	734	1284	1302	3	4	2024-03-27 12:14:00.8	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1304	\\xaba3c0cebeb2e0c71a9aa913483759e2bf7a1e62143b54b7b1d28c48618113a3	12	12753	753	1285	1303	8	4	2024-03-27 12:14:04.6	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1305	\\x47fc4484af5dc432175aedee01ec337d164b43355b4a2ddca8e0f40c30fca12d	12	12761	761	1286	1304	28	4	2024-03-27 12:14:06.2	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1306	\\x271017b5345ed0a54cbffbad114a567bac2b5451657d2bbdbaaaadd7ab2448c3	12	12763	763	1287	1305	32	4	2024-03-27 12:14:06.6	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1307	\\x3f7ccb7f44fea586f8a755383d49e6e6b2dbc7e68c5bf03539fadb717c796f12	12	12766	766	1288	1306	9	4	2024-03-27 12:14:07.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1308	\\xf48fb89b0abefa0a694feb6bc276707fd725fe8d6e3a30d87fcc43957d9bae6e	12	12767	767	1289	1307	4	4	2024-03-27 12:14:07.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1309	\\x8506d720ed371afb56c2c75fb6fd0b5c199c447ac085c81e9119fbfa0024ad0a	12	12768	768	1290	1308	3	4	2024-03-27 12:14:07.6	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1311	\\x1298b68ac078e9fa1e6d99a3d76152666cb207012a939819cb7218cbf36bf57e	12	12777	777	1291	1309	17	4	2024-03-27 12:14:09.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1312	\\x4b225700664eac09446a6f99d723e8e53e43455c655b3a7aeb3afe81375b25a2	12	12787	787	1292	1311	3	4	2024-03-27 12:14:11.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1313	\\x8768e9e5f8b084b8c721e8cef1a6a2c637eb66da3cc3c24517a848eb065503a1	12	12790	790	1293	1312	3	4	2024-03-27 12:14:12	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1314	\\x8f7e83aa9fe34a7af094661320ffb262ebbbe193a8ccbc87ee858085e507e73b	12	12793	793	1294	1313	29	4	2024-03-27 12:14:12.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1315	\\xae08e44d698c8daefc78a0db27eb52a83ce2f9735be8c85187d5df65f73b87cc	12	12821	821	1295	1314	24	4	2024-03-27 12:14:18.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1316	\\x3ece0d25b658524f5fdcb9ab4b792d31b7b8f7bd4b50d12761f6c3ba966c2c42	12	12824	824	1296	1315	8	4	2024-03-27 12:14:18.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1317	\\x864f111263d317497c4c832713c2a7aaaf87f2ef009bcf2cb090388bc08d6bd5	12	12827	827	1297	1316	17	4	2024-03-27 12:14:19.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1318	\\xf4e3bf7208d019378fbe8b76d6974b192355592d1af4dae06647d8417d403824	12	12831	831	1298	1317	24	4	2024-03-27 12:14:20.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1319	\\x4a1f331d578bc095f49f784b7cc51e43804cd74c939bca103420d9e21760ef3f	12	12835	835	1299	1318	17	4	2024-03-27 12:14:21	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1320	\\xbbb4cc737950aea087bd1f8443db4c6fbac9c9ddd83be326933c662d37f9adda	12	12840	840	1300	1319	32	4	2024-03-27 12:14:22	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1321	\\x8d2dd7d7d752c6acb1cf48205c31091042ad057e3219b500653f69dfddb7524f	12	12849	849	1301	1320	17	4	2024-03-27 12:14:23.8	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1322	\\x17bfb2500632f8608a28ed8a32fee09e7100a5cf0fea80e2d80b7a6669784736	12	12867	867	1302	1321	28	4	2024-03-27 12:14:27.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1323	\\x23f3f79523867ce2c38c60baee0a9f641b63edc9a619095016487f3ff402662f	12	12869	869	1303	1322	32	4	2024-03-27 12:14:27.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1324	\\x610c8493cda5c226175477d4ff4c956b23132bf95ca9b59f872acbfa3d6e117d	12	12885	885	1304	1323	17	4	2024-03-27 12:14:31	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1325	\\x6e83eb2bd2de777353cf362c4ac22d0c2ae02beebb4a34a6ae441fe86f8d51b4	12	12896	896	1305	1324	29	4	2024-03-27 12:14:33.2	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1327	\\x3a9404fa3e67afc7d88e6524f003eddc8ea30bdbd18917f7d037f6b789d1c68c	12	12898	898	1306	1325	17	4	2024-03-27 12:14:33.6	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1328	\\x196975562e00bd3c583669089d068d17526d69e0d455732d74a8e4502811c98a	12	12907	907	1307	1327	17	4	2024-03-27 12:14:35.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1329	\\xab0c7bb5178d66ff2149ff55e43a8bcac0f2337ad3324733394da8fb3acd59c0	12	12916	916	1308	1328	9	4	2024-03-27 12:14:37.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1330	\\xd378b1247f5d62811fde0c04291a1513db70976727580ca9f15934e4966c42ac	12	12932	932	1309	1329	29	4	2024-03-27 12:14:40.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1331	\\x20713ea42ef7609a94609921b54335756052e7105fddaf755f422817f1a83d1e	12	12951	951	1310	1330	4	4	2024-03-27 12:14:44.2	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1332	\\x3d0ac35fa574a30e7ac6cd3f6bc0e9564a07d710628bab711f59d9d9b735102a	12	12954	954	1311	1331	28	4	2024-03-27 12:14:44.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1333	\\xe7c7f47773bf32d576e4096cf3cb65e17d53fc0e336eb112ba26a4a330221a3b	12	12965	965	1312	1332	9	4	2024-03-27 12:14:47	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1334	\\x53e45ecbe809e26c4784255ec33da240f75e42a1c444015a988fb253e6cb56f2	12	12976	976	1313	1333	24	4	2024-03-27 12:14:49.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1335	\\xd3ba8aaf156216fb95e21f99b5ee4c8823e09dc52d2f0de8b7a1bde5d2f8ef95	12	12999	999	1314	1334	8	4	2024-03-27 12:14:53.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1336	\\xd0178ad22ce09c2c2f47c61630692d6e65c805382f218ed3088b4d599bc64058	13	13009	9	1315	1335	8	4	2024-03-27 12:14:55.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1337	\\x00aadd28387e633b83e0dcd0de7137e1c2e3de2746bacf8ee3e6967e8ddb5bc2	13	13020	20	1316	1336	17	1344	2024-03-27 12:14:58	1	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1338	\\xc24666b7f4b4f64bd27813e84861a0932b4e983e9c92127ad7fe6e198a32becb	13	13049	49	1317	1337	8	4	2024-03-27 12:15:03.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1339	\\xcd019d6a08910ba6e2ed97dba3e3397133c1319ae103c1c12c562b94977e65f0	13	13056	56	1318	1338	24	4	2024-03-27 12:15:05.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1340	\\xa10161ffd4084322055902588a5a78c98003320af9ea074976b8e5141912177b	13	13075	75	1319	1339	24	4	2024-03-27 12:15:09	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1341	\\x9a5b42114d2b0215c75ab6835da24a45b790925f93dd62d21a1b077ecdbb01b0	13	13094	94	1320	1340	9	4	2024-03-27 12:15:12.8	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1342	\\xa4f49c893b09c09bd1ce471916b66c24a97bd301a0d643d42d55e59e6dac5daf	13	13125	125	1321	1341	8	4	2024-03-27 12:15:19	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1343	\\x292662ac4bca847caa31dee3815a99bb26eb4d18c2c6903b932d982733465df3	13	13140	140	1322	1342	8	554	2024-03-27 12:15:22	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1344	\\x6688d3b53b0aa232141330d1c649916708f8866f8b465833080b987519392355	13	13153	153	1323	1343	28	4	2024-03-27 12:15:24.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1345	\\xfcf696a227461b06d548388f5eece8580e4a4f3869f5f94794187a37c41d69d6	13	13159	159	1324	1344	28	4	2024-03-27 12:15:25.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1346	\\xee39440a219bf44056a4a029925d22fb0bde47bd17475d37728a236e456269c5	13	13167	167	1325	1345	29	4	2024-03-27 12:15:27.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1347	\\xb2de832919971569a100070da7374be08dc2d668f1226b0f5b81963571d35213	13	13172	172	1326	1346	29	365	2024-03-27 12:15:28.4	1	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1348	\\x82a4521c7c4489577cf827ae2f86bb668524df49ec9600db7a2f258c5df3c541	13	13184	184	1327	1347	8	4	2024-03-27 12:15:30.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1349	\\xb9f504980ed79c5d59b67afcef3489c4b70fbe622960e25fb85c2f4a52f338b3	13	13204	204	1328	1348	8	4	2024-03-27 12:15:34.8	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1350	\\xb612d13699fe342d104efdd927177a6a5442b83a1e3b5d2586e893cc90eb50d3	13	13206	206	1329	1349	9	4	2024-03-27 12:15:35.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1351	\\x443cad890799a81cd698a887097e2894eed9734c4931f96f718727a6678d5bd2	13	13225	225	1330	1350	17	460	2024-03-27 12:15:39	1	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1352	\\x1cddb9e9c70ba44756db8894cb02b027f82acd75067305f8fa94ebfaa9326a72	13	13231	231	1331	1351	3	4	2024-03-27 12:15:40.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1353	\\xea109e47a8de34ed4a9cd3bb5da7fc1d6bd50e647e656185c18b98ac72a9acd8	13	13250	250	1332	1352	28	4	2024-03-27 12:15:44	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1354	\\xacd34edc518a06f71d136f6aa72dd68970c5a98dffb5a821f421cbdd38a8cd02	13	13252	252	1333	1353	28	4	2024-03-27 12:15:44.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1355	\\x4ad018a286975c9a4148d6d3794a18ae110887e1c0f48023d78afacb3b8ee8fc	13	13254	254	1334	1354	3	362	2024-03-27 12:15:44.8	1	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1356	\\x35019e34a170313faa48f4c6625ed7b104b2cc1eb3d4212ff75bcdd59a8f872c	13	13255	255	1335	1355	29	4	2024-03-27 12:15:45	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1357	\\xf13d793f64576ac2ed7bc331d2a7d59eabe3647bc9a29be27a2d99176817e4d2	13	13260	260	1336	1356	28	594	2024-03-27 12:15:46	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1358	\\x2ce3d7e7c232ecfbe048551468df424052c6a3280f516b3c7a5eeba81c370039	13	13265	265	1337	1357	32	4	2024-03-27 12:15:47	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1359	\\x4a9e6de7e19a06c0fcf95a1a25f0cbf6503ebc8bba089ce94ce29652e02038aa	13	13292	292	1338	1358	17	4	2024-03-27 12:15:52.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1360	\\x21cf8a5145299c308df0fdb1bc5daab1de9cd5f98c7b1dc43bda087b08f789df	13	13295	295	1339	1359	32	4	2024-03-27 12:15:53	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1361	\\xda24f46c9173f4931d1071242c932a2e4eac5b05f10cabf82a35869654978c85	13	13312	312	1340	1360	8	397	2024-03-27 12:15:56.4	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1362	\\x30905657d08c111bec20a006b947191c8c4dc1ddb61f6146df29bddae053d984	13	13317	317	1341	1361	17	4	2024-03-27 12:15:57.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1363	\\x3e12ff9d2f1d1727f689fee1d3a50ec2aad751c8960f15649255e3caacc217af	13	13319	319	1342	1362	28	4	2024-03-27 12:15:57.8	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1364	\\x144fbdad6de827264ef4939949010813af166a7d95da48ce6e2aa524786a856b	13	13321	321	1343	1363	24	4	2024-03-27 12:15:58.2	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1365	\\xa47a653a8c37bfab37f117c10d03dfce62a5dbdff45be9c427227eeb59abe414	13	13322	322	1344	1364	3	4	2024-03-27 12:15:58.4	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1366	\\x355c0efcd5b04fea2db7e2279f66da98b3e5ec0a6fae0fa756430f124c9be19e	13	13341	341	1345	1365	32	541	2024-03-27 12:16:02.2	1	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1367	\\xcdc4c39f3594062db5e8d8d417ed3d2628e12da4d94d65dbb34fdb8d964c2b2c	13	13354	354	1346	1366	32	4	2024-03-27 12:16:04.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1368	\\x502b8fe59ecb4777b5a2b737f4d903ffd749cfcdc2dae789718579f4633364ba	13	13363	363	1347	1367	9	4	2024-03-27 12:16:06.6	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1370	\\xf0632436ea0d896faf081db62eda3ab93e5f48be06db187b1f8b19cc291b1665	13	13372	372	1348	1368	17	4	2024-03-27 12:16:08.4	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1371	\\x103701ed32087df525b8d709a8e89e69208ea894efc58c480d1ede6dd126ec23	13	13404	404	1349	1370	28	1704	2024-03-27 12:16:14.8	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1372	\\xd168e92cceca3284eee3bbe5283cf19ede5356354983cda2441fbf06c94b8ca3	13	13408	408	1350	1371	28	4	2024-03-27 12:16:15.6	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1373	\\x5762cce132163e06244cb92b660bba6d10b1da43feb9e455cd8795dd82b4d378	13	13410	410	1351	1372	8	4	2024-03-27 12:16:16	0	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1374	\\x8a0c9d6b37ebd005e12baf0a2679ecc2c407aaac70be722218a9d6aac25db632	13	13420	420	1352	1373	29	4	2024-03-27 12:16:18	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1375	\\x92b5145cf487299289bd6b7aa8c447ce15c26765380adf0875a175b0206502e1	13	13452	452	1353	1374	28	1415	2024-03-27 12:16:24.4	1	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1376	\\xb89af1a5ffa144723a1ba57533bcb060dfe5afac7beb4a868ef66959f2e5af44	13	13467	467	1354	1375	29	4	2024-03-27 12:16:27.4	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1377	\\x478179e2f9069ef4f15ec34ad6e1b1396ed97d35248bf03555ea45e6acf15cc0	13	13471	471	1355	1376	3	4	2024-03-27 12:16:28.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1378	\\xce822f42626f841aa41cb5e261d9ab83aee4bae4418f8df67b1b274836c67e74	13	13472	472	1356	1377	28	4	2024-03-27 12:16:28.4	0	9	0	vrf_vk1x9zr4zh73pk4mzu6k433rpyacguad7vwwm5468hzqk50dune5k9sf0lwc5	\\xa2b3e0e68d3fa430b4038ac9c65a44bda915cda1f7bdd0bba6ecad08a3598bc4	0
1379	\\x94b892b13fef5e5a01d692ba33809b83dd2e3a09ca5bdae8e820702b974e5dd9	13	13477	477	1357	1378	9	1434	2024-03-27 12:16:29.4	1	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1380	\\x8d0a193a09a4ed9fe7d4b67c76fe8162892e340e648be79f9b083d30b976089a	13	13496	496	1358	1379	3	4	2024-03-27 12:16:33.2	0	9	0	vrf_vk1usxh26v2prm0cp95cc9kek37vh2gp7rkgvhgt8xera0zdff47krqh4dla4	\\xf492a657a5083fd66575a997c0475a3cfb7b233bc2d757885cfa4fb03e8c4f87	0
1381	\\xad7ffe4be59f5ffcf82a725afd3ef1fe73191519d79932aa3bb7360c2db30715	13	13501	501	1359	1380	9	4	2024-03-27 12:16:34.2	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1382	\\xf087c94f4d7146bbb15f6cd97ae6dfb57a4d448560274c845dcde52848f5c797	13	13513	513	1360	1381	24	4	2024-03-27 12:16:36.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1383	\\xdc313dad6ac8b0171d1980fa0fd6a2fc218e53713e71bef6cde2f2777fe47892	13	13534	534	1361	1382	8	712	2024-03-27 12:16:40.8	1	9	0	vrf_vk1cyrv20q62t07epqnjwx6u2898nmw379548ahqj6mp8vl52m65k9su3ujz6	\\xa6da45fcb770f6b60ff236751d279f788d0cf6af544df6d223c0274343ce7649	0
1385	\\x9fe8a76af6ea71ffacae94c90b0d3ddd54699cd8c321f13325e6ec3954f993d5	13	13538	538	1362	1383	29	4	2024-03-27 12:16:41.6	0	9	0	vrf_vk1lsk8kze8lcqm35l7pss7nr3040gxg470zz5epj96h0w5gnv7mn2q5lpspf	\\x45aff18aa6c6ccee739de0aadd049548333b208708540085b4a14f3ca3eb92bd	0
1386	\\xfc36acecb97d107dc15d2a358a8f3e97b73a2c78c730d98f6a39a1d88cd3a8a5	13	13569	569	1363	1385	24	4	2024-03-27 12:16:47.8	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
1387	\\x09fafdc3bc8e385d03a06f6976282e36fc97b107e958670f13a2439d83ea7f02	13	13572	572	1364	1386	32	4	2024-03-27 12:16:48.4	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1388	\\x42f44275934e16a40f3c0b646369dfb1bcabd41370e7fefd5bb92d67c7f617ee	13	13574	574	1365	1387	32	4	2024-03-27 12:16:48.8	0	9	0	vrf_vk1vyzt2gyglv2cgsxug3qec2tg243mrnlfmd6h9vm27erf6yvvxedq2fjyhy	\\xba581ec37c4f50edb6edcb40c5341967377380fbafa3d54ae4f38324ca6adb5b	0
1389	\\x48168193d73eedf86dfa582a355aa26a1c4326e4bd24a0c93769fdc42450b842	13	13577	577	1366	1388	4	4	2024-03-27 12:16:49.4	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1390	\\xb00e3e76732aa0c14cef3527c635b7c8e3ac8a55cd46f8e0a0a59d802eea459c	13	13595	595	1367	1389	9	4	2024-03-27 12:16:53	0	9	0	vrf_vk133eca6nmxj62eu9plfx3cuzgkpw579542443qm92ffv7cjhv63vs7wqwsq	\\xf7d41fd51cd45c2826eb2589c22d4b523de5a8b960ed91ea0dbeb403c718361f	0
1391	\\xf6e238b92b79508e26b28826dea1174a54866fc874c0efecedf445eb2fa2ac1c	13	13609	609	1368	1390	4	4	2024-03-27 12:16:55.8	0	9	0	vrf_vk1w7q5cgc2y057vjmt626f26uxe4xc7wt4hvkkvqqheguj37mxkzlsmkglrr	\\xd76ac2039258e26de4be291d2a1d6d6251fbb8b4821822e3f1788f42af182117	0
1392	\\x4853ebaf84f633e3670d4a08c3fd3b329f78ab3f9bad93313c81bc1551662c25	13	13615	615	1369	1391	17	4	2024-03-27 12:16:57	0	9	0	vrf_vk10saxkv422wcwsuthvvmf5tgj9hkz6t24vdu3nx26zl8gcd0mx9rq3vjhhv	\\xfd67b80408d5f962ca35450d815316cd47a73e51eecdfc1302070ca2f9312230	0
1393	\\x9fe1d82eada33747598d76df091b884c4b0782dedae112e90452de180f446353	13	13618	618	1370	1392	24	4	2024-03-27 12:16:57.6	0	9	0	vrf_vk14ppwshynejez2xk7fhu4t7xpf83umhx9jejw3vwwpvwuzmr5aqlsnhd7fd	\\x91f6a1aae90896cb1d460949d367f51555f99f1b7016589bc3b38ffd08ff2664	0
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
1	121	1	addr_test1vq05unye4mh62kxls700wh09wl7w8r68ejj7zx2dluv408slwrte9	f	\\x1f4e4c99aeefa558df879ef75de577fce38f47cca5e1194dff19579e	\N	3681318081226298	\N	fromList []	\N	\N
2	128	1	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	3681317478932721	\N	fromList []	\N	\N
\.


--
-- Data for Name: committee_de_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.committee_de_registration (id, tx_id, cert_index, voting_anchor_id, cold_key_id) FROM stdin;
\.


--
-- Data for Name: committee_hash; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.committee_hash (id, raw, has_script) FROM stdin;
\.


--
-- Data for Name: committee_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.committee_registration (id, tx_id, cert_index, cold_key_id, hot_key_id) FROM stdin;
\.


--
-- Data for Name: constitution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.constitution (id, gov_action_proposal_id, voting_anchor_id, script_hash) FROM stdin;
2	11	1	\N
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
5	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	393	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "24706861726d65727332"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "6261736963"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 9}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c6574746572732c6e756d62657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "62675f696d616765"}, "v": {"bytes": "697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f"}}, {"k": {"bytes": "7066705f696d616765"}, "v": {"bytes": "697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b524244"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": "697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b"}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879"}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "01e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c980"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "312e31352e30"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "7066705f6173736574"}, "v": {"bytes": "e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e044503036383136"}}, {"k": {"bytes": "62675f6173736574"}, "v": {"bytes": "9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65"}}]}], "constructor": 0}	\\xd8799faa446e616d654a24706861726d6572733245696d6167655838697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e677468094a636861726163746572734f6c6574746572732c6e756d62657273516e756d657269635f6d6f64696669657273404776657273696f6e0101b34862675f696d6167655835697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f497066705f696d6167655835697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b52424446706f7274616c404864657369676e65725838697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b47736f6369616c73404676656e646f72404764656661756c74004e7374616e646172645f696d6167655838697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879536c6173745f7570646174655f61646472657373583901e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d4c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f686173685820bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de537374616e646172645f696d6167655f686173685820b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c9804b7376675f76657273696f6e46312e31352e304c6167726565645f7465726d7340546d6967726174655f7369675f726571756972656400446e7366770045747269616c00497066705f61737365745823e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e0445030363831364862675f6173736574582c9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65ff
6	\\xff1a404ece117cc4482d26b072e30b5a6b3cd055a22debda3f90d704957e273a	394	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "24686e646c"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d73627162317366736356365970"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "636f6d6d6f6e"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 4}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c657474657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d73627162317366736356365970"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": ""}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "00f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df40"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "32646465376163633062376532333931626633326133646537643566313763356365663231633336626432333564636663643738376463663439656661363339"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "32646465376163633062376532333931626633326133646537643566313763356365663231633336626432333564636663643738376463663439656661363339"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "322e302e31"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}]}], "constructor": 0}	\\xd8799faa446e616d654524686e646c45696d6167655838697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d73627162317366736356365970496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d626572004672617269747946636f6d6d6f6e466c656e677468044a63686172616374657273476c657474657273516e756d657269635f6d6f64696669657273404776657273696f6e0101af4e7374616e646172645f696d6167655838697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d7362716231736673635636597046706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f61646472657373583900f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df404c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f68617368584032646465376163633062376532333931626633326133646537643566313763356365663231633336626432333564636663643738376463663439656661363339537374616e646172645f696d6167655f686173685840326464653761636330623765323339316266333261336465376435663137633563656632316333366264323335646366636437383764636634396566613633394b7376675f76657273696f6e45322e302e314c6167726565645f7465726d7340546d6967726174655f7369675f72657175697265640045747269616c00446e73667700ff
7	\\x29294f077464c36e67b304ad22547fb3dfa946623b0b2cbae8acea7fb299353c	395	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "2473756240686e646c"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d3534726472455032776366"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "6261736963"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 8}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c657474657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d3534726472455032776366"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": ""}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "00f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df40"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "34333831373362613630333931353466646232643137383763363765633636333863393462643331633835336630643964356166343365626462313864623934"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "34333831373362613630333931353466646232643137383763363765633636333863393462643331633835336630643964356166343365626462313864623934"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "322e302e31"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}]}], "constructor": 0}	\\xd8799faa446e616d65492473756240686e646c45696d6167655838697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d3534726472455032776366496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e677468084a63686172616374657273476c657474657273516e756d657269635f6d6f64696669657273404776657273696f6e0101af4e7374616e646172645f696d6167655838697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d353472647245503277636646706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f61646472657373583900f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df404c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f68617368584034333831373362613630333931353466646232643137383763363765633636333863393462643331633835336630643964356166343365626462313864623934537374616e646172645f696d6167655f686173685840343338313733626136303339313534666462326431373837633637656336363338633934626433316338353366306439643561663433656264623138646239344b7376675f76657273696f6e45322e302e314c6167726565645f7465726d7340546d6967726174655f7369675f72657175697265640045747269616c00446e73667700ff
\.


--
-- Data for Name: delegation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delegation (id, addr_id, cert_index, pool_hash_id, active_epoch_no, tx_id, slot_no, redeemer_id) FROM stdin;
1	1	1	1	2	34	0	\N
2	2	3	10	2	34	0	\N
3	10	5	4	2	34	0	\N
4	6	7	7	2	34	0	\N
5	11	9	9	2	34	0	\N
6	4	11	8	2	34	0	\N
7	7	13	6	2	34	0	\N
8	3	15	3	2	34	0	\N
9	8	17	5	2	34	0	\N
10	5	19	11	2	34	0	\N
11	9	21	2	2	34	0	\N
12	21	0	10	2	59	170	\N
13	34	0	10	2	60	193	\N
14	19	0	8	2	64	247	\N
15	35	0	8	2	65	263	\N
16	16	0	5	2	69	382	\N
17	36	0	5	2	70	403	\N
18	13	0	2	2	74	452	\N
19	37	0	2	2	75	480	\N
20	14	0	3	2	79	544	\N
21	38	0	3	2	80	554	\N
22	20	0	9	2	84	614	\N
23	39	0	9	2	85	625	\N
24	12	0	1	2	89	675	\N
25	40	0	1	2	90	686	\N
26	17	0	6	2	94	780	\N
27	41	0	6	2	95	818	\N
28	41	0	6	2	97	838	\N
29	22	0	11	2	101	922	\N
30	42	0	11	2	102	938	\N
31	42	0	11	2	104	982	\N
32	18	0	7	3	108	1043	\N
33	43	0	7	3	109	1055	\N
34	43	0	7	3	111	1107	\N
35	15	0	4	3	115	1221	\N
36	44	0	4	3	116	1253	\N
37	44	0	4	3	118	1278	\N
38	68	0	10	6	137	4215	\N
39	68	0	10	6	141	4326	\N
40	68	0	10	6	150	4509	\N
41	79	1	1	6	163	4914	\N
42	80	3	2	6	163	4914	\N
43	81	5	3	6	163	4914	\N
44	82	7	10	6	163	4914	\N
45	83	9	5	6	163	4914	\N
46	79	0	1	6	165	4996	\N
47	80	1	1	6	165	4996	\N
48	81	2	1	6	165	4996	\N
49	82	3	1	6	165	4996	\N
50	83	4	1	6	165	4996	\N
51	68	1	1	7	172	5298	\N
52	91	1	1	7	177	5429	\N
53	68	1	1	7	182	5625	\N
54	95	1	2	11	284	9038	\N
55	70	0	12	15	388	13225	\N
56	67	0	13	15	392	13341	\N
\.


--
-- Data for Name: delegation_vote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delegation_vote (id, addr_id, cert_index, drep_hash_id, tx_id, redeemer_id) FROM stdin;
1	68	0	1	139	\N
2	68	0	1	141	\N
3	68	0	1	147	\N
4	68	0	1	150	\N
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
1	\\x4615beb10ff7b5d247dd0f8cb28ba447e8db9e7b4782b5d6eec7f1ed	drep1gc2mavg0776ay37ap7xt9zaygl5dh8nmg7ptt4hwclc76fcq9vn	f
\.


--
-- Data for Name: drep_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drep_registration (id, tx_id, cert_index, deposit, drep_hash_id, voting_anchor_id) FROM stdin;
1	136	0	2000000	1	1
2	143	0	\N	1	\N
3	155	0	-2000000	1	\N
\.


--
-- Data for Name: epoch; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch (id, out_sum, fees, tx_count, blk_count, no, start_time, end_time) FROM stdin;
1	147273661779875490	12367011	71	134	0	2024-03-27 11:31:35.2	2024-03-27 11:34:53.4
2	66276683496171964	5015638	27	115	1	2024-03-27 11:34:55	2024-03-27 11:38:12.8
24	5058297697016	610182	2	108	9	2024-03-27 12:01:36.2	2024-03-27 12:04:48.4
5	0	0	0	98	3	2024-03-27 11:41:35.6	2024-03-27 11:44:52.8
31	0	0	0	93	12	2024-03-27 12:11:34.2	2024-03-27 12:14:53.8
8	67972543415811	5933416	32	93	4	2024-03-27 11:44:54.8	2024-03-27 11:48:13.2
20	0	0	0	99	8	2024-03-27 11:58:16	2024-03-27 12:01:30.4
3	0	0	0	82	2	2024-03-27 11:38:18.8	2024-03-27 11:41:33.6
28	500299182573650	20229512	100	100	11	2024-03-27 12:08:15.6	2024-03-27 12:11:33.6
17	0	0	0	117	6	2024-03-27 11:51:34.6	2024-03-27 11:54:52.4
25	0	0	0	96	10	2024-03-27 12:04:57	2024-03-27 12:08:13.6
12	10284645463149	3684145	17	97	5	2024-03-27 11:48:16.4	2024-03-27 11:51:30.6
19	11777459493452	16889472	100	83	7	2024-03-27 11:54:54.6	2024-03-27 11:58:13.2
34	21925622454859	2318212	12	56	13	2024-03-27 12:14:55.8	2024-03-27 12:16:57.6
\.


--
-- Data for Name: epoch_param; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_param (id, epoch_no, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, nonce, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, block_id, extra_entropy, coins_per_utxo_size, pvt_motion_no_confidence, pvt_committee_normal, pvt_committee_no_confidence, pvt_hard_fork_initiation, dvt_motion_no_confidence, dvt_committee_normal, dvt_committee_no_confidence, dvt_update_to_constitution, dvt_hard_fork_initiation, dvt_p_p_network_group, dvt_p_p_economic_group, dvt_p_p_technical_group, dvt_p_p_gov_group, dvt_treasury_withdrawal, committee_min_size, committee_max_term_length, gov_action_lifetime, gov_action_deposit, drep_deposit, drep_activity, pvtpp_security_group) FROM stdin;
1	1	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	9	0	0	0	\\xe1765c2791529baf4596730a2b12b5329aaefd357a2ef1ec7b39be6150a7447a	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	137	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	10	1000000000	2000000	20	0.51
2	2	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	9	0	0	0	\\x02d0bfc5a40443553d066f3e81663238f98d71edd2dd742165c5639a4daebdb8	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	252	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	10	1000000000	2000000	20	0.51
3	3	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	9	0	0	0	\\xc3bebc0dde4c537168ed71f84f2f67dfd87394c37e0e8c87a75aa9b5f15c6a2e	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	334	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	10	1000000000	2000000	20	0.51
4	4	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	9	0	0	0	\\xa6a494f8b97ef55f1e32965341bef532a43f8a3d4855267de9ee46c585743d7a	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	433	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	10	1000000000	2000000	20	0.51
5	5	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	9	0	0	0	\\x867b83df2b876dbc44fbe98f9e15906416b43435d89f8b62fc717157cc1f2300	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	528	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	10	1000000000	2000000	20	0.51
7	6	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	9	0	0	0	\\x6eb7e2e25c8e6d473ca15f04c0f197d87347f953a8b89f4698e3847bf14e21e1	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	629	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	10	1000000000	2000000	20	0.51
8	7	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	9	0	0	0	\\xf3f9a4875990b870ec12d62e758f2edaf80ddb5193158d9caff19370fdc1a11e	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	749	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	10	1000000000	2000000	20	0.51
9	8	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	9	0	0	0	\\xf49fa545c82224d72ecf97fc34c849193e24e17cd6e67b3388ea37384b85d86d	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	833	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	10	1000000000	2000000	20	0.51
10	9	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	9	0	0	0	\\x72833228b7a797360b2e9364f08a815f36af9bb0764a11771605da89fdffa7b0	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	932	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	10	1000000000	2000000	20	0.51
11	10	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	9	0	0	0	\\x80808174b67e0257f0c333bd44e4cb3b53a66c2f9be512c90d022184ecb02110	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1043	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	10	1000000000	2000000	20	0.51
12	11	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	9	0	0	0	\\x5b3f23ff0d5f4eaf1abbcf058d1685ba5c86fa2ab4d330efb97f41defbf4e1fc	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1139	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	10	1000000000	2000000	20	0.51
13	12	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	9	0	0	0	\\x1b83e7072b52b9f36bb5c4607e92cd28c73e43401929bdc99c82e02f96790d9d	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1241	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	10	1000000000	2000000	20	0.51
14	13	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	9	0	0	0	\\x1b1f1977dd0741cd0383eef37ba691a48b17e6f54f1dc149e88652d1b14c7b6d	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1336	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	10	1000000000	2000000	20	0.51
\.


--
-- Data for Name: epoch_stake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_stake (id, addr_id, pool_id, amount, epoch_no) FROM stdin;
1	1	1	7772727272727272	1
2	2	10	7772727272727280	1
3	10	4	7772727272727272	1
4	6	7	7772727272727272	1
5	11	9	7772727272727272	1
6	4	8	7772727272727272	1
7	7	6	7772727272727272	1
8	3	3	7772727272727272	1
9	8	5	7772727272727272	1
10	5	11	7772727272727272	1
11	9	2	7772727272727272	1
12	12	1	500000000	2
13	20	9	500000000	2
14	1	1	7772727272727272	2
15	2	10	7772727272727280	2
16	42	11	499999289244	2
17	36	5	499999463237	2
18	17	6	300000000	2
19	41	6	499999289244	2
20	10	4	7772727272727272	2
21	19	8	600000000	2
22	13	2	500000000	2
23	39	9	499999463237	2
24	6	7	7772727272727272	2
25	35	8	499999466009	2
26	11	9	7772727272727272	2
27	4	8	7772727272727272	2
28	7	6	7772727272727272	2
29	3	3	7772727272727272	2
30	14	3	500000000	2
31	8	5	7772727272727272	2
32	5	11	7772727272727272	2
33	40	1	499999463237	2
34	37	2	499999463237	2
35	21	10	500000000	2
36	38	3	499999463237	2
37	16	5	200000000	2
38	22	11	300000000	2
39	9	2	7772727272727272	2
40	34	10	499999463237	2
41	12	1	500000000	3
42	20	9	500000000	3
43	1	1	7772727272727272	3
44	2	10	7772727272727280	3
45	44	4	499999286428	3
46	18	7	500000000	3
47	42	11	499999289244	3
48	36	5	499999463237	3
49	17	6	300000000	3
50	43	7	499999286428	3
51	41	6	499999289244	3
52	10	4	7772727272727272	3
53	19	8	600000000	3
54	13	2	500000000	3
55	39	9	499999463237	3
56	6	7	7772727272727272	3
57	35	8	499999466009	3
58	11	9	7772727272727272	3
59	4	8	7772727272727272	3
60	7	6	7772727272727272	3
61	3	3	7772727272727272	3
62	14	3	500000000	3
63	8	5	7772727272727272	3
64	5	11	7772727272727272	3
65	15	4	500000000	3
66	40	1	499999463237	3
67	37	2	499999463237	3
68	21	10	500000000	3
69	38	3	499999463237	3
70	16	5	200000000	3
71	22	11	300000000	3
72	9	2	7772727272727272	3
73	34	10	499999463237	3
74	12	1	500000000	4
75	20	9	500000000	4
76	1	1	7779630578132545	4
77	2	10	7778096510264715	4
78	44	4	499999286428	4
79	18	7	500000000	4
80	42	11	499999289244	4
81	36	5	499999463237	4
82	17	6	300000000	4
83	43	7	499999286428	4
84	41	6	499999289244	4
85	10	4	7781164646000384	4
86	19	8	600000000	4
87	13	2	500000000	4
88	39	9	499999463237	4
89	6	7	7781164646000384	4
90	35	8	499999466009	4
91	11	9	7781164646000384	4
92	4	8	7783465747802142	4
93	7	6	7780397612066464	4
94	3	3	7778096510264707	4
95	14	3	500000000	4
96	8	5	7787300917471738	4
97	5	11	7780397612066464	4
98	15	4	500000000	4
99	40	1	499999463237	4
100	37	2	499999463237	4
101	21	10	500000000	4
102	38	3	499999463237	4
103	16	5	200000000	4
104	22	11	300000000	4
105	9	2	7777329476330787	4
106	34	10	499999463237	4
107	12	1	500556091	5
108	20	9	500444873	5
109	1	1	7788275274694615	5
110	2	10	7785876737170578	5
111	44	4	499999286428	5
112	18	7	500000000	5
113	42	11	500277334658	5
114	36	5	500499945170	5
115	17	6	300166827	5
116	43	7	499999286428	5
117	41	6	500277334658	5
118	10	4	7786352131935636	5
119	19	8	600667309	5
120	13	2	500389264	5
121	39	9	500444336032	5
122	6	7	7785487550946427	5
123	35	8	500555556992	5
124	11	9	7788080403250040	5
125	4	8	7792110444141784	5
126	7	6	7784719960570114	5
127	3	3	7785012267514363	5
128	14	3	500444873	5
129	8	5	7795081144978142	5
130	5	11	7784719960570114	5
131	15	4	500000000	5
132	40	1	500555554231	5
133	37	2	500388726933	5
134	21	10	500500482	5
135	38	3	500444336032	5
136	16	5	200200192	5
137	22	11	300166827	5
138	9	2	7783380763924236	5
139	34	10	500499945132	5
140	12	1	1276474482180	6
141	82	1	0	6
142	20	9	1021354385739	6
143	1	1	7795503115561135	6
144	2	10	7790936126333545	6
145	44	4	500436904768	6
146	18	7	500601726	6
147	81	1	0	6
148	42	11	500277334658	6
149	36	5	500499945170	6
150	17	6	300166827	6
151	43	7	500601011646	6
152	41	6	500277334658	6
153	79	1	999177457	6
154	10	4	7793155117672582	6
155	19	8	893881919169	6
156	80	1	0	6
157	13	2	1531585800577	6
158	39	9	500816289883	6
159	6	7	7794841656334727	6
160	35	8	500881014418	6
161	11	9	7793862601148072	6
162	4	8	7797169833174569	6
163	7	6	7784719960570114	6
164	3	3	7790071656677330	6
165	14	3	893781643129	6
166	8	5	7795081144978142	6
167	5	11	7784719960570114	6
168	15	4	500437618	6
169	40	1	501020502559	6
170	37	2	500946670285	6
171	21	10	893781698738	6
172	38	3	500769793465	6
173	83	1	0	6
174	16	5	200200192	6
175	22	11	300166827	6
176	9	2	7792054256258697	6
177	34	10	500825402565	6
178	12	1	1778598304812	7
179	82	1	0	7
180	20	9	2275927885462	7
181	1	1	7798346089952340	7
182	2	10	7797334494661448	7
183	44	4	500939220778	7
184	81	1	0	7
185	42	11	500277334658	7
186	36	5	500499945170	7
187	79	1	999177457	7
188	10	4	7800972335989595	7
189	19	8	1771917377292	7
190	80	1	0	7
191	13	2	2284811470487	7
192	39	9	501272938480	7
193	35	8	501200473454	7
194	11	9	7800969124620246	7
195	4	8	7802142835422558	7
196	3	3	7797180991650409	7
197	14	3	2148841354176	7
198	8	5	7795081144978142	7
199	5	11	7784719960570114	7
200	15	4	1380488787347	7
201	40	1	501203221475	7
202	37	2	501220922615	7
203	21	10	2023368588678	7
204	38	3	501226802923	7
205	83	1	0	7
206	16	5	200200192	7
207	22	11	300166827	7
208	9	2	7796320162307507	7
209	34	10	501236708946	7
210	68	1	4992929054652	7
211	12	1	2890329413465	8
212	82	1	0	8
213	20	9	3881663064796	8
214	1	1	7804643282146834	8
215	2	10	7803633626727924	8
216	44	4	501118974756	8
217	81	1	0	8
218	42	11	500277334658	8
219	36	5	500499945170	8
220	79	1	999177457	8
221	10	4	7803771595529784	8
222	19	8	3253385803486	8
223	80	1	0	8
224	13	2	3644357447937	8
225	39	9	501857446735	8
226	35	8	501739580228	8
227	11	9	7810065435564825	8
228	4	8	7810535069751358	8
229	3	3	7803480823227096	8
230	14	3	3261038280451	8
231	8	5	7795081144978142	8
232	5	11	7784719960570114	8
233	15	4	1874897697793	8
234	40	1	501607944525	8
235	37	2	501716047199	8
236	21	10	3135442063992	8
237	38	3	501631775313	8
238	83	1	0	8
239	16	5	200200192	8
240	22	11	300166827	8
241	9	2	7804021661087639	8
242	34	10	501641636401	8
243	68	1	4992929054652	8
244	12	1	3928596323815	9
245	82	1	0	9
246	20	9	5542796461533	9
247	1	1	7810517793516818	9
248	2	10	7809512159497672	9
249	44	4	501307698446	9
250	81	1	0	9
251	42	11	500277334658	9
252	36	5	500499945170	9
253	79	1	999930414	9
254	10	4	7806710533448253	9
255	19	8	4187445949312	9
256	80	1	0	9
257	13	2	4994791730778	9
258	39	9	502461598647	9
259	35	8	502079173473	9
260	11	9	7819467440028310	9
261	4	8	7815821487353421	9
262	3	3	7811123863161715	9
263	14	3	4611318398219	9
264	8	5	7795081144978142	9
265	5	11	7784719960570114	9
266	15	4	2393957327261	9
267	40	1	501985502021	9
268	37	2	502207209514	9
269	21	10	4174080285672	9
270	38	3	502123093454	9
271	83	1	0	9
272	16	5	200200192	9
273	22	11	300166827	9
274	9	2	7811661523052877	9
275	34	10	502019526617	9
276	68	1	4992912165180	9
277	12	1	4905388693499	10
278	82	1	0	10
279	20	9	6520184298478	10
280	1	1	7816038456001946	10
281	2	10	7815040262804761	10
282	44	4	501485127831	10
283	81	1	0	10
284	42	11	500277334658	10
285	36	5	500499945170	10
286	79	1	1000637759	10
287	10	4	7809473586676557	10
288	19	8	5066723702530	10
289	80	1	0	10
290	13	2	6363797234233	10
291	39	9	502816633338	10
292	35	8	502398602042	10
293	11	9	7824992602983959	10
294	4	8	7820794003255098	10
295	3	3	7817204733947653	10
296	14	3	5686843800929	10
297	8	5	7795081144978142	10
298	5	11	7784719960570114	10
299	15	4	2882551513997	10
300	40	1	502340317489	10
301	37	2	502704808461	10
302	21	10	5151768303608	10
303	38	3	502513990552	10
304	83	1	0	10
305	16	5	200200192	10
306	22	11	300166827	10
307	9	2	7819401504635325	10
308	34	10	502374890146	10
309	68	1	4996446796216	10
310	12	1	5580182281904	11
311	82	1	0	11
312	20	9	7580960521880	11
313	1	1	7819847988559698	11
314	2	10	7822669916040710	11
315	44	4	502080238793	11
316	81	1	0	11
317	42	11	500277334658	11
318	36	5	500499945170	11
319	79	1	1001125468	11
320	10	4	7818741066571097	11
321	19	8	6030669794054	11
322	80	1	0	11
323	13	2	6942898633929	11
324	39	9	503201445622	11
325	35	8	502748362003	11
326	11	9	7830981174328413	11
327	4	8	7826238685228845	11
328	3	3	7824289298956277	11
329	14	3	6941014589931	11
330	8	5	7795081144978142	11
331	5	11	7784719960570114	11
332	15	4	4521103646043	11
333	40	1	502585157865	11
334	37	2	502914976391	11
335	21	10	6502260764870	11
336	38	3	502969408205	11
337	83	1	0	11
338	16	5	200200192	11
339	22	11	300166827	11
340	9	2	7822670594968089	11
341	34	10	502865347786	11
342	95	2	2498223310825	11
343	68	1	2500659979007	11
344	12	1	6722195849064	12
345	82	1	0	12
346	20	9	8811358598779	12
347	1	1	7826291049876807	12
348	2	10	7827632703466135	12
349	44	4	502558666794	12
350	81	1	0	12
351	42	11	500277334658	12
352	36	5	500499945170	12
353	79	1	1001950331	12
354	10	4	7826191478631788	12
355	19	8	7172813599345	12
356	80	1	0	12
357	13	2	7734499960720	12
358	39	9	503647186577	12
359	35	8	503162477493	12
360	11	9	7837917937056848	12
361	4	8	7832685183941202	12
362	3	3	7829746662352695	12
363	14	3	7908320944438	12
364	8	5	7795081144978142	12
365	5	11	7784719960570114	12
366	15	4	5839044552344	12
367	40	1	502999256322	12
368	37	2	503201985408	12
369	21	10	7381613719126	12
370	38	3	503320224328	12
371	83	1	0	12
372	16	5	200200192	12
373	22	11	300166827	12
374	9	2	7827134922147075	12
375	34	10	503184371067	12
376	95	2	2498223310825	12
377	68	1	2504778737850	12
378	12	1	7749293144079	13
379	82	1	0	13
380	20	9	10119078724952	13
381	1	1	7832080759571244	13
382	2	10	7835011411016373	13
383	44	4	503033103156	13
384	81	1	0	13
385	42	11	500277334658	13
386	36	5	500499945170	13
387	79	1	1002691550	13
388	10	4	7833579730120329	13
389	19	8	8013332619199	13
390	80	1	0	13
391	13	2	8669241066845	13
392	39	9	504120557664	13
393	35	8	503466966602	13
394	11	9	7845284688704194	13
395	4	8	7837425138610255	13
396	3	3	7834488038520633	13
397	14	3	8749536109353	13
398	8	5	7795081144978142	13
399	5	11	7784719960570114	13
400	15	4	7146535685447	13
401	40	1	503371363575	13
402	37	2	503540524530	13
403	21	10	8689934794410	13
404	38	3	503625014587	13
405	83	1	0	13
406	16	5	200200192	13
407	22	11	300166827	13
408	9	2	7832400782508125	13
409	34	10	503658697144	13
410	95	2	0	13
411	68	1	5006682923835	13
412	12	1	8117308436210	14
413	82	1	0	14
414	20	9	11498339244000	14
415	1	1	7834153313599509	14
416	2	10	7842784736261076	14
417	44	4	503466145325	14
418	81	1	0	14
419	42	11	500277334658	14
420	36	5	500499945170	14
421	79	1	1002956885	14
422	10	4	7840323362572156	14
423	19	8	9208359898365	14
424	80	1	0	14
425	13	2	9221326924743	14
426	39	9	504619387158	14
427	35	8	503899588233	14
428	11	9	7853047632182151	14
429	4	8	7844159720761805	14
430	3	3	7839668493615953	14
431	14	3	9669589469732	14
432	8	5	7795081144978142	14
433	5	11	7784719960570114	14
434	15	4	8341642459157	14
435	40	1	503504567557	14
436	37	2	503740259886	14
437	21	10	10069777718897	14
438	38	3	503958030191	14
439	83	1	0	14
440	16	5	200200192	14
441	22	11	300166827	14
442	9	2	7835507597724161	14
443	34	10	504158390464	14
444	95	2	992182669	14
445	68	1	5007345692845	14
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
6	6	t
7	7	t
8	8	t
9	9	t
10	10	t
11	11	t
12	12	t
13	13	t
14	14	t
\.


--
-- Data for Name: epoch_sync_time; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_sync_time (id, no, seconds, state) FROM stdin;
1	0	11	lagging
2	1	1	lagging
3	2	1	following
4	3	183	following
5	4	202	following
6	5	199	following
7	6	200	following
8	7	202	following
9	8	201	following
10	9	201	following
11	10	199	following
12	11	199	following
13	12	202	following
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
7	152	0	\N	1000000000	68	14	9	ParameterChange	{"tag": "ParameterChange", "contents": [null, {"maxTxSize": 2000}, null]}	2	\N	\N	\N	\N
8	152	1	\N	1000000000	68	14	9	HardForkInitiation	{"tag": "HardForkInitiation", "contents": [null, {"major": 10, "minor": 0}]}	\N	\N	\N	\N	\N
9	152	2	\N	1000000000	68	14	9	TreasuryWithdrawals	{"tag": "TreasuryWithdrawals", "contents": [[[{"network": "Testnet", "credential": {"keyHash": "f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80"}}, 10000000]], null]}	\N	\N	\N	\N	\N
10	152	3	\N	1000000000	68	14	9	NoConfidence	{"tag": "NoConfidence", "contents": null}	\N	\N	\N	\N	\N
11	152	4	\N	1000000000	68	14	9	NewConstitution	{"tag": "NewConstitution", "contents": [null, {"anchor": {"url": "https://testing.this", "dataHash": "3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d"}}]}	\N	\N	\N	\N	\N
12	152	5	\N	1000000000	68	14	9	InfoAction	{"tag": "InfoAction"}	\N	\N	\N	\N	\N
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
9	1	156	9
10	1	156	10
11	1	156	11
12	-1	157	10
13	1	158	12
14	1	159	13
15	1	160	14
16	-1	161	12
17	-1	161	13
18	-1	161	14
19	-1	161	9
20	-1	161	11
21	1	166	15
22	-1	167	15
23	10	168	16
24	-10	169	16
25	1	393	17
26	1	393	18
27	1	393	19
28	1	394	20
29	1	395	21
30	1	396	22
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
9	1	195	9
10	1	195	10
11	1	195	11
12	1	198	9
13	1	198	11
14	1	199	12
15	1	201	13
16	1	202	9
17	1	202	11
18	1	203	14
19	1	261	15
20	10	264	16
21	1	1541	8
22	2	1543	5
23	1	1543	6
24	1	1543	7
25	13500000000000000	1545	1
26	13500000000000000	1545	2
27	13500000000000000	1545	3
28	13500000000000000	1545	4
29	1	1546	17
30	1	1546	18
31	1	1546	19
32	1	1548	20
33	1	1550	21
34	1	1552	22
\.


--
-- Data for Name: meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meta (id, start_time, network_name, version) FROM stdin;
1	2024-03-27 11:31:34	testnet	Version {versionBranch = [13,2,0,1], versionTags = []}
\.


--
-- Data for Name: multi_asset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.multi_asset (id, policy, name, fingerprint) FROM stdin;
1	\\x3abbdda5125f6527b0217d8f1ee3f5d7b7fb8587b049f0f61c41137c	\\x	asset1d06wtup9f9c7yfaepkzvkc3mlcnzsxwjes905n
2	\\x3abbdda5125f6527b0217d8f1ee3f5d7b7fb8587b049f0f61c41137c	\\x74425443	asset1cdjp3p7t289829849r23rseyuw9ucu52ef7wju
3	\\x3abbdda5125f6527b0217d8f1ee3f5d7b7fb8587b049f0f61c41137c	\\x74455448	asset1mfvctu6fc6d8ldlpe5a76y8hkzg3swq9rfrn3m
4	\\x3abbdda5125f6527b0217d8f1ee3f5d7b7fb8587b049f0f61c41137c	\\x744d494e	asset14a0cuvn79v43w9gz76sn6ly0lvy0xxffrk3nsn
5	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x646f75626c6568616e646c65	asset1fft9svnyg59cd25v68czjlgpkhkftkuzrjsgv5
6	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x68656c6c6f68616e646c65	asset128lx4yyq873l0nsccvh6wl8ztrss7ckt8u2uuw
7	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x7465737468616e646c65	asset1rjn5efmc9704ftasgac0tlpq9ezcquqh4awd3u
8	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x283232322968616e646c653638	asset1ju4qkyl4p9xszrgfxfmu909q90luzqu0nyh4u8
9	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d303031	asset1p7xl6rzm50j2p6q2z7kd5wz3ytyjtxts8g8drz
10	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d303032	asset1ftcuk4459tu0kfkf2s6m034q8uudr20w7wcxej
11	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d66696c6573	asset1xac6dlxa7226c65wp8u5d4mrz5hmpaeljvcr29
12	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d76312d686578	asset1v2z720699zh5x5mzk23gv829akydgqz2zy9f6l
13	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d76312d75746638	asset16unjfedceaaven5ypjmxf5m2qd079td0g8hldp
14	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d7632	asset1yc673t4h5w5gfayuedepzfrzmtuj3s9hay9kes
15	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x	asset1qrmynj6uhyk2hn9pc3yh0p80rg598n4yy77ays
16	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	\\x3030303030	asset1ul4zmmx2h8rqz9wswvc230w909pq2q0hne02q0
17	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x000643b068616e646c6532	asset1vjzkdxns6ze7ph4880h3m3zghvesral9ryp2zq
18	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x000de14068616e646c6532	asset1050jtqadfpvyfta8l86yrxgj693xws6l0qa87c
19	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x68616e646c6531	asset1q0g92m9xjj3nevsw26hfl7uf74av7yce5l56jv
20	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x000de14068616e646c	asset1we79wndeyvn4qfj8ty20d0q5ng6purl4vvts9a
21	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x000de1407375624068616e646c	asset1z7ety469aym7j5knvpkevnth4n4y9ma4uedh6h
22	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x000000007669727475616c4068616e646c	asset1d7u59dapth4x73dh8gd85q9lt9dlda4mrm6mlg
\.


--
-- Data for Name: new_committee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.new_committee (id, gov_action_proposal_id, deleted_members, added_members, quorum_numerator, quorum_denominator) FROM stdin;
\.


--
-- Data for Name: new_committee_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.new_committee_info (id, gov_action_proposal_id, quorum_numerator, quorum_denominator) FROM stdin;
\.


--
-- Data for Name: new_committee_member; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.new_committee_member (id, gov_action_proposal_id, committee_hash_id, expiration_epoch) FROM stdin;
\.


--
-- Data for Name: off_chain_pool_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.off_chain_pool_data (id, pool_id, ticker_name, hash, json, bytes, pmr_id) FROM stdin;
1	10	SP1	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	{"name": "stake pool - 1", "ticker": "SP1", "homepage": "https://stakepool1.com", "description": "This is the stake pool 1 description."}	\\x7b0a2020226e616d65223a20227374616b6520706f6f6c202d2031222c0a2020227469636b6572223a2022535031222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2031206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c312e636f6d220a7d0a	1
2	5	SP3	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	{"name": "Stake Pool - 3", "ticker": "SP3", "homepage": "https://stakepool3.com", "description": "This is the stake pool 3 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2033222c0a2020227469636b6572223a2022535033222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2033206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c332e636f6d220a7d0a	2
3	2	SP4	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	{"name": "Same Name", "ticker": "SP4", "homepage": "https://stakepool4.com", "description": "This is the stake pool 4 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535034222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2034206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c342e636f6d220a7d0a	3
4	3	SP5	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	{"name": "Same Name", "ticker": "SP5", "homepage": "https://stakepool5.com", "description": "This is the stake pool 5 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535035222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2035206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c352e636f6d220a7d0a	4
5	9	SP6a7	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	{"name": "Stake Pool - 6", "ticker": "SP6a7", "homepage": "https://stakepool6.com", "description": "This is the stake pool 6 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2036222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2036206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c362e636f6d220a7d0a	5
6	1	SP6a7	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	{"name": "", "ticker": "SP6a7", "homepage": "https://stakepool7.com", "description": "This is the stake pool 7 description."}	\\x7b0a2020226e616d65223a2022222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2037206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c372e636f6d220a7d0a	6
7	7	SP10	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	{"name": "Stake Pool - 10", "ticker": "SP10", "homepage": "https://stakepool10.com", "description": "This is the stake pool 10 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130222c0a2020227469636b6572223a202253503130222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203130206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31302e636f6d220a7d0a	7
8	4	SP11	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	{"name": "Stake Pool - 10 + 1", "ticker": "SP11", "homepage": "https://stakepool11.com", "description": "This is the stake pool 11 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130202b2031222c0a2020227469636b6572223a202253503131222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203131206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31312e636f6d220a7d0a	8
\.


--
-- Data for Name: off_chain_pool_fetch_error; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.off_chain_pool_fetch_error (id, pool_id, fetch_time, pmr_id, fetch_error, retry_count) FROM stdin;
\.


--
-- Data for Name: off_chain_vote_author; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.off_chain_vote_author (id, off_chain_vote_data_id, name, witness_algorithm, public_key, signature, warning) FROM stdin;
\.


--
-- Data for Name: off_chain_vote_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.off_chain_vote_data (id, voting_anchor_id, hash, json, bytes, warning, language, comment, title, abstract, motivation, rationale, is_valid) FROM stdin;
\.


--
-- Data for Name: off_chain_vote_external_update; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.off_chain_vote_external_update (id, off_chain_vote_data_id, title, uri) FROM stdin;
\.


--
-- Data for Name: off_chain_vote_fetch_error; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.off_chain_vote_fetch_error (id, voting_anchor_id, fetch_error, fetch_time, retry_count) FROM stdin;
1	1	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this'.	2024-03-27 11:46:41.324683	0
2	9	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this'.	2024-03-27 11:46:41.324683	0
3	9	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this'.	2024-03-27 11:51:41.392363	1
4	1	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this'.	2024-03-27 11:51:41.392363	1
5	1	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this'.	2024-03-27 11:56:41.403724	2
6	9	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this'.	2024-03-27 11:56:41.403724	2
7	9	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this'.	2024-03-27 12:06:41.416669	3
8	1	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this'.	2024-03-27 12:06:41.416669	3
\.


--
-- Data for Name: off_chain_vote_reference; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.off_chain_vote_reference (id, off_chain_vote_data_id, label, uri, hash_digest, hash_algorithm) FROM stdin;
\.


--
-- Data for Name: param_proposal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.param_proposal (id, epoch_no, key, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, entropy, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, registered_tx_id, coins_per_utxo_size, pvt_motion_no_confidence, pvt_committee_normal, pvt_committee_no_confidence, pvt_hard_fork_initiation, dvt_motion_no_confidence, dvt_committee_normal, dvt_committee_no_confidence, dvt_update_to_constitution, dvt_hard_fork_initiation, dvt_p_p_network_group, dvt_p_p_economic_group, dvt_p_p_technical_group, dvt_p_p_gov_group, dvt_treasury_withdrawal, committee_min_size, committee_max_term_length, gov_action_lifetime, gov_action_deposit, drep_deposit, drep_activity, pvtpp_security_group) FROM stdin;
2	\N	\N	\N	\N	\N	2000	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	152	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: pool_hash; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_hash (id, hash_raw, view) FROM stdin;
1	\\x259a650c0f4200fa94e83c3877f5560cfa2f09810513a77250437a47	pool1ykdx2rq0ggq0498g8su80a2kpnaz7zvpq5f6wujsgdayw2qd5uf
2	\\x29474e9e14b2437f195d17ba47a1111a283da04eddde0973af5c268c	pool199r5a8s5kfph7x2az7ay0gg3rg5rmgzwmh0qjua0tsngc4s6fks
3	\\x418ff5d8a75a4f212ea6697b567fe0d1c056a0b9322232ea6a46f9f3	pool1gx8ltk98tf8jzt4xd9a4vllq68q9dg9exg3r96n2gmulxmvhvu5
4	\\x5ddf0e2b2e12b6e35e7a0e10682f9246891afea34f48b93017db793c	pool1th0su2ewz2mwxhn6pcgxstujg6y34l4rfaytjvqhmdunc3pswcq
5	\\x5e34750a822ad086e5eaf701a365948ad23dae5eb53ae984bc5c460c	pool1tc682z5z9tggde027uq6xev53tfrmtj7k5awnp9ut3rqch6p648
6	\\x5eba2c3d0647284da8c04a31f34683a3592e9da5cad5789456ce7404	pool1t6azc0gxgu5ym2xqfgclx35r5dvja8d9et2h39zkee6qgj29ple
7	\\x6d4cf9761d6f392cf234b823452949ca954a3cdc13c6f444003c1f52	pool1d4x0jasaduujeu35hq35222fe22550xuz0r0g3qq8s04yfhkr64
8	\\x82f1945f900175bf8afcab41c8fc6ef1aaa5725ee6de59c72cd85ebc	pool1stceghusq96mlzhu4dqu3lrw7x422uj7um09n3evmp0tcdm305s
9	\\xbaed3f56e6b79df1947463ca22f4d4015a36cc0319ba2dbdc52aadbd	pool1htkn74hxk7wlr9r5v09z9ax5q9drdnqrrxazm0w992km6jdnlut
10	\\xd266b3cc73eb82e2b07b43f4da16d13d46f414560f73d440de62f12c	pool16fnt8nrnawpw9vrmg06d59k384r0g9zkpaeagsx7vtcjcuvrs9v
11	\\xf2960a6df8852fa6c27c7675278b4bfe746cf9db459e6ea3c362b645	pool172tq5m0cs5h6dsnuwe6j0z6tle6xe7wmgk0xag7rv2my2s6gdhu
12	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
13	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_metadata_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata_ref (id, pool_id, url, hash, registered_tx_id) FROM stdin;
1	10	http://file-server/SP1.json	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	61
2	5	http://file-server/SP3.json	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	71
3	2	http://file-server/SP4.json	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	76
4	3	http://file-server/SP5.json	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	81
5	9	http://file-server/SP6.json	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	86
6	1	http://file-server/SP7.json	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	91
7	7	http://file-server/SP10.json	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	110
8	4	http://file-server/SP11.json	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	117
\.


--
-- Data for Name: pool_owner; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_owner (id, addr_id, pool_update_id) FROM stdin;
1	21	12
2	19	13
3	16	14
4	13	15
5	14	16
6	20	17
7	12	18
8	17	19
9	22	20
10	18	21
11	15	22
12	70	23
13	67	24
\.


--
-- Data for Name: pool_relay; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_relay (id, update_id, ipv4, ipv6, dns_name, dns_srv_name, port) FROM stdin;
1	12	127.0.0.1	\N	\N	\N	3001
2	13	127.0.0.1	\N	\N	\N	3002
3	14	127.0.0.1	\N	\N	\N	3003
4	15	127.0.0.1	\N	\N	\N	3004
5	16	127.0.0.1	\N	\N	\N	3005
6	17	127.0.0.1	\N	\N	\N	3006
7	18	127.0.0.1	\N	\N	\N	3007
8	19	127.0.0.1	\N	\N	\N	3008
9	20	127.0.0.1	\N	\N	\N	3009
10	21	127.0.0.1	\N	\N	\N	30010
11	22	127.0.0.1	\N	\N	\N	30011
12	23	127.0.0.1	\N	\N	\N	6000
13	24	127.0.0.2	\N	\N	\N	6000
\.


--
-- Data for Name: pool_retire; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retire (id, hash_id, cert_index, announced_tx_id, retiring_epoch) FROM stdin;
1	6	0	98	5
2	11	0	105	18
3	7	0	112	5
4	4	0	119	18
\.


--
-- Data for Name: pool_update; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_update (id, hash_id, cert_index, vrf_key_hash, pledge, active_epoch_no, meta_id, margin, fixed_cost, registered_tx_id, reward_addr_id) FROM stdin;
1	1	0	\\xc046763fc364d8e5161ed660fb7d7580a6a851d39b0a8170bcdb92a3a172619a	0	2	\N	0	0	34	12
2	2	1	\\xfae848169a78551cd35c323b19f424f1fcb69e657a0d19456277ae27d26add7e	0	2	\N	0	0	34	13
3	3	2	\\x6db19a457b87371b44973f105bf8ca83793fb99e8aa04825a0dee2c3f789c714	0	2	\N	0	0	34	14
4	4	3	\\xa80db6d05f0b640f5f38b2a35f9288f28c6c07a5f44e64e8317d8b4df6cb6e78	0	2	\N	0	0	34	15
5	5	4	\\xf93ab444b2a5c617dbbe9554d1fbee6ee82b394ac904c8450b743c3863dde39b	0	2	\N	0	0	34	16
6	6	5	\\x23407f14f6564d34e732ff329af7f3266a3b55837986799fd9345021a857df21	0	2	\N	0	0	34	17
7	7	6	\\xf9bbb87cf2d05a787efc51c3e24db565f1c10c90194c04b42557baad5aa4741d	0	2	\N	0	0	34	18
8	8	7	\\x902e025033617c4020f9600775536adab2befa6380d824ded888c3af1852045e	0	2	\N	0	0	34	19
9	9	8	\\xe1627b730c3bc41ce1d6f8fe64f39ff35fcfa8935e2d1764fda89284e9b4fd0f	0	2	\N	0	0	34	20
10	10	9	\\x07a3b65d1738dd7678f61c494b454be2160881625522c51167347578cb3d0a39	0	2	\N	0	0	34	21
11	11	10	\\xd12d394c1f3b2bc96f98c3beed7ddd4e2fe1062d7c3f32f501aa3bb8251e4463	0	2	\N	0	0	34	22
12	10	0	\\x07a3b65d1738dd7678f61c494b454be2160881625522c51167347578cb3d0a39	400000000	3	1	0.15	390000000	61	21
13	8	0	\\x902e025033617c4020f9600775536adab2befa6380d824ded888c3af1852045e	500000000	3	\N	0.15	390000000	66	19
14	5	0	\\xf93ab444b2a5c617dbbe9554d1fbee6ee82b394ac904c8450b743c3863dde39b	600000000	3	2	0.15	390000000	71	16
15	2	0	\\xfae848169a78551cd35c323b19f424f1fcb69e657a0d19456277ae27d26add7e	420000000	3	3	0.15	370000000	76	13
16	3	0	\\x6db19a457b87371b44973f105bf8ca83793fb99e8aa04825a0dee2c3f789c714	410000000	3	4	0.15	390000000	81	14
17	9	0	\\xe1627b730c3bc41ce1d6f8fe64f39ff35fcfa8935e2d1764fda89284e9b4fd0f	410000000	3	5	0.15	400000000	86	20
18	1	0	\\xc046763fc364d8e5161ed660fb7d7580a6a851d39b0a8170bcdb92a3a172619a	410000000	3	6	0.15	390000000	91	12
19	6	0	\\x23407f14f6564d34e732ff329af7f3266a3b55837986799fd9345021a857df21	500000000	3	\N	0.15	380000000	96	17
20	11	0	\\xd12d394c1f3b2bc96f98c3beed7ddd4e2fe1062d7c3f32f501aa3bb8251e4463	500000000	3	\N	0.15	390000000	103	22
21	7	0	\\xf9bbb87cf2d05a787efc51c3e24db565f1c10c90194c04b42557baad5aa4741d	400000000	4	7	0.15	410000000	110	18
22	4	0	\\xa80db6d05f0b640f5f38b2a35f9288f28c6c07a5f44e64e8317d8b4df6cb6e78	400000000	4	8	0.15	390000000	117	15
23	12	0	\\x2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	500000000000000	15	\N	0.2	1000	386	70
24	13	0	\\x641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	50000000	15	\N	0.2	1000	390	67
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
2	4	::
3	5	1:34:
4	6	4:40:
5	7	::
6	8	::
7	9	::
8	10	12:56:
9	11	19:63:
10	12	21:65:
11	13	::
12	14	::
13	15	::
14	16	::
15	17	::
16	18	::
17	19	::
18	20	::
19	21	23:67:
20	22	::
21	23	24:69:
22	24	::
23	25	25:70:
24	26	::
25	27	::
26	28	26:71:
27	29	::
28	30	::
29	31	27:72:
30	32	28:73:
31	33	::
32	34	29:75:
33	35	30:76:
34	36	31:77:
35	37	32:78:
36	38	::
37	39	33:79:
38	40	::
39	41	::
40	42	34:81:
41	43	::
42	44	::
43	45	::
44	46	35:82:
45	47	::
46	48	::
47	49	::
48	50	::
49	51	36:83:
50	52	::
51	53	::
52	54	::
53	55	::
54	56	37:84:
55	57	::
56	58	38:85:
57	59	::
58	60	::
59	61	39:87:
60	62	::
61	63	::
62	64	::
63	65	40:88:
64	66	::
65	67	41:89:
66	68	::
67	69	42:90:
68	70	::
69	71	::
70	72	43:91:
71	73	::
72	74	::
73	75	::
74	76	44:93:
75	77	45:94:
76	78	::
77	79	46:95:
78	80	47:96:
79	81	48:97:
80	82	::
81	83	49:99:
82	84	50:100:
83	85	::
84	86	::
85	87	::
86	88	51:101:
87	89	52:102:
88	90	53:103:
89	91	::
90	92	::
91	93	::
92	94	::
93	95	54:105:
94	96	::
95	97	55:106:
96	98	56:107:
97	99	::
98	100	57:108:
99	101	::
100	102	::
101	103	58:109:
102	104	::
103	105	::
104	106	59:111:
105	107	::
106	108	60:112:
107	109	::
108	110	::
109	111	::
110	112	61:113:
111	113	::
112	114	::
113	115	62:114:
114	116	::
115	117	63:115:
116	118	::
117	119	64:116:
118	120	65:117:
119	121	::
120	122	::
121	123	66:119:
122	124	::
123	125	67:120:
124	126	::
125	127	::
126	128	::
127	129	::
128	130	68:121:
129	131	::
130	132	::
131	133	69:122:
132	134	70:123:
133	135	::
134	136	71:124:
135	137	::
136	138	72:125:
137	139	::
138	140	::
139	141	73:127:
140	142	::
141	143	::
142	144	74:128:
143	145	75:129:
144	146	76:130:
145	147	77:131:
146	148	::
147	149	78:132:
148	150	::
149	151	79:133:
150	152	::
151	153	80:135:
152	154	81:136:
153	155	82:137:
154	156	83:138:
155	157	84:139:
156	158	85:140:
157	159	86:141:
158	160	87:143:
159	161	88:144:
160	162	89:146:
161	163	::
162	164	90:148:
163	165	::
164	166	91:150:
165	167	92:152:
166	168	::
167	169	93:154:
168	170	94:156:
169	171	96:157:1
170	172	97:159:
171	173	98:165:5
172	174	::
173	175	99:167:8
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
224	226	::
225	227	::
226	228	::
227	229	::
228	230	::
229	231	::
230	232	::
231	233	::
232	234	::
233	235	::
234	236	::
235	237	::
236	238	::
237	239	::
238	240	::
239	241	::
240	242	::
241	243	::
242	244	::
243	245	::
244	246	::
245	247	::
246	248	::
247	249	::
248	250	::
249	251	::
250	252	::
251	253	::
252	254	::
253	255	::
254	256	::
255	257	::
256	258	::
257	259	::
258	260	::
259	261	::
260	262	::
261	263	::
262	264	::
263	265	::
264	266	::
265	267	::
266	268	::
267	269	::
268	270	::
269	271	::
270	272	::
271	273	::
272	274	::
273	275	::
274	276	::
275	277	::
276	278	::
277	279	::
278	280	::
279	281	::
280	282	::
281	283	::
282	284	::
283	285	::
284	286	::
285	287	::
286	288	::
287	289	::
288	290	::
289	291	::
290	292	::
291	293	::
292	294	::
293	295	::
294	296	::
295	297	::
296	298	::
297	299	::
298	300	::
299	301	::
300	302	::
301	303	::
302	304	::
303	305	::
304	306	::
305	307	::
306	308	::
307	309	::
308	310	::
309	311	::
310	312	::
311	313	::
312	314	::
313	315	::
314	316	::
315	317	::
316	318	::
317	319	::
318	320	::
319	321	::
320	322	::
321	323	::
322	324	::
323	325	::
324	326	::
325	327	::
326	328	::
327	329	::
328	330	::
329	331	::
330	332	::
331	333	::
332	334	::
333	335	::
334	336	::
335	337	::
336	338	::
337	339	::
338	340	::
339	341	::
340	342	::
341	343	::
342	344	::
343	345	::
344	346	::
345	347	::
346	348	::
347	349	::
348	350	::
349	351	::
350	352	::
351	353	::
352	354	::
353	355	::
354	356	::
355	357	::
356	358	::
357	359	::
358	360	::
359	361	::
360	362	::
361	363	::
362	364	::
363	365	::
364	366	::
365	367	::
366	368	::
367	369	::
368	370	::
369	371	::
370	372	::
371	373	::
372	374	::
373	375	::
374	376	::
375	377	::
376	378	::
377	379	::
378	380	::
379	381	::
380	382	::
381	383	::
382	384	::
383	385	::
384	386	::
385	387	::
386	388	::
387	389	::
388	390	::
389	391	::
390	392	::
391	393	::
392	394	::
393	395	::
394	396	::
395	397	::
396	398	::
397	399	::
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
437	439	100:169:
438	440	::
439	441	::
440	442	::
441	443	::
442	444	::
443	445	::
444	446	103:173:
445	447	::
446	448	104:175:
447	449	::
448	450	105:176:
449	451	::
450	452	106:177:
451	453	::
452	454	107:178:
453	455	::
454	456	108:179:
455	457	::
456	458	109:180:
457	459	::
458	460	110:181:
459	461	::
460	462	111:182:
461	463	::
462	464	112:183:
463	465	::
464	466	113:184:
465	467	::
466	468	114:185:
467	469	::
468	470	115:186:
469	471	::
470	472	116:187:
471	473	::
472	474	117:188:
473	475	::
474	476	118:189:
475	477	::
477	479	120:191:
478	480	::
479	481	121:192:
480	482	::
481	483	122:193:
482	484	::
483	485	123:194:
484	486	::
485	487	::
486	488	124:195:9
488	490	::
489	491	::
490	492	::
491	493	125:197:12
492	494	::
493	495	::
494	496	::
495	497	127:199:14
496	498	::
497	499	::
498	500	::
499	501	128:201:15
500	502	::
501	503	::
502	504	::
503	505	129:203:18
504	506	::
505	507	::
506	508	::
507	509	130:205:
508	510	::
509	511	::
510	512	::
511	513	::
512	514	::
513	515	134:206:
514	516	::
515	517	::
516	518	::
517	519	136:208:
518	520	::
519	521	::
520	522	::
521	523	137:243:
522	524	::
523	525	::
524	526	::
525	527	172:252:
526	528	::
527	529	::
528	530	::
529	531	::
530	532	181:261:19
531	533	::
532	534	::
533	535	::
534	536	182:263:
535	537	::
536	538	::
537	539	::
538	540	183:264:20
539	541	::
540	542	::
541	543	::
542	544	184:266:
543	545	::
545	547	::
546	548	::
547	549	::
548	550	::
549	551	185:267:
550	552	::
551	553	::
552	554	186:387:
553	555	::
554	556	246:389:
555	557	::
556	558	247:391:
557	559	::
558	560	248:392:
559	561	::
560	562	::
561	563	::
562	564	250:394:
563	565	::
564	566	::
565	567	::
566	568	::
567	569	::
568	570	251:396:
569	571	252:398:
570	572	253:400:
571	573	::
572	574	::
573	575	::
574	576	254:401:
575	577	255:403:
576	578	::
577	579	::
578	580	::
579	581	::
580	582	::
581	583	256:405:
582	584	::
583	585	::
584	586	::
585	587	::
586	588	::
587	589	::
588	590	258:407:
589	591	::
590	592	::
591	593	::
592	594	::
594	596	::
595	597	::
596	598	::
597	599	::
598	600	::
599	601	::
600	602	::
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
623	625	::
624	626	::
625	627	::
627	629	::
628	630	::
629	631	::
630	632	::
631	633	::
632	634	::
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
683	685	::
684	686	::
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
729	731	::
730	732	::
732	734	::
733	735	::
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
748	750	259:408:
749	751	280:446:
750	752	::
751	753	::
752	754	::
753	755	::
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
845	847	::
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
911	913	::
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
931	933	391:608:
932	934	::
933	935	::
934	936	::
935	937	::
936	938	392:610:
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
976	978	::
977	979	::
978	980	::
979	981	::
980	982	::
981	983	::
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
993	995	::
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
1053	1055	::
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
1073	1075	::
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
1119	1121	::
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
1138	1140	527:624:
1139	1141	550:642:
1140	1142	640:732:
1141	1143	1027:1119:
1142	1144	::
1143	1145	1045:1137:
1144	1146	1180:1272:
1145	1147	::
1146	1148	::
1147	1149	::
1148	1150	::
1149	1151	::
1150	1152	::
1151	1153	::
1153	1155	::
1154	1156	::
1155	1157	::
1156	1158	::
1157	1159	::
1158	1160	::
1159	1161	::
1160	1162	::
1161	1163	::
1162	1164	::
1163	1165	::
1164	1166	::
1165	1167	::
1166	1168	::
1167	1169	::
1168	1170	::
1169	1171	::
1170	1172	::
1171	1173	::
1172	1174	::
1173	1175	::
1174	1176	::
1175	1177	::
1176	1178	::
1177	1179	::
1178	1180	::
1179	1181	::
1180	1182	::
1181	1183	::
1182	1184	::
1183	1185	::
1184	1186	::
1185	1187	::
1186	1188	::
1187	1189	::
1188	1190	::
1189	1191	::
1190	1192	::
1191	1193	::
1192	1194	::
1193	1195	::
1194	1196	::
1195	1197	::
1196	1198	::
1197	1199	::
1198	1200	::
1199	1201	::
1200	1202	::
1201	1203	::
1202	1204	::
1203	1205	::
1204	1206	::
1205	1207	::
1206	1208	::
1207	1209	::
1208	1210	::
1209	1211	::
1210	1212	::
1211	1213	::
1212	1214	::
1213	1215	::
1214	1216	::
1215	1217	::
1216	1218	::
1217	1219	::
1218	1220	::
1219	1221	::
1220	1222	::
1221	1223	::
1222	1224	::
1223	1225	::
1224	1226	::
1225	1227	::
1226	1228	::
1227	1229	::
1228	1230	::
1229	1231	::
1230	1232	::
1231	1233	::
1232	1234	::
1233	1235	::
1235	1237	::
1236	1238	::
1237	1239	::
1238	1240	::
1239	1241	::
1240	1242	::
1241	1243	::
1242	1244	::
1243	1245	::
1244	1246	::
1245	1247	::
1246	1248	::
1247	1249	::
1248	1250	::
1249	1251	::
1250	1252	::
1251	1253	::
1252	1254	::
1253	1255	::
1254	1256	::
1255	1257	::
1256	1258	::
1257	1259	::
1258	1260	::
1259	1261	::
1260	1262	::
1261	1263	::
1262	1264	::
1263	1265	::
1264	1266	::
1265	1267	::
1266	1268	::
1267	1269	::
1268	1270	::
1269	1271	::
1270	1272	::
1271	1273	::
1272	1274	::
1273	1275	::
1274	1276	::
1275	1277	::
1276	1278	::
1277	1279	::
1278	1280	::
1279	1281	::
1280	1282	::
1281	1283	::
1282	1284	::
1283	1285	::
1284	1286	::
1285	1287	::
1286	1288	::
1287	1289	::
1288	1290	::
1289	1291	::
1290	1292	::
1291	1293	::
1292	1294	::
1293	1295	::
1294	1296	::
1295	1297	::
1296	1298	::
1297	1299	::
1298	1300	::
1299	1301	::
1300	1302	::
1301	1303	::
1302	1304	::
1303	1305	::
1304	1306	::
1305	1307	::
1306	1308	::
1307	1309	::
1309	1311	::
1310	1312	::
1311	1313	::
1312	1314	::
1313	1315	::
1314	1316	::
1315	1317	::
1316	1318	::
1317	1319	::
1318	1320	::
1319	1321	::
1320	1322	::
1321	1323	::
1322	1324	::
1323	1325	::
1325	1327	::
1326	1328	::
1327	1329	::
1328	1330	::
1329	1331	::
1330	1332	::
1331	1333	::
1332	1334	::
1333	1335	::
1334	1336	::
1335	1337	1432:1524:
1336	1338	::
1337	1339	::
1338	1340	::
1339	1341	::
1340	1342	::
1341	1343	1441:1533:
1342	1344	::
1343	1345	::
1344	1346	::
1345	1347	1442:1535:
1346	1348	::
1347	1349	::
1348	1350	::
1349	1351	1444:1537:
1350	1352	::
1351	1353	::
1352	1354	::
1353	1355	1445:1539:
1354	1356	::
1355	1357	1446:1540:21
1356	1358	::
1357	1359	::
1358	1360	::
1359	1361	1447:1542:22
1360	1362	::
1361	1363	::
1362	1364	::
1363	1365	::
1364	1366	1448:1544:25
1365	1367	::
1366	1368	::
1368	1370	::
1369	1371	1449:1546:29
1370	1372	::
1371	1373	::
1372	1374	::
1373	1375	1450:1548:32
1374	1376	::
1375	1377	::
1376	1378	::
1377	1379	1451:1550:33
1378	1380	::
1379	1381	::
1380	1382	::
1381	1383	1452:1552:34
1383	1385	::
1384	1386	::
1385	1387	::
1386	1388	::
1387	1389	::
1388	1390	::
1389	1391	::
1390	1392	::
1391	1393	::
\.


--
-- Data for Name: reward; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward (addr_id, type, amount, spendable_epoch, pool_id) FROM stdin;
1	member	6903305405273	3	1
2	member	5369237537435	3	10
10	member	8437373273112	3	4
6	member	8437373273112	3	7
11	member	8437373273112	3	9
4	member	10738475074870	3	8
7	member	7670339339192	3	6
3	member	5369237537435	3	3
8	member	14573644744466	3	5
5	member	7670339339192	3	11
9	member	4602203603515	3	2
12	leader	0	3	1
20	leader	0	3	9
18	leader	0	3	7
17	leader	0	3	6
19	leader	0	3	8
13	leader	0	3	2
14	leader	0	3	3
15	leader	0	3	4
21	leader	0	3	10
16	leader	0	3	5
22	leader	0	3	11
12	member	556091	4	1
20	member	444873	4	9
1	member	8644696562070	4	1
2	member	7780226905863	4	10
42	member	278045414	4	11
36	member	500481933	4	5
17	member	166827	4	6
41	member	278045414	4	6
10	member	5187485935252	4	4
19	member	667309	4	8
13	member	389264	4	2
39	member	444872795	4	9
6	member	4322904946043	4	7
35	member	556090983	4	8
11	member	6915757249656	4	9
4	member	8644696339642	4	8
7	member	4322348503650	4	6
3	member	6915757249656	4	3
14	member	444873	4	3
8	member	7780227506404	4	5
5	member	4322348503650	4	11
40	member	556090994	4	1
37	member	389263696	4	2
21	member	500482	4	10
38	member	444872795	4	3
16	member	200192	4	5
22	member	166827	4	11
9	member	6051287593449	4	2
34	member	500481895	4	10
12	leader	0	4	1
20	leader	0	4	9
18	leader	0	4	7
17	leader	0	4	6
19	leader	0	4	8
13	leader	0	4	2
14	leader	0	4	3
15	leader	0	4	4
21	leader	0	4	10
16	leader	0	4	5
22	leader	0	4	11
1	member	7227840866520	5	1
2	member	5059389162967	5	10
44	member	437618340	5	4
18	member	601726	5	7
43	member	601725218	5	7
10	member	6802985736946	5	4
39	member	371953851	5	9
6	member	9354105388300	5	7
35	member	325457426	5	8
11	member	5782197898032	5	9
4	member	5059389032785	5	8
3	member	5059389162967	5	3
15	member	437618	5	4
40	member	464948328	5	1
37	member	557943352	5	2
38	member	325457433	5	3
12	leader	1275973926089	5	1
20	leader	1020853940866	5	9
18	leader	0	5	7
17	leader	0	5	6
19	leader	893281251860	5	8
13	leader	1531085411313	5	2
14	leader	893281198256	5	3
15	leader	0	5	4
21	leader	893281198256	5	10
16	leader	0	5	5
22	leader	0	5	11
9	member	8673492334461	5	2
34	member	325457433	5	10
1	member	2842974391205	6	1
2	member	6398368327903	6	10
44	member	502316010	6	4
43	member	182645720	6	7
10	member	7817218317013	6	4
39	member	456648597	6	9
6	member	2842396902666	6	7
35	member	319459036	6	8
11	member	7106523472174	6	9
4	member	4973002247989	6	8
3	member	7109334973079	6	3
40	member	182718916	6	1
37	member	274252330	6	2
38	member	457009458	6	3
9	member	4265906048810	6	2
34	member	411306381	6	10
12	leader	502123822632	6	1
20	leader	1254573499723	6	9
18	leader	502041899887	6	7
17	leader	0	6	6
19	leader	878035458123	6	8
13	leader	753225669910	6	2
14	leader	1255059711047	6	3
15	leader	1379988349729	6	4
21	leader	1129586889940	6	10
16	leader	0	6	5
22	leader	0	6	11
1	member	6297192194494	7	1
2	member	6299132066476	7	10
44	member	179753978	7	4
43	member	359608004	7	7
10	member	2799259540189	7	4
39	member	584508255	7	9
6	member	5599455271259	7	7
35	member	539106774	7	8
11	member	9096310944579	7	9
4	member	8392234328800	7	8
3	member	6299831576687	7	3
40	member	404723050	7	1
37	member	495124584	7	2
38	member	404972390	7	3
9	member	7701498780132	7	2
34	member	404927455	7	10
12	leader	1111731108653	7	1
20	leader	1605735179334	7	9
18	leader	988613048821	7	7
17	leader	0	7	6
19	leader	1481468426194	7	8
13	leader	1359545977450	7	2
14	leader	1112196926275	7	3
15	leader	494408910446	7	4
21	leader	1112073475314	7	10
16	leader	0	7	5
22	leader	0	7	11
1	member	5874511369984	8	1
2	member	5878532769748	8	10
44	member	188723690	8	4
43	member	415173003	8	7
79	member	752957	8	1
10	member	2938937918469	8	4
39	member	604151912	8	9
6	member	6464644996024	8	7
35	member	339593245	8	8
11	member	9402004463485	8	9
4	member	5286417602063	8	8
3	member	7643039934619	8	3
40	member	377557496	8	1
12	leader	1038266910350	8	1
20	leader	1661133396737	8	9
18	leader	1141303459444	8	7
17	leader	0	8	6
19	leader	934060145826	8	8
13	leader	1350434282841	8	2
14	leader	1350280117768	8	3
15	leader	519059629468	8	4
37	member	491162315	8	2
21	leader	1038638221680	8	10
38	member	491318141	8	3
16	leader	0	8	5
22	leader	0	8	11
9	member	7639861965238	8	2
34	member	377890216	8	10
1	member	5520662485128	9	1
2	member	5528103307089	9	10
44	member	177429385	9	4
79	member	707345	9	1
10	member	2763053228304	9	4
39	member	355034691	9	9
35	member	319428569	9	8
11	member	5525162955649	9	9
4	member	4972515901677	9	8
3	member	6080870785938	9	3
40	member	354815468	9	1
37	member	497598947	9	2
38	member	390897098	9	3
9	member	7739981582448	9	2
34	member	355363529	9	10
68	member	3534631036	9	1
12	leader	976792369684	9	1
20	leader	977387836945	9	9
19	leader	879277753218	9	8
13	leader	1369005503455	9	2
14	leader	1075525402710	9	3
15	leader	488594186736	9	4
21	leader	977688017936	9	10
16	leader	0	9	5
22	leader	0	9	11
1	member	3809532557752	10	1
2	member	7629653235949	10	10
44	member	595110962	10	4
79	member	487709	10	1
10	member	9267479894540	10	4
39	member	384812284	10	9
35	member	349759961	10	8
11	member	5988571344454	10	9
4	member	5444681973747	10	8
3	member	7084565008624	10	3
40	member	244840376	10	1
37	member	210167930	10	2
38	member	455417653	10	3
9	member	3269090332764	10	2
34	member	490457640	10	10
68	member	2437103798	10	1
12	leader	674793588405	10	1
20	leader	1060776223402	10	9
19	leader	963946091524	10	8
13	leader	579101399696	10	2
14	leader	1254170789002	10	3
15	leader	1638552132046	10	4
21	leader	1350492461262	10	10
16	leader	0	10	5
22	leader	0	10	11
1	member	6443061317109	11	1
2	member	4962787425425	11	10
44	member	478428001	11	4
79	member	824863	11	1
10	member	7450412060691	11	4
39	member	445740955	11	9
35	member	414115490	11	8
11	member	6936762728435	11	9
4	member	6446498712357	11	8
3	member	5457363396418	11	3
40	member	414098457	11	1
37	member	287009017	11	2
38	member	350816123	11	3
9	member	4464327178986	11	2
34	member	319023281	11	10
68	member	4118758843	11	1
12	leader	1142013567160	11	1
20	leader	1230398076899	11	9
19	leader	1142143805291	11	8
13	leader	791601326791	11	2
14	leader	967306354507	11	3
15	leader	1317940906301	11	4
21	leader	879352954256	11	10
16	leader	0	11	5
22	leader	0	11	11
1	member	5789709694437	12	1
2	member	7378707550238	12	10
44	member	474436362	12	4
79	member	741219	12	1
10	member	7388251488541	12	4
39	member	473371087	12	9
35	member	304489109	12	8
11	member	7366751647346	12	9
4	member	4739954669053	12	8
3	member	4741376167938	12	3
40	member	372107253	12	1
37	member	338539122	12	2
38	member	304790259	12	3
9	member	5265860361050	12	2
34	member	474326077	12	10
68	member	3701104672	12	1
12	leader	1027097295015	12	1
20	leader	1307720126173	12	9
19	leader	840519019854	12	8
13	leader	934741106125	12	2
14	leader	841215164915	12	3
15	leader	1307491133103	12	4
21	leader	1308321075284	12	10
16	leader	0	12	5
22	leader	0	12	11
1	member	2072554028265	13	1
2	member	7773325244703	13	10
44	member	433042169	13	4
79	member	265335	13	1
10	member	6743632451827	13	4
39	member	498829494	13	9
35	member	432621631	13	8
11	member	7762943477957	13	9
4	member	6734582151550	13	8
3	member	5180455095320	13	3
40	member	133203982	13	1
37	member	199735356	13	2
38	member	333015604	13	3
9	member	3106815216036	13	2
34	member	499693320	13	10
95	member	992182669	13	2
68	member	662769010	13	1
12	leader	368015292131	13	1
20	leader	1379260519048	13	9
19	leader	1195027279166	13	8
13	leader	552085857898	13	2
14	leader	920053360379	13	3
15	leader	1195106773710	13	4
21	leader	1379842924487	13	10
16	leader	0	13	5
22	leader	0	13	11
1	member	3057532501494	14	1
2	member	4587841330377	14	10
44	member	556822507	14	4
79	member	391436	14	1
10	member	8671225580496	14	4
39	member	163496147	14	9
35	member	425461145	14	8
11	member	2544379130267	14	9
4	member	6623115518078	14	8
3	member	7133943824348	14	3
\.


--
-- Data for Name: schema_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_version (id, stage_one, stage_two, stage_three) FROM stdin;
1	13	36	6
\.


--
-- Data for Name: script; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.script (id, tx_id, hash, type, json, bytes, serialised_size) FROM stdin;
1	121	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	plutusV1	\N	\\x4d01000033222220051200120011	14
2	123	\\x477e52b3116b62fe8cd34a312615f5fcd678c94e1d6cdb86c1a3964c	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "e09d36c79dec9bd1b3d9e152247701cd0bb860b5ebfd1de8abb6735a"}, {"type": "sig", "keyHash": "a687dcc24e00dd3caafbeb5e68f97ca8ef269cb6fe971345eb951756"}, {"type": "sig", "keyHash": "0bd1d702b2e6188fe0857a6dc7ffb0675229bab58c86638ffa87ed6d"}]}	\N	\N
3	124	\\x120125c6dea2049988eb0dc8ddcc4c56dd48628d45206a2d0bc7e55b	timelock	{"type": "all", "scripts": [{"slot": 1000, "type": "after"}, {"type": "sig", "keyHash": "966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37"}]}	\N	\N
4	126	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	plutusV2	\N	\\x5908920100003233223232323232332232323232323232323232332232323232322223232533532323232325335001101d13357389211e77726f6e67207573616765206f66207265666572656e636520696e7075740001c3232533500221533500221333573466e1c00800408007c407854cd4004840784078d40900114cd4c8d400488888888888802d40044c08526221533500115333533550222350012222002350022200115024213355023320015021001232153353235001222222222222300e00250052133550253200150233355025200100115026320013550272253350011502722135002225335333573466e3c00801c0940904d40b00044c01800c884c09526135001220023333573466e1cd55cea80224000466442466002006004646464646464646464646464646666ae68cdc39aab9d500c480008cccccccccccc88888888888848cccccccccccc00403403002c02802402001c01801401000c008cd405c060d5d0a80619a80b80c1aba1500b33501701935742a014666aa036eb94068d5d0a804999aa80dbae501a35742a01066a02e0446ae85401cccd5406c08dd69aba150063232323333573466e1cd55cea801240004664424660020060046464646666ae68cdc39aab9d5002480008cc8848cc00400c008cd40b5d69aba15002302e357426ae8940088c98c80c0cd5ce01901a01709aab9e5001137540026ae854008c8c8c8cccd5cd19b8735573aa004900011991091980080180119a816bad35742a004605c6ae84d5d1280111931901819ab9c03203402e135573ca00226ea8004d5d09aba2500223263202c33573805c06005426aae7940044dd50009aba1500533501775c6ae854010ccd5406c07c8004d5d0a801999aa80dbae200135742a00460426ae84d5d1280111931901419ab9c02a02c026135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d55cf280089baa00135742a00860226ae84d5d1280211931900d19ab9c01c01e018375a00a6666ae68cdc39aab9d375400a9000100e11931900c19ab9c01a01c016101b132632017335738921035054350001b135573ca00226ea800448c88c008dd6000990009aa80d911999aab9f0012500a233500930043574200460066ae880080608c8c8cccd5cd19b8735573aa004900011991091980080180118061aba150023005357426ae8940088c98c8050cd5ce00b00c00909aab9e5001137540024646464646666ae68cdc39aab9d5004480008cccc888848cccc00401401000c008c8c8c8cccd5cd19b8735573aa0049000119910919800801801180a9aba1500233500f014357426ae8940088c98c8064cd5ce00d80e80b89aab9e5001137540026ae854010ccd54021d728039aba150033232323333573466e1d4005200423212223002004357426aae79400c8cccd5cd19b875002480088c84888c004010dd71aba135573ca00846666ae68cdc3a801a400042444006464c6403666ae7007407c06406005c4d55cea80089baa00135742a00466a016eb8d5d09aba2500223263201533573802e03202626ae8940044d5d1280089aab9e500113754002266aa002eb9d6889119118011bab00132001355018223233335573e0044a010466a00e66442466002006004600c6aae754008c014d55cf280118021aba200301613574200222440042442446600200800624464646666ae68cdc3a800a400046a02e600a6ae84d55cf280191999ab9a3370ea00490011280b91931900819ab9c01201400e00d135573aa00226ea80048c8c8cccd5cd19b875001480188c848888c010014c01cd5d09aab9e500323333573466e1d400920042321222230020053009357426aae7940108cccd5cd19b875003480088c848888c004014c01cd5d09aab9e500523333573466e1d40112000232122223003005375c6ae84d55cf280311931900819ab9c01201400e00d00c00b135573aa00226ea80048c8c8cccd5cd19b8735573aa004900011991091980080180118029aba15002375a6ae84d5d1280111931900619ab9c00e01000a135573ca00226ea80048c8cccd5cd19b8735573aa002900011bae357426aae7940088c98c8028cd5ce00600700409baa001232323232323333573466e1d4005200c21222222200323333573466e1d4009200a21222222200423333573466e1d400d2008233221222222233001009008375c6ae854014dd69aba135744a00a46666ae68cdc3a8022400c4664424444444660040120106eb8d5d0a8039bae357426ae89401c8cccd5cd19b875005480108cc8848888888cc018024020c030d5d0a8049bae357426ae8940248cccd5cd19b875006480088c848888888c01c020c034d5d09aab9e500b23333573466e1d401d2000232122222223005008300e357426aae7940308c98c804ccd5ce00a80b80880800780700680600589aab9d5004135573ca00626aae7940084d55cf280089baa0012323232323333573466e1d400520022333222122333001005004003375a6ae854010dd69aba15003375a6ae84d5d1280191999ab9a3370ea0049000119091180100198041aba135573ca00c464c6401866ae700380400280244d55cea80189aba25001135573ca00226ea80048c8c8cccd5cd19b875001480088c8488c00400cdd71aba135573ca00646666ae68cdc3a8012400046424460040066eb8d5d09aab9e500423263200933573801601a00e00c26aae7540044dd500089119191999ab9a3370ea00290021091100091999ab9a3370ea00490011190911180180218031aba135573ca00846666ae68cdc3a801a400042444004464c6401466ae7003003802001c0184d55cea80089baa0012323333573466e1d40052002200623333573466e1d40092000200623263200633573801001400800626aae74dd5000a4c244004244002921035054310012333333357480024a00c4a00c4a00c46a00e6eb400894018008480044488c0080049400848488c00800c4488004448c8c00400488cc00cc0080080041	2197
5	129	\\x3abbdda5125f6527b0217d8f1ee3f5d7b7fb8587b049f0f61c41137c	timelock	{"type": "sig", "keyHash": "55393b392d789cc58cae43b30185fb36eeee3198954bb8e03e8c5578"}	\N	\N
6	131	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	timelock	{"type": "sig", "keyHash": "5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967"}	\N	\N
7	156	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}]}	\N	\N
8	168	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}, {"type": "sig", "keyHash": "3178bf14adf78294ac2d03d60b9edfb7323d3d719e98b4b0b3ca34cd"}]}	\N	\N
9	177	\\xda336dc6885ad6718c652d764ab2e97a45fc895f5c13c7bfa474ea98	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "3d9cfb6171b45e4c1e1db1fd876de764930962f9abd6b0fba2f9bc4e"}, {"type": "sig", "keyHash": "04813036edd98bc62f57f56cd685c84d1e45ad09b5c11815fedb2a52"}, {"type": "sig", "keyHash": "0d57b5442cdd2460105b302540b9539f99ae692a5db4ac335f8393a6"}]}	\N	\N
10	180	\\x29f17f78a28a85f825b8d5ada46758cdc5acb4a2c407f162d944f476	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "bdc3630707ba9c0aa4cae2e564ba9f583ad1d905952c69aebf47b245"}, {"type": "sig", "keyHash": "b56e5bd2af975d2a4fca11e846af63fcaa502a9a83cdb04a232213b0"}, {"type": "sig", "keyHash": "3b8e6021ab8c33cc4a15b4e34569e0408eb3795b313c20498a6fb789"}]}	\N	\N
\.


--
-- Data for Name: slot_leader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slot_leader (id, hash, pool_hash_id, description) FROM stdin;
1	\\x888f329ccb0f8c1691ad701e931f3a13449060c2290aee9a3053eadf	\N	Genesis slot leader
2	\\x5368656c6c65792047656e6573697320536c6f744c65616465722048	\N	Shelley Genesis slot leader
29	\\xbaed3f56e6b79df1947463ca22f4d4015a36cc0319ba2dbdc52aadbd	9	Pool-baed3f56e6b79df1
9	\\x82f1945f900175bf8afcab41c8fc6ef1aaa5725ee6de59c72cd85ebc	8	Pool-82f1945f900175bf
24	\\xf2960a6df8852fa6c27c7675278b4bfe746cf9db459e6ea3c362b645	11	Pool-f2960a6df8852fa6
5	\\x6d4cf9761d6f392cf234b823452949ca954a3cdc13c6f444003c1f52	7	Pool-6d4cf9761d6f392c
7	\\x5eba2c3d0647284da8c04a31f34683a3592e9da5cad5789456ce7404	6	Pool-5eba2c3d0647284d
8	\\xd266b3cc73eb82e2b07b43f4da16d13d46f414560f73d440de62f12c	10	Pool-d266b3cc73eb82e2
28	\\x418ff5d8a75a4f212ea6697b567fe0d1c056a0b9322232ea6a46f9f3	3	Pool-418ff5d8a75a4f21
32	\\x29474e9e14b2437f195d17ba47a1111a283da04eddde0973af5c268c	2	Pool-29474e9e14b2437f
4	\\x259a650c0f4200fa94e83c3877f5560cfa2f09810513a77250437a47	1	Pool-259a650c0f4200fa
17	\\x5ddf0e2b2e12b6e35e7a0e10682f9246891afea34f48b93017db793c	4	Pool-5ddf0e2b2e12b6e3
3	\\x5e34750a822ad086e5eaf701a365948ad23dae5eb53ae984bc5c460c	5	Pool-5e34750a822ad086
\.


--
-- Data for Name: stake_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_address (id, hash_raw, view, script_hash) FROM stdin;
1	\\xe01f9704b45ddb3b50193318f3a1d6d83a826f717e56d28bc0e40a4b24	stake_test1uq0ewp95thdnk5qexvv08gwkmqagymm30etd9z7qus9ykfqz9vw7v	\N
2	\\xe034dcf6357c055ce1c8c3ee8d7e988a90de0242290e7b1bb98e2a46cd	stake_test1uq6dea340sz4ecwgc0hg6l5c32gduqjz9y88kxae3c4ydngqq2pws	\N
10	\\xe07d555248a2a3552e6ee0b3bfec0a9ae1203de76a0062fe30d8965b5e	stake_test1up7425jg52342tnwuzemlmq2ntsjq008dgqx9l3smzt9khsxrft5x	\N
6	\\xe097ed0f1853d618e3f2867259efaee569bab00ae4b53372a442b85027	stake_test1uzt76rcc20tp3cljsee9nmawu45m4vq2uj6nxu4yg2u9qfcu2yk2v	\N
11	\\xe09e78ed0f3f2668ccfa7add59b84dc23dcbb7771342a86356e3dd7acf	stake_test1uz083mg08unx3n860tw4nwzdcg7uhdmhzdp2sc6ku0wh4ncu3pvn0	\N
4	\\xe0ae840a7b749511548550553838efb8cdb95c057db872862b4728f6b5	stake_test1uzhggznmwj23z4y92p2nsw80hrxmjhq90ku89p3tgu50ddgx4muse	\N
7	\\xe0aea5e8bf3eb95f8d38fc572364c34ddfe6001ef95a93c7759e71d98a	stake_test1uzh2t69l86u4lrfcl3tjxexrfh07vqq7l9df83m4necanzskmsvd8	\N
3	\\xe0b7fcc1e4c67ebbef4befe0ace9f27bae74e3f2371f1fe7941b06edb7	stake_test1uzmles0ycelthm6tals2e60j0wh8fcljxu03leu5rvrwmdcyjt9yj	\N
8	\\xe0bfc6286f5980f34efda94cbf7d5c710ef1256d8bb05c2d92723bf1d2	stake_test1uzluv2r0txq0xnha49xt7l2uwy80zftd3wc9ctvjwgalr5sas5rxr	\N
5	\\xe0c128dd19292f28bb8802725550c74106c281054240ee67e9280d79e4	stake_test1urqj3hge9yhj3wugqfe925x8gyrv9qg9gfqwuelf9qxhneq8zk76c	\N
9	\\xe0ddd7d79c8b148890fed6396d4ad06a7855cc35c0671e329acfe1c80b	stake_test1urwa04uu3v2g3y876cuk6jksdfu9tnp4cpn3uv56elsuszc528mce	\N
34	\\xe0e4e52846687edee7bfe402db22440bcfd8145d9da09a4ab0055b616b	stake_test1urjw22zxdpldaealuspdkgjyp08as9zanksf5j4sq4dkz6cpntvhm	\N
35	\\xe09da0b39a0342cfa481028d61ec9b83f7ac5e465b5e5a65bbba58c92b	stake_test1uzw6pvu6qdpvlfypq2xkrmyms0m6chjxtd095edmhfvvj2cz7s2mk	\N
36	\\xe05adb751cd3788c6a9aac2a66fc867324e433fdaf3be50d62d9623055	stake_test1upddkagu6dugc6564s4xdlyxwvjwgvla4ua72rtzm93rq4g23d506	\N
37	\\xe0c72315d3b6871b957b9e322f04055be6b65e8a47103de44a189baa80	stake_test1urrjx9wnk6r3h9tmncez7pq9t0ntvh52gugrmez2rzd64qqdr8c4j	\N
38	\\xe0cb96d4162f31ade9ad24b9406cf1bcc5d482e30a996719e52e9e1a49	stake_test1ur9ed4qk9uc6m6ddyju5qm83hnzafqhrp2vkwx09960p5jg20mtkr	\N
39	\\xe094e7b8a6c38a607965e593fd8095984878441bf2fa282388d299a267	stake_test1uz2w0w9xcw9xq7t9ukflmqy4npy8s3qm7tazsgug62v6yec7rldfx	\N
40	\\xe0c50cd1d484245d710ed443ffb47f5e8d68c5a2002ee50d3d53bc98ee	stake_test1urzse5w5ssj96ugw63plldrlt6xk33dzqqhw2rfa2w7f3msz7mzzd	\N
41	\\xe070dfbd1cd0151c7a9887b841ceeb6913975fd31b479a902565991191	stake_test1upcdl0gu6q23c75cs7uyrnhtdyfewh7nrdre4yp9vkv3rygzhgfwp	\N
42	\\xe04fab6c1366a3d5cbc5f69ad0a384a8a2b37a504fb65de8663966a9a7	stake_test1up86kmqnv63atj7976ddpguy4z3tx7jsf7m9m6rx89n2nfc5vxyqx	\N
43	\\xe063c5fa519cce259110de46c353402a8f13b48173aae72f7c7864ab45	stake_test1up3ut7j3nn8ztygsmervx56q92838dypww4wwtmu0pj2k3gugexeq	\N
44	\\xe0351e6b213f832a5277345473908db0caa08fb0004c03c71e985bd683	stake_test1uq63u6ep87pj55nhx3288yydkr92prasqpxq83c7npdadqcculy8c	\N
21	\\xe0c935891423260fd4e3c0bde0cdc6c865cb4d77f0f42eaa4e1e6c1b7f	stake_test1uryntzg5yvnql48rcz77pnwxepjuknth7r6za2jwrekpklcujqfg3	\N
19	\\xe0833c62ca85351d47ae6a3fb343302f3363fb8bf9b43551852cfe6c97	stake_test1uzpncck2s56363awdglmxses9uek87utlx6r25v99nlxe9cm0m3hj	\N
16	\\xe0ceaea99752b870cd6357ccecc12e7c3e653d0ac699d4699ef379aa73	stake_test1ur82a2vh22u8pntr2lxwesfw0slx20g2c6vag6v77du65ucyfvzsn	\N
13	\\xe09187b4783ba8feaa8065e7c8264d0e7e66f33c3cda4f020ce473cdd0	stake_test1uzgc0drc8w50a25qvhnusfjdpelxdueu8ndy7qsvu3eum5qfdkvrw	\N
14	\\xe0bd041f2c1e72e7e470c72d9555df0f9630e3a4b21f64f9b871739208	stake_test1uz7sg8evreew0erscuke24wlp7trpcaykg0kf7dcw9eeyzqmv3h9z	\N
20	\\xe01df9c9609197151d9821167d4cc7b6474938fe745084606ca97f89ce	stake_test1uqwlnjtqjxt328vcyyt86nx8ker5jw87w3gggcrv49lcnnsv6jd05	\N
12	\\xe00b2fbf0c11358e54996c0dae986ee782c3dbec0881e35120ecc8f45d	stake_test1uq9jl0cvzy6cu4yedsx6axrwu7pv8klvpzq7x5fqany0ghg8c4jux	\N
17	\\xe061748993c5dfbbaf9fc5f80f4292c0cb019108ffb03b82ffe622a9e2	stake_test1upshfzvnch0mhtulchuq7s5jcr9sryggl7crhqhluc32ncsmkdefh	\N
22	\\xe0d518f96bb9fda97d5479ac7719adb4ee7b3d0671cf7bd755da611d2b	stake_test1ur2337tth876jl250xk8wxddknh8k0gxw88hh464mfs362chcana9	\N
18	\\xe048b71aee13ef4c8dc4890a7bcedd8b3067a48449f96c601ec471a301	stake_test1upytwxhwz0h5erwy3y98hnka3vcx0fyyf8ukccq7c3c6xqg7mujut	\N
15	\\xe0c3292dae6ce2fc6c4546442c1418636572e90c5dd36b8f2c4cd133a9	stake_test1urpjjtdwdn30cmz9gezzc9qcvdjh96gvthfkhrevfngn82gtgn8d2	\N
69	\\xe01bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	stake_test1uqdlrcfc7tuta27fv0y5es5wark5kst5gcql9md02zepalg9yxxuz	\N
71	\\xe09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j	\N
72	\\xe07d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	stake_test1up73dx2qeg7gv59739gpmycmxzffyqk3ha2ctmh9ghdgneqmy000q	\N
89	\\xe0dd0648b4599deea74734c3b4abbd60dfea1ea41e39eba258f22f406f	stake_test1urwsvj95txw7af68xnpmf2aavr07584yrcu7hgjc7gh5qmc6avy35	\N
91	\\xf0da336dc6885ad6718c652d764ab2e97a45fc895f5c13c7bfa474ea98	stake_test17rdrxmwx3pddvuvvv5khvj4ja9aytlyftawp83al536w4xqhfd3g2	\\xda336dc6885ad6718c652d764ab2e97a45fc895f5c13c7bfa474ea98
93	\\xf029f17f78a28a85f825b8d5ada46758cdc5acb4a2c407f162d944f476	stake_test17q5lzlmc529gt7p9hr26mfr8trxutt955tzq0utzm9z0gaspllta4	\\x29f17f78a28a85f825b8d5ada46758cdc5acb4a2c407f162d944f476
68	\\xe0f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	stake_test1urc4mvzl2cp4gedl3yq2px7659krmzuzgnl2dpjjgsydmqqxgamj7	\N
79	\\xe072263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	stake_test1upezv0agh8cq09rt33ardnh8pdstd3lwpa5s64g2pne0uqgcygw6k	\N
80	\\xe08de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	stake_test1uzx79ge8d7gkx27vu3k9xgj9zlra0fvat5d5lxcnzm9n7hc8yk6td	\N
81	\\xe04f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	stake_test1up85ec98csnkgus5dw3x8u25mlkgu8m63hvw650ukldv04q6rf54k	\N
82	\\xe00ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	stake_test1uq8lxxfr92332xgqp66eenhpw7z04q09czgjf6uvnku20fq023mfy	\N
83	\\xe0ce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	stake_test1ur89gkdpkj42jwy3smuznfxcjdas0jz64xtckt9s8kz8h3gj4h8zv	\N
95	\\xe0f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	stake_test1urcqjef42euycw37mup524mf4j5wqlwylwwm9wzjp4v42ksjgsgcy	\N
70	\\xe0e0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	\N
67	\\xe0a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	\N
\.


--
-- Data for Name: stake_deregistration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_deregistration (id, addr_id, cert_index, epoch_no, tx_id, redeemer_id) FROM stdin;
1	68	0	4	138	\N
2	68	0	4	140	\N
3	68	0	4	142	\N
4	68	0	4	145	\N
5	68	0	4	148	\N
6	68	0	4	153	\N
7	68	0	5	173	\N
8	91	0	5	178	\N
9	70	0	13	389	\N
\.


--
-- Data for Name: stake_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_registration (id, addr_id, cert_index, epoch_no, tx_id) FROM stdin;
1	1	0	0	34
2	2	2	0	34
3	10	4	0	34
4	6	6	0	34
5	11	8	0	34
6	4	10	0	34
7	7	12	0	34
8	3	14	0	34
9	8	16	0	34
10	5	18	0	34
11	9	20	0	34
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
23	21	0	0	58
24	19	0	0	63
25	16	0	0	68
26	13	0	0	73
27	14	0	0	78
28	20	0	0	83
29	12	0	0	88
30	17	0	0	93
31	22	0	0	100
32	18	0	1	107
33	15	0	1	114
34	68	0	4	137
35	68	0	4	139
36	68	0	4	141
37	68	0	4	144
38	68	0	4	146
39	68	0	4	149
40	79	0	4	163
41	80	2	4	163
42	81	4	4	163
43	82	6	4	163
44	83	8	4	163
45	68	0	5	172
46	91	0	5	177
47	68	0	5	182
48	95	0	9	284
49	70	0	13	387
50	67	0	13	391
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
2	9	68	10000000
\.


--
-- Data for Name: tx; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx (id, hash, block_id, block_index, out_sum, fee, deposit, size, invalid_before, invalid_hereafter, valid_contract, script_size) FROM stdin;
1	\\xd9f0e9f05652aad3709826c7e0445c747073d33411d5c62947188b436b1a68dd	1	0	910909092	0	0	0	\N	\N	t	0
2	\\x114bfd652a0818c1c2dbceb6493b230e25694cd0c7056e783d822cd37e93abd4	1	0	910909092	0	0	0	\N	\N	t	0
3	\\xbaf67550c355ba93718fe20210a770d8ab35dc553758b1003d20b160e4acad23	1	0	910909092	0	0	0	\N	\N	t	0
4	\\x994ab4cbb9bff7a2b735f5cf609b9d6af1952ff64fe3e9e147fcbf096c043e5e	1	0	910909092	0	0	0	\N	\N	t	0
5	\\xd0d144ca829486345ac775c0976b07230dd9c99c0acf0cb9d5cccf03af7e5f55	1	0	910909092	0	0	0	\N	\N	t	0
6	\\x2cd14c9c9c050878a4c33e41ed388d1649ecc9910e3ddf6d290b12face088645	1	0	910909092	0	0	0	\N	\N	t	0
7	\\xd74e8a07eb639b6adcf9b91dd9ba64c06cb48262262832ec9e940edc1113423c	1	0	910909092	0	0	0	\N	\N	t	0
8	\\x07cf3154cc3aab9d2598bcb3ef3c4721db8768914e602385ce7bce7623d275b1	1	0	910909092	0	0	0	\N	\N	t	0
9	\\x1b78ce30b505fc5c499208d634bb8fcfc54aafc95179472156ac5c8573032007	1	0	910909092	0	0	0	\N	\N	t	0
10	\\x32a7d21f5193f24c17f5ccbf94160c5348e11253af2ee0b4e7f58e23d6d6e7a6	1	0	910909092	0	0	0	\N	\N	t	0
11	\\x646438908271e5c286677819f6a2386471cc6a335ae94094f13bd127945f142f	1	0	910909092	0	0	0	\N	\N	t	0
12	\\x0b14aeb2f33f568b7dbb4cebeb3c8726989bef81fa03897708e6404a8ff99c81	2	0	7772727272727272	0	0	0	\N	\N	t	0
13	\\x1d03fab15b54838697c21896d7a5076b06081363b41154fde2971667c6e17537	2	0	3681818181818181	0	0	0	\N	\N	t	0
14	\\x28457d8386ea1e8df275e7fb51482f3d5088f16a565b397baff2e158dc0d32e7	2	0	3681818181818181	0	0	0	\N	\N	t	0
15	\\x29f296563016764edc6ae0746e1b5958da52d85e13ec5a0b69b22dbfc6d84d48	2	0	7772727272727280	0	0	0	\N	\N	t	0
16	\\x2be0b4cd26fcc78998a66b280725b10880cc327f3be010563b22077ff5a107a9	2	0	3681818181818181	0	0	0	\N	\N	t	0
17	\\x3e8c1dcbd2bf34919e6593056e07e76e952f740e0337e64398b32a06d02084b1	2	0	7772727272727272	0	0	0	\N	\N	t	0
18	\\x3f4d40dd8a7955028875f1860652ea977f0e6516f9c0fa291771e5bc7f3b28e4	2	0	7772727272727272	0	0	0	\N	\N	t	0
19	\\x560d484e6b6d5fc3d2a2b398c98a0c5d84206f530bcf9f02be6581347f633cd7	2	0	7772727272727272	0	0	0	\N	\N	t	0
20	\\x5c3f7152eb3ee0fe201b2108a4f6ce4cb8bcddf2e689df7c037ae1cc59cfc9ea	2	0	3681818181818181	0	0	0	\N	\N	t	0
21	\\x6af9774c4d1510dd1f145aec4f47d230a46d52c9ed76e2eb941879f71cbadffc	2	0	7772727272727272	0	0	0	\N	\N	t	0
22	\\x7111c08b4eb97066a10fa6e7a589f8ae47a3022597e1d96cbcc0843dd369c9ca	2	0	3681818181818190	0	0	0	\N	\N	t	0
23	\\x79ccfadb63342059dea7d5de8aaa06344f7424c7d8a18266c72b7052a0a5e33d	2	0	7772727272727272	0	0	0	\N	\N	t	0
24	\\x7b173c37dba83d0f2e0e1c33f643aa390699cd7c855d3fe26a6af64187b317e6	2	0	3681818181818181	0	0	0	\N	\N	t	0
25	\\x8b1d81c220ba7f8338ecf684ac58d450bbf6025938e96509cb897ddba60bd375	2	0	7772727272727272	0	0	0	\N	\N	t	0
26	\\x8cf0bc132a552f8781b592ea4b2171ec0c3cf0a83c76ebdc0edf49b2126378a9	2	0	7772727272727272	0	0	0	\N	\N	t	0
27	\\xa025cedcb315ab8cc047f957a5a7dd89c707fe970b7e19b06389eb1e5268bd8b	2	0	7772727272727272	0	0	0	\N	\N	t	0
28	\\xa0ee4689ec1c351a413dd74ec7e51b99b277af5d8cb93c5cba4c3189a7426557	2	0	3681818181818181	0	0	0	\N	\N	t	0
29	\\xad0a8d6b2585cf715df46bf3ab7954817418344d560702960b31f51270570849	2	0	3681818181818181	0	0	0	\N	\N	t	0
30	\\xbdfeb6b21ed17a901087b4ab0dfec1e33ac0ad11d86e88e591c12f784784a1ad	2	0	3681818181818181	0	0	0	\N	\N	t	0
31	\\xc1193cc8c9f972d5babf82615d7731bde8079c231dc24cf93be60542cccfc964	2	0	3681818181818181	0	0	0	\N	\N	t	0
32	\\xcc023bf910a0d769d7e35e4cdadedc1db086110b4df1d18351c286fa667ad5ee	2	0	7772727272727272	0	0	0	\N	\N	t	0
33	\\xe631d434b685d297b7d9e0f6cd5e5cab564c058069067c4210a87fb79b880825	2	0	3681818181818181	0	0	0	\N	\N	t	0
34	\\x5368656c6c65792047656e65736973205374616b696e67205478204861736820	2	0	0	0	0	0	\N	\N	t	0
35	\\xe6d03697768495003924c4d4eaf3ba5c11834fee83301c01eba6add39a9aa224	5	0	3681818181650964	167217	0	269	\N	\N	t	0
36	\\xc5d152de62fe4cef4ed80307ab6cdfef1c9c01c872b465991bc358cdbd70b4d3	5	1	3681818181650964	167217	0	269	\N	\N	t	0
37	\\x56fcfb10337f6f95246db31643585314cc955478ccc26e8b08486c44b2a2f270	5	2	3681818181650964	167217	0	269	\N	\N	t	0
38	\\x8ef40d407e1d45de5e877557664b5c37e89fcfcb9457aef0ced70714d3c298ec	6	0	3681818181650964	167217	0	269	\N	\N	t	0
39	\\xbba23c83b1a7541d5676c389ae6ad1d171d5fcebdf95f940964111313ef86c07	6	1	3681818181650973	167217	0	269	\N	\N	t	0
40	\\xad6b62158ed440eaaa7e061f4e6587f6dacfe3b2c6f02a60fcd358d06f4a6b1c	6	2	3681818181650964	167217	0	269	\N	\N	t	0
41	\\xb3db43c0337bf83cfc93ef2ce5f3fa1425e1e40d3e2b87e157948a24a469eef9	6	3	3681818181650964	167217	0	269	\N	\N	t	0
42	\\x773e9e63bc651bac451860da66a23a3916a3f67b6c53b529a8af1e87f6682cd3	6	4	3681818181650964	167217	0	269	\N	\N	t	0
43	\\xdeee25b9fdfc23a080fa14b92d63f5fa35f5ce20df4158ad4af7f92033ab64d8	6	5	3681818181650964	167217	0	269	\N	\N	t	0
44	\\x6d1b8a74e0137b73a6fd7ebbd85e54bc60412222977ab20f4b5d609af70648a8	6	6	3681818181650964	167217	0	269	\N	\N	t	0
45	\\xc9561a42c0d7a9da8f9919aab67fbe52a81668d83350eecbef7738e734eee29f	6	7	3681818181650964	167217	0	269	\N	\N	t	0
46	\\x60de06bd1751411ec0e8e46d3ee53616d2af34b68e8e58096342702f49f9d4b7	10	0	499999828383	171617	0	369	\N	\N	t	0
47	\\x22160d8a9fb714ed03a66001239b808766d1516378f2af774ab1d0321735b2ad	10	1	499999828383	171617	0	369	\N	\N	t	0
48	\\x62bb49a010375c4fedf1bfa1019ad7fb10757e68dca7a5ed0e605d57f283a296	10	2	499999828383	171617	0	369	\N	\N	t	0
49	\\xb47213e74f542d56a9e08dec0a46ca169ecb6937e7a58240c9d0cdb4d90fbb33	10	3	499999828383	171617	0	369	\N	\N	t	0
50	\\x2062fd54aa4a143274525bd4ec6a43e7be40603e78c072f396c1dabcae064268	10	4	499999828383	171617	0	369	\N	\N	t	0
51	\\x020785172e424266adf73a2e9e31ea55d6cbb3d1eae35b1e10d909bfca55379f	10	5	499999828383	171617	0	369	\N	\N	t	0
52	\\xbdb1da27c489371c0d9a55ba90fda3041d7ab7d0fafd8fc133823a244302c0c3	10	6	499999828383	171617	0	369	\N	\N	t	0
53	\\xcaef261722288d21e36561a43fcecada64b7939561e7cea727941755258e68b6	11	0	499999828383	171617	0	369	\N	\N	t	0
54	\\x34f692de40d75779070e076a427405766310bec8abae29d29492751d1658cf3c	11	1	499999828383	171617	0	369	\N	\N	t	0
55	\\x0df2d7b73cdae2f5ae96bcd1b4aadf6fd08b08346b524b006934aefc088990f8	12	0	499999828383	171617	0	369	\N	\N	t	0
56	\\xb810edef30d727f3b2140d25ea2dbfbe98b44a10c19641d32d16a5dfe1c48638	12	1	499999828383	171617	0	369	\N	\N	t	0
57	\\xeeaa515526fa81b4799c558c6048285f3b7190337a4e5efbc8f388055db355f1	21	0	3681318181483923	167041	0	265	\N	\N	t	0
58	\\xb92c71fb14a9e233f449427a52aa52713c1264a70b5cbb6570904e810e44549d	23	0	3681317681309710	174213	0	337	\N	5000000	t	0
59	\\x9c865b4879dcc08e8dba9b9fdd3299f5de07e6524bf1b9630d28a8fa3894755b	25	0	3681317681134177	175533	0	367	\N	5000000	t	0
60	\\xa283ebc61959aa44e6eb802e925261da51813e626778f24bdc2a36263ad84a3a	28	0	499999651618	176765	0	395	\N	5000000	t	0
61	\\x9c0e24bbb77e7dcf0a6fced9112005f1bfc8619bca39d852637f65445ba4f806	31	0	499999463237	188381	0	651	\N	500000	t	0
62	\\x6fda9243ccd869e8d3641e6451abba7f9e19fc4cf4a9c0b4ef49d11ec37bffc9	32	0	3681317680967136	167041	0	265	\N	\N	t	0
63	\\x2a11c44ea44806e6d6642467cd73bcd692c3f51e1a2de8d3274c39a1f42e0cc5	34	0	3681317080792923	174213	0	337	\N	5000000	t	0
64	\\xf70afa8a9971f85ae9cc9024b8af13f413057d74345727ffc527c16dd2bb177a	35	0	3681317080617390	175533	0	367	\N	5000000	t	0
65	\\x86bc020ae058728a7feafe7de7bbed9fd086308fa7edfd7b9f228dc07eb3ab79	36	0	499999651618	176765	0	395	\N	5000000	t	0
66	\\x0c6dcaf96b06faa2ddcb58026ddd5e64b9d7d588f9919eae787220c56eaf1e0a	37	0	499999466009	185609	0	588	\N	500000	t	0
67	\\x4d05e150dfe6961c4197b5af440a169b63febb6e66e3672de5fa4052c9541862	39	0	3681317080450349	167041	0	265	\N	\N	t	0
68	\\xe5e73e572d6986a553aeb4aa01f33da832d9b5bc801640a8e3455027f0210933	42	0	3681316880276136	174213	0	337	\N	5000000	t	0
69	\\xf24545d98621c0b16fc6f12abcedc3357ecc88386cc4ea2a9fe2c70f33367f6d	46	0	3681316880100603	175533	0	367	\N	5000000	t	0
70	\\x2d53af7cb0cb64b79dceed07cac2797f4cb836033c2f295cb4c9d7db74fee5cb	51	0	499999651618	176765	0	395	\N	5000000	t	0
71	\\x347a913e0ae2c13e461172a9fc3f6d5ca5b07cd0d40bc5fbad5b63e24d37e345	56	0	499999463237	188381	0	651	\N	500000	t	0
72	\\xb7316144b6446d62905bbf377dd9ab6b6738358982d901a371724ef9bab9feae	58	0	3681316879933562	167041	0	265	\N	\N	t	0
73	\\x64fa39484da9da20bfa2f9f273b9789d2564d4a6192f2cbf0f51cfe73ddd1b63	61	0	3681316379759349	174213	0	337	\N	5000000	t	0
74	\\x417fc9602231bd102acb0a7c212aff0ce2caef030b47e40f7ff43735b83bbfa1	65	0	3681316379583816	175533	0	367	\N	5000000	t	0
75	\\x9213bdb6e37f862a1d38245731b2376727ea41031fc00abaff0f9f4a56f87d0a	67	0	499999651618	176765	0	395	\N	5000000	t	0
76	\\x69e50db74d6e47fa7d92dd499d6e5d91b395ccf55feb164295b3205f1341646f	69	0	499999463237	188381	0	651	\N	500000	t	0
77	\\x08a66bbf42b3e0a79c575818241b560748ad29df5f4938fd8050c70d4ce35cd3	72	0	3681316379416775	167041	0	265	\N	\N	t	0
78	\\xc338376a0ae7f0e7da843ea89521604c6232eb5a71a1027bc6e9af26b3ee6e99	76	0	3681315879242562	174213	0	337	\N	5000000	t	0
79	\\x022976d8bfe12b725ef74b3f174a12611e833d59b86be68a07a93ddf2a82ac1a	77	0	3681315879067029	175533	0	367	\N	5000000	t	0
80	\\x9d8208e30e836477002355cd423c62a77dc542f34225ef2b274cb53d383d8dcb	79	0	499999651618	176765	0	395	\N	5000000	t	0
81	\\x2f5be2417dd5b0f32460753ea2be1b06560bf5d2a1eb384824815d2af9ec6b90	80	0	499999463237	188381	0	651	\N	500000	t	0
82	\\xbf15d2c21f5f8cdebdc2da8a0a859c539a713438e3ca3019e728a23de04bdb97	81	0	3681315878899988	167041	0	265	\N	\N	t	0
83	\\xbb794a10a5f6705a05425b7494b6cfa92b0253e1bf4a07c86e2652248edd4ade	83	0	3681315378725775	174213	0	337	\N	5000000	t	0
84	\\xa365ce47887b9596b3ad3d4de2a3e3a0ceae07b535fc370bfb14a6a7c00058c7	84	0	3681315378550242	175533	0	367	\N	5000000	t	0
85	\\xee577e777110915ff2a28cc55f0222bf91ec147b6c90d21a745c28b9f65c6f82	88	0	499999651618	176765	0	395	\N	5000000	t	0
86	\\x6a6d5a2361ba47256f5916eac05399f42546a32c6528b3ccbe59adf64948908b	89	0	499999463237	188381	0	651	\N	500000	t	0
87	\\x0bf553ceefbe5b6adccf7ae7f003b9ee4c9bf90f2626b753409f5e062f870708	90	0	3681315378383201	167041	0	265	\N	\N	t	0
88	\\x8c188118da015e832c539b04dc9914a5e5d264db6034652435741800db59d1c3	95	0	3681314878208988	174213	0	337	\N	5000000	t	0
89	\\xa4d8f95512df4b64b5cbb9b5ba7aaa70c575443b00e391d5a254ed7bf36af3ac	97	0	3681314878033455	175533	0	367	\N	5000000	t	0
90	\\x7eef3c8ffdaefa46236e3965d753aa3d555ef7c38187ef6a1788a76e4c45a2e1	98	0	499999651618	176765	0	395	\N	5000000	t	0
91	\\xd53ee71319a4644e6d29a3378450665bc5734056a73473fcb03f9ce1d481a97a	100	0	499999463237	188381	0	651	\N	500000	t	0
92	\\xdddb76d0d915fb1ce0eb8f6b205a0d900c0d5ecef2ad926ba1119d28b75f4765	103	0	3681314877866414	167041	0	265	\N	\N	t	0
93	\\x5674efde5508875fc7444ed5e58572823c2f00fedd801c7ff675deacfb338022	106	0	3681314577692201	174213	0	337	\N	5000000	t	0
94	\\x5f2aa291c1e9bf7c254056875407925597d7605dfec0d22f513fa7ad559edd00	108	0	3681314577516668	175533	0	367	\N	5000000	t	0
95	\\x86dcafcfdbb0df1eafbd5c54fc902812b0c0493a11bc9f7b7661615be73a2561	112	0	499999651618	176765	0	395	\N	5000000	t	0
96	\\x14f22692a2813fc16381a4e7a8ac563c11a9ff578d415ac31c35e56af26056cb	115	0	499999466009	185609	0	588	\N	500000	t	0
97	\\x022974e797cd265fcc16943e75ab02224d7cc75075c2a1dadfb4165d2bd294c6	117	0	499999289244	176765	0	395	\N	5000000	t	0
98	\\x99f76fda27aaeb7fb3eadeba2e8fde5411bd51d9713e2b899d86791c2cdd3a33	119	0	3681314577338055	178613	0	437	\N	500000	t	0
99	\\x7952a691e9f0e97512f91e433c43e3e70f9101e27d4c782c7d6f33d9abdeb48a	120	0	3681314577171014	167041	0	265	\N	\N	t	0
100	\\x8c2d6bbad7beb053ac05993792112730f29e90edaad6c8e92ee319fe4ad6a86b	123	0	3681314276996801	174213	0	337	\N	5000000	t	0
101	\\x7fcbf1b0bbf35727567db229dba6797753f8d52a52ca6472cd4eab52ad52811e	125	0	3681314276821268	175533	0	367	\N	5000000	t	0
102	\\x269abd829465321c4424e71a55e41a4b3740d1c5045e7b940ddb35f35b8db080	130	0	499999651618	176765	0	395	\N	5000000	t	0
103	\\x5470682e864e63f9628a998643f04d106367fde65d66017da1ed4dbdadbef15b	133	0	499999466009	185609	0	588	\N	500000	t	0
104	\\xa1dfd498ce64b7e4fee1986cb3ab7745f019960cbdd8d3f49401a237bb395a31	134	0	499999289244	176765	0	395	\N	5000000	t	0
105	\\x9a13d14e0ee16f463318f75038084faf05702ba65617c93537caa9ecfffd938b	136	0	3681314276642655	178613	0	437	\N	500000	t	0
106	\\xd38ac1b19b5da89bb3105e93c478967e3b8c183ac1ccee3e33b2c012aa686d77	138	0	3681314276475614	167041	0	265	\N	\N	t	0
107	\\x9e68aa7b646d4cb3e93bccd6db20a036e26d1cf958fb0c847ed0f1c667183b64	141	0	3681313776301401	174213	0	337	\N	5000000	t	0
108	\\xaffb033610813ec2bfd5bd9738d7bc5ac9870c3518b28f98f31d63f7a7978fbf	144	0	3681313776125868	175533	0	367	\N	5000000	t	0
109	\\xb3ac06912fff77deaabb616cffd40108101b9b64ec239b4e07fa95f84a09f0ff	145	0	499999651618	176765	0	395	\N	5000000	t	0
110	\\x8aaa5a63590abe8501b2dbcb573c77c6d0b88d59b34209e43f77328271c26012	146	0	499999463193	188425	0	652	\N	500000	t	0
111	\\xa9c3a2bce0fc6d8d05010d699455e8ae07a355f80b58b5f5eb92468d06704d06	147	0	499999286428	176765	0	395	\N	5000000	t	0
112	\\x35f9a09cabcba6995904c1eb38af8cd0d56fe398ba33c32dd0692849064ad2e7	149	0	3681313775947255	178613	0	437	\N	500000	t	0
113	\\x26424b33f184c0e79cb7aa26f56f2d012e2396873070154ba9fc0db621309d0c	151	0	3681313775780214	167041	0	265	\N	\N	t	0
114	\\x9676c900ce3fb9101237c9e37219154f6d0bfddde78a29595d3d37d65dc86bf0	153	0	3681313275606001	174213	0	337	\N	5000000	t	0
115	\\x1ec0a173a5c2880d9403d4664680f7613cd4e2a82ccc6c87cfbef33ef3978cff	154	0	3681313275430468	175533	0	367	\N	5000000	t	0
116	\\xfaefe9afdfecc10e714feac434ae45d906868a7e9986bebbc835cbf81b5d8802	155	0	499999651618	176765	0	395	\N	5000000	t	0
117	\\xa0264cef7025ec41ca584ffbf7f477ef82cc01f21aa19536db86f2c5c1a224a2	156	0	499999463193	188425	0	652	\N	500000	t	0
118	\\x3c27d6471375fa3b0c55e3aeadb186b8a2b70ce50e6faab01c9c38855d8b87b9	157	0	499999286428	176765	0	395	\N	5000000	t	0
119	\\x0cf2be59bfbeac57d62a1c31fb2c12ce0bf896434e595699985a9f328bb50574	158	0	3681313275251855	178613	0	437	\N	500000	t	0
120	\\x4cb7b93de6506964ae4368b80590c97ef767e8d33c548f29d8273b3bb8ccedf8	159	0	3681318181483659	167305	0	271	\N	\N	t	0
121	\\x7b06a997fc08dc632d067075c20c11481dfc0d8a5048b493300cacfaa8650961	160	0	99828426	171574	0	361	\N	\N	t	14
122	\\x915b7d9611602d513afabe9c73439bf728658de835d333143f8759655d00cba7	161	0	3681318081317410	166249	0	247	\N	\N	t	0
123	\\xd9172e2feb167a13dddd7093d0772771003457a1bb5ff3c4764c7805ece422cb	162	0	3681317981146849	170561	0	345	\N	\N	t	0
124	\\x76b6efe7d2a5de2fbe23bce7f8b30edac8990ae1a6e2f9b5df5a6e213bf90803	164	0	3681317880978884	167965	0	286	\N	\N	t	0
125	\\xd3531831f248dd91a3affe156a576fd69dec57ad0d6cad11465e3dccf3986a2a	166	0	3681317780812063	166821	0	260	\N	\N	t	0
126	\\x69c00003d3590fc074a2f2df31c848f6b92c5da92e5a343376466eabed43fb23	167	0	3681317680549014	263049	0	2447	\N	\N	t	0
127	\\xf5213687dbcb40ab20da2e85d83d5f9968481b2acacc25c4a44bfde6b8118900	169	0	3681317580382721	166293	0	248	\N	\N	t	0
128	\\x98be048d6e34573dc18a93dc66b92d67ac4ac68743191212dacb79a16dd8b9d9	170	0	3681317580054890	327831	0	2624	\N	\N	t	2197
129	\\x828009ddf3d6c9947968111a5210bbea27554998e3e8679cfe7f0ed6934fbc8e	171	0	3681318181474815	176149	0	472	\N	\N	t	0
130	\\x6c1004b1e79962472ffb1c3786d9e3f65daf18872bfee31f2b9505b76aab9765	172	0	3681313275072494	179361	0	545	\N	\N	t	0
131	\\x911dba86477fe2679558d6cdfc4e42986fff191bd62054f9fd0967c31f3db2fe	173	0	4999999767355	232645	0	1756	\N	\N	t	0
132	\\xe6699029fd04d7d7e3f14013c7e062b0712424e123e088864e11c1a326347498	175	0	4999989582230	185125	0	676	\N	\N	t	0
133	\\x24ef20f363eb71d5db8a1828ce442797d5a848b80b45f764403ee832af306cdc	439	0	4999979413649	168581	0	295	\N	5501	t	0
134	\\xb01be3bf1e8aac19f4a3f95e7a8b35eea1eb03c44a71f6861b321be1bde7ace7	439	1	4999979243484	170165	0	331	\N	5501	t	0
135	\\xed8be8e05fe5327f5cb1aa7c4203951e3c1fcf29bf74fa0962030de73ac4ba4f	446	0	1999991325477	168669	0	297	\N	5573	t	0
136	\\xcbea38edb8dc0e452fc672c0bcd167c68030430a032dc9216854eb8243592352	448	0	17825523	174477	2000000	429	\N	5629	t	0
137	\\x23ed853658536d05ccf67be32c5f4cc4b3503f080d1af1817a32be8009066559	450	0	2999987576005	173333	0	403	\N	5641	t	0
138	\\x6ceeae37d47444caa5792ee0856b756e57e2beb8c8bc7b15cd36594dec53aeaf	452	0	1999971153464	172013	0	373	\N	5685	t	0
139	\\xac3051943c84f45421acce2f1fecf999d4cd57be7f60ab15cd08bfcfb31d5cb0	454	0	2999987402584	173421	0	405	\N	5699	t	0
140	\\x8321ffc3892986baf3397b4001ff630c76ec42010b80f28787b2730768b46bc7	456	0	1999970981451	172013	0	373	\N	5743	t	0
141	\\xbdad8c67dab2b2d883f69645f7f4848fa82086f28cb99da8c62649fb750d41c6	458	0	2999987227843	174741	0	435	\N	5755	t	0
142	\\xf342999b22c2e0330b695c02d0bc67efe6e1d4079a6e1c6bad09488f828dae9b	460	0	1999970809438	172013	0	373	\N	5770	t	0
143	\\x07a01096cce4b0be4dac98bb3e288e1874dba38d3b57fbecb460075b3875f062	462	0	17653686	171837	0	369	\N	5778	t	0
144	\\xb81bc74b8d536c74d332e92e868463b6048c6cc649ff4e2965a28a5c4c0fe71d	464	0	2999987055830	172013	0	373	\N	5804	t	0
145	\\x120e24d3cadbe4582bb6547c8ce18e925a851421d9aed0138e45172c57202898	466	0	1999970637425	172013	0	373	\N	5838	t	0
146	\\x5ae2133cdad29fbeb2dd9a44221eb686eceaa129a54d950e896ee7c7bde0e362	468	0	2999986883817	172013	0	373	\N	5878	t	0
147	\\xefb3c6b15a2fcdc802946ea8a68769fa5510d91fed8c1a99ac0ec96a2ac4d81e	470	0	1999970464048	173377	0	404	\N	5884	t	0
148	\\x56f00f11c7b016952856eec2c72bdb96d86d44de9c754d597e4cfc4c8a74d0be	472	0	2999986711804	172013	0	373	\N	5895	t	0
149	\\xd196f521c392ee73c823613b54cfbd09d45d66b95b2dbe6d1c7aa870c151ce79	474	0	1999970292035	172013	0	373	\N	5929	t	0
150	\\xfab6dadac0c85cb7c3c01f71f6c065f56ee48d475efa3ad20767f0adeb21437a	476	0	2999986537107	174697	0	434	\N	5939	t	0
152	\\xc8686bd84d979285513a27e1c8dd4f6306c332df1b888ca5f2bb652945d78d64	479	0	2993986341202	195905	6000000000	916	\N	5963	t	0
153	\\x425a6bf8e323c423edf8a4eaef29e8f65aa82b4d77b1ea7b0ff4a5a44e0ec86d	481	0	1999970120022	172013	0	373	\N	6020	t	0
154	\\x97701adceba2629774c9788236d9560c8af8166c3f7c2514d0acaf0908e72afd	483	0	17477933	175753	0	458	\N	6060	t	0
155	\\x308acd75abd0e87b5e367bb7d9a4daf5a5d624a8731196fe152bfd427e6c9d37	485	0	19305920	172013	-2000000	373	\N	6082	t	0
156	\\x8e9a10922c8074c58143b2c909296219f6039c4d5b2b7214de7a928a3407cda1	488	0	2993986137201	204001	0	1100	\N	6097	t	0
157	\\x6af6d1a53586c059f829e4aa01129aada939ce9e992d6e4777cfee14a6b5118b	493	0	2993985956960	180241	0	560	\N	6159	t	0
158	\\xcc2f905834fe14513cebeada19d19cf17b04058a05e864766d3a725f14cb4c6f	497	0	1999969932829	187193	0	718	\N	6191	t	0
159	\\xa7a39d3e61b958c40361b8c792124dcbd2f4156b0ac482a0f804cd6591204c66	501	0	2993975767963	188997	0	759	\N	6227	t	0
160	\\x66df0683591de4bb42539b49bfdb4fe3dc1fdd634f82ef1ccede88c47e152554	505	0	1999959748276	184553	0	658	\N	6249	t	0
161	\\x3b93c9e49fbc365cf2689ed3588a41f60c7c8a8dcb3265a71c104f248cea59da	509	0	2993995587150	180813	0	573	\N	6273	t	0
162	\\xd8dcf423b9e664f3be3ac9065017914d591d0da8fcec791548cb89884fadb496	515	0	1999959578287	169989	0	327	\N	6317	t	0
163	\\x5d717d09e4b65981c2555bd5cc1959d9051703bf4e39223dc6c5297ee71206ae	519	0	999675351	324649	0	3846	\N	6343	t	0
164	\\xf797ad947b1c4a5c558ced5f423642cc69cbaacc5441bbd264929850e1af2343	523	0	999414590	260761	0	2394	\N	6401	t	0
165	\\x5f6d4bd6a518e836f792e61d6b051cb3f954c907ae66b26728855ca95a460dd1	527	0	999177457	237133	0	1857	\N	6426	t	0
166	\\xf9a68f3cfcf2f44400f94b535792f18819f4a496a28dd48ea842f042559d2b8c	532	0	1998959400730	177557	0	499	\N	6467	t	0
167	\\x4118f99671c3eb2c27993dec1602abe348e2cb7762c81ab2b87e948d6e49eb36	536	0	2827019	172981	0	395	\N	6516	t	0
168	\\x808eabef4db2e4538d9d80f27276451c63c34f49be0f83fcaade58b6d92182bb	540	0	2993995403301	183849	0	642	\N	6591	t	0
169	\\x20e8b4754f7ef5faccf0de6b57e43914aa98082870aa125e12f360f79e3eb81c	544	0	2820947	179053	0	533	\N	6636	t	0
170	\\xaeaa4a833a0935b3f50a67f7d8d305dff410f67601b3e23d9f6384381c04f752	551	0	2993991886988	516313	0	8198	\N	6689	t	0
171	\\x0dc719d9bd806d5f361d5118ade3b35796c047c0947d6bc2b0ca5eba90367082	554	0	179474447	525553	0	8408	\N	6701	t	0
172	\\xacc6fb1dd6704ecacd254fa5a10a0cd2e9911f0f6401032fbfbbc8c8f8347143	556	0	49753967306	182397	0	609	\N	6729	t	0
173	\\x53069fc830678ec3e12bc077a546e22dc9bc1f4711287bd132a6e2132be2c800	558	0	1998956229113	171617	0	364	\N	6739	t	0
174	\\x5d22e219e4e5194aae47e2ceeee89b6620b0ac730da69dbce67ec471b32aa6ed	560	0	49756800617	170033	0	328	\N	6751	t	0
175	\\xdc30a44ac5ae96a97deca62dff6c0ceff0aa558a0a48441b31c46e6466aa2edb	564	0	49753979406	170297	0	334	\N	6777	t	0
176	\\x851a7f4b744ba4b7fd69526d19ec0ca7ff60a63b405ec275ab8e889bccf703ac	570	0	49753981254	168449	0	292	\N	6818	t	0
177	\\x1e51204b7f85e447725ce47bc8d326f54da2719a9a00e74decb9c9b7f08fa91b	571	0	9814039	185961	0	690	\N	6826	t	0
178	\\xc69318e501bdbfbf38682a9aa4d1e9c59efa2215b7517a3bff73bded193b0f71	572	0	8633754	180285	0	561	\N	6869	t	0
179	\\x816c5cc81c74e87abbcd1a6d049a577dd5d3dcba7521ccbeb64897ce619a1b45	576	0	49753981254	168449	0	292	\N	6933	t	0
180	\\xf9ec2ddd619c4c267caad1bbaa29a5b8eb53ecd74b6d25bd3c9cc170385559dd	577	0	9818439	181561	0	590	\N	6941	t	0
181	\\x0cbf16c9fdb60bf556e47968e10eb827bf8bb81d5849da650d9ad1832624a810	583	0	49753797713	169593	0	318	\N	6972	t	0
182	\\x6610ce7a9e3aac3baf4d509967f7cd47baf10d53542be8f221985f6362b2672f	590	0	2646822	180197	0	559	\N	7047	t	0
183	\\x85798a6c4ec5a4478d18b0203fda1888cf927450dec6ba2927636aab5801e2ec	750	0	49753981254	168449	0	292	\N	8443	t	0
184	\\x7ed1cc35f4c668551d44723bfaf065d0573d7387850dc176863e48a5261aaed2	750	1	49746632212	168405	0	291	\N	8443	t	0
185	\\xfe24fb814c40291ffd1a095927e4d382499c7ad835ed945f847ec24bdea2033a	750	2	49753981254	168449	0	292	\N	8443	t	0
186	\\x98ec368954ad0597abe05feac9fa202f15b06d09f964613dd55af6afd458e431	750	3	49758979670	170033	0	328	\N	8443	t	0
187	\\x0a8ef6522b84cb84ca2dac038f3724b24998b4e593c27a7a5b3705a449bfdfeb	750	4	49756626492	170033	0	328	\N	8443	t	0
188	\\xc0faf3a69a8c49319be5fcc4c175330767bfa2ccc8a3358b4db03a74217343b9	750	5	49753981254	168449	0	292	\N	8443	t	0
189	\\xc4fd9c5d7076eb1c4e4d35b5c21b3bdd790dc9f59876a405c8a4a16de7763662	750	6	49753981254	168449	0	292	\N	8443	t	0
190	\\x778eee1a59bc8821075c02ddde0e389b0f6a0dd0b07db892ac0385eec812bdf3	750	7	49753981254	168449	0	292	\N	8443	t	0
191	\\x1c6277ed9c7e88d5d50ea756b9cc9307068bff218cc2f2003f89515d21909fae	750	8	49748812849	168405	0	291	\N	8443	t	0
192	\\x2d5a838e4c8c355f7d5bd00bb52d5bfc296f192a633b59f0c9499cc921502e37	750	9	1998956060708	168405	0	291	\N	8443	t	0
193	\\x9fca94717368ed9ff9830819624e1c0d845ac83a87df6aa204401b76315ed03e	750	10	49743812849	168405	0	291	\N	8443	t	0
194	\\x75f25f5aaf96e06bcb46773f7b4c30af041b16e760821a68040a3637c09c0faf	750	11	49753981254	168449	0	292	\N	8443	t	0
195	\\xb47a3994a9970c7bb6462a84694337d49dcec5492d43069eaa7730de7914f12d	750	12	49753981254	168449	0	292	\N	8443	t	0
196	\\x046eb3bedbb60e09b95a89fb53ffcb92417211f129398579596d6e78fbaea059	750	13	49751458087	168405	0	291	\N	8443	t	0
197	\\xaf97bf829e771cfe72b997a03fa4c782b9df1c1974098de2bea7d5cec809a01d	750	14	49753981254	168449	0	292	\N	8443	t	0
198	\\xdfd587c885d4ed77bbcad68a02447297df4e56a9ba6e1926c96789bd5b51528b	750	15	49753981254	168449	0	292	\N	8443	t	0
199	\\xddccfcd62cbbed92c145c30fd690c28366b23536dd807a924d516774a4efe44f	750	16	49753981254	168449	0	292	\N	8443	t	0
200	\\x5df7ea2a8def59aa3227979126ab99ef0c31525fa362fddebbc19ddfd462213c	750	17	49753981254	168449	0	292	\N	8443	t	0
201	\\x2ddaeed0992fe824b7103abea0ab6a08e4755b8364d59d7b6947084caf7b7da0	750	18	49753981254	168449	0	292	\N	8443	t	0
202	\\x3e749d2f2cd17a7d1dee2ff6dcca4470c6c24a708f1fe3a18b91e08dd5d62ca3	751	0	49741463807	168405	0	291	\N	8443	t	0
203	\\xbc75753550642ffa64724f9e4402348a9d73762100735ec5f53c6270220ce716	751	1	49748812849	168405	0	291	\N	8443	t	0
204	\\x434f4bca765f80b0b848154ab3e7674318e2c94a1d08d2fdc4b02933c5b6208e	751	2	49749779431	171573	0	363	\N	8443	t	0
205	\\xa4cd393afba4b6da375b536a9164cd3fc221b5c058283d2e387f89bf22045476	751	3	49753981254	168449	0	292	\N	8443	t	0
206	\\x59ab479061b842197856480e31605907224bcafd196b34b50a46f0441f2599b2	751	4	49748812849	168405	0	291	\N	8449	t	0
207	\\xfc89c314a5cdbfb19d26046fd474b87f20a1566cff7a11336465d0ff386aa189	751	5	49753981254	168449	0	292	\N	8449	t	0
208	\\xc94ecc56c7b85fb116d5cbf7d4183ce05c58cc4ca86054d4a3d53c9079acb7c8	751	6	49748812849	168405	0	291	\N	8449	t	0
209	\\xbe485659a7b3780d65699ee4a396340014328801f8353bd857143c68a8195968	751	7	49753981254	168449	0	292	\N	8449	t	0
210	\\x3f1946f80cded76154a800e4186d317d192e7c82044caeee37fc863c42cf6298	751	8	49748812849	168405	0	291	\N	8449	t	0
211	\\x28b961b7aa464ba99f0bc1079c446c1dc7fee38cbdb9e0bc11018dabcaa8e981	751	9	49753981254	168449	0	292	\N	8449	t	0
212	\\x616ec47122d48e564fc6684e19b073043027b7d7551ed4d0c7a33a5fec523267	751	10	49753981254	168449	0	292	\N	8449	t	0
213	\\x47f2a7f003a4ff394bc1e708f65d23f43442969150f1e05dcfaba9380a9fe551	751	11	49743644444	168405	0	291	\N	8449	t	0
214	\\x92639bce1cc9701d62934682e27d1400f34e793ae71cc6227f7a79fb5f71a6c7	751	12	49748812849	168405	0	291	\N	8449	t	0
215	\\xdbfa0a13a3497685fb8139612c9ebac39cc0072d860b54f092fe490629afbda7	751	13	49753981254	168449	0	292	\N	8449	t	0
216	\\x4e701af80569229293e4cba4585a55308659cf5b4a44c4a2df2942a9cc1310ab	751	14	49753981254	168449	0	292	\N	8449	t	0
217	\\xa9670ccdaa719b1be5f5ea5dabf1fb02965b1890f5ef1b3bfa0da0ea6baba034	751	15	49753981254	168449	0	292	\N	8449	t	0
218	\\x7ae7bb3e0bb5bf91a15b0c92421f7f90abaa7e2a5f793ae0b9f04706afe55e7e	751	16	49748812849	168405	0	291	\N	8449	t	0
219	\\x06698035f7cfce0c07f630cc97f8844839aa109050095ade95e4e9f618c91e19	751	17	49753981254	168449	0	292	\N	8449	t	0
220	\\x5eb2e85276d69f43e501d082f846feb8d87ecef135029370f9d6879efd57182d	751	18	49753981254	168449	0	292	\N	8449	t	0
221	\\x3a76bc77882af2861819bd747cdbf0a7bf27d58725afb3a897378bdefea0c1e1	751	19	49748812849	168405	0	291	\N	8449	t	0
222	\\xa5f769e53f63119e69f66b1717483999a8034882ef4ea051450597b0c1e00ca5	751	20	49738644444	168405	0	291	\N	8449	t	0
223	\\x0dabba7a590dc7f15be9149429fd4fdb7e605d0aae363abe9a30c16940de7bbc	751	21	178331771	168229	0	287	\N	8449	t	0
224	\\x33ff4b2dd25a605c0d3a37d2fd1992a9a45ab3b1ff924650835d6feffab563f1	751	22	49753981254	168449	0	292	\N	8449	t	0
225	\\xc9acb7cd0bb0abb2f250c2c36b74f9902a654c72e6f05004509e2dc0058bfd82	751	23	49753811265	169989	0	327	\N	8449	t	0
226	\\xbe6631e6dce1d9fecf772c431a7264d3b5190cc5fec56b60db472068467aa1d6	751	24	49753981254	168449	0	292	\N	8449	t	0
227	\\x6e4fcc5df58897cb87d31b7ae9696e339170ad3a631ed774d9d7bd19c6d64460	751	25	49748642860	169989	0	327	\N	8449	t	0
228	\\x94281e2c53ad8c56fa35764ad2f3fd2d6a35c6738161b6df79a546ea5227db9d	751	26	1998950892303	168405	0	291	\N	8449	t	0
229	\\x8c541828f701fb7f4c1406d39dfd91963733c4abd37b55d75cd9ff9656884b2e	751	27	49748812849	168405	0	291	\N	8449	t	0
230	\\x05158b2019da05f173564f4aa4789954f5af9773752b9770a6a3cf2f1381dc54	751	28	49758979670	170033	0	328	\N	8449	t	0
231	\\xdcae791b8fd5eea01b71d293c4b4690bac66f261294b218be9f42f2f30d34e2c	751	29	9831771	168229	0	287	\N	8449	t	0
232	\\x3cb26f2918dec72991198b76582dce4117610bafc659185bcccab420e724c9a5	751	30	49743644444	168405	0	291	\N	8449	t	0
233	\\xba922e1c92046168662c63777bb92d54a00928d98644f9892bed31f7e4ba7007	751	31	9830187	169813	0	323	\N	8449	t	0
234	\\x9fa8bc659990d3726a163107fd5872ba6823c7f98bac3729063860b79fac770e	751	32	49748812849	168405	0	291	\N	8449	t	0
235	\\x9e31bed103a6d9e19971fed95bd0bb6690d0f07c2247990cab74811bcb4cd2f2	751	33	49753981254	168449	0	292	\N	8449	t	0
236	\\xd4802d6390c86c96bc89ec924f6cdaabf9e42bffdd826c5443554bd826b724f0	751	34	1998945723898	168405	0	291	\N	8449	t	0
237	\\x177516240f9d77261ba996369a0b204b97797c0f928469ccdabab455e318585e	751	35	49753981254	168449	0	292	\N	8449	t	0
238	\\xa0f0342f75092d918bdaf28b1b474d11a57c45f6f42e640522aa1b27ff63ac4e	751	36	9830187	169813	0	323	\N	8449	t	0
239	\\xcd4b62d6baf2e2bf3be6e4cd6f6bfb43c38ef2134bd9a33607cc40c53cf3fed2	751	37	49753811265	169989	0	327	\N	8449	t	0
240	\\x8896a5bc5a357031c74e1f1953b220a1adb178a02aab2797d0b600fbdc8f478f	751	38	49748812849	168405	0	291	\N	8449	t	0
241	\\x84e4b3371d4fbfa215d1989dcbc360463740dd3f4a07f70fbfd803236da09af9	751	39	49753981254	168449	0	292	\N	8449	t	0
242	\\x77ad06d1e3945f820b0ab9c7fbff863008bbe09fae50825c158854f9e56aad75	751	40	10828603	171397	0	359	\N	8449	t	0
243	\\x44dbb9430a563b2cb2d33272b134ab18ae0d09ea7b9e9e5da8f2f3293c826a6e	751	41	49753981254	168449	0	292	\N	8449	t	0
244	\\x8bf7164ccc4d954d8b89cbdb08f5f6bf0f1cdd26d9b8a1409a0cd4ad8e589bfe	751	42	1998940555493	168405	0	291	\N	8449	t	0
245	\\x5bad01df413c2315cc0594035f456965795dc25199e0d08335d9e6fe3341abd7	751	43	49758979670	170033	0	328	\N	8449	t	0
246	\\x5c2ec72ad1b5e2844b3be6de66951c8b80e710b7ecf2b144a9257801a7464210	751	44	9830187	169813	0	323	\N	8449	t	0
247	\\x1b3cbe39dc90748f16f0f4e63fffe49dff319b466be3f0f88868f962266b303d	751	45	49748812849	168405	0	291	\N	8449	t	0
248	\\x9ad5e87320fdf8fc9e710c4db7d91b0ed48bc91bd3133b5af8d01f44148462a1	751	46	9830187	169813	0	323	\N	8449	t	0
249	\\xe93c6c919d8ff809d8f42fbd2570bd61ccfd0ea22d13fd24ec6ca5ecb41a02a4	751	47	9830187	169813	0	323	\N	8449	t	0
250	\\x0330f1bae1d4a2cbf2242d7f52b16bf7464023b0a5059694222eacb6af03916b	751	48	49748812849	168405	0	291	\N	8449	t	0
251	\\x922375786fe06104dbdff0c3989ad0a2fc0b36e8848da067cda8ad1ca681e9fc	751	49	9830187	169813	0	323	\N	8449	t	0
252	\\x358b7cbd7bba64279f14843a3479e0e69e2003ba34b2805e7570b00760f17bbe	751	50	49753811265	169989	0	327	\N	8449	t	0
253	\\x94659fd2f90284d88a8803133aa323e7aa6ecee3697a241c0dbda5aa3021b3a3	751	51	49753981254	168449	0	292	\N	8449	t	0
254	\\xce9749a39be48d3ce23bb7f2bd0132886630166c56bde3ae44d6983e4494bf0b	751	52	9830187	169813	0	323	\N	8449	t	0
255	\\xee192b0f3a179de338a92dc09e67f4bdc05b1785ad7c445ed79f3aab8e24a2d4	751	53	49753811265	168405	0	291	\N	8449	t	0
256	\\x6a59ea014d700974909f3b9c69b071370b3ee9f73b4657d5540f00934e80eabe	751	54	49743644444	168405	0	291	\N	8449	t	0
257	\\xfb9fa7888302d41498ba2b9ebcc2936f98fd713b00a72981df0443dac3f78761	751	55	49753981254	168449	0	292	\N	8449	t	0
258	\\xf9a4205264c4f0ed6b33b0cfba180ea52bfcba04ab5e66bf6c7874eb3c228c40	751	56	49753981254	168449	0	292	\N	8449	t	0
259	\\x6b58b729292c9e5984645602e322d1e0ce1a0e086c1e17adccbb7993b34b0375	751	57	49753981254	168449	0	292	\N	8449	t	0
260	\\xcc91121e638c7bfc45511c5b0eca7330b4a8ffa5326b75f5e8ff34260fee12ab	751	58	49758809857	170033	0	328	\N	8449	t	0
261	\\x7aa9999a79a81be0522ddcc2491a2f5385b1a6b53a839cb167228db754ecd83a	751	59	49753981254	168449	0	292	\N	8449	t	0
262	\\x8b23099953123508e6707f2cc59279d9cdc37e6fdc60b74378129abedc36b82d	751	60	9660374	169813	0	323	\N	8449	t	0
263	\\x35d46dc4c1eca70c76c097e7fb854adc5cffbd6da8eabeb993921748332518a6	751	61	49743644444	168405	0	291	\N	8449	t	0
264	\\x0dc0bb9ae2bfccf04ae34b5b21d4d2c2bce2925cce79ef7660547cad71c3d216	751	62	9830187	169813	0	323	\N	8449	t	0
265	\\xb1b8c4345e59c2743bfb0830f18b315f8a09c29cd551c97d9792bba0094e4a76	751	63	9830187	169813	0	323	\N	8449	t	0
266	\\x0560273c5f04ff2625beea0e8bbeeac1965fe73862088c56869bbd1d87b8620b	751	64	49753811265	169989	0	327	\N	8449	t	0
267	\\xbc6e55f917ec9f7d437d3a3a3171c776717863cefa8168ae4cfe24f7a2ac9319	751	65	9830187	169813	0	323	\N	8449	t	0
268	\\x8a8e9d6fbd78028b4f920409e8c7e02fb0e58296abb5d1c9ad4aeb015c4e0f8a	751	66	9660374	169813	0	323	\N	8449	t	0
269	\\x9751c5bf550cb216e22e803747d16c3aa8b810615d9cfc7c7da37c7bc3409d29	751	67	9830187	169813	0	323	\N	8449	t	0
270	\\x037a65da582e559eea80fcd7cb8ef2ea3f544959567a1f49758c1791e314a5f9	751	68	49753981254	168449	0	292	\N	8449	t	0
271	\\xa639d466144e298bf3ab6862de6d03a0bc23c118c32c8172e5fab4eed7e45e3c	751	69	49753641452	168405	0	291	\N	8449	t	0
272	\\xd555956d410f58c33732fbb5421ada330544618ddfe14843f33c0957683fd267	751	70	9661958	169813	0	323	\N	8449	t	0
273	\\x90c6be6124f5ef59ed1cddba337d558f207bcfdedefb73eefc6c291ef1246597	751	71	9830187	169813	0	323	\N	8449	t	0
274	\\x9ad7f93876a53e199916f2b70f5d10697607156ebf0975602fde99d3a2d188e3	751	72	173163542	168229	0	287	\N	8449	t	0
275	\\x0337b5a806f03d6eca9d75662c858e9432ceac5e558733a406cb9504c54bacf7	751	73	49748473047	168405	0	291	\N	8449	t	0
276	\\x50403fb4838065cb9ee58b7b22805916d9346c061b1c7911d25bddb090f80789	751	74	9492145	169813	0	323	\N	8449	t	0
277	\\x02ef1ba132216265387a4ea4544f81861cb4ec53d2e2055df4b2e40a61f97334	751	75	49753981254	168449	0	292	\N	8449	t	0
278	\\x0951720fbf4dac76a1eb526d88fa9bf0d1d2fede296e9d30f4a2f1db6bb86c3f	751	76	49753981254	168449	0	292	\N	8449	t	0
279	\\xe0006d3efbe33f2d33760b19d5e01d7ee93605e2c357cc288d4e64fe804cf57d	751	77	49748642860	169989	0	327	\N	8449	t	0
280	\\xedb0bc040535d9ee83dc7b63451441554de60cbcc3d2bdbff72f45e20e8375c1	751	78	49753811265	168405	0	291	\N	8449	t	0
281	\\xe8ac901ef2551176cd6f8458a87d84a1598b6b77ecbcb58de14ba4ca17d9d186	751	79	49755119869	169989	0	327	\N	8449	t	0
282	\\xdcf2d4637fc09b233c931bd75ddf648bd190ddab8d665e9f4ea6ab314ca95348	751	80	49743644444	168405	0	291	\N	8449	t	0
283	\\x90d218a6f2a332636efdcd3d5ae8aaf78f49936a947cf9439dcbeba4e26c8e48	933	0	61851510982	174565	0	431	\N	10451	t	0
284	\\xe6483043e8f318e74f1a5c5ec795778622a1cc84a070a55d3e454508085e0af3	938	0	4996446186034	435617	0	6368	\N	10467	t	0
285	\\x7a399eecea9dae42927b55f889e5414f5241c729291e435398d0ebecad2f9218	1140	0	5003001832310	216365	0	1385	\N	12448	t	0
286	\\xd5327acc3ec02683481bb4973ac1c53d930da43ecf1ac186793213357bbb16ae	1140	1	5003001630157	202153	0	1062	\N	12448	t	0
287	\\xdb80e9cdd2002ef6aa1ed9ad92805a4674cb817440912d64471036b2279c247c	1141	0	5003001428004	202153	0	1062	\N	12448	t	0
288	\\xff159d304c72ec73dcb158cc5a780cb9b5cf83efe8ea443154b216c93c0db54a	1141	1	5003001225851	202153	0	1062	\N	12448	t	0
289	\\x05574fb104e37fc5d2f0e794b5b82a2d0fc51989234e992446be01a404b3438d	1141	2	5003001023698	202153	0	1062	\N	12450	t	0
290	\\x38937ed1d6cca689a5d8ce23992ee53cefdd52b7cd055b1e4426712daed0f341	1141	3	5003000821545	202153	0	1062	\N	12450	t	0
291	\\xe35b4c7f355d53822e356d1de2764a27009dd7661a856af601a7f54fba3a7d92	1141	4	5003000619392	202153	0	1062	\N	12450	t	0
292	\\x1462ee30c6a891d5dd897076eedf42b18088e67101485fe2ad58db1e7f6858c6	1141	5	5003000417239	202153	0	1062	\N	12450	t	0
293	\\xae5d35f542b1bd588da4897f624ae8a9f9a768f9154914076d9d792ff1f321a7	1141	6	5003000215086	202153	0	1062	\N	12450	t	0
294	\\xd7c2e22978add05a51f80b808b6bb6aa2b5a6ffd0b23758dc1f617f4cb93bcdb	1141	7	5003000012933	202153	0	1062	\N	12450	t	0
295	\\x7e46b696160e8fbec7035874830c268717a9ecc0b02bf2140f69911d2ce83222	1141	8	5002999810780	202153	0	1062	\N	12450	t	0
296	\\x2d9440dedf4888314f5c70ee96bae3361275d77b4c37dee19a721151515d20a4	1141	9	5002999608627	202153	0	1062	\N	12450	t	0
297	\\xa2b9f72dc94683b0034fe3b64156afa10e7136eeb9873049859781ba63205b3a	1142	0	5002999406474	202153	0	1062	\N	12450	t	0
298	\\x5d6306a740f583e1458b443c0a5eabc45cbaaf7989dd3699b9141a08a67997da	1142	1	5002999204321	202153	0	1062	\N	12450	t	0
299	\\x6f2d23402b1d38ca7fe9dc05d96a8babe30570d4e2d07379f3c9980326845691	1142	2	5002999002168	202153	0	1062	\N	12454	t	0
300	\\xcaa44ef0cb8066fc894455cdd74e08583015bc2702d1d4666b17fe68e466e6b4	1142	3	5002998800015	202153	0	1062	\N	12454	t	0
301	\\xc494c77cea8e06acc2b949d81c7af38155397714369fe50504def4ddb2df46a1	1142	4	5002998597862	202153	0	1062	\N	12454	t	0
302	\\xb76dfdc69283e95eb40fe5fa11a1ad8893de32d69b34531682dfc8575f18af17	1142	5	5002998395709	202153	0	1062	\N	12454	t	0
303	\\xc6782fc5e50fbbc23d523ac7b825ae01a0f7aa0e71c7505ed994d21c4aaa377f	1142	6	5002998193556	202153	0	1062	\N	12454	t	0
304	\\x0a4ddeeb3c56b0c5620bd5860cd7d9e0aad026fb750328fc15be43cb7a00f434	1142	7	5002997991403	202153	0	1062	\N	12454	t	0
305	\\xa07c2de0bbdf7005430e727f898e709a4ddb129df1ef873fa2c402b18a233a5a	1142	8	5002997789250	202153	0	1062	\N	12454	t	0
306	\\x5497fa510a1ee481496e49b05bde309c5c257f8c84b4506ce4301ac44b2d8017	1142	9	5002997587097	202153	0	1062	\N	12454	t	0
307	\\x4d163e1c4f275b4610318c02fbb4426c956f80ebf4edea911a957ff5b802ecd5	1142	10	5002997384944	202153	0	1062	\N	12454	t	0
308	\\x949d3a0ce8a1506935143019a64d3200f3c7d2dc633c92bfd2bb5176d015fe34	1142	11	5002997182791	202153	0	1062	\N	12454	t	0
309	\\x252ecee7778540b28706107d26e5c87d53c79e44e244cbdbd922c8268b38188d	1142	12	5002996980638	202153	0	1062	\N	12454	t	0
310	\\x7ce6a0266d22640af1476c914c8d27bd94d56ae7e9e856e79dd67baffa2ae79d	1142	13	5002996778485	202153	0	1062	\N	12454	t	0
311	\\x28a99a7584d97fede9e804e6e25c6fd3a4af40cea1ea229c4b4fe8fb25156283	1142	14	5002996576332	202153	0	1062	\N	12454	t	0
312	\\xb83a763aa37ea176f8fec88f58e255f90dcdab04237c2362c8c0f19c87f9a8d9	1142	15	5002996374179	202153	0	1062	\N	12454	t	0
313	\\x02592eb146448e6d26816db97498111ce991571efbe3207ff326d4fd4150f768	1142	16	5002996172026	202153	0	1062	\N	12454	t	0
314	\\x45f519a4e72d80d7f7dd61e5b00fe46e1cbce570f8685be2a9b296c17f2ea07d	1142	17	5002995969873	202153	0	1062	\N	12454	t	0
315	\\x7f1f72e6acfe89f4b108d73cc7b5252a62bc79e052c973a661026a5c34006b5f	1142	18	5002995767720	202153	0	1062	\N	12454	t	0
316	\\x2a5e4a7e75e090a552f40aee3b693c61d47755125cecf7ca78268ebcf868bcfb	1142	19	5002995565567	202153	0	1062	\N	12454	t	0
317	\\xafbe2b409a5810e1823321c288be6c7d931603c4142e425d91fe189d03033a7d	1142	20	5002995363414	202153	0	1062	\N	12454	t	0
318	\\x632a7877da84b93747dd19a23d6a7f4faf46d1b4d63c11aaad977b8c7b9ce89e	1142	21	5002995161261	202153	0	1062	\N	12454	t	0
319	\\xb68f852d7bdba0ee1a0af56d5391a96dc1f7d598690c21e369a129dda1a4c510	1142	22	5002994959108	202153	0	1062	\N	12454	t	0
320	\\xc31c3ef40ef8d548d1f98679b943cf890268450a8e249e0f164850269646c5bc	1142	23	5002994756955	202153	0	1062	\N	12454	t	0
321	\\x11b065ad1b7715636296ed5df58e416951b08da3e4e6eb44b375c44344db6c8e	1142	24	5002994554802	202153	0	1062	\N	12454	t	0
322	\\x298310a53a40a9cf23e9e17d646f2fa9970ae61b015935606f5f410482d54986	1142	25	5002994352649	202153	0	1062	\N	12454	t	0
323	\\xe2b9ec553848d6100c9f1170920e1e0af75e36dde362001b15cb5002135fed8f	1142	26	5002994150496	202153	0	1062	\N	12454	t	0
324	\\x99f89cc50daf6d4cfcf4c5c8631fd3012782355f93192afad94bcb926159a246	1142	27	5002993948343	202153	0	1062	\N	12454	t	0
325	\\x311c55e81d277854373552d0c6c0dd68e3073bd31b34641bdedc8fc69acbb57f	1142	28	5002993746190	202153	0	1062	\N	12454	t	0
326	\\x3b98170ac50f78ad90e08ed5c90fadfcddf3b1ba6fe4257de702f5dbce9189b3	1142	29	5002993544037	202153	0	1062	\N	12454	t	0
327	\\x2a42678cfa011a2cf064d83dda66fd04716fae74466cae3aceceb2dc59fc5842	1142	30	5002993341884	202153	0	1062	\N	12454	t	0
328	\\xe510b21fa3f907bb6115d4021152cacf33f5f4ee4f29303c255698f676337295	1142	31	5002993139731	202153	0	1062	\N	12454	t	0
329	\\x37aaf75dc2f7d43632757fdae410d154008db38fdcc3fde3b7225596e6f86174	1142	32	5002992937578	202153	0	1062	\N	12454	t	0
330	\\xcec79aa33da0fd7056ab40b6063876be402e6f744e8ac3c88923f97be2331d42	1142	33	5002992735425	202153	0	1062	\N	12454	t	0
331	\\x8c1554c25f0f4e2eaceafe2c8b94d9c872b817ed966ed67ca54a6bcc52946df2	1142	34	5002992533272	202153	0	1062	\N	12454	t	0
332	\\x0aa1d1f8b79ada405f5861942710ceeb6af53cb4111b98b0bffec3b95e806802	1142	35	5002992331119	202153	0	1062	\N	12454	t	0
333	\\x4ca4baee79f7c21a866a3c6cc1363a1419a197ebeeeef44bd33ab826177920ca	1142	36	5002992128966	202153	0	1062	\N	12454	t	0
334	\\xf538ad27edbec33186cad3a75d88b32d2f8c176a7fa601e49ad5678237695b66	1142	37	5002991926813	202153	0	1062	\N	12454	t	0
335	\\x52b0b62442423dd44d6b9c8cc09bfe1c4aa717518f2b166633463fa17176cbaa	1142	38	5002991724660	202153	0	1062	\N	12454	t	0
336	\\xbf0e0480007b5655236d1930819e4aa0959f8ea38bb18084a367288c0c2a9eb4	1142	39	5002991522507	202153	0	1062	\N	12454	t	0
337	\\x51946995613f2749934adf62b27918275f695c393c4621e41d62286390d5d954	1142	40	5002991320354	202153	0	1062	\N	12454	t	0
338	\\x1ed48de750bc085ada0d1f41359080be5f449f3614b57baeec6b46a8f196c511	1142	41	5002991118201	202153	0	1062	\N	12454	t	0
339	\\x8a78513011ad57d79ead06a91dd815f655958ae13a9571298c9814ae5c4a0770	1142	42	5002990916048	202153	0	1062	\N	12454	t	0
340	\\xe0c07e43ada125048071158525e695957fd9c06fc17d224f6b7677447b2566d4	1143	0	5002990713895	202153	0	1062	\N	12454	t	0
341	\\xfa1b08b6daaf1aa17dccd6912a7936374f0c0f6ea546d6eaff2efa48d5f573c2	1143	1	5002990511742	202153	0	1062	\N	12454	t	0
342	\\x6b67c8485b37ff3c8abb622e84dc67931e567c0996ba51a8bfefc16b90b7aeab	1145	0	5002990309589	202153	0	1062	\N	12454	t	0
343	\\xa26bcdea6003c974e6be6ab8ecc896f263b64b3ffb47b38e0e9b833f64275d20	1145	1	5002990107436	202153	0	1062	\N	12474	t	0
344	\\x60a6d1ebf154fa1f65b599eb1cab2bbca721ac37c43bbd837c95e9d4cd5a1909	1145	2	5002989905283	202153	0	1062	\N	12479	t	0
345	\\x5d2747d640236dcbf46de4620d175c95e70962e9429cb41452f19d1ba78da524	1145	3	5002989703130	202153	0	1062	\N	12479	t	0
346	\\xc1b27bc81a04373a9a099ce2fa98055e2cfee3bb51f8763fffd522d8b7045e86	1145	4	5002989500977	202153	0	1062	\N	12479	t	0
347	\\xf1b9e4505563a54ae586a5f36543eed69b37a6c6cb2b23ababb39f017e636921	1145	5	5002989298824	202153	0	1062	\N	12479	t	0
348	\\xb905cec1784e8009ce6cea572a49f9bbc3b330915c1a08e955495076fdfba973	1145	6	5002989096671	202153	0	1062	\N	12479	t	0
349	\\xa2d7ff37e955d1623883a5427316721e48dd3a4d48b6b296d16f5fe72914bb01	1145	7	5002988894518	202153	0	1062	\N	12479	t	0
350	\\xd0e12584c00a72f47b47f486583c616d56cf040ac8a2826f400161608fecec5f	1145	8	5002988692365	202153	0	1062	\N	12479	t	0
351	\\x183e9e6c84b1f5947c0a0b29e41b866685e35973b961d62d5c33b9744f9ac6f5	1145	9	5002988490212	202153	0	1062	\N	12479	t	0
352	\\x56f29e710004a38e13a9e86c3cfcf7c7b275e66db5544bdc4dc75f8788fbfba4	1145	10	5002988288059	202153	0	1062	\N	12479	t	0
353	\\x3bfdfb7bd1a7844453f29a63f5c976d83eba5ad157b831d4725dd1e58ce83a8f	1145	11	5002988085906	202153	0	1062	\N	12479	t	0
354	\\xd2cf0037117bcee24c632423f616f089f38696f70c66e221102d167245c7bb4a	1145	12	5002987883753	202153	0	1062	\N	12479	t	0
355	\\x8ae85c4b9774ae524cd5a817116049d4dab56552788674d11840845cce0da291	1145	13	5002987681600	202153	0	1062	\N	12479	t	0
356	\\x9a7e905d5b5edd8a333fa1780356512640ce6a0185cca6c395a21ed623463df0	1145	14	5002987479447	202153	0	1062	\N	12479	t	0
357	\\xac3accde7c2faf38cf14bf447ad1b2a878c653c7027858f26384a65c53747e47	1146	0	5002987277294	202153	0	1062	\N	12479	t	0
358	\\x7ce07e3bc057995ce575843d0ef549bfd9d65bce594a575b3fb46e0a0d1403b2	1146	1	5002987075141	202153	0	1062	\N	12479	t	0
359	\\x4b0e86ba0790908b464fa7049287bb395136c3f99d24379eeb2db4312cd90838	1146	2	5002986872988	202153	0	1062	\N	12486	t	0
360	\\x03bc362e81b25f37f3350560258e17f8a78f5da70b43d93f0573feef50725275	1146	3	5002986670835	202153	0	1062	\N	12486	t	0
361	\\x8a0478644fe958f6805e0bc6e7dbf5f25627c1aa1330bda4e6f059c661cd15fe	1146	4	5002986468682	202153	0	1062	\N	12486	t	0
362	\\x1df3644a7bac5bf01847a1c74007fb541c506254399b6c7c015002643c592c91	1146	5	5002986266529	202153	0	1062	\N	12486	t	0
363	\\x345f01db50fd6a41584a50d85b6fa5e2944274d7830c213900d5726a6a64a76f	1146	6	5002986064376	202153	0	1062	\N	12486	t	0
364	\\x615f02b4e7e3fdb90ed2f27c579ba292724450c737021761e6e24bbb2fa8f268	1146	7	5002985862223	202153	0	1062	\N	12486	t	0
365	\\x55fe8464dcdd44f619cc0f91f4ee2546bb2a80712c1b12134bec2e8772ff7815	1146	8	5002985660070	202153	0	1062	\N	12486	t	0
366	\\x4d161354c0ab9b8eb8718c1ba541b2ada05714649f137d4b93604187e53917bc	1146	9	5002985457917	202153	0	1062	\N	12486	t	0
367	\\x44fa9dd3ab89355206c17bd5705ad8d46230db126d85d73b6f208a6417c59915	1146	10	5002985255764	202153	0	1062	\N	12486	t	0
368	\\x7fa7e1d9a51331ab9e7964028174e05df9976e85f5df2f919aa798c6391f6dd0	1146	11	5002985053611	202153	0	1062	\N	12486	t	0
369	\\xf7c55795761109a3d9d262a48baabe9fb4221ae50560d6673d6537902236a206	1146	12	5002984851458	202153	0	1062	\N	12486	t	0
370	\\x3d3eff30302f2027a2d3dd48e1c3710e88ede9f0e0916016d57bcf97d80b8961	1146	13	5002984649305	202153	0	1062	\N	12486	t	0
371	\\x7ec54cf10863a62d18506943f3f65b3a5885b7e2badc4d8cd99eb74960ef8d05	1146	14	5002984447152	202153	0	1062	\N	12486	t	0
372	\\x27b69b0a0a1863a120c6d8816a542f9c2c397d2b32864fa70421c4d88df628d9	1146	15	5002984244999	202153	0	1062	\N	12486	t	0
373	\\x337e0b7f0f9aa1c4736f5115adcd0e7d0b5ba7feedb9a1c2a96ffcef9d3769b1	1146	16	5002984042846	202153	0	1062	\N	12486	t	0
374	\\xd4751e31ebe16b66a6755a13cee78cfdfdd7f92e23b4ec99f27308256486c228	1146	17	5002983840693	202153	0	1062	\N	12486	t	0
375	\\x84a0dc755c7a9572a1c5221400b3dc3f109293e2b3d75f183ce915c04a08a05f	1146	18	5002983638540	202153	0	1062	\N	12486	t	0
376	\\xf9724e9ec23bb8ae4e03941a8b977d49d69b35ef59b826fe6fcc9e9004a8310e	1146	19	5002983436387	202153	0	1062	\N	12486	t	0
377	\\x4a63e69e0b639d3ea239197c8c940cb43b0e347f1a406d045b1f828cfa4bd921	1146	20	5002983234234	202153	0	1062	\N	12486	t	0
378	\\x60ac7286215ff15104c81731841620b1e19d2e30b4e4c3b7ba0e5d43d7aee1d1	1146	21	5002983032081	202153	0	1062	\N	12486	t	0
379	\\x7fafb388e40da069f4c1eecddd6a43868566d0c87115d7eee044904d3a5422a0	1146	22	5002982829928	202153	0	1062	\N	12486	t	0
380	\\x61e3c280ff04e9cdfedc7947c06f2adb3c125a47b7b6b90147ff02bbe00c7c9b	1146	23	5002982627775	202153	0	1062	\N	12486	t	0
381	\\x5d003646488254ad4ae95f06213330c8753f356a52b9f49e88c3566641ca9802	1146	24	5002982425622	202153	0	1062	\N	12486	t	0
382	\\x54f8320c6bfe5ceb87485e74056dc2c05d022d21f101ececfa25939f57c30712	1146	25	5002982223469	202153	0	1062	\N	12486	t	0
383	\\xb9ec0328ec1540551cf50a0a55d07b087438035ac8f4aec569f1805dc24c4d7c	1146	26	5002982021316	202153	0	1062	\N	12486	t	0
384	\\x9a1175d216fb56ca87e0afb6b47b387dbd1e60d2506a651caad1548ce43aa51f	1146	27	5002981819163	202153	0	1062	\N	12486	t	0
385	\\x002aadfa5f826cd5c6d4578d5636e91bccf37bd2c14c7ec9d231474a9e3f57e7	1337	0	5008337661041	214473	0	1342	\N	14449	t	0
386	\\x8081f21a566b48855b7b5f338a7ae3758e83593ebf32b49589994caaa18d39e9	1343	0	4999999820111	179889	0	552	\N	14534	t	0
387	\\xe8e24150716bf70053532c8db5bfce7b6441a5ff10b786ab4ea3ce04bf178a44	1347	0	4999999648538	171573	0	363	\N	14607	t	0
388	\\xdb99620dce36f288384b61c21b33f9f86317b2ce886213e69606498ad7538075	1351	0	4999996472785	175753	0	458	\N	14646	t	0
389	\\x02a1ec12147954f6b232e7b659bef24caf518e9c57f404c9eeb9db03cfad726c	1355	0	2828559	171441	0	360	\N	14692	t	0
390	\\x5f1282a56a2cfa42fd10ca9364ab9a9a4b768f2e6141446c87eb1a8949d00ac9	1357	0	9818351	181649	0	592	\N	14695	t	0
391	\\xba16e323340344083b25c4ade8b1fb82cd15771d4d8e1ff7d0e402cb96ccf363	1361	0	9827019	172981	0	395	\N	14735	t	0
392	\\xccba2c494dddef35efef6bc08516bcf0151a1fc655e9107351551fa81b0e5810	1366	0	9820683	179317	0	539	\N	14762	t	0
393	\\xb853812e87132117f4e3ea049db7f184aeb3570c8a403bf82b0fec7219462ab9	1371	0	1252082984034	234845	0	1700	\N	14812	t	0
394	\\xe82a91883cc4b307b665477090b67e043fa1eb4bb851d26aafd7ce4a86d4be49	1375	0	626041387310	222129	0	1411	\N	14860	t	0
395	\\x13ecb9207e88262d227a8c48dd1cc65b53bd1d3472060846090a8881090443c2	1379	0	39127377625	222965	0	1430	\N	14912	t	0
396	\\xf86a42798bf4a6824454fc539e37d0d9004e8ab5d704f176b9e8f99d5f222db8	1383	0	4808803	191197	0	708	\N	14953	t	0
\.


--
-- Data for Name: tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_in (id, tx_in_id, tx_out_id, tx_out_index, redeemer_id) FROM stdin;
1	35	33	0	\N
2	36	20	0	\N
3	37	14	0	\N
4	38	13	0	\N
5	39	22	0	\N
6	40	29	0	\N
7	41	31	0	\N
8	42	24	0	\N
9	43	28	0	\N
10	44	16	0	\N
11	45	30	0	\N
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
24	58	57	1	\N
25	59	58	0	\N
26	60	46	0	\N
27	61	60	0	\N
28	62	59	0	\N
29	63	62	1	\N
30	64	63	0	\N
31	65	47	0	\N
32	66	65	0	\N
33	67	64	0	\N
34	68	67	1	\N
35	69	68	0	\N
36	70	48	0	\N
37	71	70	0	\N
38	72	69	0	\N
39	73	72	1	\N
40	74	73	0	\N
41	75	49	0	\N
42	76	75	0	\N
43	77	74	0	\N
44	78	77	1	\N
45	79	78	0	\N
46	80	50	0	\N
47	81	80	0	\N
48	82	79	0	\N
49	83	82	1	\N
50	84	83	0	\N
51	85	51	0	\N
52	86	85	0	\N
53	87	84	0	\N
54	88	87	1	\N
55	89	88	0	\N
56	90	52	0	\N
57	91	90	0	\N
58	92	89	0	\N
59	93	92	1	\N
60	94	93	0	\N
61	95	53	0	\N
62	96	95	0	\N
63	97	96	0	\N
64	98	94	0	\N
65	99	98	0	\N
66	100	99	1	\N
67	101	100	0	\N
68	102	54	0	\N
69	103	102	0	\N
70	104	103	0	\N
71	105	101	0	\N
72	106	105	0	\N
73	107	106	1	\N
74	108	107	0	\N
75	109	55	0	\N
76	110	109	0	\N
77	111	110	0	\N
78	112	108	0	\N
79	113	112	0	\N
80	114	113	1	\N
81	115	114	0	\N
82	116	56	0	\N
83	117	116	0	\N
84	118	117	0	\N
85	119	115	0	\N
86	120	36	1	\N
87	121	120	0	1
88	122	120	1	\N
89	123	122	1	\N
90	124	123	1	\N
91	125	124	1	\N
92	126	125	1	\N
93	127	126	1	\N
94	128	127	0	2
95	128	127	1	\N
96	129	35	1	\N
97	130	119	0	\N
98	131	130	0	\N
99	132	131	1	\N
100	133	132	1	\N
101	134	133	0	\N
102	134	133	1	\N
103	135	134	1	\N
104	136	135	0	\N
105	137	134	0	\N
106	138	135	1	\N
107	139	137	0	\N
108	140	138	0	\N
109	141	139	0	\N
110	142	140	0	\N
111	143	136	0	\N
112	144	141	0	\N
113	145	142	0	\N
114	146	144	0	\N
115	147	145	0	\N
116	148	146	0	\N
117	149	147	0	\N
118	150	148	0	\N
120	152	150	0	\N
121	153	149	0	\N
122	154	143	0	\N
123	155	154	0	\N
124	156	152	0	\N
125	157	156	0	\N
126	157	156	1	\N
127	158	153	0	\N
128	159	157	1	\N
129	160	158	1	\N
130	161	160	0	\N
131	161	159	0	\N
132	161	159	1	\N
133	161	158	0	\N
134	162	160	1	\N
135	162	157	0	\N
136	163	162	0	\N
137	164	163	0	\N
138	164	163	1	\N
139	164	163	2	\N
140	164	163	3	\N
141	164	163	4	\N
142	164	163	5	\N
143	164	163	6	\N
144	164	163	7	\N
145	164	163	8	\N
146	164	163	9	\N
147	164	163	10	\N
148	164	163	11	\N
149	164	163	12	\N
150	164	163	13	\N
151	164	163	14	\N
152	164	163	15	\N
153	164	163	16	\N
154	164	163	17	\N
155	164	163	18	\N
156	164	163	19	\N
157	164	163	20	\N
158	164	163	21	\N
159	164	163	22	\N
160	164	163	23	\N
161	164	163	24	\N
162	164	163	25	\N
163	164	163	26	\N
164	164	163	27	\N
165	164	163	28	\N
166	164	163	29	\N
167	164	163	30	\N
168	164	163	31	\N
169	164	163	32	\N
170	164	163	33	\N
171	164	163	34	\N
172	165	164	0	\N
173	165	164	1	\N
174	165	164	2	\N
175	165	164	3	\N
176	165	164	4	\N
177	165	164	5	\N
178	165	164	6	\N
179	165	164	7	\N
180	165	164	8	\N
181	166	162	1	\N
182	167	166	0	\N
183	168	161	0	\N
184	169	168	0	\N
185	170	168	1	\N
186	171	170	0	\N
187	171	170	1	\N
188	171	170	2	\N
189	171	170	3	\N
190	171	170	4	\N
191	171	170	5	\N
192	171	170	6	\N
193	171	170	7	\N
194	171	170	8	\N
195	171	170	9	\N
196	171	170	10	\N
197	171	170	11	\N
198	171	170	12	\N
199	171	170	13	\N
200	171	170	14	\N
201	171	170	15	\N
202	171	170	16	\N
203	171	170	17	\N
204	171	170	18	\N
205	171	170	19	\N
206	171	170	20	\N
207	171	170	21	\N
208	171	170	22	\N
209	171	170	23	\N
210	171	170	24	\N
211	171	170	25	\N
212	171	170	26	\N
213	171	170	27	\N
214	171	170	28	\N
215	171	170	29	\N
216	171	170	30	\N
217	171	170	31	\N
218	171	170	32	\N
219	171	170	33	\N
220	171	170	34	\N
221	171	170	35	\N
222	171	170	36	\N
223	171	170	37	\N
224	171	170	38	\N
225	171	170	39	\N
226	171	170	40	\N
227	171	170	41	\N
228	171	170	42	\N
229	171	170	43	\N
230	171	170	44	\N
231	171	170	45	\N
232	171	170	46	\N
233	171	170	47	\N
234	171	170	48	\N
235	171	170	49	\N
236	171	170	50	\N
237	171	170	51	\N
238	171	170	52	\N
239	171	170	53	\N
240	171	170	54	\N
241	171	170	55	\N
242	171	170	56	\N
243	171	170	57	\N
244	171	170	58	\N
245	171	170	59	\N
246	172	170	66	\N
247	173	166	1	\N
248	174	169	0	\N
249	174	170	81	\N
250	175	170	114	\N
251	176	170	71	\N
252	177	176	0	\N
253	178	177	1	\N
254	179	170	70	\N
255	180	179	0	\N
256	181	172	1	\N
257	181	180	0	\N
258	182	167	0	\N
259	183	170	109	\N
260	184	174	1	\N
261	185	170	93	\N
262	186	170	115	\N
263	186	185	0	\N
264	187	182	0	\N
265	187	170	89	\N
266	188	170	83	\N
267	189	170	67	\N
268	190	170	119	\N
269	191	185	1	\N
270	192	173	0	\N
271	193	176	1	\N
272	194	170	98	\N
273	195	170	76	\N
274	196	187	1	\N
275	197	170	62	\N
276	198	170	92	\N
277	199	170	111	\N
278	200	170	72	\N
279	201	170	86	\N
280	202	184	1	\N
281	203	190	1	\N
282	204	179	1	\N
283	204	197	0	\N
284	204	175	0	\N
285	205	170	63	\N
286	206	197	1	\N
287	207	170	100	\N
288	208	188	1	\N
289	209	170	75	\N
290	210	189	1	\N
291	211	170	113	\N
292	212	170	90	\N
293	213	203	1	\N
294	214	207	1	\N
295	215	170	117	\N
296	216	170	102	\N
297	217	170	96	\N
298	218	216	1	\N
299	219	170	64	\N
300	220	170	69	\N
301	221	200	1	\N
302	222	193	1	\N
303	223	171	0	\N
304	224	170	97	\N
305	225	211	1	\N
306	225	216	0	\N
307	226	170	101	\N
308	227	206	1	\N
309	227	188	0	\N
310	228	192	1	\N
311	229	220	1	\N
312	230	214	0	\N
313	230	170	87	\N
314	231	174	0	\N
315	232	208	1	\N
316	233	212	0	\N
317	233	218	0	\N
318	234	209	1	\N
319	235	170	94	\N
320	236	228	1	\N
321	237	170	106	\N
322	238	237	0	\N
323	238	222	0	\N
324	239	237	1	\N
325	239	238	0	\N
326	240	198	1	\N
327	241	170	118	\N
328	242	177	0	\N
329	242	193	0	\N
330	242	208	0	\N
331	243	170	80	\N
332	244	236	1	\N
333	245	170	79	\N
334	245	226	0	\N
335	246	240	0	\N
336	246	228	0	\N
337	247	224	1	\N
338	248	223	0	\N
339	248	198	0	\N
340	249	242	0	\N
341	249	207	0	\N
342	250	205	1	\N
343	251	201	0	\N
344	251	183	0	\N
345	252	221	0	\N
346	252	195	1	\N
347	253	170	68	\N
348	254	200	0	\N
349	254	231	0	\N
350	255	230	1	\N
351	256	221	1	\N
352	257	170	107	\N
353	258	170	104	\N
354	259	170	105	\N
355	260	251	1	\N
356	260	170	103	\N
357	261	170	91	\N
358	262	246	1	\N
359	262	229	0	\N
360	263	229	1	\N
361	264	191	0	\N
362	264	205	0	\N
363	265	261	0	\N
364	265	248	0	\N
365	266	243	1	\N
366	266	262	0	\N
367	267	192	0	\N
368	267	246	0	\N
369	268	264	1	\N
370	268	243	0	\N
371	269	219	0	\N
372	269	210	0	\N
373	270	170	82	\N
374	271	260	1	\N
375	272	215	0	\N
376	272	231	1	\N
377	273	224	0	\N
378	273	203	0	\N
379	274	223	1	\N
380	275	271	1	\N
381	276	247	0	\N
382	276	272	1	\N
383	277	170	112	\N
384	278	170	84	\N
385	279	251	0	\N
386	279	214	1	\N
387	280	245	1	\N
388	281	181	1	\N
389	281	276	1	\N
390	282	250	1	\N
391	283	170	60	\N
392	284	277	0	\N
393	284	277	1	\N
394	284	250	0	\N
395	284	275	0	\N
396	284	275	1	\N
397	284	270	0	\N
398	284	270	1	\N
399	284	196	0	\N
400	284	196	1	\N
401	284	230	0	\N
402	284	266	0	\N
403	284	266	1	\N
404	284	219	1	\N
405	284	278	0	\N
406	284	278	1	\N
407	284	187	0	\N
408	284	264	0	\N
409	284	247	1	\N
410	284	191	1	\N
411	284	211	0	\N
412	284	201	1	\N
413	284	252	0	\N
414	284	252	1	\N
415	284	263	0	\N
416	284	263	1	\N
417	284	232	0	\N
418	284	232	1	\N
419	284	202	0	\N
420	284	202	1	\N
421	284	210	1	\N
422	284	204	0	\N
423	284	204	1	\N
424	284	213	0	\N
425	284	213	1	\N
426	284	276	0	\N
427	284	206	0	\N
428	284	245	0	\N
429	284	220	0	\N
430	284	212	1	\N
431	284	256	0	\N
432	284	256	1	\N
433	284	259	0	\N
434	284	259	1	\N
435	284	227	0	\N
436	284	227	1	\N
437	284	194	0	\N
438	284	194	1	\N
439	284	190	0	\N
440	284	242	1	\N
441	284	261	1	\N
442	284	218	1	\N
443	284	184	0	\N
444	284	241	0	\N
445	284	241	1	\N
446	284	183	1	\N
447	284	240	1	\N
448	284	268	0	\N
449	284	268	1	\N
450	284	262	1	\N
451	284	244	0	\N
452	284	244	1	\N
453	284	273	0	\N
454	284	273	1	\N
455	284	283	0	\N
456	284	283	1	\N
457	284	253	0	\N
458	284	253	1	\N
459	284	269	0	\N
460	284	269	1	\N
461	284	186	0	\N
462	284	186	1	\N
463	284	248	1	\N
464	284	274	0	\N
465	284	274	1	\N
466	284	235	0	\N
467	284	235	1	\N
468	284	234	0	\N
469	284	234	1	\N
470	284	238	1	\N
471	284	222	1	\N
472	284	271	0	\N
473	284	217	0	\N
474	284	217	1	\N
475	284	170	61	\N
476	284	170	65	\N
477	284	170	73	\N
478	284	170	74	\N
479	284	170	77	\N
480	284	170	78	\N
481	284	170	85	\N
482	284	170	88	\N
483	284	170	95	\N
484	284	170	99	\N
485	284	170	108	\N
486	284	170	110	\N
487	284	170	116	\N
488	284	265	0	\N
489	284	265	1	\N
490	284	195	0	\N
491	284	233	0	\N
492	284	233	1	\N
493	284	267	0	\N
494	284	267	1	\N
495	284	209	0	\N
496	284	226	1	\N
497	284	189	0	\N
498	284	225	0	\N
499	284	225	1	\N
500	284	260	0	\N
501	284	239	0	\N
502	284	239	1	\N
503	284	254	0	\N
504	284	254	1	\N
505	284	236	0	\N
506	284	272	0	\N
507	284	215	1	\N
508	284	175	1	\N
509	284	282	0	\N
510	284	282	1	\N
511	284	199	0	\N
512	284	199	1	\N
513	284	279	0	\N
514	284	279	1	\N
515	284	281	0	\N
516	284	281	1	\N
517	284	249	0	\N
518	284	249	1	\N
519	284	280	0	\N
520	284	280	1	\N
521	284	255	0	\N
522	284	255	1	\N
523	284	258	0	\N
524	284	258	1	\N
525	284	257	0	\N
526	284	257	1	\N
527	285	284	0	\N
528	285	284	1	\N
529	285	284	2	\N
530	285	284	3	\N
531	285	284	4	\N
532	285	284	5	\N
533	285	284	6	\N
534	285	284	7	\N
535	285	284	8	\N
536	285	284	9	\N
537	285	284	10	\N
538	285	284	11	\N
539	285	284	12	\N
540	285	284	13	\N
541	286	285	0	\N
542	286	285	1	\N
543	286	285	2	\N
544	286	285	3	\N
545	286	285	4	\N
546	286	285	5	\N
547	286	285	6	\N
548	286	285	7	\N
549	286	285	8	\N
550	287	286	0	\N
551	287	286	1	\N
552	287	286	2	\N
553	287	286	3	\N
554	287	286	4	\N
555	287	286	5	\N
556	287	286	6	\N
557	287	286	7	\N
558	287	286	8	\N
559	288	287	0	\N
560	288	287	1	\N
561	288	287	2	\N
562	288	287	3	\N
563	288	287	4	\N
564	288	287	5	\N
565	288	287	6	\N
566	288	287	7	\N
567	288	287	8	\N
568	289	288	0	\N
569	289	288	1	\N
570	289	288	2	\N
571	289	288	3	\N
572	289	288	4	\N
573	289	288	5	\N
574	289	288	6	\N
575	289	288	7	\N
576	289	288	8	\N
577	290	289	0	\N
578	290	289	1	\N
579	290	289	2	\N
580	290	289	3	\N
581	290	289	4	\N
582	290	289	5	\N
583	290	289	6	\N
584	290	289	7	\N
585	290	289	8	\N
586	291	290	0	\N
587	291	290	1	\N
588	291	290	2	\N
589	291	290	3	\N
590	291	290	4	\N
591	291	290	5	\N
592	291	290	6	\N
593	291	290	7	\N
594	291	290	8	\N
595	292	291	0	\N
596	292	291	1	\N
597	292	291	2	\N
598	292	291	3	\N
599	292	291	4	\N
600	292	291	5	\N
601	292	291	6	\N
602	292	291	7	\N
603	292	291	8	\N
604	293	292	0	\N
605	293	292	1	\N
606	293	292	2	\N
607	293	292	3	\N
608	293	292	4	\N
609	293	292	5	\N
610	293	292	6	\N
611	293	292	7	\N
612	293	292	8	\N
613	294	293	0	\N
614	294	293	1	\N
615	294	293	2	\N
616	294	293	3	\N
617	294	293	4	\N
618	294	293	5	\N
619	294	293	6	\N
620	294	293	7	\N
621	294	293	8	\N
622	295	294	0	\N
623	295	294	1	\N
624	295	294	2	\N
625	295	294	3	\N
626	295	294	4	\N
627	295	294	5	\N
628	295	294	6	\N
629	295	294	7	\N
630	295	294	8	\N
631	296	295	0	\N
632	296	295	1	\N
633	296	295	2	\N
634	296	295	3	\N
635	296	295	4	\N
636	296	295	5	\N
637	296	295	6	\N
638	296	295	7	\N
639	296	295	8	\N
640	297	296	0	\N
641	297	296	1	\N
642	297	296	2	\N
643	297	296	3	\N
644	297	296	4	\N
645	297	296	5	\N
646	297	296	6	\N
647	297	296	7	\N
648	297	296	8	\N
649	298	297	0	\N
650	298	297	1	\N
651	298	297	2	\N
652	298	297	3	\N
653	298	297	4	\N
654	298	297	5	\N
655	298	297	6	\N
656	298	297	7	\N
657	298	297	8	\N
658	299	298	0	\N
659	299	298	1	\N
660	299	298	2	\N
661	299	298	3	\N
662	299	298	4	\N
663	299	298	5	\N
664	299	298	6	\N
665	299	298	7	\N
666	299	298	8	\N
667	300	299	0	\N
668	300	299	1	\N
669	300	299	2	\N
670	300	299	3	\N
671	300	299	4	\N
672	300	299	5	\N
673	300	299	6	\N
674	300	299	7	\N
675	300	299	8	\N
676	301	300	0	\N
677	301	300	1	\N
678	301	300	2	\N
679	301	300	3	\N
680	301	300	4	\N
681	301	300	5	\N
682	301	300	6	\N
683	301	300	7	\N
684	301	300	8	\N
685	302	301	0	\N
686	302	301	1	\N
687	302	301	2	\N
688	302	301	3	\N
689	302	301	4	\N
690	302	301	5	\N
691	302	301	6	\N
692	302	301	7	\N
693	302	301	8	\N
694	303	302	0	\N
695	303	302	1	\N
696	303	302	2	\N
697	303	302	3	\N
698	303	302	4	\N
699	303	302	5	\N
700	303	302	6	\N
701	303	302	7	\N
702	303	302	8	\N
703	304	303	0	\N
704	304	303	1	\N
705	304	303	2	\N
706	304	303	3	\N
707	304	303	4	\N
708	304	303	5	\N
709	304	303	6	\N
710	304	303	7	\N
711	304	303	8	\N
712	305	304	0	\N
713	305	304	1	\N
714	305	304	2	\N
715	305	304	3	\N
716	305	304	4	\N
717	305	304	5	\N
718	305	304	6	\N
719	305	304	7	\N
720	305	304	8	\N
721	306	305	0	\N
722	306	305	1	\N
723	306	305	2	\N
724	306	305	3	\N
725	306	305	4	\N
726	306	305	5	\N
727	306	305	6	\N
728	306	305	7	\N
729	306	305	8	\N
730	307	306	0	\N
731	307	306	1	\N
732	307	306	2	\N
733	307	306	3	\N
734	307	306	4	\N
735	307	306	5	\N
736	307	306	6	\N
737	307	306	7	\N
738	307	306	8	\N
739	308	307	0	\N
740	308	307	1	\N
741	308	307	2	\N
742	308	307	3	\N
743	308	307	4	\N
744	308	307	5	\N
745	308	307	6	\N
746	308	307	7	\N
747	308	307	8	\N
748	309	308	0	\N
749	309	308	1	\N
750	309	308	2	\N
751	309	308	3	\N
752	309	308	4	\N
753	309	308	5	\N
754	309	308	6	\N
755	309	308	7	\N
756	309	308	8	\N
757	310	309	0	\N
758	310	309	1	\N
759	310	309	2	\N
760	310	309	3	\N
761	310	309	4	\N
762	310	309	5	\N
763	310	309	6	\N
764	310	309	7	\N
765	310	309	8	\N
766	311	310	0	\N
767	311	310	1	\N
768	311	310	2	\N
769	311	310	3	\N
770	311	310	4	\N
771	311	310	5	\N
772	311	310	6	\N
773	311	310	7	\N
774	311	310	8	\N
775	312	311	0	\N
776	312	311	1	\N
777	312	311	2	\N
778	312	311	3	\N
779	312	311	4	\N
780	312	311	5	\N
781	312	311	6	\N
782	312	311	7	\N
783	312	311	8	\N
784	313	312	0	\N
785	313	312	1	\N
786	313	312	2	\N
787	313	312	3	\N
788	313	312	4	\N
789	313	312	5	\N
790	313	312	6	\N
791	313	312	7	\N
792	313	312	8	\N
793	314	313	0	\N
794	314	313	1	\N
795	314	313	2	\N
796	314	313	3	\N
797	314	313	4	\N
798	314	313	5	\N
799	314	313	6	\N
800	314	313	7	\N
801	314	313	8	\N
802	315	314	0	\N
803	315	314	1	\N
804	315	314	2	\N
805	315	314	3	\N
806	315	314	4	\N
807	315	314	5	\N
808	315	314	6	\N
809	315	314	7	\N
810	315	314	8	\N
811	316	315	0	\N
812	316	315	1	\N
813	316	315	2	\N
814	316	315	3	\N
815	316	315	4	\N
816	316	315	5	\N
817	316	315	6	\N
818	316	315	7	\N
819	316	315	8	\N
820	317	316	0	\N
821	317	316	1	\N
822	317	316	2	\N
823	317	316	3	\N
824	317	316	4	\N
825	317	316	5	\N
826	317	316	6	\N
827	317	316	7	\N
828	317	316	8	\N
829	318	317	0	\N
830	318	317	1	\N
831	318	317	2	\N
832	318	317	3	\N
833	318	317	4	\N
834	318	317	5	\N
835	318	317	6	\N
836	318	317	7	\N
837	318	317	8	\N
838	319	318	0	\N
839	319	318	1	\N
840	319	318	2	\N
841	319	318	3	\N
842	319	318	4	\N
843	319	318	5	\N
844	319	318	6	\N
845	319	318	7	\N
846	319	318	8	\N
847	320	319	0	\N
848	320	319	1	\N
849	320	319	2	\N
850	320	319	3	\N
851	320	319	4	\N
852	320	319	5	\N
853	320	319	6	\N
854	320	319	7	\N
855	320	319	8	\N
856	321	320	0	\N
857	321	320	1	\N
858	321	320	2	\N
859	321	320	3	\N
860	321	320	4	\N
861	321	320	5	\N
862	321	320	6	\N
863	321	320	7	\N
864	321	320	8	\N
865	322	321	0	\N
866	322	321	1	\N
867	322	321	2	\N
868	322	321	3	\N
869	322	321	4	\N
870	322	321	5	\N
871	322	321	6	\N
872	322	321	7	\N
873	322	321	8	\N
874	323	322	0	\N
875	323	322	1	\N
876	323	322	2	\N
877	323	322	3	\N
878	323	322	4	\N
879	323	322	5	\N
880	323	322	6	\N
881	323	322	7	\N
882	323	322	8	\N
883	324	323	0	\N
884	324	323	1	\N
885	324	323	2	\N
886	324	323	3	\N
887	324	323	4	\N
888	324	323	5	\N
889	324	323	6	\N
890	324	323	7	\N
891	324	323	8	\N
892	325	324	0	\N
893	325	324	1	\N
894	325	324	2	\N
895	325	324	3	\N
896	325	324	4	\N
897	325	324	5	\N
898	325	324	6	\N
899	325	324	7	\N
900	325	324	8	\N
901	326	325	0	\N
902	326	325	1	\N
903	326	325	2	\N
904	326	325	3	\N
905	326	325	4	\N
906	326	325	5	\N
907	326	325	6	\N
908	326	325	7	\N
909	326	325	8	\N
910	327	326	0	\N
911	327	326	1	\N
912	327	326	2	\N
913	327	326	3	\N
914	327	326	4	\N
915	327	326	5	\N
916	327	326	6	\N
917	327	326	7	\N
918	327	326	8	\N
919	328	327	0	\N
920	328	327	1	\N
921	328	327	2	\N
922	328	327	3	\N
923	328	327	4	\N
924	328	327	5	\N
925	328	327	6	\N
926	328	327	7	\N
927	328	327	8	\N
928	329	328	0	\N
929	329	328	1	\N
930	329	328	2	\N
931	329	328	3	\N
932	329	328	4	\N
933	329	328	5	\N
934	329	328	6	\N
935	329	328	7	\N
936	329	328	8	\N
937	330	329	0	\N
938	330	329	1	\N
939	330	329	2	\N
940	330	329	3	\N
941	330	329	4	\N
942	330	329	5	\N
943	330	329	6	\N
944	330	329	7	\N
945	330	329	8	\N
946	331	330	0	\N
947	331	330	1	\N
948	331	330	2	\N
949	331	330	3	\N
950	331	330	4	\N
951	331	330	5	\N
952	331	330	6	\N
953	331	330	7	\N
954	331	330	8	\N
955	332	331	0	\N
956	332	331	1	\N
957	332	331	2	\N
958	332	331	3	\N
959	332	331	4	\N
960	332	331	5	\N
961	332	331	6	\N
962	332	331	7	\N
963	332	331	8	\N
964	333	332	0	\N
965	333	332	1	\N
966	333	332	2	\N
967	333	332	3	\N
968	333	332	4	\N
969	333	332	5	\N
970	333	332	6	\N
971	333	332	7	\N
972	333	332	8	\N
973	334	333	0	\N
974	334	333	1	\N
975	334	333	2	\N
976	334	333	3	\N
977	334	333	4	\N
978	334	333	5	\N
979	334	333	6	\N
980	334	333	7	\N
981	334	333	8	\N
982	335	334	0	\N
983	335	334	1	\N
984	335	334	2	\N
985	335	334	3	\N
986	335	334	4	\N
987	335	334	5	\N
988	335	334	6	\N
989	335	334	7	\N
990	335	334	8	\N
991	336	335	0	\N
992	336	335	1	\N
993	336	335	2	\N
994	336	335	3	\N
995	336	335	4	\N
996	336	335	5	\N
997	336	335	6	\N
998	336	335	7	\N
999	336	335	8	\N
1000	337	336	0	\N
1001	337	336	1	\N
1002	337	336	2	\N
1003	337	336	3	\N
1004	337	336	4	\N
1005	337	336	5	\N
1006	337	336	6	\N
1007	337	336	7	\N
1008	337	336	8	\N
1009	338	337	0	\N
1010	338	337	1	\N
1011	338	337	2	\N
1012	338	337	3	\N
1013	338	337	4	\N
1014	338	337	5	\N
1015	338	337	6	\N
1016	338	337	7	\N
1017	338	337	8	\N
1018	339	338	0	\N
1019	339	338	1	\N
1020	339	338	2	\N
1021	339	338	3	\N
1022	339	338	4	\N
1023	339	338	5	\N
1024	339	338	6	\N
1025	339	338	7	\N
1026	339	338	8	\N
1027	340	339	0	\N
1028	340	339	1	\N
1029	340	339	2	\N
1030	340	339	3	\N
1031	340	339	4	\N
1032	340	339	5	\N
1033	340	339	6	\N
1034	340	339	7	\N
1035	340	339	8	\N
1036	341	340	0	\N
1037	341	340	1	\N
1038	341	340	2	\N
1039	341	340	3	\N
1040	341	340	4	\N
1041	341	340	5	\N
1042	341	340	6	\N
1043	341	340	7	\N
1044	341	340	8	\N
1045	342	341	0	\N
1046	342	341	1	\N
1047	342	341	2	\N
1048	342	341	3	\N
1049	342	341	4	\N
1050	342	341	5	\N
1051	342	341	6	\N
1052	342	341	7	\N
1053	342	341	8	\N
1054	343	342	0	\N
1055	343	342	1	\N
1056	343	342	2	\N
1057	343	342	3	\N
1058	343	342	4	\N
1059	343	342	5	\N
1060	343	342	6	\N
1061	343	342	7	\N
1062	343	342	8	\N
1063	344	343	0	\N
1064	344	343	1	\N
1065	344	343	2	\N
1066	344	343	3	\N
1067	344	343	4	\N
1068	344	343	5	\N
1069	344	343	6	\N
1070	344	343	7	\N
1071	344	343	8	\N
1072	345	344	0	\N
1073	345	344	1	\N
1074	345	344	2	\N
1075	345	344	3	\N
1076	345	344	4	\N
1077	345	344	5	\N
1078	345	344	6	\N
1079	345	344	7	\N
1080	345	344	8	\N
1081	346	345	0	\N
1082	346	345	1	\N
1083	346	345	2	\N
1084	346	345	3	\N
1085	346	345	4	\N
1086	346	345	5	\N
1087	346	345	6	\N
1088	346	345	7	\N
1089	346	345	8	\N
1090	347	346	0	\N
1091	347	346	1	\N
1092	347	346	2	\N
1093	347	346	3	\N
1094	347	346	4	\N
1095	347	346	5	\N
1096	347	346	6	\N
1097	347	346	7	\N
1098	347	346	8	\N
1099	348	347	0	\N
1100	348	347	1	\N
1101	348	347	2	\N
1102	348	347	3	\N
1103	348	347	4	\N
1104	348	347	5	\N
1105	348	347	6	\N
1106	348	347	7	\N
1107	348	347	8	\N
1108	349	348	0	\N
1109	349	348	1	\N
1110	349	348	2	\N
1111	349	348	3	\N
1112	349	348	4	\N
1113	349	348	5	\N
1114	349	348	6	\N
1115	349	348	7	\N
1116	349	348	8	\N
1117	350	349	0	\N
1118	350	349	1	\N
1119	350	349	2	\N
1120	350	349	3	\N
1121	350	349	4	\N
1122	350	349	5	\N
1123	350	349	6	\N
1124	350	349	7	\N
1125	350	349	8	\N
1126	351	350	0	\N
1127	351	350	1	\N
1128	351	350	2	\N
1129	351	350	3	\N
1130	351	350	4	\N
1131	351	350	5	\N
1132	351	350	6	\N
1133	351	350	7	\N
1134	351	350	8	\N
1135	352	351	0	\N
1136	352	351	1	\N
1137	352	351	2	\N
1138	352	351	3	\N
1139	352	351	4	\N
1140	352	351	5	\N
1141	352	351	6	\N
1142	352	351	7	\N
1143	352	351	8	\N
1144	353	352	0	\N
1145	353	352	1	\N
1146	353	352	2	\N
1147	353	352	3	\N
1148	353	352	4	\N
1149	353	352	5	\N
1150	353	352	6	\N
1151	353	352	7	\N
1152	353	352	8	\N
1153	354	353	0	\N
1154	354	353	1	\N
1155	354	353	2	\N
1156	354	353	3	\N
1157	354	353	4	\N
1158	354	353	5	\N
1159	354	353	6	\N
1160	354	353	7	\N
1161	354	353	8	\N
1162	355	354	0	\N
1163	355	354	1	\N
1164	355	354	2	\N
1165	355	354	3	\N
1166	355	354	4	\N
1167	355	354	5	\N
1168	355	354	6	\N
1169	355	354	7	\N
1170	355	354	8	\N
1171	356	355	0	\N
1172	356	355	1	\N
1173	356	355	2	\N
1174	356	355	3	\N
1175	356	355	4	\N
1176	356	355	5	\N
1177	356	355	6	\N
1178	356	355	7	\N
1179	356	355	8	\N
1180	357	356	0	\N
1181	357	356	1	\N
1182	357	356	2	\N
1183	357	356	3	\N
1184	357	356	4	\N
1185	357	356	5	\N
1186	357	356	6	\N
1187	357	356	7	\N
1188	357	356	8	\N
1189	358	357	0	\N
1190	358	357	1	\N
1191	358	357	2	\N
1192	358	357	3	\N
1193	358	357	4	\N
1194	358	357	5	\N
1195	358	357	6	\N
1196	358	357	7	\N
1197	358	357	8	\N
1198	359	358	0	\N
1199	359	358	1	\N
1200	359	358	2	\N
1201	359	358	3	\N
1202	359	358	4	\N
1203	359	358	5	\N
1204	359	358	6	\N
1205	359	358	7	\N
1206	359	358	8	\N
1207	360	359	0	\N
1208	360	359	1	\N
1209	360	359	2	\N
1210	360	359	3	\N
1211	360	359	4	\N
1212	360	359	5	\N
1213	360	359	6	\N
1214	360	359	7	\N
1215	360	359	8	\N
1216	361	360	0	\N
1217	361	360	1	\N
1218	361	360	2	\N
1219	361	360	3	\N
1220	361	360	4	\N
1221	361	360	5	\N
1222	361	360	6	\N
1223	361	360	7	\N
1224	361	360	8	\N
1225	362	361	0	\N
1226	362	361	1	\N
1227	362	361	2	\N
1228	362	361	3	\N
1229	362	361	4	\N
1230	362	361	5	\N
1231	362	361	6	\N
1232	362	361	7	\N
1233	362	361	8	\N
1234	363	362	0	\N
1235	363	362	1	\N
1236	363	362	2	\N
1237	363	362	3	\N
1238	363	362	4	\N
1239	363	362	5	\N
1240	363	362	6	\N
1241	363	362	7	\N
1242	363	362	8	\N
1243	364	363	0	\N
1244	364	363	1	\N
1245	364	363	2	\N
1246	364	363	3	\N
1247	364	363	4	\N
1248	364	363	5	\N
1249	364	363	6	\N
1250	364	363	7	\N
1251	364	363	8	\N
1252	365	364	0	\N
1253	365	364	1	\N
1254	365	364	2	\N
1255	365	364	3	\N
1256	365	364	4	\N
1257	365	364	5	\N
1258	365	364	6	\N
1259	365	364	7	\N
1260	365	364	8	\N
1261	366	365	0	\N
1262	366	365	1	\N
1263	366	365	2	\N
1264	366	365	3	\N
1265	366	365	4	\N
1266	366	365	5	\N
1267	366	365	6	\N
1268	366	365	7	\N
1269	366	365	8	\N
1270	367	366	0	\N
1271	367	366	1	\N
1272	367	366	2	\N
1273	367	366	3	\N
1274	367	366	4	\N
1275	367	366	5	\N
1276	367	366	6	\N
1277	367	366	7	\N
1278	367	366	8	\N
1279	368	367	0	\N
1280	368	367	1	\N
1281	368	367	2	\N
1282	368	367	3	\N
1283	368	367	4	\N
1284	368	367	5	\N
1285	368	367	6	\N
1286	368	367	7	\N
1287	368	367	8	\N
1288	369	368	0	\N
1289	369	368	1	\N
1290	369	368	2	\N
1291	369	368	3	\N
1292	369	368	4	\N
1293	369	368	5	\N
1294	369	368	6	\N
1295	369	368	7	\N
1296	369	368	8	\N
1297	370	369	0	\N
1298	370	369	1	\N
1299	370	369	2	\N
1300	370	369	3	\N
1301	370	369	4	\N
1302	370	369	5	\N
1303	370	369	6	\N
1304	370	369	7	\N
1305	370	369	8	\N
1306	371	370	0	\N
1307	371	370	1	\N
1308	371	370	2	\N
1309	371	370	3	\N
1310	371	370	4	\N
1311	371	370	5	\N
1312	371	370	6	\N
1313	371	370	7	\N
1314	371	370	8	\N
1315	372	371	0	\N
1316	372	371	1	\N
1317	372	371	2	\N
1318	372	371	3	\N
1319	372	371	4	\N
1320	372	371	5	\N
1321	372	371	6	\N
1322	372	371	7	\N
1323	372	371	8	\N
1324	373	372	0	\N
1325	373	372	1	\N
1326	373	372	2	\N
1327	373	372	3	\N
1328	373	372	4	\N
1329	373	372	5	\N
1330	373	372	6	\N
1331	373	372	7	\N
1332	373	372	8	\N
1333	374	373	0	\N
1334	374	373	1	\N
1335	374	373	2	\N
1336	374	373	3	\N
1337	374	373	4	\N
1338	374	373	5	\N
1339	374	373	6	\N
1340	374	373	7	\N
1341	374	373	8	\N
1342	375	374	0	\N
1343	375	374	1	\N
1344	375	374	2	\N
1345	375	374	3	\N
1346	375	374	4	\N
1347	375	374	5	\N
1348	375	374	6	\N
1349	375	374	7	\N
1350	375	374	8	\N
1351	376	375	0	\N
1352	376	375	1	\N
1353	376	375	2	\N
1354	376	375	3	\N
1355	376	375	4	\N
1356	376	375	5	\N
1357	376	375	6	\N
1358	376	375	7	\N
1359	376	375	8	\N
1360	377	376	0	\N
1361	377	376	1	\N
1362	377	376	2	\N
1363	377	376	3	\N
1364	377	376	4	\N
1365	377	376	5	\N
1366	377	376	6	\N
1367	377	376	7	\N
1368	377	376	8	\N
1369	378	377	0	\N
1370	378	377	1	\N
1371	378	377	2	\N
1372	378	377	3	\N
1373	378	377	4	\N
1374	378	377	5	\N
1375	378	377	6	\N
1376	378	377	7	\N
1377	378	377	8	\N
1378	379	378	0	\N
1379	379	378	1	\N
1380	379	378	2	\N
1381	379	378	3	\N
1382	379	378	4	\N
1383	379	378	5	\N
1384	379	378	6	\N
1385	379	378	7	\N
1386	379	378	8	\N
1387	380	379	0	\N
1388	380	379	1	\N
1389	380	379	2	\N
1390	380	379	3	\N
1391	380	379	4	\N
1392	380	379	5	\N
1393	380	379	6	\N
1394	380	379	7	\N
1395	380	379	8	\N
1396	381	380	0	\N
1397	381	380	1	\N
1398	381	380	2	\N
1399	381	380	3	\N
1400	381	380	4	\N
1401	381	380	5	\N
1402	381	380	6	\N
1403	381	380	7	\N
1404	381	380	8	\N
1405	382	381	0	\N
1406	382	381	1	\N
1407	382	381	2	\N
1408	382	381	3	\N
1409	382	381	4	\N
1410	382	381	5	\N
1411	382	381	6	\N
1412	382	381	7	\N
1413	382	381	8	\N
1414	383	382	0	\N
1415	383	382	1	\N
1416	383	382	2	\N
1417	383	382	3	\N
1418	383	382	4	\N
1419	383	382	5	\N
1420	383	382	6	\N
1421	383	382	7	\N
1422	383	382	8	\N
1423	384	383	0	\N
1424	384	383	1	\N
1425	384	383	2	\N
1426	384	383	3	\N
1427	384	383	4	\N
1428	384	383	5	\N
1429	384	383	6	\N
1430	384	383	7	\N
1431	384	383	8	\N
1432	385	384	0	\N
1433	385	384	1	\N
1434	385	384	2	\N
1435	385	384	3	\N
1436	385	384	4	\N
1437	385	384	5	\N
1438	385	384	6	\N
1439	385	384	7	\N
1440	385	384	8	\N
1441	386	130	2	\N
1442	387	386	0	\N
1443	387	386	1	\N
1444	388	387	1	\N
1445	389	387	0	\N
1446	390	132	0	\N
1447	391	131	0	\N
1448	392	129	0	\N
1449	393	385	2	\N
1450	394	385	3	\N
1451	395	385	7	\N
1452	396	385	0	\N
\.


--
-- Data for Name: tx_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_metadata (id, key, json, bytes, tx_id) FROM stdin;
1	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "testhandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "testhandle", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": "ipfs://some-hash", "website": "https://cardano.org/", "mediaType": "image/jpeg", "description": "The Handle Standard", "augmentations": []}, "hellohandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "hellohandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "doublehandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "doublehandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a460a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656067776562736974657468747470733a2f2f63617264616e6f2e6f72672f6c646f75626c6568616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656c646f75626c6568616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6b68656c6c6f68616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656b68656c6c6f68616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6a7465737468616e646c65a86d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e646172646566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e7965696d61676570697066733a2f2f736f6d652d68617368696d65646961547970656a696d6167652f6a706567646e616d656a7465737468616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f	131
2	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"NFT-001": {"name": "One", "image": ["ipfs://some_hash1"], "version": "1.0"}, "NFT-002": {"name": "Two", "image": ["ipfs://some_hash2"], "version": "1.0"}, "NFT-files": {"id": "1", "name": "NFT with files", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": ["ipfs://somehash"], "version": "1.0", "mediaType": "image/png", "description": ["NFT with different types of files"]}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a3674e46542d303031a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65634f6e656776657273696f6e63312e30674e46542d303032a365696d6167658171697066733a2f2f736f6d655f6861736832646e616d656354776f6776657273696f6e63312e30694e46542d66696c6573a76b6465736372697074696f6e8178214e4654207769746820646966666572656e74207479706573206f662066696c65736566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e79626964613165696d616765816f697066733a2f2f736f6d6568617368696d656469615479706569696d6167652f706e67646e616d656e4e465420776974682066696c65736776657273696f6e63312e30	156
3	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"4349502d303032352d76312d686578": {"name": "CIP-0025-v1-hex", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1781e343334393530326433303330333233353264373633313264363836353738a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656f4349502d303032352d76312d6865786776657273696f6e63312e30	158
4	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"CIP-0025-v1-utf8": {"name": "CIP-0025-v1-utf8", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1704349502d303032352d76312d75746638a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65704349502d303032352d76312d757466386776657273696f6e63312e30	159
5	721	{"0x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"0x4349502d303032352d7632": {"name": "CIP-0025-v2", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a1581c17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029a14b4349502d303032352d7632a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656b4349502d303032352d76326776657273696f6e63312e30	160
6	6862	{"name": "Test Portfolio", "pools": [{"id": "259a650c0f4200fa94e83c3877f5560cfa2f09810513a77250437a47", "weight": 1}, {"id": "29474e9e14b2437f195d17ba47a1111a283da04eddde0973af5c268c", "weight": 1}, {"id": "418ff5d8a75a4f212ea6697b567fe0d1c056a0b9322232ea6a46f9f3", "weight": 1}, {"id": "d266b3cc73eb82e2b07b43f4da16d13d46f414560f73d440de62f12c", "weight": 1}, {"id": "5e34750a822ad086e5eaf701a365948ad23dae5eb53ae984bc5c460c", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783832353961363530633066343230306661393465383363333837376635353630636661326630393831303531336137373235303433376134376677656967687401a2626964783832393437346539653134623234333766313935643137626134376131313131613238336461303465646464653039373361663563323638636677656967687401a2626964783834313866663564386137356134663231326561363639376235363766653064316330353661306239333232323332656136613436663966336677656967687401a2626964783864323636623363633733656238326532623037623433663464613136643133643436663431343536306637336434343064653632663132636677656967687401a2626964783835653334373530613832326164303836653565616637303161333635393438616432336461653565623533616539383462633563343630636677656967687401	163
7	6862	{"name": "Test Portfolio", "pools": [{"id": "259a650c0f4200fa94e83c3877f5560cfa2f09810513a77250437a47", "weight": 0}, {"id": "29474e9e14b2437f195d17ba47a1111a283da04eddde0973af5c268c", "weight": 0}, {"id": "418ff5d8a75a4f212ea6697b567fe0d1c056a0b9322232ea6a46f9f3", "weight": 0}, {"id": "d266b3cc73eb82e2b07b43f4da16d13d46f414560f73d440de62f12c", "weight": 0}, {"id": "5e34750a822ad086e5eaf701a365948ad23dae5eb53ae984bc5c460c", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783832353961363530633066343230306661393465383363333837376635353630636661326630393831303531336137373235303433376134376677656967687400a2626964783832393437346539653134623234333766313935643137626134376131313131613238336461303465646464653039373361663563323638636677656967687400a2626964783834313866663564386137356134663231326561363639376235363766653064316330353661306239333232323332656136613436663966336677656967687400a2626964783864323636623363633733656238326532623037623433663464613136643133643436663431343536306637336434343064653632663132636677656967687400a2626964783835653334373530613832326164303836653565616637303161333635393438616432336461653565623533616539383462633563343630636677656967687401	164
8	6862	{"pools": [{"id": "259a650c0f4200fa94e83c3877f5560cfa2f09810513a77250437a47", "weight": 1}]}	\\xa1191acea165706f6f6c7381a2626964783832353961363530633066343230306661393465383363333837376635353630636661326630393831303531336137373235303433376134376677656967687401	172
9	123	"1234"	\\xa1187b6431323334	175
10	6862	{"name": "Test Portfolio", "pools": [{"id": "259a650c0f4200fa94e83c3877f5560cfa2f09810513a77250437a47", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7381a2626964783832353961363530633066343230306661393465383363333837376635353630636661326630393831303531336137373235303433376134376677656967687401	182
11	6862	{"name": "Test Portfolio", "pools": [{"id": "259a650c0f4200fa94e83c3877f5560cfa2f09810513a77250437a47", "weight": 1}, {"id": "29474e9e14b2437f195d17ba47a1111a283da04eddde0973af5c268c", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7382a2626964783832353961363530633066343230306661393465383363333837376635353630636661326630393831303531336137373235303433376134376677656967687401a2626964783832393437346539653134623234333766313935643137626134376131313131613238336461303465646464653039373361663563323638636677656967687401	284
12	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	393
13	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16568616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65662468616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	394
14	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"sub@handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$sub@handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a1697375624068616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656a247375624068616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	395
15	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"virtual@handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$virtual@handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16d7669727475616c4068616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656e247669727475616c4068616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	396
\.


--
-- Data for Name: tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_out (id, tx_id, index, address, address_has_script, payment_cred, stake_address_id, value, data_hash, inline_datum_id, reference_script_id) FROM stdin;
1	1	0	5oP9ib6ym3XXxySpK253gyuQxm27TxfC7gWV2u9ZafVUcTobrWsqhd6rYT27sxQ4tZ	f	\N	\N	910909092	\N	\N	\N
2	2	0	5oP9ib6ym3XZzc418hgd7CgsjXJsmKhsJdggCZzvjTHhPGiiBCyz9Z2iwsdrZFzWGw	f	\N	\N	910909092	\N	\N	\N
3	3	0	5oP9ib6ym3Xb37wj7NYupiMt7dP9WuBZN72AnUJwia9TmeFGNQLX5vSxq2PkjMXBso	f	\N	\N	910909092	\N	\N	\N
4	4	0	5oP9ib6ym3XcEKhtcqWtdz67pwTxgpyJqFvuX9rp4nw1sfx7kkxEUUYrQFLbaxTWzT	f	\N	\N	910909092	\N	\N	\N
5	5	0	5oP9ib6ym3XcLUgmvjWwrCGnWRiREpgVBMvbUQRitmkNhbcxHih4DMzQpAAscQHvX1	f	\N	\N	910909092	\N	\N	\N
6	6	0	5oP9ib6ym3XcPyWe7oPqRTbPyVeTU428dLsbVTpK8gQ5bxhY6MbApFHNcJC4JT47iW	f	\N	\N	910909092	\N	\N	\N
7	7	0	5oP9ib6ym3XeZ8DwKDFFgh9hxAuscqBhBoCZdZGHcWvT1yd8EPyg5Dr44LNMSQvN8y	f	\N	\N	910909092	\N	\N	\N
8	8	0	5oP9ib6ym3XfCfL2NS6uq3cuNsUoACpbqgVuBUA27R5vKhLqZsJtPoqKy7EUTcnLsb	f	\N	\N	910909092	\N	\N	\N
9	9	0	5oP9ib6ym3Xi9KiBHRuHE4oiWK2B3tHLNMhSj5W8iyrqT2tDErGKTuZzp6xgWrX4fy	f	\N	\N	910909092	\N	\N	\N
10	10	0	5oP9ib6ym3Xj6NV6ztzRiFnzuywmXULED5DuiURJoQ9DB8hZRZgPydUtSUV1dFyV3k	f	\N	\N	910909092	\N	\N	\N
11	11	0	5oP9ib6ym3XkAMtWSCgAUhA3rm7JLp2quEFzpqnPENeGr1Ykm4b5dmPVcAMihqGBcR	f	\N	\N	910909092	\N	\N	\N
12	12	0	addr_test1qrwtlfaxamh9044mpghtvlsmqdcad7ked52ea872u96ha2gljuztghwm8dgpjvcc7wsadkp6sfhhzljk629upeq2fvjqvg9qk5	f	\\xdcbfa7a6eeee57d6bb0a2eb67e1b0371d6fad96d159e9fcae1757ea9	\N	7772727272727272	\N	\N	\N
13	13	0	addr_test1vzl6355lcfuhpcvfgt40mm6xnnm9sm0m7cqszaqxv7q62dc2vd82h	f	\\xbfa8d29fc27970e18942eafdef469cf6586dfbf6010174066781a537	\N	3681818181818181	\N	\N	\N
14	14	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681818181818181	\N	\N	\N
15	15	0	addr_test1qrav5k3cd5kq52dk3vkv7ceu7alk99fqqdk5ymkc33q0qcp5mnmr2lq9tnsu3slw34lf3z5smcpyy2gw0vdmnr32gmxsrcqdlq	f	\\xfaca5a386d2c0a29b68b2ccf633cf77f629520036d426ed88c40f060	\N	7772727272727280	\N	\N	\N
16	16	0	addr_test1vq22732sp8y9g6wwuk4craytjluk22u6nkr0en9uz6sr0xq64q8zk	f	\\x14af455009c85469cee5ab81f48b97f9652b9a9d86fcccbc16a03798	\N	3681818181818181	\N	\N	\N
17	17	0	addr_test1qrzxymw2h7y0a3sw8x8dqztwu9q872c6gh2an7zl7slcly9hlnq7f3n7h0h5hmlq4n5ly7awwn3lydclrlnegxcxakmsq6xmkn	f	\\xc4626dcabf88fec60e398ed0096ee1407f2b1a45d5d9f85ff43f8f90	\N	7772727272727272	\N	\N	\N
18	18	0	addr_test1qqgxspkzfh7g3qgrn3878xv43kkt5lgspcxfeww95g63nfawss98kay4z92g25z48quwlwxdh9wq2ldcw2rzk3eg766s2sa2wm	f	\\x106806c24dfc8881039c4fe399958dacba7d100e0c9cb9c5a23519a7	\N	7772727272727272	\N	\N	\N
19	19	0	addr_test1qzqehlss0kza43r3j5kz240m6kd7ecpqvx942fv0hdvd2gkp9rw3j2f09zacsqnj24gvwsgxc2qs2sjqaen7j2qd08jq5aemlt	f	\\x819bfe107d85dac471952c2555fbd59bece020618b55258fbb58d522	\N	7772727272727272	\N	\N	\N
20	20	0	addr_test1vq05unye4mh62kxls700wh09wl7w8r68ejj7zx2dluv408slwrte9	f	\\x1f4e4c99aeefa558df879ef75de577fce38f47cca5e1194dff19579e	\N	3681818181818181	\N	\N	\N
21	21	0	addr_test1qqzlk3d6y47ec2aanqj8g3jh75067klrxhhcdjd04xylptvha583s57krr3l9pnjt8h6aetfh2cq4e94xde2gs4c2qnsqc3eqq	f	\\x05fb45ba257d9c2bbd9824744657f51faf5be335ef86c9afa989f0ad	\N	7772727272727272	\N	\N	\N
22	22	0	addr_test1vzrmkervznxfmnssflkcdgu35avumsyqenkv4sgeag6a0qc3eyj4s	f	\\x87bb646c14cc9dce104fed86a391a759cdc080cceccac119ea35d783	\N	3681818181818190	\N	\N	\N
23	23	0	addr_test1qqplm6j2tq2eqc6jn326q93qyet6mw9gt90rswjuslrr264w5h5t704et7xn3lzhydjvxnwlucqpa726j0rht8n3mx9qqpz00n	f	\\x03fdea4a58159063529c55a016202657adb8a8595e383a5c87c6356a	\N	7772727272727272	\N	\N	\N
24	24	0	addr_test1vq7vez87576sp9gy2fzk9af7jjqnd3untd65rskjf4wlu6srj9f03	f	\\x3ccc88fea7b5009504524562f53e948136c7935b7541c2d24d5dfe6a	\N	3681818181818181	\N	\N	\N
25	25	0	addr_test1qrguzxcph0z848ashgwky0dkgh0ydwu2d20mg97lnguqmz4lcc5x7kvq7d80m22vha74cugw7yjkmzastskeyu3m78fqft2nj0	f	\\xd1c11b01bbc47a9fb0ba1d623db645de46bb8a6a9fb417df9a380d8a	\N	7772727272727272	\N	\N	\N
26	26	0	addr_test1qzz4c4lynnrxg7yxfs4ejwgexell35quzdv8x0f2sljs8xxa6lteezc53zg0a43ed49dq6nc2hxrtsr8rcef4nlpeq9s5epzm6	f	\\x855c57e49cc66478864c2b993919367ff8d01c1358733d2a87e50398	\N	7772727272727272	\N	\N	\N
27	27	0	addr_test1qz2cdfyrnv6vs4jy656rv3v6383lrwzclwf3m7l87pw597ma24fy3g4r25hxac9nhlkq4xhpyq77w6sqvtlrpkyktd0q2vd33r	f	\\x9586a4839b34c85644d53436459a89e3f1b858fb931dfbe7f05d42fb	\N	7772727272727272	\N	\N	\N
28	28	0	addr_test1vpkw856efusqc8c7zc7rulz06ydkfz0dagzagmsqkfy2nqs4umf52	f	\\x6ce3d3594f200c1f1e163c3e7c4fd11b6489edea05d46e00b248a982	\N	3681818181818181	\N	\N	\N
29	29	0	addr_test1vpgdcam4mjqq8fjnx94d4s7an6pltg4l95ctc5cn2l0kfas5n7j3k	f	\\x50dc7775dc8003a653316adac3dd9e83f5a2bf2d30bc531357df64f6	\N	3681818181818181	\N	\N	\N
30	30	0	addr_test1vr2fc7m8zzvvdr0k5hx2p34akax9hl9p73ts2enqm7h2rlqntprxf	f	\\xd49c7b671098c68df6a5cca0c6bdb74c5bfca1f457056660dfaea1fc	\N	3681818181818181	\N	\N	\N
31	31	0	addr_test1vq5fpr6pu9a74gdxsz46jerqdfzpfm8j2sr073ttd637ucgns84jf	f	\\x28908f41e17beaa1a680aba964606a4414ecf25406ff456b6ea3ee61	\N	3681818181818181	\N	\N	\N
32	32	0	addr_test1qz0ygqxu0v6h2ap4q20a27a7sqd6sapwayqqh6s7llfwwvu70rks70exdrx057katxuyms3aewmhwy6z4p34dc7a0t8ssjtauc	f	\\x9e4400dc7b35757435029fd57bbe801ba8742ee9000bea1effd2e733	\N	7772727272727272	\N	\N	\N
33	33	0	addr_test1vp2njwee94ufe3vv4epmxqv9lvmwam33nz25hw8q86x927q9man5j	f	\\x55393b392d789cc58cae43b30185fb36eeee3198954bb8e03e8c5578	\N	3681818181818181	\N	\N	\N
34	35	0	addr_test1qpe5mzn8yjnav6sd04sls234amtguxfzylf3fk4z9xh93u0yu55yv6r7mmnmleqzmv3ygz70mq29m8dqnf9tqp2mv94sfe5kml	f	\\x734d8a6724a7d66a0d7d61f82a35eed68e192227d314daa229ae58f1	34	500000000000	\N	\N	\N
35	35	1	addr_test1vp2njwee94ufe3vv4epmxqv9lvmwam33nz25hw8q86x927q9man5j	f	\\x55393b392d789cc58cae43b30185fb36eeee3198954bb8e03e8c5578	\N	3681318181650964	\N	\N	\N
36	36	0	addr_test1qpwl2yk0aar7ysam2sausgf6mnz6pn22ykgzcdl50usxngya5zee5q6ze7jgzq5dv8kfhqlh430yvk67tfjmhwjcey4s0tq8z0	f	\\x5df512cfef47e243bb543bc8213adcc5a0cd4a25902c37f47f2069a0	35	500000000000	\N	\N	\N
37	36	1	addr_test1vq05unye4mh62kxls700wh09wl7w8r68ejj7zx2dluv408slwrte9	f	\\x1f4e4c99aeefa558df879ef75de577fce38f47cca5e1194dff19579e	\N	3681318181650964	\N	\N	\N
38	37	0	addr_test1qpknqzzcyv5dl9g4cs4mxe7gr594v5f834meg57jvk0sx4z6md63e5mc334f4tp2vm7gvueyuselmtemu5xk9ktzxp2sxe30x6	f	\\x6d3008582328df9515c42bb367c81d0b5651278d779453d2659f0354	36	500000000000	\N	\N	\N
39	37	1	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681318181650964	\N	\N	\N
40	38	0	addr_test1qrmhd4xsqh77u7d4wytt0t5w7kzu3n78k8hs9vv2r2fa5sw8yv2a8d58rw2hh83j9uzq2klxke0g53cs8hjy5xym42qqv00kgf	f	\\xf776d4d005fdee79b57116b7ae8ef585c8cfc7b1ef02b18a1a93da41	37	500000000000	\N	\N	\N
41	38	1	addr_test1vzl6355lcfuhpcvfgt40mm6xnnm9sm0m7cqszaqxv7q62dc2vd82h	f	\\xbfa8d29fc27970e18942eafdef469cf6586dfbf6010174066781a537	\N	3681318181650964	\N	\N	\N
42	39	0	addr_test1qr796l3xxf2marc6d7t9ptlq3ctr8rnppk3jsx47ezv342wtjm2pvte34h566f9egpk0r0x96jpwxz5evuv72t57rfyscjl0n4	f	\\xfc5d7e263255be8f1a6f9650afe08e16338e610da3281abec8991aa9	38	500000000000	\N	\N	\N
43	39	1	addr_test1vzrmkervznxfmnssflkcdgu35avumsyqenkv4sgeag6a0qc3eyj4s	f	\\x87bb646c14cc9dce104fed86a391a759cdc080cceccac119ea35d783	\N	3681318181650973	\N	\N	\N
44	40	0	addr_test1qpdnpjxwzj7v62hqr67w4hjhj4gcr9trm2g9cuzved46jqv5u7u2dsu2vpuktevnlkqftxzg0pzphuh69q3c355e5fnsrpfucv	f	\\x5b30c8ce14bccd2ae01ebceade579551819563da905c704ccb6ba901	39	500000000000	\N	\N	\N
45	40	1	addr_test1vpgdcam4mjqq8fjnx94d4s7an6pltg4l95ctc5cn2l0kfas5n7j3k	f	\\x50dc7775dc8003a653316adac3dd9e83f5a2bf2d30bc531357df64f6	\N	3681318181650964	\N	\N	\N
46	41	0	addr_test1qpftvzsxqnx9v6638yqe4jx4tx9wax82q7vvr45qq7mf9379pngafppyt4csa4zrl7687h5ddrz6yqpwu5xn65aunrhqn7a3dz	f	\\x52b60a0604cc566b5139019ac8d5598aee98ea0798c1d68007b692c7	40	500000000000	\N	\N	\N
47	41	1	addr_test1vq5fpr6pu9a74gdxsz46jerqdfzpfm8j2sr073ttd637ucgns84jf	f	\\x28908f41e17beaa1a680aba964606a4414ecf25406ff456b6ea3ee61	\N	3681318181650964	\N	\N	\N
48	42	0	addr_test1qrgeehz8p7tujtnpgnr2jw76zzlr32xxsvgl83485r4ef7msm773e5q4r3af3pacg88wk6gnja0axx68n2gz2evezxgs357v7d	f	\\xd19cdc470f97c92e6144c6a93bda10be38a8c68311f3c6a7a0eb94fb	41	500000000000	\N	\N	\N
49	42	1	addr_test1vq7vez87576sp9gy2fzk9af7jjqnd3untd65rskjf4wlu6srj9f03	f	\\x3ccc88fea7b5009504524562f53e948136c7935b7541c2d24d5dfe6a	\N	3681318181650964	\N	\N	\N
50	43	0	addr_test1qqtax3c5t2ewgv4sl3hvrga4wcypm5ukhjrvx68zr624qd604dkpxe4r6h9uta566z3cf29zkda9qnakth5xvwtx4xnsa8qc9n	f	\\x17d347145ab2e432b0fc6ec1a3b576081dd396bc86c368e21e955037	42	500000000000	\N	\N	\N
51	43	1	addr_test1vpkw856efusqc8c7zc7rulz06ydkfz0dagzagmsqkfy2nqs4umf52	f	\\x6ce3d3594f200c1f1e163c3e7c4fd11b6489edea05d46e00b248a982	\N	3681318181650964	\N	\N	\N
52	44	0	addr_test1qzpeqmtplvy0ptwkam52jllwklk0wf0e6hvwl99vkhcsz9mrcha9r8xwykg3phjxcdf5q250zw6gzua2uuhhc7ry4dzsje4z4g	f	\\x83906d61fb08f0add6eee8a97feeb7ecf725f9d5d8ef94acb5f10117	43	500000000000	\N	\N	\N
53	44	1	addr_test1vq22732sp8y9g6wwuk4craytjluk22u6nkr0en9uz6sr0xq64q8zk	f	\\x14af455009c85469cee5ab81f48b97f9652b9a9d86fcccbc16a03798	\N	3681318181650964	\N	\N	\N
54	45	0	addr_test1qz4xfh3ka0r5vjs0t0du7jct62g6d0hwep203xt49k45fa34re4jz0ur9ff8wdz5wwggmvx25z8mqqzvq0r3axzm66psz65h2l	f	\\xaa64de36ebc7464a0f5bdbcf4b0bd291a6beeec854f899752dab44f6	44	500000000000	\N	\N	\N
55	45	1	addr_test1vr2fc7m8zzvvdr0k5hx2p34akax9hl9p73ts2enqm7h2rlqntprxf	f	\\xd49c7b671098c68df6a5cca0c6bdb74c5bfca1f457056660dfaea1fc	\N	3681318181650964	\N	\N	\N
56	46	0	addr_test1qpe5mzn8yjnav6sd04sls234amtguxfzylf3fk4z9xh93u0yu55yv6r7mmnmleqzmv3ygz70mq29m8dqnf9tqp2mv94sfe5kml	f	\\x734d8a6724a7d66a0d7d61f82a35eed68e192227d314daa229ae58f1	34	499999828383	\N	\N	\N
57	47	0	addr_test1qpwl2yk0aar7ysam2sausgf6mnz6pn22ykgzcdl50usxngya5zee5q6ze7jgzq5dv8kfhqlh430yvk67tfjmhwjcey4s0tq8z0	f	\\x5df512cfef47e243bb543bc8213adcc5a0cd4a25902c37f47f2069a0	35	499999828383	\N	\N	\N
58	48	0	addr_test1qpknqzzcyv5dl9g4cs4mxe7gr594v5f834meg57jvk0sx4z6md63e5mc334f4tp2vm7gvueyuselmtemu5xk9ktzxp2sxe30x6	f	\\x6d3008582328df9515c42bb367c81d0b5651278d779453d2659f0354	36	499999828383	\N	\N	\N
59	49	0	addr_test1qrmhd4xsqh77u7d4wytt0t5w7kzu3n78k8hs9vv2r2fa5sw8yv2a8d58rw2hh83j9uzq2klxke0g53cs8hjy5xym42qqv00kgf	f	\\xf776d4d005fdee79b57116b7ae8ef585c8cfc7b1ef02b18a1a93da41	37	499999828383	\N	\N	\N
60	50	0	addr_test1qr796l3xxf2marc6d7t9ptlq3ctr8rnppk3jsx47ezv342wtjm2pvte34h566f9egpk0r0x96jpwxz5evuv72t57rfyscjl0n4	f	\\xfc5d7e263255be8f1a6f9650afe08e16338e610da3281abec8991aa9	38	499999828383	\N	\N	\N
61	51	0	addr_test1qpdnpjxwzj7v62hqr67w4hjhj4gcr9trm2g9cuzved46jqv5u7u2dsu2vpuktevnlkqftxzg0pzphuh69q3c355e5fnsrpfucv	f	\\x5b30c8ce14bccd2ae01ebceade579551819563da905c704ccb6ba901	39	499999828383	\N	\N	\N
62	52	0	addr_test1qpftvzsxqnx9v6638yqe4jx4tx9wax82q7vvr45qq7mf9379pngafppyt4csa4zrl7687h5ddrz6yqpwu5xn65aunrhqn7a3dz	f	\\x52b60a0604cc566b5139019ac8d5598aee98ea0798c1d68007b692c7	40	499999828383	\N	\N	\N
63	53	0	addr_test1qrgeehz8p7tujtnpgnr2jw76zzlr32xxsvgl83485r4ef7msm773e5q4r3af3pacg88wk6gnja0axx68n2gz2evezxgs357v7d	f	\\xd19cdc470f97c92e6144c6a93bda10be38a8c68311f3c6a7a0eb94fb	41	499999828383	\N	\N	\N
64	54	0	addr_test1qqtax3c5t2ewgv4sl3hvrga4wcypm5ukhjrvx68zr624qd604dkpxe4r6h9uta566z3cf29zkda9qnakth5xvwtx4xnsa8qc9n	f	\\x17d347145ab2e432b0fc6ec1a3b576081dd396bc86c368e21e955037	42	499999828383	\N	\N	\N
65	55	0	addr_test1qzpeqmtplvy0ptwkam52jllwklk0wf0e6hvwl99vkhcsz9mrcha9r8xwykg3phjxcdf5q250zw6gzua2uuhhc7ry4dzsje4z4g	f	\\x83906d61fb08f0add6eee8a97feeb7ecf725f9d5d8ef94acb5f10117	43	499999828383	\N	\N	\N
66	56	0	addr_test1qz4xfh3ka0r5vjs0t0du7jct62g6d0hwep203xt49k45fa34re4jz0ur9ff8wdz5wwggmvx25z8mqqzvq0r3axzm66psz65h2l	f	\\xaa64de36ebc7464a0f5bdbcf4b0bd291a6beeec854f899752dab44f6	44	499999828383	\N	\N	\N
67	57	0	addr_test1qz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvkfxky3ggexpl2w8s9aurxudjr9edxh0u85964yu8nvrdlsw9n5wv	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	21	500000000	\N	\N	\N
68	57	1	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681317681483923	\N	\N	\N
69	58	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681317681309710	\N	\N	\N
70	59	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681317681134177	\N	\N	\N
71	60	0	addr_test1qpe5mzn8yjnav6sd04sls234amtguxfzylf3fk4z9xh93u0yu55yv6r7mmnmleqzmv3ygz70mq29m8dqnf9tqp2mv94sfe5kml	f	\\x734d8a6724a7d66a0d7d61f82a35eed68e192227d314daa229ae58f1	34	499999651618	\N	\N	\N
72	61	0	addr_test1qpe5mzn8yjnav6sd04sls234amtguxfzylf3fk4z9xh93u0yu55yv6r7mmnmleqzmv3ygz70mq29m8dqnf9tqp2mv94sfe5kml	f	\\x734d8a6724a7d66a0d7d61f82a35eed68e192227d314daa229ae58f1	34	499999463237	\N	\N	\N
73	62	0	addr_test1qz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuv5r833v4pf4r4r6u63lkdpnqtenv0ach7d5x4gc2t87djts8ayp60	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	19	600000000	\N	\N	\N
74	62	1	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681317080967136	\N	\N	\N
75	63	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681317080792923	\N	\N	\N
76	64	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681317080617390	\N	\N	\N
77	65	0	addr_test1qpwl2yk0aar7ysam2sausgf6mnz6pn22ykgzcdl50usxngya5zee5q6ze7jgzq5dv8kfhqlh430yvk67tfjmhwjcey4s0tq8z0	f	\\x5df512cfef47e243bb543bc8213adcc5a0cd4a25902c37f47f2069a0	35	499999651618	\N	\N	\N
78	66	0	addr_test1qpwl2yk0aar7ysam2sausgf6mnz6pn22ykgzcdl50usxngya5zee5q6ze7jgzq5dv8kfhqlh430yvk67tfjmhwjcey4s0tq8z0	f	\\x5df512cfef47e243bb543bc8213adcc5a0cd4a25902c37f47f2069a0	35	499999466009	\N	\N	\N
79	67	0	addr_test1qz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvkw465ew54cwrxkx47vanqjulp7v57s435e635eaume4fese90lse	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	16	200000000	\N	\N	\N
80	67	1	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681316880450349	\N	\N	\N
81	68	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681316880276136	\N	\N	\N
82	69	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681316880100603	\N	\N	\N
83	70	0	addr_test1qpknqzzcyv5dl9g4cs4mxe7gr594v5f834meg57jvk0sx4z6md63e5mc334f4tp2vm7gvueyuselmtemu5xk9ktzxp2sxe30x6	f	\\x6d3008582328df9515c42bb367c81d0b5651278d779453d2659f0354	36	499999651618	\N	\N	\N
84	71	0	addr_test1qpknqzzcyv5dl9g4cs4mxe7gr594v5f834meg57jvk0sx4z6md63e5mc334f4tp2vm7gvueyuselmtemu5xk9ktzxp2sxe30x6	f	\\x6d3008582328df9515c42bb367c81d0b5651278d779453d2659f0354	36	499999463237	\N	\N	\N
85	72	0	addr_test1qz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuv53s768swagl64gqe08eqny6rn7vmenc0x6fupqeernehgqvuy0zf	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	13	500000000	\N	\N	\N
86	72	1	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681316379933562	\N	\N	\N
87	73	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681316379759349	\N	\N	\N
88	74	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681316379583816	\N	\N	\N
89	75	0	addr_test1qrmhd4xsqh77u7d4wytt0t5w7kzu3n78k8hs9vv2r2fa5sw8yv2a8d58rw2hh83j9uzq2klxke0g53cs8hjy5xym42qqv00kgf	f	\\xf776d4d005fdee79b57116b7ae8ef585c8cfc7b1ef02b18a1a93da41	37	499999651618	\N	\N	\N
90	76	0	addr_test1qrmhd4xsqh77u7d4wytt0t5w7kzu3n78k8hs9vv2r2fa5sw8yv2a8d58rw2hh83j9uzq2klxke0g53cs8hjy5xym42qqv00kgf	f	\\xf776d4d005fdee79b57116b7ae8ef585c8cfc7b1ef02b18a1a93da41	37	499999463237	\N	\N	\N
91	77	0	addr_test1qz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuv4aqs0jc8njulj8p3edj42a7rukxr36fvslvnumsutnjgyq3x9u0z	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	14	500000000	\N	\N	\N
92	77	1	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681315879416775	\N	\N	\N
93	78	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681315879242562	\N	\N	\N
94	79	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681315879067029	\N	\N	\N
95	80	0	addr_test1qr796l3xxf2marc6d7t9ptlq3ctr8rnppk3jsx47ezv342wtjm2pvte34h566f9egpk0r0x96jpwxz5evuv72t57rfyscjl0n4	f	\\xfc5d7e263255be8f1a6f9650afe08e16338e610da3281abec8991aa9	38	499999651618	\N	\N	\N
96	81	0	addr_test1qr796l3xxf2marc6d7t9ptlq3ctr8rnppk3jsx47ezv342wtjm2pvte34h566f9egpk0r0x96jpwxz5evuv72t57rfyscjl0n4	f	\\xfc5d7e263255be8f1a6f9650afe08e16338e610da3281abec8991aa9	38	499999463237	\N	\N	\N
97	82	0	addr_test1qz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvsal8ykpyvhz5wesggk04xv0dj8fyu0uazss3sxe2tl388qe6u2sz	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	20	500000000	\N	\N	\N
98	82	1	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681315378899988	\N	\N	\N
99	83	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681315378725775	\N	\N	\N
100	84	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681315378550242	\N	\N	\N
101	85	0	addr_test1qpdnpjxwzj7v62hqr67w4hjhj4gcr9trm2g9cuzved46jqv5u7u2dsu2vpuktevnlkqftxzg0pzphuh69q3c355e5fnsrpfucv	f	\\x5b30c8ce14bccd2ae01ebceade579551819563da905c704ccb6ba901	39	499999651618	\N	\N	\N
102	86	0	addr_test1qpdnpjxwzj7v62hqr67w4hjhj4gcr9trm2g9cuzved46jqv5u7u2dsu2vpuktevnlkqftxzg0pzphuh69q3c355e5fnsrpfucv	f	\\x5b30c8ce14bccd2ae01ebceade579551819563da905c704ccb6ba901	39	499999463237	\N	\N	\N
103	87	0	addr_test1qz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst97lscyf43e2fjmqd46vxaeuzc0d7czypudgjpmxg73wsx3c4vg	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	12	500000000	\N	\N	\N
104	87	1	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681314878383201	\N	\N	\N
105	88	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681314878208988	\N	\N	\N
106	89	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681314878033455	\N	\N	\N
107	90	0	addr_test1qpftvzsxqnx9v6638yqe4jx4tx9wax82q7vvr45qq7mf9379pngafppyt4csa4zrl7687h5ddrz6yqpwu5xn65aunrhqn7a3dz	f	\\x52b60a0604cc566b5139019ac8d5598aee98ea0798c1d68007b692c7	40	499999651618	\N	\N	\N
108	91	0	addr_test1qpftvzsxqnx9v6638yqe4jx4tx9wax82q7vvr45qq7mf9379pngafppyt4csa4zrl7687h5ddrz6yqpwu5xn65aunrhqn7a3dz	f	\\x52b60a0604cc566b5139019ac8d5598aee98ea0798c1d68007b692c7	40	499999463237	\N	\N	\N
109	92	0	addr_test1qz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvnpwjye83wlhwhel30cpapf9sxtqxgs3las8wp0le3z483qj8jej3	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	17	300000000	\N	\N	\N
110	92	1	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681314577866414	\N	\N	\N
111	93	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681314577692201	\N	\N	\N
112	94	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681314577516668	\N	\N	\N
113	95	0	addr_test1qrgeehz8p7tujtnpgnr2jw76zzlr32xxsvgl83485r4ef7msm773e5q4r3af3pacg88wk6gnja0axx68n2gz2evezxgs357v7d	f	\\xd19cdc470f97c92e6144c6a93bda10be38a8c68311f3c6a7a0eb94fb	41	499999651618	\N	\N	\N
114	96	0	addr_test1qrgeehz8p7tujtnpgnr2jw76zzlr32xxsvgl83485r4ef7msm773e5q4r3af3pacg88wk6gnja0axx68n2gz2evezxgs357v7d	f	\\xd19cdc470f97c92e6144c6a93bda10be38a8c68311f3c6a7a0eb94fb	41	499999466009	\N	\N	\N
115	97	0	addr_test1qrgeehz8p7tujtnpgnr2jw76zzlr32xxsvgl83485r4ef7msm773e5q4r3af3pacg88wk6gnja0axx68n2gz2evezxgs357v7d	f	\\xd19cdc470f97c92e6144c6a93bda10be38a8c68311f3c6a7a0eb94fb	41	499999289244	\N	\N	\N
116	98	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681314577338055	\N	\N	\N
117	99	0	addr_test1qz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvk4rrukhw0a4974g7dvwuv6md8w0v7svuw000t4tknpr54sfasw9z	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	22	300000000	\N	\N	\N
118	99	1	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681314277171014	\N	\N	\N
119	100	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681314276996801	\N	\N	\N
120	101	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681314276821268	\N	\N	\N
121	102	0	addr_test1qqtax3c5t2ewgv4sl3hvrga4wcypm5ukhjrvx68zr624qd604dkpxe4r6h9uta566z3cf29zkda9qnakth5xvwtx4xnsa8qc9n	f	\\x17d347145ab2e432b0fc6ec1a3b576081dd396bc86c368e21e955037	42	499999651618	\N	\N	\N
122	103	0	addr_test1qqtax3c5t2ewgv4sl3hvrga4wcypm5ukhjrvx68zr624qd604dkpxe4r6h9uta566z3cf29zkda9qnakth5xvwtx4xnsa8qc9n	f	\\x17d347145ab2e432b0fc6ec1a3b576081dd396bc86c368e21e955037	42	499999466009	\N	\N	\N
123	104	0	addr_test1qqtax3c5t2ewgv4sl3hvrga4wcypm5ukhjrvx68zr624qd604dkpxe4r6h9uta566z3cf29zkda9qnakth5xvwtx4xnsa8qc9n	f	\\x17d347145ab2e432b0fc6ec1a3b576081dd396bc86c368e21e955037	42	499999289244	\N	\N	\N
124	105	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681314276642655	\N	\N	\N
125	106	0	addr_test1qz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvjgkudwuyl0fjxufzg2008dmzesv7jggj0ed3spa3r35vqshtpdxw	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	18	500000000	\N	\N	\N
126	106	1	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681313776475614	\N	\N	\N
127	107	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681313776301401	\N	\N	\N
128	108	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681313776125868	\N	\N	\N
129	109	0	addr_test1qzpeqmtplvy0ptwkam52jllwklk0wf0e6hvwl99vkhcsz9mrcha9r8xwykg3phjxcdf5q250zw6gzua2uuhhc7ry4dzsje4z4g	f	\\x83906d61fb08f0add6eee8a97feeb7ecf725f9d5d8ef94acb5f10117	43	499999651618	\N	\N	\N
130	110	0	addr_test1qzpeqmtplvy0ptwkam52jllwklk0wf0e6hvwl99vkhcsz9mrcha9r8xwykg3phjxcdf5q250zw6gzua2uuhhc7ry4dzsje4z4g	f	\\x83906d61fb08f0add6eee8a97feeb7ecf725f9d5d8ef94acb5f10117	43	499999463193	\N	\N	\N
131	111	0	addr_test1qzpeqmtplvy0ptwkam52jllwklk0wf0e6hvwl99vkhcsz9mrcha9r8xwykg3phjxcdf5q250zw6gzua2uuhhc7ry4dzsje4z4g	f	\\x83906d61fb08f0add6eee8a97feeb7ecf725f9d5d8ef94acb5f10117	43	499999286428	\N	\N	\N
132	112	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681313775947255	\N	\N	\N
133	113	0	addr_test1qz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvkr9yk6um8zl3ky23jy9s2pscm9wt5schwndw8jcnx3xw5skdgwch	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	15	500000000	\N	\N	\N
134	113	1	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681313275780214	\N	\N	\N
135	114	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681313275606001	\N	\N	\N
136	115	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681313275430468	\N	\N	\N
137	116	0	addr_test1qz4xfh3ka0r5vjs0t0du7jct62g6d0hwep203xt49k45fa34re4jz0ur9ff8wdz5wwggmvx25z8mqqzvq0r3axzm66psz65h2l	f	\\xaa64de36ebc7464a0f5bdbcf4b0bd291a6beeec854f899752dab44f6	44	499999651618	\N	\N	\N
138	117	0	addr_test1qz4xfh3ka0r5vjs0t0du7jct62g6d0hwep203xt49k45fa34re4jz0ur9ff8wdz5wwggmvx25z8mqqzvq0r3axzm66psz65h2l	f	\\xaa64de36ebc7464a0f5bdbcf4b0bd291a6beeec854f899752dab44f6	44	499999463193	\N	\N	\N
139	118	0	addr_test1qz4xfh3ka0r5vjs0t0du7jct62g6d0hwep203xt49k45fa34re4jz0ur9ff8wdz5wwggmvx25z8mqqzvq0r3axzm66psz65h2l	f	\\xaa64de36ebc7464a0f5bdbcf4b0bd291a6beeec854f899752dab44f6	44	499999286428	\N	\N	\N
140	119	0	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3681313275251855	\N	\N	\N
141	120	0	addr_test1wpnlxv2xv9a9ucvnvzqakwepzl9ltx7jzgm53av2e9ncv4sysemm8	t	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	\N	100000000	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	\N	\N
142	120	1	addr_test1vq05unye4mh62kxls700wh09wl7w8r68ejj7zx2dluv408slwrte9	f	\\x1f4e4c99aeefa558df879ef75de577fce38f47cca5e1194dff19579e	\N	3681318081483659	\N	\N	\N
143	121	0	addr_test1vq05unye4mh62kxls700wh09wl7w8r68ejj7zx2dluv408slwrte9	f	\\x1f4e4c99aeefa558df879ef75de577fce38f47cca5e1194dff19579e	\N	99828426	\N	\N	\N
144	122	0	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	100000000	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	2	\N
145	122	1	addr_test1vq05unye4mh62kxls700wh09wl7w8r68ejj7zx2dluv408slwrte9	f	\\x1f4e4c99aeefa558df879ef75de577fce38f47cca5e1194dff19579e	\N	3681317981317410	\N	\N	\N
146	123	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	2
147	123	1	addr_test1vq05unye4mh62kxls700wh09wl7w8r68ejj7zx2dluv408slwrte9	f	\\x1f4e4c99aeefa558df879ef75de577fce38f47cca5e1194dff19579e	\N	3681317881146849	\N	\N	\N
148	124	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	3
149	124	1	addr_test1vq05unye4mh62kxls700wh09wl7w8r68ejj7zx2dluv408slwrte9	f	\\x1f4e4c99aeefa558df879ef75de577fce38f47cca5e1194dff19579e	\N	3681317780978884	\N	\N	\N
150	125	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	1
151	125	1	addr_test1vq05unye4mh62kxls700wh09wl7w8r68ejj7zx2dluv408slwrte9	f	\\x1f4e4c99aeefa558df879ef75de577fce38f47cca5e1194dff19579e	\N	3681317680812063	\N	\N	\N
152	126	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	4
153	126	1	addr_test1vq05unye4mh62kxls700wh09wl7w8r68ejj7zx2dluv408slwrte9	f	\\x1f4e4c99aeefa558df879ef75de577fce38f47cca5e1194dff19579e	\N	3681317580549014	\N	\N	\N
154	127	0	addr_test1wzem0yuxjqyrmzvrsr8xfqhumyy555ngyjxw7wrg2pav90q8cagu2	t	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	\N	100000000	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	3	\N
155	127	1	addr_test1vq05unye4mh62kxls700wh09wl7w8r68ejj7zx2dluv408slwrte9	f	\\x1f4e4c99aeefa558df879ef75de577fce38f47cca5e1194dff19579e	\N	3681317480382721	\N	\N	\N
156	128	0	addr_test1vq05unye4mh62kxls700wh09wl7w8r68ejj7zx2dluv408slwrte9	f	\\x1f4e4c99aeefa558df879ef75de577fce38f47cca5e1194dff19579e	\N	3681317580054890	\N	\N	\N
157	129	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	10000000	\N	\N	\N
158	129	1	addr_test1vp2njwee94ufe3vv4epmxqv9lvmwam33nz25hw8q86x927q9man5j	f	\\x55393b392d789cc58cae43b30185fb36eeee3198954bb8e03e8c5578	\N	3681318171474815	\N	\N	\N
159	130	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000000000	\N	\N	\N
160	130	1	addr_test1qrml5hwl9s7ydm2djyup95ud6s74skkl4zzf8zk657s8thgm78sn3uhch64ujc7ffnpga68dfdqhg3sp7tk6759jrm7spy03k9	f	\\xf7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd	69	5000000000000	\N	\N	\N
161	130	2	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	5000000000000	\N	\N	\N
162	130	3	addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k	f	\\x594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0	71	5000000000000	\N	\N	\N
163	130	4	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	5000000000000	\N	\N	\N
164	130	5	addr_test1vz6pd984cjezcadzhy8f0an3dd75nhj7kytc6aapcjytuvst987kp	f	\\xb41694f5c4b22c75a2b90e97f6716b7d49de5eb1178d77a1c488be32	\N	3656313275072494	\N	\N	\N
165	131	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	10000000	\N	\N	\N
166	131	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999989767355	\N	\N	\N
167	132	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	10000000	\\x81cb2989cbf6c49840511d8d3451ee44f58dde2c074fc749d05deb51eeb33741	4	\N
168	132	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999979582230	\N	\N	\N
169	133	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999987749338	\N	\N	\N
170	133	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999991664311	\N	\N	\N
171	134	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999987749338	\N	\N	\N
172	134	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999991494146	\N	\N	\N
173	135	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	72	20000000	\N	\N	\N
174	135	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999971325477	\N	\N	\N
175	136	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	72	17825523	\N	\N	\N
176	137	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999987576005	\N	\N	\N
177	138	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999971153464	\N	\N	\N
178	139	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999987402584	\N	\N	\N
179	140	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999970981451	\N	\N	\N
180	141	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999987227843	\N	\N	\N
181	142	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999970809438	\N	\N	\N
182	143	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	72	17653686	\N	\N	\N
183	144	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999987055830	\N	\N	\N
184	145	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999970637425	\N	\N	\N
185	146	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999986883817	\N	\N	\N
186	147	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999970464048	\N	\N	\N
187	148	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999986711804	\N	\N	\N
188	149	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999970292035	\N	\N	\N
189	150	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999986537107	\N	\N	\N
191	152	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2993986341202	\N	\N	\N
192	153	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999970120022	\N	\N	\N
193	154	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	72	17477933	\N	\N	\N
194	155	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	72	19305920	\N	\N	\N
195	156	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
196	156	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2993976137201	\N	\N	\N
197	157	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
198	157	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2993975956960	\N	\N	\N
199	158	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
200	158	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999959932829	\N	\N	\N
201	159	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
202	159	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2993965767963	\N	\N	\N
203	160	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
204	160	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999949748276	\N	\N	\N
205	161	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2993995587150	\N	\N	\N
206	162	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	1000000000	\N	\N	\N
207	162	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1998959578287	\N	\N	\N
208	163	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	99675351	\N	\N	\N
209	163	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	80	100000000	\N	\N	\N
210	163	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	100000000	\N	\N	\N
211	163	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	82	100000000	\N	\N	\N
212	163	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	100000000	\N	\N	\N
213	163	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	50000000	\N	\N	\N
214	163	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	80	50000000	\N	\N	\N
215	163	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	50000000	\N	\N	\N
216	163	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	82	50000000	\N	\N	\N
217	163	9	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	50000000	\N	\N	\N
218	163	10	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	25000000	\N	\N	\N
219	163	11	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	80	25000000	\N	\N	\N
220	163	12	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	25000000	\N	\N	\N
221	163	13	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	82	25000000	\N	\N	\N
222	163	14	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	25000000	\N	\N	\N
223	163	15	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	12500000	\N	\N	\N
224	163	16	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	80	12500000	\N	\N	\N
225	163	17	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	12500000	\N	\N	\N
226	163	18	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	82	12500000	\N	\N	\N
227	163	19	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	12500000	\N	\N	\N
228	163	20	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	6250000	\N	\N	\N
229	163	21	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	80	6250000	\N	\N	\N
230	163	22	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	6250000	\N	\N	\N
231	163	23	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	82	6250000	\N	\N	\N
232	163	24	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	6250000	\N	\N	\N
233	163	25	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	3125000	\N	\N	\N
234	163	26	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	3125000	\N	\N	\N
235	163	27	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	80	3125000	\N	\N	\N
236	163	28	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	80	3125000	\N	\N	\N
237	163	29	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	3125000	\N	\N	\N
238	163	30	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	81	3125000	\N	\N	\N
239	163	31	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	82	3125000	\N	\N	\N
240	163	32	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	82	3125000	\N	\N	\N
241	163	33	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	3125000	\N	\N	\N
242	163	34	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	3125000	\N	\N	\N
243	164	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	499576915	\N	\N	\N
244	164	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	249918838	\N	\N	\N
245	164	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	124959419	\N	\N	\N
246	164	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	62479709	\N	\N	\N
247	164	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	31239855	\N	\N	\N
248	164	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	15619927	\N	\N	\N
249	164	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	7809964	\N	\N	\N
250	164	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	3904982	\N	\N	\N
251	164	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	83	3904981	\N	\N	\N
252	165	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	499470162	\N	\N	\N
253	165	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	249853648	\N	\N	\N
254	165	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	124926824	\N	\N	\N
255	165	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	62463412	\N	\N	\N
256	165	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	31231706	\N	\N	\N
257	165	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	15615853	\N	\N	\N
258	165	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	7807926	\N	\N	\N
259	165	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	3903963	\N	\N	\N
260	165	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	79	3903963	\N	\N	\N
261	166	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	3000000	\N	\N	\N
262	166	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1998956400730	\N	\N	\N
263	167	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2827019	\N	\N	\N
264	168	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	3000000	\N	\N	\N
265	168	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2993992403301	\N	\N	\N
266	169	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2820947	\N	\N	\N
267	170	0	addr_test1qr9jy3vjkapfqs0hutvtxt9hqs8k5cwhurgadrcqjwk2l9kaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsjm7efx	f	\\xcb224592b7429041f7e2d8b32cb7040f6a61d7e0d1d68f0093acaf96	89	3000000	\N	\N	\N
268	170	1	addr_test1qzwpmkvhv0m5paxwq79dmzjcumu6kve2e4kscnugyup0yrkaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsdcaf6w	f	\\x9c1dd99763f740f4ce078add8a58e6f9ab332acd6d0c4f882702f20e	89	3000000	\N	\N	\N
269	170	2	addr_test1qzlzlaqcrnes26ycp9nrkt0uz7x8egfmcjd5a0gqnfdwr2xaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsp7h3u5	f	\\xbe2ff4181cf305689809663b2dfc178c7ca13bc49b4ebd009a5ae1a8	89	3000000	\N	\N	\N
270	170	3	addr_test1qqzsgmx8zv0dpr2gm83s5nkzt9u95zasr5upvvte8g9zgaxaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs4a3f47	f	\\x05046cc7131ed08d48d9e30a4ec259785a0bb01d381631793a0a2474	89	3000000	\N	\N	\N
271	170	4	addr_test1qrr2mezevgz95ckaj582r70yw4v5zkdsdvwcw9z9ezdjuhxaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs2qkgz6	f	\\xc6ade45962045a62dd950ea1f9e475594159b06b1d871445c89b2e5c	89	3000000	\N	\N	\N
272	170	5	addr_test1qps0vscfm2pdjymvht4mxn6yvyulcw3pz39msajnfzk4757aqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphssdmw7r	f	\\x60f64309da82d9136cbaebb34f446139fc3a21144bb8765348ad5f53	89	3000000	\N	\N	\N
273	170	6	addr_test1qqw9wfde0y9pzrt5f645gpnjp9nym2sr4n0mmxs9er8jf3xaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsz4yr53	f	\\x1c5725b9790a110d744eab44067209664daa03acdfbd9a05c8cf24c4	89	3000000	\N	\N	\N
274	170	7	addr_test1qp5k0rkck46gzp4sz6xvtgw970jdk3y7n8t8ry0wwz8h7x7aqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs0ksl2r	f	\\x69678ed8b5748106b0168cc5a1c5f3e4db449e99d67191ee708f7f1b	89	3000000	\N	\N	\N
275	170	8	addr_test1qzdqpma952n7w69l0dpsn0y6j3975v9qznxhwslgzhzl9t7aqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs4kthp2	f	\\x9a00efa5a2a7e768bf7b4309bc9a944bea30a014cd7743e815c5f2af	89	3000000	\N	\N	\N
276	170	9	addr_test1qqmdj22szgwmrd0ucu8xyd2ms5fz547j3mf507xnnamts8xaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs8tzwfc	f	\\x36d92950121db1b5fcc70e62355b85122a57d28ed347f8d39f76b81c	89	3000000	\N	\N	\N
277	170	10	addr_test1qrcle9ttg098ngewz6gm2ah5xumzahuja2z7paqxa8q9la7aqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsm3dytq	f	\\xf1fc956b43ca79a32e1691b576f437362edf92ea85e0f406e9c05ff7	89	3000000	\N	\N	\N
278	170	11	addr_test1qr3kg43pw0akqj3t8guua96fhznsqmpgxp3s0gkj9ep29fwaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsxer9s0	f	\\xe364562173fb604a2b3a39ce9749b8a7006c28306307a2d22e42a2a5	89	3000000	\N	\N	\N
279	170	12	addr_test1qp7pdjuqsxfc9k6pljmtk6tf28480gqw9nen8w272g3zgwwaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsayws3f	f	\\x7c16cb80819382db41fcb6bb696951ea77a00e2cf333b95e52222439	89	3000000	\N	\N	\N
280	170	13	addr_test1qr9uv5j4vcus9mdtw99zf3hf4xk8tennh85ltmaadt3x6zkaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsx2k5ww	f	\\xcbc65255663902edab714a24c6e9a9ac75e673b9e9f5efbd6ae26d0a	89	3000000	\N	\N	\N
281	170	14	addr_test1qzartc044jz26wswh6y7feu5pwgv84mdmyt7vy0a6d2ac3waqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs5wn3p2	f	\\xba35e1f5ac84ad3a0ebe89e4e7940b90c3d76dd917e611fdd355dc45	89	3000000	\N	\N	\N
282	170	15	addr_test1qrd6ug7h8zfjcxlsjrn9cu2hsazwgdphlc7khpsyc3rrlpkaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsn6ynav	f	\\xdbae23d738932c1bf090e65c71578744e43437fe3d6b8604c4463f86	89	3000000	\N	\N	\N
283	170	16	addr_test1qpad3ljufkx2tnwrjnkusyv9zu98wvlwpvav85dag58hxpwaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphss272pa	f	\\x7ad8fe5c4d8ca5cdc394edc81185170a7733ee0b3ac3d1bd450f7305	89	3000000	\N	\N	\N
284	170	17	addr_test1qqugzlmjzmvhqde7xfhrd2qxs87ydkvj4whef0lzd2ktjkxaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsh5t00g	f	\\x38817f7216d970373e326e36a80681fc46d992abaf94bfe26aacb958	89	3000000	\N	\N	\N
285	170	18	addr_test1qrutswnwkypgk05ta90hlt7wlur2qp82r2xql93jk7uxgm7aqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsymkglt	f	\\xf8b83a6eb1028b3e8be95f7fafceff06a004ea1a8c0f9632b7b8646f	89	3000000	\N	\N	\N
286	170	19	addr_test1qqvkeu3ma9kyfkkkwpcszq23qgvgkxtu65wjmdg4pks806kaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsj2v7rt	f	\\x196cf23be96c44dad6707101015102188b197cd51d2db5150da077ea	89	3000000	\N	\N	\N
287	170	20	addr_test1qr6v9c68j0fgxr9mgn4sp978zf06d6csueq40jev4cjaafxaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs63074l	f	\\xf4c2e34793d2830cbb44eb0097c7125fa6eb10e64157cb2cae25dea4	89	3000000	\N	\N	\N
288	170	21	addr_test1qrkmmsl6njl98wyjjsdn8n735hakqz6wah50z69wx4390gxaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphscru2wg	f	\\xedbdc3fa9cbe53b892941b33cfd1a5fb600b4eede8f168ae356257a0	89	3000000	\N	\N	\N
289	170	22	addr_test1qrm54j8ytyu07ag9qpkyar2480qjplpu3fpw7dyqff0y2kxaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs6cpgxp	f	\\xf74ac8e45938ff7505006c4e8d553bc120fc3c8a42ef34804a5e4558	89	3000000	\N	\N	\N
290	170	23	addr_test1qqac45xq5xxrtsthqu84a99y5aw0x8qlqp50mag89tjdxlkaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphshw692s	f	\\x3b8ad0c0a18c35c177070f5e94a4a75cf31c1f0068fdf5072ae4d37e	89	3000000	\N	\N	\N
291	170	24	addr_test1qpgq87tazlzwagkzasvcl4ykfe86wuhclafkr98zee8cnwwaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsfyhjrq	f	\\x5003f97d17c4eea2c2ec198fd4964e4fa772f8ff536194e2ce4f89b9	89	3000000	\N	\N	\N
292	170	25	addr_test1qpp8e2dgx39wa8h48eh2lkltk3na7es6m7mx6808nnrgraxaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsxd9uwm	f	\\x427ca9a8344aee9ef53e6eafdbebb467df661adfb66d1de79cc681f4	89	3000000	\N	\N	\N
293	170	26	addr_test1qpcgrvy20huujp9u7eehy26qutl056j479msv0vex5868rxaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsq52ryu	f	\\x7081b08a7df9c904bcf673722b40e2fefa6a55f177063d99350fa38c	89	3000000	\N	\N	\N
294	170	27	addr_test1qp3cpulprrexx9ua2uf2dmdqwlke6k7ktkze3c79g853mjwaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphse72xr3	f	\\x6380f3e118f263179d5712a6eda077ed9d5bd65d8598e3c541e91dc9	89	3000000	\N	\N	\N
295	170	28	addr_test1qqshxg09wl5gusel7tu0hauhfp6cnc6hylargj24dv2ajkwaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphstdw45y	f	\\x217321e577e88e433ff2f8fbf797487589e35727fa3449556b15d959	89	3000000	\N	\N	\N
296	170	29	addr_test1qp49060acu4a9yvlkhecdwe770jzu95fsl4y83r56fl3uykaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsl5m4er	f	\\x6a57e9fdc72bd2919fb5f386bb3ef3e42e168987ea43c474d27f1e12	89	3000000	\N	\N	\N
297	170	30	addr_test1qqp24j4cnhatm9m5gx4ckkr5hghnha64qx0ju9cwc0afn9xaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsgcej77	f	\\x02aacab89dfabd977441ab8b5874ba2f3bf755019f2e170ec3fa9994	89	3000000	\N	\N	\N
298	170	31	addr_test1qremtc5s6nav4rprsu5qva47ngm4z9nvqp9kstxamgap4fwaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsaznjkj	f	\\xf3b5e290d4faca8c2387280676be9a3751166c004b682cddda3a1aa5	89	3000000	\N	\N	\N
299	170	32	addr_test1qzalfrq3hc2qhuj8rnsunfyyg8yhzzsvfe5a7rnhcrsrzhkaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsqgvf9l	f	\\xbbf48c11be140bf2471ce1c9a48441c9710a0c4e69df0e77c0e0315e	89	3000000	\N	\N	\N
300	170	33	addr_test1qpyg5kxl2yuphfjnvrxcyln9hv9vq4al3wzppwpgxpl6gywaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs6jna0l	f	\\x488a58df51381ba65360cd827e65bb0ac057bf8b8410b828307fa411	89	3000000	\N	\N	\N
301	170	34	addr_test1qqql4q2cwk4cqlw894kgujrul587pdlxmldls3hk4jmsd6xaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs4s9thx	f	\\x01fa815875ab807dc72d6c8e487cfd0fe0b7e6dfdbf846f6acb706e8	89	3000000	\N	\N	\N
302	170	35	addr_test1qp3vzattrec9kmdh4fr5ad9vdldvwd0qkyy328x6lk6zu0waqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsjd3y0s	f	\\x62c1756b1e705b6db7aa474eb4ac6fdac735e0b109151cdafdb42e3d	89	3000000	\N	\N	\N
303	170	36	addr_test1qqc0crgmrpz6mp0p66nrrau69vlxy8p2wynpetvcy470p77aqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphstr4j83	f	\\x30fc0d1b1845ad85e1d6a631f79a2b3e621c2a71261cad98257cf0fb	89	3000000	\N	\N	\N
304	170	37	addr_test1qqk7jtz4f84xrlhxdy0k63usf0p5npng8kx4m6zzk99skmkaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs4fh22z	f	\\x2de92c5549ea61fee6691f6d47904bc34986683d8d5de842b14b0b6e	89	3000000	\N	\N	\N
305	170	38	addr_test1qpdw2lnwzd44fkqjhvedqum2g9lr867zy4euqtardzqxhvkaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsxnhd7u	f	\\x5ae57e6e136b54d812bb32d0736a417e33ebc22573c02fa368806bb2	89	3000000	\N	\N	\N
306	170	39	addr_test1qrkgym8n5vjf5hc0vh3ygjk3s08r34dknv7n5mzkame4kdwaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs8590u0	f	\\xec826cf3a3249a5f0f65e2444ad183ce38d5b69b3d3a6c56eef35b35	89	3000000	\N	\N	\N
307	170	40	addr_test1qpmar3yjjcan0xmn30g9a7ph7xfn69fqu3wtmxgl2scflnwaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsdmkmd4	f	\\x77d1c492963b379b738bd05ef837f1933d1520e45cbd991f54309fcd	89	3000000	\N	\N	\N
308	170	41	addr_test1qp3y8qcjam9vjfavn2vfqhk9n6v5kqeaaf43yrj8pjv8c7xaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs46960s	f	\\x62438312eecac927ac9a98905ec59e994b033dea6b120e470c987c78	89	3000000	\N	\N	\N
309	170	42	addr_test1qzgrav3hw3gjau0sncsucfs7h2xqp6uxffzqt664rspjwt7aqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs8fvg0c	f	\\x903eb23774512ef1f09e21cc261eba8c00eb864a4405eb551c03272f	89	3000000	\N	\N	\N
310	170	43	addr_test1qqs9t682vw0qgs0w0unmsh6w7ge4zvp8n7fm6qnw2vwg5hxaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs9kqafr	f	\\x2055e8ea639e0441ee7f27b85f4ef2335130279f93bd026e531c8a5c	89	3000000	\N	\N	\N
311	170	44	addr_test1qznffq7zrlwz9hjq4e04qk74kdpj8wemylfjqrp44gcxpw7aqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsvnllwp	f	\\xa69483c21fdc22de40ae5f505bd5b34323bb3b27d3200c35aa3060bb	89	3000000	\N	\N	\N
312	170	45	addr_test1qzdhqwgc775s30psg5rl9l8u8rvc8999f047qnt246axv9waqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphswnspmh	f	\\x9b703918f7a908bc304507f2fcfc38d98394a54bebe04d6aaeba6615	89	3000000	\N	\N	\N
313	170	46	addr_test1qqqgqq5uuc3z6gx6nhr7rhsdf5j2uscvrvhgeud6llw8ta7aqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsq022y0	f	\\x0080029ce6222d20da9dc7e1de0d4d24ae430c1b2e8cf1baffdc75f7	89	3000000	\N	\N	\N
314	170	47	addr_test1qpumljt6h6cd58yfrcf46kw2my7dd86fvgvh5jjq4us8mkkaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsy7et5y	f	\\x79bfc97abeb0da1c891e135d59cad93cd69f4962197a4a40af207dda	89	3000000	\N	\N	\N
315	170	48	addr_test1qp5qawwthqyv60lsuk0wpl0ljwfx6zaruth8m7y7ewrppykaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsctdfw0	f	\\x680eb9cbb808cd3ff0e59ee0fdff93926d0ba3e2ee7df89ecb861092	89	3000000	\N	\N	\N
316	170	49	addr_test1qqy3d8k98hersmyh902kpz846lq8r9dk6whddvdc5sfl9fkaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsu3m2yk	f	\\x09169ec53df2386c972bd56088f5d7c07195b6d3aed6b1b8a413f2a6	89	3000000	\N	\N	\N
317	170	50	addr_test1qprak0hez0txheplk9cdlvt9draxn8s9vgwljc04xvcwh37aqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphss7z5n0	f	\\x47db3ef913d66be43fb170dfb16568fa699e05621df961f53330ebc7	89	3000000	\N	\N	\N
318	170	51	addr_test1qp2j70xle3vzgmfcqzuhe7upz9k5736ap4vz698eda90207aqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphs9wd3rm	f	\\x552f3cdfcc58246d3800b97cfb81116d4f475d0d582d14f96f4af53f	89	3000000	\N	\N	\N
319	170	52	addr_test1qz5s0gfjs96vszzqc05kzrlu2cerzam7cve78pz2wtcved7aqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsqu4hsj	f	\\xa907a1328174c80840c3e9610ffc563231777ec333e3844a72f0ccb7	89	3000000	\N	\N	\N
320	170	53	addr_test1qzts69ayznkjfx7s73fkgjl7w927hqa2pkcxqwan58ps92xaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsqhmnu5	f	\\x970d17a414ed249bd0f453644bfe7155eb83aa0db0603bb3a1c302a8	89	3000000	\N	\N	\N
321	170	54	addr_test1qq2l0ulmzlvd9m02znlyegpp7paamdkca4nlj2ee9lzndf7aqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphstmfe7p	f	\\x15f7f3fb17d8d2edea14fe4ca021f07bddb6d8ed67f92b392fc536a7	89	3000000	\N	\N	\N
322	170	55	addr_test1qpwhh5fnq89w7patm0rank6kqevuyzlu6zprus285ddhlhkaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsyee6dv	f	\\x5d7bd13301caef07abdbc7d9db560659c20bfcd0823e4147a35b7fde	89	3000000	\N	\N	\N
323	170	56	addr_test1qrr20z3j6ktnzsc3tr853lvjet3rsypchcrd0jeh8n5g9f7aqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsz84y40	f	\\xc6a78a32d59731431158cf48fd92cae2381038be06d7cb373ce882a7	89	3000000	\N	\N	\N
324	170	57	addr_test1qp4zw4mmsyjpjl8wl2gq3e63twt5r6qpg0rur0dkahkjm2kaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsuujsrp	f	\\x6a27577b8124197ceefa9008e7515b9741e80143c7c1bdb6eded2daa	89	3000000	\N	\N	\N
325	170	58	addr_test1qp2pexr7c855mqqtwn4eqrpdrv8uxxa0yz0vlva3wahw32xaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsx0cpx3	f	\\x541c987ec1e94d800b74eb900c2d1b0fc31baf209ecfb3b1776ee8a8	89	3000000	\N	\N	\N
326	170	59	addr_test1qq72e7t9udhulh2g3rpvzv3fu3zt4clfr3fyca8qq93akfxaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphstwpzqc	f	\\x3cacf965e36fcfdd4888c2c13229e444bae3e91c524c74e00163db24	89	3000000	\N	\N	\N
327	170	60	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	58317054511	\N	\N	\N
328	170	61	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
329	170	62	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
330	170	63	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
331	170	64	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
332	170	65	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
333	170	66	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
334	170	67	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
335	170	68	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
336	170	69	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
337	170	70	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
338	170	71	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
339	170	72	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
340	170	73	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
341	170	74	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
342	170	75	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
343	170	76	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
344	170	77	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
345	170	78	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
346	170	79	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
347	170	80	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
348	170	81	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
349	170	82	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
350	170	83	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
351	170	84	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
352	170	85	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
353	170	86	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
354	170	87	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
355	170	88	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
356	170	89	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
357	170	90	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
358	170	91	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
359	170	92	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
360	170	93	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
361	170	94	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
362	170	95	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
363	170	96	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
364	170	97	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
365	170	98	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
366	170	99	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
367	170	100	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
368	170	101	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
369	170	102	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
370	170	103	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
371	170	104	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
372	170	105	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
373	170	106	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
374	170	107	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
375	170	108	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
376	170	109	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
377	170	110	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
378	170	111	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
379	170	112	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
380	170	113	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
381	170	114	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
382	170	115	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
383	170	116	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
384	170	117	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
385	170	118	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
386	170	119	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49754149703	\N	\N	\N
387	171	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	178500000	\N	\N	\N
388	171	1	addr_test1qr9jy3vjkapfqs0hutvtxt9hqs8k5cwhurgadrcqjwk2l9kaqeytgkvaa6n5wdxrkj4m6cxlag02g83eaw393u30gphsjm7efx	f	\\xcb224592b7429041f7e2d8b32cb7040f6a61d7e0d1d68f0093acaf96	89	974447	\N	\N	\N
389	172	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	72	1000000	\N	\N	\N
390	172	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49752967306	\N	\N	\N
391	173	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1998956229113	\N	\N	\N
392	174	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
393	174	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49746800617	\N	\N	\N
394	175	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	969750	\N	\N	\N
395	175	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49753009656	\N	\N	\N
396	176	0	addr_test1xrdrxmwx3pddvuvvv5khvj4ja9aytlyftawp83al536w4xx6xdkudzz66ecccefdwe9t96t6gh7gjh6uz0rmlfr5a2vqp7y5cz	t	\\xda336dc6885ad6718c652d764ab2e97a45fc895f5c13c7bfa474ea98	91	10000000	\N	\N	\N
397	176	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743981254	\N	\N	\N
398	177	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1000000	\N	\N	\N
399	177	1	addr_test1xrdrxmwx3pddvuvvv5khvj4ja9aytlyftawp83al536w4xx6xdkudzz66ecccefdwe9t96t6gh7gjh6uz0rmlfr5a2vqp7y5cz	t	\\xda336dc6885ad6718c652d764ab2e97a45fc895f5c13c7bfa474ea98	91	8814039	\N	\N	\N
400	178	0	addr_test1xrdrxmwx3pddvuvvv5khvj4ja9aytlyftawp83al536w4xx6xdkudzz66ecccefdwe9t96t6gh7gjh6uz0rmlfr5a2vqp7y5cz	t	\\xda336dc6885ad6718c652d764ab2e97a45fc895f5c13c7bfa474ea98	91	8633754	\N	\N	\N
401	179	0	addr_test1xq5lzlmc529gt7p9hr26mfr8trxutt955tzq0utzm9z0ga3f79lh3g52shuztwx44kjxwkxdckktfgkyqlck9k2y73mqsktw87	t	\\x29f17f78a28a85f825b8d5ada46758cdc5acb4a2c407f162d944f476	93	10000000	\N	\N	\N
402	179	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743981254	\N	\N	\N
403	180	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1000000	\N	\N	\N
404	180	1	addr_test1xq5lzlmc529gt7p9hr26mfr8trxutt955tzq0utzm9z0ga3f79lh3g52shuztwx44kjxwkxdckktfgkyqlck9k2y73mqsktw87	t	\\x29f17f78a28a85f825b8d5ada46758cdc5acb4a2c407f162d944f476	93	8818439	\N	\N	\N
405	181	0	5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg	f	\N	\N	3000000	\N	\N	\N
406	181	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49750797713	\N	\N	\N
407	182	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2646822	\N	\N	\N
408	183	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
409	183	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
410	184	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
411	184	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49741632212	\N	\N	\N
412	185	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
413	185	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
414	186	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
415	186	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49753979670	\N	\N	\N
416	187	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
417	187	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49751626492	\N	\N	\N
418	188	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
419	188	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
420	189	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
421	189	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
422	190	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
423	190	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
424	191	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
425	191	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743812849	\N	\N	\N
426	192	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
427	192	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1998951060708	\N	\N	\N
428	193	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
429	193	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49738812849	\N	\N	\N
430	194	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
431	194	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
432	195	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
433	195	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
434	196	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
435	196	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49746458087	\N	\N	\N
436	197	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
437	197	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
438	198	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
439	198	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
440	199	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
441	199	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
442	200	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
443	200	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
444	201	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
445	201	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
446	202	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
447	202	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49736463807	\N	\N	\N
448	203	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
449	203	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743812849	\N	\N	\N
450	204	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
451	204	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49744779431	\N	\N	\N
452	205	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
453	205	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
454	206	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
455	206	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743812849	\N	\N	\N
456	207	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
457	207	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
458	208	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
459	208	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743812849	\N	\N	\N
460	209	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
461	209	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
462	210	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
463	210	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743812849	\N	\N	\N
464	211	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
465	211	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
466	212	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
467	212	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
468	213	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
469	213	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49738644444	\N	\N	\N
470	214	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
471	214	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743812849	\N	\N	\N
472	215	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
473	215	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
474	216	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
475	216	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
476	217	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
477	217	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
478	218	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
479	218	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743812849	\N	\N	\N
480	219	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
481	219	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
482	220	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
483	220	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
484	221	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
485	221	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743812849	\N	\N	\N
486	222	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
487	222	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49733644444	\N	\N	\N
488	223	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
489	223	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	173331771	\N	\N	\N
490	224	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
491	224	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
492	225	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
493	225	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748811265	\N	\N	\N
494	226	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
495	226	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
496	227	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
497	227	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743642860	\N	\N	\N
498	228	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
499	228	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1998945892303	\N	\N	\N
500	229	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
501	229	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743812849	\N	\N	\N
502	230	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
503	230	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49753979670	\N	\N	\N
504	231	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
505	231	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4831771	\N	\N	\N
506	232	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
507	232	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49738644444	\N	\N	\N
508	233	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
509	233	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
510	234	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
511	234	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743812849	\N	\N	\N
512	235	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
513	235	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
514	236	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
515	236	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1998940723898	\N	\N	\N
516	237	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
517	237	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
518	238	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
519	238	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
520	239	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
521	239	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748811265	\N	\N	\N
522	240	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
523	240	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743812849	\N	\N	\N
524	241	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
525	241	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
526	242	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
527	242	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5828603	\N	\N	\N
528	243	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
529	243	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
530	244	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
531	244	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1998935555493	\N	\N	\N
532	245	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
533	245	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49753979670	\N	\N	\N
534	246	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
535	246	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
536	247	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
537	247	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743812849	\N	\N	\N
538	248	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
539	248	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
540	249	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
541	249	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
542	250	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
543	250	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743812849	\N	\N	\N
544	251	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
545	251	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
546	252	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
547	252	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748811265	\N	\N	\N
548	253	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
549	253	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
550	254	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
551	254	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
552	255	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
553	255	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748811265	\N	\N	\N
554	256	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
555	256	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49738644444	\N	\N	\N
556	257	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
557	257	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
558	258	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
559	258	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
560	259	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
561	259	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
562	260	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
563	260	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49753809857	\N	\N	\N
564	261	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
565	261	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
566	262	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
567	262	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
568	263	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
569	263	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49738644444	\N	\N	\N
570	264	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
571	264	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
572	265	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
573	265	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
574	266	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
575	266	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748811265	\N	\N	\N
576	267	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
577	267	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
578	268	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
579	268	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
580	269	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
581	269	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
582	270	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
583	270	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
584	271	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
585	271	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748641452	\N	\N	\N
586	272	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
587	272	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4661958	\N	\N	\N
588	273	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
589	273	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
590	274	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
591	274	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	168163542	\N	\N	\N
592	275	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
593	275	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743473047	\N	\N	\N
594	276	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
595	276	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4492145	\N	\N	\N
596	277	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
597	277	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
598	278	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
599	278	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748981254	\N	\N	\N
600	279	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
601	279	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49743642860	\N	\N	\N
602	280	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
603	280	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49748811265	\N	\N	\N
604	281	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
605	281	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49750119869	\N	\N	\N
606	282	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
607	282	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	49738644444	\N	\N	\N
608	283	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
609	283	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	61846510982	\N	\N	\N
610	284	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1249111219796	\N	\N	\N
611	284	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	95	1249111655413	\N	\N	\N
612	284	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	624555827707	\N	\N	\N
613	284	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	95	624555827706	\N	\N	\N
614	284	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312277913853	\N	\N	\N
615	284	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	95	312277913853	\N	\N	\N
616	284	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156138956927	\N	\N	\N
617	284	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	95	156138956927	\N	\N	\N
618	284	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78069478463	\N	\N	\N
619	284	9	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	95	78069478463	\N	\N	\N
620	284	10	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39034739232	\N	\N	\N
621	284	11	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	95	39034739232	\N	\N	\N
622	284	12	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39034739231	\N	\N	\N
623	284	13	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	95	39034739231	\N	\N	\N
624	285	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
625	285	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501498307973	\N	\N	\N
626	285	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250749262169	\N	\N	\N
627	285	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374631084	\N	\N	\N
628	285	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687315542	\N	\N	\N
629	285	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343657771	\N	\N	\N
630	285	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171828886	\N	\N	\N
631	285	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085914443	\N	\N	\N
632	285	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085914442	\N	\N	\N
633	286	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
634	286	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501498214002	\N	\N	\N
635	286	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250749208078	\N	\N	\N
636	286	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374604039	\N	\N	\N
637	286	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687302019	\N	\N	\N
638	286	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343651010	\N	\N	\N
639	286	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171825505	\N	\N	\N
640	286	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085912752	\N	\N	\N
641	286	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085912752	\N	\N	\N
642	287	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
643	287	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501498112926	\N	\N	\N
644	287	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250749157539	\N	\N	\N
645	287	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374578770	\N	\N	\N
646	287	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687289385	\N	\N	\N
647	287	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343644692	\N	\N	\N
648	287	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171822346	\N	\N	\N
649	287	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085911173	\N	\N	\N
650	287	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085911173	\N	\N	\N
651	288	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
652	288	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501498011849	\N	\N	\N
653	288	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250749107001	\N	\N	\N
654	288	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374553501	\N	\N	\N
655	288	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687276750	\N	\N	\N
656	288	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343638375	\N	\N	\N
657	288	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171819188	\N	\N	\N
658	288	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085909594	\N	\N	\N
659	288	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085909593	\N	\N	\N
660	289	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
661	289	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501497910773	\N	\N	\N
662	289	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250749056463	\N	\N	\N
663	289	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374528231	\N	\N	\N
664	289	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687264116	\N	\N	\N
665	289	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343632058	\N	\N	\N
666	289	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171816029	\N	\N	\N
667	289	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085908014	\N	\N	\N
668	289	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085908014	\N	\N	\N
669	290	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
670	290	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501497809696	\N	\N	\N
671	290	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250749005925	\N	\N	\N
672	290	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374502962	\N	\N	\N
673	290	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687251481	\N	\N	\N
674	290	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343625741	\N	\N	\N
675	290	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171812870	\N	\N	\N
676	290	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085906435	\N	\N	\N
677	290	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085906435	\N	\N	\N
678	291	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
679	291	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501497708620	\N	\N	\N
680	291	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748955386	\N	\N	\N
681	291	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374477693	\N	\N	\N
682	291	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687238847	\N	\N	\N
683	291	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343619423	\N	\N	\N
684	291	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171809712	\N	\N	\N
685	291	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085904856	\N	\N	\N
686	291	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085904855	\N	\N	\N
687	292	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
688	292	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501497607543	\N	\N	\N
689	292	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748904848	\N	\N	\N
690	292	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374452424	\N	\N	\N
691	292	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687226212	\N	\N	\N
692	292	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343613106	\N	\N	\N
693	292	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171806553	\N	\N	\N
694	292	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085903277	\N	\N	\N
695	292	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085903276	\N	\N	\N
696	293	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
697	293	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501497506467	\N	\N	\N
698	293	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748854310	\N	\N	\N
699	293	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374427155	\N	\N	\N
700	293	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687213577	\N	\N	\N
701	293	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343606789	\N	\N	\N
702	293	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171803394	\N	\N	\N
703	293	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085901697	\N	\N	\N
704	293	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085901697	\N	\N	\N
705	294	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
706	294	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501497405390	\N	\N	\N
707	294	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748803772	\N	\N	\N
708	294	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374401886	\N	\N	\N
709	294	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687200943	\N	\N	\N
710	294	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343600471	\N	\N	\N
711	294	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171800236	\N	\N	\N
712	294	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085900118	\N	\N	\N
713	294	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085900117	\N	\N	\N
714	295	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
715	295	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501497304314	\N	\N	\N
716	295	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748753233	\N	\N	\N
717	295	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374376617	\N	\N	\N
718	295	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687188308	\N	\N	\N
719	295	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343594154	\N	\N	\N
720	295	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171797077	\N	\N	\N
721	295	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085898539	\N	\N	\N
722	295	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085898538	\N	\N	\N
723	296	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
724	296	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501497203237	\N	\N	\N
725	296	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748702695	\N	\N	\N
726	296	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374351348	\N	\N	\N
727	296	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687175674	\N	\N	\N
728	296	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343587837	\N	\N	\N
729	296	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171793918	\N	\N	\N
730	296	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085896959	\N	\N	\N
731	296	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085896959	\N	\N	\N
732	297	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
733	297	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501497102161	\N	\N	\N
734	297	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748652157	\N	\N	\N
735	297	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374326078	\N	\N	\N
736	297	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687163039	\N	\N	\N
737	297	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343581520	\N	\N	\N
738	297	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171790760	\N	\N	\N
739	297	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085895380	\N	\N	\N
740	297	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085895379	\N	\N	\N
741	298	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
742	298	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501497001084	\N	\N	\N
743	298	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748601619	\N	\N	\N
744	298	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374300809	\N	\N	\N
745	298	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687150405	\N	\N	\N
746	298	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343575202	\N	\N	\N
747	298	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171787601	\N	\N	\N
748	298	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085893801	\N	\N	\N
749	298	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085893800	\N	\N	\N
750	299	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
751	299	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501496900008	\N	\N	\N
752	299	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748551080	\N	\N	\N
753	299	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374275540	\N	\N	\N
754	299	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687137770	\N	\N	\N
755	299	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343568885	\N	\N	\N
756	299	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171784443	\N	\N	\N
757	299	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085892221	\N	\N	\N
758	299	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085892221	\N	\N	\N
759	300	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
760	300	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501496798931	\N	\N	\N
761	300	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748500542	\N	\N	\N
762	300	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374250271	\N	\N	\N
763	300	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687125136	\N	\N	\N
764	300	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343562568	\N	\N	\N
765	300	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171781284	\N	\N	\N
766	300	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085890642	\N	\N	\N
767	300	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085890641	\N	\N	\N
768	301	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
769	301	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501496697855	\N	\N	\N
770	301	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748450004	\N	\N	\N
771	301	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374225002	\N	\N	\N
772	301	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687112501	\N	\N	\N
773	301	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343556250	\N	\N	\N
774	301	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171778125	\N	\N	\N
775	301	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085889063	\N	\N	\N
776	301	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085889062	\N	\N	\N
777	302	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
778	302	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501496596778	\N	\N	\N
779	302	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748399466	\N	\N	\N
780	302	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374199733	\N	\N	\N
781	302	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687099866	\N	\N	\N
782	302	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343549933	\N	\N	\N
783	302	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171774967	\N	\N	\N
784	302	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085887483	\N	\N	\N
785	302	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085887483	\N	\N	\N
786	303	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
787	303	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501496495702	\N	\N	\N
788	303	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748348927	\N	\N	\N
789	303	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374174464	\N	\N	\N
790	303	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687087232	\N	\N	\N
791	303	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343543616	\N	\N	\N
792	303	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171771808	\N	\N	\N
793	303	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085885904	\N	\N	\N
794	303	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085885903	\N	\N	\N
795	304	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
796	304	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501496394625	\N	\N	\N
797	304	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748298389	\N	\N	\N
798	304	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374149195	\N	\N	\N
799	304	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687074597	\N	\N	\N
800	304	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343537299	\N	\N	\N
801	304	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171768649	\N	\N	\N
802	304	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085884325	\N	\N	\N
803	304	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085884324	\N	\N	\N
804	305	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
805	305	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501496293549	\N	\N	\N
806	305	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748247851	\N	\N	\N
807	305	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374123925	\N	\N	\N
808	305	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687061963	\N	\N	\N
809	305	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343530981	\N	\N	\N
810	305	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171765491	\N	\N	\N
811	305	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085882745	\N	\N	\N
812	305	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085882745	\N	\N	\N
813	306	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
814	306	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501496192472	\N	\N	\N
815	306	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748197313	\N	\N	\N
816	306	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374098656	\N	\N	\N
817	306	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687049328	\N	\N	\N
818	306	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343524664	\N	\N	\N
819	306	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171762332	\N	\N	\N
820	306	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085881166	\N	\N	\N
821	306	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085881166	\N	\N	\N
822	307	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
823	307	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501496091396	\N	\N	\N
824	307	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748146774	\N	\N	\N
825	307	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374073387	\N	\N	\N
826	307	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687036694	\N	\N	\N
827	307	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343518347	\N	\N	\N
828	307	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171759173	\N	\N	\N
829	307	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085879587	\N	\N	\N
830	307	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085879586	\N	\N	\N
831	308	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
832	308	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501495990319	\N	\N	\N
833	308	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748096236	\N	\N	\N
834	308	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374048118	\N	\N	\N
835	308	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687024059	\N	\N	\N
836	308	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343512030	\N	\N	\N
837	308	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171756015	\N	\N	\N
838	308	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085878007	\N	\N	\N
839	308	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085878007	\N	\N	\N
840	309	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
841	309	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501495889243	\N	\N	\N
842	309	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250748045698	\N	\N	\N
843	309	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625374022849	\N	\N	\N
844	309	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312687011424	\N	\N	\N
845	309	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343505712	\N	\N	\N
846	309	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171752856	\N	\N	\N
847	309	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085876428	\N	\N	\N
848	309	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085876428	\N	\N	\N
849	310	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
850	310	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501495788166	\N	\N	\N
851	310	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747995160	\N	\N	\N
852	310	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373997580	\N	\N	\N
853	310	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686998790	\N	\N	\N
854	310	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343499395	\N	\N	\N
855	310	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171749697	\N	\N	\N
856	310	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085874849	\N	\N	\N
857	310	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085874848	\N	\N	\N
858	311	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
859	311	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501495687090	\N	\N	\N
860	311	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747944621	\N	\N	\N
861	311	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373972311	\N	\N	\N
862	311	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686986155	\N	\N	\N
863	311	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343493078	\N	\N	\N
864	311	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171746539	\N	\N	\N
865	311	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085873269	\N	\N	\N
866	311	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085873269	\N	\N	\N
867	312	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
868	312	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501495586013	\N	\N	\N
869	312	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747894083	\N	\N	\N
870	312	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373947042	\N	\N	\N
871	312	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686973521	\N	\N	\N
872	312	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343486760	\N	\N	\N
873	312	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171743380	\N	\N	\N
874	312	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085871690	\N	\N	\N
875	312	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085871690	\N	\N	\N
876	313	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
877	313	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501495484937	\N	\N	\N
878	313	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747843545	\N	\N	\N
879	313	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373921772	\N	\N	\N
880	313	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686960886	\N	\N	\N
881	313	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343480443	\N	\N	\N
882	313	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171740222	\N	\N	\N
883	313	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085870111	\N	\N	\N
884	313	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085870110	\N	\N	\N
885	314	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
886	314	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501495383860	\N	\N	\N
887	314	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747793007	\N	\N	\N
888	314	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373896503	\N	\N	\N
889	314	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686948252	\N	\N	\N
890	314	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343474126	\N	\N	\N
891	314	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171737063	\N	\N	\N
892	314	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085868531	\N	\N	\N
893	314	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085868531	\N	\N	\N
894	315	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
895	315	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501495282784	\N	\N	\N
896	315	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747742468	\N	\N	\N
897	315	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373871234	\N	\N	\N
898	315	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686935617	\N	\N	\N
899	315	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343467809	\N	\N	\N
900	315	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171733904	\N	\N	\N
901	315	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085866952	\N	\N	\N
902	315	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085866952	\N	\N	\N
903	316	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
904	316	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501495181707	\N	\N	\N
905	316	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747691930	\N	\N	\N
906	316	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373845965	\N	\N	\N
907	316	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686922983	\N	\N	\N
908	316	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343461491	\N	\N	\N
909	316	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171730746	\N	\N	\N
910	316	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085865373	\N	\N	\N
911	316	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085865372	\N	\N	\N
912	317	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
913	317	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501495080631	\N	\N	\N
914	317	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747641392	\N	\N	\N
915	317	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373820696	\N	\N	\N
916	317	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686910348	\N	\N	\N
917	317	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343455174	\N	\N	\N
918	317	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171727587	\N	\N	\N
919	317	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085863793	\N	\N	\N
920	317	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085863793	\N	\N	\N
921	318	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
922	318	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501494979554	\N	\N	\N
923	318	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747590854	\N	\N	\N
924	318	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373795427	\N	\N	\N
925	318	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686897713	\N	\N	\N
926	318	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343448857	\N	\N	\N
927	318	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171724428	\N	\N	\N
928	318	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085862214	\N	\N	\N
929	318	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085862214	\N	\N	\N
930	319	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
931	319	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501494878478	\N	\N	\N
932	319	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747540315	\N	\N	\N
933	319	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373770158	\N	\N	\N
934	319	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686885079	\N	\N	\N
935	319	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343442539	\N	\N	\N
936	319	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171721270	\N	\N	\N
937	319	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085860635	\N	\N	\N
938	319	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085860634	\N	\N	\N
939	320	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
940	320	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501494777401	\N	\N	\N
941	320	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747489777	\N	\N	\N
942	320	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373744889	\N	\N	\N
943	320	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686872444	\N	\N	\N
944	320	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343436222	\N	\N	\N
945	320	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171718111	\N	\N	\N
946	320	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085859056	\N	\N	\N
947	320	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085859055	\N	\N	\N
948	321	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
949	321	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501494676325	\N	\N	\N
950	321	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747439239	\N	\N	\N
951	321	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373719619	\N	\N	\N
952	321	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686859810	\N	\N	\N
953	321	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343429905	\N	\N	\N
954	321	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171714952	\N	\N	\N
955	321	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085857476	\N	\N	\N
956	321	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085857476	\N	\N	\N
957	322	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
958	322	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501494575248	\N	\N	\N
959	322	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747388701	\N	\N	\N
960	322	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373694350	\N	\N	\N
961	322	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686847175	\N	\N	\N
962	322	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343423588	\N	\N	\N
963	322	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171711794	\N	\N	\N
964	322	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085855897	\N	\N	\N
965	322	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085855896	\N	\N	\N
966	323	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
967	323	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501494474172	\N	\N	\N
968	323	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747338162	\N	\N	\N
969	323	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373669081	\N	\N	\N
970	323	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686834541	\N	\N	\N
971	323	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343417270	\N	\N	\N
972	323	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171708635	\N	\N	\N
973	323	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085854318	\N	\N	\N
974	323	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085854317	\N	\N	\N
975	324	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
976	324	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501494373095	\N	\N	\N
977	324	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747287624	\N	\N	\N
978	324	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373643812	\N	\N	\N
979	324	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686821906	\N	\N	\N
980	324	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343410953	\N	\N	\N
981	324	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171705477	\N	\N	\N
982	324	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085852738	\N	\N	\N
983	324	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085852738	\N	\N	\N
984	325	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
985	325	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501494272019	\N	\N	\N
986	325	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747237086	\N	\N	\N
987	325	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373618543	\N	\N	\N
988	325	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686809271	\N	\N	\N
989	325	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343404636	\N	\N	\N
990	325	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171702318	\N	\N	\N
991	325	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085851159	\N	\N	\N
992	325	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085851158	\N	\N	\N
993	326	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
994	326	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501494170942	\N	\N	\N
995	326	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747186548	\N	\N	\N
996	326	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373593274	\N	\N	\N
997	326	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686796637	\N	\N	\N
998	326	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343398318	\N	\N	\N
999	326	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171699159	\N	\N	\N
1000	326	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085849580	\N	\N	\N
1001	326	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085849579	\N	\N	\N
1002	327	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1003	327	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501494069866	\N	\N	\N
1004	327	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747136009	\N	\N	\N
1005	327	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373568005	\N	\N	\N
1006	327	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686784002	\N	\N	\N
1007	327	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343392001	\N	\N	\N
1008	327	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171696001	\N	\N	\N
1009	327	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085848000	\N	\N	\N
1010	327	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085848000	\N	\N	\N
1011	328	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1012	328	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501493968789	\N	\N	\N
1013	328	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747085471	\N	\N	\N
1014	328	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373542736	\N	\N	\N
1015	328	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686771368	\N	\N	\N
1016	328	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343385684	\N	\N	\N
1017	328	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171692842	\N	\N	\N
1018	328	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085846421	\N	\N	\N
1019	328	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085846420	\N	\N	\N
1020	329	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1021	329	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501493867713	\N	\N	\N
1022	329	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250747034933	\N	\N	\N
1023	329	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373517466	\N	\N	\N
1024	329	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686758733	\N	\N	\N
1025	329	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343379367	\N	\N	\N
1026	329	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171689683	\N	\N	\N
1027	329	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085844842	\N	\N	\N
1028	329	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085844841	\N	\N	\N
1029	330	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1030	330	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501493766636	\N	\N	\N
1031	330	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746984395	\N	\N	\N
1032	330	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373492197	\N	\N	\N
1033	330	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686746099	\N	\N	\N
1034	330	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343373049	\N	\N	\N
1035	330	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171686525	\N	\N	\N
1036	330	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085843262	\N	\N	\N
1037	330	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085843262	\N	\N	\N
1038	331	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1039	331	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501493665560	\N	\N	\N
1040	331	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746933856	\N	\N	\N
1041	331	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373466928	\N	\N	\N
1042	331	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686733464	\N	\N	\N
1043	331	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343366732	\N	\N	\N
1044	331	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171683366	\N	\N	\N
1045	331	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085841683	\N	\N	\N
1046	331	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085841683	\N	\N	\N
1047	332	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1048	332	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501493564483	\N	\N	\N
1049	332	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746883318	\N	\N	\N
1050	332	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373441659	\N	\N	\N
1051	332	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686720830	\N	\N	\N
1052	332	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343360415	\N	\N	\N
1053	332	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171680207	\N	\N	\N
1054	332	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085840104	\N	\N	\N
1055	332	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085840103	\N	\N	\N
1056	333	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1057	333	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501493463407	\N	\N	\N
1058	333	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746832780	\N	\N	\N
1059	333	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373416390	\N	\N	\N
1060	333	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686708195	\N	\N	\N
1061	333	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343354097	\N	\N	\N
1062	333	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171677049	\N	\N	\N
1063	333	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085838524	\N	\N	\N
1064	333	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085838524	\N	\N	\N
1065	334	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1066	334	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501493362330	\N	\N	\N
1067	334	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746782242	\N	\N	\N
1068	334	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373391121	\N	\N	\N
1069	334	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686695560	\N	\N	\N
1070	334	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343347780	\N	\N	\N
1071	334	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171673890	\N	\N	\N
1072	334	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085836945	\N	\N	\N
1073	334	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085836945	\N	\N	\N
1074	335	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1075	335	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501493261254	\N	\N	\N
1076	335	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746731703	\N	\N	\N
1077	335	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373365852	\N	\N	\N
1078	335	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686682926	\N	\N	\N
1079	335	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343341463	\N	\N	\N
1080	335	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171670731	\N	\N	\N
1081	335	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085835366	\N	\N	\N
1082	335	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085835365	\N	\N	\N
1083	336	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1084	336	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501493160177	\N	\N	\N
1085	336	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746681165	\N	\N	\N
1086	336	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373340583	\N	\N	\N
1087	336	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686670291	\N	\N	\N
1088	336	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343335146	\N	\N	\N
1089	336	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171667573	\N	\N	\N
1090	336	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085833786	\N	\N	\N
1091	336	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085833786	\N	\N	\N
1092	337	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1093	337	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501493059101	\N	\N	\N
1094	337	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746630627	\N	\N	\N
1095	337	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373315313	\N	\N	\N
1096	337	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686657657	\N	\N	\N
1097	337	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343328828	\N	\N	\N
1098	337	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171664414	\N	\N	\N
1099	337	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085832207	\N	\N	\N
1100	337	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085832207	\N	\N	\N
1101	338	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1102	338	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501492958024	\N	\N	\N
1103	338	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746580089	\N	\N	\N
1104	338	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373290044	\N	\N	\N
1105	338	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686645022	\N	\N	\N
1106	338	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343322511	\N	\N	\N
1107	338	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171661256	\N	\N	\N
1108	338	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085830628	\N	\N	\N
1109	338	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085830627	\N	\N	\N
1110	339	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1111	339	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501492856948	\N	\N	\N
1112	339	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746529550	\N	\N	\N
1113	339	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373264775	\N	\N	\N
1114	339	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686632388	\N	\N	\N
1115	339	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343316194	\N	\N	\N
1116	339	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171658097	\N	\N	\N
1117	339	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085829048	\N	\N	\N
1118	339	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085829048	\N	\N	\N
1119	340	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1120	340	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501492755871	\N	\N	\N
1121	340	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746479012	\N	\N	\N
1122	340	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373239506	\N	\N	\N
1123	340	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686619753	\N	\N	\N
1124	340	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343309877	\N	\N	\N
1125	340	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171654938	\N	\N	\N
1126	340	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085827469	\N	\N	\N
1127	340	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085827469	\N	\N	\N
1128	341	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1129	341	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501492654795	\N	\N	\N
1130	341	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746428474	\N	\N	\N
1131	341	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373214237	\N	\N	\N
1132	341	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686607118	\N	\N	\N
1133	341	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343303559	\N	\N	\N
1134	341	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171651780	\N	\N	\N
1135	341	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085825890	\N	\N	\N
1136	341	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085825889	\N	\N	\N
1137	342	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1138	342	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501492553718	\N	\N	\N
1139	342	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746377936	\N	\N	\N
1140	342	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373188968	\N	\N	\N
1141	342	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686594484	\N	\N	\N
1142	342	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343297242	\N	\N	\N
1143	342	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171648621	\N	\N	\N
1144	342	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085824310	\N	\N	\N
1145	342	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085824310	\N	\N	\N
1146	343	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1147	343	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501492452642	\N	\N	\N
1148	343	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746327397	\N	\N	\N
1149	343	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373163699	\N	\N	\N
1150	343	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686581849	\N	\N	\N
1151	343	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343290925	\N	\N	\N
1152	343	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171645462	\N	\N	\N
1153	343	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085822731	\N	\N	\N
1154	343	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085822731	\N	\N	\N
1155	344	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1156	344	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501492351565	\N	\N	\N
1157	344	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746276859	\N	\N	\N
1158	344	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373138430	\N	\N	\N
1159	344	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686569215	\N	\N	\N
1160	344	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343284607	\N	\N	\N
1161	344	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171642304	\N	\N	\N
1162	344	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085821152	\N	\N	\N
1163	344	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085821151	\N	\N	\N
1164	345	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1165	345	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501492250489	\N	\N	\N
1166	345	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746226321	\N	\N	\N
1167	345	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373113160	\N	\N	\N
1168	345	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686556580	\N	\N	\N
1169	345	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343278290	\N	\N	\N
1170	345	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171639145	\N	\N	\N
1171	345	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085819573	\N	\N	\N
1172	345	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085819572	\N	\N	\N
1173	346	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1174	346	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501492149412	\N	\N	\N
1175	346	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746175783	\N	\N	\N
1176	346	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373087891	\N	\N	\N
1177	346	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686543946	\N	\N	\N
1178	346	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343271973	\N	\N	\N
1179	346	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171635986	\N	\N	\N
1180	346	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085817993	\N	\N	\N
1181	346	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085817993	\N	\N	\N
1182	347	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1183	347	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501492048336	\N	\N	\N
1184	347	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746125244	\N	\N	\N
1185	347	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373062622	\N	\N	\N
1186	347	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686531311	\N	\N	\N
1187	347	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343265656	\N	\N	\N
1188	347	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171632828	\N	\N	\N
1189	347	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085816414	\N	\N	\N
1190	347	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085816413	\N	\N	\N
1191	348	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1192	348	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501491947259	\N	\N	\N
1193	348	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746074706	\N	\N	\N
1194	348	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373037353	\N	\N	\N
1195	348	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686518677	\N	\N	\N
1196	348	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343259338	\N	\N	\N
1197	348	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171629669	\N	\N	\N
1198	348	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085814835	\N	\N	\N
1199	348	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085814834	\N	\N	\N
1200	349	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1201	349	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501491846183	\N	\N	\N
1202	349	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250746024168	\N	\N	\N
1203	349	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625373012084	\N	\N	\N
1204	349	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686506042	\N	\N	\N
1205	349	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343253021	\N	\N	\N
1206	349	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171626510	\N	\N	\N
1207	349	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085813255	\N	\N	\N
1208	349	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085813255	\N	\N	\N
1209	350	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1210	350	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501491745106	\N	\N	\N
1211	350	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745973630	\N	\N	\N
1212	350	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372986815	\N	\N	\N
1213	350	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686493407	\N	\N	\N
1214	350	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343246704	\N	\N	\N
1215	350	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171623352	\N	\N	\N
1216	350	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085811676	\N	\N	\N
1217	350	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085811675	\N	\N	\N
1218	351	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1219	351	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501491644030	\N	\N	\N
1220	351	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745923091	\N	\N	\N
1221	351	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372961546	\N	\N	\N
1222	351	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686480773	\N	\N	\N
1223	351	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343240386	\N	\N	\N
1224	351	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171620193	\N	\N	\N
1225	351	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085810097	\N	\N	\N
1226	351	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085810096	\N	\N	\N
1227	352	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1228	352	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501491542953	\N	\N	\N
1229	352	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745872553	\N	\N	\N
1230	352	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372936277	\N	\N	\N
1231	352	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686468138	\N	\N	\N
1232	352	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343234069	\N	\N	\N
1233	352	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171617035	\N	\N	\N
1234	352	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085808517	\N	\N	\N
1235	352	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085808517	\N	\N	\N
1236	353	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1237	353	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501491441877	\N	\N	\N
1238	353	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745822015	\N	\N	\N
1239	353	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372911007	\N	\N	\N
1240	353	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686455504	\N	\N	\N
1241	353	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343227752	\N	\N	\N
1242	353	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171613876	\N	\N	\N
1243	353	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085806938	\N	\N	\N
1244	353	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085806937	\N	\N	\N
1245	354	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1246	354	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501491340800	\N	\N	\N
1247	354	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745771477	\N	\N	\N
1248	354	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372885738	\N	\N	\N
1249	354	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686442869	\N	\N	\N
1250	354	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343221435	\N	\N	\N
1251	354	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171610717	\N	\N	\N
1252	354	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085805359	\N	\N	\N
1253	354	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085805358	\N	\N	\N
1254	355	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1255	355	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501491239724	\N	\N	\N
1256	355	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745720938	\N	\N	\N
1257	355	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372860469	\N	\N	\N
1258	355	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686430235	\N	\N	\N
1259	355	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343215117	\N	\N	\N
1260	355	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171607559	\N	\N	\N
1261	355	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085803779	\N	\N	\N
1262	355	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085803779	\N	\N	\N
1263	356	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1264	356	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501491138647	\N	\N	\N
1265	356	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745670400	\N	\N	\N
1266	356	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372835200	\N	\N	\N
1267	356	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686417600	\N	\N	\N
1268	356	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343208800	\N	\N	\N
1269	356	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171604400	\N	\N	\N
1270	356	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085802200	\N	\N	\N
1271	356	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085802200	\N	\N	\N
1272	357	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1273	357	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501491037571	\N	\N	\N
1274	357	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745619862	\N	\N	\N
1275	357	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372809931	\N	\N	\N
1276	357	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686404965	\N	\N	\N
1277	357	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343202483	\N	\N	\N
1278	357	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171601241	\N	\N	\N
1279	357	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085800621	\N	\N	\N
1280	357	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085800620	\N	\N	\N
1281	358	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1282	358	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501490936494	\N	\N	\N
1283	358	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745569324	\N	\N	\N
1284	358	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372784662	\N	\N	\N
1285	358	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686392331	\N	\N	\N
1286	358	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343196165	\N	\N	\N
1287	358	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171598083	\N	\N	\N
1288	358	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085799041	\N	\N	\N
1289	358	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085799041	\N	\N	\N
1290	359	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1291	359	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501490835418	\N	\N	\N
1292	359	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745518785	\N	\N	\N
1293	359	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372759393	\N	\N	\N
1294	359	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686379696	\N	\N	\N
1295	359	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343189848	\N	\N	\N
1296	359	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171594924	\N	\N	\N
1297	359	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085797462	\N	\N	\N
1298	359	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085797462	\N	\N	\N
1299	360	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1300	360	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501490734341	\N	\N	\N
1301	360	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745468247	\N	\N	\N
1302	360	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372734124	\N	\N	\N
1303	360	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686367062	\N	\N	\N
1304	360	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343183531	\N	\N	\N
1305	360	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171591765	\N	\N	\N
1306	360	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085795883	\N	\N	\N
1307	360	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085795882	\N	\N	\N
1308	361	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1309	361	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501490633265	\N	\N	\N
1310	361	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745417709	\N	\N	\N
1311	361	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372708854	\N	\N	\N
1312	361	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686354427	\N	\N	\N
1313	361	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343177214	\N	\N	\N
1314	361	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171588607	\N	\N	\N
1315	361	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085794303	\N	\N	\N
1316	361	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085794303	\N	\N	\N
1317	362	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1318	362	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501490532188	\N	\N	\N
1319	362	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745367171	\N	\N	\N
1320	362	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372683585	\N	\N	\N
1321	362	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686341793	\N	\N	\N
1322	362	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343170896	\N	\N	\N
1323	362	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171585448	\N	\N	\N
1324	362	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085792724	\N	\N	\N
1325	362	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085792724	\N	\N	\N
1326	363	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1327	363	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501490431112	\N	\N	\N
1328	363	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745316632	\N	\N	\N
1329	363	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372658316	\N	\N	\N
1330	363	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686329158	\N	\N	\N
1331	363	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343164579	\N	\N	\N
1332	363	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171582290	\N	\N	\N
1333	363	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085791145	\N	\N	\N
1334	363	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085791144	\N	\N	\N
1335	364	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1336	364	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501490330035	\N	\N	\N
1337	364	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745266094	\N	\N	\N
1338	364	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372633047	\N	\N	\N
1339	364	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686316524	\N	\N	\N
1340	364	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343158262	\N	\N	\N
1341	364	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171579131	\N	\N	\N
1342	364	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085789565	\N	\N	\N
1343	364	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085789565	\N	\N	\N
1344	365	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1345	365	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501490228959	\N	\N	\N
1346	365	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745215556	\N	\N	\N
1347	365	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372607778	\N	\N	\N
1348	365	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686303889	\N	\N	\N
1349	365	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343151944	\N	\N	\N
1350	365	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171575972	\N	\N	\N
1351	365	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085787986	\N	\N	\N
1352	365	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085787986	\N	\N	\N
1353	366	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1354	366	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501490127882	\N	\N	\N
1355	366	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745165018	\N	\N	\N
1356	366	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372582509	\N	\N	\N
1357	366	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686291254	\N	\N	\N
1358	366	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343145627	\N	\N	\N
1359	366	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171572814	\N	\N	\N
1360	366	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085786407	\N	\N	\N
1361	366	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085786406	\N	\N	\N
1362	367	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1363	367	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501490026806	\N	\N	\N
1364	367	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745114479	\N	\N	\N
1365	367	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372557240	\N	\N	\N
1366	367	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686278620	\N	\N	\N
1367	367	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343139310	\N	\N	\N
1368	367	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171569655	\N	\N	\N
1369	367	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085784827	\N	\N	\N
1370	367	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085784827	\N	\N	\N
1371	368	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1372	368	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501489925729	\N	\N	\N
1373	368	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745063941	\N	\N	\N
1374	368	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372531971	\N	\N	\N
1375	368	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686265985	\N	\N	\N
1376	368	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343132993	\N	\N	\N
1377	368	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171566496	\N	\N	\N
1378	368	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085783248	\N	\N	\N
1379	368	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085783248	\N	\N	\N
1380	369	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1381	369	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501489824653	\N	\N	\N
1382	369	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250745013403	\N	\N	\N
1383	369	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372506701	\N	\N	\N
1384	369	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686253351	\N	\N	\N
1385	369	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343126675	\N	\N	\N
1386	369	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171563338	\N	\N	\N
1387	369	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085781669	\N	\N	\N
1388	369	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085781668	\N	\N	\N
1389	370	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1390	370	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501489723576	\N	\N	\N
1391	370	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744962865	\N	\N	\N
1392	370	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372481432	\N	\N	\N
1393	370	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686240716	\N	\N	\N
1394	370	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343120358	\N	\N	\N
1395	370	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171560179	\N	\N	\N
1396	370	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085780090	\N	\N	\N
1397	370	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085780089	\N	\N	\N
1398	371	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1399	371	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501489622500	\N	\N	\N
1400	371	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744912326	\N	\N	\N
1401	371	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372456163	\N	\N	\N
1402	371	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686228082	\N	\N	\N
1403	371	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343114041	\N	\N	\N
1404	371	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171557020	\N	\N	\N
1405	371	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085778510	\N	\N	\N
1406	371	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085778510	\N	\N	\N
1407	372	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1408	372	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501489521423	\N	\N	\N
1409	372	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744861788	\N	\N	\N
1410	372	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372430894	\N	\N	\N
1411	372	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686215447	\N	\N	\N
1412	372	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343107724	\N	\N	\N
1413	372	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171553862	\N	\N	\N
1414	372	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085776931	\N	\N	\N
1415	372	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085776930	\N	\N	\N
1416	373	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1417	373	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501489420347	\N	\N	\N
1418	373	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744811250	\N	\N	\N
1419	373	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372405625	\N	\N	\N
1420	373	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686202812	\N	\N	\N
1421	373	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343101406	\N	\N	\N
1422	373	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171550703	\N	\N	\N
1423	373	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085775352	\N	\N	\N
1424	373	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085775351	\N	\N	\N
1425	374	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1426	374	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501489319270	\N	\N	\N
1427	374	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744760712	\N	\N	\N
1428	374	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372380356	\N	\N	\N
1429	374	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686190178	\N	\N	\N
1430	374	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343095089	\N	\N	\N
1431	374	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171547544	\N	\N	\N
1432	374	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085773772	\N	\N	\N
1433	374	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085773772	\N	\N	\N
1434	375	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1435	375	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501489218194	\N	\N	\N
1436	375	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744710173	\N	\N	\N
1437	375	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372355087	\N	\N	\N
1438	375	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686177543	\N	\N	\N
1439	375	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343088772	\N	\N	\N
1440	375	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171544386	\N	\N	\N
1441	375	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085772193	\N	\N	\N
1442	375	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085772192	\N	\N	\N
1443	376	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1444	376	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501489117117	\N	\N	\N
1445	376	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744659635	\N	\N	\N
1446	376	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372329818	\N	\N	\N
1447	376	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686164909	\N	\N	\N
1448	376	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343082454	\N	\N	\N
1449	376	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171541227	\N	\N	\N
1450	376	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085770614	\N	\N	\N
1451	376	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085770613	\N	\N	\N
1452	377	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1453	377	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501489016041	\N	\N	\N
1454	377	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744609097	\N	\N	\N
1455	377	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372304548	\N	\N	\N
1456	377	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686152274	\N	\N	\N
1457	377	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343076137	\N	\N	\N
1458	377	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171538069	\N	\N	\N
1459	377	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085769034	\N	\N	\N
1460	377	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085769034	\N	\N	\N
1461	378	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1462	378	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501488914964	\N	\N	\N
1463	378	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744558559	\N	\N	\N
1464	378	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372279279	\N	\N	\N
1465	378	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686139640	\N	\N	\N
1466	378	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343069820	\N	\N	\N
1467	378	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171534910	\N	\N	\N
1468	378	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085767455	\N	\N	\N
1469	378	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085767454	\N	\N	\N
1470	379	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1471	379	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501488813888	\N	\N	\N
1472	379	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744508020	\N	\N	\N
1473	379	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372254010	\N	\N	\N
1474	379	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686127005	\N	\N	\N
1475	379	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343063503	\N	\N	\N
1476	379	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171531751	\N	\N	\N
1477	379	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085765876	\N	\N	\N
1478	379	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085765875	\N	\N	\N
1479	380	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1480	380	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501488712811	\N	\N	\N
1481	380	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744457482	\N	\N	\N
1482	380	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372228741	\N	\N	\N
1483	380	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686114371	\N	\N	\N
1484	380	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343057185	\N	\N	\N
1485	380	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171528593	\N	\N	\N
1486	380	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085764296	\N	\N	\N
1487	380	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085764296	\N	\N	\N
1488	381	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1489	381	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501488611735	\N	\N	\N
1490	381	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744406944	\N	\N	\N
1491	381	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372203472	\N	\N	\N
1492	381	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686101736	\N	\N	\N
1493	381	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343050868	\N	\N	\N
1494	381	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171525434	\N	\N	\N
1495	381	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085762717	\N	\N	\N
1496	381	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085762716	\N	\N	\N
1497	382	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1498	382	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501488510658	\N	\N	\N
1499	382	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744356406	\N	\N	\N
1500	382	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372178203	\N	\N	\N
1501	382	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686089101	\N	\N	\N
1502	382	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343044551	\N	\N	\N
1503	382	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171522275	\N	\N	\N
1504	382	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085761138	\N	\N	\N
1505	382	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085761137	\N	\N	\N
1506	383	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1507	383	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501488409582	\N	\N	\N
1508	383	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744305867	\N	\N	\N
1509	383	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372152934	\N	\N	\N
1510	383	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686076467	\N	\N	\N
1511	383	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343038233	\N	\N	\N
1512	383	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171519117	\N	\N	\N
1513	383	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085759558	\N	\N	\N
1514	383	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085759558	\N	\N	\N
1515	384	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1516	384	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2501488308505	\N	\N	\N
1517	384	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1250744255329	\N	\N	\N
1518	384	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625372127665	\N	\N	\N
1519	384	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312686063832	\N	\N	\N
1520	384	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156343031916	\N	\N	\N
1521	384	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78171515958	\N	\N	\N
1522	384	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085757979	\N	\N	\N
1523	384	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39085757979	\N	\N	\N
1524	385	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1525	385	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2504166223284	\N	\N	\N
1526	385	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1252083218879	\N	\N	\N
1527	385	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626041609439	\N	\N	\N
1528	385	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313020804720	\N	\N	\N
1529	385	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156510402360	\N	\N	\N
1530	385	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78255201180	\N	\N	\N
1531	385	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39127600590	\N	\N	\N
1532	385	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39127600589	\N	\N	\N
1533	386	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	3000000	\N	\N	\N
1534	386	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	4999996820111	\N	\N	\N
1535	387	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	3000000	\N	\N	\N
1536	387	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	4999996648538	\N	\N	\N
1537	388	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	3000000	\N	\N	\N
1538	388	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	4999993472785	\N	\N	\N
1539	389	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	2828559	\N	\N	\N
1540	390	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	3000000	\N	\N	\N
1541	390	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	6818351	\N	\N	\N
1542	391	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	3000000	\N	\N	\N
1543	391	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	6827019	\N	\N	\N
1544	392	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	3000000	\N	\N	\N
1545	392	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	6820683	\N	\N	\N
1546	393	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	5	\N
1547	393	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	95	1252072984034	\N	\N	\N
1548	394	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\\xff1a404ece117cc4482d26b072e30b5a6b3cd055a22debda3f90d704957e273a	6	\N
1549	394	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	95	626031387310	\N	\N	\N
1550	395	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\\x29294f077464c36e67b304ad22547fb3dfa946623b0b2cbae8acea7fb299353c	7	\N
1551	395	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	95	39117377625	\N	\N	\N
1552	396	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	95	4808803	\N	\N	\N
\.


--
-- Data for Name: voting_anchor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.voting_anchor (id, tx_id, url, data_hash, type) FROM stdin;
9	152	https://testing.this	\\x3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d	gov_action
1	136	https://testing.this	\\x3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d	other
\.


--
-- Data for Name: voting_procedure; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.voting_procedure (id, tx_id, index, gov_action_proposal_id, voter_role, drep_voter, pool_voter, vote, voting_anchor_id, committee_voter) FROM stdin;
1	154	0	7	DRep	1	\N	Abstain	1	\N
\.


--
-- Data for Name: withdrawal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.withdrawal (id, addr_id, amount, redeemer_id, tx_id) FROM stdin;
1	68	3534631036	\N	283
2	68	6555862641	\N	285
3	95	992182669	\N	385
4	68	4363873682	\N	385
\.


--
-- Name: ada_pots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ada_pots_id_seq', 14, true);


--
-- Name: block_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.block_id_seq', 1393, true);


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
-- Name: committee_hash_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.committee_hash_id_seq', 1, false);


--
-- Name: committee_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.committee_registration_id_seq', 1, false);


--
-- Name: constitution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.constitution_id_seq', 2, true);


--
-- Name: cost_model_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cost_model_id_seq', 14, true);


--
-- Name: datum_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.datum_id_seq', 7, true);


--
-- Name: delegation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delegation_id_seq', 56, true);


--
-- Name: delegation_vote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delegation_vote_id_seq', 4, true);


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

SELECT pg_catalog.setval('public.drep_hash_id_seq', 8, true);


--
-- Name: drep_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drep_registration_id_seq', 3, true);


--
-- Name: epoch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_id_seq', 34, true);


--
-- Name: epoch_param_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_param_id_seq', 14, true);


--
-- Name: epoch_stake_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_stake_id_seq', 445, true);


--
-- Name: epoch_stake_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_stake_progress_id_seq', 14, true);


--
-- Name: epoch_sync_time_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_sync_time_id_seq', 13, true);


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

SELECT pg_catalog.setval('public.gov_action_proposal_id_seq', 12, true);


--
-- Name: ma_tx_mint_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_mint_id_seq', 30, true);


--
-- Name: ma_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_out_id_seq', 34, true);


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
-- Name: new_committee_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.new_committee_info_id_seq', 1, false);


--
-- Name: new_committee_member_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.new_committee_member_id_seq', 1, false);


--
-- Name: off_chain_pool_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_pool_data_id_seq', 8, true);


--
-- Name: off_chain_pool_fetch_error_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_pool_fetch_error_id_seq', 1, false);


--
-- Name: off_chain_vote_author_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_vote_author_id_seq', 1, false);


--
-- Name: off_chain_vote_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_vote_data_id_seq', 1, false);


--
-- Name: off_chain_vote_external_update_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_vote_external_update_id_seq', 1, false);


--
-- Name: off_chain_vote_fetch_error_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_vote_fetch_error_id_seq', 8, true);


--
-- Name: off_chain_vote_reference_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_vote_reference_id_seq', 1, false);


--
-- Name: param_proposal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.param_proposal_id_seq', 2, true);


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

SELECT pg_catalog.setval('public.reverse_index_id_seq', 1391, true);


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

SELECT pg_catalog.setval('public.slot_leader_id_seq', 1393, true);


--
-- Name: stake_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_address_id_seq', 98, true);


--
-- Name: stake_deregistration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_deregistration_id_seq', 9, true);


--
-- Name: stake_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_registration_id_seq', 50, true);


--
-- Name: treasury_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.treasury_id_seq', 1, false);


--
-- Name: treasury_withdrawal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.treasury_withdrawal_id_seq', 2, true);


--
-- Name: tx_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_id_seq', 396, true);


--
-- Name: tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_in_id_seq', 1452, true);


--
-- Name: tx_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_metadata_id_seq', 15, true);


--
-- Name: tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_out_id_seq', 1552, true);


--
-- Name: voting_anchor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.voting_anchor_id_seq', 16, true);


--
-- Name: voting_procedure_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.voting_procedure_id_seq', 1, true);


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
-- Name: committee_hash committee_hash_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.committee_hash
    ADD CONSTRAINT committee_hash_pkey PRIMARY KEY (id);


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
-- Name: new_committee_info new_committee_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.new_committee_info
    ADD CONSTRAINT new_committee_info_pkey PRIMARY KEY (id);


--
-- Name: new_committee_member new_committee_member_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.new_committee_member
    ADD CONSTRAINT new_committee_member_pkey PRIMARY KEY (id);


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
-- Name: off_chain_vote_author off_chain_vote_author_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_author
    ADD CONSTRAINT off_chain_vote_author_pkey PRIMARY KEY (id);


--
-- Name: off_chain_vote_data off_chain_vote_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_data
    ADD CONSTRAINT off_chain_vote_data_pkey PRIMARY KEY (id);


--
-- Name: off_chain_vote_external_update off_chain_vote_external_update_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_external_update
    ADD CONSTRAINT off_chain_vote_external_update_pkey PRIMARY KEY (id);


--
-- Name: off_chain_vote_fetch_error off_chain_vote_fetch_error_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_fetch_error
    ADD CONSTRAINT off_chain_vote_fetch_error_pkey PRIMARY KEY (id);


--
-- Name: off_chain_vote_reference off_chain_vote_reference_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_reference
    ADD CONSTRAINT off_chain_vote_reference_pkey PRIMARY KEY (id);


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
-- Name: committee_hash unique_committee_hash; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.committee_hash
    ADD CONSTRAINT unique_committee_hash UNIQUE (raw, has_script);


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
    ADD CONSTRAINT unique_drep_hash UNIQUE (raw, has_script);


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
    ADD CONSTRAINT unique_voting_anchor UNIQUE (data_hash, url, type);


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

