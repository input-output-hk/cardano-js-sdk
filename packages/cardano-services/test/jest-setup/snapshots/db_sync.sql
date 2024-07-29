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
    'drep',
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
    'refund',
    'proposal_refund'
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

--
-- Name: sdk_notify_tip(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sdk_notify_tip() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
  PERFORM pg_notify('sdk_tip', json_build_object(
    'blockNo', NEW.block_no,
    'hash',    encode(NEW.hash, 'hex'),
    'slot',    NEW.slot_no
  )::TEXT);
  RETURN NEW;
END;$$;


ALTER FUNCTION public.sdk_notify_tip() OWNER TO postgres;

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
    deposits_stake public.lovelace NOT NULL,
    fees public.lovelace NOT NULL,
    block_id bigint NOT NULL,
    deposits_drep public.lovelace NOT NULL,
    deposits_proposal public.lovelace NOT NULL
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
-- Name: committee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.committee (
    id bigint NOT NULL,
    gov_action_proposal_id bigint,
    quorum_numerator bigint NOT NULL,
    quorum_denominator bigint NOT NULL
);


ALTER TABLE public.committee OWNER TO postgres;

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
-- Name: committee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.committee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.committee_id_seq OWNER TO postgres;

--
-- Name: committee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.committee_id_seq OWNED BY public.committee.id;


--
-- Name: committee_member; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.committee_member (
    id bigint NOT NULL,
    committee_id bigint NOT NULL,
    committee_hash_id bigint NOT NULL,
    expiration_epoch public.word31type NOT NULL
);


ALTER TABLE public.committee_member OWNER TO postgres;

--
-- Name: committee_member_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.committee_member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.committee_member_id_seq OWNER TO postgres;

--
-- Name: committee_member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.committee_member_id_seq OWNED BY public.committee_member.id;


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
    gov_action_proposal_id bigint,
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
    pvtpp_security_group double precision,
    min_fee_ref_script_cost_per_byte double precision
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
-- Name: epoch_state; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.epoch_state (
    id bigint NOT NULL,
    committee_id bigint,
    no_confidence_id bigint,
    constitution_id bigint,
    epoch_no public.word31type NOT NULL
);


ALTER TABLE public.epoch_state OWNER TO postgres;

--
-- Name: epoch_state_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.epoch_state_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.epoch_state_id_seq OWNER TO postgres;

--
-- Name: epoch_state_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.epoch_state_id_seq OWNED BY public.epoch_state.id;


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
-- Name: off_chain_vote_drep_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.off_chain_vote_drep_data (
    id bigint NOT NULL,
    off_chain_vote_data_id bigint NOT NULL,
    payment_address character varying,
    given_name character varying NOT NULL,
    objectives character varying,
    motivations character varying,
    qualifications character varying,
    image_url character varying,
    image_hash character varying
);


ALTER TABLE public.off_chain_vote_drep_data OWNER TO postgres;

--
-- Name: off_chain_vote_drep_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.off_chain_vote_drep_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.off_chain_vote_drep_data_id_seq OWNER TO postgres;

--
-- Name: off_chain_vote_drep_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.off_chain_vote_drep_data_id_seq OWNED BY public.off_chain_vote_drep_data.id;


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
-- Name: off_chain_vote_gov_action_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.off_chain_vote_gov_action_data (
    id bigint NOT NULL,
    off_chain_vote_data_id bigint NOT NULL,
    title character varying NOT NULL,
    abstract character varying NOT NULL,
    motivation character varying NOT NULL,
    rationale character varying NOT NULL
);


ALTER TABLE public.off_chain_vote_gov_action_data OWNER TO postgres;

--
-- Name: off_chain_vote_gov_action_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.off_chain_vote_gov_action_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.off_chain_vote_gov_action_data_id_seq OWNER TO postgres;

--
-- Name: off_chain_vote_gov_action_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.off_chain_vote_gov_action_data_id_seq OWNED BY public.off_chain_vote_gov_action_data.id;


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
    pvtpp_security_group double precision,
    min_fee_ref_script_cost_per_byte double precision
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
-- Name: pool_stat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_stat (
    id bigint NOT NULL,
    pool_hash_id bigint NOT NULL,
    epoch_no public.word31type NOT NULL,
    number_of_blocks public.word64type NOT NULL,
    number_of_delegators public.word64type NOT NULL,
    stake public.word64type NOT NULL,
    voting_power public.word64type
);


ALTER TABLE public.pool_stat OWNER TO postgres;

--
-- Name: pool_stat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_stat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_stat_id_seq OWNER TO postgres;

--
-- Name: pool_stat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_stat_id_seq OWNED BY public.pool_stat.id;


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
    reward_addr_id bigint NOT NULL,
    deposit public.lovelace
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
-- Name: reward_rest; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reward_rest (
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


ALTER TABLE public.reward_rest OWNER TO postgres;

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
    tx_id bigint NOT NULL,
    deposit public.lovelace
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
    script_size public.word31type NOT NULL,
    treasury_donation public.lovelace DEFAULT 0 NOT NULL
);


ALTER TABLE public.tx OWNER TO postgres;

--
-- Name: tx_cbor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tx_cbor (
    id bigint NOT NULL,
    tx_id bigint NOT NULL,
    bytes bytea NOT NULL
);


ALTER TABLE public.tx_cbor OWNER TO postgres;

--
-- Name: tx_cbor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tx_cbor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tx_cbor_id_seq OWNER TO postgres;

--
-- Name: tx_cbor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tx_cbor_id_seq OWNED BY public.tx_cbor.id;


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
    url character varying NOT NULL,
    data_hash bytea NOT NULL,
    type public.anchortype NOT NULL,
    block_id bigint NOT NULL
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
-- Name: committee id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.committee ALTER COLUMN id SET DEFAULT nextval('public.committee_id_seq'::regclass);


--
-- Name: committee_de_registration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.committee_de_registration ALTER COLUMN id SET DEFAULT nextval('public.committee_de_registration_id_seq'::regclass);


--
-- Name: committee_hash id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.committee_hash ALTER COLUMN id SET DEFAULT nextval('public.committee_hash_id_seq'::regclass);


--
-- Name: committee_member id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.committee_member ALTER COLUMN id SET DEFAULT nextval('public.committee_member_id_seq'::regclass);


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
-- Name: epoch_state id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_state ALTER COLUMN id SET DEFAULT nextval('public.epoch_state_id_seq'::regclass);


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
-- Name: off_chain_vote_author id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_author ALTER COLUMN id SET DEFAULT nextval('public.off_chain_vote_author_id_seq'::regclass);


--
-- Name: off_chain_vote_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_data ALTER COLUMN id SET DEFAULT nextval('public.off_chain_vote_data_id_seq'::regclass);


--
-- Name: off_chain_vote_drep_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_drep_data ALTER COLUMN id SET DEFAULT nextval('public.off_chain_vote_drep_data_id_seq'::regclass);


--
-- Name: off_chain_vote_external_update id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_external_update ALTER COLUMN id SET DEFAULT nextval('public.off_chain_vote_external_update_id_seq'::regclass);


--
-- Name: off_chain_vote_fetch_error id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_fetch_error ALTER COLUMN id SET DEFAULT nextval('public.off_chain_vote_fetch_error_id_seq'::regclass);


--
-- Name: off_chain_vote_gov_action_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_gov_action_data ALTER COLUMN id SET DEFAULT nextval('public.off_chain_vote_gov_action_data_id_seq'::regclass);


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
-- Name: pool_stat id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_stat ALTER COLUMN id SET DEFAULT nextval('public.pool_stat_id_seq'::regclass);


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
-- Name: tx_cbor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tx_cbor ALTER COLUMN id SET DEFAULT nextval('public.tx_cbor_id_seq'::regclass);


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

COPY public.ada_pots (id, slot_no, epoch_no, treasury, reserves, rewards, utxo, deposits_stake, fees, block_id, deposits_drep, deposits_proposal) FROM stdin;
1	1003	1	0	8999989979999988	0	126000009958549647	44000000	17450365	93	0	0
2	2000	2	80999911565036	8918990085885317	0	126000009953321531	44000000	5228116	210	0	0
3	3005	3	170189812946700	8741502187363934	88298002367835	126000009951422856	44000000	1898675	299	0	0
4	4001	4	246240882166633	8590160561631384	163588560779127	125999409933812566	56000000	5610290	396	0	600000000000
5	5006	5	327847408063160	8445622525134343	226520076989931	125999409933812566	56000000	0	511	0	600000000000
6	6002	6	412303633314503	8304424374119433	283262002753498	125999409916902238	56000000	16910328	631	0	600000000000
7	7005	7	495347878746730	8164463536842601	340178611508431	125999409916902238	56000000	0	732	0	600000000000
8	8000	8	575359621407787	8037586617278328	387042440667099	125999411262114748	58000000	532038	840	0	600000000000
9	9001	9	655735487633774	7907482683680201	436770508571277	125999411262114748	58000000	0	932	0	600000000000
10	10021	10	726112083518527	7794214207545944	479655271548610	125999418362453359	58000000	16933560	1029	0	600000000000
11	11016	11	800157120183569	7670329831436811	529494627926261	125999418362453359	58000000	0	1127	0	600000000000
12	12036	12	873792286565362	7549530103708196	576652957337529	125999423588269378	1062000000	2119535	1210	0	600000000000
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (id, hash, epoch_no, slot_no, epoch_slot_no, block_no, previous_id, slot_leader_id, size, "time", tx_count, proto_major, proto_minor, vrf_key, op_cert, op_cert_counter) FROM stdin;
1	\\x579f363d5055d14b1831197eb17e09681c90714998de5c1672fc40de53395f4a	\N	\N	\N	\N	\N	1	0	2024-07-26 08:41:13	11	0	0	\N	\N	\N
2	\\x5368656c6c65792047656e6573697320426c6f636b2048617368200000000000	\N	\N	\N	\N	1	2	0	2024-07-26 08:41:13	23	0	0	\N	\N	\N
3	\\xf74cf081e315b91070fdd6e30b784c5aaa6cbcc48b0bb710618d93cc281b706c	0	5	5	0	1	3	4	2024-07-26 08:41:14	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
4	\\xfb5c7ff028f70867a7547253da7e1c02d8d2da08d8e70c5f21c03846c0be2fb9	0	39	39	1	3	4	2941	2024-07-26 08:41:20.8	11	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
5	\\x3f872e47a93c56a360a050a092e692ac6c9e497fb0867104ee419e0860187779	0	45	45	2	4	4	4	2024-07-26 08:41:22	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
6	\\x265edddbe357b5d5abe1c6819f4849db37983111d7dbae8756a59e01f5526eae	0	56	56	3	5	4	4	2024-07-26 08:41:24.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
7	\\x5da8c7d32ceba492a2bcdd1840791a30abc017bb708d289636418d99bc199d33	0	71	71	4	6	4	4	2024-07-26 08:41:27.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
8	\\x09ff2024053b926e3ea19ab751bc49bfa7fcfad18e1439445bba50f7f8ead133	0	83	83	5	7	4	4	2024-07-26 08:41:29.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
9	\\x3b8e9cdafa4b5dc4bfc5034611c890f926407f74dd6495b64dc55481057fab5b	0	88	88	6	8	3	4	2024-07-26 08:41:30.6	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
10	\\xe69582513acb2b2f086e9561f8067e100ac9f9b922f7d62b707a1c6a87d3b774	0	97	97	7	9	10	4	2024-07-26 08:41:32.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
11	\\x87849c7c24cd44b219661c491b81189290152b1a789863820ebf91b5eb85c484	0	115	115	8	10	11	4085	2024-07-26 08:41:36	11	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
12	\\x751fc6fbdcda8f1a7b1917c867e9a435222a300e4c5ade2d407b1a9a16f548e8	0	122	122	9	11	12	4	2024-07-26 08:41:37.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
13	\\x7add0c815f625f96cc8817e2f1e1c97e40f7ca62e357870f726c4a4062339ec4	0	132	132	10	12	13	4	2024-07-26 08:41:39.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
14	\\x9c52f2308205711ae310a740094c06e54bcc771beb0d51806cbfd371a851675b	0	135	135	11	13	14	4	2024-07-26 08:41:40	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
15	\\x6a33294be657e9e756edb8ff21c986cdcc102b87ae3f45296d066a9ac60f9da1	0	149	149	12	14	11	4	2024-07-26 08:41:42.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
16	\\x8f0b8b6f186438725d87708b0959c217b66a63f06b1428e7fc2a9cdd56f4ff3d	0	151	151	13	15	12	4	2024-07-26 08:41:43.2	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
17	\\x8d5b15678f826e9317763a839e8b886a365e43338eee92ada58f554b611449dc	0	161	161	14	16	11	4	2024-07-26 08:41:45.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
18	\\x0482d389804a5ad9d2e186e717ec20b11349b31d631a3862e98270cce3408bc2	0	162	162	15	17	18	4	2024-07-26 08:41:45.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
19	\\x34dfbb5a4042f4ecafcafa711b286f9f152769a854fecf55be4b875407c8cae4	0	183	183	16	18	10	2897	2024-07-26 08:41:49.6	11	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
20	\\xa564f4c130b4e1612723d4e084ebae0105762635fed281b94af83e85c2f1a2b3	0	194	194	17	19	14	3843	2024-07-26 08:41:51.8	11	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
21	\\xc1a2905e3236ca86b25ed6e9bdb0b01e027e3e80f3a8d44ff16c9b9321bf8d84	0	200	200	18	20	21	4	2024-07-26 08:41:53	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
22	\\xd759fa2278d118547d8f9a135ace5810d8ea414eb2cef27b1b32925b1a995beb	0	214	214	19	21	13	4118	2024-07-26 08:41:55.8	11	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
23	\\xedc4a90b36c72f7f6fbf7bc07eba01c604588f3346e7850a89e66b3872f5dfdb	0	242	242	20	22	14	4426	2024-07-26 08:42:01.4	11	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
24	\\xf28d30e5f365c76a6f8b5e21c06283b310e9a8c7527f2bb9b32edb813e675eda	0	245	245	21	23	21	4	2024-07-26 08:42:02	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
25	\\x6f720699efe65196d7b5d7d6c93013c866f285b962f99713ddd7f9b38ea21570	0	246	246	22	24	11	4	2024-07-26 08:42:02.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
26	\\x874f5302dba09412fc4760302e7e07b583ab2cfad836c8922c89d28de0e14b0a	0	250	250	23	25	10	7088	2024-07-26 08:42:03	11	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
27	\\x342735da1c5992b1684cbd4b130f2464dd533e52a7d9700174861b9e3cee90d9	0	266	266	24	26	10	1612	2024-07-26 08:42:06.2	4	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
28	\\xf75471b9e8f991b55e63727bf3bf2940b0e65ebcfdb59a91829d1be673102e90	0	294	294	25	27	21	1780	2024-07-26 08:42:11.8	4	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
29	\\xb9491b4cd7153a7bee693293fc3036f1f93ee2eb206064fed848383a3388634c	0	298	298	26	28	14	4	2024-07-26 08:42:12.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
30	\\xd1a878ff8c8ebb905f3c37bfc8c29d3472743eafa1c63344ade806073770d914	0	302	302	27	29	11	4	2024-07-26 08:42:13.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
31	\\xfd21f59a1c3b3e04805e24ec046edc8e20764afeb69f0a434f273dfc3dc28cce	0	303	303	28	30	13	4	2024-07-26 08:42:13.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
32	\\x94740a9047c05ef18f0024f69f7e58d8eca181da3818ee73f26102ae8269a328	0	305	305	29	31	21	273	2024-07-26 08:42:14	1	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
33	\\x79a5925cc03d6d008e48981cc13895d039a3d7945d5fa5d6b8fc57839bcbcaee	0	309	309	30	32	13	4	2024-07-26 08:42:14.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
34	\\xe200ffe9fdf725aff36adb744c83b4f849b5c75a49a9e7f861c70b8cec1a3837	0	314	314	31	33	12	4	2024-07-26 08:42:15.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
35	\\x7866697f72db091db0671af0553674af2d02b6ba6fc48fa437b3577e8395192e	0	318	318	32	34	35	364	2024-07-26 08:42:16.6	1	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
36	\\xe776baea955278bc7318363faf4b5e27ea98736fdce164ce44f4dc2a67b4fba6	0	327	327	33	35	13	249	2024-07-26 08:42:18.4	1	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
37	\\xd46f7a7b01e17c2cd92d69b5029f26259f18ef16fe9aef3fe104ff5e3030ec6b	0	329	329	34	36	37	4	2024-07-26 08:42:18.8	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
38	\\xc7cbe992abd70cd7c291403a766e5774bdf3211954e01c93a282ee7888bddfc8	0	336	336	35	37	14	4	2024-07-26 08:42:20.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
39	\\x83a0e079090fc0e0e66ad9c813ada8a3ab3327ad49cc5e25e3d7f4cd18ae39bf	0	340	340	36	38	3	347	2024-07-26 08:42:21	1	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
40	\\x5954a1005d59a7e80f815266868c7b064a3b20f7f245e6b802a4cfc1d13e664d	0	365	365	37	39	3	288	2024-07-26 08:42:26	1	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
41	\\x55e096ef0511fd78215d1a2cc8647ec92c83b1e06288ceea37f8a80caa9495cb	0	383	383	38	40	37	262	2024-07-26 08:42:29.6	1	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
42	\\xbc68bd2f7a2578e283f491409c6f661cd502e5d54da5812823cc12e1994aaf25	0	398	398	39	41	10	2449	2024-07-26 08:42:32.6	1	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
43	\\x84ef98c9ca56c7d104d624deb462ff78d8f98eb3f3f0a0377fe8285a83844efb	0	404	404	40	42	12	4	2024-07-26 08:42:33.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
44	\\x55e725c34af8e21eab54e6407dc2faf772015244c579bef1d6d58741ff18e8db	0	407	407	41	43	14	4	2024-07-26 08:42:34.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
45	\\x0439071595aae13c27cec94367862cbd696b3f7c153d54033c1ed6fbe5c96b3f	0	410	410	42	44	10	250	2024-07-26 08:42:35	1	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
46	\\x48eab0ba61c99c43de2390eee94d31bab9d23526ced8720c9a4e11c502ad8f95	0	412	412	43	45	3	4	2024-07-26 08:42:35.4	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
47	\\xcf9eb0db09a6750ad2729a23f9b0daf79693e8f9b0dbd5881758119279591fc4	0	418	418	44	46	12	4	2024-07-26 08:42:36.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
48	\\xeb7dfb22010a5fcfede9d5cc6cb288146370b0f501d1b187103756ddc4acea1b	0	428	428	45	47	14	2627	2024-07-26 08:42:38.6	1	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
49	\\x5ccef4e602f7f4260e8bb65507f771cd1c8377db05b8f34f65f4b5dd931f0de0	0	432	432	46	48	11	4	2024-07-26 08:42:39.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
50	\\x68563cc7dcbf65be49d8ce04d92a75edc3f92e2378d51264b3f0a700d640c899	0	438	438	47	49	3	474	2024-07-26 08:42:40.6	1	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
51	\\x53ddfb89711ce69dac2397d4d6603f8af8b7b9739cd2472637412fe526fe9def	0	455	455	48	50	35	547	2024-07-26 08:42:44	1	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
52	\\x36c8bbb9583d68e62b68d7654706ccd065e8e2c822c88fdcf75fe0da29bef25e	0	461	461	49	51	21	1760	2024-07-26 08:42:45.2	1	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
53	\\xeeddc614b9be69b277962fafa1d3cba8af5ee503a0c6d4f7f05530345ea577af	0	536	536	50	52	18	678	2024-07-26 08:43:00.2	1	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
54	\\xe611cfae409856ad6ca34f0dffab657d7464277c4729eadaf9eb8ba6994f3bc7	0	552	552	51	53	12	4	2024-07-26 08:43:03.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
55	\\xbc97ee779eee2172425281da43e9a11a7eb5987e58c80271cd0ddb65eadfe181	0	558	558	52	54	35	4	2024-07-26 08:43:04.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
56	\\xdcde1cd665026a559e6e5e940df2f13774dd31f64278f802eebdc15ba026760e	0	561	561	53	55	10	4	2024-07-26 08:43:05.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
57	\\xe5df9a68e7dc57f5f9f5ea83f9851c9beb3677bdee9686dc693a26f23341718f	0	566	566	54	56	18	4	2024-07-26 08:43:06.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
58	\\x291d10f359a7d88bf6a95924a1e57b7bf220b0b1f3bd95644ad4d6ad63f69db9	0	568	568	55	57	12	4	2024-07-26 08:43:06.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
59	\\x8e6d31818933b56a333a3320ca4a0f59848338022a1533f8202b94af8367e484	0	574	574	56	58	35	4	2024-07-26 08:43:07.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
60	\\x3edc34a25424df6a6a62358a9a586c5b1b045d85c11bb95100f1eb8daa88bde3	0	588	588	57	59	21	4	2024-07-26 08:43:10.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
61	\\x0752fcc56ad7fd6c9b8f888d7fd217b00bcfb5330439c94d3cc9188a2bd702b7	0	595	595	58	60	37	4	2024-07-26 08:43:12	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
62	\\xbdf4863c5736358a8f73423cd85da824fbdd06cc072324dcdd184be064c1976a	0	605	605	59	61	12	4	2024-07-26 08:43:14	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
63	\\xa9c087b05e8e401302b449de7bcdd79f8a71f554a77e740c9c25ec8405e5ccde	0	609	609	60	62	12	4	2024-07-26 08:43:14.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
64	\\x641bac5b40c58e1512df687b69606680637c9c0f1ddbf054b103e58a9332b870	0	623	623	61	63	11	4	2024-07-26 08:43:17.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
65	\\xef75ab72b02aa6e451504af0cfb930238b0c1119447c28f3e36e44f611353ee3	0	671	671	62	64	37	4	2024-07-26 08:43:27.2	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
66	\\x9aad62a9bee518a12aa556457cee19f9227f05d4d36aa20f5fca60b5bea41d11	0	674	674	63	65	14	4	2024-07-26 08:43:27.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
67	\\x3e218020c17c878e1411f3eb4b64d2d4a375d7763f35327ec55f661f50d9178c	0	677	677	64	66	4	4	2024-07-26 08:43:28.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
68	\\x66431b44e8966a65e85eb5b8b17fa303c623d302973fc827842c538172876845	0	679	679	65	67	13	4	2024-07-26 08:43:28.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
69	\\x9459bf7bf49447f4bac77aea1e2f047309fd0734a364101eedd6d46b6c90c8f4	0	680	680	66	68	14	4	2024-07-26 08:43:29	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
70	\\xa5b38da9df5076fe5c1d5c926606f70fe04585daa8799b89064c0d783a46981b	0	684	684	67	69	10	4	2024-07-26 08:43:29.8	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
71	\\x87c85933459f7be01e0de19658004ad5cd14a9a7077a5c60b41fbf03b996f619	0	696	696	68	70	35	4	2024-07-26 08:43:32.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
72	\\x6d2cead7475d4d3656990f57d964f145ddf0196ba48ca35dc6a178972144dcd4	0	703	703	69	71	12	4	2024-07-26 08:43:33.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
73	\\x0c847c2401e6ad26d5beff52f0fb033e49e50a894ce474eb6c8eee44eb19e2e9	0	721	721	70	72	13	4	2024-07-26 08:43:37.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
74	\\xd47e07c48d8b7b1d0c4f402d2b4f2f898b7787f80efe7cef7cea888cf67e8913	0	728	728	71	73	10	4	2024-07-26 08:43:38.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
75	\\xcc71b3cfe1462d4da535cc616443a9cacfbdeb3e27c8fb0c5acfcfd8bd205d93	0	731	731	72	74	21	4	2024-07-26 08:43:39.2	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
76	\\x6a01430798b6dab4d0e2d8daac468fa05b90d8b5a14a72a2c7ee6904fb906584	0	749	749	73	75	37	4	2024-07-26 08:43:42.8	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
77	\\x86cb3c573bcab194de31baf3efef2bf3b8ec25f81299d2368b009aaba94ca3c0	0	778	778	74	76	37	4	2024-07-26 08:43:48.6	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
78	\\x544acef20c18b6033410cb7427bd0bb20fc2c089c1f4acd480a84d754e594fe4	0	788	788	75	77	11	4	2024-07-26 08:43:50.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
79	\\xf5433d835bf47e7c50d03915151aab73166cd01ceb2aa15da9ae7d079f65ce7b	0	793	793	76	78	12	4	2024-07-26 08:43:51.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
80	\\x56a167c5f1c07e87157abe282c5ea069b106133f774582d34715be5bb457522c	0	795	795	77	79	12	4	2024-07-26 08:43:52	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
81	\\x07d8ca51d536d448686c7e6f9c986a0da4739953f3a38bed5112a3742bbece52	0	802	802	78	80	4	4	2024-07-26 08:43:53.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
82	\\x13d8dcbc86826a9a013ba22a4566f4870927b76a3d30689fc9a7acf4e066263e	0	807	807	79	81	21	4	2024-07-26 08:43:54.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
83	\\xf084e0d9e1f612be14ddd92c6121718ad6e02ea41959a1a2efb1bcd5fc2c7fde	0	810	810	80	82	14	4	2024-07-26 08:43:55	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
84	\\xc65b7c4736e1595290cdbc7d45eceb5f79c913ed716528768fe88470a5174243	0	811	811	81	83	12	4	2024-07-26 08:43:55.2	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
85	\\xdf63198d7a39a1d7a7ae861f16cc726313a9e01a99e3cf76686657e6caaf97e0	0	820	820	82	84	37	4	2024-07-26 08:43:57	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
86	\\x995e486593865bec452d33efcdcba29c84ba175ac592db6ea233b0a4ed71ad00	0	827	827	83	85	4	4	2024-07-26 08:43:58.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
87	\\x118cd57bfba6d3d091a022c245da8800cd3182a5e300cc884dbaa8dc390fd19e	0	882	882	84	86	14	4	2024-07-26 08:44:09.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
88	\\xb10d0c1714453255a35e99c4966da86b8c1687a6c1474d3d1a2294851a3db8b2	0	939	939	85	87	3	4	2024-07-26 08:44:20.8	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
89	\\x32596d5f0d39b2d8e22e46857bf2d3072c0608ff7bb4e43032c9cacb46e76073	0	940	940	86	88	18	4	2024-07-26 08:44:21	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
90	\\xded713794e955a71a85872521dec971b4074c46b9878414a48b8f9805862ec05	0	951	951	87	89	14	4	2024-07-26 08:44:23.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
91	\\xb90058d3354e431ce821289cb3a7b6c77d946f163a715008c7ad1f946e07f9b9	0	968	968	88	90	13	4	2024-07-26 08:44:26.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
92	\\x84f09a547f842380494fb096352d7bf390b0c6664a2521c74a1c35403de66533	0	989	989	89	91	18	4	2024-07-26 08:44:30.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
93	\\x1d67353822ef73825176ed8fcaa783aeadbb3917aba6acf223cea13ad2299019	1	1003	3	90	92	11	4	2024-07-26 08:44:33.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
94	\\x42548d5e7c9a9d1001bd9f4fa3476cf86dcc0d0d3d07446c8c3918c85e7345c2	1	1005	5	91	93	12	4	2024-07-26 08:44:34	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
95	\\x7fd89aaf12215ed0a06fdd4ba1208a89299a0c219f54654ebd64d91d191b36d6	1	1006	6	92	94	18	4	2024-07-26 08:44:34.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
96	\\x0e7c84ff9c641491318ce55bd20eb87f6989e41288996e2b77b8b74e0c45ac13	1	1010	10	93	95	4	4	2024-07-26 08:44:35	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
97	\\x4b45137850c0537ed3361b00371c61a559a4dfb3ca279ba4b408c6657d0168d7	1	1015	15	94	96	11	4	2024-07-26 08:44:36	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
98	\\x6dd1f94a6b8d2331948272f011005db45e254bf6d633ef8e0f23f68ea8e90ecb	1	1016	16	95	97	3	4	2024-07-26 08:44:36.2	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
99	\\x9a8630ceac9d5fd3b38835277988460ad67858bc49843ffe6a77e0d1b7875a84	1	1018	18	96	98	4	4	2024-07-26 08:44:36.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
100	\\x5a30de5fbfad88f2662f11f1ce215dd06e086a7ceea1501c925cf62a7f471748	1	1021	21	97	99	13	4	2024-07-26 08:44:37.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
101	\\x0178c924b700afeb88bb3b9ccc65d8375513ca9d186ace3e9a402a38897d5497	1	1031	31	98	100	35	1704	2024-07-26 08:44:39.2	1	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
102	\\xf5481f872efa73d4d06602896899edb85bf10e1b203bd46d9c387b177c1ceca7	1	1038	38	99	101	18	4	2024-07-26 08:44:40.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
103	\\x5cebd9b11a52dd5e1e7b2772ceb0534458efa298a17decba8847077ae89c6451	1	1046	46	100	102	14	4	2024-07-26 08:44:42.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
104	\\x82105c0c3cbe4318ac0dcb92896eb1c70e7837c28259dd7c87458a6b5fd79ec4	1	1055	55	101	103	35	4	2024-07-26 08:44:44	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
105	\\x9f33c149fe24e924ba073e3c404d5cb5dc1f24621197eb1b7019c3719db6c0a3	1	1057	57	102	104	13	1415	2024-07-26 08:44:44.4	1	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
106	\\x9b4f739f6d4c2bf488b5da3cf154306fbe2da913e3f86043e893868763e2a1b1	1	1060	60	103	105	13	4	2024-07-26 08:44:45	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
107	\\x6a2cc72318cb5ef559d69936e8bc853bbb5efb96560c20ec5405b9d1c4791553	1	1079	79	104	106	14	4	2024-07-26 08:44:48.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
108	\\x3d9c3bc77e54c02eae30972ff756b222be50d560d8eb093320764c23dc2598fa	1	1084	84	105	107	21	4	2024-07-26 08:44:49.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
109	\\xceaab98ee4dcc1b2d749c09925ddbfda87d7c27eef09250b940b2bb8fb88a41d	1	1090	90	106	108	3	1434	2024-07-26 08:44:51	1	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
110	\\xb705f4eb92ced54f1a5436430eac7df2dfbc5f36b1e889d372d42eb206d88f5b	1	1097	97	107	109	18	4	2024-07-26 08:44:52.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
111	\\xa57d57710d9b754c35f80af741435c6ea356df03e51829427aa37101e8a5885d	1	1103	103	108	110	13	4	2024-07-26 08:44:53.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
112	\\x1ed161a760e645677498deb785491ad0df48ea299a86ac67485a7b6cee63b18d	1	1130	130	109	111	37	4	2024-07-26 08:44:59	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
113	\\x19bf2a9f6caf974b3e8c256df1f9053aa0962f8dbc05839578b444675e8d26b6	1	1138	138	110	112	13	747	2024-07-26 08:45:00.6	1	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
114	\\xbe627498bc5422e23053c0686459d11202a8d759715364b4989584a4727045e1	1	1142	142	111	113	12	4	2024-07-26 08:45:01.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
115	\\xd05d2f695ab645e687d0ba9e049bf5e8965b74a643810ad5698df4200b2fb8f9	1	1152	152	112	114	4	4	2024-07-26 08:45:03.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
116	\\x71cf228e41a652c6415141f7bc534ea7faabcde6f2dbf5cfe68fc921b6f4f3ac	1	1155	155	113	115	35	4	2024-07-26 08:45:04	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
117	\\x88617b694f1201436db095680501fd36064725a55e4d4b75968030f7c7b68216	1	1159	159	114	116	3	449	2024-07-26 08:45:04.8	1	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
118	\\xe8bc2a08afac25f9774910533d14f644199bbdaf430393bcac04f01b7862c7d9	1	1172	172	115	117	4	4	2024-07-26 08:45:07.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
119	\\x7331d54fee7368df107b58f87d5b5847537ce4edda69a2870002da94c39835fc	1	1179	179	116	118	18	4	2024-07-26 08:45:08.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
120	\\x7fb20980153dd76602934d8a0095ef1654e8a01a544760da5b2d89f7a8702684	1	1191	191	117	119	10	4	2024-07-26 08:45:11.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
121	\\x8274d5cb8c44a2c64cac465cbcd1c32ff112f6d5d40fc4b1d8fe467c137d6b08	1	1197	197	118	120	3	469	2024-07-26 08:45:12.4	1	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
122	\\x08bff7884e1bafc3dc46257ac5a3a5ca0250671b76bfd60a799018cf909d129e	1	1198	198	119	121	3	4	2024-07-26 08:45:12.6	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
123	\\xfa6fc47120551d944cb5489767140c5bd461165d04350bd49d29b32b352ff83f	1	1226	226	120	122	14	4	2024-07-26 08:45:18.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
124	\\x8d5388ee3923a751eec7f690203969453cbf5840a68a1cc046474d34d35957fa	1	1228	228	121	123	14	4	2024-07-26 08:45:18.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
125	\\xa2c1b89cc84d3d09bc71ad5d8b5a6e3a590b59f55e0e61b515be3923a2efa4b2	1	1241	241	122	124	13	366	2024-07-26 08:45:21.2	1	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
126	\\xfcdf6b5375e9e46b3721a30ea661cd90478b6b094acafaa24166651282ace2bb	1	1244	244	123	125	37	4	2024-07-26 08:45:21.8	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
127	\\xdfe53541d1d57042936b16df7ce370f4571598642f8b4ab0f6f5b35a078f4d37	1	1245	245	124	126	37	4	2024-07-26 08:45:22	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
128	\\x98b887b0dcd2c4d11bede35fbc95cdd3b0a04eb7a2d9578a92681dd683a5b876	1	1250	250	125	127	10	4	2024-07-26 08:45:23	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
129	\\xa8138b2b07a630807bc5a6a26ec40daa16f0454301881822f86f9c659ae77086	1	1274	274	126	128	21	401	2024-07-26 08:45:27.8	1	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
130	\\xcf35550bb186881d1c1e2cc14c30ac4ff9443f3d57e537223c547a534acfd073	1	1282	282	127	129	35	4	2024-07-26 08:45:29.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
131	\\xadfe23c65ae0e552e0ea2a0d0ec68c0fa42b0936619c4f779db19cf865c0b8c2	1	1292	292	128	130	13	4	2024-07-26 08:45:31.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
132	\\xd5a71fcf17a1f029cc5911cfd66fb42d3840902b92e75f9fdec7fdf5b16c375f	1	1297	297	129	131	35	4	2024-07-26 08:45:32.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
133	\\x930c998d55e2d84a6603943132610eb346d0186e7951c1f002d39ebdc8a2905d	1	1310	310	130	132	14	749	2024-07-26 08:45:35	1	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
134	\\x2d58c2c2aa00e5dacf476b678821f5603d2f4251aa39caf0e72194a5416dbc5a	1	1324	324	131	133	3	4	2024-07-26 08:45:37.8	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
135	\\xc168da1d2c3970f6a0c9e4b07f8580e62d4af86524b4bbfe41d59e8c8ccc4d91	1	1327	327	132	134	4	4	2024-07-26 08:45:38.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
136	\\xcab0fa52f44d5778b33944882faa23efc1d94f6eb87a31b9646a8e1bbd44e9b9	1	1328	328	133	135	12	4	2024-07-26 08:45:38.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
137	\\x096b9eb1a7b04cc9004aba215fcd7470098497a5f66602a4b6ca3e8c3d037ead	1	1335	335	134	136	14	749	2024-07-26 08:45:40	1	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
138	\\x5cb5c13570eb298b5b4596c0f38cf603d9d958856eb83de08f2a2bf8353d82d3	1	1341	341	135	137	37	4	2024-07-26 08:45:41.2	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
139	\\x5f3f73d7552abaa6659a01135f5b84c2a62aa6ffb0978686044db96146d6f049	1	1350	350	136	138	13	4	2024-07-26 08:45:43	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
140	\\x9c8b4c8be7aeb235a7806d4a7b39b071401bec019eec7492c03b60ebec5bc1c6	1	1353	353	137	139	11	4	2024-07-26 08:45:43.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
141	\\xb3d0b64a1da92f81e992911f5c626a875f66f53b64f7560fb00087f0d8b36f74	1	1359	359	138	140	35	336	2024-07-26 08:45:44.8	1	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
142	\\xdb86ee30901d36a43f01a8508014f7efa8b75bd9e393aa67c1d472f4957fc9f2	1	1361	361	139	141	18	4	2024-07-26 08:45:45.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
143	\\xa2d018ec699ca0cb23aad32cf450d66bd77e90c242fc5ddb11da72f3e248ffcc	1	1372	372	140	142	18	4	2024-07-26 08:45:47.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
144	\\x223799542c0697c256e37db9025e645e241fbbee44a12cff1349f479315a2eab	1	1390	390	141	143	4	4	2024-07-26 08:45:51	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
145	\\x03183e63115a472c0d44cb946401df7ba56085d6001020d70eaf7e041be9d024	1	1400	400	142	144	37	749	2024-07-26 08:45:53	1	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
146	\\x373037f9cac33dba101fee860b18006de263c4bc4276ce714fc9c132dde684f6	1	1403	403	143	145	4	4	2024-07-26 08:45:53.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
147	\\xc2baa4a8a61b5b7aba1b233ce7eab05f99a40eb490c2a9ee390361cca3ac5865	1	1406	406	144	146	3	4	2024-07-26 08:45:54.2	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
148	\\x01e358f4254aab4d5879b1a9d7d884b19b196e157e9fac0c9ebe668748770b09	1	1412	412	145	147	35	4	2024-07-26 08:45:55.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
149	\\x24214518e87be939b5efa59085cce4e3a5d4579a10198997f6735b42607e869c	1	1425	425	146	148	37	300	2024-07-26 08:45:58	1	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
150	\\x8940dc2936b360292a91fe08ffb6fbff0f9079b3020b4aaab6775b3e4c4edd87	1	1427	427	147	149	13	4	2024-07-26 08:45:58.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
151	\\xf334ffa8ab6a94732812efa30e032ef23763487589aa8a36deab6fe9e6aeed48	1	1430	430	148	150	10	4	2024-07-26 08:45:59	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
152	\\x798047050b0574cea3047255712d707f6e086c1ce21646dacc2c1419f06c7d51	1	1451	451	149	151	4	4	2024-07-26 08:46:03.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
153	\\xd9b0bcfadc29d781b0860bad3ac1aea409d3b0c2ef8f895e59d3cdca8b2d28bb	1	1460	460	150	152	37	745	2024-07-26 08:46:05	1	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
154	\\x08b419814ccd7fc763a8641d08c174f88b5d38d2b6e3a8c784d816e3a5b9cc78	1	1461	461	151	153	12	4	2024-07-26 08:46:05.2	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
155	\\x6c8fe97d2811787b00ea0a07b63c901fa46bcda050e3ec09066e0df4180c10e5	1	1463	463	152	154	35	4	2024-07-26 08:46:05.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
156	\\x46a92ac04cf51edcc6146c55d1baabfa0d9285acf1dbd72184c5708403822e2d	1	1479	479	153	155	18	4	2024-07-26 08:46:08.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
157	\\xbbc9d3a3b1388537a4faa311f59e6f7e3309270068ae74371f243a71e51cb22a	1	1489	489	154	156	3	342	2024-07-26 08:46:10.8	1	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
158	\\x3f30228eb0804e8a8d2e365d015f30bbf50ef0098a1bf661b99c582e7a9e1c1f	1	1492	492	155	157	10	4	2024-07-26 08:46:11.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
159	\\x3eb41ae5c4a8ed01236d9a28fb1f97016b5920ddf785c3c758c30333bfed42fa	1	1506	506	156	158	14	4	2024-07-26 08:46:14.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
160	\\x0ed0b9b33186ea78e6a760a411ff3ced08dfe5470af65a519728b714dc09262b	1	1515	515	157	159	4	4	2024-07-26 08:46:16	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
161	\\xe8269c2574a18ecc209adb38d1ad9646e45768362975c5f671b3bf289e0be312	1	1525	525	158	160	12	300	2024-07-26 08:46:18	1	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
162	\\x7ecaa6200467021e82b23ebce78e9b63637d9cb9356b2ac74f84eb0bfd6a2266	1	1536	536	159	161	14	4	2024-07-26 08:46:20.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
163	\\x8aacc08d0efe10caea35fc789ab388ed72759d1829ef1b10d77dbe6b1bfcdcaa	1	1560	560	160	162	10	4	2024-07-26 08:46:25	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
164	\\x37fbd0421b40183cccdcc25715862a730ba80dd82a5318297c62a20f3577c9e7	1	1567	567	161	163	37	4	2024-07-26 08:46:26.4	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
165	\\x58e377356a2a79a395c8de2830c308cc4a53750e849bbbac22dd0239e824801a	1	1574	574	162	164	12	4	2024-07-26 08:46:27.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
166	\\x2968617b6dcaa581ddb72589e5f663cd2e0ea620a11d76dbc48b6d6a19d05c03	1	1595	595	163	165	4	1136	2024-07-26 08:46:32	1	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
167	\\x750f78a9a3d7fab67a851be56cd9d6591700556442b74aca6cd9a9693fab585b	1	1599	599	164	166	37	4	2024-07-26 08:46:32.8	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
168	\\x4f4ac4bb95e704400ca82bf55f65831140e5bca3206f717c927324f23a29a3e1	1	1615	615	165	167	11	4	2024-07-26 08:46:36	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
169	\\x5035138e4ef0ed7b9e0a466fb3633da4a47f4a14bc83a7518c812dcf09e189d7	1	1616	616	166	168	37	4	2024-07-26 08:46:36.2	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
170	\\x6f3c226e868b4bb21712688190018accb96dcd1ab9d3c9c961653f8d87393401	1	1624	624	167	169	12	562	2024-07-26 08:46:37.8	1	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
171	\\x816e0c3aace019726004edb3faaf11481bcc3eb091184f5525a51056e1e9b3e2	1	1627	627	168	170	11	4	2024-07-26 08:46:38.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
172	\\x187f9686dfb9b05f12e843831d9c97c34d643bd80a6f75c0cbd4b0f5208b18cc	1	1632	632	169	171	13	4	2024-07-26 08:46:39.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
173	\\x7dd0079197590546c658e31eb09f1b86841072b8fa379811e5beb86c94650c8e	1	1648	648	170	172	35	4	2024-07-26 08:46:42.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
174	\\x5a6448186eb21d7cb391b4cef7bf005012becefcd289b320d37702f6baeb0f23	1	1656	656	171	173	37	775	2024-07-26 08:46:44.2	1	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
175	\\x0623702b5550c697758b853910d7b9099e279363a6f3e316557752cf9cebe38a	1	1658	658	172	174	12	4	2024-07-26 08:46:44.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
176	\\x37f3d4271994cc7e6a7e4c63dc16d43502d3c7e98ee25cb64b1fd3f0f6d34d3d	1	1671	671	173	175	3	4	2024-07-26 08:46:47.2	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
177	\\xf22cb984b9aac9f249ebf5f8b5e46b11d9f32be3d015ef3580d6e4447c20f775	1	1672	672	174	176	12	4	2024-07-26 08:46:47.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
178	\\x843b38ccb8230712b7b671ec8ca8f79a494c49769c5890c5323001d270db2bb1	1	1681	681	175	177	11	742	2024-07-26 08:46:49.2	1	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
179	\\xcb11640403dccda7bed70e188766a12d29083fa31c4fdd51cfd8940f076b9cb0	1	1704	704	176	178	12	4	2024-07-26 08:46:53.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
180	\\x5fd311a35d2c6f119b6c5efb4f216b69cce41f33116eee5e6a0febb0a17c19dd	1	1712	712	177	179	4	4	2024-07-26 08:46:55.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
181	\\xceb1b56c0ee949599d0d59419f70274a8c27b4f5f5437a9c040155de9c2e1def	1	1736	736	178	180	21	4	2024-07-26 08:47:00.2	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
182	\\x5bbd61265938f634bdeb7f7f30d4bdd641fdc4e10603ee7761d8af7b0d1b0646	1	1737	737	179	181	4	745	2024-07-26 08:47:00.4	1	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
183	\\x35ce5e97044e9dfd83bfcd9562aa21587f5677dee5f8e95baef23592ce376da3	1	1748	748	180	182	12	4	2024-07-26 08:47:02.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
185	\\xfa70f226f4e2aa64e9c16a7a9ec9012dc0948c8ddfd9e83d62e8c1ae4cb3fd1f	1	1788	788	181	183	21	4	2024-07-26 08:47:10.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
186	\\xc0999d56312481067f7c1a56c2122f60e20df37c198b0a97324bd9a72590c3ee	1	1795	795	182	185	37	4	2024-07-26 08:47:12	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
187	\\xe74831aeaecda85a554578a29a2cd132a2f231ce3b16db3722368bf0508970cf	1	1798	798	183	186	10	575	2024-07-26 08:47:12.6	1	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
188	\\xb35cf985ce317cf74134e2cc17f414f8865e685bf7de7efd680b4b47622631b8	1	1802	802	184	187	3	4	2024-07-26 08:47:13.4	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
189	\\xa077227f5f3bcf854f8fd6ca6da4ed8d2b36ca6633820bc47a21e56fc6f0aa84	1	1805	805	185	188	35	4	2024-07-26 08:47:14	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
190	\\x3cfe4308d5b2f3461fc20f14431d6ef4456423ba50a37cbfe26c64a45bd4c74d	1	1816	816	186	189	14	4	2024-07-26 08:47:16.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
191	\\x73cf1742d52567831a448cb3033fc3b1cf3d10b24a24cad4cb64f486eeba083b	1	1819	819	187	190	18	4	2024-07-26 08:47:16.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
192	\\xdf32bec7fdcbe79659377a4a2871f5c0332413e703d4a42856c436facbb7a9b5	1	1830	830	188	191	21	662	2024-07-26 08:47:19	2	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
193	\\x31cfb1be4081793d386630e50564791fcf87ecf07e8d2ba59b151e3b7a27147c	1	1833	833	189	192	35	4	2024-07-26 08:47:19.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
194	\\x5dadd4e565f539574418b9a799f55a9516516ef9dd33b97574a1be3882a4cb21	1	1848	848	190	193	11	4	2024-07-26 08:47:22.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
195	\\x041e988504360e0ca816b0848a841cc690fda277657b26c8348d40279d962f63	1	1851	851	191	194	37	4	2024-07-26 08:47:23.2	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
196	\\x7c6e80c117fc1d6956aff2b98e93d334777e546229f6d8fea4a79aa7062bfdfa	1	1870	870	192	195	4	644	2024-07-26 08:47:27	1	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
197	\\xcf5f01caa644d3569e12d30a9004a08d4af3be0df77a8ce531a8bc74ad141790	1	1895	895	193	196	37	4	2024-07-26 08:47:32	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
198	\\xacfd09cce697087d19411b23cffd9b3ca0187803592294e1f83bffb895ef74d1	1	1908	908	194	197	14	4	2024-07-26 08:47:34.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
199	\\x7e1ef71ca141e2f8f4cf30ec69da963c330770f0d8700fc3c15afdcc2de0490b	1	1912	912	195	198	4	4	2024-07-26 08:47:35.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
200	\\x1524d4aa7963c612495b3418a2662c8735b6840b0e2d116c9d8a8ebafbeb75a3	1	1913	913	196	199	12	535	2024-07-26 08:47:35.6	1	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
201	\\xf4fdbb38f31a9fc8dbded270f48e68c5ca6f3c7bffbfc7c1a362f7dd8733fae1	1	1916	916	197	200	11	4	2024-07-26 08:47:36.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
202	\\xa35d1870a58904aa3796b6efa96f9a18ba2a5b1f56f51c00a8a03af9a56e4c34	1	1923	923	198	201	37	4	2024-07-26 08:47:37.6	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
203	\\xfbe86f1a88cf844600f12378ca9ad3038ead018f2af881c8660c5bb3742cd15a	1	1925	925	199	202	11	4	2024-07-26 08:47:38	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
204	\\x1a9dd7ed0a4fcb03e421a4f6e20f58055c962b76b0758b5600ca13fd5c29fabd	1	1938	938	200	203	11	537	2024-07-26 08:47:40.6	1	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
205	\\x6571c8e4406f676e76ae0b82848f21e9e1b04f36c52197cbf08689933d4e2377	1	1959	959	201	204	21	4	2024-07-26 08:47:44.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
206	\\xb8c2a9dd2c97442283e23632bcd4563dace4de8b1b494650839345506e5b939f	1	1963	963	202	205	37	4	2024-07-26 08:47:45.6	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
207	\\xf0f177ecb2ccfbe24f968c281a7c0bb2a210d6af53ae4b5f432321ee09c01f44	1	1986	986	203	206	3	4	2024-07-26 08:47:50.2	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
208	\\xa39624884b6a1c30fb4252b461891b29aa10faf5a5c0aeef0f31f89601f3fb74	1	1992	992	204	207	21	397	2024-07-26 08:47:51.4	1	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
209	\\x9ab1fc774eab41edbdb62d1c23bc5ae9720968236d4dda867717337476c6941d	1	1997	997	205	208	12	4	2024-07-26 08:47:52.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
210	\\x4e1e0b16863e301865c2ca5a59003a88614c42d2e504f3cab222498b7f0cde65	2	2000	0	206	209	14	4	2024-07-26 08:47:53	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
211	\\x324b2f678a042f4137815f387df93ce9a11fa2a715d98696bcc134ff7ef0593a	2	2006	6	207	210	13	4	2024-07-26 08:47:54.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
212	\\x0768f27e9cf02fc539a14b0e07becc00a3df4394967070cf785440f857c742c2	2	2010	10	208	211	13	4	2024-07-26 08:47:55	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
213	\\x4427e6348916c6bdbedb0d83e277a5aaaa40d68083f8e31aa074ed95c53690c5	2	2033	33	209	212	35	8200	2024-07-26 08:47:59.6	1	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
214	\\xa2489d6d764652e561eb1b75d105415146c4e824b61baff7d7299ec09d9c217a	2	2047	47	210	213	18	8410	2024-07-26 08:48:02.4	1	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
215	\\x432f679046df21c378dd512c683da4759b45a2c5ec4bae2901a3cfe363b85b47	2	2052	52	211	214	21	4	2024-07-26 08:48:03.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
216	\\x6b9d80e76900e7a5203082e800cb8ca34f6eb6d8492ec5b126ff407892e49cfc	2	2096	96	212	215	11	285	2024-07-26 08:48:12.2	1	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
217	\\xe794dd4028d1208b112310f6ca2e12179ac512680606975a58dac67529d11422	2	2113	113	213	216	10	338	2024-07-26 08:48:15.6	1	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
218	\\xfdcf04d9ad824b79313cb6a5908f84f06d946f59d5ecccfcd710376e98640f42	2	2125	125	214	217	11	4	2024-07-26 08:48:18	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
219	\\x224999e50dd25637e1447d3cdfaec0b788e54963dd0b19d4ae06dbe2a17ad952	2	2128	128	215	218	3	4	2024-07-26 08:48:18.6	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
220	\\x3771092290cc57bce4589dacf91bfbf97985b4bc651aae547ec4ec1edd333ebe	2	2133	133	216	219	11	294	2024-07-26 08:48:19.6	1	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
221	\\xfc9f6ebbfac856bbf2ef0ba528075edd583f43ffaa049d4394e6fd6dd5231c19	2	2150	150	217	220	11	592	2024-07-26 08:48:23	1	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
222	\\x8bc6088d04795f5b1706bb56f40836be7d26835fb8043bdead51a34d96a99ff0	2	2152	152	218	221	35	4	2024-07-26 08:48:23.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
223	\\xf787fd3fecb461feed96fa45427d6a301c78c016cf187ec5a24e4736a3d6b257	2	2155	155	219	222	21	4	2024-07-26 08:48:24	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
224	\\x7539d40c9c6dea1e387a141bc16b04fc5370adc021a4ef296cc6f4459d34699d	2	2181	181	220	223	13	4	2024-07-26 08:48:29.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
225	\\x52a26feee7347b579919fb49a03825e5ee896fd7c947928f7db8d8cc48df2303	2	2184	184	221	224	10	4	2024-07-26 08:48:29.8	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
226	\\xbb0d2df3eadf5a5f544d8727664217eefa19a0660fb71cee2b679d79c5d11f4b	2	2212	212	222	225	14	294	2024-07-26 08:48:35.4	1	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
227	\\x46bb4c876030c81fc614d2968cd36adc8475825b09f2d46a97ba5e1a0391bf60	2	2217	217	223	226	18	4	2024-07-26 08:48:36.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
228	\\x945786a17afbd293625d268bbabb4663f54670c7cc9c0c5abc9ae3ce639259aa	2	2247	247	224	227	35	4	2024-07-26 08:48:42.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
229	\\xe0ad4aaf51c127adb8f3d234c0e447c6d2a24d5b841752a08059d628d85f2b21	2	2273	273	225	228	21	4	2024-07-26 08:48:47.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
230	\\x73639763335f6a6237d5deb3cd9ec8983dd3c165a0284b664af7766b255eec40	2	2312	312	226	229	4	4	2024-07-26 08:48:55.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
231	\\x366dac5d03a78eced738d08bca235a85b3f0878dba22076d07ad909dfdb476dd	2	2314	314	227	230	3	4	2024-07-26 08:48:55.8	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
232	\\xed952ffae4bca5a58897007593adadf144521cc841c2f08f84d3985ae29ad8ea	2	2316	316	228	231	37	4	2024-07-26 08:48:56.2	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
233	\\x7d9f37b883e5a63a60c0caddf863aed0ebed0d8290fd5d0e6914e562361e5a91	2	2322	322	229	232	13	4	2024-07-26 08:48:57.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
234	\\x1f1cadc49c4b5d8a4be7426e57352a62cdbf25df1ef7b1c99f39985cb9970cca	2	2323	323	230	233	21	4	2024-07-26 08:48:57.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
235	\\x6b0c69de2533466a1d42c80b06057875003e0054f86f8d4e412f3afa17c74bcd	2	2332	332	231	234	21	4	2024-07-26 08:48:59.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
236	\\xf8dcf1c6e0733c9e095239690a4db1c7f6297c524606e5face2136188f261e53	2	2343	343	232	235	10	4	2024-07-26 08:49:01.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
237	\\x43803a1d143db1d505745d4906d18239b943ff1b38b259fb026806af5faca3a1	2	2347	347	233	236	14	4	2024-07-26 08:49:02.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
238	\\x776e158fda081620b4afe6f09b978ac20807f01dc59edeae09b3e5c3ade0e502	2	2352	352	234	237	4	4	2024-07-26 08:49:03.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
240	\\xe9610ee33d5df6f5dbc44b1343ec09fc9546854643f6ec2f836a87c8264301e5	2	2356	356	235	238	10	4	2024-07-26 08:49:04.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
241	\\x0c23e6bc66b5c41422cc71e5f7ab5a6a3ad92f1d78f9274b19460ecb0cc3aee8	2	2357	357	236	240	13	4	2024-07-26 08:49:04.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
242	\\x36f9571c306e456b490d6705eee2ffd4a57afa8be6c78d1dee2ccb66957a4df8	2	2375	375	237	241	37	4	2024-07-26 08:49:08	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
243	\\x287a6a8dca39832382cdfa1197bcbd950db47468f918b8b525f6a50dd81f9b34	2	2423	423	238	242	13	4	2024-07-26 08:49:17.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
244	\\x6c5fe3ca870d1f298a1df51ab739bd5e3a6b60d50ddf4dcae22ad59c481f1c89	2	2437	437	239	243	11	4	2024-07-26 08:49:20.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
245	\\x431d6f7a5f018b9f83edffbe9b7543c3d989252337ff9c105c5b44c01c709718	2	2453	453	240	244	18	4	2024-07-26 08:49:23.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
246	\\x3243c0d049f226ebebc2cf42f95d7fed0870dc13c196ea6451f8b1b72e567bee	2	2461	461	241	245	35	4	2024-07-26 08:49:25.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
247	\\xedab01471f06711eda8d729fb4f0f4ce955dffc0107b651c6c80a7ff6c3465e6	2	2473	473	242	246	3	4	2024-07-26 08:49:27.6	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
249	\\x0c620ca5c07b988c7380e95997f688a44cb09128df9390f7376a5fb3f48cbcb1	2	2484	484	243	247	13	4	2024-07-26 08:49:29.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
250	\\x5e79e86b983476e56a458e06b40b2cb19c804b441d200fc96fc47c85273acf90	2	2489	489	244	249	21	4	2024-07-26 08:49:30.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
251	\\xeef421884b8c8993e4e43429c1a9ab3b18b2df8ef56d32194ed1e98f8291c381	2	2498	498	245	250	37	4	2024-07-26 08:49:32.6	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
252	\\xb0a4af05a6085c0765cb92d285711f0fd0286c93b5679fb7e1a9852d7cbf029d	2	2527	527	246	251	11	4	2024-07-26 08:49:38.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
253	\\x368a1a71d223f27842e2dd789f9464902654c0d90ed880f6cccbed5716883ea5	2	2529	529	247	252	13	4	2024-07-26 08:49:38.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
254	\\x14f3e174ce0205bdcacca9cb227386fee01e6f5011d53d7cd5641ecd0e040296	2	2534	534	248	253	13	4	2024-07-26 08:49:39.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
255	\\x34d397d4817e7235b3b0ae5c72d40195764b3eea000747757671972c22c2dbdb	2	2537	537	249	254	11	4	2024-07-26 08:49:40.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
256	\\xf74196fa2121bed80e3683d05d854a3e032ae5ebef3c09dc393823210ea99cac	2	2540	540	250	255	37	4	2024-07-26 08:49:41	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
257	\\x490278cff1734ec3ee0bf32bb7f486838a98d091de3e8ecefb827d6288a319bc	2	2553	553	251	256	12	4	2024-07-26 08:49:43.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
258	\\xe79bbceece064f99a1e5ecab395146cae30c1927b0671d8ec5c62204a9a3775b	2	2559	559	252	257	18	4	2024-07-26 08:49:44.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
259	\\x31ce1048588d6e11b864ae01ba6af32c70d50e2ffea3cb7c5135ff8e19daeb05	2	2566	566	253	258	18	4	2024-07-26 08:49:46.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
260	\\xd7d36ba296399a207979ae74afce6ee37ea146343eccc43c5f4fbaa88771872c	2	2573	573	254	259	18	4	2024-07-26 08:49:47.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
261	\\xc8c9990c9ea40d8ce3dc6e1e14e8fac17e16b56087844228207e7ea69e320600	2	2578	578	255	260	35	4	2024-07-26 08:49:48.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
262	\\xd898f4c0273f2222d639058b7adfe24c7db5755e7efd88a7d77dd3666995077e	2	2588	588	256	261	13	4	2024-07-26 08:49:50.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
263	\\x9a8ecc1129512171433e4246b355c34e336a4b989bcb6e7f0111e4929b31b4e0	2	2594	594	257	262	10	4	2024-07-26 08:49:51.8	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
264	\\x2a08fb96781217848e5e2ad384f06fc79ffc3570e4f03df91fce821b9f0d2568	2	2598	598	258	263	11	4	2024-07-26 08:49:52.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
265	\\x416e72dea359b3fce1b69ea9686c84d540fd56ed609b04edad5885565a09df46	2	2610	610	259	264	13	4	2024-07-26 08:49:55	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
266	\\x5a40e7579ba44dd4c8a9321fc5a70d2aca337a8c51fc787540c9a2d2af606b7e	2	2611	611	260	265	11	4	2024-07-26 08:49:55.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
267	\\xb614e909a379698389ee676e4e4a6b2b655a266c1e5ad15db579026b1e68a1b7	2	2615	615	261	266	3	4	2024-07-26 08:49:56	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
268	\\xf78393fec7dbda9c38697358ee639871776045df434352d059bddf20d22c9fbe	2	2622	622	262	267	12	4	2024-07-26 08:49:57.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
269	\\xae77bb26298b09fbc77b383777fae9634ae7b9cbb996adb2db18b2e0511dac9d	2	2627	627	263	268	21	4	2024-07-26 08:49:58.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
270	\\x56beb13a3c43a8a89b9ad117010c7fa8ae7e9a0cb136c584e31be9b8238490ed	2	2641	641	264	269	18	4	2024-07-26 08:50:01.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
271	\\x57e8df1b512b209bc3bc7a135249a00c74c4eba70f0300a79f48ce24e6a5cdc3	2	2662	662	265	270	14	4	2024-07-26 08:50:05.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
272	\\x2286ec62e8bb156b01710475f281a6b5c5883ba257330e3a7417f5ed7b2c889e	2	2664	664	266	271	37	4	2024-07-26 08:50:05.8	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
273	\\x300fe142090985261e015694e7de909d5cc95dfd54e1ea15dddc2497063ec38d	2	2695	695	267	272	3	4	2024-07-26 08:50:12	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
274	\\xc854976ddeeafb2afb712373ce9e6737c786a28243f9d04281e46dff4b33739c	2	2699	699	268	273	35	4	2024-07-26 08:50:12.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
275	\\x46347703c83be96a947b50c071e4a9d02ac13aabda240440625e08eb2845bbd4	2	2736	736	269	274	3	4	2024-07-26 08:50:20.2	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
276	\\xb09d8de918552e9a9d28f718a7ad503e96a98132742f94d33bce0f8114033d33	2	2745	745	270	275	37	4	2024-07-26 08:50:22	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
277	\\x23c40f1e792854db8aa073f1e275b80db6dab947560f371657a4cca8725cd40c	2	2758	758	271	276	14	4	2024-07-26 08:50:24.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
278	\\x307fd76f03247946e004b9e12dedb7eeda7d27796c5fd228bf43a7ecfc65f14a	2	2781	781	272	277	11	4	2024-07-26 08:50:29.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
279	\\x78f546cb69a70b2a5db3e4730cc32237d815f8fc5f70e2cd6567fe8c76031906	2	2784	784	273	278	11	4	2024-07-26 08:50:29.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
280	\\x6e2813544ed0ef334da119955cc2d06529aabd1635e33327591586bcb707f24f	2	2785	785	274	279	3	4	2024-07-26 08:50:30	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
281	\\xf994e4c60f0a3a0bc82df1d39f4db27fbbb7a983643b4c32eaa9e88919f40813	2	2792	792	275	280	18	4	2024-07-26 08:50:31.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
282	\\x0c965722b8ca3ec48f936ff8c85faeb2589006c985f6d73154ce05a1ef61b9ec	2	2798	798	276	281	11	4	2024-07-26 08:50:32.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
283	\\xd3e55642083c1db3b7fc078abd595d9c7b5f781fb52a04889dd4563709f19010	2	2802	802	277	282	18	4	2024-07-26 08:50:33.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
284	\\xb0d0b193126198a28eac97cbcab17209efda3c8b24f54175a63781a25af737ab	2	2808	808	278	283	4	4	2024-07-26 08:50:34.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
285	\\xaa1aa49b196b7747ceeab65a72420b30e3d7c1fe6190910c5b1dfdfe73c81abd	2	2858	858	279	284	12	4	2024-07-26 08:50:44.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
286	\\x889d55f74ca43aee4e787bca708c96a3734cef7c1187733d775e9272783b1b79	2	2862	862	280	285	18	4	2024-07-26 08:50:45.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
287	\\xbddb22352896a7260e7d944bdb0f4284ff518e5ceda96252b58fcd05156ef4b0	2	2868	868	281	286	12	4	2024-07-26 08:50:46.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
288	\\xd91b974b541b4d74c7a04fee03ea283a10f4abdb465c5f4180602951f37413f9	2	2870	870	282	287	37	4	2024-07-26 08:50:47	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
289	\\x4940b7f279163c8a9277a1d18c7d44ea470a53ea17cb1e5d3cfe90b4f6d9438d	2	2874	874	283	288	3	4	2024-07-26 08:50:47.8	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
290	\\x35bab7075bdc598895649166654f38d25b3b3e7c47bae5823d66ed7b4435ab3c	2	2903	903	284	289	3	4	2024-07-26 08:50:53.6	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
291	\\xef3e27c1c5794a7ca795d7c66bf7987e7e05996935fc8d13ffab15a51b6fee0f	2	2908	908	285	290	12	4	2024-07-26 08:50:54.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
292	\\x7cec2f53aae8dfb30326b52b6880e86b49e7c5bbd9e8ed467ba8657274ce3e4a	2	2927	927	286	291	3	4	2024-07-26 08:50:58.4	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
293	\\xb8d96159c4fdb78e3193b2667d28087b3cb19bb0b587ab4a823add0d02caa363	2	2946	946	287	292	12	4	2024-07-26 08:51:02.2	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
294	\\xe9cfff67b123fb2902d495e1d44c2424e40b1e701b6fdc764d1edf02e72c2cb7	2	2948	948	288	293	18	4	2024-07-26 08:51:02.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
295	\\x9e02b1bf3ec24f9db3246ad6436d28f48e89632641bb736ef71aab2b3c262589	2	2976	976	289	294	10	4	2024-07-26 08:51:08.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
296	\\x4007a1883997d24e56bdf9c12a3fb41349f04caea3a6248003fb42325a80c4df	2	2978	978	290	295	4	4	2024-07-26 08:51:08.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
297	\\xb40f9cd50485c500abdd7a4c9744ece5f518e7429e6501a94dd5f4e6b80b18ea	2	2985	985	291	296	35	4	2024-07-26 08:51:10	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
298	\\x2a0b46bad06ce36e0496d05585910e4707ab8c31eb8b86048c3481f08f7f03f4	2	2993	993	292	297	11	4	2024-07-26 08:51:11.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
299	\\x49c0087604aa44df28c7ad88e27f7bd0adbd4fe83ea5b0ea4f5a855600cd6149	3	3005	5	293	298	14	4	2024-07-26 08:51:14	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
300	\\xf4652ac23668602c36409d9234e2c83051a204d706ad9743083a428e0edd912c	3	3018	18	294	299	4	4	2024-07-26 08:51:16.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
301	\\x37e8d12ab356d72d3fc6e4861e41bad442834a69c116cd273600ff1d4d158450	3	3028	28	295	300	14	4	2024-07-26 08:51:18.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
302	\\x7d30cb9ea2dc0bd0c76ca9c2aa49e38d69c6f8bb30ca7e8f5556f169fed4613a	3	3041	41	296	301	4	4	2024-07-26 08:51:21.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
303	\\x42106c9920f8a76a06b0b9a7bee58835b68143ced810758bab5286b34248f5d1	3	3074	74	297	302	21	4	2024-07-26 08:51:27.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
304	\\x0475038dc82a8c8738f7d9d858d38669617aff419e8a48e1464878cb09115a71	3	3077	77	298	303	10	4	2024-07-26 08:51:28.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
305	\\xb470bb3ec71021950bab0514f9b19bfd5453622f42e8021a51ef689852f5271c	3	3090	90	299	304	4	4	2024-07-26 08:51:31	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
306	\\xf09372a558f234dcec48a722c9851cbf54405828c7256240fe5e315e2a30e7f0	3	3098	98	300	305	3	4	2024-07-26 08:51:32.6	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
307	\\x98f222e60f4c1395551ed6b6c625faa12816da8fb7373d301e23856d7d54fefb	3	3117	117	301	306	3	300	2024-07-26 08:51:36.4	1	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
308	\\x2d7cb87bb65eaca62add5a9d733c3b99ecc9efe56c7ca237128e93654e1bfad7	3	3120	120	302	307	14	4	2024-07-26 08:51:37	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
309	\\x9ef8bcd478737bfe3d8410e72f99200d22f3b8e441ee97a5cc842f2efef588db	3	3122	122	303	308	13	431	2024-07-26 08:51:37.4	1	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
310	\\x75149761e5d1e43191281b3ccc27f6a669782eba4f06af45da0e54ba51403467	3	3126	126	304	309	13	4	2024-07-26 08:51:38.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
311	\\x1eda08f00736e3f913648ba01534fe44641a58167b2953de1897e16c8c1d1f8e	3	3129	129	305	310	14	410	2024-07-26 08:51:38.8	1	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
312	\\x9776bb0941352cb638464a7553f29d83eeca3ee124cddf07f964b291e5923f5c	3	3130	130	306	311	3	4	2024-07-26 08:51:39	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
313	\\xe7753d56164d239daf784afa56cba6c7412f1a38b6940c4318284aaae7c2fd43	3	3133	133	307	312	10	379	2024-07-26 08:51:39.6	1	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
314	\\xa0275cbfbc5a7e57ed4a02a768d5cb3bf63e2e6b3f23650e51d95cdee71c63e6	3	3135	135	308	313	3	4	2024-07-26 08:51:40	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
315	\\x8b261514448e445b015cf3674710ff65fef49846028f35689c244af7ded85f89	3	3137	137	309	314	21	412	2024-07-26 08:51:40.4	1	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
316	\\x06ee031188f843cbc2a2d3cbb2052a7f8b1380d9049ee06c93607d9392edf85e	3	3146	146	310	315	37	4	2024-07-26 08:51:42.2	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
317	\\xf9330b5712b803fe86eb5a1c9a46c508c9d17685ba93b02b5719f07e8ac60d36	3	3161	161	311	316	3	375	2024-07-26 08:51:45.2	1	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
318	\\x6aee3bb42ee31188ea56b90704af956ed6dd215e2bd2a46b81a71bc629cc32c9	3	3163	163	312	317	3	4	2024-07-26 08:51:45.6	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
319	\\x655a65f3220f277154298e0083c16e69dead00d72780daba95d1dece1b4c4e4c	3	3184	184	313	318	4	442	2024-07-26 08:51:49.8	1	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
320	\\x9f0d5a70e978fcb0541cd1fb2c720c6a180150019bc3fa40a927754c92d7ecb4	3	3187	187	314	319	21	4	2024-07-26 08:51:50.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
321	\\xa67c6b4b906f81e0f4e328e6eed0f887ee7ca0c8298b16346e17001b5c332192	3	3211	211	315	320	4	380	2024-07-26 08:51:55.2	1	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
322	\\x573d0b8c56a9191164668fa4f9e3e971551635ac22432444d06f8d1aabcebcd6	3	3214	214	316	321	13	4	2024-07-26 08:51:55.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
323	\\x49c91f981667cdedaae418c49dad54622d31e88756d68173411c308b37ef5dd7	3	3217	217	317	322	10	371	2024-07-26 08:51:56.4	1	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
324	\\x2d2733d518320eea275082f5c9ec7436393c153080f6a8f2bbcbd3715a59f8c3	3	3225	225	318	323	10	4	2024-07-26 08:51:58	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
325	\\xe1f2672dbcfed388d90a41814cc5cb36d8cf0a06caed83f4b0ef3aeb23cd4063	3	3246	246	319	324	21	380	2024-07-26 08:52:02.2	1	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
326	\\x7ac263dba630df8ee8be95f981f5a061a8888784675bd4de58558def00422a3f	3	3258	258	320	325	37	4	2024-07-26 08:52:04.6	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
327	\\xe64ee5402aba51605a0aa4a854b63a3efa3c8a43fc227a5be6c3ebbdfdd09397	3	3262	262	321	326	10	380	2024-07-26 08:52:05.4	1	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
328	\\x0af5222767f30aead1fbfc86c25646d6d8c05a81d519dfad7aa772d114071bbe	3	3275	275	322	327	3	4	2024-07-26 08:52:08	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
329	\\x9dd99f5d84e2aa7134861440412061a88230c00bccfff16e3358ebdc34b0b6a5	3	3284	284	323	328	18	380	2024-07-26 08:52:09.8	1	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
330	\\x0e72d770a7d198f6abdc14f64113c6c83dc6ebf3137ef8e77de01485359902f2	3	3288	288	324	329	35	4	2024-07-26 08:52:10.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
331	\\x7ed840c8be276dc106bc7daa61d896cdcdbeee378f7f6e578cd9975af3a1edcd	3	3292	292	325	330	21	407	2024-07-26 08:52:11.4	1	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
332	\\xdf4a538d1b5f5a959e4660ea6c340a041945e40d29869bf574c9cfa0f7affc9d	3	3317	317	326	331	12	4	2024-07-26 08:52:16.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
333	\\x7caa4701491243db360ae2b06ca882448f70bc71cc417ff9968658dbf0559f53	3	3344	344	327	332	37	380	2024-07-26 08:52:21.8	1	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
334	\\x1d6137947ea02b5d05ae3c433214b82a54cd56d42f72669d64a70b1f703bed8f	3	3346	346	328	333	13	4	2024-07-26 08:52:22.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
335	\\x0d3964820b231f4a08d416aac10a3da90767b415a76c87897fd062db7dff7b87	3	3349	349	329	334	12	380	2024-07-26 08:52:22.8	1	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
336	\\x4ebcf3522572bcb4b11e81590e82c5c0aaf4ce65e5fdf48158562a43ea0249f3	3	3357	357	330	335	13	4	2024-07-26 08:52:24.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
337	\\x7cc0929412e3adffa871bbd3ac005a3e6292a5ee3e8f4d8bc65c545504fe95dd	3	3368	368	331	336	3	437	2024-07-26 08:52:26.6	1	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
338	\\x4c339f18be2662011832f248484317256de3fca363bb25c62ef54c13fb1837b2	3	3384	384	332	337	21	4	2024-07-26 08:52:29.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
339	\\xe0adefbce363d81e6e872e1e02be442debaf497531f820743ba9b40bc061e965	3	3388	388	333	338	21	3344	2024-07-26 08:52:30.6	1	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
340	\\xc568fbc152bafa818d86e4b04257f1d7a65506463336395c7872a1e26c09b7fd	3	3391	391	334	339	35	4	2024-07-26 08:52:31.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
341	\\xb13e7713354e791f66d8b5272bd204887b6171dc2f8163aa7b083690eaffe6f6	3	3400	400	335	340	35	380	2024-07-26 08:52:33	1	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
342	\\xefb7fe65e8da3a864ae8853402c2dba5493afd6c5c459daeef7c5b1b1c4f100f	3	3404	404	336	341	4	4	2024-07-26 08:52:33.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
343	\\xa653bece77585594431129b8ab2d9372c3ad9ff5950cc34abf70bb04fbc7b9b0	3	3409	409	337	342	13	460	2024-07-26 08:52:34.8	1	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
344	\\xcb26dac5a2c4e3eefaaf379cc19afc7aa2dedfc7e404b6cc6f99b92b5c6c672e	3	3412	412	338	343	10	4	2024-07-26 08:52:35.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
345	\\xa29e253722d9e03285d2d181434d4e1b44d66b9d53a2371170a2dbc8ce8cf5fe	3	3425	425	339	344	11	375	2024-07-26 08:52:38	1	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
346	\\x079e0e516b6ed6bc493662a7032f3274dae8d8d91b514c5b851e2c808fbaf9c6	3	3429	429	340	345	37	4	2024-07-26 08:52:38.8	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
347	\\xdd11c13bac76cd2dbafaee5686d04fd6794ce3e80dff62514acda66add24c0e5	3	3444	444	341	346	4	294	2024-07-26 08:52:41.8	1	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
348	\\x5f1c9ef24d46868fb1b946a777923765a99bced2326b3fc4e64524236281b302	3	3446	446	342	347	4	4	2024-07-26 08:52:42.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
349	\\x807c4fefc5d344e7dec5ab18af1c63eb038cb336f7f7f60cd70e923710a6eb5b	3	3471	471	343	348	35	4	2024-07-26 08:52:47.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
351	\\x02e95a9e9906bfed6243c6ded04f4c76cfa20ab671ccf679e453e4f2de23c7ee	3	3483	483	344	349	10	4	2024-07-26 08:52:49.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
352	\\xe869b611f4c8df80c8102275ffc4bcc4eea0091d80b413901508b47389c05a68	3	3498	498	345	351	11	3850	2024-07-26 08:52:52.6	1	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
353	\\x5fa8ab79fc601c782a6024911463aa52a0cf7ef5884cdcdc5dea649c932aaa62	3	3509	509	346	352	3	4	2024-07-26 08:52:54.8	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
354	\\x8eebe3be3d09aee1ee4b5386211b4c86ef29b0be6a061e693820baa02270b169	3	3511	511	347	353	10	4	2024-07-26 08:52:55.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
355	\\x5f171d5231abeed9fe4637fca6e1e16e6826504144fd6170bdb6c07ef4e82037	3	3514	514	348	354	18	4	2024-07-26 08:52:55.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
356	\\x53cad4c755b8bfbe91dfa81c94f9ed194c22a82f5d856331648a6f3fb47f1ab5	3	3523	523	349	355	12	2398	2024-07-26 08:52:57.6	1	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
357	\\xce1137d466cb65f9ba7b841617d3edb6f77bdd781b6eaf9d38a09f9a188b52b4	3	3563	563	350	356	4	4	2024-07-26 08:53:05.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
358	\\xe88037899d6603dea21e874c70551aa5522eaa0df506cf9dec387231f0899748	3	3608	608	351	357	11	4	2024-07-26 08:53:14.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
359	\\x16aab4c83ec0a5b662ccc162b0731de2cf7b2afe9fff9a2102593e7e8884d2ae	3	3617	617	352	358	4	4	2024-07-26 08:53:16.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
360	\\x7cec9ef27a4f57221196aa36909b0b83f1318bdcadcee45649909efa442e9239	3	3626	626	353	359	35	1051	2024-07-26 08:53:18.2	1	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
361	\\x6e738fd8dd46664c6b065b5b142e0088953b37d0c3f5022653c8db8e6a015373	3	3634	634	354	360	13	4	2024-07-26 08:53:19.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
362	\\x141c85391a77e1a6136797762b5c4ddff0792330283ffdd60280e2e07b576d95	3	3640	640	355	361	35	4	2024-07-26 08:53:21	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
363	\\x8718be1c9b1f00516f76b244f326455710102ba64afe239a153be336b7d7fe9a	3	3652	652	356	362	10	4	2024-07-26 08:53:23.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
364	\\x9c3345e20d925aac68b6654f37f1cc00a924abc4e6d7424e0226e0952111cb3b	3	3661	661	357	363	21	294	2024-07-26 08:53:25.2	1	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
365	\\xd45e8757c202ba6c3939603bff87b0f14522f04a8a56c93dc20f608daf26a981	3	3685	685	358	364	13	692	2024-07-26 08:53:30	1	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
367	\\x9bf412dfbde70f925a016b2c1f57127f0293bc5d76bd4775e9c2a32a4e28c1d9	3	3692	692	359	365	3	563	2024-07-26 08:53:31.4	1	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
368	\\x1d082e65defc6a21157b2c425bc4fd39b94ae8c4ca09787a610c05c1e2a4e4a9	3	3709	709	360	367	11	613	2024-07-26 08:53:34.8	1	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
369	\\xa1e377913564ec8511d168f02d426e153bb2346cecafbe0f52f919fb2ba84507	3	3711	711	361	368	13	4	2024-07-26 08:53:35.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
370	\\xecc76a817af650df8eba63da365fcfb7c0def3c528a6e248a44ff72c8e7d042b	3	3720	720	362	369	21	366	2024-07-26 08:53:37	1	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
371	\\x63d94ababb7cc557ddb803d3cded8c8d04567a684acd2ca68daa29d09c82d4ce	3	3725	725	363	370	11	4	2024-07-26 08:53:38	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
372	\\x7956a317b0e3f7d97f427828e2f7bb1d08a67f8bde2aea57ae0ebe1336b9419a	3	3739	739	364	371	14	4	2024-07-26 08:53:40.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
373	\\xeef5695b1acfcb35a8bdac49ac864ccc6bd3bf8154cf880827aff0038f979e5e	3	3744	744	365	372	35	4	2024-07-26 08:53:41.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
374	\\x9763a2000098cf29e2dc2c8d258352ea24f9f2c4948b8cb5769f6a64cf11ea29	3	3748	748	366	373	21	4	2024-07-26 08:53:42.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
375	\\xb8ecc5693efef376c6f0a2c7fbbbc747ef900fe99e70416fccd34e5fff39cea9	3	3757	757	367	374	4	567	2024-07-26 08:53:44.4	1	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
376	\\xd3d66f3919ec1fa2286c0598f874e38874a18abcce4c1298622a1c2cff452f29	3	3761	761	368	375	14	4	2024-07-26 08:53:45.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
377	\\xb4f7d69891f451a1fcedfde76f6ab94e16930167ef07c54407a1924838530e11	3	3768	768	369	376	12	4	2024-07-26 08:53:46.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
378	\\xb78853480b322b47f4425d2eac97052317ca9e2b3d7eda483a1469ccbffd5466	3	3772	772	370	377	11	4	2024-07-26 08:53:47.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
379	\\xf5af1a146611b8308a0293590eb74fd95d72baa89f9d20a5c1d26a160dcbf73a	3	3813	813	371	378	14	4	2024-07-26 08:53:55.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
380	\\x3f1dc9063ff72b5a203347bd4eac369d985a7833e3bef639dd54385b718d13ea	3	3815	815	372	379	11	4	2024-07-26 08:53:56	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
381	\\xb4dfe99db208e8999ff01de1742da2c2beeaeb39bedf2db365b1b563c420ec08	3	3831	831	373	380	35	4	2024-07-26 08:53:59.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
382	\\x7b098cd848ed49a4c7b26f8e0f4e4fc5f43c85dc60beb37a90fc9c1dfde41823	3	3850	850	374	381	10	4	2024-07-26 08:54:03	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
383	\\xc8b185522891e0ad83d4f083ec0d4fb7cab9498e6ceab17d8d6c4a6d1261eae9	3	3871	871	375	382	35	4	2024-07-26 08:54:07.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
384	\\xdbf228b8b60047b4a99ee80859bd6972276a3414f21a9f373085e000745290be	3	3883	883	376	383	3	4	2024-07-26 08:54:09.6	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
385	\\x3325ffc3d17245cc7367c97a0182f503557cb6dfc435ee94751db19e79e8c7a0	3	3907	907	377	384	10	4	2024-07-26 08:54:14.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
386	\\x55cb5c9c0c4aae42cef7310ced38beaa1212c54a63584b6d72bc3d00d0a2e7e2	3	3912	912	378	385	21	4	2024-07-26 08:54:15.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
387	\\xf818ba3165bcc7cd17a53da1f96ab991f53bfb4afcc67c9947b95350f7b921d4	3	3919	919	379	386	13	4	2024-07-26 08:54:16.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
388	\\x1a77397a60474023ffc86198863683a51d3f4c8c60502d762f61708f8fe81ad0	3	3945	945	380	387	35	4	2024-07-26 08:54:22	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
389	\\x859c12524f913cd0772adb5c16e24b61c30f7cbdb0a40c26abc4dde8b9557ffc	3	3948	948	381	388	3	4	2024-07-26 08:54:22.6	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
390	\\xe9de0ee1a282a13eaa1066bbf26e5afacc973bbd2aa5e6800ee0b8a269580fc0	3	3951	951	382	389	11	4	2024-07-26 08:54:23.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
391	\\x4ebac829efe76831a54073a02f3db40c29e31d97fbb7bbbdcede5c1c36fbf439	3	3964	964	383	390	11	4	2024-07-26 08:54:25.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
392	\\x5582dd1e7c4fd18013a0fa569093fa4abaa2f1a160d31f9a3346f461976799cd	3	3967	967	384	391	12	4	2024-07-26 08:54:26.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
393	\\xe69bf0939cfa7ca89b895d9ded1a6ec0f7e88eeb4bf4f99586c0bf6eb100a95c	3	3970	970	385	392	10	4	2024-07-26 08:54:27	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
394	\\x1c721de1b09d842a75fd915f39220a1f61ce56fa4bc4491b72b993ff8b1733d7	3	3983	983	386	393	10	4	2024-07-26 08:54:29.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
395	\\x4a3a7865cccf618326fa0b8d8662528f4a107066e0855941576798812b18c903	3	3998	998	387	394	21	4	2024-07-26 08:54:32.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
396	\\x6b70efc864a2afe69327a6561abafc8e82deb124cd40f5ff8c947654453d78f4	4	4001	1	388	395	3	4	2024-07-26 08:54:33.2	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
397	\\x5e98fe32153bd0e5eeeafedc738dbb5c660463a88d33bfe17977251a338af839	4	4012	12	389	396	35	4	2024-07-26 08:54:35.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
398	\\x05af50496de2ec38e074fdfc642cbb366df0c2f2d191a9d1053769f8f9efd439	4	4017	17	390	397	13	4	2024-07-26 08:54:36.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
399	\\xb4afdbe7488c64a72a42fe8133a356cf36a84670c1383033c108069712650bb7	4	4022	22	391	398	14	4	2024-07-26 08:54:37.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
400	\\xcf706af130717c87b65de3c20ff14e8f625d902a8c9e97ad17069248a53df5d1	4	4029	29	392	399	11	4	2024-07-26 08:54:38.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
401	\\xfbb90a2d8bfd5ba37cd008e0766767a2c9b46ef9f1efdc5111f984e4ecfd0700	4	4048	48	393	400	14	4	2024-07-26 08:54:42.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
402	\\xfd3ad96e2894deeca07a5cf433c62c4afd3bd883a5bcd3662436ed75847cbd41	4	4052	52	394	401	4	4	2024-07-26 08:54:43.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
403	\\x8dd0e24e8fbabd741a823f68691b86cec1132cbef03aaf1eaad0cc2ab896f01f	4	4063	63	395	402	13	4	2024-07-26 08:54:45.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
404	\\x205798b2de422043b8895b804d3d985323d6fb4abe68152402d0fd92fc44852e	4	4065	65	396	403	37	4	2024-07-26 08:54:46	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
405	\\xf29e6777098286ce8b939594cb43fbdab9fdbad7faa8dd52780263dc490f5522	4	4080	80	397	404	37	4	2024-07-26 08:54:49	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
406	\\xd515080075f263c1898eeafeb521ab04ffc417fb433d7dc5a8e86e5c97979e2f	4	4086	86	398	405	11	4	2024-07-26 08:54:50.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
407	\\x2438893d6dfded6f62ba0d4d817974d2716a6e37e5fda9673041b1a3f5b993bf	4	4090	90	399	406	11	4	2024-07-26 08:54:51	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
408	\\x63cdf661bfea3310fda8c31d9ecb29e4ac6410e5ec2bb80fb6d1eda613c16312	4	4091	91	400	407	18	4	2024-07-26 08:54:51.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
409	\\x78c36c2ebcacb251e012e86155afff033743aac5ff925f4d01a160093e317b95	4	4102	102	401	408	37	4	2024-07-26 08:54:53.4	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
410	\\x247f5a7667c5840fa6b6b410afc181315d37e5da3c25dd643e25a168f4f6d47a	4	4109	109	402	409	14	4	2024-07-26 08:54:54.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
411	\\x5c0b52924e215c30d2698dd978b2a267b3f6aeb713dd83a7d40a922afd36cc96	4	4149	149	403	410	13	4	2024-07-26 08:55:02.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
412	\\xdb4db21a78ee71c6a7a801d933640bc766a451107df287fd14315d6f16a37da6	4	4150	150	404	411	11	4	2024-07-26 08:55:03	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
413	\\x49ecdd5e4e3df9592e44424856a91ef9d81ed80ec50e6b5386db77e74817b9ff	4	4151	151	405	412	10	4	2024-07-26 08:55:03.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
414	\\xaef95883a3024023f6e4c89477f4b37f5482c37ef8ab0124607887aa15b9d451	4	4156	156	406	413	35	4	2024-07-26 08:55:04.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
415	\\x8b1ac63ebc77dd220a17e7543088538a89bbd7f357b9c40b1ecf3dc12e8b66c6	4	4161	161	407	414	35	4	2024-07-26 08:55:05.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
416	\\x7e45b3116ac1a7fda905d3b8888a302df1cdaa3f8389b4c50c8e278e1504f75b	4	4175	175	408	415	35	4	2024-07-26 08:55:08	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
417	\\x8ce255262c1185beea2a7544b871392816da65039bed431400c2f71e4253c7c2	4	4182	182	409	416	37	4	2024-07-26 08:55:09.4	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
418	\\xa8a2d93d7593656633ca62779ac3768a3796e4375bf5bb9cbf3681e934aecaca	4	4193	193	410	417	18	4	2024-07-26 08:55:11.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
419	\\xe92232fce77bcdcd7bfdeea3a90cb3e86b63929ff022696b5f533efcf932fcac	4	4203	203	411	418	14	4	2024-07-26 08:55:13.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
420	\\x8ef573a7b46844d919d65958df2e10e2cee2edc487d2c917421fd7eb2ce706e4	4	4209	209	412	419	21	4	2024-07-26 08:55:14.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
421	\\x190435d00a6e152e2e28c72fecbefa49af26ce322f45d352695ddfa5e3051d9b	4	4234	234	413	420	13	4	2024-07-26 08:55:19.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
422	\\x744964e9f734704c11671804e44b88a007122bf0fe0612f84137ee86f1ebbd0f	4	4241	241	414	421	13	4	2024-07-26 08:55:21.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
423	\\x0da040a358edd1c60c53aa6aeaab4e65933965f422c43e86f1fd7d28006840f6	4	4245	245	415	422	21	4	2024-07-26 08:55:22	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
424	\\x54163f79acae52dc4abbfe1e511e3cfbabdcbabdde9251fb14f554192f0b6b74	4	4259	259	416	423	14	4	2024-07-26 08:55:24.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
425	\\x11355361aef08a386b094d30f11184bd6c8ea7ca0dc568e6f115b8c486cf0d5d	4	4262	262	417	424	12	4	2024-07-26 08:55:25.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
426	\\xc3a4b4305dbcf861a6f94a235973a25d2a788f01c7d6c596b092310d01269356	4	4263	263	418	425	11	4	2024-07-26 08:55:25.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
427	\\xd036be10bba37780ed9a6e552465cd799e058ebbe7591afe213f8b3a068818b8	4	4282	282	419	426	12	4	2024-07-26 08:55:29.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
428	\\xc15e40d50ed7eee417a93ebfde93457b5654efa9463de74d071dfe1393d20484	4	4283	283	420	427	10	4	2024-07-26 08:55:29.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
429	\\xd2dc1f3fe21fc5487b0d4aab4a082afbd2eb2b6d75f99bd8377108e9eafca2ad	4	4295	295	421	428	13	4	2024-07-26 08:55:32	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
430	\\x02138088722d85d5fca7ed403e468db83be495cc9d0b002e66d17c5c421830b9	4	4303	303	422	429	18	4	2024-07-26 08:55:33.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
431	\\x3a956c9f5ad98e432136b17406871df5602598f023b9f34a54cf8695ceb4c653	4	4313	313	423	430	14	4	2024-07-26 08:55:35.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
432	\\x8ff9b7ecae79a2a6c4486e286a336882acad348bc1e0ec12fceb232407658cfa	4	4315	315	424	431	37	4	2024-07-26 08:55:36	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
433	\\x68375f74f9ff19db6e68de6382fdbabb0b9327f0a93c2b7d0c28007a847c18ed	4	4319	319	425	432	13	4	2024-07-26 08:55:36.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
434	\\xcde01d891379d194e9f6312974cb10d1de1733216fbd11ba3ac54ed7a7c460a1	4	4329	329	426	433	14	4	2024-07-26 08:55:38.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
435	\\xe19928b8db0f746cefbd172a19eeac0c86a6257e2653c21ca8e5bfed0cb7c19a	4	4333	333	427	434	13	4	2024-07-26 08:55:39.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
436	\\xff2ef2ee897dd460257bcc846ecaf1dd934cfa91e0b6f0b9f710f0f8bab71993	4	4356	356	428	435	10	4	2024-07-26 08:55:44.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
437	\\x973d08267541feb9c67aae8a2165b83b031227df074410c8ba63d72decc19305	4	4361	361	429	436	4	4	2024-07-26 08:55:45.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
438	\\x52d2d4c0170f20eafd2951808dd14d51bab25c6258eea2426820d18b5fb5a941	4	4363	363	430	437	21	4	2024-07-26 08:55:45.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
439	\\xefba0ce2e3794e9d9bec3cdaca6ba21c923c80520d75a3ac023a845d5f523281	4	4373	373	431	438	4	4	2024-07-26 08:55:47.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
440	\\x2d77704ce8a52fb2136a6b509520b83bf40b30bc1416433b54728db78407ee91	4	4383	383	432	439	35	4	2024-07-26 08:55:49.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
441	\\xe3a6a473d76d32b607cc98ec3b89b2f96e1129ce1ce6a5138bc28152c4bc15d8	4	4402	402	433	440	12	4	2024-07-26 08:55:53.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
442	\\xaaab1d9a549069f19f1fd255febb4efa95b14d745159f1f397d73b890a794144	4	4417	417	434	441	21	4	2024-07-26 08:55:56.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
444	\\xcab9d7c413395f0c07a59ccafe2dd3bad44d34669fa98cfa0d5989b1667c120a	4	4418	418	435	442	21	4	2024-07-26 08:55:56.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
445	\\x9776d1afb3d9cbe6a341d531297246507813c314111211909c7c19908faf6ccc	4	4431	431	436	444	13	4	2024-07-26 08:55:59.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
446	\\xfb36f7ec3621a28e5b2672c8ef3ea323b967e36d81ff077fe0b0f543aeaf593a	4	4438	438	437	445	18	4	2024-07-26 08:56:00.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
447	\\xcc16b71f9e07b7b5704663365481ebeba3e889467f6fdcbd6c2bcb3ea0292a95	4	4474	474	438	446	13	4	2024-07-26 08:56:07.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
448	\\x0ffbda0676f40c4aa5e0363d5972cc02bc1a9bf70cf99cf20de5baa8d2838eaa	4	4484	484	439	447	11	4	2024-07-26 08:56:09.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
449	\\x73ddcc8a2d87587f1067160662a391de2e0b2a5cca761d867900c9f3df2bea85	4	4486	486	440	448	18	4	2024-07-26 08:56:10.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
450	\\x873abea73d4959f6b181be1d3c6012fe3e36eddfaf0a39ab31fac5e20e218e3a	4	4492	492	441	449	3	4	2024-07-26 08:56:11.4	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
451	\\x062bf0894b3d8509ce47ece577aa04c55ccbce4e3e0259ae5c619a8416f89e98	4	4504	504	442	450	3	4	2024-07-26 08:56:13.8	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
452	\\x5f6159969d9969940d3554670620471d4f8f63bd45125e3eebf1fcf362a40968	4	4509	509	443	451	4	4	2024-07-26 08:56:14.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
453	\\xf626c17fa766bf250897cfeb6e58b9f6eeb6854bc08258496bbc88968eaf0635	4	4520	520	444	452	37	4	2024-07-26 08:56:17	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
454	\\xabc6774b3f0cc9d951150a0a4f2242435b8c3125db6c2ae0c1c9475f6d500491	4	4537	537	445	453	18	4	2024-07-26 08:56:20.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
455	\\xcb837819407849954cff93fe31a69653019b99013f6c32161fd776cb6771503d	4	4546	546	446	454	11	4	2024-07-26 08:56:22.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
456	\\x63daf816687ad7325be7eddcd719e684e9c1f61aa9e19efae43c5af45eb5e828	4	4569	569	447	455	12	4	2024-07-26 08:56:26.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
457	\\xd529932d5c25b671dca4a9ed7f898325f68b789ffb2ce49491368042fcb021de	4	4571	571	448	456	14	4	2024-07-26 08:56:27.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
458	\\x497b387196c3bf52a6b43219417a88fcfaf8f4bbae0d908db0f1df3fd8ae5efc	4	4584	584	449	457	21	4	2024-07-26 08:56:29.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
459	\\xe49e271c749df3ee7fe522fdf50b7f00d3eca54025b21281e73748f811b69164	4	4595	595	450	458	11	4	2024-07-26 08:56:32	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
460	\\xbdc443611d18a227e6f922097a24657a82bfb379ebc9d92f2e7d7680e50d19e0	4	4601	601	451	459	13	4	2024-07-26 08:56:33.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
461	\\x0d4735ad68aca6c620d3016cbfb3ac857358e8d6c8e96139ed91747c365a3a20	4	4604	604	452	460	18	4	2024-07-26 08:56:33.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
462	\\x677e7e446cffed4745bd65f3541050800f4cfd52e3cc6517796d7636f1b83bf0	4	4615	615	453	461	11	4	2024-07-26 08:56:36	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
463	\\xef1514d5ac41e69bb017eef8c610bbe42edb45ce6660a2e5262f2ce737a9be2c	4	4622	622	454	462	10	4	2024-07-26 08:56:37.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
464	\\xacad00ef7fc6d4dfe21c9545cdf0436e01ee4440c9750b34977e671780ccd837	4	4642	642	455	463	13	4	2024-07-26 08:56:41.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
465	\\x35b59c1918782fa4a566332224eff2f7388bc45e306d38472a41b63718733ef4	4	4648	648	456	464	35	4	2024-07-26 08:56:42.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
466	\\xa0bbe5dee9c3765c371a3f29073468b47abc387c5448ee4d3468650eb61bf19d	4	4660	660	457	465	10	4	2024-07-26 08:56:45	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
467	\\x6741b09d5ccd04de535a9c883ca42f203e7e9571c8d81bb7b55b43306fc8e68e	4	4661	661	458	466	11	4	2024-07-26 08:56:45.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
469	\\x39f579851e2607db85c047a479363417f20f935a1983fe69ab9d8736ae3b3ba4	4	4669	669	459	467	13	4	2024-07-26 08:56:46.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
470	\\xa25ad1fd5410ecdc46ad7e80427c2628795abddf8a3699cd69a72447222cd457	4	4676	676	460	469	10	4	2024-07-26 08:56:48.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
471	\\x77ecea754fd1c5247289ef1143708ee60b1585c938bf0d3f01627082075954a8	4	4695	695	461	470	18	4	2024-07-26 08:56:52	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
472	\\xcb0a5050fac1945a3280b2ef596ff3a7f1e8bb0541fee0de285b2d6a322bf33a	4	4707	707	462	471	13	4	2024-07-26 08:56:54.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
473	\\x80e809284a5d96f8a6b41859c3209fbf63b1fc5fcd1fb0bf8862867bc469d57a	4	4708	708	463	472	37	4	2024-07-26 08:56:54.6	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
474	\\x923ef9ddf9a36bb0d68ee50589707bb31991445b06a42c62436135cbfe542496	4	4715	715	464	473	3	4	2024-07-26 08:56:56	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
475	\\xcbafcf90a7ee025c28ed5831010b085e4729b6e91ef86584654c397520c5ddcb	4	4718	718	465	474	37	4	2024-07-26 08:56:56.6	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
476	\\xcedba3941b28392d51d871819ce549ba622f32213bcc21a691e2786f2b080a86	4	4722	722	466	475	11	4	2024-07-26 08:56:57.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
477	\\x10ba9bea01eabf83c9c2db7619e27e4a75dcbc73aec698e71ff826b5412bd07e	4	4723	723	467	476	21	4	2024-07-26 08:56:57.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
478	\\xc474c67ab811cf27fa3a6422d23c19f2417373b968e020ed540ebb7d8f633cc7	4	4736	736	468	477	14	4	2024-07-26 08:57:00.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
479	\\xd29b3f641e3b5efc38de30f53b16acc632c46e01884aba7ea2d1e18c6e9845a5	4	4743	743	469	478	14	4	2024-07-26 08:57:01.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
480	\\xfc6320de6ee06ba6378741929ea5d38dbf91b23590caf6abc216668507dc9a86	4	4744	744	470	479	21	4	2024-07-26 08:57:01.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
481	\\xd28b02b19f8f6bae0f609d38fb4a81a4c47285e0d84fa08c5311646bb9f4086f	4	4745	745	471	480	13	4	2024-07-26 08:57:02	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
482	\\xc6d39c0347fdbd96f07df27721ad5a9cd15c869f26199c1310d715355c7ffe17	4	4748	748	472	481	21	4	2024-07-26 08:57:02.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
483	\\x240055d236b8348cc4734faeca666c4e6d0b495c0193c1475571feb8b4116fb5	4	4757	757	473	482	18	4	2024-07-26 08:57:04.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
484	\\xe135a0461b54ab9943c48be067b1ea978fe519ee47152aaaf39e13ee61942dac	4	4764	764	474	483	14	4	2024-07-26 08:57:05.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
485	\\x0771e6a2044c5f592ad0a431858bff741822e53800501d6e4ef0fa023963ad07	4	4773	773	475	484	12	4	2024-07-26 08:57:07.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
486	\\x802667e398de5fddf0938a462bda2c93667c7cdfd7c80768314854cd4c9f284e	4	4803	803	476	485	37	4	2024-07-26 08:57:13.6	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
487	\\x78ed56089080d252474d76bf3b4de0c0fb18d73fd8a15076fe125ca1b59bcfbb	4	4804	804	477	486	18	4	2024-07-26 08:57:13.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
488	\\xdecd1b0a13262acf002b26def9a563394acd535e5d925e7adac4da86ebb789a4	4	4808	808	478	487	21	4	2024-07-26 08:57:14.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
489	\\x0ea56acfc021360d1c65d1b795ed03a984822b10e8f8f7384c3d2b6b49d80860	4	4828	828	479	488	3	4	2024-07-26 08:57:18.6	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
490	\\xfea2c6fd17f68a252a19115d76bd5c56f8af2a9794899cf613d52381b3474bb8	4	4832	832	480	489	21	4	2024-07-26 08:57:19.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
491	\\x5221410006c9683eb0aaec0fd68e8cec345df2d120df2a6d8b2342e29daf3beb	4	4838	838	481	490	3	4	2024-07-26 08:57:20.6	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
492	\\xae25ca44c8cf4fba8d4d067719e7bb4ea4de50fdce4760e57f725cde4275279b	4	4841	841	482	491	14	4	2024-07-26 08:57:21.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
493	\\x2ad99d4a1562273f87d7f1ff3f2d6613298f6ca708ced1d07df4bc3ee8e7b508	4	4847	847	483	492	37	4	2024-07-26 08:57:22.4	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
494	\\xab5fd5f041308a8b369c6e8acb64fff0dfd423f111b918f58d2fb2b0d6facba2	4	4852	852	484	493	37	4	2024-07-26 08:57:23.4	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
495	\\x0ce794765b3e5ed00fdf79eef49cbc8412a22fd30ed4e7f4ba122b99d2e1dafc	4	4864	864	485	494	13	4	2024-07-26 08:57:25.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
496	\\x89e4906e6598aba7fae70b2c37ed4ca1625c657fe54a5c55570f68d9e9e1cbc0	4	4869	869	486	495	37	4	2024-07-26 08:57:26.8	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
497	\\xeb46f64ca9b57dc8741e45a7c71264c52bcc16c457d65dfad1ad8987250414be	4	4874	874	487	496	14	4	2024-07-26 08:57:27.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
498	\\x9f247ad9bc79bb1b10d8b7ef4cd1acb70ede5613a392b60985a1a0b5bc044f84	4	4879	879	488	497	4	4	2024-07-26 08:57:28.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
500	\\x085b377392169ad70370248ef9fc5e7751d2554989477356ccfa339cdedbf2ba	4	4880	880	489	498	37	4	2024-07-26 08:57:29	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
501	\\x328f9fb6ff10cd1b35cceae09a5b1c6fc4f531c6a6fcde663e5134c7296eeb48	4	4890	890	490	500	35	4	2024-07-26 08:57:31	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
502	\\xbaaa09eb7ba084df4e7ad98aa242bbef8902cd80c3a1e94b01a0317f4687bb74	4	4894	894	491	501	35	4	2024-07-26 08:57:31.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
503	\\x39fe228fb9d874f9bdc8477426d9f5155bfa58f8e99ba26ffc8ce6e2b8999ad2	4	4902	902	492	502	37	4	2024-07-26 08:57:33.4	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
504	\\xdca46aaa9d0358693c12465b6ca6e38c81096a63929dd0cd584cf8e206c65e59	4	4921	921	493	503	21	4	2024-07-26 08:57:37.2	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
505	\\x8592049ac245f416d3926ed6b7780235e496a002d53cffb0402119f51d2f7943	4	4940	940	494	504	35	4	2024-07-26 08:57:41	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
506	\\x7c028720bd6329a8dd230e7afa4b46f2ccc2bad449e6cfa8bc38307d890c43c9	4	4943	943	495	505	12	4	2024-07-26 08:57:41.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
507	\\xecc6f8f5f1cd7ce4e2c26a02285048261831115ca988e8ba659f5741afdccc95	4	4955	955	496	506	3	4	2024-07-26 08:57:44	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
508	\\xffb7752edcaef1e61c8427afd1d7959a8877ae32a4167bd0ea0b40089c9086af	4	4962	962	497	507	11	4	2024-07-26 08:57:45.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
509	\\x0ec8604c8740a73151f114da0c9523be22b75d82a698f4b8aac1de569d264985	4	4972	972	498	508	4	4	2024-07-26 08:57:47.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
510	\\x63a8c7e4a84f512e4ed9d3e0404c282d3d988a3ce35228b3ba64dda070776c9c	4	4997	997	499	509	18	4	2024-07-26 08:57:52.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
511	\\x62a0f84a92c951322b71d3ede43986382fdb0f5ca8bea76e9aa763971b81b257	5	5006	6	500	510	11	4	2024-07-26 08:57:54.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
512	\\x83103f1b8b459ba98f4d74847cdf042c4a088d34c0259017ef971ea6c28dd841	5	5012	12	501	511	3	11714	2024-07-26 08:57:55.4	39	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
513	\\x1ea4ad2939b6a0d845346c86b6ca7bb03a2ff596350bd7bcdba19bda8f65b386	5	5021	21	502	512	14	18785	2024-07-26 08:57:57.2	61	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
514	\\x8cfa484a6a8c5ac4e10be08b9a0497dea31e7be26049a816972f42a8055b6014	5	5023	23	503	513	21	4	2024-07-26 08:57:57.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
515	\\x4aebb4609d0d7f87146eb20e43343564e58a6c0dc966c47c706b5a4a52caf736	5	5024	24	504	514	10	4	2024-07-26 08:57:57.8	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
516	\\x3d32027b1559f0547e50101cc0b1e0f3ebf6dba18aba8fa53f4a0ae107673040	5	5026	26	505	515	13	4	2024-07-26 08:57:58.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
517	\\xaeb744909c26257edda2a6032bfb5b85212529ec685a2481ab4d67c3a1363623	5	5049	49	506	516	37	4	2024-07-26 08:58:02.8	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
518	\\x8fce72d0600424d3dd3c5d5e7d10c462bdc7a029851060a3b7e3afc7e8fde581	5	5054	54	507	517	11	4	2024-07-26 08:58:03.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
519	\\x8cd0daabf773f66dbbe710c0da8aa4ff449c8ef6c83cb4cb6483758d71e95e93	5	5059	59	508	518	21	4	2024-07-26 08:58:04.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
520	\\x66b267fb9bc510ec317134d5bd87d5b784e6e158b5b3174362d078c612d99e5b	5	5062	62	509	519	10	4	2024-07-26 08:58:05.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
522	\\xe4414a358438c6b813488a19c7699fd5e561d5e63e33091eb7c2c31cd3440c1d	5	5076	76	510	520	18	4	2024-07-26 08:58:08.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
523	\\x6c6ff32220ad3f976ae23bb5839cf8e6642de00f4c61efcf3bf8cdaeecf92209	5	5090	90	511	522	10	4	2024-07-26 08:58:11	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
524	\\x61f6987451aa85abc75a75d36f1e2c6ff4274026f710297b18e0cb7a12726515	5	5095	95	512	523	37	4	2024-07-26 08:58:12	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
525	\\x4623173ea92608e74ac5e2f86c5d622ffcef8499ebf73c1fd0bd9d450ff44211	5	5119	119	513	524	14	4	2024-07-26 08:58:16.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
526	\\x3eef4a41a6beea0a6265d4c5ce9b706d87e02b4860def05d0722111532e8307d	5	5122	122	514	525	37	4	2024-07-26 08:58:17.4	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
527	\\x45f0584289e6bb8789ed863ca0c02eb001578956d5d992c724a01d144321ba16	5	5124	124	515	526	21	4	2024-07-26 08:58:17.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
528	\\x75168cd78d53f1b689e0d237f8203db404007ee4b556df825a7d9b86407b596a	5	5127	127	516	527	11	4	2024-07-26 08:58:18.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
529	\\x2a957c3a589e13fe4cffa55bae44deb2a537a88593fc83fd8131dd3c51b28a2e	5	5134	134	517	528	11	4	2024-07-26 08:58:19.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
530	\\xf7cfc683cb342cbb69d3bb7f0134cb649cd71e9325138575011c285965f07f5c	5	5139	139	518	529	11	4	2024-07-26 08:58:20.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
531	\\xdccdb7012a49453096b40faa66da35f4f8a575a93de8aa59c593d159f30db07f	5	5149	149	519	530	14	4	2024-07-26 08:58:22.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
532	\\xdc5f361e949f92864f3471ecb9d4dcd39ac77652991d3ad0052b02bf7564291b	5	5156	156	520	531	37	4	2024-07-26 08:58:24.2	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
533	\\x1313d55f9c744d70ae10fb2b333093cde0a45d84cacc8fd42314c744fd17726e	5	5161	161	521	532	13	4	2024-07-26 08:58:25.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
534	\\xabd488db3d7a0d80bbe79b2917770ab98fe4a74c6dc31f89d9030c6871249acd	5	5170	170	522	533	13	4	2024-07-26 08:58:27	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
535	\\x7cd65224e529fbb39326037e75ac4d6f37566d6f1baedb8866f600d99711bf09	5	5171	171	523	534	13	4	2024-07-26 08:58:27.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
536	\\xa10092761d84489bf2d76fc1afbaaea21ce909604c37befc5cbd55c5acf0bb8f	5	5177	177	524	535	37	4	2024-07-26 08:58:28.4	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
537	\\x85c3feeba2138d2b094c40622efe0bdc7604efc251ecd2e8518c9d1a555ee71e	5	5180	180	525	536	18	4	2024-07-26 08:58:29	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
538	\\x76cb15dc176f06a1b33625cab893b98ebaaba92f412923e9064f1b40be8c5ccc	5	5198	198	526	537	35	4	2024-07-26 08:58:32.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
539	\\xaaee0f0447ea9dc642a3fd5952c1ac84b438b3011a2d6c03e553a1484d70c91e	5	5217	217	527	538	3	4	2024-07-26 08:58:36.4	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
540	\\x48961046c6e9a39583c2db02045d8b203400485b8a6e01aeb8a6bd25398f9cb0	5	5221	221	528	539	14	4	2024-07-26 08:58:37.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
541	\\x6e93cde1241dfa9a950222dbfce527ca126bb4ee5ff32b3b8daf835d8b495f6e	5	5224	224	529	540	37	4	2024-07-26 08:58:37.8	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
542	\\x5c5283da1e69b0d2ee9d7131dd4d411ce9e07099100c825461f7bc35b2129659	5	5271	271	530	541	21	4	2024-07-26 08:58:47.2	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
543	\\x3c91aebf8ebaac8f46cdf50df945d32071d57a3560aeef00b1e94889c87ceaef	5	5286	286	531	542	10	4	2024-07-26 08:58:50.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
544	\\x1bede9b32faf0da41b1fffae786d949ee48996ef8fe64ed0c88d484817373259	5	5301	301	532	543	4	4	2024-07-26 08:58:53.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
545	\\xdd0521863ddab8d69936a2b985c9102e66bd54d991108853c9d946254b489c72	5	5304	304	533	544	3	4	2024-07-26 08:58:53.8	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
546	\\x4ade81f547cf7a717dc9986d0f1885ea0317069be47fe104520b49610792526a	5	5321	321	534	545	14	4	2024-07-26 08:58:57.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
547	\\xca4cbd183b42494d8c457f23a3cf2c2095e9a27a76892d60add866d82c48a315	5	5383	383	535	546	3	4	2024-07-26 08:59:09.6	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
548	\\x74b69ce329be86b42d27d93ef565711f593f066f9bf08f659da9d68ec69a79b8	5	5385	385	536	547	12	4	2024-07-26 08:59:10	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
549	\\xac0839543b800c2d9abd0cf49ddc589501db211691d3d78a48a091d9b1aadb9e	5	5386	386	537	548	10	4	2024-07-26 08:59:10.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
550	\\x9991b42b2ca2681513378bfbbc9730f641a53dfe74432674a242382adffd4468	5	5405	405	538	549	10	4	2024-07-26 08:59:14	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
551	\\xea3de198ae00b251c29739a1101f4af9254782a2be489dafdb4cb2fb16d91e07	5	5416	416	539	550	35	4	2024-07-26 08:59:16.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
552	\\x5245a9650fa67d55488de72a72d3b080875886f22cf8668fbab1c248d260abe8	5	5417	417	540	551	18	4	2024-07-26 08:59:16.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
553	\\x8e2bde91d11742c1681d9e97a0cfc75625307920bbc68a258791bb2771e4b872	5	5418	418	541	552	35	4	2024-07-26 08:59:16.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
554	\\x50e9de2f6faa75a1489fc2f28ef373ff9c6c6217c3a4b30bebe1e59e515fb86d	5	5421	421	542	553	12	4	2024-07-26 08:59:17.2	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
555	\\x465d34410903c72ecf065113de1aaaa10945234de623d8517dd2ee0183e681f9	5	5428	428	543	554	12	4	2024-07-26 08:59:18.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
556	\\x009ec677df074a1117892fe07cc6a1c69b48198c47f70b32b6c182dc0e0c2e53	5	5430	430	544	555	3	4	2024-07-26 08:59:19	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
557	\\xb4c45411ea8d5c341482fa2e681b149944e63fbd14dadb9218265f584b91d6e0	5	5431	431	545	556	37	4	2024-07-26 08:59:19.2	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
558	\\x40a4461dd32a767d8e803d97ffed95c3038cda0298bbd7f8ae04f28208e491ad	5	5436	436	546	557	3	4	2024-07-26 08:59:20.2	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
559	\\x93016b0a5b1a9ebf907be1ebc6672c3954e1c71df5c35c2b9b2fb02cb3a1813c	5	5458	458	547	558	4	4	2024-07-26 08:59:24.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
560	\\x144a4774d548ad272ac8f48ae97faa67a8ec09741345b213bce1431f306772e7	5	5468	468	548	559	11	4	2024-07-26 08:59:26.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
561	\\x572eddd335e1ce0148d132befca0d74a269a80da3aa59bef4bc3adc55b7a79b6	5	5481	481	549	560	18	4	2024-07-26 08:59:29.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
562	\\x1b3c4e098dd08179836e72b08c42937c63e8ed7ff990c4d37ed92fc96e1de9df	5	5488	488	550	561	12	4	2024-07-26 08:59:30.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
563	\\x6b7a68edfb6fb150560b12cbbb3aebd36b4b92132a13bb5ad4e04155ad3a3dfb	5	5490	490	551	562	18	4	2024-07-26 08:59:31	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
564	\\xd2ea7ddbc71aa5ddd965f90b1e9000bdad0d3bad4e4e60c747bb12effc8937d6	5	5494	494	552	563	3	4	2024-07-26 08:59:31.8	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
565	\\xd128ab67a344acd433d4ebaa1b869ee61f66c9471c25fd5f907e98b8ce73dad8	5	5498	498	553	564	11	4	2024-07-26 08:59:32.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
566	\\xb83cc474c09086e13a9610f5f2c96adbcd6b212f1630a9ca8dd003064b77cf10	5	5505	505	554	565	35	4	2024-07-26 08:59:34	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
567	\\x0149940ba2e1e86af2b9303d1363e708cbf5b66645c7cd9a1908e41949888c52	5	5520	520	555	566	14	4	2024-07-26 08:59:37	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
568	\\x4f9647058637903af168fc2beb6dfb256f67c62ea2cfa7536e87ff8fecdbc8f9	5	5524	524	556	567	37	4	2024-07-26 08:59:37.8	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
569	\\x64cc0c6b1e09c09431864719ff1f3cba80efad1526453673ae0d9302ce5591cc	5	5525	525	557	568	35	4	2024-07-26 08:59:38	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
570	\\x75448e06889751b115bc5ef600b9f1cb52b73c5d9bc8f58ec6676f081d93310b	5	5531	531	558	569	21	4	2024-07-26 08:59:39.2	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
571	\\xbca82c392c936826ace266036a8d23205c22c45c5680ecedf0c552a5b3823626	5	5532	532	559	570	11	4	2024-07-26 08:59:39.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
572	\\xcf3f5e3bdcba4ea5bbed520cc2647b12ed5e7cfe3e1cee32cc8b14d75c845a83	5	5564	564	560	571	11	4	2024-07-26 08:59:45.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
573	\\xdcb4d06b29dc962bf137f1de8e75455d732e98047578f88d85476ccb211048a2	5	5568	568	561	572	11	4	2024-07-26 08:59:46.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
574	\\xeaf0c0d28fb1df583fa083fd8c89b5751431a9a68e1c76ebff84bb12faeffbd0	5	5569	569	562	573	37	4	2024-07-26 08:59:46.8	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
575	\\xaacfddcfa62944fba3f086e8044e2dadd3f3b072b49fa144a0ec30bc1e6a40a5	5	5570	570	563	574	4	4	2024-07-26 08:59:47	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
576	\\x8823f47213ce9c0dd7e452f67738d5c598fd23592977f13b731de8de15147ae9	5	5578	578	564	575	18	4	2024-07-26 08:59:48.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
577	\\x3a68c3363500a3bab51f52a18f3030c8c861ea431de96d810af7f1e40c1a9deb	5	5591	591	565	576	13	4	2024-07-26 08:59:51.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
578	\\x304fdb6cb6045651505d5e347b6451ce453b96b926d89b18bc3c1d6f6a3facd0	5	5592	592	566	577	18	4	2024-07-26 08:59:51.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
579	\\x13e3c4ce39716c101f2a721f5d71e8208804b9776a05c6580407f0128ffa10a2	5	5602	602	567	578	14	4	2024-07-26 08:59:53.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
580	\\xd6378309102cc4d5586e854d3a903e7ee8cfb4723db18e52a9efe4f4c3e1bb9f	5	5615	615	568	579	11	4	2024-07-26 08:59:56	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
581	\\xaaac2900853f4997d9092aa8a9c8e7392918ef97b3bc4c4703fa56fb9411fa02	5	5625	625	569	580	14	4	2024-07-26 08:59:58	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
582	\\x68ed99835895233ccaaf8119b00e698a22d46bc20aad61bc305e624f88babc5d	5	5629	629	570	581	12	4	2024-07-26 08:59:58.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
583	\\xf9d06d498704101e97d3ce8dc9662e1916e6b55058a52b858f3bba7061999da7	5	5652	652	571	582	13	4	2024-07-26 09:00:03.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
584	\\x6bfb074831993c9e63e1f67a1fc8dc28d1a815cce479e417fc11c42bd9851770	5	5661	661	572	583	10	4	2024-07-26 09:00:05.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
585	\\x99d3991c2f6d2e48e7edc5a14b2e52784c15a5f22eec63f611401b3223f9a2fd	5	5667	667	573	584	12	4	2024-07-26 09:00:06.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
586	\\xec546bf745b403eb864365dd06031222cbc09413654d677028caec54393b48ec	5	5671	671	574	585	18	4	2024-07-26 09:00:07.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
588	\\x1ddb2da97cd9c7dfda9d6ab3f0999d98c6788703c03c46270f3917dd889a5b1d	5	5680	680	575	586	13	4	2024-07-26 09:00:09	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
589	\\x7adf70df84cd023c2fd0e6a4390921ae69ca277ac3a637ac5e61fec2852c4a59	5	5682	682	576	588	12	4	2024-07-26 09:00:09.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
590	\\xca2a625faf6069c6f5e254aafd59d2feafed13a5193b5512944d885961402c1c	5	5694	694	577	589	11	4	2024-07-26 09:00:11.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
591	\\x6fbdbe0fc9b62739aa9c389e6a804d99946885a59163af7d76b05a1d7e709af0	5	5695	695	578	590	12	4	2024-07-26 09:00:12	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
592	\\xce38d49ab31171743f028a417d241a0da3c5f54a28f6c78dc86f22c91367ea61	5	5696	696	579	591	10	4	2024-07-26 09:00:12.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
593	\\x3c400a63fed6fb054c419f7830a2aad8ed8d9edbaa22b24a0366b9febc64f331	5	5701	701	580	592	37	4	2024-07-26 09:00:13.2	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
594	\\xd5bd79561e1c4a29210801c11fc6d4b480cd4ca3cb85e62c57ef2094efa780c7	5	5709	709	581	593	14	4	2024-07-26 09:00:14.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
595	\\x897b3ef57f3857e88369c0fdc2c7efb30fa47993bba6d5617d28ffac144a5155	5	5725	725	582	594	14	4	2024-07-26 09:00:18	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
596	\\x521611d85fdcd202f0b081e36778cbfabda34ee4550e16b641ca50c1b2197542	5	5730	730	583	595	21	4	2024-07-26 09:00:19	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
597	\\x3a93c01509f3dffcaa92b35fb19627152c0f1405eee98fcf2b91945173cef3db	5	5739	739	584	596	12	4	2024-07-26 09:00:20.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
598	\\x323c0c491604dce8c59771bf164b874ebc3dead031d190e299ebca323cec818e	5	5745	745	585	597	11	4	2024-07-26 09:00:22	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
599	\\x3155d17a232dbbd98cf92aeb665f9deb05c96520303013c47a865a1f66ee3edd	5	5756	756	586	598	18	4	2024-07-26 09:00:24.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
600	\\x8d2b7e058c2b70e10b70d7104874c4f4ada4c3e947afa7795399b4a632120c43	5	5757	757	587	599	35	4	2024-07-26 09:00:24.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
601	\\xdd182198196b6861c4aaca9c67c2d0386dd67fde98cab5e5511c976affd28c83	5	5759	759	588	600	12	4	2024-07-26 09:00:24.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
602	\\x7d6448921d8a4209fa38863c331ec754ebf54961f5cb3f1c58aa44b3ed22ddd7	5	5780	780	589	601	18	4	2024-07-26 09:00:29	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
603	\\x4f631c87235bae67ce94b9306379685a6be4530c807316bdbf056b5e0e9dfc0f	5	5783	783	590	602	35	4	2024-07-26 09:00:29.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
605	\\x6df0d256c7da82c7affe734a4bdda06598cbdeaf1fc37fd76df14f5a55a7836e	5	5784	784	591	603	35	4	2024-07-26 09:00:29.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
606	\\x7625feb998eb1c28c3821147cc8407cadd5264c64198a879eeb05d6c80b9d821	5	5791	791	592	605	12	4	2024-07-26 09:00:31.2	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
607	\\x1416e45ceb6190c1a03a4fec99e345fc476f33c4e6378c67c692c99938124036	5	5803	803	593	606	10	4	2024-07-26 09:00:33.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
608	\\xfa6d39e0186a8ec0bfbe14922c19ba8cae60f319b466b671419cba0135a0d836	5	5837	837	594	607	14	4	2024-07-26 09:00:40.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
609	\\x2a740999b1b4ecff178e252de668db4a6a4cf4e1caacf40b3c5f0effc66c3f5e	5	5840	840	595	608	14	4	2024-07-26 09:00:41	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
610	\\x647e919e04cbf8a765b2ce6908ef74a6cd2cbc88439f6efa9fb0edbadbf4e0ca	5	5846	846	596	609	3	4	2024-07-26 09:00:42.2	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
611	\\xddb4de4660be0480e5e9d9a07348a614a62b742b50baeba59a7e48f58799aff4	5	5847	847	597	610	14	4	2024-07-26 09:00:42.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
612	\\xb127f667e92210441d3856c80e450e8ddff2f7fc4c5b732674a7d56d1f385b67	5	5854	854	598	611	35	4	2024-07-26 09:00:43.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
613	\\xe80b39d8c02d54f916491a7f1a87cabefe72307f6dd1be55d58f2a60ab28ae04	5	5859	859	599	612	3	4	2024-07-26 09:00:44.8	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
614	\\x3b7f27f831c57c4a73773af25105f8dda800b5a816d2c5a170eeea93ad24d1b1	5	5863	863	600	613	13	4	2024-07-26 09:00:45.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
615	\\x0e92a5a9a37f6fd3a94ec385bd9122a2663407ac5ea56d8bd7df168dafcc2b9a	5	5865	865	601	614	13	4	2024-07-26 09:00:46	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
616	\\xdb44e0247b4ab490e935aad9232461d83ec51286487972f7701bda77fd903333	5	5867	867	602	615	37	4	2024-07-26 09:00:46.4	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
617	\\x2e5ba22af558102c0e42c4179d22e147fd6918ec77c694e0201753be77a89b07	5	5869	869	603	616	3	4	2024-07-26 09:00:46.8	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
618	\\xf8e6bae44f1093a478726f50927c4bc6d91ef8d41b694eb32384ed10edcabc6b	5	5871	871	604	617	13	4	2024-07-26 09:00:47.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
619	\\x33b77f77176e2c47c796c8bc554e873833f0829c333d809f6128bfa746040ba3	5	5877	877	605	618	21	4	2024-07-26 09:00:48.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
620	\\x16421f79e89548de88c01ae45528e800c50451bbcfe8ca4acbc36dcffca32323	5	5881	881	606	619	4	4	2024-07-26 09:00:49.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
621	\\x35d2634f4f46ec4775fb7f2101e1197fc0f66f44b6d3c9b5183037d2c3d27d9d	5	5890	890	607	620	12	4	2024-07-26 09:00:51	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
622	\\x622b7dde8724e910469ae8ff729c61c142e7fd64d7765747af9d58236638bd45	5	5917	917	608	621	14	4	2024-07-26 09:00:56.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
623	\\xc4d236d9353e1b28f9991853d8c9d4d72a92eab516469d5535871abacb5a904a	5	5925	925	609	622	35	4	2024-07-26 09:00:58	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
624	\\xe4885437440980f91c105b1eee75187bc5765251d4b1cf5e8f90734d65bd7197	5	5928	928	610	623	13	4	2024-07-26 09:00:58.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
625	\\xc5c9cf1744b43755dcbb852a75b74969790088c4ba6c8f5793feccc50789dedf	5	5938	938	611	624	35	4	2024-07-26 09:01:00.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
626	\\x06cf68c16771b2149f53efdc67f8d2c6949261cb27c1ff147d441d9320ad49dc	5	5940	940	612	625	10	4	2024-07-26 09:01:01	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
627	\\x1dfdf4a5773b11f350dbfbd36859a1bc8067bbaaac37af3c7fdb4c772c6e4881	5	5969	969	613	626	12	4	2024-07-26 09:01:06.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
628	\\x13113816000cf44b3fcb0fdff63dccf39e690f0dfc20dabd09147c179c0395d8	5	5976	976	614	627	10	4	2024-07-26 09:01:08.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
629	\\x1de664599c9062f8d3e953ddb892723fb6b0dda66730afef11258b812dbb311d	5	5995	995	615	628	13	4	2024-07-26 09:01:12	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
630	\\x8a1ac1f79c8dbe3aae0fdc633fc80b4e0d7aad2c2deb16eb82b59dbafdab00ca	5	5999	999	616	629	10	4	2024-07-26 09:01:12.8	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
631	\\x871289dc691704153a6c0fa1fb9c42a337af4947e640e65297245a77fee08c76	6	6002	2	617	630	21	4	2024-07-26 09:01:13.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
632	\\x342bd0a00e462925fc5b2c7926e16d386df798bb0a0ea72d92e9e4d41562d37f	6	6005	5	618	631	3	4	2024-07-26 09:01:14	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
633	\\x99cc0ceced4d968b6ea1f4b081b297f157616354fe57608a10b99156537d5fbf	6	6040	40	619	632	37	4	2024-07-26 09:01:21	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
634	\\xfadf5e0f1e91882a430543a66c5266e10f8ac61b0abe6d46cb546ad68c31203a	6	6053	53	620	633	37	4	2024-07-26 09:01:23.6	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
635	\\x9dd8a87a54e9af8526dd11418fb78c4d4f9e06c2f2c485745a25418352c428ad	6	6064	64	621	634	18	4	2024-07-26 09:01:25.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
636	\\x6dc69d1c22c27fab8ac7c94d838cf06abaec9989b527e7994ab99a55ee5763b8	6	6067	67	622	635	3	4	2024-07-26 09:01:26.4	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
637	\\x713657db82f7e1c3118c58efebe6a8e7ba5360b8e0818896f92ca250f4653c80	6	6079	79	623	636	35	4	2024-07-26 09:01:28.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
638	\\x5f9412a14052e67794e1a6286080262ef424204892dacdb3248fbe4791db802a	6	6107	107	624	637	18	4	2024-07-26 09:01:34.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
639	\\xf465b5626f7b868b34dcfc12c770768157610307d8e2cb492819307aa8e5f34e	6	6117	117	625	638	4	4	2024-07-26 09:01:36.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
640	\\x3a0f4213d2ee9ecf31a615dfad3fe63f8ea7ee5726fc0ec0cf79d72f5b417597	6	6140	140	626	639	14	4	2024-07-26 09:01:41	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
641	\\xb800eca71e71b097ab2b2e850bc4556ae9f9024af1a6a78361879cc5dba77fb5	6	6145	145	627	640	14	4	2024-07-26 09:01:42	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
643	\\x5ea0c406e8eb4757cb5ea550b389a50b0f9c9139c72bc4cc0f4d43bf0f82fc4b	6	6166	166	628	641	3	4	2024-07-26 09:01:46.2	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
645	\\x043182d253554301291f93615bdf3ec5c174df139bf16614d0f5ca30b9f58a81	6	6170	170	629	643	37	4	2024-07-26 09:01:47	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
646	\\xb44453003b4eb71a644c888673bd3f105e3e4d559a82fd4ed82473a206e7d231	6	6191	191	630	645	14	4	2024-07-26 09:01:51.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
647	\\xef6bf95b2d1fc6776876dd15492d6f006038b3e7ed73b3f7c0638c668b9207b9	6	6201	201	631	646	10	4	2024-07-26 09:01:53.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
648	\\x2a92d6d6a268085159b41d4d809eabb2c97b3feab77eaa35edb8c55eb560b36b	6	6215	215	632	647	21	4	2024-07-26 09:01:56	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
649	\\x9643bccc47aa97ecee341db22125667b5abe7377e4add48e10cf2b1e8c1adf6d	6	6223	223	633	648	35	4	2024-07-26 09:01:57.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
650	\\x1199cca76828580acd1eb06cece66eb9db6c3f3e56f5bd68c820a36d46c68a38	6	6238	238	634	649	14	4	2024-07-26 09:02:00.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
651	\\x9c56da4831499016646386891ed24c7c0e1cf5a9c4202b7ab3c71d905168c479	6	6240	240	635	650	37	4	2024-07-26 09:02:01	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
652	\\xd160ca6546e7f162c0ff8bb41bc6fd52bf92a32c16948dce7ff10746c7e8f674	6	6248	248	636	651	14	4	2024-07-26 09:02:02.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
653	\\xc2f3f64637409f07e6d552d6a9063ebede1b4d908eb401b49bb729dec1ab6a03	6	6250	250	637	652	18	4	2024-07-26 09:02:03	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
654	\\x45ff07e5165fb324138b29b8072c5ed5398bbceb2c42ee99f6910f7d1234e599	6	6254	254	638	653	12	4	2024-07-26 09:02:03.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
655	\\xfc7ab9e553f4be443635b7c936b805c6c8d7606fbd49c83a0fa1c92f8735821f	6	6260	260	639	654	4	4	2024-07-26 09:02:05	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
656	\\x180eec541e535aa91dd0099a7812d6d460707a41940aadddf6ea419fc8702a8a	6	6262	262	640	655	13	4	2024-07-26 09:02:05.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
657	\\xcc9a6baa83e06fcc2289b5600ade4ac1c6630ff03e119cdf45a67ba18d6ea8e9	6	6277	277	641	656	11	4	2024-07-26 09:02:08.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
658	\\xc4977beea79cac8181ef6351e32baba34a52101a509cf8a92bd10405a32c3423	6	6278	278	642	657	18	4	2024-07-26 09:02:08.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
659	\\xa1d1239743e3bc10fa7e54fca67a44f8563dfa2ac7925ac3a24a1f339a7adad8	6	6290	290	643	658	4	4	2024-07-26 09:02:11	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
660	\\xb702b5cd6d446f2cc2769c37a1f093554a730e8a4563e0e5e11fc9244cb9f731	6	6296	296	644	659	35	4	2024-07-26 09:02:12.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
661	\\x906d62eece69a8a698e13dc8b7514b39062f3724f67bcbe163d2ec6ffafea134	6	6298	298	645	660	12	4	2024-07-26 09:02:12.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
662	\\x9f5a62897da6df46c6766f99ea7f4c1099d4ff038cdab4d7c71863a85bb3dfff	6	6307	307	646	661	4	4	2024-07-26 09:02:14.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
663	\\xe8d70b68595325c88be77a6c087612c9a96e20bdbaaf037db94e2f8d17a32fc2	6	6313	313	647	662	21	4	2024-07-26 09:02:15.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
664	\\x6cd993244ab639eacf50c365c56e63a77ce1c542dd5bb3dcb769a2b2c41df416	6	6324	324	648	663	4	4	2024-07-26 09:02:17.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
665	\\xa2678f1ea5917da50aedc4bedd04719e76b1d5933bc0fd01af1b0f848be161c3	6	6334	334	649	664	10	4	2024-07-26 09:02:19.8	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
666	\\x49c0da720bec98a02d362a4a103a12a4907dc1d37041eae9ee2c643e03f049ce	6	6341	341	650	665	4	4	2024-07-26 09:02:21.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
667	\\x95b7690b28835137d62bae817f90b3ad1cca358ebe5a411a645b88003d697cb3	6	6346	346	651	666	14	4	2024-07-26 09:02:22.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
668	\\x041656cbab5285977185b647a7bba1cff287b28d05af0bb1ae8d5f49b14f5fac	6	6347	347	652	667	14	4	2024-07-26 09:02:22.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
669	\\x89819a3a8d767f92d83f90b8e800c19f9b425a5b62f42563a78192b310e90c36	6	6368	368	653	668	35	4	2024-07-26 09:02:26.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
670	\\x66a529cce4f3844a4d8e9ea972e3669df696376591d126fc1501b46bc5e1aae2	6	6389	389	654	669	13	4	2024-07-26 09:02:30.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
671	\\x780d6e1b081b04295f015532d734c44c4a4a3120808963d6da494aec3f45bb5e	6	6392	392	655	670	11	4	2024-07-26 09:02:31.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
672	\\x9566e59ff9a2e59d7255499285ab2e9f45f17af8567b9bba3415d3cc07abcd70	6	6394	394	656	671	13	4	2024-07-26 09:02:31.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
673	\\x802a25254f1c15c7f36cc767b8cae6b3e77e2173159d70c1bce93be5dca38575	6	6398	398	657	672	21	4	2024-07-26 09:02:32.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
674	\\x3b8e53dc2821ce941e774e074835b456747caa44037e3acf49326e087fd21b9c	6	6404	404	658	673	13	4	2024-07-26 09:02:33.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
675	\\x1d51fa9ffdd97acd0bc54f00c2558bec98142a1b61b6424bf2d6904a6cd3614a	6	6433	433	659	674	35	4	2024-07-26 09:02:39.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
676	\\x19c14a11fb24378bca8cf2ba07cb2badbee8cbd19cdc43adddb4604dbc8412a5	6	6441	441	660	675	11	4	2024-07-26 09:02:41.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
677	\\x67b94f11135bd0885c9c90a974be03b0e0afa7a47b1dbe35003ad691714ee208	6	6448	448	661	676	35	4	2024-07-26 09:02:42.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
678	\\x92e78f2ede7dcffcb08e37b0ac6fd572304679dd4f897e4d9cf924918ec7ec6e	6	6453	453	662	677	4	4	2024-07-26 09:02:43.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
679	\\x16f0a89ec0059f7fca76d260197db96627433947ffc08d02b90ad535bceee8ba	6	6475	475	663	678	35	4	2024-07-26 09:02:48	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
680	\\xa7c3cf438eacfc2ec7ed933f0d1cc89fe0c7b028333e9287a292f87476933df0	6	6495	495	664	679	10	4	2024-07-26 09:02:52	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
681	\\xee7e37b1652829266b8dbc5409b997b5be531385d447afe49d4954c3dc96a95c	6	6499	499	665	680	12	4	2024-07-26 09:02:52.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
682	\\x15c43d87419ffb032ab144a00710e1fe0e2626a9177fb9806e4d02381257a6bd	6	6502	502	666	681	13	4	2024-07-26 09:02:53.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
683	\\x458b6cceeabd4e78cad6fed4c2962ac8a69b26c95ae911e00f680d3db5919704	6	6506	506	667	682	10	4	2024-07-26 09:02:54.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
684	\\xfb559a5c4a298b0678d3f0decf14a816b98989c87b9b67acef614d1ef136b083	6	6521	521	668	683	14	4	2024-07-26 09:02:57.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
685	\\xd728fa3812f426ca0b1075a9d71011df32899caa049906c35ffb174a96e19fdc	6	6538	538	669	684	14	4	2024-07-26 09:03:00.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
686	\\xd60d7bb632849cf9c6a0bb99055c2840c1eb701c3f4b810e55815b2ee1bcdcae	6	6542	542	670	685	21	4	2024-07-26 09:03:01.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
687	\\xf8d028781508949603064242c987e03892572c94f920763b4ca0da521ea643a1	6	6554	554	671	686	3	4	2024-07-26 09:03:03.8	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
688	\\x5ef63c5246617a6302cce429edadc3f96aab2c90a337b3bbec9d24e7a3ac418f	6	6564	564	672	687	14	4	2024-07-26 09:03:05.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
689	\\x93880f7f375daece4863548cbd525c1e1d740f5d44d5c474f95abea6b296d0bf	6	6571	571	673	688	10	4	2024-07-26 09:03:07.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
690	\\x7b43253e7fdea465e824442ad30989f6f8ea4b1762d0beda94bdb90bc9671ed7	6	6572	572	674	689	11	4	2024-07-26 09:03:07.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
691	\\xe16d4f649de4fe1f50e662ce87b03206d262e7976d4e30980338df3fb1374335	6	6577	577	675	690	35	4	2024-07-26 09:03:08.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
692	\\x0cc3850d6b7fb9ddf6034c2ef3869a0decf064377dc40529776ca9aa481f8622	6	6579	579	676	691	14	4	2024-07-26 09:03:08.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
693	\\x5c4eed1325df6633a37fedbfb8196e426b7799379275dbe813b6f4b6c2e969ec	6	6592	592	677	692	21	4	2024-07-26 09:03:11.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
694	\\x7b12939ca7fac45c19a7107b20e7eca073eda48d3f6e046fba4b526828371e66	6	6599	599	678	693	13	4	2024-07-26 09:03:12.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
695	\\xaea9e31ae9fafb66970acb44a3490c1a59b2ca5ab32e5a0e49c98674fd9fa43d	6	6603	603	679	694	14	4	2024-07-26 09:03:13.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
696	\\x40e2d0f5961ab485363594fb32351c043245d9dedcc920aba12e58e52c257228	6	6604	604	680	695	13	4	2024-07-26 09:03:13.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
697	\\xe515334fc5a062b93977be0930b43ce9147a8012dba3a284ee84d3572b72a0a6	6	6609	609	681	696	10	4	2024-07-26 09:03:14.8	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
698	\\x02caa447261073886a25ee23632da3ff49a8904e8e92da2186458ac7629b2d65	6	6617	617	682	697	35	4	2024-07-26 09:03:16.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
699	\\xe58b7c652963afc3e8a345a39ae315e20cc886c151d3508581f592b2a9b751e1	6	6635	635	683	698	3	4	2024-07-26 09:03:20	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
700	\\x6fa201182088a70c4cdf88c4773260d09d0cf48d5528ab8c7d5cf8959c0f2d24	6	6669	669	684	699	14	4	2024-07-26 09:03:26.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
701	\\x0fc41381360a807dd2d74801d78af269225eda8a3e8a0e527052ebdb1f592040	6	6678	678	685	700	21	4	2024-07-26 09:03:28.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
702	\\xe7a48fbbb119c19feb0f53f7aca03287c70ae699a0c6e161c03b670abbd925f5	6	6683	683	686	701	3	4	2024-07-26 09:03:29.6	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
703	\\xaef6193f36f9dfdc7cdb475fefe2d9ce41d14be416119ecfdb6c7fbf549c1822	6	6684	684	687	702	3	4	2024-07-26 09:03:29.8	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
704	\\xfbfbe2f721d8947f3a4b01ac1657702aa1c213ca899804f718004c2da8d3a7eb	6	6715	715	688	703	3	4	2024-07-26 09:03:36	0	10	0	vrf_vk154h929l05ppvrw8t33uwjyx5vktsv8rjdzt77h8u4nnuzs7t2uasujrycd	\\x7d4b709cb2a037794f4a6fe2767c76d6673c13b5b5ce9c6890a6b3c5b30c5fbe	0
705	\\x268d5825a40e68ddbb8c8c077a4919d5bf04d98830c744a14e178a50d975ae7b	6	6716	716	689	704	10	4	2024-07-26 09:03:36.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
706	\\x7d53a6b48d474ca59aa2b67bdde72de2c0fc2702062b54fe6a94e053a338d48e	6	6726	726	690	705	12	4	2024-07-26 09:03:38.2	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
707	\\x3f8809ed9365935d25c70f38f5d9b8650568d4e3b6dff621be582a23f0644e50	6	6729	729	691	706	11	4	2024-07-26 09:03:38.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
708	\\x415442b16333b45f8aa545d76a8e2b2d54eba3b61bae5e1cf86695c3ba79a91f	6	6736	736	692	707	10	4	2024-07-26 09:03:40.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
709	\\x63d2fef3e5434a2368916ce9160a05cd58057280e1442f7c148d6621b0d86c66	6	6742	742	693	708	35	4	2024-07-26 09:03:41.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
710	\\xe5438387a39175bbdbfef6c1e7e2df35eba14e01c6841768dcd80d33b81bd6d8	6	6744	744	694	709	13	4	2024-07-26 09:03:41.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
711	\\x7ccf7841b2d537ccd9a593e11ba12112b96c46870d5aad8c1d77f50df55d7b02	6	6758	758	695	710	37	4	2024-07-26 09:03:44.6	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
712	\\x5fefd56a83e8f5a9ed16d82e36bba9215ae5ba06f29f6e5650f1e46e97dd20c6	6	6783	783	696	711	14	4	2024-07-26 09:03:49.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
713	\\x0bb2d57a754146efc434bfb2f607d9cbc3de3869c6060efddbf3e7b4ef389b76	6	6798	798	697	712	21	4	2024-07-26 09:03:52.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
714	\\xc817168d7b03775355217a721872a6feb27d3c45a42f446e4d4c5d1c113186da	6	6803	803	698	713	14	4	2024-07-26 09:03:53.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
715	\\xa71dff2e8b7aeadbdb453865df04dcd0682fe0cb27b5fb5ccfad3024fb284a69	6	6810	810	699	714	37	4	2024-07-26 09:03:55	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
716	\\x0aacd13e0d669262313557ba8c992f63bd02ea06870ce0c90b3e64caf7a053d0	6	6811	811	700	715	35	4	2024-07-26 09:03:55.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
718	\\xf863c51e0606f835afbef44ac3d6c67b563f10377377d6cfa6bd40152bdee96e	6	6823	823	701	716	10	4	2024-07-26 09:03:57.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
719	\\x0edb51e731edcb1da46906146cecef10e5b70d855345ac7cf538aa8a279ddc39	6	6828	828	702	718	35	4	2024-07-26 09:03:58.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
720	\\x916979737e15f9db7646e446406e02e618de6668e83adb3c1eabe1685cd6652e	6	6829	829	703	719	13	4	2024-07-26 09:03:58.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
721	\\xed92785df6cb55372d54f4a821729c9a5b77907b168f5188a97dcab8ce75627c	6	6832	832	704	720	12	4	2024-07-26 09:03:59.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
722	\\xd908c54a7cb16b67aba8bb63ac32db9b8f2e86a5721cba61cc458566dc568da4	6	6842	842	705	721	37	4	2024-07-26 09:04:01.4	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
723	\\x0ada54efaaac5871252d8a6d06a341f3f5c37f76c5d7acdf51b46711322cd09f	6	6871	871	706	722	37	4	2024-07-26 09:04:07.2	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
724	\\x52a6445245880cb916848df8f952bbc8faa4e16a44b80b8b2c4e04db37db2f9a	6	6888	888	707	723	37	4	2024-07-26 09:04:10.6	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
725	\\x790a572770f3926336633647eb3178998f4090f33d42c00e481f20586a329037	6	6921	921	708	724	21	4	2024-07-26 09:04:17.2	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
726	\\xdc86c7ec75b4ed0c697293ade3890233ebbed49ea9648b648e9a22e969ba1806	6	6923	923	709	725	37	4	2024-07-26 09:04:17.6	0	10	0	vrf_vk1pnx8djczjz6ppxg0ekct8falf0fg30s2yl89hsqzg55z0w6etkjszygplk	\\x2e27f8f12224ee777680c4cf7491bbcf48786d3063217fd4ff038ce3d8f2c9a0	0
727	\\xb35dbf2c2417f68e2ab8675b75e234b58b5836868712cd10e8faedd23b3c67a5	6	6925	925	710	726	35	4	2024-07-26 09:04:18	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
728	\\x85370700474f0578b0793d083638e858081e7b39d2d2d1010341254e3133055f	6	6935	935	711	727	35	4	2024-07-26 09:04:20	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
729	\\x62b2627c5e184353f963a3f881ad0a81a094c1e819bd6646fc117c4e4a0a8dbc	6	6968	968	712	728	10	4	2024-07-26 09:04:26.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
730	\\xe78e8cc7a47914861180b4b872465c31b34a0349a195451e3ef477d166fd9e30	6	6973	973	713	729	35	4	2024-07-26 09:04:27.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
731	\\x6db037f9bdfc5ad8871097fe4eb9a2b73091dccb58e17e95009145d0fe1414ae	6	6982	982	714	730	12	4	2024-07-26 09:04:29.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
732	\\xe40af3168d084d65c42171a4d43143a2b665922f30f392a17bb54742f43626cf	7	7005	5	715	731	4	4	2024-07-26 09:04:34	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
733	\\x4e56061bd79641c83012c62baf3078ba5401ec784dfc6c36cf2299979b641b3e	7	7012	12	716	732	12	433	2024-07-26 09:04:35.4	1	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
734	\\xbcc2f1a4aa18113ac4f9682df0062670528f1c5dac42be51087cb680de3936e7	7	7014	14	717	733	14	4	2024-07-26 09:04:35.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
735	\\x19dfb2b03b3969987c12f3c96fcad6c3220e90532ac4324e0d0665ac9788742b	7	7026	26	718	734	12	4	2024-07-26 09:04:38.2	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
736	\\x11dd71400296f731a0d82d0cfd235de7e4b97d2d504e74cc7decbaf6030aa3b4	7	7029	29	719	735	11	4	2024-07-26 09:04:38.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
737	\\x7f300333e7dfd904c3d06f008b9641961fc42e5d6942d84d109fdd5f9a8bdf72	7	7031	31	720	736	11	4	2024-07-26 09:04:39.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
738	\\xbac1de5c36fc9750f20c2572d6496c8029cb00fef813f1916e66249ab39c492e	7	7033	33	721	737	10	4	2024-07-26 09:04:39.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
739	\\x0c3f510bcc541fea46d9ece17f617e977fbc24a444562ddd607e1f3b0d75a005	7	7037	37	722	738	12	4596	2024-07-26 09:04:40.4	1	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
740	\\x648e57e53d50f10b40bd9f8951cd152f3997ef7618a46bbe8ce426ad53085d8d	7	7039	39	723	739	12	4	2024-07-26 09:04:40.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
741	\\x573dcb414e86fbb4b75d1fa0e586addb32b1b09d4b31d9a1e7371f951a42c83b	7	7044	44	724	740	4	4	2024-07-26 09:04:41.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
743	\\x6f88378c112f85bda8db5ce7872923d393dff6531449796aecca0eca6a314b93	7	7057	57	725	741	4	4	2024-07-26 09:04:44.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
744	\\xd4b67fa92e5248a6902f522ce54534880161ae31f2b0ae534624faa2df80558c	7	7060	60	726	743	4	4	2024-07-26 09:04:45	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
745	\\x8b0bfd7010752d0ff34796223357921434aa0e3abf7c7b0b5f9e00dd9d958be5	7	7079	79	727	744	10	4	2024-07-26 09:04:48.8	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
746	\\x49d163ca1622bb2932226532c84a242486d7425442e969aac3e2ae978669f637	7	7085	85	728	745	4	4	2024-07-26 09:04:50	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
747	\\xc8463264ffdd8226d4a8d122a20356dd6052819fe572290b7b23788048a46750	7	7093	93	729	746	18	4	2024-07-26 09:04:51.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
748	\\x838185eb85838649497ebc2e5078ae19f7c5a7b9f1a4c9c2d6ec25974a2008e4	7	7094	94	730	747	14	4	2024-07-26 09:04:51.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
749	\\xd407e8d931047e92630032a2bdced3a545119589a731cd98f5036882a30a358a	7	7099	99	731	748	4	4	2024-07-26 09:04:52.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
750	\\xcb3b8f426ec5cb0a5b3a28a294d09f890ef6a3a7b3c764e6eda1a9e1563b717f	7	7107	107	732	749	35	4	2024-07-26 09:04:54.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
751	\\x72fdce71aaa178a7681a86cc84f2b9935afc09ea4e3a4ba83f48efd3aef63f0d	7	7108	108	733	750	4	4	2024-07-26 09:04:54.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
752	\\x42e54b1235d135d7fa006844e787260a5c55337eb1b75ffb516ab8f64a01aa4d	7	7115	115	734	751	21	4	2024-07-26 09:04:56	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
753	\\xb6af7fdc91f603f2318ee4c31cd488ffc8dd8bc85bcc9238f17554e686cb8e18	7	7118	118	735	752	18	4	2024-07-26 09:04:56.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
754	\\x087a9d197b9da6bcc6f6050f87af9316e9e6bc47edbceb2707abe36d2ffdc851	7	7119	119	736	753	12	4	2024-07-26 09:04:56.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
755	\\x52bea6fef3d5fc5bc4b6953d1d0cc25805801e7d1bc6a95e2d19c8b87a4395dd	7	7145	145	737	754	11	4	2024-07-26 09:05:02	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
756	\\x754e63728f31a30368c8f3c72bfd2a48e88c73e602f70846d55f074625ce9e4f	7	7147	147	738	755	18	4	2024-07-26 09:05:02.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
757	\\x3c010588d7efde5989d624496c7edf8ccf60ef4e1d49e18bf50204e88f73f146	7	7158	158	739	756	21	4	2024-07-26 09:05:04.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
758	\\xebb789c8daff35927c673dc5c85f4fbba960244c713e75db1ff77bb89f2d29c3	7	7161	161	740	757	35	4	2024-07-26 09:05:05.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
759	\\xb754547007867812fac210d85d5f00a4630e5b6f2917ed6638213b1812090499	7	7172	172	741	758	21	4	2024-07-26 09:05:07.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
760	\\xcd4be353166ac83163fe4408d4399576b7da7c7e59f76dfa375c1836483b515d	7	7174	174	742	759	18	4	2024-07-26 09:05:07.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
761	\\xe20371b127363d0f4655d4a218b6e2f1f08c7fb63352843735c02cad0e51882f	7	7182	182	743	760	21	4	2024-07-26 09:05:09.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
762	\\xe1259d4e49087a23834e5b4d68eec89263a16d81c5712fe5b52576e0dbebd111	7	7190	190	744	761	14	4	2024-07-26 09:05:11	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
763	\\x275b330168505c1cfd2f409dee19b295e2f98f44285389d4ccc8cbaa9228354a	7	7192	192	745	762	14	4	2024-07-26 09:05:11.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
764	\\xa0a1bdf0455e64ae7f4ecfd48df97a0bc8523bbcf4f94600efa013e757e65727	7	7209	209	746	763	14	4	2024-07-26 09:05:14.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
765	\\x475c16fcc69cb892fbf4ff4256d491ef8fd0657951899fdf5895c6412a3e9ce7	7	7243	243	747	764	18	4	2024-07-26 09:05:21.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
766	\\x2bb7698d143af0057170f75295981b86d83a31e6688263ad21c9e02c96fd3e24	7	7249	249	748	765	18	4	2024-07-26 09:05:22.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
767	\\xc0d218f8fa215037b33a445a0c11ab5b4a26ce8510da79190c1e04ef66f6c89a	7	7274	274	749	766	21	4	2024-07-26 09:05:27.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
768	\\x71d5e1cebc62104c54883afb283f82d61b1e33c697212c8d73de8d8b5b8a3893	7	7278	278	750	767	14	4	2024-07-26 09:05:28.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
769	\\x06626f0fb2ed46b3dff700ebac7f94144f9e22a9a007b5355e1082047821e3b3	7	7293	293	751	768	10	4	2024-07-26 09:05:31.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
770	\\xec54fe4b7b3faf986f4fdb11b519f1afb159948cde010ad3f4d1a4789263c2f4	7	7298	298	752	769	4	4	2024-07-26 09:05:32.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
771	\\xe71a2e37dac9613d694c30f1616d39fd5fc48c4319dbb4f63d8058cea6e7305a	7	7312	312	753	770	18	4	2024-07-26 09:05:35.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
772	\\x6851ac467bd53e25ba466079a42f2cd475513f1ccfebf1b78dfd65788090d90c	7	7313	313	754	771	10	4	2024-07-26 09:05:35.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
773	\\x699a62f80ab7e6d725cd09e8bd14bbfc4c6c7ae8b8b671328027b0b102d32e81	7	7317	317	755	772	14	4	2024-07-26 09:05:36.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
774	\\x9f19e89429039d465dd3bdff8affff0279f7ac1945d3f3a173014a48335d10cd	7	7328	328	756	773	35	4	2024-07-26 09:05:38.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
775	\\x871b886323926a142be05e12d89953498fe81bb3a6d4dde2c4f5aeda4b324073	7	7345	345	757	774	11	4	2024-07-26 09:05:42	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
776	\\x7d0cc309675ef2b9db41737efd6626dfbe94760bfed6a57db8b541daf563316e	7	7358	358	758	775	11	4	2024-07-26 09:05:44.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
777	\\x44a0fb8c2165a208aaf93c9af227203f991fc06db00c42c69846583d6fa8842b	7	7376	376	759	776	10	4	2024-07-26 09:05:48.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
778	\\x4531ca7a676e6b5b3499514ca6f4d370dfe7087a5a2099a20a418c80d331a3bf	7	7380	380	760	777	4	4	2024-07-26 09:05:49	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
780	\\xff8af0fb15e77b1df9543e3ecdc3508af4979e35bed0daa4d96d0c24f6c2a32e	7	7385	385	761	778	21	4	2024-07-26 09:05:50	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
781	\\xeaeae5986cacffaa0226e02db27790733096a3b098d5be014ceb901c1963a6d5	7	7387	387	762	780	21	4	2024-07-26 09:05:50.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
782	\\x53f21ee177a2019df0ea080878a9f2ec7dab63aac5d46488520c0da448c3da3e	7	7390	390	763	781	14	4	2024-07-26 09:05:51	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
783	\\xaaca603f7bfc226fb85d32c40465cd5117480b6d6a8e294671cbcaff237a2a10	7	7411	411	764	782	10	4	2024-07-26 09:05:55.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
784	\\x5721865333c8d41cbef5034075efd01d3f5d3e8dfa643a2f42d5b0dba6944066	7	7428	428	765	783	35	4	2024-07-26 09:05:58.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
785	\\x8a5018aecd57b3ff35c46f1cfd732551ae4a33b28d320b7076139871e71f29ff	7	7440	440	766	784	14	4	2024-07-26 09:06:01	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
786	\\x0f92b91eee038b3e9c0b83271cbc6bbd593222603e03229a2905ac3f75984b6f	7	7453	453	767	785	13	4	2024-07-26 09:06:03.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
787	\\xf99409698e018afced50aadeb9aaea143abe9d8b9e75fcc78b4308d7ff504c4a	7	7455	455	768	786	10	4	2024-07-26 09:06:04	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
788	\\x27ab51c3b99ba053efea6c896480d93acd600030b35569b330f895f16994696e	7	7468	468	769	787	14	4	2024-07-26 09:06:06.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
789	\\x929df2d6c4c47e31a670ee550dd3e492210e1654f968cac9af398c241efc4f0a	7	7472	472	770	788	10	4	2024-07-26 09:06:07.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
790	\\xe6d0dce6628599195f4d269ad6cb35aa227251ce5b6ef828055914bd2035cbfd	7	7473	473	771	789	21	4	2024-07-26 09:06:07.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
791	\\x2a516cb60537a7c261a5df349b06a444fb31ea416dd1368ea2c1548ec836bb53	7	7480	480	772	790	35	4	2024-07-26 09:06:09	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
792	\\x9a2b659cb5fc2412f90fab5c2de19c2f0e7bc422eb14385ada45756d3d0856db	7	7492	492	773	791	13	4	2024-07-26 09:06:11.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
793	\\x004085ced155829000ad65b212bed8d7bee935b56931ecb69ff40c7eb4285af7	7	7495	495	774	792	10	4	2024-07-26 09:06:12	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
794	\\x774e15c2e5d877fffd11bbaf6adde99b25aac19ee1f5830c7f940c30d1767a4b	7	7512	512	775	793	4	4	2024-07-26 09:06:15.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
795	\\x24b3d2005cc443baa4ee574e69d80fee0e1add277e10a425fb3cdf18936b35e4	7	7521	521	776	794	21	4	2024-07-26 09:06:17.2	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
796	\\x9cb68fda9e34b88875c1b79e35db67f05e4e68350f6a4e7d854cfc748b8e3f32	7	7523	523	777	795	10	4	2024-07-26 09:06:17.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
797	\\x9e72b6e0241304e7eb54b83b081b584010eeda7ee07fb2eeaf01a23e3fb7ac3e	7	7531	531	778	796	35	4	2024-07-26 09:06:19.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
798	\\x15778edbe26da8da81939e63cd003d536743cebcb1dcbbb5c3014cdf5f24edde	7	7534	534	779	797	14	4	2024-07-26 09:06:19.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
799	\\xc962bff6d3e006c63c87834efe4e44dee63e9d04a1875b1d2d25fd5eea1b9f3d	7	7553	553	780	798	12	4	2024-07-26 09:06:23.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
800	\\x0413c77a1a7359dc7c686ad8b52931a99e189de6aeee12616160c07ae5b06461	7	7554	554	781	799	14	4	2024-07-26 09:06:23.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
801	\\x7257b0e4931769a3d08f5a38515280c4a1a602800b45ffed2e8afe4d0a37fd29	7	7565	565	782	800	12	4	2024-07-26 09:06:26	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
802	\\xfce7e162576f3ce0a728233df68676f02bc9186ee47e611b7243aa0cb16532b5	7	7572	572	783	801	10	4	2024-07-26 09:06:27.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
803	\\x1690a6e36c4631b350274fb65ff72584a716d32aa7a3e63a6fd92787d62c51f6	7	7575	575	784	802	13	4	2024-07-26 09:06:28	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
804	\\x15aba6bd044271477e202dff9ef1866ba550bc2ef919a4ed46b54f8f4f44b6c6	7	7576	576	785	803	21	4	2024-07-26 09:06:28.2	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
805	\\x10a055ccb6e46ec4fa278c1be7050b60f4af3372f6433dea3f9107140e6b3b7b	7	7579	579	786	804	18	4	2024-07-26 09:06:28.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
806	\\x7ada2cdb42a0d0559ab6113de36b90399f8095e8e2b61100020f514aab9861d7	7	7587	587	787	805	18	4	2024-07-26 09:06:30.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
807	\\x229de27cdd882d3c18a9ac865823432176ce84c74e615fa2d2712810a9a7e2fd	7	7609	609	788	806	11	4	2024-07-26 09:06:34.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
808	\\x9f54d4280940aadd1ab819d239e46784d1b2490e2619c88fa84eadbf49a87804	7	7610	610	789	807	21	4	2024-07-26 09:06:35	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
809	\\xcaa0d4220b5beb421cd796bd820ad0f9c01a70f1f447eefefdcf2c60dd85b711	7	7620	620	790	808	4	4	2024-07-26 09:06:37	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
810	\\xd97e8fea950e351dcb4c0941a557e97b0a0e536044c9f94192cd3b3561991d09	7	7639	639	791	809	14	4	2024-07-26 09:06:40.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
811	\\x52c3443e79e5a79d966e32a9a596c8a0d9176b504a77fc0145d52d7af5dfb158	7	7669	669	792	810	11	4	2024-07-26 09:06:46.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
812	\\x154109ff32a401c170b0e78635efac3341117ac1d816c22fdffebbe2a6fd9f70	7	7679	679	793	811	4	4	2024-07-26 09:06:48.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
813	\\x5604cd289aaf4e3a0b4aab6fcf98fdbe12e56a7561ddbcbc635fede8bfaaedea	7	7685	685	794	812	21	4	2024-07-26 09:06:50	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
814	\\x784bf9f2f17e5f8f2f8f7094f9f41aa01ffa7aae8dedfc026487ca69f9768ffe	7	7701	701	795	813	4	4	2024-07-26 09:06:53.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
815	\\xdf19936a25365ed52cbb8574fa47f18e97bc4fbfdcdca15b290c7fffc49906cc	7	7715	715	796	814	14	4	2024-07-26 09:06:56	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
816	\\x352d431a692998845b19992c260782824aa6e260a5e2c5be3dbb606777fbbc32	7	7721	721	797	815	10	4	2024-07-26 09:06:57.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
817	\\x1b66a0fbb72cd0982d8dc0325708f49a942c9f5f6d60bea78e2c3bacfc45cdb0	7	7737	737	798	816	35	4	2024-07-26 09:07:00.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
818	\\x8115e2e117aac134cd245edb67422a489b56165d407d69d8ec70bd3ebee6b48b	7	7740	740	799	817	4	4	2024-07-26 09:07:01	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
819	\\xd7e2debb1fc62e360302d60ee0fbda32450c82cfb800ee712b120d904c0ad21d	7	7744	744	800	818	21	4	2024-07-26 09:07:01.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
820	\\x3783f7d52d9302769b4a9277c8e2fc01c8c0cd57b0d7256e00c04563883bf1f7	7	7752	752	801	819	10	4	2024-07-26 09:07:03.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
821	\\xafbaaf08bd3a6a39bab88f0d73c3f38532529ca1a1051f206646d0d4461d1959	7	7757	757	802	820	4	4	2024-07-26 09:07:04.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
822	\\x07be45797d0c69784030836a15bf024793bda0a9ea86117c70fe015817c488ec	7	7764	764	803	821	13	4	2024-07-26 09:07:05.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
823	\\x92c2c771fcf766bfd1434d00364127b699cd52f05a8a0f4a3cf5f2b38630885c	7	7767	767	804	822	14	4	2024-07-26 09:07:06.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
824	\\x42bf9365c003f4b636821da7e1ed416c6f6c88d755a0b52bb700cbe5226817b1	7	7804	804	805	823	12	4	2024-07-26 09:07:13.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
825	\\x71125ffb91d161282a0c67062c9cdb11d35580c94c5f8327330f81d8b94220f7	7	7827	827	806	824	21	4	2024-07-26 09:07:18.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
826	\\xc919ef0b0d46f091995a1307876e05b55d4741b36527f21d04d3c28a51edd55a	7	7843	843	807	825	18	4	2024-07-26 09:07:21.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
827	\\x2f0c872109c10bf5ebc5bd3963f26bd017a3d5a0c6747ef80e9810856fb1836a	7	7848	848	808	826	11	4	2024-07-26 09:07:22.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
828	\\xf37d296aec1875f7d48b8aba2638b48e379ca2acdf3681af33c11e4330b772dc	7	7854	854	809	827	21	4	2024-07-26 09:07:23.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
829	\\xc99e579b53fd3f3c9eff14a074597894686339b6d8fa635fc860e5c2fd6bc099	7	7881	881	810	828	13	4	2024-07-26 09:07:29.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
830	\\xf65993b0d0c7901ad6d443be9e1b39f5a008df9daa79add0926d20d8e35cde8b	7	7894	894	811	829	11	4	2024-07-26 09:07:31.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
831	\\x22fd74e18f3f228285c2a0eb427316f915f1d5ccff9bbff788f9f84c7b0bc492	7	7903	903	812	830	10	4	2024-07-26 09:07:33.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
832	\\x3b4fffd6039b6e1864352ca88bc7312c6b0df34336d062b02bca270b7cd58a47	7	7939	939	813	831	13	4	2024-07-26 09:07:40.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
833	\\xd815a81c3e4d199d3cfd76b5e7e18a3a0ee653ea3a898fee6efd59b6bf710c29	7	7946	946	814	832	11	4	2024-07-26 09:07:42.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
834	\\xe3c11c52c84d206e685d51c420172c0355ad74caf28a6acffe479cc04530f823	7	7962	962	815	833	35	4	2024-07-26 09:07:45.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
835	\\xfd79bd19d8c61af4b47d2614d106e75c5477f1d7f6c5df13faeac22cd88fce3a	7	7963	963	816	834	12	4	2024-07-26 09:07:45.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
836	\\xa7351a91355935833cbdc7c1c9e3fd3f48675882e30fa133a8d9a178e39b33db	7	7976	976	817	835	11	4	2024-07-26 09:07:48.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
837	\\x6946adcf47c017072731f108c7aa722cf5d1c65ad24e93104eadcec2ddc2598c	7	7977	977	818	836	35	4	2024-07-26 09:07:48.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
838	\\xdffb99c10bc7fd85e8d73046cbc284e4f07bcd4cabe73b22ef55ba199f963940	7	7992	992	819	837	35	4	2024-07-26 09:07:51.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
839	\\xb46532a96bb8914b6ff98f3abc5ea2c29f4be079062dc0dea3d4e84a81da8e38	7	7998	998	820	838	12	4	2024-07-26 09:07:52.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
840	\\x0caaeddb0a67b24aedb714e7225590d0aae8749ed841591b1511a46dedab4ac1	8	8000	0	821	839	18	4	2024-07-26 09:07:53	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
841	\\x29dbf5e83b3700054a11d380d5a8e1fe580f074356dace1966cf702b752f49f0	8	8020	20	822	840	11	4	2024-07-26 09:07:57	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
842	\\xe8ce363287501c06788aff512826db81e336189058dd883ca6702054f26bbb90	8	8034	34	823	841	11	4	2024-07-26 09:07:59.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
843	\\xfaf7e9b8a23c3b069953adcf127e2742ef0a9511fb275adfb74e150764ba9829	8	8035	35	824	842	4	4	2024-07-26 09:08:00	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
844	\\xa576372695863275c3ab6c1a38157accb0b277a1cf47f42dae80af24841d4d2c	8	8043	43	825	843	18	4	2024-07-26 09:08:01.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
845	\\xc2df33e3ca50fa58aa76dbabe7cbbaa3692b063e480c7cd721ce914deda18e3e	8	8046	46	826	844	18	4	2024-07-26 09:08:02.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
846	\\xc69b674b1e74e1acbc50007424192c32d43885cfb2016a46a10605eadeb517c2	8	8050	50	827	845	12	4	2024-07-26 09:08:03	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
847	\\xc52427b0a6578a7274ff430bcd0b4b8a0efb4e0385cf13abe716fcaea56b3e2e	8	8052	52	828	846	12	4	2024-07-26 09:08:03.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
848	\\x8acab5f9fd84a1e682455f4cea79b0eefb58b9e9ce23c7d508c6bd7c64cac552	8	8061	61	829	847	13	4	2024-07-26 09:08:05.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
849	\\xe20e6b2bd231bf52638ed659194d06b69e21b0f0dea4fbe2e72bcc6eaa091753	8	8066	66	830	848	12	4	2024-07-26 09:08:06.2	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
850	\\x6c0c3cba93f1d42e06fc45571c469e521e76065f219b439de44be035105f7a5d	8	8080	80	831	849	35	4	2024-07-26 09:08:09	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
851	\\xbcb1e7825c003fd87cf214522e97a9f94b762c45bc8a2390a09520e39750db95	8	8086	86	832	850	13	4	2024-07-26 09:08:10.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
852	\\xb0028710086facf75b6979da3dd54dd99c27bba6da10b25feef3fa034b5b986a	8	8098	98	833	851	21	4	2024-07-26 09:08:12.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
853	\\xa785bb89c0460f68e9bc0893772facdbbab7a70db50165853fcf03ea8e9c7872	8	8112	112	834	852	35	4	2024-07-26 09:08:15.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
854	\\x0375f628ef9d1cfe99729ebcf57e5787e482c9772702576ac0588bfa2e6d205e	8	8136	136	835	853	14	4	2024-07-26 09:08:20.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
855	\\x1da0a773e26796c7795cb8c401294801d7e4cbcd2fc8eb652b7ece70dd36c9f7	8	8139	139	836	854	4	4	2024-07-26 09:08:20.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
856	\\x0eb2f209b202d944704d508269560b7dd8146d65e14d489b0a642f2c32f34274	8	8181	181	837	855	14	4	2024-07-26 09:08:29.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
857	\\xa4ba66e18b60f5e71620b80ffa5b10c567f901737014f81371297fe9a81db6ce	8	8183	183	838	856	35	4	2024-07-26 09:08:29.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
859	\\x29128b94d7f7cfcdb89e95f033259eb9b61ae869df6191cdf10f963d83a3c5eb	8	8210	210	839	857	10	4	2024-07-26 09:08:35	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
860	\\x345aa40ce6e296a436acaec1ace0b78ea6fb4acf36f5c82ffaa205f6c234d8ff	8	8221	221	840	859	10	4	2024-07-26 09:08:37.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
861	\\x977d55e97657b775f8847fcacd76dbcacfd2982c2fb45c571aa2607dc6cd95a3	8	8230	230	841	860	12	4	2024-07-26 09:08:39	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
862	\\x79134a8a8a5605c5226d43ca5deb64365b93889fab6ac918f4e302948453fc3b	8	8235	235	842	861	4	4	2024-07-26 09:08:40	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
863	\\x5d32e491a849862f3ccd2f091ac6fb62a882d131d50a1c9d398fd26ef412c6d7	8	8240	240	843	862	18	4	2024-07-26 09:08:41	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
864	\\xb80ebca61c1760a0d00c42e564d6cc3d4f356f342224a8255fd53510a51d91ca	8	8244	244	844	863	12	4	2024-07-26 09:08:41.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
865	\\xea74c36c02f1d9814723a887d9f712ca308ea7880d6a219bfb5e860d9c62092a	8	8253	253	845	864	10	4	2024-07-26 09:08:43.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
866	\\x2b1053e5260d846abe4ba642b26ba6b31d2294f8460151523e3f5703d469b8fe	8	8262	262	846	865	18	4	2024-07-26 09:08:45.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
867	\\x932f410841c23320a2f8624c1a752542beb830e8334064bdc23b16651d9634e0	8	8264	264	847	866	21	4	2024-07-26 09:08:45.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
868	\\x6a6b0b061dc2d5025d4d4c8f74a5b5ee4c1afeee6af62750673134a145256ce9	8	8274	274	848	867	35	4	2024-07-26 09:08:47.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
869	\\xf9edc8d5bf9ac9120bb3504fef95c9aee424a15b2717ea1ca75d7759a778868b	8	8288	288	849	868	10	4	2024-07-26 09:08:50.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
870	\\x3f3d82a44e1c128c65c7827e845b04d6ca8c385187be80357cd00965932c15e9	8	8291	291	850	869	35	4	2024-07-26 09:08:51.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
871	\\x399ceb70068fe488a0ef4ac79412776edd4e7d63078cafcef8b6772e6e1f9e2d	8	8313	313	851	870	14	4	2024-07-26 09:08:55.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
872	\\x195bbe095959defe533467184170998de991b454d031404fdfd77a50a9dedabe	8	8316	316	852	871	21	4	2024-07-26 09:08:56.2	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
873	\\x9e83aa81c06e8e0bd8ebccd557dc293b8984a027f87f1a67e1019099eca75cf0	8	8327	327	853	872	4	4	2024-07-26 09:08:58.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
874	\\x3e472f706b657ee5c5d1d3903086978438772ac6785640b1ea74e46723e2ecb7	8	8362	362	854	873	14	4	2024-07-26 09:09:05.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
875	\\x8a1b145d0dd7b1a18fae5bf69c7de1798e0c60aa95dcb08637389f6d24a69990	8	8368	368	855	874	35	4	2024-07-26 09:09:06.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
876	\\x7069278268bd2613267f3cf65f8858fc3fb9c9d6b6741c25902a0d43849b89ae	8	8378	378	856	875	13	4	2024-07-26 09:09:08.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
877	\\xe8fc4f3e062ac737cc27f2748fcd7cda30ad56975d1c5dee5ca99656fdcf9783	8	8404	404	857	876	18	4	2024-07-26 09:09:13.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
878	\\x5a2124b82b71218c6fa5063521aa62136c877ac3e29916a122a4423e1c62f8a6	8	8453	453	858	877	10	4	2024-07-26 09:09:23.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
879	\\x1ffb35f7758d01b2dc97f9c1cdd193530cf566b468c54422c77c8d3a5e4dbead	8	8474	474	859	878	14	4	2024-07-26 09:09:27.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
880	\\x7c921e7d945c8356560123f524cb7c75d26981d47c789c11745ae3e61c11d620	8	8493	493	860	879	21	4	2024-07-26 09:09:31.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
881	\\xe2d2b9003b3da9e4d8288b1a50512fd2f6a4a92c0c4980ece4fe4c70273d3009	8	8495	495	861	880	4	4	2024-07-26 09:09:32	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
882	\\xde25a896e0bf488b70a0b8089ebdf8a16c131262d7f7f676d34d1934b0b8ba98	8	8507	507	862	881	14	4	2024-07-26 09:09:34.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
883	\\x9d8a27efc382555b16ee89dccf061b62b48a14b49ba958d70560f8f16869208c	8	8519	519	863	882	13	4	2024-07-26 09:09:36.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
884	\\x5d0adb65a96fd07edc5828897eb092dc49128ec1e182f9350a18b097729f2a79	8	8525	525	864	883	35	4	2024-07-26 09:09:38	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
885	\\x3ced95cc88a9ae25ea0117efc3ac0dfd5002251f2c37fe7cbbdc8ca948f2569f	8	8552	552	865	884	11	4	2024-07-26 09:09:43.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
886	\\xf596ae3de3d0a07dee2630241f621491f23178c0473b8a1c801d015f2fd3d3ba	8	8553	553	866	885	21	4	2024-07-26 09:09:43.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
887	\\xde02af822fbe00e4d65bd8e8f9f9910fdd8b11ffc5808dab246423d10b269302	8	8555	555	867	886	12	4	2024-07-26 09:09:44	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
888	\\xafd38c326ff6c6c6f0d65fa0fbe41c6f2a8f44f9e3364a20ea9b1e697bf3aba6	8	8568	568	868	887	10	4	2024-07-26 09:09:46.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
889	\\xfefea3aa7bee43d6afa24b298382c34a14557d9836b86fc4f7751e92fccb71d8	8	8581	581	869	888	35	4	2024-07-26 09:09:49.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
890	\\x978ef5e573f146a43eb2068a4cc5fdaf1558b6c30096f5dd418b8db751699d10	8	8583	583	870	889	18	4	2024-07-26 09:09:49.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
891	\\xe972cf25ae16dd4aeb75760779cd34212ff3af61bdf11aea044f2f5a0e72b213	8	8595	595	871	890	35	4	2024-07-26 09:09:52	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
892	\\xd9a3108822809cdc0151f9318193bc4c838bc16eba6660390c17d14e480dbfd9	8	8604	604	872	891	11	4	2024-07-26 09:09:53.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
893	\\xca87f9f574e417236c357cef766fa5e30e681078bdd35089ea4037e2978bf141	8	8621	621	873	892	10	4	2024-07-26 09:09:57.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
895	\\x7df928e8a58565e06f8bac1eefd5201478a1634bd0801383b1fb2b30a751450f	8	8628	628	874	893	18	4	2024-07-26 09:09:58.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
896	\\xe192e822ebd4c1e10beecc8d0856bf6eeb0bfbad4013895bd5f6a086727a0262	8	8630	630	875	895	18	4	2024-07-26 09:09:59	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
897	\\x5516d5d7a6ac27014067b2d6c931db93dcbb3dadd86bd99e80ff4827eb01b562	8	8637	637	876	896	21	4	2024-07-26 09:10:00.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
898	\\x4fdfe00e98a90a94630f589be81ebdff441b254c47a52feb6f559d5728947995	8	8661	661	877	897	35	4	2024-07-26 09:10:05.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
899	\\x8ca93af81537aa61084faa5f9e4ef78e365174dbc0a2d2f90be09572b79dfa28	8	8664	664	878	898	12	4	2024-07-26 09:10:05.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
901	\\x1117075f52d0abe8afaeb6573b4d204cebb1e9c35ec23ba3d9e7915cf9d69e77	8	8705	705	879	899	21	4	2024-07-26 09:10:14	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
902	\\x1ee33233f1ca4bd032cb2d0ed1d08adad21d29aa6e241daa64e483be1a95409c	8	8711	711	880	901	11	4	2024-07-26 09:10:15.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
903	\\xfb290c64c932049c57e584cb8755ce4dcbfa91b6676d009687e26357e3411d13	8	8724	724	881	902	35	4	2024-07-26 09:10:17.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
904	\\xab98f7c1a646db04befa0b7b2a15882f77c1ce60eeca50699bb5e34a0e654ac4	8	8727	727	882	903	12	4	2024-07-26 09:10:18.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
905	\\x325dc6fae66da1945f3210ca55535ef9fd8bb7d690e23888780f170ac3a8ea35	8	8743	743	883	904	10	4	2024-07-26 09:10:21.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
906	\\xc70416950f25b9c9cd4572055caac36b6e407c3ddc9c22e39d120179343e1797	8	8753	753	884	905	21	4	2024-07-26 09:10:23.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
907	\\x6f3f0a3cbcebe265b98b008bd3ff02b6d431f7c6d83433fb575c0264eba0ff0d	8	8774	774	885	906	35	4	2024-07-26 09:10:27.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
908	\\x33a508093ef1c1f620e3ce8923ee752be2007db021e8ec3e8e95beb7333695e6	8	8782	782	886	907	21	4	2024-07-26 09:10:29.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
909	\\x5651aa5815fa84ba67ac2cc53d94ae5834af28832bde36a0db8629f89af00caf	8	8803	803	887	908	21	4	2024-07-26 09:10:33.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
910	\\xda7a31b4c0e319de5d70c3b39df05b0df6e8dce281eff0cc89a6542c0752b2b1	8	8818	818	888	909	10	4	2024-07-26 09:10:36.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
911	\\xf49dead3ea6aa5e4b5b82e4f26599644d371af81ea782842933226dac5737010	8	8852	852	889	910	12	4	2024-07-26 09:10:43.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
912	\\x5532cc2e339d3bde1ac552a7fa2249fdb7017e01cca1e32f795a119e39611f57	8	8860	860	890	911	11	4	2024-07-26 09:10:45	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
913	\\x6fe4a6774f4ea1de4be0993c4594eee68ac75e6b05ba19e62dd3a74f5dd64f7e	8	8881	881	891	912	12	4	2024-07-26 09:10:49.2	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
914	\\xbe6856dfe55b1bb44e3d4a78aadb077e3d9137aa41c743a5c02dabe9eb0a324e	8	8885	885	892	913	14	4	2024-07-26 09:10:50	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
915	\\xcde588e0311ea0b4851fa9a61e01c25858b70ad39c96376f159751d4e55f6021	8	8888	888	893	914	13	4	2024-07-26 09:10:50.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
916	\\xd1f9a4a8c36dcec245a677f4bbf637a997f80a99702a0e7823774eaf56465066	8	8893	893	894	915	10	4	2024-07-26 09:10:51.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
917	\\xfd748ee72250ec6f91a6e2ccd424fdf3867376879f6d600f6a67a26b6061b655	8	8898	898	895	916	12	4	2024-07-26 09:10:52.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
918	\\xc9cd8a7b94233620c499bfaede52cff5df6cece7bd4708a48db348a69312126e	8	8914	914	896	917	10	4	2024-07-26 09:10:55.8	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
919	\\xaca0a955ffdbd81c68a441a205b44e67a85ded631a39ae6c0dc124dd0f9a66bc	8	8926	926	897	918	18	4	2024-07-26 09:10:58.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
920	\\x4b5be22ae1f3e93b1f4b7950a8acb5990982a2f00a84dfeca264325525bea79b	8	8936	936	898	919	18	4	2024-07-26 09:11:00.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
921	\\xa4e1d42c9792a628232ac1daf551b52c563cbff7e8e4584ffa61c968671af943	8	8939	939	899	920	18	4	2024-07-26 09:11:00.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
922	\\x710c99346066825f8f9422305c8b1e01c4556464ab653ef983d76e113784890f	8	8943	943	900	921	35	4	2024-07-26 09:11:01.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
923	\\xb57064e434d0b6fbb4d8a17085c3c2bd889229ad8f707d4cc60aceb21c6e2e7a	8	8944	944	901	922	18	4	2024-07-26 09:11:01.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
924	\\xcf641f62b0f50233ae2b724feafc098254b17fcc1ef35255becb73ad40b5886b	8	8949	949	902	923	4	4	2024-07-26 09:11:02.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
925	\\x353e843a4e6cd01cdc399e9d5ebcc3a9d6bd845bdef94a97463dba4475985127	8	8962	962	903	924	4	4	2024-07-26 09:11:05.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
926	\\x629a7880d92f4696750943ea3c3c13b6b7204bd327e14e2199efc0a1bd481a66	8	8965	965	904	925	14	4	2024-07-26 09:11:06	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
927	\\xb7da1b5301805bcc597c41e1ef441abc220535918fdee9a683fd1e0a47bd2d87	8	8967	967	905	926	21	4	2024-07-26 09:11:06.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
928	\\x442761aaf258acfa2a061204214f652b65a17a65d04686645e86f27de3a074f6	8	8979	979	906	927	35	4	2024-07-26 09:11:08.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
929	\\xb70e1c4309c14e33b34ddea26f1b169129f6e1266700d65b6b4cc6f28cef9044	8	8993	993	907	928	10	4	2024-07-26 09:11:11.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
930	\\x09da80bef95488122496a043e411d194fe93f4f924698d8ed602b1e66295e2d7	8	8994	994	908	929	4	4	2024-07-26 09:11:11.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
931	\\xca617321b7e47d5d51639f88a251b3bede246f0977cf4f206de30fb8b37c1f2e	8	8998	998	909	930	11	4	2024-07-26 09:11:12.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
932	\\x6b20191c8fd346aac851472da4b2d7a4b735318cbf6dbcf4bff4f43f37dd9ce8	9	9001	1	910	931	14	4	2024-07-26 09:11:13.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
933	\\x7e6a43c7a9b494e21f3340f6077d352a2cd1c6b8f340a77b13e07946dd749839	9	9006	6	911	932	12	10868	2024-07-26 09:11:14.2	35	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
934	\\x2dc94a922993e397e7f0d0fe2441c2172ca8157bed9a5b21e3517b2773d77d24	9	9014	14	912	933	10	17619	2024-07-26 09:11:15.8	57	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
935	\\x615370aca42356138bace51dabb43d8c26e6e83e66b5b6066deb86789c4db150	9	9029	29	913	934	10	2544	2024-07-26 09:11:18.8	8	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
936	\\xda2152ac29c841f2138d984195f89c55125e61fbf6ab2483939e80c7eead81b5	9	9042	42	914	935	18	4	2024-07-26 09:11:21.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
937	\\xf6df7046337f611afd7d2de6581ab70bb0bc4786db35d475709bdf3f1a356721	9	9045	45	915	936	35	4	2024-07-26 09:11:22	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
938	\\x8bb0720285ed6949c5fc17a8ea5054b2221eafe2aff5142941e9bd3396afdc01	9	9052	52	916	937	12	4	2024-07-26 09:11:23.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
939	\\xe27273ec4b0bb462d041bbe9ff453baa17aa7e5b6836f1346c8dc1aca06bbdf4	9	9068	68	917	938	14	4	2024-07-26 09:11:26.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
940	\\x038c4ff29638425a78b772c012ce962d929ccab9dfee58cf8f112b4ce16aa95e	9	9091	91	918	939	12	4	2024-07-26 09:11:31.2	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
941	\\x08613a096fae208cb2cc5841f7085085fe97aeffec864064e9002092a928c482	9	9095	95	919	940	12	4	2024-07-26 09:11:32	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
942	\\x79e0e81114449941e36f301082b7b7fbe3eaaee8c4c375f352b09ff439898cd3	9	9116	116	920	941	21	4	2024-07-26 09:11:36.2	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
943	\\xfddf04f0cddf4f1b297c1aec039628a184dfb7e93f9b99fc8adba9155ec81b86	9	9151	151	921	942	10	4	2024-07-26 09:11:43.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
944	\\x1642b0ed7af30b4e1c1160caa23821e2224712bcd2d4ca95db3a2a04f35024c6	9	9157	157	922	943	4	4	2024-07-26 09:11:44.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
945	\\x29bdf1f05a9b48cfd7b6702c49821878c66a423d6a21c18894209acc8784ddf0	9	9170	170	923	944	12	4	2024-07-26 09:11:47	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
946	\\xbbd9ae66b54cc80b8065d2d899babcf71f5a7ca887c20d61c3abb41a62822164	9	9177	177	924	945	18	4	2024-07-26 09:11:48.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
947	\\x2788f9747c2f43eca681a7bdf589b1e43f37686b4670855b89a71efeb7c0a617	9	9191	191	925	946	18	4	2024-07-26 09:11:51.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
948	\\xb0e20c9ccef165d78a7c137b137817c95b7602731ea9a924be5172abedfee919	9	9193	193	926	947	10	4	2024-07-26 09:11:51.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
949	\\x556ffe17e2f69a066cc57140391718c308595255e1c880cce0cac0d1ecdd0c84	9	9197	197	927	948	14	4	2024-07-26 09:11:52.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
950	\\x3f4916e720952f5b95f95bbb7e06d433679f289a577be89126f277d1058cb964	9	9198	198	928	949	12	4	2024-07-26 09:11:52.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
951	\\xaf45ff6b6562a7fce2dd71bd90d5b360b40caf58682c8f729080e99d5acd74a1	9	9212	212	929	950	13	4	2024-07-26 09:11:55.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
952	\\x323be09e575f9d430547ede9cee12e33566a0163eadfe34151ab34684244b716	9	9227	227	930	951	21	4	2024-07-26 09:11:58.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
953	\\x3b9a9337d2e18ac282e14f8b9b8f2855b129bc5e464f7f11bd5ebe885cab2818	9	9241	241	931	952	13	4	2024-07-26 09:12:01.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
954	\\x9f4b74950cb6b3dc87a469309bb29f1f4aae3dc11e5fe4386f20a2fcf05ff49f	9	9243	243	932	953	10	4	2024-07-26 09:12:01.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
955	\\x450472cee9ee7d8fcf72f6e18edb280b4f2bc5be0f29d168fb70af9cf9cab8cd	9	9246	246	933	954	11	4	2024-07-26 09:12:02.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
956	\\xa52c43fae390b69c034d45ce4d2b9b3967bfda5a5b2148838aed4bd3ed76807d	9	9248	248	934	955	13	4	2024-07-26 09:12:02.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
957	\\x03ec83800ff4c7e0735a4a15ad51b4ce886b86de63390463e07c1b54b95a82d1	9	9255	255	935	956	21	4	2024-07-26 09:12:04	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
958	\\x613ea354f8cd421199f9f321b8b4a8fe5bc5a872de34ef606f4ad363e24a733d	9	9256	256	936	957	14	4	2024-07-26 09:12:04.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
959	\\xa6173557f59398fd0ceb97f59f6ef9aa98c520bc0ee861c16652188719da6ffa	9	9258	258	937	958	14	4	2024-07-26 09:12:04.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
960	\\x4a7a2075799c6349f4b17316e5878890604cfedb5317e6d1c51699937f0ea241	9	9274	274	938	959	18	4	2024-07-26 09:12:07.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
961	\\x754ed72897c97ebe8b821622bff98996634eb6a7a311a91e80704d5c263f14ea	9	9280	280	939	960	13	4	2024-07-26 09:12:09	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
962	\\x7c951f496664b5ea35286f81836d639dfd5f9d0b534e56c95e912b9977c8f552	9	9282	282	940	961	11	4	2024-07-26 09:12:09.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
963	\\xb5a5e4c193be5b8b8a1be9dd757f57f85ef677e59a21e06f4894da98f500299f	9	9290	290	941	962	14	4	2024-07-26 09:12:11	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
964	\\xea8ac1bc0ce8f4913ae9ccd7a405c65fcc16da273393985575ba5d093ef256b2	9	9300	300	942	963	21	4	2024-07-26 09:12:13	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
965	\\xfe3d570cfb51be58bdea1cae2fbebcaa8baa0f8da535df70f3272320acc6ddb2	9	9313	313	943	964	4	4	2024-07-26 09:12:15.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
966	\\x4f55c5d5f9e0436ed0a610496bf752e75ee3285ad9dcac45c72b2398752ee7b2	9	9323	323	944	965	11	4	2024-07-26 09:12:17.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
967	\\xe6a373da0435fd982c318d87a4d21f1e4961c6a0b238e9aa3f5c2c23a1f5e90c	9	9352	352	945	966	35	4	2024-07-26 09:12:23.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
968	\\x38f422912bf2f1f9be94654db5a08299680c3d25fb56537745d2c41ae8f374f3	9	9356	356	946	967	4	4	2024-07-26 09:12:24.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
969	\\x4d6ca3062913ede62ccbf1a4dea10592beed7ca6e92825fabf70cd1222b747f3	9	9367	367	947	968	21	4	2024-07-26 09:12:26.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
970	\\x8bf33f5d43095464462d5a682d63ba2aedd4ce63243260312b809fdc542acaae	9	9371	371	948	969	12	4	2024-07-26 09:12:27.2	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
972	\\x5016b429f01e472dbe22a2b3ed95555b991bea6270d6dca365b242b83fdad994	9	9376	376	949	970	10	4	2024-07-26 09:12:28.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
973	\\x1bebfc5b13b5051a51faf71b025e808febd7a713fe3913101c241872c5bb0920	9	9379	379	950	972	12	4	2024-07-26 09:12:28.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
974	\\xdfe91e7c014526e6435e768f44215f13fb0d28b4120dc8c30314652b9f61b227	9	9381	381	951	973	35	4	2024-07-26 09:12:29.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
976	\\x47b040a2470dac0bd1b02fdde7de412d5c079acdb443ab94ca523f414fa6acdb	9	9412	412	952	974	4	4	2024-07-26 09:12:35.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
977	\\xb72a73cb59e5ae837440b9a63376ba395c0fc95fd0d5468a6411f06673fd658c	9	9429	429	953	976	12	4	2024-07-26 09:12:38.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
978	\\x6421928917334aaa6ed469f6cc492ce0d977a245127af3776576fcd682bbc40e	9	9466	466	954	977	13	4	2024-07-26 09:12:46.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
979	\\x0413ca5f21d3b4e0f6f1477b70d251a78e8005767f9e42d18869db2ff406e3ec	9	9476	476	955	978	4	4	2024-07-26 09:12:48.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
980	\\x66d30e5f00d58bfdb0060c056c4baf6e6eae38b5e628d15bd690648164521819	9	9477	477	956	979	4	4	2024-07-26 09:12:48.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
981	\\xd83801b84c2de1a342ef8eebf1c104a7073bf35c08b37eaae321da7aee937768	9	9509	509	957	980	21	4	2024-07-26 09:12:54.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
982	\\x0a33a0b4a328859782cf8ffe35533e64406385c2644b278a3c7a10ac571ceccd	9	9512	512	958	981	35	4	2024-07-26 09:12:55.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
983	\\xf0ae57e46661af42ef3d0dec6aee01bcf17a300d1c45d9673d34b0ff577e2a34	9	9524	524	959	982	12	4	2024-07-26 09:12:57.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
984	\\x3c762e83ad053d032e3cd311c8ad13224a54b5e8ace7c4de249c83788770946f	9	9539	539	960	983	4	4	2024-07-26 09:13:00.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
985	\\x4bac6a823b998022e1dbbaed7d6705c324c62f2ae10b445c77254e5bad7cf0a1	9	9560	560	961	984	21	4	2024-07-26 09:13:05	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
986	\\x27ca20466537b632d8dd1a85198029905be662fa328f7801281634e958c399b1	9	9579	579	962	985	10	4	2024-07-26 09:13:08.8	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
987	\\xd3736ea41906d2eeb294cd55ebbb3d4d9cc23fea5325dec7d4e4a08355bb3f2c	9	9601	601	963	986	4	4	2024-07-26 09:13:13.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
988	\\xbd9aceaeba38030ff9450091470315d3a84dd07f6582445ff9f0f60836ec7692	9	9606	606	964	987	21	4	2024-07-26 09:13:14.2	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
989	\\xe0d327b16db8bfb0389233c157514676e997bac1b0a7c55910a30fb8f2762419	9	9612	612	965	988	10	4	2024-07-26 09:13:15.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
990	\\x23d0eb7036e6acfcabe43ec6e337bb86b72c014af4cc9838776452e4da8712fc	9	9617	617	966	989	12	4	2024-07-26 09:13:16.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
991	\\x27d373c45e4c23f90821a5bcc41bea5976f5d98fd87e0b406eccbb03ab3f5d81	9	9626	626	967	990	14	4	2024-07-26 09:13:18.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
992	\\x6cfc5a2b3d0c0a808412bbed8ebfa29cc91418e7195a650abcce880d04246120	9	9627	627	968	991	12	4	2024-07-26 09:13:18.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
993	\\x13c66c138fee3f42677bffbbd8303aa86cf73c485bc5d091ed7a2ffaf6ff5f6f	9	9635	635	969	992	13	4	2024-07-26 09:13:20	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
994	\\xca8a78865814dd7f8ab7d24de051ecfcb8d421f3222ecb81003268de3e63d008	9	9641	641	970	993	13	4	2024-07-26 09:13:21.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
995	\\x9fb84b674725fa4aed1900fc774433d8352f70efd7070eddaa3e39049dd97f31	9	9644	644	971	994	12	4	2024-07-26 09:13:21.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
996	\\xaefd07f9eea0d59fb742a8e1d6fc39e14356b745ba0158da473cc0597e9b0c3b	9	9652	652	972	995	35	4	2024-07-26 09:13:23.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
997	\\xc3aab18de51a52673246ef40eafe3bbf780c70af7dc26c8ece6c86650ed90c42	9	9674	674	973	996	12	4	2024-07-26 09:13:27.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
998	\\xd7686e94a341b37f7718b78d9973387b78f07fd3e8c9972be7492029a24b9a2c	9	9686	686	974	997	13	4	2024-07-26 09:13:30.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
999	\\x24463dc04f6698f2885af75bdf541c83e6e3399f134379667f834073dfba7030	9	9707	707	975	998	11	4	2024-07-26 09:13:34.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1000	\\xe53de0f7ad3bf5cb40754df40080ba992332beaa62f99dd33b712fd77161762e	9	9708	708	976	999	12	4	2024-07-26 09:13:34.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1001	\\x1e6f07a4bf9e4158e6b6def710b8e5e15bbfcf144856e1caff7addc99fea7dab	9	9717	717	977	1000	4	4	2024-07-26 09:13:36.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1002	\\xb90cfca27980c656566fec31b8666e0b970d99c3de45e80a2f9ad2762919ef76	9	9734	734	978	1001	12	4	2024-07-26 09:13:39.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1003	\\x016c15819013b48d0ed41fab6f063ffcd9e7a6f29bf5a80fa0639bd495882fc6	9	9736	736	979	1002	11	4	2024-07-26 09:13:40.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1004	\\x58d9a81f015619a2c3fdd11d9c4afc2ae2377fd2e6d8eb2a3cdc9b1f3845e4ef	9	9737	737	980	1003	4	4	2024-07-26 09:13:40.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1005	\\x3030d1c0f7dd0c739d0b10a546f48940ec91233753ea40891574023a0c32e35c	9	9740	740	981	1004	13	4	2024-07-26 09:13:41	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1006	\\x7d0c6109f12dea57fab21287ae2962794b9a2b4c584350efa814bc7a687612d3	9	9746	746	982	1005	18	4	2024-07-26 09:13:42.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1007	\\x5ebf2de5e662a7ff53f528c2ba0d11dabeda84c95311e42fd78b70ea920a4ca4	9	9767	767	983	1006	18	4	2024-07-26 09:13:46.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1008	\\xc462b3fd59622ff7b56d67cd87f71953b8a9ac04fef985abf241f1bce0a17682	9	9770	770	984	1007	13	4	2024-07-26 09:13:47	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1009	\\xe94ee797cfd8c07ee3480e1af1be2ebb1b2b069b02691059dc65cde176a45908	9	9791	791	985	1008	4	4	2024-07-26 09:13:51.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1010	\\x5c6f66ff4ac23f83a3f56f89be47f0a7d259fc2201444cb4456578edb3b8c4a9	9	9857	857	986	1009	18	4	2024-07-26 09:14:04.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1011	\\x1ebbc5e7ce5ea6ba2c4cdf0594ff6ce79d8dc04d0a2171fca0c0666224d63e39	9	9858	858	987	1010	35	4	2024-07-26 09:14:04.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1012	\\x708dbc84434d308e5709e1438e00650a57056e65441f7fbb22811ca85bccdd3f	9	9867	867	988	1011	12	4	2024-07-26 09:14:06.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1013	\\x860ba839b978b774a8dd0645ffee7949833d04832d353c77d664fce0bf8a977f	9	9870	870	989	1012	11	4	2024-07-26 09:14:07	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1014	\\x1f9eaed0fa0d132daf2537df8a98df0e94e33a2ba84d91dcca4c3b800fc2e174	9	9894	894	990	1013	4	4	2024-07-26 09:14:11.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1015	\\x61e47ca90cb529e262e86cf39f224f7d630fc68463672ef7ec0e0095148a0d0f	9	9908	908	991	1014	21	4	2024-07-26 09:14:14.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1016	\\xe318f1ef367045966860e57a7835827fc53d02ef25ae472a7d36d1ab279e52ab	9	9915	915	992	1015	14	4	2024-07-26 09:14:16	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1017	\\x3efdc3ea056b339053b4239ce59d502408a24e7d4cbde1ff5516b277bc10b40f	9	9917	917	993	1016	18	4	2024-07-26 09:14:16.4	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1018	\\x2490f7e050a9fc45e08916cb2050016439b027cec4f2ef130853d852ae9a0663	9	9924	924	994	1017	14	4	2024-07-26 09:14:17.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1019	\\xae2ce1c1dd9dca70d7365fb4c59ac007d946d46b0811b39d97e25868b63fb4ef	9	9932	932	995	1018	14	4	2024-07-26 09:14:19.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1020	\\xfb695ffbb4b6cedef91695b7bc2a85decce305d873bd3e4d6c00a314a5cbba92	9	9933	933	996	1019	10	4	2024-07-26 09:14:19.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1021	\\x3c9194e8ec39c91c7383a5ed6dcdd21e6d854cce2f5453fd6904106b91ded02e	9	9941	941	997	1020	18	4	2024-07-26 09:14:21.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1022	\\x8b66e622dc712c2ff2f06300d09fa2c788ef3eb050b606983b958b09c0a1b942	9	9946	946	998	1021	13	4	2024-07-26 09:14:22.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1023	\\xb31ba9645490c767c24ea5a614180030098098c69a09324c784dbc055168e6b1	9	9950	950	999	1022	4	4	2024-07-26 09:14:23	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1024	\\x8e9bd6f7486d5e02e23d724d9af01f7e159a9fc37cb0dbd495473507d9f045fe	9	9973	973	1000	1023	18	4	2024-07-26 09:14:27.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1025	\\x41b2685c0893b69787133be62859099ef338b5e30ee337f5fdf08ca56201ce64	9	9974	974	1001	1024	4	4	2024-07-26 09:14:27.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1026	\\x9b71c97cb4d53699b353f28e2aaaa8c81c5e8cc630bbe37ea9b25097ae9e1042	9	9980	980	1002	1025	4	4	2024-07-26 09:14:29	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1027	\\x57ab237b1aa4148db54adeb75619a7c6285e04e4c0da4dbade46a3393297c120	9	9989	989	1003	1026	12	4	2024-07-26 09:14:30.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1028	\\x575c58ae601b2543648ddac286f0d5260f5d57cbd8b1a40059fc847f83c240b8	9	9993	993	1004	1027	12	4	2024-07-26 09:14:31.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1029	\\x9c824193ef70fac763cde1a02d12d49490aa846a1a3032bd6c15eafcd7b03a87	10	10021	21	1005	1028	4	4	2024-07-26 09:14:37.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1030	\\x3ee3463c2fa0212b8d65f4edbfc3d7ba91c985f7c0abdfe2b79eb11c8981cfbc	10	10026	26	1006	1029	18	4	2024-07-26 09:14:38.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1031	\\x42d2e1f342e0a40b4187d3f08f399b3d3e6afad7561d161da25302b42e7cd269	10	10034	34	1007	1030	21	4	2024-07-26 09:14:39.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1032	\\x69d1179cd831525a340ecc35df9330ff99810a8520cbb9b3db37d648bf7a950e	10	10043	43	1008	1031	18	4	2024-07-26 09:14:41.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1033	\\xf8bb5cc07aa0eef3d45df92a50098af430102af6d5d5a674a9b09063291ef28a	10	10044	44	1009	1032	12	4	2024-07-26 09:14:41.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1034	\\xc8f46fa6ada0803f2d1f634dbb3ecf7af472f961e83cf760d65292bffe125646	10	10064	64	1010	1033	12	4	2024-07-26 09:14:45.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1035	\\xd3ca2d0450a89c2260a396d584276241e80a0e47cd8078875552a07eb653dc3c	10	10072	72	1011	1034	14	4	2024-07-26 09:14:47.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1036	\\x3b8f8dad1d45dcafed3ad5a741a96f382b6ae727d02b46ec406064b0ff7caa07	10	10106	106	1012	1035	11	4	2024-07-26 09:14:54.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1037	\\x5f67b1c9ed71152db09f185ad5e42379097792bce96f7d4748285b889f227d09	10	10109	109	1013	1036	12	4	2024-07-26 09:14:54.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1038	\\x4928923cf278835474321a2b710ee9e938de36faf897b4084431a3ec0c30aa89	10	10116	116	1014	1037	11	4	2024-07-26 09:14:56.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1039	\\x0a0421629dac8e06835a8222a844af3567d79f9b9ce6ecd602df39d9d698ecdb	10	10117	117	1015	1038	13	4	2024-07-26 09:14:56.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1040	\\x2c99d5ec69cc1ecfe8219a4b47ef60c0a3fbb01dc6b787074bcf2ebe78ad50d2	10	10131	131	1016	1039	14	4	2024-07-26 09:14:59.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1041	\\xdd1dbd66d1e438b4c13de93ac6c71d1f431d3d6999ccd44d9a6374d0db871e20	10	10132	132	1017	1040	11	4	2024-07-26 09:14:59.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1042	\\x0516052951a1c1d7e477440c9a5cbb35f17df4893e55b81cc5e1db4da1201ff8	10	10149	149	1018	1041	13	4	2024-07-26 09:15:02.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1043	\\xfff2ffce1bda536bac2a5b1bebd93fa7edb116e39b666a561ec327d286580b5d	10	10157	157	1019	1042	4	4	2024-07-26 09:15:04.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1045	\\xf21954e1c2ee55ec8f004f7b6143b366dab1172101d1792701a8b5dbfe7d17d8	10	10163	163	1020	1043	35	4	2024-07-26 09:15:05.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1046	\\x616d74de0fb86df5cd9d801e4ed0aa407cb2c7c99bbbc7454f1a18e1ff8fa427	10	10169	169	1021	1045	35	4	2024-07-26 09:15:06.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1047	\\x9c4fe294f419535aa342d09d274b81087f9528b98b7e373921cce6927c988547	10	10170	170	1022	1046	14	4	2024-07-26 09:15:07	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1048	\\xd5a14710575d7e9d9d62c5d76782a02e15b456e185713c693f391970b55b703c	10	10172	172	1023	1047	10	4	2024-07-26 09:15:07.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1049	\\x881a378ef71ed650da16239983eb96fc03c6fd39632f4e0f81a771f7239a4a6c	10	10183	183	1024	1048	14	4	2024-07-26 09:15:09.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1050	\\xcfe333c2509ac0d58c099f8d927acfd059eb8b6b3327efb25e98e65fea320ee4	10	10188	188	1025	1049	18	4	2024-07-26 09:15:10.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1051	\\x3f4033b8fed90a8e6aeda4ac1fb88c9135bf0f18cdbc1e46de926dea3232fb69	10	10200	200	1026	1050	14	4	2024-07-26 09:15:13	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1052	\\xacc483a653175f5242806c147d327272f0c1e7fd50643f5fa5789c9c1cdb3707	10	10215	215	1027	1051	14	4	2024-07-26 09:15:16	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1053	\\xa62b4218969bf54771933b20d420fc1f9e48a8e310cc75cbcdd3f1f0655bad0a	10	10217	217	1028	1052	21	4	2024-07-26 09:15:16.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1054	\\xbc03a703581e3699479f180137c9a87dbd6e3c40897aa64701ca533049dd3430	10	10226	226	1029	1053	13	4	2024-07-26 09:15:18.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1055	\\x34b516912bcdd1578d8ddd49884a73c000a7d070d626340a7e8f701b44ba6678	10	10230	230	1030	1054	10	4	2024-07-26 09:15:19	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1056	\\xee004a8b61fa9cc13a5abcfc4d35bfc20a9e0e7d8157c925cdd350c76137facd	10	10239	239	1031	1055	18	4	2024-07-26 09:15:20.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1057	\\x07948172dccadb2623a5a0d241d8bc1c7bb3bd19ee5935c6559d9534324648a1	10	10241	241	1032	1056	14	4	2024-07-26 09:15:21.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1058	\\x1efeac6c2b4932e3c9dda92155001fa75de8c1d2acc6efc5ddc6387a7732b2ba	10	10266	266	1033	1057	14	4	2024-07-26 09:15:26.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1059	\\xb33111a952d38138628711ccffd4dc2412fa17ca95704c1aee7eb267670445bc	10	10274	274	1034	1058	10	4	2024-07-26 09:15:27.8	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1060	\\x41877651630ccdcdd4ba27929d1827af5f7e7b0c21c11a51eb154153b7f72ab3	10	10278	278	1035	1059	11	4	2024-07-26 09:15:28.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1061	\\x07e33d75f31fb2fda333b515a617facdd2fdf31cfe4df080d6fb55f844b163f0	10	10283	283	1036	1060	4	4	2024-07-26 09:15:29.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1062	\\x247d95deadeae2cc3753508ec36c1a6cfe34ffd54119c2cf36d296d93eeb0f2e	10	10292	292	1037	1061	12	4	2024-07-26 09:15:31.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1063	\\x28b550a7ee02fd954fd6fdfcffc8079a19f386d7e3ebbf9880a4acadf3201bce	10	10300	300	1038	1062	18	4	2024-07-26 09:15:33	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1064	\\x18d26a1702a57e61f45225429ac0111f56847043716dcac12a849efc6717b3cb	10	10313	313	1039	1063	11	4	2024-07-26 09:15:35.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1065	\\x6f1a97a168b9c4a04d283b5ddb20f334701da538924b219b9134f5b47916fd69	10	10317	317	1040	1064	12	4	2024-07-26 09:15:36.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1066	\\xb5ff21f8822fda33620e3e69bc58a868457148405e22a192b2fe4d20d2395064	10	10335	335	1041	1065	10	4	2024-07-26 09:15:40	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1068	\\x4e2bd4e4846ac820d5c866e72ee746a9a24a1991523d5c158d8c2e232bdffc66	10	10344	344	1042	1066	4	4	2024-07-26 09:15:41.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1069	\\xf54371c3599c69a5dc73e6dee7fd866eba8a8623e6f9c10d751d842da11368c7	10	10346	346	1043	1068	11	4	2024-07-26 09:15:42.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1070	\\xef044c75881710fb1e107d91095208f8528653845765ca2c514ba556cf429bcd	10	10349	349	1044	1069	12	4	2024-07-26 09:15:42.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1071	\\x7de6ad51ea869922c4af1ed499b3b36ca83431da024eb7b93e16299b37ee428a	10	10351	351	1045	1070	13	4	2024-07-26 09:15:43.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1072	\\xf65e744ff2fa15b9abeb1f701ced7571c2eb2cb4364b92517bd163d08b95a611	10	10357	357	1046	1071	4	4	2024-07-26 09:15:44.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1073	\\x23f1987d566926bfee3ff4ae8dc938c041a8e395ac6e02aa38cb4a10ad5d70f9	10	10374	374	1047	1072	4	4	2024-07-26 09:15:47.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1074	\\x9155d37b819eae4183de68a6320a87e77f3a0efc51407858c2823151c157c947	10	10396	396	1048	1073	14	4	2024-07-26 09:15:52.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1075	\\xaa4917da62f4463210a856ec283494870306d3a66edc97968072c4e56a73e484	10	10403	403	1049	1074	13	4	2024-07-26 09:15:53.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1076	\\x9eca7d410cae5a86e7267b3f7ec432665d5dc58aecc4e9860024853e19cb371a	10	10411	411	1050	1075	12	4	2024-07-26 09:15:55.2	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1077	\\xc8c529b9947cce458cc3ef8cea4ec50294ca3c6e93f2ca1ee26b9c2c03d1b48e	10	10419	419	1051	1076	14	4	2024-07-26 09:15:56.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1078	\\xe8b3e9685949c0aa01c4945bbe2cb1a3f4dd172f3e100e1694de4d10706b16e7	10	10424	424	1052	1077	21	4	2024-07-26 09:15:57.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1079	\\xeca5cdd5c143a07bfc0616b83e2f7af6e58f6bcca99129638212fa96db6b4b41	10	10435	435	1053	1078	18	4	2024-07-26 09:16:00	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1080	\\x5ad5bcf52e359b002f068f318a07f697fb0b7d4136a94dcce2159ec7bdc434f7	10	10439	439	1054	1079	13	4	2024-07-26 09:16:00.8	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1081	\\xdf672ebfa99910b7076e220b12b9afaa2665110f2772ea78d749903bae2fbddc	10	10448	448	1055	1080	21	4	2024-07-26 09:16:02.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1082	\\x4f307dbd83bcd382a0335908e78c43045c97af0745a590ebb632b7063ba2beab	10	10482	482	1056	1081	14	4	2024-07-26 09:16:09.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1083	\\xac697a44bf6dcbea7088b09364c7ea32e0c1c54a6d7b644ad1ccde7e66b31d56	10	10492	492	1057	1082	13	4	2024-07-26 09:16:11.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1084	\\xa99550c9eb133fd2acee0b707a1f4771d60392a9ca5d3bc139581e726148bde9	10	10507	507	1058	1083	21	4	2024-07-26 09:16:14.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1085	\\xe6113f17b87be4c1e0043dbd118eb5b3e317305f616fa7270e64890da0342cf9	10	10510	510	1059	1084	21	4	2024-07-26 09:16:15	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1086	\\xf57c54e3873650c823cc9cdafe824abea62b6a0994393cac3d64a7ca433f8773	10	10526	526	1060	1085	14	4	2024-07-26 09:16:18.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1087	\\xa7c2600a775893f22b7a9a3adbb08086cd354d9d2f625f33f7b86b61cbcf6e7d	10	10538	538	1061	1086	11	4	2024-07-26 09:16:20.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1088	\\x30afeb5e0f155cf6708d3e1cf7891ece2b5b59b1a7bcb5ff6e577a71b7d5367e	10	10556	556	1062	1087	13	4	2024-07-26 09:16:24.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1089	\\xf705339146c4128f78610278bb45ce107fb8a44efa8b23dfeb86941bdf722e64	10	10566	566	1063	1088	4	4	2024-07-26 09:16:26.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1090	\\xfcb09f1e48db16941d1dc282bc14e5fd6f584b9d4eabde20e0766a04d87becf5	10	10567	567	1064	1089	11	4	2024-07-26 09:16:26.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1091	\\xf429295f606aaf014a7bb460d24a9132e54bad4caeb1eaccedf4f9a304fe7c63	10	10604	604	1065	1090	35	4	2024-07-26 09:16:33.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1092	\\x65ea1b6373bd5df47ae252e17423f512c24f4ed217e7844eb8e5a5eb3353362c	10	10605	605	1066	1091	12	4	2024-07-26 09:16:34	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1093	\\x4a5d505081c14ae3575a6df98f3f2c6d8a924cbb8292c752405b53a709b3ad63	10	10643	643	1067	1092	14	4	2024-07-26 09:16:41.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1094	\\xfd73b03537592b9b36b8471349fce99f8f8982bdb9dd74380ad31cdc224c31c0	10	10653	653	1068	1093	18	4	2024-07-26 09:16:43.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1095	\\x94c79e9edf39e8febd66c3ac46236e85b6a53e376b6ea2c2615a32eb41997121	10	10677	677	1069	1094	13	4	2024-07-26 09:16:48.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1096	\\x9103d262e0ef049aeff8c9d2d19ebd1d1dfec8dfc3a6f914cfc6ec40b09ff50b	10	10688	688	1070	1095	12	4	2024-07-26 09:16:50.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1097	\\x79a1437f748542dd51d37a9088a33cb27e0329ae74f964b003eb3ce303698115	10	10692	692	1071	1096	21	4	2024-07-26 09:16:51.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1098	\\x770b7347b5d62a12eec4ff8d4d484a69be800d74ee5afdc581767ab2f55a8a34	10	10707	707	1072	1097	35	4	2024-07-26 09:16:54.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1099	\\x8d14559315c76a9e8e94527868421c9c173d143cbb8526430df1504a89fbed0b	10	10722	722	1073	1098	13	4	2024-07-26 09:16:57.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1100	\\xb31dc782bced0d0a8129142d8ed133a06321b345cd95feba0b8f3e246aa8f77d	10	10725	725	1074	1099	4	4	2024-07-26 09:16:58	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1101	\\x023e37bba993ffcc80558582fe813e6ceddc2df8f187d4f852f2c5c7da5bdf30	10	10729	729	1075	1100	21	4	2024-07-26 09:16:58.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1102	\\x59250e7cd89a08ed6dddf356c5612526b48bd7b9b15824b58e3de2ac11bdfddc	10	10740	740	1076	1101	12	4	2024-07-26 09:17:01	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1103	\\x0fff4309d1ff276542c1873bb203a9d292a0c5a8e3c7ae5fcf8dd1e53dca6376	10	10743	743	1077	1102	4	4	2024-07-26 09:17:01.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1104	\\xc3b88ca0df1fccda665f0af36d8d9040e8ef4e5d0341236752328426bc3a68e4	10	10777	777	1078	1103	11	4	2024-07-26 09:17:08.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1105	\\x2c0b192b91342a434f2b7464e1e2ef03a1ecd5ee30190f0f1628c62fe9f20738	10	10782	782	1079	1104	21	4	2024-07-26 09:17:09.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1106	\\xa908d5857b0dabedbfb8112fa4416638d848d54adeb8d31cdee5492d1bf13c57	10	10785	785	1080	1105	11	4	2024-07-26 09:17:10	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1107	\\xa5361e38df5553d9e384a30a5234e8544ab67eade538cc5d718230c84c541da7	10	10796	796	1081	1106	11	4	2024-07-26 09:17:12.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1108	\\x4cd290b343fc0b62eaf521d728135ecdf869ed67c9486eed7e5898c58b8c494e	10	10816	816	1082	1107	13	4	2024-07-26 09:17:16.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1109	\\xfa8e8b29f3e78a6a233a2260054ba8ffc7afd230af5f6e5423fb1cc1a5c9707c	10	10821	821	1083	1108	12	4	2024-07-26 09:17:17.2	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1110	\\xbc8204e6ec87cc5e6e0f64b85fd818819e3c31dcd849f73753ce58373fd36800	10	10836	836	1084	1109	21	4	2024-07-26 09:17:20.2	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1111	\\xc5d07645678fab11307a3e7c4100c9f9196b3d2c4da956977c0a9ea2acd848fb	10	10841	841	1085	1110	4	4	2024-07-26 09:17:21.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1112	\\x9d30df8cb2b69c4b16c27a739fadb705922aa43de0ba6075663763551786bf3d	10	10853	853	1086	1111	13	4	2024-07-26 09:17:23.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1113	\\x033ffd6f5c8c8bffedf4aa3c76b27d3f2a0eebb1a5ca3a21dd1e321f4a4acd91	10	10857	857	1087	1112	10	4	2024-07-26 09:17:24.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1114	\\x7beea66ddf610cedfa3ade1e4138a53f2e850366e85f653c5fe4841bcb8b1ea4	10	10861	861	1088	1113	4	4	2024-07-26 09:17:25.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1115	\\x093c1343b346a01d92644d0e83d066dbbce35445974ff07b55811db0329ad083	10	10881	881	1089	1114	35	4	2024-07-26 09:17:29.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1116	\\xdbb1556240a50ec5dbcd16ab92668130972de9d65ae5db2a69b256daa1d130d2	10	10882	882	1090	1115	21	4	2024-07-26 09:17:29.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1117	\\xb2abf34d3e18a6a47a9b65c42df2fb35b831d593b52d8e3f105eb42565fe52fb	10	10889	889	1091	1116	11	4	2024-07-26 09:17:30.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1118	\\xd1a0d361a06d68df761459f48d9bf43e47f3421a9a4241113b45f707f6fc8c27	10	10902	902	1092	1117	13	4	2024-07-26 09:17:33.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1119	\\x70ee306a23dd3aacabdfde5453e41db7dfd7928893f251b1fdac7d56338b7468	10	10905	905	1093	1118	14	4	2024-07-26 09:17:34	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1120	\\x8759c3c48e362dffa3b7d59a2f37b3fe48cc6cebbaed9d599a47489b5304f305	10	10909	909	1094	1119	11	4	2024-07-26 09:17:34.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1121	\\x4f2bef3bbde6e4a592cb2344b47591664c5d47ac983f0f2db847e8be22ff1713	10	10912	912	1095	1120	13	4	2024-07-26 09:17:35.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1122	\\x44399dae6a7ca2aadb68e18c8d80395f9cadbb428a02709daa7e69e0cd6a7dfa	10	10927	927	1096	1121	13	4	2024-07-26 09:17:38.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1123	\\x57bc0379f69e3290e85f69662b9ab7ac40567f3e1978fbb1873f6ffde2427891	10	10929	929	1097	1122	11	4	2024-07-26 09:17:38.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1124	\\x20d8b0e0911de2812632c630db063bbfe240e3c42fbb817731c247e891667b85	10	10950	950	1098	1123	12	4	2024-07-26 09:17:43	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1125	\\x8ff69d36569bc126f5fc1dece9e71b1be0f3a6d4c30a879fc5496ce043f76ce0	10	10976	976	1099	1124	14	4	2024-07-26 09:17:48.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1126	\\x41a878d88ce73d8df61c2d8bfc3b363344bb75822a42e6b83d9a5cb9cc52eeb4	10	10977	977	1100	1125	4	4	2024-07-26 09:17:48.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1127	\\x04aec80a2fb99271175526b39a6072a1624fc5efcd265b5a668f8a8ec1fed27c	11	11016	16	1101	1126	18	4	2024-07-26 09:17:56.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1128	\\x45ca31d2c852e73665f6de42ae0eb032e370ed8f8a80bbe6f85c7e0adc493834	11	11019	19	1102	1127	11	573	2024-07-26 09:17:56.8	1	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1129	\\x90f099344cfa629058f9c3b17f017655dc35215fe90716aea752280a97ce8a06	11	11026	26	1103	1128	10	4	2024-07-26 09:17:58.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1130	\\x4f8fd5cb4f6bbf0bb58212838f05b1a76a423f0410cf7baae847aa178bb82f72	11	11029	29	1104	1129	35	4	2024-07-26 09:17:58.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1131	\\x589bbd863c8d2386af5ce322c577844e6b868c71fab35668f87c30e647ae07cf	11	11054	54	1105	1130	35	4	2024-07-26 09:18:03.8	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1132	\\x511a63356ce86578e08652b01fff612d05c7abb79c42301c0f98e9c836fff238	11	11077	77	1106	1131	35	4	2024-07-26 09:18:08.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1133	\\x23419de8242b2b7ac65e4d92086a476dfce939d133081623c515830570534b6e	11	11081	81	1107	1132	11	4	2024-07-26 09:18:09.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1134	\\x980f64c45334cff2b71dd6308c04ca24b872abdda1cecaf35d1ff4ae1523fdb3	11	11087	87	1108	1133	4	554	2024-07-26 09:18:10.4	1	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1135	\\xcd4eaeeca0ba363a0393688fbd8ba488e4a310c13c180c5d8c80922520cc0f98	11	11093	93	1109	1134	13	4	2024-07-26 09:18:11.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1136	\\x29e3f50c8d396f48efaf5007a6b1729b3cdc138be837b8e37782902081296bcf	11	11122	122	1110	1135	14	4	2024-07-26 09:18:17.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1137	\\x17ae0be4c537a1af987a3cf21f7f9693f9287d65869ffefbfab033e59976995d	11	11132	132	1111	1136	12	4	2024-07-26 09:18:19.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1138	\\x32e7d2f7ae7bb2ab987fd593eff5140a3663299b63366b1a802e8810037048f7	11	11134	134	1112	1137	35	365	2024-07-26 09:18:19.8	1	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1139	\\xd52d675f3dd48b82ddb22e8e0d37f28f7f7551ec152b4d875f3cfc4d4e412f67	11	11137	137	1113	1138	11	4	2024-07-26 09:18:20.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1140	\\xb4a52bea6faf3fbbeb3ec7db8d1bc0f2f8fc661da07f8853e41a1ec3f86a2056	11	11150	150	1114	1139	14	4	2024-07-26 09:18:23	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1141	\\xc759b1e248d9d2239a4dc3d378dd0148407c0afb6e921aa941b63e627035343e	11	11178	178	1115	1140	35	4	2024-07-26 09:18:28.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1143	\\x1b2b8fb85e901b7b85011bf6990ddf8f68360d7cc43414917143fd2bee876725	11	11190	190	1116	1141	21	496	2024-07-26 09:18:31	1	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1144	\\xab6674780f1481370577b8ab68f99fc2942a747fc96967c89fef17abf5d45066	11	11199	199	1117	1143	12	4	2024-07-26 09:18:32.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1145	\\x6ebb90392aff0d6ddecd233c96fa65f232a0c184a5ecea509fcc227d1b2299c7	11	11213	213	1118	1144	35	4	2024-07-26 09:18:35.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1146	\\xf6fc8b9854c2f22c53827dbb8d57f52e48fd0f44194d1d414d4d7048a2dbe611	11	11253	253	1119	1145	14	4	2024-07-26 09:18:43.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1147	\\xad919fca2414677b7e08258d6ebcef866c95d8dbf5c91fccb8ff6f29571a7bd8	11	11258	258	1120	1146	18	634	2024-07-26 09:18:44.6	1	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1148	\\xc23aee522cd35d6e4d94b6190e01c2799c183cca8e7ae2a1f646adff7da3ac98	11	11266	266	1121	1147	10	4	2024-07-26 09:18:46.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1149	\\xf1eda1aaaeec86e78325ae0091930437a20f37f91fdc0182a2cea5ee7d83d6be	11	11280	280	1122	1148	12	4	2024-07-26 09:18:49	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1150	\\x4ca900e7beb2f0afe7684f5ec092b9cdb832639438c12c2453510efdaacd537c	11	11292	292	1123	1149	12	4	2024-07-26 09:18:51.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1151	\\x76e493615703689524f1544faf9fb0d5561e56b13f24fbe0b5c89ab01ab2b386	11	11295	295	1124	1150	11	410	2024-07-26 09:18:52	1	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1152	\\xe64c178a667d7027280f2221b10aff824784cd7892c57ee4b8300cd3985af215	11	11302	302	1125	1151	14	4	2024-07-26 09:18:53.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1153	\\xb938da431326b7f7d4efa1f87ebffbbaa5e7947b3218c6ba08d569cce046c84b	11	11309	309	1126	1152	18	4	2024-07-26 09:18:54.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1154	\\x7b8395550a9236db4cbb29382ee255836e7617c7c913c7def169bfa1ebacaf0c	11	11333	333	1127	1153	21	4	2024-07-26 09:18:59.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1155	\\x5ecaa92fb9dd1ec8b81a6bf796c2f94ecdd3c4bdd187b4c45159bfafc0ada3ae	11	11362	362	1128	1154	12	492	2024-07-26 09:19:05.4	1	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1156	\\x8f64ef57e186d54cd1c3e722739089b50726cbaf408768a2743d5094d4417b00	11	11372	372	1129	1155	4	4	2024-07-26 09:19:07.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1157	\\x2d365316d74cedf0e87ade276d1ec278b933bad7b6e8e3edf7d98cc8142bca78	11	11388	388	1130	1156	21	4	2024-07-26 09:19:10.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1158	\\x9eaafb8bdbece7cf40ce253b38e3db30db0748368885f9725b12149ac2a0e4b9	11	11399	399	1131	1157	12	4	2024-07-26 09:19:12.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1159	\\xf8b4528f01afa279229aac1a5e17eb32b05301e5a05705e4072659a37e1eb051	11	11425	425	1132	1158	12	1704	2024-07-26 09:19:18	1	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1160	\\xb6aea341938b04120459393694505935733241bf694cd23f6262a4c8f74234f5	11	11429	429	1133	1159	18	4	2024-07-26 09:19:18.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1161	\\x5e5c1c1ae9153a8521c25d4855d838afc91b2e05b22618ff349ddeda56f4c923	11	11439	439	1134	1160	11	4	2024-07-26 09:19:20.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1162	\\xaf233103087575a7eb49f71c21bee36a82e0122e045ae6afd25b2a22e604f1aa	11	11443	443	1135	1161	12	4	2024-07-26 09:19:21.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1163	\\x8767f852a48994ffde54fa9143bac5ee96837f458c9e2785d47884bcc0e4c818	11	11456	456	1136	1162	18	1519	2024-07-26 09:19:24.2	1	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1164	\\x23e96b41182bb881fe5bc3cb6194b83c82722933c552a23261745fa9849b6e60	11	11469	469	1137	1163	11	4	2024-07-26 09:19:26.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1165	\\xc6ef3e631d6da95086416e14f37110a31edf387b486901fdbea660e846c4ad92	11	11471	471	1138	1164	11	4	2024-07-26 09:19:27.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1166	\\xa2dad3673f3e340674fe5cf5c78250dddab8e744320bee6ed8117d0c88556e3b	11	11484	484	1139	1165	12	4	2024-07-26 09:19:29.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1167	\\xab67abc3fdaffba64aa5ae21b1a56074f6d292f1e3ae7808e36b01ea99ea5767	11	11508	508	1140	1166	10	1434	2024-07-26 09:19:34.6	1	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1168	\\x452d7c5115307c4f4c6fd73c3d1ec10e4215ca8cc8c7eba2af21b36556244689	11	11532	532	1141	1167	14	4	2024-07-26 09:19:39.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1169	\\xaa699a73efbac94363ae0fe6f1a850f8bba347c059cdc7e5f82a27f6c7faceb4	11	11535	535	1142	1168	18	4	2024-07-26 09:19:40	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1170	\\xeabd7ddd7d1e7f3fcc13a48fe6996a51ed1dbf78a264ca111c0c746b96604c1c	11	11537	537	1143	1169	13	4	2024-07-26 09:19:40.4	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1171	\\xeb53f043af90a82311dcf1fe8a16a582795f9c888e5ec3a8f5bb69097b600707	11	11548	548	1144	1170	18	716	2024-07-26 09:19:42.6	1	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1172	\\xe130efddb1a82982df01db630403462202de404cc12367f6cab76723faefc998	11	11550	550	1145	1171	14	4	2024-07-26 09:19:43	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1174	\\x28518d91ed979e209bbc3c3292db6f9c7301f10816efa6c74ec064b6bbf05cf9	11	11555	555	1146	1172	13	4	2024-07-26 09:19:44	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1175	\\x5334396b004fb3638a11c8f15111d1f9c40aee7189b8f15318c2f2c6424c7790	11	11557	557	1147	1174	11	4	2024-07-26 09:19:44.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1176	\\xb8490a9d6e1ce8f4d0947a72ef249d4cb9a89e1881161f6b24e1aa064c309f95	11	11569	569	1148	1175	14	4	2024-07-26 09:19:46.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1177	\\x6a0242f546e03c60d814409bab26cd140c62e9df79717ea3a44dc6478d30e60e	11	11579	579	1149	1176	14	4	2024-07-26 09:19:48.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1178	\\xddf25094488020892d53d40b702d17b860a8341d255cd15e8fc88885b419ed3f	11	11581	581	1150	1177	4	4	2024-07-26 09:19:49.2	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1179	\\xae157b18a2880772cf3ce26e6dde7294643eae3a117c46abe517d40ab362ef1c	11	11583	583	1151	1178	10	4	2024-07-26 09:19:49.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1180	\\xadaf2df1d2a44c9407ca59b5cee0ee9afec320cc31fcc0ac65ddc85589d7f7df	11	11612	612	1152	1179	4	4	2024-07-26 09:19:55.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1181	\\xb872e7faa56bc97d46df64104f26c6ac46c947c99d58e62ec1dadc3ad4a1c596	11	11614	614	1153	1180	4	4	2024-07-26 09:19:55.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1182	\\x8c9d691c46155bb16260b787372056740d4ae7967518b421f9a0685d51c65980	11	11634	634	1154	1181	21	4	2024-07-26 09:19:59.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1183	\\xebbaa9d3c843c2bb1cd77e0d23de846e5ca1e9dff7aa5daa0bc8aa4629ea399b	11	11640	640	1155	1182	21	4	2024-07-26 09:20:01	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1184	\\x9f69e8b6136d8314e2b1ed4168d3993c8311075f5406814a9a54968a88fbe8f0	11	11642	642	1156	1183	10	4	2024-07-26 09:20:01.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1185	\\x9a6c02b0f857688d163bf524843ad19dff05660d9892703ee610d0894b3a9c11	11	11648	648	1157	1184	12	4	2024-07-26 09:20:02.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1186	\\x74c029238e86312b7f0526c42b7c9f564b34a70fb2dd8d7c6524316f9cb353d6	11	11649	649	1158	1185	11	4	2024-07-26 09:20:02.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1187	\\xe8aaaed0469dc9f93994e2bba5ba339bca4e0c88c57c182898737c4e66cbe7fa	11	11652	652	1159	1186	11	4	2024-07-26 09:20:03.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1188	\\x61733c03979730819c068e87b3d143cd8aeec8b98f47e0019be3dca9c3d9087b	11	11664	664	1160	1187	11	4	2024-07-26 09:20:05.8	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1189	\\x5a54506cf1ec9b191b1630ca0656d09217ba8d99f518e8a0d7ffaf5db95a8385	11	11710	710	1161	1188	12	4	2024-07-26 09:20:15	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1190	\\x3e2edef79c702fbe71ab3541a2947b4b92804ccdc67dde99df9fcd4a74688d39	11	11716	716	1162	1189	18	4	2024-07-26 09:20:16.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1191	\\x91878ad72dee370122b661ba45d4a6bbe961744a0c23853ebd68d41e84fc9a12	11	11751	751	1163	1190	35	4	2024-07-26 09:20:23.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1192	\\xe91e22f4083f4c76fd725f06581963f6355161ee74ed813a6291c2922ccb3ee9	11	11761	761	1164	1191	14	4	2024-07-26 09:20:25.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1193	\\xe123d666f537189581426a61e71dceb0773dda9f015d208b90ed2b265b75e7d1	11	11763	763	1165	1192	21	4	2024-07-26 09:20:25.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1194	\\xf51cc3883a78c00e225b95b7851d91b074b65c0b2526691d6459854ea07f9138	11	11797	797	1166	1193	35	4	2024-07-26 09:20:32.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1195	\\x6aa08c6849a67410c0b458e50514d25567d0de1c4d8a69b03695f56563d26fb0	11	11823	823	1167	1194	35	4	2024-07-26 09:20:37.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1196	\\xd5daa694f57fbf8b9a6ea78c7bdea20320ea50569b8f2559e24b97ded173ec2f	11	11853	853	1168	1195	13	4	2024-07-26 09:20:43.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1197	\\xf9cd979623c7b3db643c1fc49fa1e69559cee891335eb8793996e4737a69b08b	11	11893	893	1169	1196	14	4	2024-07-26 09:20:51.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1198	\\xfcf14ea9cc86ce0c483b1db4c57b54a5130d219ba20c7aefdde6e80ae11c5fd4	11	11894	894	1170	1197	12	4	2024-07-26 09:20:51.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1199	\\x8abe6f1a1976997706745ccd5111695a823884226ef1acfa57d27d996e6c7058	11	11906	906	1171	1198	21	4	2024-07-26 09:20:54.2	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1200	\\x79d414cf2d8523ab8372e31f1be4303dcdad481b7f183bba19762e9690a37e21	11	11936	936	1172	1199	13	4	2024-07-26 09:21:00.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1201	\\x21720f0fd0c20c2a59b7e7d841809ea0316e2cdd71e5b9303706f305cd3a1539	11	11937	937	1173	1200	12	4	2024-07-26 09:21:00.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1202	\\xf3ba8f172de9ecd268eee1f0db0c6b962864264dc9bbcce7e8cabe0677284596	11	11938	938	1174	1201	35	4	2024-07-26 09:21:00.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1203	\\x1761427011a864f73a745b8a23eee86b07f24410cef275b0471d238366614315	11	11940	940	1175	1202	14	4	2024-07-26 09:21:01	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1204	\\xda57a6ff6a6203fa51dc7764aaf0f7aba67069055d89340b1105b791702bc65e	11	11941	941	1176	1203	11	4	2024-07-26 09:21:01.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1205	\\x75d0771694185fc5442decbbee42da6c291f794b57be5f414db2da11a8bd6120	11	11947	947	1177	1204	4	4	2024-07-26 09:21:02.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1206	\\x67d043ae49a3cc93a7ce3f520ffe86a6fd161f9d7cb2bcd7ab0deba5e122a7d0	11	11966	966	1178	1205	11	4	2024-07-26 09:21:06.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1207	\\xd7dc7b52500ea30c316df8811f11666d3c6dd48c0e5593cb4b215e4121a9034f	11	11973	973	1179	1206	21	4	2024-07-26 09:21:07.6	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1208	\\x0ceb6265dcd1886540970f4a43cc6b8963730819b1e405fa47a33e4c3a99f332	11	11979	979	1180	1207	18	4	2024-07-26 09:21:08.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1209	\\x3f522abdc016a4a3b10defb3098c95f5fd0ecfff28666eff539c546f9db367c2	11	11992	992	1181	1208	11	4	2024-07-26 09:21:11.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1210	\\x7d326b47257683b9b38aeeb9dfb4519779916858be67b2c8c06fbc224637f2b6	12	12036	36	1182	1209	13	4	2024-07-26 09:21:20.2	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1211	\\x2092e7b87fdb164fa4de0e06a61cab921df8b81bdd188e2b0d0bab0adfb87d1e	12	12042	42	1183	1210	21	4	2024-07-26 09:21:21.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1212	\\x80ecbbf86907b395877d797a52147efab3472fb5ba1d176c6e0e0a29541e8a2b	12	12047	47	1184	1211	35	4	2024-07-26 09:21:22.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1213	\\xdb7aeb21ecf17bcb2a76153ab35cb357c7bd420001eadf9e4fee5fddc053010a	12	12048	48	1185	1212	35	4	2024-07-26 09:21:22.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1214	\\xf0fdbad710d903b5845e1219dcee129e238f85004391a2cad3229c34ea0efffb	12	12060	60	1186	1213	21	4	2024-07-26 09:21:25	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1215	\\x54bb858d8b3f4fa51c61fadec1301bf8f5517792cee4993fa52ed651c7e1a648	12	12063	63	1187	1214	10	4	2024-07-26 09:21:25.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1216	\\x0514ecd78770ec1e0d93d23793f72534327901d5c6787787e253ebc472d4d718	12	12064	64	1188	1215	21	4	2024-07-26 09:21:25.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1217	\\xab57fa2c3eb36d93b371bb6186166200d7c23f56042b6fab60535ac48c5b4cc4	12	12074	74	1189	1216	14	4	2024-07-26 09:21:27.8	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1218	\\xe09e9b511d25e0d78ed71220b157c5dad67456f3fd92c86c12ccb9de2aa59320	12	12087	87	1190	1217	35	4	2024-07-26 09:21:30.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1219	\\x4233c9e7498cb384154087d2f1f0aaae34e2023fe454a05944a7ad4a571c52b4	12	12093	93	1191	1218	13	4	2024-07-26 09:21:31.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1220	\\x176c4f647c6b99ffc1e7a4de7403a04fc337b394dadf94734c49548229829104	12	12119	119	1192	1219	12	4	2024-07-26 09:21:36.8	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1221	\\x9de64f8a42e141f6ad8f7df4e076d379660db48b4b7a33c170d831d1684c4668	12	12126	126	1193	1220	14	4	2024-07-26 09:21:38.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1222	\\x90b3406d368a955babb97fced542a77c35b3bf38800f7d679b5a4a5d3dbf8f1e	12	12142	142	1194	1221	35	4	2024-07-26 09:21:41.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1223	\\xb09b21fd208038846c1ddb0b1541f47dfe9216ace852fe708a4a0886c5398e50	12	12152	152	1195	1222	10	4	2024-07-26 09:21:43.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1224	\\xb8dfd75bdc737812744f5c92911690bb73e5ff1e5cd25931782c3119caa6e629	12	12156	156	1196	1223	35	4	2024-07-26 09:21:44.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1225	\\xbc7abfac362dfee82a31c8ed6ad2a14f649f4d626b570a2e732c9487138f600b	12	12158	158	1197	1224	35	4	2024-07-26 09:21:44.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1226	\\x63917c8ecf20b7dfc2712330f78893c38d951520dede0feba81b89c56021bcc2	12	12175	175	1198	1225	10	4	2024-07-26 09:21:48	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1227	\\x82c96f00e9103d63e678ac706334e462428a043476c341790225714eb8de0eac	12	12182	182	1199	1226	35	4	2024-07-26 09:21:49.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1228	\\xe35606ae1095dbeb6362886ee08402479e5cb22faefbde44997599820dd415d7	12	12192	192	1200	1227	35	4	2024-07-26 09:21:51.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1229	\\x821719bbb7e581c2f41d0df73b165e76952dcac60631d4ccd2a277123b85269f	12	12195	195	1201	1228	35	4	2024-07-26 09:21:52	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1230	\\xfa818d6196ac65f278504287b09b90323159c23e267c1947e017a95e7be0df6d	12	12197	197	1202	1229	35	4	2024-07-26 09:21:52.4	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1231	\\x8b70bf0f4367d189bc72ae8199bcf3a831ddf15fee6fbb897e8eafd0b4e19d51	12	12208	208	1203	1230	35	4	2024-07-26 09:21:54.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1232	\\xcd2e7af31193738909ebed290bce2970ae16e82a0882075d522371dc40c4b3f9	12	12219	219	1204	1231	4	4	2024-07-26 09:21:56.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1233	\\xf60c90271991fc40b64d851d25e17d412919b98d08cf07ae68942e3c27b9a05a	12	12226	226	1205	1232	11	4	2024-07-26 09:21:58.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1234	\\xc8f6584425f3e6b2334acb811c3f7e60a727a933c966c52a58004b24c5808a9f	12	12264	264	1206	1233	18	4	2024-07-26 09:22:05.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1235	\\xd250aa3114fe34c40973595f09054fcce2278e52477e087b3ad163e7570eec0d	12	12273	273	1207	1234	35	4	2024-07-26 09:22:07.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1236	\\xc3eb597366b6313f74c64e76b96e2d7682a5bb3046937ece76ab1a2d2f0bad95	12	12312	312	1208	1235	10	4	2024-07-26 09:22:15.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1237	\\x2aa662a1d23e195a7fb456c39d5cb65749ef56021eebcde808ad15f9d3b032b0	12	12330	330	1209	1236	35	4	2024-07-26 09:22:19	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1238	\\x4db1a94e6d1ae1dcb8f1a78c68ea787405532385149e8fa8abb1caeae2de35e3	12	12336	336	1210	1237	11	4	2024-07-26 09:22:20.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1239	\\x67dc123dc42bfc6f11bf999fb44dce1382a8c9825b35392613f299b25a40e8b3	12	12338	338	1211	1238	18	4	2024-07-26 09:22:20.6	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1241	\\xb6d99b527c2cd4d4d6ef084fc1c6f7c1229f85f790b801547bcc80153f1a5adc	12	12341	341	1212	1239	18	4	2024-07-26 09:22:21.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1242	\\xa1f67f7d8ea13994a75b015c7cc678c2a114fe7762476c2cb68fefe64b691616	12	12346	346	1213	1241	11	4	2024-07-26 09:22:22.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1243	\\x58f67b2cfaf1686ddb3827be913026f15ac990767762f137d4ef68e39ac114d9	12	12357	357	1214	1242	11	4	2024-07-26 09:22:24.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1244	\\xbb7a6bd03d313851f68500b6a7d39ba52ec31641f7c558f80ec63e464922b2de	12	12366	366	1215	1243	14	4	2024-07-26 09:22:26.2	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1245	\\xa379a74486d8d1aa76b6dbe915505a2b51c09de2570aecd13e4808135b5548a7	12	12368	368	1216	1244	12	4	2024-07-26 09:22:26.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1246	\\xaaa268e012fd8bb24b926c57c670dbdc16891efc3ef344d38fcdd776432ffa07	12	12388	388	1217	1245	13	4	2024-07-26 09:22:30.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1247	\\xd2c1cff18aaaceb1f127ce5a5c05f6d5b002c97789205a830f04e3a64ffcc104	12	12390	390	1218	1246	14	4	2024-07-26 09:22:31	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1248	\\x829c679a2035b504779fcdb3de67fe741132a49c92b00ef9a99af9c8d360ce5e	12	12392	392	1219	1247	21	4	2024-07-26 09:22:31.4	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1249	\\x5f69318cd400934d801d6941012d0fce531d024b7fe968a7dbe96c27b2e70cc1	12	12395	395	1220	1248	10	4	2024-07-26 09:22:32	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1250	\\x923dd1cb9c43c1e3b54a5393d1a74738144d0bdad36cd99fb873191c3dadfa4d	12	12401	401	1221	1249	18	4	2024-07-26 09:22:33.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1251	\\xf8d3fafed395a9624bacf3648f638a2f9573c0a56362b0a7317c890e412667fd	12	12405	405	1222	1250	18	4	2024-07-26 09:22:34	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1252	\\x383a1761cb144495d1df3ffa19ba33e26acc21a7877541541b726e139b4e7321	12	12415	415	1223	1251	10	4	2024-07-26 09:22:36	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1253	\\xa86bc01b2af5e763d5d24b67aa038621bd9983310669bc7fa8a65a65e409e055	12	12438	438	1224	1252	10	4	2024-07-26 09:22:40.6	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1254	\\xce660787a8fe1a8cd76ce6d2705cc35252a53dbe1e817203a710a9fd96cdb698	12	12459	459	1225	1253	18	4	2024-07-26 09:22:44.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1255	\\xbcef6b0370d52ca9e7b3c958c7683783c87db3efaff96566ad4df8dc3dcc9f48	12	12462	462	1226	1254	14	4	2024-07-26 09:22:45.4	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1256	\\x560ce0fed9347fc10fd5cde6f67ea9e7b73560d756dbe1336a13c464700fa7cc	12	12463	463	1227	1255	4	4	2024-07-26 09:22:45.6	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1257	\\x86160bda49e4de54384eb179ede34b85765728d0d86cbe84ab28eebc0ecde91e	12	12472	472	1228	1256	11	4	2024-07-26 09:22:47.4	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1258	\\xc19566ef93926d531c0b4b0af9ece0df53f13ef1eac794747124d3ab40530f1e	12	12475	475	1229	1257	11	4	2024-07-26 09:22:48	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1259	\\x47e32b290f17edbb5c8fce1a356b7f945f1ae5a46b7d28552cb755592c92c019	12	12504	504	1230	1258	21	4	2024-07-26 09:22:53.8	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1260	\\xe3973ce0397258a02c2c5fbbceb0d40314c0329aa2e300018fd24f07f6350007	12	12521	521	1231	1259	10	4	2024-07-26 09:22:57.2	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1261	\\x4cf1a8aaf812651ea91f085f357669f4f840bc94fa30e98ce683c28af371a791	12	12526	526	1232	1260	18	4	2024-07-26 09:22:58.2	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1262	\\xa96c513dd7795af1de33a5087960d3d684216b51473b3a8793c697796bffee22	12	12531	531	1233	1261	35	4	2024-07-26 09:22:59.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1264	\\xf9dd0faa196de4b1653a4a3ddd85d7941763202b5fb5b6de6ee5c3410796efe5	12	12533	533	1234	1262	13	4	2024-07-26 09:22:59.6	0	10	0	vrf_vk1t56mr4gkqley80n3065256eg0hw2l5z9fuj4zjpznhz24x4dmmdqpsu75e	\\x3d917084052cfe528004095e7dd59821d15b08227e5c1a94cf55d4655c7d621d	0
1265	\\xdaf25d9866635c062ea77d39102e5b173f8c921fecd6439d6d96569e58a4bc3b	12	12550	550	1235	1264	12	4	2024-07-26 09:23:03	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1266	\\x11ddd3baa9ac82356f182ffbc9a36ab6fecd5b812f0a9598090488aa893b8532	12	12557	557	1236	1265	4	4	2024-07-26 09:23:04.4	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1267	\\xe26b356162e52659febc3d0cce6d6b8ce29feb42674ab4473ef28470abffdbdf	12	12570	570	1237	1266	12	4	2024-07-26 09:23:07	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1268	\\x16f121d1ee8cc94fe4561356db10d6c74b5bb8b8192ca089e00010a49890a935	12	12571	571	1238	1267	11	4	2024-07-26 09:23:07.2	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1269	\\xa0e7a43875045bfb919e891c6b461459909548334d5db1658b7c0921a65504f6	12	12577	577	1239	1268	12	4	2024-07-26 09:23:08.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1270	\\x2968fc99b2274065004cc7176a194fdc8f200e709c81ce713c693bd98accdc61	12	12593	593	1240	1269	14	4	2024-07-26 09:23:11.6	0	10	0	vrf_vk1sdzwfa4g2u6z46al47xt20fn0juhkjuyftzey72h340rupjelvlsv2l4dk	\\xbf9af6cce28442ddcc58399a256983d2c3098b43c339b27b904fbfc14dbcb2e5	0
1271	\\x0d95867b01a7d39c85c4d4323c84c83f91fba34e1c19fddd4d70d8c759e76785	12	12608	608	1241	1270	11	4	2024-07-26 09:23:14.6	0	10	0	vrf_vk1pee4vn3z4lk49dmygxv3t23ldueqjqv33audtv90u4c5f9mp79ks3l94fw	\\x9bed7506fa580271d799b06b4fd01a5c93815c047affd60a590e0072d367a927	0
1273	\\xe7ba72661f19941d2207c88af6eb0d3c341da3fbac8da49cbc46416d6da01f59	12	12624	624	1242	1271	10	4	2024-07-26 09:23:17.8	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1274	\\xcb5a05fa24d880b4a4e39ad4b3d8882088ee40e67036a6e86cec97cc2c4ba94b	12	12630	630	1243	1273	18	4	2024-07-26 09:23:19	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1275	\\x4515dbfddf514bf3375393fefd76571146abbbf4bc5d35f7dfe2c138a7757fd3	12	12634	634	1244	1274	18	4	2024-07-26 09:23:19.8	0	10	0	vrf_vk14gvf9qfc720aaxyvx7wfhnm7mt8fx4zzk0x2hp2njmtdhly3288s39h896	\\xcf5f8dcf5ac88b65ad7a47f7ee77d209ed9c3e4edfc87d67974caa9314fe05da	0
1276	\\x4137004488cb85c429d0cacf24ff0b2a4af303a72e4e8f57652be75c239772db	12	12642	642	1245	1275	10	4	2024-07-26 09:23:21.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1277	\\xc6c0d6d11b98ed07b2b4e84e18430a90f0a3328850de38d615676d2c28ac9396	12	12655	655	1246	1276	21	4	2024-07-26 09:23:24	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1278	\\xc73ee3bce9090a36a08c931931f415b5a06ee2697fe86ecb46016d569ba84347	12	12667	667	1247	1277	12	4	2024-07-26 09:23:26.4	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1279	\\x0faa7c91623f6a8bd1846c2ebd5030d586861c52cff79cc5ef431e66797c33e0	12	12675	675	1248	1278	4	4	2024-07-26 09:23:28	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1280	\\x78018ba2008005b4a8ca529b24a865965b443762abe86a501ccfbca1fdcacad0	12	12691	691	1249	1279	35	4	2024-07-26 09:23:31.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1281	\\x9bc28050f59110d65ff8d9dd2f0063c2ae5b8d8af011d0c7d1ba4bb075018180	12	12693	693	1250	1280	35	4	2024-07-26 09:23:31.6	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1282	\\x96948ab90a240f295e4c4355c95fc2055b791a770a6bd7a73268a2121e7ffc84	12	12694	694	1251	1281	4	4	2024-07-26 09:23:31.8	0	10	0	vrf_vk1a4xvz0e8qu83z77mu5eay8aezrf4mkjtlvx4s6wggz0y0q86swas9d5x5p	\\x69005d7693d75dc1f85f9c89b953645341e17ee668434658254c70e5faea08a1	0
1283	\\xd42c66a4e02327ef026dcb98025d0e78b462e0df9ac46dcfdba709fe6ef48e82	12	12706	706	1252	1282	35	4	2024-07-26 09:23:34.2	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1284	\\x0578f1170597370c1b199ec6c95a672c8f958d7830b798d1181afc43ffe2b77e	12	12710	710	1253	1283	35	4	2024-07-26 09:23:35	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1285	\\x2eb0926459460731b3451a3ef0647dbc269dd00dafdcb1dec8022a46abdc3161	12	12754	754	1254	1284	10	4	2024-07-26 09:23:43.8	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
1286	\\x26ed8d9431a47f64c406802cd42ab7caa8c501ea403ab3d2265d9216c043410a	12	12765	765	1255	1285	35	4	2024-07-26 09:23:46	0	10	0	vrf_vk104q2rhg2sf7k3u7s3hl9ggqy2kayv904hrez2kafwgax7qtyqxzqfuc6at	\\x6dbd84831077a3e20a387b03d5f95f285af6a450c1894f6cf28383ccae32eb07	0
1287	\\xf4a2ffdc7affe8bd18d1a9d9695a1dc830e9e586bb35fd2c8b131f1223e887b8	12	12768	768	1256	1286	12	4	2024-07-26 09:23:46.6	0	10	0	vrf_vk1ahtrll2k9tlf7j5tpl0q6sm3u9le2gsnpch7v48mrknhh5fzfcmsg8qnqc	\\x2d7cc3ad283caed8e3faa700d54d74ab2e23343eeacdc39b4116439ca0c188ea	0
1288	\\x4b25aa7c49a5e7cadb91b33273bbb4ead6e453099bfdd9976e62c00373f3a03b	12	12775	775	1257	1287	21	4	2024-07-26 09:23:48	0	10	0	vrf_vk1uw8w67my9pa2fzqffzk8daydn08tmv77rzenf2gqu3uwn83hm3mssywje3	\\x293381cd68109d07aa4c831931c6e68075b371f2489080ef99ed98f5762c1a99	0
1290	\\x756ca4e4fe752264c185ff128f3212c707b1bc6275dc9812ae65c8cae5680202	12	12787	787	1258	1288	10	4	2024-07-26 09:23:50.4	0	10	0	vrf_vk14m8xg0h0dcf4834fkr9cmuhd605ge9lq3er9z2nhla6dn3twzpkq8cs02u	\\x61359572d4afd39895a11f45c97b367eb36dd2ef1553db7da67dc6c1e9d90179	0
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
1	121	1	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	3681317478696443	\N	fromList []	\N	\N
2	128	1	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	3681316876382934	\N	fromList []	\N	\N
\.


--
-- Data for Name: committee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.committee (id, gov_action_proposal_id, quorum_numerator, quorum_denominator) FROM stdin;
1	\N	67	100
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
1	\\x27999ed757d6dac217471ae61d69b1b067b8b240d9e3ff36eb66b5d0	t
2	\\x6095e643ea6f1cccb6e463ec34349026b3a48621aac5d512655ab1bf	t
3	\\x7ceede7d6a89e006408e6b7c6acb3dd094b3f6817e43b4a36d01535b	t
4	\\x87f867a31c0f81360d4d7dcddb6b025ba8383db9bf77a2af7797799d	t
5	\\xa19a7ba1caede8f3ab3e5e2a928b3798d7d011af18fbd577f7aeb0ec	t
\.


--
-- Data for Name: committee_member; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.committee_member (id, committee_id, committee_hash_id, expiration_epoch) FROM stdin;
1	1	1	500
2	1	2	500
3	1	3	500
4	1	4	500
5	1	5	500
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
1	\N	1	\N
2	5	8	\N
\.


--
-- Data for Name: cost_model; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cost_model (id, costs, hash) FROM stdin;
5	{"PlutusV1": [205665, 812, 1, 1, 1000, 571, 0, 1, 1000, 24177, 4, 1, 1000, 32, 117366, 10475, 4, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 100, 100, 23000, 100, 19537, 32, 175354, 32, 46417, 4, 221973, 511, 0, 1, 89141, 32, 497525, 14068, 4, 2, 196500, 453240, 220, 0, 1, 1, 1000, 28662, 4, 2, 245000, 216773, 62, 1, 1060367, 12586, 1, 208512, 421, 1, 187000, 1000, 52998, 1, 80436, 32, 43249, 32, 1000, 32, 80556, 1, 57667, 4, 1000, 10, 197145, 156, 1, 197145, 156, 1, 204924, 473, 1, 208896, 511, 1, 52467, 32, 64832, 32, 65493, 32, 22558, 32, 16563, 32, 76511, 32, 196500, 453240, 220, 0, 1, 1, 69522, 11687, 0, 1, 60091, 32, 196500, 453240, 220, 0, 1, 1, 196500, 453240, 220, 0, 1, 1, 806990, 30482, 4, 1927926, 82523, 4, 265318, 0, 4, 0, 85931, 32, 205665, 812, 1, 1, 41182, 32, 212342, 32, 31220, 32, 32696, 32, 43357, 32, 32247, 32, 38314, 32, 57996947, 18975, 10], "PlutusV2": [205665, 812, 1, 1, 1000, 571, 0, 1, 1000, 24177, 4, 1, 1000, 32, 117366, 10475, 4, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 100, 100, 23000, 100, 19537, 32, 175354, 32, 46417, 4, 221973, 511, 0, 1, 89141, 32, 497525, 14068, 4, 2, 196500, 453240, 220, 0, 1, 1, 1000, 28662, 4, 2, 245000, 216773, 62, 1, 1060367, 12586, 1, 208512, 421, 1, 187000, 1000, 52998, 1, 80436, 32, 43249, 32, 1000, 32, 80556, 1, 57667, 4, 1000, 10, 197145, 156, 1, 197145, 156, 1, 204924, 473, 1, 208896, 511, 1, 52467, 32, 64832, 32, 65493, 32, 22558, 32, 16563, 32, 76511, 32, 196500, 453240, 220, 0, 1, 1, 69522, 11687, 0, 1, 60091, 32, 196500, 453240, 220, 0, 1, 1, 196500, 453240, 220, 0, 1, 1, 1159724, 392670, 0, 2, 806990, 30482, 4, 1927926, 82523, 4, 265318, 0, 4, 0, 85931, 32, 205665, 812, 1, 1, 41182, 32, 212342, 32, 31220, 32, 32696, 32, 43357, 32, 32247, 32, 38314, 32, 35892428, 10, 57996947, 18975, 10, 38887044, 32947, 10]}	\\xfab6824e3ce85788a1b893579df8631717189fcf9f300483f5ae51a95eb4edfa
1	{"PlutusV1": [197209, 0, 1, 1, 396231, 621, 0, 1, 150000, 1000, 0, 1, 150000, 32, 2477736, 29175, 4, 29773, 100, 29773, 100, 29773, 100, 29773, 100, 29773, 100, 29773, 100, 100, 100, 29773, 100, 150000, 32, 150000, 32, 150000, 32, 150000, 1000, 0, 1, 150000, 32, 150000, 1000, 0, 8, 148000, 425507, 118, 0, 1, 1, 150000, 1000, 0, 8, 150000, 112536, 247, 1, 150000, 10000, 1, 136542, 1326, 1, 1000, 150000, 1000, 1, 150000, 32, 150000, 32, 150000, 32, 1, 1, 150000, 1, 150000, 4, 103599, 248, 1, 103599, 248, 1, 145276, 1366, 1, 179690, 497, 1, 150000, 32, 150000, 32, 150000, 32, 150000, 32, 150000, 32, 150000, 32, 148000, 425507, 118, 0, 1, 1, 61516, 11218, 0, 1, 150000, 32, 148000, 425507, 118, 0, 1, 1, 148000, 425507, 118, 0, 1, 1, 2477736, 29175, 4, 0, 82363, 4, 150000, 5000, 0, 1, 150000, 32, 197209, 0, 1, 1, 150000, 32, 150000, 32, 150000, 32, 150000, 32, 150000, 32, 150000, 32, 150000, 32, 3345831, 1, 1], "PlutusV2": [205665, 812, 1, 1, 1000, 571, 0, 1, 1000, 24177, 4, 1, 1000, 32, 117366, 10475, 4, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 100, 100, 23000, 100, 19537, 32, 175354, 32, 46417, 4, 221973, 511, 0, 1, 89141, 32, 497525, 14068, 4, 2, 196500, 453240, 220, 0, 1, 1, 1000, 28662, 4, 2, 245000, 216773, 62, 1, 1060367, 12586, 1, 208512, 421, 1, 187000, 1000, 52998, 1, 80436, 32, 43249, 32, 1000, 32, 80556, 1, 57667, 4, 1000, 10, 197145, 156, 1, 197145, 156, 1, 204924, 473, 1, 208896, 511, 1, 52467, 32, 64832, 32, 65493, 32, 22558, 32, 16563, 32, 76511, 32, 196500, 453240, 220, 0, 1, 1, 69522, 11687, 0, 1, 60091, 32, 196500, 453240, 220, 0, 1, 1, 196500, 453240, 220, 0, 1, 1, 1159724, 392670, 0, 2, 806990, 30482, 4, 1927926, 82523, 4, 265318, 0, 4, 0, 85931, 32, 205665, 812, 1, 1, 41182, 32, 212342, 32, 31220, 32, 32696, 32, 43357, 32, 32247, 32, 38314, 32, 35892428, 10, 9462713, 1021, 10, 38887044, 32947, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10], "PlutusV3": [100788, 420, 1, 1, 1000, 173, 0, 1, 1000, 59957, 4, 1, 11183, 32, 201305, 8356, 4, 16000, 100, 16000, 100, 16000, 100, 16000, 100, 16000, 100, 16000, 100, 100, 100, 16000, 100, 94375, 32, 132994, 32, 61462, 4, 72010, 178, 0, 1, 22151, 32, 91189, 769, 4, 2, 85848, 123203, 7305, -900, 1716, 549, 57, 85848, 0, 1, 1, 1000, 42921, 4, 2, 24548, 29498, 38, 1, 898148, 27279, 1, 51775, 558, 1, 39184, 1000, 60594, 1, 141895, 32, 83150, 32, 15299, 32, 76049, 1, 13169, 4, 22100, 10, 28999, 74, 1, 28999, 74, 1, 43285, 552, 1, 44749, 541, 1, 33852, 32, 68246, 32, 72362, 32, 7243, 32, 7391, 32, 11546, 32, 85848, 123203, 7305, -900, 1716, 549, 57, 85848, 0, 1, 90434, 519, 0, 1, 74433, 32, 85848, 123203, 7305, -900, 1716, 549, 57, 85848, 0, 1, 1, 85848, 123203, 7305, -900, 1716, 549, 57, 85848, 0, 1, 955506, 213312, 0, 2, 270652, 22588, 4, 1457325, 64566, 4, 20467, 1, 4, 0, 141992, 32, 100788, 420, 1, 1, 81663, 32, 59498, 32, 20142, 32, 24588, 32, 20744, 32, 25933, 32, 24623, 32, 43053543, 10, 53384111, 14333, 10, 43574283, 26308, 10, 16000, 100, 16000, 100, 962335, 18, 2780678, 6, 442008, 1, 52538055, 3756, 18, 267929, 18, 76433006, 8868, 18, 52948122, 18, 1995836, 36, 3227919, 12, 901022, 1, 166917843, 4307, 36, 284546, 36, 158221314, 26549, 36, 74698472, 36, 333849714, 1, 254006273, 72, 2174038, 72, 2261318, 64571, 4, 207616, 8310, 4, 1293828, 28716, 63, 0, 1, 1006041, 43623, 251, 0, 1]}	\\x9679942deec8f983275c08d6efeeac9de2ea7586dec3a413a5d0745ab4b512ae
\.


--
-- Data for Name: datum; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.datum (id, hash, tx_id, value, bytes) FROM stdin;
1	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	121	{"int": 12}	\\x0c
2	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	122	{"int": 42}	\\x182a
3	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	127	{"fields": [], "constructor": 0}	\\xd87980
4	\\x81cb2989cbf6c49840511d8d3451ee44f58dde2c074fc749d05deb51eeb33741	132	{"fields": [{"map": [{"k": {"bytes": "636f7265"}, "v": {"map": [{"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "707265666978"}, "v": {"bytes": "24"}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 0}}, {"k": {"bytes": "7465726d736f66757365"}, "v": {"bytes": "68747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f"}}, {"k": {"bytes": "68616e646c65456e636f64696e67"}, "v": {"bytes": "7574662d38"}}]}}, {"k": {"bytes": "6e616d65"}, "v": {"bytes": "283130302968616e646c653638"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f736f6d652d68617368"}}, {"k": {"bytes": "77656273697465"}, "v": {"bytes": "68747470733a2f2f63617264616e6f2e6f72672f"}}, {"k": {"bytes": "6465736372697074696f6e"}, "v": {"bytes": "5468652048616e646c65205374616e64617264"}}, {"k": {"bytes": "6175676d656e746174696f6e73"}, "v": {"list": []}}]}, {"int": 1}, {"map": []}], "constructor": 0}	\\xd8799fa644636f7265a5426f67004670726566697841244776657273696f6e004a7465726d736f66757365583668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f4e68616e646c65456e636f64696e67457574662d38446e616d654d283130302968616e646c65363845696d61676550697066733a2f2f736f6d652d6861736847776562736974655468747470733a2f2f63617264616e6f2e6f72672f4b6465736372697074696f6e535468652048616e646c65205374616e646172644d6175676d656e746174696f6e738001a0ff
5	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	133	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "24706861726d65727332"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "6261736963"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 9}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c6574746572732c6e756d62657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "62675f696d616765"}, "v": {"bytes": "697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f"}}, {"k": {"bytes": "7066705f696d616765"}, "v": {"bytes": "697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b524244"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": "697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b"}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879"}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "01e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c980"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "312e31352e30"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "7066705f6173736574"}, "v": {"bytes": "e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e044503036383136"}}, {"k": {"bytes": "62675f6173736574"}, "v": {"bytes": "9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65"}}]}], "constructor": 0}	\\xd8799faa446e616d654a24706861726d6572733245696d6167655838697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e677468094a636861726163746572734f6c6574746572732c6e756d62657273516e756d657269635f6d6f64696669657273404776657273696f6e0101b34862675f696d6167655835697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f497066705f696d6167655835697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b52424446706f7274616c404864657369676e65725838697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b47736f6369616c73404676656e646f72404764656661756c74004e7374616e646172645f696d6167655838697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879536c6173745f7570646174655f61646472657373583901e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d4c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f686173685820bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de537374616e646172645f696d6167655f686173685820b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c9804b7376675f76657273696f6e46312e31352e304c6167726565645f7465726d7340546d6967726174655f7369675f726571756972656400446e7366770045747269616c00497066705f61737365745823e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e0445030363831364862675f6173736574582c9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65ff
6	\\xff1a404ece117cc4482d26b072e30b5a6b3cd055a22debda3f90d704957e273a	134	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "24686e646c"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d73627162317366736356365970"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "636f6d6d6f6e"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 4}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c657474657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d73627162317366736356365970"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": ""}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "00f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df40"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "32646465376163633062376532333931626633326133646537643566313763356365663231633336626432333564636663643738376463663439656661363339"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "32646465376163633062376532333931626633326133646537643566313763356365663231633336626432333564636663643738376463663439656661363339"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "322e302e31"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}]}], "constructor": 0}	\\xd8799faa446e616d654524686e646c45696d6167655838697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d73627162317366736356365970496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d626572004672617269747946636f6d6d6f6e466c656e677468044a63686172616374657273476c657474657273516e756d657269635f6d6f64696669657273404776657273696f6e0101af4e7374616e646172645f696d6167655838697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d7362716231736673635636597046706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f61646472657373583900f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df404c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f68617368584032646465376163633062376532333931626633326133646537643566313763356365663231633336626432333564636663643738376463663439656661363339537374616e646172645f696d6167655f686173685840326464653761636330623765323339316266333261336465376435663137633563656632316333366264323335646366636437383764636634396566613633394b7376675f76657273696f6e45322e302e314c6167726565645f7465726d7340546d6967726174655f7369675f72657175697265640045747269616c00446e73667700ff
7	\\x29294f077464c36e67b304ad22547fb3dfa946623b0b2cbae8acea7fb299353c	135	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "2473756240686e646c"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d3534726472455032776366"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "6261736963"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 8}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c657474657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d3534726472455032776366"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": ""}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "00f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df40"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "34333831373362613630333931353466646232643137383763363765633636333863393462643331633835336630643964356166343365626462313864623934"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "34333831373362613630333931353466646232643137383763363765633636333863393462643331633835336630643964356166343365626462313864623934"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "322e302e31"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}]}], "constructor": 0}	\\xd8799faa446e616d65492473756240686e646c45696d6167655838697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d3534726472455032776366496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e677468084a63686172616374657273476c657474657273516e756d657269635f6d6f64696669657273404776657273696f6e0101af4e7374616e646172645f696d6167655838697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d353472647245503277636646706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f61646472657373583900f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df404c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f68617368584034333831373362613630333931353466646232643137383763363765633636333863393462643331633835336630643964356166343365626462313864623934537374616e646172645f696d6167655f686173685840343338313733626136303339313534666462326431373837633637656336363338633934626433316338353366306439643561663433656264623138646239344b7376675f76657273696f6e45322e302e314c6167726565645f7465726d7340546d6967726174655f7369675f72657175697265640045747269616c00446e73667700ff
\.


--
-- Data for Name: delegation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delegation (id, addr_id, cert_index, pool_hash_id, active_epoch_no, tx_id, slot_no, redeemer_id) FROM stdin;
1	4	1	6	2	34	0	\N
2	2	3	8	2	34	0	\N
3	5	5	2	2	34	0	\N
4	8	7	5	2	34	0	\N
5	1	9	1	2	34	0	\N
6	11	11	11	2	34	0	\N
7	3	13	3	2	34	0	\N
8	7	15	4	2	34	0	\N
9	9	17	7	2	34	0	\N
10	6	19	10	2	34	0	\N
11	10	21	9	2	34	0	\N
12	22	0	11	2	79	214	\N
13	18	0	7	2	80	214	\N
14	16	0	5	2	81	214	\N
15	15	0	4	2	82	214	\N
16	17	0	6	2	83	214	\N
17	14	0	3	2	84	214	\N
18	19	0	8	2	85	214	\N
19	13	0	2	2	86	214	\N
20	21	0	10	2	87	214	\N
21	12	0	1	2	88	214	\N
22	20	0	9	2	89	214	\N
23	25	0	4	2	90	242	\N
24	32	0	5	2	91	242	\N
25	33	0	7	2	92	242	\N
26	23	0	2	2	93	242	\N
27	29	0	11	2	94	242	\N
28	27	0	8	2	95	242	\N
29	24	0	6	2	96	242	\N
30	28	0	1	2	97	242	\N
31	30	0	10	2	98	242	\N
32	31	0	3	2	99	242	\N
33	26	0	9	2	100	242	\N
34	33	0	7	2	112	266	\N
35	32	0	5	2	113	266	\N
36	30	0	10	2	114	266	\N
37	31	0	3	2	115	266	\N
38	35	0	11	5	170	3129	\N
39	35	0	11	5	174	3184	\N
40	35	0	11	5	183	3368	\N
41	42	1	11	5	189	3498	\N
42	43	3	8	5	189	3498	\N
43	44	5	9	5	189	3498	\N
44	45	7	2	5	189	3498	\N
45	46	9	4	5	189	3498	\N
46	42	0	11	5	191	3626	\N
47	43	1	11	5	191	3626	\N
48	44	2	11	5	191	3626	\N
49	45	3	11	5	191	3626	\N
50	46	4	11	5	191	3626	\N
51	47	1	8	5	193	3685	\N
52	35	1	11	5	196	3709	\N
53	35	1	11	5	198	3757	\N
54	48	1	8	9	300	7037	\N
56	37	0	12	13	405	11190	\N
57	34	0	13	13	408	11362	\N
\.


--
-- Data for Name: delegation_vote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delegation_vote (id, addr_id, cert_index, drep_hash_id, tx_id, redeemer_id) FROM stdin;
1	35	0	1	172	\N
2	35	0	1	174	\N
3	35	0	1	180	\N
4	35	0	1	183	\N
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
1	169	0	500000000	1	2
2	176	0	\N	1	\N
3	187	0	-500000000	1	\N
\.


--
-- Data for Name: epoch; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch (id, out_sum, fees, tx_count, blk_count, no, start_time, end_time) FROM stdin;
34	0	0	0	96	10	2024-07-26 09:14:37.2	2024-07-26 09:17:48.4
3	74999267061502	5228116	28	116	1	2024-07-26 08:44:33.6	2024-07-26 08:47:52.4
13	0	0	0	112	4	2024-07-26 08:54:33.2	2024-07-26 08:57:52.4
24	4433814489590	532038	2	106	7	2024-07-26 09:04:34	2024-07-26 09:07:52.6
1	213550434837809581	17450365	98	90	0	2024-07-26 08:41:14	2024-07-26 08:44:30.8
37	21489231063907	2119535	11	81	11	2024-07-26 09:17:56.2	2024-07-26 09:21:11.4
9	4077162144584	5610290	30	95	3	2024-07-26 08:51:14	2024-07-26 08:54:32.6
21	0	0	0	98	6	2024-07-26 09:01:13.4	2024-07-26 09:04:29.4
31	12208204998808	16933560	100	95	9	2024-07-26 09:11:13.2	2024-07-26 09:14:31.6
6	2133099845896	1898675	7	87	2	2024-07-26 08:47:53	2024-07-26 08:51:11.6
42	0	0	0	77	12	2024-07-26 09:21:20.2	2024-07-26 09:23:50.4
28	0	0	0	89	8	2024-07-26 09:07:53	2024-07-26 09:11:12.6
17	6768684896787	16910328	100	117	5	2024-07-26 08:57:54.2	2024-07-26 09:01:12.8
\.


--
-- Data for Name: epoch_param; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_param (id, epoch_no, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, nonce, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, block_id, extra_entropy, coins_per_utxo_size, pvt_motion_no_confidence, pvt_committee_normal, pvt_committee_no_confidence, pvt_hard_fork_initiation, dvt_motion_no_confidence, dvt_committee_normal, dvt_committee_no_confidence, dvt_update_to_constitution, dvt_hard_fork_initiation, dvt_p_p_network_group, dvt_p_p_economic_group, dvt_p_p_technical_group, dvt_p_p_gov_group, dvt_treasury_withdrawal, committee_min_size, committee_max_term_length, gov_action_lifetime, gov_action_deposit, drep_deposit, drep_activity, pvtpp_security_group, min_fee_ref_script_cost_per_byte) FROM stdin;
1	0	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	10	0	0	0	\\xc044e16435fcafe0505d7d026601e3d42346ca2b574326bfee633ee7c9aa7a59	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	3	\N	4310	0.6	0.65	0.65	0.51	0.67	0.67	0.65	0.75	0.6	0.67	0.67	0.67	0.75	0.67	5	146	14	100000000000	500000000	20	0.6	15
2	1	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	10	0	0	0	\\xa81d098d11b1c5479c9ce74f07e595fcb46106465ae05dd205c3d814abf2b628	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	93	\N	4310	0.6	0.65	0.65	0.51	0.67	0.67	0.65	0.75	0.6	0.67	0.67	0.67	0.75	0.67	5	146	14	100000000000	500000000	20	0.6	15
3	2	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	10	0	0	0	\\x9ba6850adf6c5dc7a7e331536c05a9131b227d937cd6214d826c80d5febca7d5	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	210	\N	4310	0.6	0.65	0.65	0.51	0.67	0.67	0.65	0.75	0.6	0.67	0.67	0.67	0.75	0.67	5	146	14	100000000000	500000000	20	0.6	15
4	3	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	10	0	0	0	\\x9607563cee695f5c060cdc1ef66ff73defc46d349ac793404d2aa968390187d6	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	299	\N	4310	0.6	0.65	0.65	0.51	0.67	0.67	0.65	0.75	0.6	0.67	0.67	0.67	0.75	0.67	5	146	14	100000000000	500000000	20	0.6	15
5	4	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	10	0	0	0	\\xc4ab0da3825a05e6f552f911030a29bb22add9d16a6b0a5d8753cb29c7effd6d	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	396	\N	4310	0.6	0.65	0.65	0.51	0.67	0.67	0.65	0.75	0.6	0.67	0.67	0.67	0.75	0.67	5	146	14	100000000000	500000000	20	0.6	15
6	5	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	10	0	0	0	\\x4198e863ea53065616c41fd256047eec4c89029ff2e41910750db7e7f0a1bddc	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	511	\N	4310	0.6	0.65	0.65	0.51	0.67	0.67	0.65	0.75	0.6	0.67	0.67	0.67	0.75	0.67	5	146	14	100000000000	500000000	20	0.6	15
7	6	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	10	0	0	0	\\x7c0d8bae13e4ac86cbf923cff8362e6e6aedd072783729e5f99283bfc7d0c82d	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	631	\N	4310	0.6	0.65	0.65	0.51	0.67	0.67	0.65	0.75	0.6	0.67	0.67	0.67	0.75	0.67	5	146	14	100000000000	500000000	20	0.6	15
8	7	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	10	0	0	0	\\x3a7e5a38c2008d142aef320fa3fa362137904ec2359921a5e04b4f4c42b11c6a	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	732	\N	4310	0.6	0.65	0.65	0.51	0.67	0.67	0.65	0.75	0.6	0.67	0.67	0.67	0.75	0.67	5	146	14	100000000000	500000000	20	0.6	15
9	8	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	10	0	0	0	\\x8b45917e3a01d5bdcbaef64ff0390beafecfbef92e6d7eda44f821bb220edaec	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	840	\N	4310	0.6	0.65	0.65	0.51	0.67	0.67	0.65	0.75	0.6	0.67	0.67	0.67	0.75	0.67	5	146	14	100000000000	500000000	20	0.6	15
10	9	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	10	0	0	0	\\xde3c28728572a0d2a46b8e7e5173b3cda1fb495e8007b237f99a83b7a385e79b	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	932	\N	4310	0.6	0.65	0.65	0.51	0.67	0.67	0.65	0.75	0.6	0.67	0.67	0.67	0.75	0.67	5	146	14	100000000000	500000000	20	0.6	15
11	10	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	10	0	0	0	\\x62448f1a49608e4193c8fcff498c5cebaa14e0688e28b8b0c13a0821732d2088	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1029	\N	4310	0.6	0.65	0.65	0.51	0.67	0.67	0.65	0.75	0.6	0.67	0.67	0.67	0.75	0.67	5	146	14	100000000000	500000000	20	0.6	15
12	11	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	10	0	0	0	\\x6bf7a54a9433a8dd7566be0197a9bf3f1fa037ac333ef50ad55165c6060927ba	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1127	\N	4310	0.6	0.65	0.65	0.51	0.67	0.67	0.65	0.75	0.6	0.67	0.67	0.67	0.75	0.67	5	146	14	100000000000	500000000	20	0.6	15
13	12	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.1	0.1	0	10	0	0	0	\\xe5b63e50f7902328849395ab8330a7ea2b5717923965821e22f819b67f0dbd0a	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1210	\N	4310	0.6	0.65	0.65	0.51	0.67	0.67	0.65	0.75	0.6	0.67	0.67	0.67	0.75	0.67	5	146	14	100000000000	500000000	20	0.6	15
\.


--
-- Data for Name: epoch_stake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_stake (id, addr_id, pool_id, amount, epoch_no) FROM stdin;
1	4	6	7772727272727272	1
2	2	8	7772727272727272	1
3	5	2	7772727272727280	1
4	8	5	7772727272727272	1
5	1	1	7772727272727272	1
6	11	11	7772727272727272	1
7	3	3	7772727272727272	1
8	7	4	7772727272727272	1
9	9	7	7772727272727272	1
10	6	10	7772727272727272	1
11	10	9	7772727272727272	1
12	4	6	7772727272727272	2
13	25	4	499997461609	2
14	2	8	7772727272727272	2
15	28	1	499997461609	2
16	14	3	300000000	2
17	29	11	499997461609	2
18	33	7	499997288408	2
19	32	5	499997288408	2
20	5	2	7772727272727280	2
21	31	3	499997291224	2
22	8	5	7772727272727272	2
23	21	10	300000000	2
24	27	8	499997461609	2
25	26	9	499997461609	2
26	1	1	7772727272727272	2
27	11	11	7772727272727272	2
28	19	8	500000000	2
29	13	2	500000000	2
30	20	9	500000000	2
31	24	6	499997464381	2
32	3	3	7772727272727272	2
33	7	4	7772727272727272	2
34	9	7	7772727272727272	2
35	12	1	500000000	2
36	18	7	500000000	2
37	22	11	500000000	2
38	17	6	600000000	2
39	16	5	500000000	2
40	30	10	499997291224	2
41	6	10	7772727272727272	2
42	15	4	200000000	2
43	10	9	7772727272727272	2
44	23	2	499997461609	2
45	4	6	7772727272727272	3
46	25	4	499997461609	3
47	2	8	7772727272727272	3
48	28	1	499997461609	3
49	14	3	300000000	3
50	29	11	499997461609	3
51	33	7	499997288408	3
52	32	5	499997288408	3
53	5	2	7772727272727280	3
54	31	3	499997291224	3
55	8	5	7772727272727272	3
56	21	10	300000000	3
57	27	8	499997461609	3
58	26	9	499997461609	3
59	1	1	7772727272727272	3
60	11	11	7772727272727272	3
61	19	8	500000000	3
62	13	2	500000000	3
63	20	9	500000000	3
64	24	6	499997464381	3
65	3	3	7772727272727272	3
66	7	4	7772727272727272	3
67	9	7	7772727272727272	3
68	12	1	500000000	3
69	18	7	500000000	3
70	22	11	500000000	3
71	17	6	600000000	3
72	16	5	500000000	3
73	30	10	499997291224	3
74	6	10	7772727272727272	3
75	15	4	200000000	3
76	10	9	7772727272727272	3
77	23	2	499997461609	3
78	4	6	7782622738509874	4
79	25	4	499997461609	4
80	2	8	7778816790131950	4
81	28	1	499997461609	4
82	14	3	300000000	4
83	29	11	499997461609	4
84	33	7	499997288408	4
85	32	5	499997288408	4
86	5	2	7780339169483128	4
87	31	3	499997291224	4
88	8	5	7781100359158705	4
89	21	10	300000000	4
90	27	8	499997461609	4
91	26	9	499997461609	4
92	1	1	7778055600456365	4
93	11	11	7783383928185459	4
94	19	8	500000000	4
95	13	2	500000000	4
96	20	9	500000000	4
97	24	6	499997464381	4
98	3	3	7781100359158705	4
99	7	4	7780339169483120	4
100	9	7	7777294410780780	4
101	12	1	500000000	4
102	18	7	500000000	4
103	22	11	500000000	4
104	17	6	600000000	4
105	16	5	500000000	4
106	30	10	499997291224	4
107	6	10	7784906307536629	4
108	15	4	200000000	4
109	10	9	7780339169483120	4
110	23	2	499997461609	4
111	4	6	7787814856323868	5
112	25	4	500275790126	5
113	45	11	0	5
114	2	8	7788335673035862	5
115	28	1	500387121504	5
116	14	3	300233797	5
117	29	11	500220124406	5
118	33	7	500331282488	5
119	32	5	500553945208	5
120	5	2	7789858052387040	5
121	31	3	500386951006	5
122	8	5	7789753889071737	5
123	44	11	0	5
124	21	10	300233797	5
125	27	8	500609784301	5
126	26	9	500721115699	5
127	42	11	0	5
128	1	1	7784113071395218	5
129	11	11	7786845340150517	5
130	19	8	500612325	5
131	13	2	500612325	5
132	20	9	500723657	5
133	24	6	500331458569	5
134	3	3	7787157830409532	5
135	43	11	0	5
136	7	4	7784665934773417	5
137	9	7	7782486528728599	5
138	12	1	500389661	5
139	18	7	500333995	5
140	22	11	500222663	5
141	17	6	600400795	5
142	16	5	500556659	5
143	46	11	989212833	5
144	30	10	500386951006	5
145	6	10	7790963778787456	5
146	15	4	200111331	5
147	10	9	7791588758369561	5
148	23	2	500609784301	5
149	35	11	4397904064025	5
150	4	6	7791428602092177	6
151	25	4	500275790126	6
152	45	11	0	6
153	2	8	7789780972493186	6
154	28	1	500945059618	6
155	14	3	300233797	6
156	29	11	500731566402	6
157	33	7	500935717605	6
158	32	5	501111882582	6
159	5	2	7797085875588287	6
160	31	3	500386951006	6
161	8	5	7798427326210446	6
162	44	11	0	6
163	21	10	300233797	6
164	27	8	500702756308	6
165	26	9	501139565457	6
166	42	11	0	6
167	1	1	7792786517032992	6
168	11	11	7794795978819754	6
169	19	8	255959973939	6
170	13	2	1276471420483	6
171	20	9	1148890600998	6
172	24	6	500563920568	6
173	3	3	7787157830409532	6
174	43	11	0	6
175	7	4	7784665934773417	6
176	9	7	7791882798334235	6
177	12	1	1531607559454	6
178	18	7	1659162934643	6
179	22	11	1404034961639	6
180	17	6	638751593150	6
181	16	5	1531616226486	6
182	46	11	989212833	6
183	30	10	500386951006	6
184	6	10	7790963778787456	6
185	15	4	200111331	6
186	10	9	7798093783101722	6
187	23	2	501074729631	6
188	35	11	4397904064025	6
228	4	6	7795234428549721	7
229	25	4	500275790126	7
230	45	11	0	7
231	2	8	7796762011081654	7
232	28	1	501434668271	7
233	14	3	300233797	7
234	29	11	500976025308	7
235	33	7	501180559385	7
236	5	2	7807238277488306	7
237	31	3	500386951006	7
238	44	11	0	7
239	27	8	501151475138	7
240	26	9	501628888398	7
241	42	11	0	7
242	1	1	7800402962366427	7
243	11	11	7798601433193071	7
244	19	8	1488377673722	7
245	13	2	3068577659162	7
246	20	9	2493036155003	7
247	24	6	500808427290	7
248	3	3	7787157830409532	7
249	43	11	0	7
250	7	4	7784665934773417	7
251	9	7	7795691232203602	7
252	12	1	2876173125247	7
253	18	7	2331672995249	7
254	22	11	2076019160808	7
255	17	6	1310801520267	7
256	46	11	989212833	7
257	15	4	200111331	7
258	10	9	7805708018655974	7
259	23	2	501727165864	7
260	35	11	4397887153697	7
261	4	6	7802998417554504	8
262	25	4	500275790126	8
263	45	11	0	8
264	2	8	7802733834205702	8
265	28	1	501703528329	8
266	14	3	300233797	8
267	29	11	501129318543	8
268	33	7	501641619726	8
269	5	2	7814403131140467	8
270	31	3	500386951006	8
271	44	11	0	8
272	27	8	501535325194	8
273	26	9	502127595242	8
274	42	11	0	8
275	1	1	7804585398333260	8
276	11	11	7800987724072167	8
277	19	8	2542687003095	8
278	13	2	4333435394359	8
279	20	9	3862949786771	8
280	24	6	501307228046	8
281	3	3	7787157830409532	8
282	43	11	0	8
283	7	4	7784665934773417	8
284	9	7	7802862872315164	8
285	12	1	3614697822770	8
286	18	7	3597728450364	8
287	22	11	2497784438805	8
288	17	6	2681395954849	8
289	46	11	989515978	8
290	15	4	200111331	8
291	10	9	7813468263871086	8
292	23	2	502187610177	8
293	35	11	4399234898245	8
327	4	6	7807120595051321	9
328	25	4	500275790126	9
329	45	11	0	9
330	2	8	7805482693220196	9
331	28	1	502100858093	9
332	14	3	300233797	9
333	29	11	501437719595	9
334	33	7	502083179918	9
335	5	2	7820581066404488	9
336	31	3	500386951006	9
337	44	11	0	9
338	27	8	501712013253	9
339	26	9	502348132861	9
340	42	11	0	9
341	1	1	7810766327708822	9
342	11	11	7805788546395300	9
343	19	8	3028307213183	9
344	13	2	5425309207131	9
345	20	9	4469552004782	9
346	24	6	501572059238	9
347	3	3	7787157830409532	9
348	43	11	0	9
349	7	4	7784665934773417	9
350	9	7	7809731189240557	9
351	12	1	4707349371247	9
352	18	7	4811972893265	9
353	22	11	3346928259389	9
354	17	6	3409673355730	9
355	46	11	990125235	9
356	15	4	200111331	9
357	10	9	7816899988602997	9
358	23	2	502584631229	9
359	48	8	2199616361840	9
360	35	11	2202324677700	9
361	4	6	7812341371693580	10
362	25	4	500275790126	10
363	45	11	0	10
364	2	8	7810702209221050	10
365	28	1	502603745024	10
366	14	3	300233797	10
367	29	11	501939915819	10
368	33	7	502552934927	10
369	5	2	7823707177183777	10
370	31	3	500386951006	10
371	44	11	0	10
372	27	8	502047507415	10
373	26	9	502716590305	10
374	42	11	0	10
375	1	1	7818589322328678	10
376	11	11	7813606142441144	10
377	19	8	3951019699842	10
378	13	2	5978846791130	10
379	20	9	5483929152514	10
380	24	6	501907470438	10
381	3	3	7787157830409532	10
382	43	11	0	10
383	7	4	7784665934773417	10
384	9	7	7817038066849592	10
385	12	1	6091760111440	10
386	18	7	6104465922196	10
387	22	11	4730209142309	10
388	17	6	4332468889392	10
389	46	11	991116857	10
390	15	4	200111331	10
391	10	9	7822633452717006	10
392	23	2	502785528735	10
393	48	8	2199616361840	10
394	35	11	2206733276538	10
395	4	6	7818326502170028	11
396	25	4	500275790126	11
397	45	11	0	11
398	2	8	7817776096146886	11
399	28	1	502988317506	11
400	14	3	300233797	11
401	29	11	502219301918	11
402	33	7	502972606272	11
403	5	2	7826422394475982	11
404	31	3	500386951006	11
405	44	11	0	11
406	27	8	502502194740	11
407	26	9	502960946932	11
408	42	11	0	11
409	1	1	7824571797255514	11
410	11	11	7817955294348646	11
411	19	8	5202534898299	11
412	13	2	6460194999117	11
413	20	9	6157559608805	11
414	24	6	502291987902	11
415	3	3	7787157830409532	11
416	43	11	0	11
417	7	4	7784665934773417	11
418	9	7	7823565910292048	11
419	12	1	7151218595321	11
420	18	7	7260443348201	11
421	22	11	5500217046565	11
422	17	6	5391545900048	11
423	46	11	991668525	11
424	15	4	200111331	11
425	10	9	7826435818442431	11
426	23	2	502960020434	11
427	48	8	2199600856314	11
428	35	11	2209184479058	11
429	4	6	7828515185938392	12
430	25	4	500275790126	12
431	45	11	0	12
432	2	8	7823137031591030	12
433	28	1	503298302733	12
434	14	3	300233797	12
435	29	11	502735823172	12
436	33	7	503282654955	12
437	5	2	7832307789590298	12
438	31	3	500386951006	12
439	44	11	0	12
440	27	8	502846778902	12
441	26	9	503167388281	12
442	42	11	0	12
443	1	1	7829393980159861	12
444	11	11	7825995885495144	12
445	19	8	6151746670086	12
446	13	2	7504054209046	12
447	20	9	6727016938098	12
448	24	6	502946564584	12
449	3	3	7787157830409532	12
450	43	11	0	12
451	7	4	7784665934773417	12
452	9	7	7828388610925863	12
453	12	1	8006065818743	12
454	18	7	8115448776090	12
455	22	11	6924082569755	12
456	17	6	7195289484074	12
457	46	11	992688433	12
458	15	4	200111331	12
459	10	9	7829648195035652	12
460	23	2	503338241579	12
461	48	8	2201111589446	12
462	35	11	2211453050926	12
463	4	6	7834846492829098	13
464	25	4	500275790126	13
465	45	11	0	13
466	2	8	7826829211788370	13
467	28	1	503670915091	13
468	14	3	300233797	13
469	29	11	503142204686	13
470	33	7	503452062338	13
471	5	2	7840207197700115	13
472	31	3	500386951006	13
473	44	11	0	13
474	27	8	503084100696	13
475	26	9	503641319910	13
476	42	11	0	13
477	1	1	7835190401368235	13
478	11	11	7832321951626386	13
479	19	8	6806120519801	13
480	13	2	8905648986909	13
481	20	9	8034973778402	13
482	24	6	503353322311	13
483	3	3	7787157830409532	13
484	43	11	0	13
485	7	4	7784665934773417	13
486	9	7	7831023684508892	13
487	34	13	4999527465877	13
488	12	1	9034742624842	13
489	18	7	8583302570228	13
490	22	11	8045729829511	13
491	17	6	8317171463948	13
492	46	11	993490862	13
493	15	4	200111331	13
494	10	9	7837022913693636	13
495	37	12	4999497471201	13
496	23	2	503845891979	13
497	48	8	2200624756332	13
498	35	11	2214765222774	13
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
8	7	t
9	8	t
11	9	t
12	10	t
13	11	t
14	12	t
15	13	t
\.


--
-- Data for Name: epoch_state; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_state (id, committee_id, no_confidence_id, constitution_id, epoch_no) FROM stdin;
1	1	\N	1	0
2	1	\N	1	1
3	1	\N	1	2
4	1	\N	1	3
5	1	\N	1	4
6	1	\N	1	5
7	1	\N	1	6
8	1	\N	1	7
9	1	\N	1	8
10	1	\N	1	9
11	1	\N	1	10
12	1	\N	1	11
13	1	\N	1	12
\.


--
-- Data for Name: epoch_sync_time; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_sync_time (id, no, seconds, state) FROM stdin;
1	0	74	following
2	1	200	following
3	2	201	following
4	3	200	following
5	4	202	following
6	5	200	following
7	6	201	following
8	7	199	following
9	8	201	following
10	9	205	following
11	10	199	following
12	11	205	following
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
1	184	0	\N	100000000000	35	18	3	ParameterChange	{"tag": "ParameterChange", "contents": [null, {"maxTxSize": 400, "costModels": {"PlutusV1": [205665, 812, 1, 1, 1000, 571, 0, 1, 1000, 24177, 4, 1, 1000, 32, 117366, 10475, 4, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 100, 100, 23000, 100, 19537, 32, 175354, 32, 46417, 4, 221973, 511, 0, 1, 89141, 32, 497525, 14068, 4, 2, 196500, 453240, 220, 0, 1, 1, 1000, 28662, 4, 2, 245000, 216773, 62, 1, 1060367, 12586, 1, 208512, 421, 1, 187000, 1000, 52998, 1, 80436, 32, 43249, 32, 1000, 32, 80556, 1, 57667, 4, 1000, 10, 197145, 156, 1, 197145, 156, 1, 204924, 473, 1, 208896, 511, 1, 52467, 32, 64832, 32, 65493, 32, 22558, 32, 16563, 32, 76511, 32, 196500, 453240, 220, 0, 1, 1, 69522, 11687, 0, 1, 60091, 32, 196500, 453240, 220, 0, 1, 1, 196500, 453240, 220, 0, 1, 1, 806990, 30482, 4, 1927926, 82523, 4, 265318, 0, 4, 0, 85931, 32, 205665, 812, 1, 1, 41182, 32, 212342, 32, 31220, 32, 32696, 32, 43357, 32, 32247, 32, 38314, 32, 57996947, 18975, 10], "PlutusV2": [205665, 812, 1, 1, 1000, 571, 0, 1, 1000, 24177, 4, 1, 1000, 32, 117366, 10475, 4, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 23000, 100, 100, 100, 23000, 100, 19537, 32, 175354, 32, 46417, 4, 221973, 511, 0, 1, 89141, 32, 497525, 14068, 4, 2, 196500, 453240, 220, 0, 1, 1, 1000, 28662, 4, 2, 245000, 216773, 62, 1, 1060367, 12586, 1, 208512, 421, 1, 187000, 1000, 52998, 1, 80436, 32, 43249, 32, 1000, 32, 80556, 1, 57667, 4, 1000, 10, 197145, 156, 1, 197145, 156, 1, 204924, 473, 1, 208896, 511, 1, 52467, 32, 64832, 32, 65493, 32, 22558, 32, 16563, 32, 76511, 32, 196500, 453240, 220, 0, 1, 1, 69522, 11687, 0, 1, 60091, 32, 196500, 453240, 220, 0, 1, 1, 196500, 453240, 220, 0, 1, 1, 1159724, 392670, 0, 2, 806990, 30482, 4, 1927926, 82523, 4, 265318, 0, 4, 0, 85931, 32, 205665, 812, 1, 1, 41182, 32, 212342, 32, 31220, 32, 32696, 32, 43357, 32, 32247, 32, 38314, 32, 35892428, 10, 57996947, 18975, 10, 38887044, 32947, 10]}, "txFeeFixed": 200, "dRepDeposit": 2000, "minPoolCost": 1000, "treasuryCut": 0.25, "dRepActivity": 5000, "maxValueSize": 954, "txFeePerByte": 100, "utxoCostPerByte": 35000, "committeeMinSize": 100, "govActionDeposit": 1000, "maxBlockBodySize": 300, "stakePoolDeposit": 200000000, "govActionLifetime": 1000000, "monetaryExpansion": {"numerator": 1, "denominator": 3}, "maxBlockHeaderSize": 500, "poolRetireMaxEpoch": 800, "stakePoolTargetNum": 900, "executionUnitPrices": {"priceSteps": 0.5, "priceMemory": 0.5}, "maxCollateralInputs": 100, "maxTxExecutionUnits": {"steps": 4294967296, "memory": 4294967296}, "poolPledgeInfluence": 0.5, "stakeAddressDeposit": 2000000, "collateralPercentage": 852, "dRepVotingThresholds": {"ppGovGroup": {"numerator": 6, "denominator": 7}, "ppNetworkGroup": {"numerator": 6, "denominator": 7}, "committeeNormal": {"numerator": 1, "denominator": 3}, "ppEconomicGroup": {"numerator": 6, "denominator": 7}, "ppTechnicalGroup": {"numerator": 6, "denominator": 7}, "hardForkInitiation": {"numerator": 4, "denominator": 7}, "motionNoConfidence": {"numerator": 1, "denominator": 3}, "treasuryWithdrawal": {"numerator": 6, "denominator": 7}, "updateToConstitution": {"numerator": 6, "denominator": 7}, "committeeNoConfidence": {"numerator": 1, "denominator": 3}}, "poolVotingThresholds": {"committeeNormal": {"numerator": 1, "denominator": 3}, "ppSecurityGroup": {"numerator": 1, "denominator": 3}, "hardForkInitiation": {"numerator": 6, "denominator": 7}, "motionNoConfidence": {"numerator": 1, "denominator": 3}, "committeeNoConfidence": {"numerator": 1, "denominator": 3}}, "committeeMaxTermLength": 200, "maxBlockExecutionUnits": {"steps": 4294967296, "memory": 4294967296}, "minFeeRefScriptCostPerByte": 44.5}, null]}	1	\N	\N	\N	\N
2	184	1	\N	100000000000	35	18	3	HardForkInitiation	{"tag": "HardForkInitiation", "contents": [null, {"major": 11, "minor": 0}]}	\N	\N	\N	\N	\N
3	184	2	\N	100000000000	35	18	3	TreasuryWithdrawals	{"tag": "TreasuryWithdrawals", "contents": [[[{"network": "Testnet", "credential": {"keyHash": "f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80"}}, 10000000]], null]}	\N	\N	\N	\N	\N
4	184	3	\N	100000000000	35	18	3	NoConfidence	{"tag": "NoConfidence", "contents": null}	\N	\N	\N	\N	\N
5	184	4	\N	100000000000	35	18	3	NewConstitution	{"tag": "NewConstitution", "contents": [null, {"anchor": {"url": "https://testing.this", "dataHash": "3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d"}}]}	\N	\N	\N	\N	\N
6	184	5	\N	100000000000	35	18	3	InfoAction	{"tag": "InfoAction"}	\N	\N	\N	\N	\N
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
9	1	133	9
10	1	133	10
11	1	133	11
12	1	134	12
13	1	135	13
14	1	136	14
15	-1	139	14
16	-1	139	9
17	-1	139	12
18	-1	139	10
19	-1	139	13
20	-1	140	11
21	1	141	11
22	1	142	11
23	-2	143	11
24	2	144	11
25	-2	145	11
26	2	146	11
27	-1	147	11
28	-1	148	11
29	1	149	15
30	1	149	16
31	1	149	17
32	-1	150	16
33	1	151	18
34	1	152	19
35	1	153	20
36	-1	154	18
37	-1	154	19
38	-1	154	20
39	-1	154	15
40	-1	154	17
41	10	157	21
42	-10	158	21
43	1	159	22
44	-1	160	22
45	1	409	9
46	1	409	10
47	1	409	11
48	1	410	12
49	1	411	13
50	1	412	14
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
9	1	169	9
10	1	169	10
11	1	169	11
12	1	171	12
13	1	173	13
14	1	175	14
15	1	175	9
16	1	175	10
17	1	175	11
18	1	176	11
19	1	177	14
20	1	177	9
21	1	177	10
22	1	179	14
23	1	179	9
24	1	179	12
25	1	179	10
26	1	179	13
27	1	182	11
28	1	184	11
29	2	187	11
30	2	190	11
31	1	192	11
32	1	194	15
33	1	194	16
34	1	194	17
35	1	197	15
36	1	197	17
37	1	198	18
38	1	199	15
39	1	199	17
40	1	200	19
41	1	202	20
42	1	203	19
43	10	209	21
44	1	212	22
45	1	852	8
46	13500000000000000	854	1
47	13500000000000000	854	2
48	13500000000000000	854	3
49	13500000000000000	854	4
50	1	857	9
51	1	857	10
52	1	857	11
53	1	859	12
54	1	861	13
55	1	863	14
\.


--
-- Data for Name: meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meta (id, start_time, network_name, version) FROM stdin;
1	2024-07-26 08:41:13	testnet	Version {versionBranch = [13,3,0,0], versionTags = []}
\.


--
-- Data for Name: multi_asset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.multi_asset (id, policy, name, fingerprint) FROM stdin;
1	\\x30c51387c9fcff0f644c880bb50768987ff0ef21134c4f7dafb8f16d	\\x	asset1l0l286zcl3kpwu26k3hvxcsmyqkct368kmzklk
2	\\x30c51387c9fcff0f644c880bb50768987ff0ef21134c4f7dafb8f16d	\\x74425443	asset1sjut5xldftqsgutxyavk8jeplt5z2zj7pamm55
3	\\x30c51387c9fcff0f644c880bb50768987ff0ef21134c4f7dafb8f16d	\\x74455448	asset1mthxjkse9qrlxz2uz4jd08qfwl5g0fdu7fxxh9
4	\\x30c51387c9fcff0f644c880bb50768987ff0ef21134c4f7dafb8f16d	\\x744d494e	asset1c55u483knxgwrxvhu4ywsx5jr96pupcas5lcvr
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
21	\\x4976d2d8dbb10f2d0ca68aa650492564319e61cf687f2ac04f1fbc44	\\x3030303030	asset1zyvnkhk5hgyzp8506sps7x40vlwthm6yxz22xe
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
1	7	SP11	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	{"name": "Stake Pool - 10 + 1", "ticker": "SP11", "homepage": "https://stakepool11.com", "description": "This is the stake pool 11 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130202b2031222c0a2020227469636b6572223a202253503131222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203131206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31312e636f6d220a7d0a	1
2	2	SP1	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	{"name": "stake pool - 1", "ticker": "SP1", "homepage": "https://stakepool1.com", "description": "This is the stake pool 1 description."}	\\x7b0a2020226e616d65223a20227374616b6520706f6f6c202d2031222c0a2020227469636b6572223a2022535031222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2031206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c312e636f6d220a7d0a	2
3	11	SP6a7	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	{"name": "", "ticker": "SP6a7", "homepage": "https://stakepool7.com", "description": "This is the stake pool 7 description."}	\\x7b0a2020226e616d65223a2022222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2037206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c372e636f6d220a7d0a	3
4	4	SP3	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	{"name": "Stake Pool - 3", "ticker": "SP3", "homepage": "https://stakepool3.com", "description": "This is the stake pool 3 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2033222c0a2020227469636b6572223a2022535033222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2033206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c332e636f6d220a7d0a	4
5	5	SP10	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	{"name": "Stake Pool - 10", "ticker": "SP10", "homepage": "https://stakepool10.com", "description": "This is the stake pool 10 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130222c0a2020227469636b6572223a202253503130222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203130206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31302e636f6d220a7d0a	5
6	8	SP5	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	{"name": "Same Name", "ticker": "SP5", "homepage": "https://stakepool5.com", "description": "This is the stake pool 5 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535035222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2035206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c352e636f6d220a7d0a	6
7	1	SP6a7	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	{"name": "Stake Pool - 6", "ticker": "SP6a7", "homepage": "https://stakepool6.com", "description": "This is the stake pool 6 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2036222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2036206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c362e636f6d220a7d0a	7
8	9	SP4	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	{"name": "Same Name", "ticker": "SP4", "homepage": "https://stakepool4.com", "description": "This is the stake pool 4 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535034222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2034206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c342e636f6d220a7d0a	8
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

COPY public.off_chain_vote_data (id, voting_anchor_id, hash, json, bytes, warning, language, comment, is_valid) FROM stdin;
\.


--
-- Data for Name: off_chain_vote_drep_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.off_chain_vote_drep_data (id, off_chain_vote_data_id, payment_address, given_name, objectives, motivations, qualifications, image_url, image_hash) FROM stdin;
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
1	1	Error Offchain Voting Anchor: HTTP Exception error for ipfs://QmQq5hWDNzvDR1ForEktAHrdCQmfSL2u5yctNpzDwoSBu4 resulted in : "InvalidUrlException \\"ipfs://QmQq5hWDNzvDR1ForEktAHrdCQmfSL2u5yctNpzDwoSBu4\\" \\"Invalid scheme\\""	2024-07-26 08:48:20.45268	0
2	2	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this.	2024-07-26 08:53:20.460176	0
3	3	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this.	2024-07-26 08:53:20.460176	0
4	8	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this.	2024-07-26 08:53:20.460176	0
5	1	Error Offchain Voting Anchor: HTTP Exception error for ipfs://QmQq5hWDNzvDR1ForEktAHrdCQmfSL2u5yctNpzDwoSBu4 resulted in : "InvalidUrlException \\"ipfs://QmQq5hWDNzvDR1ForEktAHrdCQmfSL2u5yctNpzDwoSBu4\\" \\"Invalid scheme\\""	2024-07-26 08:53:20.460176	1
6	8	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this.	2024-07-26 08:58:20.770759	1
7	3	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this.	2024-07-26 08:58:20.770759	1
8	1	Error Offchain Voting Anchor: HTTP Exception error for ipfs://QmQq5hWDNzvDR1ForEktAHrdCQmfSL2u5yctNpzDwoSBu4 resulted in : "InvalidUrlException \\"ipfs://QmQq5hWDNzvDR1ForEktAHrdCQmfSL2u5yctNpzDwoSBu4\\" \\"Invalid scheme\\""	2024-07-26 08:58:20.770759	2
9	2	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this.	2024-07-26 08:58:20.770759	1
10	2	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this.	2024-07-26 09:03:21.065583	2
11	3	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this.	2024-07-26 09:03:21.065583	2
12	8	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this.	2024-07-26 09:03:21.065583	2
13	1	Error Offchain Voting Anchor: HTTP Exception error for ipfs://QmQq5hWDNzvDR1ForEktAHrdCQmfSL2u5yctNpzDwoSBu4 resulted in : "InvalidUrlException \\"ipfs://QmQq5hWDNzvDR1ForEktAHrdCQmfSL2u5yctNpzDwoSBu4\\" \\"Invalid scheme\\""	2024-07-26 09:08:21.265733	3
14	3	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this.	2024-07-26 09:13:21.26912	3
15	2	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this.	2024-07-26 09:13:21.26912	3
16	8	Error Offchain Voting Anchor: Connection failure error when fetching metadata from https://testing.this.	2024-07-26 09:13:21.26912	3
\.


--
-- Data for Name: off_chain_vote_gov_action_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.off_chain_vote_gov_action_data (id, off_chain_vote_data_id, title, abstract, motivation, rationale) FROM stdin;
\.


--
-- Data for Name: off_chain_vote_reference; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.off_chain_vote_reference (id, off_chain_vote_data_id, label, uri, hash_digest, hash_algorithm) FROM stdin;
\.


--
-- Data for Name: param_proposal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.param_proposal (id, epoch_no, key, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, entropy, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, registered_tx_id, coins_per_utxo_size, pvt_motion_no_confidence, pvt_committee_normal, pvt_committee_no_confidence, pvt_hard_fork_initiation, dvt_motion_no_confidence, dvt_committee_normal, dvt_committee_no_confidence, dvt_update_to_constitution, dvt_hard_fork_initiation, dvt_p_p_network_group, dvt_p_p_economic_group, dvt_p_p_technical_group, dvt_p_p_gov_group, dvt_treasury_withdrawal, committee_min_size, committee_max_term_length, gov_action_lifetime, gov_action_deposit, drep_deposit, drep_activity, pvtpp_security_group, min_fee_ref_script_cost_per_byte) FROM stdin;
1	\N	\N	100	200	300	400	500	2000000	200000000	800	900	0.5	0.3333333333333333	0.25	\N	\N	\N	\N	\N	1000	5	0.5	0.5	4294967296	4294967296	4294967296	4294967296	954	852	100	184	35000	0.3333333333333333	0.3333333333333333	0.3333333333333333	0.8571428571428571	0.3333333333333333	0.3333333333333333	0.3333333333333333	0.8571428571428571	0.5714285714285714	0.8571428571428571	0.8571428571428571	0.8571428571428571	0.8571428571428571	0.8571428571428571	100	200	1000000	1000	2000	5000	0.3333333333333333	44.5
\.


--
-- Data for Name: pool_hash; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_hash (id, hash_raw, view) FROM stdin;
1	\\x388256ea6d8404e402d5e9f3d3f0507bdb734fdf405e6ea5ddc34a73	pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc
2	\\x5148025323825b67898f81f3da8d69d75b0c6bfca7218128036c0855	pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz
3	\\x715b98fb98b35b09398c9e2ad90166138de233c0e4ae4615fd233188	pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g
4	\\x7debbb717e5a3a1fde6089eec6f4ae8810dd642aeccf249c89baf543	pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5
5	\\x8d836d482503cad3c449cca6f7041637f8533a69260b42801bf58e17	pool13kpk6jp9q09d83zfejn0wpqkxlu9xwnfyc959qqm7k8pwxyymf8
6	\\xb7275c0659a4aafb36a75d8aa14e0acd403235233e7c45a6ba480e23	pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw
7	\\xc2708cc2e1ce7942205847bcce85719c48bbb8acbc46d44c16ba554f	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5
8	\\xc66cea9a75934694cca07dc9216180d4e7063365af27c1d67df28e14	pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve
9	\\xcf5a14bd1e7148b65dbe1d7195421010fd607f6cb4f10d8b3bf622a3	pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg
10	\\xd5bb7beb32da145c62236d739c6ef381b74d4adc2b4ffeff9dd83ad8	pool16kahh6ejmg29cc3rd4eecmhnsxm56jku9d8laluamqadsplvkx5
11	\\xf2e2f054b20b4cacaa5ed0c2b6b82278aa258f84a058d66b9e7167e6	pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf
12	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
13	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_metadata_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata_ref (id, pool_id, url, hash, registered_tx_id) FROM stdin;
1	7	http://file-server/SP11.json	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	101
2	2	http://file-server/SP1.json	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	102
3	11	http://file-server/SP7.json	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	103
4	4	http://file-server/SP3.json	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	104
5	5	http://file-server/SP10.json	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	105
6	8	http://file-server/SP5.json	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	106
7	1	http://file-server/SP6.json	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	109
8	9	http://file-server/SP4.json	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	111
\.


--
-- Data for Name: pool_owner; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_owner (id, addr_id, pool_update_id) FROM stdin;
1	18	12
2	13	13
3	22	14
4	15	15
5	16	16
6	19	17
7	21	18
8	14	19
9	12	20
10	17	21
11	20	22
12	37	23
13	34	24
\.


--
-- Data for Name: pool_relay; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_relay (id, update_id, ipv4, ipv6, dns_name, dns_srv_name, port) FROM stdin;
1	12	127.0.0.1	\N	\N	\N	30011
2	13	127.0.0.1	\N	\N	\N	3001
3	14	127.0.0.1	\N	\N	\N	3007
4	15	127.0.0.1	\N	\N	\N	3003
5	16	127.0.0.1	\N	\N	\N	30010
6	17	127.0.0.1	\N	\N	\N	3005
7	18	127.0.0.1	\N	\N	\N	3008
8	19	127.0.0.1	\N	\N	\N	3009
9	20	127.0.0.1	\N	\N	\N	3006
10	21	127.0.0.1	\N	\N	\N	3002
11	22	127.0.0.1	\N	\N	\N	3004
12	23	127.0.0.1	\N	\N	\N	6000
13	24	127.0.0.2	\N	\N	\N	6000
\.


--
-- Data for Name: pool_retire; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retire (id, hash_id, cert_index, announced_tx_id, retiring_epoch) FROM stdin;
1	3	0	116	18
2	7	0	117	18
3	5	0	118	5
4	10	0	119	5
\.


--
-- Data for Name: pool_stat; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_stat (id, pool_hash_id, epoch_no, number_of_blocks, number_of_delegators, stake, voting_power) FROM stdin;
\.


--
-- Data for Name: pool_update; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_update (id, hash_id, cert_index, vrf_key_hash, pledge, active_epoch_no, meta_id, margin, fixed_cost, registered_tx_id, reward_addr_id, deposit) FROM stdin;
1	1	0	\\x9a196bdc4c92d9e06351e6df1f596e564bfd343c1c57b3971a3c54007af64294	0	2	\N	0	0	34	12	\N
2	2	1	\\xb76dd2f97a1857fb3367b4228a880aadd711d9b4c54cca7a88cb0c4d1a967588	0	2	\N	0	0	34	13	\N
3	3	2	\\xad94751659b91c51a5eb1df6804c329cadf37df587c4d41d54b0b7c76c6460c9	0	2	\N	0	0	34	14	\N
4	4	3	\\x93e6b92de27fd14f9ceb483e655ebc2d258829966000fcadb408ba9a3db1821d	0	2	\N	0	0	34	15	\N
5	5	4	\\xb12a829458e487ca0349e732f9996373b4d372d42ad289b1e1ede606fa97e02f	0	2	\N	0	0	34	16	\N
6	6	5	\\xb4591f64145a52b57f5f29c7b5bd616072862034c95ff46754057bcf78ae05b5	0	2	\N	0	0	34	17	\N
7	7	6	\\xe87c80a007d721c33bc271dac5d5c41b9fa959798b1f740248e1d98ab01cd365	0	2	\N	0	0	34	18	\N
8	8	7	\\x787d72c8279534c2bb2fe4d6a2db7d17766114ee6b2a029aa4d2fdfcccf56c8a	0	2	\N	0	0	34	19	\N
9	9	8	\\xbc2a2cd2c1a7fa821532ec8a30134c4045afffc6b9510c4c92f2c206d955ec21	0	2	\N	0	0	34	20	\N
10	10	9	\\x0292d8379ed785cef6e419eef4d0d5552478ad027903bc603f423ba270c19e71	0	2	\N	0	0	34	21	\N
11	11	10	\\x220ba9398e3e5fae23a83d0d5927649d577a5f69d6ef1d5253c259d9393ba294	0	2	\N	0	0	34	22	\N
12	7	0	\\xe87c80a007d721c33bc271dac5d5c41b9fa959798b1f740248e1d98ab01cd365	400000000	3	1	0.15	390000000	101	18	\N
13	2	0	\\xb76dd2f97a1857fb3367b4228a880aadd711d9b4c54cca7a88cb0c4d1a967588	400000000	3	2	0.15	390000000	102	13	\N
14	11	0	\\x220ba9398e3e5fae23a83d0d5927649d577a5f69d6ef1d5253c259d9393ba294	410000000	3	3	0.15	390000000	103	22	\N
15	4	0	\\x93e6b92de27fd14f9ceb483e655ebc2d258829966000fcadb408ba9a3db1821d	600000000	3	4	0.15	390000000	104	15	\N
16	5	0	\\xb12a829458e487ca0349e732f9996373b4d372d42ad289b1e1ede606fa97e02f	400000000	3	5	0.15	410000000	105	16	\N
17	8	0	\\x787d72c8279534c2bb2fe4d6a2db7d17766114ee6b2a029aa4d2fdfcccf56c8a	410000000	3	6	0.15	390000000	106	19	\N
18	10	0	\\x0292d8379ed785cef6e419eef4d0d5552478ad027903bc603f423ba270c19e71	500000000	3	\N	0.15	380000000	107	21	\N
19	3	0	\\xad94751659b91c51a5eb1df6804c329cadf37df587c4d41d54b0b7c76c6460c9	500000000	3	\N	0.15	390000000	108	14	\N
20	1	0	\\x9a196bdc4c92d9e06351e6df1f596e564bfd343c1c57b3971a3c54007af64294	410000000	3	7	0.15	400000000	109	12	\N
21	6	0	\\xb4591f64145a52b57f5f29c7b5bd616072862034c95ff46754057bcf78ae05b5	500000000	3	\N	0.15	390000000	110	17	\N
22	9	0	\\xbc2a2cd2c1a7fa821532ec8a30134c4045afffc6b9510c4c92f2c206d955ec21	420000000	3	8	0.15	370000000	111	20	\N
23	12	0	\\x2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	500000000000000	13	\N	0.2	1000	402	37	500000000
24	13	0	\\x641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	50000000	13	\N	0.2	1000	406	34	500000000
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
9	11	12:56:
10	12	::
11	13	::
12	14	::
13	15	::
14	16	::
15	17	::
16	18	::
17	19	23:67:
18	20	34:89:
19	21	::
20	22	45:100:
21	23	56:111:
22	24	::
23	25	::
24	26	67:122:
25	27	78:133:
26	28	82:137:
27	29	::
28	30	::
29	31	::
30	32	86:141:
31	33	::
32	34	::
33	35	87:143:
34	36	88:144:
35	37	::
36	38	::
37	39	89:146:
38	40	90:148:
39	41	91:150:
40	42	92:152:
41	43	::
42	44	::
43	45	93:154:
44	46	::
45	47	::
46	48	94:156:
47	49	::
48	50	96:157:1
49	51	97:159:
50	52	98:165:5
51	53	99:167:8
52	54	::
53	55	::
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
99	101	100:169:9
100	102	::
101	103	::
102	104	::
103	105	101:171:12
104	106	::
105	107	::
106	108	::
107	109	102:173:13
108	110	::
109	111	::
110	112	::
111	113	103:175:14
112	114	::
113	115	::
114	116	::
115	117	104:176:18
116	118	::
117	119	::
118	120	::
119	121	106:178:22
120	122	::
121	123	::
122	124	::
123	125	109:180:
124	126	::
125	127	::
126	128	::
127	129	110:181:
128	130	::
129	131	::
130	132	::
131	133	111:182:27
132	134	::
133	135	::
134	136	::
135	137	112:184:28
136	138	::
137	139	::
138	140	::
139	141	113:186:
140	142	::
141	143	::
142	144	::
143	145	115:187:29
144	146	::
145	147	::
146	148	::
147	149	116:189:
148	150	::
149	151	::
150	152	::
151	153	117:190:30
152	154	::
153	155	::
154	156	::
155	157	118:192:31
156	158	::
157	159	::
158	160	::
159	161	119:193:
160	162	::
161	163	::
162	164	::
163	165	::
164	166	120:194:32
165	167	::
166	168	::
167	169	::
168	170	122:196:35
169	171	::
170	172	::
171	173	::
172	174	124:198:37
173	175	::
174	176	::
175	177	::
176	178	125:200:40
177	179	::
178	180	::
179	181	::
180	182	127:202:41
181	183	::
183	185	::
184	186	::
185	187	129:204:
186	188	::
187	189	::
188	190	::
189	191	::
190	192	133:205:
191	193	::
192	194	::
193	195	::
194	196	137:209:43
195	197	::
196	198	::
197	199	::
198	200	138:211:
199	201	::
200	202	::
201	203	::
202	204	139:212:44
203	205	::
204	206	::
205	207	::
206	208	141:214:
207	209	::
208	210	::
209	211	::
210	212	::
211	213	142:215:
212	214	143:335:
213	215	::
214	216	203:337:
215	217	204:339:
216	218	::
217	219	::
218	220	205:341:
219	221	206:343:
220	222	::
221	223	::
222	224	::
223	225	::
224	226	207:345:
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
238	240	::
239	241	::
240	242	::
241	243	::
242	244	::
243	245	::
244	246	::
245	247	::
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
305	307	208:347:
306	308	::
307	309	209:349:
308	310	::
309	311	210:350:
310	312	::
311	313	211:351:
312	314	::
313	315	212:352:
314	316	::
315	317	213:353:
316	318	::
317	319	214:354:
318	320	::
319	321	215:355:
320	322	::
321	323	216:356:
322	324	::
323	325	217:357:
324	326	::
325	327	218:358:
326	328	::
327	329	219:359:
328	330	::
329	331	220:360:
330	332	::
331	333	221:361:
332	334	::
333	335	222:362:
334	336	::
335	337	223:363:
336	338	::
337	339	224:364:
338	340	::
339	341	259:365:
340	342	::
341	343	260:366:
342	344	::
343	345	261:367:
344	346	::
345	347	262:368:
346	348	::
347	349	::
349	351	::
350	352	263:370:
351	353	::
352	354	::
353	355	::
354	356	264:405:
355	357	::
356	358	::
357	359	::
358	360	299:414:
359	361	::
360	362	::
361	363	::
362	364	300:415:
363	365	301:417:
365	367	303:420:
366	368	304:421:
367	369	::
368	370	305:423:
369	371	::
370	372	::
371	373	::
372	374	::
373	375	306:424:
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
442	444	::
443	445	::
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
510	512	307:425:
511	513	359:503:
512	514	::
513	515	::
514	516	::
515	517	::
516	518	::
517	519	::
518	520	::
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
578	580	::
579	581	::
580	582	::
581	583	::
582	584	::
583	585	::
584	586	::
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
636	638	::
637	639	::
638	640	::
639	641	::
641	643	::
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
731	733	455:625:
732	734	::
733	735	::
734	736	::
735	737	::
736	738	::
737	739	456:627:
738	740	::
739	741	::
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
893	895	::
894	896	::
895	897	::
896	898	::
897	899	::
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
931	933	542:641:
932	934	595:711:
933	935	687:825:
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
970	972	::
971	973	::
972	974	::
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
1126	1128	702:841:
1127	1129	::
1128	1130	::
1129	1131	::
1130	1132	::
1131	1133	::
1132	1134	703:843:
1133	1135	::
1134	1136	::
1135	1137	::
1136	1138	704:845:
1137	1139	::
1138	1140	::
1139	1141	::
1141	1143	708:849:
1142	1144	::
1143	1145	::
1144	1146	::
1145	1147	710:851:45
1146	1148	::
1147	1149	::
1148	1150	::
1149	1151	712:853:46
1150	1152	::
1151	1153	::
1152	1154	::
1153	1155	713:855:
1154	1156	::
1155	1157	::
1156	1158	::
1157	1159	715:857:50
1158	1160	::
1159	1161	::
1160	1162	::
1161	1163	716:859:53
1162	1164	::
1163	1165	::
1164	1166	::
1165	1167	720:861:54
1166	1168	::
1167	1169	::
1168	1170	::
1169	1171	721:863:55
1170	1172	::
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
1234	1236	::
1235	1237	::
1236	1238	::
1237	1239	::
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
1262	1264	::
1263	1265	::
1264	1266	::
1265	1267	::
1266	1268	::
1267	1269	::
1268	1270	::
1269	1271	::
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
1288	1290	::
\.


--
-- Data for Name: reward; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward (addr_id, type, amount, spendable_epoch, pool_id) FROM stdin;
4	member	9895465782602	3	6
2	member	6089517404678	3	8
5	member	7611896755848	3	2
8	member	8373086431433	3	5
1	member	5328327729093	3	1
11	member	10656655458187	3	11
3	member	8373086431433	3	3
7	member	7611896755848	3	4
9	member	4567138053508	3	7
6	member	12179034809357	3	10
10	member	7611896755848	3	9
14	leader	0	3	3
21	leader	0	3	10
19	leader	0	3	8
13	leader	0	3	2
20	leader	0	3	9
12	leader	0	3	1
18	leader	0	3	7
22	leader	0	3	11
17	leader	0	3	6
16	leader	0	3	5
15	leader	0	3	4
4	member	5192117813994	4	6
25	member	278328517	4	4
2	member	9518882903912	4	8
28	member	389659895	4	1
14	member	233797	4	3
29	member	222662797	4	11
33	member	333994080	4	7
32	member	556656800	4	5
5	member	9518882903912	4	2
31	member	389659782	4	3
8	member	8653529913032	4	5
21	member	233797	4	10
27	member	612322692	4	8
26	member	723654090	4	9
1	member	6057470938853	4	1
11	member	3461411965058	4	11
19	member	612325	4	8
13	member	612325	4	2
20	member	723657	4	9
24	member	333994188	4	6
3	member	6057471250827	4	3
7	member	4326765290297	4	4
9	member	5192117947819	4	7
12	member	389661	4	1
18	member	333995	4	7
22	member	222663	4	11
17	member	400795	4	6
16	member	556659	4	5
30	member	389659782	4	10
6	member	6057471250827	4	10
15	member	111331	4	4
10	member	11249588886441	4	9
23	member	612322692	4	2
14	leader	0	4	3
21	leader	0	4	10
19	leader	0	4	8
13	leader	0	4	2
20	leader	0	4	9
12	leader	0	4	1
18	leader	0	4	7
22	leader	0	4	11
17	leader	0	4	6
16	leader	0	4	5
15	leader	0	4	4
4	member	3613745768309	5	6
2	member	1445299457324	5	8
28	member	557938114	5	1
29	member	511441996	5	11
33	member	604435117	5	7
32	member	557937374	5	5
5	member	7227823201247	5	2
8	member	8673437138709	5	5
27	member	92972007	5	8
26	member	418449758	5	9
1	member	8673445637774	5	1
11	member	7950638669237	5	11
24	member	232461999	5	6
9	member	9396269605636	5	7
10	member	6505024732161	5	9
23	member	464945330	5	2
14	leader	0	5	3
21	leader	0	5	10
19	leader	255459361614	5	8
13	leader	1275970808158	5	2
20	leader	1148389877341	5	9
12	leader	1531107169793	5	1
18	leader	1658662600648	5	7
22	leader	1403534738976	5	11
17	leader	638151192355	5	6
16	leader	1531115669827	5	5
15	leader	0	5	4
4	member	3805826457544	6	6
2	member	6981038588468	6	8
28	member	489608653	6	1
29	member	244458906	6	11
33	member	244841780	6	7
32	member	285371838	6	5
5	member	10152401900019	6	2
8	member	4441037908545	6	5
27	member	448718830	6	8
26	member	489322941	6	9
1	member	7616445333435	6	1
11	member	3805454373317	6	11
24	member	244506722	6	6
9	member	3808433869367	6	7
10	member	7614235554252	6	9
23	member	652436233	6	2
14	leader	0	6	3
21	leader	0	6	10
19	leader	1232417699783	6	8
13	leader	1792106238679	6	2
20	leader	1344145554005	6	9
12	leader	1344565565793	6	1
18	leader	672510060606	6	7
22	leader	671984199169	6	11
17	leader	672049927117	6	6
16	leader	784173267565	6	5
15	leader	0	6	4
4	member	7763989004783	7	6
2	member	5971823124048	7	8
28	member	268860058	7	1
29	member	153293235	7	11
33	member	461060341	7	7
32	member	383666418	7	5
5	member	7164853652161	7	2
8	member	5970719049928	7	5
27	member	383850056	7	8
26	member	498706844	7	9
1	member	4182435966833	7	1
11	member	2386290879096	7	11
24	member	498800756	7	6
9	member	7171640111562	7	7
46	member	303145	7	11
10	member	7760245215112	7	9
23	member	460444313	7	2
35	member	1347744548	7	11
14	leader	0	7	3
21	leader	0	7	10
19	leader	1054309329373	7	8
13	leader	1264857735197	7	2
20	leader	1369913631768	7	9
12	leader	738524697523	7	1
18	leader	1266055455115	7	7
22	leader	421765277997	7	11
17	leader	1370594434582	7	6
16	leader	1054134460141	7	5
15	leader	0	7	4
4	member	4122177496817	8	6
2	member	2748859014494	8	8
28	member	397329764	8	1
29	member	308401052	8	11
33	member	441560192	8	7
32	member	352785841	8	5
5	member	6177935264021	8	2
8	member	5490140713586	8	5
27	member	176688059	8	8
26	member	220537619	8	9
1	member	6180929375562	8	1
11	member	4800822323133	8	11
24	member	264831192	8	6
9	member	6868316925393	8	7
46	member	609257	8	11
10	member	3431724731911	8	9
23	member	397021052	8	2
35	member	2708673333	8	11
14	leader	0	8	3
21	leader	0	8	10
19	leader	485620210088	8	8
13	leader	1091873812772	8	2
20	leader	606602218011	8	9
12	leader	1092651548477	8	1
18	leader	1214244442901	8	7
22	leader	849143820584	8	11
17	leader	728277400881	8	6
16	leader	970589167224	8	5
15	leader	0	8	4
4	member	5220776642259	9	6
2	member	5219516000854	9	8
28	member	502886931	9	1
29	member	502196224	9	11
33	member	469755009	9	7
5	member	3126110779289	9	2
27	member	335494162	9	8
26	member	368457444	9	9
1	member	7822994619856	9	1
11	member	7817596045844	9	11
24	member	335411200	9	6
9	member	7306877609035	9	7
46	member	991622	9	11
14	leader	0	9	3
19	leader	922712486659	9	8
13	leader	553537583999	9	2
20	leader	1014377147732	9	9
12	leader	1384410740193	9	1
18	leader	1292493028931	9	7
22	leader	1383280882920	9	11
17	leader	922795533662	9	6
15	leader	0	9	4
10	member	5733464114009	9	9
23	member	200897506	9	2
35	member	4408598838	9	11
4	member	5985130476448	10	6
2	member	7073886925836	10	8
28	member	384572482	10	1
29	member	279386099	10	11
33	member	419671345	10	7
5	member	2715217292205	10	2
27	member	454687325	10	8
26	member	244356627	10	9
1	member	5982474926836	10	1
11	member	4349151907502	10	11
24	member	384517464	10	6
9	member	6527843442456	10	7
46	member	551668	10	11
10	member	3802365725425	10	9
23	member	174491699	10	2
35	member	2452630554	10	11
14	leader	0	10	3
19	leader	1251515198457	10	8
13	leader	481348207987	10	2
20	leader	673630456291	10	9
12	leader	1059458483881	10	1
18	leader	1155977426005	10	7
22	leader	770007904256	10	11
17	leader	1059077010656	10	6
15	leader	0	10	4
4	member	10188683768364	11	6
2	member	5360935444144	11	8
28	member	309985227	11	1
29	member	516521254	11	11
33	member	310048683	11	7
5	member	5885395114316	11	2
27	member	344584162	11	8
26	member	206441349	11	9
1	member	4822182904347	11	1
11	member	8040591146498	11	11
24	member	654576682	11	6
9	member	4822700633815	11	7
46	member	1019908	11	11
10	member	3212376593221	11	9
23	member	378221145	11	2
14	leader	0	11	3
19	leader	949211771787	11	8
13	leader	1043859209929	11	2
20	leader	569457329293	11	9
12	leader	854847223422	11	1
18	leader	855005427889	11	7
22	leader	1423865523190	11	11
17	leader	1803743584026	11	6
15	leader	0	11	4
48	member	1510733132	11	8
35	member	2268571868	11	11
4	member	6331306890706	12	6
2	member	3692180197340	12	8
28	member	372612358	12	1
29	member	406381514	12	11
33	member	169407383	12	7
5	member	7899408109817	12	2
27	member	237321794	12	8
26	member	473931629	12	9
1	member	5796421208374	12	1
11	member	6326066131242	12	11
24	member	406757727	12	6
9	member	2635073583029	12	7
46	member	802429	12	11
10	member	7374718657984	12	9
23	member	507650400	12	2
48	member	1039775906	12	8
35	member	1786619441	12	11
14	leader	0	12	3
19	leader	654373849715	12	8
13	leader	1401594777863	12	2
20	leader	1307956840304	12	9
12	leader	1028676806099	12	1
18	leader	467853794138	12	7
22	leader	1121647259756	12	11
17	leader	1121881979874	12	6
15	leader	0	12	4
4	member	6748041072028	13	6
2	member	4669546569340	13	8
28	member	266603545	13	1
29	member	199951262	13	11
33	member	166652528	13	7
5	member	2591807919209	13	2
27	member	300143847	13	8
26	member	466445156	13	9
1	member	4147330088125	13	1
11	member	3112604440744	13	11
24	member	433531007	13	6
9	member	2592222760768	13	7
46	member	394818	13	11
10	member	7258223729183	13	9
23	member	166560875	13	2
48	member	1313818470	13	8
35	member	879554456	13	11
14	leader	0	13	3
19	leader	828368289954	13	8
13	leader	460314162756	13	2
20	leader	1288033572733	13	9
12	leader	736788153199	13	1
18	leader	460700649917	13	7
22	leader	552439978920	13	11
17	leader	1196771957291	13	6
15	leader	0	13	4
\.


--
-- Data for Name: reward_rest; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward_rest (addr_id, type, amount, spendable_epoch) FROM stdin;
\.


--
-- Data for Name: schema_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_version (id, stage_one, stage_two, stage_three) FROM stdin;
1	14	41	6
\.


--
-- Data for Name: script; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.script (id, tx_id, hash, type, json, bytes, serialised_size) FROM stdin;
1	121	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	plutusV1	\N	\\x4d01000033222220051200120011	14
2	123	\\x477e52b3116b62fe8cd34a312615f5fcd678c94e1d6cdb86c1a3964c	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "e09d36c79dec9bd1b3d9e152247701cd0bb860b5ebfd1de8abb6735a"}, {"type": "sig", "keyHash": "a687dcc24e00dd3caafbeb5e68f97ca8ef269cb6fe971345eb951756"}, {"type": "sig", "keyHash": "0bd1d702b2e6188fe0857a6dc7ffb0675229bab58c86638ffa87ed6d"}]}	\N	\N
3	124	\\x120125c6dea2049988eb0dc8ddcc4c56dd48628d45206a2d0bc7e55b	timelock	{"type": "all", "scripts": [{"slot": 1000, "type": "after"}, {"type": "sig", "keyHash": "966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37"}]}	\N	\N
4	126	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	plutusV2	\N	\\x5908920100003233223232323232332232323232323232323232332232323232322223232533532323232325335001101d13357389211e77726f6e67207573616765206f66207265666572656e636520696e7075740001c3232533500221533500221333573466e1c00800408007c407854cd4004840784078d40900114cd4c8d400488888888888802d40044c08526221533500115333533550222350012222002350022200115024213355023320015021001232153353235001222222222222300e00250052133550253200150233355025200100115026320013550272253350011502722135002225335333573466e3c00801c0940904d40b00044c01800c884c09526135001220023333573466e1cd55cea80224000466442466002006004646464646464646464646464646666ae68cdc39aab9d500c480008cccccccccccc88888888888848cccccccccccc00403403002c02802402001c01801401000c008cd405c060d5d0a80619a80b80c1aba1500b33501701935742a014666aa036eb94068d5d0a804999aa80dbae501a35742a01066a02e0446ae85401cccd5406c08dd69aba150063232323333573466e1cd55cea801240004664424660020060046464646666ae68cdc39aab9d5002480008cc8848cc00400c008cd40b5d69aba15002302e357426ae8940088c98c80c0cd5ce01901a01709aab9e5001137540026ae854008c8c8c8cccd5cd19b8735573aa004900011991091980080180119a816bad35742a004605c6ae84d5d1280111931901819ab9c03203402e135573ca00226ea8004d5d09aba2500223263202c33573805c06005426aae7940044dd50009aba1500533501775c6ae854010ccd5406c07c8004d5d0a801999aa80dbae200135742a00460426ae84d5d1280111931901419ab9c02a02c026135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d55cf280089baa00135742a00860226ae84d5d1280211931900d19ab9c01c01e018375a00a6666ae68cdc39aab9d375400a9000100e11931900c19ab9c01a01c016101b132632017335738921035054350001b135573ca00226ea800448c88c008dd6000990009aa80d911999aab9f0012500a233500930043574200460066ae880080608c8c8cccd5cd19b8735573aa004900011991091980080180118061aba150023005357426ae8940088c98c8050cd5ce00b00c00909aab9e5001137540024646464646666ae68cdc39aab9d5004480008cccc888848cccc00401401000c008c8c8c8cccd5cd19b8735573aa0049000119910919800801801180a9aba1500233500f014357426ae8940088c98c8064cd5ce00d80e80b89aab9e5001137540026ae854010ccd54021d728039aba150033232323333573466e1d4005200423212223002004357426aae79400c8cccd5cd19b875002480088c84888c004010dd71aba135573ca00846666ae68cdc3a801a400042444006464c6403666ae7007407c06406005c4d55cea80089baa00135742a00466a016eb8d5d09aba2500223263201533573802e03202626ae8940044d5d1280089aab9e500113754002266aa002eb9d6889119118011bab00132001355018223233335573e0044a010466a00e66442466002006004600c6aae754008c014d55cf280118021aba200301613574200222440042442446600200800624464646666ae68cdc3a800a400046a02e600a6ae84d55cf280191999ab9a3370ea00490011280b91931900819ab9c01201400e00d135573aa00226ea80048c8c8cccd5cd19b875001480188c848888c010014c01cd5d09aab9e500323333573466e1d400920042321222230020053009357426aae7940108cccd5cd19b875003480088c848888c004014c01cd5d09aab9e500523333573466e1d40112000232122223003005375c6ae84d55cf280311931900819ab9c01201400e00d00c00b135573aa00226ea80048c8c8cccd5cd19b8735573aa004900011991091980080180118029aba15002375a6ae84d5d1280111931900619ab9c00e01000a135573ca00226ea80048c8cccd5cd19b8735573aa002900011bae357426aae7940088c98c8028cd5ce00600700409baa001232323232323333573466e1d4005200c21222222200323333573466e1d4009200a21222222200423333573466e1d400d2008233221222222233001009008375c6ae854014dd69aba135744a00a46666ae68cdc3a8022400c4664424444444660040120106eb8d5d0a8039bae357426ae89401c8cccd5cd19b875005480108cc8848888888cc018024020c030d5d0a8049bae357426ae8940248cccd5cd19b875006480088c848888888c01c020c034d5d09aab9e500b23333573466e1d401d2000232122222223005008300e357426aae7940308c98c804ccd5ce00a80b80880800780700680600589aab9d5004135573ca00626aae7940084d55cf280089baa0012323232323333573466e1d400520022333222122333001005004003375a6ae854010dd69aba15003375a6ae84d5d1280191999ab9a3370ea0049000119091180100198041aba135573ca00c464c6401866ae700380400280244d55cea80189aba25001135573ca00226ea80048c8c8cccd5cd19b875001480088c8488c00400cdd71aba135573ca00646666ae68cdc3a8012400046424460040066eb8d5d09aab9e500423263200933573801601a00e00c26aae7540044dd500089119191999ab9a3370ea00290021091100091999ab9a3370ea00490011190911180180218031aba135573ca00846666ae68cdc3a801a400042444004464c6401466ae7003003802001c0184d55cea80089baa0012323333573466e1d40052002200623333573466e1d40092000200623263200633573801001400800626aae74dd5000a4c244004244002921035054310012333333357480024a00c4a00c4a00c46a00e6eb400894018008480044488c0080049400848488c00800c4488004448c8c00400488cc00cc0080080041	2197
5	129	\\x30c51387c9fcff0f644c880bb50768987ff0ef21134c4f7dafb8f16d	timelock	{"type": "sig", "keyHash": "10ad0e83c4ea427162f7c64dfe2e412f84819b0a2a34094565b11aad"}	\N	\N
6	131	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	timelock	{"type": "sig", "keyHash": "5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967"}	\N	\N
7	149	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}]}	\N	\N
8	157	\\x4976d2d8dbb10f2d0ca68aa650492564319e61cf687f2ac04f1fbc44	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "5f21f211fe62aa097d05468ccfc6006142df513a16771e3bd7331783"}, {"type": "sig", "keyHash": "c00c7c8a2f4fb4cc74a1d07cf973697f87f90a5f055482bc5761cdbb"}]}	\N	\N
9	166	\\x60917f8bacdcfda9ed240eed5f4aa5a69afd9ac62f674c0a3a528a4f	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "184617cae316d1c27062569ad924bad99359997aafc84e73d83d815b"}, {"type": "sig", "keyHash": "34b7882ec76e408e1d12707ff06a4be108be5bed49a7d7ab647176a4"}, {"type": "sig", "keyHash": "4932568555eea584807dfa4c531bea4945aa670b86a2b72d080f4dbf"}]}	\N	\N
10	193	\\x74678902a9e5c08298c0740cc9239bc8d836bae431bbc4e310e5316f	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "549cffa4bc798683c70d064aab0a80834fe7c869c8bb243fd36817a4"}, {"type": "sig", "keyHash": "9ab757a5acaddceafa79d4bad34a0296446a2d751a12197308978ae2"}, {"type": "sig", "keyHash": "836114bac618d49ec3dccca47f7b7b8a67c13d74f2aa275bce1d0b1b"}]}	\N	\N
\.


--
-- Data for Name: slot_leader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slot_leader (id, hash, pool_hash_id, description) FROM stdin;
1	\\x579f363d5055d14b1831197eb17e09681c90714998de5c1672fc40de	\N	Genesis slot leader
2	\\x5368656c6c65792047656e6573697320536c6f744c65616465722048	\N	Shelley Genesis slot leader
14	\\x7debbb717e5a3a1fde6089eec6f4ae8810dd642aeccf249c89baf543	4	Pool-7debbb717e5a3a1f
11	\\xcf5a14bd1e7148b65dbe1d7195421010fd607f6cb4f10d8b3bf622a3	9	Pool-cf5a14bd1e7148b6
18	\\xc66cea9a75934694cca07dc9216180d4e7063365af27c1d67df28e14	8	Pool-c66cea9a75934694
4	\\xf2e2f054b20b4cacaa5ed0c2b6b82278aa258f84a058d66b9e7167e6	11	Pool-f2e2f054b20b4cac
35	\\x715b98fb98b35b09398c9e2ad90166138de233c0e4ae4615fd233188	3	Pool-715b98fb98b35b09
21	\\x388256ea6d8404e402d5e9f3d3f0507bdb734fdf405e6ea5ddc34a73	1	Pool-388256ea6d8404e4
12	\\xb7275c0659a4aafb36a75d8aa14e0acd403235233e7c45a6ba480e23	6	Pool-b7275c0659a4aafb
10	\\xc2708cc2e1ce7942205847bcce85719c48bbb8acbc46d44c16ba554f	7	Pool-c2708cc2e1ce7942
3	\\x8d836d482503cad3c449cca6f7041637f8533a69260b42801bf58e17	5	Pool-8d836d482503cad3
13	\\x5148025323825b67898f81f3da8d69d75b0c6bfca7218128036c0855	2	Pool-5148025323825b67
37	\\xd5bb7beb32da145c62236d739c6ef381b74d4adc2b4ffeff9dd83ad8	10	Pool-d5bb7beb32da145c
\.


--
-- Data for Name: stake_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_address (id, hash_raw, view, script_hash) FROM stdin;
1	\\xe0766c841ccb9c54b42fe722f3ac6be6c64918208c3e51b7bb11fdb646	stake_test1upmxepqueww9fdp0uu308trtumryjxpq3sl9rdamz87mv3sppe2ve	\N
2	\\xe0109b3008a5dcdd65c84b6c8faeb9e963b5904ed4d2936b2e84d659aa	stake_test1uqgfkvqg5hwd6ewgfdkglt4ea93mtyzw6nffx6ewsnt9n2sdvqv9u	\N
3	\\xe0896a2fd343a80c575f34fc3674b3160a2c7e1a88dbfb86ad1d86cefe	stake_test1uzyk5t7ngw5qc46lxn7rva9nzc9zcls63rdlhp4drkrvalspaz8a0	\N
4	\\xe00352bd8e2a01199b4c968fc7e4feaeccacd768a4f5cbfca86429c846	stake_test1uqp490vw9gq3nx6vj68u0e874mx2e4mg5n6uhl9gvs5us3srkp2cu	\N
5	\\xe038d2e4d8cd2f18282d14fd64e18a1aa4909d7fa1122f3a294232b1f1	stake_test1uqud9exce5h3s2pdzn7kfcv2r2jfp8tl5yfz7w3fggetrug4dekp7	\N
6	\\xe0d0ceb70a8b3c7f25c3731e2c865dec34f09b455585b8c8f54a65534b	stake_test1urgvadc23v787fwrwv0zepjaas60px692kzm3j84ffj4xjcdk9nfh	\N
7	\\xe09f99e2f6e41be9e5c0bf6b224217d2f4476a9af6b8ef8dd92916a513	stake_test1uz0enchkusd7newqha4jyssh6t6yw65676uwlrwe9yt22yc8qenen	\N
8	\\xe046546c70203d63291d7fa74b34d5bc6c8ccd0fdb22621e088e4899a5	stake_test1upr9gmrsyq7kx2ga07n5kdx4h3kgeng0mv3xy8sg3eyfnfgvn6s86	\N
9	\\xe0a7cd643e0424e158ccfd427209b033c0bf7bd35825d0727c06ed1a10	stake_test1uznu6ep7qsjwzkxvl4p8yzdsx0qt777ntqjaqunuqmk35yq5pzrny	\N
10	\\xe0db010e422bba33e687d458d1b11345701f22ac0fcb9c661ca337d51d	stake_test1urdszrjz9war8e5863vdrvgng4cp7g4vpl9ecesu5vma28g0jdz9l	\N
11	\\xe0776cf597e0393a761194a1611efc0481904ab6cc12bc3b444c2eddad	stake_test1upmkeavhuqun5as3jjskz8huqjqeqj4kesftcw6yfshdmtge0xd2f	\N
12	\\xe0b586d58b1f75e25cb224ee41b155df4833fd57e96297b28d5e1d42da	stake_test1uz6cd4vtra67yh9jynhyrv24mayr8l2ha93f0v5dtcw59ksu5tnft	\N
13	\\xe07cf4b76729085bd46f93e6d0bec92db85172c8dba17944ab392abfb0	stake_test1up70fdm89yy9h4r0j0ndp0kf9ku9zukgmwshj39t8y4tlvqqs3vj7	\N
14	\\xe014e4af6cd351342d83af29a9a67459dff030c1b25be822baf3508818	stake_test1uq2wftmv6dgngtvr4u56nfn5t80lqvxpkfd7sg467dggsxq7n6y23	\N
15	\\xe0d5d4cbda09bc8245bb0ea886f8cab99ddfe76e141446a3c401420016	stake_test1ur2afj76px7gy3dmp65gd7x2hxwalemwzs2ydg7yq9pqq9sw8eqqa	\N
16	\\xe0ccb96b400fe3fc42225a72623f666b9ea3fc003bc36f3a9bff9c59e7	stake_test1urxtj66qpl3lcs3ztfexy0mxdw028lqq80pk7w5ml7w9nec20gpg8	\N
17	\\xe0cb0d82296e205b45307aeffe77f74994be7b753e3f32ab0c71ec4c5e	stake_test1ur9smq3fdcs9k3fs0thlualhfx2tu7m48cln92cvw8kychsfgetcr	\N
18	\\xe0b953af738018466f83be0b099623d88a986c1b443a27ce6f83fcbca2	stake_test1uzu48tmnsqvyvmurhc9sn93rmz9fsmqmgsaz0nn0s07tegs0qvdvd	\N
19	\\xe0798987947674ddbc108ae0ada89531f2d26359bb3c4b29ad7dfe8119	stake_test1upucnpu5we6dm0qs3ts2m2y4x8edyc6ehv7yk2dd0hlgzxgcz6k52	\N
20	\\xe083c6901d641989b43a5401351f6a9f135a4c9bdd14cd0a27982bf107	stake_test1uzpudyqavsvcndp62sqn28m2nuf45nymm52v6z38nq4lzpcvy0gqy	\N
21	\\xe05df843ebac7996d7ab2f3ad88b488e00207468cbd84db11dfd3eb7cd	stake_test1upwlsslt43ued4at9uad3z6g3cqzqarge0vymvgal5lt0ng9rp8m6	\N
22	\\xe0c1ad3d781c275691102bbb2f2adcb336b81d46e138b729e0099fbbda	stake_test1urq660tcrsn4dygs9waj72kukvmts82xuyutw20qpx0mhksj9p50t	\N
23	\\xe0e78a14b42f6af255187fb92bc0f1c055e783721141b19fea42517a56	stake_test1urnc59959a40y4gc07ujhs83cp270qmjz9qmr8l2gfgh54sejsl64	\N
24	\\xe086157f3ce99153a6f6abdfdc7f8a6fa3e541056a6154ce788341893d	stake_test1uzrp2leuaxg48fhk400aclu2d7372sg9dfs4fnncsdqcj0gevt8f2	\N
25	\\xe00d75a8d4c6b862bf8292cea4d8d6fb09e112461221086a9a4edac970	stake_test1uqxht2x5c6ux90uzjt82fkxklvy7zyjxzgsss656fmdvjuqxzupe0	\N
26	\\xe069b9b8e82fc2dc13a14f3c3ca719a785cd48d8fb96773e02e432b3ef	stake_test1up5mnw8g9lpdcyapfu7refce57zu6jxclwt8w0szuset8mcrla73t	\N
27	\\xe0643fc1e5d2236abe3b92ba58454d96ade407be5bf3aebafb246ec21e	stake_test1upjrls096g3k403mj2a9s32dj6k7gpa7t0e6awhmy3hvy8st8apu2	\N
28	\\xe0114e98b89e0aef00f8389d9ff6d69f6843e68a68fe80e752129f70cb	stake_test1uqg5ax9cnc9w7q8c8zwelakkna5y8e52drlgpe6jz20hpjcgh5qwv	\N
29	\\xe016d2ba3b22c56b30ffa753b4ec09c28a73f3bce850099d16489bf6c6	stake_test1uqtd9w3mytzkkv8l5afmfmqfc2988uauapgqn8gkfzdld3s7jh2wd	\N
30	\\xe0cf7a160dd1df265da174c6c1c4249ecb7389fceca2f3062665e1b46f	stake_test1ur8h59sd680jvhdpwnrvr3pynm9h8z0uaj30xp3xvhsmgmc6myhrf	\N
31	\\xe03a14dd891eaa4b002faaf596ee99109be39b165aa9c3830db6d86afe	stake_test1uqapfhvfr64ykqp04t6edm5ezzd78xckt25u8qcdkmvx4lsp6ujqj	\N
32	\\xe0311ac6725e0dd5bee9ebe80af71a2297bc481db07dd94a3c02055d20	stake_test1uqc343njtcxat0hfa05q4ac6y2tmcjqakp7ajj3uqgz46gqv906x4	\N
33	\\xe01a874c371ea61391b6c48bb29f1f29d573b46de87805b17606eeb7c0	stake_test1uqdgwnphr6np8ydkcj9m98cl982h8drdapuqtvtkqmht0sqzrpcxw	\N
34	\\xe0a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	\N
35	\\xe0f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	stake_test1urc4mvzl2cp4gedl3yq2px7659krmzuzgnl2dpjjgsydmqqxgamj7	\N
36	\\xe01bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	stake_test1uqdlrcfc7tuta27fv0y5es5wark5kst5gcql9md02zepalg9yxxuz	\N
37	\\xe0e0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	\N
38	\\xe09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j	\N
39	\\xe07d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	stake_test1up73dx2qeg7gv59739gpmycmxzffyqk3ha2ctmh9ghdgneqmy000q	\N
40	\\xe0061b7c81f80fb14e36694edbc42885f6cef274ce1a2d5208d579d8cf	stake_test1uqrpklyplq8mzn3kd98dh3pgshmvaun5ecdz65sg64ua3nc2sxa43	\N
41	\\xf060917f8bacdcfda9ed240eed5f4aa5a69afd9ac62f674c0a3a528a4f	stake_test17psfzlut4nw0m20dys8w6h625knf4lv6cchkwnq28ffg5ncvkaqtf	\\x60917f8bacdcfda9ed240eed5f4aa5a69afd9ac62f674c0a3a528a4f
42	\\xe072263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	stake_test1upezv0agh8cq09rt33ardnh8pdstd3lwpa5s64g2pne0uqgcygw6k	\N
43	\\xe08de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	stake_test1uzx79ge8d7gkx27vu3k9xgj9zlra0fvat5d5lxcnzm9n7hc8yk6td	\N
44	\\xe04f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	stake_test1up85ec98csnkgus5dw3x8u25mlkgu8m63hvw650ukldv04q6rf54k	\N
45	\\xe00ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	stake_test1uq8lxxfr92332xgqp66eenhpw7z04q09czgjf6uvnku20fq023mfy	\N
46	\\xe0ce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	stake_test1ur89gkdpkj42jwy3smuznfxcjdas0jz64xtckt9s8kz8h3gj4h8zv	\N
47	\\xf074678902a9e5c08298c0740cc9239bc8d836bae431bbc4e310e5316f	stake_test17p6x0zgz48jupq5ccp6qejfrn0ydsd46uscmh38rzrjnzmcejna8f	\\x74678902a9e5c08298c0740cc9239bc8d836bae431bbc4e310e5316f
48	\\xe0f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	stake_test1urcqjef42euycw37mup524mf4j5wqlwylwwm9wzjp4v42ksjgsgcy	\N
\.


--
-- Data for Name: stake_deregistration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_deregistration (id, addr_id, cert_index, epoch_no, tx_id, redeemer_id) FROM stdin;
1	35	0	3	171	\N
2	35	0	3	173	\N
3	35	0	3	175	\N
4	35	0	3	178	\N
5	35	0	3	181	\N
6	35	0	3	185	\N
8	47	0	3	195	\N
9	35	0	3	197	\N
\.


--
-- Data for Name: stake_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_registration (id, addr_id, cert_index, epoch_no, tx_id, deposit) FROM stdin;
1	4	0	0	34	\N
2	2	2	0	34	\N
3	5	4	0	34	\N
4	8	6	0	34	\N
5	1	8	0	34	\N
6	11	10	0	34	\N
7	3	12	0	34	\N
8	7	14	0	34	\N
9	9	16	0	34	\N
10	6	18	0	34	\N
11	10	20	0	34	\N
12	23	0	0	46	2000000
13	24	0	0	47	2000000
14	25	0	0	48	2000000
15	26	0	0	49	2000000
16	27	0	0	50	2000000
17	28	0	0	51	2000000
18	29	0	0	52	2000000
19	30	0	0	53	2000000
20	31	0	0	54	2000000
21	32	0	0	55	2000000
22	33	0	0	56	2000000
23	17	0	0	68	2000000
24	19	0	0	69	2000000
25	16	0	0	70	2000000
26	14	0	0	71	2000000
27	15	0	0	72	2000000
28	21	0	0	73	2000000
29	12	0	0	74	2000000
30	13	0	0	75	2000000
31	18	0	0	76	2000000
32	20	0	0	77	2000000
33	22	0	0	78	2000000
34	35	0	3	170	2000000
35	35	0	3	172	2000000
36	35	0	3	174	2000000
37	35	0	3	177	2000000
38	35	0	3	179	2000000
39	35	0	3	182	2000000
40	42	0	3	189	2000000
41	43	2	3	189	2000000
42	44	4	3	189	2000000
43	45	6	3	189	2000000
44	46	8	3	189	2000000
45	47	0	3	193	2000000
46	35	0	3	196	2000000
47	35	0	3	198	2000000
48	48	0	7	300	2000000
49	37	0	11	403	2000000
50	34	0	11	407	2000000
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
1	3	35	10000000
\.


--
-- Data for Name: tx; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx (id, hash, block_id, block_index, out_sum, fee, deposit, size, invalid_before, invalid_hereafter, valid_contract, script_size, treasury_donation) FROM stdin;
1	\\xaed1bc99ed464f8bfe7ffc97201f72284c0bcfdd8c167008c5f29a2ccbb75512	1	0	910909092	0	0	0	\N	\N	t	0	0
2	\\x844096768121fbac645ec4a404218142c6c94737a991fd05f1944d589f9994c1	1	0	910909092	0	0	0	\N	\N	t	0	0
3	\\x64d9cac84084f7e0303240e8b8ab9f7c72603088939ebe0d8dcd068bebd853a7	1	0	910909092	0	0	0	\N	\N	t	0	0
4	\\x8702bf1ffadb2cd62e2eec3aba6320ce31f14c65961fd92dfc763efbbdba1505	1	0	910909092	0	0	0	\N	\N	t	0	0
5	\\x09a31bc9335cf16a1459e4ee26572429d8526d0a40c0010421af0f634fbb374d	1	0	910909092	0	0	0	\N	\N	t	0	0
6	\\x82bf1900cbc1ff16f68a2394cf41974efbf258efc2c7ed46abc5f6adb6498adb	1	0	910909092	0	0	0	\N	\N	t	0	0
7	\\x079a8b9243e7bbf930fd784e16f40fd83803c24ad443b9ac2ff703292b0039ce	1	0	910909092	0	0	0	\N	\N	t	0	0
8	\\x3df66b4dc2a4d6438b30aa641d558a3d9c580fc2aed49fbc979bb79727fb25c3	1	0	910909092	0	0	0	\N	\N	t	0	0
9	\\xb077313b8c90bb737ff02c2269eef91d350d59c4aeaa637aa367288dfec07cad	1	0	910909092	0	0	0	\N	\N	t	0	0
10	\\xb89d5751ee8bac6080f0083376b617081c53ea83e3c988e93bbfd72b3e25e13c	1	0	910909092	0	0	0	\N	\N	t	0	0
11	\\x2e3c0a9dfe9a80f2a024de583fdf88f9fe302c59a7a92b01291dd822f6a13112	1	0	910909092	0	0	0	\N	\N	t	0	0
12	\\x06ba57195663516ebf407d5246fd3a2fef9702baaa13ffccfd3d41bb58b4a588	2	0	3681818181818181	0	0	0	\N	\N	t	0	0
13	\\x0bfc5d2c46e33ba151cb64a0f332b90f50c3fe8b41f0a26195173718d29a5483	2	0	7772727272727272	0	0	0	\N	\N	t	0	0
14	\\x1e08afe5ee02029612603456794bcb1bd05caf892956451d0d24dbbdc10e4e84	2	0	7772727272727272	0	0	0	\N	\N	t	0	0
15	\\x1ff20dfa47749f6afa372f63348c3e6da7790e7a5eef14400a4fcae9f2af3b04	2	0	7772727272727272	0	0	0	\N	\N	t	0	0
16	\\x253f6f800e365cfad44ea06095741543a58178540e3fb79ca39660ddb70d7cb8	2	0	7772727272727272	0	0	0	\N	\N	t	0	0
17	\\x43a543d3065b73b47f001dfbc21c5f5197a64c83cad40b7e6e4d66a719d5da07	2	0	3681818181818181	0	0	0	\N	\N	t	0	0
18	\\x4aa38eca4d930f0caf933582babeba1db1761084887ee07f24955be8d6b08c82	2	0	3681818181818181	0	0	0	\N	\N	t	0	0
19	\\x4acbb810ef73df03f117684de5c4296a65453ab291c8db031ac9c2dc78e67ef4	2	0	7772727272727280	0	0	0	\N	\N	t	0	0
20	\\x4e74d74d43f318bffe981915631cb2d3ea571197fd1f71c407972be76fdc5111	2	0	3681818181818181	0	0	0	\N	\N	t	0	0
21	\\x4eb0d13bc1d6b5e25cae518beff84b17d2a135639cb9d0df6b5b704476877e0e	2	0	3681818181818181	0	0	0	\N	\N	t	0	0
22	\\x5718b7c7c158d8039849c22797e49d3334b453f56c8ce9970bcc548237eb9e0f	2	0	3681818181818181	0	0	0	\N	\N	t	0	0
23	\\x73c73c3e37a7bf83aa196e7b7455dca04627288032a1dd7560973a5b4f6ee7e5	2	0	7772727272727272	0	0	0	\N	\N	t	0	0
24	\\x7ab1508afeff2ad7b8cfe688652f1629c454701527d63e894a93f0d0423211cc	2	0	7772727272727272	0	0	0	\N	\N	t	0	0
25	\\x87ac1f80d844fad10fc4a27c253ce5656315330f892993972f2e3914ab772795	2	0	3681818181818181	0	0	0	\N	\N	t	0	0
26	\\xa657df309acfc3ef23dd3413812f014ed4858fd933cb333fa0e69d9630f467a4	2	0	7772727272727272	0	0	0	\N	\N	t	0	0
27	\\xada8ed20a35b2339e1820d72ae8b57bef6959dd9693da0c91eeee7b0690c8934	2	0	3681818181818190	0	0	0	\N	\N	t	0	0
28	\\xae4871c9ee6b1287e59c653a64e5c4b2ae0453b74d8430f6437be744b58b298a	2	0	7772727272727272	0	0	0	\N	\N	t	0	0
29	\\xb1a857ba435c4fc4993fead13e82b6f30becd91597588658ddcdacc57009e492	2	0	3681818181818181	0	0	0	\N	\N	t	0	0
30	\\xd6c44c5ca95bbb2a9a214e086d0363df7f2044782b8bf81c37437a14457870e7	2	0	3681818181818181	0	0	0	\N	\N	t	0	0
31	\\xe65181109f007786063f702b0509bd8f8b26dea21b84936d85784550ff888372	2	0	7772727272727272	0	0	0	\N	\N	t	0	0
32	\\xf4aa256a66f6f1dce595f4e8be62abeb030062e09f35bfef820262b3515952db	2	0	3681818181818181	0	0	0	\N	\N	t	0	0
33	\\xfa0bf06f5c1afdbb244f693122e042e23851959ed7f296051f6a02a1a3bf8053	2	0	7772727272727272	0	0	0	\N	\N	t	0	0
34	\\x5368656c6c65792047656e65736973205374616b696e67205478204861736820	2	0	0	0	0	0	\N	\N	t	0	0
35	\\x2153064a5577fc44a89b587d4f5bcd77cd762a5ec451fcf5d512122db62952e7	4	0	3681818181646520	171661	0	269	\N	\N	t	0	0
36	\\xc2152cc1373666981da87b4160135e61c7d730a1d4c83a43e6d7d0e064c2ca55	4	1	3681818181646520	171661	0	269	\N	\N	t	0	0
37	\\x55bbdc63a5cbf7f4a717c99794c1e2e61cd20086146a5bfa1ebade988abc7d76	4	2	3681818181646520	171661	0	269	\N	\N	t	0	0
38	\\xc105ee55e865ae7019ac2579c8306f336301cf4f4bc3890b61bc90fef55a6342	4	3	3681818181646520	171661	0	269	\N	\N	t	0	0
39	\\x7a3ae7c5f8b73bff6c5cfa80b6f939d424ac1bacc599bcea407d3116d96fe8f8	4	4	3681818181646529	171661	0	269	\N	\N	t	0	0
40	\\xd6b5a147d5819434ab74909d653e58b202bf37db3afc59f8dba36b4c2dbca605	4	5	3681818181646520	171661	0	269	\N	\N	t	0	0
41	\\x64f460ee1ee977977cc1ff15af5c1427a67490c917e4b91595574bf2616ad797	4	6	3681818181646520	171661	0	269	\N	\N	t	0	0
42	\\x6a2c4b2b4b42e03930260f30709f65215ed6425e0ee2699421fa9b08e26d7a0e	4	7	3681818181646520	171661	0	269	\N	\N	t	0	0
43	\\xfee17699cbab805ff8a3eb9493c9523ce77d4d1a0306037f98a4f8e5e676a6f0	4	8	3681818181646520	171661	0	269	\N	\N	t	0	0
44	\\xa2e9cd3effaad0c823d3001c40eb07496253a632aab104b1ea2f3d95634aef4e	4	9	3681818181646520	171661	0	269	\N	\N	t	0	0
45	\\xc801135bd3b6b49fdb1615ba6285e735900fd24679950a2413bd2361cae6e5aa	4	10	3681818181646520	171661	0	269	\N	\N	t	0	0
46	\\x84c9b83d9d00239328d5962b85791c198bb4f0a05f54faa86bd54e74f42daebd	11	0	499997819319	180681	2000000	373	\N	\N	t	0	0
47	\\x7e96acff02b3505327379f6ab90c9813b4e9e1d48ae45f6a7520e7f01ac2af12	11	1	499997819319	180681	2000000	373	\N	\N	t	0	0
48	\\x2055ffc718acd4a7fd12ddcdb52fc05f3376295b14df13b64c93dbf5c45d48dd	11	2	499997819319	180681	2000000	373	\N	\N	t	0	0
49	\\x4082c58ad483570df1c40c2e15a90263b690d5fd5f4afd482efad1b581042791	11	3	499997819319	180681	2000000	373	\N	\N	t	0	0
50	\\xe085869265ecd240c105785ecfedecc819e782a55d94d8eca19360e5cd1a8e2d	11	4	499997819319	180681	2000000	373	\N	\N	t	0	0
51	\\xaa0fd762134aa389c5dd1471c2cbc71d831d667b0b2936b1ab6b8741cbc04b2b	11	5	499997819319	180681	2000000	373	\N	\N	t	0	0
52	\\x2b476d6aca2e5f18a4a0a2404875313d6483d643c89fd9ea9563067edb7c0e4d	11	6	499997819319	180681	2000000	373	\N	\N	t	0	0
53	\\xf7bcabf0c8037cc1d859d46ebd75a4a98360bb2848511e833c7eb0a2ca11e684	11	7	499997819319	180681	2000000	373	\N	\N	t	0	0
54	\\xa80bd04aabe239840e4c3d86b24ac794c257482cb05c408ff65e59a03afa3897	11	8	499997819319	180681	2000000	373	\N	\N	t	0	0
55	\\x998b4d3bcd8f9b62d8d4ea3a8eeb2096d451810587c5139cd5567c8fe71930fa	11	9	499997819319	180681	2000000	373	\N	\N	t	0	0
56	\\xc5492617de67d8922fbb629782b068e1d7b4831345d9f56341fa0fedee62382f	11	10	499997819319	180681	2000000	373	\N	\N	t	0	0
57	\\x1a271cc14634583aa5ec1302cf0f956e0d9bbde755068de5e19502974eeb653f	19	0	3681318181475035	171485	0	265	\N	\N	t	0	0
58	\\xde4a82a80b13ca1947d031af448cbbfb8893436d7cf8b9f0b2bd39848f0800b0	19	1	3681318181475035	171485	0	265	\N	\N	t	0	0
59	\\x75a3fea58d75a445f35531a00ac81fcd7dfcd0db8b8c756b3c6cce872a2b9ae7	19	2	3681318181475035	171485	0	265	\N	\N	t	0	0
60	\\xc28cca06eb8499d04a264604a9693974a57539c0b1f8fa1ac6f790f4baf36471	19	3	3681318181475044	171485	0	265	\N	\N	t	0	0
61	\\xf2250ac7d3fe049aa3e8a394d117848d015aced691bd440faf6e9c16921eeee9	19	4	3681318181475035	171485	0	265	\N	\N	t	0	0
62	\\x8a41ab5c3942a673a2bc6290e705034bac768385ae999684414beffff8de895c	19	5	3681318181475035	171485	0	265	\N	\N	t	0	0
63	\\x84d046b01c4fdede7e6542633ef282ac791413e6e1539ab2f71ee6bea868ee1b	19	6	3681318181475035	171485	0	265	\N	\N	t	0	0
64	\\x0fa35e940115b14eec323960c5c2a1b1e365dcf139e3e462cafa1ff46e96560c	19	7	3681318181475035	171485	0	265	\N	\N	t	0	0
65	\\xaa467fb1e1041cb7337ad833f88b995c4f5536fe772f194dbaec6363fd7fdf86	19	8	3681318181475035	171485	0	265	\N	\N	t	0	0
66	\\xa97b7db2864b04ebc92429a5d431fb40094ad3b954f3715e5bbfae42a6846d56	19	9	3681318181475035	171485	0	265	\N	\N	t	0	0
67	\\xfcd8e7fbcce5a1b9fbb1dbc60c166e0d459382872ed7174e0dc3a41279b68f86	19	10	3681318181475035	171485	0	265	\N	\N	t	0	0
68	\\x2d69d1c48f5bf8fdb2113232ba44f008e027a5a9c5122f5d4fa9c4296e05da22	20	0	3681317579304210	170825	2000000	351	\N	5000000	t	0	0
69	\\x29ffd443dffd5ee56b995716d04024557bd73e835bdb26fdfd12a8ea8ae67295	20	1	3681317679304219	170825	2000000	351	\N	5000000	t	0	0
70	\\xa87b29f46530e8ca0c8657fa6efe1f63d01145de88887b96a5e4f01868cc9c7f	20	2	3681317679304210	170825	2000000	351	\N	5000000	t	0	0
71	\\x9c581b9951ed8f9b7ae5974253a0b7e3b099d7c87ed1c0baa791de030572ba9c	20	3	3681317879304210	170825	2000000	351	\N	5000000	t	0	0
72	\\x178409f7cba9772fa0e5f7bb1f43b5f42512d22d41e629e94c80e1432cfe3a6e	20	4	3681317979304210	170825	2000000	351	\N	5000000	t	0	0
73	\\xcd09ce0bbb290c4a992624605b2e5ee512dc0bb6e5acdffd9869db0d9bf090a5	20	5	3681317879304210	170825	2000000	351	\N	5000000	t	0	0
74	\\x80c4e5112c896736c0d7cf59b18073bf6c69ce94ba904a4c232f1d91a0696194	20	6	3681317679304210	170825	2000000	351	\N	5000000	t	0	0
75	\\x8fae5821caae65127f6050c2b6a325fa2e79b4cf20a656d9106f670cddb1b361	20	7	3681317679304210	170825	2000000	351	\N	5000000	t	0	0
76	\\xba3ee95d869676e6514dc077347b8aac43eafa3141c2b1e48716dd4854e2f2a3	20	8	3681317679304210	170825	2000000	351	\N	5000000	t	0	0
77	\\x1ccfbd4677113dda38cb5947aa98b896e6628107374c89c42908d72ad4817332	20	9	3681317679304210	170825	2000000	351	\N	5000000	t	0	0
78	\\x1139f9630d21c8540a8d855136e083ce6511a135f44a8acec12b83b58f964dda	20	10	3681317679304210	170825	2000000	351	\N	5000000	t	0	0
79	\\x540c8cbd10cabb41a89a731da4801cbe5a0fdda8ab8d7771658171b27268c371	22	0	3681317679132285	171925	0	376	\N	5000000	t	0	0
80	\\x10559f165c7ccb9a1fe2d670a004b0e0232dd6bf9410d9e647a9c334059d503b	22	1	3681317679132285	171925	0	376	\N	5000000	t	0	0
81	\\x4bb73ec23afc89b568ded490595ec5648e3430ca7816b32313841e719cdd0d3b	22	2	3681317679132285	171925	0	376	\N	5000000	t	0	0
82	\\x44b6492a7f52ce6975ac5eb3b067015b5a36553980f4bedfa7f7584da6c6d186	22	3	3681317979132285	171925	0	376	\N	5000000	t	0	0
83	\\x371d69ee2f001c9a7e28482c5b73e99fcf66b0eb32178f0ebf3ec7ca92b11a34	22	4	3681317579132285	171925	0	376	\N	5000000	t	0	0
84	\\x0e6ca6557b9723988ffe113776512ebdfa8fe6d8cf08e2def364e4c378c6847a	22	5	3681317879132285	171925	0	376	\N	5000000	t	0	0
85	\\x99ea4feb76e73a1131e861eac38016e603e2391948e6caa4738be74df5440a7a	22	6	3681317679132294	171925	0	376	\N	5000000	t	0	0
86	\\x5c691b73d75ef8bee708d6e6b97bba7d3b2a313850bbd72fc783e853e7a9ba94	22	7	3681317679132285	171925	0	376	\N	5000000	t	0	0
87	\\x6df57f0402fb82101f5c8445ac4695728081f4e35ecc7a6dfdb87a36d602feef	22	8	3681317879132285	171925	0	376	\N	5000000	t	0	0
88	\\x1604497c614d2949c0715bcff67db867819f79832757ca912a2c4633d4f79244	22	9	3681317679132285	171925	0	376	\N	5000000	t	0	0
89	\\xa0e04c483e5230fdf4123a9a0b12596ea1d81faaed9a005401ab427365f72178	22	10	3681317679132285	171925	0	376	\N	5000000	t	0	0
90	\\xf30363ca021196da41c50debd50f3ddec59e28c6f16465728efb6fabad24fca9	23	0	499997646162	173157	0	404	\N	5000000	t	0	0
91	\\x5b2fccb26e23e959eed4dfb01b47a242da6c0fdf8046d5f069750869d37d7245	23	1	499997646162	173157	0	404	\N	5000000	t	0	0
92	\\x0b92ac4d9efd373b319ef037286668d920251f648968d433f0b99173c8a1af70	23	2	499997646162	173157	0	404	\N	5000000	t	0	0
93	\\x06b9a58ce1787de65458c99be55a22c5839c4ab8251450a88b479bdf90a56430	23	3	499997646162	173157	0	404	\N	5000000	t	0	0
94	\\xdccc354a7e9fe965716062cbab38600e15cc8e189e9a9c40b7a52fc31d6f402e	23	4	499997646162	173157	0	404	\N	5000000	t	0	0
95	\\x0d31a90897d97323dfe665e0b45cb4f73fc3553c9473c2399e41a376484ef0f4	23	5	499997646162	173157	0	404	\N	5000000	t	0	0
96	\\xceb5ff607481e1e60c64f4efc7895ec37d5fb45e8586a21a08c224f9adeb11f3	23	6	499997646162	173157	0	404	\N	5000000	t	0	0
97	\\x5d671ee38e27e619de6f89a5e51bde5548ba462bceb60808707f852c75eb01e2	23	7	499997646162	173157	0	404	\N	5000000	t	0	0
98	\\x35faad33777ed90c808284b8a51612ecacb3a7d51c54fc517637a33194b0b01c	23	8	499997646162	173157	0	404	\N	5000000	t	0	0
99	\\x9877f4b290b42984fa1ef63a91e4c48a0e07a058bfcf4e41b8c7eaf4e655be9c	23	9	499997646162	173157	0	404	\N	5000000	t	0	0
100	\\x3fe8f76d5fcf4267cd7e21d41012bbae2c20b08647ccf569e272dd2dffcb3b13	23	10	499997646162	173157	0	404	\N	5000000	t	0	0
101	\\x8e38e1b0577ef8b8301acc9cd873875673f697d8db70a43f3267dea9de9014e7	26	0	499997461565	184597	0	664	\N	500000	t	0	0
102	\\x3ef83f883762a36d30b7e0002a56530c083f1801b740a2f28a814a3f20ecf264	26	1	499997461609	184553	0	663	\N	500000	t	0	0
103	\\x4ec34199fd7ae084e54171a0bc4db61a5e5207d0cd56c7c74449c42e1b81b3b4	26	2	499997461609	184553	0	663	\N	500000	t	0	0
104	\\x5c7f1198016d1a0258ffbaee022759dae911a5bd94039fa1b6a12411e804497b	26	3	499997461609	184553	0	663	\N	500000	t	0	0
105	\\x1dd2cd59e387d38de6f66fdf25c2cb0033af487727029ff0e42303c32f3aa36e	26	4	499997461565	184597	0	664	\N	500000	t	0	0
106	\\xc9e32d9ceca4338e94941e4a0026c496da84b7c3dd7eb3a0bf7785700bbef5ec	26	5	499997461609	184553	0	663	\N	500000	t	0	0
107	\\xe01f5bfbca124da5b5589eef1657767b7c4be848e9267efd5e97c4f0ef6951a7	26	6	499997464381	181781	0	600	\N	500000	t	0	0
108	\\x4b5ef7a88e5170b9422e299c0b98bf1b13d7d5c0f26e2c87c5aa721e340a24b7	26	7	499997464381	181781	0	600	\N	500000	t	0	0
109	\\x67b9164b7357a820fb918a8f4acf9d7013a155702bcb5d365f8a8496d31c8916	26	8	499997461609	184553	0	663	\N	500000	t	0	0
110	\\x890e827a32db08031bb426efed2f1d3daa77e18e7842a4a5751f78fc01e491c3	26	9	499997464381	181781	0	600	\N	500000	t	0	0
111	\\xed7633e9cff0aae834be292bedd99052999ce0c62dc107970dbf6f812f611fe5	26	10	499997461609	184553	0	663	\N	500000	t	0	0
112	\\xcc930308f3f6b2b48065b2e1468d8ec60cc68bf0f7337bcb7ac9ec1c8f021cc6	27	0	499997288408	173157	0	404	\N	5000000	t	0	0
113	\\x547d2f8702e93cb43e6c8191afd78f6ff63fbc3c4b2a1f229fe3e01220e343d2	27	1	499997288408	173157	0	404	\N	5000000	t	0	0
114	\\x52c39c949bc38d08c87ea5dfda308691b9a6defaf2757cc0945574e80f1c8209	27	2	499997291224	173157	0	404	\N	5000000	t	0	0
115	\\x25e4b3fa1dcc2b0edbe191c4c128636bfb683e3d58e8436592ff11340727300e	27	3	499997291224	173157	0	404	\N	5000000	t	0	0
116	\\x368ba23779c883db9b7e84dbf8d3d1a5d926c61e10cf469e0651ec4373f3fb5f	28	0	3681317878957280	175005	0	446	\N	500000	t	0	0
117	\\x83590db518637ff2db157043a61691cbbc4eca825867ab62e8f4935b30c9d55c	28	1	3681317678957280	175005	0	446	\N	500000	t	0	0
118	\\xbbdd401edaebf282e058bdbd505c15fedb89ca0801607ace6110462ea1caec37	28	2	3681317678957280	175005	0	446	\N	500000	t	0	0
119	\\xbce3d15f087ed4aa55e68725e11243752a067baf699befcc3eea50d03152943b	28	3	3681317878957280	175005	0	446	\N	500000	t	0	0
120	\\x62d50aab5ac3c27c7a80f377c18d4646097c05458e28b936bba0fcec3e6a77fe	32	0	3681317578960536	171749	0	271	\N	\N	t	0	0
121	\\xc286000a5c29e38999691ee32ea77ea94d5f236f74ade67ae462497b9b8a8a70	35	0	99823938	176062	0	362	\N	\N	t	14	0
122	\\x9fe4acb302f56bff309eb572aa7da577ad26f00fc13c08a697ae410581098b6f	36	0	3681317478789843	170693	0	247	\N	\N	t	0	0
123	\\x433a32d5f27df49eb2560cd00f7b17347e5e1236fe8bbe261e9eb7fba246bf1e	39	0	3681317378614838	175005	0	345	\N	\N	t	0	0
124	\\x646303e49602ebacc167577c4028fdfeb6575708050781a26f7b310ca4fc3608	40	0	3681317278442429	172409	0	286	\N	\N	t	0	0
125	\\x84b6f89f3fd42ac7cdacbb3e1c2d95153ed220aa24561191032eb72378cd6f5e	41	0	3681317178271164	171265	0	260	\N	\N	t	0	0
126	\\x0ee4a24ddb513352869fb6111faef781fd70de8300924745b40e4527960331db	42	0	3681317078003671	267493	0	2447	\N	\N	t	0	0
127	\\xdfb7f591e1f2c6af6bd6bc6cc4745b6fcb07114e92e695da9698405306f6c33c	45	0	3681316977832934	170737	0	248	\N	\N	t	0	0
128	\\x506f76b6666b1975b4e61ea3b4311e667e717f490a192b76eebee949b4003632	48	0	3681316977500615	332319	0	2625	\N	\N	t	2197	0
129	\\x2cee18358b6f6e007b5040daf7594701362f6115fd64b38a53d3208eb2a59590	50	0	3681317678951692	180593	0	472	\N	\N	t	0	0
130	\\xdd9a589c58a18402655d995931f3a05a4c4ea9dfdd816350b88279e829ec3a69	51	0	3681317978948480	183805	0	545	\N	\N	t	0	0
131	\\xdae9e82c7441f8eaedef58807eb36d385b2d573ab6d10b78bdddad85d01dc3cb	52	0	4999999762911	237089	0	1756	\N	\N	t	0	0
132	\\x380b18de150e5a1d0700e23363c63f469722bca0ae3b5aa7328f03c98bc4c0d8	53	0	4999989573342	189569	0	676	\N	\N	t	0	0
133	\\xe35cceb1df2c1a3c612456abb399f4bec69b8eb6d0c7ff78d130f30bc3924dfd	101	0	4999979338497	234845	0	1700	\N	2461	t	0	0
134	\\x7aece95c2ecc112cde60f8dae21eb3399a37e3d070372f421509431441652549	105	0	4999969116368	222129	0	1411	\N	2495	t	0	0
135	\\x7e8e7d56c2a9cc6089bad380e0dc0cbe77d3ccb8935617d595d0685d61bf9e48	109	0	4999958893403	222965	0	1430	\N	2524	t	0	0
136	\\xf2a6684733538e5cd684c56b9500b8a9ad18225285599eba0e94b8f3a561d322	113	0	9807263	192737	0	743	\N	2570	t	0	0
137	\\x2346dc7a06a65bd92e0502c99b0e6a93eb7ea07ca103f8990cce0a4568f9f6b5	117	0	4999958525397	175269	0	447	\N	2595	t	0	0
138	\\x84b87f2939fd8657435ae9a8271a6847206f555f34b2e3a09f11ce4f96b59332	121	0	4999958349248	176149	0	467	\N	2631	t	0	0
139	\\x0d357b72b01080e982eab39bfabb2abd228caeab09dbb4945b6bffbe2b615551	125	0	4999938173187	176061	0	364	\N	2666	t	0	0
140	\\x311c85a6b23a0d1556927d846910f1af86a9006a1d3fe8afbdc5a0f5a4062660	129	0	19826843	173157	0	399	\N	2690	t	0	0
141	\\x8dafa6e5cd87c44205ce82bcd33cf8f3b2ef40ce106850f8939ce3413f8eaaaa	133	0	4999937980362	192825	0	745	\N	2737	t	0	0
142	\\x18ba2d4d8d6f967066f132c239ae4edd42668d98b2457c3303638fa2a8e693a8	137	0	4999927787537	192825	0	745	\N	2768	t	0	0
143	\\xd544e36ee1f1f430808ffaacb7da60a87da6d421394bdffc14181ea54bd58221	141	0	19825259	174741	0	334	\N	2793	t	0	0
144	\\x3cc976c0a805c65ed7c907a772b819419c8c54246516f35da6f3c5760061d532	145	0	4999917594712	192825	0	745	\N	2830	t	0	0
145	\\x318eea0e5a8a3677b732d1e2dcbdb6e4cf2dd7e7658bd5c93fe63d0771306116	149	0	9826843	173157	0	298	\N	2852	t	0	0
146	\\xd6d75bbdd9f55be80d22fa2de8998badd928db2517ff195a2f34bd478284e91e	153	0	19632610	192649	0	741	\N	2891	t	0	0
147	\\xa0143baa47f3adb35041cd0f0a8a16077976c11915ffae987d92a60b8e58456e	157	0	9824995	175005	0	340	\N	2919	t	0	0
148	\\x52fe8526c7189380ad24776c8b3feb8229bbaf49193cd5c89d0972e2aee803c2	161	0	9651838	173157	0	298	\N	2955	t	0	0
149	\\x7c5cc839e28bdd7c1fd6aa46a88aa3e8271e6ebc64cffaf49c7f99aa2efead82	166	0	19079039	205409	0	1132	\N	3007	t	0	0
150	\\x0867f0c2730b4714d549e709913aedb16d5785e09838adad2bfc08eb699952c7	170	0	4999917414471	180241	0	560	\N	3056	t	0	0
151	\\x6575e9246b354a1c45f9fdab472ea454e538b94d551eddfe7794870d257adfc0	174	0	4999907224946	189525	0	771	\N	3088	t	0	0
152	\\xfcbeb474de91c6dc9dd345ed74f74b9e7dbe803a6f19a0e514971200a025f065	178	0	18890966	188073	0	738	\N	3112	t	0	0
153	\\x9d0753f659dbb64f6508346a4b192a8755cc1a5a88eef1063d0e8c8d694aeacd	182	0	19638638	188205	0	741	\N	3176	t	0	0
154	\\xaa1e74f3ab8649a42c10e92248a14c81bd506b64da6bf79fd78f5274e58fc0dc	187	0	4999926682771	180813	0	573	\N	3235	t	0	0
155	\\xc316c7cb628ef171e1822421e23142192015f2e5af2201aed4b0c040748a8a75	192	0	4999935403572	170165	0	331	\N	3259	t	0	0
156	\\x760e58a14bc95e29f8d103f06421d189de81f50ea290a3b0fd5a6df42079a200	192	1	4999935233407	170165	0	331	\N	3259	t	0	0
157	\\x63d51f7d25666ecea2b13f85b1d58ca0e5d34c7213435fecedb52d8e2b6fa549	196	0	2999961160393	183849	0	642	\N	3291	t	0	0
158	\\xac0ae11f6360bea288f4420458f3aea0b7304f70fe17425b1d4ebf6e691b4ca5	200	0	2820947	179053	0	533	\N	3352	t	0	0
159	\\x5ee0cd904cf847e67dc6360a45add20bd6d8f5e98934848eb5afbce58f99ffed	204	0	1999976530971	179141	0	535	\N	3365	t	0	0
160	\\x4d26c7f8075b20773ded27b75de9aed28f08604647f299f78a89dbe417e047e6	208	0	2827019	172981	0	395	\N	3426	t	0	0
161	\\xb7bf402c6f4fc4218e96eea8213b9af6aa6de0d7453a3a85037798876ceaf63f	213	0	1999973014658	516313	0	8198	\N	3450	t	0	0
162	\\x13e91735fcbc1bed8a974d73e91f89818d356251bf3bc13a538ea1b0f5d44cf3	214	0	179474447	525553	0	8408	\N	3473	t	0	0
163	\\xa92ae0ddab750c501adb5b2835eb83b091a8be0da2a0115fdf57ac809a93814b	216	0	33234385347	168053	0	283	\N	3492	t	0	0
164	\\x330e70bc9626da74e79920a352d5fb1412f403ab625249a7e35f6a0bf28ed822	217	0	33234383103	170297	0	334	\N	3536	t	0	0
165	\\x79770df62d80547ab095c0f439b94ef63978dcab8983a557215174250d8f1bfa	220	0	33234384951	168449	0	292	\N	3568	t	0	0
166	\\xd82503cd18eb9407b50fa8f364cac69de9ca4a73d4027b31beb42eb084f2b0ab	221	0	9818439	181561	0	590	\N	3573	t	0	0
167	\\xb5267d4e2806e11f9baaa98d056f613d352517149b94c686e90325f31a0f0c8e	226	0	33234384951	168449	0	292	\N	3624	t	0	0
168	\\x6bf13d6bc9f7a1188585d65e375e117757906a5cc3542c895d7a2073d9033e4f	307	0	33234384687	168713	0	298	\N	4538	t	0	0
169	\\x34cee9e8986c2ebce8abafb7eaae2777868edc227c59f057317ced9cac4b7f09	309	0	499825523	174477	500000000	429	\N	4557	t	0	0
170	\\x6de5be64b8335832cecd4c1aff223c8f4cab6d353b4f161bf9a9a9605a527768	311	0	33232379847	173553	2000000	408	\N	4562	t	0	0
171	\\x57f818060102c3542f5937d1cbdad843226f17e9a4b58f8aed233ead2698ba1b	313	0	2999959988204	172189	-2000000	377	\N	4570	t	0	0
172	\\x246f9fce2f940defc1bd81068727fafcd017bdf18d0efbc7d2b4842f75d6a464	315	0	33232379759	173641	2000000	410	\N	4575	t	0	0
173	\\x0845fa9693188ac057cc2f672fabc28fb90f912e0dbfeb937a23b9d59efa0dec	317	0	4655006	172013	-2000000	373	\N	4586	t	0	0
174	\\xc32e78756438840c48581efca6e573fb32207585fa42b07d7c7f8d08cd063e55	319	0	33232378439	174961	2000000	440	\N	4603	t	0	0
175	\\x7afe60116915437b490a18fd3d2e7f2a524131f709dd1304c85015e606de5396	321	0	38956191825	172233	-2000000	378	\N	4627	t	0	0
176	\\xb669a3554c120abd3348a2780b21f2376ab4de75519807e3ca3f36090e692471	323	0	19828163	171837	0	369	\N	4651	t	0	0
177	\\xe61aeed9627cb43308705ea7197d10cfa0aebd6079150d5ec624524fc1b62e15	325	0	33232381167	172233	2000000	378	\N	4665	t	0	0
178	\\xdc5bb774e1a3972a15d62073d91e59c7127578d00ee24b48f2f3ef4d193a96f9	327	0	33236381167	172233	-2000000	378	\N	4698	t	0	0
179	\\x8f3622b00b9beee729ef39410b53d66d2aab286333782019300e9cd7cd6fcafa	329	0	33232381167	172233	2000000	378	\N	4715	t	0	0
180	\\x4a283bae3ad3177077e6e4706d6af9f96837254db4a41fdebc064bb8a6657b6e	331	0	33234379979	173421	0	405	\N	4728	t	0	0
181	\\xca82827430a8a17d443d2c706a83bd86a513d5156d75b2430bcfe06b8f6e272d	333	0	33236381167	172233	-2000000	378	\N	4757	t	0	0
182	\\x6f5ebc505f4203098e38396efcc38f034a0e95fc6104874bcb675d407cc1050d	335	0	33232381167	172233	2000000	378	\N	4786	t	0	0
183	\\x5311c96c9ff1c4275041fae332c351e47259f80d14ac3539e0bea8d9ade9ae61	337	0	33234378659	174741	0	435	\N	4797	t	0	0
184	\\x6d9856210597afe4b8267df90f3a3d5f5085a260f12337cf4dd1ddeb7361ea25	339	0	469238146517	302649	600000000000	3342	\N	4824	t	0	0
185	\\xb74e315a4ddba3c25e1e3d45d095bfe2982392d1b69fab4acff6c2b20d1526bf	341	0	33236381167	172233	-2000000	378	\N	4831	t	0	0
186	\\xa123741f539de56335e40ef13813303c124bec297b5e3b385ebe87023d1835e3	343	0	19651090	175753	0	458	\N	4844	t	0	0
187	\\x498b008f2e8d2599b4563760c4a6e0a5bebfd7867b2329529119e42046dc272c	345	0	999653510	172013	-500000000	373	\N	4852	t	0	0
188	\\x6021cad93001a53890c2e7087f8cfabdc983926b5b68ef6bd5b3c1039e059a2f	347	0	33234384951	168449	0	292	\N	4869	t	0	0
189	\\x6597662847ce644d5b29087ea0982a3ea4ec2e17f2cf16cabcbad4fccbb65a2e	352	0	989675351	324649	10000000	3846	\N	4923	t	0	0
190	\\xaf2a4a091b46f0eddf58fc54699451e27f6348d43df96d6524dd240b3fffc046	356	0	989414590	260761	0	2394	\N	4954	t	0	0
191	\\xf6575515fd1432713ab99c2beac59b22585cc13b6aa975b9f7845f8f02976865	360	0	494375158	201757	0	1049	\N	5057	t	0	0
192	\\xafb667f58584a8971905570efcf6b2e42325f29de878f3ef548c42c6fce90918	364	0	33234384951	168449	0	292	\N	5092	t	0	0
193	\\x7bdf70ac0128d9f1f1e78b201e99773298f71ecb308c8739e83f8a7733e3804c	365	0	7814039	185961	2000000	690	\N	5101	t	0	0
195	\\x9982cba9377ea5b9760ba96a270727f2e5ab6df0b103c9a62794c339be01b969	367	0	8633754	180285	-2000000	561	\N	5125	t	0	0
196	\\x14136166aa2f9f50dd4dbf22580b7cccd5e0c65f76fe24c6420285daed2d3446	368	0	33232371003	182397	2000000	609	\N	5132	t	0	0
197	\\xe8e149b9616fd981f3634a809c1aacc00d3719723adbce78ad7c813e4699173e	370	0	33236381783	171617	-2000000	364	\N	5151	t	0	0
198	\\xec07c49ef6851436e7e689929d24ab38037b191568fea309b115ae95543cadc1	375	0	33230200794	180373	2000000	563	\N	5188	t	0	0
199	\\xe8ca72d1ff6fbae37c1fa69123f612a21c6d68daa62d11e92fc98a214faeb35e	512	0	469237978112	168405	0	291	\N	6446	t	0	0
200	\\xc7a923356d00ff63621e562af2a74af8dfb10c28c76c9d1a41d05baa9faefbbb	512	1	33232212762	168405	0	291	\N	6446	t	0	0
201	\\x6d4f8dd2dfb3a4b89a34cb83f14d2a7ffdaac1d2c598b4e900de482047e70cfd	512	2	33234384951	168449	0	292	\N	6446	t	0	0
202	\\x4b8ddacad9c959c4f8ba4d8b126e6c0cf931a8449ddb34c5f5f85d7dcabd8b3a	512	3	33230032389	168405	0	291	\N	6446	t	0	0
203	\\x10a6a3201904ff6bfd53e8ee1a0d68cb511c8dda26ec69db4c58ad25c550b614	512	4	33234384951	168449	0	292	\N	6446	t	0	0
204	\\x3d22907f67da61598f72bfa4ad9c1fb153785c2978f9395230239bcb56d98298	512	5	33224863984	168405	0	291	\N	6446	t	0	0
205	\\xd338af2de0ca44b1e4329616cfa559b273d717acac3a95830b8a853e41ff4dee	512	6	33230214962	169989	0	327	\N	6446	t	0	0
206	\\xd1e98b4d48508cd598d3ec86f15881bd57bbd990a7b97bf3ce7b7603bcdaaefd	512	7	33234384951	168449	0	292	\N	6446	t	0	0
207	\\xb69d1956565b02fecc58830b0e49ee721582f570037bd01fc507164cae4f1e61	512	8	33232212762	168405	0	291	\N	6446	t	0	0
208	\\x38b0a350eaeeec176751ad65669a5afeb89968d4cf8aff40d3d215adc0bb5e86	512	9	469232809707	168405	0	291	\N	6446	t	0	0
209	\\xfd22a968e9df477424d2fc2807bba3dc5cf667218c78ea6271278f32566f24d4	512	10	33227044357	168405	0	291	\N	6446	t	0	0
210	\\x9f7bb4367011755543e279bcc31916e0f7c4b5da1f91d2f4350ae924f1d5ca0d	512	11	33232211442	168405	0	291	\N	6446	t	0	0
211	\\xe6b349dd05e96ce107ab4cc9446db9f32cba35ce763c3ec4623580c655846aee	512	12	9485193	169813	0	323	\N	6446	t	0	0
212	\\x320ca79aac1475a7a257241a43b164e6dc4d3fae694257837de83df9c7e49ebd	512	13	33234384951	168449	0	292	\N	6446	t	0	0
213	\\xf222fb07a63e06c8f3565efe3a3508de33f8d318dafcc0cff8d2338660e6a5c8	512	14	33239383367	170033	0	328	\N	6446	t	0	0
214	\\x83e3aa6562c4f7c5b6913794701853e83a5fb51b7d1e46aa22c0416c1abe5b54	512	15	33227043037	168405	0	291	\N	6446	t	0	0
215	\\xf9fcbb8db6c208621ae30382d2485699b955fd1b6f0f8156acd5600cb7f06e19	512	16	2999959819799	168405	0	291	\N	6446	t	0	0
216	\\x4dffa313eaf6fa962a8147c6cbce9ca7b7c2e4545ef7dd0dba4275eb8e31b844	512	17	33234384951	168449	0	292	\N	6446	t	0	0
217	\\x86251495dcdb5292a79a8455bdf834c1d53976abc12e2b1294bb5598eaabc287	512	18	33234384951	168449	0	292	\N	6446	t	0	0
218	\\xf9991873fedde4bc2b80aa8634cc72ad88ed9bf39fd3bc6082e53605a3e98983	512	19	9830187	169813	0	323	\N	6446	t	0	0
219	\\x69162f2f386acb13cdeee36b4e501d759b3f95b3f55a5fda78e5c476619d6f2c	512	20	9830187	169813	0	323	\N	6446	t	0	0
220	\\x9db88f44647eddc49e77c317d72ad78c4006c4f5d94a0f9ea1daf81aa955c1d0	512	21	33229216546	168405	0	291	\N	6446	t	0	0
221	\\x9d5dccf550f7945a0b4837d22f474c49117d52494459774e69a290aa48375e54	512	22	33221875952	168405	0	291	\N	6446	t	0	0
222	\\xc1b186b78bf14402636a8e7fccbb98d80bb42e6b535c061463b55629dcbf6a48	512	23	9830187	169813	0	323	\N	6446	t	0	0
223	\\x1df7ba64f718d99122ab4145f5df950fab799bce4b9ffcb64df82598fb83a296	512	24	9830187	169813	0	323	\N	6446	t	0	0
224	\\x01c0b8cf6127e32e6c3cc4e8c520eeae31d710d483267121485c3d001434366b	512	25	33236212762	168405	0	291	\N	6446	t	0	0
225	\\x40b215cddfe798c2b083c0c08b524bbfbbac19dd68abeedbac891e01c4ea4475	512	26	33234384951	168449	0	292	\N	6446	t	0	0
226	\\x737e30d9d9f6750312c707a264ee6b74cc519f093b6e3f68bc0f54b2d9e270a7	512	27	9315380	169813	0	323	\N	6446	t	0	0
227	\\xbdd811d277aff815c190390a42ed694eee7d1c1f2ef3b3c0625d804157dc4fb7	512	28	33219695579	168405	0	291	\N	6446	t	0	0
228	\\x328f883fb17016898006d1377599111d4236a77708331222291de3c86264855c	512	29	9830187	169813	0	323	\N	6446	t	0	0
229	\\xe714d293bf8999c9d8b8d876aeaaa6840d7e44a0840d971c8c2d6407b6e520e1	512	30	9660374	169813	0	323	\N	6446	t	0	0
230	\\x261c8e2b6bf941d8eed9e73d647e04df78ecc308c12b9d09dbd74449230b2e66	512	31	9830187	169813	0	323	\N	6446	t	0	0
231	\\xd4e478328e7c99005d582433f27f2c64e9e608f19617888580584f8981f9a334	512	32	469232639718	169989	0	327	\N	6446	t	0	0
232	\\xfc1d479bbc9da46c5d5b56ced314e221911a0418adea8bb451b9f65626abf7cc	512	33	9660374	169813	0	323	\N	6446	t	0	0
233	\\x27acd5da9d0907ef3f668f4a590af3270775a2b73fcfef984f72aee087351aed	512	34	33224216546	168405	0	291	\N	6446	t	0	0
234	\\xe02fa3d5cf532e90af9473ac74e0a2555cbbb842d6e6e77550384ca84de5777e	512	35	33229216546	168405	0	291	\N	6446	t	0	0
235	\\x33c6de381eb1d3c985a61771f8ef14fcc5189f9b4f1d7504d1b1d84d69cf2c3f	512	36	33236213378	168405	0	291	\N	6446	t	0	0
236	\\x0a71a8294c44e313cf63b51e5140f7161cff9b87c3bb2a13191dc3e7a0eec3c6	512	37	33234384951	168449	0	292	\N	6446	t	0	0
237	\\x372f991a962380704c9846a59f247fa7fbd6882f1e22777a5f59aeb09356c3d5	512	38	33229216546	168405	0	291	\N	6446	t	0	0
238	\\xea5435a926466ecc9425669bdf9c5b1344f502c1041e22c817c47d99a48cf784	513	0	33229216546	168405	0	291	\N	6446	t	0	0
239	\\x0aad00c51d8a5fad3f3ffbe40d347ecca2cb6a6900624160b2437ca493e85df4	513	1	33238698747	170033	0	328	\N	6446	t	0	0
240	\\x5d19a131bac9b8aa8e9dd219164c03e982eed0c0902f72da4807003210855f98	513	2	33233530342	168405	0	291	\N	6446	t	0	0
241	\\xd181fb957279b2d82729d43e777662030be0cd9b221f7cdd4d16b135d182c85a	513	3	33224216546	168405	0	291	\N	6446	t	0	0
242	\\x43434e77e24cca98a0c085cc47d08023abf9c3b68c490fcb5d935b7e85cb3b65	513	4	33231202598	168405	0	291	\N	6452	t	0	0
243	\\xc35108d7d2d602eb80c4c2d356539c6ee67588d314a1edd30efedc503e05fc1f	513	5	9830187	169813	0	323	\N	6452	t	0	0
244	\\x22deab002e8a57e27dd4029443f85d8a18e5b0f85edbb9b7a7e2becc13974c84	513	6	33216707547	168405	0	291	\N	6452	t	0	0
245	\\x25585e000f080cd874c699c18e3e0bc849ff43d64a95e5350d4d62bcf21175f6	513	7	9830187	169813	0	323	\N	6452	t	0	0
246	\\x88899d93b698ca44c5c713189d3b62ac4b13872907e5cd13f381550cc17c6d0b	513	8	32234216546	168405	0	291	\N	6452	t	0	0
247	\\x0cedbedc6d3207e64019a54027229066a9e90758e331d2ce431d9ed5ef5715f9	513	9	33228361937	168405	0	291	\N	6452	t	0	0
248	\\xccabb0623b5dbb6a57ff800dd194d157437202fef597dd98db9e75270d6c777a	513	10	9830187	169813	0	323	\N	6452	t	0	0
249	\\xe157b74bef43d78ecd400296c2524640ce82c46722f12b96e68c90934110e773	513	11	9660374	169813	0	323	\N	6452	t	0	0
250	\\xc2cf46d5c773597bc7ef50f2df95ca7679175fb3c8b7836775dc26e67ccab1ca	513	12	33236043389	169989	0	327	\N	6452	t	0	0
251	\\xe2e570b0834d01548eb14a5115bb7e4805d7e811eba648bf937069f5f2641cc8	513	13	9490561	169813	0	323	\N	6452	t	0	0
252	\\xb15ad36b9272762d2e57e5ba83a3470466a47be23842b7c9cedff909d9c413c4	513	14	33221874632	168405	0	291	\N	6452	t	0	0
253	\\x417edd7d725f14d4c46b52cc7b1bb52b17c8b3218aee8b1a39be70c08b9d43ea	513	15	469227471313	168405	0	291	\N	6452	t	0	0
254	\\x036c965f46babc24da23f0715ef6195d61c334ee754f2284d9e6d560286ac1ad	513	16	9830187	169813	0	323	\N	6452	t	0	0
255	\\x5c17647fc3f0114f99b2929addde7d5cbad99577837b107e104bdd977cf544bc	513	17	33221534830	169989	0	327	\N	6452	t	0	0
256	\\xc60ae1dd94957efa35712e918f4e6f6ba04c294be4f5ac55238af661ee94d236	513	18	33230874984	168405	0	291	\N	6452	t	0	0
257	\\xded44093fe9dc56f155bfa8ff5dd5e177b5dd25900da66f0c64ae380073cc21e	513	19	9660374	169813	0	323	\N	6452	t	0	0
258	\\x8d1ae2e7d0529e8a7d8db1f4a89526327768dd2a4f84d7f65d56ab121c341c3a	513	20	33226034193	168405	0	291	\N	6452	t	0	0
259	\\x76b138407054c54ab09ab39b8a942cf1a6920468484406e916fe94c990a0ab8d	513	21	33234384951	168449	0	292	\N	6452	t	0	0
260	\\x7e5d264e1c13b4af05b666aa97353c107c140502dda667ec3924449d4ec1602a	513	22	33224048141	168405	0	291	\N	6452	t	0	0
261	\\x5a2206993b73420a65f26edad73408cf891fb4b37ca0702321dab9012098dd71	513	23	9660374	169813	0	323	\N	6452	t	0	0
262	\\xcbede35b50e750154edf3400fb3c347141d660aa3843742abe759f2cd4fc7d8e	513	24	9490561	169813	0	323	\N	6452	t	0	0
263	\\x913c6a1e2be206a1a8f867efaf2d6f57a45dc987d22ca93d8e9319d344802167	513	25	33225046557	168405	0	291	\N	6452	t	0	0
264	\\xf940fa29a94071ffdb72109c1fbfba9b5ef1b95e9dac6f585468c9eec7655581	513	26	9830187	169813	0	323	\N	6452	t	0	0
265	\\xd386fe384484c1db83992b3055af2de8974ce14c710a9ca14189859a5132053a	513	27	9830187	169813	0	323	\N	6452	t	0	0
266	\\x53c4d35aee7e0b36d8acd19021b8f4bfa5782bff04e40a1bf7b7f8f556d6fae6	513	28	33233244948	168405	0	291	\N	6452	t	0	0
267	\\x4da558ee58bf707e768c0c9e37885b88834b2bc14175c2a64781c0e4b0a7a30b	513	29	32239214698	169989	0	327	\N	6452	t	0	0
268	\\x6a432e069a5d01ce3cbfe4b7e7ce1521c26c381f382c79aa289289f7ef4e491b	513	30	178331771	168229	0	287	\N	6452	t	0	0
269	\\x4d81a9553f62f18a7bd34ee9a9d4e60eb57efb0cd2f062c0201df5e814536641	513	31	9830187	169813	0	323	\N	6452	t	0	0
270	\\x15f439223fe2b36b4b7b9f2640ce1624b5365acd33408d212c88d257fcb23d75	513	32	9660374	169813	0	323	\N	6452	t	0	0
271	\\x52f071b020533b7a83cb1f4eb358be3e24e307e4a01d590b694e5d43d501b85f	513	33	33223706931	169989	0	327	\N	6452	t	0	0
272	\\xaedb63491b772982663def85b5df8e5739601f52eb14bccb75bbae59f1e6fb10	513	34	9660374	169813	0	323	\N	6452	t	0	0
273	\\x3914ab4edff10c36425764584e2dfd16ce6c85c6d1577e56a6bd9ce7ef627fc5	513	35	9830187	169813	0	323	\N	6452	t	0	0
274	\\x6a8a5871170abfaddf0b21ea7d2260476a84ac578362a8d78c5140c3c0085f2b	513	36	9830187	169813	0	323	\N	6452	t	0	0
275	\\x649e13b509ecb8bd8d0f63d68ceb23696d3a94a8574ee1fda051ac61f4beb65f	513	37	9830187	169813	0	323	\N	6452	t	0	0
276	\\x7db557bb0a83de3678234d9126c5b81b85b71c5eb8f06f98e0e4b7d20ec9df1f	513	38	9490561	169813	0	323	\N	6452	t	0	0
277	\\xb39532f2901242bc6e9a0f308c8bf9b7ccd76353944b14f301658fbe26bc4561	513	39	33234214962	168405	0	291	\N	6452	t	0	0
278	\\xc5de921276a1a8f15c97532f06a4becafaf3dd54260d10d9b0e859a6d8a70de4	513	40	33230535182	169989	0	327	\N	6452	t	0	0
279	\\xe9d251b8ed6133ca57625fb23c541c2377f316f1e1304a824712f22a24f6aa1d	513	41	33219878152	168405	0	291	\N	6452	t	0	0
280	\\xc4246b4d51c01f7de87b22b6d0c8a857b4d13d478ec8587346c4931140e1e6ac	513	42	33225366777	168405	0	291	\N	6452	t	0	0
281	\\xce18370f7e6a9d261457469dfc1e5e8ce8f17c5e56341b3237f215bce79767d9	513	43	33224046557	169989	0	327	\N	6452	t	0	0
282	\\x227bb1700a2cea6153deef8b1f91bcf1312dc36813636e8e73b40fa09c0af25f	513	44	9830187	169813	0	323	\N	6452	t	0	0
283	\\xfcafc79986d9e387463e5829d1007011055f3d5b0ed80fb8ff33f29ea373bfe4	513	45	33224048141	168405	0	291	\N	6452	t	0	0
284	\\x1df162df6a5cc372136cb44b991fd68481d60c52290922f40f4d52929fbda725	513	46	33229046557	168405	0	291	\N	6452	t	0	0
285	\\xa504ef1730c1bf44fa6d17af62dc9558955ed2745e8b19335a244d5cd4a08b2a	513	47	33223193532	168405	0	291	\N	6452	t	0	0
286	\\x8c91230d362060eb95fe646bf4372a811cad435321a2c539b76b7b9f37918467	513	48	33231216942	168405	0	291	\N	6452	t	0	0
287	\\xcdd4b95bdf3176d0fd95d7164295eecbdc9775a6f01d829dd6bad35579c74cd9	513	49	9830187	169813	0	323	\N	6452	t	0	0
288	\\x50f9da5fa35c960c7da48b03d6d8ceffe6952d5b8ad3f9bebbe403a49366da18	513	50	33229216546	168405	0	291	\N	6452	t	0	0
289	\\x9224ca28bb425d8bb185e3c0a4640c49482d719ac867e84023db5464cd220578	513	51	9490561	169813	0	323	\N	6452	t	0	0
290	\\x5ad3eea6b9f296f5a00bebb7e383731ebdff6ff93aacd6892b5a46dfa70c8de4	513	52	9830187	169813	0	323	\N	6452	t	0	0
291	\\x1c8ee3cdb26e86451de3745d7dbad344856e35c0cc06eb8e4f0b7e66bd29cef8	513	53	9490561	169813	0	323	\N	6452	t	0	0
292	\\x536fb937859f4895f3df63a120bcb71684e8ddefac558c5834abc6ecaa661b21	513	54	173163542	168229	0	287	\N	6452	t	0	0
293	\\x9a01d909148f14c1cf2134565f8a4fb44c988708c6d8053f8e360aa64c194271	513	55	33218879736	168405	0	291	\N	6452	t	0	0
294	\\xb3e524c08e9bfbe875ed3d1638b243a05320669d086bf36afb6e3450b5b1e696	513	56	32238535270	169989	0	327	\N	6452	t	0	0
295	\\x644d3d97402f85cf62e1dc1f0a4b78765a69038323f44d4939df7adc615e2e60	513	57	9830187	169813	0	323	\N	6452	t	0	0
296	\\x2920a7035b2fa55e22dea492f0657946575521041955b0cceda268e1c1172725	513	58	9830187	169813	0	323	\N	6452	t	0	0
297	\\x74577995a9e63471ee0f45a5b10ee3cfa1a870688b544475d3330b3ed6139a14	513	59	9830187	169813	0	323	\N	6452	t	0	0
298	\\x81e17216cd9a9173df5c7ee4b07c5a94d4d1c9691f5e4b753dc33da2fef00fc6	513	60	33236042773	169989	0	327	\N	6452	t	0	0
299	\\x60fdab9e5187922a7ead72a39f488a7bfc5626fff7670ed7c5ed5421bb552376	733	0	34582123383	174565	0	431	\N	8445	t	0	0
300	\\x7a56ef452d9df4d3addc0bfa85b9a6be6ee423da758cd0668653cdb4dcd3311c	739	0	4399232366207	357473	2000000	4592	\N	8471	t	0	0
301	\\x4030b6dfb05ab22deb41673b846798d8d0c5acf84dd655aefab98bc936b4a664	933	0	1106924920921	174697	0	434	\N	10441	t	0	0
302	\\x09b7648f872b6daec5108b20d27921a05eda4f554b12a43c01703ee68f1c7062	933	1	137475854210	168405	0	291	\N	10441	t	0	0
303	\\xa46d98a2a9946eab2f04641e0140f41c42b3d19705a80ee29277c115483228fd	933	2	137470685805	168405	0	291	\N	10441	t	0	0
304	\\x3cc7350c73213ddbed3f6ed66958747de24617ff380ed796ea12e819275657ce	933	3	9830187	169813	0	323	\N	10441	t	0	0
305	\\x1273f67150442075a5989a5310c7ef42f249048e5d5b16989dd671bbd97e7699	933	4	9830187	169813	0	323	\N	10441	t	0	0
306	\\x0390bb24ddfde0d5f8a44849379f285246a267bd0e94ef1ad3859d323a02efd7	933	5	549903922055	168405	0	291	\N	10441	t	0	0
307	\\xb6b8596f085b52d98f655b42f35fa95c4dd4f521c0c196816fb5e1f3fe77e566	933	6	34368837248	168405	0	291	\N	10441	t	0	0
308	\\xb9f08fcd70a1633aabaca719d5813bb1ff75d028b4eee26a574996a35df26086	933	7	274956705428	169989	0	327	\N	10441	t	0	0
309	\\x1c14a048b8299ba960a1883751620a5ad8ccd65cc77d50a2ccf3c25cb9dbf660	933	8	9660374	169813	0	323	\N	10441	t	0	0
310	\\xdd4e8e5c801a9005a3162e96b490d96c3bcb34b1c3c220662b78018fb4906315	933	9	9830187	169813	0	323	\N	10441	t	0	0
311	\\x82eb3e0f964216ce509be7a04c659bb1f763f3e9a116367ee2c7ce9a04494699	933	10	34363668843	168405	0	291	\N	10441	t	0	0
312	\\x316237b579b7df0afc4f88f96df447878942e09408f72ddfcba6ad392c959750	933	11	34368837249	168405	0	291	\N	10441	t	0	0
313	\\x14d157ffea2624369045d5181cdec5593355c2ceb781320072a1b5450ada85b4	933	12	274951876825	168405	0	291	\N	10441	t	0	0
314	\\x30a2ca7e74e3a2f6a151f9901dfa3e78759f96a71cc82667b02ac7f0a266d8bb	933	13	549903582253	169989	0	327	\N	10441	t	0	0
315	\\xe22a1abb140cda3f4678d08f8d98947c9ffca9da22aca4068eae494a45c24a79	933	14	549898413848	168405	0	291	\N	10441	t	0	0
316	\\xb2f2b8c847c6a85a636eb5c900c6e93144096ab1fece21d7ffd9b2ace8537357	933	15	34363668844	168405	0	291	\N	10441	t	0	0
317	\\xc894bcab7fb7723ca1b24543f39a3fddba528cfb797187e9bf1e98ec38fb8acf	933	16	34358500438	168405	0	291	\N	10441	t	0	0
318	\\xda5cbc43dd70ade26a2419df9a90ccb6ddfb093afdcd14437005ac41ddcde421	933	17	1099808012515	168405	0	291	\N	10441	t	0	0
319	\\x0933403612dabc4d0a6142204196789fd2a6511f36c8f585b91e783ffd9191d8	933	18	274956535439	169989	0	327	\N	10441	t	0	0
320	\\xa839790bb7380c888ea239837d97f27ba2f49566485d1383c651e67b6064c33e	933	19	9830187	169813	0	323	\N	10441	t	0	0
321	\\x1ad5183a2a271c1607c1d9a96d64e1fb1551c71c0e09f70e6b319fc341b089b2	933	20	9830187	169813	0	323	\N	10441	t	0	0
322	\\x5ed435964063cf4a038a3bcf3f1d89ca5a0ce595eb352d9f959721e1da32a652	933	21	9830187	169813	0	323	\N	10441	t	0	0
323	\\x0f5efafd61770da0d7f51fff5239c98e2fe3fa7e2f70a2ab7f6f5ae46cc5ed26	933	22	274956365450	169989	0	327	\N	10441	t	0	0
324	\\xe6b99fa7a53d86855bc7f3402387fbba708275deb7445bf8a8a12385b3776777	933	23	34368837249	168405	0	291	\N	10441	t	0	0
325	\\x5ca71e8a818390f3ed09279cd08350db7346da04b736dc6a1626698e7ea1c5aa	933	24	274951197045	168405	0	291	\N	10441	t	0	0
326	\\x9d10923d64beb267e591c5d12f18a261b21f42425cfd1b67178cf3e61d12a336	933	25	68737842903	168405	0	291	\N	10441	t	0	0
327	\\xa53bea401e749e749d07b31d3409bff36972f03644ee1ad8a4b017468e7863d9	933	26	9830187	169813	0	323	\N	10441	t	0	0
328	\\x5ca8d13f50f73a72ca96a78c474bda6ddecec0bbcc698639eda34d214c00d3f7	933	27	34363668844	168405	0	291	\N	10441	t	0	0
329	\\x4fe313a019e25540fa32fa266ab5c312804f364deda9ed9513c69dd51734f256	933	28	9830187	169813	0	323	\N	10441	t	0	0
330	\\x37f3b50fc9e77ccbe25c0ea70b9e115bea29c896e45470159201ac95ad470c8e	933	29	34358160636	169989	0	327	\N	10441	t	0	0
331	\\x8442d18d1c5723044da9ac2219933f79e500b6d1433f7dd6d951b15e5ea8942c	933	30	9490561	169813	0	323	\N	10441	t	0	0
332	\\x06ff9533e9b72b517ec9a1edef7bbeec3c623d1f9a3da9472621f007669415cd	933	31	9830187	169813	0	323	\N	10441	t	0	0
333	\\x0fef65ed7d48236151bb89103a1c70975ed86734557de679e4f98232250a227a	933	32	549898243859	169989	0	327	\N	10441	t	0	0
334	\\x0e961db0c0e94b690f086a404c1e95f475bfa5aa77dc364b526d7c89825b5998	933	33	68742331880	169989	0	327	\N	10441	t	0	0
335	\\xd0dcd3ac6baa19235fc1647ff07f11d35096eae85033b2d3f2383078cb87c33d	933	34	34352992231	168405	0	291	\N	10441	t	0	0
336	\\x197e59f7fc2b3d3d72682d755a80d574ba627f7eeed2f8edc6de9d0c3297bfd0	934	0	68737163475	168405	0	291	\N	10441	t	0	0
337	\\xae6e716f0ce8c61c28a6162d9ff48f63685f2e41787f643b3747f982cba0b2fe	934	1	9830187	169813	0	323	\N	10441	t	0	0
338	\\x4e13429f8c1cfec670a8084b604b27340a8eb794450f66ba65fe73aa19a6544e	934	2	9830187	169813	0	323	\N	10441	t	0	0
339	\\x786a0421213421aac74e59b6662e592e71bf90eb44e5b91a62b3122f46a8552c	934	3	137465517400	168405	0	291	\N	10446	t	0	0
340	\\xc1e24d2e36542e521b603b82c3ac239a90d522db36045cdd4d8219279c407dba	934	4	9660374	169813	0	323	\N	10446	t	0	0
341	\\x9f2fc08de9bc7c534e29b772f4555990299b4f55746b78e78b359eff8058bfdc	934	5	9830187	169813	0	323	\N	10446	t	0	0
342	\\x1d75934ee72db8b249144c94b285dbb83459e81cd9317e70e3c8fb455b0c737f	934	6	34358500439	168405	0	291	\N	10446	t	0	0
343	\\x3d3b6c097eff21932e171bc0c2dc6b301bb737235fcc7bc5e0fa4d6fde6c2452	934	7	34358500439	168405	0	291	\N	10446	t	0	0
344	\\x1625f671a943bb5b43dfca47e24585eb2188eb6a22f4f1bf870c3bb0c70935b3	934	8	549893075454	168405	0	291	\N	10446	t	0	0
345	\\x87ee89f371aa2911ff798063685dab182cf539e3989be16c1ff2f50528607603	934	9	549887907049	168405	0	291	\N	10446	t	0	0
346	\\xc0a0bf1b0ef80a345c8eba81683aa90d4f1bcd9830063918890515e4d0e459df	934	10	9830187	169813	0	323	\N	10446	t	0	0
347	\\xe4bda3cdd662c2aa5a44bb544a06f52be9e9eb04e382b428a0865de29628d2af	934	11	34347823826	168405	0	291	\N	10446	t	0	0
348	\\x3ec9e216e11b2c0d2ebbba4166c0e790b8bd219cc925a12e401c0e51d7a0282f	934	12	68731995070	168405	0	291	\N	10446	t	0	0
349	\\xf180a480b6c8bdb2c99d033ace8e3b24e645a2f8dfc8b207fbd5673ad4502034	934	13	137475854210	168405	0	291	\N	10446	t	0	0
350	\\xf07e61b724a7771417ed36e7cdfcc061e155fe44a13c5d126919a86e95140c0e	934	14	274946028640	168405	0	291	\N	10446	t	0	0
351	\\x547868124b2f651f000c7b3c3c5974e776478ea6479a530122e4ac9f035a2154	934	15	9830187	169813	0	323	\N	10446	t	0	0
352	\\xd5fa1ee299878f8391c7b599fa593c0bab660c5f5df0544b095bfecc93455f1e	934	16	9830187	169813	0	323	\N	10446	t	0	0
353	\\x9c801a8ac9bf8b4909d136d4951a76adc0a2f1af7df364e45fb01bc1291e3e4a	934	17	274940860235	168405	0	291	\N	10446	t	0	0
354	\\xef95ce970f996fda01aa0570fba45fc49648d64a2931fd105b0deb18768269bd	934	18	137470685805	168405	0	291	\N	10446	t	0	0
355	\\x90e96373cbe146840b13364044d1fda47fbbfc4c776d3ff105c1b237eddeafd8	934	19	9490561	169813	0	323	\N	10446	t	0	0
356	\\x26504abb9e3cf3fb317cd17b1ec3af4298dfce2e1219b1ca86e99b03c35a950c	934	20	9660374	169813	0	323	\N	10446	t	0	0
357	\\x6fd3a2469453b4b46fd7b523aaf945208990b34824b0a80f3fb519a68c3ff570	934	21	34368837248	168405	0	291	\N	10446	t	0	0
358	\\x86f6ccf8ffcb8b81ca05666f4f427d1fa7cf4acfb96914ca54e68b44b18aad5a	934	22	9830187	169813	0	323	\N	10446	t	0	0
359	\\xe5cb389e96ba4a9490198ea799423122a8d0b06019b4da310b7a4157262f6318	934	23	68737503101	169989	0	327	\N	10446	t	0	0
360	\\x1cdc0a3a8eb9936f7d28590c77183707a9591ec9c5722ad18ddf403ee97051e0	934	24	137465517400	168405	0	291	\N	10446	t	0	0
361	\\x7806b0264c0003f3cce1144f11b4823e7741b81988d2ed842a1348605791c2e2	934	25	9830187	169813	0	323	\N	10446	t	0	0
362	\\xb2cd2392d158b60fb1d5f38f081bd919c4c72e205fca01eb1f10b797fa223b69	934	26	137460348995	168405	0	291	\N	10446	t	0	0
363	\\x8d01772579bb0eb75b15b142ce8f02db4f39d561eba17814b8a90e4e55e840f2	934	27	9490561	169813	0	323	\N	10446	t	0	0
364	\\x3c4731e96354e7fdde928b4c8c22f9f8a1154b4cbb8f57ebc203527909e63dd7	934	28	549903922055	168405	0	291	\N	10446	t	0	0
365	\\xcb557d410f291bbdc95c429e324099a69bb1ed8bceea038ed6cec0e7e4e04d5e	934	29	34353332034	168405	0	291	\N	10446	t	0	0
366	\\x48b4eac87097525f9328638b42868ab5886f84e100123fb581f2408573c978d9	934	30	9830187	169813	0	323	\N	10446	t	0	0
367	\\x9a466f96b6bc414eba8d1cc29623d332fd74ec5df180332163ffdbef598c0f18	934	31	9830187	169813	0	323	\N	10446	t	0	0
368	\\xf5f017daf17c0b38397d243661fff9dc77389d0dd341a6152dd10f5a335efe12	934	32	9660374	169813	0	323	\N	10446	t	0	0
369	\\x5a8353d7b140efc5ffbe6fa79209d34df93105bf91fc503681167f0d92cb55df	934	33	9830187	169813	0	323	\N	10446	t	0	0
370	\\x8cca96daf944d2bfe145dbcf39e986045504bd8f223b1d2d5bc1c82686e92f3d	934	34	9830187	169813	0	323	\N	10446	t	0	0
371	\\x3af0576062016841406bdc413b956b620b17ef0310174c330b6d4eaf65821551	934	35	9660374	169813	0	323	\N	10446	t	0	0
372	\\x7c029d355494f6f78354bab669f038aedb7b4d78206f40814acfb8b7b53abd15	934	36	9660374	169813	0	323	\N	10446	t	0	0
373	\\x7e881b8e4ce03eeb2640d3d7526816915ba9e785839cfe43dde8ac478b30a0d5	934	37	34347314211	169989	0	327	\N	10446	t	0	0
374	\\x68da3e3a8098adc9b17191e50c80a5f155e6215318a760dc5ec3369a750ff719	934	38	68736823673	169989	0	327	\N	10446	t	0	0
375	\\xe91491cec1fc50e1909d940ad7b9f747db8d9f58c37a47ab8ad89eda0b75ce8a	934	39	9320748	169813	0	323	\N	10446	t	0	0
376	\\x5e43e8438fcdc4e438c26cf33798b2a65bd15d2f610ce0f03f651b668b0eced7	934	40	34368327633	169989	0	327	\N	10446	t	0	0
377	\\x1fd0e593e7b29d5e596cd899ee56b531b51d2cb23e59dfcd74f04355a9591069	934	41	34342145806	168405	0	291	\N	10446	t	0	0
378	\\xb5f7b67dd44883169067d26d90560990b7ecd019e087b04c6ff28c61865dc6d4	934	42	549882738644	168405	0	291	\N	10446	t	0	0
379	\\xf7e22c665bde164e98bc769e3fed8d1ba961967659b339f7b94b6da711bb2616	934	43	549898753650	168405	0	291	\N	10446	t	0	0
380	\\x0581f3d4bf63e2c0f253ec9ff8acfb9aade0abd17ede84dc6254b08623879781	934	44	9830187	169813	0	323	\N	10446	t	0	0
381	\\x055f5377c6493d0feffdec1d1a544f3283d06f8983c974fbafece0304f9048d5	934	45	137455180590	168405	0	291	\N	10446	t	0	0
382	\\xd5b20bfd5a6108bff8c3c70127a29efca15fd4811dbf787d70285b1fa723b007	934	46	9660374	169813	0	323	\N	10446	t	0	0
383	\\xc7599be8f969892aabf76202ae9ec2d6f9daeb9fd6f6d9bd485d10ec90defb59	934	47	9830187	169813	0	323	\N	10446	t	0	0
384	\\x31eefb34095e6a7b931dce5922dac2d7f1cde2de86c7ddbaa0bb7de817bdc254	934	48	9490561	169813	0	323	\N	10446	t	0	0
385	\\xa854848c81024c84a9b3c0cce1f3292926552237cc30887b55b04e88c69a3200	934	49	9660374	169813	0	323	\N	10446	t	0	0
386	\\x47288dcf08f57d8e54d271132dec02c23dcac69d5fa55a2d83594a780df6a91a	934	50	9830187	169813	0	323	\N	10446	t	0	0
387	\\x67e2f54a1728feb4d259b27fcc991e223844adad6dd28e8da96b5c5b82ab921c	934	51	137460348995	168405	0	291	\N	10446	t	0	0
388	\\xc4399f051b1b0564ed66f8194dce080ae3e1a391d9fc0a5e49299362334af2a9	934	52	9150935	169813	0	323	\N	10446	t	0	0
389	\\x2fe7c07b2152a321b55f8a8aeb6d3c8a8b6cdc5cbf9c40cc217a1440eea3abc8	934	53	549882398842	169989	0	327	\N	10446	t	0	0
390	\\x962f4f6f00f2e4264153dd0cf0a88133793bbc2a52db826761d776b9138d9b4d	934	54	9830187	169813	0	323	\N	10446	t	0	0
391	\\x55dc304a3ce15fbf0efa42c9a515a22b18a0fa0b0e3cad5fab387df9d2112c6a	934	55	9150935	169813	0	323	\N	10446	t	0	0
392	\\x5146d47a77d520d731205a8655925d07ebf734c3a9f251e0941578099a595894	934	56	9830187	169813	0	323	\N	10446	t	0	0
393	\\x66b690b13e5523ddbb3bd11f0dd93d2f9ca2a8c5ca983d8fe37223933d8b4877	935	0	9830187	169813	0	323	\N	10446	t	0	0
394	\\x3a17c213b88dcf1ed15df5e988f94f76fa41fbfdceb4328a2aa71b49904baf87	935	1	9830187	169813	0	323	\N	10446	t	0	0
395	\\x409b0cc91cd865da829564ba9ab0928422fe7581e3fb3622222f47f428b9f111	935	2	9320748	169813	0	323	\N	10446	t	0	0
396	\\xa43580df9dca222c585b670fe8fc774acb898d64a614f9205bdc4fa0cdf5f74b	935	3	274940520433	169989	0	327	\N	10454	t	0	0
397	\\x7cacdd6beeb9649529c33ea14c6e56b9d3a4d66899166adb88ffd5ad4df37514	935	4	9660374	169813	0	323	\N	10454	t	0	0
398	\\x103edf5ea2ccc53a58bd28b8ec0553550b7f26fc158b7e420a0bca70c24cc90d	935	5	9830187	169813	0	323	\N	10454	t	0	0
399	\\x60c9b6af88430a83824555c9e7cd455cf9b42fa62786f4a31ac1f812f33f02f0	935	6	68726826665	168405	0	291	\N	10454	t	0	0
400	\\x107b520fb294f9335cdc47382511c6eb41601a377d6477ad874f27888ea6efc0	935	7	9660374	169813	0	323	\N	10454	t	0	0
401	\\x4f58ae6ca804661f7a6fafc8dd731091690fd10d3c358b793a4c00b7d7c788bf	1128	0	1113151675750	180725	0	571	\N	12456	t	0	0
402	\\x080ede4ce1d7d74a5a3088cfb080ae0c6f33c4d3b6ce33b506107ebb746f7719	1134	0	4999499820111	179889	500000000	552	\N	12521	t	0	0
403	\\x2325661a2e1498462c6c5c5dd1a742a33927bc0696d1bea46ed8caa58655abab	1138	0	4999497648538	171573	2000000	363	\N	12572	t	0	0
405	\\xf0ebd164953304f560bbb6b205489aa44bc094da62a9b96c89cbb62ae0bf4848	1143	0	4999497471201	177337	0	494	\N	12618	t	0	0
406	\\x04f1ff742f9e6ac34a68ca00e1b968ef990193478ab738b4195abdedf8daa609	1147	0	4999509816591	183409	500000000	632	\N	12653	t	0	0
407	\\xd67bd3cf0b261b14b19be79289b362675cc0035286d560e76348b77cea45f766	1151	0	7826447	173553	2000000	408	\N	12732	t	0	0
408	\\xeeb6f01249df756221ae1995a75202d8e0fe259979a2cbf65e4214ac1104fade	1155	0	5822839	177161	0	490	\N	12773	t	0	0
409	\\x814c8440a90f268e33a457d4cac7803481bf274579d4c945627dc281157ab69e	1159	0	34363092788	234845	0	1700	\N	12839	t	0	0
410	\\x145868dfa9294e855d1d98be742ffd913f3f40871a7572749faf32ece1c47d86	1163	0	19603482	226705	0	1515	\N	12883	t	0	0
411	\\x3f964a203922e445781b5fde950079ea81e2ca4f34b461a1e5fcfd42d660390c	1167	0	68731600708	222965	0	1430	\N	12924	t	0	0
412	\\x73f99e9235b44410bbed82e94badf367e55bb9a3b5dcfc0149662dbb8b52dc51	1171	0	274946685452	191373	0	712	\N	12977	t	0	0
\.


--
-- Data for Name: tx_cbor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_cbor (id, tx_id, bytes) FROM stdin;
\.


--
-- Data for Name: tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_in (id, tx_in_id, tx_out_id, tx_out_index, redeemer_id) FROM stdin;
1	35	32	0	\N
2	36	21	0	\N
3	37	22	0	\N
4	38	29	0	\N
5	39	27	0	\N
6	40	12	0	\N
7	41	25	0	\N
8	42	17	0	\N
9	43	18	0	\N
10	44	20	0	\N
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
23	57	42	1	\N
24	58	36	1	\N
25	59	44	1	\N
26	60	39	1	\N
27	61	43	1	\N
28	62	40	1	\N
29	63	45	1	\N
30	64	37	1	\N
31	65	41	1	\N
32	66	35	1	\N
33	67	38	1	\N
34	68	58	1	\N
35	69	60	1	\N
36	70	59	1	\N
37	71	61	1	\N
38	72	64	1	\N
39	73	57	1	\N
40	74	62	1	\N
41	75	66	1	\N
42	76	63	1	\N
43	77	67	1	\N
44	78	65	1	\N
45	79	78	0	\N
46	80	76	0	\N
47	81	70	0	\N
48	82	72	0	\N
49	83	68	0	\N
50	84	71	0	\N
51	85	69	0	\N
52	86	75	0	\N
53	87	73	0	\N
54	88	74	0	\N
55	89	77	0	\N
56	90	48	0	\N
57	91	55	0	\N
58	92	56	0	\N
59	93	46	0	\N
60	94	52	0	\N
61	95	50	0	\N
62	96	47	0	\N
63	97	51	0	\N
64	98	53	0	\N
65	99	54	0	\N
66	100	49	0	\N
67	101	92	0	\N
68	102	93	0	\N
69	103	94	0	\N
70	104	90	0	\N
71	105	91	0	\N
72	106	95	0	\N
73	107	98	0	\N
74	108	99	0	\N
75	109	97	0	\N
76	110	96	0	\N
77	111	100	0	\N
78	112	101	0	\N
79	113	105	0	\N
80	114	107	0	\N
81	115	108	0	\N
82	116	84	0	\N
83	117	80	0	\N
84	118	81	0	\N
85	119	87	0	\N
86	120	83	0	\N
87	121	120	0	1
88	122	120	1	\N
89	123	122	1	\N
90	124	123	1	\N
91	125	124	1	\N
92	126	125	1	\N
93	127	126	1	\N
94	128	127	0	2
95	128	127	1	\N
96	129	86	0	\N
97	130	82	0	\N
98	131	130	0	\N
99	132	131	1	\N
100	133	132	1	\N
101	134	133	1	\N
102	135	134	1	\N
103	136	133	0	\N
104	137	135	1	\N
105	137	136	0	\N
106	138	137	1	\N
107	138	134	0	\N
108	138	135	0	\N
109	139	138	1	\N
110	140	137	0	\N
111	141	139	0	\N
112	142	141	1	\N
113	143	142	0	\N
114	143	141	0	\N
115	144	142	1	\N
116	145	144	0	\N
117	146	143	0	\N
118	147	146	0	\N
119	148	147	0	\N
120	149	148	0	\N
121	149	146	1	\N
122	150	144	1	\N
123	150	149	0	\N
124	151	150	1	\N
125	152	150	0	\N
126	152	149	1	\N
127	153	145	0	\N
128	153	152	0	\N
129	154	151	0	\N
130	154	151	1	\N
131	154	153	0	\N
132	154	153	1	\N
133	155	154	0	\N
134	155	152	1	\N
135	156	155	0	\N
136	156	155	1	\N
137	157	156	0	\N
138	158	157	0	\N
139	159	156	1	\N
140	159	158	0	\N
141	160	159	0	\N
142	161	159	1	\N
143	162	161	0	\N
144	162	161	1	\N
145	162	161	2	\N
146	162	161	3	\N
147	162	161	4	\N
148	162	161	5	\N
149	162	161	6	\N
150	162	161	7	\N
151	162	161	8	\N
152	162	161	9	\N
153	162	161	10	\N
154	162	161	11	\N
155	162	161	12	\N
156	162	161	13	\N
157	162	161	14	\N
158	162	161	15	\N
159	162	161	16	\N
160	162	161	17	\N
161	162	161	18	\N
162	162	161	19	\N
163	162	161	20	\N
164	162	161	21	\N
165	162	161	22	\N
166	162	161	23	\N
167	162	161	24	\N
168	162	161	25	\N
169	162	161	26	\N
170	162	161	27	\N
171	162	161	28	\N
172	162	161	29	\N
173	162	161	30	\N
174	162	161	31	\N
175	162	161	32	\N
176	162	161	33	\N
177	162	161	34	\N
178	162	161	35	\N
179	162	161	36	\N
180	162	161	37	\N
181	162	161	38	\N
182	162	161	39	\N
183	162	161	40	\N
184	162	161	41	\N
185	162	161	42	\N
186	162	161	43	\N
187	162	161	44	\N
188	162	161	45	\N
189	162	161	46	\N
190	162	161	47	\N
191	162	161	48	\N
192	162	161	49	\N
193	162	161	50	\N
194	162	161	51	\N
195	162	161	52	\N
196	162	161	53	\N
197	162	161	54	\N
198	162	161	55	\N
199	162	161	56	\N
200	162	161	57	\N
201	162	161	58	\N
202	162	161	59	\N
203	163	161	93	\N
204	164	161	87	\N
205	165	161	106	\N
206	166	165	0	\N
207	167	161	61	\N
208	168	161	119	\N
209	169	168	0	\N
210	170	161	66	\N
211	171	157	1	\N
212	172	161	104	\N
213	173	160	0	\N
214	174	161	84	\N
215	175	161	60	\N
216	176	138	0	\N
217	177	161	90	\N
218	178	161	62	\N
219	179	161	107	\N
220	180	161	63	\N
221	181	161	64	\N
222	182	161	92	\N
223	183	161	65	\N
224	184	172	0	\N
225	184	164	0	\N
226	184	183	0	\N
227	184	175	0	\N
228	184	167	0	\N
229	184	161	68	\N
230	184	161	70	\N
231	184	161	74	\N
232	184	161	75	\N
233	184	161	76	\N
234	184	161	78	\N
235	184	161	80	\N
236	184	161	83	\N
237	184	161	88	\N
238	184	161	91	\N
239	184	161	94	\N
240	184	161	96	\N
241	184	161	97	\N
242	184	161	98	\N
243	184	161	99	\N
244	184	161	100	\N
245	184	161	101	\N
246	184	161	103	\N
247	184	161	105	\N
248	184	161	108	\N
249	184	161	109	\N
250	184	161	112	\N
251	184	161	113	\N
252	184	161	116	\N
253	184	161	117	\N
254	184	161	118	\N
255	184	174	0	\N
256	184	181	0	\N
257	184	166	0	\N
258	184	178	0	\N
259	185	161	67	\N
260	186	140	0	\N
261	187	169	0	\N
262	188	161	110	\N
263	189	188	0	\N
264	190	189	0	\N
265	190	189	1	\N
266	190	189	2	\N
267	190	189	3	\N
268	190	189	4	\N
269	190	189	5	\N
270	190	189	6	\N
271	190	189	7	\N
272	190	189	8	\N
273	190	189	9	\N
274	190	189	10	\N
275	190	189	11	\N
276	190	189	12	\N
277	190	189	13	\N
278	190	189	14	\N
279	190	189	15	\N
280	190	189	16	\N
281	190	189	17	\N
282	190	189	18	\N
283	190	189	19	\N
284	190	189	20	\N
285	190	189	21	\N
286	190	189	22	\N
287	190	189	23	\N
288	190	189	24	\N
289	190	189	25	\N
290	190	189	26	\N
291	190	189	27	\N
292	190	189	28	\N
293	190	189	29	\N
294	190	189	30	\N
295	190	189	31	\N
296	190	189	32	\N
297	190	189	33	\N
298	190	189	34	\N
299	191	190	0	\N
300	192	161	114	\N
301	193	192	0	\N
303	195	193	1	\N
304	196	161	95	\N
305	197	161	69	\N
306	198	182	0	\N
307	199	184	0	\N
308	200	179	0	\N
309	201	161	71	\N
310	202	198	0	\N
311	203	161	115	\N
312	204	202	1	\N
313	205	201	1	\N
314	205	193	0	\N
315	206	161	81	\N
316	207	177	0	\N
317	208	199	1	\N
318	209	207	1	\N
319	210	170	0	\N
320	211	173	0	\N
321	211	207	0	\N
322	212	161	85	\N
323	213	212	0	\N
324	213	161	82	\N
325	214	210	1	\N
326	215	171	0	\N
327	216	161	72	\N
328	217	161	79	\N
329	218	204	0	\N
330	218	213	0	\N
331	219	208	0	\N
332	219	216	0	\N
333	220	212	1	\N
334	221	209	1	\N
335	222	202	0	\N
336	222	221	0	\N
337	223	219	0	\N
338	223	210	0	\N
339	224	185	0	\N
340	225	161	111	\N
341	226	217	0	\N
342	226	211	1	\N
343	227	204	1	\N
344	228	223	0	\N
345	228	201	0	\N
346	229	224	0	\N
347	229	218	1	\N
348	230	229	0	\N
349	230	209	0	\N
350	231	208	1	\N
351	231	200	0	\N
352	232	230	1	\N
353	232	220	0	\N
354	233	167	1	\N
355	234	206	1	\N
356	235	197	0	\N
357	236	161	73	\N
358	237	203	1	\N
359	238	216	1	\N
360	239	226	1	\N
361	239	161	89	\N
362	240	239	1	\N
363	241	192	1	\N
364	242	196	1	\N
365	243	206	0	\N
366	243	218	0	\N
367	244	221	1	\N
368	245	203	0	\N
369	245	237	0	\N
370	246	188	1	\N
371	247	240	1	\N
372	248	227	0	\N
373	248	238	0	\N
374	249	236	0	\N
375	249	248	1	\N
376	250	247	0	\N
377	250	235	1	\N
378	251	245	0	\N
379	251	229	1	\N
380	252	214	1	\N
381	253	231	1	\N
382	254	228	0	\N
383	254	231	0	\N
384	255	245	1	\N
385	255	252	1	\N
386	256	250	1	\N
387	257	223	1	\N
388	257	199	0	\N
389	258	242	1	\N
390	259	161	102	\N
391	260	220	1	\N
392	261	219	1	\N
393	261	222	0	\N
394	262	230	0	\N
395	262	257	1	\N
396	263	205	1	\N
397	264	254	0	\N
398	264	255	0	\N
399	265	243	0	\N
400	265	211	0	\N
401	266	164	1	\N
402	267	168	1	\N
403	267	264	0	\N
404	268	162	0	\N
405	269	256	0	\N
406	269	215	0	\N
407	270	222	1	\N
408	270	265	0	\N
409	271	270	1	\N
410	271	233	1	\N
411	272	254	1	\N
412	272	239	0	\N
413	273	225	0	\N
414	273	242	0	\N
415	274	235	0	\N
416	274	251	0	\N
417	275	253	0	\N
418	275	271	0	\N
419	276	275	0	\N
420	276	249	1	\N
421	277	213	1	\N
422	278	243	1	\N
423	278	256	1	\N
424	279	263	1	\N
425	280	278	1	\N
426	281	268	0	\N
427	281	241	1	\N
428	282	266	0	\N
429	282	277	0	\N
430	283	234	1	\N
431	284	277	1	\N
432	285	247	1	\N
433	286	163	1	\N
434	287	267	0	\N
435	287	283	0	\N
436	288	236	1	\N
437	289	249	0	\N
438	289	232	1	\N
439	290	240	0	\N
440	290	262	0	\N
441	291	228	1	\N
442	291	265	1	\N
443	292	268	1	\N
444	293	283	1	\N
445	294	267	1	\N
446	294	289	1	\N
447	295	290	0	\N
448	295	294	0	\N
449	296	282	0	\N
450	296	286	0	\N
451	297	270	0	\N
452	297	276	0	\N
453	298	224	1	\N
454	298	273	0	\N
455	299	161	77	\N
456	300	291	0	\N
457	300	291	1	\N
458	300	284	0	\N
459	300	284	1	\N
460	300	282	1	\N
461	300	244	0	\N
462	300	244	1	\N
463	300	233	0	\N
464	300	296	0	\N
465	300	296	1	\N
466	300	237	1	\N
467	300	273	1	\N
468	300	225	1	\N
469	300	253	1	\N
470	300	180	0	\N
471	300	269	0	\N
472	300	269	1	\N
473	300	288	0	\N
474	300	288	1	\N
475	300	271	1	\N
476	300	292	0	\N
477	300	292	1	\N
478	300	266	1	\N
479	300	261	0	\N
480	300	261	1	\N
481	300	290	1	\N
482	300	255	1	\N
483	300	299	0	\N
484	300	299	1	\N
485	300	295	0	\N
486	300	295	1	\N
487	300	275	1	\N
488	300	274	0	\N
489	300	274	1	\N
490	300	226	0	\N
491	300	297	0	\N
492	300	297	1	\N
493	300	259	0	\N
494	300	259	1	\N
495	300	165	1	\N
496	300	276	1	\N
497	300	260	0	\N
498	300	260	1	\N
499	300	298	0	\N
500	300	298	1	\N
501	300	214	0	\N
502	300	217	1	\N
503	300	246	0	\N
504	300	246	1	\N
505	300	286	1	\N
506	300	258	0	\N
507	300	258	1	\N
508	300	263	0	\N
509	300	289	0	\N
510	300	293	0	\N
511	300	293	1	\N
512	300	285	0	\N
513	300	285	1	\N
514	300	272	0	\N
515	300	272	1	\N
516	300	252	0	\N
517	300	294	1	\N
518	300	161	86	\N
519	300	227	1	\N
520	300	250	0	\N
521	300	280	0	\N
522	300	280	1	\N
523	300	278	0	\N
524	300	200	1	\N
525	300	262	1	\N
526	300	248	0	\N
527	300	287	0	\N
528	300	287	1	\N
529	300	281	0	\N
530	300	281	1	\N
531	300	241	0	\N
532	300	205	0	\N
533	300	257	0	\N
534	300	234	0	\N
535	300	251	1	\N
536	300	279	0	\N
537	300	279	1	\N
538	300	238	1	\N
539	300	264	1	\N
540	300	215	1	\N
541	300	232	0	\N
542	301	300	0	\N
543	302	300	7	\N
544	303	302	1	\N
545	304	301	0	\N
546	304	303	0	\N
547	305	302	0	\N
548	305	304	0	\N
549	306	300	3	\N
550	307	300	12	\N
551	308	304	1	\N
552	308	300	4	\N
553	309	306	0	\N
554	309	305	1	\N
555	310	309	0	\N
556	310	308	0	\N
557	311	307	1	\N
558	312	300	10	\N
559	313	300	5	\N
560	314	306	1	\N
561	314	310	1	\N
562	315	314	1	\N
563	316	312	1	\N
564	317	311	1	\N
565	318	300	1	\N
566	319	308	1	\N
567	319	317	0	\N
568	320	305	0	\N
569	320	315	0	\N
570	321	319	0	\N
571	321	311	0	\N
572	322	321	0	\N
573	322	320	0	\N
574	323	319	1	\N
575	323	318	0	\N
576	324	300	11	\N
577	325	323	1	\N
578	326	300	9	\N
579	327	314	0	\N
580	327	312	0	\N
581	328	324	1	\N
582	329	328	0	\N
583	329	326	0	\N
584	330	320	1	\N
585	330	317	1	\N
586	331	309	1	\N
587	331	327	0	\N
588	332	330	0	\N
589	332	331	0	\N
590	333	322	0	\N
591	333	315	1	\N
592	334	300	8	\N
593	334	331	1	\N
594	335	330	1	\N
595	336	334	1	\N
596	337	323	0	\N
597	337	316	0	\N
598	338	336	0	\N
599	338	329	0	\N
600	339	303	1	\N
601	340	321	1	\N
602	340	335	0	\N
603	341	334	0	\N
604	341	338	0	\N
605	342	316	1	\N
606	343	328	1	\N
607	344	333	1	\N
608	345	344	1	\N
609	346	344	0	\N
610	346	310	0	\N
611	347	335	1	\N
612	348	336	1	\N
613	349	300	6	\N
614	350	325	1	\N
615	351	324	0	\N
616	351	350	0	\N
617	352	342	0	\N
618	352	325	0	\N
619	353	350	1	\N
620	354	349	1	\N
621	355	341	0	\N
622	355	340	1	\N
623	356	341	1	\N
624	356	307	0	\N
625	357	300	13	\N
626	358	357	0	\N
627	358	349	0	\N
628	359	326	1	\N
629	359	346	1	\N
630	360	354	1	\N
631	361	358	0	\N
632	361	352	0	\N
633	362	360	1	\N
634	363	332	1	\N
635	363	358	1	\N
636	364	300	2	\N
637	365	343	1	\N
638	366	356	0	\N
639	366	351	0	\N
640	367	333	0	\N
641	367	363	0	\N
642	368	366	0	\N
643	368	361	1	\N
644	369	353	0	\N
645	369	340	0	\N
646	370	360	0	\N
647	370	337	0	\N
648	371	351	1	\N
649	371	367	0	\N
650	372	371	0	\N
651	372	369	1	\N
652	373	371	1	\N
653	373	347	1	\N
654	374	363	1	\N
655	374	359	1	\N
656	375	372	1	\N
657	375	370	1	\N
658	376	356	1	\N
659	376	357	1	\N
660	377	373	1	\N
661	378	345	1	\N
662	379	364	1	\N
663	380	373	0	\N
664	380	368	0	\N
665	381	362	1	\N
666	382	338	1	\N
667	382	369	0	\N
668	383	381	0	\N
669	383	343	0	\N
670	384	313	0	\N
671	384	368	1	\N
672	385	348	0	\N
673	385	322	1	\N
674	386	364	0	\N
675	386	361	0	\N
676	387	339	1	\N
677	388	385	1	\N
678	388	382	1	\N
679	389	337	1	\N
680	389	378	1	\N
681	390	386	0	\N
682	390	387	0	\N
683	391	376	0	\N
684	391	375	1	\N
685	392	391	0	\N
686	392	339	0	\N
687	393	382	0	\N
688	393	375	0	\N
689	394	346	0	\N
690	394	383	0	\N
691	395	355	1	\N
692	395	390	0	\N
693	396	392	1	\N
694	396	353	1	\N
695	397	329	1	\N
696	397	393	0	\N
697	398	372	0	\N
698	398	345	0	\N
699	399	348	1	\N
700	400	393	1	\N
701	400	374	0	\N
702	401	301	1	\N
703	402	130	2	\N
704	403	402	0	\N
705	403	402	1	\N
708	405	403	0	\N
709	405	403	1	\N
710	406	132	0	\N
711	406	130	4	\N
712	407	129	0	\N
713	408	406	0	\N
714	408	407	0	\N
715	409	376	1	\N
716	410	380	0	\N
717	410	384	0	\N
718	410	386	1	\N
719	410	359	0	\N
720	411	374	1	\N
721	412	313	1	\N
\.


--
-- Data for Name: tx_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_metadata (id, key, json, bytes, tx_id) FROM stdin;
1	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "testhandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "testhandle", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": "ipfs://some-hash", "website": "https://cardano.org/", "mediaType": "image/jpeg", "description": "The Handle Standard", "augmentations": []}, "hellohandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "hellohandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "doublehandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "doublehandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a460a664636f7265a5626f67006670726566697861246776657273696f6e006a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6e68616e646c65456e636f64696e67657574662d38646e616d656065696d61676570697066733a2f2f736f6d652d6861736867776562736974657468747470733a2f2f63617264616e6f2e6f72672f6b6465736372697074696f6e735468652048616e646c65205374616e646172646d6175676d656e746174696f6e73806a7465737468616e646c65a864636f7265a5626f67006670726566697861246776657273696f6e006a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6e68616e646c65456e636f64696e67657574662d38646e616d656a7465737468616e646c656566696c657382a3637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35646e616d6569736f6d65206e616d65696d656469615479706569766964656f2f6d7034a363737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e79646e616d6569736f6d65206e616d65696d65646961547970656a617564696f2f6d70656765696d61676570697066733a2f2f736f6d652d6861736867776562736974657468747470733a2f2f63617264616e6f2e6f72672f696d65646961547970656a696d6167652f6a7065676b6465736372697074696f6e735468652048616e646c65205374616e646172646d6175676d656e746174696f6e73806b68656c6c6f68616e646c65a664636f7265a5626f67006670726566697861246776657273696f6e006a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6e68616e646c65456e636f64696e67657574662d38646e616d656b68656c6c6f68616e646c6565696d61676570697066733a2f2f736f6d652d6861736867776562736974657468747470733a2f2f63617264616e6f2e6f72672f6b6465736372697074696f6e735468652048616e646c65205374616e646172646d6175676d656e746174696f6e73806c646f75626c6568616e646c65a664636f7265a5626f67006670726566697861246776657273696f6e006a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6e68616e646c65456e636f64696e67657574662d38646e616d656c646f75626c6568616e646c6565696d61676570697066733a2f2f736f6d652d6861736867776562736974657468747470733a2f2f63617264616e6f2e6f72672f6b6465736372697074696f6e735468652048616e646c65205374616e646172646d6175676d656e746174696f6e7380	131
2	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	133
3	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16568616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65662468616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	134
4	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"sub@handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$sub@handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a1697375624068616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656a247375624068616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	135
5	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"virtual@handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$virtual@handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16d7669727475616c4068616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656e247669727475616c4068616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	136
6	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	141
7	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	142
8	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	144
9	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	146
10	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"NFT-001": {"name": "One", "image": ["ipfs://some_hash1"], "version": "1.0"}, "NFT-002": {"name": "Two", "image": ["ipfs://some_hash2"], "version": "1.0"}, "NFT-files": {"id": "1", "name": "NFT with files", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": ["ipfs://somehash"], "version": "1.0", "mediaType": "image/png", "description": ["NFT with different types of files"]}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a3674e46542d303031a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65634f6e656776657273696f6e63312e30674e46542d303032a365696d6167658171697066733a2f2f736f6d655f6861736832646e616d656354776f6776657273696f6e63312e30694e46542d66696c6573a76b6465736372697074696f6e8178214e4654207769746820646966666572656e74207479706573206f662066696c65736566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e79626964613165696d616765816f697066733a2f2f736f6d6568617368696d656469615479706569696d6167652f706e67646e616d656e4e465420776974682066696c65736776657273696f6e63312e30	149
11	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"4349502d303032352d76312d686578": {"name": "CIP-0025-v1-hex", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1781e343334393530326433303330333233353264373633313264363836353738a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656f4349502d303032352d76312d6865786776657273696f6e63312e30	151
12	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"CIP-0025-v1-utf8": {"name": "CIP-0025-v1-utf8", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1704349502d303032352d76312d75746638a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65704349502d303032352d76312d757466386776657273696f6e63312e30	152
13	721	{"0x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"0x4349502d303032352d7632": {"name": "CIP-0025-v2", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a1581c17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029a14b4349502d303032352d7632a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656b4349502d303032352d76326776657273696f6e63312e30	153
14	123	"1234"	\\xa1187b6431323334	164
15	6862	{"name": "Test Portfolio", "pools": [{"id": "f2e2f054b20b4cacaa5ed0c2b6b82278aa258f84a058d66b9e7167e6", "weight": 1}, {"id": "c66cea9a75934694cca07dc9216180d4e7063365af27c1d67df28e14", "weight": 1}, {"id": "cf5a14bd1e7148b65dbe1d7195421010fd607f6cb4f10d8b3bf622a3", "weight": 1}, {"id": "5148025323825b67898f81f3da8d69d75b0c6bfca7218128036c0855", "weight": 1}, {"id": "7debbb717e5a3a1fde6089eec6f4ae8810dd642aeccf249c89baf543", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783866326532663035346232306234636163616135656430633262366238323237386161323538663834613035386436366239653731363765366677656967687401a2626964783863363663656139613735393334363934636361303764633932313631383064346537303633333635616632376331643637646632386531346677656967687401a2626964783863663561313462643165373134386236356462653164373139353432313031306664363037663663623466313064386233626636323261336677656967687401a2626964783835313438303235333233383235623637383938663831663364613864363964373562306336626663613732313831323830333663303835356677656967687401a2626964783837646562626237313765356133613166646536303839656563366634616538383130646436343261656363663234396338396261663534336677656967687401	189
16	6862	{"name": "Test Portfolio", "pools": [{"id": "f2e2f054b20b4cacaa5ed0c2b6b82278aa258f84a058d66b9e7167e6", "weight": 0}, {"id": "c66cea9a75934694cca07dc9216180d4e7063365af27c1d67df28e14", "weight": 0}, {"id": "cf5a14bd1e7148b65dbe1d7195421010fd607f6cb4f10d8b3bf622a3", "weight": 0}, {"id": "5148025323825b67898f81f3da8d69d75b0c6bfca7218128036c0855", "weight": 0}, {"id": "7debbb717e5a3a1fde6089eec6f4ae8810dd642aeccf249c89baf543", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783866326532663035346232306234636163616135656430633262366238323237386161323538663834613035386436366239653731363765366677656967687400a2626964783863363663656139613735393334363934636361303764633932313631383064346537303633333635616632376331643637646632386531346677656967687400a2626964783863663561313462643165373134386236356462653164373139353432313031306664363037663663623466313064386233626636323261336677656967687400a2626964783835313438303235333233383235623637383938663831663364613864363964373562306336626663613732313831323830333663303835356677656967687400a2626964783837646562626237313765356133613166646536303839656563366634616538383130646436343261656363663234396338396261663534336677656967687401	190
17	6862	{"pools": [{"id": "f2e2f054b20b4cacaa5ed0c2b6b82278aa258f84a058d66b9e7167e6", "weight": 1}]}	\\xa1191acea165706f6f6c7381a2626964783866326532663035346232306234636163616135656430633262366238323237386161323538663834613035386436366239653731363765366677656967687401	196
18	6862	{"name": "Test Portfolio", "pools": [{"id": "f2e2f054b20b4cacaa5ed0c2b6b82278aa258f84a058d66b9e7167e6", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7381a2626964783866326532663035346232306234636163616135656430633262366238323237386161323538663834613035386436366239653731363765366677656967687401	198
19	6862	{"name": "Test Portfolio", "pools": [{"id": "f2e2f054b20b4cacaa5ed0c2b6b82278aa258f84a058d66b9e7167e6", "weight": 1}, {"id": "c66cea9a75934694cca07dc9216180d4e7063365af27c1d67df28e14", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7382a2626964783866326532663035346232306234636163616135656430633262366238323237386161323538663834613035386436366239653731363765366677656967687401a2626964783863363663656139613735393334363934636361303764633932313631383064346537303633333635616632376331643637646632386531346677656967687401	300
20	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	409
21	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16568616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65662468616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	410
22	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"sub@handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$sub@handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a1697375624068616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656a247375624068616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	411
23	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"virtual@handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$virtual@handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16d7669727475616c4068616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656e247669727475616c4068616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	412
\.


--
-- Data for Name: tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_out (id, tx_id, index, address, address_has_script, payment_cred, stake_address_id, value, data_hash, inline_datum_id, reference_script_id) FROM stdin;
1	1	0	5oP9ib6ym3XauetniYeX3dEutTM8zWRTKiHHekgC2JF3ibDsNg6bVtPq8tJwTpt5Kd	f	\N	\N	910909092	\N	\N	\N
2	2	0	5oP9ib6ym3XbAPxfbsT8ztoJZtaUwPgm6WMwsN5BVytS6qw2q3WeLYV4QA8UU4Tv84	f	\N	\N	910909092	\N	\N	\N
3	3	0	5oP9ib6ym3Xbvr8edfsSJNUr54R3y3e6DKYhJN1oFYQMdszkMVkv9s2ToPnX26Hbu9	f	\N	\N	910909092	\N	\N	\N
4	4	0	5oP9ib6ym3XcEF2HGe77ko6hfHCuWpYuy8zqBSPhEEnS8KgHwnHVGsE4Yn1HGjP4No	f	\N	\N	910909092	\N	\N	\N
5	5	0	5oP9ib6ym3XdCJyTaQbpruKB8oUJsxHtt13aovwn4ZgMTkD1AUjKbrJx2PASJJd7qC	f	\N	\N	910909092	\N	\N	\N
6	6	0	5oP9ib6ym3XhK22djUMpfk7dYmTGod3VFXJ6Rt1TvFZYgN8FPwTNLZLjDLuBpXTu1F	f	\N	\N	910909092	\N	\N	\N
7	7	0	5oP9ib6ym3XhgtR9xQjpsA4wLYgTiss5jY6K6agohcbRUti5AmHBHyoDxYdVkDPAW4	f	\N	\N	910909092	\N	\N	\N
8	8	0	5oP9ib6ym3XiEkxyjzDbnVUngBqKATkAJGvQQyDa91TyUbPfbtyEBbFRocSntcZorc	f	\N	\N	910909092	\N	\N	\N
9	9	0	5oP9ib6ym3Xj7fRHBFD58BHHYEPAeFqU9iNCShCs8hShoRm81PvgC6T5Tn1XozA2TB	f	\N	\N	910909092	\N	\N	\N
10	10	0	5oP9ib6ym3XjPU1kn7iypynkUMfS7oELoM61KFtQbJMs2oiNPsLwUh4mebDkPK4NK8	f	\N	\N	910909092	\N	\N	\N
11	11	0	5oP9ib6ym3XjcJ8LNvHDTcmsdyG2b6E4FhLuQdZDMA8YcgJ53QSiNNBTk4dt4xrC8w	f	\N	\N	910909092	\N	\N	\N
12	12	0	addr_test1vzqt0s8ttysxz6j78mygrkxrt08j70833v4572x94yh009caul2ux	f	\\x80b7c0eb5920616a5e3ec881d8c35bcf2f3cf18b2b4f28c5a92ef797	\N	3681818181818181	\N	\N	\N
13	13	0	addr_test1qrnfm6g9aqqthh9cyh02cksvp88wyrflnqaqsu2f7j9dnenkdjzpejuu2j6zleez7wkxhekxfyvzprp72xmmky0akerqcr6q2x	f	\\xe69de905e800bbdcb825deac5a0c09cee20d3f983a087149f48ad9e6	\N	7772727272727272	\N	\N	\N
14	14	0	addr_test1qr3mm5lglw4mfuxwj48wup67qr49yaqk5kajflzt7r8hl4csnvcq3fwum4jusjmv37htn6trkkgya4xjjd4japxktx4qvz0qhv	f	\\xe3bdd3e8fbabb4f0ce954eee075e00ea527416a5bb24fc4bf0cf7fd7	\N	7772727272727272	\N	\N	\N
15	15	0	addr_test1qqks74z7wwf9vhzgpj92sxl8zx90wgm5p2kdmldszt6e4zvfdghaxsagp3t47d8uxe6tx9s293lp4zxmlwr268vxemlqgesxkr	f	\\x2d0f545e7392565c480c8aa81be7118af723740aacddfdb012f59a89	\N	7772727272727272	\N	\N	\N
16	16	0	addr_test1qq4l4rt9qgurt2q22jpeujam7khtq6zhyu8ace5ftjpe5sqr227cu2sprxd5e950clj0atkv4ntk3f84e072sepfeprqecfzqr	f	\\x2bfa8d65023835a80a54839e4bbbf5aeb06857270fdc66895c839a40	\N	7772727272727272	\N	\N	\N
17	17	0	addr_test1vr6czudaegg2pt0tw3ps6ltxf7jd0lceusgmk9ssf8x2cpce90nml	f	\\xf58171bdca10a0adeb74430d7d664fa4d7ff19e411bb161049ccac07	\N	3681818181818181	\N	\N	\N
18	18	0	addr_test1vqp5zy3qydc8nayn94nythx2gqdre3ra7gccrlr7xfctfmcc8cu9p	f	\\x03411220237079f4932d6645dcca401a3cc47df23181fc7e3270b4ef	\N	3681818181818181	\N	\N	\N
19	19	0	addr_test1qqk0pgr4s0c8nv723nzq933r0yuk2fyznquw7qym4ms4njfc6tjd3nf0rq5z698avnsc5x4yjzwhlggj9uazjs3jk8csgd2zg0	f	\\x2cf0a07583f079b3ca8cc402c62379396524829838ef009baee159c9	\N	7772727272727280	\N	\N	\N
20	20	0	addr_test1vz0eq7cc486qyku55akdldeljspcp9n848p7ucqw2gturagan44vw	f	\\x9f907b18a9f4025b94a76cdfb73f9403809667a9c3ee600e5217c1f5	\N	3681818181818181	\N	\N	\N
21	21	0	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	3681818181818181	\N	\N	\N
22	22	0	addr_test1vzvn2pm0rhd8u2m8evmtqdca2s3jctqzrgj33dmfs733x8cpn70aw	f	\\x9935076f1dda7e2b67cb36b0371d54232c2c021a2518b76987a3131f	\N	3681818181818181	\N	\N	\N
23	23	0	addr_test1qpewnv7jwclgrng7hx2gpr6kkn309c3jgq9a29268du0erkse6ms4zeu0ujuxuc79jr9mmp57zd524v9hry02jn92d9s4gktga	f	\\x72e9b3d2763e81cd1eb994808f56b4e2f2e232400bd5155a3b78fc8e	\N	7772727272727272	\N	\N	\N
24	24	0	addr_test1qr8vm3fj9wjk7y3sw22ne5rdhy5fusnv3zyv5yhusn8g6wvln830deqma8jup0mtyfpp05h5ga4f4a4ca7xaj2gk55fstzcwgy	f	\\xcecdc5322ba56f123072953cd06db9289e426c8888ca12fc84ce8d39	\N	7772727272727272	\N	\N	\N
25	25	0	addr_test1vr0u9q4km0k5ttppluy33d3vah27jktp8yaem9hwhchudrs90avtk	f	\\xdfc282b6dbed45ac21ff0918b62cedd5e95961393b9d96eebe2fc68e	\N	3681818181818181	\N	\N	\N
26	26	0	addr_test1qqppyq5u7wgx7tzqpcu3qg9dwpzxmmhk05knrskwmxw5axzx23k8qgpavv536la8fv6dt0rv3nxslkezvg0q3rjgnxjstxhute	f	\\x0212029cf3906f2c400e391020ad70446deef67d2d31c2ced99d4e98	\N	7772727272727272	\N	\N	\N
27	27	0	addr_test1vruntcx07c0utm9wpjssje2pykjzurvj2f04pfrm369uwsslt2kty	f	\\xf935e0cff61fc5ecae0ca109654125a42e0d92525f50a47b8e8bc742	\N	3681818181818190	\N	\N	\N
28	28	0	addr_test1qq0gchx2qzszr3x90gmh8n5j4jv7dcj4n6d7gsy4h92wu6d8e4jruppyu9vvel2zwgymqv7qhaaaxkp96pe8cphdrggqxcuguf	f	\\x1e8c5cca00a021c4c57a3773ce92ac99e6e2559e9be44095b954ee69	\N	7772727272727272	\N	\N	\N
29	29	0	addr_test1vqfw3xt7zcrlvdjpmnynl3xk2rgnyv2vxmsl2cyudww9kgs4lhs6g	f	\\x12e8997e1607f63641dcc93fc4d650d132314c36e1f5609c6b9c5b22	\N	3681818181818181	\N	\N	\N
30	30	0	addr_test1vqrtql78ql0uf6vshyvlmnwhgzalzpzzmx3ree5e77ys73qdnnrq0	f	\\x06b07fc707dfc4e990b919fdcdd740bbf10442d9a23ce699f7890f44	\N	3681818181818181	\N	\N	\N
31	31	0	addr_test1qqf78vrpr4n69ps0wvzdm3yjfs22eyafudu99mhrwd62j2xmqy8yy2a6x0ng04zc6xc3x3tsru32cr7tn3npegeh65wsztpumj	f	\\x13e3b0611d67a2860f7304ddc4924c14ac93a9e37852eee37374a928	\N	7772727272727272	\N	\N	\N
32	32	0	addr_test1vqg26r5rcn4yyutz7lryml3wgyhcfqvmpg4rgz29vkc34tgwzsjvj	f	\\x10ad0e83c4ea427162f7c64dfe2e412f84819b0a2a34094565b11aad	\N	3681818181818181	\N	\N	\N
33	33	0	addr_test1qrecs948hdqjk47f3wgc6xwr6l8jdpc4l7rx4uj7nccrnarhdn6e0cpe8fmpr99pvy00cpypjp9tdnqjhsa5gnpwmkksh78na2	f	\\xf38816a7bb412b57c98b918d19c3d7cf268715ff866af25e9e3039f4	\N	7772727272727272	\N	\N	\N
34	35	0	addr_test1qrxenuqgyfnk2gkh402v8w8yxdtap5qnpphxaxefetlqf0l83g2tgtm27f23slae90q0rsz4u7phyy2pkx075sj30ftqgmyfnc	f	\\xcd99f00822676522d7abd4c3b8e43357d0d013086e6e9b29cafe04bf	23	500000000000	\N	\N	\N
35	35	1	addr_test1vqg26r5rcn4yyutz7lryml3wgyhcfqvmpg4rgz29vkc34tgwzsjvj	f	\\x10ad0e83c4ea427162f7c64dfe2e412f84819b0a2a34094565b11aad	\N	3681318181646520	\N	\N	\N
36	36	0	addr_test1qp8fej3mfxcjj0lc9ps2zw8rzul7tj9nhvhwydp87m5rxpuxz4lne6v32wn0d27lm3lc5maru4qs26np2n883q6p3y7snn3k7l	f	\\x4e9cca3b49b1293ff82860a138e3173fe5c8b3bb2ee23427f6e83307	24	500000000000	\N	\N	\N
37	36	1	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	3681318181646520	\N	\N	\N
38	37	0	addr_test1qp2uljf0wsuhzppus0f62j2apge59juuyuaprp4p7j7vpcgdwk5df34cv2lc9ykw5nvdd7cfuyfyvy3ppp4f5nk6e9cqqa37k6	f	\\x55cfc92f743971043c83d3a5495d0a3342cb9c273a1186a1f4bcc0e1	25	500000000000	\N	\N	\N
39	37	1	addr_test1vzvn2pm0rhd8u2m8evmtqdca2s3jctqzrgj33dmfs733x8cpn70aw	f	\\x9935076f1dda7e2b67cb36b0371d54232c2c021a2518b76987a3131f	\N	3681318181646520	\N	\N	\N
40	38	0	addr_test1qzd84ufc3u75zw6cpzzfhj08utkkmq3qwfrm620lm5p5rsnfhxuwst7zmsf6zneu8jn3nfu9e4yd37ukwulq9epjk0hs0h7l2z	f	\\x9a7af1388f3d413b5808849bc9e7e2ed6d82207247bd29ffdd0341c2	26	500000000000	\N	\N	\N
41	38	1	addr_test1vqfw3xt7zcrlvdjpmnynl3xk2rgnyv2vxmsl2cyudww9kgs4lhs6g	f	\\x12e8997e1607f63641dcc93fc4d650d132314c36e1f5609c6b9c5b22	\N	3681318181646520	\N	\N	\N
42	39	0	addr_test1qzhyqxjyans6m7qglm2u6x4tx9cptgshcgde8a52xvhsndry8lq7t53rd2lrhy46tpz5m94dusrmukln46a0kfrwcg0qwpvj8v	f	\\xae401a44ece1adf808fed5cd1aab317015a217c21b93f68a332f09b4	27	500000000000	\N	\N	\N
43	39	1	addr_test1vruntcx07c0utm9wpjssje2pykjzurvj2f04pfrm369uwsslt2kty	f	\\xf935e0cff61fc5ecae0ca109654125a42e0d92525f50a47b8e8bc742	\N	3681318181646529	\N	\N	\N
44	40	0	addr_test1qrwvx2h3t95pscwpefy4vf0h5q7chnjx8mc66y22e8tvejq3f6vt38s2auq0swyanlmdd8mgg0ng5687srn4yy5lwr9svfcnt9	f	\\xdcc32af159681861c1ca495625f7a03d8bce463ef1ad114ac9d6ccc8	28	500000000000	\N	\N	\N
45	40	1	addr_test1vzqt0s8ttysxz6j78mygrkxrt08j70833v4572x94yh009caul2ux	f	\\x80b7c0eb5920616a5e3ec881d8c35bcf2f3cf18b2b4f28c5a92ef797	\N	3681318181646520	\N	\N	\N
46	41	0	addr_test1qpal7090ma65kc28pvulweeu2749m3ln4e35qyge02vqr9gk62arkgk9dvc0lf6nknkqns52w0eme6zspxw3vjym7mrq0xmwzt	f	\\x7bff3cafdf754b61470b39f7673c57aa5dc7f3ae634011197a980195	29	500000000000	\N	\N	\N
47	41	1	addr_test1vr0u9q4km0k5ttppluy33d3vah27jktp8yaem9hwhchudrs90avtk	f	\\xdfc282b6dbed45ac21ff0918b62cedd5e95961393b9d96eebe2fc68e	\N	3681318181646520	\N	\N	\N
48	42	0	addr_test1qqpgetq3v92wykpc6lmfugr8lzkm3838zjuxcn2kjyd3ruw00gtqm5wlyew6zaxxc8zzf8ktwwylem9z7vrzve0pk3hs42crls	f	\\x028cac116154e25838d7f69e2067f8adb89e2714b86c4d56911b11f1	30	500000000000	\N	\N	\N
49	42	1	addr_test1vr6czudaegg2pt0tw3ps6ltxf7jd0lceusgmk9ssf8x2cpce90nml	f	\\xf58171bdca10a0adeb74430d7d664fa4d7ff19e411bb161049ccac07	\N	3681318181646520	\N	\N	\N
50	43	0	addr_test1qruf9gpk6fdvjj4606nzxllsq3jwfa7wvjfzv9c4shnlx736znwcj842fvqzl2h4jmhfjyymuwd3vk4fcwpsmdkcdtlqu8d9gm	f	\\xf892a036d25ac94aba7ea6237ff00464e4f7ce649226171585e7f37a	31	500000000000	\N	\N	\N
51	43	1	addr_test1vqp5zy3qydc8nayn94nythx2gqdre3ra7gccrlr7xfctfmcc8cu9p	f	\\x03411220237079f4932d6645dcca401a3cc47df23181fc7e3270b4ef	\N	3681318181646520	\N	\N	\N
52	44	0	addr_test1qzc03c3ts9g639wc0zz9338w3pgdaeqemympyv7ynetckee3rtr8yhsd6klwn6lgptm35g5hh3ypmvram99rcqs9t5sq8c7k8e	f	\\xb0f8e22b8151a895d8788458c4ee8850dee419d9361233c49e578b67	32	500000000000	\N	\N	\N
53	44	1	addr_test1vz0eq7cc486qyku55akdldeljspcp9n848p7ucqw2gturagan44vw	f	\\x9f907b18a9f4025b94a76cdfb73f9403809667a9c3ee600e5217c1f5	\N	3681318181646520	\N	\N	\N
54	45	0	addr_test1qr7j0er0ff74sxcvd9wunf04lvg84a3xaj0qppcwn3pdv9c6saxrw84xzwgmd3ytk20372w4ww6xm6rcqkchvphwklqqnujjgn	f	\\xfd27e46f4a7d581b0c695dc9a5f5fb107af626ec9e00870e9c42d617	33	500000000000	\N	\N	\N
55	45	1	addr_test1vqrtql78ql0uf6vshyvlmnwhgzalzpzzmx3ree5e77ys73qdnnrq0	f	\\x06b07fc707dfc4e990b919fdcdd740bbf10442d9a23ce699f7890f44	\N	3681318181646520	\N	\N	\N
56	46	0	addr_test1qrxenuqgyfnk2gkh402v8w8yxdtap5qnpphxaxefetlqf0l83g2tgtm27f23slae90q0rsz4u7phyy2pkx075sj30ftqgmyfnc	f	\\xcd99f00822676522d7abd4c3b8e43357d0d013086e6e9b29cafe04bf	23	499997819319	\N	\N	\N
57	47	0	addr_test1qp8fej3mfxcjj0lc9ps2zw8rzul7tj9nhvhwydp87m5rxpuxz4lne6v32wn0d27lm3lc5maru4qs26np2n883q6p3y7snn3k7l	f	\\x4e9cca3b49b1293ff82860a138e3173fe5c8b3bb2ee23427f6e83307	24	499997819319	\N	\N	\N
58	48	0	addr_test1qp2uljf0wsuhzppus0f62j2apge59juuyuaprp4p7j7vpcgdwk5df34cv2lc9ykw5nvdd7cfuyfyvy3ppp4f5nk6e9cqqa37k6	f	\\x55cfc92f743971043c83d3a5495d0a3342cb9c273a1186a1f4bcc0e1	25	499997819319	\N	\N	\N
59	49	0	addr_test1qzd84ufc3u75zw6cpzzfhj08utkkmq3qwfrm620lm5p5rsnfhxuwst7zmsf6zneu8jn3nfu9e4yd37ukwulq9epjk0hs0h7l2z	f	\\x9a7af1388f3d413b5808849bc9e7e2ed6d82207247bd29ffdd0341c2	26	499997819319	\N	\N	\N
60	50	0	addr_test1qzhyqxjyans6m7qglm2u6x4tx9cptgshcgde8a52xvhsndry8lq7t53rd2lrhy46tpz5m94dusrmukln46a0kfrwcg0qwpvj8v	f	\\xae401a44ece1adf808fed5cd1aab317015a217c21b93f68a332f09b4	27	499997819319	\N	\N	\N
61	51	0	addr_test1qrwvx2h3t95pscwpefy4vf0h5q7chnjx8mc66y22e8tvejq3f6vt38s2auq0swyanlmdd8mgg0ng5687srn4yy5lwr9svfcnt9	f	\\xdcc32af159681861c1ca495625f7a03d8bce463ef1ad114ac9d6ccc8	28	499997819319	\N	\N	\N
62	52	0	addr_test1qpal7090ma65kc28pvulweeu2749m3ln4e35qyge02vqr9gk62arkgk9dvc0lf6nknkqns52w0eme6zspxw3vjym7mrq0xmwzt	f	\\x7bff3cafdf754b61470b39f7673c57aa5dc7f3ae634011197a980195	29	499997819319	\N	\N	\N
63	53	0	addr_test1qqpgetq3v92wykpc6lmfugr8lzkm3838zjuxcn2kjyd3ruw00gtqm5wlyew6zaxxc8zzf8ktwwylem9z7vrzve0pk3hs42crls	f	\\x028cac116154e25838d7f69e2067f8adb89e2714b86c4d56911b11f1	30	499997819319	\N	\N	\N
64	54	0	addr_test1qruf9gpk6fdvjj4606nzxllsq3jwfa7wvjfzv9c4shnlx736znwcj842fvqzl2h4jmhfjyymuwd3vk4fcwpsmdkcdtlqu8d9gm	f	\\xf892a036d25ac94aba7ea6237ff00464e4f7ce649226171585e7f37a	31	499997819319	\N	\N	\N
65	55	0	addr_test1qzc03c3ts9g639wc0zz9338w3pgdaeqemympyv7ynetckee3rtr8yhsd6klwn6lgptm35g5hh3ypmvram99rcqs9t5sq8c7k8e	f	\\xb0f8e22b8151a895d8788458c4ee8850dee419d9361233c49e578b67	32	499997819319	\N	\N	\N
66	56	0	addr_test1qr7j0er0ff74sxcvd9wunf04lvg84a3xaj0qppcwn3pdv9c6saxrw84xzwgmd3ytk20372w4ww6xm6rcqkchvphwklqqnujjgn	f	\\xfd27e46f4a7d581b0c695dc9a5f5fb107af626ec9e00870e9c42d617	33	499997819319	\N	\N	\N
67	57	0	addr_test1qr6czudaegg2pt0tw3ps6ltxf7jd0lceusgmk9ssf8x2cp6alpp7htrejmt6kte6mz953rsqyp6x3j7cfkc3mlf7klxs55xw3u	f	\\xf58171bdca10a0adeb74430d7d664fa4d7ff19e411bb161049ccac07	21	300000000	\N	\N	\N
68	57	1	addr_test1vr6czudaegg2pt0tw3ps6ltxf7jd0lceusgmk9ssf8x2cpce90nml	f	\\xf58171bdca10a0adeb74430d7d664fa4d7ff19e411bb161049ccac07	\N	3681317881475035	\N	\N	\N
69	58	0	addr_test1qqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqnwtpkpzjm3qtdznq7h0lemlwjv5heah203lx24scu0vf30qrvxvqq	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	17	600000000	\N	\N	\N
70	58	1	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	3681317581475035	\N	\N	\N
71	59	0	addr_test1qz0eq7cc486qyku55akdldeljspcp9n848p7ucqw2gturawvh945qrlrl3pzyknjvglkv6u7507qqw7rduafhluut8nsy7n268	f	\\x9f907b18a9f4025b94a76cdfb73f9403809667a9c3ee600e5217c1f5	16	500000000	\N	\N	\N
72	59	1	addr_test1vz0eq7cc486qyku55akdldeljspcp9n848p7ucqw2gturagan44vw	f	\\x9f907b18a9f4025b94a76cdfb73f9403809667a9c3ee600e5217c1f5	\N	3681317681475035	\N	\N	\N
73	60	0	addr_test1qruntcx07c0utm9wpjssje2pykjzurvj2f04pfrm369uwsne3xregan5mk7ppzhq4k5f2v0j6f34nweufv566l07syvs7d9phy	f	\\xf935e0cff61fc5ecae0ca109654125a42e0d92525f50a47b8e8bc742	19	500000000	\N	\N	\N
74	60	1	addr_test1vruntcx07c0utm9wpjssje2pykjzurvj2f04pfrm369uwsslt2kty	f	\\xf935e0cff61fc5ecae0ca109654125a42e0d92525f50a47b8e8bc742	\N	3681317681475044	\N	\N	\N
75	61	0	addr_test1qqp5zy3qydc8nayn94nythx2gqdre3ra7gccrlr7xfctfmc5ujhke563xskc8tef4xn8gkwl7qcvrvjmaq3t4u6s3qvqapn3ha	f	\\x03411220237079f4932d6645dcca401a3cc47df23181fc7e3270b4ef	14	300000000	\N	\N	\N
76	61	1	addr_test1vqp5zy3qydc8nayn94nythx2gqdre3ra7gccrlr7xfctfmcc8cu9p	f	\\x03411220237079f4932d6645dcca401a3cc47df23181fc7e3270b4ef	\N	3681317881475035	\N	\N	\N
77	62	0	addr_test1qzqt0s8ttysxz6j78mygrkxrt08j70833v4572x94yh009a4sm2ck8m4ufwtyf8wgxc4th6gx07406tzj7eg6hsagtdqajsaxj	f	\\x80b7c0eb5920616a5e3ec881d8c35bcf2f3cf18b2b4f28c5a92ef797	12	500000000	\N	\N	\N
78	62	1	addr_test1vzqt0s8ttysxz6j78mygrkxrt08j70833v4572x94yh009caul2ux	f	\\x80b7c0eb5920616a5e3ec881d8c35bcf2f3cf18b2b4f28c5a92ef797	\N	3681317681475035	\N	\N	\N
79	63	0	addr_test1qqrtql78ql0uf6vshyvlmnwhgzalzpzzmx3ree5e77ys739e2whh8qqcgehc80stpxtz8ky2npkpk3p6yl8xlqluhj3q3ejnhu	f	\\x06b07fc707dfc4e990b919fdcdd740bbf10442d9a23ce699f7890f44	18	500000000	\N	\N	\N
80	63	1	addr_test1vqrtql78ql0uf6vshyvlmnwhgzalzpzzmx3ree5e77ys73qdnnrq0	f	\\x06b07fc707dfc4e990b919fdcdd740bbf10442d9a23ce699f7890f44	\N	3681317681475035	\N	\N	\N
81	64	0	addr_test1qzvn2pm0rhd8u2m8evmtqdca2s3jctqzrgj33dmfs733x8746n9a5zdusfzmkr4gsmuv4wvamlnku9q5g63ugq2zqqtqgefequ	f	\\x9935076f1dda7e2b67cb36b0371d54232c2c021a2518b76987a3131f	15	200000000	\N	\N	\N
82	64	1	addr_test1vzvn2pm0rhd8u2m8evmtqdca2s3jctqzrgj33dmfs733x8cpn70aw	f	\\x9935076f1dda7e2b67cb36b0371d54232c2c021a2518b76987a3131f	\N	3681317981475035	\N	\N	\N
83	65	0	addr_test1qr0u9q4km0k5ttppluy33d3vah27jktp8yaem9hwhchudrkp457hs8p826g3q2am9u4devekhqw5dcfcku57qzvlh0dqj4ac99	f	\\xdfc282b6dbed45ac21ff0918b62cedd5e95961393b9d96eebe2fc68e	22	500000000	\N	\N	\N
84	65	1	addr_test1vr0u9q4km0k5ttppluy33d3vah27jktp8yaem9hwhchudrs90avtk	f	\\xdfc282b6dbed45ac21ff0918b62cedd5e95961393b9d96eebe2fc68e	\N	3681317681475035	\N	\N	\N
85	66	0	addr_test1qqg26r5rcn4yyutz7lryml3wgyhcfqvmpg4rgz29vkc34ttu7jmkw2ggt02xlylx6zlvjtdc29ev3kap09z2kwf2h7cqp84vu9	f	\\x10ad0e83c4ea427162f7c64dfe2e412f84819b0a2a34094565b11aad	13	500000000	\N	\N	\N
86	66	1	addr_test1vqg26r5rcn4yyutz7lryml3wgyhcfqvmpg4rgz29vkc34tgwzsjvj	f	\\x10ad0e83c4ea427162f7c64dfe2e412f84819b0a2a34094565b11aad	\N	3681317681475035	\N	\N	\N
87	67	0	addr_test1qqfw3xt7zcrlvdjpmnynl3xk2rgnyv2vxmsl2cyudww9kg5rc6gp6eqe3x6r54qpx50k48cntfxfhhg5e59z0xpt7yrszh7alw	f	\\x12e8997e1607f63641dcc93fc4d650d132314c36e1f5609c6b9c5b22	20	500000000	\N	\N	\N
88	67	1	addr_test1vqfw3xt7zcrlvdjpmnynl3xk2rgnyv2vxmsl2cyudww9kgs4lhs6g	f	\\x12e8997e1607f63641dcc93fc4d650d132314c36e1f5609c6b9c5b22	\N	3681317681475035	\N	\N	\N
89	68	0	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	3681317579304210	\N	\N	\N
90	69	0	addr_test1vruntcx07c0utm9wpjssje2pykjzurvj2f04pfrm369uwsslt2kty	f	\\xf935e0cff61fc5ecae0ca109654125a42e0d92525f50a47b8e8bc742	\N	3681317679304219	\N	\N	\N
91	70	0	addr_test1vz0eq7cc486qyku55akdldeljspcp9n848p7ucqw2gturagan44vw	f	\\x9f907b18a9f4025b94a76cdfb73f9403809667a9c3ee600e5217c1f5	\N	3681317679304210	\N	\N	\N
92	71	0	addr_test1vqp5zy3qydc8nayn94nythx2gqdre3ra7gccrlr7xfctfmcc8cu9p	f	\\x03411220237079f4932d6645dcca401a3cc47df23181fc7e3270b4ef	\N	3681317879304210	\N	\N	\N
93	72	0	addr_test1vzvn2pm0rhd8u2m8evmtqdca2s3jctqzrgj33dmfs733x8cpn70aw	f	\\x9935076f1dda7e2b67cb36b0371d54232c2c021a2518b76987a3131f	\N	3681317979304210	\N	\N	\N
94	73	0	addr_test1vr6czudaegg2pt0tw3ps6ltxf7jd0lceusgmk9ssf8x2cpce90nml	f	\\xf58171bdca10a0adeb74430d7d664fa4d7ff19e411bb161049ccac07	\N	3681317879304210	\N	\N	\N
95	74	0	addr_test1vzqt0s8ttysxz6j78mygrkxrt08j70833v4572x94yh009caul2ux	f	\\x80b7c0eb5920616a5e3ec881d8c35bcf2f3cf18b2b4f28c5a92ef797	\N	3681317679304210	\N	\N	\N
96	75	0	addr_test1vqg26r5rcn4yyutz7lryml3wgyhcfqvmpg4rgz29vkc34tgwzsjvj	f	\\x10ad0e83c4ea427162f7c64dfe2e412f84819b0a2a34094565b11aad	\N	3681317679304210	\N	\N	\N
97	76	0	addr_test1vqrtql78ql0uf6vshyvlmnwhgzalzpzzmx3ree5e77ys73qdnnrq0	f	\\x06b07fc707dfc4e990b919fdcdd740bbf10442d9a23ce699f7890f44	\N	3681317679304210	\N	\N	\N
98	77	0	addr_test1vqfw3xt7zcrlvdjpmnynl3xk2rgnyv2vxmsl2cyudww9kgs4lhs6g	f	\\x12e8997e1607f63641dcc93fc4d650d132314c36e1f5609c6b9c5b22	\N	3681317679304210	\N	\N	\N
99	78	0	addr_test1vr0u9q4km0k5ttppluy33d3vah27jktp8yaem9hwhchudrs90avtk	f	\\xdfc282b6dbed45ac21ff0918b62cedd5e95961393b9d96eebe2fc68e	\N	3681317679304210	\N	\N	\N
100	79	0	addr_test1vr0u9q4km0k5ttppluy33d3vah27jktp8yaem9hwhchudrs90avtk	f	\\xdfc282b6dbed45ac21ff0918b62cedd5e95961393b9d96eebe2fc68e	\N	3681317679132285	\N	\N	\N
101	80	0	addr_test1vqrtql78ql0uf6vshyvlmnwhgzalzpzzmx3ree5e77ys73qdnnrq0	f	\\x06b07fc707dfc4e990b919fdcdd740bbf10442d9a23ce699f7890f44	\N	3681317679132285	\N	\N	\N
102	81	0	addr_test1vz0eq7cc486qyku55akdldeljspcp9n848p7ucqw2gturagan44vw	f	\\x9f907b18a9f4025b94a76cdfb73f9403809667a9c3ee600e5217c1f5	\N	3681317679132285	\N	\N	\N
103	82	0	addr_test1vzvn2pm0rhd8u2m8evmtqdca2s3jctqzrgj33dmfs733x8cpn70aw	f	\\x9935076f1dda7e2b67cb36b0371d54232c2c021a2518b76987a3131f	\N	3681317979132285	\N	\N	\N
104	83	0	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	3681317579132285	\N	\N	\N
105	84	0	addr_test1vqp5zy3qydc8nayn94nythx2gqdre3ra7gccrlr7xfctfmcc8cu9p	f	\\x03411220237079f4932d6645dcca401a3cc47df23181fc7e3270b4ef	\N	3681317879132285	\N	\N	\N
106	85	0	addr_test1vruntcx07c0utm9wpjssje2pykjzurvj2f04pfrm369uwsslt2kty	f	\\xf935e0cff61fc5ecae0ca109654125a42e0d92525f50a47b8e8bc742	\N	3681317679132294	\N	\N	\N
107	86	0	addr_test1vqg26r5rcn4yyutz7lryml3wgyhcfqvmpg4rgz29vkc34tgwzsjvj	f	\\x10ad0e83c4ea427162f7c64dfe2e412f84819b0a2a34094565b11aad	\N	3681317679132285	\N	\N	\N
108	87	0	addr_test1vr6czudaegg2pt0tw3ps6ltxf7jd0lceusgmk9ssf8x2cpce90nml	f	\\xf58171bdca10a0adeb74430d7d664fa4d7ff19e411bb161049ccac07	\N	3681317879132285	\N	\N	\N
109	88	0	addr_test1vzqt0s8ttysxz6j78mygrkxrt08j70833v4572x94yh009caul2ux	f	\\x80b7c0eb5920616a5e3ec881d8c35bcf2f3cf18b2b4f28c5a92ef797	\N	3681317679132285	\N	\N	\N
110	89	0	addr_test1vqfw3xt7zcrlvdjpmnynl3xk2rgnyv2vxmsl2cyudww9kgs4lhs6g	f	\\x12e8997e1607f63641dcc93fc4d650d132314c36e1f5609c6b9c5b22	\N	3681317679132285	\N	\N	\N
111	90	0	addr_test1qp2uljf0wsuhzppus0f62j2apge59juuyuaprp4p7j7vpcgdwk5df34cv2lc9ykw5nvdd7cfuyfyvy3ppp4f5nk6e9cqqa37k6	f	\\x55cfc92f743971043c83d3a5495d0a3342cb9c273a1186a1f4bcc0e1	25	499997646162	\N	\N	\N
112	91	0	addr_test1qzc03c3ts9g639wc0zz9338w3pgdaeqemympyv7ynetckee3rtr8yhsd6klwn6lgptm35g5hh3ypmvram99rcqs9t5sq8c7k8e	f	\\xb0f8e22b8151a895d8788458c4ee8850dee419d9361233c49e578b67	32	499997646162	\N	\N	\N
113	92	0	addr_test1qr7j0er0ff74sxcvd9wunf04lvg84a3xaj0qppcwn3pdv9c6saxrw84xzwgmd3ytk20372w4ww6xm6rcqkchvphwklqqnujjgn	f	\\xfd27e46f4a7d581b0c695dc9a5f5fb107af626ec9e00870e9c42d617	33	499997646162	\N	\N	\N
114	93	0	addr_test1qrxenuqgyfnk2gkh402v8w8yxdtap5qnpphxaxefetlqf0l83g2tgtm27f23slae90q0rsz4u7phyy2pkx075sj30ftqgmyfnc	f	\\xcd99f00822676522d7abd4c3b8e43357d0d013086e6e9b29cafe04bf	23	499997646162	\N	\N	\N
115	94	0	addr_test1qpal7090ma65kc28pvulweeu2749m3ln4e35qyge02vqr9gk62arkgk9dvc0lf6nknkqns52w0eme6zspxw3vjym7mrq0xmwzt	f	\\x7bff3cafdf754b61470b39f7673c57aa5dc7f3ae634011197a980195	29	499997646162	\N	\N	\N
116	95	0	addr_test1qzhyqxjyans6m7qglm2u6x4tx9cptgshcgde8a52xvhsndry8lq7t53rd2lrhy46tpz5m94dusrmukln46a0kfrwcg0qwpvj8v	f	\\xae401a44ece1adf808fed5cd1aab317015a217c21b93f68a332f09b4	27	499997646162	\N	\N	\N
117	96	0	addr_test1qp8fej3mfxcjj0lc9ps2zw8rzul7tj9nhvhwydp87m5rxpuxz4lne6v32wn0d27lm3lc5maru4qs26np2n883q6p3y7snn3k7l	f	\\x4e9cca3b49b1293ff82860a138e3173fe5c8b3bb2ee23427f6e83307	24	499997646162	\N	\N	\N
118	97	0	addr_test1qrwvx2h3t95pscwpefy4vf0h5q7chnjx8mc66y22e8tvejq3f6vt38s2auq0swyanlmdd8mgg0ng5687srn4yy5lwr9svfcnt9	f	\\xdcc32af159681861c1ca495625f7a03d8bce463ef1ad114ac9d6ccc8	28	499997646162	\N	\N	\N
119	98	0	addr_test1qqpgetq3v92wykpc6lmfugr8lzkm3838zjuxcn2kjyd3ruw00gtqm5wlyew6zaxxc8zzf8ktwwylem9z7vrzve0pk3hs42crls	f	\\x028cac116154e25838d7f69e2067f8adb89e2714b86c4d56911b11f1	30	499997646162	\N	\N	\N
120	99	0	addr_test1qruf9gpk6fdvjj4606nzxllsq3jwfa7wvjfzv9c4shnlx736znwcj842fvqzl2h4jmhfjyymuwd3vk4fcwpsmdkcdtlqu8d9gm	f	\\xf892a036d25ac94aba7ea6237ff00464e4f7ce649226171585e7f37a	31	499997646162	\N	\N	\N
121	100	0	addr_test1qzd84ufc3u75zw6cpzzfhj08utkkmq3qwfrm620lm5p5rsnfhxuwst7zmsf6zneu8jn3nfu9e4yd37ukwulq9epjk0hs0h7l2z	f	\\x9a7af1388f3d413b5808849bc9e7e2ed6d82207247bd29ffdd0341c2	26	499997646162	\N	\N	\N
122	101	0	addr_test1qr7j0er0ff74sxcvd9wunf04lvg84a3xaj0qppcwn3pdv9c6saxrw84xzwgmd3ytk20372w4ww6xm6rcqkchvphwklqqnujjgn	f	\\xfd27e46f4a7d581b0c695dc9a5f5fb107af626ec9e00870e9c42d617	33	499997461565	\N	\N	\N
123	102	0	addr_test1qrxenuqgyfnk2gkh402v8w8yxdtap5qnpphxaxefetlqf0l83g2tgtm27f23slae90q0rsz4u7phyy2pkx075sj30ftqgmyfnc	f	\\xcd99f00822676522d7abd4c3b8e43357d0d013086e6e9b29cafe04bf	23	499997461609	\N	\N	\N
124	103	0	addr_test1qpal7090ma65kc28pvulweeu2749m3ln4e35qyge02vqr9gk62arkgk9dvc0lf6nknkqns52w0eme6zspxw3vjym7mrq0xmwzt	f	\\x7bff3cafdf754b61470b39f7673c57aa5dc7f3ae634011197a980195	29	499997461609	\N	\N	\N
125	104	0	addr_test1qp2uljf0wsuhzppus0f62j2apge59juuyuaprp4p7j7vpcgdwk5df34cv2lc9ykw5nvdd7cfuyfyvy3ppp4f5nk6e9cqqa37k6	f	\\x55cfc92f743971043c83d3a5495d0a3342cb9c273a1186a1f4bcc0e1	25	499997461609	\N	\N	\N
126	105	0	addr_test1qzc03c3ts9g639wc0zz9338w3pgdaeqemympyv7ynetckee3rtr8yhsd6klwn6lgptm35g5hh3ypmvram99rcqs9t5sq8c7k8e	f	\\xb0f8e22b8151a895d8788458c4ee8850dee419d9361233c49e578b67	32	499997461565	\N	\N	\N
127	106	0	addr_test1qzhyqxjyans6m7qglm2u6x4tx9cptgshcgde8a52xvhsndry8lq7t53rd2lrhy46tpz5m94dusrmukln46a0kfrwcg0qwpvj8v	f	\\xae401a44ece1adf808fed5cd1aab317015a217c21b93f68a332f09b4	27	499997461609	\N	\N	\N
128	107	0	addr_test1qqpgetq3v92wykpc6lmfugr8lzkm3838zjuxcn2kjyd3ruw00gtqm5wlyew6zaxxc8zzf8ktwwylem9z7vrzve0pk3hs42crls	f	\\x028cac116154e25838d7f69e2067f8adb89e2714b86c4d56911b11f1	30	499997464381	\N	\N	\N
129	108	0	addr_test1qruf9gpk6fdvjj4606nzxllsq3jwfa7wvjfzv9c4shnlx736znwcj842fvqzl2h4jmhfjyymuwd3vk4fcwpsmdkcdtlqu8d9gm	f	\\xf892a036d25ac94aba7ea6237ff00464e4f7ce649226171585e7f37a	31	499997464381	\N	\N	\N
130	109	0	addr_test1qrwvx2h3t95pscwpefy4vf0h5q7chnjx8mc66y22e8tvejq3f6vt38s2auq0swyanlmdd8mgg0ng5687srn4yy5lwr9svfcnt9	f	\\xdcc32af159681861c1ca495625f7a03d8bce463ef1ad114ac9d6ccc8	28	499997461609	\N	\N	\N
131	110	0	addr_test1qp8fej3mfxcjj0lc9ps2zw8rzul7tj9nhvhwydp87m5rxpuxz4lne6v32wn0d27lm3lc5maru4qs26np2n883q6p3y7snn3k7l	f	\\x4e9cca3b49b1293ff82860a138e3173fe5c8b3bb2ee23427f6e83307	24	499997464381	\N	\N	\N
132	111	0	addr_test1qzd84ufc3u75zw6cpzzfhj08utkkmq3qwfrm620lm5p5rsnfhxuwst7zmsf6zneu8jn3nfu9e4yd37ukwulq9epjk0hs0h7l2z	f	\\x9a7af1388f3d413b5808849bc9e7e2ed6d82207247bd29ffdd0341c2	26	499997461609	\N	\N	\N
133	112	0	addr_test1qr7j0er0ff74sxcvd9wunf04lvg84a3xaj0qppcwn3pdv9c6saxrw84xzwgmd3ytk20372w4ww6xm6rcqkchvphwklqqnujjgn	f	\\xfd27e46f4a7d581b0c695dc9a5f5fb107af626ec9e00870e9c42d617	33	499997288408	\N	\N	\N
134	113	0	addr_test1qzc03c3ts9g639wc0zz9338w3pgdaeqemympyv7ynetckee3rtr8yhsd6klwn6lgptm35g5hh3ypmvram99rcqs9t5sq8c7k8e	f	\\xb0f8e22b8151a895d8788458c4ee8850dee419d9361233c49e578b67	32	499997288408	\N	\N	\N
135	114	0	addr_test1qqpgetq3v92wykpc6lmfugr8lzkm3838zjuxcn2kjyd3ruw00gtqm5wlyew6zaxxc8zzf8ktwwylem9z7vrzve0pk3hs42crls	f	\\x028cac116154e25838d7f69e2067f8adb89e2714b86c4d56911b11f1	30	499997291224	\N	\N	\N
136	115	0	addr_test1qruf9gpk6fdvjj4606nzxllsq3jwfa7wvjfzv9c4shnlx736znwcj842fvqzl2h4jmhfjyymuwd3vk4fcwpsmdkcdtlqu8d9gm	f	\\xf892a036d25ac94aba7ea6237ff00464e4f7ce649226171585e7f37a	31	499997291224	\N	\N	\N
137	116	0	addr_test1vqp5zy3qydc8nayn94nythx2gqdre3ra7gccrlr7xfctfmcc8cu9p	f	\\x03411220237079f4932d6645dcca401a3cc47df23181fc7e3270b4ef	\N	3681317878957280	\N	\N	\N
138	117	0	addr_test1vqrtql78ql0uf6vshyvlmnwhgzalzpzzmx3ree5e77ys73qdnnrq0	f	\\x06b07fc707dfc4e990b919fdcdd740bbf10442d9a23ce699f7890f44	\N	3681317678957280	\N	\N	\N
139	118	0	addr_test1vz0eq7cc486qyku55akdldeljspcp9n848p7ucqw2gturagan44vw	f	\\x9f907b18a9f4025b94a76cdfb73f9403809667a9c3ee600e5217c1f5	\N	3681317678957280	\N	\N	\N
140	119	0	addr_test1vr6czudaegg2pt0tw3ps6ltxf7jd0lceusgmk9ssf8x2cpce90nml	f	\\xf58171bdca10a0adeb74430d7d664fa4d7ff19e411bb161049ccac07	\N	3681317878957280	\N	\N	\N
141	120	0	addr_test1wpnlxv2xv9a9ucvnvzqakwepzl9ltx7jzgm53av2e9ncv4sysemm8	t	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	\N	100000000	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	\N	\N
142	120	1	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	3681317478960536	\N	\N	\N
143	121	0	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	99823938	\N	\N	\N
144	122	0	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	100000000	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	2	\N
145	122	1	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	3681317378789843	\N	\N	\N
146	123	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	2
147	123	1	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	3681317278614838	\N	\N	\N
148	124	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	3
149	124	1	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	3681317178442429	\N	\N	\N
150	125	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	1
151	125	1	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	3681317078271164	\N	\N	\N
152	126	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	4
153	126	1	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	3681316978003671	\N	\N	\N
154	127	0	addr_test1wzem0yuxjqyrmzvrsr8xfqhumyy555ngyjxw7wrg2pav90q8cagu2	t	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	\N	100000000	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	3	\N
155	127	1	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	3681316877832934	\N	\N	\N
156	128	0	addr_test1vqn3tvm23gv4g0sfrjey8d05fh5exftlzsaqz9tgmkszqngpwyah4	f	\\x2715b36a8a19543e091cb243b5f44de993257f143a011568dda0204d	\N	3681316977500615	\N	\N	\N
157	129	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	34	10000000	\N	\N	\N
158	129	1	addr_test1vqg26r5rcn4yyutz7lryml3wgyhcfqvmpg4rgz29vkc34tgwzsjvj	f	\\x10ad0e83c4ea427162f7c64dfe2e412f84819b0a2a34094565b11aad	\N	3681317668951692	\N	\N	\N
159	130	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000000000	\N	\N	\N
160	130	1	addr_test1qrml5hwl9s7ydm2djyup95ud6s74skkl4zzf8zk657s8thgm78sn3uhch64ujc7ffnpga68dfdqhg3sp7tk6759jrm7spy03k9	f	\\xf7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd	36	5000000000000	\N	\N	\N
161	130	2	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	37	5000000000000	\N	\N	\N
162	130	3	addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k	f	\\x594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0	38	5000000000000	\N	\N	\N
163	130	4	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	34	5000000000000	\N	\N	\N
164	130	5	addr_test1vzvn2pm0rhd8u2m8evmtqdca2s3jctqzrgj33dmfs733x8cpn70aw	f	\\x9935076f1dda7e2b67cb36b0371d54232c2c021a2518b76987a3131f	\N	3656317978948480	\N	\N	\N
165	131	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	34	10000000	\N	\N	\N
166	131	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4999989762911	\N	\N	\N
167	132	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	34	10000000	\\x81cb2989cbf6c49840511d8d3451ee44f58dde2c074fc749d05deb51eeb33741	4	\N
168	132	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4999979573342	\N	\N	\N
169	133	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	5	\N
170	133	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4999969338497	\N	\N	\N
171	134	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\\xff1a404ece117cc4482d26b072e30b5a6b3cd055a22debda3f90d704957e273a	6	\N
172	134	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4999959116368	\N	\N	\N
173	135	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\\x29294f077464c36e67b304ad22547fb3dfa946623b0b2cbae8acea7fb299353c	7	\N
174	135	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4999948893403	\N	\N	\N
175	136	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	9807263	\N	\N	\N
176	137	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	39	20000000	\N	\N	\N
177	137	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4999938525397	\N	\N	\N
178	138	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	39	20000000	\N	\N	\N
179	138	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4999938349248	\N	\N	\N
180	139	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4999938173187	\N	\N	\N
181	140	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	39	19826843	\N	\N	\N
182	141	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\N	\N	\N
183	141	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4999927980362	\N	\N	\N
184	142	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\N	\N	\N
185	142	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4999917787537	\N	\N	\N
186	143	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	19825259	\N	\N	\N
187	144	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\N	\N	\N
188	144	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4999907594712	\N	\N	\N
189	145	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	9826843	\N	\N	\N
190	146	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\N	\N	\N
191	146	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	9632610	\N	\N	\N
192	147	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	9824995	\N	\N	\N
193	148	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	9651838	\N	\N	\N
194	149	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\N	\N	\N
195	149	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	9079039	\N	\N	\N
196	150	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\N	\N	\N
197	150	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4999907414471	\N	\N	\N
198	151	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\N	\N	\N
199	151	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4999897224946	\N	\N	\N
200	152	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\N	\N	\N
201	152	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	8890966	\N	\N	\N
202	153	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\N	\N	\N
203	153	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	9638638	\N	\N	\N
204	154	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4999926682771	\N	\N	\N
205	155	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	2999961344242	\N	\N	\N
206	155	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	1999974059330	\N	\N	\N
207	156	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	2999961344242	\N	\N	\N
208	156	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	1999973889165	\N	\N	\N
209	157	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	3000000	\N	\N	\N
210	157	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	2999958160393	\N	\N	\N
211	158	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	2820947	\N	\N	\N
212	159	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	3000000	\N	\N	\N
213	159	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	1999973530971	\N	\N	\N
214	160	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	2827019	\N	\N	\N
215	161	0	addr_test1qpd3u500n5lp29d3xylx0n7wg8vl5jzv35sa6pul4ysemggxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s8ttn89	f	\\x5b1e51ef9d3e1515b1313e67cfce41d9fa484c8d21dd079fa9219da1	40	3000000	\N	\N	\N
216	161	1	addr_test1qz7e64eypmjypy32uw86nzm6t6ly4nnmdpumf3ewrs88r5cxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sda6yr4	f	\\xbd9d57240ee440922ae38fa98b7a5ebe4ace7b6879b4c72e1c0e71d3	40	3000000	\N	\N	\N
217	161	2	addr_test1qzkvc96rp4qjyp9aawn9kz5qk5xzgdj2af3f83djdh0gu2sxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sy7rz9m	f	\\xaccc17430d412204bdeba65b0a80b50c24364aea6293c5b26dde8e2a	40	3000000	\N	\N	\N
218	161	3	addr_test1qpeapf9f7vh6fspnvr3nqla4v7378rpkdkluwrd6rk2qacgxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sqnrt44	f	\\x73d0a4a9f32fa4c03360e3307fb567a3e38c366dbfc70dba1d940ee1	40	3000000	\N	\N	\N
219	161	4	addr_test1qzlwpfur36qxc5k0tjcc3s5t5wjunccelvvdna3jrlnerrgxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sx4p8t0	f	\\xbee0a7838e806c52cf5cb188c28ba3a5c9e319fb18d9f6321fe7918d	40	3000000	\N	\N	\N
220	161	5	addr_test1qqg9dp53wh7eyegw74e4r8p962jh7nw3e8lp4lycljdlemcxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s9hkhft	f	\\x1056869175fd92650ef573519c25d2a57f4dd1c9fe1afc98fc9bfcef	40	3000000	\N	\N	\N
221	161	6	addr_test1qrrya38n926c70c69jg852hyj8pzd7x0muusj36l8e793vgxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sq02rf5	f	\\xc64ec4f32ab58f3f1a2c907a2ae491c226f8cfdf3909475f3e7c58b1	40	3000000	\N	\N	\N
222	161	7	addr_test1qzf6g2d5u2pmhzjah0h8v798g7ett9cmmrz4d8qwphcytycxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sx3nl3e	f	\\x93a429b4e283bb8a5dbbee7678a747b2b5971bd8c5569c0e0df04593	40	3000000	\N	\N	\N
223	161	8	addr_test1qp76r5sarvwu37emxxtlsqkxts3awzy24es3q9d3tedu4mcxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sv878af	f	\\x7da1d21d1b1dc8fb3b3197f802c65c23d7088aae611015b15e5bcaef	40	3000000	\N	\N	\N
224	161	9	addr_test1qq6pcqfj0eupehyln3drlx4cg387jeckzwu9j3l747rjdrgxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s7340cv	f	\\x341c01327e781cdc9f9c5a3f9ab8444fe9671613b85947feaf87268d	40	3000000	\N	\N	\N
225	161	10	addr_test1qzum98pdzu85lq6p3ce80lx5wag7z3q4yqjlgjrhwgjv2fsxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s7zet88	f	\\xb9b29c2d170f4f83418e3277fcd47751e144152025f448777224c526	40	3000000	\N	\N	\N
226	161	11	addr_test1qqnqv22k3cfpxzp3sd3dqgtdp7kywkk2dtkwev79lh4ztsgxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s8neypa	f	\\x260629568e121308318362d0216d0fac475aca6aececb3c5fdea25c1	40	3000000	\N	\N	\N
227	161	12	addr_test1qpmg7lkergtylajeyxxpgtlq54hsdfkcw99sxwd7hemnndsxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8srl33n8	f	\\x768f7ed91a164ff659218c142fe0a56f06a6d8714b0339bebe7739b6	40	3000000	\N	\N	\N
228	161	13	addr_test1qqgcxdp3xrcyfu0j69thsaphfeaz98fjpax23mc7hsc3e0gxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sxu8x68	f	\\x1183343130f044f1f2d1577874374e7a229d320f4ca8ef1ebc311cbd	40	3000000	\N	\N	\N
229	161	14	addr_test1qz02h3vf9wvttzgzukjh8as6q3a0jn3ja66qpkd48mzhpuqxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sy0zlrx	f	\\x9eabc5892b98b58902e5a573f61a047af94e32eeb400d9b53ec570f0	40	3000000	\N	\N	\N
230	161	15	addr_test1qpvwwz99cezr6ry5e2ghxvhhzzv59kmquy3znf7f5kudrkgxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8swgxnl6	f	\\x58e708a5c6443d0c94ca917332f7109942db60e12229a7c9a5b8d1d9	40	3000000	\N	\N	\N
231	161	16	addr_test1qp7t45va2zx4yu3mxf663gc7dqgntj70f6jvt3fxvk8grpcxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sqtcl7x	f	\\x7cbad19d508d52723b3275a8a31e681135cbcf4ea4c5c526658e8187	40	3000000	\N	\N	\N
232	161	17	addr_test1qrqs409wdfcrkmj0kj3a8uhys3jlrc4s87zv5695q63v85cxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8skvzf7n	f	\\xc10abcae6a703b6e4fb4a3d3f2e48465f1e2b03f84ca68b406a2c3d3	40	3000000	\N	\N	\N
233	161	18	addr_test1qrz57vdle9gw60ke9lvz25wclerfy5xulmh2d3ga0xuvvzcxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sj2rkq3	f	\\xc54f31bfc950ed3ed92fd82551d8fe469250dcfeeea6c51d79b8c60b	40	3000000	\N	\N	\N
234	161	19	addr_test1qpl9lxy4snrwxdxk3u5gv8f9twpy75fuun3k3mvrelphgncxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sfnxumt	f	\\x7e5f989584c6e334d68f28861d255b824f513ce4e368ed83cfc3744f	40	3000000	\N	\N	\N
235	161	20	addr_test1qqslvzpdcry3drywmpsn3g79tzgwpxetcu0sf25zcdr9wkgxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8swmf2uq	f	\\x21f6082dc0c9168c8ed86138a3c55890e09b2bc71f04aa82c3465759	40	3000000	\N	\N	\N
236	161	21	addr_test1qp67thvqpdjf62hupjn832g639fd38z5xja4zy8xlr5qy9cxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sf5qygp	f	\\x75e5dd800b649d2afc0ca678a91a8952d89c5434bb5110e6f8e80217	40	3000000	\N	\N	\N
237	161	22	addr_test1qpk9u99ajt6rdc2zmq94cn49yf5mqv05dz4v5kkzs04ta4cxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s3ussg5	f	\\x6c5e14bd92f436e142d80b5c4ea52269b031f468aaca5ac283eabed7	40	3000000	\N	\N	\N
238	161	23	addr_test1qrckp3r5q0tp20f47xwkdnm083xn6muhngg4npywha5xvrcxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sdgcqkx	f	\\xf160c47403d6153d35f19d66cf6f3c4d3d6f979a1159848ebf68660f	40	3000000	\N	\N	\N
239	161	24	addr_test1qzt339u6737wlezplund06h5snmt07f89gphpjes30mrlkgxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8spny4e0	f	\\x9718979af47cefe441ff26d7eaf484f6b7f9272a0370cb308bf63fd9	40	3000000	\N	\N	\N
240	161	25	addr_test1qq9a0nsvyhq44rt6gfs2a9rnju82uvcdhv0s0nxvjh64plsxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8ssyurlk	f	\\x0bd7ce0c25c15a8d7a4260ae9473970eae330dbb1f07cccc95f550fe	40	3000000	\N	\N	\N
241	161	26	addr_test1qrh76g03s4cql8yaeuzp7vw4e7grykvawydn99ye2gtq2ssxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s2y9udk	f	\\xefed21f185700f9c9dcf041f31d5cf9032599d711b32949952160542	40	3000000	\N	\N	\N
242	161	27	addr_test1qrrrakqdcukyuaa5kkdrpzznna8t445p0f2jnuvmtf8taqcxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s8d6u32	f	\\xc63ed80dc72c4e77b4b59a3088539f4ebad6817a5529f19b5a4ebe83	40	3000000	\N	\N	\N
243	161	28	addr_test1qq8hmmzwpqrlwl683trj737luw562htc7yna3p5e9j6znysxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8snlhl07	f	\\x0f7dec4e0807f77f478ac72f47dfe3a9a55d78f127d886992cb42992	40	3000000	\N	\N	\N
244	161	29	addr_test1qr2qhj7cmaelglhrm92vgs3x4xhmfkq3njp0ugnp96q4qscxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s3ut77c	f	\\xd40bcbd8df73f47ee3d954c44226a9afb4d8119c82fe22612e815043	40	3000000	\N	\N	\N
245	161	30	addr_test1qrsyfpjt4t6a2a0wpp5c8wlv0lmhz4q9j7z4q24ux9j9eyqxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sasyjfa	f	\\xe044864baaf5d575ee086983bbec7ff77154059785502abc31645c90	40	3000000	\N	\N	\N
246	161	31	addr_test1qr0ltkzay6k4yjk9hhl6ejjxstpkdwgcwlxg3js35wvjv9gxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8stup9kl	f	\\xdff5d85d26ad524ac5bdffacca4682c366b91877cc88ca11a3992615	40	3000000	\N	\N	\N
247	161	32	addr_test1qqg0wrq00y3vqexrq4geg6h83j0xvfeqpsj703shus79k9cxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8snuaj39	f	\\x10f70c0f7922c064c30551946ae78c9e6627200c25e7c617e43c5b17	40	3000000	\N	\N	\N
248	161	33	addr_test1qqacquveujqc2udt60felhjy4m6xzup823qqhyws38mcgpqxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8srwemyu	f	\\x3b807199e4818571abd3d39fde44aef461702754400b91d089f78404	40	3000000	\N	\N	\N
249	161	34	addr_test1qzfg9509gx22g3j806pmm99q4fmwsu36swmwg96n7dsj0aqxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s5l4x8l	f	\\x9282d1e54194a446477e83bd94a0aa76e8723a83b6e41753f36127f4	40	3000000	\N	\N	\N
250	161	35	addr_test1qzwtgmmcna0a8r2q4pa59yvdtn07kpfslft5k046unxg67qxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8smamfc7	f	\\x9cb46f789f5fd38d40a87b42918d5cdfeb0530fa574b3ebae4cc8d78	40	3000000	\N	\N	\N
251	161	36	addr_test1qzsurzea6ppmk4qwgjd3eaunewgf6gxg86s6fflkk7j9azgxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s9dn56z	f	\\xa1c18b3dd043bb540e449b1cf793cb909d20c83ea1a4a7f6b7a45e89	40	3000000	\N	\N	\N
252	161	37	addr_test1qzukhj7d69nxa8gglm3r8sdappv2yns684p0y42295w80ssxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8scpe2fz	f	\\xb96bcbcdd1666e9d08fee233c1bd0858a24e1a3d42f2554a2d1c77c2	40	3000000	\N	\N	\N
253	161	38	addr_test1qr4ewczppy3dh0m2mrcs3aw5e8hj2y2prfgp9jk7kvk9emqxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s3mv55c	f	\\xeb9760410922dbbf6ad8f108f5d4c9ef2511411a5012cadeb32c5cec	40	3000000	\N	\N	\N
254	161	39	addr_test1qr8at4dzz6zr3kf3jk0l6kspy277nk2s63ev6tlj4d7gvpqxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8slr2fs9	f	\\xcfd5d5a2168438d931959ffd5a0122bde9d950d472cd2ff2ab7c8604	40	3000000	\N	\N	\N
255	161	40	addr_test1qzcjaatvq3w6rkvawe3clg20ryuwr52hjv36v2s769m7pjqxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s7qg2ek	f	\\xb12ef56c045da1d99d76638fa14f1938e1d1579323a62a1ed177e0c8	40	3000000	\N	\N	\N
256	161	41	addr_test1qqxecqxzk3s5tt7n6urgxs6z75mzgkgygltrna5d0320wpsxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s576x05	f	\\x0d9c00c2b46145afd3d706834342f53624590447d639f68d7c54f706	40	3000000	\N	\N	\N
257	161	42	addr_test1qpzkkdksnqcmfcqdssn6dp93khlynuvqce72q0hq228asysxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8skejh6t	f	\\x456b36d09831b4e00d8427a684b1b5fe49f180c67ca03ee0528fd812	40	3000000	\N	\N	\N
258	161	43	addr_test1qrt63yahw88cez8qkqhy756tpwnjeej6zpkt49dwtq0zc4sxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sgfg0xk	f	\\xd7a893b771cf8c88e0b02e4f534b0ba72ce65a106cba95ae581e2c56	40	3000000	\N	\N	\N
259	161	44	addr_test1qqpnhwtwr5c6qghry2sav9eja4htuesqwwl0g5vr9jm0wugxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sxke2u9	f	\\x033bb96e1d31a022e322a1d61732ed6ebe660073bef451832cb6f771	40	3000000	\N	\N	\N
260	161	45	addr_test1qp88rpxp26yca4svd72yvrljnm7qaj7nruktn59vjeu77esxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8snt2chw	f	\\x4e7184c156898ed60c6f94460ff29efc0ecbd31f2cb9d0ac9679ef66	40	3000000	\N	\N	\N
261	161	46	addr_test1qzzy5pukljzmpajam3gl2qjlyvr35sn5fvahrwzc7rrle5sxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8suv3pc2	f	\\x844a0796fc85b0f65ddc51f5025f23071a42744b3b71b858f0c7fcd2	40	3000000	\N	\N	\N
262	161	47	addr_test1qzr3uz9y7tezekts2c82txdymx975evcku2mceaq5xy8w6sxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sae2mnh	f	\\x871e08a4f2f22cd970560ea599a4d98bea6598b715bc67a0a188776a	40	3000000	\N	\N	\N
263	161	48	addr_test1qz8383ppd4qum3kf078328356vzn23f30wu94pv7zwh378qxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sfympme	f	\\x8f13c4216d41cdc6c97f8f151e34d3053545317bb85a859e13af1f1c	40	3000000	\N	\N	\N
264	161	49	addr_test1qp7jhqttcphegmsyswwkvfxe3gm50wz6vvt69hj7x7se8pgxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sveu8z0	f	\\x7d2b816bc06f946e04839d6624d98a3747b85a6317a2de5e37a19385	40	3000000	\N	\N	\N
265	161	50	addr_test1qqaamqggckemdv8h46a2slnuj8866ev2eendz9v2xgtr3rsxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sjrk5kq	f	\\x3bdd8108c5b3b6b0f7aebaa87e7c91cfad658ace66d1158a3216388e	40	3000000	\N	\N	\N
266	161	51	addr_test1qpvwn56l7eq6suzard42pgdl93a6akfgt5uhrw4s5vg6fkgxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8shtq07r	f	\\x58e9d35ff641a8705d1b6aa0a1bf2c7baed9285d3971bab0a311a4d9	40	3000000	\N	\N	\N
267	161	52	addr_test1qzwrvz62dv38pzqqvzkerqm8r537uader2qeyj876dxjhlsxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sl2ya9d	f	\\x9c360b4a6b2270880060ad9183671d23ee75b91a819248fed34d2bfe	40	3000000	\N	\N	\N
268	161	53	addr_test1qrr2gtyfem85vazut2dhch5kjxglqhkfnr5mxg4nxclumdqxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sdk64vl	f	\\xc6a42c89cecf46745c5a9b7c5e969191f05ec998e9b322b3363fcdb4	40	3000000	\N	\N	\N
269	161	54	addr_test1qpvrunwxmx8aq6xjerttmkran9mru5avfxv3r33gz4fvu5sxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sfhr78c	f	\\x583e4dc6d98fd068d2c8d6bdd87d99763e53ac499911c6281552ce52	40	3000000	\N	\N	\N
270	161	55	addr_test1qprkku8ygzrp3ddnvc694uxav8kj83m4lhvf3jg8uhwv08gxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sq00w88	f	\\x476b70e4408618b5b366345af0dd61ed23c775fdd898c907e5dcc79d	40	3000000	\N	\N	\N
271	161	56	addr_test1qzfvzef8d0xhkksemjnnfurz39uuz5exx8x60d8kck65qcgxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sz6l0a5	f	\\x92c165276bcd7b5a19dca734f0628979c1532631cda7b4f6c5b54061	40	3000000	\N	\N	\N
272	161	57	addr_test1qqeccn2vjjxf89vch453jw6w44vh9hzlvxlzp7s8y9l4qesxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8sum8m2x	f	\\x338c4d4c948c939598bd69193b4ead5972dc5f61be20fa07217f5066	40	3000000	\N	\N	\N
273	161	58	addr_test1qzvvlymxn0du0kg5hrpz0acnmmmxvun5hhnzyfhx56rc3wsxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s0japea	f	\\x98cf93669bdbc7d914b8c227f713def6667274bde62226e6a68788ba	40	3000000	\N	\N	\N
274	161	59	addr_test1qzdsk5vq9tctprr23l8kxl6rn270tpznr23z9jg0m2y8lsgxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s8ez4xd	f	\\x9b0b51802af0b08c6a8fcf637f439abcf584531aa222c90fda887fc1	40	3000000	\N	\N	\N
275	161	60	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	38954364058	\N	\N	\N
276	161	61	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
277	161	62	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
278	161	63	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
279	161	64	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
280	161	65	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
281	161	66	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
282	161	67	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
283	161	68	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
284	161	69	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
285	161	70	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
286	161	71	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
287	161	72	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
288	161	73	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
289	161	74	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
290	161	75	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
291	161	76	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
292	161	77	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
293	161	78	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
294	161	79	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
295	161	80	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
296	161	81	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
297	161	82	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
298	161	83	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
299	161	84	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
300	161	85	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
301	161	86	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
302	161	87	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
303	161	88	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
304	161	89	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
305	161	90	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
306	161	91	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
307	161	92	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
308	161	93	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
309	161	94	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
310	161	95	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
311	161	96	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
312	161	97	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
313	161	98	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
314	161	99	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
315	161	100	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
316	161	101	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
317	161	102	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
318	161	103	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
319	161	104	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
320	161	105	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
321	161	106	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
322	161	107	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
323	161	108	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
324	161	109	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
325	161	110	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
326	161	111	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
327	161	112	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
328	161	113	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
329	161	114	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
330	161	115	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
331	161	116	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
332	161	117	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
333	161	118	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
334	161	119	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234553400	\N	\N	\N
335	162	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	178500000	\N	\N	\N
336	162	1	addr_test1qpd3u500n5lp29d3xylx0n7wg8vl5jzv35sa6pul4ysemggxrd7gr7q0k98rv62wm0zz3p0keme8fns694fq34temr8s8ttn89	f	\\x5b1e51ef9d3e1515b1313e67cfce41d9fa484c8d21dd079fa9219da1	40	974447	\N	\N	\N
337	163	0	5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg	f	\N	\N	3000000	\N	\N	\N
338	163	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33231385347	\N	\N	\N
339	164	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	969750	\N	\N	\N
340	164	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33233413353	\N	\N	\N
341	165	0	addr_test1xpsfzlut4nw0m20dys8w6h625knf4lv6cchkwnq28ffg5nmqj9lchtxulk576fqwa4054fdxnt7e4330vaxq5wjj3f8s5r3g68	t	\\x60917f8bacdcfda9ed240eed5f4aa5a69afd9ac62f674c0a3a528a4f	41	10000000	\N	\N	\N
342	165	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33224384951	\N	\N	\N
343	166	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	1000000	\N	\N	\N
344	166	1	addr_test1xpsfzlut4nw0m20dys8w6h625knf4lv6cchkwnq28ffg5nmqj9lchtxulk576fqwa4054fdxnt7e4330vaxq5wjj3f8s5r3g68	t	\\x60917f8bacdcfda9ed240eed5f4aa5a69afd9ac62f674c0a3a528a4f	41	8818439	\N	\N	\N
345	167	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\N	\N	\N
346	167	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33224384951	\N	\N	\N
347	168	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	39	1000000000	\N	\N	\N
348	168	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	32234384687	\N	\N	\N
349	169	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	39	499825523	\N	\N	\N
350	170	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33232379847	\N	\N	\N
351	171	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	2999959988204	\N	\N	\N
352	172	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33232379759	\N	\N	\N
353	173	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4655006	\N	\N	\N
354	174	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33232378439	\N	\N	\N
355	175	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	38956191825	\N	\N	\N
356	176	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	39	19828163	\N	\N	\N
357	177	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33232381167	\N	\N	\N
358	178	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33236381167	\N	\N	\N
359	179	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33232381167	\N	\N	\N
360	180	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234379979	\N	\N	\N
361	181	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33236381167	\N	\N	\N
362	182	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33232381167	\N	\N	\N
363	183	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234378659	\N	\N	\N
364	184	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	469238146517	\N	\N	\N
365	185	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33236381167	\N	\N	\N
366	186	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	39	19651090	\N	\N	\N
367	187	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	39	999653510	\N	\N	\N
368	188	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	42	1000000000	\N	\N	\N
369	188	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	32234384951	\N	\N	\N
370	189	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	42	98675351	\N	\N	\N
371	189	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	43	99000000	\N	\N	\N
372	189	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	44	99000000	\N	\N	\N
373	189	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	45	99000000	\N	\N	\N
374	189	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	99000000	\N	\N	\N
375	189	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	42	49500000	\N	\N	\N
376	189	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	43	49500000	\N	\N	\N
377	189	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	44	49500000	\N	\N	\N
378	189	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	45	49500000	\N	\N	\N
379	189	9	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	49500000	\N	\N	\N
380	189	10	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	42	24750000	\N	\N	\N
381	189	11	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	43	24750000	\N	\N	\N
382	189	12	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	44	24750000	\N	\N	\N
383	189	13	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	45	24750000	\N	\N	\N
384	189	14	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	24750000	\N	\N	\N
385	189	15	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	42	12375000	\N	\N	\N
386	189	16	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	43	12375000	\N	\N	\N
387	189	17	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	44	12375000	\N	\N	\N
388	189	18	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	45	12375000	\N	\N	\N
389	189	19	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	12375000	\N	\N	\N
390	189	20	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	42	6187500	\N	\N	\N
391	189	21	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	43	6187500	\N	\N	\N
392	189	22	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	44	6187500	\N	\N	\N
393	189	23	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	45	6187500	\N	\N	\N
394	189	24	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	6187500	\N	\N	\N
395	189	25	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	42	3093750	\N	\N	\N
396	189	26	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	42	3093750	\N	\N	\N
397	189	27	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	43	3093750	\N	\N	\N
398	189	28	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	43	3093750	\N	\N	\N
399	189	29	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	44	3093750	\N	\N	\N
400	189	30	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	44	3093750	\N	\N	\N
401	189	31	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	45	3093750	\N	\N	\N
402	189	32	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	45	3093750	\N	\N	\N
403	189	33	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	3093750	\N	\N	\N
404	189	34	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	3093750	\N	\N	\N
405	190	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	494576915	\N	\N	\N
406	190	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	247418838	\N	\N	\N
407	190	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	123709419	\N	\N	\N
408	190	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	61854709	\N	\N	\N
409	190	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	30927355	\N	\N	\N
410	190	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	15463677	\N	\N	\N
411	190	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	7731839	\N	\N	\N
412	190	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	3865919	\N	\N	\N
413	190	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	3865919	\N	\N	\N
414	191	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	46	494375158	\N	\N	\N
415	192	0	addr_test1xp6x0zgz48jupq5ccp6qejfrn0ydsd46uscmh38rzrjnzmm5v7ys9209czpf3sr5pnyj8x7gmqmt4ep3h0zwxy89x9hsl2cx27	t	\\x74678902a9e5c08298c0740cc9239bc8d836bae431bbc4e310e5316f	47	10000000	\N	\N	\N
416	192	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33224384951	\N	\N	\N
417	193	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	1000000	\N	\N	\N
418	193	1	addr_test1xp6x0zgz48jupq5ccp6qejfrn0ydsd46uscmh38rzrjnzmm5v7ys9209czpf3sr5pnyj8x7gmqmt4ep3h0zwxy89x9hsl2cx27	t	\\x74678902a9e5c08298c0740cc9239bc8d836bae431bbc4e310e5316f	47	6814039	\N	\N	\N
420	195	0	addr_test1xp6x0zgz48jupq5ccp6qejfrn0ydsd46uscmh38rzrjnzmm5v7ys9209czpf3sr5pnyj8x7gmqmt4ep3h0zwxy89x9hsl2cx27	t	\\x74678902a9e5c08298c0740cc9239bc8d836bae431bbc4e310e5316f	47	8633754	\N	\N	\N
421	196	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	39	1000000	\N	\N	\N
422	196	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33231371003	\N	\N	\N
423	197	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33236381783	\N	\N	\N
424	198	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33230200794	\N	\N	\N
425	199	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
426	199	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	469232978112	\N	\N	\N
427	200	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
428	200	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33227212762	\N	\N	\N
429	201	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
430	201	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33229384951	\N	\N	\N
431	202	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
432	202	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33225032389	\N	\N	\N
433	203	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
434	203	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33229384951	\N	\N	\N
435	204	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
436	204	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33219863984	\N	\N	\N
437	205	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
438	205	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33225214962	\N	\N	\N
439	206	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
440	206	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33229384951	\N	\N	\N
441	207	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
442	207	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33227212762	\N	\N	\N
443	208	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
444	208	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	469227809707	\N	\N	\N
445	209	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
446	209	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33222044357	\N	\N	\N
447	210	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
448	210	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33227211442	\N	\N	\N
449	211	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
450	211	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4485193	\N	\N	\N
451	212	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
452	212	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33229384951	\N	\N	\N
453	213	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
454	213	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33234383367	\N	\N	\N
455	214	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
456	214	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33222043037	\N	\N	\N
457	215	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
458	215	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	2999954819799	\N	\N	\N
459	216	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
460	216	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33229384951	\N	\N	\N
461	217	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
462	217	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33229384951	\N	\N	\N
463	218	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
464	218	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
465	219	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
466	219	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
467	220	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
468	220	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33224216546	\N	\N	\N
469	221	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
470	221	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33216875952	\N	\N	\N
471	222	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
472	222	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
473	223	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
474	223	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
475	224	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
476	224	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33231212762	\N	\N	\N
477	225	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
478	225	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33229384951	\N	\N	\N
479	226	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
480	226	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4315380	\N	\N	\N
481	227	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
482	227	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33214695579	\N	\N	\N
483	228	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
484	228	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
485	229	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
486	229	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4660374	\N	\N	\N
487	230	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
488	230	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
489	231	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
490	231	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	469227639718	\N	\N	\N
491	232	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
492	232	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4660374	\N	\N	\N
493	233	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
494	233	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33219216546	\N	\N	\N
495	234	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
496	234	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33224216546	\N	\N	\N
497	235	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
498	235	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33231213378	\N	\N	\N
499	236	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
500	236	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33229384951	\N	\N	\N
501	237	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
502	237	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33224216546	\N	\N	\N
503	238	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
504	238	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33224216546	\N	\N	\N
505	239	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
506	239	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33233698747	\N	\N	\N
507	240	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
508	240	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33228530342	\N	\N	\N
509	241	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
510	241	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33219216546	\N	\N	\N
511	242	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
512	242	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33226202598	\N	\N	\N
513	243	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
514	243	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
515	244	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
516	244	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33211707547	\N	\N	\N
517	245	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
518	245	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
519	246	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
520	246	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	32229216546	\N	\N	\N
521	247	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
522	247	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33223361937	\N	\N	\N
523	248	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
524	248	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
525	249	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
526	249	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4660374	\N	\N	\N
527	250	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
528	250	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33231043389	\N	\N	\N
529	251	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
530	251	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4490561	\N	\N	\N
531	252	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
532	252	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33216874632	\N	\N	\N
533	253	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
534	253	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	469222471313	\N	\N	\N
535	254	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
536	254	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
537	255	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
538	255	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33216534830	\N	\N	\N
539	256	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
540	256	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33225874984	\N	\N	\N
541	257	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
542	257	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4660374	\N	\N	\N
543	258	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
544	258	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33221034193	\N	\N	\N
545	259	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
546	259	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33229384951	\N	\N	\N
547	260	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
548	260	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33219048141	\N	\N	\N
549	261	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
550	261	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4660374	\N	\N	\N
551	262	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
552	262	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4490561	\N	\N	\N
553	263	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
554	263	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33220046557	\N	\N	\N
555	264	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
556	264	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
557	265	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
558	265	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
559	266	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
560	266	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33228244948	\N	\N	\N
561	267	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
562	267	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	32234214698	\N	\N	\N
563	268	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
564	268	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	173331771	\N	\N	\N
565	269	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
566	269	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
567	270	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
568	270	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4660374	\N	\N	\N
569	271	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
570	271	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33218706931	\N	\N	\N
571	272	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
572	272	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4660374	\N	\N	\N
573	273	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
574	273	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
575	274	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
576	274	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
577	275	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
578	275	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
579	276	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
580	276	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4490561	\N	\N	\N
581	277	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
582	277	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33229214962	\N	\N	\N
583	278	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
584	278	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33225535182	\N	\N	\N
585	279	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
586	279	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33214878152	\N	\N	\N
587	280	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
588	280	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33220366777	\N	\N	\N
589	281	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
590	281	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33219046557	\N	\N	\N
591	282	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
592	282	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
593	283	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
594	283	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33219048141	\N	\N	\N
595	284	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
596	284	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33224046557	\N	\N	\N
597	285	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
598	285	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33218193532	\N	\N	\N
599	286	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
600	286	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33226216942	\N	\N	\N
601	287	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
602	287	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
603	288	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
604	288	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33224216546	\N	\N	\N
605	289	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
606	289	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4490561	\N	\N	\N
607	290	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
608	290	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
609	291	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
610	291	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4490561	\N	\N	\N
611	292	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
612	292	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	168163542	\N	\N	\N
613	293	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
614	293	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33213879736	\N	\N	\N
615	294	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
616	294	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	32233535270	\N	\N	\N
617	295	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
618	295	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
619	296	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
620	296	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
621	297	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
622	297	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	4830187	\N	\N	\N
623	298	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
624	298	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	33231042773	\N	\N	\N
625	299	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
626	299	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	34577123383	\N	\N	\N
627	300	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	1099807823447	\N	\N	\N
628	300	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	1099808180920	\N	\N	\N
629	300	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	549904090460	\N	\N	\N
630	300	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	549904090460	\N	\N	\N
631	300	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	274952045230	\N	\N	\N
632	300	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	274952045230	\N	\N	\N
633	300	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	137476022615	\N	\N	\N
634	300	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	137476022615	\N	\N	\N
635	300	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	68738011308	\N	\N	\N
636	300	9	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	68738011308	\N	\N	\N
637	300	10	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	34369005654	\N	\N	\N
638	300	11	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	34369005654	\N	\N	\N
639	300	12	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	34369005653	\N	\N	\N
640	300	13	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	34369005653	\N	\N	\N
641	301	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
642	301	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	1106919920921	\N	\N	\N
643	302	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
644	302	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	137470854210	\N	\N	\N
645	303	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
646	303	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	137465685805	\N	\N	\N
647	304	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
648	304	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
649	305	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
650	305	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
651	306	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
652	306	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	549898922055	\N	\N	\N
653	307	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
654	307	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	34363837248	\N	\N	\N
655	308	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
656	308	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	274951705428	\N	\N	\N
657	309	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
658	309	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4660374	\N	\N	\N
659	310	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
660	310	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
661	311	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
662	311	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	34358668843	\N	\N	\N
663	312	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
664	312	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	34363837249	\N	\N	\N
665	313	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
666	313	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	274946876825	\N	\N	\N
667	314	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
668	314	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	549898582253	\N	\N	\N
669	315	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
670	315	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	549893413848	\N	\N	\N
671	316	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
672	316	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	34358668844	\N	\N	\N
673	317	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
674	317	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	34353500438	\N	\N	\N
675	318	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
676	318	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	1099803012515	\N	\N	\N
677	319	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
678	319	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	274951535439	\N	\N	\N
679	320	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
680	320	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
681	321	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
682	321	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
683	322	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
684	322	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
685	323	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
686	323	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	274951365450	\N	\N	\N
687	324	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
688	324	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	34363837249	\N	\N	\N
689	325	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
690	325	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	274946197045	\N	\N	\N
691	326	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
692	326	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	68732842903	\N	\N	\N
693	327	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
694	327	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
695	328	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
696	328	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	34358668844	\N	\N	\N
697	329	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
698	329	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
699	330	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
700	330	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	34353160636	\N	\N	\N
701	331	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
702	331	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4490561	\N	\N	\N
703	332	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
704	332	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
705	333	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
706	333	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	549893243859	\N	\N	\N
707	334	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
708	334	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	68737331880	\N	\N	\N
709	335	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
710	335	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	34347992231	\N	\N	\N
711	336	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
712	336	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	68732163475	\N	\N	\N
713	337	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
714	337	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
715	338	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
716	338	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
717	339	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
718	339	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	137460517400	\N	\N	\N
719	340	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
720	340	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4660374	\N	\N	\N
721	341	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
722	341	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
723	342	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
724	342	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	34353500439	\N	\N	\N
725	343	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
726	343	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	34353500439	\N	\N	\N
727	344	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
728	344	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	549888075454	\N	\N	\N
729	345	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
730	345	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	549882907049	\N	\N	\N
731	346	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
732	346	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
733	347	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
734	347	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	34342823826	\N	\N	\N
735	348	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
736	348	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	68726995070	\N	\N	\N
737	349	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
738	349	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	137470854210	\N	\N	\N
739	350	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
740	350	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	274941028640	\N	\N	\N
741	351	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
742	351	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
743	352	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
744	352	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
745	353	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
746	353	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	274935860235	\N	\N	\N
747	354	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
748	354	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	137465685805	\N	\N	\N
749	355	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
750	355	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4490561	\N	\N	\N
751	356	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
752	356	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4660374	\N	\N	\N
753	357	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
754	357	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	34363837248	\N	\N	\N
755	358	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
756	358	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
757	359	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
758	359	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	68732503101	\N	\N	\N
759	360	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
760	360	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	137460517400	\N	\N	\N
761	361	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
762	361	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
763	362	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
764	362	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	137455348995	\N	\N	\N
765	363	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
766	363	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4490561	\N	\N	\N
767	364	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
768	364	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	549898922055	\N	\N	\N
769	365	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
770	365	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	34348332034	\N	\N	\N
771	366	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
772	366	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
773	367	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
774	367	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
775	368	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
776	368	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4660374	\N	\N	\N
777	369	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
778	369	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
779	370	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
780	370	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
781	371	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
782	371	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4660374	\N	\N	\N
783	372	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
784	372	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4660374	\N	\N	\N
785	373	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
786	373	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	34342314211	\N	\N	\N
787	374	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
788	374	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	68731823673	\N	\N	\N
789	375	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
790	375	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4320748	\N	\N	\N
791	376	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
792	376	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	34363327633	\N	\N	\N
793	377	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
794	377	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	34337145806	\N	\N	\N
795	378	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
796	378	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	549877738644	\N	\N	\N
797	379	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
798	379	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	549893753650	\N	\N	\N
799	380	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
800	380	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
801	381	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
802	381	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	137450180590	\N	\N	\N
803	382	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
804	382	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4660374	\N	\N	\N
805	383	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
806	383	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
807	384	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
808	384	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4490561	\N	\N	\N
809	385	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
810	385	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4660374	\N	\N	\N
811	386	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
812	386	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
813	387	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
814	387	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	137455348995	\N	\N	\N
815	388	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
816	388	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4150935	\N	\N	\N
817	389	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
818	389	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	549877398842	\N	\N	\N
819	390	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
820	390	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
821	391	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
822	391	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4150935	\N	\N	\N
823	392	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
824	392	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
825	393	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
826	393	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
827	394	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
828	394	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
829	395	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
830	395	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4320748	\N	\N	\N
831	396	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
832	396	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	274935520433	\N	\N	\N
833	397	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
834	397	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4660374	\N	\N	\N
835	398	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
836	398	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4830187	\N	\N	\N
837	399	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
838	399	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	68721826665	\N	\N	\N
839	400	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
840	400	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	4660374	\N	\N	\N
841	401	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	5000000	\N	\N	\N
842	401	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	1113146675750	\N	\N	\N
843	402	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	37	3000000	\N	\N	\N
844	402	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	37	4999496820111	\N	\N	\N
845	403	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	37	3000000	\N	\N	\N
846	403	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	37	4999494648538	\N	\N	\N
849	405	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	37	3000000	\N	\N	\N
850	405	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	37	4999494471201	\N	\N	\N
851	406	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	34	3000000	\N	\N	\N
852	406	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	34	4999506816591	\N	\N	\N
853	407	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	34	3000000	\N	\N	\N
854	407	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	34	4826447	\N	\N	\N
855	408	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	34	3000000	\N	\N	\N
856	408	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	34	2822839	\N	\N	\N
857	409	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	5	\N
858	409	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	34353092788	\N	\N	\N
859	410	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\\xff1a404ece117cc4482d26b072e30b5a6b3cd055a22debda3f90d704957e273a	6	\N
860	410	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	9603482	\N	\N	\N
861	411	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	35	10000000	\\x29294f077464c36e67b304ad22547fb3dfa946623b0b2cbae8acea7fb299353c	7	\N
862	411	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	68721600708	\N	\N	\N
863	412	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	48	274946685452	\N	\N	\N
\.


--
-- Data for Name: voting_anchor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.voting_anchor (id, url, data_hash, type, block_id) FROM stdin;
1	ipfs://QmQq5hWDNzvDR1ForEktAHrdCQmfSL2u5yctNpzDwoSBu4	\\x23b43bebac48a4acc39e578715aa06635d6d900fa3ea7441dfffd6e43b914f7b	other	3
2	https://testing.this	\\x3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d	drep	309
3	https://testing.this	\\x3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d	gov_action	339
8	https://testing.this	\\x3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d	other	339
\.


--
-- Data for Name: voting_procedure; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.voting_procedure (id, tx_id, index, gov_action_proposal_id, voter_role, drep_voter, pool_voter, vote, voting_anchor_id, committee_voter) FROM stdin;
1	186	0	1	DRep	1	\N	Abstain	8	\N
\.


--
-- Data for Name: withdrawal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.withdrawal (id, addr_id, amount, redeemer_id, tx_id) FROM stdin;
1	35	1347744548	\N	299
2	35	7117272171	\N	301
3	48	1510733132	\N	401
4	35	4721202422	\N	401
\.


--
-- Name: ada_pots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ada_pots_id_seq', 12, true);


--
-- Name: block_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.block_id_seq', 1290, true);


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

SELECT pg_catalog.setval('public.committee_hash_id_seq', 5, true);


--
-- Name: committee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.committee_id_seq', 1, true);


--
-- Name: committee_member_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.committee_member_id_seq', 5, true);


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

SELECT pg_catalog.setval('public.delegation_id_seq', 57, true);


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

SELECT pg_catalog.setval('public.epoch_id_seq', 42, true);


--
-- Name: epoch_param_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_param_id_seq', 13, true);


--
-- Name: epoch_stake_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_stake_id_seq', 498, true);


--
-- Name: epoch_stake_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_stake_progress_id_seq', 15, true);


--
-- Name: epoch_state_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_state_id_seq', 13, true);


--
-- Name: epoch_sync_time_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_sync_time_id_seq', 12, true);


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

SELECT pg_catalog.setval('public.gov_action_proposal_id_seq', 6, true);


--
-- Name: ma_tx_mint_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_mint_id_seq', 50, true);


--
-- Name: ma_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_out_id_seq', 55, true);


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
-- Name: off_chain_vote_author_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_vote_author_id_seq', 1, false);


--
-- Name: off_chain_vote_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_vote_data_id_seq', 1, false);


--
-- Name: off_chain_vote_drep_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_vote_drep_data_id_seq', 1, false);


--
-- Name: off_chain_vote_external_update_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_vote_external_update_id_seq', 1, false);


--
-- Name: off_chain_vote_fetch_error_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_vote_fetch_error_id_seq', 16, true);


--
-- Name: off_chain_vote_gov_action_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_vote_gov_action_data_id_seq', 1, false);


--
-- Name: off_chain_vote_reference_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.off_chain_vote_reference_id_seq', 1, false);


--
-- Name: param_proposal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.param_proposal_id_seq', 1, true);


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
-- Name: pool_stat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_stat_id_seq', 1, false);


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

SELECT pg_catalog.setval('public.reverse_index_id_seq', 1288, true);


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

SELECT pg_catalog.setval('public.slot_leader_id_seq', 1290, true);


--
-- Name: stake_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_address_id_seq', 48, true);


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

SELECT pg_catalog.setval('public.treasury_withdrawal_id_seq', 1, true);


--
-- Name: tx_cbor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_cbor_id_seq', 1, false);


--
-- Name: tx_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_id_seq', 412, true);


--
-- Name: tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_in_id_seq', 721, true);


--
-- Name: tx_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_metadata_id_seq', 23, true);


--
-- Name: tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_out_id_seq', 863, true);


--
-- Name: voting_anchor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.voting_anchor_id_seq', 10, true);


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
-- Name: committee_member committee_member_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.committee_member
    ADD CONSTRAINT committee_member_pkey PRIMARY KEY (id);


--
-- Name: committee committee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.committee
    ADD CONSTRAINT committee_pkey PRIMARY KEY (id);


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
-- Name: epoch_state epoch_state_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_state
    ADD CONSTRAINT epoch_state_pkey PRIMARY KEY (id);


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
-- Name: off_chain_vote_drep_data off_chain_vote_drep_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_drep_data
    ADD CONSTRAINT off_chain_vote_drep_data_pkey PRIMARY KEY (id);


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
-- Name: off_chain_vote_gov_action_data off_chain_vote_gov_action_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.off_chain_vote_gov_action_data
    ADD CONSTRAINT off_chain_vote_gov_action_data_pkey PRIMARY KEY (id);


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
-- Name: pool_stat pool_stat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_stat
    ADD CONSTRAINT pool_stat_pkey PRIMARY KEY (id);


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
-- Name: tx_cbor tx_cbor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tx_cbor
    ADD CONSTRAINT tx_cbor_pkey PRIMARY KEY (id);


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
-- Name: idx_committee_member_committee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_committee_member_committee_id ON public.committee_member USING btree (committee_id);


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
-- Name: idx_tx_cbor_tx_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tx_cbor_tx_id ON public.tx_cbor USING btree (tx_id);


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
-- Name: block sdk_notify_tip; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER sdk_notify_tip AFTER INSERT ON public.block FOR EACH ROW EXECUTE FUNCTION public.sdk_notify_tip();


--
-- Name: committee_member committee_member_committee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.committee_member
    ADD CONSTRAINT committee_member_committee_id_fkey FOREIGN KEY (committee_id) REFERENCES public.committee(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

