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

CREATE DOMAIN public.addr29type AS bytea
	CONSTRAINT addr29type_check CHECK ((octet_length(VALUE) = 29));


ALTER DOMAIN public.addr29type OWNER TO postgres;

--
-- Name: asset32type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.asset32type AS bytea
	CONSTRAINT asset32type_check CHECK ((octet_length(VALUE) <= 32));


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

CREATE DOMAIN public.hash28type AS bytea
	CONSTRAINT hash28type_check CHECK ((octet_length(VALUE) = 28));


ALTER DOMAIN public.hash28type OWNER TO postgres;

--
-- Name: hash32type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.hash32type AS bytea
	CONSTRAINT hash32type_check CHECK ((octet_length(VALUE) = 32));


ALTER DOMAIN public.hash32type OWNER TO postgres;

--
-- Name: int65type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.int65type AS numeric(20,0)
	CONSTRAINT int65type_check CHECK (((VALUE >= '-18446744073709551615'::numeric) AND (VALUE <= '18446744073709551615'::numeric)));


ALTER DOMAIN public.int65type OWNER TO postgres;

--
-- Name: lovelace; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.lovelace AS numeric(20,0)
	CONSTRAINT lovelace_check CHECK (((VALUE >= (0)::numeric) AND (VALUE <= '18446744073709551615'::numeric)));


ALTER DOMAIN public.lovelace OWNER TO postgres;

--
-- Name: word128type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.word128type AS numeric(39,0)
	CONSTRAINT word128type_check CHECK (((VALUE >= (0)::numeric) AND (VALUE <= '340282366920938463463374607431768211455'::numeric)));


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

CREATE DOMAIN public.txindex AS smallint
	CONSTRAINT txindex_check CHECK ((VALUE >= 0));


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

CREATE DOMAIN public.word31type AS integer
	CONSTRAINT word31type_check CHECK ((VALUE >= 0));


ALTER DOMAIN public.word31type OWNER TO postgres;

--
-- Name: word63type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.word63type AS bigint
	CONSTRAINT word63type_check CHECK ((VALUE >= 0));


ALTER DOMAIN public.word63type OWNER TO postgres;

--
-- Name: word64type; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.word64type AS numeric(20,0)
	CONSTRAINT word64type_check CHECK (((VALUE >= (0)::numeric) AND (VALUE <= '18446744073709551615'::numeric)));


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
-- Name: anchor_offline_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.anchor_offline_data (
    id bigint NOT NULL,
    voting_anchor_id bigint NOT NULL,
    hash bytea NOT NULL,
    json jsonb NOT NULL,
    bytes bytea NOT NULL
);


ALTER TABLE public.anchor_offline_data OWNER TO postgres;

--
-- Name: anchor_offline_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.anchor_offline_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.anchor_offline_data_id_seq OWNER TO postgres;

--
-- Name: anchor_offline_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.anchor_offline_data_id_seq OWNED BY public.anchor_offline_data.id;


--
-- Name: anchor_offline_fetch_error; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.anchor_offline_fetch_error (
    id bigint NOT NULL,
    voting_anchor_id bigint NOT NULL,
    fetch_error character varying NOT NULL,
    retry_count public.word31type NOT NULL
);


ALTER TABLE public.anchor_offline_fetch_error OWNER TO postgres;

--
-- Name: anchor_offline_fetch_error_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.anchor_offline_fetch_error_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.anchor_offline_fetch_error_id_seq OWNER TO postgres;

--
-- Name: anchor_offline_fetch_error_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.anchor_offline_fetch_error_id_seq OWNED BY public.anchor_offline_fetch_error.id;


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
    address_raw bytea NOT NULL,
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
    hot_key bytea NOT NULL,
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
    cold_key bytea NOT NULL,
    hot_key bytea NOT NULL
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
    raw public.hash28type NOT NULL,
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
-- Name: governance_action; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.governance_action (
    id bigint NOT NULL,
    tx_id bigint NOT NULL,
    index bigint NOT NULL,
    deposit public.lovelace NOT NULL,
    return_address bigint NOT NULL,
    voting_anchor_id bigint,
    type public.govactiontype NOT NULL,
    description character varying NOT NULL,
    param_proposal bigint,
    ratified_epoch public.word31type,
    enacted_epoch public.word31type,
    dropped_epoch public.word31type,
    expired_epoch public.word31type,
    expiration public.word31type
);


ALTER TABLE public.governance_action OWNER TO postgres;

--
-- Name: governance_action_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.governance_action_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.governance_action_id_seq OWNER TO postgres;

--
-- Name: governance_action_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.governance_action_id_seq OWNED BY public.governance_action.id;


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
    governance_action_id bigint NOT NULL,
    quorum double precision NOT NULL,
    deleted_members character varying NOT NULL,
    added_members character varying NOT NULL
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
-- Name: pool_offline_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_offline_data (
    id bigint NOT NULL,
    pool_id bigint NOT NULL,
    ticker_name character varying NOT NULL,
    hash public.hash32type NOT NULL,
    json jsonb NOT NULL,
    bytes bytea NOT NULL,
    pmr_id bigint NOT NULL
);


ALTER TABLE public.pool_offline_data OWNER TO postgres;

--
-- Name: pool_offline_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_offline_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_offline_data_id_seq OWNER TO postgres;

--
-- Name: pool_offline_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_offline_data_id_seq OWNED BY public.pool_offline_data.id;


--
-- Name: pool_offline_fetch_error; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_offline_fetch_error (
    id bigint NOT NULL,
    pool_id bigint NOT NULL,
    fetch_time timestamp without time zone NOT NULL,
    pmr_id bigint NOT NULL,
    fetch_error character varying NOT NULL,
    retry_count public.word31type NOT NULL
);


ALTER TABLE public.pool_offline_fetch_error OWNER TO postgres;

--
-- Name: pool_offline_fetch_error_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_offline_fetch_error_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_offline_fetch_error_id_seq OWNER TO postgres;

--
-- Name: pool_offline_fetch_error_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_offline_fetch_error_id_seq OWNED BY public.pool_offline_fetch_error.id;


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
    id bigint NOT NULL,
    addr_id bigint NOT NULL,
    type public.rewardtype NOT NULL,
    amount public.lovelace NOT NULL,
    earned_epoch bigint NOT NULL,
    spendable_epoch bigint NOT NULL,
    pool_id bigint
);


ALTER TABLE public.reward OWNER TO postgres;

--
-- Name: reward_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reward_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reward_id_seq OWNER TO postgres;

--
-- Name: reward_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reward_id_seq OWNED BY public.reward.id;


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
    governance_action_id bigint NOT NULL,
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
    address_raw bytea NOT NULL,
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
    tx_out.address_raw,
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
    tx_out.address_raw,
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
    governance_action_id bigint NOT NULL,
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
-- Name: anchor_offline_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.anchor_offline_data ALTER COLUMN id SET DEFAULT nextval('public.anchor_offline_data_id_seq'::regclass);


--
-- Name: anchor_offline_fetch_error id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.anchor_offline_fetch_error ALTER COLUMN id SET DEFAULT nextval('public.anchor_offline_fetch_error_id_seq'::regclass);


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
-- Name: governance_action id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.governance_action ALTER COLUMN id SET DEFAULT nextval('public.governance_action_id_seq'::regclass);


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
-- Name: pool_offline_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_offline_data ALTER COLUMN id SET DEFAULT nextval('public.pool_offline_data_id_seq'::regclass);


--
-- Name: pool_offline_fetch_error id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_offline_fetch_error ALTER COLUMN id SET DEFAULT nextval('public.pool_offline_fetch_error_id_seq'::regclass);


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
-- Name: reward id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reward ALTER COLUMN id SET DEFAULT nextval('public.reward_id_seq'::regclass);


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
1	504	1	0	8999989979999988	0	126000010012688214	0	7311798	60
2	1018	2	89999900531179	8909990086780607	0	126000010007837635	0	4850579	109
3	1510	3	177317803866686	8736227463993540	86444724302139	126000010004175263	0	3662372	146
4	2005	4	241965887466475	8607577730642780	150446377715482	126000010004175263	0	0	193
5	2502	5	319434087042260	8458528216432700	222027692349777	126000010004175263	0	0	249
7	3025	6	404019369206587	8309648246351381	286322380266769	126000009996243718	0	7931545	305
8	3517	7	487115852463255	8168215748458537	344658402834490	126000009996243718	0	0	353
9	4005	8	562263437349073	8038087319921971	399639246485238	126000009979358866	0	16884852	399
10	4502	9	636213842380840	7914679951944023	449096226316271	126000009979358866	0	0	456
11	5005	10	715360641900280	7787184670268273	497437651907517	126000017035313484	0	610446	499
12	5507	11	780772993191578	7683947292322047	535262679172891	126000017035313484	0	0	543
13	6008	12	845318150447083	7587062060789711	567595437339846	126000024331193848	0	20229512	593
14	6501	13	919671360665773	7466048613281531	614255694858848	126000024331193848	0	0	637
\.


--
-- Data for Name: anchor_offline_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.anchor_offline_data (id, voting_anchor_id, hash, json, bytes) FROM stdin;
\.


--
-- Data for Name: anchor_offline_fetch_error; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.anchor_offline_fetch_error (id, voting_anchor_id, fetch_error, retry_count) FROM stdin;
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (id, hash, epoch_no, slot_no, epoch_slot_no, block_no, previous_id, slot_leader_id, size, "time", tx_count, proto_major, proto_minor, vrf_key, op_cert, op_cert_counter) FROM stdin;
1	\\xbc08eff8efe06e69da94b956363895a7928b16b9912408d75ca643cd892dc5b1	\N	\N	\N	\N	\N	1	0	2023-11-22 21:19:42	11	0	0	\N	\N	\N
2	\\x5368656c6c65792047656e6573697320426c6f636b2048617368200000000000	\N	\N	\N	\N	1	2	0	2023-11-22 21:19:42	23	0	0	\N	\N	\N
3	\\x3910388138d2c6d36ccf02e807277120dc3bc6f47b4999d5b2684ec068836666	0	3	3	0	1	3	4	2023-11-22 21:19:42.6	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
4	\\x8931aca3013400a3f3d535ef8dc6543917985300ce00168553c97a0e696f7ff2	0	9	9	1	3	4	1570	2023-11-22 21:19:43.8	6	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
5	\\x82b9e467b0c1d3afa9b18eb52253d337caa29fc5aa0381417ffb3407cf29b6fd	0	11	11	2	4	5	1048	2023-11-22 21:19:44.2	4	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
6	\\xfe6884ed223951cf95a328d814b1e16789b7695b179c5fdf57a174e2c93ec7b8	0	14	14	3	5	6	265	2023-11-22 21:19:44.8	1	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
7	\\x53e297ce07e72e16e808a7dce7f3d78ef23745f3f42e14edfd55ac46cffc1004	0	18	18	4	6	7	4	2023-11-22 21:19:45.6	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
8	\\xf4ec6f311b8487f97742fcaf0e6b2e7f18371b66773446cfbe55e64201337cd8	0	29	29	5	7	8	4	2023-11-22 21:19:47.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
9	\\x0c76a57c6e8fab45fd6691cff5801c52f0a78dbf07867da14020b72f8c42f96f	0	33	33	6	8	9	4	2023-11-22 21:19:48.6	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
10	\\xe7ae552c5ada33d7c1e51b4c5070dac556ced4e859a750f54b25e6be5cb725b0	0	54	54	7	9	9	4	2023-11-22 21:19:52.8	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
11	\\x0a2116309c6f970ce73798b94306106009e37e62d292aac53491cbc35707f957	0	65	65	8	10	5	2170	2023-11-22 21:19:55	6	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
12	\\x2773f862ab86052116820d8f9c418b3139a9c704b62879193b83085176a46b8b	0	78	78	9	11	7	1809	2023-11-22 21:19:57.6	5	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
13	\\xd6eee17e24be38e038afab2d1ca34d2a291712da608cf8e707ed9fa38694bb44	0	101	101	10	12	13	4	2023-11-22 21:20:02.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
14	\\x9730622ba36ec37c3ffe5f4458a04c293777c067c34b02a65ac98221bd948bdc	0	102	102	11	13	6	4	2023-11-22 21:20:02.4	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
15	\\xdc6b8525f1c9e2df72db050e867a69f96c0ed6a2a4b230a067a9a483c5558932	0	112	112	12	14	9	4	2023-11-22 21:20:04.4	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
16	\\x6cb33ef1c39861fdabef1e66576af5b7c2acd0f6946d72ea7f39915c9d8fe01b	0	136	136	13	15	8	261	2023-11-22 21:20:09.2	1	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
17	\\xa073b033dc806e54a27d9127686f96667061751d200757c04c397e7f9998ac3f	0	142	142	14	16	8	4	2023-11-22 21:20:10.4	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
18	\\x4e2a53dc2811ce5d0871c3673467ac9feef0567c1208029cbade58ad586090a7	0	143	143	15	17	5	4	2023-11-22 21:20:10.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
19	\\x06a488c413a112ee5c91bf9ac68bf2350bccffd037709fd484abaf1905cd81f9	0	160	160	16	18	19	339	2023-11-22 21:20:14	1	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
20	\\xffc1d11cc28552b7aa37bd163eaac608bb5c258261771e6ab46c38bea33fc220	0	170	170	17	19	5	369	2023-11-22 21:20:16	1	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
21	\\xb7768045b6ea65704d549ced02f496eeba5c4c900f29b0aba9f8adaa8a60b5e6	0	173	173	18	20	8	4	2023-11-22 21:20:16.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
22	\\xbf85ccb8fdea004624e2510b489aef35831848eb6f59554520a27f6edeab276a	0	189	189	19	21	7	397	2023-11-22 21:20:19.8	1	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
23	\\x517fe323b78d67277c51816a7a909a89732f9e6f72c05a5a5ae9964db2b5840a	0	190	190	20	22	19	4	2023-11-22 21:20:20	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
24	\\x8d09401ef66a3ca274fda5144d399620fd5abd0982cf02e34fe373470c1e8092	0	196	196	21	23	7	4	2023-11-22 21:20:21.2	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
25	\\x2e9b753b743970406341f3a473ef21e002c436c4ce416a44bb1fa7e9019e8449	0	201	201	22	24	4	653	2023-11-22 21:20:22.2	1	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
26	\\xbc51ed902e9c1f03cd6f95baaeac7618bf23094fa6b79883ffde04bf203adf16	0	209	209	23	25	8	4	2023-11-22 21:20:23.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
27	\\xe35c6c5fd5f89bc446b77ad8a0101c3d42dc45aed82507347eef157a06f9c873	0	215	215	24	26	27	261	2023-11-22 21:20:25	1	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
28	\\x176aba747c3944a68ab50184ca4d6bddf9d31e2bd1a7c98fdc301d47240956b9	0	285	285	25	27	8	339	2023-11-22 21:20:39	1	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
29	\\x5540ccc508c48535c1c8df0f6d4ec7c2583aba8c20f70ab5fceb07da7a9d3d55	0	297	297	26	28	27	369	2023-11-22 21:20:41.4	1	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
30	\\xadcc9951ffb005b05ca17cf97788fb0928bb948936aa260688ec96746fd39896	0	298	298	27	29	7	4	2023-11-22 21:20:41.6	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
31	\\x185d8cdcd2059b77184e043fc1a3392449079a095cd6bc659d9149b955744525	0	326	326	28	30	13	397	2023-11-22 21:20:47.2	1	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
32	\\x76caa95ee794d5d5d1968795d670659ed6de59a9a9290a064b771019e5b1a523	0	328	328	29	31	19	4	2023-11-22 21:20:47.6	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
33	\\xa0884993a81feadbaf5ee0a021ae7bcda21df6bea262fdf8ac939ed2e1255d1f	0	333	333	30	32	27	4	2023-11-22 21:20:48.6	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
34	\\x710060b8b14b189628165d47b6c14294243fe5cff746b0009b323b7959952e96	0	359	359	31	33	5	590	2023-11-22 21:20:53.8	1	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
35	\\x7b04c7eeeff716455e9b1ea11a7fe42eb74061e750e0ab76b63ee2857c327408	0	371	371	32	34	3	261	2023-11-22 21:20:56.2	1	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
36	\\xa92265e5626d1f3be913a13b47a07dfc70d5d07bb4d8fd7cb906e576de1de272	0	375	375	33	35	36	4	2023-11-22 21:20:57	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
37	\\x660bae832ee2c837de582ac97e7a49c9add2c14c1deec72c7d40e588e019392b	0	384	384	34	36	8	339	2023-11-22 21:20:58.8	1	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
38	\\x8b874fb42d3b8d3478734676f5334e957f4b0f69dea2af5df6d91405481b7651	0	387	387	35	37	19	4	2023-11-22 21:20:59.4	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
39	\\x7051f1e630ce2e508005a337caac7559fd060b35b0939be00ea166452d26e65c	0	391	391	36	38	13	4	2023-11-22 21:21:00.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
40	\\x9bcdb4f7598dfcbab53f3cd4d16b52e1b176d04db0b4325589295899b1023397	0	401	401	37	39	7	369	2023-11-22 21:21:02.2	1	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
41	\\x91cbd1e85440278d0ca2d17957c99124fac5e584cf5e1df9273a3f5d72079ae4	0	403	403	38	40	8	4	2023-11-22 21:21:02.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
42	\\x832afca3100989b26f68b058c19467f749b0ec13d65df7779d19dc987dec96e7	0	413	413	39	41	27	397	2023-11-22 21:21:04.6	1	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
43	\\x077c784c2e1ab5ae10861d47aa7226484a984aee558034580c90ea7e65d620f0	0	416	416	40	42	13	4	2023-11-22 21:21:05.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
44	\\xc66b488b8394ff164a15f9abf498544de42548ecdcde96830d43ee3e582e57de	0	418	418	41	43	6	4	2023-11-22 21:21:05.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
45	\\xad85efbbc9bf93121e35da4bb4a1ad1e65d0f01fcc84065ed09ef7e6c54aeff1	0	421	421	42	44	7	653	2023-11-22 21:21:06.2	1	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
46	\\xa2a32dcdb86cb37f22fa9c4a31f4350134620c2e8316dda16de31e4027123771	0	428	428	43	45	19	4	2023-11-22 21:21:07.6	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
47	\\x2642b369fcf57a9f0540718467c783cf365d3ea99233aafdee6a83bf4cc6aa5d	0	432	432	44	46	9	261	2023-11-22 21:21:08.4	1	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
48	\\xc23e0ce693e2ec5263887fbc9e77b8a50879535ecad82bf7013b9b7d754b7b5a	0	440	440	45	47	9	4	2023-11-22 21:21:10	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
49	\\xe95da6a295f1ec7ef915aca0b34e8e8a6005d2db286dc2ee28036592d5a7e8fd	0	441	441	46	48	36	4	2023-11-22 21:21:10.2	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
50	\\x4e8ca14b8b04a58ea2a8adafb8f5b5e6763c31603c3bb57d8e4f0c721c694429	0	451	451	47	49	5	339	2023-11-22 21:21:12.2	1	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
51	\\x94ef879688b61aaa792a3f077e30390b8e5f1bf14677e62eca236024194d494d	0	455	455	48	50	36	4	2023-11-22 21:21:13	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
52	\\xe73e3656573fb1bdf734b059e80f881a71affe48eedfff6a76f484bb1a98e846	0	456	456	49	51	3	4	2023-11-22 21:21:13.2	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
53	\\x8055a6bcd000af4b1e049c5156efef0e81bb112176c0c4c6846c87ac9887b7bc	0	470	470	50	52	27	369	2023-11-22 21:21:16	1	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
54	\\xe77685e46afc0b23825ff49ca026dc609d84bee4cd38baaea61e0f112063c81c	0	474	474	51	53	5	4	2023-11-22 21:21:16.8	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
55	\\xabbcc6ff14cedfd907271bc4f04d637a3bc2f883aa952e216fdaf9ea09c9f947	0	477	477	52	54	4	4	2023-11-22 21:21:17.4	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
56	\\xcf81316c9ba151dbb50fc42a3837ce6d4cc7713cbce89cd80ea6590737e5cbd8	0	487	487	53	55	9	397	2023-11-22 21:21:19.4	1	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
57	\\xe7aa269bec91751f790487a2c9ed11c78dcb06ac9a052994c2e59a8b2d3b5d2b	0	489	489	54	56	6	4	2023-11-22 21:21:19.8	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
58	\\x1cf95a485cfa56dc7c83b6fdc3d946105154fdac513722a1240a27247bbb58d5	0	496	496	55	57	6	653	2023-11-22 21:21:21.2	1	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
59	\\xe9dc3aca06bdd08a9e25b09624625598c8df67ab98bcb13708a1cfc4c61959f0	0	498	498	56	58	19	4	2023-11-22 21:21:21.6	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
60	\\x6cac8a1480fa9b1968c4f528e152bab43e9509ec929f93f9698bfd3a5dcf0d4d	1	504	4	57	59	6	4	2023-11-22 21:21:22.8	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
61	\\x0a68fe1516a3396dca312fc824ee106bc1c919fcea309c8d81997054c36e9e92	1	525	25	58	60	3	261	2023-11-22 21:21:27	1	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
62	\\x613bf89647985d97797b633227f454fbb117f0a918bc3eecc7020a8b1d58bb53	1	542	42	59	61	7	339	2023-11-22 21:21:30.4	1	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
63	\\x8eb193d17b1f2cdd5cfdd619d4e7ec1dbf9ef9782755f74e2d1cb493ce55bf45	1	563	63	60	62	19	369	2023-11-22 21:21:34.6	1	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
64	\\xc5ef661605aab165eac6e6ac282e297281191f79b864ab5a16bd3d7f77580405	1	570	70	61	63	36	397	2023-11-22 21:21:36	1	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
65	\\xea782dce79740de9a8192a0658761974b738249734504731e4028088c588340f	1	574	74	62	64	4	4	2023-11-22 21:21:36.8	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
66	\\x557f5199ffbece63345f5bf3acc83a803250d1b864e7647062e63617d0090692	1	615	115	63	65	9	653	2023-11-22 21:21:45	1	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
67	\\x8dc2a5d95b268e689cb5fdfb73c7ebcc7a959da7b9640feacd08a92a28923bdb	1	629	129	64	66	8	261	2023-11-22 21:21:47.8	1	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
68	\\xef6f15448a571d35b2aa033a57b5cf97ce5d016c9efc8579701e124cfc89d30f	1	636	136	65	67	13	4	2023-11-22 21:21:49.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
69	\\x197c7db40da2da6d90c801988cadeb5566d0972bca15cdd8e7f8befac5216e86	1	643	143	66	68	13	339	2023-11-22 21:21:50.6	1	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
70	\\x1342316cb62d254353ab1b5588c87c71e64bee73588c55c96e00f81a5f77c2cf	1	653	153	67	69	7	369	2023-11-22 21:21:52.6	1	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
71	\\x5a36e74ccd07bc649184eb277e22ab708f222427650921d1ff4b2eda3583140b	1	660	160	68	70	36	397	2023-11-22 21:21:54	1	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
72	\\x87967d53937e1cd3cf18bfcb5fdfa29c434737cc1965f67ec42f73fd1f042454	1	661	161	69	71	6	4	2023-11-22 21:21:54.2	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
73	\\x49f4133656dad2b3a8e3692eb1ccee4e7ba96a1ae9ff59de4e2f7a48f79a7053	1	666	166	70	72	6	653	2023-11-22 21:21:55.2	1	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
74	\\x1d5bb8ba745966f1a1ad6947dbc7f8aa899b263af5c5303667eab951deb9d382	1	670	170	71	73	4	4	2023-11-22 21:21:56	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
75	\\x24fc40f100a18e2d7089cef4614c3db8edce9b5539b29c9eec63628e8903c88d	1	673	173	72	74	36	4	2023-11-22 21:21:56.6	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
76	\\x94562b05b2133f701379b12a3fca86bc9485d8ecc7a1983e9945c45f78db6808	1	682	182	73	75	19	261	2023-11-22 21:21:58.4	1	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
77	\\xb33d88d6a477925982b5a9eae7285a6bfaee1cf89466d187d521cdfc3c2d2ded	1	690	190	74	76	7	339	2023-11-22 21:22:00	1	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
78	\\x45d75239c340e8bb8ca6cbcdbf7c37e09066d028c89786df82956642bfd01175	1	691	191	75	77	13	4	2023-11-22 21:22:00.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
79	\\x08a7272d79af8c6be96128ef45d16ea2822032f37504d16beb31ad83e032a85c	1	693	193	76	78	9	4	2023-11-22 21:22:00.6	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
80	\\x3a8c79ce622180ce52e6aa9071cc86e5fe040c1e0ca0563aa37f95dbafc2dd7e	1	697	197	77	79	36	4	2023-11-22 21:22:01.4	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
81	\\xe245e8abc1b51453c3ca2a71b08b850bedbc536710597022bc8a317e275ef0c6	1	723	223	78	80	19	369	2023-11-22 21:22:06.6	1	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
82	\\x6bc9a307a7220b57e09ec413c9b70c7ae216664b77fa7f056334a4241839729c	1	727	227	79	81	19	4	2023-11-22 21:22:07.4	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
83	\\x1c7c3abd84a7350281fb77d2f428a20572cab7338fec10e9bb26cd0d923d130d	1	730	230	80	82	3	4	2023-11-22 21:22:08	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
84	\\xbae493664652d904dd0074a551b521379d8fcc38c321b59f67b9251854ab078d	1	752	252	81	83	5	397	2023-11-22 21:22:12.4	1	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
85	\\x0018546cc129d240ee59e9800a9aab57b76373a87fa6cc96a8907da646d46f3f	1	755	255	82	84	27	4	2023-11-22 21:22:13	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
86	\\xa1824cd16792df79172d067f4c5d3114d892053eefe48e8e593b04b0e7e30310	1	766	266	83	85	3	653	2023-11-22 21:22:15.2	1	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
87	\\xb1ba1a5b3f776292996263d73656346bb13ac612cdfe79e372d16708cc2ccadb	1	787	287	84	86	3	261	2023-11-22 21:22:19.4	1	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
88	\\x904497c7b7e50bbe67179562032965e0f261668f71da1de2809999809a260948	1	816	316	85	87	6	339	2023-11-22 21:22:25.2	1	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
89	\\xbf9621dc1a71f228b9265fa4e3dfb108ff77919bd54634b4df40f167eb9134ca	1	830	330	86	88	3	369	2023-11-22 21:22:28	1	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
90	\\x269ee1728123653509beec7433c85d9b9a2d106a6b87f794aa8ad2e93f76f213	1	834	334	87	89	4	4	2023-11-22 21:22:28.8	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
91	\\x781b22c0e95655519817eb6341a99915d95f6cb2a558183a4afc807f8435e817	1	837	337	88	90	7	397	2023-11-22 21:22:29.4	1	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
92	\\x8a455a8a5fa4bafc6fcbcff328c2f3ac32eff63ee6f52ef86f8dca549b9008f3	1	844	344	89	91	36	4	2023-11-22 21:22:30.8	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
93	\\x011a542e6951e1644b1e608dd372f25d0b66b01daf7db902e9314a8fadb9fad8	1	849	349	90	92	4	590	2023-11-22 21:22:31.8	1	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
94	\\xacca59a9fcbbb9d5c4e20f9c568664ee6c7e5cccb3871623ad78f31bab3b6731	1	850	350	91	93	36	4	2023-11-22 21:22:32	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
95	\\x5259a8d22179d157076c373b635ff4bed52acc31126ea304b23327c759c295c0	1	852	352	92	94	4	4	2023-11-22 21:22:32.4	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
96	\\x372c29cea5f4322cabcf322c035b982196ff67d8c569de371bbe7c139d50f41a	1	860	360	93	95	6	397	2023-11-22 21:22:34	1	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
97	\\xf5c7fdd44fe2e5cd2fe0f6f9b5e9731c0f7a87bf420fd6cf04e9646dc6f1a4b8	1	911	411	94	96	5	439	2023-11-22 21:22:44.2	1	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
98	\\x912822dabbeaaf976ed5d2de2f746156bf8a7283c9f7f5df41565d54cc79aa4e	1	912	412	95	97	8	4	2023-11-22 21:22:44.4	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
99	\\xf4af53522d1efbe629655133250526dbadf0909ba49325b948b70e63441266ab	1	926	426	96	98	7	261	2023-11-22 21:22:47.2	1	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
100	\\x26b9cee4f5c1263fd3c6e022431863b1e70206a633e93f74608b81dd3cb701cc	1	932	432	97	99	8	339	2023-11-22 21:22:48.4	1	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
101	\\xefa3b44c3c61b4bb2585c3a1cc2b49cf6c4f44ba02ea4ec73632fa484b844457	1	939	439	98	100	27	4	2023-11-22 21:22:49.8	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
102	\\xe05cfcd830577e05d7e852ada76607960478acb5f91e85a0fd658abcdabd3845	1	952	452	99	101	7	369	2023-11-22 21:22:52.4	1	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
103	\\xf625275975a3254592b280dee51b256215811929da5cacd165e163cee1734ace	1	956	456	100	102	8	4	2023-11-22 21:22:53.2	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
104	\\x9113b27000a3983b1340c423b3efdbd2d3724ec8374e81d5806dfb0feec8280f	1	959	459	101	103	7	4	2023-11-22 21:22:53.8	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
105	\\x0bd31044c546d3197480a7df8483d847b368cf77ff95ec81d5769a768366a212	1	969	469	102	104	19	397	2023-11-22 21:22:55.8	1	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
106	\\x08151a093f4a21123bd27e54d960402de7998f0e099e8f0d7b4cfead8c305824	1	988	488	103	105	9	590	2023-11-22 21:22:59.6	1	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
107	\\x400585ab935857a00ba2f0e6bc3049e7c3c64967572061eb87dfd4c4127a54cf	1	991	491	104	106	27	4	2023-11-22 21:23:00.2	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
108	\\x9ce10dc79d1d2bccf7fd31b44f28a48a435e46e0b7bb71071b6d0e964aac657c	1	992	492	105	107	6	4	2023-11-22 21:23:00.4	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
109	\\x071b6a0b9da9671130e1095fb3d1e3aeeb663bfe6c5da9e8cf1f496940bdd122	2	1018	18	106	108	7	397	2023-11-22 21:23:05.6	1	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
110	\\x64931c5e155d62e463c7da5e26fa0fa76741f63952f0c7bdb8fb75377e7f76c4	2	1031	31	107	109	9	439	2023-11-22 21:23:08.2	1	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
111	\\xa2c0367a51ca1f8f2670d5043ffccd8569e376f59220f0097cee3086315ab2d9	2	1035	35	108	110	36	4	2023-11-22 21:23:09	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
112	\\x4139f84340ce0e64593e4cc5b641d73589e19bd0f96ea112768f0d5cc461e14b	2	1038	38	109	111	8	4	2023-11-22 21:23:09.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
113	\\x83ab05b7fd660f2297d2c089c3fb6f940ae7516c40b331a37a5fe09b029451f5	2	1090	90	110	112	4	261	2023-11-22 21:23:20	1	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
114	\\xeed1c8b4a54a562f44ec37268b8e2308b57b2dab4097f5de1a46ad9fde0a3408	2	1104	104	111	113	8	339	2023-11-22 21:23:22.8	1	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
115	\\x3195b1009bed7616c98bb7f5893199d85a79fd5ad009609afcb4269b59c6184f	2	1105	105	112	114	13	4	2023-11-22 21:23:23	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
116	\\xac26558e7b21a9ce9f78c6e56a7356fed16d67a791f95abf7dfc5671283b0bba	2	1121	121	113	115	8	369	2023-11-22 21:23:26.2	1	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
117	\\xd33422dc727c926d77d980eaee04aabb845c530c7ed4dcfa9126bdd22630f94b	2	1140	140	114	116	8	397	2023-11-22 21:23:30	1	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
118	\\x1b9a5458b45099b65ce7f101a78281ba2af80f1bbdf262ad38abdd7299989f03	2	1158	158	115	117	19	654	2023-11-22 21:23:33.6	1	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
119	\\x729f1790e05e5b5677a8c047d2548aea7533675d7015005cad286617d5209ee5	2	1171	171	116	118	6	397	2023-11-22 21:23:36.2	1	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
120	\\x94d23b41d1ac103e25f5f0284fcac19652f67b27c0f9e332ed63ae244ee2b516	2	1178	178	117	119	27	4	2023-11-22 21:23:37.6	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
121	\\x11c218eaeb40f39b0ceeaf09a7079bb128667f696712a6eaa4a1dba6f94fea1d	2	1186	186	118	120	19	439	2023-11-22 21:23:39.2	1	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
122	\\x3022e1f3181d8cee36ff7df555436a471c9e2f013919af6a688ba0042236798f	2	1199	199	119	121	8	261	2023-11-22 21:23:41.8	1	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
123	\\x5b6b1314d32e5314b87eaa8d5df23c5596043c29e53497cb203d638f3c524099	2	1200	200	120	122	27	4	2023-11-22 21:23:42	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
124	\\xf6292b2cde240317958d848f8482e0e61e393344aa41582a38adaa1bb0564fe9	2	1202	202	121	123	13	4	2023-11-22 21:23:42.4	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
125	\\xa67bd8abb9c1e7eb4e1117bbdf44c3609d516b6b9bb95634fceffa2e0aea30fe	2	1203	203	122	124	3	4	2023-11-22 21:23:42.6	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
126	\\x6cc200ab950f2261fee6d7092a71ed1ed5a0f3d9db6ab7c85e25f3914875a97c	2	1231	231	123	125	9	339	2023-11-22 21:23:48.2	1	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
127	\\x05bdb6afd1fc1ec5e2567537600f41e90481ed85adde169cd336016ce1ea1a78	2	1234	234	124	126	9	4	2023-11-22 21:23:48.8	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
128	\\x1469068fef9e4adb9a267cdda69260f48586f5750b44f5532cacc5b3a0b8247b	2	1235	235	125	127	5	4	2023-11-22 21:23:49	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
129	\\xa95481cc3c3de045f0a9d01edc6ade846d47011774fffc9bcb0c9a2899c4ff48	2	1249	249	126	128	7	369	2023-11-22 21:23:51.8	1	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
130	\\xf46bd98e56d5f2cf7a5d0977327e89c60c3768d170d209dd2b8d42a3a150c08e	2	1277	277	127	129	7	397	2023-11-22 21:23:57.4	1	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
131	\\x86a494fff1d60e6d547cf3266322887c210f8a5bf4d19e2f7f380271839ac694	2	1298	298	128	130	8	654	2023-11-22 21:24:01.6	1	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
132	\\xa0c28e57f82fb39d8da1da7af1bfe8e63b8c4268ec3ae43714e9dd363a71d4eb	2	1307	307	129	131	4	4	2023-11-22 21:24:03.4	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
133	\\x422fbad7992cd69ab3df7864dc9f09c8ab72b717d98d2950571c313c258d2426	2	1312	312	130	132	8	397	2023-11-22 21:24:04.4	1	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
134	\\xaa8201388f1deb7f704fe63a1c595216d067b0b6da127f79580abec49a259907	2	1318	318	131	133	7	4	2023-11-22 21:24:05.6	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
135	\\x431116706d8717eee8ab5d8082972567407fccef297b85eb6d5e3be6789679e2	2	1331	331	132	134	3	439	2023-11-22 21:24:08.2	1	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
136	\\x6aee4accf1e173a280ef0e15d78d9ac4ef4a4d6f1780d859c02a9125cd0365bf	2	1335	335	133	135	3	4	2023-11-22 21:24:09	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
137	\\xaa60e35f5c70e38678a4da3651b4171a5cea98885b12d156c28b837140e63ab9	2	1346	346	134	136	27	465	2023-11-22 21:24:11.2	1	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
138	\\x50d022fd83b658f377e6d9b5719076025f06e7ac48794e9e6a97b40851816919	2	1354	354	135	137	36	541	2023-11-22 21:24:12.8	1	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
139	\\xb4ec005a7c84e1fccfd96586fafc25d7a937d097e51f125b621b7be2fc62ff7a	2	1372	372	136	138	6	1751	2023-11-22 21:24:16.4	1	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
140	\\x240c81625eaf020f6c670f8659095986158e3386d9f7b009f63833900a3b4149	2	1417	417	137	139	5	669	2023-11-22 21:24:25.4	1	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
141	\\xc9a37cebcd4664c632aa089c8ddf64abbc662d57cff5bdbeb1f28509a2a13a9e	2	1433	433	138	140	8	4	2023-11-22 21:24:28.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
142	\\x05bf3722fe3cda66275f87640101b605f65617bc97db5e0e1180fbbfb83993c4	2	1444	444	139	141	36	4	2023-11-22 21:24:30.8	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
143	\\xf8bc35a3c58e5319d7187bd5f97ab6a0f6906d72400aad57aeeed971f7a9b5a0	2	1446	446	140	142	27	4	2023-11-22 21:24:31.2	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
144	\\xd9972ccd11952bd2774b70e0b6d28831b70ff30c639ec14b4e97245bd79bcc39	2	1450	450	141	143	4	4	2023-11-22 21:24:32	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
145	\\xd0c8efeb74b55a7ca07b8ea2498cb05e270774f842cf095f2323f16780e30a49	2	1485	485	142	144	19	4	2023-11-22 21:24:39	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
146	\\xa0f892e3e1c6d1891bf7a2ff807f9b18fdaf1b9e0d358256b78841cc75e37f30	3	1510	10	143	145	13	4	2023-11-22 21:24:44	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
147	\\xa96a2505792f716fc352d60003af001c4a83295175068def86b521e4aa44885b	3	1512	12	144	146	7	4	2023-11-22 21:24:44.4	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
148	\\x6330141add2271f45ff15a82a3b489ea33d91985002f7f35e5b63c3d37eee917	3	1522	22	145	147	8	4	2023-11-22 21:24:46.4	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
149	\\xe8ebf0da1f8687ed6bfdd5aa9e2265f62ef6eb1f804389b390c4dfb73809be94	3	1526	26	146	148	4	4	2023-11-22 21:24:47.2	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
150	\\xd1b31126d2076b292fb7fc71c43790269a6ad8af1dd35df090f7688822218677	3	1540	40	147	149	7	4	2023-11-22 21:24:50	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
151	\\x6f2d6ff012066e9318f5cc93a62d5074f937955273d28f1e7b51e7d7e46f580b	3	1583	83	148	150	13	4	2023-11-22 21:24:58.6	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
152	\\x5c27f44ba6732c43fa8b7822987eb66c859c0900fdeb9740f7b336acc63529a8	3	1592	92	149	151	36	4	2023-11-22 21:25:00.4	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
153	\\x38d40fc3e8da936de328cc326362c3944aefdbb9dece79161c01530edea33c3c	3	1597	97	150	152	6	4	2023-11-22 21:25:01.4	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
154	\\x3ac7d5b61ca71c57c1b2a07da6d5721a6dd74fcbd264bbfa8c21357f055b3032	3	1612	112	151	153	9	4	2023-11-22 21:25:04.4	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
155	\\x561217a5284e5206e26a1fbe50c18973e5bc5439edca37e2aecd58dd5eb503ce	3	1616	116	152	154	4	4	2023-11-22 21:25:05.2	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
156	\\xa8c6fc6a4167443acf636359939cc85b3baa5b70bdf1cde92604b8aa2bb67b37	3	1618	118	153	155	13	4	2023-11-22 21:25:05.6	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
157	\\x205c5139756f4e40ac0809c54dc7deb4f3153e5fd19d36a210610a37d685d5f7	3	1626	126	154	156	13	4	2023-11-22 21:25:07.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
158	\\x2d8766bbee85e706f203c4b1e20e9e5354a4e4a4f287b9752276710a172ac3d7	3	1643	143	155	157	13	4	2023-11-22 21:25:10.6	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
159	\\x3d67853fb7b526b781e32a7434b83ffc8f25a1f1a009be80082dfc8fa21fd6fa	3	1648	148	156	158	5	4	2023-11-22 21:25:11.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
160	\\x8d53f5942fc228a827fe9959433f519caca6c9983b441119abf796c724613050	3	1667	167	157	159	9	4	2023-11-22 21:25:15.4	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
161	\\x1529ea68903055c3deda30d2b2c49d2cb50b909b060227a3dfce71d21306c342	3	1668	168	158	160	13	4	2023-11-22 21:25:15.6	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
162	\\x54e01a978b4e504adc1a5bb672a418cd6bc0b4282944c303d8b0a02a0cf1c81d	3	1678	178	159	161	6	4	2023-11-22 21:25:17.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
163	\\x88e88c5b37f044519106647479b087ff8e7a937d67b5c146b3a67c7cb00c10a4	3	1695	195	160	162	27	4	2023-11-22 21:25:21	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
164	\\x9630ef8e6607c4b3d677a47ceb5adba48a9915b3f5eae87ec5e4c58480960f1f	3	1733	233	161	163	4	4	2023-11-22 21:25:28.6	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
165	\\x47aa36b221b48e963a0c72714228bc8cc1b7e970f2fd1eeaaaac7db53ba9ba68	3	1745	245	162	164	5	4	2023-11-22 21:25:31	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
166	\\x2496d14bd4a4b33e184cb86cb9010f8b5fca2354924a453a32ec9da1f912942e	3	1747	247	163	165	4	4	2023-11-22 21:25:31.4	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
167	\\x875761cd744040898b4ef0c4caf8baa26099d434ddd6c1effb530c05e4168d07	3	1748	248	164	166	9	4	2023-11-22 21:25:31.6	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
168	\\xfab53af27ddccc870d0eff49148659659567b2f7bf8f042d353e4a7086b1365e	3	1752	252	165	167	8	4	2023-11-22 21:25:32.4	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
169	\\x8945b343bc64f16bb75ea99715317394fbabedc40bec67d33456cafe5889aae5	3	1783	283	166	168	7	4	2023-11-22 21:25:38.6	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
170	\\x227f80ae7a449a7591cdc8129a560d63492d9da6d772906ba150f3c7153397ee	3	1786	286	167	169	3	4	2023-11-22 21:25:39.2	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
171	\\xb345eeba2e59828fc6ffd6e45ae7c7feaa5fbe6f049d7e3b38f84a2883433885	3	1799	299	168	170	13	4	2023-11-22 21:25:41.8	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
172	\\xe030bec876d5cecd4b9dfd398d31ceebb5c7835ff8365cc28e7c380448cb5820	3	1821	321	169	171	36	4	2023-11-22 21:25:46.2	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
173	\\x9504d24e3d417eb934f9995abf3759f6af40c6acd707ed1c05530b2dcffe96c9	3	1828	328	170	172	36	4	2023-11-22 21:25:47.6	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
174	\\xd6c187e45b7239163dc2fe4482537ef2948ffcbd9fe9471618146ba65bd25c62	3	1835	335	171	173	13	4	2023-11-22 21:25:49	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
175	\\x4814ac8559c593207af6e46933ac477965b0f0c07b6c8c58d5de47f5bd6a7b23	3	1837	337	172	174	3	4	2023-11-22 21:25:49.4	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
176	\\x0101bcb7c5fb0e31c81e7a543091236db22314f1c724ab7355a1daed0ee9d4d6	3	1842	342	173	175	36	4	2023-11-22 21:25:50.4	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
177	\\x8722e7eb1d9a971e02eb50f3bb805a98ed8dc4ac2a8ec67befc3cda5d1a3d4fd	3	1861	361	174	176	7	4	2023-11-22 21:25:54.2	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
178	\\x5bbe4ae8a780ff9fe8f7ac269d878ddda27fe1e236cf540eed04c62809976ecf	3	1865	365	175	177	9	4	2023-11-22 21:25:55	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
179	\\x0df25bb7b34ab96195c0b39e03490ffdaa7207f3717930ef6f232127f0896a2d	3	1866	366	176	178	7	4	2023-11-22 21:25:55.2	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
180	\\xe1f7d92cd9f3e90e64ca7af089241b308025ae48d4a715e2378e64c049582a61	3	1869	369	177	179	5	4	2023-11-22 21:25:55.8	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
182	\\x7a658386ad5bc8fcf1f43325f77abfd863bc06a87150b6990cbabf8cf9565d29	3	1871	371	178	180	5	4	2023-11-22 21:25:56.2	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
183	\\x446eb0200c1137feec442dfdeb261d4017fdcb21dc0718b365c3d62e366e3113	3	1907	407	179	182	8	4	2023-11-22 21:26:03.4	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
184	\\x0646f776a55897cc2d5e3654b8500c5d34ef9fb39090db702e13f888fdc99d7a	3	1918	418	180	183	5	4	2023-11-22 21:26:05.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
185	\\x3aacc456b800df3bd4af55eced14cb85982931645c443d691364935a1d92d1f5	3	1932	432	181	184	13	4	2023-11-22 21:26:08.4	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
186	\\x85dfd6db43e2089ad3caedf7ed61d298d6f5b7a353630a1b95927f3e406859bd	3	1958	458	182	185	8	4	2023-11-22 21:26:13.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
187	\\xa172ef93c856afd8b5c919affd572fc421c50e4bf3f5734479285756f9e37816	3	1960	460	183	186	36	4	2023-11-22 21:26:14	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
188	\\x0dcbe90a3ed8e248a36568809fac924eb1e270e459050efc483c0bab4501674d	3	1965	465	184	187	8	4	2023-11-22 21:26:15	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
189	\\xfffe15dff0100ba1047be078febbfdebf3d204bfcca95cc953fb78c2c6c4dff7	3	1978	478	185	188	3	4	2023-11-22 21:26:17.6	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
191	\\xc97513b9435bf18f91dc79ee7b7456582a0ff1999fd05366b6ffd7e2f8a17b6a	3	1979	479	186	189	19	4	2023-11-22 21:26:17.8	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
192	\\xc1b5afe75808d32358d0920c84775ef4fdd52fbde74dbbd01d386a029baffc16	3	1985	485	187	191	8	4	2023-11-22 21:26:19	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
193	\\x81347d66d7be0463f086e25b1c117a4e135d9e40fd403455808bc8b1ae8291e5	4	2005	5	188	192	4	4	2023-11-22 21:26:23	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
194	\\x803cb374a32c7fd80024769778265feca6a4dcae694a127e28c5b626f50ef879	4	2008	8	189	193	8	4	2023-11-22 21:26:23.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
195	\\xb74906ff9fc9cb77d40f52757a9aa46578581b7fd36bfa3b8707300d6bc6b0c0	4	2017	17	190	194	27	4	2023-11-22 21:26:25.4	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
196	\\x1f7b7db6adcd5704c6a96373a6fc28a79eb6c3858040ebe8a078323bf9ab7f8c	4	2018	18	191	195	6	4	2023-11-22 21:26:25.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
197	\\x64dc32fcd823204fe5a9284d346347cb89c6952d401cac18f69ef7589d3fe9e5	4	2022	22	192	196	36	4	2023-11-22 21:26:26.4	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
198	\\xf20c82dfbddefc385ad55e90856f9cf6878a9630a44b6f72e10d76116fd17151	4	2048	48	193	197	3	4	2023-11-22 21:26:31.6	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
199	\\xf0037e991fe1d9398082ea1bc94ed58d0a5b48cf63c785f50a6e1a1969c779a0	4	2076	76	194	198	8	4	2023-11-22 21:26:37.2	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
200	\\xb57d6f0ddb419b36c4d08adf9febdb68cb0bd0068cee93430f931bdce81275c0	4	2082	82	195	199	3	4	2023-11-22 21:26:38.4	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
201	\\x34b69beedb2ecbd05910940e51aa71e46acb21edb76acfce33003d8999bcb2dc	4	2086	86	196	200	27	4	2023-11-22 21:26:39.2	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
202	\\x0c5c6627f9a103ce8a67acc0c9a1067f35d5d19bb72054d30361bfd462a1155a	4	2100	100	197	201	7	4	2023-11-22 21:26:42	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
203	\\xfbc66b50813d6f67e7c3a669ca6ade09f6a74bbff56362642faff80814d23c6f	4	2111	111	198	202	8	4	2023-11-22 21:26:44.2	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
204	\\x3f72aca48fd124f5e6e7fa4c780473d7312548e175b3acee270833918a88df9a	4	2112	112	199	203	5	4	2023-11-22 21:26:44.4	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
205	\\xdeb28f6109ed323c889a9238fe94cc0e412e48d73c5ef63f3adcb23e5a4d5a7b	4	2130	130	200	204	8	4	2023-11-22 21:26:48	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
206	\\x35bd926fb2311657f84065b7c6186f5f7c2d0ac4a7dd1dfa5adb9f43fadafa8f	4	2139	139	201	205	6	4	2023-11-22 21:26:49.8	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
207	\\x5fd46922fb57c9b0fcfdeda9b6775430a24bf3c7c203e9e537b8e074d0735cc3	4	2168	168	202	206	7	4	2023-11-22 21:26:55.6	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
208	\\x153e74c675b3eac71b048bde51e144da002a093c709469f9a9f514532e4daaeb	4	2192	192	203	207	5	4	2023-11-22 21:27:00.4	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
209	\\x203a9511602914bbf1e169796f3634bac9d9c4f7b82b387136db859361666bbd	4	2200	200	204	208	4	4	2023-11-22 21:27:02	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
210	\\x12d69448d8128865ec3533db40a0d575c56189ea82246a358cafb809c28374b4	4	2201	201	205	209	8	4	2023-11-22 21:27:02.2	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
211	\\x9ffd9604322a928b824d1b3b72cfbf0959525fc105d20a1beca3d9435dc1a2a5	4	2202	202	206	210	3	4	2023-11-22 21:27:02.4	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
212	\\x39a2bfb40a851bd1e351bf3684caced2972dc99d3c8975bf4bfefed629d330c4	4	2204	204	207	211	8	4	2023-11-22 21:27:02.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
213	\\x1017001c88194db7a58ec944478705dc344c6dd8d2c71bc295f3e194dcdc124f	4	2209	209	208	212	13	4	2023-11-22 21:27:03.8	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
214	\\x08130e2ea87bdaf03506aa5a34f2673898139a574c9e48b58bc34b0f907b4745	4	2214	214	209	213	5	4	2023-11-22 21:27:04.8	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
215	\\xeb3f0e9d1e2a91793efff1062a735d25017ce4d708e2297820f8f06337b6e5ea	4	2225	225	210	214	6	4	2023-11-22 21:27:07	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
216	\\x80fe9c0b8035d3bd0ae7fe056c1770f1ecabe7a6e0cf44e24b1d791246c01d0b	4	2231	231	211	215	4	4	2023-11-22 21:27:08.2	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
217	\\xee48dfcc8b6afa27d98c1a8ffbc0054f3b93e2a64dfc95a5da3fe6d7e2873363	4	2234	234	212	216	5	4	2023-11-22 21:27:08.8	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
218	\\x786cb7f0e81fdd2a85bb3d9dd660fe8a5a2540286ebf828b94c5fa1bbb93d324	4	2240	240	213	217	36	4	2023-11-22 21:27:10	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
219	\\xbd9862eed48ca7e84f40e71677deab387b6c191fbfd11bfc5906238b21cafe6b	4	2266	266	214	218	13	4	2023-11-22 21:27:15.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
220	\\x8b6bdf862b9a70787e391527e39187d8cc1999434b90cbf6a505863a60b903a6	4	2276	276	215	219	13	4	2023-11-22 21:27:17.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
221	\\xd5ede37d10ac51c8f78ff3958147953b66d3600c48ffc0d48188ff7b4f0cde6c	4	2277	277	216	220	7	4	2023-11-22 21:27:17.4	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
222	\\x4689e3c10c7ad8fe6dc5520eb34cdef2c7c89f765a8e95649681ec6ca8f13fb6	4	2301	301	217	221	6	4	2023-11-22 21:27:22.2	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
223	\\x61975b9094e7cda755b041948ee360528500ed368cff4fd84b1bb88db57b3e7f	4	2305	305	218	222	13	4	2023-11-22 21:27:23	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
224	\\xe21a1f6c6661d325a4a18993e15ec1b5c3c7532f4171b3d0877eaaee7f3ae3e4	4	2307	307	219	223	4	4	2023-11-22 21:27:23.4	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
225	\\x7a7d8a5f56ac35431149dde7815891bd71b04069918b1db44022723ddfb4c2bc	4	2313	313	220	224	3	4	2023-11-22 21:27:24.6	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
226	\\x2215a0b7845caf89c3d05bd32f414085cc5118c3060d1a96a4c4f4e3df79d42c	4	2318	318	221	225	7	4	2023-11-22 21:27:25.6	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
227	\\x23ceee602d116fb2550b20e40380b68f39839dda1e9d628b99c4f2b2c46c6d41	4	2324	324	222	226	8	4	2023-11-22 21:27:26.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
228	\\x24ab452c246707b5f96d75cc3ca0b70215ddb4bce667d6914593149b1ac0e1d6	4	2346	346	223	227	7	4	2023-11-22 21:27:31.2	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
229	\\x83b1249353de9bb15597b4fda1160e1ecbf31cc81800263825ada4b607bd95a0	4	2349	349	224	228	9	4	2023-11-22 21:27:31.8	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
230	\\x573e1becbfd10851920abb448303e444643b9ccd86e4476436e4cb291d0a8ad3	4	2356	356	225	229	19	4	2023-11-22 21:27:33.2	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
231	\\x79175e259c0fb7b426c6ba1bf1910f7ed5b9e89796fa4b2d9040af6b428f409f	4	2360	360	226	230	7	4	2023-11-22 21:27:34	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
232	\\xc85731e508a0a1ba37a9366d7eec9f10aec15bf203f8a3472a66f99c0c545557	4	2370	370	227	231	19	4	2023-11-22 21:27:36	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
233	\\x9ca6644bf8a1ff407a67eae959135286f714186d6c97f52bd53d72e9243dde73	4	2371	371	228	232	19	4	2023-11-22 21:27:36.2	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
234	\\x9e44fec1793e8b946ec6d27f1b81c40ed0022a1e2362031a7c784b33b2482572	4	2373	373	229	233	3	4	2023-11-22 21:27:36.6	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
235	\\x12ffceabb1d9d7120db58cea9c46aa27f2911cf9ac4b3dfc46db238f62b60218	4	2376	376	230	234	36	4	2023-11-22 21:27:37.2	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
236	\\xad636b92689b13f126f44c57f72fd4be25823a60e9aaa446d9fa0259b8789fdf	4	2383	383	231	235	6	4	2023-11-22 21:27:38.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
237	\\x1b56f8c029c51cdbece8351e39315ca4a34427773a7e540ee768d809e69e8e4a	4	2386	386	232	236	3	4	2023-11-22 21:27:39.2	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
238	\\x1325f9c1af096d714e33c452ca08b30e166f1c48e59775b77068f375abb04f40	4	2415	415	233	237	19	4	2023-11-22 21:27:45	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
239	\\xebdd33b12721b18d5c2b585f081a9c6867a38a7b6cdab845d501ccf6a407521a	4	2416	416	234	238	13	4	2023-11-22 21:27:45.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
240	\\xa50d40607c0378d404b0aeeb9ca99b594c766b265efe02d6868dbcc5f89991aa	4	2420	420	235	239	6	4	2023-11-22 21:27:46	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
241	\\x2a15bd97747c02517933e77e01aca3f0ddd54a1e5ea6144808dbf962f48307fa	4	2439	439	236	240	19	4	2023-11-22 21:27:49.8	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
242	\\x8d490ac9c79693b415486c77c52d93d1434e5011bef3e203fc3434e9754f3948	4	2443	443	237	241	8	4	2023-11-22 21:27:50.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
243	\\x315bd1d79c78d92a9b0199bdc6ea3d64442c3e438b162aba129731b1cee96b5e	4	2451	451	238	242	19	4	2023-11-22 21:27:52.2	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
244	\\x07ab43dad8c86ad99f74e46e2e8e8ac1c4afa41923f5c332832def2656eb41ac	4	2453	453	239	243	9	4	2023-11-22 21:27:52.6	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
245	\\x3cbc354d6b0b9987e3bf06641b0b3b42d6f3fd7768e37976eaab297d3326b693	4	2460	460	240	244	36	4	2023-11-22 21:27:54	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
246	\\xed08d41cde57680f4cea0abc43aea151f1718c8a4a5f2e26f01b1b0847161520	4	2474	474	241	245	7	4	2023-11-22 21:27:56.8	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
247	\\xb3b779aec7a41dde29760fe5a0723ba12b2087a0d9944c78e7f5d825a13979cb	4	2491	491	242	246	9	4	2023-11-22 21:28:00.2	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
248	\\xd2ebc4aa5e8e3a8bdda881c19b62c9a49477d749f4115bd3bb9c2aee1494dd96	4	2499	499	243	247	7	4	2023-11-22 21:28:01.8	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
249	\\x546ac22d479eb44ae459924a953cdbdff89561c2ee541b27ec912487e8e41e98	5	2502	2	244	248	6	4	2023-11-22 21:28:02.4	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
250	\\x7cfe6e09b2e29ae2549c9a1813184e51d0e0925a73aa4cae116b07482ee87279	5	2508	8	245	249	13	4	2023-11-22 21:28:03.6	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
251	\\x5467dbb592f55a2b16604b7e38835a5751a758c1a5db16b3f1602b20a469c675	5	2522	22	246	250	36	626	2023-11-22 21:28:06.4	2	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
252	\\xb58950fb8a2f4626761731696529d10370a789e266ea979c937f7d322cb2e158	5	2524	24	247	251	4	4	2023-11-22 21:28:06.8	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
253	\\x464339e7c1549d13940fd29ebcb8dfdbbf2b6a5e6730fab18d3ee6a12caf617d	5	2533	33	248	252	9	4	2023-11-22 21:28:08.6	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
254	\\x8ce3956e7281286039a2a1bbda34496180e7366b9bfb4e683095c9bf95c32031	5	2541	41	249	253	5	4	2023-11-22 21:28:10.2	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
255	\\xd0bbd126d72d0a27a3654db9e472cf92d2409c34cecb581c95c43feb6b00d937	5	2552	52	250	254	19	4	2023-11-22 21:28:12.4	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
256	\\x26ca575addac4aed096030e711fb30605da62149d604823a4633b8a0e9a8ade1	5	2554	54	251	255	4	4	2023-11-22 21:28:12.8	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
257	\\x0a8cc50a4a23be8e12674865931ad42da7a844a5f1420301b9fe176645a29081	5	2559	59	252	256	3	4	2023-11-22 21:28:13.8	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
258	\\xfa6cb7737c727ee1a3827943f332a0bb028791e5b4533ab4f8aabc16923b4d50	5	2566	66	253	257	19	4	2023-11-22 21:28:15.2	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
259	\\x3a58139ffbb1603b98fc894298dae5b27a35a57e4bed238443b1ecb379dacaf0	5	2571	71	254	258	13	4	2023-11-22 21:28:16.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
260	\\xaec6691935ec7802790b4cb13fbadf8f60db6e4417fafe35acbc1ceaa4b5e124	5	2610	110	255	259	5	337	2023-11-22 21:28:24	1	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
261	\\x580252f017723a90b95fe0abf90ba4ebeac80ffb21ded317f8f2f046b07f4ba3	5	2611	111	256	260	6	4	2023-11-22 21:28:24.2	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
262	\\x8707933f856159916a4430b4c356b0fb11e8eb8d85f5b7f0e879789dbb8e911e	5	2620	120	257	261	4	4	2023-11-22 21:28:26	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
263	\\x28ce699a839dc2284f0181b3e6f384957639a52a213ce153971c2a9f7469e99a	5	2628	128	258	262	5	4	2023-11-22 21:28:27.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
264	\\xc3104dccf28e5dd4ad0906a54a2eb401b99447d36a2805b6cbf0b5c29dbc4d43	5	2632	132	259	263	7	329	2023-11-22 21:28:28.4	1	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
265	\\xfb2ef872acef3d3beaf069964532c2b73c443ff184cf73a5d8f6d187b1f3e6f0	5	2635	135	260	264	8	365	2023-11-22 21:28:29	1	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
266	\\x9a9fb637cb9829c4b222e42e3b0b130ab5c886e1fd2b4812691e0c9808cee9c9	5	2636	136	261	265	27	4	2023-11-22 21:28:29.2	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
267	\\x75b40bc6d204c05675678e225f054bb7c220190fbd150654034e165a32281fcf	5	2654	154	262	266	6	293	2023-11-22 21:28:32.8	1	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
268	\\xa58c979108aa6b48de286561140fccecc2a79a9f8170002fde4ab3ab17d0d5c8	5	2667	167	263	267	6	2403	2023-11-22 21:28:35.4	1	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
269	\\x875007994d7aeae50dcf5ac58b44d62618a2619fb27de9f0acae5cc59d54b709	5	2673	173	264	268	5	4	2023-11-22 21:28:36.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
270	\\x2500b75014fcea8e9149526965e0696c4f8e7bdd2bba7d1e32d03523d967719a	5	2679	179	265	269	6	4	2023-11-22 21:28:37.8	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
271	\\x9920081b0afeb4be92f1fc33be85bfc2cbe817a4a5eea5aad6f9c54701a3cb62	5	2683	183	266	270	36	8200	2023-11-22 21:28:38.6	1	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
272	\\xaf4a11b3de91af2a794ef8c31cb48eb5dab224f9181d5c34b7fe41ec35994b25	5	2689	189	267	271	8	4	2023-11-22 21:28:39.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
273	\\x41c2b99969b0d7cb3d342ba69e786df92de52ab9ce2cc86d06b44d4507142c36	5	2697	197	268	272	36	8410	2023-11-22 21:28:41.4	1	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
274	\\xc6da3e9c60d6e6db6894e9d8efe0ce9b30013228e07dafc8a64744169f851142	5	2700	200	269	273	5	4	2023-11-22 21:28:42	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
275	\\x03fc9b0c83fb05bf8b79a246c233adb8b1f3a7692607334632c831f19cb8251c	5	2707	207	270	274	19	4	2023-11-22 21:28:43.4	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
276	\\x9cdcd588876067220ab728784743ca2abddd0c112be93ddc40e19667e2766d0f	5	2710	210	271	275	36	4	2023-11-22 21:28:44	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
277	\\x153586c2fd7a51c00e73d22a9114dd17fedb8ad7be9c6991998ac350b1e1a1d9	5	2729	229	272	276	4	613	2023-11-22 21:28:47.8	1	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
278	\\x8c1ea5de1028e498eb03be16937a7f4d4a2448b8e9e250a2021f71ea45cb0789	5	2733	233	273	277	19	361	2023-11-22 21:28:48.6	1	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
279	\\xd85b931185eeae4f6f54fb388473d0b1c086b9f4669a50bbc4827d9b395d020d	5	2744	244	274	278	7	4	2023-11-22 21:28:50.8	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
280	\\x02876bbd571c9b818256869dc8f03316d6f1ade5a5408a33733c78c3f0d50a57	5	2751	251	275	279	19	294	2023-11-22 21:28:52.2	1	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
281	\\xd138a2dbd26692b8b24be04ae357ebb8edf6ca2f90fe6b1d5cfa3fea940cf1fb	5	2752	252	276	280	36	4	2023-11-22 21:28:52.4	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
282	\\x75ad03371068f353efa3f0c3c21ed65261572117012ea6455bfd46d2b01cdcab	5	2756	256	277	281	6	4	2023-11-22 21:28:53.2	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
283	\\x92f0f0638ad2b18b8dd8038ccd351f32caad58252e4b76dc5fd969fd16ddeb79	5	2765	265	278	282	3	4	2023-11-22 21:28:55	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
284	\\x1d4cb75e2c8790b8bf6f5e2e048d06771061412b6e9be4d32612d2c75f5d5f41	5	2767	267	279	283	3	285	2023-11-22 21:28:55.4	1	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
285	\\x43abe575769f102e8ef605d8cd3c0da74c064afbaee434e951cf9e8889032294	5	2783	283	280	284	9	4	2023-11-22 21:28:58.6	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
286	\\x1b5277c7ff8ca578e8d5268a0ea0e2b9ebcf7377254c7fd4e7004c46baa9c1c3	5	2798	298	281	285	3	4	2023-11-22 21:29:01.6	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
287	\\x93b4a098f04889e4c974f32feb5c252594920b232cea00de01de261eccab5838	5	2839	339	282	286	9	568	2023-11-22 21:29:09.8	1	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
288	\\x73026aae511118ebcf5ffaecde3b8a33bc4ec8d370af26d11b6ab8c2eb4cf81d	5	2840	340	283	287	9	4	2023-11-22 21:29:10	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
289	\\x454a3695e5e4225334f8f48d2ffd8cb319745c8254edf52bf6e12a782127edc4	5	2858	358	284	288	13	4	2023-11-22 21:29:13.6	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
290	\\xa04b61abee09081fa3a080878398509047d51a45109d706860ea2702be2f2a11	5	2859	359	285	289	9	4	2023-11-22 21:29:13.8	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
291	\\xde2948f76709c8d60fee709accc32837b5efa5df6fd03e93f8bdd146cedf9e9e	5	2868	368	286	290	6	4	2023-11-22 21:29:15.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
292	\\xe73ababbb1c52bb1d32bf8b4d1a40d0ffa4bf5092e622e91831f92a5a4a4a7d3	5	2873	373	287	291	9	4	2023-11-22 21:29:16.6	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
293	\\x2324d06ee47aaf5055ab2f8444677781e55cd1d68e54193e3a5917429cb64e8f	5	2887	387	288	292	7	4	2023-11-22 21:29:19.4	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
294	\\x1a958569f0514efc9355552b778c3d7a59c7a749acc32a4824b3be4b8ef9910b	5	2895	395	289	293	5	4	2023-11-22 21:29:21	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
295	\\x09a62f4630ec0c3b942aaea1f15d7feb08615d8b093f2c5d73f4f7d3c08ed5f1	5	2912	412	290	294	13	4	2023-11-22 21:29:24.4	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
296	\\x4805e0265469a92092603cc40dc225538173cc2feee9a768de42ef08cd1b8fa3	5	2921	421	291	295	5	4	2023-11-22 21:29:26.2	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
297	\\xcff7ddb4d71f843ca2cc323368d4a533a2579c6c387c5684a08c2994a33787b1	5	2932	432	292	296	7	4	2023-11-22 21:29:28.4	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
298	\\xcdb4b5e0cf234f713fd35f5a69d2f686cae7f7cb8a00969dc4b235ef49b9c864	5	2941	441	293	297	19	4	2023-11-22 21:29:30.2	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
299	\\x6057688b33059f98b6a6b56d8890fecbe1110e31a456025a2f92b47dc41f7b89	5	2942	442	294	298	9	4	2023-11-22 21:29:30.4	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
300	\\x41f40025fce9f00e4ad99918054aa7e0faf0792d0973cf9c72c3e1857a8de9c1	5	2944	444	295	299	27	4	2023-11-22 21:29:30.8	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
301	\\x4da76332852a0ccb6420778b34bfb543235b1d25fd05459188b362fbbcf0f4d3	5	2967	467	296	300	27	4	2023-11-22 21:29:35.4	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
302	\\x3951cb929fd06675c3afef0c6fe8fbdc3c49227cfb538f17175c0a32d66f4e06	5	2975	475	297	301	8	4	2023-11-22 21:29:37	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
303	\\x6c88c54b2fc25cc53e052bb81ee939d507c436218ba117e934a308e41bbd14d5	5	2989	489	298	302	4	4	2023-11-22 21:29:39.8	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
305	\\xcaf5578766339b80733f0bcecca1db415a748720001a44b46d5c7c54f8b7ac97	6	3025	25	299	303	8	4	2023-11-22 21:29:47	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
306	\\xaf5a11517de7470dd0f711b59a4b8f4dd617a7d1a7b60c26cee2a01f26ec880b	6	3027	27	300	305	7	4	2023-11-22 21:29:47.4	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
307	\\x7682a7101d53bb424f4ca9e4ce0428c99b5dbe3ac9f5903e1a48b7b13bb91745	6	3040	40	301	306	13	4	2023-11-22 21:29:50	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
308	\\x8ad1be91ff819f2799a6ff478f9339d4ee1f2dc599b716b2075534c54d49ce3a	6	3070	70	302	307	8	4	2023-11-22 21:29:56	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
309	\\x55825eabc00dbc198551c79d0c8be9857a54232032e3302bea4e9f74eea04881	6	3087	87	303	308	7	4	2023-11-22 21:29:59.4	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
310	\\xdfcc78b8adf0adc7a9b39e233b01b19d2dae988c7ecf6dc9a80e3ac42e25d51d	6	3100	100	304	309	27	4	2023-11-22 21:30:02	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
311	\\xdd976e01b8aa4ad6975617709b9cf91341141a3970d2389ced66dc42b5743a83	6	3117	117	305	310	27	4	2023-11-22 21:30:05.4	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
312	\\x7869b77da714a51e6cf81b91243ac527bb33d0fe7f50929c2904359c4b4ce75b	6	3118	118	306	311	5	4	2023-11-22 21:30:05.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
313	\\xbce8fa78520c790cd4984f6052a83139b1490dbf80cc63769e7e437b1bf94d01	6	3119	119	307	312	7	4	2023-11-22 21:30:05.8	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
314	\\x6a06e476281169e5379101b74017fb7f6d740c71eeb3405fa4173ca65403496b	6	3129	129	308	313	3	4	2023-11-22 21:30:07.8	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
315	\\xeb9e3ba3d5edbad6a53829fa52635cd602eb03eb92775758ef70e7881181fa34	6	3148	148	309	314	9	4	2023-11-22 21:30:11.6	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
316	\\x6287c0d75029adf1ceafb976e9fda0a4e97eebfc94436ac866f166e043c3d749	6	3163	163	310	315	6	4	2023-11-22 21:30:14.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
317	\\x1b2defe7d515745f1caac597fae35cc8f623bf5028320d655b050280118b9d60	6	3165	165	311	316	3	4	2023-11-22 21:30:15	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
318	\\x15dfac476e84ef0f3cb83a33bd3d1a33a1da21530a261606d856fdc8fc4919fd	6	3179	179	312	317	19	4	2023-11-22 21:30:17.8	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
319	\\x4bcd3b364f792a9e637a2be4516eff7993122e618adebda57129bd69e54d032e	6	3184	184	313	318	6	4	2023-11-22 21:30:18.8	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
320	\\x053a528db6576105ddfa477af19126581644ec2c1a6edf679b0b7ef896fa5710	6	3207	207	314	319	4	4	2023-11-22 21:30:23.4	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
321	\\x22838f19c6cf2ac29841840a0c3e88bd6286ea7fefaadd26989670956fb83033	6	3215	215	315	320	7	4	2023-11-22 21:30:25	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
322	\\xd83951ca039713e7b603813a5c4d1a905f6d43b6283a87dd634b4481fa95d906	6	3229	229	316	321	3	4	2023-11-22 21:30:27.8	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
323	\\x065e5e514d53dd51260d88f6e7c03f5d081cca0026c10e734fe0c686c99a20b6	6	3230	230	317	322	36	4	2023-11-22 21:30:28	0	9	0	vrf_vk1z7vp0x3x9rcq7qkm9rcevfm5un4wej90qxl7splusv3ua9e97zysdc2wlf	\\x52fa8f57909b61fbd86ddf8ff894ecd584c91651f1cc32bcd12351eb88063cc8	0
324	\\x846f342b5ef543b34b1f2ec705a74b0ad8b3e1f0c047d386abb537a4d4c40fc8	6	3238	238	318	323	5	4	2023-11-22 21:30:29.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
325	\\x0ac16e205d7542e94ff2f84e64f3218d3cbf76032fb2fbaafb162d8e822c6bef	6	3247	247	319	324	6	4	2023-11-22 21:30:31.4	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
326	\\xaea834857faec86e23af659208704a4e129322417abfa5d2373443d5ac985232	6	3256	256	320	325	6	4	2023-11-22 21:30:33.2	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
327	\\x2c7b9e14d697fd8f2955460d776e53282ae21088f56dd24976dcdc6964e2e749	6	3276	276	321	326	3	4	2023-11-22 21:30:37.2	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
328	\\xfcc28b71d80b5466e61f3474bcc9746dd699832807d23bd369a6493b184e57ba	6	3290	290	322	327	13	4	2023-11-22 21:30:40	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
329	\\x021f9d9ae74b84c4d853e231c1c3daab6ad98e1c16af6366d82f4b2f5bbe1fe6	6	3292	292	323	328	9	4	2023-11-22 21:30:40.4	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
330	\\x754064c0c8faadfad37c46c50e5cd273ce5221e1485d4e8267256d1acf40a058	6	3311	311	324	329	27	4	2023-11-22 21:30:44.2	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
331	\\x96121b3ec0c8cb7209509174b748ddbff5d15d131d232f8aa3191c64980617f9	6	3325	325	325	330	3	4	2023-11-22 21:30:47	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
333	\\xc0b6b4dda089eeacc3937398cf1c455ab26a17c49928408edb26fb289ed7e245	6	3328	328	326	331	13	4	2023-11-22 21:30:47.6	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
334	\\x0e96d12cc72d653b654cd28960b14bd8e1c6823c933b20523b79b089295fd12e	6	3336	336	327	333	6	4	2023-11-22 21:30:49.2	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
335	\\xceb59259d80dc4678b33628dc88f2cc7036785fc8d76a896fd3f1a726e19ca3e	6	3370	370	328	334	8	4	2023-11-22 21:30:56	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
336	\\xc2925c24f61762aed4c4aae270459c24e0bc93d060249c4bacb5506c4ac08115	6	3377	377	329	335	19	4	2023-11-22 21:30:57.4	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
337	\\x427c9c29ed6c1f5badb2495a52c3f06de9cc26f27c575be49c2ed81496eb0b71	6	3378	378	330	336	19	4	2023-11-22 21:30:57.6	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
338	\\x90672415edc0832eb45d06ab2ff83db820609893632e8dec84488a6b46ecf1b3	6	3379	379	331	337	8	4	2023-11-22 21:30:57.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
339	\\xc5351f3f658bfbd6e4bbaf481667c3a093db6a6a54cbef10488239dfb742814e	6	3389	389	332	338	8	4	2023-11-22 21:30:59.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
341	\\x031211397ddcc1e2793892362763f3fb7b572b7ed1f7d46438afcd507b704387	6	3392	392	333	339	27	4	2023-11-22 21:31:00.4	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
342	\\xe69712109d9a1f7a34732151b11e69a4d144758acd7b3bf434500abe721d0415	6	3397	397	334	341	6	4	2023-11-22 21:31:01.4	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
343	\\x5dd38ada200abe9bee06dda4aa3b8d851ece688c0cde8d2b86243b217e568fea	6	3419	419	335	342	7	4	2023-11-22 21:31:05.8	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
344	\\x5d1114972da3ab30e34aa870d6f9741103632241853c42a9551851b5dd63b411	6	3425	425	336	343	13	4	2023-11-22 21:31:07	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
345	\\xe45a75fa3417be36a22ff13a0b4202c0a48a0607c00cbf7929ee6a785b5b1045	6	3431	431	337	344	4	4	2023-11-22 21:31:08.2	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
346	\\x1891649385569d1b5fc5222e25ffee2dc7ed5937e31fe0c8c00145ccff737435	6	3442	442	338	345	5	4	2023-11-22 21:31:10.4	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
347	\\xcbace2aa08eae4326cbc7aca1a97954db9ab7c1873c220309efe0cc7b6f0d5ba	6	3446	446	339	346	19	4	2023-11-22 21:31:11.2	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
348	\\xa5c7d6f7f5ea62dddf29ddaeb83c8cdb49e99aafc540a8678edafc9cc637ddf4	6	3457	457	340	347	9	4	2023-11-22 21:31:13.4	0	9	0	vrf_vk10rryvl8eknlyz3cl04n0l422xjzhqxttyr3xseyg7zq38mchh53qc30x8r	\\x0400da9cbd24bf4c54458fe9c13859425b5c7cb451a13184ca161b3478250bbd	0
349	\\x9e92be1f346644b0eb1bb92ff1ec5a836f47d7757c2598b70e88c00dd7b891f3	6	3463	463	341	348	13	4	2023-11-22 21:31:14.6	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
350	\\x1b9e316c3ccc65f03f744a60f5ef6a250b3c7ec665ee410fd77632e98369493e	6	3492	492	342	349	4	4	2023-11-22 21:31:20.4	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
351	\\x6244dc5e4a839b285e63dd6573b16d443463109aa90ea52946ca3035e36b381f	6	3495	495	343	350	4	4	2023-11-22 21:31:21	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
352	\\x337944aa92d1b42dc7f36bb2ffb378c65bb617ecb47f037c072fefbda1bf9bbc	6	3498	498	344	351	27	4	2023-11-22 21:31:21.6	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
353	\\xc8e2753dd0add6eef450c46702b4615c6385abc4f92e7e9ed60afcd0f76daa87	7	3517	17	345	352	8	4	2023-11-22 21:31:25.4	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
354	\\x8f258da1e106f0510aad526aca1b1a06e52e414d940bfdd3c0d665ddfc93bf4f	7	3519	19	346	353	13	2612	2023-11-22 21:31:25.8	9	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
355	\\x7172da44644a8dce3fb11c456b2db9243ca5c187fb9329f3afd0cf7ef69ad029	7	3549	49	347	354	8	27306	2023-11-22 21:31:31.8	91	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
356	\\x334b635a3819eaac33b855067631c1821fd60e2902267820b988d60ad463f475	7	3557	57	348	355	6	4	2023-11-22 21:31:33.4	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
357	\\xbf3bd9d12e90382c53f17a47fba7999968b99a7471d47a2ad715c56c00b739c9	7	3583	83	349	356	4	4	2023-11-22 21:31:38.6	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
358	\\xb6928b5ca6dcb4eac6358e3dbd1537dd7c887117d7a5bdf17932ea8e7369718a	7	3599	99	350	357	8	4	2023-11-22 21:31:41.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
359	\\x1e086d99e861ddcdc6a34de3f349ba9eddb3f744e62a1be8677cef6d4acc47a7	7	3610	110	351	358	7	4	2023-11-22 21:31:44	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
360	\\x68e87e665d236fe6b3cd275528f12203dc43e40c70e5933dcc6d16cdd85bb287	7	3633	133	352	359	8	4	2023-11-22 21:31:48.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
361	\\x5a81102b63731cf48a6729afc35dc7c77666fc0fe44170a12d6b6bd39a343f1c	7	3648	148	353	360	8	4	2023-11-22 21:31:51.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
362	\\xc681038fe48ba0f1cd6ca2e2e603c310f10c6a33d366fb89043bed5d701b87e4	7	3651	151	354	361	5	4	2023-11-22 21:31:52.2	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
363	\\xc2914bdf883122a3f0994968c9917a5e0b24e06d25c312d84d158226bfb523a9	7	3654	154	355	362	27	4	2023-11-22 21:31:52.8	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
364	\\x11c013974002d1624780a1c3136cde348dde13e36452042f3439c2a549560dcb	7	3659	159	356	363	19	4	2023-11-22 21:31:53.8	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
365	\\x288e19c1e1844cebb1c18ec4fe5c500b88282e8c71a301a64f0e0c2ddbc55e77	7	3663	163	357	364	4	4	2023-11-22 21:31:54.6	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
366	\\xea05cf6c59a6e940d988e9c1cba602b659d65e1cff0ed38a3a823cdfe735643f	7	3666	166	358	365	5	4	2023-11-22 21:31:55.2	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
367	\\xfae71aa8184dcc006b66a974b7676e176c423223a79aadfaf2d92fa1be48835e	7	3672	172	359	366	5	4	2023-11-22 21:31:56.4	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
368	\\x0d3f793ea46b8ef439afc5f94b13e44aa1d030f56f042388bb771a2d398de018	7	3674	174	360	367	7	4	2023-11-22 21:31:56.8	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
369	\\xa06b0910ad96d0cf08ef5ce17a9abbdd8066f542200f154d281dcc660a8aa739	7	3675	175	361	368	27	4	2023-11-22 21:31:57	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
370	\\xec09cf32f4d10432a151cb30a20cc385169f718ae0ee6ed3680dc1c49f223442	7	3692	192	362	369	19	4	2023-11-22 21:32:00.4	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
371	\\xaf13ea5b63e65fedf64b0da4928ac49fefd933a62f4494b771918bc10d91e461	7	3693	193	363	370	19	4	2023-11-22 21:32:00.6	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
372	\\xee6525662572c56e215a3630e6e6719e1558db596913c191f929a40494bda5f6	7	3694	194	364	371	27	4	2023-11-22 21:32:00.8	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
373	\\x77fef72096154892caa8e12be337ff50569fe274f18050518012a13fb36e16ca	7	3699	199	365	372	8	4	2023-11-22 21:32:01.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
374	\\x823d477a1f6a2b239cab8a1b1bc9a93beb64fc481fe2fe87a1890d418fca25e7	7	3728	228	366	373	4	4	2023-11-22 21:32:07.6	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
375	\\x0e2b792c3eda40fc90a1e60e0f9d47f9c51209fc2c9a351db67744c689ab548d	7	3748	248	367	374	8	4	2023-11-22 21:32:11.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
376	\\xe7fe0ee9f299e14076890e9b017fd6d67f9075d1890f30b26156375a70df0993	7	3757	257	368	375	19	4	2023-11-22 21:32:13.4	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
377	\\x29be364afffde8f59dab57060c5c8d8a0f51c7e16f43459c71db32541d47c8ef	7	3786	286	369	376	8	4	2023-11-22 21:32:19.2	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
378	\\x2f7aff67168a95ac45a307348723a2af2d41defd1bee7b58e9537b37e29fbf78	7	3788	288	370	377	8	4	2023-11-22 21:32:19.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
379	\\x38fdca4b4e96ee8f7326150837a84bdbdec4c0ac1e402fe60932060f37f866e3	7	3796	296	371	378	19	4	2023-11-22 21:32:21.2	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
380	\\x01672e3619b0b47dd4fc3defe873d4e8b3fee6b446d52aef991c89773552932c	7	3798	298	372	379	6	4	2023-11-22 21:32:21.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
381	\\xda3d7888f4f2b9db0520deec9434b955be27392fe0bbc34942e36b4233dcb8cd	7	3799	299	373	380	13	4	2023-11-22 21:32:21.8	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
382	\\x1fe74416309f900cb861a8001a72bbbbbefa54c2376041805d0369e89ba13db6	7	3800	300	374	381	5	4	2023-11-22 21:32:22	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
383	\\xca479ac5302dc89d967a9ee48f0480f5f409ce1f623a72a88f3d190830bf340d	7	3803	303	375	382	5	4	2023-11-22 21:32:22.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
384	\\x240ddebacf6ab5fb21b8f54e3ae63989128a9485c4619bba010da24d457837ba	7	3844	344	376	383	27	4	2023-11-22 21:32:30.8	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
385	\\x3c80f324cb5d9434ebacaad8b13621e801bf5fee72167fc79e87c6a1e3e81543	7	3850	350	377	384	27	4	2023-11-22 21:32:32	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
386	\\xaeba649ef54af59ce1f9049d25ac9e94fa046523adedfc351b4f8d86294e8a27	7	3864	364	378	385	4	4	2023-11-22 21:32:34.8	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
387	\\x46ecb51e75cc3258c74944096d09da85e3ac91e906513fa7b343ad65d6fb7869	7	3897	397	379	386	3	4	2023-11-22 21:32:41.4	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
388	\\x069c437236ab7fcbe32e2d09d283d332b572f3d0a9d19bedc0fa84a0b5bf576a	7	3921	421	380	387	27	4	2023-11-22 21:32:46.2	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
389	\\xa09c9381b4659c988b11880f11f83f2a06f695ccea559d97b2e6208611cdd4e2	7	3925	425	381	388	7	4	2023-11-22 21:32:47	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
390	\\x0e6c9e4f4db0c9ebc8021a932543418a71c51580dc856b4499fb6cc29ce52d53	7	3933	433	382	389	6	4	2023-11-22 21:32:48.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
391	\\xeb034656c1302d13815c8bb8888ff97388f9ff4cdfbb49a6806d36e7dd181328	7	3952	452	383	390	3	4	2023-11-22 21:32:52.4	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
392	\\xfa2b963e387d22484adf05a0198d04618bde01d96fe8ede6e7e556ddbbe3fd13	7	3955	455	384	391	8	4	2023-11-22 21:32:53	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
393	\\x7017b9ade85a188589231709fac3a2a65851d8ac56dc9eec139f068779ccc7df	7	3957	457	385	392	3	4	2023-11-22 21:32:53.4	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
394	\\xfdec71e7979dd58d46b8c58d930a0a6df4dffa30da9bf3e3c943cfaef9679735	7	3968	468	386	393	27	4	2023-11-22 21:32:55.6	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
395	\\xc8a280424ccbf2ac17ce3b2d5fd61cc1a6cad051643c9d4cef5b5e5ea6fda130	7	3979	479	387	394	19	4	2023-11-22 21:32:57.8	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
396	\\x84dca8b0348a461dd6cfd329e88e29b79fa2fcc336d0f3993e21908718b3ea9b	7	3983	483	388	395	4	4	2023-11-22 21:32:58.6	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
397	\\x6d58d4ae06e2849d8cef36083c436379e908296c74e48adc27436c9575f53d87	7	3988	488	389	396	6	4	2023-11-22 21:32:59.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
398	\\x8bbe583f2ce75b0b00da66177b70ab259cebc0f3bce1d729c0d19b382c613d80	7	3991	491	390	397	7	4	2023-11-22 21:33:00.2	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
399	\\xf61e8cfaee3ef149cc3520fca0dcb02218ef447ee75b106287f13f4575c8235f	8	4005	5	391	398	6	4	2023-11-22 21:33:03	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
400	\\x0bb841dd80716409cecfcbbc95861ed5ff94b99dfe82c44cc1bea6576858aeac	8	4010	10	392	399	8	4	2023-11-22 21:33:04	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
401	\\x6c8132421f84382d70028f0d2fe2abde29673a4eb759ee208b8d198957920c4d	8	4026	26	393	400	6	4	2023-11-22 21:33:07.2	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
402	\\x1a60c846816549055b1f208f6c4886b804aac6e73897f0298e576c34cf6134b1	8	4046	46	394	401	13	4	2023-11-22 21:33:11.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
403	\\x0ef2e28281219cd6bac69d032375c0eb22e81f004d341d217474984f31413d42	8	4072	72	395	402	6	4	2023-11-22 21:33:16.4	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
404	\\x2db724ba33064d575f1c34c40ebfec4e9689af1defdf9e9a01bd4c308eb01fdc	8	4079	79	396	403	19	4	2023-11-22 21:33:17.8	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
405	\\x57e4505d4ad95e5aff91591e160f8314b5987781bbc52af58563ad4d705bb414	8	4086	86	397	404	19	4	2023-11-22 21:33:19.2	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
407	\\x472a1996ca7c00bd7ee3ce5c3b235d23743a221f4c50bc0294618f7b5cb805e9	8	4093	93	398	405	7	4	2023-11-22 21:33:20.6	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
408	\\x7d0388c0b84106180f2bc00ce0177bad3f754ed8a86bc17c79c1b13ef2f4f14e	8	4097	97	399	407	8	4	2023-11-22 21:33:21.4	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
409	\\x3f48c184e5fe14f12a1c0b51ad04ae376815fb9fdeebaafab3b1e582bc8f9c23	8	4110	110	400	408	13	4	2023-11-22 21:33:24	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
410	\\xa608e2370cae640adbfe2a4f6d645e6ac4b0fd1d92bef1fc342def610dcb31c8	8	4119	119	401	409	7	4	2023-11-22 21:33:25.8	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
411	\\x4e36f015f69aeddaffd759774d801674e729c2ed8d4f54684c2934e09afb70a4	8	4126	126	402	410	3	4	2023-11-22 21:33:27.2	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
412	\\x4579da8e44bc6732ea26947c343d0e9055fabe758c20137d570b1d27c890ba27	8	4135	135	403	411	3	4	2023-11-22 21:33:29	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
413	\\xa7342a003ed9ff46c82cc3bb73c1379209e2f411717da0bfa17ee35a816c3bc8	8	4136	136	404	412	3	4	2023-11-22 21:33:29.2	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
414	\\xddcee1d3c7c013b80c60699b1a62235beafd38135ff4133e4c6b7a99e98f175e	8	4140	140	405	413	4	4	2023-11-22 21:33:30	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
415	\\x8cbbb769bdb510789478fb5a1425824a3f7ded7574da232def745b2f0b0ac2b9	8	4144	144	406	414	8	4	2023-11-22 21:33:30.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
416	\\x1aa10f3081023f4ca6dbe12e92fe476abf6689505ee74b5caf1a4918d0f617cd	8	4146	146	407	415	8	4	2023-11-22 21:33:31.2	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
417	\\x6cf2be7b60275798f1d416a69ee738f8c362413598cedd84e6e2057d3163ab4a	8	4147	147	408	416	7	4	2023-11-22 21:33:31.4	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
418	\\x9c00874a540ee5278ebfdbe7dfa87a987680d9ea2984e279a838939a60083083	8	4157	157	409	417	3	4	2023-11-22 21:33:33.4	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
419	\\xac007d3b1f99e670e5b7a75eaffb57981c84026807baf2cf22e0c4559cb48019	8	4164	164	410	418	6	4	2023-11-22 21:33:34.8	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
420	\\xddf9e98646912ed50edbc89d9e8931dd4cdd3316498136171b3fea8f3b878c03	8	4171	171	411	419	7	4	2023-11-22 21:33:36.2	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
421	\\xbc49e331718ba32c65f5d54382f0d2766450bd7919a8d6783f81299ee422e1ac	8	4182	182	412	420	6	4	2023-11-22 21:33:38.4	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
422	\\x6df86a8bbcf2f35ff496859f03f8b7387ec5a28b19a1a3b9891ad6f2f0b4c437	8	4191	191	413	421	4	4	2023-11-22 21:33:40.2	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
423	\\xf8eb79e76e41632b717dead18339b5c6b56186d6d5ae297e065aed5f67daee74	8	4212	212	414	422	19	4	2023-11-22 21:33:44.4	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
424	\\x634621ecfe3da4c44fe02c376d47c5ba5d59892ca0117e5ef83850410ff53b95	8	4219	219	415	423	27	4	2023-11-22 21:33:45.8	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
425	\\xe8a4db810480d6e29ccb9288a291807c41ea9faffb46532b17722c64671d9b82	8	4260	260	416	424	27	4	2023-11-22 21:33:54	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
426	\\xbf4cc1ab490ade64a27d31989a0df793e39fe3b2a35bb0f3795a99fa65cf90d0	8	4263	263	417	425	27	4	2023-11-22 21:33:54.6	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
427	\\x4688f9ff230301e66e80098435543b05d75fef440559345b7c767d2a48f35e91	8	4276	276	418	426	27	4	2023-11-22 21:33:57.2	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
428	\\xa8a1aba0c8b7ec597af4dfbc1af47c87f5d2fd450ce20ba4bc450da6acc86a11	8	4293	293	419	427	4	4	2023-11-22 21:34:00.6	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
429	\\x04a1f9f3c1a34e0914aac3f0494328b31c05de94354e0a7cfcc6159a871b2343	8	4294	294	420	428	7	4	2023-11-22 21:34:00.8	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
430	\\x50148e045bb04d7101d4fa485163e1ebe6ca4b2bb18ae42d6efbcad40c0c5751	8	4298	298	421	429	3	4	2023-11-22 21:34:01.6	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
431	\\xca963ef6616f98de4fd367f8223bad445359c939a810858c8adde02d7938c17a	8	4334	334	422	430	6	4	2023-11-22 21:34:08.8	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
432	\\x2fb64bb7bdae8502bc59d9cc7a4e15ee7ccf96b4f8bf7d54f521db4f25a7c65b	8	4345	345	423	431	3	4	2023-11-22 21:34:11	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
433	\\xfb75839dcb6ba89795daf9a5cc18aa2f9729bee031a0285dc2b28b60c8e00b18	8	4351	351	424	432	4	4	2023-11-22 21:34:12.2	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
434	\\x6a849de6a3e534ef9b47c603afdf93c39b65800571955110344cde31a9173c23	8	4352	352	425	433	13	4	2023-11-22 21:34:12.4	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
435	\\x8ef96c643816eb6214881a144ddc1f85a030d856b54bbcf5c85c21a037edb2cf	8	4353	353	426	434	5	4	2023-11-22 21:34:12.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
436	\\xc559607a36cd73a4a3c418da861c83e40441d19452c29ad14c3bd69f6ef9c8de	8	4374	374	427	435	3	4	2023-11-22 21:34:16.8	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
438	\\x921610d732804b5a63b0fffb43fd4386f0d68abe53b13050755e41efa6c2bc93	8	4384	384	428	436	8	4	2023-11-22 21:34:18.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
439	\\xbb6985f392a798b4a3a360bdb6f7197df6bc91eeecdad740e962f0866a3a6b1f	8	4390	390	429	438	13	4	2023-11-22 21:34:20	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
440	\\x1266bc9aac7e95d8530eb8081ac51d01d78114bef25b30294a8e8f8c179c51f8	8	4400	400	430	439	8	4	2023-11-22 21:34:22	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
441	\\x28b089e5ab534e2c1dc9c3baea389a65d1580932a24a140d0a4b40ecbb144072	8	4410	410	431	440	27	4	2023-11-22 21:34:24	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
443	\\xdf61d982e0a74c3a33cc0eed6a513a68334b5cc06be25e6718ea859e446acc8c	8	4415	415	432	441	8	4	2023-11-22 21:34:25	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
444	\\xdf584266140b8a442c8a6d86ba01d1e7d5c8206c4ff1dff3a4271543fdd119e8	8	4419	419	433	443	7	4	2023-11-22 21:34:25.8	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
445	\\x953617b308b4b1eeddfae10723bda6997b6ee7e31dcd79fa480c530710948365	8	4423	423	434	444	5	4	2023-11-22 21:34:26.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
446	\\x5957baf11b582422eb57901ab08758244e4bf00c54e18d806721f7d7c82d563f	8	4429	429	435	445	27	4	2023-11-22 21:34:27.8	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
447	\\xfd1894f9c89c04ae5a9bf20488f52dfbf07a253a224722245422df372bf43152	8	4439	439	436	446	6	4	2023-11-22 21:34:29.8	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
448	\\xa346df3b01116dbcd9af9e4ab75dd815cf6189e740ae9dd4a902d288fa44bdbd	8	4452	452	437	447	6	4	2023-11-22 21:34:32.4	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
449	\\x4b9699ddd6edac9322d0661ef7df4c5d0c7c4fad0432554fd62ad6bc6cd0167d	8	4454	454	438	448	4	4	2023-11-22 21:34:32.8	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
450	\\x9d768b1136018b6ecf49dc5050f802633778bef3cc4b30fbce97e830e1015525	8	4456	456	439	449	19	4	2023-11-22 21:34:33.2	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
452	\\x5c4a3005a75d32ccdeecf79c962463213092d19317da0b56b6b1cd1ff3566069	8	4478	478	440	450	7	4	2023-11-22 21:34:37.6	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
453	\\xb5ddfecd30ee0c01459b39d2a086683e191d988878c208dd5af463273dc53ea0	8	4480	480	441	452	3	4	2023-11-22 21:34:38	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
454	\\xd9b45746d75f2915f419af6931f591c078e80f6befa694b08dad27dc3208b321	8	4494	494	442	453	19	4	2023-11-22 21:34:40.8	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
455	\\x33e0fb690f02ba62d2da0c55b1eea4ad2c840e424188a53f0c8d58476d94a539	8	4497	497	443	454	7	4	2023-11-22 21:34:41.4	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
456	\\xfce7c2f16d07956b8f8dfd7d47e0690464ba1055d60ec8a6f5aa002577d03005	9	4502	2	444	455	27	4	2023-11-22 21:34:42.4	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
457	\\x82006bf9b134f887ce1b9b59c132ab756b158ba4233a3b9c4e12a011b4c2845f	9	4503	3	445	456	3	437	2023-11-22 21:34:42.6	1	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
458	\\x6360a33dfd1812c1261c39d997837cb9490431d28cb48e608f930c6d198330b1	9	4506	6	446	457	4	4	2023-11-22 21:34:43.2	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
459	\\x22643b94a0a3fa66f37c9c7906ea4f76dce919b5b1345e6338ce8a1a9f892b94	9	4510	10	447	458	19	4	2023-11-22 21:34:44	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
460	\\x76f67103196b9ddd190f364bf9392a9adde88e677efa7d6e529ec866388162af	9	4536	36	448	459	27	4	2023-11-22 21:34:49.2	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
462	\\xb6625a52a2d388e7ba468bc4ee07ae57effa092567eb1d228b0145358ca57314	9	4554	54	449	460	27	6374	2023-11-22 21:34:52.8	1	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
463	\\x2a81f51a08916d31e5b227ab0439681efef44228a4e70ae66e77e7958099ff00	9	4576	76	450	462	19	4	2023-11-22 21:34:57.2	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
464	\\x3fb27710a2d775affef0ce9bce06bc71c93541c23df5b53a3490be4d5ce02de4	9	4610	110	451	463	27	4	2023-11-22 21:35:04	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
465	\\x7f8139aedc9d56b07938d98a19eb20a5c00a0fcaf037e1901faaf6ffdf798946	9	4617	117	452	464	5	4	2023-11-22 21:35:05.4	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
466	\\x954dd99f82ec43fa3e03fec5e54519715310dede38cc940e33278d6bcbcaa382	9	4626	126	453	465	5	4	2023-11-22 21:35:07.2	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
467	\\x4c1e49112de0b304210f533a135408352fb5adf6f31d087b0e8154ab2c572b64	9	4629	129	454	466	27	4	2023-11-22 21:35:07.8	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
468	\\x856f33bd067d5bf24bec742e0875794500b738639089949f7be69bf73d83097e	9	4635	135	455	467	6	4	2023-11-22 21:35:09	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
469	\\x9e87cf1a858d675a28f213638bd4575a7f2ae5a3d413689bae4fa165b781d0bf	9	4649	149	456	468	3	4	2023-11-22 21:35:11.8	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
470	\\x02c2b3b02447027296e8d410223a1a158cd1163f98a573389a513d9686e3f761	9	4655	155	457	469	3	4	2023-11-22 21:35:13	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
471	\\xba09ee4d9cc5b68999e934f929a31ea9aaf4b44e3ba1f5f5e6d94bc5e65a9dfc	9	4660	160	458	470	7	4	2023-11-22 21:35:14	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
472	\\xd5dc3080a179dde7d49f1faccb20d1d2361019a94078f1b060db21e022221861	9	4674	174	459	471	8	4	2023-11-22 21:35:16.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
473	\\x670074c2634d131e138b728c86deae4f1bf474aa7db1e660cfff5b22d632b58f	9	4678	178	460	472	19	4	2023-11-22 21:35:17.6	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
474	\\xc2dfa51968f8a8cf897e978cfb87208b6a979516fcf9e7b775e5474aae8e00b9	9	4695	195	461	473	7	4	2023-11-22 21:35:21	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
475	\\xc7b15d068cb31f8410d6024f77da14e05a04117e1a896362c63a1adafcb05134	9	4698	198	462	474	5	4	2023-11-22 21:35:21.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
476	\\x51c671d777477d50b61726294cffa11ec3ae61ad90565fde7db868f30a4898f4	9	4701	201	463	475	4	4	2023-11-22 21:35:22.2	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
477	\\x2bdea263a2029c3aed08ac22b862ad4fdc122418ec53c37ee845ac1cc9a451bb	9	4713	213	464	476	4	4	2023-11-22 21:35:24.6	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
478	\\xba414e957ccd784ab06cd3d7e0fb564a76ab5b864b18dd346ca19f85c1fe0458	9	4714	214	465	477	4	4	2023-11-22 21:35:24.8	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
479	\\x6b377df316fa069777e6596032eee51e7edd43378c2a0958faec2bb95435f9f6	9	4728	228	466	478	3	4	2023-11-22 21:35:27.6	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
480	\\xbf8343dd24eaae94b8c5205291d25d6c8861884279db36235381308e6f724b66	9	4785	285	467	479	8	4	2023-11-22 21:35:39	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
481	\\x178db7f4c55c8edd3abb15119056cdeb07a9be69efabdce6d4ef1a868b4f73f2	9	4802	302	468	480	5	4	2023-11-22 21:35:42.4	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
482	\\xe1efbe7115318af442b9e4f5200f5a1b2be9349cddd8c38095a5701afbe31fc2	9	4806	306	469	481	3	4	2023-11-22 21:35:43.2	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
483	\\x4cfc977897082b86e9f2b161f0d6b7535e41ed74db00c155fe34add05a0caf3f	9	4813	313	470	482	5	4	2023-11-22 21:35:44.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
484	\\xced9fce8bbf8c40079176c85e873c0c5e63965d0ff1cf54a0404045ac24117bd	9	4818	318	471	483	5	4	2023-11-22 21:35:45.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
485	\\x72e911bc1603a222cb8f4b6ba5fe84e0d5f371b210e6560df872760df010beae	9	4840	340	472	484	7	4	2023-11-22 21:35:50	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
486	\\x54f2de20befaf498156bbff507a067bbfd5f34921480acc962508a267c97da78	9	4847	347	473	485	13	4	2023-11-22 21:35:51.4	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
487	\\x8c3c6cae15e942b758793b8e01b5dc8d9c438d78337ba71fcf60d437ccac6822	9	4861	361	474	486	7	4	2023-11-22 21:35:54.2	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
488	\\xa2a1acf04ae24d55207876f4eac33553cff87755a77167bf8028a5fba6955fe9	9	4868	368	475	487	13	4	2023-11-22 21:35:55.6	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
489	\\xeceefe81ebd6bafacc4f578c17e78355557553ffb318b5fbdf10d64c5403e2ad	9	4896	396	476	488	7	4	2023-11-22 21:36:01.2	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
490	\\x93cd8818cec41b22e8062196760ec0bafd1ed4e6593434ccef49c703c18e95d5	9	4900	400	477	489	13	4	2023-11-22 21:36:02	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
491	\\xd123535882b50b87487ea873fc12ce9b9eef7debec47c215152ea5cbfbe6e199	9	4906	406	478	490	27	4	2023-11-22 21:36:03.2	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
492	\\xdab7fa43d2c9f829ea20aaedeb5ef5bd0ad07ba6c58102b334f779a98e70b2a5	9	4934	434	479	491	3	4	2023-11-22 21:36:08.8	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
493	\\x2f52072ede28b8aa85487f29e7794d819970c0f781b1993dd53ac93607510883	9	4938	438	480	492	27	4	2023-11-22 21:36:09.6	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
494	\\x8cf09fe731b0eb97e0194f7885800ac462445ca476c4d12795d2ecd8619b3fb2	9	4941	441	481	493	3	4	2023-11-22 21:36:10.2	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
495	\\xe88edb22075af8853621ea895fe234c046de88646f67ebf1bb6578d9ee0eff58	9	4967	467	482	494	8	4	2023-11-22 21:36:15.4	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
496	\\x136d571c54a8647190d2eea9a1ba4af2311985e486dc349afd70f15abe2e56e0	9	4980	480	483	495	4	4	2023-11-22 21:36:18	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
497	\\x59927d2b269ecdeff9e65a482ac534c02129ec3adfdc7f4bf43991d37b4cfb23	9	4989	489	484	496	13	4	2023-11-22 21:36:19.8	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
498	\\x77efa7c3cbf72bfc8c8ef36ab7a46cb26de54e006f219923b84c0ff9dcca6764	9	4999	499	485	497	8	4	2023-11-22 21:36:21.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
499	\\x628d2dd3e4f82493ef093fc0dee757df47821352ddb407a8d64e64a97ca74c41	10	5005	5	486	498	4	4	2023-11-22 21:36:23	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
500	\\x4f52515f70ce8e96bb3d80e1d35eb7ea6620741e6877e5de94768fe438a54915	10	5018	18	487	499	6	4	2023-11-22 21:36:25.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
501	\\xe2edb2edcd1df70bb7ded1fbf5ea47af01fce5e2e3fcc3259967a632bf8de71b	10	5024	24	488	500	5	4	2023-11-22 21:36:26.8	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
502	\\x0ab9f96f8f9c1b9b1ee533c444b10dfc2e4b5c38421b7b8beea913c2565f73b4	10	5026	26	489	501	3	4	2023-11-22 21:36:27.2	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
503	\\xd1bf2f797e9012ec491543e3692d8b8d17ea1c454dc34aedaa7ea704a38cd509	10	5043	43	490	502	5	4	2023-11-22 21:36:30.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
504	\\x3037ab7b7101262efe9441c67ff2ddd0b649aa22166badaa0148e5728cce0931	10	5052	52	491	503	3	4	2023-11-22 21:36:32.4	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
505	\\xaea03fd2002ed6a6e6690fdff30a41456ad7ca8a62edfd07e979d8a2a8a4c221	10	5054	54	492	504	13	4	2023-11-22 21:36:32.8	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
506	\\xe7e81dd20329019fa802d1f511b221a1bcde1574675e2d9836a61639af62bce0	10	5061	61	493	505	8	4	2023-11-22 21:36:34.2	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
507	\\xfb643e24d30c0c2c55768b1efa495f2b1908c131e5298b1a0148831f931c46ba	10	5071	71	494	506	19	4	2023-11-22 21:36:36.2	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
508	\\xe31c78491beb7796d6dc535f442ece751de405fb5463244448df245935395e34	10	5130	130	495	507	4	4	2023-11-22 21:36:48	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
509	\\x9cc1015b047dcffb2126ddbc7f538bc438e0fb4cf3b22d21dcc6bfd2b285fcb8	10	5137	137	496	508	3	4	2023-11-22 21:36:49.4	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
510	\\x8f84f035287697b876957705c100287f3a8aab847699d24d733b6cd36ae32504	10	5138	138	497	509	4	4	2023-11-22 21:36:49.6	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
511	\\x5b753f614becfb0a5c46471113c9451a8e2789f357ed7e5232edba1d43a654ee	10	5147	147	498	510	4	4	2023-11-22 21:36:51.4	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
512	\\x61e5f5549c9cb4ed2e1a9ba88795b9cf6e59be979bd111f0e6196aab5da78773	10	5153	153	499	511	27	4	2023-11-22 21:36:52.6	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
513	\\xe8d36846f4ec97d78e9dc3a521d5025b12bbd05439ea86fe7e1fd070bba48eaa	10	5161	161	500	512	5	4	2023-11-22 21:36:54.2	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
514	\\x1b533c5e0cc2e3ce100b4df4d3883db2b0ab1719daad7f124d635bf6b4ad15de	10	5184	184	501	513	7	4	2023-11-22 21:36:58.8	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
515	\\x661ee03a374739e70661cf75dbadb0b90f9efb7a790369eb64d714f5a6c110df	10	5222	222	502	514	8	4	2023-11-22 21:37:06.4	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
516	\\x5e59a6dd3e822819e56dbe916f833e09b31a4fdbbc6b5ca4e0d634d6f76645d3	10	5225	225	503	515	7	4	2023-11-22 21:37:07	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
518	\\x8c4dab8a4b0546d5088277c458bb577067af55c0272309424ab75a73a43f3e55	10	5231	231	504	516	5	4	2023-11-22 21:37:08.2	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
520	\\xebbc90970d6d2634b90cab377a0d75aa351d0285b85e6d0134d11b53ab83a79d	10	5235	235	505	518	27	4	2023-11-22 21:37:09	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
521	\\x99adb042d6f0dcafd290c3b9b70cf889a24ed0c5d0477908faec34cd3380b4ad	10	5238	238	506	520	27	4	2023-11-22 21:37:09.6	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
522	\\xfcf48f4f5318827539869fd63cdd49592f41e7f8f28910ca30d20407613c7192	10	5242	242	507	521	7	4	2023-11-22 21:37:10.4	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
523	\\xdade1f15a856b239a0a2d50b77c64a54581dde80b5b94159ea203e2f91247bd9	10	5256	256	508	522	4	4	2023-11-22 21:37:13.2	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
524	\\x1fa18bfd045f0304ad3e6ac1da46678c5bbf59e841ada5f5cdf916de5be64d26	10	5265	265	509	523	13	4	2023-11-22 21:37:15	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
525	\\x5497f65f8652e1c0b3867993d099510b712fbc578328fd0b1b19171c2b3981dd	10	5272	272	510	524	4	4	2023-11-22 21:37:16.4	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
526	\\x9a27411f9d21f3ec5e9b22139e7e2d727db0022ff80c30df20e3cd746e2f7635	10	5277	277	511	525	3	4	2023-11-22 21:37:17.4	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
527	\\x5cffa4c1473c8b2f0334d689593378af7ca4f3b33a555830dbda2b23cc4fe0d3	10	5288	288	512	526	13	4	2023-11-22 21:37:19.6	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
528	\\x749bd46e3259a628d556d6a906b0076742880307736b70010c6400154af5d554	10	5290	290	513	527	4	4	2023-11-22 21:37:20	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
529	\\xe506693b2c09357bbeb8b3bc8536c3371c682e597a1e033eedb8db8c3ef9e4f3	10	5325	325	514	528	6	4	2023-11-22 21:37:27	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
530	\\xc3a7e59ec3c3bbee4ffac624cb7ab7f5b6bcf17f5a05d57f682b61e2add942ab	10	5345	345	515	529	3	4	2023-11-22 21:37:31	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
531	\\x2133372facdbc5e676026fb9ffc6ec10141f55fec1a9712fb6df57858e18a3eb	10	5361	361	516	530	3	4	2023-11-22 21:37:34.2	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
532	\\xc41e2695797bdfc344572175e4da9fe7d0d3727f0339169943aa3f66b6a6c5ee	10	5362	362	517	531	27	4	2023-11-22 21:37:34.4	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
533	\\xb153f614f1d71a2d03fabdbc183eb800723bad70e7715c5233ec3be9e5e235e2	10	5365	365	518	532	8	4	2023-11-22 21:37:35	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
534	\\xa79eba7480881575b9526ed9211b5a9cc606d07cfbdcde803508bbb3554156dd	10	5382	382	519	533	6	4	2023-11-22 21:37:38.4	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
535	\\x48566047242ec96e7df00aca21d7780e1393268d0b9100c93ebc235fd699fd3d	10	5391	391	520	534	19	4	2023-11-22 21:37:40.2	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
536	\\xd85c94b2a2a317a76cc57768a090a3adb4ad85db2ca7e078542a4e79f3024515	10	5449	449	521	535	4	4	2023-11-22 21:37:51.8	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
537	\\x652c10dd332216ff49dfbd8e6a2a16653a69cac4dd9b0681b2b2c8e4b3393038	10	5464	464	522	536	3	4	2023-11-22 21:37:54.8	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
538	\\xb26be4210d7f360c9e625e0ecdcaaac75e46daa122d9be0e48ef854cb2506762	10	5468	468	523	537	6	4	2023-11-22 21:37:55.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
539	\\x6869147785288233a26526af0ecac59603a0f483827d87df21b63868794a7b3d	10	5473	473	524	538	3	4	2023-11-22 21:37:56.6	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
540	\\x8daba9ef0f5e1dbfc9715bcf973ffdb3514d3373953d29760d2a922c30058c84	10	5483	483	525	539	5	4	2023-11-22 21:37:58.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
541	\\x88e33d4db969732057831be72f54baf3da55ba3cee5212df01a2c75e62760019	10	5485	485	526	540	13	4	2023-11-22 21:37:59	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
542	\\xdd03e2a2acaca0f28071b10fe31f6a7ca4cccca409b2b5ba0f0357458d430169	10	5491	491	527	541	27	4	2023-11-22 21:38:00.2	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
543	\\xcc4c975ae2cba67a60e3a32e08586d33a1073efdb3c130ff41ba1a96648bda82	11	5507	7	528	542	5	4	2023-11-22 21:38:03.4	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
544	\\x5ef1dad4dbe0ea132f9bd0dd1799446545bfcc53725ac81ce10eff4c7de3e6c1	11	5522	22	529	543	7	38489	2023-11-22 21:38:06.4	36	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
545	\\xea7b3b829d531ea7f56e13726cfea51d1a761ac489913243cd7ae35c4bb0067c	11	5525	25	530	544	5	6364	2023-11-22 21:38:07	6	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
546	\\x0a413adf0ca5f196d8b1ecb1ca6df824348d029c58c6c60a690ea042c3628657	11	5531	31	531	545	6	16964	2023-11-22 21:38:08.2	16	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
547	\\x1c1e6c1032db278454ab66486879eee0d5bb3f7a7791bfcb2a752e9e13984d37	11	5576	76	532	546	3	44526	2023-11-22 21:38:17.2	42	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
548	\\xee3ec767f6ceb1d0774199db7f288d4e7cde68d813f18bec5ab1edbf1902a88e	11	5578	78	533	547	8	4	2023-11-22 21:38:17.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
549	\\xe4b0bc0f70dc7b93f69fcc14987562e1286827e19164a5b5099002052ecc0c19	11	5585	85	534	548	7	4	2023-11-22 21:38:19	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
550	\\x52fc59a4e572ffda02d970594ed200e151ec556effe7040257e294399cd1cf21	11	5590	90	535	549	13	4	2023-11-22 21:38:20	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
551	\\xd4b5f9078de7896802b90d14e519612ec930a47b89c92bcb2908617e8db55b1b	11	5595	95	536	550	7	4	2023-11-22 21:38:21	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
552	\\x17d2198dc40f7fc8accf3e30b1359ef8c4f91429854de9e08b43e4478d826b46	11	5607	107	537	551	13	4	2023-11-22 21:38:23.4	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
553	\\xd19059c48b263c6b5d156fc31f53a3a53872c96a1dcc5157f3c9bc0690ee51db	11	5627	127	538	552	7	4	2023-11-22 21:38:27.4	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
554	\\xd08ac2b448b5cf45c082c1f40012cd566c0c9724d049b89d06fc7274418320d6	11	5649	149	539	553	3	4	2023-11-22 21:38:31.8	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
555	\\x9454edb3ed7b498202480b596b863f8394703ff46f9e08f35c590d7f688e34fb	11	5661	161	540	554	13	4	2023-11-22 21:38:34.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
556	\\xc4d34e4ba10a1840316dcd665e7e41b23bd01a9196a8262a7cbf6cedd4fe7268	11	5666	166	541	555	13	4	2023-11-22 21:38:35.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
557	\\x46dbc1851367f89581386654bf4fa91ced99ad7cad4876790b768662a2858009	11	5668	168	542	556	6	4	2023-11-22 21:38:35.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
558	\\x6b76563415b42b100b899f8d04359b6c8c9cc58ca97315eebb314b18e716e2dd	11	5671	171	543	557	13	4	2023-11-22 21:38:36.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
560	\\x38c61b08b1e4e0aebf6c6892aac34fc01d5d87f2ea2abd0eb2de6c2e06178d05	11	5674	174	544	558	4	4	2023-11-22 21:38:36.8	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
561	\\xb29114b628b627ff64a9ec54ac283acaf9ce82d76d70aae73e28941d5b2498f0	11	5682	182	545	560	5	4	2023-11-22 21:38:38.4	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
562	\\xafc39a67a56b8b98789d703853f2e345928c642cd73c1a262006a216105653bd	11	5691	191	546	561	3	4	2023-11-22 21:38:40.2	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
563	\\x53f9f6743724a32a2d1b9ed102e8d582244a436760ed3ff18bb184a92a510f9c	11	5693	193	547	562	7	4	2023-11-22 21:38:40.6	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
564	\\xe780122d12837f321a10352257249dfe50e70b8221adae9bfe0bca547905a2a4	11	5699	199	548	563	3	4	2023-11-22 21:38:41.8	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
565	\\x5c81bc351255f9e63b818b02741ececdd97d3b2ff33d964673810bf20c52cb65	11	5701	201	549	564	13	4	2023-11-22 21:38:42.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
566	\\x31b4da51edeab64d7c977aca15bdd232041228fbf9ae17cb666470c004a1eb3e	11	5716	216	550	565	27	4	2023-11-22 21:38:45.2	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
567	\\x0d8c43f8fdb3d853ccde4db5a4d35d42b6539e1f3f3d4d7fc4a94cc7a8ef55ea	11	5727	227	551	566	6	4	2023-11-22 21:38:47.4	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
568	\\x9565727017020689fc812fbd466f3c0141bf690cff217e70d8573a69d94e8bc9	11	5759	259	552	567	8	4	2023-11-22 21:38:53.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
569	\\x54d0e1c60608f78bcbf6255ba14ed084aaff58c34c0bca95218d9148b8177285	11	5772	272	553	568	13	4	2023-11-22 21:38:56.4	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
570	\\xc46d1c7c74d95309af5e7ec3dd26308f1beb10124428aef3c1a1f7524db483d9	11	5776	276	554	569	3	4	2023-11-22 21:38:57.2	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
571	\\x48632fe7bf675f57b967b36a1e85c842fee93fd9068fb7123caff16a48af1042	11	5784	284	555	570	4	4	2023-11-22 21:38:58.8	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
572	\\x2a95f0377b49cf6363fc2c4728af5fce6a5941c0d029f3eb0d326b84e5f34f44	11	5794	294	556	571	5	4	2023-11-22 21:39:00.8	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
573	\\xaff1d150f25ed56931858c6f4e6f2683158e830ee7d8d991f072993c81caf6d4	11	5796	296	557	572	6	4	2023-11-22 21:39:01.2	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
574	\\x3b13d2313cb7f622caf9e2b3512c4185862f08fd284983f7ef3b67006316b872	11	5797	297	558	573	27	4	2023-11-22 21:39:01.4	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
575	\\xe49e38ab2a1a7670f06084a0c4f7ffdf3e356ddbb7db277360546dce9d996fd0	11	5824	324	559	574	27	4	2023-11-22 21:39:06.8	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
576	\\xc9bd3e0aba3c25559ece2d2881f8a9d6e8c2306c5aa1d148529c4f203881d099	11	5843	343	560	575	3	4	2023-11-22 21:39:10.6	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
577	\\x978a84811d16980307b4d5e9c6d7598b90bf9fa96668628c2e9d3226dd419798	11	5844	344	561	576	5	4	2023-11-22 21:39:10.8	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
578	\\x2842e5ae4cd08e74d8e0432064ad4b70c7f91111f2dab94cdeeaa79ee6abdaa1	11	5854	354	562	577	27	4	2023-11-22 21:39:12.8	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
579	\\xf4c2889b7889b45a8bad4e75ce0a29a4d6a02327347415785c4999c417d478e5	11	5874	374	563	578	19	4	2023-11-22 21:39:16.8	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
580	\\x34c0954ed2c0bec43114e238a23f33460d3c3f895c3677321d50c55b8df07a68	11	5887	387	564	579	7	4	2023-11-22 21:39:19.4	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
581	\\x0410531993579e46610b2d9d4bfb8e9df43300801c9b4e7fe112959202a993fe	11	5895	395	565	580	4	4	2023-11-22 21:39:21	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
582	\\xaa9ea0c9626c229b3585485f223fffc30174baa0128ef83863dce7aaf8c90759	11	5899	399	566	581	8	4	2023-11-22 21:39:21.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
583	\\x7bc1b854fcdd0b610e991a266644d87099aa8e972450486b5dac649add49ac20	11	5905	405	567	582	27	4	2023-11-22 21:39:23	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
584	\\xf5dc2ceaa85799cab76fe4767f460fddd1772f0477f7c9efad0cc2df41f7483f	11	5913	413	568	583	27	4	2023-11-22 21:39:24.6	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
585	\\x117090ce92c5670817dbc5f434f09af3fa1b3661d6aa2435255cf77a4f159bca	11	5915	415	569	584	6	4	2023-11-22 21:39:25	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
586	\\x6a9877715ccb2ef6cd73ad7eb2c343851c9bff643956a92e6823af6e549701c6	11	5925	425	570	585	5	4	2023-11-22 21:39:27	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
587	\\x452340c3b40965814c649c0bc8b14feebde144ea3caa81440de425c6c9d3f2e1	11	5932	432	571	586	8	4	2023-11-22 21:39:28.4	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
588	\\xd33bdd790dba3475592f9929e820b00d7afb48f1cfdc9e1d0d6b5551fd6d74fb	11	5939	439	572	587	27	4	2023-11-22 21:39:29.8	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
589	\\xfd3e9f3b9f74e89f7284698317c1d6c0b66ebd1210b4f28531e4a25059fc4e85	11	5955	455	573	588	27	4	2023-11-22 21:39:33	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
590	\\x07086a763e111b30c420e04c9ffbed6226e6eb8a383c743374c7b4867fd85824	11	5969	469	574	589	19	4	2023-11-22 21:39:35.8	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
591	\\x592b113ca8010472c2265e93792c8390163e314a8e5612aa8d3e3c722125ac54	11	5987	487	575	590	3	4	2023-11-22 21:39:39.4	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
592	\\x0eaa1dc067a1f93801d71685df751584458e49f8103523a3b4a4ea2c8341d263	11	5989	489	576	591	3	4	2023-11-22 21:39:39.8	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
593	\\x1372fd343f5073e355790f76cf912335c23a57da5c017bae58b65c7aaf3f399a	12	6008	8	577	592	6	4	2023-11-22 21:39:43.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
594	\\x3e603366ad4c97e4a42463c4cbd25c8af6d01bf4632177941db7aca01cee0a5d	12	6011	11	578	593	5	4	2023-11-22 21:39:44.2	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
595	\\x61f2c59d3ebc106ede958d952478ac8d3f316de14a5099f124d60bf933955d9c	12	6016	16	579	594	13	4	2023-11-22 21:39:45.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
596	\\x3e5853550604a50066bbe681a50338ee8cb0d08843d1ba2a015e0f85d0b0580a	12	6021	21	580	595	27	4	2023-11-22 21:39:46.2	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
597	\\xcad677b6e1a6f6305b3e9ff6e825e6f0988e689a2968f82682389bca6b9be564	12	6065	65	581	596	5	4	2023-11-22 21:39:55	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
598	\\x48cc96beeceb4872c99fe73336b03755d8c3220367285590fbfe2105eb78fa71	12	6068	68	582	597	5	4	2023-11-22 21:39:55.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
599	\\x493ba03a12996393d25ccaa5c71a53eb4982dd682772de343963f557223ceafb	12	6121	121	583	598	7	4	2023-11-22 21:40:06.2	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
600	\\xd95c24f249c850e7f8263d4a02616700be4a1f489e31e23b0870adb13d31f94a	12	6143	143	584	599	4	4	2023-11-22 21:40:10.6	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
601	\\xf1bbf3887ababdd83d77b5d6c26a7cad42141dd03b653df7c2040f6f5d8aa367	12	6176	176	585	600	27	4	2023-11-22 21:40:17.2	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
602	\\x923c35ad88c878cd94ccd8aa035b00c4307bc67b1f36aa6f13d467d9e738eb8d	12	6188	188	586	601	6	4	2023-11-22 21:40:19.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
603	\\x8df7c0cb7b4e4838e729b5ee221fb1fd49f64bbf6547dfb3410f84dd4cfb2994	12	6203	203	587	602	6	4	2023-11-22 21:40:22.6	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
604	\\x20f3178c8c14e011c9aaaa9b24369433ea41e0ebd5142ef5ae07db5d5386e222	12	6214	214	588	603	4	4	2023-11-22 21:40:24.8	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
605	\\x9a3b07f9d5be1cd5bb0160cf6e0a8f8fa4b2343f258c9aeb9265576db8a11e9a	12	6217	217	589	604	13	4	2023-11-22 21:40:25.4	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
606	\\x1932fb8a836cbead7957f4a03cdd12d02a55833c8f0f2771678d8b9c403b61ad	12	6218	218	590	605	27	4	2023-11-22 21:40:25.6	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
607	\\xf7732c26fc39ff198d406e7cbfbc1e433313678c609b00908ad2f6140f05fbfd	12	6219	219	591	606	6	4	2023-11-22 21:40:25.8	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
608	\\xb71cf25b7e3a4d0befbb1b4049e5315df800a08f52692cf9bc8f4a26dc15c529	12	6237	237	592	607	5	4	2023-11-22 21:40:29.4	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
609	\\x9c74b2130b8005bbb7f6d34daad2111d349ce59d33b10e24848e7ea108d65e5c	12	6238	238	593	608	27	4	2023-11-22 21:40:29.6	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
610	\\xc64a8a1b2f3eb7fb9c4917a470527211c886958f6c8bd816e78c279823073a59	12	6240	240	594	609	8	4	2023-11-22 21:40:30	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
611	\\x87173a96f8bfdf186ab4cecc2995aa08a0862d2c7aeb47a6e78e2215b641f99c	12	6249	249	595	610	3	4	2023-11-22 21:40:31.8	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
612	\\xf968bd8af8196a0637b1b0f366100b7ca621c19f1726088a5ac460f4601ba932	12	6252	252	596	611	5	4	2023-11-22 21:40:32.4	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
613	\\x0becc49fbe32b2317a235f84eec7c2f628f92e4cd6bf4975eb6baedfacd5c15b	12	6257	257	597	612	5	4	2023-11-22 21:40:33.4	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
615	\\x818c185c8582d9d1c329ba7136df289d1354cc330f89b2e00c957531634a07b4	12	6266	266	598	613	3	4	2023-11-22 21:40:35.2	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
616	\\x6c7235dcdf48108827dcb9af0efb4a612744fd8eb87cda0a3b515566e15535a7	12	6278	278	599	615	27	4	2023-11-22 21:40:37.6	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
617	\\x5d08666d31cf349de8ccdf92cccb56f067f70096ca70608a468a44d8f7ab9af8	12	6279	279	600	616	19	4	2023-11-22 21:40:37.8	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
618	\\x1a447496f187b801daaa04c42c9c7d325095f2afd024e25cf334ea4e57afb971	12	6280	280	601	617	3	4	2023-11-22 21:40:38	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
619	\\x381126f2aa727e4e52ded05373ec4c5ba29aeb7f9ba7dd814f37ea88fd0983bc	12	6310	310	602	618	7	4	2023-11-22 21:40:44	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
620	\\x4c523096c9613ef2e528c971a90e51c8de641bf5518febcd80a94d64b71c8955	12	6322	322	603	619	27	4	2023-11-22 21:40:46.4	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
622	\\xa9a7d7494d4a8d68561dd89f358d3664c9fb0f45934be4b96980123abaa6c440	12	6332	332	604	620	13	4	2023-11-22 21:40:48.4	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
623	\\x286fd94908028cefd52b2d383dc0abcf644dbcfed1b57e2a1207454dd0ee8ee7	12	6337	337	605	622	8	4	2023-11-22 21:40:49.4	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
624	\\x4328bf2c7eaae313f33d087d68d999b3edf27f6121788f1b261daf4e758a39ce	12	6339	339	606	623	13	4	2023-11-22 21:40:49.8	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
625	\\x94aa7454c49a1b21e08c1282e038b98db58937c0172f58f64c9f112e2527c1e9	12	6342	342	607	624	27	4	2023-11-22 21:40:50.4	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
626	\\x94c4fda7107506e8871d60a50b8e5c835a5c5445a084d9d3f04119406845a400	12	6348	348	608	625	19	4	2023-11-22 21:40:51.6	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
627	\\x121c662b0fac036397857ba0d75de204bf92d7c0a55d98c301ec062722443d99	12	6352	352	609	626	4	4	2023-11-22 21:40:52.4	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
628	\\xf2ecb94710a1d3d8ede2d1542e2ac10d0e0e8463564ffc37b193fb741f8f908f	12	6354	354	610	627	27	4	2023-11-22 21:40:52.8	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
629	\\x93cd63ee9ab0728fc911a50ac2b355cda662980b356d7b395f81d8f4b3ac0e66	12	6363	363	611	628	5	4	2023-11-22 21:40:54.6	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
630	\\x81a7bee8324a8bebe0c10c308503a95f94849ccf1a35ea552087bc88d7a33f2c	12	6371	371	612	629	7	4	2023-11-22 21:40:56.2	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
631	\\x0a8034bde8286dc6799b2249cf2503f5c25db15ef6a0f09e13fcaacb9dae108c	12	6382	382	613	630	3	4	2023-11-22 21:40:58.4	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
632	\\x5ca5b68499c45beb17af5eb2e81d1173fbc10e32d2365bfff7291c6bdb876922	12	6450	450	614	631	6	4	2023-11-22 21:41:12	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
633	\\xddf2b75a2c5465c7541d5e7b91cb33c2e90445780a062c185b4ee2a9b952989e	12	6461	461	615	632	13	4	2023-11-22 21:41:14.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
634	\\x34b3f2c48dd1dd439c6b7c9c10b5b55a018e3f608500392ca3e39267dbeedba3	12	6474	474	616	633	6	4	2023-11-22 21:41:16.8	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
635	\\xaf8127415a72effbd72949fda4643eeeb2b596d61d0cd79767349a4f46090ea4	12	6489	489	617	634	6	4	2023-11-22 21:41:19.8	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
636	\\x396405868ee98ca03257a8ed9b80499df235bc3e020fdb1e27e619da1074237c	12	6490	490	618	635	7	4	2023-11-22 21:41:20	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
637	\\x383b6dc1dfd352c77d5d407d2138a447a6dbc8b7661e4655625bcf4b9172638a	13	6501	1	619	636	6	4	2023-11-22 21:41:22.2	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
638	\\xe16ad6a3fd5195038870231b3c6fe2aae48de8c5e12194d475fac06a7abf3a08	13	6507	7	620	637	19	1340	2023-11-22 21:41:23.4	1	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
639	\\x40f23ccc7abcea63ee48806db120b7aa9c80442ed75394085a090d85408b359d	13	6531	31	621	638	6	4	2023-11-22 21:41:28.2	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
640	\\x0229733870ed7d91cf9a8b541562b31298b96a381d7c7c50c52196c396874599	13	6532	32	622	639	27	4	2023-11-22 21:41:28.4	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
641	\\x7aec17c46e7f188e6c0667f155ffb8c7f37463838c05951f51d9d732d0941214	13	6544	44	623	640	8	4	2023-11-22 21:41:30.8	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
642	\\x64153a21fcb6e48761521109e8754b07bb4a1a03d5b2fc41feabd646525c1e3e	13	6556	56	624	641	27	1704	2023-11-22 21:41:33.2	1	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
643	\\xa8be7ee8dfeca22be2d41189ff80d6a7cdf4fee22218e6a9cfd50ea2e0f44841	13	6557	57	625	642	5	4	2023-11-22 21:41:33.4	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
644	\\xf4f56f51872cab155b23ede6213719053cb4c74adbf54ca537632e30a222181d	13	6567	67	626	643	19	4	2023-11-22 21:41:35.4	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
645	\\x17c3af8b2aee87e55b8b9c61770638d49aff5632a0cf01a6774d20847b9fce24	13	6571	71	627	644	13	4	2023-11-22 21:41:36.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
646	\\xb727fcdc62302a6629caea165c5a15754a72874950b6ebe6e95b812acc54d1a5	13	6572	72	628	645	4	4	2023-11-22 21:41:36.4	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
648	\\xe81607704b3b952ec7746d77d95392533246df26351c591548e298635c1febda	13	6583	83	629	646	13	4	2023-11-22 21:41:38.6	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
649	\\x7a5701ab39a477842a25010aa28e83caae2325dcdd8e81b6721f0ea9b31b5c29	13	6607	107	630	648	19	4	2023-11-22 21:41:43.4	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
650	\\x8664230fd4d6327e68d5bd3a307e46fc69abb9526b83bd2f51a62eb6a65d1288	13	6635	135	631	649	7	554	2023-11-22 21:41:49	1	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
651	\\x2fc6cd8d5e3d45ab920e5164052f4fec76e8c4540e66e4d9a941139d5eb15d79	13	6643	143	632	650	8	4	2023-11-22 21:41:50.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
652	\\x5d047eeb9667d5d258c75dfe4d1a4b1e05124bf74ee32c34ddc4c0192bf4da6e	13	6653	153	633	651	8	4	2023-11-22 21:41:52.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
653	\\xa16c648c775f21e962fed6fad050b81a032a70731911ce7f3dabe9213cb4956a	13	6667	167	634	652	6	4	2023-11-22 21:41:55.4	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
654	\\xeade50ec91d5c2c8270daacd9241241072de808000f3c4d6cd38e0d870bc0f83	13	6668	168	635	653	4	4	2023-11-22 21:41:55.6	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
655	\\xdf6619f32a24a00086888026eefac255364dbc4593c17e152537b79c2bacf2e5	13	6670	170	636	654	3	329	2023-11-22 21:41:56	1	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
656	\\x797a95da53b988f155fb56a394af68447c0be79bcf6ebad0a7e0ba698949dd0e	13	6671	171	637	655	5	4	2023-11-22 21:41:56.2	0	9	0	vrf_vk1w08ajz4prs88j6ehz95feyrxje2vtvatl4jaf6juh90sxrgdeefs5nchul	\\x99e34506970e8c877a826b7793a1e18600c932c787167466407e6b1eb072c47f	0
657	\\x87cb60b4267809cbf99fff4f0872548d4b5652d47a92f924e4583992f3ad5f37	13	6673	173	638	656	7	4	2023-11-22 21:41:56.6	0	9	0	vrf_vk1wn320u23hfctzzfae5yvn997wllt38fu6x49jfffnw6gkxly06mqhj0q4f	\\xf9484f0eebbb0cb878a2d639193ea8891117588343bea69cd3cfe935204f7814	0
658	\\x11e620e6b632f75606403db9dfaebd317f469e6705c92cf5ce15b39d636c15a1	13	6674	174	639	657	27	4	2023-11-22 21:41:56.8	0	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
659	\\x393513fd68620cee08f21350150d09cb2c1a734f09d98add1050fbedc1295057	13	6695	195	640	658	19	460	2023-11-22 21:42:01	1	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
660	\\x43ea67a3db0a78f9d70ad31daa4fa99f2d51507e8718e4fb7b23219b9dd86d51	13	6696	196	641	659	6	4	2023-11-22 21:42:01.2	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
661	\\x43d1b5a81a552798e39652f1f6ea100ef8ca25a352b962644e2a955d93f5135a	13	6718	218	642	660	3	4	2023-11-22 21:42:05.6	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
662	\\xb73eee33240f9aa2939eda53b2c16b5f8678b6878b4b42763068f92f0c521c61	13	6735	235	643	661	19	4	2023-11-22 21:42:09	0	9	0	vrf_vk1me5we59mtayfttr2gag32lg0755fq50qyc6rdgv6xt56afzph7fqdzx36h	\\x069e8dd7246711046c89b26540e47353f21c9421eb5068a8a506abd70922bf51	0
663	\\xb14aabc57f6e690aedbca42f313ee614913c0c0a1ead280e14dff1c82e2257c0	13	6740	240	644	662	13	594	2023-11-22 21:42:10	1	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
664	\\xa71625910dab0a13f025a9dddc4656f6db863b4c748745b63fbee9b269514018	13	6761	261	645	663	4	4	2023-11-22 21:42:14.2	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
665	\\x45ba3dc0933e3c714699a278164c4c528bcdea21f642b6e4b07ab36b4fd99a14	13	6780	280	646	664	6	4	2023-11-22 21:42:18	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
666	\\x8b15c9dbc26490970f5652b888280bea15d0eedf379b2b21ec50eb55f0545c55	13	6791	291	647	665	3	4	2023-11-22 21:42:20.2	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
667	\\x22b70de1bb37f1bda5f46c8de0fb29f31ac9faab2ba78d45ebd81c31a8b7d62d	13	6794	294	648	666	27	410	2023-11-22 21:42:20.8	1	9	0	vrf_vk1k0z4cx4wzqwuuan572uze0q70c2852npcqwlxcnt2cucg9eypg5q2dulry	\\xd1d6f86fb2022925881126d7bdc4c2970bc1616f7cfd57a99371d2bf560aa594	0
668	\\x157cb8b111e316bb06ebee229caf5ed3d0c8b81d1556cf1fd6b59c8b6c8a930e	13	6803	303	649	667	8	4	2023-11-22 21:42:22.6	0	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
669	\\x8ef9623a0320a98a8a6993876630791b6e3cd00fdadb0fd8cf91d3c19ff4e763	13	6808	308	650	668	4	4	2023-11-22 21:42:23.6	0	9	0	vrf_vk1s82qsj2jz85qx0f8ke3al74zgjx5wtprfevam7etqq97v2m80hqq3pe0tg	\\x8d25c81f94aaf5ae8051af28fa38bbe94b435dd386b1049aefbd0eadd9df6c2b	0
670	\\xf5708ee42d556e6dabe7a5aa941ee73f7b5b5fe5121f0cd06218f682405cebce	13	6811	311	651	669	13	4	2023-11-22 21:42:24.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
671	\\x4449435862194d2f36613763504e9d85da2dc9da297000506477ab29bf346d98	13	6837	337	652	670	8	528	2023-11-22 21:42:29.4	1	9	0	vrf_vk1kw0xxcjuadrgangefnqvkjvy4npp9j5g246gna7a5qw68w50z8xq35jzc9	\\x2b3a4f3a1ac3451f7fdf3ebb4f09fa1216a3331d9bf64546b041f002703fcb64	0
672	\\xec2b207c621b59e099d25446dc50fd569ec76e40a580b333033e5e88881e4865	13	6859	359	653	671	6	4	2023-11-22 21:42:33.8	0	9	0	vrf_vk1whq3vu487lm8jlknkjxqvpyl0pym0wrk4fvnyqzeehqce8mw2z9qk29t88	\\xbb8d66c56a781abdb2f514d11d0678585125bfeb43dd68748fbcb68b67c2c841	0
673	\\x1bfcd2dbaf3e0d1d86f1675e3a04cbfc9b3e3347885a0414971247831c1fb5c6	13	6876	376	654	672	13	4	2023-11-22 21:42:37.2	0	9	0	vrf_vk1jnt286x43ju800d0wl8zr6m2uqsf8kse8ut8c95l4luwzc4hm7ysn09hlg	\\xf5ef9ec5aaa4f3f1727b52a4cb77d06772f95674c6bb4b0b36c76d152e3555b7	0
674	\\xa6823fde938a47af5bc7295f84820171d2b8e470efd1c8fc170f8cbc5a1af45c	13	6892	392	655	673	3	4	2023-11-22 21:42:40.4	0	9	0	vrf_vk1jnjnu97w7w8tqh0rvn5myfgvxrsxmj2tk6j3flgp5vf0ewxmuhlqewfqnw	\\xc24998cfbcc929b74d328a5e7b6bfcb7b73a1ae644677e94a622510c80ee374e	0
\.


--
-- Data for Name: collateral_tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collateral_tx_in (id, tx_in_id, tx_out_id, tx_out_index) FROM stdin;
\.


--
-- Data for Name: collateral_tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collateral_tx_out (id, tx_id, index, address, address_raw, address_has_script, payment_cred, stake_address_id, value, data_hash, multi_assets_descr, inline_datum_id, reference_script_id) FROM stdin;
\.


--
-- Data for Name: committee_de_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.committee_de_registration (id, tx_id, cert_index, hot_key, voting_anchor_id) FROM stdin;
\.


--
-- Data for Name: committee_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.committee_registration (id, tx_id, cert_index, cold_key, hot_key) FROM stdin;
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
1	\\x81cb2989cbf6c49840511d8d3451ee44f58dde2c074fc749d05deb51eeb33741	123	{"fields": [{"map": [{"k": {"bytes": "636f7265"}, "v": {"map": [{"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "707265666978"}, "v": {"bytes": "24"}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 0}}, {"k": {"bytes": "7465726d736f66757365"}, "v": {"bytes": "68747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f"}}, {"k": {"bytes": "68616e646c65456e636f64696e67"}, "v": {"bytes": "7574662d38"}}]}}, {"k": {"bytes": "6e616d65"}, "v": {"bytes": "283130302968616e646c653638"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f736f6d652d68617368"}}, {"k": {"bytes": "77656273697465"}, "v": {"bytes": "68747470733a2f2f63617264616e6f2e6f72672f"}}, {"k": {"bytes": "6465736372697074696f6e"}, "v": {"bytes": "5468652048616e646c65205374616e64617264"}}, {"k": {"bytes": "6175676d656e746174696f6e73"}, "v": {"list": []}}]}, {"int": 1}, {"map": []}], "constructor": 0}	\\xd8799fa644636f7265a5426f67004670726566697841244776657273696f6e004a7465726d736f66757365583668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f4e68616e646c65456e636f64696e67457574662d38446e616d654d283130302968616e646c65363845696d61676550697066733a2f2f736f6d652d6861736847776562736974655468747470733a2f2f63617264616e6f2e6f72672f4b6465736372697074696f6e535468652048616e646c65205374616e646172644d6175676d656e746174696f6e738001a0ff
2	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	342	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "24706861726d65727332"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "6261736963"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 9}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c6574746572732c6e756d62657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "62675f696d616765"}, "v": {"bytes": "697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f"}}, {"k": {"bytes": "7066705f696d616765"}, "v": {"bytes": "697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b524244"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": "697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b"}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879"}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "01e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c980"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "312e31352e30"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "7066705f6173736574"}, "v": {"bytes": "e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e044503036383136"}}, {"k": {"bytes": "62675f6173736574"}, "v": {"bytes": "9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65"}}]}], "constructor": 0}	\\xd8799faa446e616d654a24706861726d6572733245696d6167655838697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e677468094a636861726163746572734f6c6574746572732c6e756d62657273516e756d657269635f6d6f64696669657273404776657273696f6e0101b34862675f696d6167655835697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f497066705f696d6167655835697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b52424446706f7274616c404864657369676e65725838697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b47736f6369616c73404676656e646f72404764656661756c74004e7374616e646172645f696d6167655838697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879536c6173745f7570646174655f61646472657373583901e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d4c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f686173685820bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de537374616e646172645f696d6167655f686173685820b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c9804b7376675f76657273696f6e46312e31352e304c6167726565645f7465726d7340546d6967726174655f7369675f726571756972656400446e7366770045747269616c00497066705f61737365745823e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e0445030363831364862675f6173736574582c9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65ff
\.


--
-- Data for Name: delegation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delegation (id, addr_id, cert_index, pool_hash_id, active_epoch_no, tx_id, slot_no, redeemer_id) FROM stdin;
1	1	1	2	2	34	0	\N
2	3	3	7	2	34	0	\N
3	5	5	5	2	34	0	\N
4	4	7	1	2	34	0	\N
5	8	9	11	2	34	0	\N
6	11	11	6	2	34	0	\N
7	2	13	4	2	34	0	\N
8	7	15	8	2	34	0	\N
9	10	17	9	2	34	0	\N
10	9	19	10	2	34	0	\N
11	6	21	3	2	34	0	\N
12	19	0	8	2	59	170	\N
13	34	0	8	2	60	189	\N
14	13	0	2	2	64	297	\N
15	35	0	2	2	65	326	\N
16	22	0	11	2	69	401	\N
17	36	0	11	2	70	413	\N
18	14	0	3	2	74	470	\N
19	37	0	3	2	75	487	\N
20	18	0	7	3	79	563	\N
21	38	0	7	3	80	570	\N
22	15	0	4	3	84	653	\N
23	39	0	4	3	85	660	\N
24	20	0	9	3	89	723	\N
25	40	0	9	3	90	752	\N
26	21	0	10	3	94	830	\N
27	41	0	10	3	95	837	\N
28	41	0	10	3	97	860	\N
29	17	0	6	3	101	952	\N
30	42	0	6	3	102	969	\N
31	42	0	6	4	104	1018	\N
32	16	0	5	4	108	1121	\N
33	43	0	5	4	109	1140	\N
34	43	0	5	4	111	1171	\N
35	12	0	1	4	115	1249	\N
36	44	0	1	4	116	1277	\N
37	44	0	1	4	118	1312	\N
38	68	1	7	7	133	2729	\N
39	68	1	9	7	137	2839	\N
41	76	1	7	11	240	4554	\N
42	70	0	12	15	345	6695	\N
43	67	0	13	15	348	6837	\N
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
1	84685305858933948	7311798	42	57	0	2023-11-22 21:19:42.6	2023-11-22 21:21:21.6
2	58906541643956811	4850579	27	49	1	2023-11-22 21:21:22.8	2023-11-22 21:23:00.4
23	0	0	0	42	10	2023-11-22 21:36:23	2023-11-22 21:38:00.2
7	0	0	0	56	4	2023-11-22 21:26:23	2023-11-22 21:28:01.8
20	5097153609067	610446	2	42	9	2023-11-22 21:34:42.4	2023-11-22 21:36:21.8
6	0	0	0	45	3	2023-11-22 21:24:44	2023-11-22 21:26:19
3	40507954924617499	3662372	20	37	2	2023-11-22 21:23:05.6	2023-11-22 21:24:39
30	20058890352634	1508720	8	37	13	2023-11-22 21:41:22.2	2023-11-22 21:42:40.4
18	0	0	0	53	8	2023-11-22 21:33:03	2023-11-22 21:34:41.4
13	6744646252340	16884852	100	46	7	2023-11-22 21:31:25.4	2023-11-22 21:33:00.2
12	0	0	0	46	6	2023-11-22 21:29:47	2023-11-22 21:31:21.6
28	0	0	0	42	12	2023-11-22 21:39:43.6	2023-11-22 21:41:20
8	30346709442296	7931545	14	55	5	2023-11-22 21:28:02.4	2023-11-22 21:29:39.8
25	501431163373350	20229512	100	49	11	2023-11-22 21:38:03.4	2023-11-22 21:39:39.8
\.


--
-- Data for Name: epoch_param; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_param (id, epoch_no, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, nonce, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, block_id, extra_entropy, coins_per_utxo_size, pvt_motion_no_confidence, pvt_committee_normal, pvt_committee_no_confidence, pvt_hard_fork_initiation, dvt_motion_no_confidence, dvt_committee_normal, dvt_committee_no_confidence, dvt_update_to_constitution, dvt_hard_fork_initiation, dvt_p_p_network_group, dvt_p_p_economic_group, dvt_p_p_technical_group, dvt_p_p_gov_group, dvt_treasury_withdrawal, committee_min_size, committee_max_term_length, gov_action_lifetime, gov_action_deposit, drep_deposit, drep_activity) FROM stdin;
1	1	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	0	0	\\x787469df93ae795b531ed95c2422f051be788eb2d987745fca141cd5ba706c00	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	60	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	2	0	0	0
2	2	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	0	0	\\x4330b78894915001b6dbe6743c9e2201b6381fb70ad4cf40a796d4505cb31d82	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	109	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	2	0	0	0
3	3	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	0	0	\\x249b0d6dd7a5e9cff99095564b751df8889b8491b17860f021e021b485d0e455	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	146	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	2	0	0	0
4	4	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	0	0	\\x8dc18f0e203cc4758ddb711c1daf1293eb8fd52bb3bebddf85047a31a8e8876d	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	193	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	2	0	0	0
5	5	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	0	0	\\x58199f969e7f7b7c1c0bdf74f35495e08c39a117eff12c0aecfb457ea3a6f8f6	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	249	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	2	0	0	0
7	6	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	0	0	\\x35721444341c916ab0ba10dd70e2f85fd3f4013b980e17dfa18e176da7d93679	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	305	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	2	0	0	0
8	7	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	0	0	\\x2632dc7d6837b86cc0a09da897654f51268ee7333de9b96bd6957f6bd2c19377	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	353	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	2	0	0	0
9	8	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	0	0	\\x0880ba7977b158024f81032d41c9dfd8565c9c2d8c93699c9d55f6db143e03ae	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	399	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	2	0	0	0
10	9	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	0	0	\\xb70339190e4759ee22ea8a79f96a482fbceeacb5d501bbadb1c15bf4449a7515	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	456	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	2	0	0	0
11	10	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	0	0	\\x6a7b5bfbfc270bb9bfae6dbacaab190deacf3e0093ceba1d13b527b7ca3197bb	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	499	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	2	0	0	0
12	11	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	0	0	\\x9881c3656d6dbfb09d459ad9a47cd56fff9ae91009beb7dea20943fae5186b2f	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	543	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	2	0	0	0
13	12	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	0	0	\\x0d8e5bff3be32a0eb6cb6b1992b48d4d2f7d1ab91e5f86a25a1682852ad631af	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	593	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	2	0	0	0
14	13	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	0	0	\\x747645ce1324be015a59ffdc1883c224ab33ffe162ddfd837a12c611a03830b7	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	637	\N	4310	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0.51	0	200	2	0	0	0
\.


--
-- Data for Name: epoch_stake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_stake (id, addr_id, pool_id, amount, epoch_no) FROM stdin;
1	1	2	7772727272727272	1
2	3	7	7772727272727272	1
3	5	5	7772727272727272	1
4	4	1	7772727272727272	1
5	8	11	7772727272727272	1
6	11	6	7772727272727272	1
7	2	4	7772727272727272	1
8	7	8	7772727272727280	1
9	10	9	7772727272727272	1
10	9	10	7772727272727272	1
11	6	3	7772727272727272	1
12	22	11	200000000	2
13	36	11	499999454261	2
14	14	3	500000000	2
15	1	2	7772727272727272	2
16	34	8	499999454261	2
17	3	7	7772727272727272	2
18	5	5	7772727272727272	2
19	13	2	600000000	2
20	4	1	7772727272727272	2
21	19	8	500000000	2
22	35	2	499999457033	2
23	8	11	7772727272727272	2
24	11	6	7772727272727272	2
25	2	4	7772727272727272	2
26	7	8	7772727272727280	2
27	10	9	7772727272727272	2
28	9	10	7772727272727272	2
29	37	3	499999454261	2
30	6	3	7772727272727272	2
31	22	11	200000000	3
32	36	11	499999454261	3
33	14	3	500000000	3
34	1	2	7772727272727272	3
35	18	7	500000000	3
36	38	7	499999454261	3
37	17	6	300000000	3
38	34	8	499999454261	3
39	3	7	7772727272727272	3
40	5	5	7772727272727272	3
41	13	2	600000000	3
42	4	1	7772727272727272	3
43	19	8	500000000	3
44	35	2	499999457033	3
45	21	10	300000000	3
46	8	11	7772727272727272	3
47	42	6	499999457033	3
48	11	6	7772727272727272	3
49	20	9	500000000	3
50	40	9	499999454261	3
51	2	4	7772727272727272	3
52	7	8	7772727272727280	3
53	10	9	7772727272727272	3
54	9	10	7772727272727272	3
55	15	4	500000000	3
56	39	4	499999454261	3
57	37	3	499999454261	3
58	41	10	499999276572	3
59	6	3	7772727272727272	3
60	22	11	200000000	4
61	36	11	499999454261	4
62	14	3	500000000	4
63	1	2	7778019806868219	4
64	18	7	500000000	4
65	38	7	499999454261	4
66	17	6	300000000	4
67	34	8	499999454261	4
68	3	7	7776255628821237	4
69	5	5	7783312341009167	4
70	13	2	600000000	4
71	4	1	7778019806868219	4
72	19	8	500000000	4
73	35	2	499999457033	4
74	16	5	500000000	4
75	21	10	300000000	4
76	8	11	7781548162962184	4
77	42	6	499999276572	4
78	11	6	7781548162962184	4
79	20	9	500000000	4
80	43	5	499999273756	4
81	40	9	499999454261	4
82	2	4	7781548162962184	4
83	7	8	7783312341009175	4
84	10	9	7779783984915202	4
85	9	10	7778019806868219	4
86	15	4	500000000	4
87	44	1	499999273756	4
88	39	4	499999454261	4
89	12	1	500000000	4
90	37	3	499999454261	4
91	41	10	499999276572	4
92	6	3	7785076519056149	4
93	22	11	200133512	5
94	36	11	500333234602	5
95	14	3	500445040	5
96	1	2	7784938169876877	5
97	18	7	500000000	5
98	38	7	499999454261	5
99	17	6	300000000	5
100	34	8	500221974471	5
101	3	7	7779715255914376	5
102	5	5	7788501781648875	5
103	13	2	600534049	5
104	4	1	7781479433961358	5
105	19	8	500222520	5
106	35	2	500444497445	5
107	16	5	500000000	5
108	21	10	300000000	5
109	8	11	7786736935752696	5
110	42	6	499999276572	5
111	11	6	7786737603601892	5
112	20	9	500000000	5
113	43	5	499999273756	5
114	40	9	499999454261	5
115	2	4	7786737603601892	5
116	7	8	7786771522602509	5
117	10	9	7793622493287758	5
118	9	10	7783209247507927	5
119	15	4	500000000	5
120	44	1	499999273756	5
121	39	4	499999454261	5
122	12	1	500000000	5
123	37	3	500444494681	5
124	41	10	499999276572	5
125	6	3	7791994882242818	5
126	22	11	200133512	6
127	36	11	500333234602	6
128	14	3	1279025730980	6
129	1	2	7786386383449340	6
130	18	7	500548125	6
131	38	7	500547578739	6
132	17	6	300263100	6
133	34	8	500408315470	6
134	3	7	7788236109375470	6
135	5	5	7797023732490506	6
136	13	2	256574206563	6
137	4	1	7796818945476295	6
138	19	8	512116036883	6
139	35	2	500537657281	6
140	16	5	500000000	6
141	21	10	300263100	6
142	8	11	7786736935752696	6
143	42	6	500437776179	6
144	11	6	7793554286721540	6
145	20	9	500657750	6
146	43	5	499999273756	6
147	40	9	500657203634	6
148	2	4	7788441774294110	6
149	7	8	7789668281300625	6
150	10	9	7803847517441072	6
151	9	10	7790025930627891	6
152	15	4	500109625	6
153	44	1	499999273756	6
154	39	4	500109079156	6
155	12	1	500000000	6
156	37	3	500910380257	6
157	41	10	500437776021	6
158	6	3	7799237293204998	6
159	22	11	200133512	7
160	36	11	500333234602	7
161	14	3	3072722214506	7
162	1	2	7788928816702037	7
163	18	7	898540124065	7
164	38	7	500874622138	7
165	17	6	300263100	7
166	34	8	500898002109	7
167	3	7	7793322461082107	7
168	13	2	705657970751	7
169	4	1	7804297665467065	7
170	19	8	1857788873155	7
171	35	2	500701094155	7
172	8	11	7786736935752696	7
173	42	6	500437776179	7
174	11	6	7793554286721540	7
175	20	9	1795434088804	7
176	40	9	501310718596	7
177	2	4	7796066270284268	7
178	7	8	7797291057754947	7
179	10	9	7814015939011982	7
180	15	4	1346486432747	7
181	44	1	500480032953	7
182	39	4	500598987302	7
183	12	1	500480759	7
184	37	3	501563008096	7
185	68	9	4999966677030	7
186	6	3	7809398819632952	7
187	22	11	200133512	8
188	36	11	500333234602	8
189	14	3	3969835139565	8
190	1	2	7792743086223918	8
191	18	7	2470745960410	8
192	38	7	501447031934	8
193	17	6	300263100	8
194	34	8	501469629254	8
195	3	7	7802228841262197	8
196	13	2	1379197972881	8
197	4	1	7809385729779161	8
198	19	8	3428570344671	8
199	35	2	500946289447	8
200	8	11	7786736935752696	8
201	42	6	500437776179	8
202	11	6	7793554286721540	8
203	20	9	2468223990033	8
204	40	9	501555150238	8
205	2	4	7803693370573959	8
206	7	8	7806189367322211	8
207	10	9	7817825959057758	8
208	15	4	2692932309846	8
209	44	1	500806966729	8
210	39	4	501088736177	8
211	12	1	898842261718	8
212	37	3	501889351474	8
213	68	9	4999966677030	8
214	6	3	7814480034355952	8
215	22	11	200133512	9
216	36	11	500333234602	9
217	14	3	5183072961515	9
218	1	2	7799621172612116	9
219	18	7	3199302576088	9
220	38	7	501712209383	9
221	17	6	300263100	9
222	34	8	501999593355	9
223	3	7	7806354851805741	9
224	13	2	2593712590267	9
225	4	1	7816255066395768	9
226	19	8	4885530548480	9
227	35	2	501388438227	9
228	8	11	7786736935752696	9
229	42	6	500437776179	9
230	11	6	7793554286721540	9
231	20	9	3679836159712	9
232	40	9	501995456766	9
233	2	4	7809194675314942	9
234	7	8	7814439119424230	9
235	10	9	7824689108110698	9
236	15	4	3664213547039	9
237	44	1	501247487836	9
238	39	4	501441984301	9
239	12	1	2111546392516	9
240	37	3	502330258100	9
241	68	9	4999949792178	9
242	6	3	7821345005693672	9
243	22	11	200133512	10
244	36	11	500333234602	10
245	14	3	5965161601189	10
246	1	2	7807377672775548	10
247	18	7	4177600340569	10
248	38	7	502068062164	10
249	17	6	300263100	10
250	34	8	502283924968	10
251	3	7	7811891717422868	10
252	13	2	3963811457323	10
253	4	1	7818467009302413	10
254	19	8	5668284933197	10
255	35	2	501887054687	10
256	8	11	7786736935752696	10
257	42	6	500437776179	10
258	11	6	7793554286721540	10
259	20	9	5630711958731	10
260	40	9	502702967821	10
261	2	4	7815835871504105	10
262	7	8	7818865202857892	10
263	10	9	7835717203986483	10
264	15	4	4838014040555	10
265	44	1	501389337020	10
266	39	4	501868427069	10
267	12	1	2502304457485	10
268	37	3	502613998061	10
269	68	9	5007006357242	10
270	6	3	7825762872416573	10
271	22	11	200133512	11
272	36	11	500333234602	11
273	14	3	7418756110802	11
274	1	2	7813553795332031	11
275	18	7	4541498710580	11
276	38	7	502200162742	11
277	17	6	300263100	11
278	34	8	502811749556	11
279	3	7	7813947126817546	11
280	13	2	5055461478018	11
281	4	1	7822576048488460	11
282	19	8	7122974936619	11
283	35	2	502284078641	11
284	8	11	7786736935752696	11
285	42	6	500437776179	11
286	11	6	7793554286721540	11
287	20	9	6900170752794	11
288	40	9	503163041642	11
289	2	4	7820973627785540	11
290	7	8	7827081649983460	11
291	10	9	7842888453380060	11
292	15	4	5747220966494	11
293	44	1	501652844999	11
294	39	4	502198331343	11
295	12	1	3228421922219	11
296	37	3	503141072704	11
297	76	7	2503503091250	11
298	68	9	2508089097887	11
299	6	3	7833969490594440	11
300	22	11	200133512	12
301	36	11	500333234602	12
302	14	3	8366926802492	12
303	1	2	7821065376448697	12
304	18	7	5680104550841	12
305	38	7	502613539321	12
306	17	6	300263100	12
307	34	8	502880495217	12
308	3	7	7820379029824306	12
309	13	2	6384448566362	12
310	4	1	7826859639228455	12
311	19	8	7313012040147	12
312	35	2	502766950801	12
313	8	11	7786736935752696	12
314	42	6	500437776179	12
315	11	6	7793554286721540	12
316	20	9	7657301875474	12
317	40	9	503437100534	12
318	2	4	7824187854346265	12
319	7	8	7828151787874907	12
320	10	9	7847160256241936	12
321	15	4	6316648160908	12
322	44	1	501927546768	12
323	39	4	502404722425	12
324	12	1	3986149592960	12
325	37	3	503484480678	12
326	76	7	2503503091250	12
327	68	9	2510818765422	12
328	6	3	7839316395749035	12
329	22	11	200133512	13
330	36	11	500333234602	13
331	14	3	8928752136598	13
332	1	2	7826356170312525	13
333	18	7	6616960586519	13
334	38	7	502953362258	13
335	17	6	300263100	13
336	34	8	503151878101	13
337	3	7	7825666480246506	13
338	13	2	7321728256152	13
339	4	1	7831087791458111	13
340	19	8	8062555667296	13
341	35	2	503107062559	13
342	8	11	7786736935752696	13
343	42	6	500437776179	13
344	11	6	7793554286721540	13
345	20	9	8217958249337	13
346	40	9	503639670720	13
347	2	4	7826301204288992	13
348	7	8	7832376303301176	13
349	10	9	7850317752404611	13
350	15	4	6691555235557	13
351	44	1	502198693329	13
352	39	4	502540424303	13
353	12	1	4734323979743	13
354	37	3	503687773330	13
355	76	7	0	13
356	68	9	5016319260383	13
357	6	3	7842481687794414	13
358	22	11	200133512	14
359	36	11	500333234602	14
360	14	3	10038476816266	14
361	1	2	7834711701585206	14
362	18	7	7727304671102	14
363	38	7	503355887552	14
364	17	6	300263100	14
365	34	8	503486588928	14
366	3	7	7831929543460304	14
367	13	2	8803078711281	14
368	4	1	7838393830456832	14
369	19	8	8988050932141	14
370	35	2	503644186950	14
371	8	11	7786736935752696	14
372	42	6	500437776179	14
373	11	6	7793554286721540	14
374	20	9	8956588653331	14
375	40	9	503906388882	14
376	2	4	7828387482359555	14
377	7	8	7837586621029612	14
378	10	9	7854475134060076	14
379	15	4	7061949236522	14
380	44	1	502667221244	14
381	39	4	502674387849	14
382	12	1	6027645006942	14
383	37	3	504088958658	14
384	76	7	2006616868	14
385	68	9	5017648755717	14
386	6	3	7848728193589704	14
\.


--
-- Data for Name: epoch_stake_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_stake_progress (id, epoch_no, completed) FROM stdin;
\.


--
-- Data for Name: epoch_sync_time; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_sync_time (id, no, seconds, state) FROM stdin;
1	0	11	lagging
2	1	1	lagging
3	2	1	following
4	3	74	following
5	4	100	following
6	5	105	following
7	6	99	following
8	7	98	following
9	8	100	following
10	9	101	following
11	10	101	following
12	11	101	following
13	12	99	following
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
-- Data for Name: governance_action; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.governance_action (id, tx_id, index, deposit, return_address, voting_anchor_id, type, description, param_proposal, ratified_epoch, enacted_epoch, dropped_epoch, expired_epoch, expiration) FROM stdin;
\.


--
-- Data for Name: ma_tx_mint; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ma_tx_mint (id, quantity, tx_id, ident) FROM stdin;
1	13500000000000000	120	1
2	13500000000000000	120	2
3	13500000000000000	120	3
4	13500000000000000	120	4
5	2	122	5
6	1	122	6
7	1	122	7
8	1	123	8
9	1	342	9
10	1	342	10
11	1	342	11
\.


--
-- Data for Name: ma_tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ma_tx_out (id, quantity, tx_out_id, ident) FROM stdin;
1	13500000000000000	141	1
2	13500000000000000	141	2
3	13500000000000000	141	3
4	13500000000000000	141	4
5	2	149	5
6	1	149	6
7	1	149	7
8	1	151	8
9	1	1434	9
10	1	1434	10
11	1	1434	11
12	1	1443	8
13	13500000000000000	1445	1
14	13500000000000000	1445	2
15	13500000000000000	1445	3
16	13500000000000000	1445	4
17	2	1447	5
18	1	1447	6
19	1	1447	7
\.


--
-- Data for Name: meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meta (id, start_time, network_name, version) FROM stdin;
1	2023-11-22 21:19:42	testnet	Version {versionBranch = [13,1,1,3], versionTags = []}
\.


--
-- Data for Name: multi_asset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.multi_asset (id, policy, name, fingerprint) FROM stdin;
1	\\xed83c1218dd788b04657538041a5ad15293b0c713bc7a60f624e651a	\\x	asset109zcfqjn63wgd4urj6dlfyjnuv272gdrd2jgke
2	\\xed83c1218dd788b04657538041a5ad15293b0c713bc7a60f624e651a	\\x74425443	asset1frt6yyfpdl0mg9dk5m607dt7runemk9lturug8
3	\\xed83c1218dd788b04657538041a5ad15293b0c713bc7a60f624e651a	\\x74455448	asset1u3mtawcgu2zh5mhh6eqph5at9lcfpx7z5xzxf8
4	\\xed83c1218dd788b04657538041a5ad15293b0c713bc7a60f624e651a	\\x744d494e	asset1fwhxr3twetk773459mp6gxn3pf6tfwy6gcu52g
5	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x446f75626c6548616e646c65	asset1ss4nvcah07l2492qrfydamvukk4xdqme8k22vv
6	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x48656c6c6f48616e646c65	asset13xe953tueyajgxrksqww9kj42erzvqygyr3phl
7	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x5465737448616e646c65	asset1ne8rapyhga8jp95pemrefrgts9ht035zlmy6zj
8	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x283232322968616e646c653638	asset1ju4qkyl4p9xszrgfxfmu909q90luzqu0nyh4u8
9	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x000643b068616e646c6532	asset1vjzkdxns6ze7ph4880h3m3zghvesral9ryp2zq
10	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x000de14068616e646c6532	asset1050jtqadfpvyfta8l86yrxgj693xws6l0qa87c
11	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x68616e646c6531	asset1q0g92m9xjj3nevsw26hfl7uf74av7yce5l56jv
\.


--
-- Data for Name: new_committee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.new_committee (id, governance_action_id, quorum, deleted_members, added_members) FROM stdin;
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
1	\\x24c636313afe85a5a3c9497cc64987ee7b578325b425d257839bef08	pool1ynrrvvf6l6z6tg7ff97vvjv8aea40qe9ksjay4urn0hssj95pgk
2	\\x63ef4d4583506aae3b8f723b6cecea450f6701fd0ea64ec718ffe1b0	pool1v0h563vr2p42uwu0wgakem82g58kwq0ap6nya3ccllsmql07ezn
3	\\x6c7227f00f18985f90f987dddaa950ee2cb315107eef44a278df0267	pool1d3ez0uq0rzv9ly8eslwa422sacktx9gs0mh5fgncmupxwgvkf77
4	\\x70b3a58e1a9e386579187b63846f3f7300fc536a96ba3235e33b39fb	pool1wze6trs6ncux27gc0d3cgmelwvq0c5m2j6aryd0r8vulkavsdqj
5	\\xa860a2b02d06e6960923e1de27028f8849b4dd92c0f1c550b2ac823f	pool14ps29vpdqmnfvzfru80zwq503pymfhvjcrcu259j4jpr70susa4
6	\\xad8b2c5c69599455e4e6fc9c56b1ebe108c4c4383dd79301f600d72b	pool14k9jchrftx29te8xljw9dv0tuyyvf3pc8htexq0kqrtjk5vyyhv
7	\\xae0f374ebdaa66166205e9ea9551cff3219990c82435990a724b6f80	pool14c8nwn4a4fnpvcs9a84f25w07vsenyxgys6ejznjfdhcqn2xrku
8	\\xcdb5370bec7fb2d1b8e0e94073c0d27e947698dbfc43df2d97dd6fbf	pool1ek6nwzlv07edrw8qa9q88sxj0628dxxml3pa7tvhm4hm7ql4an4
9	\\xd92618e7570364165223512b374ed5928366045f2593db59bc2389c7	pool1mynp3e6hqdjpv53r2y4nwnk4j2pkvpzlykfakkduywyuw789dfy
10	\\xda47b6338e0b2da38f76901cd5b77c069430514cbdf058a6b10489bc	pool1mfrmvvuwpvk68rmkjqwdtdmuq62rq52vhhc93f43qjymcwsydvp
11	\\xef1b1c5a3ecb23c75d386f614a99b39058b1ae6d462434a510351036	pool1aud3ck37ev3uwhfcdas54xdnjpvtrtndgcjrffgsx5grvl28fvv
12	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
13	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_metadata_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata_ref (id, pool_id, url, hash, registered_tx_id) FROM stdin;
1	8	http://file-server/SP1.json	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	61
2	11	http://file-server/SP3.json	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	71
3	3	http://file-server/SP4.json	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	76
4	7	http://file-server/SP5.json	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	81
5	4	http://file-server/SP6.json	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	86
6	9	http://file-server/SP7.json	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	91
7	5	http://file-server/SP10.json	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	110
8	1	http://file-server/SP11.json	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	117
\.


--
-- Data for Name: pool_offline_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_offline_data (id, pool_id, ticker_name, hash, json, bytes, pmr_id) FROM stdin;
1	8	SP1	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	{"name": "stake pool - 1", "ticker": "SP1", "homepage": "https://stakepool1.com", "description": "This is the stake pool 1 description."}	\\x7b0a2020226e616d65223a20227374616b6520706f6f6c202d2031222c0a2020227469636b6572223a2022535031222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2031206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c312e636f6d220a7d0a	1
2	11	SP3	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	{"name": "Stake Pool - 3", "ticker": "SP3", "homepage": "https://stakepool3.com", "description": "This is the stake pool 3 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2033222c0a2020227469636b6572223a2022535033222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2033206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c332e636f6d220a7d0a	2
3	3	SP4	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	{"name": "Same Name", "ticker": "SP4", "homepage": "https://stakepool4.com", "description": "This is the stake pool 4 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535034222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2034206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c342e636f6d220a7d0a	3
4	7	SP5	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	{"name": "Same Name", "ticker": "SP5", "homepage": "https://stakepool5.com", "description": "This is the stake pool 5 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535035222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2035206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c352e636f6d220a7d0a	4
5	4	SP6a7	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	{"name": "Stake Pool - 6", "ticker": "SP6a7", "homepage": "https://stakepool6.com", "description": "This is the stake pool 6 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2036222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2036206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c362e636f6d220a7d0a	5
6	9	SP6a7	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	{"name": "", "ticker": "SP6a7", "homepage": "https://stakepool7.com", "description": "This is the stake pool 7 description."}	\\x7b0a2020226e616d65223a2022222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2037206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c372e636f6d220a7d0a	6
7	5	SP10	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	{"name": "Stake Pool - 10", "ticker": "SP10", "homepage": "https://stakepool10.com", "description": "This is the stake pool 10 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130222c0a2020227469636b6572223a202253503130222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203130206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31302e636f6d220a7d0a	7
8	1	SP11	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	{"name": "Stake Pool - 10 + 1", "ticker": "SP11", "homepage": "https://stakepool11.com", "description": "This is the stake pool 11 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130202b2031222c0a2020227469636b6572223a202253503131222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203131206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31312e636f6d220a7d0a	8
\.


--
-- Data for Name: pool_offline_fetch_error; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_offline_fetch_error (id, pool_id, fetch_time, pmr_id, fetch_error, retry_count) FROM stdin;
\.


--
-- Data for Name: pool_owner; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_owner (id, addr_id, pool_update_id) FROM stdin;
1	19	12
2	13	13
3	22	14
4	14	15
5	18	16
6	15	17
7	20	18
8	21	19
9	17	20
10	16	21
11	12	22
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
1	10	0	98	5
2	6	0	105	18
3	5	0	112	5
4	1	0	119	18
\.


--
-- Data for Name: pool_update; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_update (id, hash_id, cert_index, vrf_key_hash, pledge, active_epoch_no, meta_id, margin, fixed_cost, registered_tx_id, reward_addr_id) FROM stdin;
1	1	0	\\x865791ee4e86a7940c03ac69bc3a2864b36bcf65ee5819ba9b7a47bc1272b949	0	2	\N	0	0	34	12
2	2	1	\\xb77cd36464ea31a71ec3c8964231ec9f3b92d33733cba8d9328adc78e790c3fc	0	2	\N	0	0	34	13
3	3	2	\\x24186b236ca5558a2c6e3f0048b47e4ffcb75091e6dca6964301920a2f26587f	0	2	\N	0	0	34	14
4	4	3	\\x72a7904ad7bd7b8526809329a51873cb931670e014889233d741ff9e74fbf0c9	0	2	\N	0	0	34	15
5	5	4	\\x219c3f9b1fcb24b02e06dfea38fe92ee27d6b8d67b9d172099a3ce315c9f974b	0	2	\N	0	0	34	16
6	6	5	\\x8500221ec6d9ace43294765319da4b7ad0d33fb24f5750646250d08cc65b94e6	0	2	\N	0	0	34	17
7	7	6	\\x9057558dcc1f2a5736c72ef1b92588573e7cff5a29513309a8424301bbf009ac	0	2	\N	0	0	34	18
8	8	7	\\x9c55fa2bba0abd059da9a3e15d6b939231152be15c479cb2e467ba68cae35954	0	2	\N	0	0	34	19
9	9	8	\\xdb692743c0994ab4eb78732c87e2bf6090121c1fb3cd6767c65505db39dfdd2e	0	2	\N	0	0	34	20
10	10	9	\\xfc1548a4651e9339edfe0a673f02244603b90a309e2230bfd108d10c9a597625	0	2	\N	0	0	34	21
11	11	10	\\x7ce6f0deb73d49544fefb0bb900e136924be06de52ddf6e79b189368d9318d26	0	2	\N	0	0	34	22
12	8	0	\\x9c55fa2bba0abd059da9a3e15d6b939231152be15c479cb2e467ba68cae35954	400000000	3	1	0.15	390000000	61	19
13	2	0	\\xb77cd36464ea31a71ec3c8964231ec9f3b92d33733cba8d9328adc78e790c3fc	500000000	3	\N	0.15	390000000	66	13
14	11	0	\\x7ce6f0deb73d49544fefb0bb900e136924be06de52ddf6e79b189368d9318d26	600000000	3	2	0.15	390000000	71	22
15	3	0	\\x24186b236ca5558a2c6e3f0048b47e4ffcb75091e6dca6964301920a2f26587f	420000000	3	3	0.15	370000000	76	14
16	7	0	\\x9057558dcc1f2a5736c72ef1b92588573e7cff5a29513309a8424301bbf009ac	410000000	4	4	0.15	390000000	81	18
17	4	0	\\x72a7904ad7bd7b8526809329a51873cb931670e014889233d741ff9e74fbf0c9	410000000	4	5	0.15	400000000	86	15
18	9	0	\\xdb692743c0994ab4eb78732c87e2bf6090121c1fb3cd6767c65505db39dfdd2e	410000000	4	6	0.15	390000000	91	20
19	10	0	\\xfc1548a4651e9339edfe0a673f02244603b90a309e2230bfd108d10c9a597625	500000000	4	\N	0.15	380000000	96	21
20	6	0	\\x8500221ec6d9ace43294765319da4b7ad0d33fb24f5750646250d08cc65b94e6	500000000	4	\N	0.15	390000000	103	17
21	5	0	\\x219c3f9b1fcb24b02e06dfea38fe92ee27d6b8d67b9d172099a3ce315c9f974b	400000000	5	7	0.15	410000000	110	16
22	1	0	\\x865791ee4e86a7940c03ac69bc3a2864b36bcf65ee5819ba9b7a47bc1272b949	400000000	5	8	0.15	390000000	117	12
23	12	0	\\x2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	500000000000000	15	\N	0.2	1000	343	70
24	13	0	\\x641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	50000000	15	\N	0.2	1000	346	67
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
\.


--
-- Data for Name: redeemer_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.redeemer_data (id, hash, tx_id, value, bytes) FROM stdin;
\.


--
-- Data for Name: reference_tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reference_tx_in (id, tx_in_id, tx_out_id, tx_out_index) FROM stdin;
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
3	5	7:46:
4	6	11:54:
5	7	::
6	8	::
7	9	::
8	10	::
9	11	12:56:
10	12	18:62:
11	13	::
12	14	::
13	15	::
14	16	23:67:
15	17	::
16	18	::
17	19	24:69:
18	20	25:70:
19	21	::
20	22	26:71:
21	23	::
22	24	::
23	25	27:72:
24	26	::
25	27	28:73:
26	28	29:75:
27	29	30:76:
28	30	::
29	31	31:77:
30	32	::
31	33	::
32	34	32:78:
33	35	33:79:
34	36	::
35	37	34:81:
36	38	::
37	39	::
38	40	35:82:
39	41	::
40	42	36:83:
41	43	::
42	44	::
43	45	37:84:
44	46	::
45	47	38:85:
46	48	::
47	49	::
48	50	39:87:
49	51	::
50	52	::
51	53	40:88:
52	54	::
53	55	::
54	56	41:89:
55	57	::
56	58	42:90:
57	59	::
58	60	::
59	61	43:91:
60	62	44:93:
61	63	45:94:
62	64	46:95:
63	65	::
64	66	47:96:
65	67	48:97:
66	68	::
67	69	49:99:
68	70	50:100:
69	71	51:101:
70	72	::
71	73	52:102:
72	74	::
73	75	::
74	76	53:103:
75	77	54:105:
76	78	::
77	79	::
78	80	::
79	81	55:106:
80	82	::
81	83	::
82	84	56:107:
83	85	::
84	86	57:108:
85	87	58:109:
86	88	59:111:
87	89	60:112:
88	90	::
89	91	61:113:
90	92	::
91	93	62:114:
92	94	::
93	95	::
94	96	63:115:
95	97	64:116:
96	98	::
97	99	65:117:
98	100	66:119:
99	101	::
100	102	67:120:
101	103	::
102	104	::
103	105	68:121:
104	106	69:122:
105	107	::
106	108	::
107	109	70:123:
108	110	71:124:
109	111	::
110	112	::
111	113	72:125:
112	114	73:127:
113	115	::
114	116	74:128:
115	117	75:129:
116	118	76:130:
117	119	77:131:
118	120	::
119	121	78:132:
120	122	79:133:
121	123	::
122	124	::
123	125	::
124	126	80:135:
125	127	::
126	128	::
127	129	81:136:
128	130	82:137:
129	131	83:138:
130	132	::
131	133	84:139:
132	134	::
133	135	85:140:
134	136	::
135	137	86:141:1
136	138	87:143:
137	139	88:149:5
138	140	89:151:8
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
180	182	::
181	183	::
182	184	::
183	185	::
184	186	::
185	187	::
186	188	::
187	189	::
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
249	251	90:153:
250	252	::
251	253	::
252	254	::
253	255	::
254	256	::
255	257	::
256	258	::
257	259	::
258	260	93:157:
259	261	::
260	262	::
261	263	::
262	264	94:159:
263	265	96:161:
264	266	::
265	267	99:163:
266	268	100::
267	269	::
268	270	::
269	271	101:165:
270	272	::
271	273	102:285:
272	274	::
273	275	::
274	276	::
275	277	162:287:
276	278	163:289:
277	279	::
278	280	164:290:
279	281	::
280	282	::
281	283	::
282	284	165:292:
283	285	::
284	286	::
285	287	166:294:
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
331	333	::
332	334	::
333	335	::
334	336	::
335	337	::
336	338	::
337	339	::
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
352	354	167:295:
353	355	176:313:
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
436	438	::
437	439	::
438	440	::
439	441	::
441	443	::
442	444	::
443	445	::
444	446	::
445	447	::
446	448	::
447	449	::
448	450	::
450	452	::
451	453	::
452	454	::
453	455	::
454	456	::
455	457	296:495:
456	458	::
457	459	::
458	460	::
460	462	432:511:
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
486	488	::
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
503	505	::
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
516	518	::
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
539	541	::
540	542	::
541	543	::
542	544	567:525:
543	545	896:849:
544	546	950:903:
545	547	1094:1047:
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
578	580	::
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
613	615	::
614	616	::
615	617	::
616	618	::
617	619	::
618	620	::
620	622	::
621	623	::
622	624	::
623	625	::
624	626	::
625	627	::
626	628	::
627	629	::
628	630	::
629	631	::
630	632	::
631	633	::
632	634	::
633	635	::
634	636	::
635	637	::
636	638	1472:1425:
637	639	::
638	640	::
639	641	::
640	642	1481:1434:9
641	643	::
642	644	::
643	645	::
644	646	::
646	648	::
647	649	::
648	650	1482:1436:
649	651	::
650	652	::
651	653	::
652	654	::
653	655	1483:1438:
654	656	::
655	657	::
656	658	::
657	659	1484:1440:
658	660	::
659	661	::
660	662	::
661	663	1485:1442:12
662	664	::
663	665	::
664	666	::
665	667	1486:1444:13
666	668	::
667	669	::
668	670	::
669	671	1487:1446:17
670	672	::
671	673	::
672	674	::
\.


--
-- Data for Name: reward; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward (id, addr_id, type, amount, earned_epoch, spendable_epoch, pool_id) FROM stdin;
1	1	member	5292534140947	1	3	2
2	3	member	3528356093965	1	3	7
3	5	member	10585068281895	1	3	5
4	4	member	5292534140947	1	3	1
5	8	member	8820890234912	1	3	11
6	22	leader	0	1	3	11
7	14	leader	0	1	3	3
8	18	leader	0	1	3	7
9	17	leader	0	1	3	6
10	13	leader	0	1	3	2
11	19	leader	0	1	3	8
12	16	leader	0	1	3	5
13	21	leader	0	1	3	10
14	11	member	8820890234912	1	3	6
15	20	leader	0	1	3	9
16	2	member	8820890234912	1	3	4
17	7	member	10585068281895	1	3	8
18	10	member	7056712187930	1	3	9
19	9	member	5292534140947	1	3	10
20	15	leader	0	1	3	4
21	12	leader	0	1	3	1
22	6	member	12349246328877	1	3	3
23	22	member	133512	2	4	11
24	36	member	333780341	2	4	11
25	14	member	445040	2	4	3
26	1	member	6918363008658	2	4	2
27	34	member	222520210	2	4	8
28	3	member	3459627093139	2	4	7
29	5	member	5189440639708	2	4	5
31	13	member	534049	2	4	2
32	22	leader	0	2	4	11
33	14	leader	0	2	4	3
34	18	leader	0	2	4	7
35	17	leader	0	2	4	6
36	13	leader	0	2	4	2
37	4	member	3459627093139	2	4	1
38	19	leader	0	2	4	8
39	19	member	222520	2	4	8
40	35	member	445040412	2	4	2
41	16	leader	0	2	4	5
42	21	leader	0	2	4	10
43	8	member	5188772790512	2	4	11
44	11	member	5189440639708	2	4	6
45	20	leader	0	2	4	9
46	2	member	5189440639708	2	4	4
47	7	member	3459181593334	2	4	8
48	10	member	13838508372556	2	4	9
49	9	member	5189440639708	2	4	10
50	15	leader	0	2	4	4
51	12	leader	0	2	4	1
52	37	member	445040420	2	4	3
53	6	member	6918363186669	2	4	3
54	1	member	1448213572463	3	5	2
55	18	member	548125	3	5	7
56	38	member	548124478	3	5	7
57	17	member	263100	3	5	6
58	34	member	186340999	3	5	8
59	3	member	8520853461094	3	5	7
60	5	member	8521950841631	3	5	5
61	22	leader	0	3	5	11
62	14	leader	1278525285940	3	5	3
63	18	leader	0	3	5	7
64	17	leader	0	3	5	6
65	13	leader	255973672514	3	5	2
66	4	member	15339511514937	3	5	1
67	19	leader	511615814363	3	5	8
68	35	member	93159836	3	5	2
69	16	leader	0	3	5	5
70	21	leader	0	3	5	10
71	21	member	263100	3	5	10
72	42	member	438499607	3	5	6
73	11	member	6816683119648	3	5	6
74	20	leader	0	3	5	9
75	20	member	657750	3	5	9
76	40	member	657749373	3	5	9
77	2	member	1704170692218	3	5	4
78	7	member	2896758698116	3	5	8
79	10	member	10225024153314	3	5	9
80	9	member	6816683119964	3	5	10
81	15	leader	0	3	5	4
82	15	member	109625	3	5	4
83	39	member	109624895	3	5	4
84	12	leader	0	3	5	1
85	37	member	465885576	3	5	3
86	41	member	438499449	3	5	10
87	6	member	7242410962180	3	5	3
88	1	member	2542433252697	4	6	2
89	38	member	327043399	4	6	7
90	34	member	489686639	4	6	8
91	22	leader	0	4	6	11
92	14	leader	1793696483526	4	6	3
93	18	leader	898039575940	4	6	7
94	17	leader	0	4	6	6
95	3	member	5086351706637	4	6	7
96	5	member	5978908183027	4	6	5
97	13	leader	449083764188	4	6	2
98	4	member	7478719990770	4	6	1
99	19	leader	1345672836272	4	6	8
100	35	member	163436874	4	6	2
101	16	leader	0	4	6	5
102	16	member	384085	4	6	5
103	21	leader	0	4	6	10
104	20	leader	1794933431054	4	6	9
105	43	member	384084515	4	6	5
106	40	member	653514962	4	6	9
107	2	member	7624495990158	4	6	4
108	7	member	7622776454322	4	6	8
109	10	member	10168421570910	4	6	9
110	15	leader	1345986323122	4	6	4
111	44	member	480759197	4	6	1
112	39	member	489908146	4	6	4
113	12	leader	0	4	6	1
114	12	member	480759	4	6	1
115	37	member	652627839	4	6	3
116	6	member	10161526427954	4	6	3
143	1	member	3814269521881	5	7	2
144	38	member	572409796	5	7	7
145	34	member	571627145	5	7	8
146	3	member	8906380180090	5	7	7
147	22	leader	0	5	7	11
148	14	leader	897112925059	5	7	3
149	18	leader	1572205836345	5	7	7
150	17	leader	0	5	7	6
151	5	member	6354412184323	5	7	5
152	13	leader	673540002130	5	7	2
153	4	member	5088064312096	5	7	1
154	19	leader	1570781471516	5	7	8
155	35	member	245195292	5	7	2
156	16	leader	1121849324488	5	7	5
157	21	leader	0	5	7	10
158	20	leader	672789901229	5	7	9
159	43	member	407934871	5	7	5
160	40	member	244431642	5	7	9
161	2	member	7627100289691	5	7	4
162	7	member	8898309567264	5	7	8
163	10	member	3810020045776	5	7	9
164	15	leader	1346445877099	5	7	4
165	44	member	326933776	5	7	1
166	39	member	489748875	5	7	4
167	12	leader	898341780959	5	7	1
168	37	member	326343378	5	7	3
169	6	member	5081214723000	5	7	3
170	1	member	6878086388198	6	8	2
171	38	member	265177449	6	8	7
172	34	member	529964101	6	8	8
173	3	member	4126010543544	6	8	7
174	5	member	1373549060020	6	8	5
175	22	leader	0	6	8	11
176	14	leader	1213237821950	6	8	3
177	18	leader	728556615678	6	8	7
178	17	leader	0	6	8	6
179	13	leader	1214514617386	6	8	2
180	4	member	6869336616607	6	8	1
181	19	leader	1456960203809	6	8	8
182	35	member	442148780	6	8	2
183	16	leader	242816658011	6	8	5
184	21	leader	0	6	8	10
185	20	leader	1211612169679	6	8	9
186	43	member	88081498	6	8	5
187	40	member	440306528	6	8	9
188	2	member	5501304740983	6	8	4
189	7	member	8249752102019	6	8	8
190	10	member	6863149052940	6	8	9
191	15	leader	971281237193	6	8	4
192	44	member	440521107	6	8	1
193	39	member	353248124	6	8	4
194	12	leader	1212704130798	6	8	1
195	37	member	440906626	6	8	3
196	6	member	6864971337720	6	8	3
197	1	member	7756500163432	7	9	2
198	38	member	355852781	7	9	7
199	34	member	284331613	7	9	8
200	3	member	5536865617127	7	9	7
202	4	member	2211942906645	7	9	1
203	22	leader	0	7	9	11
204	14	leader	782088639674	7	9	3
205	18	leader	978297764481	7	9	7
206	17	leader	0	7	9	6
207	13	leader	1370098867056	7	9	2
208	19	leader	782754384717	7	9	8
209	35	member	498616460	7	9	2
210	20	leader	1950875799019	7	9	9
211	40	member	707511055	7	9	9
212	2	member	6641196189163	7	9	4
213	7	member	4426083433662	7	9	8
214	10	member	11028095875785	7	9	9
215	15	leader	1173800493516	7	9	4
216	44	member	141849184	7	9	1
217	39	member	426442768	7	9	4
218	12	leader	390758064969	7	9	1
219	37	member	283739961	7	9	3
220	68	member	7056565064	7	9	9
221	6	member	4417866722901	7	9	3
222	1	member	6176122556483	8	10	2
223	38	member	132100578	8	10	7
224	22	leader	0	8	10	11
225	14	leader	1453594509613	8	10	3
226	18	leader	363898370011	8	10	7
227	17	leader	0	8	10	6
228	34	member	527824588	8	10	8
229	3	member	2055409394678	8	10	7
230	13	leader	1091650020695	8	10	2
231	4	member	4109039186047	8	10	1
232	19	leader	1454690003422	8	10	8
233	35	member	397023954	8	10	2
234	20	leader	1269458794063	8	10	9
235	40	member	460073821	8	10	9
236	2	member	5137756281435	8	10	4
237	7	member	8216447125568	8	10	8
238	10	member	7171249393577	8	10	9
239	15	leader	909206925939	8	10	4
240	44	member	263507979	8	10	1
241	39	member	329904274	8	10	4
242	12	leader	726117464734	8	10	1
243	37	member	527074643	8	10	3
244	68	member	4586442341	8	10	9
245	6	member	8206618177867	8	10	3
246	1	member	7511581116666	9	11	2
247	38	member	413376579	9	11	7
248	22	leader	0	9	11	11
249	14	leader	948170691690	9	11	3
250	18	leader	1138605840261	9	11	7
251	17	leader	0	9	11	6
252	34	member	68745661	9	11	8
253	3	member	6431903006760	9	11	7
254	13	leader	1328987088344	9	11	2
255	4	member	4283590739995	9	11	1
256	19	leader	190037103528	9	11	8
257	35	member	482872160	9	11	2
258	20	leader	757131122680	9	11	9
259	40	member	274058892	9	11	9
260	2	member	3214226560725	9	11	4
261	7	member	1070137891447	9	11	8
262	10	member	4271802861876	9	11	9
263	15	leader	569427194414	9	11	4
264	44	member	274701769	9	11	1
265	39	member	206391082	9	11	4
266	12	leader	757727670741	9	11	1
267	37	member	343407974	9	11	3
268	68	member	2729667535	9	11	9
269	6	member	5346905154595	9	11	3
270	1	member	5290793863828	10	12	2
271	38	member	339822937	10	12	7
272	34	member	271382884	10	12	8
273	3	member	5287450422200	10	12	7
274	22	leader	0	10	12	11
275	14	leader	561825334106	10	12	3
276	18	leader	936856035678	10	12	7
277	17	leader	0	10	12	6
278	13	leader	937279689790	10	12	2
279	4	member	4228152229656	10	12	1
280	19	leader	749543627149	10	12	8
281	35	member	340111758	10	12	2
282	20	leader	560656373863	10	12	9
283	40	member	202570186	10	12	9
284	2	member	2113349942727	10	12	4
285	7	member	4224515426269	10	12	8
286	10	member	3157496162675	10	12	9
287	15	leader	374907074649	10	12	4
288	44	member	271146561	10	12	1
289	39	member	135701878	10	12	4
290	12	leader	748174386783	10	12	1
291	37	member	203292652	10	12	3
292	68	member	2017633223	10	12	9
293	6	member	3165292045379	10	12	3
294	1	member	8355531272681	11	13	2
295	22	leader	0	11	13	11
296	14	leader	1109724679668	11	13	3
297	18	leader	1110344084583	11	13	7
298	38	member	402525294	11	13	7
299	17	leader	0	11	13	6
300	34	member	334710827	11	13	8
301	3	member	6263063213798	11	13	7
302	13	leader	1481350455129	11	13	2
303	4	member	7306038998721	11	13	1
304	19	leader	925495264845	11	13	8
305	35	member	537124391	11	13	2
306	20	leader	738630403994	11	13	9
307	40	member	266718162	11	13	9
308	2	member	2086278070563	11	13	4
309	7	member	5210317728436	11	13	8
310	10	member	4157381655465	11	13	9
311	15	leader	370394000965	11	13	4
312	44	member	468527915	11	13	1
313	39	member	133963546	11	13	4
314	12	leader	1293321027199	11	13	1
315	37	member	401185328	11	13	3
316	76	member	2006616868	11	13	7
317	68	member	1329495334	11	13	9
318	6	member	6246505795290	11	13	3
\.


--
-- Data for Name: schema_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_version (id, stage_one, stage_two, stage_three) FROM stdin;
1	11	30	6
\.


--
-- Data for Name: script; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.script (id, tx_id, hash, type, json, bytes, serialised_size) FROM stdin;
1	120	\\xed83c1218dd788b04657538041a5ad15293b0c713bc7a60f624e651a	timelock	{"type": "sig", "keyHash": "22d78ce7b4220cfffbe10b1fd6b5d94d2256f8a0ad43089582aad862"}	\N	\N
2	122	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	timelock	{"type": "sig", "keyHash": "5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967"}	\N	\N
\.


--
-- Data for Name: slot_leader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slot_leader (id, hash, pool_hash_id, description) FROM stdin;
1	\\xbc08eff8efe06e69da94b956363895a7928b16b9912408d75ca643cd	\N	Genesis slot leader
2	\\x5368656c6c65792047656e6573697320536c6f744c65616465722048	\N	Shelley Genesis slot leader
5	\\xae0f374ebdaa66166205e9ea9551cff3219990c82435990a724b6f80	7	Pool-ae0f374ebdaa6616
7	\\x6c7227f00f18985f90f987dddaa950ee2cb315107eef44a278df0267	3	Pool-6c7227f00f18985f
19	\\x70b3a58e1a9e386579187b63846f3f7300fc536a96ba3235e33b39fb	4	Pool-70b3a58e1a9e3865
27	\\x63ef4d4583506aae3b8f723b6cecea450f6701fd0ea64ec718ffe1b0	2	Pool-63ef4d4583506aae
4	\\xad8b2c5c69599455e4e6fc9c56b1ebe108c4c4383dd79301f600d72b	6	Pool-ad8b2c5c69599455
8	\\xd92618e7570364165223512b374ed5928366045f2593db59bc2389c7	9	Pool-d92618e757036416
6	\\xcdb5370bec7fb2d1b8e0e94073c0d27e947698dbfc43df2d97dd6fbf	8	Pool-cdb5370bec7fb2d1
36	\\xa860a2b02d06e6960923e1de27028f8849b4dd92c0f1c550b2ac823f	5	Pool-a860a2b02d06e696
13	\\x24c636313afe85a5a3c9497cc64987ee7b578325b425d257839bef08	1	Pool-24c636313afe85a5
3	\\xef1b1c5a3ecb23c75d386f614a99b39058b1ae6d462434a510351036	11	Pool-ef1b1c5a3ecb23c7
9	\\xda47b6338e0b2da38f76901cd5b77c069430514cbdf058a6b10489bc	10	Pool-da47b6338e0b2da3
\.


--
-- Data for Name: stake_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_address (id, hash_raw, view, script_hash) FROM stdin;
1	\\xe002a359cf42f6abed91d352a587b82bda723f7df1247da7dba9d7011b	stake_test1uqp2xkw0gtm2hmv36df2tpac90d8y0ma7yj8mf7m48tszxc0sfs29	\N
3	\\xe02cca73ef22f1d79c33de8743be9e920c0074d949a3b9a57bfaa53b13	stake_test1uqkv5ul0ytca08pnm6r58057jgxqqaxefx3mnftml2jnkyc0rhtw9	\N
5	\\xe031837b4fbb22565aac0e86404cff1aaf6eb99315eee016667750a6d9	stake_test1uqccx760hv39vk4vp6ryqn8lr2hkawvnzhhwq9nxwag2dkgxyxc0n	\N
4	\\xe04450c6d1725985b20d501d2dc173c0f059e654ec0c0f50b7c5c01636	stake_test1upz9p3k3wfvctvsd2qwjmstncrc9nej5asxq759hchqpvds6q72ve	\N
8	\\xe07de466fcf7eca71f4665a7e9cd6985aba3825b692d6ef729e564a0fe	stake_test1up77gehu7lk2w86xvkn7nntfsk468qjmdykkaaefu4j2pls5fh37m	\N
11	\\xe09378fc8c70952d55b9bb35c08e8b6f4abaac3d43153ce89f2e5502a5	stake_test1uzfh3lyvwz2j64dehv6upr5tda9t4tpagv2ne6yl9e2s9fgdfj9cd	\N
2	\\xe0a0e60ec886cb4a8b06e5521c67560c4c5b507273ddfba615d00acef6	stake_test1uzswvrkgsm954zcxu4fpce6kp3x9k5rjw0wlhfs46q9vaasv39g6u	\N
7	\\xe0a7bef75be06997a34220bbcb6b66a681a8b94ef60c03793d432476a7	stake_test1uznmaa6mup5e0g6zyzauk6mx56q63w2w7cxqx7fagvj8dfcz6h7le	\N
10	\\xe0bad62cb834138603b04bc5468abdf3184cd5b4abadeb3973d516b1a5	stake_test1uzadvt9cxsfcvqasf0z5dz4a7vvye4d54wk7kwtn65ttrfgz4qpuz	\N
9	\\xe0c0f47b0b62836d796636f541f8304db89c76951f1f12b805f6f7bbde	stake_test1urq0g7ctv2pk67txxm65r7psfkufca54ru039wq97mmmhhs66hy6k	\N
6	\\xe0fb2a816883dd321792c0e48507045768c5c8a5de49ddc797ef57d171	stake_test1uraj4qtgs0wny9ujcrjg2pcy2a5vtj99meyam3uhaatazugjl3kr2	\N
34	\\xe028e3bd18db3d7524a5687836ac83004ef558ff9984bafe598a031705	stake_test1uq5w80gcmv7h2f99dpurdtyrqp802k8lnxzt4lje3gp3wpgd3pr5z	\N
35	\\xe06a6494acb251045274873afc111ab2119afb437521ae663e2a15bd3c	stake_test1up4xf99vkfgsg5n5sua0cyg6kgge476rw5s6ue379g2m60qqyflzg	\N
36	\\xe000b5304c184735960a8645ca24403808a184c25a8c3a35b1bbdfa1a9	stake_test1uqqt2vzvrprnt9s2sezu5fzq8qy2rpxzt2xr5dd3h006r2g3le3df	\N
37	\\xe0e577e43534c1078f4a302a4d78e24be380a96da2303b758408cdad76	stake_test1urjh0ep4xnqs0r62xq4y678zf03cp2td5gcrkavyprx66asw6s483	\N
38	\\xe017328dc0197dbc337cb70c8482afe47c1ddad5f4f1c6b2800d1d7280	stake_test1uqtn9rwqr97mcvmukuxgfq40u37pmkk47ncudv5qp5wh9qqdty6s3	\N
39	\\xe0d867f4370d89488ee8a181e6bb81ee526736290d9b8a6f3fcecba809	stake_test1urvx0aphpky53rhg5xq7dwupaefxwd3fpkdc5melem96szge9lkk9	\N
40	\\xe09c433f19669dc6d438fdf9d0baee1f4cc4a5012545ac33112a5a5fe9	stake_test1uzwyx0cev6wud4pclhuapwhwraxvffgpy4z6cvc39fd9l6g5gs9w2	\N
41	\\xe0f185b054ad0ac1f8ca1c1d415e85bd3ec637cac98beaeae2226dcd9f	stake_test1urcctvz5459vr7x2rsw5zh59h5lvvd72ex9746hzyfkum8crgrtr3	\N
42	\\xe092310ccf411e0350198ee6745a6d798332964d1d44487953c4cc4840	stake_test1uzfrzrx0gy0qx5qe3mn8gknd0xpn99jdr4zys72ncnxyssqa8p7tn	\N
43	\\xe09b940b86c343e5bddff3d24b3cd259caddb74359d02500d532aa9f0f	stake_test1uzdegzuxcdp7t0wl70fyk0xjt89dmd6rt8gz2qx4x24f7rcwe2pls	\N
44	\\xe0cd181f2507dd92bfb33b9ee1fc4b651c9fd7529b5e6446ff751fa576	stake_test1urx3s8e9qlwe90an8w0wrlztv5wfl46jnd0xg3hlw5062asluauf6	\N
19	\\xe04855befc76b9c8deff957c74c7bfcaf4ed2adce11881630b9e9254fd	stake_test1upy9t0huw6uu3hhlj478f3alet6w62kuuyvgzcctn6f9flg9mg76c	\N
13	\\xe0420c0a965820a7e8de6b635f5b7e2bbe0636fca5f3e3d09699065ae7	stake_test1uppqcz5ktqs206x7dd347km79wlqvdhu5he785yknyr94ec88thga	\N
22	\\xe000695e02eabfd36e73db520454b497a0551df17b69be4102917c3c33	stake_test1uqqxjhsza2laxmnnmdfqg495j7s928030d5musgzj97rcvcld8u7u	\N
14	\\xe0018e8fbf8ca91c718e91dde0d16cb02926e1f708b01bdef09ddefb1d	stake_test1uqqcaral3j53cuvwj8w7p5tvkq5jdc0hpzcphhhsnh00k8g5wpfs0	\N
18	\\xe00d1eeb75092b78efc67f03d211230efdcd622594ba3f5177ab74b2ad	stake_test1uqx3a6m4py4h3m7x0upayyfrpm7u6c39jjar75th4d6t9tg3rwx8d	\N
15	\\xe0c4cbf0c5fdb6b665eaa717529d07a98a6e5ddce7d85854a9a4b4baf4	stake_test1urzvhux9lkmtve025ut498g84x9xuhwuulv9s49f5j6t4aqmr8y54	\N
20	\\xe09a6236a651784627f12e6171fd8225469162ca07bf93c41b9d0a2011	stake_test1uzdxyd4x29uyvfl39eshrlvzy4rfzck2q7le83qmn59zqygyat708	\N
21	\\xe073c5492af85211fdcc200fba1b8b7702c78728b379ff25f7a13d55f1	stake_test1upeu2jf2lpfprlwvyq8m5xutwupv0pegkdul7f0h5y74tug4zcz5y	\N
17	\\xe027eec155f57e0d117fc7815d9f38e22dce34bb2a4ab99dc8cdcfe698	stake_test1uqn7as2474lq6ytlc7q4m8ecugkuud9m9f9tn8wgeh87dxqd9aq6s	\N
16	\\xe06d57b8f6bbbdde2ffdf035e7fec5020341ffcc3e801a34142d40c8b4	stake_test1upk40w8khw7autla7q670lk9qgp5rl7v86qp5dq594qv3dqmzan6u	\N
12	\\xe0d98bd0ce5666d723d1efe72d88849da5152294e9c96ee70b2154a20b	stake_test1urvch5xw2endwg73alnjmzyynkj32g55a8ykaecty922yzcuqmz2q	\N
69	\\xe01bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	stake_test1uqdlrcfc7tuta27fv0y5es5wark5kst5gcql9md02zepalg9yxxuz	\N
71	\\xe09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j	\N
72	\\xe0ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	stake_test1uzh8se0dq68kua2e9zaal86j8fdm7wnn6kszzldk9zjjycq46ca0t	\N
73	\\xe07d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	stake_test1up73dx2qeg7gv59739gpmycmxzffyqk3ha2ctmh9ghdgneqmy000q	\N
68	\\xe0f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	stake_test1urc4mvzl2cp4gedl3yq2px7659krmzuzgnl2dpjjgsydmqqxgamj7	\N
76	\\xe0f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	stake_test1urcqjef42euycw37mup524mf4j5wqlwylwwm9wzjp4v42ksjgsgcy	\N
70	\\xe0e0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	\N
67	\\xe0a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	\N
\.


--
-- Data for Name: stake_deregistration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_deregistration (id, addr_id, cert_index, epoch_no, tx_id, redeemer_id) FROM stdin;
1	68	0	5	134	\N
\.


--
-- Data for Name: stake_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_registration (id, addr_id, cert_index, epoch_no, tx_id) FROM stdin;
1	1	0	0	34
2	3	2	0	34
3	5	4	0	34
4	4	6	0	34
5	8	8	0	34
6	11	10	0	34
7	2	12	0	34
8	7	14	0	34
9	10	16	0	34
10	9	18	0	34
11	6	20	0	34
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
23	19	0	0	58
24	13	0	0	63
25	22	0	0	68
26	14	0	0	73
27	18	0	1	78
28	15	0	1	83
29	20	0	1	88
30	21	0	1	93
31	17	0	1	100
32	16	0	2	107
33	12	0	2	114
34	68	0	5	133
35	68	0	5	137
37	76	0	9	240
38	70	0	13	344
39	67	0	13	347
\.


--
-- Data for Name: treasury; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.treasury (id, addr_id, cert_index, amount, tx_id) FROM stdin;
\.


--
-- Data for Name: treasury_withdrawal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.treasury_withdrawal (id, governance_action_id, stake_address_id, amount) FROM stdin;
\.


--
-- Data for Name: tx; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx (id, hash, block_id, block_index, out_sum, fee, deposit, size, invalid_before, invalid_hereafter, valid_contract, script_size) FROM stdin;
1	\\xfaae66a65183959065909644bfd88ceb053d620fc4477fd78dafd4f774ce8aa3	1	0	910909092	0	0	0	\N	\N	t	0
2	\\x739a2852b6385f89110ceae36ceec2e0ea820fd64fa501ef2eebb819565be40e	1	0	910909092	0	0	0	\N	\N	t	0
3	\\x4934792271e0c2353c65e759ad8bd4898a5fb17f496f5e8882e201ac09cc7786	1	0	910909092	0	0	0	\N	\N	t	0
4	\\x891c5578472157b23174098995494632d2c82607b93a6ad878b87558c1733a01	1	0	910909092	0	0	0	\N	\N	t	0
5	\\x5a8862345bd2e0c22b30cc0510d611623fa3a622438da5d393b125f5c0c1dae7	1	0	910909092	0	0	0	\N	\N	t	0
6	\\x354b20fd4dd801f6efd73fd836ba851ed847901c478f861709da42e73a983a3c	1	0	910909092	0	0	0	\N	\N	t	0
7	\\x4787cf8e421902c22038ddd6d5af6f7a66a173c10737dccb017bf708e8e4c48a	1	0	910909092	0	0	0	\N	\N	t	0
8	\\xe3e43042c8ea9e4aec855dfa152f6892d8d0fc4b06fb959b4f16dc6ff7677814	1	0	910909092	0	0	0	\N	\N	t	0
9	\\x91eb873105686c0ca7e2226c6af0ada21d7c7b60723afd6329fa182d3aeade82	1	0	910909092	0	0	0	\N	\N	t	0
10	\\x6a2e9f67cc906704be2079c4de09f7866fe8dc2577e6676ef09f61daa18db8cf	1	0	910909092	0	0	0	\N	\N	t	0
11	\\x76cd4d5df79a07e768ab6a6d1af149763d658ba6385729b5c8a651780cc3cd95	1	0	910909092	0	0	0	\N	\N	t	0
12	\\x0b074d4bf550129c2ce8e68b19119c76c0d5150e6e537085226a4cbdbe87c411	2	0	3681818181818181	0	0	0	\N	\N	t	0
13	\\x174c42b2e12363390c823f6d9ecfa5bb0567642a6fe39861b85aa75deac1b829	2	0	3681818181818181	0	0	0	\N	\N	t	0
14	\\x17ee9ea4468cb671715d9de072dc7108765cecf16b1f020754be4b2779362dc5	2	0	3681818181818181	0	0	0	\N	\N	t	0
15	\\x22424719e395ed62548a1baf01545e41357e424c25167ce27c24ba41bc80768b	2	0	7772727272727272	0	0	0	\N	\N	t	0
16	\\x28dcdda533908e7c078e2e822328aaae2928b6f1ac53bfcd5e63f122c74b996f	2	0	3681818181818190	0	0	0	\N	\N	t	0
17	\\x297797ee069b9619849359ec646ed5f836fc9b6eb9dc6af101cfc1a83c7310d1	2	0	7772727272727272	0	0	0	\N	\N	t	0
18	\\x2a7bb16c17738c29737aec593bb3e4e36b995273c9335e7b63007054bfe7632b	2	0	3681818181818181	0	0	0	\N	\N	t	0
19	\\x434cefd319f9a01bdb13266c08383a41c6b0a48be50593da229da9e0c219657e	2	0	7772727272727272	0	0	0	\N	\N	t	0
20	\\x45ee2be2694ea0bb6a7313d916b47a178178b3a63433da05549a1b6b96ac1033	2	0	7772727272727272	0	0	0	\N	\N	t	0
21	\\x473e5f377585f744b14aa0c0ad11969fd2cf32e0268932b4483df1c3fcebb9e6	2	0	3681818181818181	0	0	0	\N	\N	t	0
22	\\x691fca2c80cb2ddf851c43c138c236e77fe23aacc4ecc222fad4e1b618187168	2	0	7772727272727272	0	0	0	\N	\N	t	0
23	\\x6ba40c82dd26e058756f006155959a1749840fd47f377d72943d7d7f7bdd47e4	2	0	7772727272727272	0	0	0	\N	\N	t	0
24	\\x6cd80ddae63749ef119208317418b840cda783f3ecf77edd429bd6d6d9f478ce	2	0	7772727272727280	0	0	0	\N	\N	t	0
25	\\x9b0a63447e89dbacfe8ccdf476cb580fe0426d504dfe90ee045c973dd0dbf088	2	0	7772727272727272	0	0	0	\N	\N	t	0
26	\\xb4b5366240c074d3836756d34c8c0e1b2c1a995aceef18861e5aa4e2d65ff6fc	2	0	3681818181818181	0	0	0	\N	\N	t	0
27	\\xb91a137c217c2650c9226f9180cdf3beabf8565ef62e322c9fa1f0e29d40bbbc	2	0	3681818181818181	0	0	0	\N	\N	t	0
28	\\xbaa7ea326837456804d39b3e89073d46220f453230e68d07d15f8962489e6bf7	2	0	3681818181818181	0	0	0	\N	\N	t	0
29	\\xbf045ac986b4d4ca6a93bef0be322d320a3ee5b55877edec6e04e29dea486929	2	0	3681818181818181	0	0	0	\N	\N	t	0
30	\\xcf15f535c49e6b6d9ff0902e0b375b179feb4947efd83f7f11b3d3134eb81fff	2	0	7772727272727272	0	0	0	\N	\N	t	0
31	\\xd256c2b3f4568e83265f78ce195a62a17f04a3b31dbdc2dcb1bbcfcecd4c171e	2	0	3681818181818181	0	0	0	\N	\N	t	0
32	\\xe2feff40fb61e37473fc9cfbeed70409c4647b710651db84c517dc7603520967	2	0	7772727272727272	0	0	0	\N	\N	t	0
33	\\xfc88dac2c3c6f1828a5b150d0e06525e63cbc5399bd1c75c5c26db8142f8210e	2	0	7772727272727272	0	0	0	\N	\N	t	0
34	\\x5368656c6c65792047656e65736973205374616b696e67205478204861736820	2	0	0	0	0	0	\N	\N	t	0
35	\\x882a3e7915a546421851551868cb44824acbb6839a1b8b39e4fed4fd2a85736b	4	0	3681818181651228	166953	0	263	\N	\N	t	0
36	\\x5399c1d861f9bb79274b77fb42380e844dafac0a75f1a80f0e261664319e309d	4	1	3681818181651228	166953	0	263	\N	\N	t	0
37	\\x6dfa44b55c186e17ddb993f4b1cd4ba65da36faa2a42f16d965014d049d71c72	4	2	3681818181651228	166953	0	263	\N	\N	t	0
38	\\x1cfbf4f1631f0b184dfa48906276d3954aaf25b9b6f637d810cfad9a743dc8cb	4	3	3681818181651228	166953	0	263	\N	\N	t	0
39	\\xf680b25da83b9e16eefc273a1f599723b26b03416805ce6457027e979431671f	4	4	3681818181651228	166953	0	263	\N	\N	t	0
40	\\xa5b46feb0a6f2c3f75715b4d509adf01edfa004abd8e4754be8a50f263e4408a	4	5	3681818181651228	166953	0	263	\N	\N	t	0
41	\\x01a989c684279b55244252e8acff5e497a536f8ef643f46037fb23baacb323f0	5	0	3681818181651228	166953	0	263	\N	\N	t	0
42	\\xd24373a1fcce7290627f7c19ffc3bcc39103f1cc24c665c820e487f31fb4129d	5	1	3681818181651228	166953	0	263	\N	\N	t	0
43	\\x498f51757e0b8f6e7838a7b8d601ae79735f30d0311159850121b9b458d75579	5	2	3681818181651228	166953	0	263	\N	\N	t	0
44	\\x66bdf1e8a23a6837c7035a2f68bffba67c33bb5ef1dc53d2fc8c89bcdb1bef9b	5	3	3681818181651228	166953	0	263	\N	\N	t	0
45	\\x9ad10cf85600c9f3c60e8b2162d64d0b8a35235fb6706212854a72f9dd31694d	6	0	3681818181651237	166953	0	263	\N	\N	t	0
46	\\x90538425958938e70d425c465ab7e31718880913e663dcab1a9364bb553e4d62	11	0	499999828647	171353	0	363	\N	\N	t	0
47	\\xcbdfa5f002e0e6ed2b609412e658fb524764737fe77efd1e27be0ffcf3488985	11	1	499999828647	171353	0	363	\N	\N	t	0
48	\\x7baf56735c6190560a0549e06406e1152ceca28c73dd5040d1870d77b2144b01	11	2	499999828647	171353	0	363	\N	\N	t	0
49	\\x357d51d4e289578bf2dc195a1f8658734c335e83ea53beb66e0ff0906aeef0f1	11	3	499999828647	171353	0	363	\N	\N	t	0
50	\\x441943b9163edb43fe1ba2a544b166d09e1bbeb8da017267f0291d9bd618ac36	11	4	499999828647	171353	0	363	\N	\N	t	0
51	\\xebe70bd69617aca548f74e1661064be0caa689dcc5317f555eb4683eaf195392	11	5	499999828647	171353	0	363	\N	\N	t	0
52	\\x39ac5dcd03eeee8ed1c5e043649dda8c5ec0cbe052c496523677318291974b76	12	0	499999828647	171353	0	363	\N	\N	t	0
53	\\x43f54df4bc7d51bf25a703b1dc6cda63e2e2180b91a9798003cc7b72ae919abd	12	1	499999828647	171353	0	363	\N	\N	t	0
54	\\x2ba3a7de67db0ef1f4c8eb1678026e9fcecd0d6b1e4992f4a3ecd16991c89c98	12	2	499999828647	171353	0	363	\N	\N	t	0
55	\\x55a0dbf4ad008571a0aa9373308e0b6b164db5c436190ca5bd2d42b1c5ac00ee	12	3	499999828647	171353	0	363	\N	\N	t	0
56	\\x5f09ab9c1ced97c48a56d24e1b7883c6fcd5b7535b631ddd4585777b3905e1c5	12	4	499999828647	171353	0	363	\N	\N	t	0
57	\\x230468077e8059ceb978e6f01527c02d936aae9a34de3b9f0d84dba4a73fe02d	16	0	3681318181484451	166777	0	259	\N	\N	t	0
58	\\x152d903e285b28200646b9c2eefc1c264efeaab331c00e932772b1a1240a9e3d	19	0	3681317681306542	177909	0	337	\N	5000000	t	0
59	\\xdac7e90ead70a61b349874588097df61f0c7e3f9dd35654b569b7a676f639b6f	20	0	3681317681127313	179229	0	367	\N	5000000	t	0
60	\\x488676de107e43eb1d39124059662be7ee6df136a30b61c7180828c2ca574787	22	0	499999648186	180461	0	395	\N	5000000	t	0
61	\\x5855863c3cdd68dd274dd071322590b9d1ee380f0d1ecfc2abbaf8a7e1fb0632	25	0	499999454261	193925	0	651	\N	500000	t	0
62	\\x91ae4a7c2ce19e652fa1c51b45e92ccd6eb7aec2ef9e6c9479709f10688512ed	27	0	3681317680960536	166777	0	259	\N	\N	t	0
63	\\xa243b91a3cfa1ad8a0b23c264e88df290b26064f29bde61dd9cfd545f7e48d5e	28	0	3681317080782627	177909	0	337	\N	5000000	t	0
64	\\xbd3e24cc78066f9d54df9978dd7533a0c310e1f5a7245b25cb01bf730d00e197	29	0	3681317080603398	179229	0	367	\N	5000000	t	0
65	\\xdb4a0411e39489e905e3b883bca5763ca43a3044a1626c0e9773116f48028058	31	0	499999648186	180461	0	395	\N	5000000	t	0
66	\\x1e99cdeef98320dc1617d29f4e22ef1e737bc5a8878bfc6d552e6342ef892a99	34	0	499999457033	191153	0	588	\N	500000	t	0
67	\\x1f470d3e4a60efdc3976a01bc18a91ff49344a070d06778a485fc5f1bffc2f09	35	0	3681317080436621	166777	0	259	\N	\N	t	0
68	\\x3d84ff89c29a0a7d130cce866e2ae914ac401ec206a5318bf0216e9a41deaa6d	37	0	3681316880258712	177909	0	337	\N	5000000	t	0
69	\\xc5d1fc12a7995e8cbab6957037e6e67da41f518e2f4ed31bff1e62d9dc062dd8	40	0	3681316880079483	179229	0	367	\N	5000000	t	0
70	\\xdf943b56d0a95691979fd3092684a3becfc86a45eb55624a15772b1755afb849	42	0	499999648186	180461	0	395	\N	5000000	t	0
71	\\xb5a7ea1d62a74367e17252437d484c5675e26f01051ab5844ff7e96d48c20a9c	45	0	499999454261	193925	0	651	\N	500000	t	0
72	\\x745203a2d440c8ad0b548e069487707a6ba4366cecc760abb6907b6b43f916a4	47	0	3681316879912706	166777	0	259	\N	\N	t	0
73	\\x9d5750d0ae36ff3a9b68bc5c1cda303adcd2f0f947921c61112755bd42e2048d	50	0	3681316379734797	177909	0	337	\N	5000000	t	0
74	\\xbe86452e790b4212dd258a1986d6696255da2a24795b7bb866a626c41312999c	53	0	3681316379555568	179229	0	367	\N	5000000	t	0
75	\\xdef45705d1ba1c16ad3cb293ce60366995a9c823f6f6ab5f2e81e1a5010343e2	56	0	499999648186	180461	0	395	\N	5000000	t	0
76	\\xa99b1c7b1467a0dca97e1ba1b8d46e181764f235eb6a81c302094984a49a8eaa	58	0	499999454261	193925	0	651	\N	500000	t	0
77	\\x879e7ffe7f966dea2ea91d221d241f9a4ebe816bfc27f0911fd226560bf97c06	61	0	3681316379388791	166777	0	259	\N	\N	t	0
78	\\x2167095ae815a0e422a826488c8844f4b4ebe0a8aa7e68a5868088a01a40b438	62	0	3681315879210882	177909	0	337	\N	5000000	t	0
79	\\x484c01dd19a87bb37e788ed25438ce581926734ad697b79b9b35e692594c4df1	63	0	3681315879031653	179229	0	367	\N	5000000	t	0
80	\\xd384b9bd395e686f60bba652eeaac55c8d699f157e9cddd6e8f4d0d3a14fa066	64	0	499999648186	180461	0	395	\N	5000000	t	0
81	\\x414579877fb3a0bdba11187183abc9166a776d7c439f57d79cf0c168f1994274	66	0	499999454261	193925	0	651	\N	500000	t	0
82	\\x2af958f71e3b3030e2ca607bc706ece5e2a0a537381aed5ca22c9c03a1fb5416	67	0	3681315878864876	166777	0	259	\N	\N	t	0
83	\\xe144c330bc7b1726a429f71bb9d1aad811fcab8650bd71eeaafe4598a522f940	69	0	3681315378686967	177909	0	337	\N	5000000	t	0
84	\\x3bcf62023aa0f4cc7cdb1c4abafd42b6674d3b4e1b5e79efe9144f32404fc604	70	0	3681315378507738	179229	0	367	\N	5000000	t	0
85	\\x36a243acbff3d3011fd62e6b2c393feaaa76f88b9e441ed6db023352208a3092	71	0	499999648186	180461	0	395	\N	5000000	t	0
86	\\xcd81098d04f4ddf6de5c03785003fb692ea4e5c0a4deda6fdae3b0057274e17f	73	0	499999454261	193925	0	651	\N	500000	t	0
87	\\x78efe4c0b722b78cc883eb68b609a2ee895b7c2c44410c50e5a919cfc700ae05	76	0	3681315378340961	166777	0	259	\N	\N	t	0
88	\\x11476fd859459e3f8313c1ccc0ba34baf49cace1cc3e05aeda176356283a4e4c	77	0	3681314878163052	177909	0	337	\N	5000000	t	0
89	\\x585d50028a48f21ff1322fbfb1331f3797c72346c4d27eb1664c23416368fa63	81	0	3681314877983823	179229	0	367	\N	5000000	t	0
90	\\x60ee5df8f74795d6bf5bd28595bbd81e02ef3cd39e68669d7b673002d65394bf	84	0	499999648186	180461	0	395	\N	5000000	t	0
91	\\x892c114693b3e512a84f2a832f44765bc8ea3122cd19806745ff6ebe87bde02a	86	0	499999454261	193925	0	651	\N	500000	t	0
92	\\xb754f16f5fed17206d72844e35f0c127e2c390370b283ac3b0625a24d6acc04a	87	0	3681314877817046	166777	0	259	\N	\N	t	0
93	\\xa4a57de2106a7a95cad55fac3b1a989dffff06f194adf77df769b1b1b4d02d3a	88	0	3681314577639137	177909	0	337	\N	5000000	t	0
94	\\x9cb9fd0c4b88fe6ef28c20434be7959c3bf687c63862e85fca8e9cc65d2a1d76	89	0	3681314577459908	179229	0	367	\N	5000000	t	0
95	\\xec407767569cc29d9f47b1a431f2e3c9182dd17440082eed29a3b29757c7186d	91	0	499999648186	180461	0	395	\N	5000000	t	0
96	\\xa92de59da37927400d6739439f9ddd3ccc726ac02b51f65e9278f81462e90c82	93	0	499999457033	191153	0	588	\N	500000	t	0
97	\\x23c136f54652243c44957e141e941688228b358b715c96f6666111c30bceb4f6	96	0	499999276572	180461	0	395	\N	5000000	t	0
98	\\x2ead68ffc9b6bd66640964fbc9e24ff2a281c2e99564a6a3de48be72ead7e090	97	0	3681314577275751	184157	0	437	\N	500000	t	0
99	\\x277de0699b0d19ad5d91de2ee152c433564ba2a8e8056728bf2def79ffce8148	99	0	3681314577108974	166777	0	259	\N	\N	t	0
100	\\x811f776fe20d57675f9192660a7163c35bed596ca7f41fe6dd74cc7114c0177f	100	0	3681314276931065	177909	0	337	\N	5000000	t	0
101	\\xa986fd40c9a0bffeef64e99f74aae757d3fc18daa33351350e14d1e0b150aee0	102	0	3681314276751836	179229	0	367	\N	5000000	t	0
102	\\x7f61098dff369ff5f728d6fb549af57dff1875d15000349e226290426db447b0	105	0	499999648186	180461	0	395	\N	5000000	t	0
103	\\x03177258609855bc36892504c9353a7caa7d9fa01e97a0de2aa3d2ce5479316b	106	0	499999457033	191153	0	588	\N	500000	t	0
104	\\xd0cff06ddb44da90ba69f54bbb4fef7e8b3c466cb1a75d91043d00032583c937	109	0	499999276572	180461	0	395	\N	5000000	t	0
105	\\x8b697798d88d6bfcd09769846bde4c8dfdf3d51d7242ff89c4bc8b01bc0fa24f	110	0	3681314276567679	184157	0	437	\N	500000	t	0
106	\\x10332d354054a41c3e76d39f4db7ca03144e072c037161027fdf0f455202da32	113	0	3681314276400902	166777	0	259	\N	\N	t	0
107	\\xda688fddae3fe22afa75c73b3fc86dbf2927f974ac4848d79ca19a132f14dca5	114	0	3681313776222993	177909	0	337	\N	5000000	t	0
108	\\x70c8d6c31ea5a077959743622f6010da77b5dc97923184df8c48507cc1d92de5	116	0	3681313776043764	179229	0	367	\N	5000000	t	0
109	\\x12d67057b46b27e8e09de69c3f77843cbfb5d5b788ca31469ffcaa4a9c8017d3	117	0	499999648186	180461	0	395	\N	5000000	t	0
110	\\xc752cc989f7d684ea1af478a1bf3bcfd971f5be387c2417fa1102b3602ed1b80	118	0	499999454217	193969	0	652	\N	500000	t	0
111	\\x850e39f64a8a2395fa0b6166b907203c003d934ab9ae817fb1ec721ceb7ce30c	119	0	499999273756	180461	0	395	\N	5000000	t	0
112	\\x6a32eb88b7f65652c5fe7f4ee0e9e78a9307b692611de388e02eee4f68d17656	121	0	3681313775859607	184157	0	437	\N	500000	t	0
113	\\x28890c5887ed8df3823800ba0e1642356b914c7b428daf33c53f3025e7035a2b	122	0	3681313775692830	166777	0	259	\N	\N	t	0
114	\\x7e1307c02b7ef6d85cabdc2ae6dc6de78d6d48d0c3006e599036bda5a215ef01	126	0	3681313275514921	177909	0	337	\N	5000000	t	0
115	\\x89cadcfa10fbc6d4cef35bf9bf177f7e87e6d6ffdc88e22a3beae7b041f5e572	129	0	3681313275335692	179229	0	367	\N	5000000	t	0
116	\\x6bf82131d76b3fd22256a0d605b5c9c48a7846bb4a1bd4f4d52157b101f0c621	130	0	499999648186	180461	0	395	\N	5000000	t	0
117	\\xc97ddae27d533015d763084c41369a7a43f33f202635bec06358b4d1d80b2d22	131	0	499999454217	193969	0	652	\N	500000	t	0
118	\\x95c80d8bd6992157dfc15702f36bdc35d9f5ca97d29e84b45de816487ae47999	133	0	499999273756	180461	0	395	\N	5000000	t	0
119	\\x0657cf3feb07320df76b1e249978e1522eb635f6fd194aa86c2dd9aec54408ca	135	0	3681313275151535	184157	0	437	\N	500000	t	0
120	\\xc714b0f8405471152864d3e5c56c29177173fa753ff53298aec38358b2ea584d	137	0	3681318181475475	175753	0	463	\N	\N	t	0
121	\\xe622b5ab7e13d4d50b67d7fef3955d9e2d2276c5edaa00fadde53107f7bf2437	138	0	3681313274972438	179097	0	539	\N	\N	t	0
122	\\xfd1de357fb04243b53cf6a38d052233aafe134678a0584cfec87fc651e34d30e	139	0	4999999767751	232249	0	1747	\N	\N	t	0
123	\\xa63290d88d087210674588d3ae23bdd5ed36fcf42ce89b1b28d3942909415f8d	140	0	4999989583022	184729	0	667	\N	\N	t	0
124	\\x5d424fa827b02ce870fe840dead78046c71be9f573d6631a4094a4ee2a729600	251	0	4999979414441	168581	0	295	\N	3942	t	0
125	\\xd590478c5fb3b567123bbc7c956514c4648d1ac8cd6b5f08c68e78084800a53d	251	1	4999979244276	170165	0	331	\N	3942	t	0
126	\\xfb5620a33e1c51c8aec82dfc7d751a15b5cbce9a97d2f93760148fb78e12c368	260	0	2999987579560	170253	0	333	\N	4011	t	0
127	\\x4a1445a931b5c5b99d9b4dd7e03428d6e9678f36d06d8a5ee32fcc22eeace23f	264	0	1999992294224	169989	0	327	\N	4068	t	0
128	\\x49c2e569a5e50287843657fe66559cf2f8672f7468f2ca99305a259a8e09bc2b	265	0	4999978732461	171573	0	363	\N	4072	t	0
129	\\x7005009abc1fe66b8acb2a876e87c7514fbc679dfb61ef034dff54f8567118d9	267	0	4999974235629	168405	0	291	\N	4076	t	0
130	\\x1da6262030afc8cd4e442641f407e80c5137634a4fcd2735c29196556fdeb715	268	0	0	5000000	0	2400	\N	\N	f	1893
131	\\xebdda6a6d740b135d59e3b0afb3cce63b1fdb3d75b580ee2bf9103529e986911	271	0	4999968719316	516313	0	8198	\N	4113	t	0
132	\\x9c632de2be419e177b6ed739d7a6a3a1723e20c75f3c9cfdd8b49b4bef63d1f6	273	0	179474447	525553	0	8408	\N	4123	t	0
133	\\xf81e2fa0c610c076f0893431870d9f82b301fcf58746487a109222bc35d87871	277	0	83091289551	182397	0	609	\N	4150	t	0
134	\\x0c9e27a4d6f0fd646bd32ecb82c99c0c1e3efa1c4ff2ee8345893e2a0161b178	278	0	4157030	171397	0	359	\N	4169	t	0
135	\\xed62bd7e8d712af02aec814df3873d8373f15bf6518d6e21d2afd486dcb92cf5	280	0	83091303499	168449	0	292	\N	4184	t	0
136	\\x7bcecb316c794a69ebf4692ff8f16dde48d161679bccdf969c2a1c84cdeafddf	284	0	83091303895	168053	0	283	\N	4196	t	0
137	\\x2986b8eec8d2da51532787c5b81c72bba839ed3e8ece02ed88be04c516ad5bfd	287	0	97391693967	180417	0	564	\N	4238	t	0
138	\\xaf48d31c2b3a35082c65b08d307468fc7fe144929942e776a9dc60b44ce39409	354	0	83091303499	168449	0	292	\N	4957	t	0
139	\\x962d4f584e2a4862e632151d3876d64495efba78534afd68c9d19248c30b5e4a	354	1	83088135490	168405	0	291	\N	4957	t	0
140	\\xbc1fe4db844eb318ec4281b4ff9e86a9cbd2a8090bb3d66800d3d15d9e0fb195	354	2	83091303499	168449	0	292	\N	4957	t	0
141	\\xbbff12c4d550c9cfb28af543891a5bce320a0270024797ad7be5e3ae987956c4	354	3	83086135094	168405	0	291	\N	4957	t	0
142	\\x8f6697ba723ec03b89694ff4f631b9afab0f681f6891c3f20cd8cad7594f8bb3	354	4	83091303499	168449	0	292	\N	4957	t	0
143	\\xa182b653f6cb93e63dad85a4ec6284138378c0c668aa427eb5e60e205c26ee54	354	5	83091303499	168449	0	292	\N	4957	t	0
144	\\x949a81cfa709dfe4768fc22a98ff69b6e35c09df6eaacb3ff73f37bf29cfc8ab	354	6	83091303499	168449	0	292	\N	4957	t	0
145	\\x0555071747e72d3c1d3451ed3f94fc6fdf206a8f871bb94f5967f3d5ae815a9f	354	7	83091303499	168449	0	292	\N	4957	t	0
146	\\xc25fb1167a3cdf46b2b388691749ed57031da3110170492d2f8f5e6d33d75e67	354	8	83091303499	168449	0	292	\N	4957	t	0
147	\\x7ace12f98cbde51d5390a0c0529481bd5181f6777c2597389d1bd07719a85e11	355	0	83091303499	168449	0	292	\N	4957	t	0
148	\\x0b3f87f662587b5bfb532c8147530d4b7f5e570eeb126335fa9ff60253c33af4	355	1	83091303499	168449	0	292	\N	4957	t	0
149	\\x60629f164126491381ceb81178151ec8195bf228671d69bb6e032784cac901c7	355	2	83091303499	168449	0	292	\N	4959	t	0
150	\\x40456493ae2604092c0dd1f21b0fdf51e50388a40723cb6369fb94589d4ecba3	355	3	83091303499	168449	0	292	\N	4959	t	0
151	\\x56fc53f108ac4e552768f64fe1c16bf23e6a106fcddcc68eb7203e11fbb92b2a	355	4	83096301915	170033	0	328	\N	4959	t	0
152	\\xb9892d24a2064770d1dc149d9004468f4a8584897e00010e14bb598de209f22f	355	5	83091133510	169989	0	327	\N	4959	t	0
153	\\x4f0cccc1e42bd9026370dcb30c2b548a248d0b20320ba9801b0c152f801baeca	355	6	83091133510	169989	0	327	\N	4959	t	0
154	\\xfa15ab0677aa4b04a2f6085f8d3b2d0636918bc3b7097bc92aa4e697ff6d7bae	355	7	83086133510	169989	0	327	\N	4959	t	0
155	\\xd770552b1a320d8262bfdb7c72e2ead9f04b85345968d7ec2c54a12641f5e354	355	8	83091303499	168449	0	292	\N	4959	t	0
156	\\xb4fa05848011b7378fe892afa00dde2b47cba09ba718d7ed9b3346b929c84da8	355	9	83091303499	168449	0	292	\N	4959	t	0
157	\\x814424c50881ae1431e6375d539bddec88062a8baff71a66e534b1149a905efb	355	10	9830187	169813	0	323	\N	4959	t	0
158	\\xa92b76f9daea51463ebdeda3503c211f4ebec6f0ead6faf1addc1b04544aaec6	355	11	9830187	169813	0	323	\N	4959	t	0
159	\\x680f60378ad47944b8ad44f4d1e0c85783c330758efca4ee6ddc8c420c411508	355	12	83091303499	168449	0	292	\N	4959	t	0
160	\\x64350c41311bac9a86e955589ee840fdd5abb1407425232120fcd6d7711e7189	355	13	83086135094	168405	0	291	\N	4959	t	0
161	\\xb9c684c8f4c3f4cf10cc1717d777ab715607068b4003951fdad4e454f3a2251e	355	14	83091303499	168449	0	292	\N	4959	t	0
162	\\xc6fcad7331f73ff6665a690dc8ddfea9e4ae23eddec72692c02b8d5f220d051b	355	15	83086135094	168405	0	291	\N	4959	t	0
163	\\x5b3b65cecd38b757028f28b2099a7f97830e903c580078e499961a95e66ca4f4	355	16	83086135094	168405	0	291	\N	4959	t	0
164	\\x006397364b097b71e14ef7d39a7cb1db06260a0083f47a85efece94f84353d90	355	17	83086135094	168405	0	291	\N	4959	t	0
165	\\xa0620b15ee91e740ebef8d825177288e49a9cb1085139f6bdca914a630260cc9	355	18	83091303499	168449	0	292	\N	4959	t	0
166	\\x8296966e5202430121078fd50a7f0353e5acc08413efb3e97510fe1f73fb72ed	355	19	9830187	169813	0	323	\N	4959	t	0
167	\\x81a4884e5b0c990cc0fb0ddb1fe2436614a501cd0f479cbc93e85efc588b6d22	355	20	83090121146	168405	0	291	\N	4959	t	0
168	\\xaf8a3d33fef7f0b8a5ab014271f340211c1dd326ac6b889e6e7806879b82f8e2	355	21	83086135094	168405	0	291	\N	4959	t	0
169	\\x692dc6612ee69c35eed98c218b877fdc93a11cee268a94bbfdeefe0d91ffbedd	355	22	83080966689	168405	0	291	\N	4959	t	0
170	\\x3ddbb10b1c92805dafd3cdf09ea3ff02b8d7d9f29501f8141eb75fd659b5a35b	355	23	83091303499	168449	0	292	\N	4959	t	0
171	\\xdf89c6c198398be43167c95aa89abb25b88fcadcdedd686a6b45967b73abfa4b	355	24	83080965105	168405	0	291	\N	4959	t	0
172	\\xbf88e0001fc8f02d965834f7fe3149612d2aaf5a6c2dc5f69f3474033fd20f08	355	25	14830187	169813	0	323	\N	4959	t	0
173	\\xebc139a1ab5bc99ef44fd144ecc1c6499ed0051b531f000840a2b1a9cbaf323e	355	26	83091303499	168449	0	292	\N	4959	t	0
174	\\x8ad1670eceeb23f3e5d8c03ba74bce5253251c0e6b0909b0b62a6d56826cdd76	355	27	9830187	169813	0	323	\N	4959	t	0
175	\\xf31e85dd37c840f3b85cae909ee22c02a7fac37a4186546e4ce91556fbc99377	355	28	83091303499	168449	0	292	\N	4959	t	0
176	\\xa1810db3f963d8f62958f294ecbf6c5e85b9d54af2b9cfadca7d5df704b3b3c1	355	29	83091303499	168449	0	292	\N	4959	t	0
177	\\xb1fa78f46fcefcb35482730fa01cced93ecc2474f7ca70bd4382c94871048022	355	30	9830187	169813	0	323	\N	4959	t	0
178	\\x29fb13791de645c5cae359ece6b4cdf72ed602e50ebe2fb94f94783cd3d5c464	355	31	83091303499	168449	0	292	\N	4959	t	0
179	\\xb18270cf53b22670470eb0b02daa3242b0e97dd9abac370024a8cb4cddd74e28	355	32	83091303499	168449	0	292	\N	4959	t	0
180	\\x294dc60daf469f953b0ff971933f15ba4c126a83585f5a9074a5a6fe2bc10e13	355	33	83086135094	168405	0	291	\N	4959	t	0
181	\\x8a6b655773efac6e111825c34bb986b7461a6b43ab45acddb79067add8969a75	355	34	83091303499	168449	0	292	\N	4959	t	0
182	\\x18b9a1d99318d15896eb3aa24db55db15f96859818ca1d4502afdcfd93c79680	355	35	83091303499	168449	0	292	\N	4959	t	0
183	\\x6c756a662f6f4cecf8bb478c4c12b589cb64f33e16681e6bbefa401f3fad1642	355	36	83091303499	168449	0	292	\N	4959	t	0
184	\\xeb6cadc6cbc605c610fd06200728a0fa2e6a7eb6609405ed0267b64c2a89eb19	355	37	83086135094	168405	0	291	\N	4959	t	0
185	\\xd268c37c60d5044d542d34e99cac6374b1e0a6ed1b3915f7fab5f2e047ea6c03	355	38	83096301915	170033	0	328	\N	4959	t	0
186	\\x417353dc0317a4ab66e980752dc7c9b3f35d2fe2c383d5825da5f422766f66b2	355	39	83091303499	168449	0	292	\N	4959	t	0
187	\\x38d810d055e812a1ed4fe701a0b3e2eaf59820d4bdc3d50c3b51ce0f17c282ee	355	40	97391525562	168405	0	291	\N	4959	t	0
188	\\x795117b70fc760d9c8108e630d784e5d609838fecc3e20df900d0c2884922215	355	41	83091303499	168449	0	292	\N	4959	t	0
189	\\xb1431eadae2012c818e958c38315636ff68bfb06c1eb69d63d6635bf513fc564	355	42	83091303499	168449	0	292	\N	4959	t	0
190	\\x110eaa3656452455d9a7cba11151e6192437af3061b55a6c4eb80ee871b0551b	355	43	14660374	169813	0	323	\N	4959	t	0
191	\\xbd691ea3a019010ed8843726c16689e7ed948cc8ca4c8d32a096f97ab6779143	355	44	83091303499	168449	0	292	\N	4959	t	0
192	\\xd9a2af110847d835f1c0d155abcfea5612ae0b02a477cb9acbbf1dce1f9103f9	355	45	9660374	169813	0	323	\N	4959	t	0
193	\\x3187da08f329daaf8930abae0205dc2628d509595b6b60002cc948f9d82d8bc5	355	46	83087965501	169989	0	327	\N	4959	t	0
194	\\x54ceafd497a36dcb3ffd7df80e494dea0ad3be0771dad73d31caf601abe8aa04	355	47	83091303499	168449	0	292	\N	4959	t	0
195	\\x10429cfb641f77cfcd9c84decfcc2d7ec4c8ef87be1c2abf22fccb2cc12de5d9	355	48	83085965105	169989	0	327	\N	4959	t	0
196	\\xfa0b2872a8976064880365e8834b51c35d0fa60291532e83ec702728c99cdc13	355	49	83086135094	168405	0	291	\N	4959	t	0
197	\\x3afc49eaa59c527421da34b82422764e8d20a9d3d89abe53c555feebe9922bf4	355	50	83091303499	168449	0	292	\N	4959	t	0
198	\\xdb70b6d3a0e2ce47f880141b0ee2eb8e141303db696c43c8cdf4345a0dda95a6	355	51	83085965105	169989	0	327	\N	4959	t	0
199	\\x811ffcb10ff9e7994201f4dd8a99e78af703554400ce382168ac4ce531c184df	355	52	83086135094	168405	0	291	\N	4959	t	0
200	\\x34e9338c7ca97c7beb88c54d6aa8c5e9346714225e3b55092e7651121877c6dc	355	53	83086135094	168405	0	291	\N	4959	t	0
201	\\x872dc65156d503d1a92a7928e6f7b5eabc1eb920423fd0bf635b837a52528f52	355	54	9830187	169813	0	323	\N	4959	t	0
202	\\xc29091c229b85508e05d5ec2b435bd27c1a28285661bb80921848e5b195355dc	355	55	83080966689	168405	0	291	\N	4959	t	0
203	\\x4327ba71ad436a0683b42238d2be47ac3fbe47a9230a6c5b8c7c5f3fc2d410c5	355	56	83086135094	168405	0	291	\N	4959	t	0
204	\\xfcb544c45ef2479b4dd9a285e5015d587bf760d1bd05a6a381fdea76cce123de	355	57	83091303499	168449	0	292	\N	4959	t	0
205	\\x5637be16f2e5996530c1b2a78e1952b3f41ded3ff22d471ee9137599dd7d4604	355	58	83091303499	168449	0	292	\N	4959	t	0
206	\\x7319830758519bc2864a6bde3b56973ec521aac9873fb59dff5174ed9f0c76e1	355	59	83086135094	168405	0	291	\N	4959	t	0
207	\\x0bc8e05b1583879d5f0f0c52f2f068c7a36de8d164ac7ab7221644e6e9d154dd	355	60	83080966689	168405	0	291	\N	4959	t	0
208	\\x36cf45def5bac0f5ac538e248967a75deac18352a966ee2ec39c57223b8f98d1	355	61	83086135094	168405	0	291	\N	4959	t	0
209	\\xcf9802617d075a24dc398768bab985490429e21121099c9a14d125ab44933d84	355	62	83091303499	168449	0	292	\N	4959	t	0
210	\\x5e0745bff247dbd091263d61ccd163e70ddb4ec9aac6e5a9a7cf69df5928e7d6	355	63	83091303499	168449	0	292	\N	4959	t	0
211	\\xbe7c27e405e474b09bb92ca0d36898ec287131d4452f768c1badf9618aa73a46	355	64	83091303499	168449	0	292	\N	4959	t	0
212	\\x8779a04e3f7a29cde2cdf4ed2717016095fedfda0226c9f97389a0f5ea77e698	355	65	83086135094	168405	0	291	\N	4959	t	0
213	\\x4afb896aff998e236e2d6f7141dc3df89c93491a1cdba4fde91cfca5e59580a4	355	66	83080796700	168405	0	291	\N	4959	t	0
214	\\x67e59039214615b12d62e7fdd75b70cd82b1dfdd7f4c49f968cca2919abed7cd	355	67	83086135094	168405	0	291	\N	4959	t	0
215	\\x0b4b770238bcc5512e3b6fc585e8b2724806dfeaaac7f5b5dfa14b0b0dbee300	355	68	9830187	169813	0	323	\N	4959	t	0
216	\\x3b7f3a470307422d1e0a67e9827c51475b872370c9947bd8b87fc603230fa2d1	355	69	9660374	169813	0	323	\N	4959	t	0
217	\\xbad306bea25027a4f0aa541345dbd69d651a61ae0191a5e4c0aa9d0d1bdd76b2	355	70	83087455886	169989	0	327	\N	4959	t	0
218	\\x6b609130a3e54dd02c4225b35d6241ac4222ef7deccc950e2af4570a88648c2f	355	71	83080966689	168405	0	291	\N	4959	t	0
219	\\xe44a6312bcbfeb4ec361fdd74a4645e2620025133873b32efd88a7c8f1c70aba	355	72	83080966689	168405	0	291	\N	4959	t	0
220	\\xfc4deda6496dabd82e302cb52b8c3b1ba4ed06c3cce7f4c226cbc9bd9c88fbd6	355	73	83080966689	168405	0	291	\N	4959	t	0
221	\\x8a04ccab170fe789d76acbe5d085a9ea7c307e79fb7a915b541cc1e41aa93ad7	355	74	83075798284	168405	0	291	\N	4959	t	0
222	\\xf5f6c26f82dbf530cf0ac022c6bff9bd06611398d3863d9eb58ca1e176898ebf	355	75	9830187	169813	0	323	\N	4959	t	0
223	\\xce2b0b8f15ed3e5cbc56df3b80c46b7bb6d160946ac6c220df30f0310dc73646	355	76	9830187	169813	0	323	\N	4959	t	0
224	\\x8a17e8bdf437d6928f180f551fc05dbfe30e573b199b5b296993b0fffa1dc578	355	77	83085965105	168405	0	291	\N	4959	t	0
225	\\x7d5867e2a7ac55d652de8a5ea56791688c55412e5d8740664fc023835f1d5a5f	355	78	9830187	169813	0	323	\N	4959	t	0
226	\\x881c6e353bf060068767c35ff98116adfd23dafcff6481caa88c6cd22913cffe	355	79	83075798284	168405	0	291	\N	4959	t	0
227	\\x66096ba5093010a210d50bec57de3010d83f46ac3c933f9fbaff75923a5e64e2	355	80	83086135094	168405	0	291	\N	4959	t	0
228	\\xe87d5bcc328389ef54923b2574303f7662eae5c0148e5db85c14a43af2877d3a	355	81	83091133510	169989	0	327	\N	4959	t	0
229	\\x49e1c180559a83ffcd97ce8ddff99b284bcc1de071310df127864109d576f1cd	355	82	9830187	169813	0	323	\N	4959	t	0
230	\\x4cdac77db59cf5594a4dd6e6e385b2872f53b059b3d692acfe1a42f54d4af966	355	83	83091303499	168449	0	292	\N	4959	t	0
231	\\xa5705d5f4b401b8ed63364991349faf9a2c7529ba877af194a39f6725a1d58f1	355	84	83070629879	168405	0	291	\N	4959	t	0
232	\\x20a4a8eba8caf442851dc7413d9468e868333a38a62e6f65903de66cb8b46632	355	85	9830187	169813	0	323	\N	4959	t	0
233	\\xa6b24192380ca00f06d8dd97c232f66168ee2992ec5eda1f0f6fbc769c78024d	355	86	83091303499	168449	0	292	\N	4959	t	0
234	\\xd59a17dbd80a7b38013344782b49d2f5d8f8a8da5ed16fd6df41fea1c70ca0f6	355	87	9830187	169813	0	323	\N	4959	t	0
235	\\xb5e85fab0585deed54379600ade45dbbf174d5bca2178889c1d431f22c50193d	355	88	9830187	169813	0	323	\N	4959	t	0
236	\\xcf6e463c5825325c866cdf805da58c54259a3818f39e098b9f4052cb184cb0c6	355	89	83091133510	168405	0	291	\N	4959	t	0
237	\\x7ffb9fa905b2ed18fb3bdc53812c01e0b191b5ff7edeb3d6ad8706e04706886b	355	90	9830187	169813	0	323	\N	4959	t	0
238	\\xe7efd43514f5061a39ca61e390267d16d44cd22226bf256ebc172e98cee02374	457	0	90147862271	174741	0	435	\N	5942	t	0
240	\\x6709ada1672bccad58bda7c94c3109efcceb71f24ede184828865ac347405276	462	0	5007005746796	435705	0	6370	\N	5976	t	0
241	\\x46d9241a415c72c1fa38c37ec60b8044ea34a816e4ebaab69c1a140f11469123	544	0	5014321640307	216365	0	1385	\N	6947	t	0
242	\\x50937ff383556e0777b873b22f39961d44fe4dcb8ab2d3955ae438c81b4871e2	544	1	5014321438154	202153	0	1062	\N	6947	t	0
243	\\x6b63948e9f59196fdb713aecfa7149de45a7407c529fbf7754ab4c52cbe0f99a	544	2	5014321236001	202153	0	1062	\N	6947	t	0
244	\\x0f33487302a1308916609b333cb4502d024adbb9e15e6c9b16c34d6a1e8d52c5	544	3	5014321033848	202153	0	1062	\N	6947	t	0
245	\\x3d8a7cf80b5708f17c25ef13f3bee7376147ff934c9fc1b593d3c4dd9dd5bca0	544	4	5014320831695	202153	0	1062	\N	6947	t	0
246	\\xba7e038a9e064a57b93fba9320d369c2f32edc889a96bfe79a1b63182f7895f7	544	5	5014320629542	202153	0	1062	\N	6947	t	0
247	\\xfdedb0d9d06a8f9b19201648e98c82c80949a313c741b2377441064a538bf4b2	544	6	5014320427389	202153	0	1062	\N	6947	t	0
248	\\x5d501e0a6071558d5abd3b4ec28a128f2dac8015430e04a91603acfaedeb9c7e	544	7	5014320225236	202153	0	1062	\N	6947	t	0
249	\\x9d23fcd5f9cb2c9faa2382244e3baac52f080812e308de4c3ed46dab97477b99	544	8	5014320023083	202153	0	1062	\N	6947	t	0
250	\\x38076dc537c7b8fe00ae151b7e0807691d2b7c1b2af0026b5fc4150fce44af6d	544	9	5014319820930	202153	0	1062	\N	6947	t	0
251	\\xe1e642d14f98a7605f690cd2d488cb7d60c25e2ca723a6f2e8c8fa00039d6b4c	544	10	5014319618777	202153	0	1062	\N	6947	t	0
252	\\xce7430528c0b13b166b15246eb205896be102351a665dcf5e487ba403fdb7724	544	11	5014319416624	202153	0	1062	\N	6947	t	0
253	\\xbe9ec13ac236331c2f7137bbb97263f7cb958b183faa14e6d8f083afca238a9d	544	12	5014319214471	202153	0	1062	\N	6947	t	0
254	\\x33812f24651e2e2c20cca4634809eb63919d582fc6335231d41fb36703c786be	544	13	5014319012318	202153	0	1062	\N	6947	t	0
255	\\x7c4ab0077a491d62c93f954b942e5bd5827c74af35df5b29bed290339b915016	544	14	5014318810165	202153	0	1062	\N	6947	t	0
256	\\x5b3a097f9f0f85d7de28f056164f73cf5b4b29ffe714738d970d560ad9835846	544	15	5014318608012	202153	0	1062	\N	6947	t	0
257	\\x402f33fae82b9be6b5c34d48f5e3fb31720a2c6aa6b1b200724a64e065af8f09	544	16	5014318405859	202153	0	1062	\N	6947	t	0
258	\\xed1feea7e95c43e3a064ea0ba9184a0febbf8da3c01bff020bb05313a0c79d5c	544	17	5014318203706	202153	0	1062	\N	6947	t	0
259	\\x63f2cace5b534443724de9936c05e15d9770f062993bae63b10934d6273cd5d5	544	18	5014318001553	202153	0	1062	\N	6947	t	0
260	\\xe24552ddb43232ae2b4030b7f6bb78166dd357c93fb3cbc7b089819fb7d14890	544	19	5014317799400	202153	0	1062	\N	6947	t	0
261	\\x50f6a20a3b9a0f09537c18d44a19c630bd05724b8b2c03fb2cd3247e09245ee1	544	20	5014317597247	202153	0	1062	\N	6947	t	0
262	\\x4f23624161162eadc4653d26b9ad11afdafcfe0286956e263e15ca7051489e2b	544	21	5014317395094	202153	0	1062	\N	6947	t	0
263	\\xf6858edd739f53af03abf20a3f6c4f939e05cf8488f0c53c14fa2e150466ddcd	544	22	5014317192941	202153	0	1062	\N	6947	t	0
264	\\xb6c1fd7ca8ea3936e7591f4c4a544525776634ee90834c85417abb0b34e3d183	544	23	5014316990788	202153	0	1062	\N	6947	t	0
265	\\x3d2ef215035f1d67042b14c9694cf2031b351b563151110790a3cf5b499fa1ee	544	24	5014316788635	202153	0	1062	\N	6947	t	0
266	\\x809b645af70a3c12eb704530d747c9fb855af1de131f1a66df55d4a9945ad8ae	544	25	5014316586482	202153	0	1062	\N	6947	t	0
267	\\xfdfde2ebe4b21121604260fc5273144206d5da4e8338472855f100f161908fe2	544	26	5014316384329	202153	0	1062	\N	6947	t	0
268	\\xf58073321e617a15589f1d29eb7c51f24b95aa7a3928a2c3f716e6bbf4071fc5	544	27	5014316182176	202153	0	1062	\N	6947	t	0
269	\\x8c7007ab55e63d2b317a28713e1b6eca41d93218de6df0f06d4e5fc96769b353	544	28	5014315980023	202153	0	1062	\N	6947	t	0
270	\\x0efd5259c215e0f7d0263385569f5ec66a31e373b929c24d9ab997539d78cd1d	544	29	5014315777870	202153	0	1062	\N	6947	t	0
271	\\x2c7f87292b5798322e16bc743586cf0ffd4179ee7c4b0f84038c06e4dd4190b1	544	30	5014315575717	202153	0	1062	\N	6947	t	0
272	\\xc3a8cc59fff6048158380ac8e4edaf5456b89f6cb8432258342e0905e4d72a9a	544	31	5014315373564	202153	0	1062	\N	6947	t	0
273	\\xa74692417b7cfeb2f4c1eb27fd78b6d2033b16af9cbd2e478af8c4e813892f8e	544	32	5014315171411	202153	0	1062	\N	6947	t	0
274	\\x3575503c57db1f4b0e79349ea60c1c6cec3ca40547a52a9ffa668f6d3204dabc	544	33	5014314969258	202153	0	1062	\N	6947	t	0
275	\\xe7e41c76e13c0f1d6a1035cfea20dfef22892d5c3529d4a2fe41ce694ba1d5a0	544	34	5014314767105	202153	0	1062	\N	6947	t	0
276	\\x3e6b7edaa9b38cc3fd74e2023fa199601f97f119fe55d9e2b824932aac387653	544	35	5014314564952	202153	0	1062	\N	6947	t	0
277	\\xbf456ae38c73a569539dc4c8fb3074fd784ab438a752529594bcd40b3de33ee8	545	0	5014314362799	202153	0	1062	\N	6947	t	0
278	\\xd9f73489732cf6b26a1896dd6327d1474d1387fa247d80f5773d6ae8906072cf	545	1	5014314160646	202153	0	1062	\N	6947	t	0
279	\\xd9c145cf212c613b27af5d8d3795110d7ff6bae3799ee61709ed43686430f703	545	2	5014313958493	202153	0	1062	\N	6947	t	0
280	\\x7b60ee1be2fdb8017b910d55e36fd7b70b29635924c4a13163f9a2252e0d815f	545	3	5014313756340	202153	0	1062	\N	6962	t	0
281	\\xddd9d5a5aa89e396dccfa96444069224ce795ce964625fe4e8f0febcab5e0a22	545	4	5014313554187	202153	0	1062	\N	6962	t	0
282	\\x2c8dabd8f2338f0dd878f87c7e3b74e1e6133c7a257ae1c042aa9611650505d2	545	5	5014313352034	202153	0	1062	\N	6962	t	0
283	\\x2c24d2d1dfc8e602de82752a6ec3606b0dec20fe01443e176d394a4f2cfbbed1	546	0	5014313149881	202153	0	1062	\N	6962	t	0
284	\\x574a5d4ad4c7ac2d899858cd4dd1357d06c0a031bd0a1469e4f7ac80bbc8ac5b	546	1	5014312947728	202153	0	1062	\N	6962	t	0
285	\\xb257949ed3fbd567218f44cc15e588b1e4adc9fe70ba6d976c658412eaebf40f	546	2	5014312745575	202153	0	1062	\N	6965	t	0
286	\\xf218e14e522ee2e57da6d25f1173e4e553218e3093e31fbbb1d737406cf06b3c	546	3	5014312543422	202153	0	1062	\N	6965	t	0
287	\\xc51f90695d23686b74ecabe405e0a6b68d8061777421e01de2846f1337a4dc01	546	4	5014312341269	202153	0	1062	\N	6965	t	0
288	\\x668bd92ddcc072b46d4fbd1146530a09059e8cdb4c51754c03d9d5a5db436cc5	546	5	5014312139116	202153	0	1062	\N	6965	t	0
289	\\x13d2eec34db8dd6316894f578a66c817242db75d6a5f6940470a9d75b089450b	546	6	5014311936963	202153	0	1062	\N	6965	t	0
290	\\x12144d9e59b533a715db70db2be9dff103a045b0b806976dbd57e483778d614f	546	7	5014311734810	202153	0	1062	\N	6965	t	0
291	\\x7a80316b0c7ac6b5b64b49a77a75a7b6b89a20d2cafc36692036c0625a0af12b	546	8	5014311532657	202153	0	1062	\N	6965	t	0
292	\\xcb65b239bf36f50a042e0502675550bbe4b827e66958aa3145d0f4362d7388ef	546	9	5014311330504	202153	0	1062	\N	6965	t	0
293	\\xa8a8491dee7dfa0a9e627ab6e1300edfbaf724d1290db22c79a0c27bd69a28fc	546	10	5014311128351	202153	0	1062	\N	6965	t	0
294	\\x56813006b7e2cd83c1f8a076988c42c81946db366aff7047215d33fe258199fa	546	11	5014310926198	202153	0	1062	\N	6965	t	0
295	\\x644983809f0d704759cd9cb29331c8ffb8eda1af881b94cf7bf91da3f6cfd22b	546	12	5014310724045	202153	0	1062	\N	6965	t	0
296	\\x54f0197c661ac8e74013df3edf226ad411d7e75c1d52395729d81d9bd4fd0954	546	13	5014310521892	202153	0	1062	\N	6965	t	0
297	\\x714228e31ae6c189bde75acc7a860fd89f5487517562b0451df9734937cf86c6	546	14	5014310319739	202153	0	1062	\N	6965	t	0
298	\\x06eca68676d78d274c91377ccf5f3e4d9a9c89a6059cfd27b0cafefa414a5152	546	15	5014310117586	202153	0	1062	\N	6965	t	0
299	\\x723176df36edb5fbbac6a88007259436d318909878fe8e87c6be36b34a5f8c74	547	0	5014309915433	202153	0	1062	\N	6965	t	0
300	\\x22196a707fe646f8184d9a063ab5761c566843eaabc35c23acf8b97ca1af24c7	547	1	5014309713280	202153	0	1062	\N	6965	t	0
301	\\x80718b28695726b60cfcdc8b860686c5c87cd00e1cbfea840b150715b5326f05	547	2	5014309511127	202153	0	1062	\N	6965	t	0
302	\\x80feebeef0782017707bab3ac6ba46cba2d289e82d6d27c404fdd7d6719feb61	547	3	5014309308974	202153	0	1062	\N	6971	t	0
303	\\x53d90eb8b0d554a5013aba8a2c13e52f1bbb0943d104e4eea4194d2c59f429e2	547	4	5014309106821	202153	0	1062	\N	6971	t	0
304	\\xf9336b3012c2e178b423115a741956dae0286b3bfb9445eae828e6ba20f51706	547	5	5014308904668	202153	0	1062	\N	6971	t	0
305	\\x4c63d9ddc3af194e278694a0ff3f8ab63315cbb3067a6e15ed4956f3cf5557e1	547	6	5014308702515	202153	0	1062	\N	6971	t	0
306	\\xddcb089e1001ce3294f69760e9878c8ce07c44e90cbaa45d45a824dff8af2632	547	7	5014308500362	202153	0	1062	\N	6971	t	0
307	\\x210a4696aa081ce83a8cf31b626b43eb47a9a3b6dee5226326a8f368f086f71a	547	8	5014308298209	202153	0	1062	\N	6971	t	0
308	\\xea8b529563835fa4a8a1bc1577028cde20193a24e262a65e8f6688572a7bebdd	547	9	5014308096056	202153	0	1062	\N	6971	t	0
309	\\x18c2811abf4f1fabc2d4d2e641685d3878a96216ab71a7d3da29620741ea282c	547	10	5014307893903	202153	0	1062	\N	6971	t	0
310	\\x0237daff7b809e7e914506702feae5d35f299a8d29b7121259c7f936591e7d02	547	11	5014307691750	202153	0	1062	\N	6971	t	0
311	\\x3607e41a9c87d0d36a4bb7028a2eb1c87192672ce515a0c1d5b2ab5a744efca0	547	12	5014307489597	202153	0	1062	\N	6971	t	0
312	\\xc251f618dc6c38f6c60a7119d404e3fac5a2a5d3a58bd9a0a0779c38d2f0afa8	547	13	5014307287444	202153	0	1062	\N	6971	t	0
313	\\x1dab574b9605ec4d09a01bd9bb8b4e5b2b77feb504cdf7f1962355da0cb75280	547	14	5014307085291	202153	0	1062	\N	6971	t	0
314	\\xe82c4987d43a0e0daadb18e0c911e1d086eefd3ef1d199636a6c8d0736b946a7	547	15	5014306883138	202153	0	1062	\N	6971	t	0
315	\\x713ea4f245dd53e1477a4b2003af7886837dcb9d3712165bdac7fb4c37ddac6d	547	16	5014306680985	202153	0	1062	\N	6971	t	0
316	\\xec07327d1da2121dd2e37a6dabe990540568d5b73b8efa428d143dab90695175	547	17	5014306478832	202153	0	1062	\N	6971	t	0
317	\\x31e3a914a74cd49562d873e83dc34bf1eae2d74740ffb8b57a289aac0f0c4702	547	18	5014306276679	202153	0	1062	\N	6971	t	0
318	\\xe25f075690ba84052e2c0773ef770b351585f614c77ec03fbe50b1bb87a89bf6	547	19	5014306074526	202153	0	1062	\N	6971	t	0
319	\\x7379eab81203e2d8087f2f0b01e8bbb0073b07adef9c33135caca52117c66be5	547	20	5014305872373	202153	0	1062	\N	6971	t	0
320	\\x26055ea1ed3cfcde91f9b6c165c85b6d01c2211f1993ba39d7cdd2c6aac6d5cb	547	21	5014305670220	202153	0	1062	\N	6971	t	0
321	\\x462825895acdc9d845ad5aca230e841a2616ba2237f2d9302bbeb7097cdebde3	547	22	5014305468067	202153	0	1062	\N	6971	t	0
322	\\x60bc5bfb9a0ea5827b01faa3d4c4a7919440e2478156d38e645b66fe4c61fa6a	547	23	5014305265914	202153	0	1062	\N	6971	t	0
323	\\xbedbc85ccca7228815c558ba2e6fe0883c403fa6ef0a88c70ae33ec4a50d04ee	547	24	5014305063761	202153	0	1062	\N	6971	t	0
324	\\x3183768ca544889898243bdc29c58121de1266ad0efe5d942e8f24f9f63678c8	547	25	5014304861608	202153	0	1062	\N	6971	t	0
325	\\xac67070ad40dc8f179929fccc7ae257928dbe1f395484a9d2cc7c4eb398b8d03	547	26	5014304659455	202153	0	1062	\N	6971	t	0
326	\\x4a4d0d65d07a4e1f02a39b3e18cc17c6ea9dd87b123954040e9c510de1743620	547	27	5014304457302	202153	0	1062	\N	6971	t	0
327	\\x35b602c2c8abcf64a5daff633fcd797f31696616d5eed3af1fae080fd67a4039	547	28	5014304255149	202153	0	1062	\N	6971	t	0
328	\\x40d182194010b9e724da545ef32246dc667dd845c877267f824ddff680d68128	547	29	5014304052996	202153	0	1062	\N	6971	t	0
329	\\xda8b3b1d121d3a1d0b11e2fb5b9667b6234ddc8c60fb5cfae674298dad9bb09c	547	30	5014303850843	202153	0	1062	\N	6971	t	0
330	\\xbaf06a8a62c4af7f06b3289f03482a1a664a245e2d9a3987401d75662be2a2f6	547	31	5014303648690	202153	0	1062	\N	6971	t	0
331	\\xdc40f7aab8a3acb1f4290f47d0524f06f77d1daa404c6ddb4ec59d6f6a76b8e8	547	32	5014303446537	202153	0	1062	\N	6971	t	0
332	\\x969d4bf81820d46cda1fcb81ff14e5bbc26a1fd0a3a258bc70f764eb5b5491ca	547	33	5014303244384	202153	0	1062	\N	6971	t	0
333	\\x92aac94163e94591c63829e47755c5b5cea450c01e25cfd511c38ad15d500227	547	34	5014303042231	202153	0	1062	\N	6971	t	0
334	\\x09db15be1df701bf4fdf89267f9693545b12f295cfdca00ebd6e7bc1cd66c616	547	35	5014302840078	202153	0	1062	\N	6971	t	0
335	\\x6b51ff05b83da4ec965b1650b821d0cbc6545eac81bd8ae91d60cb283d109776	547	36	5014302637925	202153	0	1062	\N	6971	t	0
336	\\x43be3ff04d0c764992f747429785dc31b47a2df6577ccd825e3c802bc0481cb6	547	37	5014302435772	202153	0	1062	\N	6971	t	0
337	\\xc5ff5d4cf1035ff9c5f0763e30df5b2e42164a22ea985a6cb5f6890a15b6fcab	547	38	5014302233619	202153	0	1062	\N	6971	t	0
338	\\x36f6939760e77bb27dbd4cdd79e4fd7ebac7be290a90fc4083b19be60cc2822e	547	39	5014302031466	202153	0	1062	\N	6971	t	0
339	\\xa69bf1dc6c6ce64cbc2ff085d4997d6cae2d1d0a2f45162e7706b4b0c07f6eb0	547	40	5014301829313	202153	0	1062	\N	6971	t	0
340	\\x0956f56b49c477d443ee133ac466fa8b1ef6feb7620ab39dd31f4e7820e25cd6	547	41	5014301627160	202153	0	1062	\N	6971	t	0
341	\\xbdbc0fe6780a0ca66c4d45241314d57b491aeeafbb2eaf63caebc5621d19e87b	638	0	5019655158288	214297	0	1338	\N	7941	t	0
342	\\x3bfd023f731750bba8ecb4eab053a2593eb25c306276fd9683897f42035fe234	642	0	39215783691	234845	0	1700	\N	7984	t	0
343	\\x4f0ae45d28cd7cf90ce124fa9dba62885da0f2467e2ea82f68eada8db20bf35b	650	0	4999999820111	179889	0	552	\N	8047	t	0
344	\\x35bde0b08201735fbc5f10dc728a39039244841ecd5bab388853d562f27926f7	655	0	4999996650122	169989	0	327	\N	8108	t	0
345	\\xccea7ce0c46012f474a8487ebff9d606f1033bc05433ab9b7b34b75279e72c0a	659	0	4999993474369	175753	0	458	\N	8114	t	0
346	\\x227ea91953b11409ff6893f61fd824287f26b1b62f5a223a0fda3ead1459b6ee	663	0	9818351	181649	0	592	\N	8158	t	0
347	\\xb2d5d244dfd8246c3174f871fa7db394e83770ec9b1145b9c67891c3e7df4b87	667	0	9826447	173553	0	408	\N	8231	t	0
348	\\xc336428ba07a6ef31a24f19b605f48e7368a0da406db08cc56e445f2ce479794	671	0	9821255	178745	0	526	\N	8251	t	0
\.


--
-- Data for Name: tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_in (id, tx_in_id, tx_out_id, tx_out_index, redeemer_id) FROM stdin;
1	35	21	0	\N
2	36	28	0	\N
3	37	14	0	\N
4	38	26	0	\N
5	39	18	0	\N
6	40	27	0	\N
7	41	29	0	\N
8	42	13	0	\N
9	43	12	0	\N
10	44	31	0	\N
11	45	16	0	\N
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
86	120	35	1	\N
87	121	119	0	\N
88	122	121	0	\N
89	123	122	1	\N
90	124	123	1	\N
91	125	124	0	\N
92	125	124	1	\N
93	126	125	0	\N
94	127	125	1	\N
95	127	126	0	\N
96	128	127	0	\N
97	128	127	1	\N
98	128	126	1	\N
99	129	128	0	\N
100	130	129	0	\N
101	131	129	1	\N
102	132	131	0	\N
103	132	131	1	\N
104	132	131	2	\N
105	132	131	3	\N
106	132	131	4	\N
107	132	131	5	\N
108	132	131	6	\N
109	132	131	7	\N
110	132	131	8	\N
111	132	131	9	\N
112	132	131	10	\N
113	132	131	11	\N
114	132	131	12	\N
115	132	131	13	\N
116	132	131	14	\N
117	132	131	15	\N
118	132	131	16	\N
119	132	131	17	\N
120	132	131	18	\N
121	132	131	19	\N
122	132	131	20	\N
123	132	131	21	\N
124	132	131	22	\N
125	132	131	23	\N
126	132	131	24	\N
127	132	131	25	\N
128	132	131	26	\N
129	132	131	27	\N
130	132	131	28	\N
131	132	131	29	\N
132	132	131	30	\N
133	132	131	31	\N
134	132	131	32	\N
135	132	131	33	\N
136	132	131	34	\N
137	132	131	35	\N
138	132	131	36	\N
139	132	131	37	\N
140	132	131	38	\N
141	132	131	39	\N
142	132	131	40	\N
143	132	131	41	\N
144	132	131	42	\N
145	132	131	43	\N
146	132	131	44	\N
147	132	131	45	\N
148	132	131	46	\N
149	132	131	47	\N
150	132	131	48	\N
151	132	131	49	\N
152	132	131	50	\N
153	132	131	51	\N
154	132	131	52	\N
155	132	131	53	\N
156	132	131	54	\N
157	132	131	55	\N
158	132	131	56	\N
159	132	131	57	\N
160	132	131	58	\N
161	132	131	59	\N
162	133	131	86	\N
163	134	128	1	\N
164	135	131	112	\N
165	136	131	98	\N
166	137	131	60	\N
167	138	131	81	\N
168	139	136	1	\N
169	140	131	114	\N
170	141	140	1	\N
171	142	131	106	\N
172	143	131	92	\N
173	144	131	76	\N
174	145	131	102	\N
175	146	131	117	\N
176	147	131	79	\N
177	148	131	91	\N
178	149	131	65	\N
179	150	131	94	\N
180	151	147	0	\N
181	151	131	88	\N
182	152	147	1	\N
183	152	141	0	\N
184	153	149	1	\N
185	153	152	0	\N
186	154	151	0	\N
187	154	135	1	\N
188	155	131	105	\N
189	156	131	89	\N
190	157	139	0	\N
191	157	156	0	\N
192	158	148	0	\N
193	158	146	0	\N
194	159	131	73	\N
195	160	148	1	\N
196	161	131	84	\N
197	162	156	1	\N
198	163	142	1	\N
199	164	144	1	\N
200	165	131	116	\N
201	166	144	0	\N
202	166	154	0	\N
203	167	133	1	\N
204	168	159	1	\N
205	169	160	1	\N
206	170	131	64	\N
207	171	154	1	\N
208	172	168	0	\N
209	172	135	0	\N
210	173	131	99	\N
211	174	163	0	\N
212	174	140	0	\N
213	175	131	70	\N
214	176	131	67	\N
215	177	164	0	\N
216	177	162	0	\N
217	178	131	85	\N
218	179	131	95	\N
219	180	146	1	\N
220	181	131	96	\N
221	182	131	109	\N
222	183	131	87	\N
223	184	165	1	\N
224	185	179	0	\N
225	185	131	74	\N
226	186	131	103	\N
227	187	137	0	\N
228	188	131	72	\N
229	189	131	93	\N
230	190	149	0	\N
231	190	172	1	\N
232	191	131	101	\N
233	192	143	0	\N
234	192	158	1	\N
235	193	183	0	\N
236	193	139	1	\N
237	194	131	97	\N
238	195	180	1	\N
239	195	171	0	\N
240	196	178	1	\N
241	197	131	77	\N
242	198	164	1	\N
243	198	181	0	\N
244	199	194	1	\N
245	200	161	1	\N
246	201	166	0	\N
247	201	184	0	\N
248	202	184	1	\N
249	203	182	1	\N
250	204	131	100	\N
251	205	131	82	\N
252	206	186	1	\N
253	207	203	1	\N
254	208	145	1	\N
255	209	131	118	\N
256	210	131	110	\N
257	211	131	80	\N
258	212	210	1	\N
259	213	195	1	\N
260	214	183	1	\N
261	215	182	0	\N
262	215	211	0	\N
263	216	159	0	\N
264	216	166	1	\N
265	217	193	1	\N
266	217	216	1	\N
267	218	141	1	\N
268	219	163	1	\N
269	220	199	1	\N
270	221	202	1	\N
271	222	167	0	\N
272	222	176	0	\N
273	223	197	0	\N
274	223	169	0	\N
275	224	152	1	\N
276	225	153	0	\N
277	225	224	0	\N
278	226	169	1	\N
279	227	175	1	\N
280	228	178	0	\N
281	228	150	1	\N
282	229	177	0	\N
283	229	220	0	\N
284	230	131	111	\N
285	231	221	1	\N
286	232	145	0	\N
287	232	193	0	\N
288	233	131	61	\N
289	234	216	0	\N
290	234	194	0	\N
291	235	208	0	\N
292	235	201	0	\N
293	236	185	1	\N
294	237	142	0	\N
295	237	222	0	\N
296	238	131	62	\N
567	241	240	0	\N
568	241	240	1	\N
569	241	240	2	\N
570	241	240	3	\N
571	241	240	4	\N
572	241	240	5	\N
573	241	240	6	\N
574	241	240	7	\N
575	241	240	8	\N
576	241	240	9	\N
577	241	240	10	\N
578	241	240	11	\N
579	241	240	12	\N
580	241	240	13	\N
581	242	241	0	\N
582	242	241	1	\N
583	242	241	2	\N
584	242	241	3	\N
585	242	241	4	\N
586	242	241	5	\N
587	242	241	6	\N
588	242	241	7	\N
589	242	241	8	\N
590	243	242	0	\N
591	243	242	1	\N
592	243	242	2	\N
593	243	242	3	\N
594	243	242	4	\N
595	243	242	5	\N
596	243	242	6	\N
597	243	242	7	\N
598	243	242	8	\N
599	244	243	0	\N
600	244	243	1	\N
601	244	243	2	\N
602	244	243	3	\N
603	244	243	4	\N
604	244	243	5	\N
605	244	243	6	\N
606	244	243	7	\N
607	244	243	8	\N
608	245	244	0	\N
609	245	244	1	\N
610	245	244	2	\N
611	245	244	3	\N
612	245	244	4	\N
613	245	244	5	\N
614	245	244	6	\N
615	245	244	7	\N
616	245	244	8	\N
617	246	245	0	\N
618	246	245	1	\N
619	246	245	2	\N
620	246	245	3	\N
621	246	245	4	\N
622	246	245	5	\N
623	246	245	6	\N
624	246	245	7	\N
625	246	245	8	\N
626	247	246	0	\N
627	247	246	1	\N
628	247	246	2	\N
629	247	246	3	\N
630	247	246	4	\N
631	247	246	5	\N
632	247	246	6	\N
633	247	246	7	\N
634	247	246	8	\N
635	248	247	0	\N
636	248	247	1	\N
637	248	247	2	\N
638	248	247	3	\N
639	248	247	4	\N
640	248	247	5	\N
641	248	247	6	\N
642	248	247	7	\N
643	248	247	8	\N
644	249	248	0	\N
645	249	248	1	\N
646	249	248	2	\N
647	249	248	3	\N
648	249	248	4	\N
649	249	248	5	\N
650	249	248	6	\N
651	249	248	7	\N
652	249	248	8	\N
653	250	249	0	\N
654	250	249	1	\N
655	250	249	2	\N
656	250	249	3	\N
657	250	249	4	\N
658	250	249	5	\N
659	250	249	6	\N
660	250	249	7	\N
661	250	249	8	\N
662	251	250	0	\N
663	251	250	1	\N
664	251	250	2	\N
665	251	250	3	\N
666	251	250	4	\N
667	251	250	5	\N
668	251	250	6	\N
669	251	250	7	\N
670	251	250	8	\N
671	252	251	0	\N
672	252	251	1	\N
673	252	251	2	\N
674	252	251	3	\N
675	252	251	4	\N
676	252	251	5	\N
677	252	251	6	\N
678	252	251	7	\N
679	252	251	8	\N
680	253	252	0	\N
681	253	252	1	\N
682	253	252	2	\N
683	253	252	3	\N
684	253	252	4	\N
685	253	252	5	\N
686	253	252	6	\N
687	253	252	7	\N
688	253	252	8	\N
689	254	253	0	\N
690	254	253	1	\N
691	254	253	2	\N
692	254	253	3	\N
693	254	253	4	\N
694	254	253	5	\N
695	254	253	6	\N
696	254	253	7	\N
697	254	253	8	\N
698	255	254	0	\N
699	255	254	1	\N
700	255	254	2	\N
701	255	254	3	\N
432	240	215	0	\N
433	240	215	1	\N
434	240	207	0	\N
435	240	207	1	\N
436	240	134	0	\N
437	240	195	0	\N
438	240	190	0	\N
439	240	190	1	\N
440	240	232	0	\N
441	240	232	1	\N
442	240	180	0	\N
443	240	200	0	\N
444	240	200	1	\N
445	240	208	1	\N
446	240	187	0	\N
447	240	187	1	\N
448	240	197	1	\N
449	240	170	0	\N
450	240	170	1	\N
451	240	150	0	\N
452	240	186	0	\N
453	240	203	0	\N
454	240	229	0	\N
455	240	229	1	\N
456	240	213	0	\N
457	240	213	1	\N
458	240	230	0	\N
459	240	230	1	\N
460	240	153	1	\N
461	240	205	0	\N
462	240	205	1	\N
463	240	151	1	\N
464	240	210	0	\N
465	240	160	0	\N
466	240	227	0	\N
467	240	227	1	\N
468	240	214	0	\N
469	240	214	1	\N
470	240	218	0	\N
471	240	218	1	\N
472	240	206	0	\N
473	240	206	1	\N
474	240	188	0	\N
475	240	188	1	\N
476	240	225	0	\N
477	240	225	1	\N
478	240	237	0	\N
479	240	237	1	\N
480	240	199	0	\N
481	240	157	0	\N
482	240	157	1	\N
483	240	167	1	\N
484	240	201	1	\N
485	240	212	0	\N
486	240	212	1	\N
487	240	226	0	\N
488	240	226	1	\N
489	240	221	0	\N
490	240	224	1	\N
491	240	181	1	\N
492	240	174	0	\N
493	240	174	1	\N
494	240	132	0	\N
495	240	165	0	\N
496	240	176	1	\N
497	240	143	1	\N
498	240	231	0	\N
499	240	231	1	\N
500	240	233	0	\N
501	240	233	1	\N
502	240	158	0	\N
503	240	138	0	\N
504	240	138	1	\N
505	240	168	1	\N
506	240	189	0	\N
507	240	189	1	\N
508	240	179	1	\N
509	240	177	1	\N
510	240	235	0	\N
511	240	235	1	\N
512	240	161	0	\N
513	240	217	0	\N
514	240	217	1	\N
515	240	191	0	\N
516	240	191	1	\N
517	240	211	1	\N
518	240	172	0	\N
519	240	202	0	\N
520	240	162	1	\N
521	240	223	0	\N
522	240	223	1	\N
523	240	236	0	\N
524	240	236	1	\N
525	240	209	0	\N
526	240	209	1	\N
527	240	185	0	\N
528	240	234	0	\N
529	240	234	1	\N
530	240	155	0	\N
531	240	155	1	\N
532	240	192	0	\N
533	240	192	1	\N
534	240	198	0	\N
535	240	198	1	\N
536	240	171	1	\N
537	240	219	0	\N
538	240	219	1	\N
539	240	238	0	\N
540	240	238	1	\N
541	240	228	0	\N
542	240	228	1	\N
543	240	173	0	\N
544	240	173	1	\N
545	240	131	63	\N
546	240	131	66	\N
547	240	131	68	\N
548	240	131	69	\N
549	240	131	71	\N
550	240	131	75	\N
551	240	131	78	\N
552	240	131	83	\N
553	240	131	90	\N
554	240	131	104	\N
555	240	131	107	\N
556	240	131	108	\N
557	240	131	113	\N
558	240	131	115	\N
559	240	131	119	\N
560	240	175	0	\N
561	240	222	1	\N
562	240	196	0	\N
563	240	196	1	\N
564	240	220	1	\N
565	240	204	0	\N
566	240	204	1	\N
702	255	254	4	\N
703	255	254	5	\N
704	255	254	6	\N
705	255	254	7	\N
706	255	254	8	\N
707	256	255	0	\N
708	256	255	1	\N
709	256	255	2	\N
710	256	255	3	\N
711	256	255	4	\N
712	256	255	5	\N
713	256	255	6	\N
714	256	255	7	\N
715	256	255	8	\N
716	257	256	0	\N
717	257	256	1	\N
718	257	256	2	\N
719	257	256	3	\N
720	257	256	4	\N
721	257	256	5	\N
722	257	256	6	\N
723	257	256	7	\N
724	257	256	8	\N
725	258	257	0	\N
726	258	257	1	\N
727	258	257	2	\N
728	258	257	3	\N
729	258	257	4	\N
730	258	257	5	\N
731	258	257	6	\N
732	258	257	7	\N
733	258	257	8	\N
734	259	258	0	\N
735	259	258	1	\N
736	259	258	2	\N
737	259	258	3	\N
738	259	258	4	\N
739	259	258	5	\N
740	259	258	6	\N
741	259	258	7	\N
742	259	258	8	\N
743	260	259	0	\N
744	260	259	1	\N
745	260	259	2	\N
746	260	259	3	\N
747	260	259	4	\N
748	260	259	5	\N
749	260	259	6	\N
750	260	259	7	\N
751	260	259	8	\N
752	261	260	0	\N
753	261	260	1	\N
754	261	260	2	\N
755	261	260	3	\N
756	261	260	4	\N
757	261	260	5	\N
758	261	260	6	\N
759	261	260	7	\N
760	261	260	8	\N
761	262	261	0	\N
762	262	261	1	\N
763	262	261	2	\N
764	262	261	3	\N
765	262	261	4	\N
766	262	261	5	\N
767	262	261	6	\N
768	262	261	7	\N
769	262	261	8	\N
770	263	262	0	\N
771	263	262	1	\N
772	263	262	2	\N
773	263	262	3	\N
774	263	262	4	\N
775	263	262	5	\N
776	263	262	6	\N
777	263	262	7	\N
778	263	262	8	\N
779	264	263	0	\N
780	264	263	1	\N
781	264	263	2	\N
782	264	263	3	\N
783	264	263	4	\N
784	264	263	5	\N
785	264	263	6	\N
786	264	263	7	\N
787	264	263	8	\N
788	265	264	0	\N
789	265	264	1	\N
790	265	264	2	\N
791	265	264	3	\N
792	265	264	4	\N
793	265	264	5	\N
794	265	264	6	\N
795	265	264	7	\N
796	265	264	8	\N
797	266	265	0	\N
798	266	265	1	\N
799	266	265	2	\N
800	266	265	3	\N
801	266	265	4	\N
802	266	265	5	\N
803	266	265	6	\N
804	266	265	7	\N
805	266	265	8	\N
806	267	266	0	\N
807	267	266	1	\N
808	267	266	2	\N
809	267	266	3	\N
810	267	266	4	\N
811	267	266	5	\N
812	267	266	6	\N
813	267	266	7	\N
814	267	266	8	\N
815	268	267	0	\N
816	268	267	1	\N
817	268	267	2	\N
818	268	267	3	\N
819	268	267	4	\N
820	268	267	5	\N
821	268	267	6	\N
822	268	267	7	\N
823	268	267	8	\N
824	269	268	0	\N
825	269	268	1	\N
826	269	268	2	\N
827	269	268	3	\N
828	269	268	4	\N
829	269	268	5	\N
830	269	268	6	\N
831	269	268	7	\N
832	269	268	8	\N
833	270	269	0	\N
834	270	269	1	\N
835	270	269	2	\N
836	270	269	3	\N
837	270	269	4	\N
838	270	269	5	\N
839	270	269	6	\N
840	270	269	7	\N
841	270	269	8	\N
842	271	270	0	\N
843	271	270	1	\N
844	271	270	2	\N
845	271	270	3	\N
846	271	270	4	\N
847	271	270	5	\N
848	271	270	6	\N
849	271	270	7	\N
850	271	270	8	\N
851	272	271	0	\N
852	272	271	1	\N
853	272	271	2	\N
854	272	271	3	\N
855	272	271	4	\N
856	272	271	5	\N
857	272	271	6	\N
858	272	271	7	\N
859	272	271	8	\N
860	273	272	0	\N
861	273	272	1	\N
862	273	272	2	\N
863	273	272	3	\N
864	273	272	4	\N
865	273	272	5	\N
866	273	272	6	\N
867	273	272	7	\N
868	273	272	8	\N
869	274	273	0	\N
870	274	273	1	\N
871	274	273	2	\N
872	274	273	3	\N
873	274	273	4	\N
874	274	273	5	\N
875	274	273	6	\N
876	274	273	7	\N
877	274	273	8	\N
878	275	274	0	\N
879	275	274	1	\N
880	275	274	2	\N
881	275	274	3	\N
882	275	274	4	\N
883	275	274	5	\N
884	275	274	6	\N
885	275	274	7	\N
886	275	274	8	\N
887	276	275	0	\N
888	276	275	1	\N
889	276	275	2	\N
890	276	275	3	\N
891	276	275	4	\N
892	276	275	5	\N
893	276	275	6	\N
894	276	275	7	\N
895	276	275	8	\N
896	277	276	0	\N
897	277	276	1	\N
898	277	276	2	\N
899	277	276	3	\N
900	277	276	4	\N
901	277	276	5	\N
902	277	276	6	\N
903	277	276	7	\N
904	277	276	8	\N
905	278	277	0	\N
906	278	277	1	\N
907	278	277	2	\N
908	278	277	3	\N
909	278	277	4	\N
910	278	277	5	\N
911	278	277	6	\N
912	278	277	7	\N
913	278	277	8	\N
914	279	278	0	\N
915	279	278	1	\N
916	279	278	2	\N
917	279	278	3	\N
918	279	278	4	\N
919	279	278	5	\N
920	279	278	6	\N
921	279	278	7	\N
922	279	278	8	\N
923	280	279	0	\N
924	280	279	1	\N
925	280	279	2	\N
926	280	279	3	\N
927	280	279	4	\N
928	280	279	5	\N
929	280	279	6	\N
930	280	279	7	\N
931	280	279	8	\N
932	281	280	0	\N
933	281	280	1	\N
934	281	280	2	\N
935	281	280	3	\N
936	281	280	4	\N
937	281	280	5	\N
938	281	280	6	\N
939	281	280	7	\N
940	281	280	8	\N
941	282	281	0	\N
942	282	281	1	\N
943	282	281	2	\N
944	282	281	3	\N
945	282	281	4	\N
946	282	281	5	\N
947	282	281	6	\N
948	282	281	7	\N
949	282	281	8	\N
950	283	282	0	\N
951	283	282	1	\N
952	283	282	2	\N
953	283	282	3	\N
954	283	282	4	\N
955	283	282	5	\N
956	283	282	6	\N
957	283	282	7	\N
958	283	282	8	\N
959	284	283	0	\N
960	284	283	1	\N
961	284	283	2	\N
962	284	283	3	\N
963	284	283	4	\N
964	284	283	5	\N
965	284	283	6	\N
966	284	283	7	\N
967	284	283	8	\N
968	285	284	0	\N
969	285	284	1	\N
970	285	284	2	\N
971	285	284	3	\N
972	285	284	4	\N
973	285	284	5	\N
974	285	284	6	\N
975	285	284	7	\N
976	285	284	8	\N
977	286	285	0	\N
978	286	285	1	\N
979	286	285	2	\N
980	286	285	3	\N
981	286	285	4	\N
982	286	285	5	\N
983	286	285	6	\N
984	286	285	7	\N
985	286	285	8	\N
986	287	286	0	\N
987	287	286	1	\N
988	287	286	2	\N
989	287	286	3	\N
990	287	286	4	\N
991	287	286	5	\N
992	287	286	6	\N
993	287	286	7	\N
994	287	286	8	\N
995	288	287	0	\N
996	288	287	1	\N
997	288	287	2	\N
998	288	287	3	\N
999	288	287	4	\N
1000	288	287	5	\N
1001	288	287	6	\N
1002	288	287	7	\N
1003	288	287	8	\N
1004	289	288	0	\N
1005	289	288	1	\N
1006	289	288	2	\N
1007	289	288	3	\N
1008	289	288	4	\N
1009	289	288	5	\N
1010	289	288	6	\N
1011	289	288	7	\N
1012	289	288	8	\N
1013	290	289	0	\N
1014	290	289	1	\N
1015	290	289	2	\N
1016	290	289	3	\N
1017	290	289	4	\N
1018	290	289	5	\N
1019	290	289	6	\N
1020	290	289	7	\N
1021	290	289	8	\N
1022	291	290	0	\N
1023	291	290	1	\N
1024	291	290	2	\N
1025	291	290	3	\N
1026	291	290	4	\N
1027	291	290	5	\N
1028	291	290	6	\N
1029	291	290	7	\N
1030	291	290	8	\N
1031	292	291	0	\N
1032	292	291	1	\N
1033	292	291	2	\N
1034	292	291	3	\N
1035	292	291	4	\N
1036	292	291	5	\N
1037	292	291	6	\N
1038	292	291	7	\N
1039	292	291	8	\N
1040	293	292	0	\N
1041	293	292	1	\N
1042	293	292	2	\N
1043	293	292	3	\N
1044	293	292	4	\N
1045	293	292	5	\N
1046	293	292	6	\N
1047	293	292	7	\N
1048	293	292	8	\N
1049	294	293	0	\N
1050	294	293	1	\N
1051	294	293	2	\N
1052	294	293	3	\N
1053	294	293	4	\N
1054	294	293	5	\N
1055	294	293	6	\N
1056	294	293	7	\N
1057	294	293	8	\N
1058	295	294	0	\N
1059	295	294	1	\N
1060	295	294	2	\N
1061	295	294	3	\N
1062	295	294	4	\N
1063	295	294	5	\N
1064	295	294	6	\N
1065	295	294	7	\N
1066	295	294	8	\N
1067	296	295	0	\N
1068	296	295	1	\N
1069	296	295	2	\N
1070	296	295	3	\N
1071	296	295	4	\N
1072	296	295	5	\N
1073	296	295	6	\N
1074	296	295	7	\N
1075	296	295	8	\N
1076	297	296	0	\N
1077	297	296	1	\N
1078	297	296	2	\N
1079	297	296	3	\N
1080	297	296	4	\N
1081	297	296	5	\N
1082	297	296	6	\N
1083	297	296	7	\N
1084	297	296	8	\N
1085	298	297	0	\N
1086	298	297	1	\N
1087	298	297	2	\N
1088	298	297	3	\N
1089	298	297	4	\N
1090	298	297	5	\N
1091	298	297	6	\N
1092	298	297	7	\N
1093	298	297	8	\N
1094	299	298	0	\N
1095	299	298	1	\N
1096	299	298	2	\N
1097	299	298	3	\N
1098	299	298	4	\N
1099	299	298	5	\N
1100	299	298	6	\N
1101	299	298	7	\N
1102	299	298	8	\N
1103	300	299	0	\N
1104	300	299	1	\N
1105	300	299	2	\N
1106	300	299	3	\N
1107	300	299	4	\N
1108	300	299	5	\N
1109	300	299	6	\N
1110	300	299	7	\N
1111	300	299	8	\N
1112	301	300	0	\N
1113	301	300	1	\N
1114	301	300	2	\N
1115	301	300	3	\N
1116	301	300	4	\N
1117	301	300	5	\N
1118	301	300	6	\N
1119	301	300	7	\N
1120	301	300	8	\N
1121	302	301	0	\N
1122	302	301	1	\N
1123	302	301	2	\N
1124	302	301	3	\N
1125	302	301	4	\N
1126	302	301	5	\N
1127	302	301	6	\N
1128	302	301	7	\N
1129	302	301	8	\N
1130	303	302	0	\N
1131	303	302	1	\N
1132	303	302	2	\N
1133	303	302	3	\N
1134	303	302	4	\N
1135	303	302	5	\N
1136	303	302	6	\N
1137	303	302	7	\N
1138	303	302	8	\N
1139	304	303	0	\N
1140	304	303	1	\N
1141	304	303	2	\N
1142	304	303	3	\N
1143	304	303	4	\N
1144	304	303	5	\N
1145	304	303	6	\N
1146	304	303	7	\N
1147	304	303	8	\N
1148	305	304	0	\N
1149	305	304	1	\N
1150	305	304	2	\N
1151	305	304	3	\N
1152	305	304	4	\N
1153	305	304	5	\N
1154	305	304	6	\N
1155	305	304	7	\N
1156	305	304	8	\N
1157	306	305	0	\N
1158	306	305	1	\N
1159	306	305	2	\N
1160	306	305	3	\N
1161	306	305	4	\N
1162	306	305	5	\N
1163	306	305	6	\N
1164	306	305	7	\N
1165	306	305	8	\N
1166	307	306	0	\N
1167	307	306	1	\N
1168	307	306	2	\N
1169	307	306	3	\N
1170	307	306	4	\N
1171	307	306	5	\N
1172	307	306	6	\N
1173	307	306	7	\N
1174	307	306	8	\N
1175	308	307	0	\N
1176	308	307	1	\N
1177	308	307	2	\N
1178	308	307	3	\N
1179	308	307	4	\N
1180	308	307	5	\N
1181	308	307	6	\N
1182	308	307	7	\N
1183	308	307	8	\N
1184	309	308	0	\N
1185	309	308	1	\N
1186	309	308	2	\N
1187	309	308	3	\N
1188	309	308	4	\N
1189	309	308	5	\N
1190	309	308	6	\N
1191	309	308	7	\N
1192	309	308	8	\N
1193	310	309	0	\N
1194	310	309	1	\N
1195	310	309	2	\N
1196	310	309	3	\N
1197	310	309	4	\N
1198	310	309	5	\N
1199	310	309	6	\N
1200	310	309	7	\N
1201	310	309	8	\N
1202	311	310	0	\N
1203	311	310	1	\N
1204	311	310	2	\N
1205	311	310	3	\N
1206	311	310	4	\N
1207	311	310	5	\N
1208	311	310	6	\N
1209	311	310	7	\N
1210	311	310	8	\N
1211	312	311	0	\N
1212	312	311	1	\N
1213	312	311	2	\N
1214	312	311	3	\N
1215	312	311	4	\N
1216	312	311	5	\N
1217	312	311	6	\N
1218	312	311	7	\N
1219	312	311	8	\N
1220	313	312	0	\N
1221	313	312	1	\N
1222	313	312	2	\N
1223	313	312	3	\N
1224	313	312	4	\N
1225	313	312	5	\N
1226	313	312	6	\N
1227	313	312	7	\N
1228	313	312	8	\N
1229	314	313	0	\N
1230	314	313	1	\N
1231	314	313	2	\N
1232	314	313	3	\N
1233	314	313	4	\N
1234	314	313	5	\N
1235	314	313	6	\N
1236	314	313	7	\N
1237	314	313	8	\N
1238	315	314	0	\N
1239	315	314	1	\N
1240	315	314	2	\N
1241	315	314	3	\N
1242	315	314	4	\N
1243	315	314	5	\N
1244	315	314	6	\N
1245	315	314	7	\N
1246	315	314	8	\N
1247	316	315	0	\N
1248	316	315	1	\N
1249	316	315	2	\N
1250	316	315	3	\N
1251	316	315	4	\N
1252	316	315	5	\N
1253	316	315	6	\N
1254	316	315	7	\N
1255	316	315	8	\N
1256	317	316	0	\N
1257	317	316	1	\N
1258	317	316	2	\N
1259	317	316	3	\N
1260	317	316	4	\N
1261	317	316	5	\N
1262	317	316	6	\N
1263	317	316	7	\N
1264	317	316	8	\N
1265	318	317	0	\N
1266	318	317	1	\N
1267	318	317	2	\N
1268	318	317	3	\N
1269	318	317	4	\N
1270	318	317	5	\N
1271	318	317	6	\N
1272	318	317	7	\N
1273	318	317	8	\N
1274	319	318	0	\N
1275	319	318	1	\N
1276	319	318	2	\N
1277	319	318	3	\N
1278	319	318	4	\N
1279	319	318	5	\N
1280	319	318	6	\N
1281	319	318	7	\N
1282	319	318	8	\N
1283	320	319	0	\N
1284	320	319	1	\N
1285	320	319	2	\N
1286	320	319	3	\N
1287	320	319	4	\N
1288	320	319	5	\N
1289	320	319	6	\N
1290	320	319	7	\N
1291	320	319	8	\N
1292	321	320	0	\N
1293	321	320	1	\N
1294	321	320	2	\N
1295	321	320	3	\N
1296	321	320	4	\N
1297	321	320	5	\N
1298	321	320	6	\N
1299	321	320	7	\N
1300	321	320	8	\N
1301	322	321	0	\N
1302	322	321	1	\N
1303	322	321	2	\N
1304	322	321	3	\N
1305	322	321	4	\N
1306	322	321	5	\N
1307	322	321	6	\N
1308	322	321	7	\N
1309	322	321	8	\N
1310	323	322	0	\N
1311	323	322	1	\N
1312	323	322	2	\N
1313	323	322	3	\N
1314	323	322	4	\N
1315	323	322	5	\N
1316	323	322	6	\N
1317	323	322	7	\N
1318	323	322	8	\N
1319	324	323	0	\N
1320	324	323	1	\N
1321	324	323	2	\N
1322	324	323	3	\N
1323	324	323	4	\N
1324	324	323	5	\N
1325	324	323	6	\N
1326	324	323	7	\N
1327	324	323	8	\N
1328	325	324	0	\N
1329	325	324	1	\N
1330	325	324	2	\N
1331	325	324	3	\N
1332	325	324	4	\N
1333	325	324	5	\N
1334	325	324	6	\N
1335	325	324	7	\N
1336	325	324	8	\N
1337	326	325	0	\N
1338	326	325	1	\N
1339	326	325	2	\N
1340	326	325	3	\N
1341	326	325	4	\N
1342	326	325	5	\N
1343	326	325	6	\N
1344	326	325	7	\N
1345	326	325	8	\N
1346	327	326	0	\N
1347	327	326	1	\N
1348	327	326	2	\N
1349	327	326	3	\N
1350	327	326	4	\N
1351	327	326	5	\N
1352	327	326	6	\N
1353	327	326	7	\N
1354	327	326	8	\N
1355	328	327	0	\N
1356	328	327	1	\N
1357	328	327	2	\N
1358	328	327	3	\N
1359	328	327	4	\N
1360	328	327	5	\N
1361	328	327	6	\N
1362	328	327	7	\N
1363	328	327	8	\N
1364	329	328	0	\N
1365	329	328	1	\N
1366	329	328	2	\N
1367	329	328	3	\N
1368	329	328	4	\N
1369	329	328	5	\N
1370	329	328	6	\N
1371	329	328	7	\N
1372	329	328	8	\N
1373	330	329	0	\N
1374	330	329	1	\N
1375	330	329	2	\N
1376	330	329	3	\N
1377	330	329	4	\N
1378	330	329	5	\N
1379	330	329	6	\N
1380	330	329	7	\N
1381	330	329	8	\N
1382	331	330	0	\N
1383	331	330	1	\N
1384	331	330	2	\N
1385	331	330	3	\N
1386	331	330	4	\N
1387	331	330	5	\N
1388	331	330	6	\N
1389	331	330	7	\N
1390	331	330	8	\N
1391	332	331	0	\N
1392	332	331	1	\N
1393	332	331	2	\N
1394	332	331	3	\N
1395	332	331	4	\N
1396	332	331	5	\N
1397	332	331	6	\N
1398	332	331	7	\N
1399	332	331	8	\N
1400	333	332	0	\N
1401	333	332	1	\N
1402	333	332	2	\N
1403	333	332	3	\N
1404	333	332	4	\N
1405	333	332	5	\N
1406	333	332	6	\N
1407	333	332	7	\N
1408	333	332	8	\N
1409	334	333	0	\N
1410	334	333	1	\N
1411	334	333	2	\N
1412	334	333	3	\N
1413	334	333	4	\N
1414	334	333	5	\N
1415	334	333	6	\N
1416	334	333	7	\N
1417	334	333	8	\N
1418	335	334	0	\N
1419	335	334	1	\N
1420	335	334	2	\N
1421	335	334	3	\N
1422	335	334	4	\N
1423	335	334	5	\N
1424	335	334	6	\N
1425	335	334	7	\N
1426	335	334	8	\N
1427	336	335	0	\N
1428	336	335	1	\N
1429	336	335	2	\N
1430	336	335	3	\N
1431	336	335	4	\N
1432	336	335	5	\N
1433	336	335	6	\N
1434	336	335	7	\N
1435	336	335	8	\N
1436	337	336	0	\N
1437	337	336	1	\N
1438	337	336	2	\N
1439	337	336	3	\N
1440	337	336	4	\N
1441	337	336	5	\N
1442	337	336	6	\N
1443	337	336	7	\N
1444	337	336	8	\N
1445	338	337	0	\N
1446	338	337	1	\N
1447	338	337	2	\N
1448	338	337	3	\N
1449	338	337	4	\N
1450	338	337	5	\N
1451	338	337	6	\N
1452	338	337	7	\N
1453	338	337	8	\N
1454	339	338	0	\N
1455	339	338	1	\N
1456	339	338	2	\N
1457	339	338	3	\N
1458	339	338	4	\N
1459	339	338	5	\N
1460	339	338	6	\N
1461	339	338	7	\N
1462	339	338	8	\N
1463	340	339	0	\N
1464	340	339	1	\N
1465	340	339	2	\N
1466	340	339	3	\N
1467	340	339	4	\N
1468	340	339	5	\N
1469	340	339	6	\N
1470	340	339	7	\N
1471	340	339	8	\N
1472	341	340	0	\N
1473	341	340	1	\N
1474	341	340	2	\N
1475	341	340	3	\N
1476	341	340	4	\N
1477	341	340	5	\N
1478	341	340	6	\N
1479	341	340	7	\N
1480	341	340	8	\N
1481	342	341	7	\N
1482	343	121	2	\N
1483	344	343	1	\N
1484	345	344	1	\N
1485	346	123	0	\N
1486	347	120	0	\N
1487	348	122	0	\N
\.


--
-- Data for Name: tx_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_metadata (id, key, json, bytes, tx_id) FROM stdin;
1	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "TestHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "TestHandle", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": "ipfs://some-hash", "website": "https://cardano.org/", "mediaType": "image/jpeg", "description": "The Handle Standard", "augmentations": []}, "HelloHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "HelloHandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "DoubleHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "DoubleHandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a460a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656067776562736974657468747470733a2f2f63617264616e6f2e6f72672f6c446f75626c6548616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656c446f75626c6548616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6b48656c6c6f48616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656b48656c6c6f48616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6a5465737448616e646c65a86d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e646172646566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e7965696d61676570697066733a2f2f736f6d652d68617368696d65646961547970656a696d6167652f6a706567646e616d656a5465737448616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f	122
2	123	"1234"	\\xa1187b6431323334	126
3	6862	{"pools": [{"id": "ae0f374ebdaa66166205e9ea9551cff3219990c82435990a724b6f80", "weight": 1}]}	\\xa1191acea165706f6f6c7381a2626964783861653066333734656264616136363136363230356539656139353531636666333231393939306338323433353939306137323462366638306677656967687401	133
4	6862	{"name": "Test Portfolio", "pools": [{"id": "d92618e7570364165223512b374ed5928366045f2593db59bc2389c7", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7381a2626964783864393236313865373537303336343136353232333531326233373465643539323833363630343566323539336462353962633233383963376677656967687401	137
6	6862	{"name": "Test Portfolio", "pools": [{"id": "d92618e7570364165223512b374ed5928366045f2593db59bc2389c7", "weight": 1}, {"id": "ae0f374ebdaa66166205e9ea9551cff3219990c82435990a724b6f80", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7382a2626964783864393236313865373537303336343136353232333531326233373465643539323833363630343566323539336462353962633233383963376677656967687401a2626964783861653066333734656264616136363136363230356539656139353531636666333231393939306338323433353939306137323462366638306677656967687401	240
7	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	342
\.


--
-- Data for Name: tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_out (id, tx_id, index, address, address_raw, address_has_script, payment_cred, stake_address_id, value, data_hash, inline_datum_id, reference_script_id) FROM stdin;
1	1	0	5oP9ib6ym3XXuQYmesDNTyGH5xabxBGFmHRcfci6FhkhXKi8DaGypUo9zdLaZkUsom	\\x82d818582683581c06a3a1d4f96e5bff15244a5ca4e1305eeb5edb38cfa35db78fd87869a10243190378001aac460748	f	\N	\N	910909092	\N	\N	\N
2	2	0	5oP9ib6ym3XYTtFtgfK5PwWN4HyWiEmLyGgDDtFFywcfy1X8W8vhzzsmYMs1sbpXeF	\\x82d818582683581c11e8aa4b2116aef6b1a0d9ee99d98deefa63b87a56cbc3af74e3b3a3a10243190378001a8d024c60	f	\N	\N	910909092	\N	\N	\N
3	3	0	5oP9ib6ym3XZDGeERiNvY38B7iJLEdZcDGR3aS3Uh4JgmgUxX5dsevw9SBvFWpPNaY	\\x82d818582683581c20f6afba1add5bf11a4e7d7dd9d01147df4cd9424f0fe5f265303f57a10243190378001a69938c0d	f	\N	\N	910909092	\N	\N	\N
4	4	0	5oP9ib6ym3XcLwBjMjWRbPDaEA5FTLr4SijDJksk1ZuZAbRtM7nSC4Uup2XfAMzq5G	\\x82d818582683581c600025079705d614bf047e8fca978aaba71e7f6a2f7dbb5ebf8a35b4a10243190378001a18ed99ff	f	\N	\N	910909092	\N	\N	\N
5	5	0	5oP9ib6ym3XdXaP3vjYrHFvi4g1GUYQFF5328oUicDFYPcUxt9E1DZafrS3swDv2eU	\\x82d818582683581c77d1a02771150ac53b7b6495b88b68e6e5e376987c76baa01c193596a10243190378001a903face9	f	\N	\N	910909092	\N	\N	\N
6	6	0	5oP9ib6ym3XfCq7GJgU722GqLpjCJ8gwMidZGKXmkCJJtmfnzput2vVxKZeJiyV2vn	\\x82d818582683581c9990cc38c81ff59ccbae71e5d6c8c2da6be55cfa9ed9a53f447012bfa10243190378001a80ad1693	f	\N	\N	910909092	\N	\N	\N
7	7	0	5oP9ib6ym3XgDqvb9mHGEoaJE7rCa9Hw8MshtQdtxAt2j9FunrJDmXaaAQzUTG2Lyg	\\x82d818582683581cae0b14e130ff1dcc1c0b229ba3225127966ab13b5828e110f5623a94a10243190378001a0712831b	f	\N	\N	910909092	\N	\N	\N
8	8	0	5oP9ib6ym3Xh63wPaVWi33LmiXBYS1CWxyhdTXZLaXXWa3L5pZC67FhmSXoPhAbNes	\\x82d818582683581cbf770930ae7b6e474c8127b406de3af17103d38409c810433896f53ba10243190378001a84d550e8	f	\N	\N	910909092	\N	\N	\N
9	9	0	5oP9ib6ym3XhTWkVvsz7gSz36yoS3GtZKMqYEPwmj87HFtF9uDuxnyG6684E4aT8ao	\\x82d818582683581cc6e98db59b4ce824a70d1343a61ab130d7427e265190c2b976d9ea2ea10243190378001a65246164	f	\N	\N	910909092	\N	\N	\N
10	10	0	5oP9ib6ym3Xik4jZLPs95ceitW1TBdGrh2MyGNnmpgcCkXsU9xFkjaRhxyE92G7aaV	\\x82d818582683581ce0c80a15ecff5ff10e9cc82c86729586ea9d080171fabd45a2cc4eb0a10243190378001a3b99a83a	f	\N	\N	910909092	\N	\N	\N
11	11	0	5oP9ib6ym3Xj7f59b8eAvs6SMtxpeW7FNcPShr67a33L1SoKYHDJGc4tahA4PNEjFm	\\x82d818582683581ce846153b79fc37416a9bb36e04ad72337c1c0c31e424b34287ddbe4aa10243190378001ab0e3f498	f	\N	\N	910909092	\N	\N	\N
12	12	0	addr_test1vqufkralfg2swpqmam0ju4m23kegspt507rvycsf3kgp4zg984qme	\\x60389b0fbf4a1507041beedf2e576a8db28805747f86c262098d901a89	f	\\x389b0fbf4a1507041beedf2e576a8db28805747f86c262098d901a89	\N	3681818181818181	\N	\N	\N
13	13	0	addr_test1vrwgltwjr47kl95qznjmx9ek2q2933mwtte8e79tfmk3zaq636x3e	\\x60dc8fadd21d7d6f968014e5b31736501458c76e5af27cf8ab4eed1174	f	\\xdc8fadd21d7d6f968014e5b31736501458c76e5af27cf8ab4eed1174	\N	3681818181818181	\N	\N	\N
14	14	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681818181818181	\N	\N	\N
15	15	0	addr_test1qqaenqgd3egzhqvy4ntu08a2thzc4evsqpdlrh5uwphu0ngz5dvu7shk40ker56j5krms276wglhmufy0knah2whqydsx5xmn7	\\x003b99810d8e502b8184acd7c79faa5dc58ae590005bf1de9c706fc7cd02a359cf42f6abed91d352a587b82bda723f7df1247da7dba9d7011b	f	\\x3b99810d8e502b8184acd7c79faa5dc58ae590005bf1de9c706fc7cd	\N	7772727272727272	\N	\N	\N
16	16	0	addr_test1vqwejy8u4macnya74feaege8ydks4hgnqyuc5xzfsthukps25r2lv	\\x601d9910fcaefb8993beaa73dca327236d0add1301398a184982efcb06	f	\\x1d9910fcaefb8993beaa73dca327236d0add1301398a184982efcb06	\N	3681818181818190	\N	\N	\N
17	17	0	addr_test1qzwuakv4k5zsdde5t464zwd5lm8nev3ydzdusns55hlwma4quc8v3pktf29sde2jr3n4vrzvtdg8yu7alwnpt5q2emmq3446y4	\\x009dced995b50506b7345d755139b4fecf3cb224689bc84e14a5feedf6a0e60ec886cb4a8b06e5521c67560c4c5b507273ddfba615d00acef6	f	\\x9dced995b50506b7345d755139b4fecf3cb224689bc84e14a5feedf6	\N	7772727272727272	\N	\N	\N
18	18	0	addr_test1vpknzrycpwe53fs7eqal7tu3gfpu54fdkec4lszwu8jkgwstf57s8	\\x606d310c980bb348a61ec83bff2f914243ca552db6715fc04ee1e5643a	f	\\x6d310c980bb348a61ec83bff2f914243ca552db6715fc04ee1e5643a	\N	3681818181818181	\N	\N	\N
19	19	0	addr_test1qp958ppazce6uufhzur6pwdjk3c6a0xgk9tts3hnsc8rat3vefe77gh367wr8h58gwlfaysvqp6djjdrhxjhh7498vfshd0cvy	\\x004b43843d1633ae71371707a0b9b2b471aebcc8b156b846f3860e3eae2cca73ef22f1d79c33de8743be9e920c0074d949a3b9a57bfaa53b13	f	\\x4b43843d1633ae71371707a0b9b2b471aebcc8b156b846f3860e3eae	\N	7772727272727272	\N	\N	\N
20	20	0	addr_test1qrj48qhw3j0970rmkh3gn43rjv762yucynrjsz2rrlkz9jzy2rrdzujeskeq65qa9hqh8s8st8n9fmqvpagt03wqzcmqvxn9j6	\\x00e55382ee8c9e5f3c7bb5e289d623933da5139824c72809431fec22c84450c6d1725985b20d501d2dc173c0f059e654ec0c0f50b7c5c01636	f	\\xe55382ee8c9e5f3c7bb5e289d623933da5139824c72809431fec22c8	\N	7772727272727272	\N	\N	\N
21	21	0	addr_test1vq3d0r88ks3qellmuy93l444m9xjy4hc5zk5xzy4s24dscs95srvn	\\x6022d78ce7b4220cfffbe10b1fd6b5d94d2256f8a0ad43089582aad862	f	\\x22d78ce7b4220cfffbe10b1fd6b5d94d2256f8a0ad43089582aad862	\N	3681818181818181	\N	\N	\N
22	22	0	addr_test1qqh7ml9mf8r7us9a8ldgv4dkzg8x55pu0ns9wtwggu2asu33sda5lwez2ed2cr5xgpx07x40d6uex90wuqtxva6s5mvs5nagzx	\\x002fedfcbb49c7ee40bd3fda8655b6120e6a503c7ce0572dc84715d87231837b4fbb22565aac0e86404cff1aaf6eb99315eee016667750a6d9	f	\\x2fedfcbb49c7ee40bd3fda8655b6120e6a503c7ce0572dc84715d872	\N	7772727272727272	\N	\N	\N
23	23	0	addr_test1qqcl8ka3qc9amjm7tuvnyteyydjdta7tu3vzeyz0tpy9achm92qk3q7axgte9s8ys5rsg4mgchy2thjfmhre0m6h69cs8lcqgq	\\x0031f3dbb1060bddcb7e5f19322f242364d5f7cbe4582c904f58485ee2fb2a816883dd321792c0e48507045768c5c8a5de49ddc797ef57d171	f	\\x31f3dbb1060bddcb7e5f19322f242364d5f7cbe4582c904f58485ee2	\N	7772727272727272	\N	\N	\N
24	24	0	addr_test1qqu9dayrgakpykejnc0amxd3xwtsjnumkjnpcs0qkq4pvea8hmm4hcrfj735yg9med4kdf5p4zu5aasvqdun6seyw6nsqucxed	\\x003856f483476c125b329e1fdd99b13397094f9bb4a61c41e0b02a1667a7bef75be06997a34220bbcb6b66a681a8b94ef60c03793d432476a7	f	\\x3856f483476c125b329e1fdd99b13397094f9bb4a61c41e0b02a1667	\N	7772727272727280	\N	\N	\N
25	25	0	addr_test1qpme8m8vzxwgafhmqjm8kzsutfmhssdxvd4dhcg648mxacnau3n0ealv5u05ved8a8xknpdt5wp9k6fddmmjnety5rlqad7qhc	\\x007793ecec119c8ea6fb04b67b0a1c5a777841a6636adbe11aa9f66ee27de466fcf7eca71f4665a7e9cd6985aba3825b692d6ef729e564a0fe	f	\\x7793ecec119c8ea6fb04b67b0a1c5a777841a6636adbe11aa9f66ee2	\N	7772727272727272	\N	\N	\N
26	26	0	addr_test1vqpqg6vts75lglxklzfeynn35mrvq7s23wvapfyhj8p30kqawpwge	\\x600204698b87a9f47cd6f893924e71a6c6c07a0a8b99d0a49791c317d8	f	\\x0204698b87a9f47cd6f893924e71a6c6c07a0a8b99d0a49791c317d8	\N	3681818181818181	\N	\N	\N
27	27	0	addr_test1vpl2gr4vhhwyg4wsc67kzvt7pxhp4c84v0h36fvmr7770hgyess7n	\\x607ea40eacbddc4455d0c6bd61317e09ae1ae0f563ef1d259b1fbde7dd	f	\\x7ea40eacbddc4455d0c6bd61317e09ae1ae0f563ef1d259b1fbde7dd	\N	3681818181818181	\N	\N	\N
28	28	0	addr_test1vr0y09vwa7schmpk9seeypem6hqt8asfvw9xdpyw3cpwltswzc0ka	\\x60de47958eefa18bec362c3392073bd5c0b3f609638a66848e8e02efae	f	\\xde47958eefa18bec362c3392073bd5c0b3f609638a66848e8e02efae	\N	3681818181818181	\N	\N	\N
29	29	0	addr_test1vpajksvryqcy5lnp5n5c7t7axylcf07kqpregyfmx6zxcugargcnd	\\x607b2b418320304a7e61a4e98f2fdd313f84bfd6004794113b36846c71	f	\\x7b2b418320304a7e61a4e98f2fdd313f84bfd6004794113b36846c71	\N	3681818181818181	\N	\N	\N
30	30	0	addr_test1qp8p8wf6yluqdjau0lzlusg3yvepzmghrldysrt5k9pgj8wq73askc5rd4ukvdh4g8urqndcn3mf28clz2uqtahhh00qp26ddz	\\x004e13b93a27f806cbbc7fc5fe41112332116d171fda480d74b142891dc0f47b0b62836d796636f541f8304db89c76951f1f12b805f6f7bbde	f	\\x4e13b93a27f806cbbc7fc5fe41112332116d171fda480d74b142891d	\N	7772727272727272	\N	\N	\N
31	31	0	addr_test1vrnvef39xzzr7my9t4dp2d4mt0m0k57hznahw82dl72csrsuc2g9u	\\x60e6cca62530843f6c855d5a1536bb5bf6fb53d714fb771d4dff95880e	f	\\xe6cca62530843f6c855d5a1536bb5bf6fb53d714fb771d4dff95880e	\N	3681818181818181	\N	\N	\N
32	32	0	addr_test1qppz7j4ufnn0vnacf4sldtd9r3ygy644jxlg8v27mc6ddx466cktsdqnscpmqj79g69tmuccfn2mf2adavuh84gkkxjscdsyth	\\x00422f4abc4ce6f64fb84d61f6ada51c48826ab591be83b15ede34d69abad62cb834138603b04bc5468abdf3184cd5b4abadeb3973d516b1a5	f	\\x422f4abc4ce6f64fb84d61f6ada51c48826ab591be83b15ede34d69a	\N	7772727272727272	\N	\N	\N
33	33	0	addr_test1qrlfgzzfdpp9ghc294ecs39yy2trl7q0k2urgye7xuh663vn0r7gcuy4942mnwe4cz8gkm62h2kr6sc48n5f7tj4q2jsfmtl89	\\x00fe9408496842545f0a2d738844a422963ff80fb2b834133e372fad459378fc8c70952d55b9bb35c08e8b6f4abaac3d43153ce89f2e5502a5	f	\\xfe9408496842545f0a2d738844a422963ff80fb2b834133e372fad45	\N	7772727272727272	\N	\N	\N
34	35	0	addr_test1qqgtdmts7zmfx24g042gjfy6gp3cyfrwn5hd8tjyxqp7gtpguw733keaw5j226rcx6kgxqzw74v0lxvyhtl9nzsrzuzsjrvkwq	\\x0010b6ed70f0b6932aa87d5489249a406382246e9d2ed3ae443003e42c28e3bd18db3d7524a5687836ac83004ef558ff9984bafe598a031705	f	\\x10b6ed70f0b6932aa87d5489249a406382246e9d2ed3ae443003e42c	34	500000000000	\N	\N	\N
35	35	1	addr_test1vq3d0r88ks3qellmuy93l444m9xjy4hc5zk5xzy4s24dscs95srvn	\\x6022d78ce7b4220cfffbe10b1fd6b5d94d2256f8a0ad43089582aad862	f	\\x22d78ce7b4220cfffbe10b1fd6b5d94d2256f8a0ad43089582aad862	\N	3681318181651228	\N	\N	\N
36	36	0	addr_test1qzduy0tv07da4aauq397tctglyy4xt42p2y4lsyg7qvcs4t2vj22evj3q3f8fpe6lsg34vs3nta5xafp4enru2s4h57qc7j076	\\x009bc23d6c7f9bdaf7bc044be5e168f909532eaa0a895fc088f01988556a6494acb251045274873afc111ab2119afb437521ae663e2a15bd3c	f	\\x9bc23d6c7f9bdaf7bc044be5e168f909532eaa0a895fc088f0198855	35	500000000000	\N	\N	\N
37	36	1	addr_test1vr0y09vwa7schmpk9seeypem6hqt8asfvw9xdpyw3cpwltswzc0ka	\\x60de47958eefa18bec362c3392073bd5c0b3f609638a66848e8e02efae	f	\\xde47958eefa18bec362c3392073bd5c0b3f609638a66848e8e02efae	\N	3681318181651228	\N	\N	\N
38	37	0	addr_test1qpmw0tuq7ltlf0tqc5frf9dmxzmswg7g4tqd24lz7fz2j6qqk5cycxz8xktq4pj9egjyqwqg5xzvyk5v8g6mrw7l5x5s8cyzzc	\\x0076e7af80f7d7f4bd60c5123495bb30b70723c8aac0d557e2f244a96800b5304c184735960a8645ca24403808a184c25a8c3a35b1bbdfa1a9	f	\\x76e7af80f7d7f4bd60c5123495bb30b70723c8aac0d557e2f244a968	36	500000000000	\N	\N	\N
39	37	1	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681318181651228	\N	\N	\N
40	38	0	addr_test1qrw0706tlwmaq99mjpmvvhwzcj85x9e7k3p9hnykkxek2y09wljr2dxpq7855vp2f4uwyjlrsz5kmg3s8d6cgzxd44mq235jj5	\\x00dcff3f4bfbb7d014bb9076c65dc2c48f43173eb4425bcc96b1b36511e577e43534c1078f4a302a4d78e24be380a96da2303b758408cdad76	f	\\xdcff3f4bfbb7d014bb9076c65dc2c48f43173eb4425bcc96b1b36511	37	500000000000	\N	\N	\N
41	38	1	addr_test1vqpqg6vts75lglxklzfeynn35mrvq7s23wvapfyhj8p30kqawpwge	\\x600204698b87a9f47cd6f893924e71a6c6c07a0a8b99d0a49791c317d8	f	\\x0204698b87a9f47cd6f893924e71a6c6c07a0a8b99d0a49791c317d8	\N	3681318181651228	\N	\N	\N
42	39	0	addr_test1qq7r8erzh758deew2wlk3wy23lnrtvwhh5j3ycstnzvm99qhx2xuqxtahsehedcvsjp2lerurhddta83c6egqrgaw2qqvm0cdx	\\x003c33e462bfa876e72e53bf68b88a8fe635b1d7bd2512620b9899b29417328dc0197dbc337cb70c8482afe47c1ddad5f4f1c6b2800d1d7280	f	\\x3c33e462bfa876e72e53bf68b88a8fe635b1d7bd2512620b9899b294	38	500000000000	\N	\N	\N
43	39	1	addr_test1vpknzrycpwe53fs7eqal7tu3gfpu54fdkec4lszwu8jkgwstf57s8	\\x606d310c980bb348a61ec83bff2f914243ca552db6715fc04ee1e5643a	f	\\x6d310c980bb348a61ec83bff2f914243ca552db6715fc04ee1e5643a	\N	3681318181651228	\N	\N	\N
44	40	0	addr_test1qpwmn2t05us3nh09rta0t2elkpnkjcftamj636efvxn7q8xcvl6rwrvffz8w3gvpu6acrmjjvumzjrvm3fhnlnkt4qysslcjzx	\\x005db9a96fa72119dde51afaf5ab3fb06769612beee5a8eb2961a7e01cd867f4370d89488ee8a181e6bb81ee526736290d9b8a6f3fcecba809	f	\\x5db9a96fa72119dde51afaf5ab3fb06769612beee5a8eb2961a7e01c	39	500000000000	\N	\N	\N
45	40	1	addr_test1vpl2gr4vhhwyg4wsc67kzvt7pxhp4c84v0h36fvmr7770hgyess7n	\\x607ea40eacbddc4455d0c6bd61317e09ae1ae0f563ef1d259b1fbde7dd	f	\\x7ea40eacbddc4455d0c6bd61317e09ae1ae0f563ef1d259b1fbde7dd	\N	3681318181651228	\N	\N	\N
46	41	0	addr_test1qrtvahkxeewx7ty945l8uth06emg8agdakf6nr8lxymgm4vugvl3je5acm2r3l0e6zawu86vcjjszf294se3z2j6tl5sa4gyfg	\\x00d6cedec6ce5c6f2c85ad3e7e2eefd67683f50ded93a98cff31368dd59c433f19669dc6d438fdf9d0baee1f4cc4a5012545ac33112a5a5fe9	f	\\xd6cedec6ce5c6f2c85ad3e7e2eefd67683f50ded93a98cff31368dd5	40	500000000000	\N	\N	\N
47	41	1	addr_test1vpajksvryqcy5lnp5n5c7t7axylcf07kqpregyfmx6zxcugargcnd	\\x607b2b418320304a7e61a4e98f2fdd313f84bfd6004794113b36846c71	f	\\x7b2b418320304a7e61a4e98f2fdd313f84bfd6004794113b36846c71	\N	3681318181651228	\N	\N	\N
48	42	0	addr_test1qr7dctkkc8yq4qqw0x7ez9w8maldmu9qhxxwsay3lppg4jh3skc9ftg2c8uv58qag90gt0f7ccmu4jvtat4wygndek0s9h644l	\\x00fcdc2ed6c1c80a800e79bd9115c7df7eddf0a0b98ce87491f8428acaf185b054ad0ac1f8ca1c1d415e85bd3ec637cac98beaeae2226dcd9f	f	\\xfcdc2ed6c1c80a800e79bd9115c7df7eddf0a0b98ce87491f8428aca	41	500000000000	\N	\N	\N
49	42	1	addr_test1vrwgltwjr47kl95qznjmx9ek2q2933mwtte8e79tfmk3zaq636x3e	\\x60dc8fadd21d7d6f968014e5b31736501458c76e5af27cf8ab4eed1174	f	\\xdc8fadd21d7d6f968014e5b31736501458c76e5af27cf8ab4eed1174	\N	3681318181651228	\N	\N	\N
50	43	0	addr_test1qqa2gsteqnl0tlp6zkeg6xtk77lp0tx8wqmz8alll553v0yjxyxv7sg7qdgpnrhxw3dx67vrx2ty682yfpu483xvfpqq37lceq	\\x003aa4417904fef5fc3a15b28d1976f7be17acc7703623f7fffd29163c92310ccf411e0350198ee6745a6d798332964d1d44487953c4cc4840	f	\\x3aa4417904fef5fc3a15b28d1976f7be17acc7703623f7fffd29163c	42	500000000000	\N	\N	\N
51	43	1	addr_test1vqufkralfg2swpqmam0ju4m23kegspt507rvycsf3kgp4zg984qme	\\x60389b0fbf4a1507041beedf2e576a8db28805747f86c262098d901a89	f	\\x389b0fbf4a1507041beedf2e576a8db28805747f86c262098d901a89	\N	3681318181651228	\N	\N	\N
52	44	0	addr_test1qqcmh8dznnfhjy57ummn9y86w42xuh5yuqx9t4wl3yxyg8umjs9cds6ruk7alu7jfv7dykw2mkm5xkwsy5qd2v42nu8sjjgyew	\\x0031bb9da29cd379129ee6f73290fa75546e5e84e00c55d5df890c441f9b940b86c343e5bddff3d24b3cd259caddb74359d02500d532aa9f0f	f	\\x31bb9da29cd379129ee6f73290fa75546e5e84e00c55d5df890c441f	43	500000000000	\N	\N	\N
53	44	1	addr_test1vrnvef39xzzr7my9t4dp2d4mt0m0k57hznahw82dl72csrsuc2g9u	\\x60e6cca62530843f6c855d5a1536bb5bf6fb53d714fb771d4dff95880e	f	\\xe6cca62530843f6c855d5a1536bb5bf6fb53d714fb771d4dff95880e	\N	3681318181651228	\N	\N	\N
54	45	0	addr_test1qp6jcr9p3cygyvl9gglspnc8jtefzl65pt7qcfeqweeheuxdrq0j2p7aj2lmxwu7u87ykegunlt49x67v3r07agl54mqnx384n	\\x00752c0ca18e088233e5423f00cf0792f2917f540afc0c272076737cf0cd181f2507dd92bfb33b9ee1fc4b651c9fd7529b5e6446ff751fa576	f	\\x752c0ca18e088233e5423f00cf0792f2917f540afc0c272076737cf0	44	500000000000	\N	\N	\N
55	45	1	addr_test1vqwejy8u4macnya74feaege8ydks4hgnqyuc5xzfsthukps25r2lv	\\x601d9910fcaefb8993beaa73dca327236d0add1301398a184982efcb06	f	\\x1d9910fcaefb8993beaa73dca327236d0add1301398a184982efcb06	\N	3681318181651237	\N	\N	\N
56	46	0	addr_test1qqgtdmts7zmfx24g042gjfy6gp3cyfrwn5hd8tjyxqp7gtpguw733keaw5j226rcx6kgxqzw74v0lxvyhtl9nzsrzuzsjrvkwq	\\x0010b6ed70f0b6932aa87d5489249a406382246e9d2ed3ae443003e42c28e3bd18db3d7524a5687836ac83004ef558ff9984bafe598a031705	f	\\x10b6ed70f0b6932aa87d5489249a406382246e9d2ed3ae443003e42c	34	499999828647	\N	\N	\N
57	47	0	addr_test1qzduy0tv07da4aauq397tctglyy4xt42p2y4lsyg7qvcs4t2vj22evj3q3f8fpe6lsg34vs3nta5xafp4enru2s4h57qc7j076	\\x009bc23d6c7f9bdaf7bc044be5e168f909532eaa0a895fc088f01988556a6494acb251045274873afc111ab2119afb437521ae663e2a15bd3c	f	\\x9bc23d6c7f9bdaf7bc044be5e168f909532eaa0a895fc088f0198855	35	499999828647	\N	\N	\N
58	48	0	addr_test1qpmw0tuq7ltlf0tqc5frf9dmxzmswg7g4tqd24lz7fz2j6qqk5cycxz8xktq4pj9egjyqwqg5xzvyk5v8g6mrw7l5x5s8cyzzc	\\x0076e7af80f7d7f4bd60c5123495bb30b70723c8aac0d557e2f244a96800b5304c184735960a8645ca24403808a184c25a8c3a35b1bbdfa1a9	f	\\x76e7af80f7d7f4bd60c5123495bb30b70723c8aac0d557e2f244a968	36	499999828647	\N	\N	\N
59	49	0	addr_test1qrw0706tlwmaq99mjpmvvhwzcj85x9e7k3p9hnykkxek2y09wljr2dxpq7855vp2f4uwyjlrsz5kmg3s8d6cgzxd44mq235jj5	\\x00dcff3f4bfbb7d014bb9076c65dc2c48f43173eb4425bcc96b1b36511e577e43534c1078f4a302a4d78e24be380a96da2303b758408cdad76	f	\\xdcff3f4bfbb7d014bb9076c65dc2c48f43173eb4425bcc96b1b36511	37	499999828647	\N	\N	\N
60	50	0	addr_test1qq7r8erzh758deew2wlk3wy23lnrtvwhh5j3ycstnzvm99qhx2xuqxtahsehedcvsjp2lerurhddta83c6egqrgaw2qqvm0cdx	\\x003c33e462bfa876e72e53bf68b88a8fe635b1d7bd2512620b9899b29417328dc0197dbc337cb70c8482afe47c1ddad5f4f1c6b2800d1d7280	f	\\x3c33e462bfa876e72e53bf68b88a8fe635b1d7bd2512620b9899b294	38	499999828647	\N	\N	\N
61	51	0	addr_test1qpwmn2t05us3nh09rta0t2elkpnkjcftamj636efvxn7q8xcvl6rwrvffz8w3gvpu6acrmjjvumzjrvm3fhnlnkt4qysslcjzx	\\x005db9a96fa72119dde51afaf5ab3fb06769612beee5a8eb2961a7e01cd867f4370d89488ee8a181e6bb81ee526736290d9b8a6f3fcecba809	f	\\x5db9a96fa72119dde51afaf5ab3fb06769612beee5a8eb2961a7e01c	39	499999828647	\N	\N	\N
62	52	0	addr_test1qrtvahkxeewx7ty945l8uth06emg8agdakf6nr8lxymgm4vugvl3je5acm2r3l0e6zawu86vcjjszf294se3z2j6tl5sa4gyfg	\\x00d6cedec6ce5c6f2c85ad3e7e2eefd67683f50ded93a98cff31368dd59c433f19669dc6d438fdf9d0baee1f4cc4a5012545ac33112a5a5fe9	f	\\xd6cedec6ce5c6f2c85ad3e7e2eefd67683f50ded93a98cff31368dd5	40	499999828647	\N	\N	\N
63	53	0	addr_test1qr7dctkkc8yq4qqw0x7ez9w8maldmu9qhxxwsay3lppg4jh3skc9ftg2c8uv58qag90gt0f7ccmu4jvtat4wygndek0s9h644l	\\x00fcdc2ed6c1c80a800e79bd9115c7df7eddf0a0b98ce87491f8428acaf185b054ad0ac1f8ca1c1d415e85bd3ec637cac98beaeae2226dcd9f	f	\\xfcdc2ed6c1c80a800e79bd9115c7df7eddf0a0b98ce87491f8428aca	41	499999828647	\N	\N	\N
64	54	0	addr_test1qqa2gsteqnl0tlp6zkeg6xtk77lp0tx8wqmz8alll553v0yjxyxv7sg7qdgpnrhxw3dx67vrx2ty682yfpu483xvfpqq37lceq	\\x003aa4417904fef5fc3a15b28d1976f7be17acc7703623f7fffd29163c92310ccf411e0350198ee6745a6d798332964d1d44487953c4cc4840	f	\\x3aa4417904fef5fc3a15b28d1976f7be17acc7703623f7fffd29163c	42	499999828647	\N	\N	\N
65	55	0	addr_test1qqcmh8dznnfhjy57ummn9y86w42xuh5yuqx9t4wl3yxyg8umjs9cds6ruk7alu7jfv7dykw2mkm5xkwsy5qd2v42nu8sjjgyew	\\x0031bb9da29cd379129ee6f73290fa75546e5e84e00c55d5df890c441f9b940b86c343e5bddff3d24b3cd259caddb74359d02500d532aa9f0f	f	\\x31bb9da29cd379129ee6f73290fa75546e5e84e00c55d5df890c441f	43	499999828647	\N	\N	\N
66	56	0	addr_test1qp6jcr9p3cygyvl9gglspnc8jtefzl65pt7qcfeqweeheuxdrq0j2p7aj2lmxwu7u87ykegunlt49x67v3r07agl54mqnx384n	\\x00752c0ca18e088233e5423f00cf0792f2917f540afc0c272076737cf0cd181f2507dd92bfb33b9ee1fc4b651c9fd7529b5e6446ff751fa576	f	\\x752c0ca18e088233e5423f00cf0792f2917f540afc0c272076737cf0	44	499999828647	\N	\N	\N
67	57	0	addr_test1qqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9psjg2kl0ca4eer00l9tuwnrmljh5a54decgcs93sh85j2n7s9h0wj8	\\x00305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c24855befc76b9c8deff957c74c7bfcaf4ed2adce11881630b9e9254fd	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	19	500000000	\N	\N	\N
68	57	1	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681317681484451	\N	\N	\N
69	58	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681317681306542	\N	\N	\N
70	59	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681317681127313	\N	\N	\N
71	60	0	addr_test1qqgtdmts7zmfx24g042gjfy6gp3cyfrwn5hd8tjyxqp7gtpguw733keaw5j226rcx6kgxqzw74v0lxvyhtl9nzsrzuzsjrvkwq	\\x0010b6ed70f0b6932aa87d5489249a406382246e9d2ed3ae443003e42c28e3bd18db3d7524a5687836ac83004ef558ff9984bafe598a031705	f	\\x10b6ed70f0b6932aa87d5489249a406382246e9d2ed3ae443003e42c	34	499999648186	\N	\N	\N
72	61	0	addr_test1qqgtdmts7zmfx24g042gjfy6gp3cyfrwn5hd8tjyxqp7gtpguw733keaw5j226rcx6kgxqzw74v0lxvyhtl9nzsrzuzsjrvkwq	\\x0010b6ed70f0b6932aa87d5489249a406382246e9d2ed3ae443003e42c28e3bd18db3d7524a5687836ac83004ef558ff9984bafe598a031705	f	\\x10b6ed70f0b6932aa87d5489249a406382246e9d2ed3ae443003e42c	34	499999454261	\N	\N	\N
73	62	0	addr_test1qqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9psjzps9fvkpq5l5du6mrtadhu2a7qcm0ef0nu0gfdxgxttns0wlvr6	\\x00305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2420c0a965820a7e8de6b635f5b7e2bbe0636fca5f3e3d09699065ae7	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	13	600000000	\N	\N	\N
74	62	1	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681317080960536	\N	\N	\N
75	63	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681317080782627	\N	\N	\N
76	64	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681317080603398	\N	\N	\N
77	65	0	addr_test1qzduy0tv07da4aauq397tctglyy4xt42p2y4lsyg7qvcs4t2vj22evj3q3f8fpe6lsg34vs3nta5xafp4enru2s4h57qc7j076	\\x009bc23d6c7f9bdaf7bc044be5e168f909532eaa0a895fc088f01988556a6494acb251045274873afc111ab2119afb437521ae663e2a15bd3c	f	\\x9bc23d6c7f9bdaf7bc044be5e168f909532eaa0a895fc088f0198855	35	499999648186	\N	\N	\N
78	66	0	addr_test1qzduy0tv07da4aauq397tctglyy4xt42p2y4lsyg7qvcs4t2vj22evj3q3f8fpe6lsg34vs3nta5xafp4enru2s4h57qc7j076	\\x009bc23d6c7f9bdaf7bc044be5e168f909532eaa0a895fc088f01988556a6494acb251045274873afc111ab2119afb437521ae663e2a15bd3c	f	\\x9bc23d6c7f9bdaf7bc044be5e168f909532eaa0a895fc088f0198855	35	499999457033	\N	\N	\N
79	67	0	addr_test1qqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssqd90q964l6dh88k6jq32tf9aq25wlz7mfheqs9ytu8sesp90hqn	\\x00305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c200695e02eabfd36e73db520454b497a0551df17b69be4102917c3c33	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	22	200000000	\N	\N	\N
80	67	1	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681316880436621	\N	\N	\N
81	68	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681316880258712	\N	\N	\N
82	69	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681316880079483	\N	\N	\N
83	70	0	addr_test1qpmw0tuq7ltlf0tqc5frf9dmxzmswg7g4tqd24lz7fz2j6qqk5cycxz8xktq4pj9egjyqwqg5xzvyk5v8g6mrw7l5x5s8cyzzc	\\x0076e7af80f7d7f4bd60c5123495bb30b70723c8aac0d557e2f244a96800b5304c184735960a8645ca24403808a184c25a8c3a35b1bbdfa1a9	f	\\x76e7af80f7d7f4bd60c5123495bb30b70723c8aac0d557e2f244a968	36	499999648186	\N	\N	\N
84	71	0	addr_test1qpmw0tuq7ltlf0tqc5frf9dmxzmswg7g4tqd24lz7fz2j6qqk5cycxz8xktq4pj9egjyqwqg5xzvyk5v8g6mrw7l5x5s8cyzzc	\\x0076e7af80f7d7f4bd60c5123495bb30b70723c8aac0d557e2f244a96800b5304c184735960a8645ca24403808a184c25a8c3a35b1bbdfa1a9	f	\\x76e7af80f7d7f4bd60c5123495bb30b70723c8aac0d557e2f244a968	36	499999454261	\N	\N	\N
85	72	0	addr_test1qqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssp368mlr9fr3ccaywaurgkevpfymslwz9sr000p8w7lvwsdw62vv	\\x00305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2018e8fbf8ca91c718e91dde0d16cb02926e1f708b01bdef09ddefb1d	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	14	500000000	\N	\N	\N
86	72	1	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681316379912706	\N	\N	\N
87	73	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681316379734797	\N	\N	\N
88	74	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681316379555568	\N	\N	\N
89	75	0	addr_test1qrw0706tlwmaq99mjpmvvhwzcj85x9e7k3p9hnykkxek2y09wljr2dxpq7855vp2f4uwyjlrsz5kmg3s8d6cgzxd44mq235jj5	\\x00dcff3f4bfbb7d014bb9076c65dc2c48f43173eb4425bcc96b1b36511e577e43534c1078f4a302a4d78e24be380a96da2303b758408cdad76	f	\\xdcff3f4bfbb7d014bb9076c65dc2c48f43173eb4425bcc96b1b36511	37	499999648186	\N	\N	\N
90	76	0	addr_test1qrw0706tlwmaq99mjpmvvhwzcj85x9e7k3p9hnykkxek2y09wljr2dxpq7855vp2f4uwyjlrsz5kmg3s8d6cgzxd44mq235jj5	\\x00dcff3f4bfbb7d014bb9076c65dc2c48f43173eb4425bcc96b1b36511e577e43534c1078f4a302a4d78e24be380a96da2303b758408cdad76	f	\\xdcff3f4bfbb7d014bb9076c65dc2c48f43173eb4425bcc96b1b36511	37	499999454261	\N	\N	\N
91	77	0	addr_test1qqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssdrm4h2zft0rhuvlcr6ggjxrhae43zt9968agh02m5k2ksk0chsv	\\x00305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c20d1eeb75092b78efc67f03d211230efdcd622594ba3f5177ab74b2ad	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	18	500000000	\N	\N	\N
92	77	1	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681315879388791	\N	\N	\N
93	78	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681315879210882	\N	\N	\N
94	79	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681315879031653	\N	\N	\N
95	80	0	addr_test1qq7r8erzh758deew2wlk3wy23lnrtvwhh5j3ycstnzvm99qhx2xuqxtahsehedcvsjp2lerurhddta83c6egqrgaw2qqvm0cdx	\\x003c33e462bfa876e72e53bf68b88a8fe635b1d7bd2512620b9899b29417328dc0197dbc337cb70c8482afe47c1ddad5f4f1c6b2800d1d7280	f	\\x3c33e462bfa876e72e53bf68b88a8fe635b1d7bd2512620b9899b294	38	499999648186	\N	\N	\N
96	81	0	addr_test1qq7r8erzh758deew2wlk3wy23lnrtvwhh5j3ycstnzvm99qhx2xuqxtahsehedcvsjp2lerurhddta83c6egqrgaw2qqvm0cdx	\\x003c33e462bfa876e72e53bf68b88a8fe635b1d7bd2512620b9899b29417328dc0197dbc337cb70c8482afe47c1ddad5f4f1c6b2800d1d7280	f	\\x3c33e462bfa876e72e53bf68b88a8fe635b1d7bd2512620b9899b294	38	499999454261	\N	\N	\N
97	82	0	addr_test1qqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pskye0cvtldkkej74fch22ws02v2dewaee7ctp22nf95ht6qvv5yfp	\\x00305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2c4cbf0c5fdb6b665eaa717529d07a98a6e5ddce7d85854a9a4b4baf4	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	15	500000000	\N	\N	\N
98	82	1	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681315378864876	\N	\N	\N
99	83	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681315378686967	\N	\N	\N
100	84	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681315378507738	\N	\N	\N
101	85	0	addr_test1qpwmn2t05us3nh09rta0t2elkpnkjcftamj636efvxn7q8xcvl6rwrvffz8w3gvpu6acrmjjvumzjrvm3fhnlnkt4qysslcjzx	\\x005db9a96fa72119dde51afaf5ab3fb06769612beee5a8eb2961a7e01cd867f4370d89488ee8a181e6bb81ee526736290d9b8a6f3fcecba809	f	\\x5db9a96fa72119dde51afaf5ab3fb06769612beee5a8eb2961a7e01c	39	499999648186	\N	\N	\N
102	86	0	addr_test1qpwmn2t05us3nh09rta0t2elkpnkjcftamj636efvxn7q8xcvl6rwrvffz8w3gvpu6acrmjjvumzjrvm3fhnlnkt4qysslcjzx	\\x005db9a96fa72119dde51afaf5ab3fb06769612beee5a8eb2961a7e01cd867f4370d89488ee8a181e6bb81ee526736290d9b8a6f3fcecba809	f	\\x5db9a96fa72119dde51afaf5ab3fb06769612beee5a8eb2961a7e01c	39	499999454261	\N	\N	\N
103	87	0	addr_test1qqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9ps56vgm2v5tcgcnlztnpw87cyf2xj93v5palj0zph8g2yqgsydtper	\\x00305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c29a6236a651784627f12e6171fd8225469162ca07bf93c41b9d0a2011	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	20	500000000	\N	\N	\N
104	87	1	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681314878340961	\N	\N	\N
105	88	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681314878163052	\N	\N	\N
106	89	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681314877983823	\N	\N	\N
107	90	0	addr_test1qrtvahkxeewx7ty945l8uth06emg8agdakf6nr8lxymgm4vugvl3je5acm2r3l0e6zawu86vcjjszf294se3z2j6tl5sa4gyfg	\\x00d6cedec6ce5c6f2c85ad3e7e2eefd67683f50ded93a98cff31368dd59c433f19669dc6d438fdf9d0baee1f4cc4a5012545ac33112a5a5fe9	f	\\xd6cedec6ce5c6f2c85ad3e7e2eefd67683f50ded93a98cff31368dd5	40	499999648186	\N	\N	\N
108	91	0	addr_test1qrtvahkxeewx7ty945l8uth06emg8agdakf6nr8lxymgm4vugvl3je5acm2r3l0e6zawu86vcjjszf294se3z2j6tl5sa4gyfg	\\x00d6cedec6ce5c6f2c85ad3e7e2eefd67683f50ded93a98cff31368dd59c433f19669dc6d438fdf9d0baee1f4cc4a5012545ac33112a5a5fe9	f	\\xd6cedec6ce5c6f2c85ad3e7e2eefd67683f50ded93a98cff31368dd5	40	499999454261	\N	\N	\N
109	92	0	addr_test1qqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9psnnc4yj47zjz87ucgq0hgdckaczc7rj3vmelujl0gfa2hcsgzpesn	\\x00305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c273c5492af85211fdcc200fba1b8b7702c78728b379ff25f7a13d55f1	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	21	300000000	\N	\N	\N
110	92	1	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681314577817046	\N	\N	\N
111	93	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681314577639137	\N	\N	\N
112	94	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681314577459908	\N	\N	\N
113	95	0	addr_test1qr7dctkkc8yq4qqw0x7ez9w8maldmu9qhxxwsay3lppg4jh3skc9ftg2c8uv58qag90gt0f7ccmu4jvtat4wygndek0s9h644l	\\x00fcdc2ed6c1c80a800e79bd9115c7df7eddf0a0b98ce87491f8428acaf185b054ad0ac1f8ca1c1d415e85bd3ec637cac98beaeae2226dcd9f	f	\\xfcdc2ed6c1c80a800e79bd9115c7df7eddf0a0b98ce87491f8428aca	41	499999648186	\N	\N	\N
114	96	0	addr_test1qr7dctkkc8yq4qqw0x7ez9w8maldmu9qhxxwsay3lppg4jh3skc9ftg2c8uv58qag90gt0f7ccmu4jvtat4wygndek0s9h644l	\\x00fcdc2ed6c1c80a800e79bd9115c7df7eddf0a0b98ce87491f8428acaf185b054ad0ac1f8ca1c1d415e85bd3ec637cac98beaeae2226dcd9f	f	\\xfcdc2ed6c1c80a800e79bd9115c7df7eddf0a0b98ce87491f8428aca	41	499999457033	\N	\N	\N
115	97	0	addr_test1qr7dctkkc8yq4qqw0x7ez9w8maldmu9qhxxwsay3lppg4jh3skc9ftg2c8uv58qag90gt0f7ccmu4jvtat4wygndek0s9h644l	\\x00fcdc2ed6c1c80a800e79bd9115c7df7eddf0a0b98ce87491f8428acaf185b054ad0ac1f8ca1c1d415e85bd3ec637cac98beaeae2226dcd9f	f	\\xfcdc2ed6c1c80a800e79bd9115c7df7eddf0a0b98ce87491f8428aca	41	499999276572	\N	\N	\N
116	98	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681314577275751	\N	\N	\N
117	99	0	addr_test1qqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9ps38amq4tat7p5ghl3uptk0n3c3dec6tk2j2hxwu3nw0u6vq66d0r8	\\x00305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c227eec155f57e0d117fc7815d9f38e22dce34bb2a4ab99dc8cdcfe698	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	17	300000000	\N	\N	\N
118	99	1	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681314277108974	\N	\N	\N
119	100	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681314276931065	\N	\N	\N
120	101	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681314276751836	\N	\N	\N
121	102	0	addr_test1qqa2gsteqnl0tlp6zkeg6xtk77lp0tx8wqmz8alll553v0yjxyxv7sg7qdgpnrhxw3dx67vrx2ty682yfpu483xvfpqq37lceq	\\x003aa4417904fef5fc3a15b28d1976f7be17acc7703623f7fffd29163c92310ccf411e0350198ee6745a6d798332964d1d44487953c4cc4840	f	\\x3aa4417904fef5fc3a15b28d1976f7be17acc7703623f7fffd29163c	42	499999648186	\N	\N	\N
122	103	0	addr_test1qqa2gsteqnl0tlp6zkeg6xtk77lp0tx8wqmz8alll553v0yjxyxv7sg7qdgpnrhxw3dx67vrx2ty682yfpu483xvfpqq37lceq	\\x003aa4417904fef5fc3a15b28d1976f7be17acc7703623f7fffd29163c92310ccf411e0350198ee6745a6d798332964d1d44487953c4cc4840	f	\\x3aa4417904fef5fc3a15b28d1976f7be17acc7703623f7fffd29163c	42	499999457033	\N	\N	\N
123	104	0	addr_test1qqa2gsteqnl0tlp6zkeg6xtk77lp0tx8wqmz8alll553v0yjxyxv7sg7qdgpnrhxw3dx67vrx2ty682yfpu483xvfpqq37lceq	\\x003aa4417904fef5fc3a15b28d1976f7be17acc7703623f7fffd29163c92310ccf411e0350198ee6745a6d798332964d1d44487953c4cc4840	f	\\x3aa4417904fef5fc3a15b28d1976f7be17acc7703623f7fffd29163c	42	499999276572	\N	\N	\N
124	105	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681314276567679	\N	\N	\N
125	106	0	addr_test1qqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9psnd27u0dwaamchlmup4ullv2qsrg8luc05qrg6pgt2qez6qdlmjy3	\\x00305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c26d57b8f6bbbdde2ffdf035e7fec5020341ffcc3e801a34142d40c8b4	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	16	500000000	\N	\N	\N
126	106	1	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681313776400902	\N	\N	\N
127	107	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681313776222993	\N	\N	\N
128	108	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681313776043764	\N	\N	\N
129	109	0	addr_test1qqcmh8dznnfhjy57ummn9y86w42xuh5yuqx9t4wl3yxyg8umjs9cds6ruk7alu7jfv7dykw2mkm5xkwsy5qd2v42nu8sjjgyew	\\x0031bb9da29cd379129ee6f73290fa75546e5e84e00c55d5df890c441f9b940b86c343e5bddff3d24b3cd259caddb74359d02500d532aa9f0f	f	\\x31bb9da29cd379129ee6f73290fa75546e5e84e00c55d5df890c441f	43	499999648186	\N	\N	\N
130	110	0	addr_test1qqcmh8dznnfhjy57ummn9y86w42xuh5yuqx9t4wl3yxyg8umjs9cds6ruk7alu7jfv7dykw2mkm5xkwsy5qd2v42nu8sjjgyew	\\x0031bb9da29cd379129ee6f73290fa75546e5e84e00c55d5df890c441f9b940b86c343e5bddff3d24b3cd259caddb74359d02500d532aa9f0f	f	\\x31bb9da29cd379129ee6f73290fa75546e5e84e00c55d5df890c441f	43	499999454217	\N	\N	\N
131	111	0	addr_test1qqcmh8dznnfhjy57ummn9y86w42xuh5yuqx9t4wl3yxyg8umjs9cds6ruk7alu7jfv7dykw2mkm5xkwsy5qd2v42nu8sjjgyew	\\x0031bb9da29cd379129ee6f73290fa75546e5e84e00c55d5df890c441f9b940b86c343e5bddff3d24b3cd259caddb74359d02500d532aa9f0f	f	\\x31bb9da29cd379129ee6f73290fa75546e5e84e00c55d5df890c441f	43	499999273756	\N	\N	\N
132	112	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681313775859607	\N	\N	\N
133	113	0	addr_test1qqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pske30gvu4nx6u3arml89kygf8d9z53ff6wfdmnskg255g9seg3yrw	\\x00305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2d98bd0ce5666d723d1efe72d88849da5152294e9c96ee70b2154a20b	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	12	500000000	\N	\N	\N
134	113	1	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681313275692830	\N	\N	\N
135	114	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681313275514921	\N	\N	\N
136	115	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681313275335692	\N	\N	\N
137	116	0	addr_test1qp6jcr9p3cygyvl9gglspnc8jtefzl65pt7qcfeqweeheuxdrq0j2p7aj2lmxwu7u87ykegunlt49x67v3r07agl54mqnx384n	\\x00752c0ca18e088233e5423f00cf0792f2917f540afc0c272076737cf0cd181f2507dd92bfb33b9ee1fc4b651c9fd7529b5e6446ff751fa576	f	\\x752c0ca18e088233e5423f00cf0792f2917f540afc0c272076737cf0	44	499999648186	\N	\N	\N
138	117	0	addr_test1qp6jcr9p3cygyvl9gglspnc8jtefzl65pt7qcfeqweeheuxdrq0j2p7aj2lmxwu7u87ykegunlt49x67v3r07agl54mqnx384n	\\x00752c0ca18e088233e5423f00cf0792f2917f540afc0c272076737cf0cd181f2507dd92bfb33b9ee1fc4b651c9fd7529b5e6446ff751fa576	f	\\x752c0ca18e088233e5423f00cf0792f2917f540afc0c272076737cf0	44	499999454217	\N	\N	\N
139	118	0	addr_test1qp6jcr9p3cygyvl9gglspnc8jtefzl65pt7qcfeqweeheuxdrq0j2p7aj2lmxwu7u87ykegunlt49x67v3r07agl54mqnx384n	\\x00752c0ca18e088233e5423f00cf0792f2917f540afc0c272076737cf0cd181f2507dd92bfb33b9ee1fc4b651c9fd7529b5e6446ff751fa576	f	\\x752c0ca18e088233e5423f00cf0792f2917f540afc0c272076737cf0	44	499999273756	\N	\N	\N
140	119	0	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3681313275151535	\N	\N	\N
141	120	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	10000000	\N	\N	\N
142	120	1	addr_test1vq3d0r88ks3qellmuy93l444m9xjy4hc5zk5xzy4s24dscs95srvn	\\x6022d78ce7b4220cfffbe10b1fd6b5d94d2256f8a0ad43089582aad862	f	\\x22d78ce7b4220cfffbe10b1fd6b5d94d2256f8a0ad43089582aad862	\N	3681318171475475	\N	\N	\N
143	121	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000000000	\N	\N	\N
144	121	1	addr_test1qrml5hwl9s7ydm2djyup95ud6s74skkl4zzf8zk657s8thgm78sn3uhch64ujc7ffnpga68dfdqhg3sp7tk6759jrm7spy03k9	\\x00f7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd1bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	f	\\xf7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd	69	5000000000000	\N	\N	\N
145	121	2	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	5000000000000	\N	\N	\N
146	121	3	addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k	\\x00594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	f	\\x594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0	71	5000000000000	\N	\N	\N
147	121	4	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	5000000000000	\N	\N	\N
148	121	5	addr_test1vqc9htgtygrm0k8csxruuetucnkpzqxgg4pxqjvsmcl9pssss3hhk	\\x60305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	f	\\x305bad0b2207b7d8f88187ce657cc4ec1100c84542604990de3e50c2	\N	3656313274972438	\N	\N	\N
149	122	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	10000000	\N	\N	\N
150	122	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999989767751	\N	\N	\N
151	123	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	10000000	\\x81cb2989cbf6c49840511d8d3451ee44f58dde2c074fc749d05deb51eeb33741	1	\N
152	123	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999979583022	\N	\N	\N
153	124	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999987749813	\N	\N	\N
154	124	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999991664628	\N	\N	\N
155	125	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999987749813	\N	\N	\N
156	125	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999991494463	\N	\N	\N
157	126	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	969750	\N	\N	\N
158	126	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2999986609810	\N	\N	\N
159	127	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
160	127	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1999987294224	\N	\N	\N
161	128	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999974404034	\N	\N	\N
162	128	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4328427	\N	\N	\N
163	129	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
164	129	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4999969235629	\N	\N	\N
165	131	0	addr_test1qpndhtul8dc5c4ptgdvezayyatygee4x0unyta69jxjd46aw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqwfuztq	\\x0066dbaf9f3b714c542b4359917484eac88ce6a67f2645f74591a4daebae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x66dbaf9f3b714c542b4359917484eac88ce6a67f2645f74591a4daeb	72	3000000	\N	\N	\N
166	131	1	addr_test1qr9l08my2ev9rfz0gkl84pkej4vcqnhed37tkp9v5nhs9mdw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqdj0xpk	\\x00cbf79f64565851a44f45be7a86d99559804ef96c7cbb04aca4ef02edae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xcbf79f64565851a44f45be7a86d99559804ef96c7cbb04aca4ef02ed	72	3000000	\N	\N	\N
167	131	2	addr_test1qzmepmftr5mehfcqzsszqmuh2e6vj9dct8mgk35vuslnak9w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqa3322d	\\x00b790ed2b1d379ba7001420206f975674c915b859f68b468ce43f3ed8ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xb790ed2b1d379ba7001420206f975674c915b859f68b468ce43f3ed8	72	3000000	\N	\N	\N
168	131	3	addr_test1qqgel4d77dhk7yz3qm05ul65cx3vrmypzu2wtl5ac0yfvpaw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqjf708a	\\x00119fd5bef36f6f105106df4e7f54c1a2c1ec811714e5fe9dc3c89607ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x119fd5bef36f6f105106df4e7f54c1a2c1ec811714e5fe9dc3c89607	72	3000000	\N	\N	\N
169	131	4	addr_test1qrt29ppn7m07n27r86h8kja8vaqum9a8ug7mk5d0aan94ndw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq2aw7gg	\\x00d6a28433f6dfe9abc33eae7b4ba76741cd97a7e23dbb51afef665acdae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xd6a28433f6dfe9abc33eae7b4ba76741cd97a7e23dbb51afef665acd	72	3000000	\N	\N	\N
170	131	5	addr_test1qp2s9p6fpdzu46cf6urak3dkd3yfrtqjlm0qwxahdqf8js4w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqrzwyc8	\\x00550287490b45caeb09d707db45b66c4891ac12fede071bb768127942ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x550287490b45caeb09d707db45b66c4891ac12fede071bb768127942	72	3000000	\N	\N	\N
171	131	6	addr_test1qp6unpk4n7rlpsye93p7x386lsxq5vr3zt42jtrwtt4569dw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqlv3x2d	\\x0075c986d59f87f0c0992c43e344fafc0c0a307112eaa92c6e5aeb4d15ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x75c986d59f87f0c0992c43e344fafc0c0a307112eaa92c6e5aeb4d15	72	3000000	\N	\N	\N
172	131	7	addr_test1qrlrgwara9z2h632yefkqenkt2wh3fm5qsggc4jppa7vmz9w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqdjher3	\\x00fe343ba3e944abea2a26536066765a9d78a77404108c56410f7ccd88ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xfe343ba3e944abea2a26536066765a9d78a77404108c56410f7ccd88	72	3000000	\N	\N	\N
173	131	8	addr_test1qrtpgscrgyzz3utl5w8xsadrryufnd8p9p2f0val09fh4vdw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsql2md49	\\x00d6144303410428f17fa38e6875a3193899b4e1285497b3bf79537ab1ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xd6144303410428f17fa38e6875a3193899b4e1285497b3bf79537ab1	72	3000000	\N	\N	\N
174	131	9	addr_test1qrm6xkytqyc53egml4ck30xt5v6epj9yymu9ssf9x7gh5maw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqu8tzzc	\\x00f7a3588b013148e51bfd7168bccba33590c8a426f858412537917a6fae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xf7a3588b013148e51bfd7168bccba33590c8a426f858412537917a6f	72	3000000	\N	\N	\N
175	131	10	addr_test1qpnz9vjj9uhhmv4fzxpjehzk5xxzcnsj47qqyxg78ms7k64w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqt82jha	\\x006622b2522f2f7db2a911832cdc56a18c2c4e12af8002191e3ee1eb6aae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x6622b2522f2f7db2a911832cdc56a18c2c4e12af8002191e3ee1eb6a	72	3000000	\N	\N	\N
176	131	11	addr_test1qzzjrmp06pc3w4ca783xrl3efmg945xd8lu49d4hqy8leh9w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq0sn9ad	\\x008521ec2fd07117571df1e261fe394ed05ad0cd3ff952b6b7010ffcdcae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x8521ec2fd07117571df1e261fe394ed05ad0cd3ff952b6b7010ffcdc	72	3000000	\N	\N	\N
177	131	12	addr_test1qz05fl2ck5p4pr0gy0tx2hhnnxxslau6tq2q2d900re443dw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqfh76v7	\\x009f44fd58b503508de823d6655ef3998d0ff79a58140534af78f35ac5ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x9f44fd58b503508de823d6655ef3998d0ff79a58140534af78f35ac5	72	3000000	\N	\N	\N
178	131	13	addr_test1qrhakxgtcgd9ced0evdu7l8gkvxr3jek59jz49d9gtecx8aw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq67zw9f	\\x00efdb190bc21a5c65afcb1bcf7ce8b30c38cb36a1642a95a542f3831fae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xefdb190bc21a5c65afcb1bcf7ce8b30c38cb36a1642a95a542f3831f	72	3000000	\N	\N	\N
179	131	14	addr_test1qz435ec0vw0kt46euyzpfke6l5te6ve0x9ctvvjl5kdkuzaw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq0wapmm	\\x00ab1a670f639f65d759e10414db3afd179d332f3170b6325fa59b6e0bae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xab1a670f639f65d759e10414db3afd179d332f3170b6325fa59b6e0b	72	3000000	\N	\N	\N
180	131	15	addr_test1qzaucvuvk5xzqhe28vg0hz2muud6c6phfl6f0v4yd95c484w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq8zg0jc	\\x00bbcc338cb50c205f2a3b10fb895be71bac68374ff497b2a469698a9eae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xbbcc338cb50c205f2a3b10fb895be71bac68374ff497b2a469698a9e	72	3000000	\N	\N	\N
181	131	16	addr_test1qqyht47cetyne834jqxcz5kn0u832pgg2fqea0ppy9pv0caw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq3uw83e	\\x000975d7d8cac93c9e35900d8152d37f0f15050852419ebc212142c7e3ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x0975d7d8cac93c9e35900d8152d37f0f15050852419ebc212142c7e3	72	3000000	\N	\N	\N
182	131	17	addr_test1qqjq2et5a87xxhwn2sflucjnfmggmp68cgwjtlf5sr45844w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqrpdxsl	\\x0024056574e9fc635dd35413fe62534ed08d8747c21d25fd3480eb43d6ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x24056574e9fc635dd35413fe62534ed08d8747c21d25fd3480eb43d6	72	3000000	\N	\N	\N
183	131	18	addr_test1qpvw8qly5qn875ntm74v5yplgn2yg7y65zkescnh4ylgl8aw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq9e0s5j	\\x0058e383e4a0267f526bdfaaca103f44d444789aa0ad986277a93e8f9fae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x58e383e4a0267f526bdfaaca103f44d444789aa0ad986277a93e8f9f	72	3000000	\N	\N	\N
184	131	19	addr_test1qzpcc5fazu9pq9tzxj58f2zmyvlle8hfhx7tk83gm0tymn9w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqjpm382	\\x00838c513d170a10156234a874a85b233ffc9ee9b9bcbb1e28dbd64dccae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x838c513d170a10156234a874a85b233ffc9ee9b9bcbb1e28dbd64dcc	72	3000000	\N	\N	\N
185	131	20	addr_test1qpf99tpnsuhnfxd4rkudw0r8xfk0y3y5he5vskmu3magv2dw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqyvkgck	\\x005252ac33872f3499b51db8d73c67326cf24494be68c85b7c8efa8629ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x5252ac33872f3499b51db8d73c67326cf24494be68c85b7c8efa8629	72	3000000	\N	\N	\N
186	131	21	addr_test1qzapz5m3w6kzejnxnjmdj6jq0c39dw9ddnyq06gkzfut299w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqntkprz	\\x00ba11537176ac2cca669cb6d96a407e2256b8ad6cc807e9161278b514ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xba11537176ac2cca669cb6d96a407e2256b8ad6cc807e9161278b514	72	3000000	\N	\N	\N
187	131	22	addr_test1qq6uhy3drq4vn5neevxd40n3rz7nyfvyf349hv35r8hxyd9w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqsuy2lu	\\x0035cb922d182ac9d279cb0cdabe7118bd3225844c6a5bb23419ee6234ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x35cb922d182ac9d279cb0cdabe7118bd3225844c6a5bb23419ee6234	72	3000000	\N	\N	\N
188	131	23	addr_test1qpfputkjnufsveftfjl5zsle52hmh7w5nmaljhdh29hxg09w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqcndmnf	\\x00521e2ed29f1306652b4cbf4143f9a2afbbf9d49efbf95db7516e643cae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x521e2ed29f1306652b4cbf4143f9a2afbbf9d49efbf95db7516e643c	72	3000000	\N	\N	\N
189	131	24	addr_test1qp50uqwynadu788nykc40d0mq2kzxuw7842wua4ee3640x4w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq0hpvry	\\x0068fe01c49f5bcf1cf325b157b5fb02ac2371de3d54ee76b9cc75579aae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x68fe01c49f5bcf1cf325b157b5fb02ac2371de3d54ee76b9cc75579a	72	3000000	\N	\N	\N
190	131	25	addr_test1qqflrrhdm8vfn2gucv7hr022q7a45fmruc0g5909xl6n3ldw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqvf2e5c	\\x0013f18eedd9d899a91cc33d71bd4a07bb5a2763e61e8a15e537f538fdae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x13f18eedd9d899a91cc33d71bd4a07bb5a2763e61e8a15e537f538fd	72	3000000	\N	\N	\N
191	131	26	addr_test1qrukg37h9py7p285f9exhu869wyf4t6n58d2h5wza6xelc9w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqqmw5aj	\\x00f96447d72849e0a8f449726bf0fa2b889aaf53a1daabd1c2ee8d9fe0ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xf96447d72849e0a8f449726bf0fa2b889aaf53a1daabd1c2ee8d9fe0	72	3000000	\N	\N	\N
192	131	27	addr_test1qpnlkfd7q9nkrd2yrtzccragn8u4kc5k63reh6mxu0p0dtaw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqwq50qu	\\x0067fb25be016761b5441ac58c0fa899f95b6296d4479beb66e3c2f6afae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x67fb25be016761b5441ac58c0fa899f95b6296d4479beb66e3c2f6af	72	3000000	\N	\N	\N
193	131	28	addr_test1qrdz0x68e9hfsemuwn3sd7u6nvn9u2rwzxepklvdwm4g599w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq2krn8c	\\x00da279b47c96e98677c74e306fb9a9b265e286e11b21b7d8d76ea8a14ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xda279b47c96e98677c74e306fb9a9b265e286e11b21b7d8d76ea8a14	72	3000000	\N	\N	\N
194	131	29	addr_test1qpeq7vamgjs4v93nea8zcv0jt0xrwrmeqq9gj3hnepfnpg4w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqdvgldc	\\x00720f33bb44a1561633cf4e2c31f25bcc370f79000a8946f3c85330a2ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x720f33bb44a1561633cf4e2c31f25bcc370f79000a8946f3c85330a2	72	3000000	\N	\N	\N
195	131	30	addr_test1qzyel2uv9m2080xe79pwhucznw7lagdrqqy05jr8axwfdgdw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsquf5eeu	\\x00899fab8c2ed4f3bcd9f142ebf3029bbdfea1a30008fa4867e99c96a1ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x899fab8c2ed4f3bcd9f142ebf3029bbdfea1a30008fa4867e99c96a1	72	3000000	\N	\N	\N
196	131	31	addr_test1qz8e95vegpvs3y3gnx0ecajkze5skuum7ur0dv3lsf4e7d4w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq005y9f	\\x008f92d1994059089228999f9c765616690b739bf706f6b23f826b9f36ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x8f92d1994059089228999f9c765616690b739bf706f6b23f826b9f36	72	3000000	\N	\N	\N
197	131	32	addr_test1qzkqjnu2ng98zrnlpdmrkp7e8myew492vn4cese06kylyf4w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq994y25	\\x00ac094f8a9a0a710e7f0b763b07d93ec99754aa64eb8cc32fd589f226ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xac094f8a9a0a710e7f0b763b07d93ec99754aa64eb8cc32fd589f226	72	3000000	\N	\N	\N
198	131	33	addr_test1qr2u8v25mtmdjp2ml9d2rqy2j5507uv6vv2j2na7wuzv524w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq70jry7	\\x00d5c3b154daf6d9055bf95aa1808a9528ff719a6315254fbe7704ca2aae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xd5c3b154daf6d9055bf95aa1808a9528ff719a6315254fbe7704ca2a	72	3000000	\N	\N	\N
199	131	34	addr_test1qq787e2xel9culmf6xyl4lmx4p2677dm46gyzz2fcscjs99w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq68lyqw	\\x003c7f6546cfcb8e7f69d189faff66a855af79bbae90410949c4312814ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x3c7f6546cfcb8e7f69d189faff66a855af79bbae90410949c4312814	72	3000000	\N	\N	\N
200	131	35	addr_test1qq9d2kexw3v9qykq2rvurf578lw423fehkq4ag6p4hafts4w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqz783f3	\\x000ad55b2674585012c050d9c1a69e3fdd554539bd815ea341adfa95c2ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x0ad55b2674585012c050d9c1a69e3fdd554539bd815ea341adfa95c2	72	3000000	\N	\N	\N
201	131	36	addr_test1qqwyjlf0tl920vepydhv3ht5v06wfjhy6ww0nxz4rucq6wdw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqxapqtx	\\x001c497d2f5fcaa7b321236ec8dd7463f4e4cae4d39cf998551f300d39ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x1c497d2f5fcaa7b321236ec8dd7463f4e4cae4d39cf998551f300d39	72	3000000	\N	\N	\N
202	131	37	addr_test1qq9fj0gnz52s6k0h0y4xdkeyc26r6uj5fgc2jng9tc2uh2dw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqk5wqce	\\x000a993d1315150d59f7792a66db24c2b43d72544a30a94d055e15cba9ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x0a993d1315150d59f7792a66db24c2b43d72544a30a94d055e15cba9	72	3000000	\N	\N	\N
203	131	38	addr_test1qzgu27zzjpfhdfg5nfaqt4jxhpfv50v8zquj4sd6qpmmy5dw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqm2q79e	\\x0091c57842905376a5149a7a05d646b852ca3d8710392ac1ba0077b251ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x91c57842905376a5149a7a05d646b852ca3d8710392ac1ba0077b251	72	3000000	\N	\N	\N
204	131	39	addr_test1qz3yhx5474zrew7pqp6epz02ccwke42yanzy6ynftw6swmaw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqarhvwj	\\x00a24b9a95f5443cbbc100759089eac61d6cd544ecc44d12695bb5076fae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xa24b9a95f5443cbbc100759089eac61d6cd544ecc44d12695bb5076f	72	3000000	\N	\N	\N
205	131	40	addr_test1qz9t0cnhrkxffklpr2gkzgak5cfzence7gqdxamrxudw4k4w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqdtc08q	\\x008ab7e2771d8c94dbe11a916123b6a6122ccf19f200d37763371aeadaae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x8ab7e2771d8c94dbe11a916123b6a6122ccf19f200d37763371aeada	72	3000000	\N	\N	\N
206	131	41	addr_test1qpns28dww74r93zfeta3fggwg70uy86uzt04ua0cprd4984w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqe0tady	\\x0067051dae77aa32c449cafb14a10e479fc21f5c12df5e75f808db529eae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x67051dae77aa32c449cafb14a10e479fc21f5c12df5e75f808db529e	72	3000000	\N	\N	\N
207	131	42	addr_test1qpxzj4lwrek8cfm6mdjfa2uud7jkcrypy7vgq8peamhq074w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqzts3kz	\\x004c2957ee1e6c7c277adb649eab9c6fa56c0c812798801c39eeee07faae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x4c2957ee1e6c7c277adb649eab9c6fa56c0c812798801c39eeee07fa	72	3000000	\N	\N	\N
208	131	43	addr_test1qrnkq724lcd0um7nxnmxkrlv7pm3gkqvwzxw3d4dpfgvud4w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqwqsuc0	\\x00e7607955fe1afe6fd334f66b0fecf07714580c708ce8b6ad0a50ce36ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xe7607955fe1afe6fd334f66b0fecf07714580c708ce8b6ad0a50ce36	72	3000000	\N	\N	\N
209	131	44	addr_test1qrtj2cya2xpj06asq6qmktwf3r6n4pw5gv2464nn4l4pgedw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqvtyvd5	\\x00d725609d518327ebb00681bb2dc988f53a85d443155d5673afea1465ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xd725609d518327ebb00681bb2dc988f53a85d443155d5673afea1465	72	3000000	\N	\N	\N
210	131	45	addr_test1qqyanc08k3x5alcf702p23dgvlm5gc8pdxzm5gvfyvzk3g4w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq8sx6sp	\\x0009d9e1e7b44d4eff09f3d41545a867f74460e16985ba2189230568a2ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x09d9e1e7b44d4eff09f3d41545a867f74460e16985ba2189230568a2	72	3000000	\N	\N	\N
211	131	46	addr_test1qzz0et3zda978uq75y97dce6kcareelw0h9smxvxx7s9nhdw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqu4wdw4	\\x0084fcae226f4be3f01ea10be6e33ab63a3ce7ee7dcb0d998637a059ddae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x84fcae226f4be3f01ea10be6e33ab63a3ce7ee7dcb0d998637a059dd	72	3000000	\N	\N	\N
212	131	47	addr_test1qpkkzt82dgy48j9lwwvl30fjjdgs3zxch3rkdrlt8dmvxj9w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqypftws	\\x006d612cea6a0953c8bf7399f8bd3293510888d8bc47668feb3b76c348ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x6d612cea6a0953c8bf7399f8bd3293510888d8bc47668feb3b76c348	72	3000000	\N	\N	\N
213	131	48	addr_test1qzhwr7apu5a7u46qtlvt9mx24am5txh7lra2s593eswggkdw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq87tksm	\\x00aee1fba1e53bee57405fd8b2eccaaf77459afef8faa850b1cc1c8459ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xaee1fba1e53bee57405fd8b2eccaaf77459afef8faa850b1cc1c8459	72	3000000	\N	\N	\N
214	131	49	addr_test1qzyks3wkhkg66ztasuzm5dpw40trssz84ernssy3lk8xva9w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqpqza8y	\\x00896845d6bd91ad097d8705ba342eabd6384047ae47384091fd8e6674ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x896845d6bd91ad097d8705ba342eabd6384047ae47384091fd8e6674	72	3000000	\N	\N	\N
215	131	50	addr_test1qr6hnrqtmn9whgpad0kutz8hvsftxnayz5enldjl4hqqr5dw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqde2ey3	\\x00f5798c0bdccaeba03d6bedc588f76412b34fa415333fb65fadc001d1ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xf5798c0bdccaeba03d6bedc588f76412b34fa415333fb65fadc001d1	72	3000000	\N	\N	\N
216	131	51	addr_test1qqvthhkc332svd688rjvarzj3p5wrlg9teg7lnrzv0hzjadw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqrgtt98	\\x0018bbded88c5506374738e4ce8c528868e1fd055e51efcc6263ee2975ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x18bbded88c5506374738e4ce8c528868e1fd055e51efcc6263ee2975	72	3000000	\N	\N	\N
217	131	52	addr_test1qryyg5rj3wmem6yazvchaz2h5dgmnddddc402q4plapam8aw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqjyn7ta	\\x00c84450728bb79de89d13317e8957a351b9b5ad6e2af502a1ff43dd9fae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xc84450728bb79de89d13317e8957a351b9b5ad6e2af502a1ff43dd9f	72	3000000	\N	\N	\N
218	131	53	addr_test1qpum9jgsdhh09568j9qfj56w82mfkrn9u2v7zxznzte040aw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqrtgvh4	\\x0079b2c9106deef2d347914099534e3ab69b0e65e299e1185312f2fabfae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x79b2c9106deef2d347914099534e3ab69b0e65e299e1185312f2fabf	72	3000000	\N	\N	\N
219	131	54	addr_test1qpfjftxuvax8w9sjw68nn76ns8afhgrezs3let2pt0hxxqdw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqkdpztn	\\x005324acdc674c771612768f39fb5381fa9ba0791423fcad415bee6301ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x5324acdc674c771612768f39fb5381fa9ba0791423fcad415bee6301	72	3000000	\N	\N	\N
220	131	55	addr_test1qzuzyut9ds60d75juckqyvqyld6d9c504ahuq9q4n72h9f4w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq32qmfv	\\x00b82271656c34f6fa92e62c023004fb74d2e28faf6fc014159f9572a6ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xb82271656c34f6fa92e62c023004fb74d2e28faf6fc014159f9572a6	72	3000000	\N	\N	\N
221	131	56	addr_test1qrxdq0y6uujvuets8ulcjdzaz3jkr5hjqfcua6s7c3ux8h9w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqdna63z	\\x00ccd03c9ae724ce65703f3f89345d146561d2f20271ceea1ec47863dcae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xccd03c9ae724ce65703f3f89345d146561d2f20271ceea1ec47863dc	72	3000000	\N	\N	\N
222	131	57	addr_test1qphse5hlypep54xx37avhhnvagvxk26jeacn6c09sgpwtn4w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq3qswah	\\x006f0cd2ff20721a54c68fbacbde6cea186b2b52cf713d61e58202e5ceae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x6f0cd2ff20721a54c68fbacbde6cea186b2b52cf713d61e58202e5ce	72	3000000	\N	\N	\N
223	131	58	addr_test1qr28pfy9t94m9fgd0qr8p03ng0puqr4rh3q5enca49nxyn4w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsq8sraea	\\x00d470a485596bb2a50d780670be3343c3c00ea3bc414ccf1da966624eae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xd470a485596bb2a50d780670be3343c3c00ea3bc414ccf1da966624e	72	3000000	\N	\N	\N
224	131	59	addr_test1qz55v0r86ed7nln7kfsawytd63upkeg5jywf6pg3ktz4zj9w0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqwed6cg	\\x00a9463c67d65be9fe7eb261d7116dd4781b6514911c9d0511b2c55148ae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\xa9463c67d65be9fe7eb261d7116dd4781b6514911c9d0511b2c55148	72	3000000	\N	\N	\N
225	131	60	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	97391874384	\N	\N	\N
226	131	61	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
227	131	62	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
228	131	63	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
229	131	64	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
230	131	65	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
231	131	66	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
232	131	67	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
233	131	68	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
234	131	69	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
235	131	70	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
236	131	71	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
237	131	72	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
238	131	73	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
239	131	74	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
240	131	75	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
241	131	76	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
242	131	77	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
243	131	78	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
244	131	79	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
245	131	80	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
246	131	81	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
247	131	82	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
248	131	83	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
249	131	84	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
250	131	85	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
251	131	86	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
252	131	87	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
253	131	88	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
254	131	89	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
255	131	90	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
256	131	91	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
257	131	92	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
258	131	93	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
259	131	94	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
260	131	95	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
261	131	96	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
262	131	97	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
263	131	98	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
264	131	99	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
265	131	100	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
266	131	101	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
267	131	102	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
268	131	103	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
269	131	104	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
270	131	105	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
271	131	106	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
272	131	107	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
273	131	108	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
274	131	109	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
275	131	110	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
276	131	111	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
277	131	112	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
278	131	113	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
279	131	114	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
280	131	115	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
281	131	116	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
282	131	117	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
283	131	118	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
284	131	119	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091471948	\N	\N	\N
285	132	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	178500000	\N	\N	\N
286	132	1	addr_test1qpndhtul8dc5c4ptgdvezayyatygee4x0unyta69jxjd46aw0pj76p50de64j29mm704ywjmhua884dqy97mv299yfsqwfuztq	\\x0066dbaf9f3b714c542b4359917484eac88ce6a67f2645f74591a4daebae7865ed068f6e755928bbdf9f523a5bbf3a73d5a0217db628a52260	f	\\x66dbaf9f3b714c542b4359917484eac88ce6a67f2645f74591a4daeb	72	974447	\N	\N	\N
287	133	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	73	1000000	\N	\N	\N
288	133	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83090289551	\N	\N	\N
289	134	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4157030	\N	\N	\N
290	135	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\N	\N	\N
291	135	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081303499	\N	\N	\N
292	136	0	5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg	\\x82d818582683581c599d72b5e3f5a40fb4c4eb809e904d101f908a419472f542bc7032b9a10243190378001a2a94baa3	f	\N	\N	3000000	\N	\N	\N
293	136	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83088303895	\N	\N	\N
294	137	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	97391693967	\N	\N	\N
295	138	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
296	138	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
297	139	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
298	139	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83083135490	\N	\N	\N
299	140	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
300	140	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
301	141	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
302	141	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
303	142	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
304	142	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
305	143	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
306	143	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
307	144	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
308	144	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
309	145	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
310	145	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
311	146	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
312	146	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
313	147	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
314	147	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
315	148	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
316	148	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
317	149	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
318	149	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
319	150	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
320	150	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
321	151	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
322	151	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091301915	\N	\N	\N
323	152	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
324	152	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086133510	\N	\N	\N
325	153	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
326	153	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086133510	\N	\N	\N
327	154	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
328	154	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081133510	\N	\N	\N
329	155	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
330	155	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
331	156	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
332	156	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
333	157	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
334	157	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
335	158	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
336	158	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
337	159	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
338	159	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
339	160	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
340	160	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
341	161	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
342	161	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
343	162	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
344	162	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
345	163	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
346	163	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
347	164	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
348	164	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
349	165	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
350	165	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
351	166	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
352	166	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
353	167	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
354	167	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83085121146	\N	\N	\N
355	168	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
356	168	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
357	169	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
358	169	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83075966689	\N	\N	\N
359	170	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
360	170	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
361	171	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
362	171	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83075965105	\N	\N	\N
363	172	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
364	172	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	9830187	\N	\N	\N
365	173	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
366	173	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
367	174	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
368	174	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
369	175	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
370	175	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
371	176	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
372	176	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
373	177	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
374	177	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
375	178	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
376	178	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
377	179	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
378	179	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
379	180	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
380	180	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
381	181	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
382	181	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
383	182	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
384	182	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
385	183	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
386	183	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
387	184	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
388	184	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
389	185	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
390	185	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83091301915	\N	\N	\N
391	186	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
392	186	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
393	187	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
394	187	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	97386525562	\N	\N	\N
395	188	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
396	188	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
397	189	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
398	189	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
399	190	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
400	190	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	9660374	\N	\N	\N
401	191	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
402	191	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
403	192	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
404	192	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
405	193	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
406	193	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83082965501	\N	\N	\N
407	194	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
408	194	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
409	195	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
410	195	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83080965105	\N	\N	\N
411	196	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
412	196	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
413	197	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
414	197	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
415	198	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
416	198	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83080965105	\N	\N	\N
417	199	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
418	199	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
419	200	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
420	200	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
421	201	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
422	201	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
423	202	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
424	202	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83075966689	\N	\N	\N
425	203	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
426	203	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
427	204	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
428	204	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
429	205	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
430	205	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
431	206	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
432	206	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
433	207	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
434	207	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83075966689	\N	\N	\N
435	208	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
436	208	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
437	209	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
438	209	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
439	210	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
440	210	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
441	211	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
442	211	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
443	212	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
444	212	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
445	213	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
446	213	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83075796700	\N	\N	\N
447	214	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
448	214	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
449	215	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
450	215	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
451	216	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
452	216	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4660374	\N	\N	\N
453	217	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
454	217	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83082455886	\N	\N	\N
455	218	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
456	218	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83075966689	\N	\N	\N
457	219	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
458	219	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83075966689	\N	\N	\N
459	220	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
460	220	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83075966689	\N	\N	\N
461	221	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
462	221	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83070798284	\N	\N	\N
463	222	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
464	222	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
465	223	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
466	223	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
467	224	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
468	224	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83080965105	\N	\N	\N
469	225	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
470	225	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
471	226	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
472	226	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83070798284	\N	\N	\N
473	227	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
474	227	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83081135094	\N	\N	\N
475	228	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
476	228	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086133510	\N	\N	\N
477	229	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
478	229	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
479	230	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
480	230	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
481	231	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
482	231	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83065629879	\N	\N	\N
483	232	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
484	232	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
485	233	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
486	233	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086303499	\N	\N	\N
487	234	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
488	234	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
489	235	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
490	235	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
491	236	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
492	236	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	83086133510	\N	\N	\N
493	237	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
494	237	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	4830187	\N	\N	\N
495	238	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
496	238	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	90142862271	\N	\N	\N
511	240	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1251751109921	\N	\N	\N
512	240	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	76	1251751545625	\N	\N	\N
513	240	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	625875772813	\N	\N	\N
514	240	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	76	625875772813	\N	\N	\N
515	240	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	312937886406	\N	\N	\N
516	240	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	76	312937886406	\N	\N	\N
517	240	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156468943203	\N	\N	\N
518	240	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	76	156468943203	\N	\N	\N
519	240	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78234471602	\N	\N	\N
520	240	9	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	76	78234471602	\N	\N	\N
521	240	10	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39117235801	\N	\N	\N
522	240	11	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	76	39117235801	\N	\N	\N
523	240	12	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39117235800	\N	\N	\N
524	240	13	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	76	39117235800	\N	\N	\N
525	241	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
526	241	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507158211971	\N	\N	\N
527	241	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253579214168	\N	\N	\N
528	241	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789607084	\N	\N	\N
529	241	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394803542	\N	\N	\N
530	241	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697401771	\N	\N	\N
531	241	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348700886	\N	\N	\N
532	241	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174350443	\N	\N	\N
533	241	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174350442	\N	\N	\N
534	242	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
535	242	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507158118001	\N	\N	\N
536	242	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253579160077	\N	\N	\N
537	242	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789580038	\N	\N	\N
538	242	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394790019	\N	\N	\N
539	242	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697395010	\N	\N	\N
540	242	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348697505	\N	\N	\N
541	242	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174348752	\N	\N	\N
542	242	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174348752	\N	\N	\N
543	243	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
544	243	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507158016924	\N	\N	\N
545	243	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253579109539	\N	\N	\N
546	243	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789554769	\N	\N	\N
547	243	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394777385	\N	\N	\N
548	243	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697388692	\N	\N	\N
549	243	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348694346	\N	\N	\N
550	243	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174347173	\N	\N	\N
551	243	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174347173	\N	\N	\N
552	244	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
553	244	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507157915848	\N	\N	\N
554	244	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253579059000	\N	\N	\N
555	244	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789529500	\N	\N	\N
556	244	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394764750	\N	\N	\N
557	244	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697382375	\N	\N	\N
558	244	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348691188	\N	\N	\N
559	244	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174345594	\N	\N	\N
560	244	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174345593	\N	\N	\N
561	245	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
562	245	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507157814771	\N	\N	\N
563	245	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253579008462	\N	\N	\N
564	245	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789504231	\N	\N	\N
565	245	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394752116	\N	\N	\N
566	245	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697376058	\N	\N	\N
567	245	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348688029	\N	\N	\N
568	245	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174344014	\N	\N	\N
569	245	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174344014	\N	\N	\N
570	246	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
571	246	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507157713695	\N	\N	\N
572	246	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578957924	\N	\N	\N
573	246	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789478962	\N	\N	\N
574	246	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394739481	\N	\N	\N
575	246	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697369740	\N	\N	\N
576	246	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348684870	\N	\N	\N
577	246	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174342435	\N	\N	\N
578	246	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174342435	\N	\N	\N
579	247	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
580	247	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507157612618	\N	\N	\N
581	247	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578907386	\N	\N	\N
582	247	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789453693	\N	\N	\N
583	247	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394726846	\N	\N	\N
584	247	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697363423	\N	\N	\N
585	247	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348681712	\N	\N	\N
586	247	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174340856	\N	\N	\N
587	247	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174340855	\N	\N	\N
588	248	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
589	248	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507157511542	\N	\N	\N
590	248	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578856847	\N	\N	\N
591	248	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789428424	\N	\N	\N
592	248	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394714212	\N	\N	\N
593	248	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697357106	\N	\N	\N
594	248	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348678553	\N	\N	\N
595	248	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174339276	\N	\N	\N
596	248	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174339276	\N	\N	\N
597	249	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
598	249	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507157410465	\N	\N	\N
599	249	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578806309	\N	\N	\N
600	249	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789403155	\N	\N	\N
601	249	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394701577	\N	\N	\N
602	249	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697350789	\N	\N	\N
603	249	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348675394	\N	\N	\N
604	249	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174337697	\N	\N	\N
605	249	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174337697	\N	\N	\N
606	250	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
607	250	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507157309389	\N	\N	\N
608	250	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578755771	\N	\N	\N
609	250	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789377885	\N	\N	\N
610	250	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394688943	\N	\N	\N
611	250	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697344471	\N	\N	\N
612	250	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348672236	\N	\N	\N
613	250	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174336118	\N	\N	\N
614	250	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174336117	\N	\N	\N
615	251	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
616	251	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507157208312	\N	\N	\N
617	251	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578705233	\N	\N	\N
618	251	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789352616	\N	\N	\N
619	251	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394676308	\N	\N	\N
620	251	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697338154	\N	\N	\N
621	251	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348669077	\N	\N	\N
622	251	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174334539	\N	\N	\N
623	251	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174334538	\N	\N	\N
624	252	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
625	252	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507157107236	\N	\N	\N
626	252	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578654694	\N	\N	\N
627	252	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789327347	\N	\N	\N
628	252	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394663674	\N	\N	\N
629	252	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697331837	\N	\N	\N
630	252	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348665918	\N	\N	\N
631	252	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174332959	\N	\N	\N
632	252	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174332959	\N	\N	\N
633	253	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
634	253	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507157006159	\N	\N	\N
635	253	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578604156	\N	\N	\N
636	253	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789302078	\N	\N	\N
637	253	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394651039	\N	\N	\N
638	253	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697325520	\N	\N	\N
639	253	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348662760	\N	\N	\N
640	253	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174331380	\N	\N	\N
641	253	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174331379	\N	\N	\N
642	254	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
643	254	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507156905083	\N	\N	\N
644	254	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578553618	\N	\N	\N
645	254	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789276809	\N	\N	\N
646	254	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394638404	\N	\N	\N
647	254	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697319202	\N	\N	\N
648	254	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348659601	\N	\N	\N
649	254	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174329801	\N	\N	\N
650	254	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174329800	\N	\N	\N
651	255	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
652	255	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507156804006	\N	\N	\N
653	255	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578503080	\N	\N	\N
654	255	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789251540	\N	\N	\N
655	255	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394625770	\N	\N	\N
656	255	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697312885	\N	\N	\N
657	255	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348656442	\N	\N	\N
658	255	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174328221	\N	\N	\N
659	255	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174328221	\N	\N	\N
660	256	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
661	256	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507156702930	\N	\N	\N
662	256	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578452541	\N	\N	\N
663	256	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789226271	\N	\N	\N
664	256	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394613135	\N	\N	\N
665	256	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697306568	\N	\N	\N
666	256	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348653284	\N	\N	\N
667	256	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174326642	\N	\N	\N
668	256	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174326641	\N	\N	\N
669	257	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
670	257	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507156601853	\N	\N	\N
671	257	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578402003	\N	\N	\N
672	257	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789201002	\N	\N	\N
673	257	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394600501	\N	\N	\N
674	257	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697300250	\N	\N	\N
675	257	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348650125	\N	\N	\N
676	257	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174325063	\N	\N	\N
677	257	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174325062	\N	\N	\N
678	258	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
679	258	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507156500777	\N	\N	\N
680	258	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578351465	\N	\N	\N
681	258	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789175732	\N	\N	\N
682	258	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394587866	\N	\N	\N
683	258	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697293933	\N	\N	\N
684	258	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348646967	\N	\N	\N
685	258	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174323483	\N	\N	\N
686	258	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174323483	\N	\N	\N
687	259	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
688	259	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507156399700	\N	\N	\N
689	259	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578300927	\N	\N	\N
690	259	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789150463	\N	\N	\N
691	259	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394575232	\N	\N	\N
692	259	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697287616	\N	\N	\N
693	259	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348643808	\N	\N	\N
694	259	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174321904	\N	\N	\N
695	259	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174321903	\N	\N	\N
696	260	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
697	260	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507156298624	\N	\N	\N
698	260	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578250388	\N	\N	\N
699	260	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789125194	\N	\N	\N
700	260	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394562597	\N	\N	\N
701	260	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697281299	\N	\N	\N
702	260	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348640649	\N	\N	\N
703	260	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174320325	\N	\N	\N
704	260	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174320324	\N	\N	\N
705	261	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
706	261	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507156197547	\N	\N	\N
707	261	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578199850	\N	\N	\N
708	261	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789099925	\N	\N	\N
709	261	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394549963	\N	\N	\N
710	261	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697274981	\N	\N	\N
711	261	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348637491	\N	\N	\N
712	261	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174318745	\N	\N	\N
713	261	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174318745	\N	\N	\N
714	262	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
715	262	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507156096471	\N	\N	\N
716	262	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578149312	\N	\N	\N
717	262	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789074656	\N	\N	\N
718	262	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394537328	\N	\N	\N
719	262	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697268664	\N	\N	\N
720	262	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348634332	\N	\N	\N
721	262	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174317166	\N	\N	\N
722	262	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174317165	\N	\N	\N
723	263	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
724	263	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507155995394	\N	\N	\N
725	263	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578098774	\N	\N	\N
726	263	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789049387	\N	\N	\N
727	263	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394524693	\N	\N	\N
728	263	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697262347	\N	\N	\N
729	263	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348631173	\N	\N	\N
730	263	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174315587	\N	\N	\N
731	263	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174315586	\N	\N	\N
732	264	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
733	264	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507155894318	\N	\N	\N
734	264	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253578048235	\N	\N	\N
735	264	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626789024118	\N	\N	\N
736	264	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394512059	\N	\N	\N
737	264	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697256029	\N	\N	\N
738	264	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348628015	\N	\N	\N
739	264	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174314007	\N	\N	\N
740	264	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174314007	\N	\N	\N
741	265	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
742	265	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507155793241	\N	\N	\N
743	265	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577997697	\N	\N	\N
744	265	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788998849	\N	\N	\N
745	265	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394499424	\N	\N	\N
746	265	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697249712	\N	\N	\N
747	265	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348624856	\N	\N	\N
748	265	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174312428	\N	\N	\N
749	265	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174312428	\N	\N	\N
750	266	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
751	266	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507155692165	\N	\N	\N
752	266	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577947159	\N	\N	\N
753	266	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788973579	\N	\N	\N
754	266	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394486790	\N	\N	\N
755	266	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697243395	\N	\N	\N
756	266	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348621697	\N	\N	\N
757	266	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174310849	\N	\N	\N
758	266	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174310848	\N	\N	\N
759	267	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
760	267	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507155591088	\N	\N	\N
761	267	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577896621	\N	\N	\N
762	267	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788948310	\N	\N	\N
763	267	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394474155	\N	\N	\N
764	267	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697237078	\N	\N	\N
765	267	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348618539	\N	\N	\N
766	267	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174309269	\N	\N	\N
767	267	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174309269	\N	\N	\N
768	268	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
769	268	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507155490012	\N	\N	\N
770	268	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577846082	\N	\N	\N
771	268	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788923041	\N	\N	\N
772	268	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394461521	\N	\N	\N
773	268	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697230760	\N	\N	\N
774	268	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348615380	\N	\N	\N
775	268	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174307690	\N	\N	\N
776	268	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174307690	\N	\N	\N
777	269	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
778	269	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507155388935	\N	\N	\N
779	269	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577795544	\N	\N	\N
780	269	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788897772	\N	\N	\N
781	269	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394448886	\N	\N	\N
782	269	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697224443	\N	\N	\N
783	269	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348612222	\N	\N	\N
784	269	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174306111	\N	\N	\N
785	269	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174306110	\N	\N	\N
786	270	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
787	270	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507155287859	\N	\N	\N
788	270	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577745006	\N	\N	\N
789	270	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788872503	\N	\N	\N
790	270	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394436251	\N	\N	\N
791	270	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697218126	\N	\N	\N
792	270	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348609063	\N	\N	\N
793	270	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174304531	\N	\N	\N
794	270	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174304531	\N	\N	\N
795	271	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
796	271	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507155186782	\N	\N	\N
797	271	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577694468	\N	\N	\N
798	271	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788847234	\N	\N	\N
799	271	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394423617	\N	\N	\N
800	271	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697211808	\N	\N	\N
801	271	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348605904	\N	\N	\N
802	271	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174302952	\N	\N	\N
803	271	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174302952	\N	\N	\N
804	272	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
805	272	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507155085706	\N	\N	\N
806	272	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577643929	\N	\N	\N
807	272	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788821965	\N	\N	\N
808	272	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394410982	\N	\N	\N
809	272	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697205491	\N	\N	\N
810	272	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348602746	\N	\N	\N
811	272	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174301373	\N	\N	\N
812	272	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174301372	\N	\N	\N
813	273	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
814	273	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507154984629	\N	\N	\N
815	273	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577593391	\N	\N	\N
816	273	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788796696	\N	\N	\N
817	273	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394398348	\N	\N	\N
818	273	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697199174	\N	\N	\N
819	273	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348599587	\N	\N	\N
820	273	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174299793	\N	\N	\N
821	273	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174299793	\N	\N	\N
822	274	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
823	274	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507154883553	\N	\N	\N
824	274	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577542853	\N	\N	\N
825	274	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788771426	\N	\N	\N
826	274	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394385713	\N	\N	\N
827	274	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697192857	\N	\N	\N
828	274	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348596428	\N	\N	\N
829	274	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174298214	\N	\N	\N
830	274	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174298214	\N	\N	\N
831	275	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
832	275	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507154782476	\N	\N	\N
833	275	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577492315	\N	\N	\N
834	275	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788746157	\N	\N	\N
835	275	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394373079	\N	\N	\N
836	275	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697186539	\N	\N	\N
837	275	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348593270	\N	\N	\N
838	275	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174296635	\N	\N	\N
839	275	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174296634	\N	\N	\N
840	276	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
841	276	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507154681400	\N	\N	\N
842	276	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577441776	\N	\N	\N
843	276	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788720888	\N	\N	\N
844	276	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394360444	\N	\N	\N
845	276	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697180222	\N	\N	\N
846	276	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348590111	\N	\N	\N
847	276	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174295056	\N	\N	\N
848	276	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174295055	\N	\N	\N
849	277	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
850	277	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507154580323	\N	\N	\N
851	277	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577391238	\N	\N	\N
852	277	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788695619	\N	\N	\N
853	277	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394347810	\N	\N	\N
854	277	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697173905	\N	\N	\N
855	277	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348586952	\N	\N	\N
856	277	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174293476	\N	\N	\N
857	277	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174293476	\N	\N	\N
858	278	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
859	278	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507154479247	\N	\N	\N
860	278	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577340700	\N	\N	\N
861	278	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788670350	\N	\N	\N
862	278	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394335175	\N	\N	\N
863	278	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697167587	\N	\N	\N
864	278	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348583794	\N	\N	\N
865	278	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174291897	\N	\N	\N
866	278	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174291896	\N	\N	\N
867	279	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
868	279	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507154378170	\N	\N	\N
869	279	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577290162	\N	\N	\N
870	279	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788645081	\N	\N	\N
871	279	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394322540	\N	\N	\N
872	279	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697161270	\N	\N	\N
873	279	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348580635	\N	\N	\N
874	279	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174290318	\N	\N	\N
875	279	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174290317	\N	\N	\N
876	280	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
877	280	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507154277094	\N	\N	\N
878	280	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577239623	\N	\N	\N
879	280	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788619812	\N	\N	\N
880	280	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394309906	\N	\N	\N
881	280	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697154953	\N	\N	\N
882	280	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348577476	\N	\N	\N
883	280	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174288738	\N	\N	\N
884	280	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174288738	\N	\N	\N
885	281	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
886	281	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507154176017	\N	\N	\N
887	281	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577189085	\N	\N	\N
888	281	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788594543	\N	\N	\N
889	281	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394297271	\N	\N	\N
890	281	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697148636	\N	\N	\N
891	281	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348574318	\N	\N	\N
892	281	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174287159	\N	\N	\N
893	281	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174287158	\N	\N	\N
894	282	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
895	282	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507154074941	\N	\N	\N
896	282	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577138547	\N	\N	\N
897	282	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788569273	\N	\N	\N
898	282	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394284637	\N	\N	\N
899	282	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697142318	\N	\N	\N
900	282	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348571159	\N	\N	\N
901	282	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174285580	\N	\N	\N
902	282	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174285579	\N	\N	\N
903	283	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
904	283	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507153973864	\N	\N	\N
905	283	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577088009	\N	\N	\N
906	283	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788544004	\N	\N	\N
907	283	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394272002	\N	\N	\N
908	283	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697136001	\N	\N	\N
909	283	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348568001	\N	\N	\N
910	283	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174284000	\N	\N	\N
911	283	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174284000	\N	\N	\N
912	284	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
913	284	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507153872788	\N	\N	\N
914	284	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253577037470	\N	\N	\N
915	284	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788518735	\N	\N	\N
916	284	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394259368	\N	\N	\N
917	284	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697129684	\N	\N	\N
918	284	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348564842	\N	\N	\N
919	284	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174282421	\N	\N	\N
920	284	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174282420	\N	\N	\N
921	285	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
922	285	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507153771711	\N	\N	\N
923	285	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576986932	\N	\N	\N
924	285	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788493466	\N	\N	\N
925	285	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394246733	\N	\N	\N
926	285	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697123367	\N	\N	\N
927	285	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348561683	\N	\N	\N
928	285	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174280842	\N	\N	\N
929	285	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174280841	\N	\N	\N
930	286	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
931	286	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507153670635	\N	\N	\N
932	286	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576936394	\N	\N	\N
933	286	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788468197	\N	\N	\N
934	286	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394234098	\N	\N	\N
935	286	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697117049	\N	\N	\N
936	286	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348558525	\N	\N	\N
937	286	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174279262	\N	\N	\N
938	286	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174279262	\N	\N	\N
939	287	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
940	287	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507153569558	\N	\N	\N
941	287	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576885856	\N	\N	\N
942	287	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788442928	\N	\N	\N
943	287	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394221464	\N	\N	\N
944	287	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697110732	\N	\N	\N
945	287	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348555366	\N	\N	\N
946	287	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174277683	\N	\N	\N
947	287	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174277682	\N	\N	\N
948	288	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
949	288	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507153468482	\N	\N	\N
950	288	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576835317	\N	\N	\N
951	288	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788417659	\N	\N	\N
952	288	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394208829	\N	\N	\N
953	288	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697104415	\N	\N	\N
954	288	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348552207	\N	\N	\N
955	288	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174276104	\N	\N	\N
956	288	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174276103	\N	\N	\N
957	289	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
958	289	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507153367405	\N	\N	\N
959	289	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576784779	\N	\N	\N
960	289	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788392390	\N	\N	\N
961	289	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394196195	\N	\N	\N
962	289	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697098097	\N	\N	\N
963	289	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348549049	\N	\N	\N
964	289	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174274524	\N	\N	\N
965	289	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174274524	\N	\N	\N
966	290	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
967	290	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507153266329	\N	\N	\N
968	290	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576734241	\N	\N	\N
969	290	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788367120	\N	\N	\N
970	290	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394183560	\N	\N	\N
971	290	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697091780	\N	\N	\N
972	290	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348545890	\N	\N	\N
973	290	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174272945	\N	\N	\N
974	290	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174272945	\N	\N	\N
975	291	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
976	291	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507153165252	\N	\N	\N
977	291	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576683703	\N	\N	\N
978	291	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788341851	\N	\N	\N
979	291	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394170926	\N	\N	\N
980	291	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697085463	\N	\N	\N
981	291	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348542731	\N	\N	\N
982	291	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174271366	\N	\N	\N
983	291	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174271365	\N	\N	\N
984	292	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
985	292	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507153064176	\N	\N	\N
986	292	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576633164	\N	\N	\N
987	292	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788316582	\N	\N	\N
988	292	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394158291	\N	\N	\N
989	292	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697079146	\N	\N	\N
990	292	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348539573	\N	\N	\N
991	292	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174269786	\N	\N	\N
992	292	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174269786	\N	\N	\N
993	293	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
994	293	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507152963099	\N	\N	\N
995	293	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576582626	\N	\N	\N
996	293	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788291313	\N	\N	\N
997	293	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394145657	\N	\N	\N
998	293	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697072828	\N	\N	\N
999	293	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348536414	\N	\N	\N
1000	293	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174268207	\N	\N	\N
1001	293	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174268207	\N	\N	\N
1002	294	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1003	294	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507152862023	\N	\N	\N
1004	294	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576532088	\N	\N	\N
1005	294	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788266044	\N	\N	\N
1006	294	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394133022	\N	\N	\N
1007	294	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697066511	\N	\N	\N
1008	294	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348533255	\N	\N	\N
1009	294	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174266628	\N	\N	\N
1010	294	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174266627	\N	\N	\N
1011	295	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1012	295	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507152760946	\N	\N	\N
1013	295	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576481550	\N	\N	\N
1014	295	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788240775	\N	\N	\N
1015	295	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394120387	\N	\N	\N
1016	295	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697060194	\N	\N	\N
1017	295	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348530097	\N	\N	\N
1018	295	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174265048	\N	\N	\N
1019	295	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174265048	\N	\N	\N
1020	296	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1021	296	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507152659870	\N	\N	\N
1022	296	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576431011	\N	\N	\N
1023	296	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788215506	\N	\N	\N
1024	296	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394107753	\N	\N	\N
1025	296	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697053876	\N	\N	\N
1026	296	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348526938	\N	\N	\N
1027	296	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174263469	\N	\N	\N
1028	296	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174263469	\N	\N	\N
1029	297	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1030	297	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507152558793	\N	\N	\N
1031	297	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576380473	\N	\N	\N
1032	297	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788190237	\N	\N	\N
1033	297	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394095118	\N	\N	\N
1034	297	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697047559	\N	\N	\N
1035	297	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348523780	\N	\N	\N
1036	297	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174261890	\N	\N	\N
1037	297	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174261889	\N	\N	\N
1038	298	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1039	298	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507152457717	\N	\N	\N
1040	298	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576329935	\N	\N	\N
1041	298	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788164967	\N	\N	\N
1042	298	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394082484	\N	\N	\N
1043	298	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697041242	\N	\N	\N
1044	298	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348520621	\N	\N	\N
1045	298	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174260310	\N	\N	\N
1046	298	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174260310	\N	\N	\N
1047	299	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1048	299	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507152356640	\N	\N	\N
1049	299	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576279397	\N	\N	\N
1050	299	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788139698	\N	\N	\N
1051	299	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394069849	\N	\N	\N
1052	299	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697034925	\N	\N	\N
1053	299	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348517462	\N	\N	\N
1054	299	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174258731	\N	\N	\N
1055	299	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174258731	\N	\N	\N
1056	300	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1057	300	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507152255564	\N	\N	\N
1058	300	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576228858	\N	\N	\N
1059	300	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788114429	\N	\N	\N
1060	300	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394057215	\N	\N	\N
1061	300	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697028607	\N	\N	\N
1062	300	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348514304	\N	\N	\N
1063	300	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174257152	\N	\N	\N
1064	300	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174257151	\N	\N	\N
1065	301	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1066	301	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507152154487	\N	\N	\N
1067	301	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576178320	\N	\N	\N
1068	301	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788089160	\N	\N	\N
1069	301	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394044580	\N	\N	\N
1070	301	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697022290	\N	\N	\N
1071	301	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348511145	\N	\N	\N
1072	301	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174255573	\N	\N	\N
1073	301	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174255572	\N	\N	\N
1074	302	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1075	302	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507152053411	\N	\N	\N
1076	302	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576127782	\N	\N	\N
1077	302	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788063891	\N	\N	\N
1078	302	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394031945	\N	\N	\N
1079	302	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697015973	\N	\N	\N
1080	302	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348507986	\N	\N	\N
1081	302	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174253993	\N	\N	\N
1082	302	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174253993	\N	\N	\N
1083	303	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1084	303	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507151952334	\N	\N	\N
1085	303	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576077244	\N	\N	\N
1086	303	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788038622	\N	\N	\N
1087	303	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394019311	\N	\N	\N
1088	303	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697009655	\N	\N	\N
1089	303	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348504828	\N	\N	\N
1090	303	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174252414	\N	\N	\N
1091	303	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174252413	\N	\N	\N
1092	304	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1093	304	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507151851258	\N	\N	\N
1094	304	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253576026705	\N	\N	\N
1095	304	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626788013353	\N	\N	\N
1096	304	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313394006676	\N	\N	\N
1097	304	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156697003338	\N	\N	\N
1098	304	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348501669	\N	\N	\N
1099	304	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174250835	\N	\N	\N
1100	304	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174250834	\N	\N	\N
1101	305	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1102	305	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507151750181	\N	\N	\N
1103	305	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575976167	\N	\N	\N
1104	305	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787988084	\N	\N	\N
1105	305	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393994042	\N	\N	\N
1106	305	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696997021	\N	\N	\N
1107	305	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348498510	\N	\N	\N
1108	305	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174249255	\N	\N	\N
1109	305	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174249255	\N	\N	\N
1110	306	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1111	306	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507151649105	\N	\N	\N
1112	306	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575925629	\N	\N	\N
1113	306	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787962814	\N	\N	\N
1114	306	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393981407	\N	\N	\N
1115	306	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696990704	\N	\N	\N
1116	306	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348495352	\N	\N	\N
1117	306	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174247676	\N	\N	\N
1118	306	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174247675	\N	\N	\N
1119	307	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1120	307	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507151548028	\N	\N	\N
1121	307	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575875091	\N	\N	\N
1122	307	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787937545	\N	\N	\N
1123	307	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393968773	\N	\N	\N
1124	307	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696984386	\N	\N	\N
1125	307	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348492193	\N	\N	\N
1126	307	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174246097	\N	\N	\N
1127	307	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174246096	\N	\N	\N
1128	308	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1129	308	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507151446952	\N	\N	\N
1130	308	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575824552	\N	\N	\N
1131	308	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787912276	\N	\N	\N
1132	308	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393956138	\N	\N	\N
1133	308	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696978069	\N	\N	\N
1134	308	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348489035	\N	\N	\N
1135	308	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174244517	\N	\N	\N
1136	308	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174244517	\N	\N	\N
1137	309	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1138	309	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507151345875	\N	\N	\N
1139	309	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575774014	\N	\N	\N
1140	309	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787887007	\N	\N	\N
1141	309	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393943504	\N	\N	\N
1142	309	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696971752	\N	\N	\N
1143	309	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348485876	\N	\N	\N
1144	309	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174242938	\N	\N	\N
1145	309	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174242937	\N	\N	\N
1146	310	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1147	310	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507151244799	\N	\N	\N
1148	310	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575723476	\N	\N	\N
1149	310	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787861738	\N	\N	\N
1150	310	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393930869	\N	\N	\N
1151	310	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696965434	\N	\N	\N
1152	310	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348482717	\N	\N	\N
1153	310	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174241359	\N	\N	\N
1154	310	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174241358	\N	\N	\N
1155	311	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1156	311	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507151143722	\N	\N	\N
1157	311	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575672938	\N	\N	\N
1158	311	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787836469	\N	\N	\N
1159	311	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393918234	\N	\N	\N
1160	311	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696959117	\N	\N	\N
1161	311	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348479559	\N	\N	\N
1162	311	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174239779	\N	\N	\N
1163	311	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174239779	\N	\N	\N
1164	312	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1165	312	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507151042646	\N	\N	\N
1166	312	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575622399	\N	\N	\N
1167	312	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787811200	\N	\N	\N
1168	312	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393905600	\N	\N	\N
1169	312	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696952800	\N	\N	\N
1170	312	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348476400	\N	\N	\N
1171	312	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174238200	\N	\N	\N
1172	312	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174238199	\N	\N	\N
1173	313	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1174	313	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507150941569	\N	\N	\N
1175	313	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575571861	\N	\N	\N
1176	313	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787785931	\N	\N	\N
1177	313	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393892965	\N	\N	\N
1178	313	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696946483	\N	\N	\N
1179	313	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348473241	\N	\N	\N
1180	313	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174236621	\N	\N	\N
1181	313	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174236620	\N	\N	\N
1182	314	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1183	314	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507150840493	\N	\N	\N
1184	314	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575521323	\N	\N	\N
1185	314	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787760661	\N	\N	\N
1186	314	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393880331	\N	\N	\N
1187	314	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696940165	\N	\N	\N
1188	314	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348470083	\N	\N	\N
1189	314	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174235041	\N	\N	\N
1190	314	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174235041	\N	\N	\N
1191	315	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1192	315	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507150739416	\N	\N	\N
1193	315	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575470785	\N	\N	\N
1194	315	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787735392	\N	\N	\N
1195	315	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393867696	\N	\N	\N
1196	315	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696933848	\N	\N	\N
1197	315	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348466924	\N	\N	\N
1198	315	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174233462	\N	\N	\N
1199	315	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174233462	\N	\N	\N
1200	316	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1201	316	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507150638340	\N	\N	\N
1202	316	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575420246	\N	\N	\N
1203	316	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787710123	\N	\N	\N
1204	316	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393855062	\N	\N	\N
1205	316	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696927531	\N	\N	\N
1206	316	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348463765	\N	\N	\N
1207	316	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174231883	\N	\N	\N
1208	316	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174231882	\N	\N	\N
1209	317	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1210	317	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507150537263	\N	\N	\N
1211	317	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575369708	\N	\N	\N
1212	317	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787684854	\N	\N	\N
1213	317	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393842427	\N	\N	\N
1214	317	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696921214	\N	\N	\N
1215	317	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348460607	\N	\N	\N
1216	317	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174230303	\N	\N	\N
1217	317	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174230303	\N	\N	\N
1218	318	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1219	318	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507150436187	\N	\N	\N
1220	318	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575319170	\N	\N	\N
1221	318	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787659585	\N	\N	\N
1222	318	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393829792	\N	\N	\N
1223	318	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696914896	\N	\N	\N
1224	318	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348457448	\N	\N	\N
1225	318	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174228724	\N	\N	\N
1226	318	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174228724	\N	\N	\N
1227	319	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1228	319	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507150335110	\N	\N	\N
1229	319	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575268632	\N	\N	\N
1230	319	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787634316	\N	\N	\N
1231	319	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393817158	\N	\N	\N
1232	319	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696908579	\N	\N	\N
1233	319	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348454289	\N	\N	\N
1234	319	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174227145	\N	\N	\N
1235	319	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174227144	\N	\N	\N
1236	320	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1237	320	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507150234034	\N	\N	\N
1238	320	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575218093	\N	\N	\N
1239	320	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787609047	\N	\N	\N
1240	320	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393804523	\N	\N	\N
1241	320	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696902262	\N	\N	\N
1242	320	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348451131	\N	\N	\N
1243	320	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174225565	\N	\N	\N
1244	320	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174225565	\N	\N	\N
1245	321	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1246	321	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507150132957	\N	\N	\N
1247	321	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575167555	\N	\N	\N
1248	321	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787583778	\N	\N	\N
1249	321	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393791889	\N	\N	\N
1250	321	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696895944	\N	\N	\N
1251	321	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348447972	\N	\N	\N
1252	321	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174223986	\N	\N	\N
1253	321	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174223986	\N	\N	\N
1254	322	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1255	322	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507150031881	\N	\N	\N
1256	322	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575117017	\N	\N	\N
1257	322	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787558508	\N	\N	\N
1258	322	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393779254	\N	\N	\N
1259	322	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696889627	\N	\N	\N
1260	322	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348444814	\N	\N	\N
1261	322	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174222407	\N	\N	\N
1262	322	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174222406	\N	\N	\N
1263	323	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1264	323	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507149930804	\N	\N	\N
1265	323	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575066479	\N	\N	\N
1266	323	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787533239	\N	\N	\N
1267	323	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393766620	\N	\N	\N
1268	323	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696883310	\N	\N	\N
1269	323	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348441655	\N	\N	\N
1270	323	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174220827	\N	\N	\N
1271	323	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174220827	\N	\N	\N
1272	324	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1273	324	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507149829728	\N	\N	\N
1274	324	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253575015940	\N	\N	\N
1275	324	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787507970	\N	\N	\N
1276	324	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393753985	\N	\N	\N
1277	324	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696876993	\N	\N	\N
1278	324	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348438496	\N	\N	\N
1279	324	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174219248	\N	\N	\N
1280	324	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174219248	\N	\N	\N
1281	325	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1282	325	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507149728651	\N	\N	\N
1283	325	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574965402	\N	\N	\N
1284	325	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787482701	\N	\N	\N
1285	325	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393741351	\N	\N	\N
1286	325	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696870675	\N	\N	\N
1287	325	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348435338	\N	\N	\N
1288	325	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174217669	\N	\N	\N
1289	325	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174217668	\N	\N	\N
1290	326	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1291	326	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507149627575	\N	\N	\N
1292	326	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574914864	\N	\N	\N
1293	326	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787457432	\N	\N	\N
1294	326	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393728716	\N	\N	\N
1295	326	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696864358	\N	\N	\N
1296	326	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348432179	\N	\N	\N
1297	326	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174216089	\N	\N	\N
1298	326	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174216089	\N	\N	\N
1299	327	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1300	327	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507149526498	\N	\N	\N
1301	327	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574864326	\N	\N	\N
1302	327	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787432163	\N	\N	\N
1303	327	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393716081	\N	\N	\N
1304	327	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696858041	\N	\N	\N
1305	327	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348429020	\N	\N	\N
1306	327	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174214510	\N	\N	\N
1307	327	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174214510	\N	\N	\N
1308	328	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1309	328	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507149425422	\N	\N	\N
1310	328	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574813787	\N	\N	\N
1311	328	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787406894	\N	\N	\N
1312	328	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393703447	\N	\N	\N
1313	328	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696851723	\N	\N	\N
1314	328	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348425862	\N	\N	\N
1315	328	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174212931	\N	\N	\N
1316	328	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174212930	\N	\N	\N
1317	329	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1318	329	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507149324345	\N	\N	\N
1319	329	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574763249	\N	\N	\N
1320	329	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787381625	\N	\N	\N
1321	329	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393690812	\N	\N	\N
1322	329	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696845406	\N	\N	\N
1323	329	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348422703	\N	\N	\N
1324	329	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174211352	\N	\N	\N
1325	329	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174211351	\N	\N	\N
1326	330	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1327	330	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507149223269	\N	\N	\N
1328	330	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574712711	\N	\N	\N
1329	330	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787356355	\N	\N	\N
1330	330	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393678178	\N	\N	\N
1331	330	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696839089	\N	\N	\N
1332	330	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348419544	\N	\N	\N
1333	330	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174209772	\N	\N	\N
1334	330	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174209772	\N	\N	\N
1335	331	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1336	331	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507149122192	\N	\N	\N
1337	331	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574662173	\N	\N	\N
1338	331	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787331086	\N	\N	\N
1339	331	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393665543	\N	\N	\N
1340	331	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696832772	\N	\N	\N
1341	331	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348416386	\N	\N	\N
1342	331	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174208193	\N	\N	\N
1343	331	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174208192	\N	\N	\N
1344	332	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1345	332	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507149021116	\N	\N	\N
1346	332	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574611634	\N	\N	\N
1347	332	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787305817	\N	\N	\N
1348	332	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393652909	\N	\N	\N
1349	332	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696826454	\N	\N	\N
1350	332	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348413227	\N	\N	\N
1351	332	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174206614	\N	\N	\N
1352	332	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174206613	\N	\N	\N
1353	333	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1354	333	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507148920039	\N	\N	\N
1355	333	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574561096	\N	\N	\N
1356	333	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787280548	\N	\N	\N
1357	333	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393640274	\N	\N	\N
1358	333	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696820137	\N	\N	\N
1359	333	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348410069	\N	\N	\N
1360	333	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174205034	\N	\N	\N
1361	333	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174205034	\N	\N	\N
1362	334	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1363	334	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507148818963	\N	\N	\N
1364	334	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574510558	\N	\N	\N
1365	334	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787255279	\N	\N	\N
1366	334	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393627639	\N	\N	\N
1367	334	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696813820	\N	\N	\N
1368	334	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348406910	\N	\N	\N
1369	334	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174203455	\N	\N	\N
1370	334	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174203454	\N	\N	\N
1371	335	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1372	335	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507148717886	\N	\N	\N
1373	335	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574460020	\N	\N	\N
1374	335	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787230010	\N	\N	\N
1375	335	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393615005	\N	\N	\N
1376	335	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696807502	\N	\N	\N
1377	335	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348403751	\N	\N	\N
1378	335	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174201876	\N	\N	\N
1379	335	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174201875	\N	\N	\N
1380	336	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1381	336	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507148616810	\N	\N	\N
1382	336	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574409481	\N	\N	\N
1383	336	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787204741	\N	\N	\N
1384	336	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393602370	\N	\N	\N
1385	336	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696801185	\N	\N	\N
1386	336	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348400593	\N	\N	\N
1387	336	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174200296	\N	\N	\N
1388	336	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174200296	\N	\N	\N
1389	337	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1390	337	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507148515733	\N	\N	\N
1391	337	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574358943	\N	\N	\N
1392	337	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787179472	\N	\N	\N
1393	337	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393589736	\N	\N	\N
1394	337	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696794868	\N	\N	\N
1395	337	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348397434	\N	\N	\N
1396	337	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174198717	\N	\N	\N
1397	337	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174198716	\N	\N	\N
1398	338	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1399	338	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507148414657	\N	\N	\N
1400	338	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574308405	\N	\N	\N
1401	338	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787154202	\N	\N	\N
1402	338	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393577101	\N	\N	\N
1403	338	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696788551	\N	\N	\N
1404	338	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348394275	\N	\N	\N
1405	338	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174197138	\N	\N	\N
1406	338	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174197137	\N	\N	\N
1407	339	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1408	339	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507148313580	\N	\N	\N
1409	339	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574257867	\N	\N	\N
1410	339	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787128933	\N	\N	\N
1411	339	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393564467	\N	\N	\N
1412	339	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696782233	\N	\N	\N
1413	339	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348391117	\N	\N	\N
1414	339	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174195558	\N	\N	\N
1415	339	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174195558	\N	\N	\N
1416	340	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1417	340	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2507148212504	\N	\N	\N
1418	340	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1253574207328	\N	\N	\N
1419	340	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	626787103664	\N	\N	\N
1420	340	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313393551832	\N	\N	\N
1421	340	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156696775916	\N	\N	\N
1422	340	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78348387958	\N	\N	\N
1423	340	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174193979	\N	\N	\N
1424	340	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39174193979	\N	\N	\N
1425	341	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	5000000	\N	\N	\N
1426	341	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	2509824971996	\N	\N	\N
1427	341	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	1254912593146	\N	\N	\N
1428	341	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	627456296573	\N	\N	\N
1429	341	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	313728148287	\N	\N	\N
1430	341	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	156864074143	\N	\N	\N
1431	341	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	78432037072	\N	\N	\N
1432	341	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39216018536	\N	\N	\N
1433	341	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	39216018535	\N	\N	\N
1434	342	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	68	10000000	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	2	\N
1435	342	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	76	39205783691	\N	\N	\N
1436	343	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	3000000	\N	\N	\N
1437	343	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	4999996820111	\N	\N	\N
1438	344	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	3000000	\N	\N	\N
1439	344	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	4999993650122	\N	\N	\N
1440	345	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	3000000	\N	\N	\N
1441	345	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	70	4999990474369	\N	\N	\N
1442	346	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	3000000	\N	\N	\N
1443	346	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	6818351	\N	\N	\N
1444	347	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	3000000	\N	\N	\N
1445	347	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	6826447	\N	\N	\N
1446	348	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	3000000	\N	\N	\N
1447	348	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	67	6821255	\N	\N	\N
\.


--
-- Data for Name: voting_anchor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.voting_anchor (id, tx_id, url, data_hash) FROM stdin;
\.


--
-- Data for Name: voting_procedure; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.voting_procedure (id, tx_id, index, governance_action_id, voter_role, committee_voter, drep_voter, pool_voter, vote, voting_anchor_id) FROM stdin;
\.


--
-- Data for Name: withdrawal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.withdrawal (id, addr_id, amount, redeemer_id, tx_id) FROM stdin;
1	68	7056565064	\N	238
2	68	7316109876	\N	241
3	76	2006616868	\N	341
4	68	3347128557	\N	341
\.


--
-- Name: ada_pots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ada_pots_id_seq', 14, true);


--
-- Name: anchor_offline_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.anchor_offline_data_id_seq', 1, false);


--
-- Name: anchor_offline_fetch_error_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.anchor_offline_fetch_error_id_seq', 1, false);


--
-- Name: block_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.block_id_seq', 674, true);


--
-- Name: collateral_tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collateral_tx_in_id_seq', 1, false);


--
-- Name: collateral_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collateral_tx_out_id_seq', 1, false);


--
-- Name: committee_de_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.committee_de_registration_id_seq', 1, false);


--
-- Name: committee_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.committee_registration_id_seq', 1, false);


--
-- Name: cost_model_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cost_model_id_seq', 14, true);


--
-- Name: datum_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.datum_id_seq', 2, true);


--
-- Name: delegation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delegation_id_seq', 43, true);


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

SELECT pg_catalog.setval('public.epoch_id_seq', 30, true);


--
-- Name: epoch_param_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_param_id_seq', 14, true);


--
-- Name: epoch_stake_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_stake_id_seq', 415, true);


--
-- Name: epoch_stake_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_stake_progress_id_seq', 1, false);


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
-- Name: governance_action_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.governance_action_id_seq', 1, false);


--
-- Name: ma_tx_mint_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_mint_id_seq', 11, true);


--
-- Name: ma_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_out_id_seq', 19, true);


--
-- Name: meta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meta_id_seq', 1, true);


--
-- Name: multi_asset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.multi_asset_id_seq', 11, true);


--
-- Name: new_committee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.new_committee_id_seq', 1, false);


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
-- Name: pool_offline_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_offline_data_id_seq', 8, true);


--
-- Name: pool_offline_fetch_error_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_offline_fetch_error_id_seq', 1, false);


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

SELECT pg_catalog.setval('public.redeemer_data_id_seq', 1, false);


--
-- Name: redeemer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.redeemer_id_seq', 1, false);


--
-- Name: reference_tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reference_tx_in_id_seq', 1, false);


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

SELECT pg_catalog.setval('public.reverse_index_id_seq', 672, true);


--
-- Name: reward_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reward_id_seq', 318, true);


--
-- Name: schema_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schema_version_id_seq', 1, true);


--
-- Name: script_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.script_id_seq', 2, true);


--
-- Name: slot_leader_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slot_leader_id_seq', 674, true);


--
-- Name: stake_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_address_id_seq', 80, true);


--
-- Name: stake_deregistration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_deregistration_id_seq', 1, true);


--
-- Name: stake_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_registration_id_seq', 39, true);


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

SELECT pg_catalog.setval('public.tx_id_seq', 348, true);


--
-- Name: tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_in_id_seq', 1487, true);


--
-- Name: tx_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_metadata_id_seq', 7, true);


--
-- Name: tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_out_id_seq', 1447, true);


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
-- Name: anchor_offline_data anchor_offline_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.anchor_offline_data
    ADD CONSTRAINT anchor_offline_data_pkey PRIMARY KEY (id);


--
-- Name: anchor_offline_fetch_error anchor_offline_fetch_error_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.anchor_offline_fetch_error
    ADD CONSTRAINT anchor_offline_fetch_error_pkey PRIMARY KEY (id);


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
-- Name: governance_action governance_action_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.governance_action
    ADD CONSTRAINT governance_action_pkey PRIMARY KEY (id);


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
-- Name: pool_offline_data pool_offline_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_offline_data
    ADD CONSTRAINT pool_offline_data_pkey PRIMARY KEY (id);


--
-- Name: pool_offline_fetch_error pool_offline_fetch_error_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_offline_fetch_error
    ADD CONSTRAINT pool_offline_fetch_error_pkey PRIMARY KEY (id);


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
-- Name: reward reward_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reward
    ADD CONSTRAINT reward_pkey PRIMARY KEY (id);


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
    ADD CONSTRAINT unique_drep_hash UNIQUE (raw, view);


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
-- Name: pool_offline_data unique_pool_offline_data; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_offline_data
    ADD CONSTRAINT unique_pool_offline_data UNIQUE (pool_id, hash);


--
-- Name: pool_offline_fetch_error unique_pool_offline_fetch_error; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_offline_fetch_error
    ADD CONSTRAINT unique_pool_offline_fetch_error UNIQUE (pool_id, fetch_time, retry_count);


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
-- Name: idx_pool_offline_data_pmr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pool_offline_data_pmr_id ON public.pool_offline_data USING btree (pmr_id);


--
-- Name: idx_pool_offline_fetch_error_pmr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pool_offline_fetch_error_pmr_id ON public.pool_offline_fetch_error USING btree (pmr_id);


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

