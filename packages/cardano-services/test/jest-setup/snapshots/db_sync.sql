--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5
-- Dumped by pg_dump version 11.5

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
    'plutusV2'
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

SET default_with_oids = false;

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
    coins_per_utxo_size public.lovelace
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
-- Name: param_proposal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.param_proposal (
    id bigint NOT NULL,
    epoch_no public.word31type NOT NULL,
    key public.hash28type NOT NULL,
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
    coins_per_utxo_size public.lovelace
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
    min_ids character varying
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
-- Name: tx; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tx (
    id bigint NOT NULL,
    hash public.hash32type NOT NULL,
    block_id bigint NOT NULL,
    block_index public.word31type NOT NULL,
    out_sum public.lovelace NOT NULL,
    fee public.lovelace NOT NULL,
    deposit bigint NOT NULL,
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
-- Name: delisted_pool id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delisted_pool ALTER COLUMN id SET DEFAULT nextval('public.delisted_pool_id_seq'::regclass);


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
-- Name: epoch_sync_time id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_sync_time ALTER COLUMN id SET DEFAULT nextval('public.epoch_sync_time_id_seq'::regclass);


--
-- Name: extra_key_witness id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extra_key_witness ALTER COLUMN id SET DEFAULT nextval('public.extra_key_witness_id_seq'::regclass);


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
-- Name: withdrawal id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.withdrawal ALTER COLUMN id SET DEFAULT nextval('public.withdrawal_id_seq'::regclass);


--
-- Data for Name: ada_pots; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ada_pots (id, slot_no, epoch_no, treasury, reserves, rewards, utxo, deposits, fees, block_id) FROM stdin;
1	1012	1	0	8999989979999988	0	81000010010290406	0	9709606	101
2	2004	2	88199902755554	8911790086759983	0	81000010006123481	0	4360982	197
3	3002	3	173753088024548	8741539252435679	84697653416292	81000010006123481	0	0	282
4	4004	4	248056171670251	8593676116497689	158257705708579	81000010006123481	0	0	383
5	5011	5	333133565223578	8451596870316345	215259558336596	81000010001837991	0	4285490	486
6	6013	6	416804374668258	8311008184236941	272177439256810	81000009992889125	0	8948866	592
8	7023	7	499914457405514	8168414018271382	331661531433979	81000009992889125	0	0	691
9	8004	8	577514390579092	8035027246586488	387448369945295	81000009975919617	0	16969508	795
10	9009	9	657864664741907	7903661835533956	438463523804520	81000009975919617	0	0	886
11	10016	10	725836156527499	7790293787599668	483852791632016	81000017263824367	0	416450	992
12	11013	11	803739094445140	7663457402089955	532786239640538	81000017263824367	0	0	1099
13	12008	12	880373668466039	7541556358407156	578034912040382	81000035044152863	0	16933560	1201
14	13007	13	955789233743466	7421649136457459	622526585646212	81000035044152863	0	0	1292
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (id, hash, epoch_no, slot_no, epoch_slot_no, block_no, previous_id, slot_leader_id, size, "time", tx_count, proto_major, proto_minor, vrf_key, op_cert, op_cert_counter) FROM stdin;
1	\\x122b3f3e42c2744f30dd975f57a1543f30d5da1e82d7130ca0d96ca6a30714fb	\N	\N	\N	\N	\N	1	0	2023-10-31 17:14:13	11	0	0	\N	\N	\N
2	\\x5368656c6c65792047656e6573697320426c6f636b2048617368200000000000	\N	\N	\N	\N	1	2	0	2023-10-31 17:14:13	23	0	0	\N	\N	\N
3	\\x8fb13fa3c2db2871a0b7229012b269ad3914aa99bc8de4310a900689ccd55aea	0	0	0	0	1	3	4	2023-10-31 17:14:13	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
4	\\x3cb212ccabed9ca308501d2b4c471a38aaf7a0c0ed2767b51ecc5428a514872b	0	2	2	1	3	4	4	2023-10-31 17:14:13.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
5	\\x73613764e53166f72dc70494201b55ba71e2aa3149f15c6a110a8ec7186bf0d0	0	10	10	2	4	5	265	2023-10-31 17:14:15	1	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
6	\\xcf69888aca37e49dd7b758e6f47523730fe7463ab145f15a83d7845a0884c31e	0	15	15	3	5	5	4	2023-10-31 17:14:16	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
7	\\x9c27cbab3dcfeb42b4aa9f30125ce7f23504cb6c7883d41813b1a2029ab68d29	0	26	26	4	6	7	341	2023-10-31 17:14:18.2	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
8	\\x783c241d715e44f796c4bfd8e556bcad852667abbaa59642bde0f2b14adb053b	0	32	32	5	7	8	4	2023-10-31 17:14:19.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
9	\\xa7c6899c578896060f3d57adea5ef48791240d2d38c51a49ccb74a8280375678	0	43	43	6	8	8	371	2023-10-31 17:14:21.6	1	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
10	\\xa87e98cc5cadb6bd83cb43614313c7af060ee4bd1b9b78eb0b97d06238cd7942	0	46	46	7	9	7	4	2023-10-31 17:14:22.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
11	\\xb3a9c0b6887a129fd39fc60f7361556ca2089b4eecd0939756361f614b58b13a	0	60	60	8	10	4	399	2023-10-31 17:14:25	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
12	\\xd9cee74b1a6b68ab44ae23f344477778bf3468dc0e52919ead38e50981f610bd	0	63	63	9	11	12	4	2023-10-31 17:14:25.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
13	\\x5e1c55e6d32b5614debb2b160517c71ee435edeee95dc592b3e65fa710c4abe6	0	64	64	10	12	5	4	2023-10-31 17:14:25.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
14	\\xbe3624b03b3c7d42bc8f14659dfb8f73101642d214df2035232a947cbe8d262d	0	69	69	11	13	14	655	2023-10-31 17:14:26.8	1	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
15	\\x5d17243b0aeb027aaa669079c92fbecdfaef23a4a8cac863cc480376eb1022ac	0	74	74	12	14	15	4	2023-10-31 17:14:27.8	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
16	\\x924a891d8f818aa1fff6a01c74c4549a3053a1942791831d61a5745fe5099ed9	0	75	75	13	15	16	4	2023-10-31 17:14:28	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
17	\\x5394bb4509d34e2ca52bd08e0b3269e56bcde3e7fa936d78aa24f1ce7e50dd65	0	79	79	14	16	16	265	2023-10-31 17:14:28.8	1	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
18	\\x616c31839c180508b9c2fa442fe141022d8202ad05485c26551f7802e3cb990c	0	105	105	15	17	18	341	2023-10-31 17:14:34	1	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
19	\\xa5d3478e466aa63d356f3b5f0650f5760abc569ed0805afabce0238e35973b0d	0	107	107	16	18	18	4	2023-10-31 17:14:34.4	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
20	\\x7d13f83aabfd94757f27bb03ba3aaa40215a618d1cdc322e886b040da4ae9de5	0	120	120	17	19	14	371	2023-10-31 17:14:37	1	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
21	\\xe073ae3520a72172e09e6219568a6608a70874fc90aeaab46e026099ebcb9dd0	0	160	160	18	20	4	399	2023-10-31 17:14:45	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
22	\\x64ef4b96a4b5ae10428e96b5cd4b0bf15e6d667e1b823e1a5e4952026b40ad2b	0	176	176	19	21	5	592	2023-10-31 17:14:48.2	1	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
23	\\x18361b5a9dd3b79a88981109df68affb339ae6ba956e712f3d66c0e6a68e3557	0	195	195	20	22	12	265	2023-10-31 17:14:52	1	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
24	\\x61fe9804fa3a542e874dca22ab5e9bcdcf8e04f40167c6b2c42ce3b980dfe353	0	198	198	21	23	8	4	2023-10-31 17:14:52.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
25	\\xea8334746078d1cc52a900e667c6725ca08f616484e896b22ec3bcf2341212e5	0	201	201	22	24	12	4	2023-10-31 17:14:53.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
26	\\x0341b5eac5660248d4d9f7caa2cf3adff15cdc50062ae69c6b662167be03049b	0	206	206	23	25	18	341	2023-10-31 17:14:54.2	1	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
27	\\xd3b350b908f74ffb480f69cd3fc7acb1ae26275e0f1f0893ee13a8b03999b7d3	0	222	222	24	26	18	371	2023-10-31 17:14:57.4	1	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
28	\\xcbbbf069713389a430972455d888e1fcafb052679be1445101c123dc90b5c787	0	224	224	25	27	3	4	2023-10-31 17:14:57.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
29	\\xbeb2b53476776bdc4e3244f012845b9459a925690c540a3ec4a28973442bcee3	0	229	229	26	28	12	4	2023-10-31 17:14:58.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
30	\\xfca25b4ce54cfb80621f0fe808fb9a01aac0454b13c0a227785ca34864c5f4d9	0	231	231	27	29	3	4	2023-10-31 17:14:59.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
31	\\x86baf558355604b62fc64915667009ef6addcac19a1d8468fbdad4f69196e84a	0	233	233	28	30	15	399	2023-10-31 17:14:59.6	1	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
32	\\x0d01b0c271957af5e69741f2e4df5a140f0957a6d8d19d181e7008967b5f9d44	0	234	234	29	31	14	4	2023-10-31 17:14:59.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
33	\\xd462736dfa9947db19ed80b5e5a504f6758e579987686dd2e9f35b5d95c72a6d	0	244	244	30	32	15	655	2023-10-31 17:15:01.8	1	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
34	\\xd191516d4ea48c1044d14eaeab99a19ccd6c23a146cf3bd0c97c624c0efe3913	0	251	251	31	33	7	4	2023-10-31 17:15:03.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
35	\\xa59ccf834366159d0ad0b7be36001358014a9866438aa84cfd09418a7cff0bca	0	258	258	32	34	5	265	2023-10-31 17:15:04.6	1	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
36	\\x6f2b668aced629a0895ebf6a390eec6e11d1aebeb76631de7f87ab200780fc58	0	268	268	33	35	12	341	2023-10-31 17:15:06.6	1	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
37	\\xd99d19b9e3aa4bd305ae83008b3981d3d15edd04ce72594674bf3a2f263da7fa	0	274	274	34	36	3	4	2023-10-31 17:15:07.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
38	\\xb114ceb474dfd7e5ddb25f51c1f6174a3415b81119c7f7846f56e7810564cd01	0	276	276	35	37	3	371	2023-10-31 17:15:08.2	1	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
39	\\xc59348f3e5d612f51e6aa9e9466dad8aa85ec2558bcae6ab0c201a39271d3198	0	297	297	36	38	39	399	2023-10-31 17:15:12.4	1	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
40	\\xe13e2ee3ab2a1aab746088ee8f9fdce119f35c6de8701339b58a2a18a02531cd	0	300	300	37	39	4	4	2023-10-31 17:15:13	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
41	\\xe0b62859d419f756abb746495942100c61fea4e82f5c0ba6e25910337e3f1a4a	0	302	302	38	40	39	4	2023-10-31 17:15:13.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
42	\\x3213ba4210d504038ec331ea9f6a3ea883f84023e47dd57f3e9dffcdb56fe953	0	305	305	39	41	18	4	2023-10-31 17:15:14	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
43	\\x521c35ac0ca723ddeba65f7c9620f151812d417ada3758083a957b735b93a505	0	332	332	40	42	4	655	2023-10-31 17:15:19.4	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
44	\\x7e0fdbcb3b8313f71fd59cd8ae97597e607dcad0e3457fefbcbe84c436be8578	0	341	341	41	43	4	265	2023-10-31 17:15:21.2	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
45	\\x2509947d177bef06d58b1e67489b7c47e92496bd0302baeb2dbffa583a4bd6e3	0	360	360	42	44	3	341	2023-10-31 17:15:25	1	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
46	\\x7d05708a90747f41716070fb45e6788357a7fac87a42000291bf26598206200e	0	364	364	43	45	3	4	2023-10-31 17:15:25.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
47	\\xba5ae41d191681e7657ab14cbabf7495c2f0663fb34577016a956f9dd3755fc9	0	374	374	44	46	16	371	2023-10-31 17:15:27.8	1	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
48	\\x2a2771bb978aededd5a0e0b4c57902cc82f6bdd6d3e673287211634f27fbf909	0	381	381	45	47	5	4	2023-10-31 17:15:29.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
49	\\xa10b40d0d12e389339f80c0d08e97630a855b1b645e346d6421a037d68344342	0	407	407	46	48	15	399	2023-10-31 17:15:34.4	1	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
50	\\x8038dc85d8ba0d8d8069c6b1600d4a2b7d373ff2a20d97651a48e5fa012957d5	0	433	433	47	49	14	655	2023-10-31 17:15:39.6	1	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
51	\\xfb74ae1e29e5bc920304869e5a97d635b7f37f654914813c58d39efdb53371ed	0	436	436	48	50	18	4	2023-10-31 17:15:40.2	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
52	\\x4dd38bd3caed757f8183440f3b5d13784b85c231fda5767ef4dae9ab76017655	0	446	446	49	51	14	265	2023-10-31 17:15:42.2	1	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
53	\\xfa59e14f59d989dabbf32c683f3b28991b2da9c188ce70397c72d5cc5ae12f07	0	452	452	50	52	16	4	2023-10-31 17:15:43.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
54	\\xcda4bb9b7bfe820ef24350636536c2f54877ca7845d3a117329dcee43796cca4	0	464	464	51	53	3	341	2023-10-31 17:15:45.8	1	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
55	\\x0e3cd3ebbaf1ec648beef13afcdf0df104eae68836abe140b708b0d1ac123a78	0	489	489	52	54	12	371	2023-10-31 17:15:50.8	1	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
56	\\xcc747d619955c19dc173bda764b4cc0059b0f4ec710f43eb4f90cbff85f7bc4d	0	490	490	53	55	18	4	2023-10-31 17:15:51	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
57	\\x363f519585b85e14133f688c1fed9e39c0e0c89f55bb0cc5ce09b8eb747b69c1	0	495	495	54	56	16	4	2023-10-31 17:15:52	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
58	\\x717e5aeaba2213adec60b32b1859b4efc58dbb80e5f22ae6306437da2c4f888f	0	499	499	55	57	4	399	2023-10-31 17:15:52.8	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
59	\\xad2076210ffcc31dd50d5de46dbd22ae878c278f5f74233181e62653745b0472	0	501	501	56	58	15	4	2023-10-31 17:15:53.2	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
60	\\x83b673afd989ffd1cc98f411084b3f6ee960a14ff96c5e39b7e123106802a06d	0	511	511	57	59	7	655	2023-10-31 17:15:55.2	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
61	\\x65b28648776f445d054e4425f37b6d5a1280d2f3b85dd6323bd8e67e0a31325a	0	516	516	58	60	8	4	2023-10-31 17:15:56.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
62	\\x13963da94d7d95245a4456526e2c086bd9ecdbc3af4503200bfc3c8410b9f8e9	0	540	540	59	61	12	265	2023-10-31 17:16:01	1	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
63	\\x9661e32e9444f3a760a931817a7127a6e843240d9824b8291de3fca7eb5ea50a	0	571	571	60	62	12	341	2023-10-31 17:16:07.2	1	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
64	\\xf3d8f6ee1477d8d060c76dacc6c47af98a149cc7acfab252d9c03cf76ae6aedf	0	573	573	61	63	8	4	2023-10-31 17:16:07.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
65	\\xd0d71d526c3af0ecb2b1feb15884b58fccf940637a3e8a6a798474712dbace3f	0	603	603	62	64	4	371	2023-10-31 17:16:13.6	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
66	\\x5bfc50d3138c00e1358cdff86a7bd2299f30a22ebc3e7417978c978ddd884221	0	608	608	63	65	7	4	2023-10-31 17:16:14.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
67	\\xd69a2071e0f738afa31788af9bb22a9c1f9d158ad3f8d61f56b6936d7a34e9e8	0	622	622	64	66	39	399	2023-10-31 17:16:17.4	1	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
68	\\xe4edcf8519e4a3921d6496eaece338a80b147e7514c4e2799515664ef7d7a5e1	0	626	626	65	67	5	4	2023-10-31 17:16:18.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
69	\\x67ba69d7d5e2cc447dcde7de89927685d6e1d52f004c2f293d0660869085304c	0	641	641	66	68	7	655	2023-10-31 17:16:21.2	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
70	\\xdb249d9c52f7347c1c95ab5d03a3839484df4109975754e96dcb99cfcdfedc5d	0	685	685	67	69	14	265	2023-10-31 17:16:30	1	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
71	\\xae7238c61edac2e2ea03b068ae1ca7efa4e74378d8bb990caafd7dcfdde3f03a	0	707	707	68	70	8	341	2023-10-31 17:16:34.4	1	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
72	\\x07d85649ceedf0fa5c31efd8aa05e0a47d1787d70717e87eafd80258434a966e	0	718	718	69	71	4	371	2023-10-31 17:16:36.6	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
73	\\x82dc7aaca6ddc94366e17974d020d99baca21ec06a91a6776842567a0aee5bf3	0	741	741	70	72	15	399	2023-10-31 17:16:41.2	1	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
74	\\xfed9be0c71fb4fae7d6e940fdce73e7a63710c52d3f353adb1699f609d5c8853	0	746	746	71	73	3	4	2023-10-31 17:16:42.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
75	\\x5c05a4c66cbc8ce12e7501b0900f1faeaab77df2490d9268a17654e73c1bc408	0	786	786	72	74	18	592	2023-10-31 17:16:50.2	1	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
76	\\xa83b214579354befdc14a420bdf6416db1f440ade2ed34f3c4ac2db5b134278f	0	792	792	73	75	7	4	2023-10-31 17:16:51.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
77	\\x9b9b3c2f0117782a8553719945366e5ed482c03344c1ab7b2cc880070bee96c1	0	798	798	74	76	8	399	2023-10-31 17:16:52.6	1	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
78	\\x9a714e760da03a7d0360cd33f789e04638c6072b253d31a77e364471392660dd	0	799	799	75	77	15	4	2023-10-31 17:16:52.8	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
79	\\x027ec55e8cf35e2a84edd133846fe919313d0cf18e7b508d0f31abe936309513	0	804	804	76	78	16	4	2023-10-31 17:16:53.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
80	\\x67a9fccb7152d24725da2b46e3d83e03f0c3a71615386a841d654c329b81790a	0	807	807	77	79	12	441	2023-10-31 17:16:54.4	1	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
81	\\xde57b8fcbfae9cbe755b6760d711476cb65af127b9c35aed4fa6e14cb3f389dd	0	816	816	78	80	4	4	2023-10-31 17:16:56.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
82	\\x8369b846a17ac27aaacc42b4940751f7fb38f27b79c7b8d3c961e5080456c03e	0	823	823	79	81	3	265	2023-10-31 17:16:57.6	1	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
83	\\x445b91f5b556d2625c744a94c27e1de663969e450036abe2ae806fa04bfae814	0	829	829	80	82	7	341	2023-10-31 17:16:58.8	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
84	\\xcc82888fe205a1e097e46fb304647d2cb44c8b2096cd77a3f7bdd78c9b928195	0	835	835	81	83	14	4	2023-10-31 17:17:00	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
85	\\x8c740126e43cf18ebcd996db902b8bd9d8af7672371240946fbdd1e7ecff20f1	0	836	836	82	84	8	4	2023-10-31 17:17:00.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
86	\\x2574ce593a718c48d35f718ef3726befb29cd6213d166e20e9f262f43ea0750d	0	840	840	83	85	5	371	2023-10-31 17:17:01	1	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
87	\\x3ca1c5589b63104f03079602a09f2662e16c2dbdff5a6719252ef60740f9d2d5	0	843	843	84	86	12	4	2023-10-31 17:17:01.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
88	\\x076888696c64681e20e37b2bfe24f2390ebfc68ac6939698fd760f4de58ea2fe	0	847	847	85	87	5	4	2023-10-31 17:17:02.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
89	\\x158b19ff1a3220de70bfd073d7216dac0381e464584e37177a17de9d3bb490d5	0	869	869	86	88	5	399	2023-10-31 17:17:06.8	1	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
90	\\xf05da1d6a910f1b2cfd2109b3be09b22f653f9d1dd8bad2cefe26dd06ac8387f	0	877	877	87	89	4	592	2023-10-31 17:17:08.4	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
91	\\xf723ce99e374954c9fcbe0d0d20e0dfa651c20ab7f65141309deaeb01f20f1de	0	887	887	88	90	4	4	2023-10-31 17:17:10.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
92	\\xfeb30cbd246053bc7923d433fc083fc8ef288cb9e54799df054a10fd62db09f7	0	889	889	89	91	39	399	2023-10-31 17:17:10.8	1	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
93	\\x1dec0827d305fed3cd8cd8f7148797859ab5080ffe2b3c872dc7472b72defe21	0	903	903	90	92	4	441	2023-10-31 17:17:13.6	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
94	\\x628191308be677af21a08bbe550deffda34ee35be8f2b7df48cc7b55fa3f6808	0	929	929	91	93	14	265	2023-10-31 17:17:18.8	1	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
95	\\xf901a21ab1bad370255d6d715e1a1a56de27ddd16f0b44cf9fc3429152643dee	0	935	935	92	94	15	4	2023-10-31 17:17:20	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
96	\\x047422cde73ed47611511b6914f402056c0e014eeb73b628379f6c5254d14334	0	942	942	93	95	3	341	2023-10-31 17:17:21.4	1	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
97	\\x5dde9bf03fec95d5a94f34d0f993babbc3dea6d11aeaed897739c2a52d96e59e	0	951	951	94	96	5	4	2023-10-31 17:17:23.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
98	\\x54667597f61b08b68d080c1e168d2f7f1df131aef8beff6e08de38b490217702	0	960	960	95	97	15	371	2023-10-31 17:17:25	1	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
99	\\xa3dcd40844fa80edf8687641801cc9b36fe92e00a5f910545d880f4d39c3914f	0	963	963	96	98	3	4	2023-10-31 17:17:25.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
100	\\x25bf9ba500e5d3399a5921d85a97171f2d6046c1f27e5e1298ceb4b6c5079d84	0	979	979	97	99	12	399	2023-10-31 17:17:28.8	1	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
101	\\xbcc467b5ad8dd164c94253beb25bf81deabe34f7cb489fa9b2c41d2e2e224e9b	1	1012	12	98	100	14	656	2023-10-31 17:17:35.4	1	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
102	\\x814a0bfcf45c628b58858acefc6019486409e75ef3f6db14ef2e4f0ee37fc000	1	1016	16	99	101	5	4	2023-10-31 17:17:36.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
103	\\xe931934590c3feb4562ab3d10c4cd927991f08c7454872a9c520bbf4781d9940	1	1018	18	100	102	7	4	2023-10-31 17:17:36.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
104	\\x7a71bd0c16f32f84e6712392369714af3315beefaba1e5844c98c7f3707c8c09	1	1024	24	101	103	12	399	2023-10-31 17:17:37.8	1	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
105	\\x30217910319493fdb2c30ae0598ed81adefef1710f25866add152103b15473b5	1	1026	26	102	104	39	4	2023-10-31 17:17:38.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
106	\\xb14ecd0853f6bf32e0d0ef421d30e4cf5e1167287cad2488df39175828433f90	1	1037	37	103	105	18	441	2023-10-31 17:17:40.4	1	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
107	\\x733ba8aafc8edb0709f438549e2d34fcc76b0b0ae77d040fdcf68a62199455e8	1	1048	48	104	106	14	265	2023-10-31 17:17:42.6	1	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
108	\\xf742867e8fb73572426f8a9279835181775ef2a9745ba96bce23412354890afd	1	1052	52	105	107	7	4	2023-10-31 17:17:43.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
109	\\xe45690eb49577f623051c6a5af98c5febb6a7c3eba2e3a1314317dd5b1a57a0c	1	1060	60	106	108	15	341	2023-10-31 17:17:45	1	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
110	\\x25c1d9db8d7a5aef5ec8891a3bfbceb5f8f41e2b7e620630a2df180b99f257ba	1	1070	70	107	109	4	371	2023-10-31 17:17:47	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
111	\\x15f75f02d40f32589869634c0ffdf2e522e0f8ca7f1e3f45c4ad23c83851d3c8	1	1076	76	108	110	14	4	2023-10-31 17:17:48.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
112	\\x53357d6e90245092e20ca215d53ebbcba19790c38690a792952752b6beb3732a	1	1077	77	109	111	8	4	2023-10-31 17:17:48.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
113	\\x11f4a4e36c7a77968443d9b03ad675bbd322631d3ca27c6528a0a4dd68f6949b	1	1089	89	110	112	8	399	2023-10-31 17:17:50.8	1	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
114	\\xebb6a1ea7bb9262e42e81c770966a419937fb377619aea6f228208fdf549981d	1	1091	91	111	113	8	4	2023-10-31 17:17:51.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
115	\\x3421e1b070adb7ced468c6878f1ac406f100ce465c1e9652831c91453db8308c	1	1093	93	112	114	12	4	2023-10-31 17:17:51.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
116	\\x1362938d843407fac812259bda5333f606b626ad2323f0d0cd646158f800836c	1	1099	99	113	115	7	656	2023-10-31 17:17:52.8	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
117	\\xc422b0762404c4066ea5c0a37788c7d62c4043a9524eae9944876e21a7ff4917	1	1122	122	114	116	39	399	2023-10-31 17:17:57.4	1	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
118	\\x352e15d831d5e9dd5621f357fecd9f9c1cfc399862dfce89aacc0a0d1a506c59	1	1123	123	115	117	39	4	2023-10-31 17:17:57.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
119	\\xdd2aa781a44952adcddd419ce74fd12e5e469f3af8eb41784b27569af7c5f5c9	1	1128	128	116	118	8	441	2023-10-31 17:17:58.6	1	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
120	\\x3fa5e427d00b4ab35a93d6f130c6903c221ff740acda7954ba5870a2911d1088	1	1129	129	117	119	4	4	2023-10-31 17:17:58.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
121	\\xb31e8abb43afe2aecf140eff63f3d0751a5c551898f3cb443ec6fd50f9d13381	1	1137	137	118	120	39	4	2023-10-31 17:18:00.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
122	\\x5a2ac902ceed18333e8650155fac71019bdedd49e4743f2ff860c4d59817837b	1	1159	159	119	121	4	274	2023-10-31 17:18:04.8	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
123	\\xc930afd970198cdd5b0ff7b5ff3685ec0647dae3785d1edd290c65ba090173c9	1	1161	161	120	122	15	4	2023-10-31 17:18:05.2	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
124	\\x7a3b7b5f697abe2cfc5dbcc411ee792dd67d8087e902363ecc788bbf85c6a7a6	1	1184	184	121	123	5	352	2023-10-31 17:18:09.8	1	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
125	\\xa0730264d2588104d93841e146e1d62fd1f931b1e7e8fbee1daae08a3743154e	1	1214	214	122	124	18	245	2023-10-31 17:18:15.8	1	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
126	\\xf852d3ec7fa32fbc59c21576f06001b23c8f5a2de33d5d5bcb2cdc2308178c24	1	1223	223	123	125	3	4	2023-10-31 17:18:17.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
127	\\xa77d68672c919d29757d21967b78e000eb233060d61bbb7f07efc14d01b08509	1	1237	237	124	126	8	343	2023-10-31 17:18:20.4	1	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
128	\\xf7ebe07c33785bead15c05c5127a0db066e3f43da62a95d95ee71c7fb3dbb55a	1	1254	254	125	127	16	284	2023-10-31 17:18:23.8	1	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
129	\\x7219f7a03cd2f0b8905fb18281ff3a70dc31292b6925af6335e2b728ddcae9dd	1	1259	259	126	128	12	4	2023-10-31 17:18:24.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
130	\\xcedc51d3ad3dfad0199aa36bf1ff75c34e68c6e8dce3c15bbadd4f06c2489b23	1	1267	267	127	129	16	258	2023-10-31 17:18:26.4	1	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
131	\\x36235c76d737acc968192d5f98040fddc34797c60f7406b3e1a10a1491021307	1	1286	286	128	130	15	2445	2023-10-31 17:18:30.2	1	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
132	\\xf30c5f04684b677a1f6bafe420fa8eb1f7585fa56741ab141ff9f3a163261c6a	1	1294	294	129	131	18	4	2023-10-31 17:18:31.8	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
133	\\x05fb3f60baece460afeb7b4744740dc0e647aabb275c11508173e50a966d7a26	1	1299	299	130	132	18	246	2023-10-31 17:18:32.8	1	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
134	\\x4e81df5f96d7d36a90fa1ef29f433816d0a381809d0721455d0c76cd16b52cc0	1	1304	304	131	133	18	4	2023-10-31 17:18:33.8	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
135	\\xa4709a918a8f21955fd0a1c56cc7fd721e627b2af4b9f3cc70236a13d439416c	1	1310	310	132	134	14	2615	2023-10-31 17:18:35	1	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
136	\\xda0be525edb11a88a43020323b1c9c096a2fe0d427f0ed76bf94353da7e52a19	1	1316	316	133	135	14	4	2023-10-31 17:18:36.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
137	\\xe990ced0a1867c2c7f95a99eb6918a1caad5973aa5ab1081f55a2fa6e0464c96	1	1339	339	134	136	39	469	2023-10-31 17:18:40.8	1	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
138	\\x48dbff9bf4d1bd94b999a3c1658e738b6e053864835256ecefa3c1621910bf29	1	1347	347	135	137	7	553	2023-10-31 17:18:42.4	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
139	\\xf7693b3441c7dd03d3e10053f660e5349a55a91c14093a83cfdfdd33dad1e190	1	1371	371	136	138	12	1755	2023-10-31 17:18:47.2	1	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
140	\\x02e1ee8d43ae799705e5591dbcb185199cd9dd639b19c2533c3ed29acbdff623	1	1377	377	137	139	14	671	2023-10-31 17:18:48.4	1	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
141	\\x80f7e9b709b68b864908cfaf5eb161cac75b84f6af5da31f34ab9c4b6e3705c0	1	1398	398	138	140	12	4	2023-10-31 17:18:52.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
142	\\x28e7b1331c0c23ae6daf074bacf62a4b4012d37877730e4d7d2a9167006027c4	1	1400	400	139	141	12	4	2023-10-31 17:18:53	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
143	\\x76eac50a3692e7e57618ca0aad8ab8383bae301ffa00efef5a2d416efa212be7	1	1408	408	140	142	5	4	2023-10-31 17:18:54.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
144	\\x8b0a3b7febf6f5532707fa1394fc0e7a6a2d4242c7354ef581884ad51736fb89	1	1428	428	141	143	8	4	2023-10-31 17:18:58.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
145	\\x6d140a73757e43ed397254ba8f7da306540f8c1d641b2566791c5c80c1fd7684	1	1435	435	142	144	15	4	2023-10-31 17:19:00	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
146	\\x8b85ae6e802f5e7399daa45b546f0b7849884a9494974ce1ed71c332098d2500	1	1446	446	143	145	18	4	2023-10-31 17:19:02.2	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
147	\\xa568e8f6687d9d2746e86cfb7bc93466c87d914f19dc2c8bf913d4b0277715a0	1	1453	453	144	146	15	4	2023-10-31 17:19:03.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
148	\\x6637f49557acba8aba0bab8a0c066a11ba16ebfb51a204d29980ca1f1f5c5b43	1	1470	470	145	147	5	4	2023-10-31 17:19:07	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
149	\\x19d5df2b5b508535aba09c73beffd544d199d5177269f76607666f235e939db4	1	1486	486	146	148	15	4	2023-10-31 17:19:10.2	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
150	\\x6e77008c71a4f7de71db36c00e5b7d8d30a5cdfdeeb25fb8938cc0fbfb186353	1	1509	509	147	149	12	4	2023-10-31 17:19:14.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
151	\\x04e77d8efbeff63e7c1ec8ba2fb272f2e77ebc044736abdc35ea2d7943797eda	1	1517	517	148	150	16	4	2023-10-31 17:19:16.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
152	\\x00286282ec2afe38dbfc792557a07ff4f739ec5812aaabeaa305b8445dc9cf9d	1	1523	523	149	151	15	4	2023-10-31 17:19:17.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
153	\\xa50da646d141ca32b382d1a0596c6707191172f2f28650fc2ce3cc4825860985	1	1527	527	150	152	4	4	2023-10-31 17:19:18.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
154	\\x72123199660b07c4513858aaa4c0cec844e8f39679afd8b5d673426790ce7b94	1	1543	543	151	153	12	4	2023-10-31 17:19:21.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
155	\\xb05107d595b25af810f501e613e5acdb8e59863b3ff8a3b21d687e39a675d9e5	1	1548	548	152	154	7	4	2023-10-31 17:19:22.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
156	\\x9dfc9b66bc5bfe5c5636eafef1b5620794b4d39d4c2d24b0dc754aa5f68d7448	1	1556	556	153	155	16	4	2023-10-31 17:19:24.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
157	\\x3914546533b82a61f68cdd354ff335978d403f2c689657e4ffacf8366fd092ce	1	1561	561	154	156	12	4	2023-10-31 17:19:25.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
158	\\xd4453edce78311700d88de280e55c13d82aabe8657578ed88022c47fddde0d35	1	1603	603	155	157	12	4	2023-10-31 17:19:33.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
159	\\x382eef6bf5af2c0529d98a7b646a9ee13cfc90bc6b39cc6ab973696dedb20fe7	1	1607	607	156	158	39	4	2023-10-31 17:19:34.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
160	\\x7d573a0b96f6acfc44eab1d8afd7830b3b824d4b3e59c7c24288b5ee61bf0960	1	1611	611	157	159	18	4	2023-10-31 17:19:35.2	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
161	\\x47ed3b98b5124c47a4fd95bf02f59f35bef451db9483b8ac85753ae11aca29b5	1	1628	628	158	160	18	4	2023-10-31 17:19:38.6	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
162	\\xf2538db9d777c6dd51082cf01c6df2b29602d84bca00ac358d7e33b24545cef1	1	1642	642	159	161	39	4	2023-10-31 17:19:41.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
163	\\x71c25441901d2a7b21c12e9dcb3b5f3301946e7db15c2271002b61367fd036c4	1	1654	654	160	162	39	4	2023-10-31 17:19:43.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
164	\\x1195f54803eb74e16d5d1f2c253113503e813735ebacb4e7401bf24015c4eb0c	1	1657	657	161	163	39	4	2023-10-31 17:19:44.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
165	\\x73e2f3d85b0de87243e2245cde1b526f66f51d52eaa666a2d577298011fc27ca	1	1667	667	162	164	12	4	2023-10-31 17:19:46.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
166	\\x5858d1923a2ff903651ba172327d78c010352583d4871f9c79849ba551b284c9	1	1677	677	163	165	8	4	2023-10-31 17:19:48.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
167	\\xd58672a95cdb70b031acb2f9ad1993d7c0b0e3bb35507bf23ad7d70b44f0d338	1	1683	683	164	166	3	4	2023-10-31 17:19:49.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
168	\\xf1770f69158a356d836ba46bf7225032269a7ca4515f4ef9bbdfa3d6b8f6c07d	1	1689	689	165	167	18	4	2023-10-31 17:19:50.8	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
169	\\xc3addcee377014b1b69bb78739312bf4af145552525757b9af0ae9d5bba140ff	1	1705	705	166	168	15	4	2023-10-31 17:19:54	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
170	\\x4d5d846a8b5e4daac575b2bc4115763f1ede4cdf03a537397816d84af2ee8ed2	1	1710	710	167	169	18	4	2023-10-31 17:19:55	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
171	\\x087f953cdfd52912ed6cfc8c99d1f7d56269d762738a8c55ccf71c57d07c3a1b	1	1727	727	168	170	12	4	2023-10-31 17:19:58.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
172	\\xfc8140e43495cc8a126df7f41bd02de2940f052fb665eadaf0d821a369b7defc	1	1733	733	169	171	12	4	2023-10-31 17:19:59.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
173	\\xe7a3119599f62dc12cbd4150a916485fb6f10f0f598beb6476b2ec6085a54437	1	1751	751	170	172	8	4	2023-10-31 17:20:03.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
174	\\x4444bbfbc6e5c6b895d33ac29ed4e983ba58595d06a4a846e773c8a487dbabcb	1	1752	752	171	173	7	4	2023-10-31 17:20:03.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
175	\\x505961bb4161e24dff25dbac921abf3d3bdb27ecab7bf259bf172699555e6a07	1	1759	759	172	174	39	4	2023-10-31 17:20:04.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
176	\\x5002f809a200d9f6aa411be28e1119ee9fe461fc3be19ae552da7469c63e7337	1	1767	767	173	175	7	4	2023-10-31 17:20:06.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
177	\\x14d7ca28421e0f53f8a1e231179db123f6a6f6e8eb605ca7389201d5f871e3eb	1	1778	778	174	176	18	4	2023-10-31 17:20:08.6	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
178	\\x30d7a1a91d43f24b1a893be4fcd98ac67c04e9c27c45dc92247e7a817bc30f49	1	1788	788	175	177	8	4	2023-10-31 17:20:10.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
179	\\x470bfad86b0618527c88f79f5e39ec96c4a89776b70cc29a4f9459c71d6a8c31	1	1813	813	176	178	7	4	2023-10-31 17:20:15.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
180	\\x00a36cb4a2f374314f198e0f634da6e7c187026920d050661c98dd6a7fb9049c	1	1823	823	177	179	39	4	2023-10-31 17:20:17.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
181	\\x730fe85a8fc855ae703d0296b6ee8057ba9332023a940c87fa134586a8e702ea	1	1827	827	178	180	8	4	2023-10-31 17:20:18.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
182	\\x4d292902661f9b4dadf77d86f6f3ffef148554611fa7d0e8700005f11e374219	1	1849	849	179	181	3	4	2023-10-31 17:20:22.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
183	\\x4c68b5cf485d8f8f104fb3f846599728f4d41d1a23668065ef1b68c22fbc7d03	1	1852	852	180	182	5	4	2023-10-31 17:20:23.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
184	\\x162a6b9efc68e7be9839f5875a1311d54b36e4f2873aca22fe30efa951479a9e	1	1853	853	181	183	5	4	2023-10-31 17:20:23.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
185	\\x1d2e611eb1f6c37bc3de86e64da811627086fb4c35e402bbaf48483e4c4e5b72	1	1861	861	182	184	3	4	2023-10-31 17:20:25.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
186	\\xac85c935aebb2948c3bae2307d81a9d581a7a5447801ec158aeb9c3e08495755	1	1873	873	183	185	18	4	2023-10-31 17:20:27.6	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
187	\\x493d8ee3b74b545bfb06d08086e69ebae395bd5286bf3907dbe9b8e979975688	1	1874	874	184	186	39	4	2023-10-31 17:20:27.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
188	\\x93e599918b050e764c4ce6823e914cfd9b25e67edffe0963129b763d4f66bdfd	1	1913	913	185	187	16	4	2023-10-31 17:20:35.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
189	\\x590f3cd9569032062131578fb7323a8bda558dc41570ef94327c99a06d8926ae	1	1915	915	186	188	7	4	2023-10-31 17:20:36	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
190	\\x23526f5018eec94a08122153e6f0b2559a97021b6678779825fcb966cb64aa97	1	1943	943	187	189	3	4	2023-10-31 17:20:41.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
191	\\x8f3c566dba690d6a88b8a3e45aa59a82a41eee57363b2d9e54d31d5fe8669901	1	1950	950	188	190	8	4	2023-10-31 17:20:43	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
192	\\xa3f4a664886e77ef5dca927dcb54da0a4060b071821d647f1d063cb9241386ca	1	1970	970	189	191	16	4	2023-10-31 17:20:47	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
193	\\x5eb90546333cdf17f56d61947e9e45dc69027eceab896987eef6863d8ec3ffbb	1	1973	973	190	192	15	4	2023-10-31 17:20:47.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
194	\\x72599e7f884a7ee8a1f6598b57ce56c834e9ce99aa3afa116c7bb40897724972	1	1975	975	191	193	39	4	2023-10-31 17:20:48	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
195	\\xce5afb235552bc6b1c16ef8e1436f0cc7b07a6495f0f945e9b1e6050815b5609	1	1980	980	192	194	18	4	2023-10-31 17:20:49	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
196	\\xd111059d02d9cf47cf50a5e2446d9a9d49eae1cff7edd371c0efeb60d25ba6c0	1	1991	991	193	195	7	4	2023-10-31 17:20:51.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
197	\\x7d36dfc9f4142905277b560ba554042f274c22c1ab5abaddca84b7eaf90ea6c4	2	2004	4	194	196	5	4	2023-10-31 17:20:53.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
198	\\x9daa04c80370f742289dd27313d0e66559517465c1bae3bfb5c09dd52d95e780	2	2008	8	195	197	18	4	2023-10-31 17:20:54.6	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
199	\\xce21317668d5d7f539dc1ec1c0c08d98447b016a53ad79b810ccae7d83c9a2e1	2	2013	13	196	198	14	4	2023-10-31 17:20:55.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
200	\\x23c6041be13a1d4110641e07149b33cdb9f9fafbf9f54763e98d088d3f35d717	2	2015	15	197	199	5	4	2023-10-31 17:20:56	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
201	\\xa06c0785ad2d48f3e4b55e439997a4f15bccc6ba1f10f1381abb199b8bce39d8	2	2016	16	198	200	15	4	2023-10-31 17:20:56.2	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
202	\\x4e873aedb72b0e8401589acee4af111f9af76541498a1c7e41388fa5033a788c	2	2017	17	199	201	3	4	2023-10-31 17:20:56.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
203	\\x19eb5fc9e544285fc04a6907cd8538e80fbcd656d96f7871acbf48d73ea5b229	2	2032	32	200	202	18	4	2023-10-31 17:20:59.4	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
204	\\x9b79df599f58f65caaae1e79f109bc22d8d6c1140475fccfb7165394508d5344	2	2053	53	201	203	14	4	2023-10-31 17:21:03.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
205	\\x1dfc19bfa53e57dcdabd661bc93614f233f6a615ce25c3ca74cf5db14e30d7b5	2	2057	57	202	204	12	4	2023-10-31 17:21:04.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
206	\\xa8aed66b331f40325fd0f41b8129a10efeee6001b4177640be9f7414b4d4441c	2	2085	85	203	205	8	4	2023-10-31 17:21:10	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
207	\\x240d4bd011103b0000631880059ddd127e1923b51dbc82f24d7fd753f7aa528f	2	2094	94	204	206	5	4	2023-10-31 17:21:11.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
208	\\xd2f4f16c1746965db68532d3577986c61f17c42891107dd136f3dfc6f7a9adc8	2	2098	98	205	207	16	4	2023-10-31 17:21:12.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
209	\\xab9f5c4ea050a5e35026cc67608d6c4d30b0ed4f77e8786e31eaba0fd95eb75c	2	2106	106	206	208	39	4	2023-10-31 17:21:14.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
210	\\x76f2cf21f88800213e23b18cb1bb08aa94e0a102f3655ef930c92dc73a2a41da	2	2125	125	207	209	14	4	2023-10-31 17:21:18	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
211	\\x0b7b1dbd0d091bc328d22205c936be7cec0c890fb677cfcf68d728f119ea632c	2	2137	137	208	210	12	4	2023-10-31 17:21:20.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
212	\\xb842ab56106adffc85b5caaf6c40e273cb62ff972b7f9f1cba9d9a16be04cdaa	2	2145	145	209	211	4	4	2023-10-31 17:21:22	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
213	\\x5c80fb06336a19ffe0e9fbc1d06921bffb4a22e80e1eda4da1bdeeb99660fa82	2	2148	148	210	212	5	4	2023-10-31 17:21:22.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
214	\\xbb2524a1a38879535d0f2e05d9e9a0a8b0ec81bb0fdffc3ace99a348706904e9	2	2156	156	211	213	12	4	2023-10-31 17:21:24.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
215	\\xea4f6fe44c76867121f0ce4eac00ce5de51f7dd41e90f3745fc9d7722c77e567	2	2170	170	212	214	3	4	2023-10-31 17:21:27	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
216	\\x72acd157b01caba6af4e662fb04ec768d2e8fb608ca2a9c407061c632e0eb56a	2	2171	171	213	215	18	4	2023-10-31 17:21:27.2	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
217	\\x742906778a1bced180eb1f6fc91181eebb8ba24c9f4e6884ef8da79e7dc404ed	2	2172	172	214	216	4	4	2023-10-31 17:21:27.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
218	\\x85bedac72b89af02e33d21b6672ea6d748b996b9562c9a70a533bd6f28cfd2d9	2	2207	207	215	217	39	4	2023-10-31 17:21:34.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
219	\\x54e597a42a891e98b96b78a6db2bfd1aaa4edb2ced1ab2f14eda157b8f38443d	2	2219	219	216	218	7	4	2023-10-31 17:21:36.8	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
220	\\x0e5c2cef2ac558430fcb56218d925aece6e1c99370abfd12ad313a74d0de7e30	2	2254	254	217	219	14	4	2023-10-31 17:21:43.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
221	\\xc5955ea287190ead6e9b8f80dd74b704686ea9ef9b287e3903caccf19515201b	2	2268	268	218	220	5	4	2023-10-31 17:21:46.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
222	\\x88c4045ec0b4ebe94bfd1baff7f3c2200c6e734c7154f80b3a57845af83833f5	2	2279	279	219	221	3	4	2023-10-31 17:21:48.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
223	\\x6189208778fbbbdd1989a70cd04e51816322d8a12ff0564cdbf29dfa3605cc0d	2	2280	280	220	222	5	4	2023-10-31 17:21:49	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
224	\\x3de59fd4416038342184400d12d8e6d83089c9b33cfe4edbbf074d0d2ee36d68	2	2285	285	221	223	16	4	2023-10-31 17:21:50	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
225	\\xb0efdc7be86477571de1ce307452a5f63a63c9a210c002accf4ec5f500e5c374	2	2293	293	222	224	18	4	2023-10-31 17:21:51.6	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
226	\\x1cc20144b97330bf30d05f98453a930e1f7246c44c933622fc52a2aab280c25d	2	2300	300	223	225	18	4	2023-10-31 17:21:53	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
227	\\x02e09552e1d89c0da5de524857be8be1d438bf7fad44d054b74d4aea3284533b	2	2308	308	224	226	15	4	2023-10-31 17:21:54.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
228	\\x4742135cd4c25d387ba3451d404fa96c778e111fd85a3c257f2faa2bdc81d298	2	2313	313	225	227	4	4	2023-10-31 17:21:55.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
229	\\x4b0975263ff812d22c3e3d485ff2315a0e44c39db3ba349b21e49c909da19b17	2	2318	318	226	228	3	4	2023-10-31 17:21:56.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
230	\\xd77455c868784fa3808ba5bf73d00dd3030e38ac923554a24b7f0209ab16f4c0	2	2326	326	227	229	8	4	2023-10-31 17:21:58.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
231	\\xffc12cf01e634703d4f7dc25eb47a7f9000d854990d740f21ffdbc1183e27bd4	2	2344	344	228	230	14	4	2023-10-31 17:22:01.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
232	\\x6514e6c0ea0434b1b3096cd89332275066767ac4bf398b081915c98137bd8f5b	2	2349	349	229	231	4	4	2023-10-31 17:22:02.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
233	\\xc20b6a9bd616c8ae731f7c249dad7001e39d5769812787847c8046d0da1e0472	2	2360	360	230	232	14	4	2023-10-31 17:22:05	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
234	\\x46678befbbde39f63364aeddcb53fba57249c14dc8a1d0dc6385440ca913f12a	2	2373	373	231	233	15	4	2023-10-31 17:22:07.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
235	\\x580fe72dd41dc8c812ec09f44b9af0ced6f13209071d6cac446de3e1dec80a42	2	2383	383	232	234	16	4	2023-10-31 17:22:09.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
236	\\x64e8c53230966ec61635c4916f5b7b10eaecc724aca076fd16b1c398c9eeeb62	2	2415	415	233	235	8	4	2023-10-31 17:22:16	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
237	\\xe22788c2d7ac3dda6fda0101e0fb0dc5acea443c3fab637ee8947ad1b4a106e1	2	2416	416	234	236	3	4	2023-10-31 17:22:16.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
238	\\x4fb4b02f88bf09c7b1a08cde6a9f56af8edaa1f4862fe973d35989c7c92fafb0	2	2438	438	235	237	18	4	2023-10-31 17:22:20.6	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
239	\\xb30525d2708bc8089c179b074eb0e92edbef75cd329b37428377cc23353c5bfd	2	2442	442	236	238	3	4	2023-10-31 17:22:21.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
240	\\x58766b87f13c28dbfda8209851e3fd842ffad8ba7605e012b22707021fb09c05	2	2443	443	237	239	4	4	2023-10-31 17:22:21.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
241	\\x562e629ec0119457c0084c33e86949a8cfc8c75bc0dcea5db601ef203ae471d8	2	2450	450	238	240	3	4	2023-10-31 17:22:23	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
242	\\x2aaff83f405724c6129b25e7f21af9bff0db1517f35c1ed527ef73f092d44b06	2	2460	460	239	241	7	4	2023-10-31 17:22:25	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
243	\\x67d05f74d0a3e4eb74414153104e589bcbf09bf054243e709063e2b821353eaa	2	2461	461	240	242	15	4	2023-10-31 17:22:25.2	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
244	\\xbede6779ae57a285f00ef7887ef50c76f1a8320c1b32a3c697b1ef5fa2aa3f41	2	2516	516	241	243	16	4	2023-10-31 17:22:36.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
245	\\x82f69580fa76bac7092ca895cc052b76214c7c7ab505daae3bc905f86502d2f2	2	2527	527	242	244	7	4	2023-10-31 17:22:38.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
246	\\x11621b9dc8c17defe5fcb3c26101d29bb90945216da9fffcb601dd6609f471e8	2	2536	536	243	245	7	4	2023-10-31 17:22:40.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
247	\\x28889ca7551a233120ccc2099e497ef364d14c08ee4e563baf328acf23ecdaad	2	2537	537	244	246	12	4	2023-10-31 17:22:40.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
248	\\x45c996ee5ee2a376056c0f948504454a87a0f8478db22c49c22ce816f0597252	2	2552	552	245	247	8	4	2023-10-31 17:22:43.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
249	\\xa2ee5262a80efe7b90f804495615d5f53384b7d72c6d6c9cf98e6e99019a1b09	2	2558	558	246	248	15	4	2023-10-31 17:22:44.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
250	\\xbc123dfb9a6c100c64bc703d106240815175df193b90f7d9927e88ef353d8e39	2	2622	622	247	249	18	4	2023-10-31 17:22:57.4	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
251	\\x7c5f3c938d54a823e5205ab2520ec2e15fd9c3a6297eb4b30700baa52a905326	2	2626	626	248	250	7	4	2023-10-31 17:22:58.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
252	\\x01319aa4b7a2fd2d12eae9df0cbaceae95b1cdf4091a7c2b5c33298ee4f5af2a	2	2641	641	249	251	8	4	2023-10-31 17:23:01.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
253	\\xdc9638a53ea08722bbcc4dac61f254f36abd0d0d886fc1019bc01829553c8520	2	2678	678	250	252	3	4	2023-10-31 17:23:08.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
254	\\x066068d8568d7be4fdac40ad29c7ee5449963851e78c0adb8dcfd30a955aaf91	2	2702	702	251	253	12	4	2023-10-31 17:23:13.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
255	\\xacb9884982dfa5643195db2a1d464e3d100b2dfc4383a780eeeb8d97723b4f7a	2	2703	703	252	254	5	4	2023-10-31 17:23:13.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
256	\\x37088441275781c03b9cbccc2c39fe2875269c6f24b6d684409c4ee1bf425710	2	2733	733	253	255	7	4	2023-10-31 17:23:19.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
257	\\xc7345efbdadee9f84d7b80bbb35ee8cf4f3038903685cfc2376a26ae5d2e3101	2	2762	762	254	256	14	4	2023-10-31 17:23:25.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
258	\\xfae43780b83008e45fd4286aa4e6d79a0fa600ce2d3d7d47d0a60e9b03420c79	2	2772	772	255	257	12	4	2023-10-31 17:23:27.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
259	\\x06f9b37f0d2f7072a05ef8833a0069588cf50b0632b2eefcf021d199e585e378	2	2774	774	256	258	5	4	2023-10-31 17:23:27.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
260	\\x590f4a2c4f4bd19d4c355a418a7311439c023c4bc9c3149451e1067cb0a03d1e	2	2775	775	257	259	39	4	2023-10-31 17:23:28	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
261	\\x00db6a97e25217058f984f1be69e2613a17bdad83bf8c3a87248fab440f9a961	2	2810	810	258	260	12	4	2023-10-31 17:23:35	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
262	\\x9f71bfa20784c9146fa780c284db466534cb4d5c988d802456c1dd68ae9d8c5e	2	2836	836	259	261	3	4	2023-10-31 17:23:40.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
263	\\xf587b6e4576593c05e09ef2a387691895dc7e719800adf871c8be297060abbbc	2	2841	841	260	262	4	4	2023-10-31 17:23:41.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
264	\\x3b254d60a7ec29f3a730796a54af5879f4d0f11e6797d37aad9acfe1c50a0301	2	2851	851	261	263	18	4	2023-10-31 17:23:43.2	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
265	\\x8c32bb1e4b8ea3c6b85418d8cba833aaa0b41081365e8793adf8b1971f322ad4	2	2867	867	262	264	7	4	2023-10-31 17:23:46.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
266	\\x0594a77439344fc98d298d547096ff959a51d8f99aa11429caa86bbf2cdaa310	2	2869	869	263	265	4	4	2023-10-31 17:23:46.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
267	\\xa08da3c432b52751f0261cefe45f9837105198b122046fc32c5b794846acb66d	2	2886	886	264	266	39	4	2023-10-31 17:23:50.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
268	\\x0cde9eb111902d30a5923253bbd8c0cb1883ae1c66cd01636a09f72b6494a39f	2	2893	893	265	267	15	4	2023-10-31 17:23:51.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
269	\\x1213d8463db4a3b7bbb8785b36b4591eb71569a018f65c432f43eca06b3c9bea	2	2896	896	266	268	18	4	2023-10-31 17:23:52.2	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
270	\\x33868e7e9a6947c0be687d464e2330a8fe03aafcfd34198a3d7e0c8893616d5f	2	2897	897	267	269	5	4	2023-10-31 17:23:52.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
271	\\x3f7172d7fa8aeb0f479001004a1eb55a198464f1d0748aaf843e56446a39899c	2	2911	911	268	270	4	4	2023-10-31 17:23:55.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
272	\\x416f60092fa254c5af0715fa214bbc5b8ca816d0b433cb117cca8a26d11c2e6b	2	2937	937	269	271	7	4	2023-10-31 17:24:00.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
273	\\xf3dc5af2158515c41d295fad9b9e1bce091ad7b2dd6ab09b935fcf3de5c8e713	2	2938	938	270	272	15	4	2023-10-31 17:24:00.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
274	\\xa1ba92eeeb50d9fcb0765cc7bb7ea3bc678fd5fdc5426efba178fc5d029371d0	2	2940	940	271	273	16	4	2023-10-31 17:24:01	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
275	\\x5c6f04ba19491d4d17fbcd4fcadc75ec2ee6bd041d608faba288fc512a0c05a9	2	2983	983	272	274	5	4	2023-10-31 17:24:09.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
276	\\xde7c9322a90d84c2d362d10379d7db0f957ebe8a2b8fb2ab07254c7dd883b41c	2	2988	988	273	275	8	4	2023-10-31 17:24:10.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
277	\\x78adbdd033e9e7e70f60a79f8677e72e1ca6f3efa0b31f8b80c9716ec62a42b8	2	2990	990	274	276	12	4	2023-10-31 17:24:11	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
278	\\x37df015459ee3b7d754146721b66667de7b02827e8e6522f6830b513c4c6478c	2	2991	991	275	277	7	4	2023-10-31 17:24:11.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
279	\\x9af6983820fbacbbfa0e49d042d27f5daffae5100e917b02badbbc6c7503552c	2	2992	992	276	278	3	4	2023-10-31 17:24:11.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
280	\\x7b7026b10b9903c42ac1db8470bae75d97365a89dd74c1b2f142aa12854fa31b	2	2998	998	277	279	8	4	2023-10-31 17:24:12.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
281	\\xab407c41bb06b644cdacf7887eb5fc1e5de55e0fc2c8e0748b6c15f674920483	2	2999	999	278	280	3	4	2023-10-31 17:24:12.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
282	\\x796a9adefccb5ffab6abba6241b900e39d6d614d45e70d725dba6e044cf4be42	3	3002	2	279	281	8	4	2023-10-31 17:24:13.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
283	\\x956ca001b8427e82234caedea85009460ef5fcacb6579b29ea0da6b1682f0792	3	3010	10	280	282	12	4	2023-10-31 17:24:15	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
284	\\x46ee6406203c5860eb965d2262cd65ffeaf0509183bddbda94f36b4da84a7b2c	3	3013	13	281	283	14	4	2023-10-31 17:24:15.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
285	\\x6b1921d41a5f0bdd7375fee95134616325c01fca45640b633211b495b65406fa	3	3019	19	282	284	4	4	2023-10-31 17:24:16.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
286	\\x769195b2ad0490f9c84ec3fa093d1dfed22c4d2aa36571516e7d3d38f5cdba62	3	3047	47	283	285	5	4	2023-10-31 17:24:22.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
287	\\xda7a7557f377146f9c5b4728cdcc8625ab5c61f6d749d1c3700a2c13436ae880	3	3050	50	284	286	3	4	2023-10-31 17:24:23	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
288	\\x477f8e676ae2f68c943d5f3db9d8ce7f9a936d4805a8583f884923bfc0954031	3	3064	64	285	287	7	4	2023-10-31 17:24:25.8	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
289	\\xf46a33600996932bd794459f47d1eb41e7f1413e6a3db2e9d07f07c0550d61a0	3	3067	67	286	288	8	4	2023-10-31 17:24:26.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
290	\\xec20525319bb55ffbdd37b9b0036d4b94f7c5c936b838d3fe1859d76a7162813	3	3087	87	287	289	16	4	2023-10-31 17:24:30.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
291	\\x5f110aca3b9b01ae700718b38ccb2610ddd26e9474e9694ee4ba8b8ad005eae1	3	3102	102	288	290	15	4	2023-10-31 17:24:33.4	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
292	\\x6e805f4d3f3739a176cb7863b2da98ee21ef3700313fc05449e5cafc30ca15d2	3	3105	105	289	291	3	4	2023-10-31 17:24:34	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
293	\\x18e4e07dc50bcd6f37c4d5c798c9f9d95374341c20a6771a7f0ace2a2cb6e425	3	3125	125	290	292	39	4	2023-10-31 17:24:38	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
294	\\x593d5b2e4b933f79ec28198c38739092d418890249e473bbbc9aeac7f218eb52	3	3131	131	291	293	12	4	2023-10-31 17:24:39.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
295	\\xbc19457e9d7a1cec9360063a739bf68ca27aef746c187560d1c0b26ea811b37a	3	3163	163	292	294	5	4	2023-10-31 17:24:45.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
296	\\x6d7bc00fc56988d76bb79d07af22dba28c68ca9fdfdd29b607d76deacf4552eb	3	3166	166	293	295	7	4	2023-10-31 17:24:46.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
297	\\xbbc03a53e4d7bd569f286efefa87ef5467cc4a03c46b37bdf421f032a390387e	3	3167	167	294	296	7	4	2023-10-31 17:24:46.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
298	\\xf68520e00436f74b6a4297d668d57d02f1b1e020d94c19b2b5fc1025c75272c0	3	3193	193	295	297	4	4	2023-10-31 17:24:51.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
299	\\x75ad708c4866bc5bdddf806ae96b225f14f2e3cbbc64559a0eb6adb3297d6ed4	3	3196	196	296	298	5	4	2023-10-31 17:24:52.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
300	\\x75396b87cd6628e52ddaaf52ea57a1de3f2b819d57530983ee05490afa434157	3	3208	208	297	299	5	4	2023-10-31 17:24:54.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
301	\\x03a51d6659d499df8587ed960b0b50baff95f33dba0880c05f8076988692d499	3	3212	212	298	300	16	4	2023-10-31 17:24:55.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
302	\\x412e0a8b0bf20467515b48b018be0e1569d5e6ef600c3ddb0199587b99f16012	3	3214	214	299	301	18	4	2023-10-31 17:24:55.8	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
303	\\x22a1f3e69c2c26a56921b953df88d18b014d94ba246b7b6f6fe3d094225d54c5	3	3219	219	300	302	15	4	2023-10-31 17:24:56.8	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
304	\\xdf5b426e3bf38c504b1868f31cfd46bb63c44a76687a555e81f15a340c310501	3	3229	229	301	303	39	4	2023-10-31 17:24:58.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
305	\\x4b372e82aadd9776a7122bb5dd5c9e0b88fb401947f23f1c668790460edfc0d4	3	3231	231	302	304	18	4	2023-10-31 17:24:59.2	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
306	\\x0db552486b3be7d3190ab7f64f43aa119868cd0bfe5949d92d66e5473e503546	3	3241	241	303	305	4	4	2023-10-31 17:25:01.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
307	\\x9ef36422366de11ac43a39103f5bc297cfad52b6c762230440bfe5db25a3d67f	3	3247	247	304	306	39	4	2023-10-31 17:25:02.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
308	\\x0425b701f71876798d76d143c2aaece34cf83f452a594246e9eef383d38d3cfe	3	3269	269	305	307	12	4	2023-10-31 17:25:06.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
309	\\x600cdd371e58ef1a3091b785fab036b8445f5e0d630c87b0c90cc6cee99e0820	3	3294	294	306	308	7	4	2023-10-31 17:25:11.8	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
310	\\xe60fd71a29c399fd7c5ca20d63a6f240b7a6ef1dc5c495a2209ca0dda677ce90	3	3314	314	307	309	39	4	2023-10-31 17:25:15.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
311	\\x3399a74ba767ce437b7de86d95a48cfbb8287515beeccc1396d8c610d9d022a7	3	3317	317	308	310	16	4	2023-10-31 17:25:16.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
312	\\x9923c262542b12b7fd27321d09ae67a6c9ad949071239f2104258dcf0857c4b4	3	3319	319	309	311	15	4	2023-10-31 17:25:16.8	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
313	\\x70c8c8a13b0200cbbfef2691aaef075dfb47a6a82d22a5e49415b3409075a4e7	3	3320	320	310	312	3	4	2023-10-31 17:25:17	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
314	\\x7e0ded7d2c7192d205cd4874aff43fa339d7c8080807500c9630e2bc7bb46a78	3	3323	323	311	313	3	4	2023-10-31 17:25:17.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
315	\\x4a3e10f39a1e4093db83ce0721f32704197678340b6047f87b3c2d904094f0f3	3	3334	334	312	314	12	4	2023-10-31 17:25:19.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
316	\\x32d95a93a03d4654116a7e2c9db13aeefdb7b3bca1e9512986e0f91837aa6707	3	3346	346	313	315	4	4	2023-10-31 17:25:22.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
317	\\x3da10d6125750cc8f93fc34a15b587ae13b98102e5ad844b9505e38018f0cac7	3	3351	351	314	316	4	4	2023-10-31 17:25:23.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
318	\\xdbd6f648d513c151c32320f297ebc410d8986aef3474825ea5f49337fcfb66b5	3	3368	368	315	317	5	4	2023-10-31 17:25:26.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
319	\\x4607030da357c461dea11a1124c72e648b85d85a5d8a0ea139f23b87f10943bc	3	3385	385	316	318	7	4	2023-10-31 17:25:30	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
320	\\x10dbd45b6eba616763d3a13a2ec10bd0351d8e1ac9753b18c210a8d3bfdb88b9	3	3392	392	317	319	18	4	2023-10-31 17:25:31.4	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
321	\\xe8a4957afadac9dd75f436c345e0e379dbf9311abfebbeab6885f64c4f63df18	3	3396	396	318	320	14	4	2023-10-31 17:25:32.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
322	\\x96866ebbd7158780fd8332d232b9cbaba2deceec98af0065ce63f50ff251f8c9	3	3399	399	319	321	39	4	2023-10-31 17:25:32.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
323	\\x5c17389f92bd4b7c7f29788d8af79cf91000af04d8103ad52a8952812e501b00	3	3411	411	320	322	14	4	2023-10-31 17:25:35.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
324	\\xa8fbd6c6d5285d3fef34cb1f1f023dbb1a316a5275b1a5b2ac59e56bb95bc051	3	3421	421	321	323	5	4	2023-10-31 17:25:37.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
325	\\xa53d31aae76a9e74a95f06751e78bba1226ca16e51876de0af222798e2395c21	3	3438	438	322	324	5	4	2023-10-31 17:25:40.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
326	\\x25f5526636738c937b909149973b8cb1d738439eaffb6749413a11338187297e	3	3441	441	323	325	7	4	2023-10-31 17:25:41.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
327	\\x8cf157a2ec78feb1e74248305f6f23a45d1d2be34b4cf60394d75743e08f6247	3	3444	444	324	326	14	4	2023-10-31 17:25:41.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
328	\\xd57e79d45257b4fc967168520cb791f5971adf095816935b012ba31295b05130	3	3462	462	325	327	15	4	2023-10-31 17:25:45.4	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
329	\\x3fa621876b4d02dda2807f8f35e593c6168521e1364a4ffde0a0e3d49f79061b	3	3468	468	326	328	39	4	2023-10-31 17:25:46.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
330	\\x87ffd618ce4e2ac1fc44d8638dc74f0151cb9726abe1a064a815cccff4d34675	3	3484	484	327	329	8	4	2023-10-31 17:25:49.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
331	\\x5ff0a1847f99f4460b52f85a60658e0095f9f8703b82c3035647fab7fa25e3c3	3	3492	492	328	330	8	4	2023-10-31 17:25:51.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
332	\\xbd6d9184cfa2199e877e02b022b2308d6ef3a7ef339e8d2fbb0905b5925e17e0	3	3514	514	329	331	5	4	2023-10-31 17:25:55.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
333	\\x4968cfca1a1fa55f8601f8b8392f89df2c9f0fdbe354cc5dd292c6ffd6ff47b1	3	3520	520	330	332	18	4	2023-10-31 17:25:57	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
334	\\xa66e614357271647d62c087681f4a70124008adbf50f8a5918ac04b230115735	3	3525	525	331	333	8	4	2023-10-31 17:25:58	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
335	\\xa5eee1b4a37dbd8e99dab1dd5cdffbd6d911d4a0ef392226c0d04c99e379fe51	3	3542	542	332	334	7	4	2023-10-31 17:26:01.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
336	\\xbe5b21a20eb1c876c239888a8f82f92c6626be6d5efda79e113f694b53636001	3	3554	554	333	335	14	4	2023-10-31 17:26:03.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
337	\\x71c57fc9384f47d77cd4d9531439ef0fef496ac213b5e65536abfbcb733a7813	3	3577	577	334	336	15	4	2023-10-31 17:26:08.4	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
338	\\x4bee2a9b90112cf4454e6941969d0789737f10481332d1e071f25c99f9b6d700	3	3580	580	335	337	4	4	2023-10-31 17:26:09	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
339	\\x3654ad1c9197b47aa826953f1ad8c9f7e00b418385d47713a252661e26c3aea9	3	3588	588	336	338	16	4	2023-10-31 17:26:10.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
340	\\x6e6ca7d7fdcb05b0953cadb09ede76737b2e76ed53531ad1dd4637c5e02c39a4	3	3607	607	337	339	15	4	2023-10-31 17:26:14.4	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
341	\\xb4bdc720f803acb774611425954f4e9780c303a2c8edcaff8a9473e9972061ea	3	3639	639	338	340	7	4	2023-10-31 17:26:20.8	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
342	\\x099e84bda821abb52178c101e46e0f91ddcdbaac2729b40f72873b1687c4d796	3	3640	640	339	341	39	4	2023-10-31 17:26:21	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
343	\\x74ba6a042db56a9fcd57a34547d8b64311cc6ab6e798a76b6a044c6ee12fb492	3	3667	667	340	342	15	4	2023-10-31 17:26:26.4	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
344	\\xd3cc4baddf0512e0bd330e3a623fac1a57c87f2828887c20430a750ce12b8357	3	3679	679	341	343	8	4	2023-10-31 17:26:28.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
345	\\x45bb6f3b846c5cf3f24ff175241358bfc0c424e287331431e81d3c32fe2a5bf9	3	3680	680	342	344	18	4	2023-10-31 17:26:29	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
346	\\xd3fb8accfd71f5f1e0c13d58b4a20aefab128a5c32524c5778f4a469f0d8e96e	3	3708	708	343	345	3	4	2023-10-31 17:26:34.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
347	\\x9a176bc9c0e258bf08ef8efff7d45e92fb59a7eaf6130dedc235ad942bda188b	3	3726	726	344	346	12	4	2023-10-31 17:26:38.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
348	\\x4ee66564e43df1797365b16c19074ce416cd77eba2bfeb417f7006877ce807e8	3	3733	733	345	347	39	4	2023-10-31 17:26:39.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
349	\\x9d48c592d2965948b88b5f18943e03278a271fc351312bfc4a28f2d5d13bb9c2	3	3737	737	346	348	8	4	2023-10-31 17:26:40.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
350	\\x5ea58fe6e9bd3be6092c75b498611a8284693ca7dc8535d9dba38674becce928	3	3742	742	347	349	18	4	2023-10-31 17:26:41.4	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
351	\\xc6075b9067f9f8e07d0556ffac1a94685e23bd6ff38e2635eafaa1006fc06c36	3	3748	748	348	350	3	4	2023-10-31 17:26:42.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
352	\\x5600732991b7e1059472a907426f96f813fe84c9a5f97e70a309fec91f372ed8	3	3752	752	349	351	7	4	2023-10-31 17:26:43.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
353	\\xf767c68ecef70ef3c5bf68b09801705094ed00842344438be7e3308d0c76ad5c	3	3762	762	350	352	15	4	2023-10-31 17:26:45.4	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
354	\\x0dd9698aba095c4395bbb1e70d9284f2299fc9428105a0855d5aa3047bac240b	3	3768	768	351	353	16	4	2023-10-31 17:26:46.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
355	\\x9b69cb31a95174519ca5206f766c7d64deda091d00cf23698d8dad2b177cabfe	3	3804	804	352	354	5	4	2023-10-31 17:26:53.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
356	\\x830b944d349f4398b651f38fb38149fe560a8820e0ff0f885d4ea357221bcb44	3	3806	806	353	355	8	4	2023-10-31 17:26:54.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
357	\\x913b2dde7894fda82579df8170668e6634bb7a404e09d06f534f037eee101fc5	3	3821	821	354	356	4	4	2023-10-31 17:26:57.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
358	\\x33cd8fc5db2fdb535a5f09ec838ddfd365085673ad16b895eb91380bbe118ca1	3	3822	822	355	357	16	4	2023-10-31 17:26:57.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
359	\\x3fbf5dde9f2e8bfc52c58c8c7746ee68bffaa59b90a270254b449bcb4b41ea92	3	3839	839	356	358	16	4	2023-10-31 17:27:00.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
360	\\x8e1fa45e07a6530e649c04ab59b63634e7e588498f5921f0b66fc3fc67e09533	3	3841	841	357	359	5	4	2023-10-31 17:27:01.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
361	\\x1c0e74f1a5b5f157db23617b45f2c4af87c70db4daecb339b35e90859875b514	3	3843	843	358	360	5	4	2023-10-31 17:27:01.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
362	\\xe35e4bd286eaf8b40c20f558fc36ad938ae549e2f77cdfbe22d6092628bacc0c	3	3853	853	359	361	15	4	2023-10-31 17:27:03.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
363	\\xb26ad2fdc2327dea288b113e42a1940c28bde6eb82892e63f8e827bf0f358a3c	3	3863	863	360	362	39	4	2023-10-31 17:27:05.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
364	\\x8bed6cd8068bdf170a5b9ddd9b57c91a12ae455de51db37690f804dd265d3bc0	3	3864	864	361	363	18	4	2023-10-31 17:27:05.8	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
365	\\x61b5e7e1b7e976fd8b4933f63316ebd389ed8f05c557889a70256b5310204fbd	3	3878	878	362	364	16	4	2023-10-31 17:27:08.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
366	\\x232f2f598dddcf0c770f6518cf295f8b8311d7f03c134f24a5f970377a6d2797	3	3879	879	363	365	14	4	2023-10-31 17:27:08.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
368	\\xc3087856b973da23228a9e5e5a8fc3b2f4d7deec39d5455610c1333d518ce5e0	3	3881	881	364	366	5	4	2023-10-31 17:27:09.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
369	\\x290a1a58b29bd5356e400769b013f0c8321d72d71938b3c30f678c9a6e57074d	3	3886	886	365	368	18	4	2023-10-31 17:27:10.2	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
370	\\x3b7e65effa7be581713150041e620d07a338f53f0fa4e2047d32256687b2215a	3	3903	903	366	369	12	4	2023-10-31 17:27:13.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
371	\\xee153d45584fcb7776d511337aabcab60a646516eee579caf23770362edb785f	3	3908	908	367	370	18	4	2023-10-31 17:27:14.6	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
372	\\x042bbe367c90af0ec7cf239828aa38ac4f52dc4c40a17158e9c483872501dec4	3	3923	923	368	371	18	4	2023-10-31 17:27:17.6	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
373	\\x0404c46c96e3a27415e7872ef0ab547ec456a2e4f1aa53c4aa9bbd8d3d93da1d	3	3930	930	369	372	39	4	2023-10-31 17:27:19	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
374	\\xfc2b83c2bc0f01209aabc972a6e91a198b9dca619bbc6a78deba13da175eac09	3	3937	937	370	373	14	4	2023-10-31 17:27:20.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
375	\\x83e3aeac3769c546139d1cda283b8f842c66d92b1f4e0dc761f6663e236cba44	3	3944	944	371	374	8	4	2023-10-31 17:27:21.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
377	\\x9d83978ee0087408fb3ef1339b3999e8a250d9fd7dd082f60ee649869f898ef4	3	3950	950	372	375	18	4	2023-10-31 17:27:23	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
378	\\xd43eec6696ee0573d981abdbd37de964ffa9ee3907839c1d03ef74e727ea837e	3	3968	968	373	377	15	4	2023-10-31 17:27:26.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
379	\\x409f6faf0861f574f28f336a978c598b2a6815b77d39aae2493ffb73e106d2a2	3	3975	975	374	378	5	4	2023-10-31 17:27:28	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
380	\\xb9330e01dc161d510d057ae3f825c92027cfa554bd0dc7a4f2799982748d81d7	3	3994	994	375	379	12	4	2023-10-31 17:27:31.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
381	\\xb8d0dadde6ef6735eb448524a45abc593954d769ed0f05daabc6944bcd6b1f22	3	3995	995	376	380	18	4	2023-10-31 17:27:32	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
382	\\x048fd9da66c1b1d026a592b7963025e4a2279d1995fbc174e7e6e06c44d6a60b	3	3999	999	377	381	8	4	2023-10-31 17:27:32.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
383	\\x83555ff2663a2a33f83ee97eedd24599748b1693df0a0f4c1d3c55d857f44414	4	4004	4	378	382	39	4	2023-10-31 17:27:33.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
384	\\x6c1dc9838d4b469d279fe668982b20d09fb9f10ca049fa87bbdd5734f20d782f	4	4006	6	379	383	15	4	2023-10-31 17:27:34.2	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
385	\\x3fc13b7bb1cd36409fdd8a018c2384f8a64a88471875704ebbba7c214e19c73c	4	4013	13	380	384	16	4	2023-10-31 17:27:35.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
386	\\x131d66c149dc3d50d5eaab164a3f7a794bf9f18cb551cede6ebdbfe1365ccc74	4	4021	21	381	385	5	4	2023-10-31 17:27:37.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
387	\\x72b9d81aa600470c9b1c7b325aa806d9292eea17c65c0bcf67144ec6ff123ef8	4	4051	51	382	386	8	4	2023-10-31 17:27:43.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
388	\\x3eb30301eddb09670d2603c5f2dc8418fb4fa027addef6cb7f250990ec747a9c	4	4052	52	383	387	4	4	2023-10-31 17:27:43.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
389	\\x5ba190b246d2058f632afc2deb1455b4b0ae5fbbbfc67e14d034b76ee7af3c66	4	4062	62	384	388	4	4	2023-10-31 17:27:45.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
390	\\x2abfe776cd134ca6b7510d5cacfd2d7ca9411737a4ec3307f469d7972383c337	4	4065	65	385	389	18	4	2023-10-31 17:27:46	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
391	\\xdf4db8a7ae208f5071a414d3ce03cd49602f3d3b4ec8f1bd19b55480610a2156	4	4068	68	386	390	8	4	2023-10-31 17:27:46.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
392	\\xdaec5121ec8fae22ba2e05eb996b1cf19aa468989cc8f1a4c34c53da6f21c07a	4	4107	107	387	391	7	4	2023-10-31 17:27:54.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
393	\\x2ea82d28b479c8942e049cc6f66155508acc5a1e33bdecb7f1523f4efb4d7a3f	4	4114	114	388	392	4	4	2023-10-31 17:27:55.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
394	\\xcf7aa2c845c502f23f3ae8366fd867a459de32f1405382eea39175bf33b05e67	4	4116	116	389	393	8	4	2023-10-31 17:27:56.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
395	\\x7307040ecdecafb5436a0c811d624969c7cbfa706bc891ab16b0a54b8b23fbb9	4	4123	123	390	394	3	1704	2023-10-31 17:27:57.6	1	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
396	\\xb5bad954bcef368484b0ff16de8ecf25a13134064279648bd2e29f50deb53543	4	4147	147	391	395	16	4	2023-10-31 17:28:02.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
397	\\x103584ce7343d576c49febf20018d1c3669a7da0b2b5223ff7c5ff0d48486add	4	4148	148	392	396	15	4	2023-10-31 17:28:02.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
398	\\x0fe4b233cba11ccbf2ace3e9bf1e1ab05f05d00d3238556fe4ed999bf775f38a	4	4151	151	393	397	15	4	2023-10-31 17:28:03.2	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
399	\\x13b49ceccfcf4a5d561a121095a4ea5011ca6fe2f2ed73b3ce11012d9c01a81c	4	4170	170	394	398	8	430	2023-10-31 17:28:07	1	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
400	\\x5add286263e4cf904fff373ee1c31813792b2fc0efc3f2c32553ac6b86e6afc0	4	4192	192	395	399	5	4	2023-10-31 17:28:11.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
401	\\x10e3f50fd551220a02257076a8f0bf8b9f338e0d7f52e606c2a0bf5c560fce19	4	4198	198	396	400	3	4	2023-10-31 17:28:12.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
402	\\x13782cf31e4c6287a0e0c27f694b6ce9d012b2052ece2c4a8cb314720b1cd646	4	4204	204	397	401	5	4	2023-10-31 17:28:13.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
403	\\xf3e1cc2945b746163dd4ea9a851597b2c1cceed1061b76e2cb76edd8b753bdc7	4	4207	207	398	402	14	352	2023-10-31 17:28:14.4	1	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
404	\\x0cfd276fada1044f237d25a0d3bc7dbbb6a9a347220fdc13821f8d9295446146	4	4230	230	399	403	12	4	2023-10-31 17:28:19	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
405	\\x3fa1082e86fd972a04accd5b7a7085f7bdd66fe72508999e8ce2542fdbfba6d4	4	4253	253	400	404	4	4	2023-10-31 17:28:23.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
406	\\xf7679edd3b7dfea5761940ed1cb94436e16ca6c14ae87cd30164d0e230e2ff2f	4	4268	268	401	405	39	4	2023-10-31 17:28:26.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
407	\\xfe8f9d15555c8fc7dcb8132ad9002e6b08184a7d7f94700fdca2ca996ba373cd	4	4269	269	402	406	18	321	2023-10-31 17:28:26.8	1	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
408	\\x1850768d7141524d4a935641acb934a4019b9d78cd53288dee8be74d8e6daf52	4	4272	272	403	407	39	4	2023-10-31 17:28:27.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
409	\\xa4fa68edd6f22baf113e5d9a243d064e6bb75baf5c24769906a108a9b0e678ac	4	4273	273	404	408	3	4	2023-10-31 17:28:27.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
410	\\x690ad390d59d4e50734b85d45cf937c1a2d47c9b39713be921d22ef2fe5b69fd	4	4278	278	405	409	16	4	2023-10-31 17:28:28.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
411	\\xaabdba6632d84f13e5bf81978d25d956bdf22e078f1a4760801ca34e86cb8317	4	4296	296	406	410	4	401	2023-10-31 17:28:32.2	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
412	\\xdcefce93c1182d0ed0738b96e8f6ca5e0f4528b757d2fbca1e0cd1cbbd5e63ce	4	4316	316	407	411	14	4	2023-10-31 17:28:36.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
413	\\x92075579ce54712809f7b9ebae4b88b461a0e8acd6fb907931327cf1a2d4a586	4	4325	325	408	412	15	4	2023-10-31 17:28:38	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
414	\\x34fa575b8c951569ed91de52ca9f16c50da231512a1f578e0b6cb72b7b1391fd	4	4338	338	409	413	8	4	2023-10-31 17:28:40.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
415	\\x663aa625494aaa996ef77c69a17698ec433cbedd57dd1eb64230c826e5a6e226	4	4342	342	410	414	4	749	2023-10-31 17:28:41.4	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
416	\\xc71371ca20f689df4f66c55916e6edf2c23335c9755aeb6f033bce1beace6dd5	4	4345	345	411	415	39	4	2023-10-31 17:28:42	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
417	\\x2513e9446de76a2b98761013262bc9e5f79ef159ba0613cdaf22034f817413fc	4	4350	350	412	416	39	4	2023-10-31 17:28:43	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
418	\\xd2de244b0c952b7787e1345a0a560da06d7201f9085258779d1376672c76faa3	4	4369	369	413	417	15	4	2023-10-31 17:28:46.8	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
419	\\x0faf0c78bba9c3ee2de9c1ab1415e0febc4c197f0d18ff9ea07b9d4a545628fa	4	4385	385	414	418	15	827	2023-10-31 17:28:50	1	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
420	\\x632b1b43076e58954ec776550ceb3215206d176940dd33a666a142f07cdf6f83	4	4392	392	415	419	39	4	2023-10-31 17:28:51.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
421	\\x3dabdf27cc7ecc7ae02117ee54947b693125686b791c796049887127423bfaee	4	4398	398	416	420	14	4	2023-10-31 17:28:52.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
422	\\xcc677f892393c142485121dd90415a4774f250aee92cd23fcded3797042eba50	4	4419	419	417	421	14	4	2023-10-31 17:28:56.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
423	\\x3413e788bffd725184a0a56e0a070de267c72a8973df8be25906f761ba0f89f9	4	4424	424	418	422	16	340	2023-10-31 17:28:57.8	1	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
424	\\xe1f17f75c6e8cde2c0ef4c374d8dc30b776e28418049b2114aa2570a849a4d63	4	4447	447	419	423	15	4	2023-10-31 17:29:02.4	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
425	\\xbfbcaa77499a20c301f9ed9ce1750516db2a7338b7fd01a2f69b8739fa105d2b	4	4459	459	420	424	39	4	2023-10-31 17:29:04.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
426	\\x570731d246920642b48fb2ab3fa29aee3cd342a20a923b35d322fe1bd88952cf	4	4468	468	421	425	15	4	2023-10-31 17:29:06.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
427	\\xa95041e570710aeabd025d2cd4d09ce99a40116a9d91f5614d50d8a6fffba47f	4	4484	484	422	426	18	749	2023-10-31 17:29:09.8	1	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
428	\\x20f2fb7aacb121d139f51d6690d584629e2d6c3b5d79af5bd8ecddc402753dcd	4	4485	485	423	427	39	4	2023-10-31 17:29:10	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
429	\\x02d59ebbe52244febc2541e395889d79e7056a23b7ab11a16720eda96b9a5fc2	4	4507	507	424	428	4	4	2023-10-31 17:29:14.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
430	\\x6462d310cff954e4e93c6342ceaded236541f933591467d05710535801cf1bf3	4	4521	521	425	429	7	4	2023-10-31 17:29:17.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
431	\\x1371eef0d2f2de6869e0b1615db25130b6a064197a25080ff5f4bfd01874e541	4	4540	540	426	430	12	300	2023-10-31 17:29:21	1	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
432	\\x0c3751e1e094e791e73a1ab36c883b559aa5ee534190a87508c083fbd99c7921	4	4544	544	427	431	18	4	2023-10-31 17:29:21.8	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
433	\\x72ffa41f69e7a14099df3977dacd160626ea8434777e141d3a79a8a22720778d	4	4559	559	428	432	18	4	2023-10-31 17:29:24.8	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
434	\\x25096cb06bcda8eb2e6cb9a5b9e1dc60ea36ce0a8d6632400b7f2538f177bab4	4	4568	568	429	433	18	4	2023-10-31 17:29:26.6	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
435	\\x1e6cac5b4103f778c14ec4a3b632c926b5505db9fd63ea0171111bc3265f266c	4	4574	574	430	434	3	785	2023-10-31 17:29:27.8	1	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
436	\\x05aa1667ca3f7e62fe0bca1f4d510cc200a085a01c43aea237598cc96ad506c5	4	4584	584	431	435	3	4	2023-10-31 17:29:29.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
437	\\x6c4716218e9abf4e67a6328bf0fae6a077e033eca76c6a74abe78354782bc731	4	4595	595	432	436	8	4	2023-10-31 17:29:32	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
438	\\x5b79504dc29e4b98965da66f6f94d343fed6fd201e2cf8208542158a61421b50	4	4598	598	433	437	12	4	2023-10-31 17:29:32.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
439	\\x99974e7ee3e145a0653ef9026cddefc30e986b8d44ea16e80c12b9410542109a	4	4602	602	434	438	12	342	2023-10-31 17:29:33.4	1	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
440	\\x0ce60655481133596e97a4e1cff1100c3458941c134c49bc7788a5169960e9ee	4	4618	618	435	439	39	4	2023-10-31 17:29:36.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
441	\\xb4b35bd50fb9588a453f6312a4bb7cef8ecc3d8469dfb1777960710ffe55b679	4	4630	630	436	440	7	4	2023-10-31 17:29:39	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
442	\\x49125ca7c5242292ea6c02ec49d2bb2ec97b861b3259e3e7b3b5921ef7a3d030	4	4636	636	437	441	3	4	2023-10-31 17:29:40.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
443	\\xf8e5d6b6382fbe08426b2eb0c150172feb082b6d1903b15646552e95050e85f6	4	4650	650	438	442	39	300	2023-10-31 17:29:43	1	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
444	\\xf7e4e18bd4ebeee9db2ae3c3a5e23d7de249e5a6330edeaee518c954a91d72b3	4	4661	661	439	443	15	4	2023-10-31 17:29:45.2	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
446	\\xd280ca84652c209fa7d0c5e669946ed88a889e9ae3871b9c4d912c7eb866e7b8	4	4673	673	440	444	5	4	2023-10-31 17:29:47.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
448	\\xa4c361031db9f6a7d9cbd9aeada4341eebdcc034bfac52f6c9c6876a824609e7	4	4674	674	441	446	18	4	2023-10-31 17:29:47.8	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
450	\\x07c2744eb51da98dd1d6d3e31f07d54c231e0109c10b1f90f51c04ada500fb8d	4	4701	701	442	448	18	1104	2023-10-31 17:29:53.2	1	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
451	\\xdf2cbb7dd441563f7d80accbbebf4143786635976c4e9a8ec146745eecf1a012	4	4705	705	443	450	16	4	2023-10-31 17:29:54	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
452	\\x3e8b569083d81686eb179cd80e1ca2beec16c4d2c3ac6e5c2a3d60084ffe91f4	4	4732	732	444	451	5	4	2023-10-31 17:29:59.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
453	\\x24163e0d72258055be63ea4197468afca04d1896384ed0e2b942cf0605c05f1d	4	4766	766	445	452	39	4	2023-10-31 17:30:06.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
454	\\x3092f61d2954ffdac2088579d87f478278c51ee48733f9a1ba31994613284d3c	4	4770	770	446	453	7	562	2023-10-31 17:30:07	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
455	\\xe8a2d8c260951575ff70192c37e9bdb2eec984c48a9d045555783360a510dcdc	4	4781	781	447	454	39	4	2023-10-31 17:30:09.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
456	\\xfd027225f80cebc1ace81a82a1fd826efb94380e9a14708321ceab97cf8ca47c	4	4783	783	448	455	7	4	2023-10-31 17:30:09.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
457	\\xb0b9d3c260d4ebb64b7cf3eba96feaba9e8d9c4298dfc32a6b2402cc53032f17	4	4803	803	449	456	16	4	2023-10-31 17:30:13.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
458	\\xfcc85aa819efc9866eaa5bf448f26b10417d2ce81020bd97fd90d110b5f88bbf	4	4809	809	450	457	7	754	2023-10-31 17:30:14.8	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
460	\\x8bd62e2fe74635fdb1886d20d919036bb764f1176722e5b6d3a23fc6250d18b5	4	4832	832	451	458	16	4	2023-10-31 17:30:19.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
461	\\x011defa8b303c16bec1bc53a1dfb1cbcb4024f8c09cefc45595e188281a52c9b	4	4843	843	452	460	16	4	2023-10-31 17:30:21.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
462	\\x95bc83010dc3bf16c5eb1d126eb3e2afd5bceb336592d073e4310be3302ec25e	4	4851	851	453	461	39	4	2023-10-31 17:30:23.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
463	\\x3bcb83c993efd6aff4040f05e5aa8f5c389d01df77a71bab56e052901bb3ab8a	4	4852	852	454	462	4	763	2023-10-31 17:30:23.4	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
464	\\x38fc37623e8ac766a798334f98c35b6205f1d10bb1360bb45a7623c89bb3e2ef	4	4853	853	455	463	3	4	2023-10-31 17:30:23.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
465	\\x22bc6748c96ab03324da4d1eebc3e88cc9ebb22051aa4c86c4d8a0a38eb83005	4	4859	859	456	464	3	4	2023-10-31 17:30:24.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
466	\\x2dae917992ff616411f83426cfdf086d43e297c67b41b693cf11e98408280752	4	4868	868	457	465	18	4	2023-10-31 17:30:26.6	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
467	\\x32d79f2a9bd6a3670b5255dbddf2f9843e5a2b993467172c68decba8e2612121	4	4873	873	458	466	5	762	2023-10-31 17:30:27.6	1	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
468	\\x3e0bf396f8db4659fd25f12b63f1669663cb933e985b32362c04ef627e87b973	4	4875	875	459	467	4	4	2023-10-31 17:30:28	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
469	\\x8c964563afc7a922943ce85887467296c9e89282186f5fb9f7b7b857856358a8	4	4877	877	460	468	7	4	2023-10-31 17:30:28.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
470	\\x1d151400ccd1facfa3006655691b3c78537a61d6872d3fd690581b26c86494f5	4	4884	884	461	469	5	4	2023-10-31 17:30:29.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
471	\\x0d47715558895a4698a19f8d1fc33622cfc60f9ae23d1131284abaf8e26d6a6f	4	4887	887	462	470	3	539	2023-10-31 17:30:30.4	1	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
472	\\xb66d9e14f44096d7507ac3faee5928d1862c6d4f655873ff37d1bc7f3d3c28da	4	4889	889	463	471	15	4	2023-10-31 17:30:30.8	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
473	\\x2fa0c03eeab5ee2c1c1e699cf815b3f17bd14588b8bb84382b5c6b87578d574b	4	4898	898	464	472	39	4	2023-10-31 17:30:32.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
474	\\xd816be50c26898b3d7295d4a7ec596dc69a2db5c56218df13afce6e3b8daeb3a	4	4900	900	465	473	7	4	2023-10-31 17:30:33	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
475	\\x9ab8201a4ac29e767d58e86ba0401894f1516a9ee16b86725154927bfb380f7e	4	4901	901	466	474	4	4	2023-10-31 17:30:33.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
476	\\x936a2d6373504969d3e1f6047aee431a70ee1672c5b9ee6b24d5da0d153c31af	4	4916	916	467	475	39	329	2023-10-31 17:30:36.2	1	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
477	\\xbe59b54c638a7eaf1c3b03df25ccc5e9281d37e2c7f69cc9b22cee74b0be0cbd	4	4919	919	468	476	5	4	2023-10-31 17:30:36.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
478	\\x009cf822473fe313ff9af5d43b476f687e4ec31555e4868ffee5d16924f983c7	4	4923	923	469	477	18	4	2023-10-31 17:30:37.6	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
479	\\x820dfd2efe1ce31d40c357e9526831f95cf07f176dec3091fc9b18b0d1a1d900	4	4940	940	470	478	12	4	2023-10-31 17:30:41	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
480	\\x253c61258a4eea5fad75f65d5f1ee54d97da4ead6bc4d9df4d2db5ac057b945f	4	4943	943	471	479	4	3850	2023-10-31 17:30:41.6	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
481	\\x4285c1b5679a93bdd6a0f7a031f46d8c7e89e6fd2d38970a54e2384ae1671afe	4	4954	954	472	480	16	4	2023-10-31 17:30:43.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
482	\\x8caa2fb41fa53ba369a46989a04d5262f107b278249a0586c8c8b32fb43662fc	4	4966	966	473	481	16	4	2023-10-31 17:30:46.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
483	\\xa4d85cece612ee3deb14559d07714fb05246b30c6bea49918f0710945484c312	4	4972	972	474	482	7	4	2023-10-31 17:30:47.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
484	\\x7e1afdb4f0824e549c6cb00d63f91eda733cb02d624636a06fc9243ca3d50b52	4	4992	992	475	483	5	2398	2023-10-31 17:30:51.4	1	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
485	\\x0855171481368133c85dd20a055fd4d959ed21b7c7a05652dc5f96825c7f20be	4	4994	994	476	484	12	4	2023-10-31 17:30:51.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
486	\\xd659abae7d05d49a612399e39c94225c04cb9f34ae61ab9282b9afbd4e7f97d0	5	5011	11	477	485	5	4	2023-10-31 17:30:55.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
487	\\xa39747a3837af0728ea3ad66f47c68ca6c098d63081ee9297102f8bffb3cd3d9	5	5040	40	478	486	15	4	2023-10-31 17:31:01	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
488	\\xb1b86a448ec940b3ddb3a9cb6f442c42b4b89a31d0a19b03dc77a81689b7752f	5	5046	46	479	487	39	1051	2023-10-31 17:31:02.2	1	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
489	\\xf5d01b745a60f6ef64ed7d35f6df21a561922891cdfd4e47de532111bebac633	5	5048	48	480	488	15	4	2023-10-31 17:31:02.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
490	\\x9afc0b206d33f3674ee23f6b0a81c2a8d8457878c1cd2768c9c20027e6021a28	5	5050	50	481	489	5	4	2023-10-31 17:31:03	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
492	\\xf267020d1293e2f93158dfe7df33e0ddd77ccb956bcd8ef405c9d10526c654dc	5	5055	55	482	490	14	4	2023-10-31 17:31:04	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
493	\\x157e3ba9b5a66cf9ec59b96e2f76631d26899d2ffddc5e6ecf49cd8d8e4f2492	5	5056	56	483	492	16	4	2023-10-31 17:31:04.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
494	\\xaa754dddbffe39dd89b790328b5aefc97c610eac6f1dd33ad8a32ca176072376	5	5076	76	484	493	12	644	2023-10-31 17:31:08.2	1	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
495	\\x553129f281da31845b5779abee22f109fa62d64f2b5d4f2b0e08c7415647c75e	5	5080	80	485	494	15	4	2023-10-31 17:31:09	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
496	\\x7b45ec5c88bcd9e618fb02f4d78ddcb388ba6534f0194a4b9d23e95389620648	5	5106	106	486	495	12	4	2023-10-31 17:31:14.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
497	\\xc5ea64d7b163b3edcdae5c9f1b2feb1b9837737ff6ef9ef5cc7692382ae41c91	5	5119	119	487	496	18	4	2023-10-31 17:31:16.8	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
498	\\xb7346e54f10cdfa3b2c9cc3a741d30c0e9d1a681881dfd320efb66d92bc8997d	5	5122	122	488	497	18	535	2023-10-31 17:31:17.4	1	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
499	\\x952f2e092c15ed38bd1a06a12dbfb3295298b3b02f3f60cbbd74f7d438359c65	5	5129	129	489	498	3	4	2023-10-31 17:31:18.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
500	\\x0e48599f91744b967653391ef4679c69522656410b12476617bda4137c54db25	5	5146	146	490	499	8	4	2023-10-31 17:31:22.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
501	\\xcbf4980e9e64b4a6f375deb0acdddb3d6a6fba1b17b5e54e4d779d0fce4d4f16	5	5165	165	491	500	5	4	2023-10-31 17:31:26	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
502	\\xa40b87ea45bd7c9b34e04b986832f3f0627d7dd889b55a17afe38e9c806d0cb6	5	5167	167	492	501	18	4	2023-10-31 17:31:26.4	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
503	\\x369f4cc0b784e667299b012366096fa6aef74f72acbd150788c68bf1fdb78c55	5	5178	178	493	502	3	537	2023-10-31 17:31:28.6	1	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
504	\\x1a03aa1e20aa914894b4626cb8908131c503bef91324adc0c15fd134d3bbe683	5	5182	182	494	503	14	4	2023-10-31 17:31:29.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
505	\\x5c02336871bacb4e049b49a8c0707033728e33f18db26102e37db1d240a9fc65	5	5185	185	495	504	39	4	2023-10-31 17:31:30	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
506	\\x67e1e75e1a25c76138b14ed84c2657895f9069fc813c2c6a285d5ab94c0a7955	5	5208	208	496	505	15	4	2023-10-31 17:31:34.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
507	\\x0031d674076e4cf04d8261f77bc16fbb4675998bcdf6b19fa77922e8308af938	5	5223	223	497	506	7	397	2023-10-31 17:31:37.6	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
508	\\x8a2d25d5cf829aadf12ca78485f8f9b04915943ac51d6ef91ada25c323db1979	5	5231	231	498	507	3	4	2023-10-31 17:31:39.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
509	\\xbc746b3ccba7d8aaac046274a86168ed118f060560ad7788b6d1c898a6bae987	5	5234	234	499	508	18	4	2023-10-31 17:31:39.8	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
510	\\xb3561ac41ec9deb7114b88c250dfb16f5344a3442713f95c50f824f5a06eb83c	5	5245	245	500	509	3	4	2023-10-31 17:31:42	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
511	\\x52f5c2b6788425ed9464370fa38055fa59a2add2e732d19ce7d8c535b129e088	5	5259	259	501	510	12	662	2023-10-31 17:31:44.8	2	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
512	\\x9455b6af0e79d43217fbf333aab8e1d9886fe37e967eb7834728ca151eb71de4	5	5262	262	502	511	15	4	2023-10-31 17:31:45.4	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
513	\\xf0165513f2a46ed26f41d095dc876086678119313d2f13a3b2335104d6dcee34	5	5263	263	503	512	8	4	2023-10-31 17:31:45.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
514	\\x363114aa980a9cd8bb1dadd58a0694453c268de88f55a41c6e5b7272bf7c8061	5	5267	267	504	513	16	4	2023-10-31 17:31:46.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
515	\\xb4870e68cc1183fa18ca82f0c567641a0f562593a0b98f80b547b5c278f65efd	5	5276	276	505	514	12	4	2023-10-31 17:31:48.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
516	\\x0dab714bdca070e008f96a37ea8c4b370f0721e75858caaf053e1347c3b5f318	5	5278	278	506	515	4	4	2023-10-31 17:31:48.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
517	\\x95eb4f908f4abdffc2184d92dddace2d9e1985e4911a5ef682fe292a36a5d494	5	5294	294	507	516	12	8200	2023-10-31 17:31:51.8	1	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
518	\\xf9ae5bdbd4a1ca1a7859205e656e7c36591173701648cca434d5fb675522bc8a	5	5295	295	508	517	7	4	2023-10-31 17:31:52	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
519	\\x69f380965b56a80d8530694ba001e28f9c3db0f1444d26d455ddf3a98be3fc9e	5	5298	298	509	518	8	4	2023-10-31 17:31:52.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
520	\\xf7622d4db63173ad3074678901cfb9abf299531fede5935f6608b063c710fdf8	5	5302	302	510	519	16	8410	2023-10-31 17:31:53.4	1	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
521	\\x8962cccaa8955311ba1970bd3bce01a220464356d8d84c4f5943527b276c55fd	5	5306	306	511	520	12	4	2023-10-31 17:31:54.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
522	\\x9378165df06fc4e81ca0848339c85a405c98d26ad3998962a105e293e4d33fc9	5	5316	316	512	521	8	4	2023-10-31 17:31:56.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
523	\\xf38b2a9b5db14103156a61f6c4b83fbca3bc35cdcae81ba4669743d02b04a11f	5	5317	317	513	522	3	4	2023-10-31 17:31:56.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
524	\\x43f3e4e75c1d9c53bcf436b7dd0f63900d10f0dbb85c71770678083a270fdb9a	5	5326	326	514	523	3	4	2023-10-31 17:31:58.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
526	\\x9d7bcf313953aa37e66b44c2defc70764daccf96c6afef493a1ba389b474ae70	5	5328	328	515	524	3	4	2023-10-31 17:31:58.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
527	\\xeca0d41e8a76f125f446468bcfebf26d87ec2cf1008b18e17e19856b91272d49	5	5340	340	516	526	7	338	2023-10-31 17:32:01	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
528	\\x2df1a6f1de49df46fea1e6b76f3da7cbbaec587a8ca59e296592478a26fa78ee	5	5361	361	517	527	15	4	2023-10-31 17:32:05.2	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
529	\\x4f8ee656de8fee91b2fcb38bb57ee45c5cde330a5c6c4dedd6ad31563fe42087	5	5373	373	518	528	8	294	2023-10-31 17:32:07.6	1	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
530	\\x95f536d6fa01e9581b197064e5943d66502e839d21f3da9df0c77b31698b2722	5	5377	377	519	529	12	2620	2023-10-31 17:32:08.4	1	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
531	\\x097e2721220fdbea3a6ab6b8bed54dabbed68c645ae7e47fa9498a3a120063df	5	5400	400	520	530	39	329	2023-10-31 17:32:13	1	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
532	\\xb1bbb1b1fb43d81aa3266dc3b3edc6af895660914680964850c9ed5b94607b21	5	5434	434	521	531	8	293	2023-10-31 17:32:19.8	1	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
533	\\x082bdb8fc89c6d2c929c26a50c3bb6ded0519940757bd389528bfe16f897b632	5	5447	447	522	532	4	2363	2023-10-31 17:32:22.4	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
535	\\x4bb7a3dba423d270b65c9ac464b315005c45b6d5f571a2f84a98b4b747e5fdef	5	5467	467	523	533	4	608	2023-10-31 17:32:26.4	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
536	\\x27d827eec68d714f4266ca48e3ea9ac6bd24139ea19487608c2a1aec31225ad8	5	5474	474	524	535	14	365	2023-10-31 17:32:27.8	1	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
537	\\x6c22f9fb71617cc0c8e6b0f3a2a43df8355002de7d34394cd153d0be18c46ef4	5	5495	495	525	536	7	280	2023-10-31 17:32:32	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
538	\\x61cc53303c5cf9c45e4a9e61446c86f46a6734476ab86b77ec5c0d687bead4a6	5	5507	507	526	537	4	4	2023-10-31 17:32:34.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
539	\\x27dee7f642a6f18119aede2ce34e92a6f4863114db7556e35a1e56e65e01bd40	5	5520	520	527	538	14	4	2023-10-31 17:32:37	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
540	\\x128c5b83ce5283d0ee8455d8d081f95f460cdfd8977bdb58a8685881977ddfc1	5	5536	536	528	539	5	4	2023-10-31 17:32:40.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
541	\\xbe9788296b10b0c5e55a8605b6cf61e28c605ce83ff361c8c78a15e6e07d9ca1	5	5537	537	529	540	12	4	2023-10-31 17:32:40.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
542	\\x369fa9b597fd41b4b1ca57d8463b79fea49ef22b0f6b9e251e795bf85cd4b087	5	5544	544	530	541	18	567	2023-10-31 17:32:41.8	1	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
543	\\xf06274748de9d49b1fe280d1aaeb5a62a06edb4f611441e6ab8e7daafca4829b	5	5555	555	531	542	16	4	2023-10-31 17:32:44	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
544	\\x8c53c2502a686d170605f67a4c31869c2592a379c310b55a23f03a2fa9daa64d	5	5559	559	532	543	8	4	2023-10-31 17:32:44.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
545	\\xbf1a408d3554c764effb5da6e06031c17ec78320af31d7aedbca57ce79457fa1	5	5582	582	533	544	8	4	2023-10-31 17:32:49.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
546	\\x4f8e435b8331150e54860e229ec7773f52f9b008a9407e3e46ec2a9afb98d5b3	5	5594	594	534	545	16	4	2023-10-31 17:32:51.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
547	\\x588888af8d61c24ea3719a80154869749e5373aaff279c0886c65b49002c5c3f	5	5595	595	535	546	8	4	2023-10-31 17:32:52	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
548	\\xfba12009113cf8d14266185a4d2117d4217dd2f4b09a7d14532d14e989a15d89	5	5609	609	536	547	14	4	2023-10-31 17:32:54.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
549	\\xf3027a2193c265a6c04c194f8136e2dd0f512957b4f7789bedd87286c5b7dc91	5	5622	622	537	548	7	4	2023-10-31 17:32:57.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
550	\\x49aad675962c68413ef684b1fc402acd01235757a5b6b9d396730bc05ccf2300	5	5624	624	538	549	15	4	2023-10-31 17:32:57.8	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
552	\\xa4dddf6440a8c959f41a811303369dcc40ca123ddaeac65d1f0a0c1760358beb	5	5626	626	539	550	4	4	2023-10-31 17:32:58.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
553	\\x233e9717459149aec30af24b68f88a0f21d61b353c2a9d165051eae34f31f3c0	5	5635	635	540	552	14	4	2023-10-31 17:33:00	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
554	\\x7eae81a7560f92fc082cfbeb22f3ad26bf50b8d4b826f2640944c89cc0641704	5	5637	637	541	553	5	4	2023-10-31 17:33:00.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
556	\\xb70f06712c4bcbd625c459da13e03c89dbc92cab452bbac9aa83595ed93eaa26	5	5638	638	542	554	16	4	2023-10-31 17:33:00.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
557	\\xbf245f30b59b37a03616fe63b96d9ec1fa303f01c22d1b879e4c97b534036117	5	5642	642	543	556	3	4	2023-10-31 17:33:01.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
558	\\x48a205e6c8b4969eba524efad41478dc6d4d176c2891ba631c9a9971ac353c13	5	5644	644	544	557	16	4	2023-10-31 17:33:01.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
559	\\x6d0cf1f93735b97b845d10ce2c0c761da19572789b13a65ef8ae29e10c85c8be	5	5652	652	545	558	18	4	2023-10-31 17:33:03.4	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
560	\\x162ee1091675ab763df20c345f0698d16a678af53bf2a5217fe2aa7daece1a2d	5	5656	656	546	559	4	4	2023-10-31 17:33:04.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
561	\\x4d373b5869beae122aceda889efbe9cf0eed2011c747190dc13de863e961b38e	5	5659	659	547	560	39	4	2023-10-31 17:33:04.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
562	\\xda5ba6dc86ebbb17ccd6be6a51d37324787687d95ecb61cefe91a1621ead903d	5	5667	667	548	561	18	4	2023-10-31 17:33:06.4	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
563	\\x8bce9edc347c114bc2ec9b89cfceed60c09bf131d2047ec3c4ebf400efe6f2b2	5	5676	676	549	562	39	4	2023-10-31 17:33:08.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
564	\\x0bb23102cb0d194834c8788ec243581ee6ee3fcd894a9a7943d15c157ace8237	5	5705	705	550	563	4	4	2023-10-31 17:33:14	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
565	\\xe6ae066580f0c93640624aaaeec3d64552e63a38a280a4e96a04b758bb69f759	5	5749	749	551	564	14	4	2023-10-31 17:33:22.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
566	\\x9c0ca27910292bd3d2ccfb02d44c50c55cd3b29bbb6375194c1203048b41c4ff	5	5767	767	552	565	8	4	2023-10-31 17:33:26.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
567	\\x99e952be9aad24ebfe6ef765b26612651638ded5842fc9d1b268880cfdae9cd0	5	5770	770	553	566	4	4	2023-10-31 17:33:27	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
568	\\xa733a48af44de066e2ef7c251083c3a5c192932c9af45528c96f3c0118d217a4	5	5774	774	554	567	7	4	2023-10-31 17:33:27.8	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
569	\\xf8911b3a890487a9ae36b7511abe0b65bdfad68eb33479b7798d2729c2e2c1d7	5	5784	784	555	568	39	4	2023-10-31 17:33:29.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
570	\\x8c93024ec91cd57d492adb865d0e2c4cc68c9f15ac0c99b414b60fc6c47dc45a	5	5804	804	556	569	4	4	2023-10-31 17:33:33.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
571	\\x00756a4e223a4008226290ab55992d5ccd98b274a030732ac0a6220a74f1076d	5	5810	810	557	570	8	4	2023-10-31 17:33:35	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
572	\\x024c0e319c494587897d7115d2fd515f53f8e7a30ca58855ab35cca22685a828	5	5816	816	558	571	15	4	2023-10-31 17:33:36.2	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
573	\\x153a8c3b42eb4f591184fbea3d231764043541d741a3a7ec0a6a0bb85b1b0582	5	5844	844	559	572	15	4	2023-10-31 17:33:41.8	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
574	\\x2b190f1779411c5d6345d48b3df73d7b0297d8b2074af7fd2d93943b6450cc59	5	5845	845	560	573	39	4	2023-10-31 17:33:42	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
575	\\xff1e88e3836d57d47ae56a7afab47fc28d7e26b2f0c76679b754df242d5d44eb	5	5855	855	561	574	15	4	2023-10-31 17:33:44	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
576	\\x6319125fab7fd92d2d66e974cab79cd91127a31213fe474f0cf8d411ad0f4fb7	5	5880	880	562	575	7	4	2023-10-31 17:33:49	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
577	\\x3f89591134162b55012bb20ed8e5cd7607ce2de836b793deb4afb9af35ff41c9	5	5891	891	563	576	15	4	2023-10-31 17:33:51.2	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
578	\\xb8123192d12306ddc86f99cd3e5aaf6e1684a5e6b8eb6e6560bf98ea0aa813d6	5	5902	902	564	577	8	4	2023-10-31 17:33:53.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
579	\\xec65c2deb589b83cf71757be50627ec50ee1bf3ad273eb3e7a56c64e518fbbf6	5	5908	908	565	578	16	4	2023-10-31 17:33:54.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
580	\\x6a800d5f7800528bcfeb00d6b4c26158fe8ba294c921b6e9f880e20941eeed65	5	5914	914	566	579	15	4	2023-10-31 17:33:55.8	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
581	\\x63ca99176ed1552b8e15558f5639dcce910171acc22913bc1323f8924ebc3d29	5	5922	922	567	580	14	4	2023-10-31 17:33:57.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
582	\\x7fd3ab8d68dce496fd51ddc59ea6a9707f3f214fde6daa8d7462d56b18bebfcd	5	5923	923	568	581	3	4	2023-10-31 17:33:57.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
583	\\xe09f39b6eb4091a857650c06d6075329f0c0da1eb1eaa8d2546e8dd9ab2e0d2d	5	5940	940	569	582	15	4	2023-10-31 17:34:01	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
584	\\x1e90406fb261265802d8a594ad5f86853eb0a47e5e03cad846c2a853c02fa2e1	5	5945	945	570	583	3	4	2023-10-31 17:34:02	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
585	\\xf04671a67add16f3f605188b4f17cb8c85ee033f7916a98802485be24df0f876	5	5949	949	571	584	14	4	2023-10-31 17:34:02.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
586	\\xa8cfdae1ad6c5f2d07681085c331270ca04794966fb601a701e075d2b892ec79	5	5950	950	572	585	5	4	2023-10-31 17:34:03	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
587	\\x28a0395afe925cf63c5492b320f68c548e4e80039854a625d300db950c66ef9f	5	5960	960	573	586	12	4	2023-10-31 17:34:05	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
588	\\x6155e8b763da959cf0408ff66294c1106686ffd70d9587ccf31250a04afbc3be	5	5983	983	574	587	18	4	2023-10-31 17:34:09.6	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
589	\\xf91d306a2345e53251190537120b8c6ba6dd0a9e35b0e955a532c0a1f1363bf9	5	5985	985	575	588	39	4	2023-10-31 17:34:10	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
590	\\x048806551e43d63aa474fb40f3b8dad27ce1a37f1b496777559fad79ff01a3e5	5	5987	987	576	589	4	4	2023-10-31 17:34:10.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
591	\\x4dc919854eededc3baee311378c5530244dadc31ac8fff030d1f58dcd0697ece	5	5990	990	577	590	14	4	2023-10-31 17:34:11	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
592	\\xfa9c7d3297df1c4b93618c827d1d2b58f2656f0d35ef12e6b65bdcbc99ff41f5	6	6013	13	578	591	16	4	2023-10-31 17:34:15.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
593	\\x0add17ce53ff966d51821f6736bba47fc6e37773b4a691d49a33f48498711d85	6	6023	23	579	592	8	4	2023-10-31 17:34:17.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
594	\\xa156a878b88e0d4f6780d5f40ab814945e70dbc64f2d098ebdb4011ef9d02704	6	6027	27	580	593	8	4	2023-10-31 17:34:18.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
595	\\x1fb1eb000b33390abb3820f6092ecba3e5b10a3ee8bd11ef42e64f74b2f2d865	6	6030	30	581	594	7	4	2023-10-31 17:34:19	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
596	\\x1161cae12741072171715946c7bec6c0a11f84c8092f4fed22795ef3bc894cf5	6	6034	34	582	595	39	4	2023-10-31 17:34:19.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
597	\\xa30593fba6081dc7dd37972084d0893e24d00f7261f66dc385bbe630f522d96d	6	6040	40	583	596	18	4	2023-10-31 17:34:21	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
598	\\x26502773e2ad9e6f10dd8a6a71ec552a6c1abc8a0edb13ded9d03e2855bbf672	6	6080	80	584	597	39	4	2023-10-31 17:34:29	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
599	\\xe6a63bf4fbec16e204e6ab04fafdd2aaf5e825ea02f5aaa4096bd26b5a066bb5	6	6092	92	585	598	14	4	2023-10-31 17:34:31.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
600	\\x1d96608a7ee62b6be01e700c06f4ad9bdd89671065d175e41dd60df782938c40	6	6123	123	586	599	18	4	2023-10-31 17:34:37.6	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
601	\\x8effaa0bc1039a197a90fee2fd07468ba79d8c1a2898e4f5711a4d9578ef036b	6	6167	167	587	600	5	4	2023-10-31 17:34:46.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
602	\\xfc993b5caaf5f520c3860a7d2803431cc13e7a1a7873d284029a18cab8071216	6	6171	171	588	601	3	4	2023-10-31 17:34:47.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
603	\\xce8cc8f2667a6336621cc085726dec173912cb272a9cab3f68c5321bac2ceff0	6	6174	174	589	602	14	4	2023-10-31 17:34:47.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
604	\\x32ff8af7c260cb542d078307fd6fa7a2be036ced36b8c3d2e2420c1c449dffb1	6	6180	180	590	603	15	4	2023-10-31 17:34:49	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
605	\\x9caa2aa9b3696fbe058e3d4aad1844647de52430786394d8d24dbd7cd215bf46	6	6214	214	591	604	8	4	2023-10-31 17:34:55.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
606	\\x4af25d1abe1d35205370e368e299bd523930a2af437687d6b27f6767cb64b2bf	6	6222	222	592	605	8	4	2023-10-31 17:34:57.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
607	\\x01f4a96bf572f1f0c776ce4b1066faa7c414d050a6278790d66eb0c501eeb7a3	6	6225	225	593	606	14	4	2023-10-31 17:34:58	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
608	\\xac61afa67ee135c8758a19f2523537fcaff0748eaba095badfc5db25427fc51b	6	6252	252	594	607	7	4	2023-10-31 17:35:03.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
609	\\x873bb07b60b8543051e571030bd056904859aa82efd38fea46e307a91cbc46ca	6	6259	259	595	608	15	4	2023-10-31 17:35:04.8	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
610	\\x8b83edef0928265fe11dd3524c740f90156f0b33e1d04a6dcb7a61b6d9603d26	6	6266	266	596	609	4	4	2023-10-31 17:35:06.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
611	\\xbd27722607c7aab21d83806fec2916637f4812bf978ed463f78982aa17694b5f	6	6267	267	597	610	3	4	2023-10-31 17:35:06.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
612	\\x7f2ab27e44898f239ba95e017fbdc4693e4352dbf598336e2d03950f2650f1c0	6	6270	270	598	611	14	4	2023-10-31 17:35:07	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
613	\\x29df6308bf07360bf8ad4b632601bea2de87b51c5ad6947dda2269742dd1e52a	6	6278	278	599	612	15	4	2023-10-31 17:35:08.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
614	\\x988dbc77dc6639e3524599edfa050f4dec54d4d9cf6bfba98aacd817884c7dfe	6	6285	285	600	613	3	4	2023-10-31 17:35:10	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
615	\\x3d48bfd6a5f0c7ad6167dae73b05f3a153fdd572c938f0ee3dd31317b75c1352	6	6290	290	601	614	16	4	2023-10-31 17:35:11	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
617	\\xbd90ce9d486d88d8d8df33191806d0993f0bd41c51524d458e68da23504b772c	6	6315	315	602	615	5	4	2023-10-31 17:35:16	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
619	\\x3d052f069e27c9e1a5a783fd6fb7077f5fae19679480ed2e8ebece6297e266ca	6	6317	317	603	617	3	4	2023-10-31 17:35:16.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
620	\\x9668c0480e1bd63fe816bae3d8cea006c7c4e9c5d03bff33ead4f33e6b4f9c39	6	6320	320	604	619	16	4	2023-10-31 17:35:17	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
621	\\xdbf0339f8d4f13084fe70b8e91a3e012881f893131df1c062f435c3238776cb7	6	6333	333	605	620	7	4	2023-10-31 17:35:19.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
622	\\x092924a90a2d906dc8831ea83845315977e815d1a2967527a6fd39cbf76bc2f5	6	6335	335	606	621	3	4	2023-10-31 17:35:20	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
623	\\xed7c347869598668a399eb4a85191b16fedf4340715e13f0306722efeb5fc2d2	6	6353	353	607	622	8	4	2023-10-31 17:35:23.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
624	\\x56d9c87c61f0efff2259f2aee7d0436bfa397877d24a3ce9d2767b73980a0dd9	6	6354	354	608	623	15	4	2023-10-31 17:35:23.8	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
625	\\x6cd57445b534275821dee87b0747f1d5bdc6fc8e36211006312fb04e8e4e37f6	6	6355	355	609	624	39	4	2023-10-31 17:35:24	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
626	\\xb769728afdd62ac72b42c27e1a002f127c14378eb13d9777dbbf1f22688edaed	6	6357	357	610	625	14	4	2023-10-31 17:35:24.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
627	\\x63eb5afece1530dc80f09a1474a1d826753436f34a19bce9e6c2d7b52d18b016	6	6361	361	611	626	18	4	2023-10-31 17:35:25.2	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
628	\\xcc9bef9789ffc066188664c0c409483b38492f1213c29312b7487f244a44bc8d	6	6363	363	612	627	16	4	2023-10-31 17:35:25.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
629	\\x7d9fa1c3f1de5e60b2cc48de07f4af6b95db1e6b2b17aad1f5cd460a438784be	6	6368	368	613	628	5	4	2023-10-31 17:35:26.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
630	\\x60bfee4b6e96ce3b67967126f60c09d42afe121a65183ce5e6525a70ddfde007	6	6374	374	614	629	16	4	2023-10-31 17:35:27.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
631	\\x034248ea1ab4453edd3e1bbb751c8efa7b59e7d7eaea5ebf560e0afe9b6e5abb	6	6386	386	615	630	7	4	2023-10-31 17:35:30.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
632	\\x4e4131ec3c785453a82d5415c4b2a0911dad1897f02579b5f1e622d86647dbc9	6	6415	415	616	631	8	4	2023-10-31 17:35:36	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
633	\\x4b90972b42cf6bfe07677f3e5ef2a37f7c86bf73a4e14813ed3ae15ba5d7fb02	6	6416	416	617	632	3	4	2023-10-31 17:35:36.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
634	\\x22fc77de7473b7be5dbf1a70f6c84d7e67fd9ff2651d6ca4fe528b6beafdb5a4	6	6440	440	618	633	3	4	2023-10-31 17:35:41	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
635	\\x37ab8a6e5198f6186490161e05cc3eb7f4cd27b11675add3bd92a2c7fae6f985	6	6459	459	619	634	5	4	2023-10-31 17:35:44.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
636	\\x50a23c4b593807d50baedfd500b6195648ca9e29cc972dbb60230b364bfb34c5	6	6462	462	620	635	12	4	2023-10-31 17:35:45.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
637	\\xd6c75ecd77a0b688b83927a9ded57b5ec3c03781067e333007da6afea006c6da	6	6479	479	621	636	14	4	2023-10-31 17:35:48.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
638	\\xb92b8630be8227acb1296ce49c18bdfd577bd7adbc74e27c204fb9ace265c5bb	6	6508	508	622	637	15	4	2023-10-31 17:35:54.6	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
639	\\xb09464f1e39a6f35e3169d70025fc4150285c3c36f5296f9783529293a88878f	6	6515	515	623	638	7	4	2023-10-31 17:35:56	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
640	\\x3cd238af5b596d06b824255cc3ad1d101d6c8112888624b4b562510c0da174e8	6	6520	520	624	639	12	4	2023-10-31 17:35:57	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
641	\\x0d62057130003143d507719bacbef2bdb91bb311fb7198152b79f93564105aad	6	6521	521	625	640	39	4	2023-10-31 17:35:57.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
642	\\x2d9e1fde364df500202969a4e47e5231feda145a25b35ede0561def98f3b5ed2	6	6527	527	626	641	8	4	2023-10-31 17:35:58.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
643	\\x9dcd1e9e26476b3ec7d8c89e758c61a65cc8ec4b647d9c579736c0d863b44f68	6	6529	529	627	642	15	4	2023-10-31 17:35:58.8	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
644	\\x28d04a5388a9ffbbd8eb2b9a8a41e95c6c93fa14dafccb4c0eb7e0175ffaa047	6	6532	532	628	643	15	4	2023-10-31 17:35:59.4	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
645	\\x8c1dd4b2ab2c4297aed2c5d7f6b0cea109864e5f66a400e4602bce68b7a4b9e9	6	6533	533	629	644	5	4	2023-10-31 17:35:59.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
646	\\xdb40a4f32af7ef696a815a5b4cf227805bb6b80c045fb05b348e1a2d586d3d9f	6	6536	536	630	645	14	4	2023-10-31 17:36:00.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
647	\\x0f0c2fab8e1719a99588cc10389f27c5b6057fd75c094a87abad6aca4d0d788f	6	6538	538	631	646	16	4	2023-10-31 17:36:00.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
648	\\xd77a0e2d4c479be169d0e21cf2ee58a075ba5d2a2f35b7a60e336115e8e78be1	6	6566	566	632	647	8	4	2023-10-31 17:36:06.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
649	\\xb45c0b815c00d6b5b3a975ba894a988c9bad92a8a8484795ae511d9d331ac979	6	6567	567	633	648	18	4	2023-10-31 17:36:06.4	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
650	\\x50ec94a32a7414eb7ac645dc8718b54279eca7ee2d9607a71eb684ad83fdff72	6	6575	575	634	649	8	4	2023-10-31 17:36:08	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
651	\\xe3bce5c50d53af151653e2e359d00604bd724188bdce07598bd67b5ac7044de2	6	6591	591	635	650	15	4	2023-10-31 17:36:11.2	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
652	\\x168e2db1cd06f4f2b7e58b723248b434c3a54e53da75f49854780b500a22cb55	6	6597	597	636	651	7	4	2023-10-31 17:36:12.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
653	\\x07d645c49eb682e309bfbd427be7ce0f59dba07970d0ffd4c8893eacd76f795c	6	6598	598	637	652	5	4	2023-10-31 17:36:12.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
654	\\x46498f0f38d00f460ee94f8f558a6a0cf9007832966310fa92dc4b5e5ee509db	6	6602	602	638	653	16	4	2023-10-31 17:36:13.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
655	\\x5e376cbd929bb9363de0d80d4460687319b9fa16bfcf68cac7448c1b25b3189b	6	6607	607	639	654	7	4	2023-10-31 17:36:14.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
656	\\x70efe5dd429412cefc6b5292ad274c247cc3071934173133a038cbc94f1611ae	6	6619	619	640	655	12	4	2023-10-31 17:36:16.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
657	\\xd902269a80b2e1baf2c0627e4dd14c20d1152efdb67e43a977775c39d6f0eba4	6	6624	624	641	656	39	4	2023-10-31 17:36:17.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
658	\\x915283676c35067a05ebccf18005870290686cdd00f4da0c85e6d833c3f79546	6	6640	640	642	657	14	4	2023-10-31 17:36:21	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
659	\\x6fd5610017d0247a00c369d25cdbe09c64a98124740ab13c72f6ce8ec9a99044	6	6647	647	643	658	16	4	2023-10-31 17:36:22.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
660	\\x71f6785751cf34a04139ae5496ad7eece68df50b0413aaed412790ce52abfc30	6	6649	649	644	659	4	4	2023-10-31 17:36:22.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
661	\\x69a4bd1ade2d15309ba3ce94ce5847afc25df3d65006db045c5f0f16b7ad1f6a	6	6651	651	645	660	18	4	2023-10-31 17:36:23.2	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
662	\\xde313fc96913843372cca5a561467607628422da8bd60029fdf02bb228ad43a3	6	6661	661	646	661	14	4	2023-10-31 17:36:25.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
663	\\x8ad058415bcd4593a2a3f808e05ff963222541754e096e2e7c486f4645d50900	6	6733	733	647	662	16	4	2023-10-31 17:36:39.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
665	\\x5483e485b75085014c0fc34bbb553459fcdf510dcf6642a69d58001b135e6e4a	6	6737	737	648	663	15	4	2023-10-31 17:36:40.4	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
666	\\x036b1e5c5e5402c9d4c63f661583a3737c0d63b6b44113e96223d21acc770887	6	6739	739	649	665	8	4	2023-10-31 17:36:40.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
667	\\x00b18f75223b5cd75462d6eb0cfa8720d9038f2a590ecacd38baa8110e3fcce6	6	6741	741	650	666	14	4	2023-10-31 17:36:41.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
668	\\x94586fa3455e724f05769e4bbb16bb4227edfd649633a7b32251797757ec3e73	6	6744	744	651	667	15	4	2023-10-31 17:36:41.8	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
669	\\x251c50bc48d4cfd024616c1c9af5ef31f7dab78b9fc5f795ef19f1e234b734a7	6	6755	755	652	668	7	4	2023-10-31 17:36:44	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
670	\\x73b634db012577d7469fb911ce56fa1cc1a66335f1abba087b818798c4ee5607	6	6764	764	653	669	18	4	2023-10-31 17:36:45.8	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
671	\\xe5fae1569fb521d8d4f401980c0363a993d6a662d29d144d965f5c7f24ab7e9f	6	6812	812	654	670	16	4	2023-10-31 17:36:55.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
672	\\xf24ce0ddf539d1d14251f0bc7acd082d2f01b5ebb08d4d73bbecacaced15b06e	6	6821	821	655	671	12	4	2023-10-31 17:36:57.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
673	\\x38695fea6491064e29e29a4be2881c0d0e1109160579c7670033b4dbd817ad4e	6	6829	829	656	672	39	4	2023-10-31 17:36:58.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
674	\\x7b2fb7aa921d0318be639d994be27ceb417d7af068753d4accf2b06b53c036b1	6	6836	836	657	673	18	4	2023-10-31 17:37:00.2	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
675	\\x64c9cb95a0b4c6e3e539a0ed9e01b1806ce4757711988d38d6d375260b935296	6	6843	843	658	674	18	4	2023-10-31 17:37:01.6	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
676	\\x6a0141934ecaf981aced48d3a64596241fe93d8bdc3a5d16e2eec9394fa6071c	6	6847	847	659	675	16	4	2023-10-31 17:37:02.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
677	\\x7e5f5ca4455de24737df045943a5c8f37cf53058d4241ea010a7502d57c353f9	6	6850	850	660	676	7	4	2023-10-31 17:37:03	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
678	\\x0407379dd653acb3c44845491927f1e1a2e7538427fe5897b5c78a4fc68296eb	6	6859	859	661	677	15	4	2023-10-31 17:37:04.8	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
679	\\xe2af9bdbeb05b74eb317b8f3c4a31c0919c1c22ac53b441e4ac3a4df8a568c25	6	6881	881	662	678	14	4	2023-10-31 17:37:09.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
680	\\xbcc98b2f3ce057a7a43c16f533870ca0cdcf3d02dfb8b3a85825a8f8a431872a	6	6883	883	663	679	14	4	2023-10-31 17:37:09.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
681	\\x5cd69b2e418504de95d0562a12cf349a1b98a57281d8b3a0adf546485bce83ad	6	6887	887	664	680	4	4	2023-10-31 17:37:10.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
682	\\xfb1a21b43320b65c72c03d915ef6b920f3e856a1fc87b78631020880acae8e95	6	6901	901	665	681	5	4	2023-10-31 17:37:13.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
683	\\x0b9c77f52d374effd280951295803fd96ea0ff0eff60837a7fb3e65e94d8be80	6	6906	906	666	682	14	4	2023-10-31 17:37:14.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
684	\\x3fa87f98ba9b627e4757ea7f0a53f314046327e521845c744b25efcfe107fc9a	6	6911	911	667	683	3	4	2023-10-31 17:37:15.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
685	\\x5355cb580c9e9833184340be31baf00d74fa84c66d18f6db9e5075516bd64e03	6	6919	919	668	684	3	4	2023-10-31 17:37:16.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
686	\\xeabd52449bcae51611b066d3a2b06f66498adec191104f3687a24607c8128652	6	6927	927	669	685	15	4	2023-10-31 17:37:18.4	0	8	0	vrf_vk1xfpldunkd96pr4g8ytm0w8va7eju00c9y7hld4vqgvpwphl4prssw2wrw3	\\x042498b858ee03e59f21b143b44f31222b97bcc4e97df2f0304962b2351ffab4	0
687	\\x7c8dca45a48ebacebe15fa9e9d8272e3437cd573bf32cd508cc2aa6521277fa6	6	6956	956	670	686	8	4	2023-10-31 17:37:24.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
688	\\x845db234562e0c2d50b985712064d733f1c07bb9da5b6816e66b0c3b62eecf46	6	6962	962	671	687	18	4	2023-10-31 17:37:25.4	0	8	0	vrf_vk1x9cpq0zswx4tcyq5uqu6k5cy5uqqdtswe6ru5ukcrlp6uesyvn5s53rxpk	\\x7a51e2823c99942b87803b5f72e7be09f9756ad24a3f75d929edd870b7cfde3a	0
689	\\x6cbffcf0ff615eb935c5b4d56e742bdbe6ab5c1dea7edaeb601f4638bdd08786	6	6964	964	672	688	4	4	2023-10-31 17:37:25.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
691	\\xa0183201a0c6f8d8a9e27323287b245beecaed95fe9f4b5d54cb1dcbd9f1984f	7	7023	23	673	689	14	4	2023-10-31 17:37:37.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
692	\\x84fb392688b323a45d2e94a76db297bbb48e2c13ffae7b34372e55a567284184	7	7033	33	674	691	12	14644	2023-10-31 17:37:39.6	46	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
693	\\x301f92dd2c246f83027f97502ef55f4c18aeb0b545f3f7e3b697f20acdb2c07c	7	7056	56	675	692	3	17200	2023-10-31 17:37:44.2	54	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
694	\\x562025410fa891a1f21a6ea147a4235574909f34247f22212f49bd6da85be4f4	7	7064	64	676	693	16	4	2023-10-31 17:37:45.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
695	\\x3ec31bedbd151e5e0b95ae0c45392c4651730fbf1096c0711a2003a140b95b0a	7	7065	65	677	694	39	4	2023-10-31 17:37:46	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
697	\\xcdd70dceea9a0959dbf7e78926c82cd839ce7f31cb6aa3d3920bda2a2785dc8a	7	7070	70	678	695	8	4	2023-10-31 17:37:47	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
698	\\xf44cb776fe9b79b7edc66fe2690d6fe2277e1811d706545d06c9c9d03c43b9a7	7	7071	71	679	697	3	4	2023-10-31 17:37:47.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
699	\\x13641aad4dc7a2163bd936e84f7162b98acb99b1a81ac95a63f6756222684a0c	7	7086	86	680	698	5	4	2023-10-31 17:37:50.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
700	\\x8d9dc92a67bb6dff7f045bbd4f0fde92f77f2efe553ebb7bc5ec63a63a24370e	7	7091	91	681	699	14	4	2023-10-31 17:37:51.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
701	\\x38ccc46a9fcdf3a72582684e5e0173bd3b3fac34a00fcbe473a291a9a686d592	7	7093	93	682	700	16	4	2023-10-31 17:37:51.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
702	\\xbb52b2cf7e30b61f1a7d564e5406df0edf36f82ef90010932271cbe712a5ccc7	7	7095	95	683	701	16	4	2023-10-31 17:37:52	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
703	\\x116bcd5eb060ce2377129040281fc0f96daef9065d3a0d1ea9f82f4e1e43ae7e	7	7096	96	684	702	12	4	2023-10-31 17:37:52.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
704	\\x360e2220bba959e073c683c31198e70b7a7306640b8fa4f643f29f8186082094	7	7100	100	685	703	39	4	2023-10-31 17:37:53	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
705	\\x4d2ef249faa2eea1a516653711c5dc091ca104e143685e9f786bbe7a2e460ed7	7	7133	133	686	704	4	4	2023-10-31 17:37:59.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
706	\\x9275f99d1368238cddece8116c8cc495d7c975f3960822fafcaf9833d6d9fd26	7	7134	134	687	705	39	4	2023-10-31 17:37:59.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
707	\\xc8d62d76613c22ed5719d93507fc9859acb748ab5587541948836bb32fb24bf5	7	7151	151	688	706	39	4	2023-10-31 17:38:03.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
708	\\x81d795874b3aafdce8ef51fac0e46fdd1247694573166b745227287b55ed0dd8	7	7152	152	689	707	12	4	2023-10-31 17:38:03.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
709	\\x39aa8dc75c19a441420e1f21e53243e27aae2553e915420fa4b1d8dd933db794	7	7162	162	690	708	8	4	2023-10-31 17:38:05.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
710	\\x73a7024e5083cdd10b4dfa2cd3c4ea9e1abdc00cee73e1d19f549709a10ffa67	7	7167	167	691	709	3	4	2023-10-31 17:38:06.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
711	\\x50197d47cc566f49ce0a4a993ebad1877e35b1338783c71379413b1ebbb0f9b1	7	7187	187	692	710	39	4	2023-10-31 17:38:10.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
712	\\x3210609c3cdd79a752ff5ddcf1481a0811391a9c0175b661e133050ba75a1999	7	7190	190	693	711	3	4	2023-10-31 17:38:11	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
713	\\x64624895f97245a8681a1c39fead8a67f758f5349ede3425edcfe7deda136121	7	7195	195	694	712	8	4	2023-10-31 17:38:12	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
714	\\xdfccc79ab1c37fd1793d8d2c657f3434240994949b0660225d2d2ffe6d652488	7	7229	229	695	713	16	4	2023-10-31 17:38:18.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
715	\\x17b75aa136598c95faf466976d5b6c3493baa6617f96239c270a953a6361abfc	7	7247	247	696	714	3	4	2023-10-31 17:38:22.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
716	\\x773c55a65d4046e846e214a21af7af5c3d4bc36ca93e9506a3b4030d40973a44	7	7250	250	697	715	3	4	2023-10-31 17:38:23	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
717	\\x77d627fe9a8d20155a25ec6684c258bdcfdc8292a89dc1053a9c70c45bd5f8b5	7	7264	264	698	716	39	4	2023-10-31 17:38:25.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
718	\\x4baf58c6693bb5ae6ccba99e68b2ca78f818840358c42f8f3d6b350f8c5361e4	7	7268	268	699	717	3	4	2023-10-31 17:38:26.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
719	\\x36ba89cb65a8f9b43c74c85b828940e35df50527dd39b7d2d863e6c50684e48d	7	7269	269	700	718	12	4	2023-10-31 17:38:26.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
720	\\xb8bd9591a18dd6a428c6c225bb796c843ced06a9116c03aea28cd478f4e90fcc	7	7300	300	701	719	4	4	2023-10-31 17:38:33	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
721	\\xab38946ef4b57bf9582aa3c097c6eafd4a5105907244f72f4a7d51d6d52e6460	7	7305	305	702	720	5	4	2023-10-31 17:38:34	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
722	\\x08dda3a286fece722a198861944c78db9fcf2345fe1159d500bc89512e28d02f	7	7313	313	703	721	16	4	2023-10-31 17:38:35.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
723	\\x65c2e91708b88a37d28736d8bc411feeebb1c3642eef705c41d9dc15ecf56175	7	7316	316	704	722	8	4	2023-10-31 17:38:36.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
724	\\x6a6efa5f6e9c476691630b47b5e9297fbec28652c791c803f6712656f78f6be9	7	7321	321	705	723	8	4	2023-10-31 17:38:37.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
725	\\x5613a14cc0a8569c7f1a67c6e56b535fbe493553870a95ecdaec26d5cd025d16	7	7328	328	706	724	12	4	2023-10-31 17:38:38.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
726	\\x1f029635e6f615210f7f711e77652e8f07bb2b4e5ce0dd714817e680d3c717f6	7	7331	331	707	725	16	4	2023-10-31 17:38:39.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
727	\\x753d3561219120fd644cf23ca12e01a7ed88cdb5ecdd208c70857e23fbb5cdb9	7	7336	336	708	726	3	4	2023-10-31 17:38:40.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
728	\\xbd9e907a18a26d34fb9a42392333ef000239d5d03a710150133f41464ad81cac	7	7339	339	709	727	4	4	2023-10-31 17:38:40.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
729	\\x35259ded639e9feb9544c5652e70e8568ec6530677fc2d94bbbb7cfcabcccae2	7	7341	341	710	728	7	4	2023-10-31 17:38:41.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
730	\\xde7d70885cd41dffb7e582f51067d5f0ea169eb671e3782f98a249b87eeade8c	7	7342	342	711	729	7	4	2023-10-31 17:38:41.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
731	\\xfa4011307c87ea2923efddedc2d128e7fb24009b4cd8260f650a26a58a56b933	7	7353	353	712	730	39	4	2023-10-31 17:38:43.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
732	\\x7c0515a56eb93c56d37ab62478e41cea838f9438bac8834bc650ccd967d144fe	7	7381	381	713	731	5	4	2023-10-31 17:38:49.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
733	\\xc3fbc7ec6e472d5b9e87549e61f12c6627a79956d7a8aa8bc3264fe76ee978d5	7	7384	384	714	732	7	4	2023-10-31 17:38:49.8	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
734	\\x4d540ea434b3a50c16d02092e6023761f6067eab123ce062a39af4f85fbfca32	7	7390	390	715	733	4	4	2023-10-31 17:38:51	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
735	\\xb46a3de8bcf0d685dde82cfd8af24b820afebbb349bc58f7b292edb2cc3aa339	7	7396	396	716	734	14	4	2023-10-31 17:38:52.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
736	\\x072406e8bb727baeb3daad9bcd6d4500a871535333206811adde6319eb135dcd	7	7401	401	717	735	12	4	2023-10-31 17:38:53.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
737	\\xf9f68c5b3468ab69925a27dc16037f77bf39fa05690f708982ececbc35d45b98	7	7407	407	718	736	14	4	2023-10-31 17:38:54.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
738	\\xa13b95d187042ac76c75d4460f54d67a341a79b2f28ecc2fc82c3b99f2efff4b	7	7416	416	719	737	39	4	2023-10-31 17:38:56.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
739	\\xc5bab76c7173c7992a2bd470033b1c55b7eaf2fddf781dcdc07c3386ace4dba4	7	7430	430	720	738	5	4	2023-10-31 17:38:59	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
740	\\xd049866307930b55e8a003eac576ca87f86eb26dd8b61a2245b4b491bb2f91a7	7	7472	472	721	739	4	4	2023-10-31 17:39:07.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
741	\\x1b7fd2a900d1b4a07decd538d8e2fa0019a14ee08116aa44622c00e57c5a5ff0	7	7476	476	722	740	8	4	2023-10-31 17:39:08.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
742	\\xc4509f5af9d2c8441e51511a11f85a9f4ce004c24a4a8a0dc86f18513c910a7e	7	7479	479	723	741	14	4	2023-10-31 17:39:08.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
743	\\xdaaf87b4bf7e5dd2a3f6e9901d0c2c85c84756cce591009dd92b53e83d18fc15	7	7480	480	724	742	14	4	2023-10-31 17:39:09	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
744	\\x2afaefca196cf8928dfcaef42921bbcb30f4765429b77f17b3389d0015ac9ba3	7	7481	481	725	743	4	4	2023-10-31 17:39:09.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
745	\\x061b6d795f27ab7c073802d9be528096ffcca82052d51f6d2cb7cd54b735182c	7	7483	483	726	744	7	4	2023-10-31 17:39:09.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
746	\\xfd20bd2b7746c9150b9ceee092db6b984a128a876e143e8ad598cda7445a83fe	7	7488	488	727	745	7	4	2023-10-31 17:39:10.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
747	\\xc852ff8234b6921bcb50f836159b9730f41c3c7ea30c10bdbcec29d046a2a9cd	7	7490	490	728	746	12	4	2023-10-31 17:39:11	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
748	\\x666e606c7602f1b1240d87891b1680ac90a40ccfe833688b1a4fe6ae507332bc	7	7520	520	729	747	4	4	2023-10-31 17:39:17	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
749	\\x1521329980960c222a830a405798ee3f327691aa746980a3183a489232b0e94c	7	7557	557	730	748	14	4	2023-10-31 17:39:24.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
750	\\x9f0bef98686dc280b7522cb610a98e1f4b511b43521e1a3f37efb5e14d705e6b	7	7560	560	731	749	16	4	2023-10-31 17:39:25	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
751	\\x9cf54d2761587040a6bbe5ad5ff5662fc0dd1c02641dff863edd672310c99a25	7	7584	584	732	750	8	4	2023-10-31 17:39:29.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
752	\\x174015fe016ba7f420c6f9e28787d45feac2f0e8ffd6d22d949f39ff5d7f3849	7	7622	622	733	751	39	4	2023-10-31 17:39:37.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
753	\\x5a7a43bf88e5fe1a77036c85165e1877d144935f4af56f2d3ac7be844b58cc2d	7	7649	649	734	752	39	4	2023-10-31 17:39:42.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
754	\\x558f91b99bebd838a676915421bb340d7633bb873713ea30ce6188213e485904	7	7652	652	735	753	4	4	2023-10-31 17:39:43.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
755	\\x42767387d9d628fa64590c0749550db256da4158f313098fd1069238e785228c	7	7663	663	736	754	16	4	2023-10-31 17:39:45.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
756	\\x5952cca728496b103bc0b265246b8b7763b628028b370472abbf2f0d9446b1dc	7	7675	675	737	755	7	4	2023-10-31 17:39:48	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
757	\\x25e50a5567d05c5e202debcac4d6df6381417b477b1a45c3d00056148575264f	7	7676	676	738	756	4	4	2023-10-31 17:39:48.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
758	\\x404285fa238514dcc37d0be8f3996c2fd117c9a6e061622df072169e3cbd0a37	7	7691	691	739	757	16	4	2023-10-31 17:39:51.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
759	\\x3caa344e92620211dee37a951ecb0e935d8efd2d7999f6cf9ad81ca371a9630e	7	7695	695	740	758	7	4	2023-10-31 17:39:52	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
760	\\x204619f3068839f515d59f6e28503357409923c8a85fca4335e751565ef14fc3	7	7701	701	741	759	14	4	2023-10-31 17:39:53.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
761	\\x34851a533e3faf907f233468d8fa6f8f6b29687fd680660614c2c26c7826230b	7	7727	727	742	760	3	4	2023-10-31 17:39:58.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
762	\\xc92ba8f905571474c72814fd6fe7692089e9526c7ff4a9ee3ad6faf5302b5c1f	7	7733	733	743	761	12	4	2023-10-31 17:39:59.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
763	\\xd930248ae927752e8dc25c1f9ac660cdd881f52d872efc85a31c9143a22bc0f0	7	7738	738	744	762	3	4	2023-10-31 17:40:00.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
764	\\xc04d67262d9201f6b9677f8b30464820746e5f135b224eeaba910ed79b444cb5	7	7742	742	745	763	8	4	2023-10-31 17:40:01.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
765	\\x8e970cb0ef17ba0fed8b12eeb0c19177dd142ef3f43e1e60fc5938fe9d0cf642	7	7768	768	746	764	5	4	2023-10-31 17:40:06.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
766	\\x4883a21a9e43720a41058cae49873e4107293c9feca48b0b2f8f520e9819051a	7	7784	784	747	765	4	4	2023-10-31 17:40:09.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
767	\\x266a3cecb3f4856d7dea78dffaf2045824ab32b5d829623fbe1b564d2269adee	7	7788	788	748	766	39	4	2023-10-31 17:40:10.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
768	\\x7658e9ac679d7e7492746045b094fabd7855774032b2ad293039ce95b705774d	7	7792	792	749	767	12	4	2023-10-31 17:40:11.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
769	\\xfc9fc67e30d95999795865af4e5fc37b7a9ddf2074bf0cf0e0b96b44389cf2b2	7	7801	801	750	768	12	4	2023-10-31 17:40:13.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
770	\\x03b29828e173586ded906808f136f4f6f560a4a524d3dc96c372a5fe19998de2	7	7811	811	751	769	16	4	2023-10-31 17:40:15.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
771	\\xe3be09da5871a93e0dadceb436bd5a6f26559a9bd9f7296d5c55272ed9aee985	7	7824	824	752	770	4	4	2023-10-31 17:40:17.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
772	\\xfdb17d90dc69df7c6efdd3dc82d02b4f978d0a7f93ad89c10644f6ffa7220efa	7	7827	827	753	771	7	4	2023-10-31 17:40:18.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
773	\\xa82ecdaa42c85fcf87d9e46b91493b932f9d5f4a592d23cee10613b424d091f1	7	7832	832	754	772	16	4	2023-10-31 17:40:19.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
774	\\x81bcdb4dbfb90b3f7a6f61cb4aac8a734ee0b9d24336af23f8fa52c37fad7fe0	7	7838	838	755	773	14	4	2023-10-31 17:40:20.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
775	\\x68791cf32265f198f817461f6680dbf97db8cb29540a671f75d062a22cce9f72	7	7850	850	756	774	16	4	2023-10-31 17:40:23	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
776	\\x224dea252b4daacdad052add2ee45a21cdd906d3cb41208d8f0744af98e557d0	7	7864	864	757	775	16	4	2023-10-31 17:40:25.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
777	\\x43c08f60771211eb2920ee40343d7901cf7512f671a2bc5cb7848d67bb6a36ea	7	7876	876	758	776	4	4	2023-10-31 17:40:28.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
778	\\xc2b0178dcbb67c0e65468ac4545912306483094e3a71fd36b134123777c3386a	7	7878	878	759	777	7	4	2023-10-31 17:40:28.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
779	\\x30b5dada4eb2ea2748ff08fe7fff1920b6465453180a9c5af18a9b03a77b589a	7	7909	909	760	778	8	4	2023-10-31 17:40:34.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
780	\\xa8330f3e89800ebe3f59a3d4c61d03a4195878cc7ceb9408db5c521617ae7552	7	7911	911	761	779	12	4	2023-10-31 17:40:35.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
782	\\x5955debf1d858c251f4cd64598a18cfc718893855c47fa321def7688defc08cd	7	7930	930	762	780	14	4	2023-10-31 17:40:39	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
783	\\x01c2b87a658339452e0b8778d670774479a84e45c250d0e11a99adf5db2e2711	7	7931	931	763	782	7	4	2023-10-31 17:40:39.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
784	\\x1b72fa6ebb37cb8fa5a5dfd61eaa335b204acfe21338f47f3863a8142ef629fd	7	7942	942	764	783	16	4	2023-10-31 17:40:41.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
785	\\xba9f2d38bf8968e7d725488f7f888d6449a53253dfd02135cc11aed3ad59d033	7	7953	953	765	784	7	4	2023-10-31 17:40:43.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
786	\\xbac2bc3c1ac6ae90f6073ef49fc7f2436cabdb910bdd8dd1b716ef47eaad8fc7	7	7956	956	766	785	39	4	2023-10-31 17:40:44.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
787	\\x3e21a93d3339ca0eb11006ed49f157ba09ecfbe86fd0099910ea1a92ced0cc64	7	7958	958	767	786	5	4	2023-10-31 17:40:44.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
788	\\x77590349b598d6a8e29ba9e552065c1f5a419900fbb02aa579d4c156c8aad03c	7	7959	959	768	787	16	4	2023-10-31 17:40:44.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
789	\\x1485eba298bb0913a1944276e07715584768f39e64034e811178afde8c0608e4	7	7963	963	769	788	16	4	2023-10-31 17:40:45.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
790	\\xba95bdc6f1a1be9e1f4fcb6b16042d913c449497cf46cea6ab18b235efde452b	7	7968	968	770	789	5	4	2023-10-31 17:40:46.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
791	\\x60af2442229d93f8004c474245d66eb7ac32579c2ad79fcc0a71567c8e3ef47f	7	7975	975	771	790	4	4	2023-10-31 17:40:48	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
792	\\x5e5fda26d2e93f861ebffacfd58a40c3fcb90b73f2a739f2f611b5790b742ae1	7	7991	991	772	791	39	4	2023-10-31 17:40:51.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
793	\\xa495da290c9af7dcf64cc199e1f9bb7a83fcea24b4c934f330dfdb81145fdb6c	7	7998	998	773	792	14	4	2023-10-31 17:40:52.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
794	\\xea8ec31558af63c3398bdfda815cd6d360159ac0067395c8fe9b7e504ec019e1	7	7999	999	774	793	16	4	2023-10-31 17:40:52.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
795	\\xe0eee7a6c2e308160ea825eb1bc3d9a1af36dda10c4e51f379cac5a439221f62	8	8004	4	775	794	39	4	2023-10-31 17:40:53.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
797	\\x16d6a09cd8a0e96b16cdecbf2baec8a40267ab70998aee7bc315d621b492ba0d	8	8008	8	776	795	4	4	2023-10-31 17:40:54.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
798	\\x6eb04859f26e5344ce58de2b7e51d38fc43ddb0a3cd78caafdbce4d80be3477e	8	8013	13	777	797	39	4	2023-10-31 17:40:55.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
799	\\xb97b919c759c1468a42149ec31aa982d9c2adefdd4520c0ec50ba162e853add7	8	8025	25	778	798	14	4	2023-10-31 17:40:58	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
800	\\x30dafc501728036add817c65b637f66a0b0dbb33d2600ffa6f42be50a9577c61	8	8027	27	779	799	16	4	2023-10-31 17:40:58.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
801	\\xa81d59e5283324fcafce260a27000f475418ed8d36ab74aa4614c0f658319831	8	8040	40	780	800	8	4	2023-10-31 17:41:01	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
802	\\x33d0b1906ffe8925c2216291183dab50337e0b8da100456e651180ce65084c7d	8	8041	41	781	801	4	4	2023-10-31 17:41:01.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
803	\\xd05ddf17e4c9794aa18ccd235d190ce1ca4d0989bae9ae1c0867ed34129c0dc0	8	8074	74	782	802	5	4	2023-10-31 17:41:07.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
804	\\x008dbb0a0c02924ea9e3f93324cd164eeed35b8fa08ad4de0dcc26926398f0dd	8	8085	85	783	803	39	4	2023-10-31 17:41:10	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
805	\\x07ea5c64d3a390b26575e064a03dccecd9fe3ffefe4ebdb6a477d5d57b0139bc	8	8092	92	784	804	5	4	2023-10-31 17:41:11.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
806	\\xe8ef0ba120cb64b2af94befea27a91da795ba40ea8076ae7e21db8accbc5abe8	8	8116	116	785	805	5	4	2023-10-31 17:41:16.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
807	\\x8e68a938445324debab1244c631301c86ad45324868238f06263cf9699b014b4	8	8126	126	786	806	3	4	2023-10-31 17:41:18.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
808	\\xa94058d7efb9744ee6bd0cc25c5676ad300d428ea77c5f3301d8f30f5720fab0	8	8132	132	787	807	5	4	2023-10-31 17:41:19.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
809	\\xf48c85e860c803bc45ab5c8b52818989b47934697817e1bb96249e22056a01ee	8	8142	142	788	808	5	4	2023-10-31 17:41:21.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
810	\\x70e063a28b2e09221e840511be0e0c55a361d2d0f4763792fe1a0c83fd57dbe2	8	8155	155	789	809	14	4	2023-10-31 17:41:24	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
811	\\x7f4a5c841a5d0d81e9b1448723d557dbdee2139bb70d28a1b29fc46b8d9055ee	8	8156	156	790	810	16	4	2023-10-31 17:41:24.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
812	\\x5ce1c4568892661ff04b1948ae91e0809fd8b5e3911895589c2f4d3b8a61af4e	8	8157	157	791	811	7	4	2023-10-31 17:41:24.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
813	\\x86fba794fa73374b607112b69cd89fac4fd3419b275ded5c3a41361d1920e36a	8	8162	162	792	812	3	4	2023-10-31 17:41:25.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
814	\\x8e1e777b58914af30c65cc26ffb2b0f5898aa410d61a90fade77e23e74b12d93	8	8163	163	793	813	7	4	2023-10-31 17:41:25.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
815	\\x6000720c0534614c33f1c896fb4ee66ef2a387efdcc52a0a30ae4f02fb0576b5	8	8171	171	794	814	5	4	2023-10-31 17:41:27.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
816	\\x88ce77b63d817ff06700efd5191fe339cf9af869ce71f65ab247a53e022c5915	8	8179	179	795	815	4	4	2023-10-31 17:41:28.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
818	\\x6475599b4cfad73d2bbdee5eb68787aa91daf9ffd077037c1a0256e0871ac2d9	8	8180	180	796	816	5	4	2023-10-31 17:41:29	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
819	\\x7a91b0be9c396495cad72241e58f88020fc7d3d93c152a97a7a146822ff2a3b4	8	8206	206	797	818	16	4	2023-10-31 17:41:34.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
820	\\x8c02e9529f7e4e0845508a0e4d72a0b38ccfb60dd205128849645b5c1a2b9370	8	8207	207	798	819	12	4	2023-10-31 17:41:34.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
821	\\x47e15fc5fba40e9219700f6370d1c9f82bbdc386aa4e83106f9c298a2be6a2a6	8	8212	212	799	820	39	4	2023-10-31 17:41:35.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
822	\\x83066d74f56b5fe322c49b2acd8c89fa6ca620f35f2f776fb90618d16cd9c4fb	8	8217	217	800	821	3	4	2023-10-31 17:41:36.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
823	\\x33cb840ed2de92bb028d9e68554d96e8c37668dd51b7f68efbcea9dbe2f81956	8	8241	241	801	822	8	4	2023-10-31 17:41:41.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
824	\\x3a3d2181f16e8e496cceba2c1ec89fda38d8dd4ed7d4f954ffb1e28cae4304b5	8	8270	270	802	823	5	4	2023-10-31 17:41:47	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
825	\\x3eaa43ebbab6a5a3f8d4f58f756e30dce65e298f07c03072197ca57a09ecfa69	8	8290	290	803	824	4	4	2023-10-31 17:41:51	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
826	\\x5db516f0fde103d6a81ca1a972da52d42dd24cfc4b4b0098a997f44acea4f069	8	8295	295	804	825	3	4	2023-10-31 17:41:52	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
827	\\x1ebeb6783214f964091a22910692ea130fa97d87a3b0d55bb88d562733f67ffb	8	8314	314	805	826	16	4	2023-10-31 17:41:55.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
828	\\x973ba378a0bcdc1201916cef6618d9866ff5cb559158191b411d41cba9283c5a	8	8317	317	806	827	7	4	2023-10-31 17:41:56.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
829	\\x951b8d28afd768fd573fe9c619b5ba8cc6468ec5913901f1fb3e5b6c602ed9ab	8	8332	332	807	828	5	4	2023-10-31 17:41:59.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
830	\\x42d03e4fd01965510dc6d7bef7c412ad62f7665621728fe447bd2a25e36b1116	8	8337	337	808	829	7	4	2023-10-31 17:42:00.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
831	\\x6e35a7ace3a39a90b4e581ba7c7dc9c253c0808f1541847bbad846fc9be12df4	8	8344	344	809	830	4	4	2023-10-31 17:42:01.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
832	\\x5a14ff060686ea520ed94d0bb3a97f7a97c295f8cefa1a5082505555fbc88aff	8	8351	351	810	831	3	4	2023-10-31 17:42:03.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
833	\\x059bdc334a86dedef65acd1189f4cc75f0b672826f08a7201aff7ddacfc546c1	8	8359	359	811	832	4	4	2023-10-31 17:42:04.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
834	\\xb12828cebc7b4281570de185ca6da1464be8bab77670241dce12ba3f988a1ebf	8	8395	395	812	833	14	4	2023-10-31 17:42:12	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
835	\\x603c40e7f02344e31aec05c62f55522825f3aa45dcd4b00a560615ff53a22a7d	8	8398	398	813	834	4	4	2023-10-31 17:42:12.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
836	\\xbfc88d8c762f9553f2b4b3ba7c1591504d1eeee66c006e99ef82044dc04e8d4d	8	8401	401	814	835	3	4	2023-10-31 17:42:13.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
837	\\x5b80e230fe01fc3074d55ffd36ebc8e30306c1f64f6e368b78bd344d214c5826	8	8403	403	815	836	4	4	2023-10-31 17:42:13.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
838	\\x3673d1ee9acb67055ed7d703145a35b43a92bf5ed45ea37f0f78eb4e0124f25e	8	8406	406	816	837	12	4	2023-10-31 17:42:14.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
839	\\xf8837ba2a5c71255464d7b4fdaf409b2403c828b30f84c55b2b31425e9e5f4d4	8	8412	412	817	838	3	4	2023-10-31 17:42:15.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
840	\\xcdd1093d24a2fd3e46bad5b4da1b9606d5513305260de2e4cccc4e68021c62b3	8	8419	419	818	839	8	4	2023-10-31 17:42:16.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
842	\\x0eb592e7a84e71bf107f197448e2a9f774e016bf4b00b149c4e37f86dd1197a3	8	8454	454	819	840	39	4	2023-10-31 17:42:23.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
843	\\x7c793799a821860f6b77e6abb57c4eca908ef170d4f5f071f83cb0fb63b2e010	8	8458	458	820	842	3	4	2023-10-31 17:42:24.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
844	\\x5567e0273a6adafc597a07671301caf4583161538fc81d4f64df2b94c127e528	8	8469	469	821	843	16	4	2023-10-31 17:42:26.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
845	\\xf62bce69542e67506c231a079e3e5d1156bec93c16b69599952b36b8458099b9	8	8475	475	822	844	16	4	2023-10-31 17:42:28	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
846	\\x38ef60545f5e01d5800a8f5f32a1a8a1003e6cc73cf7e560a7008a3179e614ed	8	8476	476	823	845	12	4	2023-10-31 17:42:28.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
847	\\xa5faf5cc36d842d5312f034754ed478bc8d205b2dc12b77597bf722959598cbb	8	8489	489	824	846	3	4	2023-10-31 17:42:30.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
848	\\x7222b54772ced661e6f497ad0629c0bfcc7c3949aa0bc3939442879b3ad8f18a	8	8498	498	825	847	4	4	2023-10-31 17:42:32.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
849	\\x33d041ade83f008e6bf2f5adeacb734975f172a5460380e14de26a5c11e29425	8	8499	499	826	848	8	4	2023-10-31 17:42:32.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
850	\\x2263d734bb087bf7c01225d8f60beb9f044a8d6f3b230f7e29326f6684845fb7	8	8526	526	827	849	5	4	2023-10-31 17:42:38.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
851	\\xfdab5044c376743201b7a3bd4781888bf37d3de4413d303b1f46cde19a970d85	8	8542	542	828	850	7	4	2023-10-31 17:42:41.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
852	\\x771e5240cdf15559edadf7042d796c7dbba4c81eff6b9fd880687dd786e4fbeb	8	8579	579	829	851	5	4	2023-10-31 17:42:48.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
853	\\x048810d7ee4c7db5b2cc24a131c0ac864023436dee7c7fd549036d463ecd08c8	8	8593	593	830	852	12	4	2023-10-31 17:42:51.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
854	\\xe02b9582a9bd65bf8bde08cdde983a4a77f2e470e4ba70d9f20dbc75c4b6180a	8	8613	613	831	853	7	4	2023-10-31 17:42:55.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
855	\\x8b18004a20cae78e87f477c52b025c001aea475892329b4b8df1f26f4e478d4f	8	8620	620	832	854	8	4	2023-10-31 17:42:57	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
856	\\x25700806e235cf88bb89881c9868d78a93e27d01cb771a5c386c074a2e27ee5f	8	8624	624	833	855	12	4	2023-10-31 17:42:57.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
857	\\x372bf73d5e4136430291bac8bf320d6865562c50f42d6b5e5358cd6527b15c5e	8	8629	629	834	856	14	4	2023-10-31 17:42:58.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
858	\\x6489603fabb3f4fd9306d828298851f568d109a7fc231b14504175f848191701	8	8650	650	835	857	39	4	2023-10-31 17:43:03	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
859	\\xc09f1243c788174f31ee678ba0471c5ae62c6935dcc3d78359b8e6ef3725bb99	8	8658	658	836	858	39	4	2023-10-31 17:43:04.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
860	\\x59625970ca06faa75615e29f17df0eaa071b432f93252402108c41b968882a5d	8	8659	659	837	859	12	4	2023-10-31 17:43:04.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
861	\\xea3a8c2bdb515bc2c18ec6c766bd5c607a366d5a88c94a9c2348be396cefb084	8	8685	685	838	860	4	4	2023-10-31 17:43:10	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
862	\\x3599c563cad4acc32f391ce689cadbe4b7f47a84e7e349a8e78914b027294180	8	8704	704	839	861	12	4	2023-10-31 17:43:13.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
864	\\x4bd303b2ec476c1760317c500fdce740029f2d9ea3e44762dc8ca7da9b8fa5f1	8	8707	707	840	862	16	4	2023-10-31 17:43:14.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
865	\\x44610264737a4c4ef07659675b1480b2a12daaae719558f5d186bbf484ada2b2	8	8716	716	841	864	14	4	2023-10-31 17:43:16.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
866	\\x0dd0e91c8de35807c28d0b32d56cf588c70dff2719194c89b40c9b3c83a14241	8	8736	736	842	865	14	4	2023-10-31 17:43:20.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
867	\\x1007176bec17ddfb3d5fcd0d5bbebeb112b6521f38012983dc43bdc7addce20e	8	8742	742	843	866	16	4	2023-10-31 17:43:21.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
869	\\x3d3b76c534149ae6e61e4a82c001835074bf4f1fe34d39866be9c1dafaad9c96	8	8758	758	844	867	8	4	2023-10-31 17:43:24.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
870	\\x528289b5c71935e3accd747d4f2536a28db13456de1f310f5807c9393f3343c1	8	8783	783	845	869	8	4	2023-10-31 17:43:29.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
871	\\x281c37851c7eb8b012ec17f24d24f336966a70ff7b7e8ec25c7d6a1856ec487c	8	8784	784	846	870	16	4	2023-10-31 17:43:29.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
872	\\xb50253b57ad504bc48b1b68cc5da13b8ef2c63145f1c18ec0ff94ca35e323827	8	8793	793	847	871	3	4	2023-10-31 17:43:31.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
873	\\x4bc001de25ba85e6d6f11fa3a62c0f83b19bd942ec0fc41957a2243c6de5e6c0	8	8795	795	848	872	16	4	2023-10-31 17:43:32	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
874	\\x0898fd45d4ef97e23f1f125d80fb7541eef26ff4adac6a83838f4a2a1ec64040	8	8802	802	849	873	4	4	2023-10-31 17:43:33.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
875	\\x20f2c329ea58d8013e54dcde9d4811470465517a3263bdfc27d6ea15f585f1ef	8	8816	816	850	874	7	4	2023-10-31 17:43:36.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
876	\\x3e91774f249db7d8e977b87fd852427542cac8cb1fefa814a3ff25b45240821c	8	8821	821	851	875	16	4	2023-10-31 17:43:37.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
877	\\xe1f0e5d8ffea35abbb5107a5ec7aa83bdb9a97aaac1a7dc30ab0b90ffe9759dc	8	8856	856	852	876	12	4	2023-10-31 17:43:44.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
878	\\x95e41daa3fce7fe7f22d527c8c0829bbe8318bd0d4535a8817f482bdf474af9a	8	8878	878	853	877	8	4	2023-10-31 17:43:48.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
879	\\xc7da677c1640c18c85a6e5a701e47b1f8561408e0cc56539b6bbf9561df91358	8	8887	887	854	878	5	4	2023-10-31 17:43:50.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
880	\\x0c20180cf4ce6c87bbcae0b708c2b6140775ddab987d83ae4c87537088c75d0b	8	8908	908	855	879	3	4	2023-10-31 17:43:54.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
881	\\xd95f39d9b54d73f32fff8c0c922f0667780a6fba1b05242e58dfdd64f4cc79bc	8	8920	920	856	880	12	4	2023-10-31 17:43:57	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
882	\\x8634362b71fce7c89ece59b165ce05e95f1ec0959f844cb9f7a144c239e158de	8	8937	937	857	881	5	4	2023-10-31 17:44:00.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
883	\\x5a9e27f593e9935980935f44f9e9e6adc584176d6b5d8a151d063706c1498f92	8	8989	989	858	882	3	4	2023-10-31 17:44:10.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
884	\\x79531ce0f60ff1bbc5791b1275d2a6c00c91b74552416e85d9a8082682fdefd2	8	8990	990	859	883	12	4	2023-10-31 17:44:11	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
885	\\x8110fa759b57bbc4d0da5e7694a60be0144374e1e1daeff7f2595088c573abbf	8	8998	998	860	884	14	4	2023-10-31 17:44:12.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
886	\\x000981427010ec72400e364432f4b4c508a773e17c861b5210e4f5fcb90896a2	9	9009	9	861	885	14	4	2023-10-31 17:44:14.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
887	\\x1025c5000bfee24f46c3f652f4eedbdb0a20a3413de3059de7e3509c66e209cf	9	9014	14	862	886	5	436	2023-10-31 17:44:15.8	1	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
888	\\x24568879ddff84ebb2fa48deb6a8a1cb42495c0be40dee154313b8837d59fdf9	9	9019	19	863	887	5	4	2023-10-31 17:44:16.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
889	\\xb20114b860020ac952e7eceda2e37154fd1d5965048d496495580ae52482ebc6	9	9034	34	864	888	14	4	2023-10-31 17:44:19.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
891	\\xea2e8ff6aedd2a50576f76d10218efedd3fefafc0fcc68a055f999d864dff56c	9	9046	46	865	889	16	4	2023-10-31 17:44:22.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
892	\\xcbf71d40b8826dffb436e9ad7f2078f1fbfe140de4ab977d7543c51ffa03eb9e	9	9063	63	866	891	7	1966	2023-10-31 17:44:25.6	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
893	\\xdc3be7f6cba2e7945edc517a57ee3c3cb83d147e400a1a2e69ff1d5ae20622e9	9	9079	79	867	892	8	4	2023-10-31 17:44:28.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
894	\\x4b77042d5418ff52b5ca721ff8a92ef9bbf6c5e4f21d403d5d84c581f78d443e	9	9082	82	868	893	16	4	2023-10-31 17:44:29.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
895	\\xb31e8275d4ffbcca46ccb4eefd33d20845fa7af76d2d989a0e21d7eb28a67c12	9	9112	112	869	894	14	4	2023-10-31 17:44:35.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
896	\\x638a4af04306034b66eb0ccd44750482f8a89671d286cd1135bccba6396ffc52	9	9124	124	870	895	14	4	2023-10-31 17:44:37.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
897	\\xc2cd8b3bb08ec38895292935728d171f817f4fc423ec135360dd46a5b33f19ad	9	9145	145	871	896	7	4	2023-10-31 17:44:42	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
898	\\x52b8d18db0dfea7bba5b08f3adaa1264517d8873b04a14eaac3bbb45f7b97d3c	9	9147	147	872	897	39	4	2023-10-31 17:44:42.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
899	\\xfe55fde81d8f6ada6fbc5cfe5055e9830d8051dbafb22930a7bd74063b5d8048	9	9148	148	873	898	39	4	2023-10-31 17:44:42.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
900	\\x6701c561d3ae6974cbf0ef53cef72eede80d1fd4b2cf86b6d4d53c21be38395f	9	9149	149	874	899	7	4	2023-10-31 17:44:42.8	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
901	\\x87773aaba23821a56c2357ddc9ca497d423377f8f54a23e5d941724c0f29d8fd	9	9155	155	875	900	3	4	2023-10-31 17:44:44	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
902	\\x9b85be21d49d16c86d704c46216bedbd1ab91ea662da60f816131a63c950994f	9	9156	156	876	901	3	4	2023-10-31 17:44:44.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
903	\\xb3eac4d724ea315f4b84ad930d6cd3c285df10df38566267bc88217d4f53c2a2	9	9194	194	877	902	39	4	2023-10-31 17:44:51.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
904	\\xf8160d23fe98f23289696095572fc9e491038164d0dbecef1c187a39f3b1832f	9	9198	198	878	903	8	4	2023-10-31 17:44:52.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
905	\\x643dcbf17c92626b51644e33322abf88639297f64a9604f9af48d0b2a6af2eeb	9	9201	201	879	904	4	4	2023-10-31 17:44:53.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
906	\\x5f428e72a2b8bd234b53f5c478e8b2d9de7cecf1ec3511bcbb315099600bc50c	9	9203	203	880	905	16	4	2023-10-31 17:44:53.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
907	\\xd1fe98d961ad54dfd95804994b3789213168d24a4a0c7f19e562240e4142088f	9	9209	209	881	906	8	4	2023-10-31 17:44:54.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
908	\\x7fcfe58f95d91d8e25d494d73fc3e5e2a70d5093f6efb188846f90c914d1e053	9	9229	229	882	907	8	4	2023-10-31 17:44:58.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
909	\\xe276db4e4e8193f28881c1baf6d7ab3b033b13f7f1e280ff499a869b6edacf06	9	9236	236	883	908	12	4	2023-10-31 17:45:00.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
910	\\x006f078b67ec76cd7d5f7d7fc0ea972ad4cf71e9fd8b58737f69d014701c689c	9	9239	239	884	909	16	4	2023-10-31 17:45:00.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
911	\\xa80ede5b88957d2e6047d6eb93e6f9e05b6a2eb746251167d22be79d523b465c	9	9248	248	885	910	8	4	2023-10-31 17:45:02.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
912	\\x28c88e5cdc8e99c085c4335c3aaa2f3fb7d8304f3593b5ed7200c82281ece576	9	9253	253	886	911	4	4	2023-10-31 17:45:03.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
913	\\x0c593463a2eadcddcf1e400a971d5d38b4e3f8892570f4e4bf8ad96e1a36805d	9	9265	265	887	912	14	4	2023-10-31 17:45:06	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
914	\\x5da4d848bce8d38500676df997ebdd3f2b8a9fc0fe62e1da4434363737091c58	9	9274	274	888	913	4	4	2023-10-31 17:45:07.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
915	\\xccfc49a379f6239320a2a1c46652287e31e86c6a970f8088ff4baf3ca9697d84	9	9292	292	889	914	14	4	2023-10-31 17:45:11.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
916	\\x5b65b9dffe245229d480c5633ee24ab9e6f04ec76a21df03391fc9883edd77ba	9	9296	296	890	915	7	4	2023-10-31 17:45:12.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
917	\\xf001e0fb11082d71492fb2762b55d30f785bdd7239d9c444d03e67897a52f4df	9	9301	301	891	916	5	4	2023-10-31 17:45:13.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
918	\\x071d78eb37db9e258f55d13b7231128027e4dc49905bdbe5e3ba0c8bd674d3a7	9	9310	310	892	917	39	4	2023-10-31 17:45:15	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
919	\\xeb572c6bbf1850d70676446a2430d17271b7a3b220ce050531a3665af9809b43	9	9318	318	893	918	7	4	2023-10-31 17:45:16.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
920	\\xfbc4d649772a5cd766d51579abb48cbaa3231b6e09c7703c2bbc0af616ac1d6f	9	9325	325	894	919	7	4	2023-10-31 17:45:18	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
921	\\xb6920ebde54735e78ef228bd222cc95de72b668faed75699a077a462e0023dfa	9	9352	352	895	920	3	4	2023-10-31 17:45:23.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
922	\\x1d81c71c9dce7e5428bf3837cb4b4f384f06d02ef894f01e2c95c2fe402a6f24	9	9362	362	896	921	14	4	2023-10-31 17:45:25.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
923	\\x1545d1d112f33a7d4e43200df14caf746f985fb36cc5771fa8799280e74c3f2f	9	9366	366	897	922	4	4	2023-10-31 17:45:26.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
924	\\x5abf59489db54d4e13744896db15df53878429ef4a674036560946b39903396e	9	9373	373	898	923	4	4	2023-10-31 17:45:27.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
925	\\xeec908be8b0bb34b6d4df8bd8829adbd9e7221f26b62c0bbf855c004a3cdc69b	9	9382	382	899	924	5	4	2023-10-31 17:45:29.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
926	\\xe57c9ee2dd197f4c08b974b476d02c807b1fb1191d1eb13fa30675417f9e5ace	9	9385	385	900	925	8	4	2023-10-31 17:45:30	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
927	\\x41f0e4b8dade96b16e9471382e5fe42ad20a388008fb2d752a153937489d1b8a	9	9390	390	901	926	39	4	2023-10-31 17:45:31	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
928	\\xaf1fbc1de8b9078eed0bdc5ce64e3bacc4c82c4e9a18f88b4e35db2457be60ea	9	9392	392	902	927	12	4	2023-10-31 17:45:31.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
929	\\xe6b845cae4de6ecab4d74be1732a6a218f464c580509b7afc043040094c7fd4f	9	9410	410	903	928	3	4	2023-10-31 17:45:35	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
930	\\xa5261dcaa4048b8fa000f2b35f803dadef0a56893465ed24f53ae9b68797cf63	9	9415	415	904	929	12	4	2023-10-31 17:45:36	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
931	\\xa1defdf0d0055a369b1917e569c50faf0d0e83fdf0936542cf8a2d6994099852	9	9434	434	905	930	39	4	2023-10-31 17:45:39.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
932	\\x6c18cbbe0a8cb287225ae3a1bedc5ceba080b4788e8b088d86b52fee2b2c5e8f	9	9439	439	906	931	4	4	2023-10-31 17:45:40.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
933	\\xe68eb31c581add80fed3cff568cfe32038d13effa125a7251aa7c3945e1e360d	9	9442	442	907	932	5	4	2023-10-31 17:45:41.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
934	\\x01c8cf5523018532701f1ace13f3f780e4d06a0222c2af102f354456518c58f1	9	9448	448	908	933	14	4	2023-10-31 17:45:42.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
936	\\xc30f0662ae48a950007de98bd80a8fa0f5370e71c5d7b1aacc84e5bfac1c4078	9	9468	468	909	934	39	4	2023-10-31 17:45:46.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
937	\\x8165fa2804bb25e16dee6ba59020ffa92bfd46fda7dcaaf2edc147f15b4ae3d7	9	9470	470	910	936	12	4	2023-10-31 17:45:47	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
938	\\xc0aae131bdb489eb7d349cac72d670667beb14bf048ea9030a5697326d87193e	9	9477	477	911	937	8	4	2023-10-31 17:45:48.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
939	\\x57740fa3699e9abd8949110f3a07b14291df4ff24b6f35100de70aa6f6bb8562	9	9478	478	912	938	7	4	2023-10-31 17:45:48.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
940	\\x1c29c8f05d35cc57cd3b371db99f0fc25c02a5c685db48d667e1a3d2072cf1d7	9	9482	482	913	939	4	4	2023-10-31 17:45:49.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
941	\\xb3a5fd2b7b894d1ffcd65bb4a3fb3e03e4fcd794d790e600393469c5318714e5	9	9486	486	914	940	39	4	2023-10-31 17:45:50.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
942	\\x4b00c4f1e444734821de3310144da36bc4c437ba439c1c1906a94e15e84f8e9c	9	9492	492	915	941	4	4	2023-10-31 17:45:51.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
943	\\x63649743c735faf8cc50c2cef78d48446bfea96f18a4f25b40fe2cd40f920484	9	9509	509	916	942	12	4	2023-10-31 17:45:54.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
944	\\x67ff4f76a884cc78cb8decab03168d891fff446fd00bcb147ac216fab7857ad7	9	9519	519	917	943	3	4	2023-10-31 17:45:56.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
945	\\xd38e95b0b6276a42187bcff64c4901773b7fc80e1acac2d54e2536a3777ede32	9	9534	534	918	944	3	4	2023-10-31 17:45:59.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
946	\\x4d221a1fde4b9d5a208f285b93b71f2f8213f2abca4f664da2c018080ce94ed2	9	9535	535	919	945	39	4	2023-10-31 17:46:00	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
947	\\xda0f8aee904b3ac6708d2c1a6cbe3638cde106fc11eedce5b3a58ec23df94fb8	9	9546	546	920	946	3	4	2023-10-31 17:46:02.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
948	\\x73af333281b21b3e67e3487c8b7672f5608be947a5b39ef525f36b168ec3fecc	9	9559	559	921	947	3	4	2023-10-31 17:46:04.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
949	\\x0b07d17ccb0ed5310b0c4f4ca709a4837c85369142e65aefff4dceb67a8dfe6a	9	9561	561	922	948	5	4	2023-10-31 17:46:05.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
951	\\xd1b8541770ce2fd37277258fbbba89ae60c343f9d354f2361728760b941594bb	9	9586	586	923	949	4	4	2023-10-31 17:46:10.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
952	\\x38cea03a1a87941650d0e86f5fbfe77901a49a8b327824d9f50ee9626a74d618	9	9592	592	924	951	12	4	2023-10-31 17:46:11.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
953	\\x1806c74aba8f44c26c4a6d81abfc168afb7b6bd833819049193eff7b32751cf4	9	9606	606	925	952	5	4	2023-10-31 17:46:14.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
954	\\x27913c512b3ce77135d693f2724b021abdeb7e17f18074649cd3d4761d709904	9	9613	613	926	953	7	4	2023-10-31 17:46:15.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
955	\\x37a7d8ede003be17dff35e570c0c9dbed77ba3b58c08bfb4667378c456c5e7c0	9	9628	628	927	954	16	4	2023-10-31 17:46:18.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
956	\\xea16665ffbcdd165ff87c7fdc059edaa12512a44cb29dc3b554e39f4ecf4a286	9	9638	638	928	955	7	4	2023-10-31 17:46:20.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
957	\\x4f98bd09b651d789380ea87ce5a7a7f11f9931ba0f5723acccafe28f8bed0358	9	9639	639	929	956	5	4	2023-10-31 17:46:20.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
958	\\x8db19841b349a5ee96e27fd4d46d33d17355f522a31bac209aa5e9133f73e996	9	9649	649	930	957	4	4	2023-10-31 17:46:22.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
959	\\x5fd0c7e103096bdb06b5737910c3d89b11a47ddb4082cc4b12f01f517ab6305d	9	9654	654	931	958	4	4	2023-10-31 17:46:23.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
960	\\x8269915b6f681b506c60099c0e3d3ee3decff2b8e5cac43bbdfbb594e471468c	9	9663	663	932	959	39	4	2023-10-31 17:46:25.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
961	\\x6b58e2233b0b276fcc81cd6238a2663a5252eabf6e1d38814d97464994e5bd20	9	9664	664	933	960	16	4	2023-10-31 17:46:25.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
962	\\xbe8600828561c3597ac06977b1842b51fac3f1c213d1e3e46534fe9bb5f1a609	9	9678	678	934	961	7	4	2023-10-31 17:46:28.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
963	\\x3bb7c4814ffd91345d32071b224063015fd5a501cf01af94c68f8e62d76fa7d8	9	9680	680	935	962	14	4	2023-10-31 17:46:29	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
964	\\x7fa4bcdc79ed3d229f93bac6e79ce8fefe8a3db291d55248dfe452256de4f6be	9	9681	681	936	963	16	4	2023-10-31 17:46:29.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
965	\\xa24b856e8022a9fae2616ea5c118fcdcfe3f93fe34ebc84499653bc9cbead6bd	9	9683	683	937	964	3	4	2023-10-31 17:46:29.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
966	\\x04d97b519a8d5e39c156fc60f5ce817afb491b226c104c98a1df0d8cc72ff9fb	9	9688	688	938	965	39	4	2023-10-31 17:46:30.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
967	\\xbe6394350b6f20f981343767d0f6a92bc6d8523517d1b099cc8555fa2d8598d3	9	9693	693	939	966	14	4	2023-10-31 17:46:31.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
968	\\x6ebdc4b1b3e4837971a18a0e28c0d4ce7ff71341b5559aaf979b10c08a4e5613	9	9694	694	940	967	8	4	2023-10-31 17:46:31.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
969	\\xf5cfba17153d8176ddf5f1e5f8c7b06f24182566201e6d90cfa433e4d1d62a93	9	9723	723	941	968	5	4	2023-10-31 17:46:37.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
970	\\xc31ea5faf518ec7e1e73f036cfebb855b8a365d61ebbeeae9454eb9dbaaa2f43	9	9726	726	942	969	12	4	2023-10-31 17:46:38.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
971	\\x80975c9fa62329d381d3306e5295c7c967bcff4d654c42f4ad66f24fa443822f	9	9765	765	943	970	3	4	2023-10-31 17:46:46	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
972	\\x75676e83fb39166cad5e57c75e59f846d17e206872f77ec19599aa5fef7d3749	9	9772	772	944	971	14	4	2023-10-31 17:46:47.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
973	\\xb204fecec40e46d8c7dcf86fd6f4527b33f1bf37e78dd49ade02377b356e3c38	9	9799	799	945	972	16	4	2023-10-31 17:46:52.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
974	\\xf832aa28959c27291be5c638b57b8d8352326f283e785430ca0b0952ac823a55	9	9803	803	946	973	7	4	2023-10-31 17:46:53.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
975	\\xf9e19c65c456d93eca37ca097ba5513696c1fa8c3c1174e6c05413500382ceda	9	9809	809	947	974	16	4	2023-10-31 17:46:54.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
976	\\x8e3e03c5565b8fce253ee8de6e959f03798ee67417e8629c3f7f90b4f2e6cc54	9	9811	811	948	975	4	4	2023-10-31 17:46:55.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
977	\\x274f6ce688cba109962ce63bff51dda0aa06fb10d1d1cf556ebd06ef6d8883f9	9	9833	833	949	976	16	4	2023-10-31 17:46:59.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
978	\\x242a5a65f2b15c86a785662742fe6f46b2a0baf341668618e24f798021c7741d	9	9850	850	950	977	12	4	2023-10-31 17:47:03	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
979	\\x5fb20eeef01260ed468e049cd4660cd9b15024927e707a7dcec2247636549d25	9	9874	874	951	978	3	4	2023-10-31 17:47:07.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
980	\\x25d753fafec860c640af8f5285cd09f46b642fd9b16f52143cbf47d81f582b98	9	9894	894	952	979	39	4	2023-10-31 17:47:11.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
981	\\x190847f8992b04ffb93ae3f9c8186c18fac1017c973fa820e34c20473d7e4e34	9	9897	897	953	980	12	4	2023-10-31 17:47:12.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
982	\\x3d38fbad79549715e9ee934f6aec254a01b0b87559661e1c4fb26b0547dc9d85	9	9902	902	954	981	3	4	2023-10-31 17:47:13.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
983	\\xb3eba159877a1d2dd8da0c277c599bd17da777154cad18217bb18ebe7d04f50f	9	9915	915	955	982	12	4	2023-10-31 17:47:16	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
984	\\xa9ecf394bab63c44cc4da53f634d662006fc66433b8975c96cf616718ba492d0	9	9925	925	956	983	39	4	2023-10-31 17:47:18	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
985	\\x102db551cce29ecd521eb003b8e1fbe32e3ce51dcde31171d4e0a29ca53d5586	9	9936	936	957	984	8	4	2023-10-31 17:47:20.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
986	\\xeb4b9f87a0e8ba69dd529d7076a24623823e4c6e3ac4eccf34ae0eab3a8146c0	9	9940	940	958	985	12	4	2023-10-31 17:47:21	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
987	\\xa09abad8448411adfd7de37b7791260c39e1899c54c480bdfc5595dffa10f329	9	9949	949	959	986	14	4	2023-10-31 17:47:22.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
988	\\x71850dcf657ebf1cdbe704a22f25816d123a03167b07fcb3d12b8239ef13a107	9	9974	974	960	987	3	4	2023-10-31 17:47:27.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
989	\\xf96ed467f6f714d68abd4854fceb4be0b530d41180d3539ca63c54262802ceac	9	9978	978	961	988	14	4	2023-10-31 17:47:28.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
990	\\xfa4acbf2713bfab351b0b32b7db366a074b7b51259daa54cfa1bac86aebd1ef5	9	9986	986	962	989	39	4	2023-10-31 17:47:30.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
991	\\xf9f93a998b911ef2f39741fa254f5032b414b49b0f9cdb10f7f5723dd8cb8c0e	9	9988	988	963	990	7	4	2023-10-31 17:47:30.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
992	\\xde63c01c72781d5679e6918e8940fcba912509b62a671ae4a3847a689f3790d3	10	10016	16	964	991	7	4	2023-10-31 17:47:36.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
993	\\xeeeced2f86f2d51e7e9e9e850b1e7c4a9c7ffb9569be270bf0e7bd979f4e43fc	10	10017	17	965	992	8	4	2023-10-31 17:47:36.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
994	\\x485063fd2d45551ffc75a377ee9f61e8bc56509201a2827ef52eb68445f8217a	10	10027	27	966	993	7	4	2023-10-31 17:47:38.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
995	\\x14734f9703500f13a254f0f58f94986c4bdc7be84f0492bc5b3bc64952cc0976	10	10029	29	967	994	8	4	2023-10-31 17:47:38.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
996	\\x8217bb866160cc34e445bf219aa287d1d72cc97b76be6be05b47a9da11e6ac75	10	10035	35	968	995	8	4	2023-10-31 17:47:40	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
997	\\x0d3fd036545535a85fb23301604aa8833358b3bc7c885fa3c653d23c0b2b61a9	10	10038	38	969	996	39	4	2023-10-31 17:47:40.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
998	\\x5d0c142a3efeaf9d22b6c8b31c497c060a2fef252c360d6ba88beedeec0c1ece	10	10041	41	970	997	5	4	2023-10-31 17:47:41.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
999	\\x1df08ebe8ff698e2b0a163b1960321026e326a1ef199c3e569da01aac04f91f6	10	10044	44	971	998	7	4	2023-10-31 17:47:41.8	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1000	\\x6769baaa69d0f818cf76f10fff1ea073238d99a73c4baba127ace13eb2572718	10	10057	57	972	999	3	4	2023-10-31 17:47:44.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1001	\\x6eec48d8baa76a4d6b66abd4fa09b20f85e4aab300cf5d02b3182975156d0413	10	10072	72	973	1000	16	4	2023-10-31 17:47:47.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1002	\\x33219beb32ac553264eb8ac42f429b89f41ed1d4150c4a867a6f15be6dd7e589	10	10081	81	974	1001	3	4	2023-10-31 17:47:49.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1003	\\xdae362476acb2a277ffe0f8840455f0214c204b10e35c8b2d73e4b786707a00e	10	10084	84	975	1002	3	4	2023-10-31 17:47:49.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1004	\\xa8a438c5493de04be4521e8d793012290cdfce8bbda9e952dadf7e45e2a78d2e	10	10088	88	976	1003	12	4	2023-10-31 17:47:50.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1005	\\x552b620f9d8f26705b54bcb18cffba7b8ba5394dbe8742e5a7b00bf9831301a6	10	10108	108	977	1004	7	4	2023-10-31 17:47:54.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1006	\\x62c91cbb9a7cce366e8a2ed24156740bce3dadefe8ca24e64070d902a88322c0	10	10111	111	978	1005	7	4	2023-10-31 17:47:55.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1007	\\xfd9cee038d8573914a386e68b513a5c1cc689c63c8307fc9ea52c52cda681f3b	10	10126	126	979	1006	8	4	2023-10-31 17:47:58.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1008	\\x999700b42edce71530a8a306cc561fa5b145dd0bd9840f2cb2ae710856d11b27	10	10145	145	980	1007	8	4	2023-10-31 17:48:02	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1009	\\x8504d459efb329587381510558efd6dcffea2b7a75c7a7215d8b0487c31530f0	10	10166	166	981	1008	12	4	2023-10-31 17:48:06.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1010	\\x0443a8bc75edf536a4c9ec371d286ba902fd90f9f60bf5f71d44f6ee27b3e9b1	10	10172	172	982	1009	4	4	2023-10-31 17:48:07.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1011	\\x9e2b9e11403bdc0d741a840b744d834b55f48fed257b0f79e18d9d247b34f455	10	10179	179	983	1010	16	4	2023-10-31 17:48:08.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1012	\\x37c4e5f03b6dde62f24795d09878c60135b05ae2637315f2114357344262d8a3	10	10205	205	984	1011	39	4	2023-10-31 17:48:14	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1013	\\x9bd3bcc013be80ba05f8af59ff5129ec7e1846a7bfac3deac8fa21ea5c4ce1f0	10	10213	213	985	1012	14	4	2023-10-31 17:48:15.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1014	\\xe802581ef9647fed1822bc7ec6ded6640ba76eeb2667372205123bc5babafc03	10	10222	222	986	1013	16	4	2023-10-31 17:48:17.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1015	\\xc16259b0714ec92aca0f614957234e9bf53562a935770fe9ac3b057c3f00505c	10	10228	228	987	1014	14	4	2023-10-31 17:48:18.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1016	\\x8a87712096a75939bf02f8c4055497a9a491dd397b0a75a451ee4106ccd17be7	10	10231	231	988	1015	16	4	2023-10-31 17:48:19.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1017	\\x5d887106b67d84a8f966c1a0d381bb4dc43bd4b172a96c8a90b2bf19f5db734d	10	10238	238	989	1016	12	4	2023-10-31 17:48:20.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1018	\\x392a7d0bb52ac5863b3913d42fa74b335af08910d76ad1409097834b4d3d0124	10	10244	244	990	1017	16	4	2023-10-31 17:48:21.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1019	\\x987fdf0bfa197b042832b40cbfa01ae1ae928cd7d3c0f9d9b8c1dfdf82df2470	10	10247	247	991	1018	4	4	2023-10-31 17:48:22.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1020	\\x49c2ddb9e85eecd914d3e998eaccd16d98e77b1aa344de3a197f5a5c9e973672	10	10249	249	992	1019	3	4	2023-10-31 17:48:22.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1021	\\x8219b2d6abd746a7f58b98a5bdc0abfff9f819a8bd7cb2c653a553ff644e6f04	10	10254	254	993	1020	3	4	2023-10-31 17:48:23.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1022	\\x5af49f61fa6f621ed27706ce565a2cd17563f5331811514887e2406619dcbff8	10	10260	260	994	1021	5	4	2023-10-31 17:48:25	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1024	\\x0895ab21c0044111d7a9d662f75fc8dd703cb99aea196ba89d92c83b0d9a7b6c	10	10266	266	995	1022	39	4	2023-10-31 17:48:26.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1025	\\xe2456cd0c55d18bb1de4f89cdff76c31a4d79bca645623ec122ca5f59885fa48	10	10287	287	996	1024	39	4	2023-10-31 17:48:30.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1026	\\x75b7a000d545dc6569a23fe3be5493076ff2b4a46cacdf42b2fdb473934966e0	10	10306	306	997	1025	8	4	2023-10-31 17:48:34.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1027	\\x737f8f39f7e3deb4aa2401bc9918d4812c8ea1e3a85fadba839369a19090d798	10	10311	311	998	1026	14	4	2023-10-31 17:48:35.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1028	\\xc5f89e5c3788dc5d3cea4bfa774202b7d225fbefb3fd0dc75f9de7e822005d6b	10	10320	320	999	1027	7	4	2023-10-31 17:48:37	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1029	\\xe969c748cc9ee08b8190f8c3cdbeeb6708986a7d128a8fd554882f66c63f71e9	10	10323	323	1000	1028	16	4	2023-10-31 17:48:37.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1030	\\x0fd43cfa0427175f3dc7e108723a2a9c79372db44e8a454d1e70088d8b2249e0	10	10338	338	1001	1029	5	4	2023-10-31 17:48:40.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1031	\\xcb5d9bd6a2dfb9e8718fc56c4a63edf014fb65985383562626476dad463f2566	10	10346	346	1002	1030	14	4	2023-10-31 17:48:42.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1032	\\xe5b2e3b23055bada1274f16bc5da2c70d61d63f2e6e70b8bd4a9bddcedd11dd0	10	10352	352	1003	1031	8	4	2023-10-31 17:48:43.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1033	\\x5ff09ec8dabcd1b21b1d0f85488ceead452109919f0515037d274fc92d198ec5	10	10363	363	1004	1032	3	4	2023-10-31 17:48:45.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1034	\\x87c7955092820cf02999befdc569d0d2b889a7ce4ab21ed2d673c408ad6d0e11	10	10371	371	1005	1033	39	4	2023-10-31 17:48:47.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1035	\\xc6c56f9b235cf126353b7b46f614140e335167200cd6c186dd323d53a8ebda64	10	10376	376	1006	1034	7	4	2023-10-31 17:48:48.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1036	\\xaa03bb3e278d46ff695aabf10431a964bba717cb90d8ed0d3d54a6bf62969bee	10	10382	382	1007	1035	16	4	2023-10-31 17:48:49.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1037	\\x77c096392411892afd083824e2d08f90bc61909dbdb5794d383e515bad9229cd	10	10388	388	1008	1036	3	4	2023-10-31 17:48:50.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1038	\\x68b6927451c8adfe0d89cf423f17cbcce1eacd22c355ee37abfd0a95a7c5085f	10	10390	390	1009	1037	4	4	2023-10-31 17:48:51	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1040	\\x1494c3aeb4182ff265836bcb037ed20b45bed47848a0b3e595746d1dff05903d	10	10403	403	1010	1038	39	4	2023-10-31 17:48:53.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1041	\\x3b3aa4c2597c752b7edd8b6be86b0e866c6bc2b6f365d41b394b836f31924303	10	10418	418	1011	1040	16	4	2023-10-31 17:48:56.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1042	\\xa4855cd79fc80dc41fdbf3924e25fe59fad0f269f31227438be1c2c23c69fa10	10	10420	420	1012	1041	12	4	2023-10-31 17:48:57	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1043	\\xce6c9ec879ed7db79272cb0c285e06bc27fcd36ee4e3ca97a5ade1f4652c048b	10	10424	424	1013	1042	16	4	2023-10-31 17:48:57.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1044	\\x10eb7a32035322b343dfb5a3b0584f9773551d75ce48c3853ae5416114898548	10	10454	454	1014	1043	3	4	2023-10-31 17:49:03.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1045	\\x585c149b87f8d6f6024470222923ad77db78c81046b26863a925a97cac248f94	10	10465	465	1015	1044	7	4	2023-10-31 17:49:06	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1046	\\xf13b6e109725d5081902df919d608c366939c4e986132259adcabde9965f7738	10	10468	468	1016	1045	39	4	2023-10-31 17:49:06.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1047	\\xe359a11ab816602c4388a734905e8b750559c18ff8f9d14e15813dd5b01a40ca	10	10482	482	1017	1046	8	4	2023-10-31 17:49:09.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1048	\\x7b8f29e084efbf5e4608ac825f6b0e75d8e52a725ecd0cf2d94281266e9c4ace	10	10485	485	1018	1047	39	4	2023-10-31 17:49:10	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1049	\\x74242a894b674f209837867844d64ed2cab7ce73094c8ea9d293197f17a074e4	10	10498	498	1019	1048	39	4	2023-10-31 17:49:12.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1050	\\xa01e8ebf85a03c58544e5a67198636aafe1fc8c404feee7eafbea746a79b22e1	10	10539	539	1020	1049	4	4	2023-10-31 17:49:20.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1051	\\x0450fba2897ba047f66e0ed99012adbb6a4d2f9e8dc096e289456f38b299aa86	10	10556	556	1021	1050	5	4	2023-10-31 17:49:24.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1052	\\x5f2f2ad37c8d62311de153276727eef1c39eae8734c27d69cd54741f93295228	10	10580	580	1022	1051	39	4	2023-10-31 17:49:29	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1053	\\x37e4b29ce5c403144093582b5ae6c6eb29c6ec3c3aa373e9e7dd3d4f8cc80660	10	10582	582	1023	1052	8	4	2023-10-31 17:49:29.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1054	\\xaab204f8682c15601a72e0061a9991a677c091c316b845ca714668fab73914ec	10	10586	586	1024	1053	3	4	2023-10-31 17:49:30.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1055	\\x5827f857e4686f08d69596e117e66666eb3da1045467fa01a8d7ff77f220da13	10	10610	610	1025	1054	12	4	2023-10-31 17:49:35	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1056	\\x8df9b511043b9f04473b777f55a803bd5fc6b51a5ec7a13a374a5848057e0bf4	10	10631	631	1026	1055	8	4	2023-10-31 17:49:39.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1057	\\xf091db217619314dc61ea17705e1914ce77312ecc3f818f6afb5384604cb0af5	10	10635	635	1027	1056	5	4	2023-10-31 17:49:40	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1058	\\xe86a704ed300fa05f14bb4bf8ba0525cc1e1ecf146b3a67bae54b9e3dd26f27c	10	10652	652	1028	1057	5	4	2023-10-31 17:49:43.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1059	\\xa2f76561e9d943828efede2f1c153c645a0377fe21f925d2815a33cac66df9be	10	10658	658	1029	1058	7	4	2023-10-31 17:49:44.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1060	\\xd468c047735dc5a849b8681ec89840eab3195d126270f003ce6d0abc29d520d8	10	10670	670	1030	1059	7	4	2023-10-31 17:49:47	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1061	\\x287107c7b15b4f7f9f3f87229089876ced2709a72cf7f5c04ba1c8428a9741de	10	10698	698	1031	1060	39	4	2023-10-31 17:49:52.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1062	\\x1b671e0498c1dc2928e0f50114f6896e4be5e892c7b0b92bcbeae2c6035454e7	10	10700	700	1032	1061	12	4	2023-10-31 17:49:53	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1063	\\x537b4c4cbac88d5f61864b1e4e5ec9ab53e50e57e1ebfd48093d14a0324a7531	10	10712	712	1033	1062	8	4	2023-10-31 17:49:55.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1064	\\x3acb93ed49194f824902c0c058208991e5ead7743c6296c6b6d0bdfdbc1ce1c4	10	10733	733	1034	1063	14	4	2023-10-31 17:49:59.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1065	\\x3a73a8154e493f40e755133790a39494b815d00844bb4bb97358d5a3596998f6	10	10738	738	1035	1064	14	4	2023-10-31 17:50:00.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1066	\\x58078f775c879070ff6bbbb1ad5f47fb0a3a3c833e8b5e1e6de999c415258de3	10	10741	741	1036	1065	4	4	2023-10-31 17:50:01.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1067	\\xc8a0214b54ef965a3a6d402d600a889d87042a9b0ab40d920ec10ab97a1fd582	10	10748	748	1037	1066	14	4	2023-10-31 17:50:02.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1068	\\x2957ee4ebc37729c42aa1337c5201eea3394150e1ab5a0b8af7cca32b993bdfb	10	10757	757	1038	1067	5	4	2023-10-31 17:50:04.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1069	\\xf87c583f0d7b0b12615483a0cc64655bffc1a9295ddca21f7e1387bd8d748fdd	10	10769	769	1039	1068	5	4	2023-10-31 17:50:06.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1070	\\x2c634d4a35bba0acc88149e95a82157648cde90d184ab7bf4c35b537601bf163	10	10785	785	1040	1069	14	4	2023-10-31 17:50:10	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1071	\\xd1ce484ccf326d6d18d8a3b2aa8cee5cdf2614de8899ba9e78f030184b42426b	10	10786	786	1041	1070	39	4	2023-10-31 17:50:10.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1072	\\x8764cdfe909601eef99b21a90eb2a13a031a5c2031ab3719e2f5556f5ea8aa1c	10	10809	809	1042	1071	3	4	2023-10-31 17:50:14.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1074	\\x8acfcbbd5f023605992a14e3de14f1513e0695afa5a3791777a56ef8e4de85be	10	10814	814	1043	1072	5	4	2023-10-31 17:50:15.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1075	\\x9113794c7b85046928280d9f7f6f1b141c6798f8b3d69c9587ce2ab59827e126	10	10817	817	1044	1074	16	4	2023-10-31 17:50:16.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1076	\\x847b6de26cc8453ac4a510674bfd4dcd37a693d3395a23cb75e731a122fdb566	10	10821	821	1045	1075	5	4	2023-10-31 17:50:17.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1077	\\x98c1c6cdd1acf378ebd7ed44cd714d3ea1f0f638c6e3c28da859eae3e78b4f66	10	10822	822	1046	1076	14	4	2023-10-31 17:50:17.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1078	\\xeb8976a57bffde7a8de71531f1c19286eb967e8f9e25e42252c3f0c49743c63f	10	10824	824	1047	1077	3	4	2023-10-31 17:50:17.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1079	\\x159242f6db9961826ba2fda47e38773dd152231bf21f7abfa6c3b3a5e3dd3fbb	10	10830	830	1048	1078	3	4	2023-10-31 17:50:19	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1080	\\x7e4eaad1e466603a2f2c49cb519d7ea8861077b5fb880b5a63a62b71fbaafbe7	10	10839	839	1049	1079	7	4	2023-10-31 17:50:20.8	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1081	\\x315cde82a25a1572545bf9835cd2ac58e893866c057ebe4c1e941652ce857929	10	10862	862	1050	1080	4	4	2023-10-31 17:50:25.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1082	\\x963b6da5943d34c418ab79db963b908b62a497c8b70743e31a6be50baf5f710f	10	10873	873	1051	1081	3	4	2023-10-31 17:50:27.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1083	\\xf464529a0d87ee30dd76c66690e4becab0ac0e7ece6c366c83e36e0e5ab22acf	10	10903	903	1052	1082	5	4	2023-10-31 17:50:33.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1084	\\x9fe65c49eff5019eaba18b45e428da63ea6e1fdf2e24d444ad0407f53433b210	10	10910	910	1053	1083	39	4	2023-10-31 17:50:35	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1085	\\xf84da62baf83fd4ad9917aee66179076e93b62cf7c7129d56238ec27c99681b5	10	10914	914	1054	1084	14	4	2023-10-31 17:50:35.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1086	\\xf2376d5ede5ae5950dfc65d7ba81eb564439dfd57aa0c52bf820c5ee00ed2e0f	10	10923	923	1055	1085	5	4	2023-10-31 17:50:37.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1087	\\x54c2c677ac8fe61addb614da795882405e249863b7a890d9a82c38a76ccbabf0	10	10925	925	1056	1086	39	4	2023-10-31 17:50:38	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1088	\\xd25bcb68bc755f012b79075faaebfd6f998687ee4ad51326f3db9666cb3db953	10	10935	935	1057	1087	4	4	2023-10-31 17:50:40	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1089	\\x6c4f9c20952cf921e2f065f88d1698be674019ce73391820a69975d0d9228bc2	10	10945	945	1058	1088	39	4	2023-10-31 17:50:42	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1090	\\x851a2992fa41d70d91de03c75ce19be6c2986e42c12b505bd6b8925758928b95	10	10947	947	1059	1089	14	4	2023-10-31 17:50:42.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1091	\\xfb8fd861022d60d60d5f069f6c84490dda003fddd55fdeded1e323a22f92c45d	10	10956	956	1060	1090	39	4	2023-10-31 17:50:44.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1092	\\x81dfc88e9a5c15c9e75b23c491075c25487f481d3d4bd8fff408f12c791a529e	10	10970	970	1061	1091	3	4	2023-10-31 17:50:47	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1093	\\x91c4463a9a58e8bf666808e16032b68a682d36bbeafb774f793a1d967166d17b	10	10971	971	1062	1092	14	4	2023-10-31 17:50:47.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1094	\\x666b785dc097eed14b92568ef7dbacb09be550e4175bb5bd3a5ae9871f3bab7a	10	10984	984	1063	1093	12	4	2023-10-31 17:50:49.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1095	\\x2b53378d6229f253b641adfb32fb373c222f344d2b9bd738ce778e042389f75f	10	10985	985	1064	1094	12	4	2023-10-31 17:50:50	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1096	\\x52b44efe28c3bfc9f9b6e6cc58cf84f0106e798683aacddd33af31995a5470cd	10	10994	994	1065	1095	7	4	2023-10-31 17:50:51.8	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1097	\\xe4fcf2768917c4f9d64921c1dc141acc99efb68da38a989df7153337774bd71f	10	10997	997	1066	1096	8	4	2023-10-31 17:50:52.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1098	\\xc223d0cc899ca785d55340929120fc81205a2df82b9bde2ba18c530614dec42a	10	10999	999	1067	1097	5	4	2023-10-31 17:50:52.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1099	\\xcd947d4e0a625f404db973669460949c39dbc2d7aeb3b7283a828f211fafa953	11	11013	13	1068	1098	4	4	2023-10-31 17:50:55.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1100	\\x13f1109d97ff50f2e8a4f33bc307ca1b877ef79914511d824e259f9f3597b82e	11	11018	18	1069	1099	14	7321	2023-10-31 17:50:56.6	24	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1101	\\xaedbfab3df21d72c899097a16afc3f9d0f3c50e49a2e7d9c92fc085c11de0467	11	11022	22	1070	1100	12	7795	2023-10-31 17:50:57.4	25	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1102	\\x2d2a3d8010b297c87dc5211dc729c65b78633a0545d8e4b61d31e4026bcada7f	11	11023	23	1071	1101	7	1545	2023-10-31 17:50:57.6	5	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1103	\\x8eeaf8131e8312064e8859ea02a8da3d964703d914d1d9c0b3d5bcabbf6c2bd3	11	11059	59	1072	1102	39	14376	2023-10-31 17:51:04.8	46	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1104	\\x44462dd9610b7ebf0b1e2e0e0a7836e0d2ff8406f1fd29a7e00bd5e4488cbbac	11	11072	72	1073	1103	4	4	2023-10-31 17:51:07.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1105	\\x6218f3028db30dd7d4e6ba9da45ff27f7ef295a3b8d137e315b245e6f9dc1e1d	11	11111	111	1074	1104	4	4	2023-10-31 17:51:15.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1106	\\x437cda533727fc916808e9477ac0605ad130095fd59a1c299f7977bc93a3023d	11	11134	134	1075	1105	7	4	2023-10-31 17:51:19.8	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1107	\\x7a8d1fd68c4bbbe572ecfefd5f55bc975fd1bea60498e425d265777dd028a69e	11	11144	144	1076	1106	3	4	2023-10-31 17:51:21.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1108	\\x1a6fa892f091ad30b3c6484fa4c5099ef9fb8d72a247d3a662da814f6ade4899	11	11147	147	1077	1107	16	4	2023-10-31 17:51:22.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1109	\\x7cbaafa53287bc9eeadd28dd93851257f512d994c20c1eea2a22a6dd9a14dfbf	11	11148	148	1078	1108	14	4	2023-10-31 17:51:22.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1110	\\xd989d7873c13b2451bd1203f443dc25251b8204faf51d2e706474be5820666b0	11	11154	154	1079	1109	14	4	2023-10-31 17:51:23.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1111	\\x122bd5e81afaf51b0c357aa94efcc0f92bb9c859e4fb5642cb4424e917b0ec4d	11	11169	169	1080	1110	12	4	2023-10-31 17:51:26.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1112	\\x6cde4dce4364ed3dadb5f934bcfd1fc0da54404d4d8a1c0e877adbfa443e53b0	11	11173	173	1081	1111	12	4	2023-10-31 17:51:27.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1113	\\xf091d35548229985238ebb687c3ea3bc7dc8f66cda32410ec0e2029de942bc9c	11	11179	179	1082	1112	12	4	2023-10-31 17:51:28.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1114	\\x9f5358e2d1fd3f1704192923e4829aa9248e0049a8c35b2194c1b85553e5592c	11	11182	182	1083	1113	12	4	2023-10-31 17:51:29.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1115	\\x9373b766fa098d60eeaa259bde7fbb336159dd9bbe300855933548c24a162526	11	11188	188	1084	1114	8	4	2023-10-31 17:51:30.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1116	\\x44fdf8defdee01de89cd24d43faf853caaadb95cf9ee55c01b2e15d1f8d33d87	11	11196	196	1085	1115	8	4	2023-10-31 17:51:32.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1117	\\xc304f28b9dfd119bcf8990a5f3700285e9cf0ebbade1f4518b56032b3740d17b	11	11204	204	1086	1116	14	4	2023-10-31 17:51:33.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1118	\\x0f8260233803ee52929e509535a14325fbd3dc081545a2444ffbab6de811816d	11	11213	213	1087	1117	3	4	2023-10-31 17:51:35.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1119	\\x96ae6a4c77757283a438f4dee8d1e04262ada2ba5124df40faae6f4acde141dc	11	11218	218	1088	1118	39	4	2023-10-31 17:51:36.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1120	\\xa5bc85076a51cc58201b505382fffb405853c87009776cfc84627bfc721c0863	11	11219	219	1089	1119	8	4	2023-10-31 17:51:36.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1121	\\xfb8dc819c5c3a581cbcfc7e42ca0e59b9edee8c3e9caa46ce7c0a29126f866af	11	11242	242	1090	1120	7	4	2023-10-31 17:51:41.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1122	\\x66e4e723aa97221f89aacb959b023010dd1105a065748ceb62d3e1c87e7e9eee	11	11264	264	1091	1121	16	4	2023-10-31 17:51:45.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1123	\\xebae1114b3b4766c786d685dba997a9b45f536bee8abf4a63dddcd11e8eb9dc5	11	11287	287	1092	1122	12	4	2023-10-31 17:51:50.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1124	\\xfcbfd7cf5f77b20cc82c4f32462fc3b00ed979dfae7db6ac327cc42efaedd9a9	11	11301	301	1093	1123	8	4	2023-10-31 17:51:53.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1125	\\x1fe3f51f4dcc070dccbe29e5ebf447ea993a5395b2d76f32029b8e565f982155	11	11309	309	1094	1124	5	4	2023-10-31 17:51:54.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1126	\\x33819d1b197c781746bb709eddc4758998d41af00f190251908a0df20e76752d	11	11315	315	1095	1125	5	4	2023-10-31 17:51:56	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1127	\\xaedc1c62d67d5f1121dffc12d5d017a29d7fd337e44a0dd7121182e1a0b539c0	11	11318	318	1096	1126	16	4	2023-10-31 17:51:56.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1128	\\x2fe4ee12cef8bf09b14da3e45735a261bd65b1a9bd4447175d451f060b3f6233	11	11326	326	1097	1127	5	4	2023-10-31 17:51:58.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1129	\\x5774772a9ae9a24ea7e555c7075dacc408a853dea6641546fd96bbbfba19d0f5	11	11329	329	1098	1128	4	4	2023-10-31 17:51:58.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1130	\\x45e22e6488409da97299baa850043bd3a7392852a573934ef016b80d202c2df7	11	11337	337	1099	1129	4	4	2023-10-31 17:52:00.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1131	\\x16e42e82027584cc5c25b8f040cd11873c58fe36a78184a36f65faee6b039842	11	11356	356	1100	1130	4	4	2023-10-31 17:52:04.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1132	\\x3fe643a479e9bb5ae1a6b3492c45c891d3d9c28edb4ca6438dc486cdd1ee06cd	11	11367	367	1101	1131	12	4	2023-10-31 17:52:06.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1133	\\xcb76f45942fb22076be5aec0eb721afff7ee8ca9e4e0dfc70d5ce152d466e19d	11	11374	374	1102	1132	16	4	2023-10-31 17:52:07.8	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1134	\\xfa7c3413e41d10a0b27cf6c3b0f6cf83efaae07eeaff2e65fdd455022b877c5e	11	11378	378	1103	1133	4	4	2023-10-31 17:52:08.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1135	\\x815ebd8f92501d85d323eb8f1b6875c057bc66a691607b6704a60c80dffdae0d	11	11402	402	1104	1134	7	4	2023-10-31 17:52:13.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1136	\\x7313cf3e6e96aa7ce9956166202a955e4a1d8fe8dd236d8a2ccda583e9027a50	11	11410	410	1105	1135	7	4	2023-10-31 17:52:15	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1138	\\x97fb076604f5e8184cf49f94f4a41495a7f749146f48400ff0cc9ab8ff4f3c33	11	11412	412	1106	1136	16	4	2023-10-31 17:52:15.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1139	\\x66a456541b92b64f23e11327d11894eac51c472a2831db9be124e3bee7d583e4	11	11417	417	1107	1138	16	4	2023-10-31 17:52:16.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1140	\\x4e29394fc0c5e2b1f47f07fb25f11f8b0b988ea2ea5bf01c22f568daa0be69ec	11	11419	419	1108	1139	39	4	2023-10-31 17:52:16.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1141	\\xaa70200cf8e1adeb044bf9659d56e79d95f502f06bdff1d15187ae3362937d4a	11	11426	426	1109	1140	4	4	2023-10-31 17:52:18.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1142	\\x54c96789036a811f26d9cf606ef9cde51428bc5e7e37e45c2b6453d09aef915b	11	11428	428	1110	1141	4	4	2023-10-31 17:52:18.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1143	\\x4b37d43c5ede38f861a6f8ef8ef07e76e02fb985d24445351630ad91c39e2c47	11	11446	446	1111	1142	4	4	2023-10-31 17:52:22.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1144	\\x4f6ee240a919252f8a933e30cbe5ededb4fc25f7212d3ce79dc62f0d6e03edf8	11	11449	449	1112	1143	3	4	2023-10-31 17:52:22.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1145	\\x108aba61bc3550294528bab2eb8beed45e77881c32b4d1b67fcec4ab7b97858e	11	11452	452	1113	1144	5	4	2023-10-31 17:52:23.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1147	\\x6e5eda015d0578f8fa5e8d65d1906ad7edd5251e30797c12ea68dbc0ff523ee5	11	11453	453	1114	1145	16	4	2023-10-31 17:52:23.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1148	\\x229690f7a1a96e6d87316c5346317676b4575610950c3ad49394db24855150bc	11	11465	465	1115	1147	5	4	2023-10-31 17:52:26	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1149	\\x379d8925b01977edd564324943a754624e018d4f59851fecece94274295d2014	11	11477	477	1116	1148	7	4	2023-10-31 17:52:28.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1150	\\x7c0d5106271f400a1ca370501a0e4a1fd9b4675cbd7949358e7f4cedee7733cb	11	11486	486	1117	1149	8	4	2023-10-31 17:52:30.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1151	\\x6def27711b72f4feb5c1d99a67f10286b0c6e5cf4c1082ef0f38f093634033de	11	11493	493	1118	1150	8	4	2023-10-31 17:52:31.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1152	\\x9f778d1614fa887cff5cfc012681e41b9a9f8719f68f8293e3f53459742e919b	11	11497	497	1119	1151	12	4	2023-10-31 17:52:32.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1153	\\xb916bd72d5be2f0ab134c5fff847c1536de288bd0abe38581d1fe704c8720f9a	11	11499	499	1120	1152	3	4	2023-10-31 17:52:32.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1154	\\x62380c5744b71a1b441ac6204cc30d23f3cddbb045cdb256baab346157286ee9	11	11513	513	1121	1153	4	4	2023-10-31 17:52:35.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1155	\\x621f0424e3d156ca9b9de37f4c81d064445bb942c65fff07902f7901d1b15728	11	11523	523	1122	1154	39	4	2023-10-31 17:52:37.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1156	\\x79cdda63232172fda01554ecda155ac6ca322b07b46e581f8a7d77c8d91deed2	11	11524	524	1123	1155	3	4	2023-10-31 17:52:37.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1157	\\x7c24c37dae3363563381954ecddabde07eaf7f01aee5e39aad5ce5962a5530b8	11	11527	527	1124	1156	8	4	2023-10-31 17:52:38.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1158	\\x26e8971dfa35f161ce6bed75322a863d8513ae74670f680e9519da10946e10b5	11	11533	533	1125	1157	5	4	2023-10-31 17:52:39.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1159	\\xd99e78f35bf8ddef6e8bb3a61f60f094dff4af055c0e1aea78e6f910dcb7a13c	11	11580	580	1126	1158	8	4	2023-10-31 17:52:49	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1160	\\x70e5b1c8dd86e21e18f590c79ebf3dfdc18173ed77ddbdbd1c1d500e76d7ab84	11	11587	587	1127	1159	3	4	2023-10-31 17:52:50.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1161	\\x29ace726054b7d8215577545d2625659ff2a9507d936ace4d36f12b00aa3f1ba	11	11588	588	1128	1160	8	4	2023-10-31 17:52:50.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1162	\\x3cd5e61d4daa93ba0907b3e09cbaee73904b8b53454eea6034e524462a38bcf0	11	11599	599	1129	1161	39	4	2023-10-31 17:52:52.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1163	\\x7ee151ee33a3d9014cdf2741fdd5abd00104450a25838095cede9383e55243ce	11	11605	605	1130	1162	12	4	2023-10-31 17:52:54	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1164	\\x02ffdf54b828d99cdfc29f5b59d2a6f26e190e60ce15adbcc467a3d1946ac5c1	11	11617	617	1131	1163	39	4	2023-10-31 17:52:56.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1165	\\x5cab5cf27dc3719feda4b62b5e3f3a532c1ed5a8a8aa54f75c4a11dea3564c8a	11	11618	618	1132	1164	4	4	2023-10-31 17:52:56.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1166	\\x389d2d5979d812066989f3d4ea3ece16c622deee703095ae846232c6d0da0ee0	11	11622	622	1133	1165	3	4	2023-10-31 17:52:57.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1167	\\x616319ff005199c42c6900a301be1ea2e187a1e8683aedb331e5b3af5e32f46f	11	11625	625	1134	1166	14	4	2023-10-31 17:52:58	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1168	\\x47a66e3c76e0798df8b3a02c22c37ab79cc1766c31f14b85f62fb09ea8edab10	11	11631	631	1135	1167	7	4	2023-10-31 17:52:59.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1169	\\x1f795097a0b7ba237eb596aceda4a968b53f844a25883ffc1d358c7a89efeaa5	11	11639	639	1136	1168	8	4	2023-10-31 17:53:00.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1170	\\xfd07f783a3d576e4d679a819f2521cfb7659703686c2519ae55781a10085b68b	11	11641	641	1137	1169	16	4	2023-10-31 17:53:01.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1171	\\xd807e45a9f317945d2874ef689a2a84929e6222f4dfd98f456d963f17a9d302e	11	11658	658	1138	1170	39	4	2023-10-31 17:53:04.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1172	\\xca19448f378fba7376ee26536a6a97a66b0269c3a6ddf309686dd3962eb23efe	11	11659	659	1139	1171	5	4	2023-10-31 17:53:04.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1173	\\x82781280a60e141b873fe0dde9b78712f109304ceabde1338007629c8c2f78e9	11	11661	661	1140	1172	12	4	2023-10-31 17:53:05.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1174	\\x38e7ff664f1decdc185aee9383097402f7c91beed236b2b727b36266d9388538	11	11668	668	1141	1173	39	4	2023-10-31 17:53:06.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1175	\\xbbefeae73f8b453320d9885535989c63ec129bf09f96183608d013be14679d11	11	11692	692	1142	1174	16	4	2023-10-31 17:53:11.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1176	\\x2de61e7db0731fdeeaedc7d4504ca2f8f9e181c2abc341f1d82a4b8a53ad1a47	11	11697	697	1143	1175	39	4	2023-10-31 17:53:12.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1177	\\xe148ba52def74b10b6fa3d9efd1a469b733b2a43a48da11a75a571a106c017ad	11	11708	708	1144	1176	4	4	2023-10-31 17:53:14.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1178	\\xe4625ccab222110c3b6714b29ff1a9c499decab95bfb563370308dd92d1405fc	11	11715	715	1145	1177	14	4	2023-10-31 17:53:16	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1179	\\xff897e08ab8f754d6e3007601742278f5180bce873d1df41272fba1a16c4514e	11	11752	752	1146	1178	5	4	2023-10-31 17:53:23.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1180	\\xe42a795aaff2626bbea7b7d1dd8f30fcc8b93985723ebaef1721b85c3d5a759c	11	11758	758	1147	1179	3	4	2023-10-31 17:53:24.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1181	\\x924f482e388be74db5cb882f599c8b8c401982d8327bbce66980699730031dbf	11	11770	770	1148	1180	12	4	2023-10-31 17:53:27	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1182	\\xd33123cabe98cf4df04dc146e8e116dfea8f8d5ac790656269e887f8be950a33	11	11778	778	1149	1181	12	4	2023-10-31 17:53:28.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1183	\\x65bff36cdfcd3b40a154ae7940909952071eb63c742134ae399e8825123b5d19	11	11787	787	1150	1182	14	4	2023-10-31 17:53:30.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1184	\\x01aab09328c7088bac9a0f74897c5ce067caf8f344c01e93f328bdb1e6d54716	11	11792	792	1151	1183	8	4	2023-10-31 17:53:31.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1185	\\x2fdaf910fbd25629fb7e3594a517332c99222ee20b522b66bbdd07c5195798df	11	11845	845	1152	1184	39	4	2023-10-31 17:53:42	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1186	\\x8fb613ca711f24d52baac30cbe83b2b37be8c392f73b46e83d031c7cea5937c3	11	11861	861	1153	1185	5	4	2023-10-31 17:53:45.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1187	\\xd67dd321106c524121b2b32121e8256457533cf8025c840bbddab8b0e3774245	11	11877	877	1154	1186	14	4	2023-10-31 17:53:48.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1188	\\x9bd89fcb59c4def0b964ff4ed3f03d600e82596ecb43fa31c9c2be571ebf4bf4	11	11881	881	1155	1187	14	4	2023-10-31 17:53:49.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1189	\\xd457c9a37377ec41568449d13ec5b6227ff9961f56f07482b9b5829d4c84e24b	11	11889	889	1156	1188	8	4	2023-10-31 17:53:50.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1190	\\xd40a27f2e1a1cc27fa86938f6d67c2692d1c8ff7442e5c582650619ff45c28cf	11	11894	894	1157	1189	39	4	2023-10-31 17:53:51.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1191	\\xd672599459f3d0551b681e7ec0151cc4bba5417e340d3cd4a321b63e8b9d9797	11	11898	898	1158	1190	39	4	2023-10-31 17:53:52.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1192	\\x1b116ff9c8428502702a27b3a5b88b5febb828f73a40af30c7e1b2bf36d75511	11	11899	899	1159	1191	4	4	2023-10-31 17:53:52.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1193	\\xd3adb4be46eb921843fbb36536ae74f4b1af70cd7656002925f61965ae127027	11	11905	905	1160	1192	7	4	2023-10-31 17:53:54	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1194	\\x5dc059ab753f03b6de7c92b75ddf158c6b007f9aa6cef34e3a6115cdc158de58	11	11919	919	1161	1193	5	4	2023-10-31 17:53:56.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1195	\\x85bcfe9058a4cae8bec9678598643f7d7c717ab8085393c67e0b44e4762ba94d	11	11923	923	1162	1194	7	4	2023-10-31 17:53:57.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1196	\\x608bccd95d4ac89a3fe006f4e5c429b28fc1db677806a741e2d80457e166f6fd	11	11937	937	1163	1195	12	4	2023-10-31 17:54:00.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1197	\\x4a7685a63cdddf8f0c3a56f4d87d5d567b3b7ec147a092ea66ba1b2b877d749f	11	11956	956	1164	1196	8	4	2023-10-31 17:54:04.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1198	\\xfd148a51241313c1dd56a8ee9df6d0fad528c9eea78f6e47fbf72fcab67435c2	11	11962	962	1165	1197	14	4	2023-10-31 17:54:05.4	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1199	\\x7b4b52b596c8c191ba3d4f3cec160ffbb5337b2fa7936528987986a5cdb3160c	11	11981	981	1166	1198	8	4	2023-10-31 17:54:09.2	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1200	\\xe99b72fc6221d1c004b35ccd38af8145186590da9d15f736e75e626a22b73555	11	11995	995	1167	1199	8	4	2023-10-31 17:54:12	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1201	\\xa90cf20fe4e68c0ac3f47d5805ff3e384eee240cd5704ad5c0dfcd341f025d9c	12	12008	8	1168	1200	12	4	2023-10-31 17:54:14.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1202	\\x8075652c2af4a4f785654f9d089dd4c0b350e80660cd344cad78d1c9bb02faf5	12	12016	16	1169	1201	7	4	2023-10-31 17:54:16.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1203	\\x2b07b6f8865c6fa5d7e7a10bc9f5d35f34a3ab6cb8ea5dc73d7f4e2363049009	12	12017	17	1170	1202	7	4	2023-10-31 17:54:16.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1204	\\x12a27dd40b5987f9027f1f13aa4cb1654defed3f45b91b94aeedc52fd476624d	12	12031	31	1171	1203	4	4	2023-10-31 17:54:19.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1205	\\xe13e8c31323b55ecba5bf632143e38618ce459539ef1003168528920639984b7	12	12066	66	1172	1204	14	4	2023-10-31 17:54:26.2	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1206	\\x2380a9a54d6215ddfebd96e8056ed602df34659061d5c3cba2248df9a7a3b4b3	12	12067	67	1173	1205	5	4	2023-10-31 17:54:26.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1207	\\x881d5af871a5b93bf652484472acdf3333d9628f19f3d9798926290cba72c2b0	12	12095	95	1174	1206	14	4	2023-10-31 17:54:32	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1208	\\x9f079d79290f33828b95a4d5e7edb0eb18f38bec710db990c250a6885abfa0c5	12	12099	99	1175	1207	3	4	2023-10-31 17:54:32.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1209	\\x373a4d51fff828c96d93ede84cc62e13a92401b4e123cb311b978c21e0f61ac1	12	12103	103	1176	1208	14	4	2023-10-31 17:54:33.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1210	\\x759ead7250c36a205d4cc1df39bcdd9d32e4fd8f68464deb932d02f80cfb1ea1	12	12140	140	1177	1209	3	4	2023-10-31 17:54:41	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1211	\\xd1d96de7edeff0076dee83ac7bd5f53dbc3ec68e2ed2d53a47e5512f8489f539	12	12141	141	1178	1210	39	4	2023-10-31 17:54:41.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1212	\\x7b6be05bc49c7ab3d8329b6963711b05e0a949d36b16add870fc9c8de2b1b0c9	12	12151	151	1179	1211	4	4	2023-10-31 17:54:43.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1213	\\xc7c95275d674b7d221a74ac6fceca54b1d99534df5acf8b0fe82360e71f3d7b5	12	12154	154	1180	1212	3	4	2023-10-31 17:54:43.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1214	\\xd8d48e40694484cb2f3b06ae55336eab715e3d1b33fa5e45470c3f1f196b09cd	12	12181	181	1181	1213	4	4	2023-10-31 17:54:49.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1215	\\x9ec22b10398fbba7e223da3400f720396d90252342bf17c96d0bdb984c017601	12	12186	186	1182	1214	16	4	2023-10-31 17:54:50.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1216	\\xbfa7ec01d95c4e6d8309fc41eaad73fdcd172915b841439ea8f1f28441978678	12	12212	212	1183	1215	4	4	2023-10-31 17:54:55.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1217	\\xa07a18157f68c10ea8b2d41a0cbea2e30658e65fd85d9c8aeaa59ad5969cbc9b	12	12218	218	1184	1216	7	4	2023-10-31 17:54:56.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1218	\\x6be7e9a492ee1ef1f4d157c09ebe91cbf6e336ebb1c3a19f0df0566a7117ff87	12	12258	258	1185	1217	12	4	2023-10-31 17:55:04.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1219	\\x2db691d741e487fb26cf59e7a11e7cc7698ea513336f24d06289592ce1592463	12	12279	279	1186	1218	3	4	2023-10-31 17:55:08.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1220	\\x33fc96b59f24b10c9e38ef32d941a91c606941c735013d9c27cba5e3d09d8e8c	12	12298	298	1187	1219	12	4	2023-10-31 17:55:12.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1221	\\x642655f55723479ec4bf7d18c66c855894c471388e4dc892e7d843dbbd1a24df	12	12317	317	1188	1220	12	4	2023-10-31 17:55:16.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1222	\\x1a92c61fc37180cb0d8804542f5baf2e90c6fd4329fa8f1920d1ec349b32910c	12	12322	322	1189	1221	16	4	2023-10-31 17:55:17.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1223	\\xeb216a6005f964d0a83e4ee70d31954348fc5f80706bc9cbb2b3a1034c485f66	12	12346	346	1190	1222	4	4	2023-10-31 17:55:22.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1224	\\xca62ad0d2fb19cb69a28de354c29965bb94e42aa75065704e4a0d962cb943eaf	12	12353	353	1191	1223	16	4	2023-10-31 17:55:23.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1225	\\x967ef3282c4db69693ff29f624492159594a8c7b43cdb59b005f084a60491368	12	12354	354	1192	1224	14	4	2023-10-31 17:55:23.8	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1226	\\x06c31b49b4f4432ad6689b21a5f884591e3807270da04889b4db0e20c229a5eb	12	12371	371	1193	1225	5	4	2023-10-31 17:55:27.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1227	\\xd85f1e7c341514368fc4ec74e7c3eb43560577deaee399e3bc80ae90ea5b0b77	12	12384	384	1194	1226	39	4	2023-10-31 17:55:29.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1228	\\x212a1d0f2263a91c97fbd824f7609607adeeac1f9abe2ee586ea0d632cdd2931	12	12397	397	1195	1227	12	4	2023-10-31 17:55:32.4	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1229	\\x1825271783a28a81873b9788ac851f26cb9feb19110ce20136e9fa605ca71696	12	12404	404	1196	1228	4	4	2023-10-31 17:55:33.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1230	\\x5368e3f348ee3d516fcc77ddb53e310984fcdc7031c96eb5407f83388e789607	12	12408	408	1197	1229	14	4	2023-10-31 17:55:34.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1231	\\x1f3c493227d9bada188156eef67c2d5552fb14421f9ac0c1d4829b7aee0f76a3	12	12414	414	1198	1230	8	4	2023-10-31 17:55:35.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1232	\\x4d323e9b1d90ec6d15ec2c62cb7fbc25d3f95e7973a1a71f3f8ed6f8c59d49ac	12	12432	432	1199	1231	4	4	2023-10-31 17:55:39.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1233	\\x0566c8857b4e07f3237c12c920b79a49b538273f02851e01a75b3ed79f2a9770	12	12458	458	1200	1232	14	4	2023-10-31 17:55:44.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1234	\\xbea826c166f42729993f55f3b471c955354f7e580821752ee7cded25965f6ef8	12	12463	463	1201	1233	4	4	2023-10-31 17:55:45.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1235	\\xfe873ebe4e5851feaa9d39dcc4eac398e529e91e689903ec889d38c9646c92ae	12	12478	478	1202	1234	7	4	2023-10-31 17:55:48.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1236	\\x23373a6d85dd083f72cdbaf11bac913c362482bc0351f1704f90f30c8f4d0e51	12	12488	488	1203	1235	39	4	2023-10-31 17:55:50.6	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1237	\\x732b1152da1bd06d709fa48adf4b9e7851fdade085ec88848d4f3f09d842a061	12	12490	490	1204	1236	12	4	2023-10-31 17:55:51	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1238	\\x082a7c8d510a3da0c8a6a3db9c3b865eaf759ee88995cbb70ce20aa7d549784a	12	12492	492	1205	1237	3	4	2023-10-31 17:55:51.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1239	\\xd0321a05675462ef97461d2ffc0773c92a0dd88f17dd8374c7dd98e414720877	12	12500	500	1206	1238	8	4	2023-10-31 17:55:53	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1240	\\xcfe45fb41744c328191d366dd3e74164f6c6427b35e633be56fe907860396e7c	12	12506	506	1207	1239	12	4	2023-10-31 17:55:54.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1241	\\xaff9f4b16ed33d972e4d741a215fc85b1539a00d522029f9108574888b463dc8	12	12532	532	1208	1240	4	4	2023-10-31 17:55:59.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1242	\\xeb6444d27260abe35ce8b77298e3e0a6ab2c1bff7ab967384377b50a1c315d49	12	12559	559	1209	1241	12	4	2023-10-31 17:56:04.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1243	\\x505e529567475c1cf5153f5cac3c2f331e4bf0c11c8a202752d75ad1878a6844	12	12582	582	1210	1242	8	4	2023-10-31 17:56:09.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1244	\\x67dfea029bfb4260750f44e397ed2a68cd601f86dfeb5d47708c0461f94b9209	12	12600	600	1211	1243	39	4	2023-10-31 17:56:13	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1245	\\x9645e8cb82cf6723bc6e15264c9b0b0a3f762025d3d1f8d4fe007a2e8304f81c	12	12609	609	1212	1244	5	4	2023-10-31 17:56:14.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1246	\\x22345a554e62c42d392e838374448ad2942a83474e0746da73cba835de863749	12	12641	641	1213	1245	12	4	2023-10-31 17:56:21.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1247	\\x3870b4e992167ee98b5ba4e60afebaf5c8ce41a043764619c3feb6e921efb37d	12	12647	647	1214	1246	7	4	2023-10-31 17:56:22.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1248	\\x94cc86f2a9289b1170f7cb83328bfd9ad5fe288421c9f3803935ba485615dd7b	12	12650	650	1215	1247	7	4	2023-10-31 17:56:23	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1249	\\xcf6cccfd30c97dde467f2396b06340f9354fba4d998bddede7e89e531a1ba362	12	12661	661	1216	1248	3	4	2023-10-31 17:56:25.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1250	\\x78cb0ba1892542c709132f5dd4571bcd98ea8ffaf944d5b9af1d11bb1292f628	12	12677	677	1217	1249	4	4	2023-10-31 17:56:28.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1251	\\x9ba6f126a4284acdc56c756ec5864132e7c73e8590ef0c27e8c1439fbc5fed5c	12	12681	681	1218	1250	16	4	2023-10-31 17:56:29.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1252	\\x3711d8f10929e443daa21bce3fd6578685876efd1a70382772b1d571e35e42c4	12	12684	684	1219	1251	5	4	2023-10-31 17:56:29.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1253	\\x25ddfa33c5a7009188153db476f24f963830556f1a420147ed6f8c031b23c4f8	12	12688	688	1220	1252	4	4	2023-10-31 17:56:30.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1254	\\x72611608fe9bfce2e0e47a06e831820850b747bef4ecea934f580050c7bbe21c	12	12690	690	1221	1253	5	4	2023-10-31 17:56:31	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1255	\\x21fe2ecd233e74fbd8e81e8de8149f8bca54cf0a22be0c193bc3c7bcc57b0419	12	12692	692	1222	1254	16	4	2023-10-31 17:56:31.4	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1256	\\xebb067c4da5a76fe27c16613191f02bd4eb4edbfb79f973a4b106e9a3a0a7f0f	12	12703	703	1223	1255	12	4	2023-10-31 17:56:33.6	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1257	\\x1093fbc1d9d2fa159ef5201b1fce60da629a407cb7a881838fa387a063f03246	12	12748	748	1224	1256	3	4	2023-10-31 17:56:42.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1258	\\xead8c18cd4371a7dab9c86593dad23857ae9990ba40e9cf2728853d3725ed47a	12	12750	750	1225	1257	3	4	2023-10-31 17:56:43	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1259	\\xb4600954389ae6ff4ecbda91911494d2582a4c7e526160f7ae184c18b8734fb3	12	12754	754	1226	1258	5	4	2023-10-31 17:56:43.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1260	\\x25e4f65ea8577819d36dd554f82e5ce6e0c7cf862269e4a1e35d50aa0fd945e8	12	12755	755	1227	1259	16	4	2023-10-31 17:56:44	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1261	\\xf52a8f56d1d450a0d7680f5fe7e9d2c4c9f5cbd48830187b1688763379b64fda	12	12758	758	1228	1260	7	4	2023-10-31 17:56:44.6	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1262	\\xa70755d206d9bda897d897c0d66ce44b9a990a35bfe75a575ec38fe48ee536c7	12	12770	770	1229	1261	5	4	2023-10-31 17:56:47	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1263	\\x22017cf70c84a79e5df354db6d6bfea404d61ced91ef6e5b4d4408bf9728a217	12	12771	771	1230	1262	3	4	2023-10-31 17:56:47.2	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1264	\\xb9b7329696fcc59b5af8e8108e372807fe8343a2ad8d8755140f5272ba58e287	12	12773	773	1231	1263	8	4	2023-10-31 17:56:47.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1265	\\xc27baad354a2ed84281e33e9eff39648351e5628c3bb63c6b5b8a225d6e87865	12	12777	777	1232	1264	3	4	2023-10-31 17:56:48.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1266	\\x1c9f2204d38f3bca09b6d182dffb333af92323709ad1b47feb0352c21550f02e	12	12779	779	1233	1265	8	4	2023-10-31 17:56:48.8	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1267	\\xb8c721a64d476a7ec8e12d109ecd1cfb77efe63aa7ba2ac7f8e8f8b15d260c30	12	12781	781	1234	1266	5	4	2023-10-31 17:56:49.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1268	\\x40c044acd6dcaac4a975c1e79323a51139a772a6e27c2d98b410b4ddb8d58fab	12	12782	782	1235	1267	7	4	2023-10-31 17:56:49.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1269	\\xee08e50c09924f0fd757f639a65e48f1917c426652310070369e9dd354d51898	12	12786	786	1236	1268	5	4	2023-10-31 17:56:50.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1270	\\x77c0c567554b236a7da510c70eb91c50c1b46e1ac2f8503bff8fb140fdc17589	12	12790	790	1237	1269	4	4	2023-10-31 17:56:51	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1271	\\xf1e2cac4637fb81292d8a7d418c9f1f8ff320274b318fd94ab1ede92e1c47c7f	12	12801	801	1238	1270	39	4	2023-10-31 17:56:53.2	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1272	\\x66aae0977d825ff76b4eb8adbcc13d4176ead86d9404d528dfa73156134b9b27	12	12813	813	1239	1271	8	4	2023-10-31 17:56:55.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1273	\\xc02f0558052a5bfa023f61a3e016f0834a7702d90f1830b62d253fafe000339c	12	12818	818	1240	1272	16	4	2023-10-31 17:56:56.6	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1274	\\xc4e59195d1465f91748fdf7c60dbeb5a7703ee37d064b3c3430d10e066d2cf27	12	12822	822	1241	1273	3	4	2023-10-31 17:56:57.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1275	\\x8ca3aa80afa2d775d216256051db8d79a48bad27bd4560af75137e9009a55e30	12	12833	833	1242	1274	3	4	2023-10-31 17:56:59.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1276	\\x8e49442d4dc86a50b4828f04a6ec41dd8b97b01c283644bc23d3c84c7a6752f2	12	12839	839	1243	1275	12	4	2023-10-31 17:57:00.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1277	\\x68161fe0997ec27fd45ffa153f811de8209676eb605304b476e27dfb035173e2	12	12868	868	1244	1276	4	4	2023-10-31 17:57:06.6	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1278	\\x8b69eaeaf4dcb8e323b1c56742959c00c4115df566e19f5a3dbe4c003bd880ce	12	12880	880	1245	1277	7	4	2023-10-31 17:57:09	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1279	\\xa75ef4a456049ba6e6077923fcbab3b816e63409c17541a720e6dd7976d5bc57	12	12889	889	1246	1278	39	4	2023-10-31 17:57:10.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1280	\\x43d05952258b39759e632bba43765e9c1b5d9c810760d72ed1d078b17c67e309	12	12894	894	1247	1279	39	4	2023-10-31 17:57:11.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1281	\\x0147364a3d88571a1e5af95a48ee1a199744db5e6a88c2013b1365be3203abd8	12	12915	915	1248	1280	4	4	2023-10-31 17:57:16	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1282	\\xdc4b8f1220c19bab5b552634dc44bc1928e1c78db20babebdefd86be2af96202	12	12925	925	1249	1281	14	4	2023-10-31 17:57:18	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1283	\\xcc1cebb694f21b5a49a02b0fb9df527f0d6da6893992d87e4052de32083c0c9c	12	12926	926	1250	1282	7	4	2023-10-31 17:57:18.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1284	\\xea212a284f9f2fe43f9e281a078fcd085f51963931f527041edb05297ea39a6b	12	12929	929	1251	1283	12	4	2023-10-31 17:57:18.8	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1285	\\x96468074cf6777db77c27a5ba8203cf2c6ac6fd6115398e11fe52303ec2f9043	12	12937	937	1252	1284	39	4	2023-10-31 17:57:20.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1286	\\xebdcc25a03df5ba524c103c2814f9e5648a6d3399755fb6eb8a2e17c04f157b1	12	12956	956	1253	1285	7	4	2023-10-31 17:57:24.2	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1287	\\xb814e39cbcac58cd8ce36e7f142c828638639a2d73c7e3ce72a5448fb20202ff	12	12958	958	1254	1286	14	4	2023-10-31 17:57:24.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1288	\\x6a6472bb5f6679beeb16bc28f0c0184bd6d2a20a181240aae9e1c7c82f3a3b81	12	12964	964	1255	1287	3	4	2023-10-31 17:57:25.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1289	\\xe6ff9ced4ccd0d4c2fc269cbab30cfeb352d4f6cbc178f115aa975fdd8231898	12	12982	982	1256	1288	39	4	2023-10-31 17:57:29.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1290	\\xbbc9887fa98689af038c41d1e7d61f7868c6f095d21b8ff0fadad743fba283e8	12	12987	987	1257	1289	39	4	2023-10-31 17:57:30.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1291	\\x328990843ae28c88cd98bd043c432b1095823314f96977fefed3b36b47fb1dd6	12	12993	993	1258	1290	3	4	2023-10-31 17:57:31.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1292	\\xf7134db041c728e4158a0c1a072b0ec97312654ae4ca5c0bf9cc4f34594dfb9a	13	13007	7	1259	1291	4	4	2023-10-31 17:57:34.4	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1293	\\x0ff6b722f720dc00951c5d96bc7b29af1cab244f577c65d330eeea74112bcf55	13	13012	12	1260	1292	7	573	2023-10-31 17:57:35.4	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1294	\\xd82010aec0d583fa48a235293a223141c79610df1c7e128b76f6292f0385ddc7	13	13020	20	1261	1293	8	4	2023-10-31 17:57:37	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1295	\\xb0331c37a11f9c0d80003885484f8a1ac11a1a38ed2968e7e5fca03d2e73699e	13	13021	21	1262	1294	5	4	2023-10-31 17:57:37.2	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1296	\\x874fc2e8bce244f51851b05268969e63c3bef9fcf3be2f3ca3b3e826de8cfed6	13	13024	24	1263	1295	5	4	2023-10-31 17:57:37.8	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1297	\\xdd1daaf26f43df384a3c758bb7c84ce4888b871c3be53f8442a701ed99d71dfa	13	13037	37	1264	1296	7	4	2023-10-31 17:57:40.4	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1298	\\x0ad155244519657d23c75ee247083adf3257f32298112d68973ddb15137116ce	13	13045	45	1265	1297	5	1704	2023-10-31 17:57:42	1	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1299	\\x75e5264bf44ada7dd8972bdab1ea3e7a1adc7fd5961e23c7a420fdd5f194d930	13	13054	54	1266	1298	4	4	2023-10-31 17:57:43.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1300	\\x56ac051de436b16d522e9d7d3f485436278415f6edba32164569dbeced59dcac	13	13058	58	1267	1299	3	4	2023-10-31 17:57:44.6	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1301	\\x8cfd6947401d73e6b7460dd4d06bc03b78a8ee38072233053b20e8dd0669472d	13	13059	59	1268	1300	7	4	2023-10-31 17:57:44.8	0	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1302	\\xd2b0431f40e17bb91313cfca81faba8e32ac653b16a33eaed93f908ce9c1216e	13	13073	73	1269	1301	8	4	2023-10-31 17:57:47.6	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1303	\\x49d0808bbffb4194de597b3bb899d0d940259878ca3ea5e0d0e2ce6ef5c59708	13	13080	80	1270	1302	5	4	2023-10-31 17:57:49	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1304	\\x8d5e222e5d91d185af3ea60e4e16723b77ba7169651fdf209ecee85abdc4a47e	13	13096	96	1271	1303	4	4	2023-10-31 17:57:52.2	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1305	\\x8e3b9a85333973f96c75af829ec084d1e35ab3a684b92dbfceb40ed4b0a524b0	13	13111	111	1272	1304	4	554	2023-10-31 17:57:55.2	1	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1306	\\xcbda10fc759cc6c9005d546995daaef34f7a3960b5801cff80df69ea2be45423	13	13146	146	1273	1305	16	4	2023-10-31 17:58:02.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1307	\\x2ae8118e33c7fc80a6412435e5bf0e40fa6a77726f4832bc4d9f5f03d75d301c	13	13151	151	1274	1306	16	4	2023-10-31 17:58:03.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1308	\\x5a036c99de5db0a980636abf5cd5109d096d4919d22e52e09e8c77ddb89c82cc	13	13162	162	1275	1307	39	4	2023-10-31 17:58:05.4	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1309	\\x49b3e09b57176ac8715591e79a59966e93aeb67cd40d666aaeaba6f076d633bb	13	13178	178	1276	1308	3	329	2023-10-31 17:58:08.6	1	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1310	\\x5009206d51222fc8d17e28873b151faf2a699ba7fc404dbcb8f11aa29017ebb7	13	13191	191	1277	1309	12	4	2023-10-31 17:58:11.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1311	\\x485b3b9760d6323d8b3be44fbe3e92db7f9b2b466c7c5ded071666f3ccaa81ef	13	13203	203	1278	1310	5	4	2023-10-31 17:58:13.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1312	\\xeb1ee5ffe5343c8db1ef23672d381f4840fdc1ce377ecf3144db2ea6a8a1b5c0	13	13214	214	1279	1311	4	4	2023-10-31 17:58:15.8	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1313	\\x5dde07fa231fb7ec9d9a6c7a659428e9ae491f2762b6a98321b4778b9ed3b962	13	13215	215	1280	1312	4	4	2023-10-31 17:58:16	0	8	0	vrf_vk16tmsxcnwps5wnxxg4u95zmgl9hrqp4ll86mgchgvjslpxazygjqqads68e	\\xda1b2aae08b8671d3f6255a2aed2d28bff0b07d0f99eadf7406fafdb5d1f9a4f	0
1314	\\x679915239071f00d8c64b10ba338745142d5ee8be49acbb48b599bb7a9941636	13	13233	233	1281	1313	5	492	2023-10-31 17:58:19.6	1	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1315	\\xdec69be4734d223d75c40babcb8ec3f214e1d928f8e451a90bbaf2c961d03653	13	13240	240	1282	1314	14	4	2023-10-31 17:58:21	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1316	\\xe310a18604afd11c686c0e625b8417e5c97a8a2c77963a54b46d2e8a43235efa	13	13267	267	1283	1315	8	4	2023-10-31 17:58:26.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1317	\\x93b24cd96d37a42130c1f03f419a4d9eb37158367c2f35502f8926e1c33bec1b	13	13268	268	1284	1316	14	4	2023-10-31 17:58:26.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1318	\\xe5764e363d268ac8771fb1288ac566981db821e855a6d8e08df6e08f026e79d1	13	13276	276	1285	1317	16	550	2023-10-31 17:58:28.2	1	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1319	\\xb35a4acecf01ff10ee60b934d80497ed2ee034c9e668b970db9799fbb82e74bd	13	13304	304	1286	1318	39	4	2023-10-31 17:58:33.8	0	8	0	vrf_vk1kqq9n96vetc6fzg2jeqdht5jsp349p6yay88g3gz9p3gejq67ggqh6sy8f	\\xc48806008833b9f64a0a1e19a99bc2590c940555034982c43fb0a2a6d9bd612c	0
1320	\\xe26a211417e266d0fbfe38330f50d4a7c464e5d1aa903e84e44bc32b378385da	13	13317	317	1287	1319	3	4	2023-10-31 17:58:36.4	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
1321	\\xa7cfbbcbed6d1865ae40c0f9bda6ce23e31f4fb486110340a49ea65fbf47943c	13	13318	318	1288	1320	14	4	2023-10-31 17:58:36.6	0	8	0	vrf_vk1pp4g2sh0kx7y7ffuzyy7s42kldsy0fcrtqyffeps5zd4w004akrs9f8xyl	\\xbc594cb0ce7b2478e598ca06eec1fb710d121c0e1a875ed9860bebd0665a65bd	0
1322	\\x49ff4232610c3404f31676e2ba4fdb5818846d004541985f4a4a1b429982672a	13	13320	320	1289	1321	7	410	2023-10-31 17:58:37	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1323	\\xfc6f8fd07915faa0fdf650182c54737ad8bafe4257caf9bfd1a8615377f174a5	13	13331	331	1290	1322	12	4	2023-10-31 17:58:39.2	0	8	0	vrf_vk12qs9zwd535vahz737j8wkl8ayqnu75lfhtve92hamv73t3352nvqds0605	\\x4d243210caba302fe30f62a86c208d20c65c1bed0dfdfad8333567af8b95d333	0
1324	\\xba238fbeb1eba060ad00edad9d468ff2251bcae7eb55b0c29bcd274b3bedf98a	13	13332	332	1291	1323	8	4	2023-10-31 17:58:39.4	0	8	0	vrf_vk1vvdxjvm9cq6elsu2l49frdm9vatexu3sr4qjcx0yrkk4rsdhxguqfmdxlv	\\x8400fa194581c95c82ca575747a47cf39fcf53440efd836400be60351ab35fe5	0
1325	\\x906bd0d0fd2cdcc206a7940828b0970d77f5796268c9eb7218d45eae3fca3bc4	13	13341	341	1292	1324	16	4	2023-10-31 17:58:41.2	0	8	0	vrf_vk16eyfx85jyytf6nrxaqtzpmdhh03gyyw6ejfjzf8qdhxjwxsdgmpq70lrnd	\\xc9ad0239409b0024ee3c90c614e23fc7cb8779858398d507c555b7beeb3faef9	0
1326	\\x77c75ae63bbdccc0d47739b5d6bc0e53fa9cd4996275780aafa4150a6e6375df	13	13371	371	1293	1325	7	541	2023-10-31 17:58:47.2	1	8	0	vrf_vk1t9tt9rs2yrcpufqa7z8suhkmczeujv3qpljfhllhz7ww4cpq7fuqmzmqg6	\\xbaaf5f7d28898b9670b7f4f40dcd9849f98926764fdd3f358d7c41159a9b420a	0
1327	\\xded083ee84cd9e8f55ba4fb5447033b7dce38ca800983d5dd01681318ff4012f	13	13378	378	1294	1326	5	4	2023-10-31 17:58:48.6	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1328	\\x4e0354689a1e4ec6a626c7fc0071586d84f98c83628c2eb97e7facd0e8fa9e6d	13	13382	382	1295	1327	5	4	2023-10-31 17:58:49.4	0	8	0	vrf_vk1nlup2q465g9xu97hnrljwr54g97clv5n8apztydc62tgfugcmldqh6d7uf	\\xb9eec2b8897ec262deab5b7a177668a0b5850c65799a105ca3e282553a21cee8	0
1329	\\xb10a6484f6105968cf3fca74715c4fde146da3e85e43253e7e62eccb24ee9b6a	13	13384	384	1296	1328	3	4	2023-10-31 17:58:49.8	0	8	0	vrf_vk1m9p55scd8622zqf0en7ktzr40cuean9lz2ks80lpr7l6r0m65dysvtrrq5	\\xac5e45707554517b20f3985d2a5a2d05d529877927646b510d2c374625ab24ae	0
\.


--
-- Data for Name: collateral_tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collateral_tx_in (id, tx_in_id, tx_out_id, tx_out_index) FROM stdin;
1	99	98	1
2	106	105	1
\.


--
-- Data for Name: collateral_tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collateral_tx_out (id, tx_id, index, address, address_raw, address_has_script, payment_cred, stake_address_id, value, data_hash, multi_assets_descr, inline_datum_id, reference_script_id) FROM stdin;
1	99	1	addr_test1vrdjw35y0mee0rlz0pm7s0c7upm0x7hqu8u26ey2q690y9sjrfkfk	\\x60db2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	f	\\xdb2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	\N	3681818081394197	\N	fromList []	\N	\N
2	106	1	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	\\x702618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	3681817479100950	\N	fromList []	\N	\N
\.


--
-- Data for Name: cost_model; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cost_model (id, costs, hash) FROM stdin;
1	{"PlutusV1": {"bData-cpu-arguments": 150000, "iData-cpu-arguments": 150000, "trace-cpu-arguments": 150000, "mkCons-cpu-arguments": 150000, "fstPair-cpu-arguments": 150000, "mapData-cpu-arguments": 150000, "sndPair-cpu-arguments": 150000, "unBData-cpu-arguments": 150000, "unIData-cpu-arguments": 150000, "bData-memory-arguments": 32, "cekLamCost-exBudgetCPU": 29773, "cekVarCost-exBudgetCPU": 29773, "headList-cpu-arguments": 150000, "iData-memory-arguments": 32, "listData-cpu-arguments": 150000, "nullList-cpu-arguments": 150000, "tailList-cpu-arguments": 150000, "trace-memory-arguments": 32, "mkCons-memory-arguments": 32, "mkNilData-cpu-arguments": 150000, "unMapData-cpu-arguments": 150000, "cekApplyCost-exBudgetCPU": 29773, "cekConstCost-exBudgetCPU": 29773, "cekDelayCost-exBudgetCPU": 29773, "cekForceCost-exBudgetCPU": 29773, "chooseData-cpu-arguments": 150000, "chooseList-cpu-arguments": 150000, "chooseUnit-cpu-arguments": 150000, "constrData-cpu-arguments": 150000, "fstPair-memory-arguments": 32, "ifThenElse-cpu-arguments": 1, "mapData-memory-arguments": 32, "mkPairData-cpu-arguments": 150000, "sndPair-memory-arguments": 32, "unBData-memory-arguments": 32, "unIData-memory-arguments": 32, "unListData-cpu-arguments": 150000, "cekLamCost-exBudgetMemory": 100, "cekVarCost-exBudgetMemory": 100, "headList-memory-arguments": 32, "listData-memory-arguments": 32, "nullList-memory-arguments": 32, "sha2_256-memory-arguments": 4, "sha3_256-memory-arguments": 4, "tailList-memory-arguments": 32, "cekBuiltinCost-exBudgetCPU": 29773, "cekStartupCost-exBudgetCPU": 100, "mkNilData-memory-arguments": 32, "unConstrData-cpu-arguments": 150000, "unMapData-memory-arguments": 32, "cekApplyCost-exBudgetMemory": 100, "cekConstCost-exBudgetMemory": 100, "cekDelayCost-exBudgetMemory": 100, "cekForceCost-exBudgetMemory": 100, "chooseData-memory-arguments": 32, "chooseList-memory-arguments": 32, "chooseUnit-memory-arguments": 32, "constrData-memory-arguments": 32, "equalsData-memory-arguments": 1, "ifThenElse-memory-arguments": 1, "mkNilPairData-cpu-arguments": 150000, "mkPairData-memory-arguments": 32, "unListData-memory-arguments": 32, "blake2b_256-memory-arguments": 4, "sha2_256-cpu-arguments-slope": 29175, "sha3_256-cpu-arguments-slope": 82363, "cekBuiltinCost-exBudgetMemory": 100, "cekStartupCost-exBudgetMemory": 100, "equalsString-memory-arguments": 1, "indexByteString-cpu-arguments": 150000, "unConstrData-memory-arguments": 32, "addInteger-cpu-arguments-slope": 0, "decodeUtf8-cpu-arguments-slope": 1000, "encodeUtf8-cpu-arguments-slope": 1000, "equalsData-cpu-arguments-slope": 10000, "equalsInteger-memory-arguments": 1, "mkNilPairData-memory-arguments": 32, "blake2b_256-cpu-arguments-slope": 29175, "appendString-cpu-arguments-slope": 1000, "equalsString-cpu-arguments-slope": 1000, "indexByteString-memory-arguments": 1, "lengthOfByteString-cpu-arguments": 150000, "lessThanInteger-memory-arguments": 1, "sha2_256-cpu-arguments-intercept": 2477736, "sha3_256-cpu-arguments-intercept": 0, "addInteger-memory-arguments-slope": 1, "decodeUtf8-memory-arguments-slope": 8, "encodeUtf8-memory-arguments-slope": 8, "equalsByteString-memory-arguments": 1, "equalsInteger-cpu-arguments-slope": 1326, "modInteger-cpu-arguments-constant": 148000, "modInteger-memory-arguments-slope": 1, "addInteger-cpu-arguments-intercept": 197209, "consByteString-cpu-arguments-slope": 1000, "decodeUtf8-cpu-arguments-intercept": 150000, "encodeUtf8-cpu-arguments-intercept": 150000, "equalsData-cpu-arguments-intercept": 150000, "appendString-memory-arguments-slope": 1, "blake2b_256-cpu-arguments-intercept": 2477736, "equalsString-cpu-arguments-constant": 1000, "lengthOfByteString-memory-arguments": 4, "lessThanByteString-memory-arguments": 1, "lessThanInteger-cpu-arguments-slope": 497, "modInteger-memory-arguments-minimum": 1, "multiplyInteger-cpu-arguments-slope": 11218, "sliceByteString-cpu-arguments-slope": 5000, "subtractInteger-cpu-arguments-slope": 0, "appendByteString-cpu-arguments-slope": 621, "appendString-cpu-arguments-intercept": 150000, "divideInteger-cpu-arguments-constant": 148000, "divideInteger-memory-arguments-slope": 1, "equalsByteString-cpu-arguments-slope": 247, "equalsString-cpu-arguments-intercept": 150000, "addInteger-memory-arguments-intercept": 1, "consByteString-memory-arguments-slope": 1, "decodeUtf8-memory-arguments-intercept": 0, "encodeUtf8-memory-arguments-intercept": 0, "equalsInteger-cpu-arguments-intercept": 136542, "modInteger-memory-arguments-intercept": 0, "consByteString-cpu-arguments-intercept": 150000, "divideInteger-memory-arguments-minimum": 1, "lessThanByteString-cpu-arguments-slope": 248, "lessThanEqualsInteger-memory-arguments": 1, "multiplyInteger-memory-arguments-slope": 1, "quotientInteger-cpu-arguments-constant": 148000, "quotientInteger-memory-arguments-slope": 1, "sliceByteString-memory-arguments-slope": 1, "subtractInteger-memory-arguments-slope": 1, "appendByteString-memory-arguments-slope": 1, "appendString-memory-arguments-intercept": 0, "equalsByteString-cpu-arguments-constant": 150000, "lessThanInteger-cpu-arguments-intercept": 179690, "multiplyInteger-cpu-arguments-intercept": 61516, "remainderInteger-cpu-arguments-constant": 148000, "remainderInteger-memory-arguments-slope": 1, "sliceByteString-cpu-arguments-intercept": 150000, "subtractInteger-cpu-arguments-intercept": 197209, "verifyEd25519Signature-memory-arguments": 1, "appendByteString-cpu-arguments-intercept": 396231, "divideInteger-memory-arguments-intercept": 0, "equalsByteString-cpu-arguments-intercept": 112536, "quotientInteger-memory-arguments-minimum": 1, "consByteString-memory-arguments-intercept": 0, "lessThanEqualsByteString-memory-arguments": 1, "lessThanEqualsInteger-cpu-arguments-slope": 1366, "remainderInteger-memory-arguments-minimum": 1, "lessThanByteString-cpu-arguments-intercept": 103599, "multiplyInteger-memory-arguments-intercept": 0, "quotientInteger-memory-arguments-intercept": 0, "sliceByteString-memory-arguments-intercept": 0, "subtractInteger-memory-arguments-intercept": 1, "verifyEd25519Signature-cpu-arguments-slope": 1, "appendByteString-memory-arguments-intercept": 0, "remainderInteger-memory-arguments-intercept": 0, "lessThanEqualsByteString-cpu-arguments-slope": 248, "lessThanEqualsInteger-cpu-arguments-intercept": 145276, "modInteger-cpu-arguments-model-arguments-slope": 118, "verifyEd25519Signature-cpu-arguments-intercept": 3345831, "lessThanEqualsByteString-cpu-arguments-intercept": 103599, "divideInteger-cpu-arguments-model-arguments-slope": 118, "modInteger-cpu-arguments-model-arguments-intercept": 425507, "quotientInteger-cpu-arguments-model-arguments-slope": 118, "remainderInteger-cpu-arguments-model-arguments-slope": 118, "divideInteger-cpu-arguments-model-arguments-intercept": 425507, "quotientInteger-cpu-arguments-model-arguments-intercept": 425507, "remainderInteger-cpu-arguments-model-arguments-intercept": 425507}, "PlutusV2": {"bData-cpu-arguments": 1000, "iData-cpu-arguments": 1000, "trace-cpu-arguments": 212342, "mkCons-cpu-arguments": 65493, "fstPair-cpu-arguments": 80436, "mapData-cpu-arguments": 64832, "sndPair-cpu-arguments": 85931, "unBData-cpu-arguments": 31220, "unIData-cpu-arguments": 43357, "bData-memory-arguments": 32, "cekLamCost-exBudgetCPU": 23000, "cekVarCost-exBudgetCPU": 23000, "headList-cpu-arguments": 43249, "iData-memory-arguments": 32, "listData-cpu-arguments": 52467, "nullList-cpu-arguments": 60091, "tailList-cpu-arguments": 41182, "trace-memory-arguments": 32, "mkCons-memory-arguments": 32, "mkNilData-cpu-arguments": 22558, "unMapData-cpu-arguments": 38314, "cekApplyCost-exBudgetCPU": 23000, "cekConstCost-exBudgetCPU": 23000, "cekDelayCost-exBudgetCPU": 23000, "cekForceCost-exBudgetCPU": 23000, "chooseData-cpu-arguments": 19537, "chooseList-cpu-arguments": 175354, "chooseUnit-cpu-arguments": 46417, "constrData-cpu-arguments": 89141, "fstPair-memory-arguments": 32, "ifThenElse-cpu-arguments": 80556, "mapData-memory-arguments": 32, "mkPairData-cpu-arguments": 76511, "sndPair-memory-arguments": 32, "unBData-memory-arguments": 32, "unIData-memory-arguments": 32, "unListData-cpu-arguments": 32247, "cekLamCost-exBudgetMemory": 100, "cekVarCost-exBudgetMemory": 100, "headList-memory-arguments": 32, "listData-memory-arguments": 32, "nullList-memory-arguments": 32, "sha2_256-memory-arguments": 4, "sha3_256-memory-arguments": 4, "tailList-memory-arguments": 32, "cekBuiltinCost-exBudgetCPU": 23000, "cekStartupCost-exBudgetCPU": 100, "mkNilData-memory-arguments": 32, "unConstrData-cpu-arguments": 32696, "unMapData-memory-arguments": 32, "cekApplyCost-exBudgetMemory": 100, "cekConstCost-exBudgetMemory": 100, "cekDelayCost-exBudgetMemory": 100, "cekForceCost-exBudgetMemory": 100, "chooseData-memory-arguments": 32, "chooseList-memory-arguments": 32, "chooseUnit-memory-arguments": 4, "constrData-memory-arguments": 32, "equalsData-memory-arguments": 1, "ifThenElse-memory-arguments": 1, "mkNilPairData-cpu-arguments": 16563, "mkPairData-memory-arguments": 32, "unListData-memory-arguments": 32, "blake2b_256-memory-arguments": 4, "sha2_256-cpu-arguments-slope": 30482, "sha3_256-cpu-arguments-slope": 82523, "cekBuiltinCost-exBudgetMemory": 100, "cekStartupCost-exBudgetMemory": 100, "equalsString-memory-arguments": 1, "indexByteString-cpu-arguments": 57667, "unConstrData-memory-arguments": 32, "addInteger-cpu-arguments-slope": 812, "decodeUtf8-cpu-arguments-slope": 14068, "encodeUtf8-cpu-arguments-slope": 28662, "equalsData-cpu-arguments-slope": 12586, "equalsInteger-memory-arguments": 1, "mkNilPairData-memory-arguments": 32, "blake2b_256-cpu-arguments-slope": 10475, "appendString-cpu-arguments-slope": 24177, "equalsString-cpu-arguments-slope": 52998, "indexByteString-memory-arguments": 4, "lengthOfByteString-cpu-arguments": 1000, "lessThanInteger-memory-arguments": 1, "sha2_256-cpu-arguments-intercept": 806990, "sha3_256-cpu-arguments-intercept": 1927926, "addInteger-memory-arguments-slope": 1, "decodeUtf8-memory-arguments-slope": 2, "encodeUtf8-memory-arguments-slope": 2, "equalsByteString-memory-arguments": 1, "equalsInteger-cpu-arguments-slope": 421, "modInteger-cpu-arguments-constant": 196500, "modInteger-memory-arguments-slope": 1, "serialiseData-cpu-arguments-slope": 392670, "addInteger-cpu-arguments-intercept": 205665, "consByteString-cpu-arguments-slope": 511, "decodeUtf8-cpu-arguments-intercept": 497525, "encodeUtf8-cpu-arguments-intercept": 1000, "equalsData-cpu-arguments-intercept": 1060367, "appendString-memory-arguments-slope": 1, "blake2b_256-cpu-arguments-intercept": 117366, "equalsString-cpu-arguments-constant": 187000, "lengthOfByteString-memory-arguments": 10, "lessThanByteString-memory-arguments": 1, "lessThanInteger-cpu-arguments-slope": 511, "modInteger-memory-arguments-minimum": 1, "multiplyInteger-cpu-arguments-slope": 11687, "sliceByteString-cpu-arguments-slope": 0, "subtractInteger-cpu-arguments-slope": 812, "appendByteString-cpu-arguments-slope": 571, "appendString-cpu-arguments-intercept": 1000, "divideInteger-cpu-arguments-constant": 196500, "divideInteger-memory-arguments-slope": 1, "equalsByteString-cpu-arguments-slope": 62, "equalsString-cpu-arguments-intercept": 1000, "serialiseData-memory-arguments-slope": 2, "addInteger-memory-arguments-intercept": 1, "consByteString-memory-arguments-slope": 1, "decodeUtf8-memory-arguments-intercept": 4, "encodeUtf8-memory-arguments-intercept": 4, "equalsInteger-cpu-arguments-intercept": 208512, "modInteger-memory-arguments-intercept": 0, "serialiseData-cpu-arguments-intercept": 1159724, "consByteString-cpu-arguments-intercept": 221973, "divideInteger-memory-arguments-minimum": 1, "lessThanByteString-cpu-arguments-slope": 156, "lessThanEqualsInteger-memory-arguments": 1, "multiplyInteger-memory-arguments-slope": 1, "quotientInteger-cpu-arguments-constant": 196500, "quotientInteger-memory-arguments-slope": 1, "sliceByteString-memory-arguments-slope": 0, "subtractInteger-memory-arguments-slope": 1, "appendByteString-memory-arguments-slope": 1, "appendString-memory-arguments-intercept": 4, "equalsByteString-cpu-arguments-constant": 245000, "lessThanInteger-cpu-arguments-intercept": 208896, "multiplyInteger-cpu-arguments-intercept": 69522, "remainderInteger-cpu-arguments-constant": 196500, "remainderInteger-memory-arguments-slope": 1, "sliceByteString-cpu-arguments-intercept": 265318, "subtractInteger-cpu-arguments-intercept": 205665, "verifyEd25519Signature-memory-arguments": 10, "appendByteString-cpu-arguments-intercept": 1000, "divideInteger-memory-arguments-intercept": 0, "equalsByteString-cpu-arguments-intercept": 216773, "quotientInteger-memory-arguments-minimum": 1, "serialiseData-memory-arguments-intercept": 0, "consByteString-memory-arguments-intercept": 0, "lessThanEqualsByteString-memory-arguments": 1, "lessThanEqualsInteger-cpu-arguments-slope": 473, "remainderInteger-memory-arguments-minimum": 1, "lessThanByteString-cpu-arguments-intercept": 197145, "multiplyInteger-memory-arguments-intercept": 0, "quotientInteger-memory-arguments-intercept": 0, "sliceByteString-memory-arguments-intercept": 4, "subtractInteger-memory-arguments-intercept": 1, "verifyEd25519Signature-cpu-arguments-slope": 1021, "appendByteString-memory-arguments-intercept": 0, "remainderInteger-memory-arguments-intercept": 0, "verifyEcdsaSecp256k1Signature-cpu-arguments": 35892428, "lessThanEqualsByteString-cpu-arguments-slope": 156, "lessThanEqualsInteger-cpu-arguments-intercept": 204924, "modInteger-cpu-arguments-model-arguments-slope": 220, "verifyEcdsaSecp256k1Signature-memory-arguments": 10, "verifyEd25519Signature-cpu-arguments-intercept": 9462713, "lessThanEqualsByteString-cpu-arguments-intercept": 197145, "verifySchnorrSecp256k1Signature-memory-arguments": 10, "divideInteger-cpu-arguments-model-arguments-slope": 220, "modInteger-cpu-arguments-model-arguments-intercept": 453240, "quotientInteger-cpu-arguments-model-arguments-slope": 220, "verifySchnorrSecp256k1Signature-cpu-arguments-slope": 32947, "remainderInteger-cpu-arguments-model-arguments-slope": 220, "divideInteger-cpu-arguments-model-arguments-intercept": 453240, "quotientInteger-cpu-arguments-model-arguments-intercept": 453240, "verifySchnorrSecp256k1Signature-cpu-arguments-intercept": 38887044, "remainderInteger-cpu-arguments-model-arguments-intercept": 453240}}	\\xecd97ab4baa202a20614368334eb3f30199615cec447ecf386e89ed8191e139a
\.


--
-- Data for Name: datum; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.datum (id, hash, tx_id, value, bytes) FROM stdin;
1	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	99	{"int": 12}	\\x0c
2	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	100	{"int": 42}	\\x182a
3	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	105	{"fields": [], "constructor": 0}	\\xd87980
4	\\x81cb2989cbf6c49840511d8d3451ee44f58dde2c074fc749d05deb51eeb33741	110	{"fields": [{"map": [{"k": {"bytes": "636f7265"}, "v": {"map": [{"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "707265666978"}, "v": {"bytes": "24"}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 0}}, {"k": {"bytes": "7465726d736f66757365"}, "v": {"bytes": "68747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f"}}, {"k": {"bytes": "68616e646c65456e636f64696e67"}, "v": {"bytes": "7574662d38"}}]}}, {"k": {"bytes": "6e616d65"}, "v": {"bytes": "283130302968616e646c653638"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f736f6d652d68617368"}}, {"k": {"bytes": "77656273697465"}, "v": {"bytes": "68747470733a2f2f63617264616e6f2e6f72672f"}}, {"k": {"bytes": "6465736372697074696f6e"}, "v": {"bytes": "5468652048616e646c65205374616e64617264"}}, {"k": {"bytes": "6175676d656e746174696f6e73"}, "v": {"list": []}}]}, {"int": 1}, {"map": []}], "constructor": 0}	\\xd8799fa644636f7265a5426f67004670726566697841244776657273696f6e004a7465726d736f66757365583668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f4e68616e646c65456e636f64696e67457574662d38446e616d654d283130302968616e646c65363845696d61676550697066733a2f2f736f6d652d6861736847776562736974655468747470733a2f2f63617264616e6f2e6f72672f4b6465736372697074696f6e535468652048616e646c65205374616e646172644d6175676d656e746174696f6e738001a0ff
5	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	111	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "24706861726d65727332"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "6261736963"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 9}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c6574746572732c6e756d62657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "62675f696d616765"}, "v": {"bytes": "697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f"}}, {"k": {"bytes": "7066705f696d616765"}, "v": {"bytes": "697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b524244"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": "697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b"}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879"}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "01e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c980"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "312e31352e30"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "7066705f6173736574"}, "v": {"bytes": "e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e044503036383136"}}, {"k": {"bytes": "62675f6173736574"}, "v": {"bytes": "9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65"}}]}], "constructor": 0}	\\xd8799faa446e616d654a24706861726d6572733245696d6167655838697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e677468094a636861726163746572734f6c6574746572732c6e756d62657273516e756d657269635f6d6f64696669657273404776657273696f6e0101b34862675f696d6167655835697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f497066705f696d6167655835697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b52424446706f7274616c404864657369676e65725838697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b47736f6369616c73404676656e646f72404764656661756c74004e7374616e646172645f696d6167655838697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879536c6173745f7570646174655f61646472657373583901e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d4c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f686173685820bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de537374616e646172645f696d6167655f686173685820b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c9804b7376675f76657273696f6e46312e31352e304c6167726565645f7465726d7340546d6967726174655f7369675f726571756972656400446e7366770045747269616c00497066705f61737365745823e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e0445030363831364862675f6173736574582c9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65ff
\.


--
-- Data for Name: delegation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delegation (id, addr_id, cert_index, pool_hash_id, active_epoch_no, tx_id, slot_no, redeemer_id) FROM stdin;
1	4	1	2	2	34	0	\N
2	1	3	1	2	34	0	\N
3	5	5	6	2	34	0	\N
4	6	7	8	2	34	0	\N
5	7	9	3	2	34	0	\N
6	8	11	4	2	34	0	\N
7	2	13	5	2	34	0	\N
8	10	15	11	2	34	0	\N
9	3	17	10	2	34	0	\N
10	9	19	9	2	34	0	\N
11	11	21	7	2	34	0	\N
12	21	0	10	2	37	43	\N
13	3	0	10	2	38	60	\N
14	12	0	1	2	42	120	\N
15	1	0	1	2	43	160	\N
16	14	0	3	2	47	222	\N
17	7	0	3	2	48	233	\N
18	19	0	8	2	52	276	\N
19	6	0	8	2	53	297	\N
20	15	0	4	2	57	374	\N
21	8	0	4	2	58	407	\N
22	17	0	6	2	62	489	\N
23	5	0	6	2	63	499	\N
24	22	0	11	2	67	603	\N
25	10	0	11	2	68	622	\N
26	20	0	9	2	72	718	\N
27	9	0	9	2	73	741	\N
28	9	0	9	2	75	798	\N
29	18	0	7	2	79	840	\N
30	11	0	7	2	80	869	\N
31	11	0	7	2	82	889	\N
32	13	0	2	2	86	960	\N
33	4	0	2	2	87	979	\N
34	4	0	2	3	89	1024	\N
35	16	0	5	3	93	1070	\N
36	2	0	5	3	94	1089	\N
37	2	0	5	3	96	1122	\N
38	51	1	11	6	132	4943	\N
39	52	3	4	6	132	4943	\N
40	53	5	8	6	132	4943	\N
41	54	7	10	6	132	4943	\N
42	55	9	3	6	132	4943	\N
43	51	0	11	7	134	5046	\N
44	52	1	11	7	134	5046	\N
45	53	2	11	7	134	5046	\N
46	54	3	11	7	134	5046	\N
47	55	4	11	7	134	5046	\N
49	46	1	4	7	150	5467	\N
50	46	1	11	7	153	5544	\N
51	65	1	4	11	255	9063	\N
52	48	0	12	15	360	13233	\N
53	45	0	13	15	363	13371	\N
\.


--
-- Data for Name: delisted_pool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delisted_pool (id, hash_raw) FROM stdin;
\.


--
-- Data for Name: epoch; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch (id, out_sum, fees, tx_count, blk_count, no, start_time, end_time) FROM stdin;
1	195136285437829459	9515549	53	98	0	2023-10-31 17:14:13	2023-10-31 17:17:28.8
2	73646332579444303	4360982	23	96	1	2023-10-31 17:17:35.4	2023-10-31 17:20:51.2
10	5013486416024	416450	2	102	9	2023-10-31 17:44:14.8	2023-10-31 17:47:30.2
4	0	0	0	98	3	2023-10-31 17:24:13.4	2023-10-31 17:27:32
14	16285080758155	1475192	8	37	13	2023-10-31 17:57:34.4	2023-10-31 17:58:49.4
8	114975252283984	16969508	100	101	7	2023-10-31 17:37:37.6	2023-10-31 17:40:52.6
6	48090111783755	8948866	19	100	5	2023-10-31 17:30:55.2	2023-10-31 17:34:10.4
12	18414328098021	16933560	100	99	11	2023-10-31 17:50:55.6	2023-10-31 17:54:09.2
3	0	0	0	84	2	2023-10-31 17:20:53.8	2023-10-31 17:24:12.6
7	0	0	0	94	6	2023-10-31 17:34:15.6	2023-10-31 17:37:25.4
9	0	0	0	85	8	2023-10-31 17:40:53.8	2023-10-31 17:44:11
5	70001269730848	4285490	22	98	4	2023-10-31 17:27:33.8	2023-10-31 17:30:51.4
13	0	0	0	90	12	2023-10-31 17:54:14.6	2023-10-31 17:57:30.4
11	0	0	0	103	10	2023-10-31 17:47:36.2	2023-10-31 17:50:52.4
\.


--
-- Data for Name: epoch_param; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_param (id, epoch_no, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, nonce, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, block_id, extra_entropy, coins_per_utxo_size) FROM stdin;
1	1	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x009d6ce1ef7784dfae7f6b74f13f0f1ca0fe215ab740fcb410e5100203c6b634	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	101	\N	4310
2	2	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x99a7596dd524ec25ac9145bef2dd3be68490c25be183752b68a6630b5ed7ae2f	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	197	\N	4310
3	3	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xfc9ce86c6b38a6b2709a1adec69be7f21a88adfbfd691e0d7f5bf1dde0e148d3	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	282	\N	4310
4	4	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xc2ee525f98b09291eea7d75d6841c4caaa5eeadace1304a116a0681c04dba816	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	383	\N	4310
5	5	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x8c72a798ccac76291727e404805afb4e3de4ea2e1e7cd9cb9da9357deeecdcbd	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	486	\N	4310
6	6	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x92925a5060afc1974997a01306cee5dbff151bc26c5ec5d4565bb705783be46e	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	592	\N	4310
8	7	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x6cae6ad18e0ff0b9834886b5e4a2ff751cdf41518ea3d8c20052052973d74bbc	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	691	\N	4310
9	8	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xcfbb2488b6786b6e45f30ee17b9970eccf2d2448bf9701f6ba45a94892f9f0ac	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	795	\N	4310
10	9	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xf98a2423394984adf5ab615b29ffc392e0e0f1ffd3502fdec793d4b9be05d42e	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	886	\N	4310
11	10	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x25f50a143e146ca9632ad00ee1b6ffba1e25f338873dc84acb561e0c60c2cac1	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	992	\N	4310
12	11	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x0a7f210e53116242dd6bec76b313cb7fa40ce2cdc5721b62d4254a4737d86a68	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1099	\N	4310
13	12	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xa9869247302c601dea2ce3cb845887919c57a36ba28a7141c0958df4a88cfede	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1201	\N	4310
14	13	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x16fb2c07afafa73712d67beb57efe599fcdf07610eb3fdfbd6c2b36777e59784	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1292	\N	4310
\.


--
-- Data for Name: epoch_stake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_stake (id, addr_id, pool_id, amount, epoch_no) FROM stdin;
1	4	2	3681818181818181	1
2	1	1	3681818181818181	1
3	5	6	3681818181818181	1
4	6	8	3681818181818181	1
5	7	3	3681818181818181	1
6	8	4	3681818181818181	1
7	2	5	3681818181818190	1
8	10	11	3681818181818181	1
9	3	10	3681818181818181	1
10	9	9	3681818181818181	1
11	11	7	3681818181818181	1
12	4	2	3681818181637632	2
13	14	3	200000000	2
14	12	1	600000000	2
15	20	9	300000000	2
16	1	1	3681818181446391	2
17	5	6	3681818181443619	2
18	6	8	3681818181443619	2
19	17	6	500000000	2
20	21	10	500000000	2
21	7	3	3681818181443619	2
22	8	4	3681818181443619	2
23	19	8	500000000	2
24	2	5	3681818181818190	2
25	10	11	3681818181443619	2
26	15	4	500000000	2
27	3	10	3681818181443619	2
28	13	2	500000000	2
29	22	11	500000000	2
30	9	9	3681818181265842	2
31	11	7	3681818181265842	2
32	18	7	300000000	2
33	4	2	3681818181263026	3
34	14	3	200000000	3
35	12	1	600000000	3
36	20	9	300000000	3
37	1	1	3681818181446391	3
38	5	6	3681818181443619	3
39	6	8	3681818181443619	3
40	17	6	500000000	3
41	21	10	500000000	3
42	7	3	3681818181443619	3
43	8	4	3681818181443619	3
44	19	8	500000000	3
45	2	5	3681818181263035	3
46	16	5	500000000	3
47	10	11	3681818181443619	3
48	15	4	500000000	3
49	3	10	3681818181443619	3
50	13	2	500000000	3
51	22	11	500000000	3
52	9	9	3681818181265842	3
53	11	7	3681818181265842	3
54	18	7	300000000	3
55	4	2	3689758586270804	4
56	14	3	200000000	4
57	12	1	600000000	4
58	20	9	300000000	4
59	1	1	3690640853677255	4
60	5	6	3687111784782137	4
61	6	8	3685347250335964	4
62	17	6	500000000	4
63	21	10	500000000	4
64	7	3	3691523120897569	4
65	8	4	3687111784782137	4
66	19	8	500000000	4
67	2	5	3687111784601553	4
68	16	5	500000000	4
69	10	11	3686229517559051	4
70	15	4	500000000	4
71	3	10	3693287655343742	4
72	13	2	500000000	4
73	22	11	500000000	4
74	9	9	3693287655165965	4
75	11	7	3693287655165965	4
76	18	7	300000000	4
77	4	2	3695816471985243	5
78	14	3	200329070	5
79	12	1	601269271	5
80	20	9	300634635	5
81	1	1	3698429563458848	5
82	5	6	3693169670496895	5
83	6	8	3692270548295688	5
84	17	6	500822675	5
85	21	10	500940200	5
86	7	3	3697581007599538	5
87	8	4	3695765907231791	5
88	19	8	500940200	5
89	2	5	3691438847001191	5
90	16	5	500000000	5
91	10	11	3695749052253671	5
92	15	4	501175251	5
93	3	10	3700210953303466	5
94	13	2	500822675	5
95	22	11	501292776	5
96	9	9	3701076366217211	5
97	11	7	3696749304522074	5
98	18	7	300282060	5
99	4	2	3704324210059429	6
100	14	3	200329070	6
101	54	10	0	6
102	12	1	1149478594586	6
103	20	9	300634635	6
104	1	1	3704937651231786	6
105	5	6	3698231434650834	6
106	6	8	3697332337949623	6
107	17	6	894154129134	6
108	53	8	0	6
109	21	10	894145746661	6
110	7	3	3697581007599538	6
111	51	11	0	6
112	8	4	3705166626303351	6
113	19	8	894128746663	6
114	2	5	3698245037460540	6
115	16	5	500924297	6
116	10	11	3700087667171338	6
117	15	4	1659843101574	6
118	52	4	0	6
119	3	10	3705272725957403	6
120	13	2	501978046	6
121	22	11	766529912593	6
122	9	9	3701076366217211	6
123	11	7	3696749304522074	6
124	55	3	999414590	6
125	18	7	300282060	6
126	14	3	200329070	7
127	54	11	0	7
128	12	1	2279023345192	7
129	1	1	3711336187883680	7
130	5	6	3701077758245053	7
131	6	8	3705164096513727	7
132	17	6	1396846982211	7
133	53	11	0	7
134	21	10	1646746483036	7
135	7	3	3697581007599538	7
136	51	11	0	7
137	8	4	3711571287890287	7
138	19	8	2276575037450	7
139	2	5	3705361364946368	7
140	16	5	1256714557122	7
141	10	11	3706493861737678	7
142	15	4	2790468521056	7
143	52	11	0	7
144	3	10	3709535249616439	7
145	22	11	1897425858342	7
146	11	7	3696749304522074	7
147	55	11	999212833	7
148	18	7	300282060	7
149	46	11	4998922334279	7
174	14	3	200329070	8
175	54	11	0	8
176	12	1	3134216709324	8
177	1	1	3716180068363832	8
178	5	6	3708007577494110	8
179	6	8	3712095628857619	8
180	17	6	2620157367030	8
181	53	11	0	8
182	21	10	2745656811868	8
183	7	3	3697581007599538	8
184	51	11	0	8
185	8	4	3715726130921284	8
186	19	8	3500157733924	8
187	2	5	3710907760350282	8
188	16	5	2235881100461	8
189	10	11	3713418852705948	8
190	15	4	3524066777620	8
191	52	11	0	8
192	3	10	3715760192528205	8
193	22	11	3119874193105	8
194	11	7	3696749304522074	8
195	55	11	999212833	8
196	18	7	300282060	8
197	46	11	4998922334279	8
198	14	3	200329070	9
199	54	11	0	9
200	12	1	4226788663473	9
201	1	1	3722356324639579	9
202	5	6	3716946377457746	9
203	6	8	3714846487579295	9
204	17	6	4200535257955	9
205	53	11	0	9
206	21	10	3231228837260	9
207	7	3	3697581007599538	9
208	51	11	0	9
209	8	4	3720528192823324	9
210	19	8	3986756028688	9
211	2	5	3718474944575695	9
212	16	5	3571657757850	9
213	10	11	3719604480033068	9
214	15	4	4374410326219	9
215	52	11	0	9
216	3	10	3718505141317837	9
217	22	11	4213353071510	9
218	11	7	3696749304522074	9
219	55	11	999212833	9
220	18	7	300282060	9
221	46	11	4998905364771	9
222	14	3	200329070	10
223	54	11	0	10
224	12	1	5281737315291	10
225	1	1	3728307792845857	10
226	5	6	3722917158054103	10
227	6	8	3721891830239936	10
228	17	6	5257253562928	10
229	53	11	0	10
230	21	10	4285856096599	10
231	7	3	3697581007599538	10
232	51	11	0	10
233	8	4	3724314087834909	10
234	19	8	5235514605182	10
235	2	5	3727692745260751	10
236	16	5	5202396490177	10
237	10	11	3725008468329827	10
238	15	4	5046248089773	10
239	52	11	0	10
240	3	10	3724461524633507	10
241	22	11	5171929091854	10
242	11	7	3696749304522074	10
243	55	11	1000669663	10
244	18	7	300282060	10
245	46	11	5006193685971	10
246	14	3	200329070	11
247	54	11	0	11
248	12	1	5956243562861	11
249	1	1	3732106426529578	11
250	5	6	3726725197001485	11
251	6	8	3727866698412885	11
252	17	6	5932826132077	11
253	53	11	0	11
254	21	10	5248937218518	11
255	7	3	3697581007599538	11
256	51	11	0	11
257	8	4	3731368358492133	11
258	19	8	6296901035517	11
259	2	5	3733673576334576	11
260	16	5	6262466733903	11
261	10	11	3731508032911705	11
262	15	4	6299380449519	11
263	52	11	0	11
264	3	10	3729890032698849	11
265	22	11	6327269766774	11
266	11	7	3696749304522074	11
267	55	11	1002418576	11
268	18	7	300282060	11
269	65	4	2503096755637	11
270	46	11	2511846083981	11
271	14	3	200329070	12
272	54	11	0	12
273	12	1	7063729496031	12
274	1	1	3738332835642237	12
275	5	6	3733480383807583	12
276	6	8	3734106489149340	12
277	17	6	7134299171198	12
278	53	11	0	12
279	21	10	6263959898297	12
280	7	3	3697581007599538	12
281	51	11	0	12
282	8	4	3736040001713544	12
283	19	8	7406288829586	12
284	2	5	3738869428041982	12
285	16	5	7185643156385	12
286	10	11	3738240273890828	12
287	15	4	7130640057583	12
288	52	11	0	12
289	3	10	3735606502031072	12
290	22	11	7526270902768	12
291	11	7	3696749304522074	12
292	55	11	1004227085	12
293	18	7	300282060	12
294	65	4	2503096755637	12
295	46	11	2520893775940	12
296	14	3	200329070	13
297	54	11	0	13
298	12	1	8144036897577	13
299	1	1	3744395113089289	13
300	5	6	3739551486050663	13
301	6	8	3737648863707302	13
302	17	6	8216156276242	13
303	53	11	0	13
304	21	10	6984135271895	13
305	7	3	3697581007599538	13
306	51	11	0	13
307	8	4	3742615349821644	13
308	19	8	8037646094008	13
309	2	5	3743922316756602	13
310	16	5	8086015694394	13
311	10	11	3745300681699492	13
312	15	4	8301867074303	13
313	52	11	0	13
314	3	10	3739654233461213	13
315	22	11	8785822883561	13
316	11	7	3696749304522074	13
317	55	11	1006123761	13
318	18	7	300282060	13
319	65	4	2503039389032	13
320	46	11	2530422984458	13
\.


--
-- Data for Name: epoch_sync_time; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_sync_time (id, no, seconds, state) FROM stdin;
1	0	1	lagging
2	1	1	lagging
3	2	1	following
4	3	187	following
5	4	202	following
6	5	201	following
7	6	202	following
8	7	197	following
9	8	201	following
10	9	202	following
11	10	200	following
12	11	199	following
13	12	200	following
\.


--
-- Data for Name: extra_key_witness; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.extra_key_witness (id, hash, tx_id) FROM stdin;
\.


--
-- Data for Name: ma_tx_mint; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ma_tx_mint (id, quantity, tx_id, ident) FROM stdin;
1	13500000000000000	107	1
2	13500000000000000	107	2
3	13500000000000000	107	3
4	13500000000000000	107	4
5	2	109	5
6	1	109	6
7	1	109	7
8	1	110	8
9	1	111	9
10	1	111	10
11	1	111	11
12	-1	114	9
13	-1	114	10
14	-1	115	11
15	1	116	11
16	1	117	11
17	-2	118	11
18	2	119	11
19	-2	120	11
20	2	121	11
21	-1	122	11
22	-1	123	11
26	1	125	12
27	1	125	13
28	1	125	14
29	-1	126	13
30	1	127	15
31	1	128	16
32	1	129	17
33	-1	130	15
34	-1	130	16
35	-1	130	17
36	-1	130	12
37	-1	130	14
38	10	135	18
39	-10	136	18
40	1	137	19
41	-1	138	19
42	1	357	9
43	1	357	10
44	1	357	11
\.


--
-- Data for Name: ma_tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ma_tx_out (id, quantity, tx_out_id, ident) FROM stdin;
1	13500000000000000	124	1
2	13500000000000000	124	2
3	13500000000000000	124	3
4	13500000000000000	124	4
5	2	132	5
6	1	132	6
7	1	132	7
8	1	134	8
9	1	136	9
10	1	136	10
11	1	136	11
12	1	138	11
13	1	139	9
14	1	139	10
15	1	141	9
16	1	141	10
17	1	144	11
18	1	146	11
19	1	147	11
20	2	149	11
21	2	152	11
22	1	154	11
26	1	158	12
27	1	158	13
28	1	158	14
29	1	161	12
30	1	161	14
31	1	162	15
32	1	164	16
33	1	165	12
34	1	165	14
35	1	166	17
36	1	167	15
37	1	167	16
38	10	216	18
39	1	219	19
40	1	784	9
41	1	784	10
42	1	784	11
43	13500000000000000	795	1
44	13500000000000000	795	2
45	13500000000000000	795	3
46	13500000000000000	795	4
47	13500000000000000	797	1
48	13500000000000000	797	2
49	13500000000000000	797	3
50	13500000000000000	797	4
\.


--
-- Data for Name: meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meta (id, start_time, network_name, version) FROM stdin;
1	2023-10-31 17:14:13	testnet	Version {versionBranch = [13,1,0,0], versionTags = []}
\.


--
-- Data for Name: multi_asset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.multi_asset (id, policy, name, fingerprint) FROM stdin;
1	\\xb5882504da08775e7dec7f38b74f8f5385642b3c5a370aa5c7c4d45e	\\x	asset1qyvq9xdl3595a7zs9sgfzefz9ml6v9qmvsr9pj
2	\\xb5882504da08775e7dec7f38b74f8f5385642b3c5a370aa5c7c4d45e	\\x74425443	asset10v52faqrpqk90w9fvefdhutjd2rr338mktpzuu
3	\\xb5882504da08775e7dec7f38b74f8f5385642b3c5a370aa5c7c4d45e	\\x74455448	asset1pf4kletlayll2kqra7mc5rvt2kq0j3sqamgeg7
4	\\xb5882504da08775e7dec7f38b74f8f5385642b3c5a370aa5c7c4d45e	\\x744d494e	asset100hh2raenrsrjpm8wvxzh22x3h7nxyazf6syg3
5	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x446f75626c6548616e646c65	asset1ss4nvcah07l2492qrfydamvukk4xdqme8k22vv
6	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x48656c6c6f48616e646c65	asset13xe953tueyajgxrksqww9kj42erzvqygyr3phl
7	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x5465737448616e646c65	asset1ne8rapyhga8jp95pemrefrgts9ht035zlmy6zj
8	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x283232322968616e646c653638	asset1ju4qkyl4p9xszrgfxfmu909q90luzqu0nyh4u8
9	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x000643b068616e646c6532	asset1vjzkdxns6ze7ph4880h3m3zghvesral9ryp2zq
10	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x000de14068616e646c6532	asset1050jtqadfpvyfta8l86yrxgj693xws6l0qa87c
11	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x68616e646c6531	asset1q0g92m9xjj3nevsw26hfl7uf74av7yce5l56jv
12	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d303031	asset1p7xl6rzm50j2p6q2z7kd5wz3ytyjtxts8g8drz
13	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d303032	asset1ftcuk4459tu0kfkf2s6m034q8uudr20w7wcxej
14	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d66696c6573	asset1xac6dlxa7226c65wp8u5d4mrz5hmpaeljvcr29
15	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d76312d686578	asset1v2z720699zh5x5mzk23gv829akydgqz2zy9f6l
16	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d76312d75746638	asset16unjfedceaaven5ypjmxf5m2qd079td0g8hldp
17	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d7632	asset1yc673t4h5w5gfayuedepzfrzmtuj3s9hay9kes
18	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	\\x3030303030	asset1ul4zmmx2h8rqz9wswvc230w909pq2q0hne02q0
19	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x	asset1qrmynj6uhyk2hn9pc3yh0p80rg598n4yy77ays
\.


--
-- Data for Name: param_proposal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.param_proposal (id, epoch_no, key, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, entropy, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, registered_tx_id, coins_per_utxo_size) FROM stdin;
\.


--
-- Data for Name: pool_hash; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_hash (id, hash_raw, view) FROM stdin;
1	\\x09ab91571c5bb3cd9e5096a27401d05d00fbac0b6705660b3816326a	pool1px4ez4cutweum8jsj638gqwst5q0htqtvuzkvzeczcex5l9hrua
2	\\x42e8dcb750104852ff300804500b848985c1b798ce7c5b14d4cd478c	pool1gt5ded6szpy99lespqz9qzuy3xzurducee79k9x5e4rcc094wzs
3	\\x6854ad6d9787295c6a4bed34a7eb847420b1095345bb343ca7fb222b	pool1dp226mvhsu54c6jta56206uywsstzz2ngkang098lv3zkf0x6dn
4	\\x8a035ddd247d1d47816e812d0907b3111dc80b848b5bcb384cfd58f2	pool13gp4mhfy05w50qtwsyksjpanzywuszuy3ddukwzvl4v0yq7qd94
5	\\x8ffdd4e4e37dcb301a2d73ef8a2565435427c33b544bfa053e33bcaa	pool13l7afe8r0h9nqx3dw0hc5ft9gd2z0sem239l5pf7xw725x5r9uf
6	\\xa96125afd1de45a40ad3cebf3ccd07c27bbd325f30c01712964ff7d5	pool149sjtt73mez6gzkne6lneng8cfam6vjlxrqpwy5kflma24we70n
7	\\xa9a53a8c2789af0b998b57d31d103774d16bb48473149aa3c81428b3	pool14xjn4rp83xhshxvt2lf36yphwngkhdyywv2f4g7gzs5txwkwfw6
8	\\xc4e628589a0e0733a05dad56f9dcbaf40b2e368002c294cd0a2ffcb3	pool1cnnzsky6pcrn8gza44t0nh967s9jud5qqtpffng29l7txn4s30u
9	\\xdb9f334d663079223816dd7886932ad58a095f6187421662b19bb291	pool1mw0nxntxxpujywqkm4ugdye26k9qjhmpsappvc43nwefzt0mrr8
10	\\xe31012824263d20c391ca123162e2299b52b16f331d1ccfe3871723d	pool1uvgp9qjzv0fqcwgu5y33vt3znx6jk9hnx8guel3cw9er6mnyuyz
11	\\xf2fd1765572b452dbeff87faaebf86c021c10c8d4b18cd3d0c635671	pool17t73we2h9dzjm0hlsla2a0uxcqsuzrydfvvv60gvvdt8z0n2u6q
12	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
13	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_metadata_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata_ref (id, pool_id, url, hash, registered_tx_id) FROM stdin;
1	10	http://file-server/SP1.json	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	39
2	3	http://file-server/SP3.json	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	49
3	8	http://file-server/SP4.json	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	54
4	4	http://file-server/SP5.json	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	59
5	6	http://file-server/SP6.json	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	64
6	11	http://file-server/SP7.json	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	69
7	2	http://file-server/SP10.json	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	88
8	5	http://file-server/SP11.json	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	95
\.


--
-- Data for Name: pool_offline_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_offline_data (id, pool_id, ticker_name, hash, json, bytes, pmr_id) FROM stdin;
1	10	SP1	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	{"name": "stake pool - 1", "ticker": "SP1", "homepage": "https://stakepool1.com", "description": "This is the stake pool 1 description."}	\\x7b0a2020226e616d65223a20227374616b6520706f6f6c202d2031222c0a2020227469636b6572223a2022535031222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2031206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c312e636f6d220a7d0a	1
2	3	SP3	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	{"name": "Stake Pool - 3", "ticker": "SP3", "homepage": "https://stakepool3.com", "description": "This is the stake pool 3 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2033222c0a2020227469636b6572223a2022535033222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2033206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c332e636f6d220a7d0a	2
3	8	SP4	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	{"name": "Same Name", "ticker": "SP4", "homepage": "https://stakepool4.com", "description": "This is the stake pool 4 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535034222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2034206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c342e636f6d220a7d0a	3
4	4	SP5	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	{"name": "Same Name", "ticker": "SP5", "homepage": "https://stakepool5.com", "description": "This is the stake pool 5 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535035222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2035206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c352e636f6d220a7d0a	4
5	6	SP6a7	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	{"name": "Stake Pool - 6", "ticker": "SP6a7", "homepage": "https://stakepool6.com", "description": "This is the stake pool 6 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2036222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2036206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c362e636f6d220a7d0a	5
6	11	SP6a7	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	{"name": "", "ticker": "SP6a7", "homepage": "https://stakepool7.com", "description": "This is the stake pool 7 description."}	\\x7b0a2020226e616d65223a2022222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2037206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c372e636f6d220a7d0a	6
7	2	SP10	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	{"name": "Stake Pool - 10", "ticker": "SP10", "homepage": "https://stakepool10.com", "description": "This is the stake pool 10 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130222c0a2020227469636b6572223a202253503130222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203130206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31302e636f6d220a7d0a	7
8	5	SP11	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	{"name": "Stake Pool - 10 + 1", "ticker": "SP11", "homepage": "https://stakepool11.com", "description": "This is the stake pool 11 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130202b2031222c0a2020227469636b6572223a202253503131222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203131206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31312e636f6d220a7d0a	8
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
1	21	12
2	12	13
3	14	14
4	19	15
5	15	16
6	17	17
7	22	18
8	20	19
9	18	20
10	13	21
11	16	22
12	48	23
13	45	24
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
1	9	0	76	5
2	7	0	83	18
3	2	0	90	5
4	5	0	97	18
\.


--
-- Data for Name: pool_update; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_update (id, hash_id, cert_index, vrf_key_hash, pledge, active_epoch_no, meta_id, margin, fixed_cost, registered_tx_id, reward_addr_id) FROM stdin;
1	1	0	\\x51a850083dba78f300e66ba3355323131d67e9b8b3bf8a7049fae660e05c7172	0	2	\N	0	0	34	12
2	2	1	\\x80dec82e1ec058c23d3da938e959846073454cca32414ec685ae8269572c608b	0	2	\N	0	0	34	13
3	3	2	\\x0ae048a5895965bf74a6241e9b4e5301544073f5d61eb96d3654f236a2d2918a	0	2	\N	0	0	34	14
4	4	3	\\x1f748901bc05823a70449c783c346b664abbf3d973eea99b0b89c8b63a653c75	0	2	\N	0	0	34	15
5	5	4	\\x4ca4909e5953acd587917e0ab82e7c072e1481baa876733c4abdcb213e29094f	0	2	\N	0	0	34	16
6	6	5	\\xe3f8f46c936b2de29d2964e9e995f71aa8209190a80c27301d0a12a52b4882c8	0	2	\N	0	0	34	17
7	7	6	\\x4616bd4034636e7d98b6505c89ee8fbae578ffe27f593e7a1763c9dff2d6ff68	0	2	\N	0	0	34	18
8	8	7	\\xfdcbb9bd942e6244983f91701dddd5610fbc72240df0d22ed7cb3b7bb64ffe2a	0	2	\N	0	0	34	19
9	9	8	\\xc42bb977bf12bd0ac00c04296d71727975baa313121003753a234c2da4333766	0	2	\N	0	0	34	20
10	10	9	\\xb8db5e1752807592260c45c588603344290ca4d29f75140c9f861339b2fc83cc	0	2	\N	0	0	34	21
11	11	10	\\x51e2d40d549402b2ae914ab65a1495ccb84b8a19615b589604f3f06343251416	0	2	\N	0	0	34	22
12	10	0	\\xb8db5e1752807592260c45c588603344290ca4d29f75140c9f861339b2fc83cc	400000000	3	1	0.149999999999999994	390000000	39	21
13	1	0	\\x51a850083dba78f300e66ba3355323131d67e9b8b3bf8a7049fae660e05c7172	500000000	3	\N	0.149999999999999994	390000000	44	12
14	3	0	\\x0ae048a5895965bf74a6241e9b4e5301544073f5d61eb96d3654f236a2d2918a	600000000	3	2	0.149999999999999994	390000000	49	14
15	8	0	\\xfdcbb9bd942e6244983f91701dddd5610fbc72240df0d22ed7cb3b7bb64ffe2a	420000000	3	3	0.149999999999999994	370000000	54	19
16	4	0	\\x1f748901bc05823a70449c783c346b664abbf3d973eea99b0b89c8b63a653c75	410000000	3	4	0.149999999999999994	390000000	59	15
17	6	0	\\xe3f8f46c936b2de29d2964e9e995f71aa8209190a80c27301d0a12a52b4882c8	410000000	3	5	0.149999999999999994	400000000	64	17
18	11	0	\\x51e2d40d549402b2ae914ab65a1495ccb84b8a19615b589604f3f06343251416	410000000	3	6	0.149999999999999994	390000000	69	22
19	9	0	\\xc42bb977bf12bd0ac00c04296d71727975baa313121003753a234c2da4333766	500000000	3	\N	0.149999999999999994	380000000	74	20
20	7	0	\\x4616bd4034636e7d98b6505c89ee8fbae578ffe27f593e7a1763c9dff2d6ff68	500000000	3	\N	0.149999999999999994	390000000	81	18
21	2	0	\\x80dec82e1ec058c23d3da938e959846073454cca32414ec685ae8269572c608b	400000000	4	7	0.149999999999999994	410000000	88	13
22	5	0	\\x4ca4909e5953acd587917e0ab82e7c072e1481baa876733c4abdcb213e29094f	400000000	4	8	0.149999999999999994	390000000	95	16
23	12	0	\\x2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	500000000000000	15	\N	0.200000000000000011	1000	358	48
24	13	0	\\x641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	50000000	15	\N	0.200000000000000011	1000	361	45
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
1	99	1700	476468	133	spend	0	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	1
2	106	656230	203682571	52550	spend	0	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	2
\.


--
-- Data for Name: redeemer_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.redeemer_data (id, hash, tx_id, value, bytes) FROM stdin;
1	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	99	{"int": 12}	\\x0c
2	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	106	{"int": 42}	\\x182a
\.


--
-- Data for Name: reference_tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reference_tx_in (id, tx_in_id, tx_out_id, tx_out_index) FROM stdin;
1	106	100	0
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
4	6	::
5	7	2:36:
6	8	::
7	9	3:37:
8	10	::
9	11	4:38:
10	12	::
11	13	::
12	14	5:39:
13	15	::
14	16	::
15	17	6:40:
16	18	7:42:
17	19	::
18	20	8:43:
19	21	9:44:
20	22	10:45:
21	23	11:46:
22	24	::
23	25	::
24	26	12:48:
25	27	13:49:
26	28	::
27	29	::
28	30	::
29	31	14:50:
30	32	::
31	33	15:51:
32	34	::
33	35	16:52:
34	36	17:54:
35	37	::
36	38	18:55:
37	39	19:56:
38	40	::
39	41	::
40	42	::
41	43	20:57:
42	44	21:58:
43	45	22:60:
44	46	::
45	47	23:61:
46	48	::
47	49	24:62:
48	50	25:63:
49	51	::
50	52	26:64:
51	53	::
52	54	27:66:
53	55	28:67:
54	56	::
55	57	::
56	58	29:68:
57	59	::
58	60	30:69:
59	61	::
60	62	31:70:
61	63	32:72:
62	64	::
63	65	33:73:
64	66	::
65	67	34:74:
66	68	::
67	69	35:75:
68	70	36:76:
69	71	37:78:
70	72	38:79:
71	73	39:80:
72	74	::
73	75	40:81:
74	76	::
75	77	41:82:
76	78	::
77	79	::
78	80	42:83:
79	81	::
80	82	43:84:
81	83	44:86:
82	84	::
83	85	::
84	86	45:87:
85	87	::
86	88	::
87	89	46:88:
88	90	47:89:
89	91	::
90	92	48:90:
91	93	49:91:
92	94	50:92:
93	95	::
94	96	51:94:
95	97	::
96	98	52:95:
97	99	::
98	100	53:96:
99	101	54:97:
100	102	::
101	103	::
102	104	55:98:
103	105	::
104	106	56:99:
105	107	57:100:
106	108	::
107	109	58:102:
108	110	59:103:
109	111	::
110	112	::
111	113	60:104:
112	114	::
113	115	::
114	116	61:105:
115	117	62:106:
116	118	::
117	119	63:107:
118	120	::
119	121	::
120	122	64:108:
121	123	::
122	124	65:110:
123	125	66:111:
124	126	::
125	127	67:113:
126	128	68:115:
127	129	::
128	130	69:117:
129	131	70:119:
130	132	::
131	133	71:121:
132	134	::
133	135	72:123:
134	136	::
135	137	74:124:1
136	138	75:126:
137	139	76:132:5
138	140	77:134:8
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
366	368	::
367	369	::
368	370	::
369	371	::
370	372	::
371	373	::
372	374	::
373	375	::
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
393	395	78:136:9
394	396	::
395	397	::
396	398	::
397	399	79:138:12
398	400	::
399	401	::
400	402	::
401	403	81:140:15
402	404	::
403	405	::
404	406	::
405	407	82:142:
406	408	::
407	409	::
408	410	::
409	411	83:143:
410	412	::
411	413	::
412	414	::
413	415	84:144:17
414	416	::
415	417	::
416	418	::
417	419	85:146:18
418	420	::
419	421	::
420	422	::
421	423	87:148:
422	424	::
423	425	::
424	426	::
425	427	89:149:20
426	428	::
427	429	::
428	430	::
429	431	90:151:
430	432	::
431	433	::
432	434	::
433	435	91:152:21
434	436	::
435	437	::
436	438	::
437	439	93:154:22
438	440	::
439	441	::
440	442	::
441	443	94:155:
442	444	::
444	446	::
446	448	::
448	450	96:158:26
449	451	::
450	452	::
451	453	::
452	454	97:160:29
453	455	::
454	456	::
455	457	::
456	458	99:162:31
458	460	::
459	461	::
460	462	::
461	463	101:164:32
462	464	::
463	465	::
464	466	::
465	467	102:166:35
466	468	::
467	469	::
468	470	::
469	471	104:168:
470	472	::
471	473	::
472	474	::
473	475	::
474	476	107:169:
475	477	::
476	478	::
477	479	::
478	480	109:171:
479	481	::
480	482	::
481	483	::
482	484	110:206:
483	485	::
484	486	::
485	487	::
486	488	145:215:
487	489	::
488	490	::
490	492	::
491	493	::
492	494	146:216:38
493	495	::
494	496	::
495	497	::
496	498	147:218:
497	499	::
498	500	::
499	501	::
500	502	::
501	503	148:219:39
502	504	::
503	505	::
504	506	::
505	507	150:221:
506	508	::
507	509	::
508	510	::
509	511	151:222:
510	512	::
511	513	::
512	514	::
513	515	::
514	516	::
515	517	155:226:
516	518	::
517	519	::
518	520	156:346:
519	521	::
520	522	::
521	523	::
522	524	::
524	526	::
525	527	216:348:
526	528	::
527	529	217:350:
528	530	218:352:
529	531	282:354:
530	532	284:356:
531	533	285::
533	535	287:360:
534	536	288:362:
535	537	289:363:
536	538	::
537	539	::
538	540	::
539	541	::
540	542	290:365:
541	543	::
542	544	::
543	545	::
544	546	::
545	547	::
546	548	::
547	549	::
548	550	::
550	552	::
551	553	::
552	554	::
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
615	617	::
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
689	691	::
690	692	291:366:
691	693	378:458:
692	694	::
693	695	::
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
731	733	::
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
862	864	::
863	865	::
864	866	::
865	867	::
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
885	887	481:566:
886	888	::
887	889	::
889	891	::
890	892	482:568:
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
931	933	::
932	934	::
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
1098	1100	495:582:
1099	1101	526:630:
1100	1102	568:680:
1101	1103	576:690:
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
1136	1138	::
1137	1139	::
1138	1140	::
1139	1141	::
1140	1142	::
1141	1143	::
1142	1144	::
1143	1145	::
1145	1147	::
1146	1148	::
1147	1149	::
1148	1150	::
1149	1151	::
1150	1152	::
1151	1153	::
1152	1154	::
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
1234	1236	::
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
1291	1293	655:782:
1292	1294	::
1293	1295	::
1294	1296	::
1295	1297	::
1296	1298	656:784:40
1297	1299	::
1298	1300	::
1299	1301	::
1300	1302	::
1301	1303	::
1302	1304	::
1303	1305	657:786:
1304	1306	::
1305	1307	::
1306	1308	::
1307	1309	658:788:
1308	1310	::
1309	1311	::
1310	1312	::
1311	1313	::
1312	1314	659:790:
1313	1315	::
1314	1316	::
1315	1317	::
1316	1318	661:792:
1317	1319	::
1318	1320	::
1319	1321	::
1320	1322	662:794:43
1321	1323	::
1322	1324	::
1323	1325	::
1324	1326	663:796:47
1325	1327	::
1326	1328	::
1327	1329	::
\.


--
-- Data for Name: reward; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward (id, addr_id, type, amount, earned_epoch, spendable_epoch, pool_id) FROM stdin;
1	4	member	7940405007778	1	3	2
2	1	member	8822672230864	1	3	1
3	5	member	5293603338518	1	3	6
4	6	member	3529068892345	1	3	8
5	7	member	9704939453950	1	3	3
6	8	member	5293603338518	1	3	4
7	2	member	5293603338518	1	3	5
8	10	member	4411336115432	1	3	11
9	3	member	11469473900123	1	3	10
10	9	member	11469473900123	1	3	9
11	11	member	11469473900123	1	3	7
12	14	leader	0	1	3	3
13	12	leader	0	1	3	1
14	20	leader	0	1	3	9
15	17	leader	0	1	3	6
16	21	leader	0	1	3	10
17	19	leader	0	1	3	8
18	16	leader	0	1	3	5
19	15	leader	0	1	3	4
20	13	leader	0	1	3	2
21	22	leader	0	1	3	11
22	18	leader	0	1	3	7
23	4	member	6057885714439	2	4	2
24	14	member	329070	2	4	3
25	12	member	1269271	2	4	1
26	20	member	634635	2	4	9
27	1	member	7788709781593	2	4	1
28	5	member	6057885714758	2	4	6
29	6	member	6923297959724	2	4	8
30	17	member	822675	2	4	6
31	21	member	940200	2	4	10
32	7	member	6057886701969	2	4	3
33	8	member	8654122449654	2	4	4
34	19	member	940200	2	4	8
35	2	member	4327062399638	2	4	5
36	10	member	9519534694620	2	4	11
37	15	member	1175251	2	4	4
38	3	member	6923297959724	2	4	10
39	13	member	822675	2	4	2
40	22	member	1292776	2	4	11
41	9	member	7788711051246	2	4	9
42	11	member	3461649356109	2	4	7
43	18	member	282060	2	4	7
44	14	leader	0	2	4	3
45	12	leader	0	2	4	1
46	20	leader	0	2	4	9
47	17	leader	0	2	4	6
48	21	leader	0	2	4	10
49	19	leader	0	2	4	8
50	16	leader	0	2	4	5
51	15	leader	0	2	4	4
52	13	leader	0	2	4	2
53	22	leader	0	2	4	11
54	18	leader	0	2	4	7
55	4	member	8507738074186	3	5	2
56	1	member	6508087772938	3	5	1
57	5	member	5061764153939	3	5	6
58	6	member	5061789653935	3	5	8
59	8	member	9400719071560	3	5	4
60	2	member	6806190459349	3	5	5
61	16	member	924297	3	5	5
62	10	member	4338614917667	3	5	11
63	3	member	5061772653937	3	5	10
64	13	member	1155371	3	5	2
65	14	leader	0	3	5	3
66	12	leader	1148877325315	3	5	1
67	20	leader	0	3	5	9
68	17	leader	893653306459	3	5	6
69	21	leader	893644806461	3	5	10
70	19	leader	893627806463	3	5	8
71	16	leader	0	3	5	5
72	15	leader	1659341926323	3	5	4
73	13	leader	0	3	5	2
74	22	leader	766028619817	3	5	11
75	18	leader	0	3	5	7
87	20	refund	0	5	5	9
88	13	refund	0	5	5	2
89	4	member	7111205441872	4	6	2
90	1	member	6398536651894	4	6	1
91	5	member	2846323594219	4	6	6
92	6	member	7831758564104	4	6	8
93	8	member	6404661586936	4	6	4
94	2	member	7116327485828	4	6	5
95	10	member	6406194566340	4	6	11
96	3	member	4262523659036	4	6	10
97	14	leader	0	4	6	3
98	12	leader	1129544750606	4	6	1
99	20	leader	0	4	6	9
100	17	leader	502692853077	4	6	6
101	21	leader	752600736375	4	6	10
102	19	leader	1382446290787	4	6	8
103	16	leader	1256213632825	4	6	5
104	15	leader	1130625419482	4	6	4
105	13	leader	1255329741084	4	6	2
106	22	leader	1130895945749	4	6	11
107	18	leader	0	4	6	7
108	4	member	9002406478246	5	7	2
109	1	member	4843880480152	5	7	1
110	5	member	6929819249057	5	7	6
111	6	member	6931532343892	5	7	8
112	8	member	4154843030997	5	7	4
113	2	member	5546395403914	5	7	5
114	10	member	6924990968270	5	7	11
115	3	member	6224942911766	5	7	10
116	14	leader	0	5	7	3
117	12	leader	855193364132	5	7	1
118	20	leader	0	5	7	9
119	17	leader	1223310384819	5	7	6
120	21	leader	1098910328832	5	7	10
121	19	leader	1223582696474	5	7	8
122	16	leader	979166543339	5	7	5
123	15	leader	733598256564	5	7	4
124	13	leader	1589071401952	5	7	2
125	22	leader	1222448334763	5	7	11
126	18	leader	0	5	7	7
127	4	member	8241575131138	6	8	2
128	1	member	6176256275747	6	8	1
129	5	member	8938799963636	6	8	6
130	6	member	2750858721676	6	8	8
131	8	member	4802061902040	6	8	4
132	2	member	7567184225413	6	8	5
133	10	member	6185627327120	6	8	11
134	3	member	2744948789632	6	8	10
135	14	leader	0	6	8	3
136	12	leader	1092571954149	6	8	1
137	20	leader	0	6	8	9
138	17	leader	1580377890925	6	8	6
139	21	leader	485572025392	6	8	10
140	19	leader	486598294764	6	8	8
141	16	leader	1335776657389	6	8	5
142	15	leader	850343548599	6	8	4
143	13	leader	1454806925291	6	8	2
144	22	leader	1093478878405	6	8	11
145	18	leader	0	6	8	7
146	1	member	5951468206278	7	9	1
147	5	member	5970780596357	7	9	6
149	6	member	7045342660641	7	9	8
150	8	member	3785895011585	7	9	4
151	2	member	9217800685056	7	9	5
152	10	member	5403988296759	7	9	11
153	3	member	5956383315670	7	9	10
154	55	member	1456830	7	9	11
155	46	member	7288321200	7	9	11
156	14	leader	0	7	9	3
157	12	leader	1054948651818	7	9	1
158	17	leader	1056718304973	7	9	6
159	21	leader	1054627259339	7	9	10
160	19	leader	1248758576494	7	9	8
161	16	leader	1630738732327	7	9	5
162	15	leader	671837763554	7	9	4
163	22	leader	958576020344	7	9	11
164	18	leader	0	7	9	7
165	1	member	3798633683721	8	10	1
166	5	member	3808038947382	8	10	6
167	6	member	5974868172949	8	10	8
169	8	member	7054270657224	8	10	4
170	2	member	5980831073825	8	10	5
171	10	member	6499564581878	8	10	11
172	3	member	5428508065342	8	10	10
173	55	member	1748913	8	10	11
174	46	member	8749570097	8	10	11
175	14	leader	0	8	10	3
176	12	leader	674506247570	8	10	1
177	17	leader	675572569149	8	10	6
178	21	leader	963081121919	8	10	10
179	19	leader	1061386430335	8	10	8
180	16	leader	1060070243726	8	10	5
181	15	leader	1253132359746	8	10	4
182	22	leader	1155340674920	8	10	11
183	18	leader	0	8	10	7
184	1	member	6226409112659	9	11	1
185	5	member	6755186806098	9	11	6
186	6	member	6239790736455	9	11	8
187	8	member	4671643221411	9	11	4
188	2	member	5195851707406	9	11	5
189	10	member	6732240979123	9	11	11
190	3	member	5716469332223	9	11	10
191	55	member	1808509	9	11	11
192	46	member	9047691959	9	11	11
193	14	leader	0	9	11	3
194	12	leader	1107485933170	9	11	1
195	17	leader	1201473039121	9	11	6
196	21	leader	1015022679779	9	11	10
197	19	leader	1109387794069	9	11	8
198	16	leader	923176422482	9	11	5
199	15	leader	831259608064	9	11	4
200	22	leader	1199001135994	9	11	11
201	18	leader	0	9	11	7
202	1	member	6062277447052	10	12	1
203	5	member	6071102243080	10	12	6
204	6	member	3542374557962	10	12	8
205	8	member	6575348108100	10	12	4
206	2	member	5052888714620	10	12	5
207	10	member	7060407808664	10	12	11
208	3	member	4047731430141	10	12	10
209	55	member	1896676	10	12	11
210	46	member	9488775473	10	12	11
211	14	leader	0	10	12	3
212	12	leader	1080307401546	10	12	1
213	17	leader	1081857105044	10	12	6
214	21	leader	720175373598	10	12	10
215	19	leader	631357264422	10	12	8
216	16	leader	900372538009	10	12	5
217	15	leader	1171227016720	10	12	4
218	22	leader	1259551980793	10	12	11
219	18	leader	0	10	12	7
220	1	member	4653178165937	11	13	1
221	5	member	5177733464711	11	13	6
222	6	member	7245362296615	11	13	8
223	8	member	5163386414211	11	13	4
224	2	member	4650469477034	11	13	5
225	10	member	4130405950901	11	13	11
226	3	member	6727933351997	11	13	10
227	55	member	1109577	11	13	11
228	65	member	3463730872	11	13	4
229	46	member	2780362234	11	13	11
230	14	leader	0	11	13	3
231	12	leader	830275823542	11	13	1
232	17	leader	923815063682	11	13	6
233	21	leader	1198811148520	11	13	10
234	19	leader	1293361528976	11	13	8
235	16	leader	830237793142	11	13	5
236	15	leader	922442314681	11	13	4
237	22	leader	738015609198	11	13	11
238	18	leader	0	11	13	7
\.


--
-- Data for Name: schema_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_version (id, stage_one, stage_two, stage_three) FROM stdin;
1	9	25	6
\.


--
-- Data for Name: script; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.script (id, tx_id, hash, type, json, bytes, serialised_size) FROM stdin;
1	99	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	plutusV1	\N	\\x4d01000033222220051200120011	14
2	101	\\x477e52b3116b62fe8cd34a312615f5fcd678c94e1d6cdb86c1a3964c	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "e09d36c79dec9bd1b3d9e152247701cd0bb860b5ebfd1de8abb6735a"}, {"type": "sig", "keyHash": "a687dcc24e00dd3caafbeb5e68f97ca8ef269cb6fe971345eb951756"}, {"type": "sig", "keyHash": "0bd1d702b2e6188fe0857a6dc7ffb0675229bab58c86638ffa87ed6d"}]}	\N	\N
3	102	\\x120125c6dea2049988eb0dc8ddcc4c56dd48628d45206a2d0bc7e55b	timelock	{"type": "all", "scripts": [{"slot": 1000, "type": "after"}, {"type": "sig", "keyHash": "966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37"}]}	\N	\N
4	104	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	plutusV2	\N	\\x5908920100003233223232323232332232323232323232323232332232323232322223232533532323232325335001101d13357389211e77726f6e67207573616765206f66207265666572656e636520696e7075740001c3232533500221533500221333573466e1c00800408007c407854cd4004840784078d40900114cd4c8d400488888888888802d40044c08526221533500115333533550222350012222002350022200115024213355023320015021001232153353235001222222222222300e00250052133550253200150233355025200100115026320013550272253350011502722135002225335333573466e3c00801c0940904d40b00044c01800c884c09526135001220023333573466e1cd55cea80224000466442466002006004646464646464646464646464646666ae68cdc39aab9d500c480008cccccccccccc88888888888848cccccccccccc00403403002c02802402001c01801401000c008cd405c060d5d0a80619a80b80c1aba1500b33501701935742a014666aa036eb94068d5d0a804999aa80dbae501a35742a01066a02e0446ae85401cccd5406c08dd69aba150063232323333573466e1cd55cea801240004664424660020060046464646666ae68cdc39aab9d5002480008cc8848cc00400c008cd40b5d69aba15002302e357426ae8940088c98c80c0cd5ce01901a01709aab9e5001137540026ae854008c8c8c8cccd5cd19b8735573aa004900011991091980080180119a816bad35742a004605c6ae84d5d1280111931901819ab9c03203402e135573ca00226ea8004d5d09aba2500223263202c33573805c06005426aae7940044dd50009aba1500533501775c6ae854010ccd5406c07c8004d5d0a801999aa80dbae200135742a00460426ae84d5d1280111931901419ab9c02a02c026135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d55cf280089baa00135742a00860226ae84d5d1280211931900d19ab9c01c01e018375a00a6666ae68cdc39aab9d375400a9000100e11931900c19ab9c01a01c016101b132632017335738921035054350001b135573ca00226ea800448c88c008dd6000990009aa80d911999aab9f0012500a233500930043574200460066ae880080608c8c8cccd5cd19b8735573aa004900011991091980080180118061aba150023005357426ae8940088c98c8050cd5ce00b00c00909aab9e5001137540024646464646666ae68cdc39aab9d5004480008cccc888848cccc00401401000c008c8c8c8cccd5cd19b8735573aa0049000119910919800801801180a9aba1500233500f014357426ae8940088c98c8064cd5ce00d80e80b89aab9e5001137540026ae854010ccd54021d728039aba150033232323333573466e1d4005200423212223002004357426aae79400c8cccd5cd19b875002480088c84888c004010dd71aba135573ca00846666ae68cdc3a801a400042444006464c6403666ae7007407c06406005c4d55cea80089baa00135742a00466a016eb8d5d09aba2500223263201533573802e03202626ae8940044d5d1280089aab9e500113754002266aa002eb9d6889119118011bab00132001355018223233335573e0044a010466a00e66442466002006004600c6aae754008c014d55cf280118021aba200301613574200222440042442446600200800624464646666ae68cdc3a800a400046a02e600a6ae84d55cf280191999ab9a3370ea00490011280b91931900819ab9c01201400e00d135573aa00226ea80048c8c8cccd5cd19b875001480188c848888c010014c01cd5d09aab9e500323333573466e1d400920042321222230020053009357426aae7940108cccd5cd19b875003480088c848888c004014c01cd5d09aab9e500523333573466e1d40112000232122223003005375c6ae84d55cf280311931900819ab9c01201400e00d00c00b135573aa00226ea80048c8c8cccd5cd19b8735573aa004900011991091980080180118029aba15002375a6ae84d5d1280111931900619ab9c00e01000a135573ca00226ea80048c8cccd5cd19b8735573aa002900011bae357426aae7940088c98c8028cd5ce00600700409baa001232323232323333573466e1d4005200c21222222200323333573466e1d4009200a21222222200423333573466e1d400d2008233221222222233001009008375c6ae854014dd69aba135744a00a46666ae68cdc3a8022400c4664424444444660040120106eb8d5d0a8039bae357426ae89401c8cccd5cd19b875005480108cc8848888888cc018024020c030d5d0a8049bae357426ae8940248cccd5cd19b875006480088c848888888c01c020c034d5d09aab9e500b23333573466e1d401d2000232122222223005008300e357426aae7940308c98c804ccd5ce00a80b80880800780700680600589aab9d5004135573ca00626aae7940084d55cf280089baa0012323232323333573466e1d400520022333222122333001005004003375a6ae854010dd69aba15003375a6ae84d5d1280191999ab9a3370ea0049000119091180100198041aba135573ca00c464c6401866ae700380400280244d55cea80189aba25001135573ca00226ea80048c8c8cccd5cd19b875001480088c8488c00400cdd71aba135573ca00646666ae68cdc3a8012400046424460040066eb8d5d09aab9e500423263200933573801601a00e00c26aae7540044dd500089119191999ab9a3370ea00290021091100091999ab9a3370ea00490011190911180180218031aba135573ca00846666ae68cdc3a801a400042444004464c6401466ae7003003802001c0184d55cea80089baa0012323333573466e1d40052002200623333573466e1d40092000200623263200633573801001400800626aae74dd5000a4c244004244002921035054310012333333357480024a00c4a00c4a00c46a00e6eb400894018008480044488c0080049400848488c00800c4488004448c8c00400488cc00cc0080080041	2197
5	107	\\xb5882504da08775e7dec7f38b74f8f5385642b3c5a370aa5c7c4d45e	timelock	{"type": "sig", "keyHash": "114ac9cd840083511e90f2c0d978eddc7e9b3a6499f5dcb22a8ace6f"}	\N	\N
6	109	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	timelock	{"type": "sig", "keyHash": "5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967"}	\N	\N
8	125	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}]}	\N	\N
9	135	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}, {"type": "sig", "keyHash": "3178bf14adf78294ac2d03d60b9edfb7323d3d719e98b4b0b3ca34cd"}]}	\N	\N
\.


--
-- Data for Name: slot_leader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slot_leader (id, hash, pool_hash_id, description) FROM stdin;
1	\\x122b3f3e42c2744f30dd975f57a1543f30d5da1e82d7130ca0d96ca6	\N	Genesis slot leader
2	\\x5368656c6c65792047656e6573697320536c6f744c65616465722048	\N	Shelley Genesis slot leader
15	\\x42e8dcb750104852ff300804500b848985c1b798ce7c5b14d4cd478c	2	Pool-42e8dcb750104852
18	\\xdb9f334d663079223816dd7886932ad58a095f6187421662b19bb291	9	Pool-db9f334d66307922
4	\\xc4e628589a0e0733a05dad56f9dcbaf40b2e368002c294cd0a2ffcb3	8	Pool-c4e628589a0e0733
39	\\xa9a53a8c2789af0b998b57d31d103774d16bb48473149aa3c81428b3	7	Pool-a9a53a8c2789af0b
14	\\xa96125afd1de45a40ad3cebf3ccd07c27bbd325f30c01712964ff7d5	6	Pool-a96125afd1de45a4
12	\\xe31012824263d20c391ca123162e2299b52b16f331d1ccfe3871723d	10	Pool-e31012824263d20c
8	\\x6854ad6d9787295c6a4bed34a7eb847420b1095345bb343ca7fb222b	3	Pool-6854ad6d9787295c
16	\\x8ffdd4e4e37dcb301a2d73ef8a2565435427c33b544bfa053e33bcaa	5	Pool-8ffdd4e4e37dcb30
7	\\x09ab91571c5bb3cd9e5096a27401d05d00fbac0b6705660b3816326a	1	Pool-09ab91571c5bb3cd
5	\\x8a035ddd247d1d47816e812d0907b3111dc80b848b5bcb384cfd58f2	4	Pool-8a035ddd247d1d47
3	\\xf2fd1765572b452dbeff87faaebf86c021c10c8d4b18cd3d0c635671	11	Pool-f2fd1765572b452d
\.


--
-- Data for Name: stake_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_address (id, hash_raw, view, script_hash) FROM stdin;
4	\\xe0029ae110f397a5e88d2aefc4b80733761db77ee285323e76a914d56c	stake_test1uqpf4cgs7wt6t6yd9thufwq8xdmpmdm7u2zny0nk4y2d2mq7p3dyv	\N
1	\\xe02e13057f4614092b1fd6d714c740460ab1bf071bf165019850c68887	stake_test1uqhpxptlgc2qj2cl6mt3f36qgc9tr0c8r0ck2qvc2rrg3pcjvu0nd	\N
5	\\xe035d5800021cc8cdf5b8c12e0ab0384fc969c4371efc97944683c0492	stake_test1uq6atqqqy8xgeh6m3sfwp2crsn7fd8zrw8huj72ydq7qfys3yqv2t	\N
6	\\xe03c3ce95c5bb76a0ccda47cebed309858a11de251cbdce48f89e17a33	stake_test1uq7re62utwmk5rxd537whmfsnpv2z80z289aeey038sh5vcgarv7g	\N
7	\\xe072193313e0472dd3fc5a0c3047b33a4431eb5013dcfdbe3d064335b6	stake_test1upepjvcnuprjm5lutgxrq3an8fzrr66sz0w0m03aqepntdsem5v55	\N
8	\\xe0724b8f204b77d395d8561a5a9509ac8b418069541772717d1b2b664d	stake_test1upeyhreqfdma89wc2cd949gf4j95rqrf2sthyutarv4kvngvs4xxx	\N
2	\\xe08353c4b5a7c5238e9994e66d306a997d339f9a8ccae88a42cf2969d1	stake_test1uzp483945lzj8r5ejnnx6vr2n97n88u63n9w3zjzeu5kn5gyfumfm	\N
10	\\xe08492c0f3eccec2aa875cb308cfc4f8257e97e19b63d08b2b3c8e6e66	stake_test1uzzf9s8nan8v9258tjes3n7ylqjha9lpnd3apzet8j8xuesuuyn59	\N
3	\\xe09725a551a4c65c27eeaab026bd5951ba7bb3f743958a15b95645c2fb	stake_test1uztjtf235nr9cflw42czd02e2xa8hvlhgw2c59de2ezu97c8vsy6v	\N
9	\\xe0c06f79d0061cd2c04ee55c12a9b9402b9ea879a5a05c005f839bc1ea	stake_test1urqx77wsqcwd9szwu4wp92degq4ea2re5ks9cqzlswdur6snsgez4	\N
11	\\xe0c50df7b5277e15d5493f86585cbbbe325838ad576a3691a654db7522	stake_test1urzsmaa4yalpt42f87r9sh9mhce9sw9d2a4rdydx2ndh2gslqxmtr	\N
21	\\xe0629668ad7297060c277d30611b23089cf057cd7df788677ebade5f06	stake_test1up3fv69dw2tsvrp805cxzxerpzw0q47d0hmcsem7ht097ps5yrzgd	\N
12	\\xe0267e0876cddff98032f131348a585bf80bf181b98a7f581ee2516170	stake_test1uqn8uzrkeh0lnqpj7ycnfzjct0uqhuvphx987kq7ufgkzuq2ucpau	\N
14	\\xe002c519dc7da898245d4907dfbd7e31ec8a944efb2394a71d81cb40cf	stake_test1uqpv2xwu0k5fsfzafyral0t7x8kg49zwlv3effcas895pncla0a47	\N
19	\\xe07ed26a26b1a38bb24c37a49a4edb25741d264d85302e626086c03545	stake_test1upldy63xkx3chvjvx7jf5nkmy46p6fjds5czucnqsmqr23gyeuyus	\N
15	\\xe08d5258e38ea2889f950396a3178c87323c774346bad3c6eac84f55af	stake_test1uzx4yk8r363g38u4qwt2x9uvsuerca6rg6ad83h2ep84ttc3yhql2	\N
17	\\xe04bfa27a64d056d1252caba2d283a6c4f843ee92c76b73f23752b4c9d	stake_test1up9l5faxf5zk6yjje2az62p6d38cg0hf93mtw0erw545e8g7kr0jf	\N
22	\\xe0b1820cacbebc3e6056f77f02e8da3f26167b135d9833a9a2aa9a290d	stake_test1uzccyr9vh67ruczk7als96x68unpv7cntkvr82dz42dzjrgtj5t6w	\N
20	\\xe028d7e7da9220886df683b8502e19264cd174e79522ac20757c04d67b	stake_test1uq5d0e76jgsgsm0kswu9qtseyexdza88j532cgr40szdv7ck5r43g	\N
18	\\xe0dc316589ccc178662882a15443f8f9b0661ec97feca64a3179d79fb9	stake_test1urwrzevfenqhse3gs2s4gslclxcxv8kf0lk2vj3308telwgj7fs5r	\N
13	\\xe098a81742ceaa895921e33bd5777268040e1d067ef6716c6a6ae35ce3	stake_test1uzv2s96ze64gjkfpuvaa2amjdqzqu8gx0mm8zmr2dt34eccz3yj26	\N
16	\\xe0845ce35e0947fe4f30439f3b7102f2584fbabe43c820aade7ff9f95f	stake_test1uzz9ec67p9rlunesgw0nkugz7fvylw47g0yzp2k70luljhcqyxkt6	\N
47	\\xe01bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	stake_test1uqdlrcfc7tuta27fv0y5es5wark5kst5gcql9md02zepalg9yxxuz	\N
49	\\xe09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j	\N
50	\\xe07d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	stake_test1up73dx2qeg7gv59739gpmycmxzffyqk3ha2ctmh9ghdgneqmy000q	\N
51	\\xe072263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	stake_test1upezv0agh8cq09rt33ardnh8pdstd3lwpa5s64g2pne0uqgcygw6k	\N
52	\\xe08de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	stake_test1uzx79ge8d7gkx27vu3k9xgj9zlra0fvat5d5lxcnzm9n7hc8yk6td	\N
53	\\xe04f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	stake_test1up85ec98csnkgus5dw3x8u25mlkgu8m63hvw650ukldv04q6rf54k	\N
54	\\xe00ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	stake_test1uq8lxxfr92332xgqp66eenhpw7z04q09czgjf6uvnku20fq023mfy	\N
55	\\xe0ce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	stake_test1ur89gkdpkj42jwy3smuznfxcjdas0jz64xtckt9s8kz8h3gj4h8zv	\N
61	\\xe056a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	stake_test1upt23d8czcsqt9y9m54hg4eryp388n5audgmz29w9fnt9ssf4vex8	\N
46	\\xe0f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	stake_test1urc4mvzl2cp4gedl3yq2px7659krmzuzgnl2dpjjgsydmqqxgamj7	\N
65	\\xe0f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	stake_test1urcqjef42euycw37mup524mf4j5wqlwylwwm9wzjp4v42ksjgsgcy	\N
48	\\xe0e0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	\N
45	\\xe0a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	\N
\.


--
-- Data for Name: stake_deregistration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_deregistration (id, addr_id, cert_index, epoch_no, tx_id, redeemer_id) FROM stdin;
1	46	0	5	151	\N
\.


--
-- Data for Name: stake_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_registration (id, addr_id, cert_index, epoch_no, tx_id) FROM stdin;
1	4	0	0	34
2	1	2	0	34
3	5	4	0	34
4	6	6	0	34
5	7	8	0	34
6	8	10	0	34
7	2	12	0	34
8	10	14	0	34
9	3	16	0	34
10	9	18	0	34
11	11	20	0	34
12	21	0	0	36
13	12	0	0	41
14	14	0	0	46
15	19	0	0	51
16	15	0	0	56
17	17	0	0	61
18	22	0	0	66
19	20	0	0	71
20	18	0	0	78
21	13	0	0	85
22	16	0	1	92
23	51	0	4	132
24	52	2	4	132
25	53	4	4	132
26	54	6	4	132
27	55	8	4	132
29	46	0	5	150
30	46	0	5	153
31	65	0	9	255
32	48	0	13	359
33	45	0	13	362
\.


--
-- Data for Name: treasury; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.treasury (id, addr_id, cert_index, amount, tx_id) FROM stdin;
\.


--
-- Data for Name: tx; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx (id, hash, block_id, block_index, out_sum, fee, deposit, size, invalid_before, invalid_hereafter, valid_contract, script_size) FROM stdin;
1	\\x6463314df7a180505a97c0248cf654cbd77531d77231706cb34bbadfe6f92516	1	0	910909092	0	0	0	\N	\N	t	0
2	\\x03445c1ba80628c56a378321b7b0c6287b4778c539210d4a6f97b2b8ac6b6a44	1	0	910909092	0	0	0	\N	\N	t	0
3	\\x290d1cd4f67beba27bb9c679808929d87eeb0877c3c2384c4924a703e30fb64e	1	0	910909092	0	0	0	\N	\N	t	0
4	\\x2a7325e05fa9228d4841e52319476ef3c8ec9815c72d85d55c9fc9c691479323	1	0	910909092	0	0	0	\N	\N	t	0
5	\\x6f196f09d61de478c4a73717ed9e9a86adc2283babbdb296e9b384eb07eb7ce6	1	0	910909092	0	0	0	\N	\N	t	0
6	\\x4e8e9d30ca5285239936865cd0a69f15747fa04a3681ccff262a768ef845bd3c	1	0	910909092	0	0	0	\N	\N	t	0
7	\\xedf14cbe12e33c9752e7de5aa7ae4e9db48d3fa85afd902fdd602010d0138297	1	0	910909092	0	0	0	\N	\N	t	0
8	\\x9afd80a5d8c2eecf9974755cdec6c09e47d236d075b0a2d3a7f960dd5c99f321	1	0	910909092	0	0	0	\N	\N	t	0
9	\\x7ee9ae4ca9640f9a855f3e2d27cf9aab74d618893dcf73b005acbda8a6dbe874	1	0	910909092	0	0	0	\N	\N	t	0
10	\\xb9d95f675aa4ba8a8c7c164c99a910f2b5dcf41e2e8d1e897cb343b09e2b862d	1	0	910909092	0	0	0	\N	\N	t	0
11	\\x6fdf85067ab214e52ab5369df563e18f687a607f8da9f39afe2818a6ce67d2fd	1	0	910909092	0	0	0	\N	\N	t	0
12	\\x0f706c9dad9f3d4b0dfed59cc39c51df34165f2169daf272ebf06ac251444c3b	2	0	3681818181818181	0	0	0	\N	\N	t	0
13	\\x0f8d7c652211a088fc2848ed450bd8f0d27ce0a08418c51ebc243a3dfe892def	2	0	3681818181818181	0	0	0	\N	\N	t	0
14	\\x52e83df2ef7078684ee674f39cd18074fcdef8dde854a8f2a55ef812ccd690a5	2	0	3681818181818190	0	0	0	\N	\N	t	0
15	\\x566145ad8341d71f26249b1958b752f28015ac094acd4ea7dfb9f417062d2db4	2	0	3681818181818181	0	0	0	\N	\N	t	0
16	\\x6116b706c77201a92d2d3d09513dbc5f83b9f1cba6a322eb1c3e05860c9748a1	2	0	3681818181818181	0	0	0	\N	\N	t	0
17	\\x61acc111da9d00798367f31456dd09026c9e20c595e81278d26514b5549022dd	2	0	3681818181818181	0	0	0	\N	\N	t	0
18	\\x6a47b6f1c229d16fa3cadfc61870a7dcbb26a7cf685385ef83143751db20d204	2	0	3681818181818181	0	0	0	\N	\N	t	0
19	\\x6cba10c123f18b71b8ab5167be5e3398623df501244c9c434b2fa59e7aed988a	2	0	3681818181818181	0	0	0	\N	\N	t	0
20	\\x78d8d8de84a49d217cdc6115e747bc9151d2c7e8bffaad8a5b142844a1b420ec	2	0	3681818181818181	0	0	0	\N	\N	t	0
21	\\x7d3343e3323fc7fe562f232e65bb00372d59333d06bfb9f4e95c4280bac11aff	2	0	3681818181818181	0	0	0	\N	\N	t	0
22	\\x7f5f762a386eb580262b2a8fc7b3b83038a4e01a4eb4c8efe2c74cf77577a652	2	0	3681818181818181	0	0	0	\N	\N	t	0
23	\\x81245064512b31701d2fd94ba6e8a33494a2cdee14047360325f501d3505b9c6	2	0	3681818181818181	0	0	0	\N	\N	t	0
24	\\x8308b1549451edbd5976956f0668e729a60f0658e3977af6c8bf35e916652070	2	0	3681818181818181	0	0	0	\N	\N	t	0
25	\\x9b12e5db449f393835630a4e3b76b13ea7cfb242cc39cba4dcb83a7b0f6073d8	2	0	3681818181818181	0	0	0	\N	\N	t	0
26	\\xa433c758d501174ee64cfab819621d5d52961804215dcd3475122e8c7cc58979	2	0	3681818181818181	0	0	0	\N	\N	t	0
27	\\xaa866c3d74d05e26c8fc2ff660ae4a12a75fb979665b560d854c894b1ff62a18	2	0	3681818181818181	0	0	0	\N	\N	t	0
28	\\xb132a01dd661d766a081df4807270fed98d917d7d42dfba4401b778e9450b1a8	2	0	3681818181818181	0	0	0	\N	\N	t	0
29	\\xc17a6ea177907d4ecc2f9e0327e51789ce9fffeb6d9c2ae8a68167d1c498bd94	2	0	3681818181818181	0	0	0	\N	\N	t	0
30	\\xd06d531c91e4257aa2e63af16b5dd562e3581b0db0eb518f0bf96a12af7a4496	2	0	3681818181818190	0	0	0	\N	\N	t	0
31	\\xe0e2abb7e6e9eff4d0b476acacdd29b4f66e4c5d14ca3cfdf07dbb13951dc704	2	0	3681818181818181	0	0	0	\N	\N	t	0
32	\\xe95b1fe5bab48b23fa0c97234261be69546c61829b64f393208e0f97caced978	2	0	3681818181818181	0	0	0	\N	\N	t	0
33	\\xf40a34a62a09e86114250e90daa1fb114146a4b718c62473189f838c9cbe533b	2	0	3681818181818181	0	0	0	\N	\N	t	0
34	\\x5368656c6c65792047656e65736973205374616b696e67205478204861736820	2	0	0	0	0	0	\N	\N	t	0
35	\\x5e95bbbd4c329ee7b0f23859792277e400b9ba18425fb922d0a274434cd9a8f5	5	0	3681818181651228	166953	0	263	\N	\N	t	0
36	\\x20e7bf539b7c82ae8dd1b60eb3aa489b9dca3cc5d0646c96b9806e49a253f08d	7	0	3681817681473231	177997	0	339	\N	5000000	t	0
37	\\xdaa17d6f40cd194d852f7f8082b722b21aa342df9af05469eeff1fdd428608b8	9	0	3681817681293914	179317	0	369	\N	5000000	t	0
38	\\x24a2edc228b3178cad490441fc98f4b1af1832094dfb9bad4223423d7dc032a4	11	0	3681818181637632	180549	0	397	\N	5000000	t	0
39	\\xddc753ecd787ef9b48ece5b73cdb980db9a945d44ec392c5880c4f0a8c94c446	14	0	3681818181443619	194013	0	653	\N	500000	t	0
40	\\x14322e941fffc2386bd1159013c952deb9a7292f74ed9f4341547825d098f668	17	0	3681817681126961	166953	0	263	\N	\N	t	0
41	\\xbb458f5fa323149d1be63dbd02d9f118c9f16723b01bce2dcb1db9c39606027c	18	0	3681817080948964	177997	0	339	\N	5000000	t	0
42	\\x3aadbbca80c527c43b39ce0951e5fe2a16cde9b79c117daf1fd9ce8630ffae1f	20	0	3681817080769647	179317	0	369	\N	5000000	t	0
43	\\xce72a5f6388d6eeaee8001c98728faddf9c7442d7f5947b9bd744cdddc3f1981	21	0	3681818181637632	180549	0	397	\N	5000000	t	0
44	\\x59007d4eca21cce1e248346412c457a2bfa66598029734fca71123778fca672f	22	0	3681818181446391	191241	0	590	\N	500000	t	0
45	\\x11e3bdf789e64fb96e692c3fb0e9728a4772fb09854507e58d8307a84dd549e6	23	0	3681817080602694	166953	0	263	\N	\N	t	0
46	\\x728ef5b4dd1c914274eb94983ff55d9637c01ec2258708435ed4a419b14c3713	26	0	3681816880424697	177997	0	339	\N	5000000	t	0
47	\\xdb8f858b6b38653424307a8b91463f5dd85fbbfc24233d70bbdd1fabbdb57913	27	0	3681816880245380	179317	0	369	\N	5000000	t	0
48	\\xac74513f6a8e1f563ca1274f4e94f2e7ca1df021744b098f94ead64423680004	31	0	3681818181637632	180549	0	397	\N	5000000	t	0
49	\\x17d1a3055b80c6cc6a80c4ffc07e0f4d1616bd3caea5b581ec583ed7e805eb85	33	0	3681818181443619	194013	0	653	\N	500000	t	0
50	\\xb8780616d49c1d64dac751cb977f1951d7e1406fe7db2fa1446d00b64c8c2d43	35	0	3681816880078427	166953	0	263	\N	\N	t	0
51	\\x30aeed1b9f789cc5c563e3853a8ea162c825fdc944ad178581adeb18e6d4210a	36	0	3681816379900430	177997	0	339	\N	5000000	t	0
52	\\x7e2e0676ea1e75900c4d024d5f8fcdd6d96bd4d90ef7b1902f83bab443a6efd7	38	0	3681816379721113	179317	0	369	\N	5000000	t	0
53	\\xfdd37ff8035165962cd7cfa7a0c61c9e6e256a49d229a2e2411eb471ef8e9096	39	0	3681818181637632	180549	0	397	\N	5000000	t	0
54	\\xb6a42130db40957d4f614562dd071fd919b8be45fd1d09f4fddbbdd57bbc0f82	43	0	3681818181443619	194013	0	653	\N	500000	t	0
55	\\x49c848b7b061dcdc11142691b1d1dc7b0591618a45ddfda80257705710e50d65	44	0	3681816379554160	166953	0	263	\N	\N	t	0
56	\\x7b1d588ede4aff08004d784510ff1ecfc59d98b1fac6d4bd6e4a2f52f33b756e	45	0	3681815879376163	177997	0	339	\N	5000000	t	0
57	\\x5a2e38e192e0b8490de0a181cc1e71fd0487f1e7f7cae623ebe0f01d425cfdad	47	0	3681815879196846	179317	0	369	\N	5000000	t	0
58	\\xd89fff7cfe4df75e3db75bb10086eef783352ef198ea2692520c93577b517191	49	0	3681818181637632	180549	0	397	\N	5000000	t	0
59	\\xdd4972a21011ac704dd2e7e1f163b74230e61bfe1a158dfba2138fe1681ccab3	50	0	3681818181443619	194013	0	653	\N	500000	t	0
60	\\x868621347ce0b45513f37de0b32f9dea9356090b1df10fb4f62cfe1c1bc6476c	52	0	3681815879029893	166953	0	263	\N	\N	t	0
61	\\xf37256541289899374be995c5e3fc7b83336d28941066fa27f73a2e11fdef6cb	54	0	3681815378851896	177997	0	339	\N	5000000	t	0
62	\\xaf08d3a7d60ade8ca7cd87a17333a8fd99b8cce7a57ae40af7306af0170f2a43	55	0	3681815378672579	179317	0	369	\N	5000000	t	0
63	\\xc15ff21652c4d34abc42aa456d937fdeb84a24274082b0e5553c3a0f506d1ebd	58	0	3681818181637632	180549	0	397	\N	5000000	t	0
64	\\x8a04e5d610be04c2e85d900788238f9be90fa35ca15ada07441684b171f7df01	60	0	3681818181443619	194013	0	653	\N	500000	t	0
65	\\x49dd6d25b9b192313cce2b60f0587bde411f7c33e45a1e5556bff1a0563cc208	62	0	3681815378505626	166953	0	263	\N	\N	t	0
66	\\xdf20b36303b8f180739024d055de4a93ade4faecb227380d723c0df92edef88f	63	0	3681814878327629	177997	0	339	\N	5000000	t	0
67	\\x3714ebf83f09c069920a5a181461aa082a2ef7993e7f0b6cc38a6f38c796877c	65	0	3681814878148312	179317	0	369	\N	5000000	t	0
68	\\x43148af7435cce2984ed956387bc2ad380410c878bc7ada623c44d2264c01fb0	67	0	3681818181637632	180549	0	397	\N	5000000	t	0
69	\\xa386ed858006cb37dc036dba5c8bed39801f1a073997420a9a36285beab2376a	69	0	3681818181443619	194013	0	653	\N	500000	t	0
70	\\x7868b08585ca69deeee6d89a2c7d8830ed18e13d941707d0fa81a9c8b0a601fe	70	0	3681814877981359	166953	0	263	\N	\N	t	0
71	\\x4182bccc38ec57a5ebe63b78e126a5b6fd1e1b312ec00007b44e8ce4186862d0	71	0	3681814577803362	177997	0	339	\N	5000000	t	0
72	\\xcb8028f5a34fffcc08dc6c44c5e37389c1587a818bdd0c5216e01ac4a7f809b7	72	0	3681814577624045	179317	0	369	\N	5000000	t	0
73	\\xe53d4ffa6a1c3f663196a4692446f077cb687eb8d019919ba702257556ded289	73	0	3681818181637632	180549	0	397	\N	5000000	t	0
74	\\xc0318dfc156f46607bc91a6c673da90f03e0f1280b859020f39caabe41276eac	75	0	3681818181446391	191241	0	590	\N	500000	t	0
75	\\x25bef20014556f5529fe07023739884ae14d2db1619f23e409b6654e87d215a1	77	0	3681818181265842	180549	0	397	\N	5000000	t	0
76	\\x8920c493f4ff736fdc69cf13f4ef788e330fd445f347014a504a6d0a74a1d621	80	0	3681814577439800	184245	0	439	\N	500000	t	0
77	\\xbf3a786a04a6dfdd1736e2687499ae59989b54a2eedd511423b0808c5a1032f7	82	0	3681814577272847	166953	0	263	\N	\N	t	0
78	\\xe506cd26a7f08af4aa0eb8f1e142bfac6fa271400a87323a9058b6a3488c0f4c	83	0	3681814277094850	177997	0	339	\N	5000000	t	0
79	\\x64a28c29d3a896d4200aa6ceba0a43bb67599ebcec78fd597a926423bc39a35d	86	0	3681814276915533	179317	0	369	\N	5000000	t	0
80	\\xeb35d2d596c80800503e2ed98b9d2169676977b843b8ddd58239171b1192467b	89	0	3681818181637632	180549	0	397	\N	5000000	t	0
81	\\xe068fef416fa0c02ffe75fae21cdf9ebf1f434f419d46bace83c4d305a0a5379	90	0	3681818181446391	191241	0	590	\N	500000	t	0
82	\\x63b10bcd0f4651551fe2bb12123f1369140ee8cb521910930b2fb52d7620209f	92	0	3681818181265842	180549	0	397	\N	5000000	t	0
83	\\x4fe082a6db2b3bcd5390ec9f005c7158d45ec5164f6f8dfbd31ac5030cb0ab5d	93	0	3681814276731288	184245	0	439	\N	500000	t	0
84	\\xd270f6c721c56042b2f0389d17822163d64638a4d03f2b7df9b52ed1908d1c80	94	0	3681814276564335	166953	0	263	\N	\N	t	0
85	\\x8dcab2d56c27f8fdbc2004518ac0310bdfd4f04ebfa58c1d2806c2ac615ea752	96	0	3681813776386338	177997	0	339	\N	5000000	t	0
86	\\x1af189239c87dd303a1953539600086903181e09b14d02cf30b5876bc4e2f096	98	0	3681813776207021	179317	0	369	\N	5000000	t	0
87	\\xb3fcbd9cb4c37cacbec973ea53cc7f4d37cf2459fada850aa251fefcb86b9f36	100	0	3681818181637632	180549	0	397	\N	5000000	t	0
88	\\x37559910d0aa0e016a842e8dcb5952da433b543fc3e13c25b302d0975a0723aa	101	0	3681818181443575	194057	0	654	\N	500000	t	0
89	\\xe9ceeb7f127e7b37e063738e8b3228d62b9575812e2a1eab3bdca8531cd2e506	104	0	3681818181263026	180549	0	397	\N	5000000	t	0
90	\\xa73de37884049eae141f81821426d6522ad511bed2832c09773f0ccea8bf961d	106	0	3681813776022776	184245	0	439	\N	500000	t	0
91	\\x6f8ef583a533b0cb35965e1beacd781c581f35727ca160d3526d3b147c99bba9	107	0	3681813775855823	166953	0	263	\N	\N	t	0
92	\\x7eafde7531fa7883c4992536a0d9742c1afafc035d1771b4f1947b041811172b	109	0	3681813275677826	177997	0	339	\N	5000000	t	0
93	\\xa11b6e816d5ca2e8d6e2a16d894d7aa9e7266d00c9f887f1e67d6b4642dda059	110	0	3681813275498509	179317	0	369	\N	5000000	t	0
94	\\xba0d3a356ad6a109bea9d7b161b686f71e87b376c6953073cacfe3d64a5b9bc4	113	0	3681818181637641	180549	0	397	\N	5000000	t	0
95	\\xc9d418b0e099e9a7a26ebac50d0bf975047f8b6392461b93e59a53afbe746963	116	0	3681818181443584	194057	0	654	\N	500000	t	0
96	\\x75b4b5388198cc87068167f6929d95cd668acb36b96a5f4c662fd60bfe36b034	117	0	3681818181263035	180549	0	397	\N	5000000	t	0
97	\\x8c2f1c65b53567308a704bc2780821c21a50abdfc562ec2ae57fdca41c87e719	119	0	3681813275314264	184245	0	439	\N	500000	t	0
98	\\xa6a7e23f1767d8ddb4773f5f0bef72133ec3bca63658002a6b21d6d6567080ff	122	0	3681818181650832	167349	0	272	\N	\N	t	0
99	\\x47e413441127904b9e9fa7a91a2f90bdae359b1231754ad404d83f13e8626e27	124	0	99828910	171090	0	350	\N	\N	t	14
100	\\x3d63c292b07c4290d5cc61eff00c36b2cb2e396895b9e52449914ea926ecaf2a	125	0	3681818081484759	166073	0	243	\N	\N	t	0
101	\\xa3408f6ebb098ec9ba0e907e4d4de964b7dc628fadbfd75c75d64f04ec380af5	127	0	3681817981314374	170385	0	341	\N	\N	t	0
102	\\x63efdd9f556ce438b65975882df0e90cb494d4008e5a7efae1f533ae6295b5bd	128	0	3681817881146585	167789	0	282	\N	\N	t	0
103	\\x19f11b9bccb443e6a5f3c7e2969330f0cb876ad0b398f1ffe90b1d664811e677	130	0	3681817780979940	166645	0	256	\N	\N	t	0
104	\\x14faabea080f52304e50fc64d2b03762dc03fe2b4712cd2dc901bef50017228e	131	0	3681817680717067	262873	0	2443	\N	\N	t	0
105	\\xd6ac04754903f2b10703a199245cb21bb37a9f49d2679bf39a18647896e0c9ac	133	0	3681817580550950	166117	0	244	\N	\N	t	0
106	\\x86da042768db4efdcded90ed6f7d5f576674cc33ae4776a92f8ace41b75c4135	135	0	3681817580223603	327347	0	2613	\N	\N	t	2197
107	\\xb17e1f783eb0aac681e82bbee53b8649e63231cc716ad9e72e46403157a1a26b	137	0	3681818181642252	175929	0	467	\N	\N	t	0
108	\\x69970a5b3a1a8eaa5f302abe9cf4ce217b23ed6aa0f670e2282148e00a7a458e	138	0	3681813275134639	179625	0	551	\N	\N	t	0
109	\\x528feeda52bae4aef4cfaefb52382a8ccb7085a0729b47880d03948d843c674a	139	0	4999999767575	232425	0	1751	\N	\N	t	0
110	\\x4640cef56e5b46c90ebdda4381b18178dd4d5a5b043576caa6d670458e4e38f2	140	0	4999989582758	184817	0	669	\N	\N	t	0
111	\\xf3be22a2a8b7dff6ee170480ac94f10f7b8844f230227f21fc117c621b42569f	395	0	4999979347913	234845	0	1700	\N	5556	t	0
112	\\xc2d5b1f26f25dff80ddf8e9e2fc06a2c71839a4cf23c4a46a65c7251b86662c0	399	0	4999979173480	174433	0	428	\N	5591	t	0
113	\\xf8c81ea2450976cc1d18113113bb6d96045134199046228aa06d3f13d1427ae1	403	0	4999959002479	171001	0	350	\N	5644	t	0
114	\\x25dbe2b4f73de484149087f36271a5d73bb68cfcc8b3e3756d174fbe94fa3d73	407	0	4999938828398	174081	0	319	\N	5708	t	0
115	\\x1d29d4a54ed9b36145e28d77b65962c1bbce572153269f43a8fca8f0ccf4fa45	411	0	19826843	173157	0	399	\N	5718	t	0
116	\\x094a4fe65f61263b95ed92c45a153799ed36277fd2499f2ba96c3945618d5871	415	0	4999938635573	192825	0	745	\N	5778	t	0
117	\\x1dde0a84c20246b8080cf86f41621bc9244ce9516122ce3568f752181a135479	419	0	4999938439316	196257	0	823	\N	5809	t	0
118	\\x46c7dd5f6945a190436004ab39715bad7d1e1d4cc191bb4d3f876312bd232a12	423	0	4999938264399	174917	0	338	\N	5859	t	0
119	\\xec86b21de2b380456db06f5c30dccd1bea635d62cf3555da7b2fe8b50947e65a	427	0	4999938071574	192825	0	745	\N	5908	t	0
120	\\x6ba4af82e07d0b4daef7a11ba8940f2ce4e1d5ab39f2801757206c23b34dd7ea	431	0	9826843	173157	0	298	\N	5961	t	0
121	\\x3ca94e8e0ba5ed3f37b843d610c0489ec6f1644ea9ca94c0918a13d946ad4857	435	0	4999937704008	194409	0	781	\N	6008	t	0
122	\\x06ebfea8a3572be24dd995827074a60f5ecd881fb6457bf46cf899fdd66f8089	439	0	9824995	175005	0	340	\N	6038	t	0
123	\\x2128d885a9af643cc407865699e8ccf5be3668c4b5d871762239153fcda394b5	443	0	9651838	173157	0	298	\N	6076	t	0
125	\\x9557d560b2bb6c0bf50e1715064abd76f8033e5faafeba9d7612cdd4656dd9c3	450	0	4999927500007	204001	0	1100	\N	6114	t	0
126	\\x19950d20d9d308a4fc14b76ac96cdacb6ea493218b7d7731652e6ea9dc53ce81	454	0	4999927319766	180241	0	560	\N	6206	t	0
127	\\x834b4ef48de3a233e6061389cce6dd41185dc2a375b912da9eff2454cd8898a3	458	0	19463237	188601	0	750	\N	6243	t	0
128	\\xbfc8265cd8e5b9dbe96c14f45786445f5b057e9db8da82408db3bd847d74aacc	463	0	4999917130769	188997	0	759	\N	6291	t	0
129	\\x11cc0f69d2ac30c4aa28ec3bb0fc5adde2c3345388b68a5eaaff4af9b0bfd886	467	0	19811047	188953	0	758	\N	6308	t	0
130	\\x43194d604577d7b5d61514a62825c7405e804cee4a4f5157a9dee1795e4339cf	471	0	4999926762587	179229	0	537	\N	6324	t	0
131	\\xcb89774eb999189b60be0c1d72ee068eec5fc19f0333cd70e54f1ffbb5127688	476	0	4999936055835	169989	0	327	\N	6341	t	0
132	\\x0c16e505ac4621ecccd3a2afba51e6300ec01bff80d4a0bc21490a9134c6c04f	480	0	999675351	324649	0	3846	\N	6363	t	0
133	\\x97dc02fd283365ffca6a8a31b2427210243f5c5d22c73aff8d21f8218040a3b6	484	0	999414590	260761	0	2394	\N	6412	t	0
134	\\xf42e06214d519a0eef6a2cf5e003263b4c33c0c2e89a44a6d81b769e67f1017e	488	0	499375158	201757	0	1049	\N	6480	t	0
135	\\xf60ebd457dd693ad3d60f50b53aa2b45e2043ccec6a4e97bb2bc7cf5ac5a70fe	494	0	4998935871986	183849	0	642	\N	6496	t	0
136	\\xc953d1d46d38a0477487b7cc6806889b13d15741f52ad1c01bacca54a8f19b30	498	0	2820947	179053	0	533	\N	6559	t	0
137	\\x0525e08bdee8890c320a4b3b7d6e78cf2f00eebe3c548e3a8281eb32c6bc56d9	503	0	4998935513792	179141	0	535	\N	6607	t	0
138	\\x33ef02c4a788ed8f8d1ceeac1748abe75df84ae9b0bbb361fe508b46648e3c96	507	0	2827019	172981	0	395	\N	6648	t	0
139	\\xb2cb9739f77a93fd12219fe5cf2be7917d7f805907af36908443ffc2c00c7cc7	511	0	4998935170646	170165	0	331	\N	6685	t	0
140	\\x97bf11a0e20220411f7c05b6dca235cbb42833feee156f8f1ead18d248e0dc12	511	1	4998935000481	170165	0	331	\N	6685	t	0
141	\\x3b8a99d47d99407daa50b9b992197db2495cd5e372c58d3afac2d181ca437ee1	517	0	2999360688173	516313	0	8198	\N	6718	t	0
142	\\x7f249485458e34a0488b7db634ab8673f02c196392b2125528d8337a88af1e0c	520	0	179474447	525553	0	8408	\N	6734	t	0
143	\\x2ebe655790020318ab31ce362819a92bded493a145c9b83496470685a34edaaf	527	0	49843203495	170297	0	334	\N	6766	t	0
144	\\x814cbf0160a945c47a73f6fec37ca22bcb6d9138170c3395bc4e8ecbacd5c85c	529	0	49843205343	168449	0	292	\N	6801	t	0
145	\\x4a4b064046b222876d2351b986328389cf8ad873c90a6fe2ee82c85cd64d3900	530	0	4998932374629	270793	0	2618	\N	6813	t	0
146	\\xe384f4af2b0248c97232b61c5e9193517f8427836c2c5cb6b8438b0e8e57d912	531	0	4998932204640	169989	0	327	\N	6817	t	0
147	\\x54d3f23337e3f8f00ac5c013d2b553835670a3e9a7adc6d28e559df43d33518f	532	0	4998922036235	168405	0	291	\N	6840	t	0
148	\\xc4cf14edc4747b8a105cfb542ef938961c3b289746dcf37fa81cd0cb03367a35	533	0	0	5000000	0	2360	\N	\N	f	1893
150	\\x6348df96d3d026e47a6804a72096bb10643396388291db006713b2e3ed14af37	535	0	9817823	182177	0	604	\N	6887	t	0
151	\\xdb57e8a7f074bec5a1f01a386567c4cff7ec66ed6536e70eccdb11e7abb2dcdf	536	0	4998916864662	171573	0	363	\N	6907	t	0
152	\\x514fe5bcc7b53353e14005fc27d46f6fd9ab7689a034a6f3ccd01b08a4658dc6	537	0	8649990	167833	0	278	\N	6914	t	0
153	\\xc32eb3e021c31a4b322dd0779d854645453b80f34f6795b031cbac6c17aad3e2	542	0	4998916684289	180373	0	563	\N	6977	t	0
154	\\x2bbc91693475abdc99fab74d5615587cc01367dc6b7dc6a18525793645c08491	692	0	4998916515884	168405	0	291	\N	8463	t	0
155	\\x6ffcfa583f2945191acd6f528abd1f97b65d0ba6ee73cc645f2036175dd7af2c	692	1	10480177	169813	0	323	\N	8463	t	0
156	\\xe3e38fae64aefb67439a4a77af4291124ec526d7e1d0f9a0e15d15f16da7d848	692	2	4998916345895	169989	0	327	\N	8463	t	0
157	\\x2671c475d01fc214816f5b0eb76dc98d592139316a14c67681006c67d7b0c1b6	692	3	10310364	169813	0	323	\N	8463	t	0
158	\\x5d6efaf87cba3af7d184e8cb742c22de030ed8d3c00e5f465a8816b010523595	692	4	4998911177490	168405	0	291	\N	8463	t	0
159	\\x4a0dfe9c4f2d890c70ef418b6c541f5e98c126254bf2c38806f43c6e3347b5ce	692	5	10140551	169813	0	323	\N	8463	t	0
160	\\x2db527e2852f534214a5368c6a6efde993c8ce84e5ed3e071f3bfc572f47a8eb	692	6	9970738	169813	0	323	\N	8463	t	0
161	\\x023198382b096940b2f89c5025c16c3d2bff29aedd4e7e27b36c6b8c8531d8bd	692	7	4998911007501	169989	0	327	\N	8463	t	0
162	\\xfec728bb3baf14eecb161cc57c157ebd7028442d525143d046e463471c0a27f4	692	8	4998910808250	169989	0	327	\N	8463	t	0
163	\\x63fd8289b6ef4b10b33e99460da5bb3a7649811d24c63f0a3e5fb42e5ccf6fb5	692	9	4998905639845	168405	0	291	\N	8463	t	0
164	\\x5bbd8ff1ae754fd5217fc7b611f9efcb3fbd3ca3cb1b5b9d07f37cdc45ab1852	692	10	9830187	169813	0	323	\N	8463	t	0
165	\\xe1fec97eb7da602a5e80ec6b39930935494113466539acaa2d55fa80598ae61b	692	11	9830187	169813	0	323	\N	8463	t	0
166	\\xc47760d96f80713c42c573bcb48bbd85a9f6b4591a01f603a43c22000643fee5	692	12	9830187	169813	0	323	\N	8463	t	0
167	\\x53846f4476f507570ed34876a724f5f7537ff45bb384c8a4f282a4bac16d470b	692	13	4998905300043	169989	0	327	\N	8463	t	0
168	\\x3e820096f705a50f6457df82846d85497a76121db3b8e6c8ba258f8fe173d321	692	14	9660374	169813	0	323	\N	8463	t	0
169	\\x7a12720bfb98061b4633d3910d95454599e7460ed6197f9edc0a9c69bbc3e3f0	692	15	9830187	169813	0	323	\N	8463	t	0
170	\\xab62716ddc8e121faef649c099fc4ea88fcdda192b6a841e1097319bc1eba8a9	692	16	9490561	169813	0	323	\N	8463	t	0
171	\\x46672d09ec68ebc8b09eeabae660ef92e4d67d250c930745e83397f03cdd10d0	692	17	9660374	169813	0	323	\N	8463	t	0
172	\\x5be2eb90a781e971406b042e04038ca9bcec31d59c350ef82c82a34a55c338b2	692	18	4998904620615	169989	0	327	\N	8463	t	0
173	\\x55e999cc106fcc0fd346818034246c51230e8e5d71e3e40a8f0edd35b3d454ca	692	19	4998899452210	168405	0	291	\N	8463	t	0
174	\\x8add26024acb4c77c87d29cdb8d9aed8e12c56a7ad8908e096df63f2c7ef472d	692	20	4998894283805	168405	0	291	\N	8463	t	0
175	\\xf4e66332086fb820c0c6562042ecb8e1162825336e2123cb9eeb09ea5357e772	692	21	9490561	169813	0	323	\N	8463	t	0
176	\\x440fba87bc71039a4b66175c1d2d265d39248e08f67b2035dc03e15e4a7d89eb	692	22	9320748	169813	0	323	\N	8463	t	0
177	\\xd1fe80504417111ec956e56083a6198cf15365292505ee382003ab5f504cbe91	692	23	9830187	169813	0	323	\N	8463	t	0
178	\\x1da2e82bec76f91667b5131cfdc133ebda6e681ba00744cf1b04fe8f6ea3db61	692	24	9660374	169813	0	323	\N	8463	t	0
179	\\xc31f0ff5e8a38a40ca98e147b1fd1447d31d0370d5380c445cd208e14930966c	692	25	9830187	169813	0	323	\N	8463	t	0
180	\\x5904470395da73761817cb8fa13a1461b8439bc56f5ed939bf7a67c69e56134c	692	26	8981122	169813	0	323	\N	8463	t	0
181	\\x12d0663b00522e7f05bd26660d4973c70d4d13470bf0fc3b03f59fc9fbe746fe	692	27	9490561	169813	0	323	\N	8463	t	0
182	\\x605dbe77aff5fea8992086623c581475c699ddff63a26ff0706dc360c164c8a7	692	28	4998893604377	169989	0	327	\N	8463	t	0
183	\\xb8f1d78eb0647abffe325564374d2ea8aa1052feeec3e1981f7ce3c4bccbe0cc	692	29	9830187	169813	0	323	\N	8463	t	0
184	\\xd8be64a40daf7c9cdb43ebd075e20719057bf700c4fcdb2103ad87aaaf450bfe	692	30	9660374	169813	0	323	\N	8463	t	0
185	\\x11032e51237bbbb9b4cc833ccd083e0f4866856f16300313323f4a08cdde2702	692	31	9490561	169813	0	323	\N	8463	t	0
186	\\x937d5e7017599c938de2b87d04e04e713d940b3eab806d8d1050ca41500ca821	692	32	9320748	169813	0	323	\N	8463	t	0
187	\\x7aadacc445aa308b6096e22afac6b8d6d6c3e5848159c2284b99d0d2caa3ff55	692	33	8132057	169813	0	323	\N	8463	t	0
188	\\x24cee6edbf0fec5548dd7ebfc3aa03cfa527aca1c2d29071ddcf4ffe039cde9d	692	34	7962244	169813	0	323	\N	8463	t	0
189	\\x7305ea9ef17ccefdbfc3c8f1c4fb93d6d81df760c02ba6a2a4b3852258a92c66	692	35	7792431	169813	0	323	\N	8463	t	0
190	\\xdcb32e0ead8519dd4dc3650087a555261bcee8b796ae54b667f884b9e1dcf875	692	36	4998893434388	169989	0	327	\N	8463	t	0
191	\\xed419521e931fde8bbd2720ef0dd8fb8286d91f017e233fdb4ad6693ebc0c816	692	37	9660374	169813	0	323	\N	8463	t	0
192	\\x2885ea1a9130dce4bb4b00fa20738f428861b25277ac319bbbb9251a8e69a7f5	692	38	4998893264399	169989	0	327	\N	8463	t	0
193	\\x0df18d167f3151926ec7381d04ab6cedca31e80d18dd6accf6980af36ffd6629	692	39	7622618	169813	0	323	\N	8463	t	0
194	\\x36144db4407dd41315e8a7f1341bf8741bc7da6a5358d653ce183e0b980197aa	692	40	12111595	171397	0	359	\N	8463	t	0
195	\\xb20b7d350b7766ecc2b16f86cde777314e8d263559deeda84aefdf3f8a9b015b	692	41	9830187	169813	0	323	\N	8463	t	0
196	\\xbaf467a133bf9cc8a0d98ee79c96c715206aff6dcc371ed3c6e698d7efda0c8d	692	42	11941782	169813	0	323	\N	8463	t	0
197	\\xdd02acbe2123b4d8e5549bf7873c68ba22a9fbd5ccd564f281318f66c2e6438f	692	43	6773553	168229	0	287	\N	8463	t	0
198	\\x79e99ec85308926e06b4d8b9458ffe7b26d07de5e6cc86177a0fc60acd6b4e66	692	44	9660374	169813	0	323	\N	8463	t	0
199	\\xd5516ad7dbb616f2432b482d84dd7364a63be0ed042647afade62b37d3b189a6	692	45	9490561	169813	0	323	\N	8463	t	0
200	\\x6107110bd9a819af78b83b9ab93ef397e2d3e6b79d2591827ec3826576c8f415	693	0	9320748	169813	0	323	\N	8463	t	0
201	\\xd4db5609a38b392f566a215b0fd0e233a575616c1256511f5686b1d6490ca936	693	1	4998892415158	169989	0	327	\N	8463	t	0
202	\\x00855dc814fa26efd74870119805d99461de9787475886afc354020271a01858	693	2	9830187	169813	0	323	\N	8463	t	0
203	\\xa5584353bb975e013295e6cd6247d475f8b4fef3983a2a38e2fb98c7af6288be	693	3	6603740	169813	0	323	\N	8463	t	0
204	\\xe7150eb5525978b91e6ac28996ca7e0cbef48558116d89dc2cbfcc8dd43f902d	693	4	9660374	169813	0	323	\N	8463	t	0
205	\\x86900334312847ddcd5082aa657aee083b684d7008e1dd498af385e0b5b88a0e	693	5	11092717	171397	0	359	\N	8473	t	0
206	\\xad2071006be13c92e2f71ee13becfd757c400f35efc134113c2f481d57c4fff0	693	6	4998887246753	168405	0	291	\N	8473	t	0
207	\\x5a9324f6788c806c4c3fffce2626d501e51583d594be7682243d2f3d771aca1a	693	7	4998882078348	168405	0	291	\N	8473	t	0
208	\\x02e98f484a258c373016830f5fece6ebbff788a30b184334b41530bcac6113bc	693	8	4998881908359	169989	0	327	\N	8473	t	0
209	\\x926b310dcf95e9473a4bccc0d0bb3f0ac4dac54dc52663740b8a44d49c3f4595	693	9	9830187	169813	0	323	\N	8473	t	0
210	\\xb09f9f284e5b1ea21f16fba8297b89b3227e878f6c96c0b134e76da336728c57	693	10	9830187	169813	0	323	\N	8473	t	0
211	\\x97200fbfa974c1cf77b354424e3459cf80ff0bc477a090476c46f7c2471fbc34	693	11	10922904	169813	0	323	\N	8473	t	0
212	\\xac398579359a56158a080b6022ca09ae13d368d538251a33a66af3842a1ad908	693	12	9660374	169813	0	323	\N	8473	t	0
213	\\xc782e0a3118ce7aa2676c5473b1475fe66c120dc5d4779035f792eacf87ea6e8	693	13	9490561	169813	0	323	\N	8473	t	0
214	\\x7330c1a67ce78540623d919535e0e0ca7d506c8c47a890c63deba46b13cd9441	693	14	9660374	169813	0	323	\N	8473	t	0
215	\\xee41c87cd42451e10e33896e37f75f26d3eb67b0a74e2e231b75545587dacc34	693	15	10753091	169813	0	323	\N	8473	t	0
216	\\x8577177d3095f61ff4506175b886acfdcbc59ebf957c1a13deb885c5039645cb	693	16	9490561	169813	0	323	\N	8473	t	0
217	\\x563b390872de049aa80bd027567d9e6cf05ce52893985d595f9582108c23b2c0	693	17	9320748	169813	0	323	\N	8473	t	0
218	\\x93431312316e687aa4394e7e9ae8826932b9afa6256b0328e11965c21cfa56a5	693	18	9320748	169813	0	323	\N	8473	t	0
219	\\x1f2bbd8aa0429094dad60357207e48b519b6463e54ce9a2142f2951d4d56441e	693	19	9150935	169813	0	323	\N	8473	t	0
220	\\xf5abd7067fd36fb9b46492678cd14eb9ee01c3ff0f4bdc739cb3076ab25333f4	693	20	8981122	169813	0	323	\N	8473	t	0
221	\\x3a068c389b68eb5f70d1a89a3e7e1c90b1b34dffefcec18efb03d57adda4c3b0	693	21	8811309	169813	0	323	\N	8473	t	0
222	\\x32bb4b6296884e420d21d44471c9e266e106e4be4bfd33842c4939a609efa63f	693	22	9830187	169813	0	323	\N	8473	t	0
223	\\xa736ca8cbc8390096aeb93888e92e973561a1165d866230fe3c841671359f0a5	693	23	10413465	169813	0	323	\N	8473	t	0
224	\\x69b94d380dc1547a034667e0d89cf23033b7f9774ae5562c032e3962857df13a	693	24	4998876739954	168405	0	291	\N	8473	t	0
225	\\x54b22150d662ce97f8a0ea7cebd2e50859eea0d1858af7ef4563017bfe087c3a	693	25	9830187	169813	0	323	\N	8473	t	0
226	\\x4235d4703ab6c5fc072323b69c94a3b97902af0b26e171226f70eca4a9c95e1f	693	26	8641496	169813	0	323	\N	8473	t	0
227	\\xea5f73ddcb10e689f506d57d2585241cba5e166438570b06874b45143da21c62	693	27	4998875211461	169989	0	327	\N	8473	t	0
228	\\x0147b4080d80c00df9a90ab1f4b3e10c9ea6ba91034ad3c20d725bd323a09556	693	28	4998874362220	169989	0	327	\N	8473	t	0
229	\\xc0313863c62e0cb78959ebb0c1398485a9963b289b59659548233ef696acc289	693	29	10243652	169813	0	323	\N	8473	t	0
230	\\xd8619019a125f39860ef4e30a81b9dd59e4eccd0d4498d77ae31603fb1795b34	693	30	9830187	169813	0	323	\N	8473	t	0
231	\\x202126e6ff94004a6fd3a12540dbab0f37b80b05536cd7b16e5e109c3d497f48	693	31	9490561	169813	0	323	\N	8473	t	0
232	\\x11330a5eb733d05824c674cea724a1d6682eaffa8e2b06cfe97bd16ab5e2bcb3	693	32	9830187	169813	0	323	\N	8473	t	0
233	\\x431039eaabc870ddbd5529be1393fcbe166402a80c7b9292ac5461215f70f93e	693	33	9320748	169813	0	323	\N	8473	t	0
234	\\x99d072d039239bb508218053ba17c60cec8eeb4323eda23de6fec03bdb87e5ac	693	34	4998869193815	168405	0	291	\N	8473	t	0
235	\\x156a61d4ed0ac96bfccefba0796dad8200aea80cd1302b9078d0a3a9e4efb9c7	693	35	8981122	169813	0	323	\N	8473	t	0
236	\\x53cccae2371ee188c34d521b8eb854941c6c5fbfb9d305138f0191f30a6147ee	693	36	4998864025410	168405	0	291	\N	8473	t	0
237	\\x7c83ba2f82e252545bf1725036713d97d73639f63fba11c5728c09f5e0e87cf0	693	37	9830187	169813	0	323	\N	8473	t	0
238	\\x5a21455be83ed2a6b77d6eb15dcb5ca7072f4394cc45376c94550f7410dfcdfc	693	38	9830187	169813	0	323	\N	8473	t	0
239	\\xc74adce3b5664bc31abc049f9126bb98f2a4b726d0a0ca7dc1fe4ae9135ea8b5	693	39	9830187	169813	0	323	\N	8473	t	0
240	\\x37279e678dd3af0a3876e292f8bf972f9cc8e3b2a3a07a2b88862f46670ba510	693	40	9660374	169813	0	323	\N	8473	t	0
241	\\xc9fc6e86bd449a5ef41fd001471d165046a3df82409a986fa483bbce3eee9993	693	41	10073839	169813	0	323	\N	8473	t	0
242	\\x164a989e30b7fd2e82b40fb0ae038e18151aed3b3135ad8655fcbb0b9187d606	693	42	8811309	169813	0	323	\N	8473	t	0
243	\\x2410c3d3639c2a54ac8b7de34d3ab30990cb36163064ba7d4bb94608a3fcccfa	693	43	9660374	169813	0	323	\N	8473	t	0
244	\\x9e8157e6e76f33d1b05597f140c14c19425d7212d346674a1f83ea1c09a502c7	693	44	9490561	169813	0	323	\N	8473	t	0
245	\\x7893c8780d7a1d044fe9f3b988e4c7cdac847727c2d9b66c5fcb9f79e5006373	693	45	4998858857005	168405	0	291	\N	8473	t	0
246	\\x18c239a9f66392b6814c75668e19fa65650910dcbd236362ce51517be045a04e	693	46	9490561	169813	0	323	\N	8473	t	0
247	\\xa0b87e9eb46a7a2b52b451754fa9e0950377bba447d84c60f2f96a8cf7862c30	693	47	9830187	169813	0	323	\N	8473	t	0
248	\\x4b51fbbdfd017322e7c3c87f771ccf80a0dc83d21b4ca2127b95e4ecf3dd1496	693	48	9660374	169813	0	323	\N	8473	t	0
249	\\xaf7b827e704805af50bb5c17071ebbad5905e7225741675baddf5dc088214621	693	49	8715335	169813	0	323	\N	8473	t	0
250	\\x94c0648ba39306c4023860e60466ad53d14c8e5b843d224fc1ca8087f24bfe3f	693	50	8545522	169813	0	323	\N	8473	t	0
251	\\x70abed5d11930f2ebc1f98f9f1c01f51fc493204ee82b26344bafcfc87db0877	693	51	9830187	169813	0	323	\N	8473	t	0
252	\\x46775ebb75cd9c9d111559d7078b4ad611b5477d6f3274028a1134800b0cd914	693	52	9320748	169813	0	323	\N	8473	t	0
253	\\x794ec38c93e9fcdf20fd92086f1e8706e04ac7d241a9bcac088161499987dac9	693	53	9150935	169813	0	323	\N	8473	t	0
254	\\x2c4ea50b0479e53377e914667b0cdc3b893f075843f1337d93f0aa38198ca66c	887	0	7293146503	174697	0	434	\N	10449	t	0
255	\\xa440729d4cacb5822206481a3ec46e379b259982ea07147670e30dfeaad73375	892	0	5006193269521	241753	0	1962	\N	10486	t	0
256	\\x1700b538160619c895b16b3575044bd06577b6dd7538e27a4e95eab0cd6dc7b9	1100	0	1269345223425	174697	0	434	\N	12453	t	0
257	\\xa69f5d46aa084736a386881a39ecb65dfbe3e4a873ab1f6b446e2e0054aec1b6	1100	1	39110718401	168405	0	291	\N	12453	t	0
258	\\x324e32a5b1d2f8c01094052503e0d585ee32eb3ac9199a8e4e16187004eb1f61	1100	2	78221605209	168405	0	291	\N	12453	t	0
259	\\x738adeb30bd3bacc7ccc39767e674ba795d31000a0a0c04207e2716cd6e8ef37	1100	3	39110718401	168405	0	291	\N	12453	t	0
260	\\x3c6e77858038cca23bf79d6ed8c547e3ebf3e3cdb8a0b01d55f1882a3a9e7907	1100	4	39105549996	168405	0	291	\N	12453	t	0
261	\\xdb22aeead9356f62e8eda03730123f7fe490bd3601f26b0488bdc3b38c87cf69	1100	5	78226603625	169989	0	327	\N	12453	t	0
262	\\xa7e8c6db3ffd1c5033e49b09dd172ff5b9af0c921287b14afd4087e658294daa	1100	6	625774020504	168405	0	291	\N	12453	t	0
263	\\x6c89726a8792b859c9c20a9f991bec6443413d8b749be505362a03290fd843ad	1100	7	156443378822	168405	0	291	\N	12453	t	0
264	\\x341b4b4b6229b8745e255c8282095c7b7efcd7e831e2e7b8dd2f7ff5e1f8085b	1100	8	9830187	169813	0	323	\N	12453	t	0
265	\\x8e76148512aeb4f458c3ccc5c819a4b18f5661c3f26ca62f01d7bc40e4447d8d	1100	9	78226433636	169989	0	327	\N	12453	t	0
266	\\x69567cbb734c82cb00bfa5366fbfae7449e02e074e01eaf72f3c2f53b0346ca8	1100	10	78221265231	168405	0	291	\N	12453	t	0
267	\\x3e3e4b7b92c1070f369e917950ee01089dd09c67996197d7333574e477e52819	1100	11	1269340055020	168405	0	291	\N	12453	t	0
268	\\x4fd91a60a87d750ef49911b8289d7aa3f296cf94074eaaa68af4e82fcf722832	1100	12	78216436804	168405	0	291	\N	12453	t	0
269	\\x59868fb51693d289aac2212bb9b45d0078012ec0134d093f7b4b5b5aeb5c5cb8	1100	13	156438210417	168405	0	291	\N	12453	t	0
270	\\xa2f4cf3b1385b104c7a20823b5b55e156eebe75d1ead1b21436c8b7a3fb4dea1	1100	14	156433042012	168405	0	291	\N	12453	t	0
271	\\xbf1b8f8d773f8c6443dfd175ee947e707479303eec2a613084e1f4877e1ee50e	1100	15	9830187	169813	0	323	\N	12453	t	0
272	\\x19734b321c758162601fc7960d7a87ebb25d616585b82a542a82e1a67ed27d1b	1100	16	39110718402	168405	0	291	\N	12453	t	0
273	\\x89ba3bcb13f99c7e3e7b40f72f2970a497d247f2f654fb2ffa2a6b3e936dfe77	1100	17	1269334886615	168405	0	291	\N	12453	t	0
274	\\x483b3126d74181d1637bc026098927b62006e96a87315e55aa7fc248d4463d1d	1100	18	312886926050	168405	0	291	\N	12453	t	0
275	\\x77a8ac6c4c37af0174de8e7db65bee89ab9632c17e7b1d1558758c095a08b83b	1100	19	9830187	169813	0	323	\N	12453	t	0
276	\\xa3cae077e643012c2c10806cbc934cf46d32b94d7f7c379fd9e02b49077a2592	1100	20	9660374	169813	0	323	\N	12453	t	0
277	\\x0fd47359fdc0ed5ca6b1364b7d348af3cf75278faf84a6f29566e738a4b20525	1100	21	625779018920	169989	0	327	\N	12453	t	0
278	\\x4d01eb66847522fa8020e7de876acae228aa5f523c5992785e05b0bc58c0d7ae	1100	22	312886926050	168405	0	291	\N	12453	t	0
279	\\x2dfcf1254a211e207aa29c22b41939a559e4b5463b7f5d421144c4694ca3742c	1100	23	625768852099	168405	0	291	\N	12453	t	0
280	\\xa1611a741793db406d06f36de70515b8077ba2c9a24ce4665c9aa35571d62122	1101	0	1251548209414	168405	0	291	\N	12453	t	0
281	\\x5ea44c0f4a1824eb6e7f49bbb86f237568d5ab12c64577ece9d0883ce1c76a7c	1101	1	156432872023	169989	0	327	\N	12453	t	0
282	\\x76acbb8d8572ee690d993594203fbca96c75120d7767f253b10d192c1649ff53	1101	2	9830187	169813	0	323	\N	12453	t	0
283	\\x78d3d0dfd20bd1e9654391c8184e0f96c1f6029eaa19f59dd8eb1091d99867ae	1101	3	78216096826	168405	0	291	\N	12453	t	0
284	\\xed25b796e3672c108b534844824386ddf7ab9a9306c0be8c3eb05dbc6fde5c03	1101	4	9660374	169813	0	323	\N	12453	t	0
285	\\xe0d64ba04c7eb5f9c758f91f970c5e0895b05ff72f023d0a29c4836cc6ef5b73	1101	5	9830187	169813	0	323	\N	12453	t	0
286	\\x171cc7b1d9e742c0abfb46a13b75c0aa4a9885000b8648dc3009f2c430e4dfe5	1101	6	312881757645	168405	0	291	\N	12453	t	0
287	\\x862ab45435c2cd6bef55d3adfd0477804441b7dd49f3e577c7b48ba4948f8d80	1101	7	156432702034	169989	0	327	\N	12453	t	0
288	\\x17ee317eee83bd225fb468f268d3f061cf68e42240bc166f0c620a79a5f25d2b	1101	8	9830187	169813	0	323	\N	12453	t	0
289	\\x8f6a789c666df794729876b98fc3a8e5bf2776bffde921ab4eaceeffee1388f6	1101	9	9830187	169813	0	323	\N	12453	t	0
290	\\x8629d7dffc0ffb7f980083c64511de8b6ccc4850a274879db02f0ec2d0d428e6	1101	10	156427533629	168405	0	291	\N	12453	t	0
291	\\xe39ab2396cd7347a66cdd09660d9353271ff22fd2ce74e048f3466e5bc05152d	1101	11	312881587656	169989	0	327	\N	12453	t	0
292	\\xe7efb8b540010e63204d050a9c9059ee9095c58d444893aa7179b5c93397023f	1101	12	9830187	169813	0	323	\N	12453	t	0
293	\\x7137615c2a592a82c57c87165bcdff183e0ba03de84e5872cb2f43e231a613e3	1101	13	312881247854	169989	0	327	\N	12453	t	0
294	\\x55ba5ade797d23962ed66cfd8128b3503fc6df3018be9488d17d1c53d7f1ebea	1101	14	9830187	169813	0	323	\N	12453	t	0
295	\\x37d538347721905823cd3715fd9cd25ad1027b7dba660885a6c796f6ae161516	1101	15	156448207425	169989	0	327	\N	12453	t	0
296	\\xafa849a5977f566447a484fb5a52785142759a5a3e749e8d23f97721ebe3e47c	1101	16	9830187	169813	0	323	\N	12458	t	0
297	\\xadf433f10be20bd744a6b2626c5e7c144f04ef77a8433357d9e52949bdabb4bc	1101	17	9830187	169813	0	323	\N	12458	t	0
298	\\xc9637bf03baab3fd6a41af101bb2b8b55b8c39be2af6212db6d48ac1a7519993	1101	18	78210928421	168405	0	291	\N	12458	t	0
299	\\x1142da5811b361215aad114cfcdc54dc72e5b019969c47e98c5e54b5d586b073	1101	19	9830187	169813	0	323	\N	12458	t	0
300	\\x692cee1ef0d00612a7d71686f4088d30a561c1e4d06a4e1bb9e09c36b53c4a74	1101	20	9830187	169813	0	323	\N	12458	t	0
301	\\x10e31730352fc13e9789f087fc1abc9e2f0a1a033118efae7d7aa7976957b0a7	1101	21	312876079449	168405	0	291	\N	12458	t	0
302	\\x0502568c1810acf4cc561410da7a2d46612ccc1e4e49ac0352535e8b8b291f5e	1101	22	1269329718210	168405	0	291	\N	12458	t	0
303	\\x617bd8b08042adc8faacd9b5b04b66d9f324c507af4ea2d49f9cd263e357fcd4	1101	23	9830187	169813	0	323	\N	12458	t	0
304	\\xae28aff29b1821f49febd9829300266979da4beb23d02d162b57e8b8d636f0c3	1101	24	39105549996	168405	0	291	\N	12458	t	0
305	\\x92050c0cc93b7906c50c195179094d543808c9a76990aa1a718208a05f1bf701	1102	0	9660374	169813	0	323	\N	12458	t	0
306	\\xfd729766a52f6341b9569d7898e6f88dc519d2e3f5281453cf48e61679ce5fac	1102	1	9490561	169813	0	323	\N	12458	t	0
307	\\x8e86937947d4647a9e8af0d1f95e8df0bec803ca74f512c02ff12046618cdb98	1102	2	312870911044	168405	0	291	\N	12458	t	0
308	\\x5da75beb6a688cc84c3603a50305b86a872a7ca905269f7cd33e3f1102c7a046	1102	3	625773850515	168405	0	291	\N	12458	t	0
309	\\x0ebb5b10b893f0cfa578eddfaca816018683b70c51b29453fbb5e92dc0a895ec	1102	4	9830187	169813	0	323	\N	12462	t	0
310	\\xc73207fb1126993ad2ef0795d82bc0cf0e64b33ddc68394828080d1f444019f9	1103	0	9490561	169813	0	323	\N	12462	t	0
311	\\x06460343749b352ef3e3541f5f5023de4f14125b81908df838c161112e247038	1103	1	9660374	169813	0	323	\N	12462	t	0
312	\\x34e98b662af9f835867e85cb9eb695cba22682a5a7de4edd7df175e4f7df4117	1103	2	9490561	169813	0	323	\N	12462	t	0
313	\\xfc5bbc538e1afe7a75be18ac36d772dcb274002cb49266ed5e23dc58ec213f03	1103	3	39105380007	169989	0	327	\N	12463	t	0
314	\\xe591ab957db12d7179055ed395be9404e8edff48daf1da199426cab6925b97a7	1103	4	9150935	169813	0	323	\N	12463	t	0
315	\\x4ce46185bc7f1279643e0443a1dfdcfca7b77818b1ec085ca91a963ab3ea5489	1103	5	39110718402	168405	0	291	\N	12463	t	0
316	\\x84fd6105ae3089f9928b748e1e05be6eb3cd6294d5ef68d37afc2e457980da58	1103	6	8981122	169813	0	323	\N	12463	t	0
317	\\x600328ec4f870828140db381b519f58e88b186c06824a5aecf8e4c9d3cf2dde2	1103	7	9490561	169813	0	323	\N	12463	t	0
318	\\x7794cd3f9ef9eb84238812504337507ae7f7063e8ceb03c8c8d78c24ae6299c8	1103	8	9830187	169813	0	323	\N	12463	t	0
319	\\xad14f1d4a86ca32b56d4dd1ab0f608b8f572dc77f887b9ce690993de9d45930e	1103	9	1251543041009	168405	0	291	\N	12463	t	0
320	\\xe1c1d52110dafe1340422b7890ce08c6962222e90baf46b88ca950cb37aae96c	1103	10	39110548413	169989	0	327	\N	12463	t	0
321	\\x8023ab41e1fc303b5f727f1d34981babb1accaf5fdb8796465dc39bf573eb2f2	1103	11	625763683694	168405	0	291	\N	12463	t	0
322	\\x81894dc58dede6d06be21db8fdad25009c1a532abd16a53f73d25f6e12525de7	1103	12	1251537872604	168405	0	291	\N	12463	t	0
323	\\x018bfee3621caf50217acb3a48fba1b6cbee21542a192f348632d08207ffdc9e	1103	13	9660374	169813	0	323	\N	12463	t	0
324	\\x277f15324d1a0cdf1a8dda477a1d18382afcd27d8b3ef1a7bc10e5681b0c7d46	1103	14	9660374	169813	0	323	\N	12463	t	0
325	\\x2a518530d4ca8057db61b74f0cc6cfdcb45cf91296bbfc57980c6323163d5d08	1103	15	9830187	169813	0	323	\N	12463	t	0
326	\\x46b53d3c84484d9f6c278ca7ecf3ec710eb2daef0196ab7ef629057dcee79d4e	1103	16	312865742639	168405	0	291	\N	12463	t	0
327	\\x09a819260edb259941bc23071f96325d0317baff78c8a144ebcc26ff8ed60b59	1103	17	312881757645	168405	0	291	\N	12463	t	0
328	\\xe81c281bd78662e519e6e2f3f127eb55176d20e07bde9166b5d7ce7261f8f666	1103	18	625773340900	169989	0	327	\N	12463	t	0
329	\\x0134e7a2be268cc89428de54833a6c3c928bd58b57b4581307755949c3e78f0f	1103	19	9660374	169813	0	323	\N	12463	t	0
330	\\x95d0dde5bc6c3a7174c87159891526e3d9c66cbd18f8b8c08ec07db73d092526	1103	20	9830187	169813	0	323	\N	12463	t	0
331	\\x1882531fe38e0fbf0e631261be27651030a9dc8d648864e86ecd0891e22cf99c	1103	21	39105549997	168405	0	291	\N	12463	t	0
332	\\x415969c7e4f279ff4f3eb7c4154d51790b6faabce187ff0b2f94143a20d12562	1103	22	9150935	169813	0	323	\N	12463	t	0
333	\\x56239b3757295657379f4d837e62d7d8cfaa347f1bbfb1ac09dbe43ff8138788	1103	23	9660374	169813	0	323	\N	12463	t	0
334	\\xbf9df24b666024cecafe236a27a971c2cae9b551a1932e597142b1f7c750a1d2	1103	24	78205760016	168405	0	291	\N	12463	t	0
335	\\xd7b5da79f2a766eab14d071eb84e12823efdb8b9f3cd6c53c4bca123c000a950	1103	25	39105210195	169989	0	327	\N	12463	t	0
336	\\x9f7d05290dc30cff82a26a613a10bee2a866aa4bdb106176989ca8ba53085fed	1103	26	9830187	169813	0	323	\N	12463	t	0
337	\\x66c593051e5a2d90552030459c07f82f1dfdf8901f6e4eebd6f25b83112b909c	1103	27	9830187	169813	0	323	\N	12463	t	0
338	\\x0562bb0b9e6723484730506a53d40d6becde0a94c671735f2ac3f278c0dfa261	1103	28	9660374	169813	0	323	\N	12463	t	0
339	\\xcc5ead67d9a03a6fbb96b22a0861354091b160cd09990d0a0f5e6d169b303225	1103	29	9490561	169813	0	323	\N	12463	t	0
340	\\xd1fd32fc238a6bd85cdc2dbd48fb7727aed20d3e5a54dff4871ad38f6a8c11cc	1103	30	625768172495	168405	0	291	\N	12463	t	0
341	\\x8effc2e592df0f7a4c7645d219c2aeb82bc0ccdbab589bbb6636f5b1499f9b90	1103	31	39105040206	169989	0	327	\N	12463	t	0
342	\\x9f538e04f3fe07a1796ab7427b7486af9e62912603ff8cdb6ca8b2bdd39b06c1	1103	32	8471683	169813	0	323	\N	12463	t	0
343	\\xf210d1e8dc80842e41a0b6dedb6d0ff4e1d50c39cc2d191e568f4ea5b5fce54a	1103	33	9830187	169813	0	323	\N	12463	t	0
344	\\xd36f5ae9bc204760abadd49c24f857631c69368d68b4c89ac0548dd1d8d0baf4	1103	34	9830187	169813	0	323	\N	12463	t	0
345	\\xde1d5a3e9385ae71d5af78997a2db2cb4cba689c86152e4a7e21e381eb577ec9	1103	35	39100211602	168405	0	291	\N	12463	t	0
346	\\x30cc30a48d1813fc25acf89e436c75091ed7ff9d331510bab2111bf52bfa8e85	1103	36	9830187	169813	0	323	\N	12463	t	0
347	\\x57bac3a2217e89fd706c16d29b61b1a1354ac63d1a61d7bb30c9a603ffea9bdb	1103	37	78200591611	168405	0	291	\N	12463	t	0
348	\\x706ad4696e6cdab8c3a6ba889c191f57bc73a615e85e3f66780506da3e965f39	1103	38	78195423206	168405	0	291	\N	12463	t	0
349	\\x3299ed83831091807a1b83c4d0e34190e328ef471cc9ebe33861cebc4b21ecee	1103	39	9150935	169813	0	323	\N	12463	t	0
350	\\x71d8e80be0118d333db40c6ad5b77c779ea1883962d04d2fb629bd81ed7c4954	1103	40	9660374	169813	0	323	\N	12463	t	0
351	\\x6cff514b7dc0e46fdd19b1a70b32a205915cb0c491e994db45d96729a0b0896c	1103	41	9660374	169813	0	323	\N	12463	t	0
352	\\x6b0a68ddba4ace88e65256abb453a77f34fee0261c42a5e46b791818493c1c5d	1103	42	9490561	169813	0	323	\N	12463	t	0
353	\\xc949235b42bb23c4b95761d3514da7d3040ed5816f11ca9e0bb069a359c1f7c1	1103	43	9490561	169813	0	323	\N	12463	t	0
354	\\x3cc468122957cd3597ef866674255a288b1279a05cf4089a3b8a715a5a445fe1	1103	44	39100381591	168405	0	291	\N	12463	t	0
355	\\x4ecb5ea2ad408d381f31446851acb23cfa136e2636fbff52efc0502a36ec838d	1103	45	8132057	169813	0	323	\N	12463	t	0
356	\\xd81adc50cd49446f6f33d62ba7280b0ab10e3c02d1b153b05ab91d3e5e09b2b8	1293	0	15737687854	180725	0	571	\N	14447	t	0
357	\\x0264714424b5af707b504035475be93b97cde7c5b39373af961b5ef291ff4de2	1298	0	1269324483365	234845	0	1700	\N	14464	t	0
358	\\x46c35a329c73ee55bef815ca7b2269fee6a832d4d623617903fbf880ef258137	1305	0	4999999820111	179889	0	552	\N	14536	t	0
359	\\x576ed772c2ff7700d72fcb858577018de6e9e32a1cc5bbab0f31fde782deffcb	1309	0	4999996650122	169989	0	327	\N	14602	t	0
360	\\x9f6c9b2a3f796e676e33e617e9b95f3540ee963a82c7304b1dfd20b4fe0250a6	1314	0	5822839	177161	0	490	\N	14655	t	0
361	\\xfbd04436b0d1437ade84853696969640a6906c52e90e60c36b6008d21708b7c1	1318	0	4999999820287	179713	0	548	\N	14707	t	0
362	\\x03fa14e2901f0f72e0a7de40d24942bf6fdddf5469737b2d2aba5d391c059ee1	1322	0	9826447	173553	0	408	\N	14758	t	0
363	\\xcd0fdd603e46f9b6a4fdc020532a5a90108303b3d6c24e807d28e8fcc38bfb80	1326	0	6647130	179317	0	539	\N	14781	t	0
\.


--
-- Data for Name: tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_in (id, tx_in_id, tx_out_id, tx_out_index, redeemer_id) FROM stdin;
1	35	18	0	\N
2	36	35	1	\N
3	37	36	0	\N
4	38	19	0	\N
5	39	38	0	\N
6	40	37	0	\N
7	41	40	1	\N
8	42	41	0	\N
9	43	13	0	\N
10	44	43	0	\N
11	45	42	0	\N
12	46	45	1	\N
13	47	46	0	\N
14	48	26	0	\N
15	49	48	0	\N
16	50	47	0	\N
17	51	50	1	\N
18	52	51	0	\N
19	53	25	0	\N
20	54	53	0	\N
21	55	52	0	\N
22	56	55	1	\N
23	57	56	0	\N
24	58	27	0	\N
25	59	58	0	\N
26	60	57	0	\N
27	61	60	1	\N
28	62	61	0	\N
29	63	23	0	\N
30	64	63	0	\N
31	65	62	0	\N
32	66	65	1	\N
33	67	66	0	\N
34	68	29	0	\N
35	69	68	0	\N
36	70	67	0	\N
37	71	70	1	\N
38	72	71	0	\N
39	73	28	0	\N
40	74	73	0	\N
41	75	74	0	\N
42	76	72	0	\N
43	77	76	0	\N
44	78	77	1	\N
45	79	78	0	\N
46	80	31	0	\N
47	81	80	0	\N
48	82	81	0	\N
49	83	79	0	\N
50	84	83	0	\N
51	85	84	1	\N
52	86	85	0	\N
53	87	21	0	\N
54	88	87	0	\N
55	89	88	0	\N
56	90	86	0	\N
57	91	90	0	\N
58	92	91	1	\N
59	93	92	0	\N
60	94	14	0	\N
61	95	94	0	\N
62	96	95	0	\N
63	97	93	0	\N
64	98	20	0	\N
65	99	98	0	1
66	100	98	1	\N
67	101	100	1	\N
68	102	101	1	\N
69	103	102	1	\N
70	104	103	1	\N
71	105	104	1	\N
72	106	105	0	2
73	106	105	1	\N
74	107	15	0	\N
75	108	97	0	\N
76	109	108	0	\N
77	110	109	1	\N
78	111	110	1	\N
79	112	111	0	\N
80	112	111	1	\N
81	113	112	1	\N
82	114	113	1	\N
83	115	112	0	\N
84	116	114	0	\N
85	117	116	0	\N
86	117	116	1	\N
87	118	117	0	\N
88	118	117	1	\N
89	119	118	0	\N
90	120	119	0	\N
91	121	120	0	\N
92	121	119	1	\N
93	122	121	0	\N
94	123	122	0	\N
96	125	121	1	\N
97	126	125	0	\N
98	126	125	1	\N
99	127	126	0	\N
100	127	123	0	\N
101	128	126	1	\N
102	129	127	0	\N
103	129	128	0	\N
104	130	129	0	\N
105	130	129	1	\N
106	130	128	1	\N
107	131	130	0	\N
108	131	127	1	\N
109	132	131	0	\N
110	133	132	0	\N
111	133	132	1	\N
112	133	132	2	\N
113	133	132	3	\N
114	133	132	4	\N
115	133	132	5	\N
116	133	132	6	\N
117	133	132	7	\N
118	133	132	8	\N
119	133	132	9	\N
120	133	132	10	\N
121	133	132	11	\N
122	133	132	12	\N
123	133	132	13	\N
124	133	132	14	\N
125	133	132	15	\N
126	133	132	16	\N
127	133	132	17	\N
128	133	132	18	\N
129	133	132	19	\N
130	133	132	20	\N
131	133	132	21	\N
132	133	132	22	\N
133	133	132	23	\N
134	133	132	24	\N
135	133	132	25	\N
136	133	132	26	\N
137	133	132	27	\N
138	133	132	28	\N
139	133	132	29	\N
140	133	132	30	\N
141	133	132	31	\N
142	133	132	32	\N
143	133	132	33	\N
144	133	132	34	\N
145	134	133	0	\N
146	135	131	1	\N
147	136	135	0	\N
148	137	136	0	\N
149	137	135	1	\N
150	138	137	0	\N
151	139	137	1	\N
152	139	138	0	\N
153	140	139	0	\N
154	140	139	1	\N
155	141	140	0	\N
156	142	141	0	\N
157	142	141	1	\N
158	142	141	2	\N
159	142	141	3	\N
160	142	141	4	\N
161	142	141	5	\N
162	142	141	6	\N
163	142	141	7	\N
164	142	141	8	\N
165	142	141	9	\N
166	142	141	10	\N
167	142	141	11	\N
168	142	141	12	\N
169	142	141	13	\N
170	142	141	14	\N
171	142	141	15	\N
172	142	141	16	\N
173	142	141	17	\N
174	142	141	18	\N
175	142	141	19	\N
176	142	141	20	\N
177	142	141	21	\N
178	142	141	22	\N
179	142	141	23	\N
180	142	141	24	\N
181	142	141	25	\N
182	142	141	26	\N
183	142	141	27	\N
184	142	141	28	\N
185	142	141	29	\N
186	142	141	30	\N
187	142	141	31	\N
188	142	141	32	\N
189	142	141	33	\N
190	142	141	34	\N
191	142	141	35	\N
192	142	141	36	\N
193	142	141	37	\N
194	142	141	38	\N
195	142	141	39	\N
196	142	141	40	\N
197	142	141	41	\N
198	142	141	42	\N
199	142	141	43	\N
200	142	141	44	\N
201	142	141	45	\N
202	142	141	46	\N
203	142	141	47	\N
204	142	141	48	\N
205	142	141	49	\N
206	142	141	50	\N
207	142	141	51	\N
208	142	141	52	\N
209	142	141	53	\N
210	142	141	54	\N
211	142	141	55	\N
212	142	141	56	\N
213	142	141	57	\N
214	142	141	58	\N
215	142	141	59	\N
216	143	141	100	\N
217	144	141	65	\N
218	145	143	0	\N
219	145	143	1	\N
220	145	141	60	\N
221	145	141	61	\N
222	145	141	62	\N
223	145	141	63	\N
224	145	141	64	\N
225	145	141	66	\N
226	145	141	67	\N
227	145	141	68	\N
228	145	141	69	\N
229	145	141	70	\N
230	145	141	71	\N
231	145	141	72	\N
232	145	141	73	\N
233	145	141	74	\N
234	145	141	75	\N
235	145	141	76	\N
236	145	141	77	\N
237	145	141	78	\N
238	145	141	79	\N
239	145	141	80	\N
240	145	141	81	\N
241	145	141	82	\N
242	145	141	83	\N
243	145	141	84	\N
244	145	141	85	\N
245	145	141	86	\N
246	145	141	87	\N
247	145	141	88	\N
248	145	141	89	\N
249	145	141	90	\N
250	145	141	91	\N
251	145	141	92	\N
252	145	141	93	\N
253	145	141	94	\N
254	145	141	95	\N
255	145	141	96	\N
256	145	141	97	\N
257	145	141	98	\N
258	145	141	99	\N
259	145	141	101	\N
260	145	141	102	\N
261	145	141	103	\N
262	145	141	104	\N
263	145	141	105	\N
264	145	141	106	\N
265	145	141	107	\N
266	145	141	108	\N
267	145	141	109	\N
268	145	141	110	\N
269	145	141	111	\N
270	145	141	112	\N
271	145	141	113	\N
272	145	141	114	\N
273	145	141	115	\N
274	145	141	116	\N
275	145	141	117	\N
276	145	141	118	\N
277	145	141	119	\N
278	145	142	0	\N
279	145	144	0	\N
280	145	144	1	\N
281	145	140	1	\N
282	146	145	0	\N
283	146	145	1	\N
284	147	146	1	\N
285	148	147	0	\N
287	150	146	0	\N
288	151	147	1	\N
289	152	150	1	\N
290	153	151	0	\N
291	154	153	0	\N
292	155	154	0	\N
293	155	152	1	\N
294	156	154	1	\N
295	156	155	0	\N
296	157	155	1	\N
297	157	156	0	\N
298	158	156	1	\N
299	159	157	1	\N
300	159	158	0	\N
301	160	159	0	\N
302	160	159	1	\N
303	161	157	0	\N
304	161	158	1	\N
305	162	161	1	\N
306	162	160	1	\N
307	163	162	1	\N
308	164	161	0	\N
309	164	163	0	\N
310	165	160	0	\N
311	165	164	0	\N
312	166	165	0	\N
313	166	162	0	\N
314	167	163	1	\N
315	167	165	1	\N
316	168	167	0	\N
317	168	166	1	\N
318	169	168	0	\N
319	169	166	0	\N
320	170	168	1	\N
321	170	169	0	\N
322	171	164	1	\N
323	171	170	0	\N
324	172	167	1	\N
325	172	170	1	\N
326	173	172	1	\N
327	174	173	1	\N
328	175	171	1	\N
329	175	174	0	\N
330	176	172	0	\N
331	176	175	1	\N
332	177	171	0	\N
333	177	175	0	\N
334	178	173	0	\N
335	178	169	1	\N
336	179	178	0	\N
337	179	176	0	\N
338	180	176	1	\N
339	180	179	1	\N
340	181	178	1	\N
341	181	177	0	\N
342	182	181	1	\N
343	182	174	1	\N
344	183	180	0	\N
345	183	182	0	\N
346	184	179	0	\N
347	184	177	1	\N
348	185	183	0	\N
349	185	184	1	\N
350	186	185	1	\N
351	186	184	0	\N
352	187	180	1	\N
353	187	186	1	\N
354	188	181	0	\N
355	188	187	1	\N
356	189	188	1	\N
357	189	187	0	\N
358	190	188	0	\N
359	190	182	1	\N
360	191	186	0	\N
361	191	183	1	\N
362	192	190	1	\N
363	192	191	0	\N
364	193	192	0	\N
365	193	189	1	\N
366	194	193	1	\N
367	194	189	0	\N
368	194	191	1	\N
369	195	193	0	\N
370	195	190	0	\N
371	196	194	0	\N
372	196	194	1	\N
373	197	196	1	\N
374	198	195	1	\N
375	198	196	0	\N
376	199	198	1	\N
377	199	197	0	\N
378	200	195	0	\N
379	200	199	1	\N
380	201	192	1	\N
381	201	200	1	\N
382	202	185	0	\N
383	202	201	0	\N
384	203	199	0	\N
385	203	197	1	\N
386	204	202	1	\N
387	204	198	0	\N
388	205	203	0	\N
389	205	203	1	\N
390	205	204	1	\N
391	206	201	1	\N
392	207	206	1	\N
393	208	202	0	\N
394	208	207	1	\N
395	209	208	0	\N
396	209	207	0	\N
397	210	205	0	\N
398	210	204	0	\N
399	211	205	1	\N
400	211	210	0	\N
401	212	206	0	\N
402	212	210	1	\N
403	213	209	0	\N
404	213	212	1	\N
405	214	200	0	\N
406	214	209	1	\N
407	215	211	1	\N
408	215	213	0	\N
409	216	214	0	\N
410	216	214	1	\N
411	217	216	0	\N
412	217	213	1	\N
413	218	216	1	\N
414	218	212	0	\N
415	219	218	0	\N
416	219	218	1	\N
417	220	219	1	\N
418	220	211	0	\N
419	221	215	0	\N
420	221	220	1	\N
421	222	219	0	\N
422	222	221	0	\N
423	223	222	1	\N
424	223	215	1	\N
425	224	208	1	\N
426	225	217	0	\N
427	225	220	0	\N
428	226	221	1	\N
429	226	224	0	\N
430	227	226	1	\N
431	227	224	1	\N
432	228	217	1	\N
433	228	227	1	\N
434	229	228	0	\N
435	229	223	1	\N
436	230	226	0	\N
437	230	227	0	\N
438	231	225	1	\N
439	231	230	1	\N
440	232	223	0	\N
441	232	230	0	\N
442	233	231	1	\N
443	233	225	0	\N
444	234	228	1	\N
445	235	232	1	\N
446	235	233	1	\N
447	236	234	1	\N
448	237	233	0	\N
449	237	234	0	\N
450	238	235	0	\N
451	238	231	0	\N
452	239	236	0	\N
453	239	238	0	\N
454	240	237	0	\N
455	240	237	1	\N
456	241	232	0	\N
457	241	229	1	\N
458	242	235	1	\N
459	242	241	0	\N
460	243	242	0	\N
461	243	239	1	\N
462	244	243	1	\N
463	244	240	0	\N
464	245	236	1	\N
465	246	243	0	\N
466	246	240	1	\N
467	247	222	0	\N
468	247	245	0	\N
469	248	238	1	\N
470	248	244	0	\N
471	249	242	1	\N
472	249	241	1	\N
473	250	249	1	\N
474	250	239	0	\N
475	251	246	0	\N
476	251	249	0	\N
477	252	251	0	\N
478	252	244	1	\N
479	253	252	1	\N
480	253	247	0	\N
481	254	229	0	\N
482	255	246	1	\N
483	255	254	0	\N
484	255	254	1	\N
485	255	252	0	\N
486	255	248	0	\N
487	255	248	1	\N
488	255	251	1	\N
489	255	245	1	\N
490	255	253	0	\N
491	255	253	1	\N
492	255	250	0	\N
493	255	250	1	\N
494	255	247	1	\N
495	256	255	0	\N
496	257	255	12	\N
497	258	255	9	\N
498	259	255	13	\N
499	260	259	1	\N
500	261	255	8	\N
501	261	257	0	\N
502	262	255	3	\N
503	263	255	7	\N
504	264	259	0	\N
505	264	261	0	\N
506	265	262	0	\N
507	265	261	1	\N
508	266	265	1	\N
509	267	256	1	\N
510	268	258	1	\N
511	269	263	1	\N
512	270	269	1	\N
513	271	266	0	\N
514	271	265	0	\N
515	272	255	10	\N
516	273	267	1	\N
517	274	255	4	\N
518	275	258	0	\N
519	275	263	0	\N
520	276	269	0	\N
521	276	271	1	\N
522	277	256	0	\N
523	277	255	2	\N
524	278	255	5	\N
525	279	262	1	\N
526	280	255	1	\N
527	281	279	0	\N
528	281	270	1	\N
529	282	267	0	\N
530	282	270	0	\N
531	283	266	1	\N
532	284	275	1	\N
533	284	273	0	\N
534	285	272	0	\N
535	285	284	0	\N
536	286	278	1	\N
537	287	277	0	\N
538	287	281	1	\N
539	288	264	0	\N
540	288	276	0	\N
541	289	282	0	\N
542	289	280	0	\N
543	290	287	1	\N
544	291	286	1	\N
545	291	287	0	\N
546	292	274	0	\N
547	292	290	0	\N
548	293	289	1	\N
549	293	291	1	\N
550	294	293	0	\N
551	294	289	0	\N
552	295	255	6	\N
553	295	292	1	\N
554	296	278	0	\N
555	296	271	0	\N
556	297	281	0	\N
557	297	285	0	\N
558	298	283	1	\N
559	299	275	0	\N
560	299	298	0	\N
561	300	299	0	\N
562	300	294	0	\N
563	301	293	1	\N
564	302	273	1	\N
565	303	301	0	\N
566	303	300	0	\N
567	304	257	1	\N
568	305	299	1	\N
569	305	286	0	\N
570	306	305	1	\N
571	306	304	0	\N
572	307	301	1	\N
573	308	277	1	\N
574	309	303	0	\N
575	309	292	0	\N
576	310	288	1	\N
577	310	296	1	\N
578	311	295	0	\N
579	311	294	1	\N
580	312	307	0	\N
581	312	276	1	\N
582	313	260	1	\N
583	313	310	0	\N
584	314	264	1	\N
585	314	312	1	\N
586	315	255	11	\N
587	316	297	0	\N
588	316	314	1	\N
589	317	311	1	\N
590	317	296	0	\N
591	318	315	0	\N
592	318	316	0	\N
593	319	280	1	\N
594	320	288	0	\N
595	320	272	1	\N
596	321	279	1	\N
597	322	319	1	\N
598	323	311	0	\N
599	323	282	1	\N
600	324	317	0	\N
601	324	297	1	\N
602	325	309	0	\N
603	325	321	0	\N
604	326	307	1	\N
605	327	274	1	\N
606	328	308	1	\N
607	328	284	1	\N
608	329	323	0	\N
609	329	318	1	\N
610	330	318	0	\N
611	330	328	0	\N
612	331	315	1	\N
613	332	317	1	\N
614	332	285	1	\N
615	333	327	0	\N
616	333	330	1	\N
617	334	298	1	\N
618	335	331	1	\N
619	335	300	1	\N
620	336	334	0	\N
621	336	320	0	\N
622	337	324	0	\N
623	337	306	0	\N
624	338	331	0	\N
625	338	336	1	\N
626	339	260	0	\N
627	339	333	1	\N
628	340	328	1	\N
629	341	335	1	\N
630	341	313	0	\N
631	342	324	1	\N
632	342	316	1	\N
633	343	302	0	\N
634	343	339	0	\N
635	344	329	0	\N
636	344	336	0	\N
637	345	313	1	\N
638	346	342	0	\N
639	346	319	0	\N
640	347	334	1	\N
641	348	347	1	\N
642	349	309	1	\N
643	349	306	1	\N
644	350	346	0	\N
645	350	337	1	\N
646	351	346	1	\N
647	351	312	0	\N
648	352	329	1	\N
649	352	340	0	\N
650	353	323	1	\N
651	353	283	0	\N
652	354	304	1	\N
653	355	349	1	\N
654	355	332	1	\N
655	356	268	0	\N
656	357	302	1	\N
657	358	108	2	\N
658	359	358	1	\N
659	360	358	0	\N
660	360	359	0	\N
661	361	108	4	\N
662	362	107	0	\N
663	363	362	1	\N
\.


--
-- Data for Name: tx_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_metadata (id, key, json, bytes, tx_id) FROM stdin;
1	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "TestHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "TestHandle", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": "ipfs://some-hash", "website": "https://cardano.org/", "mediaType": "image/jpeg", "description": "The Handle Standard", "augmentations": []}, "HelloHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "HelloHandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "DoubleHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "DoubleHandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a460a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656067776562736974657468747470733a2f2f63617264616e6f2e6f72672f6c446f75626c6548616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656c446f75626c6548616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6b48656c6c6f48616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656b48656c6c6f48616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6a5465737448616e646c65a86d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e646172646566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e7965696d61676570697066733a2f2f736f6d652d68617368696d65646961547970656a696d6167652f6a706567646e616d656a5465737448616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f	109
2	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	111
3	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	116
4	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	117
5	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	119
6	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	121
8	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"NFT-001": {"name": "One", "image": ["ipfs://some_hash1"], "version": "1.0"}, "NFT-002": {"name": "Two", "image": ["ipfs://some_hash2"], "version": "1.0"}, "NFT-files": {"id": "1", "name": "NFT with files", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": ["ipfs://somehash"], "version": "1.0", "mediaType": "image/png", "description": ["NFT with different types of files"]}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a3674e46542d303031a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65634f6e656776657273696f6e63312e30674e46542d303032a365696d6167658171697066733a2f2f736f6d655f6861736832646e616d656354776f6776657273696f6e63312e30694e46542d66696c6573a76b6465736372697074696f6e8178214e4654207769746820646966666572656e74207479706573206f662066696c65736566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e79626964613165696d616765816f697066733a2f2f736f6d6568617368696d656469615479706569696d6167652f706e67646e616d656e4e465420776974682066696c65736776657273696f6e63312e30	125
9	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"4349502d303032352d76312d686578": {"name": "CIP-0025-v1-hex", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1781e343334393530326433303330333233353264373633313264363836353738a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656f4349502d303032352d76312d6865786776657273696f6e63312e30	127
10	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"CIP-0025-v1-utf8": {"name": "CIP-0025-v1-utf8", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1704349502d303032352d76312d75746638a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65704349502d303032352d76312d757466386776657273696f6e63312e30	128
11	721	{"0x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"0x4349502d303032352d7632": {"name": "CIP-0025-v2", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a1581c17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029a14b4349502d303032352d7632a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656b4349502d303032352d76326776657273696f6e63312e30	129
12	6862	{"name": "Test Portfolio", "pools": [{"id": "f2fd1765572b452dbeff87faaebf86c021c10c8d4b18cd3d0c635671", "weight": 1}, {"id": "8a035ddd247d1d47816e812d0907b3111dc80b848b5bcb384cfd58f2", "weight": 1}, {"id": "c4e628589a0e0733a05dad56f9dcbaf40b2e368002c294cd0a2ffcb3", "weight": 1}, {"id": "e31012824263d20c391ca123162e2299b52b16f331d1ccfe3871723d", "weight": 1}, {"id": "6854ad6d9787295c6a4bed34a7eb847420b1095345bb343ca7fb222b", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783866326664313736353537326234353264626566663837666161656266383663303231633130633864346231386364336430633633353637316677656967687401a2626964783838613033356464643234376431643437383136653831326430393037623331313164633830623834386235626362333834636664353866326677656967687401a2626964783863346536323835383961306530373333613035646164353666396463626166343062326533363830303263323934636430613266666362336677656967687401a2626964783865333130313238323432363364323063333931636131323331363265323239396235326231366633333164316363666533383731373233646677656967687401a2626964783836383534616436643937383732393563366134626564333461376562383437343230623130393533343562623334336361376662323232626677656967687401	132
13	6862	{"name": "Test Portfolio", "pools": [{"id": "f2fd1765572b452dbeff87faaebf86c021c10c8d4b18cd3d0c635671", "weight": 0}, {"id": "8a035ddd247d1d47816e812d0907b3111dc80b848b5bcb384cfd58f2", "weight": 0}, {"id": "c4e628589a0e0733a05dad56f9dcbaf40b2e368002c294cd0a2ffcb3", "weight": 0}, {"id": "e31012824263d20c391ca123162e2299b52b16f331d1ccfe3871723d", "weight": 0}, {"id": "6854ad6d9787295c6a4bed34a7eb847420b1095345bb343ca7fb222b", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783866326664313736353537326234353264626566663837666161656266383663303231633130633864346231386364336430633633353637316677656967687400a2626964783838613033356464643234376431643437383136653831326430393037623331313164633830623834386235626362333834636664353866326677656967687400a2626964783863346536323835383961306530373333613035646164353666396463626166343062326533363830303263323934636430613266666362336677656967687400a2626964783865333130313238323432363364323063333931636131323331363265323239396235326231366633333164316363666533383731373233646677656967687400a2626964783836383534616436643937383732393563366134626564333461376562383437343230623130393533343562623334336361376662323232626677656967687401	133
14	123	"1234"	\\xa1187b6431323334	143
16	6862	{"pools": [{"id": "8a035ddd247d1d47816e812d0907b3111dc80b848b5bcb384cfd58f2", "weight": 1}]}	\\xa1191acea165706f6f6c7381a2626964783838613033356464643234376431643437383136653831326430393037623331313164633830623834386235626362333834636664353866326677656967687401	150
17	6862	{"name": "Test Portfolio", "pools": [{"id": "f2fd1765572b452dbeff87faaebf86c021c10c8d4b18cd3d0c635671", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7381a2626964783866326664313736353537326234353264626566663837666161656266383663303231633130633864346231386364336430633633353637316677656967687401	153
18	6862	{"name": "Test Portfolio", "pools": [{"id": "f2fd1765572b452dbeff87faaebf86c021c10c8d4b18cd3d0c635671", "weight": 1}, {"id": "8a035ddd247d1d47816e812d0907b3111dc80b848b5bcb384cfd58f2", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7382a2626964783866326664313736353537326234353264626566663837666161656266383663303231633130633864346231386364336430633633353637316677656967687401a2626964783838613033356464643234376431643437383136653831326430393037623331313164633830623834386235626362333834636664353866326677656967687401	255
19	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	357
\.


--
-- Data for Name: tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_out (id, tx_id, index, address, address_raw, address_has_script, payment_cred, stake_address_id, value, data_hash, inline_datum_id, reference_script_id) FROM stdin;
1	1	0	5oP9ib6ym3XXza9agi2on59EQQCiAv4wjaBereGY1nba7b99TucXSHafMjsq4rhXwD	\\x82d818582683581c086e7daf44621b8c537b4a52542edf7491d5aea45967cd4ba96419eea10243190378001a7acaf8b0	f	\N	\N	910909092	\N	\N	\N
2	2	0	5oP9ib6ym3XY9jq8S8wA9JNftssA4UGciNoA3Si4onUXn73dNnTYTzLTh7aqCQaa1N	\\x82d818582683581c0b9ccc96e610899f6d45d006025762d585923bb39a1302e4f8b1fb98a10243190378001aa283f7b1	f	\N	\N	910909092	\N	\N	\N
3	3	0	5oP9ib6ym3XZLGPW3EpJYyy7hAJAXS7gCG69j5VSof828jKWj5bjB8WZDM9RUDQrWB	\\x82d818582683581c23641d7447025ee8caa886ae3ade9b33fc994b524086346bae69c70ba10243190378001a414636b8	f	\N	\N	910909092	\N	\N	\N
4	4	0	5oP9ib6ym3XZQotpfVx5KeyjiS4x8xZKuLyT88XrCEt2xiaYeSUFXZq5U5ySYxrhEB	\\x82d818582683581c24f7b13e11e8c69377293a4da2910c0e7b66215e4c2687728bdb4a5da10243190378001a7521d954	f	\N	\N	910909092	\N	\N	\N
5	5	0	5oP9ib6ym3XazgrK5A5WWLCUnaRwpdbQS6LCmBNUUZUqveK2YxVk91xBqBDR1dq33P	\\x82d818582683581c44d95d766a70b666daf0af888aa98405df61c1e4533f4009ea8b422aa10243190378001acbe6d692	f	\N	\N	910909092	\N	\N	\N
6	6	0	5oP9ib6ym3XdYRBTHDSF3zC5MZP2o9mmFog6nYSFpxXZNcTi5YY2NonU4Qv8tQwPZX	\\x82d818582683581c781c5dc683db3c2053b7cb7056083df4d93d089d45069b4e0c2512faa10243190378001a34c37976	f	\N	\N	910909092	\N	\N	\N
7	7	0	5oP9ib6ym3XfTY9cqA4QxjtJKJsaSvMj3udfRjEUdYUbGaPR7SdFYqtMKW82Gdq8bf	\\x82d818582683581c9eab4a1d2d0d6303699a1fa0dd4f37fc0414ba00a5eedcec0a12d380a10243190378001ae4950eb6	f	\N	\N	910909092	\N	\N	\N
8	8	0	5oP9ib6ym3XfVZqNnTjGVNDxAUeMCSrspF933R1hyTdpym96zg1oYUrQRrcpYod8XW	\\x82d818582683581c9f5f887a13b743313f7795fe4bb536f1a6434ace414d60c3d783a2d7a10243190378001ab2d6b205	f	\N	\N	910909092	\N	\N	\N
9	9	0	5oP9ib6ym3XfaLXTCF7RGBxA1zcw1XXFD7GG1n5fht6M5rZaaFmahfdVRVkY6RZkpr	\\x82d818582683581ca1074e090378b2adec70879da95550adb5a1f30206052524a083e8b2a10243190378001aca5b4bc3	f	\N	\N	910909092	\N	\N	\N
10	10	0	5oP9ib6ym3XgKQyKPd1Ykc63iq5w9dTSbsVJKZUKYZA6BA8oJ9ymr93AwonpNqRsig	\\x82d818582683581caff9d9d2526b3d4c5ea720196733ec20e936f752f2db93e67976814aa10243190378001acc33c399	f	\N	\N	910909092	\N	\N	\N
11	11	0	5oP9ib6ym3Xk5s5N5oih4TtAoh7AkzhXX8oQ4zJ916PwWDFGcNQMAh9WJSp7WE1Q5k	\\x82d818582683581cfbc70223459143bbdc27acde1f67653d7e7b281b920656b0aa717ec1a10243190378001a3a5e863f	f	\N	\N	910909092	\N	\N	\N
12	12	0	addr_test1vq8444j2gqf8qlemz2k870yr7gsvay09wq64gdetg7c8j4sxuc6dx	\\x600f5ad64a4012707f3b12ac7f3c83f220ce91e5703554372b47b07956	f	\\x0f5ad64a4012707f3b12ac7f3c83f220ce91e5703554372b47b07956	\N	3681818181818181	\N	\N	\N
13	13	0	addr_test1qqc7fcdy5a54748v4fgvz98jeg5v3lky4pauph3492sq9tfwzvzh73s5py43l4khznr5q3s2kxlswxl3v5qes5xx3zrsswgh4u	\\x0031e4e1a4a7695f54ecaa50c114f2ca28c8fec4a87bc0de352aa002ad2e13057f4614092b1fd6d714c740460ab1bf071bf165019850c68887	f	\\x31e4e1a4a7695f54ecaa50c114f2ca28c8fec4a87bc0de352aa002ad	\N	3681818181818181	\N	\N	\N
14	14	0	addr_test1qp7g5nsg4wwe3z4l00mv4cng40j6x7rgwae9pyj7glmx3nvr20zttf79yw8fn98xd5cx4xtaxw0e4rx2az9y9nefd8gsfwm30p	\\x007c8a4e08ab9d988abf7bf6cae268abe5a37868777250925e47f668cd8353c4b5a7c5238e9994e66d306a997d339f9a8ccae88a42cf2969d1	f	\\x7c8a4e08ab9d988abf7bf6cae268abe5a37868777250925e47f668cd	\N	3681818181818190	\N	\N	\N
15	15	0	addr_test1vqg54jwdssqgx5g7jrevpktcahw8axe6vjvlth9j929vumchx3zmy	\\x60114ac9cd840083511e90f2c0d978eddc7e9b3a6499f5dcb22a8ace6f	f	\\x114ac9cd840083511e90f2c0d978eddc7e9b3a6499f5dcb22a8ace6f	\N	3681818181818181	\N	\N	\N
16	16	0	addr_test1vpuv796s6hsv3gc57dmhvh950wunad0gnjv8wz3n6hyt70se25n8h	\\x6078cf1750d5e0c8a314f377765cb47bb93eb5e89c98770a33d5c8bf3e	f	\\x78cf1750d5e0c8a314f377765cb47bb93eb5e89c98770a33d5c8bf3e	\N	3681818181818181	\N	\N	\N
17	17	0	addr_test1vz43h62m5297xyhnyee2ammsg4jqnke4az2ut8smm99mzfca8tr3e	\\x60ab1be95ba28be312f32672aeef70456409db35e895c59e1bd94bb127	f	\\xab1be95ba28be312f32672aeef70456409db35e895c59e1bd94bb127	\N	3681818181818181	\N	\N	\N
18	18	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681818181818181	\N	\N	\N
19	19	0	addr_test1qq76rxpehf5ecdacxkdwmphapdrnakf80vukq6730hxqtayhykj4rfxxtsn7a24sy674j5d60welwsu43g2mj4j9ctas5wflhd	\\x003da19839ba699c37b8359aed86fd0b473ed9277b39606bd17dcc05f49725a551a4c65c27eeaab026bd5951ba7bb3f743958a15b95645c2fb	f	\\x3da19839ba699c37b8359aed86fd0b473ed9277b39606bd17dcc05f4	\N	3681818181818181	\N	\N	\N
20	20	0	addr_test1vrdjw35y0mee0rlz0pm7s0c7upm0x7hqu8u26ey2q690y9sjrfkfk	\\x60db2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	f	\\xdb2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	\N	3681818181818181	\N	\N	\N
21	21	0	addr_test1qpvcpfpavmxe6dnw0cyltdraw07qzfmn0n8gs4xpjlzeaygznts3puuh5h5g62h0cjuqwvmkrkmhac59xgl8d2g564kqzzgymk	\\x005980a43d66cd9d366e7e09f5b47d73fc0127737cce8854c197c59e91029ae110f397a5e88d2aefc4b80733761db77ee285323e76a914d56c	f	\\x5980a43d66cd9d366e7e09f5b47d73fc0127737cce8854c197c59e91	\N	3681818181818181	\N	\N	\N
22	22	0	addr_test1vrngpc4sqgxl2s7xgnshjqz4e39egnhsylplepnm82gkvyq8wpely	\\x60e680e2b0020df543c644e1790055cc4b944ef027c3fc867b3a916610	f	\\xe680e2b0020df543c644e1790055cc4b944ef027c3fc867b3a916610	\N	3681818181818181	\N	\N	\N
23	23	0	addr_test1qqcnanagdmqh7v7eag7jj72ysg4ks20p9l8cwtunl5f4xup46kqqqgwv3n04hrqjuz4s8p8uj6wyxu00e9u5g6puqjfqak3h6v	\\x00313ecfa86ec17f33d9ea3d297944822b6829e12fcf872f93fd13537035d5800021cc8cdf5b8c12e0ab0384fc969c4371efc97944683c0492	f	\\x313ecfa86ec17f33d9ea3d297944822b6829e12fcf872f93fd135370	\N	3681818181818181	\N	\N	\N
24	24	0	addr_test1vzth5f4p93lv3zjmxxzansf6mecascgw2xc7ewupnu7r0dgukd2tz	\\x60977a26a12c7ec88a5b3185d9c13ade71d8610e51b1ecbb819f3c37b5	f	\\x977a26a12c7ec88a5b3185d9c13ade71d8610e51b1ecbb819f3c37b5	\N	3681818181818181	\N	\N	\N
25	25	0	addr_test1qrcy45vp00ruq9n935f2z4cqr3as9d6rfq3kx65arst0rz3u8n54ckahdgxvmfrua0knpxzc5yw7y5wtmnjglz0p0ges05qk7n	\\x00f04ad1817bc7c016658d12a157001c7b02b7434823636a9d1c16f18a3c3ce95c5bb76a0ccda47cebed309858a11de251cbdce48f89e17a33	f	\\xf04ad1817bc7c016658d12a157001c7b02b7434823636a9d1c16f18a	\N	3681818181818181	\N	\N	\N
26	26	0	addr_test1qzpdqc83lrupf5m5ye27e6qvjd24ehfl6dg9trusn75hmlmjrye38cz89hflcksvxprmxwjyx844qy7ulklr6pjrxkmqy2g0k3	\\x0082d060f1f8f814d3742655ece80c93555cdd3fd350558f909fa97dff72193313e0472dd3fc5a0c3047b33a4431eb5013dcfdbe3d064335b6	f	\\x82d060f1f8f814d3742655ece80c93555cdd3fd350558f909fa97dff	\N	3681818181818181	\N	\N	\N
27	27	0	addr_test1qzmk4652c76zss8kudmldgguvrz5p68t3fahrw3n3r59cynjfw8jqjmh6w2as4s6t22sntytgxqxj4qhwfch6xetvexs0ndqza	\\x00b76aea8ac7b42840f6e377f6a11c60c540e8eb8a7b71ba3388e85c12724b8f204b77d395d8561a5a9509ac8b418069541772717d1b2b664d	f	\\xb76aea8ac7b42840f6e377f6a11c60c540e8eb8a7b71ba3388e85c12	\N	3681818181818181	\N	\N	\N
28	28	0	addr_test1qql8u3725ygxpapdx24yvw680u89gdn4xy0n0s3ufq8umnxqdauaqpsu6tqyae2uz25mjsptn658nfdqtsq9lqumc84qyyza79	\\x003e7e47caa11060f42d32aa463b477f0e543675311f37c23c480fcdccc06f79d0061cd2c04ee55c12a9b9402b9ea879a5a05c005f839bc1ea	f	\\x3e7e47caa11060f42d32aa463b477f0e543675311f37c23c480fcdcc	\N	3681818181818181	\N	\N	\N
29	29	0	addr_test1qpygfw4f8fzun5ptwaev8ng2jarc9fv4w0jl8eh83fxm7luyjtq08mxwc24gwh9npr8uf7p906t7rxmr6z9jk0ywdenqnmlspw	\\x004884baa93a45c9d02b7772c3cd0a974782a59573e5f3e6e78a4dbf7f8492c0f3eccec2aa875cb308cfc4f8257e97e19b63d08b2b3c8e6e66	f	\\x4884baa93a45c9d02b7772c3cd0a974782a59573e5f3e6e78a4dbf7f	\N	3681818181818181	\N	\N	\N
30	30	0	addr_test1vq5ukq4tkd7ghn05x2wuger7a6fmkc6c8n4ex8z3xkjtqrgdh2a75	\\x6029cb02abb37c8bcdf4329dc4647eee93bb63583ceb931c5135a4b00d	f	\\x29cb02abb37c8bcdf4329dc4647eee93bb63583ceb931c5135a4b00d	\N	3681818181818190	\N	\N	\N
31	31	0	addr_test1qqzpp3ryjeceyeydcl8alm02xzex456cm0l5f6vh7fj004x9phmm2fm7zh25j0uxtpwth03jtqu264m2x6g6v4xmw53qa832k5	\\x000410c464967192648dc7cfdfedea30b26ad358dbff44e997f264f7d4c50df7b5277e15d5493f86585cbbbe325838ad576a3691a654db7522	f	\\x0410c464967192648dc7cfdfedea30b26ad358dbff44e997f264f7d4	\N	3681818181818181	\N	\N	\N
32	32	0	addr_test1vznzwgnj8k02rut8rdlc7q47acrj3rdsqyg8r2pekf72rfg7d9rfd	\\x60a62722723d9ea1f1671b7f8f02beee07288db0011071a839b27ca1a5	f	\\xa62722723d9ea1f1671b7f8f02beee07288db0011071a839b27ca1a5	\N	3681818181818181	\N	\N	\N
33	33	0	addr_test1vpwxfzd8lav4gsdwe366hzdcw4ls588xmvsgedh4l5q6saqfy4nhh	\\x605c6489a7ff595441aecc75ab89b8757f0a1ce6db208cb6f5fd01a874	f	\\x5c6489a7ff595441aecc75ab89b8757f0a1ce6db208cb6f5fd01a874	\N	3681818181818181	\N	\N	\N
34	35	0	addr_test1qzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqtzje526u5hqcxzwlfsvydjxzyu7ptu6l0h3pnhawk7turqxm44tv	\\x0099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01629668ad7297060c277d30611b23089cf057cd7df788677ebade5f06	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	21	500000000	\N	\N	\N
35	35	1	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681817681651228	\N	\N	\N
36	36	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681817681473231	\N	\N	\N
37	37	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681817681293914	\N	\N	\N
72	66	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681814878327629	\N	\N	\N
38	38	0	addr_test1qq76rxpehf5ecdacxkdwmphapdrnakf80vukq6730hxqtayhykj4rfxxtsn7a24sy674j5d60welwsu43g2mj4j9ctas5wflhd	\\x003da19839ba699c37b8359aed86fd0b473ed9277b39606bd17dcc05f49725a551a4c65c27eeaab026bd5951ba7bb3f743958a15b95645c2fb	f	\\x3da19839ba699c37b8359aed86fd0b473ed9277b39606bd17dcc05f4	3	3681818181637632	\N	\N	\N
39	39	0	addr_test1qq76rxpehf5ecdacxkdwmphapdrnakf80vukq6730hxqtayhykj4rfxxtsn7a24sy674j5d60welwsu43g2mj4j9ctas5wflhd	\\x003da19839ba699c37b8359aed86fd0b473ed9277b39606bd17dcc05f49725a551a4c65c27eeaab026bd5951ba7bb3f743958a15b95645c2fb	f	\\x3da19839ba699c37b8359aed86fd0b473ed9277b39606bd17dcc05f4	3	3681818181443619	\N	\N	\N
40	40	0	addr_test1qzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqfx0cy8dnwllxqr9uf3xj99sklcp0ccrwv20avpacj3v9cqrt6ssp	\\x0099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01267e0876cddff98032f131348a585bf80bf181b98a7f581ee2516170	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	12	600000000	\N	\N	\N
41	40	1	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681817081126961	\N	\N	\N
42	41	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681817080948964	\N	\N	\N
43	42	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681817080769647	\N	\N	\N
44	43	0	addr_test1qqc7fcdy5a54748v4fgvz98jeg5v3lky4pauph3492sq9tfwzvzh73s5py43l4khznr5q3s2kxlswxl3v5qes5xx3zrsswgh4u	\\x0031e4e1a4a7695f54ecaa50c114f2ca28c8fec4a87bc0de352aa002ad2e13057f4614092b1fd6d714c740460ab1bf071bf165019850c68887	f	\\x31e4e1a4a7695f54ecaa50c114f2ca28c8fec4a87bc0de352aa002ad	1	3681818181637632	\N	\N	\N
45	44	0	addr_test1qqc7fcdy5a54748v4fgvz98jeg5v3lky4pauph3492sq9tfwzvzh73s5py43l4khznr5q3s2kxlswxl3v5qes5xx3zrsswgh4u	\\x0031e4e1a4a7695f54ecaa50c114f2ca28c8fec4a87bc0de352aa002ad2e13057f4614092b1fd6d714c740460ab1bf071bf165019850c68887	f	\\x31e4e1a4a7695f54ecaa50c114f2ca28c8fec4a87bc0de352aa002ad	1	3681818181446391	\N	\N	\N
46	45	0	addr_test1qzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgzc5vacldgnqj96jg8m77huv0v322ya7erjjn3mqwtgr8srdz597	\\x0099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de0102c519dc7da898245d4907dfbd7e31ec8a944efb2394a71d81cb40cf	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	14	200000000	\N	\N	\N
47	45	1	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681816880602694	\N	\N	\N
48	46	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681816880424697	\N	\N	\N
49	47	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681816880245380	\N	\N	\N
50	48	0	addr_test1qzpdqc83lrupf5m5ye27e6qvjd24ehfl6dg9trusn75hmlmjrye38cz89hflcksvxprmxwjyx844qy7ulklr6pjrxkmqy2g0k3	\\x0082d060f1f8f814d3742655ece80c93555cdd3fd350558f909fa97dff72193313e0472dd3fc5a0c3047b33a4431eb5013dcfdbe3d064335b6	f	\\x82d060f1f8f814d3742655ece80c93555cdd3fd350558f909fa97dff	7	3681818181637632	\N	\N	\N
51	49	0	addr_test1qzpdqc83lrupf5m5ye27e6qvjd24ehfl6dg9trusn75hmlmjrye38cz89hflcksvxprmxwjyx844qy7ulklr6pjrxkmqy2g0k3	\\x0082d060f1f8f814d3742655ece80c93555cdd3fd350558f909fa97dff72193313e0472dd3fc5a0c3047b33a4431eb5013dcfdbe3d064335b6	f	\\x82d060f1f8f814d3742655ece80c93555cdd3fd350558f909fa97dff	7	3681818181443619	\N	\N	\N
52	50	0	addr_test1qzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqt76f4zdvdr3weycdaynf8dkft5r5nympfs9e3xppkqx4zs57nvwx	\\x0099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de017ed26a26b1a38bb24c37a49a4edb25741d264d85302e626086c03545	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	19	500000000	\N	\N	\N
53	50	1	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681816380078427	\N	\N	\N
54	51	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681816379900430	\N	\N	\N
55	52	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681816379721113	\N	\N	\N
56	53	0	addr_test1qrcy45vp00ruq9n935f2z4cqr3as9d6rfq3kx65arst0rz3u8n54ckahdgxvmfrua0knpxzc5yw7y5wtmnjglz0p0ges05qk7n	\\x00f04ad1817bc7c016658d12a157001c7b02b7434823636a9d1c16f18a3c3ce95c5bb76a0ccda47cebed309858a11de251cbdce48f89e17a33	f	\\xf04ad1817bc7c016658d12a157001c7b02b7434823636a9d1c16f18a	6	3681818181637632	\N	\N	\N
57	54	0	addr_test1qrcy45vp00ruq9n935f2z4cqr3as9d6rfq3kx65arst0rz3u8n54ckahdgxvmfrua0knpxzc5yw7y5wtmnjglz0p0ges05qk7n	\\x00f04ad1817bc7c016658d12a157001c7b02b7434823636a9d1c16f18a3c3ce95c5bb76a0ccda47cebed309858a11de251cbdce48f89e17a33	f	\\xf04ad1817bc7c016658d12a157001c7b02b7434823636a9d1c16f18a	6	3681818181443619	\N	\N	\N
58	55	0	addr_test1qzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqvd2fvw8r4z3z0e2quk5vtcepej83m5x34660rw4jz02khsza6htc	\\x0099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de018d5258e38ea2889f950396a3178c87323c774346bad3c6eac84f55af	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	15	500000000	\N	\N	\N
59	55	1	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681815879554160	\N	\N	\N
60	56	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681815879376163	\N	\N	\N
61	57	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681815879196846	\N	\N	\N
62	58	0	addr_test1qzmk4652c76zss8kudmldgguvrz5p68t3fahrw3n3r59cynjfw8jqjmh6w2as4s6t22sntytgxqxj4qhwfch6xetvexs0ndqza	\\x00b76aea8ac7b42840f6e377f6a11c60c540e8eb8a7b71ba3388e85c12724b8f204b77d395d8561a5a9509ac8b418069541772717d1b2b664d	f	\\xb76aea8ac7b42840f6e377f6a11c60c540e8eb8a7b71ba3388e85c12	8	3681818181637632	\N	\N	\N
63	59	0	addr_test1qzmk4652c76zss8kudmldgguvrz5p68t3fahrw3n3r59cynjfw8jqjmh6w2as4s6t22sntytgxqxj4qhwfch6xetvexs0ndqza	\\x00b76aea8ac7b42840f6e377f6a11c60c540e8eb8a7b71ba3388e85c12724b8f204b77d395d8561a5a9509ac8b418069541772717d1b2b664d	f	\\xb76aea8ac7b42840f6e377f6a11c60c540e8eb8a7b71ba3388e85c12	8	3681818181443619	\N	\N	\N
64	60	0	addr_test1qzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auq2tlgn6vng9d5f99j46955r5mz0sslwjtrkkuljxaftfjwsfsmtgc	\\x0099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de014bfa27a64d056d1252caba2d283a6c4f843ee92c76b73f23752b4c9d	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	17	500000000	\N	\N	\N
65	60	1	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681815379029893	\N	\N	\N
66	61	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681815378851896	\N	\N	\N
67	62	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681815378672579	\N	\N	\N
68	63	0	addr_test1qqcnanagdmqh7v7eag7jj72ysg4ks20p9l8cwtunl5f4xup46kqqqgwv3n04hrqjuz4s8p8uj6wyxu00e9u5g6puqjfqak3h6v	\\x00313ecfa86ec17f33d9ea3d297944822b6829e12fcf872f93fd13537035d5800021cc8cdf5b8c12e0ab0384fc969c4371efc97944683c0492	f	\\x313ecfa86ec17f33d9ea3d297944822b6829e12fcf872f93fd135370	5	3681818181637632	\N	\N	\N
69	64	0	addr_test1qqcnanagdmqh7v7eag7jj72ysg4ks20p9l8cwtunl5f4xup46kqqqgwv3n04hrqjuz4s8p8uj6wyxu00e9u5g6puqjfqak3h6v	\\x00313ecfa86ec17f33d9ea3d297944822b6829e12fcf872f93fd13537035d5800021cc8cdf5b8c12e0ab0384fc969c4371efc97944683c0492	f	\\x313ecfa86ec17f33d9ea3d297944822b6829e12fcf872f93fd135370	5	3681818181443619	\N	\N	\N
70	65	0	addr_test1qzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqd3sgx2e04u8es9damlqt5d50exzea3xhvcxw5692569yxs63j33s	\\x0099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01b1820cacbebc3e6056f77f02e8da3f26167b135d9833a9a2aa9a290d	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	22	500000000	\N	\N	\N
71	65	1	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681814878505626	\N	\N	\N
73	67	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681814878148312	\N	\N	\N
74	68	0	addr_test1qpygfw4f8fzun5ptwaev8ng2jarc9fv4w0jl8eh83fxm7luyjtq08mxwc24gwh9npr8uf7p906t7rxmr6z9jk0ywdenqnmlspw	\\x004884baa93a45c9d02b7772c3cd0a974782a59573e5f3e6e78a4dbf7f8492c0f3eccec2aa875cb308cfc4f8257e97e19b63d08b2b3c8e6e66	f	\\x4884baa93a45c9d02b7772c3cd0a974782a59573e5f3e6e78a4dbf7f	10	3681818181637632	\N	\N	\N
75	69	0	addr_test1qpygfw4f8fzun5ptwaev8ng2jarc9fv4w0jl8eh83fxm7luyjtq08mxwc24gwh9npr8uf7p906t7rxmr6z9jk0ywdenqnmlspw	\\x004884baa93a45c9d02b7772c3cd0a974782a59573e5f3e6e78a4dbf7f8492c0f3eccec2aa875cb308cfc4f8257e97e19b63d08b2b3c8e6e66	f	\\x4884baa93a45c9d02b7772c3cd0a974782a59573e5f3e6e78a4dbf7f	10	3681818181443619	\N	\N	\N
76	70	0	addr_test1qzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqfg6lna4y3q3pkldqac2qhpjfjv696w09fz4ss82lqy6easleacjz	\\x0099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de0128d7e7da9220886df683b8502e19264cd174e79522ac20757c04d67b	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	20	300000000	\N	\N	\N
77	70	1	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681814577981359	\N	\N	\N
78	71	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681814577803362	\N	\N	\N
79	72	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681814577624045	\N	\N	\N
80	73	0	addr_test1qql8u3725ygxpapdx24yvw680u89gdn4xy0n0s3ufq8umnxqdauaqpsu6tqyae2uz25mjsptn658nfdqtsq9lqumc84qyyza79	\\x003e7e47caa11060f42d32aa463b477f0e543675311f37c23c480fcdccc06f79d0061cd2c04ee55c12a9b9402b9ea879a5a05c005f839bc1ea	f	\\x3e7e47caa11060f42d32aa463b477f0e543675311f37c23c480fcdcc	9	3681818181637632	\N	\N	\N
81	74	0	addr_test1qql8u3725ygxpapdx24yvw680u89gdn4xy0n0s3ufq8umnxqdauaqpsu6tqyae2uz25mjsptn658nfdqtsq9lqumc84qyyza79	\\x003e7e47caa11060f42d32aa463b477f0e543675311f37c23c480fcdccc06f79d0061cd2c04ee55c12a9b9402b9ea879a5a05c005f839bc1ea	f	\\x3e7e47caa11060f42d32aa463b477f0e543675311f37c23c480fcdcc	9	3681818181446391	\N	\N	\N
82	75	0	addr_test1qql8u3725ygxpapdx24yvw680u89gdn4xy0n0s3ufq8umnxqdauaqpsu6tqyae2uz25mjsptn658nfdqtsq9lqumc84qyyza79	\\x003e7e47caa11060f42d32aa463b477f0e543675311f37c23c480fcdccc06f79d0061cd2c04ee55c12a9b9402b9ea879a5a05c005f839bc1ea	f	\\x3e7e47caa11060f42d32aa463b477f0e543675311f37c23c480fcdcc	9	3681818181265842	\N	\N	\N
83	76	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681814577439800	\N	\N	\N
84	77	0	addr_test1qzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqwux9jcnnxp0pnz3q4p23pl37dsvc0vjllv5e9rz7whn7uszcl3g5	\\x0099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01dc316589ccc178662882a15443f8f9b0661ec97feca64a3179d79fb9	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	18	300000000	\N	\N	\N
85	77	1	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681814277272847	\N	\N	\N
86	78	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681814277094850	\N	\N	\N
87	79	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681814276915533	\N	\N	\N
88	80	0	addr_test1qqzpp3ryjeceyeydcl8alm02xzex456cm0l5f6vh7fj004x9phmm2fm7zh25j0uxtpwth03jtqu264m2x6g6v4xmw53qa832k5	\\x000410c464967192648dc7cfdfedea30b26ad358dbff44e997f264f7d4c50df7b5277e15d5493f86585cbbbe325838ad576a3691a654db7522	f	\\x0410c464967192648dc7cfdfedea30b26ad358dbff44e997f264f7d4	11	3681818181637632	\N	\N	\N
89	81	0	addr_test1qqzpp3ryjeceyeydcl8alm02xzex456cm0l5f6vh7fj004x9phmm2fm7zh25j0uxtpwth03jtqu264m2x6g6v4xmw53qa832k5	\\x000410c464967192648dc7cfdfedea30b26ad358dbff44e997f264f7d4c50df7b5277e15d5493f86585cbbbe325838ad576a3691a654db7522	f	\\x0410c464967192648dc7cfdfedea30b26ad358dbff44e997f264f7d4	11	3681818181446391	\N	\N	\N
90	82	0	addr_test1qqzpp3ryjeceyeydcl8alm02xzex456cm0l5f6vh7fj004x9phmm2fm7zh25j0uxtpwth03jtqu264m2x6g6v4xmw53qa832k5	\\x000410c464967192648dc7cfdfedea30b26ad358dbff44e997f264f7d4c50df7b5277e15d5493f86585cbbbe325838ad576a3691a654db7522	f	\\x0410c464967192648dc7cfdfedea30b26ad358dbff44e997f264f7d4	11	3681818181265842	\N	\N	\N
91	83	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681814276731288	\N	\N	\N
92	84	0	addr_test1qzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqvc4qt59n4239vjrcem64mhy6qypcwsvlhkw9kx56hrtn3suvkfpc	\\x0099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de0198a81742ceaa895921e33bd5777268040e1d067ef6716c6a6ae35ce3	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	13	500000000	\N	\N	\N
93	84	1	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681813776564335	\N	\N	\N
94	85	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681813776386338	\N	\N	\N
95	86	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681813776207021	\N	\N	\N
96	87	0	addr_test1qpvcpfpavmxe6dnw0cyltdraw07qzfmn0n8gs4xpjlzeaygznts3puuh5h5g62h0cjuqwvmkrkmhac59xgl8d2g564kqzzgymk	\\x005980a43d66cd9d366e7e09f5b47d73fc0127737cce8854c197c59e91029ae110f397a5e88d2aefc4b80733761db77ee285323e76a914d56c	f	\\x5980a43d66cd9d366e7e09f5b47d73fc0127737cce8854c197c59e91	4	3681818181637632	\N	\N	\N
97	88	0	addr_test1qpvcpfpavmxe6dnw0cyltdraw07qzfmn0n8gs4xpjlzeaygznts3puuh5h5g62h0cjuqwvmkrkmhac59xgl8d2g564kqzzgymk	\\x005980a43d66cd9d366e7e09f5b47d73fc0127737cce8854c197c59e91029ae110f397a5e88d2aefc4b80733761db77ee285323e76a914d56c	f	\\x5980a43d66cd9d366e7e09f5b47d73fc0127737cce8854c197c59e91	4	3681818181443575	\N	\N	\N
98	89	0	addr_test1qpvcpfpavmxe6dnw0cyltdraw07qzfmn0n8gs4xpjlzeaygznts3puuh5h5g62h0cjuqwvmkrkmhac59xgl8d2g564kqzzgymk	\\x005980a43d66cd9d366e7e09f5b47d73fc0127737cce8854c197c59e91029ae110f397a5e88d2aefc4b80733761db77ee285323e76a914d56c	f	\\x5980a43d66cd9d366e7e09f5b47d73fc0127737cce8854c197c59e91	4	3681818181263026	\N	\N	\N
99	90	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681813776022776	\N	\N	\N
100	91	0	addr_test1qzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqvytn34uz28le8nqsul8dcs9ujcf7atus7gyz4dullel90snsn25v	\\x0099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01845ce35e0947fe4f30439f3b7102f2584fbabe43c820aade7ff9f95f	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	16	500000000	\N	\N	\N
101	91	1	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681813275855823	\N	\N	\N
102	92	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681813275677826	\N	\N	\N
103	93	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681813275498509	\N	\N	\N
104	94	0	addr_test1qp7g5nsg4wwe3z4l00mv4cng40j6x7rgwae9pyj7glmx3nvr20zttf79yw8fn98xd5cx4xtaxw0e4rx2az9y9nefd8gsfwm30p	\\x007c8a4e08ab9d988abf7bf6cae268abe5a37868777250925e47f668cd8353c4b5a7c5238e9994e66d306a997d339f9a8ccae88a42cf2969d1	f	\\x7c8a4e08ab9d988abf7bf6cae268abe5a37868777250925e47f668cd	2	3681818181637641	\N	\N	\N
105	95	0	addr_test1qp7g5nsg4wwe3z4l00mv4cng40j6x7rgwae9pyj7glmx3nvr20zttf79yw8fn98xd5cx4xtaxw0e4rx2az9y9nefd8gsfwm30p	\\x007c8a4e08ab9d988abf7bf6cae268abe5a37868777250925e47f668cd8353c4b5a7c5238e9994e66d306a997d339f9a8ccae88a42cf2969d1	f	\\x7c8a4e08ab9d988abf7bf6cae268abe5a37868777250925e47f668cd	2	3681818181443584	\N	\N	\N
106	96	0	addr_test1qp7g5nsg4wwe3z4l00mv4cng40j6x7rgwae9pyj7glmx3nvr20zttf79yw8fn98xd5cx4xtaxw0e4rx2az9y9nefd8gsfwm30p	\\x007c8a4e08ab9d988abf7bf6cae268abe5a37868777250925e47f668cd8353c4b5a7c5238e9994e66d306a997d339f9a8ccae88a42cf2969d1	f	\\x7c8a4e08ab9d988abf7bf6cae268abe5a37868777250925e47f668cd	2	3681818181263035	\N	\N	\N
107	97	0	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3681813275314264	\N	\N	\N
108	98	0	addr_test1wpnlxv2xv9a9ucvnvzqakwepzl9ltx7jzgm53av2e9ncv4sysemm8	\\x7067f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	t	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	\N	100000000	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	\N	\N
109	98	1	addr_test1vrdjw35y0mee0rlz0pm7s0c7upm0x7hqu8u26ey2q690y9sjrfkfk	\\x60db2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	f	\\xdb2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	\N	3681818081650832	\N	\N	\N
110	99	0	addr_test1vrdjw35y0mee0rlz0pm7s0c7upm0x7hqu8u26ey2q690y9sjrfkfk	\\x60db2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	f	\\xdb2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	\N	99828910	\N	\N	\N
111	100	0	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	\\x702618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	100000000	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	2	\N
112	100	1	addr_test1vrdjw35y0mee0rlz0pm7s0c7upm0x7hqu8u26ey2q690y9sjrfkfk	\\x60db2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	f	\\xdb2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	\N	3681817981484759	\N	\N	\N
113	101	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	2
114	101	1	addr_test1vrdjw35y0mee0rlz0pm7s0c7upm0x7hqu8u26ey2q690y9sjrfkfk	\\x60db2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	f	\\xdb2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	\N	3681817881314374	\N	\N	\N
115	102	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	3
116	102	1	addr_test1vrdjw35y0mee0rlz0pm7s0c7upm0x7hqu8u26ey2q690y9sjrfkfk	\\x60db2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	f	\\xdb2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	\N	3681817781146585	\N	\N	\N
117	103	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	1
118	103	1	addr_test1vrdjw35y0mee0rlz0pm7s0c7upm0x7hqu8u26ey2q690y9sjrfkfk	\\x60db2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	f	\\xdb2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	\N	3681817680979940	\N	\N	\N
119	104	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	4
120	104	1	addr_test1vrdjw35y0mee0rlz0pm7s0c7upm0x7hqu8u26ey2q690y9sjrfkfk	\\x60db2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	f	\\xdb2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	\N	3681817580717067	\N	\N	\N
121	105	0	addr_test1wzem0yuxjqyrmzvrsr8xfqhumyy555ngyjxw7wrg2pav90q8cagu2	\\x70b3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	t	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	\N	100000000	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	3	\N
122	105	1	addr_test1vrdjw35y0mee0rlz0pm7s0c7upm0x7hqu8u26ey2q690y9sjrfkfk	\\x60db2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	f	\\xdb2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	\N	3681817480550950	\N	\N	\N
123	106	0	addr_test1vrdjw35y0mee0rlz0pm7s0c7upm0x7hqu8u26ey2q690y9sjrfkfk	\\x60db2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	f	\\xdb2746847ef3978fe27877e83f1ee076f37ae0e1f8ad648a068af216	\N	3681817580223603	\N	\N	\N
124	107	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\N	\N	\N
125	107	1	addr_test1vqg54jwdssqgx5g7jrevpktcahw8axe6vjvlth9j929vumchx3zmy	\\x60114ac9cd840083511e90f2c0d978eddc7e9b3a6499f5dcb22a8ace6f	f	\\x114ac9cd840083511e90f2c0d978eddc7e9b3a6499f5dcb22a8ace6f	\N	3681818171642252	\N	\N	\N
126	108	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000000000	\N	\N	\N
127	108	1	addr_test1qrml5hwl9s7ydm2djyup95ud6s74skkl4zzf8zk657s8thgm78sn3uhch64ujc7ffnpga68dfdqhg3sp7tk6759jrm7spy03k9	\\x00f7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd1bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	f	\\xf7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd	47	5000000000000	\N	\N	\N
128	108	2	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	5000000000000	\N	\N	\N
129	108	3	addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k	\\x00594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	f	\\x594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0	49	5000000000000	\N	\N	\N
130	108	4	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	5000000000000	\N	\N	\N
131	108	5	addr_test1vzvlrs5jzfrcvg070dq6yc3gaf8utlrqwrkfv9k8rs5auqgj2u7dn	\\x6099f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	f	\\x99f1c29212478621fe7b41a26228ea4fc5fc6070ec9616c71c29de01	\N	3656813275134639	\N	\N	\N
132	109	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\N	\N	\N
133	109	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999989767575	\N	\N	\N
134	110	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\\x81cb2989cbf6c49840511d8d3451ee44f58dde2c074fc749d05deb51eeb33741	4	\N
135	110	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999979582758	\N	\N	\N
136	111	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	5	\N
137	111	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999969347913	\N	\N	\N
138	112	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	20000000	\N	\N	\N
139	112	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999959173480	\N	\N	\N
140	113	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	20000000	\N	\N	\N
141	113	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999939002479	\N	\N	\N
142	114	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999938828398	\N	\N	\N
143	115	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	19826843	\N	\N	\N
144	116	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
145	116	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999928635573	\N	\N	\N
146	117	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
147	117	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999928439316	\N	\N	\N
148	118	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999938264399	\N	\N	\N
149	119	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
150	119	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999928071574	\N	\N	\N
151	120	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9826843	\N	\N	\N
152	121	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
153	121	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999927704008	\N	\N	\N
154	122	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9824995	\N	\N	\N
155	123	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9651838	\N	\N	\N
158	125	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
159	125	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999917500007	\N	\N	\N
160	126	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
161	126	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999917319766	\N	\N	\N
162	127	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
163	127	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9463237	\N	\N	\N
164	128	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
165	128	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999907130769	\N	\N	\N
166	129	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
167	129	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9811047	\N	\N	\N
168	130	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999926762587	\N	\N	\N
169	131	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	1000000000	\N	\N	\N
170	131	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998936055835	\N	\N	\N
171	132	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	99675351	\N	\N	\N
172	132	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	100000000	\N	\N	\N
173	132	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	100000000	\N	\N	\N
174	132	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	100000000	\N	\N	\N
175	132	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	100000000	\N	\N	\N
176	132	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	50000000	\N	\N	\N
177	132	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	50000000	\N	\N	\N
178	132	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	50000000	\N	\N	\N
179	132	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	50000000	\N	\N	\N
180	132	9	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	50000000	\N	\N	\N
181	132	10	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	25000000	\N	\N	\N
182	132	11	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	25000000	\N	\N	\N
183	132	12	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	25000000	\N	\N	\N
184	132	13	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	25000000	\N	\N	\N
185	132	14	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	25000000	\N	\N	\N
186	132	15	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	12500000	\N	\N	\N
187	132	16	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	12500000	\N	\N	\N
188	132	17	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	12500000	\N	\N	\N
189	132	18	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	12500000	\N	\N	\N
190	132	19	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	12500000	\N	\N	\N
191	132	20	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	6250000	\N	\N	\N
192	132	21	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	6250000	\N	\N	\N
193	132	22	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	6250000	\N	\N	\N
194	132	23	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	6250000	\N	\N	\N
195	132	24	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	6250000	\N	\N	\N
196	132	25	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	3125000	\N	\N	\N
197	132	26	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	3125000	\N	\N	\N
198	132	27	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	3125000	\N	\N	\N
199	132	28	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	3125000	\N	\N	\N
200	132	29	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	3125000	\N	\N	\N
201	132	30	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	3125000	\N	\N	\N
202	132	31	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	3125000	\N	\N	\N
203	132	32	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	3125000	\N	\N	\N
204	132	33	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	3125000	\N	\N	\N
205	132	34	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	3125000	\N	\N	\N
206	133	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	499576915	\N	\N	\N
207	133	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	249918838	\N	\N	\N
208	133	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	124959419	\N	\N	\N
209	133	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	62479709	\N	\N	\N
210	133	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	31239855	\N	\N	\N
211	133	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	15619927	\N	\N	\N
212	133	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	7809964	\N	\N	\N
213	133	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	3904982	\N	\N	\N
214	133	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	3904981	\N	\N	\N
215	134	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	499375158	\N	\N	\N
216	135	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
217	135	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998932871986	\N	\N	\N
218	136	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2820947	\N	\N	\N
219	137	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
220	137	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998932513792	\N	\N	\N
221	138	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2827019	\N	\N	\N
222	139	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999361204486	\N	\N	\N
223	139	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999573966160	\N	\N	\N
224	140	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999361204486	\N	\N	\N
225	140	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999573795995	\N	\N	\N
226	141	0	addr_test1qquq7egdkp6aeuynftp82hgyg90xmr654fl0unk6arq4qljk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqdv2a45	\\x00380f650db075dcf0934ac2755d04415e6d8f54aa7efe4edae8c1507e56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x380f650db075dcf0934ac2755d04415e6d8f54aa7efe4edae8c1507e	61	3000000	\N	\N	\N
227	141	1	addr_test1qp5lf0eulq3kkhlcfaeq7savhd7sfgda94ehwnmgjgldmd2k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqgcdw8u	\\x0069f4bf3cf8236b5ff84f720f43acbb7d04a1bd2d73774f68923eddb556a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x69f4bf3cf8236b5ff84f720f43acbb7d04a1bd2d73774f68923eddb5	61	3000000	\N	\N	\N
228	141	2	addr_test1qzmhqmjp4xlvsh90zlwrh5y5ch9zraya4guka8xqdgv2krjk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqdrxmwr	\\x00b7706e41a9bec85caf17dc3bd094c5ca21f49daa396e9cc06a18ab0e56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xb7706e41a9bec85caf17dc3bd094c5ca21f49daa396e9cc06a18ab0e	61	3000000	\N	\N	\N
229	141	3	addr_test1qz9njkk8gs73lkvhx2vxjnlg835zrt97jkqhhzgukr7hkazk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq97mjfs	\\x008b395ac7443d1fd9973298694fe83c6821acbe95817b891cb0fd7b7456a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x8b395ac7443d1fd9973298694fe83c6821acbe95817b891cb0fd7b74	61	3000000	\N	\N	\N
230	141	4	addr_test1qphw57fyv5ntvk3f94rncgxe6wt5066x6u296ma23xa9ex2k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqhfzh5u	\\x006eea79246526b65a292d473c20d9d39747eb46d7145d6faa89ba5c9956a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x6eea79246526b65a292d473c20d9d39747eb46d7145d6faa89ba5c99	61	3000000	\N	\N	\N
231	141	5	addr_test1qrdum57ma293cs0ex254thuvxzl258rutfzytvnazh8l5tzk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq4a44tv	\\x00dbcdd3dbea8b1c41f932a955df8c30beaa1c7c5a4445b27d15cffa2c56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xdbcdd3dbea8b1c41f932a955df8c30beaa1c7c5a4445b27d15cffa2c	61	3000000	\N	\N	\N
232	141	6	addr_test1qpx99c6s96hnpxse685rc2qt0lxqsvrhf5l2f4kyrmgmxa2k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqv9kwse	\\x004c52e3502eaf309a19d1e83c280b7fcc0830774d3ea4d6c41ed1b37556a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x4c52e3502eaf309a19d1e83c280b7fcc0830774d3ea4d6c41ed1b375	61	3000000	\N	\N	\N
233	141	7	addr_test1qzc2mwn09gr4pgkldtekl09cvrvvey7ns5hhtuayt9rqkqjk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqh27w6s	\\x00b0adba6f2a0750a2df6af36fbcb860d8cc93d3852f75f3a459460b0256a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xb0adba6f2a0750a2df6af36fbcb860d8cc93d3852f75f3a459460b02	61	3000000	\N	\N	\N
234	141	8	addr_test1qrp7gmwzug26f56lzp7mrndkedfy9pkn87wvk6m08f5ev22k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqr269n6	\\x00c3e46dc2e215a4d35f107db1cdb6cb524286d33f9ccb6b6f3a69962956a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xc3e46dc2e215a4d35f107db1cdb6cb524286d33f9ccb6b6f3a699629	61	3000000	\N	\N	\N
235	141	9	addr_test1qpsqcekxllptr5mhjkdmcclfrn85ulguruhckqelc6lglx6k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqxm2g8l	\\x00600c66c6ffc2b1d377959bbc63e91ccf4e7d1c1f2f8b033fc6be8f9b56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x600c66c6ffc2b1d377959bbc63e91ccf4e7d1c1f2f8b033fc6be8f9b	61	3000000	\N	\N	\N
236	141	10	addr_test1qz06e0sa0nv7s5x5z5d23adqcmhm0zyhtas8856n4sfesyzk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqgj6a9u	\\x009facbe1d7cd9e850d4151aa8f5a0c6efb788975f6073d353ac13981056a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x9facbe1d7cd9e850d4151aa8f5a0c6efb788975f6073d353ac139810	61	3000000	\N	\N	\N
237	141	11	addr_test1qpp2zg7z3asxsh0nrdxv9nhvl9p2sp5sksegwf90446fqj6k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqxv5qrl	\\x0042a123c28f60685df31b4cc2ceecf942a80690b4328724afad74904b56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x42a123c28f60685df31b4cc2ceecf942a80690b4328724afad74904b	61	3000000	\N	\N	\N
238	141	12	addr_test1qzwe75lgd4zz2emyn4pkztjk6sen4fwp26xerdgy4745pr2k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq9vn99z	\\x009d9f53e86d442567649d43612e56d4333aa5c1568d91b504afab408d56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x9d9f53e86d442567649d43612e56d4333aa5c1568d91b504afab408d	61	3000000	\N	\N	\N
239	141	13	addr_test1qrhell3fsq450465qs7gp5ev2wwx5lwdyv99nmctjvpzj42k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqh2ytnh	\\x00ef9ffe29802b47d754043c80d32c539c6a7dcd230a59ef0b9302295556a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xef9ffe29802b47d754043c80d32c539c6a7dcd230a59ef0b93022955	61	3000000	\N	\N	\N
240	141	14	addr_test1qrztfmna9j5g2v3vwd38zamvl5es4vcc5sg5hespmfrg33zk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqlf0037	\\x00c4b4ee7d2ca885322c736271776cfd330ab318a4114be601da4688c456a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xc4b4ee7d2ca885322c736271776cfd330ab318a4114be601da4688c4	61	3000000	\N	\N	\N
241	141	15	addr_test1qr8k6vx0pxf02m9ywe3jstxyed3smazhad8r80r7vqk6nrzk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqu2n4t9	\\x00cf6d30cf0992f56ca47663282cc4cb630df457eb4e33bc7e602da98c56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xcf6d30cf0992f56ca47663282cc4cb630df457eb4e33bc7e602da98c	61	3000000	\N	\N	\N
242	141	16	addr_test1qzh65navy5kqladgn73s04vqr4dw4aj6c0cj7ka077qccf2k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqczaeyx	\\x00afaa4fac252c0ff5a89fa307d5801d5aeaf65ac3f12f5baff7818c2556a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xafaa4fac252c0ff5a89fa307d5801d5aeaf65ac3f12f5baff7818c25	61	3000000	\N	\N	\N
243	141	17	addr_test1qp4lztj0tmvyyxaug474nk2sjlsa0t9p5wapp8ukqj4ljh6k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqxgk8ef	\\x006bf12e4f5ed8421bbc457d59d95097e1d7aca1a3ba109f9604abf95f56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x6bf12e4f5ed8421bbc457d59d95097e1d7aca1a3ba109f9604abf95f	61	3000000	\N	\N	\N
244	141	18	addr_test1qqax4apf0r5krxgz62ywjyc0u5km2ymggqsyz98fl3cmuw6k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq47xasp	\\x003a6af42978e9619902d288e9130fe52db5136840204114e9fc71be3b56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x3a6af42978e9619902d288e9130fe52db5136840204114e9fc71be3b	61	3000000	\N	\N	\N
245	141	19	addr_test1qrnvv7putr6vqkvqrvp908l8et78da0m5ajv2kwt7x2sjezk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqhxa5gc	\\x00e6c6783c58f4c059801b02579fe7cafc76f5fba764c559cbf195096456a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xe6c6783c58f4c059801b02579fe7cafc76f5fba764c559cbf1950964	61	3000000	\N	\N	\N
246	141	20	addr_test1qq4svrhvla34ry6x7k3ezjdfkt3rpfxypgzupv3xemdml02k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqj0ude3	\\x002b060eecff63519346f5a39149a9b2e230a4c40a05c0b226cedbbfbd56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x2b060eecff63519346f5a39149a9b2e230a4c40a05c0b226cedbbfbd	61	3000000	\N	\N	\N
247	141	21	addr_test1qrdum38crfvyst0n39q7l6da2fgnt6w90uae86q6kjk8f7jk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqyzpt82	\\x00dbcdc4f81a58482df38941efe9bd525135e9c57f3b93e81ab4ac74fa56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xdbcdc4f81a58482df38941efe9bd525135e9c57f3b93e81ab4ac74fa	61	3000000	\N	\N	\N
248	141	22	addr_test1qruqt6mq2lux4lw27le968swemc8xjj5y3yusx6uz8tyd22k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq96veey	\\x00f805eb6057f86afdcaf7f25d1e0ecef0734a542449c81b5c11d646a956a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xf805eb6057f86afdcaf7f25d1e0ecef0734a542449c81b5c11d646a9	61	3000000	\N	\N	\N
249	141	23	addr_test1qzqney3tdev4zqwdfstr7lk2gluz073n72cnrl77vhgpu7zk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqypu7j7	\\x00813c922b6e595101cd4c163f7eca47f827fa33f2b131ffde65d01e7856a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x813c922b6e595101cd4c163f7eca47f827fa33f2b131ffde65d01e78	61	3000000	\N	\N	\N
250	141	24	addr_test1qpuqfmpcgjrj7sfw6l44gl3tz22m0jgza0x4q2djgy38qa2k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq33066y	\\x007804ec3844872f412ed7eb547e2b1295b7c902ebcd5029b24122707556a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x7804ec3844872f412ed7eb547e2b1295b7c902ebcd5029b241227075	61	3000000	\N	\N	\N
251	141	25	addr_test1qq84fz5yw7fmn3msxvqrnqp3dz078gl7ulv3nc893kcnh42k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqd0wrfy	\\x000f548a847793b9c7703300398031689fe3a3fee7d919e0e58db13bd556a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x0f548a847793b9c7703300398031689fe3a3fee7d919e0e58db13bd5	61	3000000	\N	\N	\N
252	141	26	addr_test1qqrs2deh40e6238x9v9f7xl6lhu4j6e5d0dxl9mk7n30ph6k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqkd9scm	\\x0007053737abf3a544e62b0a9f1bfafdf9596b346bda6f9776f4e2f0df56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x07053737abf3a544e62b0a9f1bfafdf9596b346bda6f9776f4e2f0df	61	3000000	\N	\N	\N
253	141	27	addr_test1qpq83ryfxcfhgjskn7kt6c5d283gs04v3u9axnn8qcm2zu2k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq3f2j3v	\\x0040788c893613744a169facbd628d51e2883eac8f0bd34e670636a17156a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x40788c893613744a169facbd628d51e2883eac8f0bd34e670636a171	61	3000000	\N	\N	\N
254	141	28	addr_test1qqle2ut2d7qhre2vhyvp3ekrhmpg2h8nrut9fqx3wlq6f2zk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqsdzps9	\\x003f95716a6f8171e54cb91818e6c3bec2855cf31f165480d177c1a4a856a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x3f95716a6f8171e54cb91818e6c3bec2855cf31f165480d177c1a4a8	61	3000000	\N	\N	\N
255	141	29	addr_test1qr6kx0qntyslf3alv750nn9rtymep8mxurthscfy43lygf2k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqsmgh07	\\x00f5633c135921f4c7bf67a8f9cca35937909f66e0d7786124ac7e442556a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xf5633c135921f4c7bf67a8f9cca35937909f66e0d7786124ac7e4425	61	3000000	\N	\N	\N
256	141	30	addr_test1qqfvkr7wn3a94zqs2pp6gs8r3yvanf0n4zmjcgjwp2xjxm2k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqpw708v	\\x0012cb0fce9c7a5a88105043a440e38919d9a5f3a8b72c224e0a8d236d56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x12cb0fce9c7a5a88105043a440e38919d9a5f3a8b72c224e0a8d236d	61	3000000	\N	\N	\N
257	141	31	addr_test1qrphu9up64lg9m4rfyc0w8h4q5jew0hjsctx2lvu4puduz6k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqaqw99m	\\x00c37e1781d57e82eea34930f71ef50525973ef28616657d9ca878de0b56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xc37e1781d57e82eea34930f71ef50525973ef28616657d9ca878de0b	61	3000000	\N	\N	\N
258	141	32	addr_test1qr4ln629pmq9pfen99zxyp608hchc3h6up5g4gtjaphn8xzk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqrqg25p	\\x00ebf9e9450ec050a733294462074f3df17c46fae0688aa172e86f339856a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xebf9e9450ec050a733294462074f3df17c46fae0688aa172e86f3398	61	3000000	\N	\N	\N
259	141	33	addr_test1qqw54eqgh7gjycgpq9psa9kft5gluxk3kr3pwna9zq87422k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqwvk3nl	\\x001d4ae408bf9122610101430e96c95d11fe1ad1b0e2174fa5100feaa956a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x1d4ae408bf9122610101430e96c95d11fe1ad1b0e2174fa5100feaa9	61	3000000	\N	\N	\N
260	141	34	addr_test1qqjrp3nhachkst4era68daj5u53wqv9q2j722uge7lwyapzk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqtrxgp2	\\x002430c677ee2f682eb91f7476f654e522e030a054bca57119f7dc4e8456a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x2430c677ee2f682eb91f7476f654e522e030a054bca57119f7dc4e84	61	3000000	\N	\N	\N
261	141	35	addr_test1qqe6clykp9h90hmag70ywhsa7yvq3fmnpf5tdu4k5ld90kzk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqqmpk3j	\\x0033ac7c96096e57df7d479e475e1df11808a7730a68b6f2b6a7da57d856a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x33ac7c96096e57df7d479e475e1df11808a7730a68b6f2b6a7da57d8	61	3000000	\N	\N	\N
262	141	36	addr_test1qpwp4sz7vgweualdnqyj69rrndyz863rlhn9fgjuz64rwj6k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpquun8t0	\\x005c1ac05e621d9e77ed98092d14639b4823ea23fde654a25c16aa374b56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x5c1ac05e621d9e77ed98092d14639b4823ea23fde654a25c16aa374b	61	3000000	\N	\N	\N
263	141	37	addr_test1qzm0j2dda4qmcsq96lychkcsr3fttx4cqemmrkyd9smjhl2k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqqfle99	\\x00b6f929aded41bc4005d7c98bdb101c52b59ab80677b1d88d2c372bfd56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xb6f929aded41bc4005d7c98bdb101c52b59ab80677b1d88d2c372bfd	61	3000000	\N	\N	\N
264	141	38	addr_test1qrp5q0xydvmtnsluq9q8f3u865guwxe03fufu355gw006y6k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqt80fjq	\\x00c3403cc46b36b9c3fc014074c787d511c71b2f8a789e4694439efd1356a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xc3403cc46b36b9c3fc014074c787d511c71b2f8a789e4694439efd13	61	3000000	\N	\N	\N
265	141	39	addr_test1qzn2gj08w2ve7ew7u802ss4vfrezdzgyx0fh66awqhmd4k6k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqtk650w	\\x00a6a449e772999f65dee1dea842ac48f226890433d37d6bae05f6dadb56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xa6a449e772999f65dee1dea842ac48f226890433d37d6bae05f6dadb	61	3000000	\N	\N	\N
266	141	40	addr_test1qqkwf544hgsqp5vlhkzlag9gz7zeaeneryllg8l4fqa0e3jk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq9s7rjf	\\x002ce4d2b5ba2000d19fbd85fea0a817859ee679193ff41ff5483afcc656a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x2ce4d2b5ba2000d19fbd85fea0a817859ee679193ff41ff5483afcc6	61	3000000	\N	\N	\N
267	141	41	addr_test1qrlt96sgll3xr0vap4tveknh4023t8w0ga0kh2s908lxmhjk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqwn0cdc	\\x00feb2ea08ffe261bd9d0d56ccda77abd5159dcf475f6baa0579fe6dde56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xfeb2ea08ffe261bd9d0d56ccda77abd5159dcf475f6baa0579fe6dde	61	3000000	\N	\N	\N
268	141	42	addr_test1qq7rszluz9qu5g2vanvm67rxny37w08wfnnd6sntcrmmnfzk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq6khw5d	\\x003c380bfc1141ca214cecd9bd78669923e73cee4ce6dd426bc0f7b9a456a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x3c380bfc1141ca214cecd9bd78669923e73cee4ce6dd426bc0f7b9a4	61	3000000	\N	\N	\N
269	141	43	addr_test1qzyzy2nuxqmtt3tvtrldnx2xhx4s3wtnjx9f306nwuhvf4jk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq0wtxrp	\\x0088222a7c3036b5c56c58fed99946b9ab08b973918a98bf53772ec4d656a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x88222a7c3036b5c56c58fed99946b9ab08b973918a98bf53772ec4d6	61	3000000	\N	\N	\N
270	141	44	addr_test1qrdmzrfdh99mx4h0aecastndgqmfgky538wnhnme4d6nzjzk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqc5k79g	\\x00dbb10d2db94bb356efee71d82e6d403694589489dd3bcf79ab75314856a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xdbb10d2db94bb356efee71d82e6d403694589489dd3bcf79ab753148	61	3000000	\N	\N	\N
271	141	45	addr_test1qzrczemgzw0k86qyn0nr3z8m7vd4efev3su6cteewggv8a2k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq0l8f2x	\\x0087816768139f63e8049be63888fbf31b5ca72c8c39ac2f397210c3f556a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x87816768139f63e8049be63888fbf31b5ca72c8c39ac2f397210c3f5	61	3000000	\N	\N	\N
272	141	46	addr_test1qryctnzedettnwsu9lw0wzcr7vnaka5a6p32xrke3ezzfw6k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqj6sxh6	\\x00c985cc596e56b9ba1c2fdcf70b03f327db769dd062a30ed98e4424bb56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xc985cc596e56b9ba1c2fdcf70b03f327db769dd062a30ed98e4424bb	61	3000000	\N	\N	\N
273	141	47	addr_test1qzh2k5dzj7t8tgeygk5mlrgz3ps366mzrc2l597ayxwseuzk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqu47nfw	\\x00aeab51a2979675a32445a9bf8d0288611d6b621e15fa17dd219d0cf056a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xaeab51a2979675a32445a9bf8d0288611d6b621e15fa17dd219d0cf0	61	3000000	\N	\N	\N
274	141	48	addr_test1qrvrjr8smx5ek38xrctvezd5calh0p5axepnetcl62nt696k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqle5u9p	\\x00d8390cf0d9a99b44e61e16cc89b4c77f77869d36433caf1fd2a6bd1756a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xd8390cf0d9a99b44e61e16cc89b4c77f77869d36433caf1fd2a6bd17	61	3000000	\N	\N	\N
275	141	49	addr_test1qztdzk30l7cy090cy8r04xd7dx3l3sed7shu2ct5pu48nc2k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqkq6n3z	\\x0096d15a2fffb04795f821c6fa99be69a3f8c32df42fc561740f2a79e156a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x96d15a2fffb04795f821c6fa99be69a3f8c32df42fc561740f2a79e1	61	3000000	\N	\N	\N
276	141	50	addr_test1qqykrkrs66pm8vd05dyy8krvauh74kv93n5tjmtw77atjk6k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqxfxprl	\\x000961d870d683b3b1afa34843d86cef2fead9858ce8b96d6ef7bab95b56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x0961d870d683b3b1afa34843d86cef2fead9858ce8b96d6ef7bab95b	61	3000000	\N	\N	\N
277	141	51	addr_test1qpdzxprt59yxh2saksj2m4gtp3cllehgwtz6vkqljupygc2k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq9q9dxq	\\x005a23046ba1486baa1db424add50b0c71ffe6e872c5a6581f9702446156a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x5a23046ba1486baa1db424add50b0c71ffe6e872c5a6581f97024461	61	3000000	\N	\N	\N
278	141	52	addr_test1qqyln39wv9a7s7fgkrjzzhtzj9eya57cg039qkgdh24uvt6k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqfdu5pm	\\x0009f9c4ae617be87928b0e4215d6291724ed3d843e250590dbaabc62f56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x09f9c4ae617be87928b0e4215d6291724ed3d843e250590dbaabc62f	61	3000000	\N	\N	\N
279	141	53	addr_test1qrlaph7xqgzd2570ax6jcf98nlrg6xq3zd2rg0axenhs9gzk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqdsvlnf	\\x00ffd0dfc60204d553cfe9b52c24a79fc68d18111354343fa6ccef02a056a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xffd0dfc60204d553cfe9b52c24a79fc68d18111354343fa6ccef02a0	61	3000000	\N	\N	\N
280	141	54	addr_test1qrk489yqfzyy5l0hn4l2mc2tgl3pwc8kqkqeaz2ucc9pkcjk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqvrml2e	\\x00ed53948048884a7df79d7eade14b47e21760f605819e895cc60a1b6256a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xed53948048884a7df79d7eade14b47e21760f605819e895cc60a1b62	61	3000000	\N	\N	\N
281	141	55	addr_test1qrzheh64g26l5slefs8s5h99jn07aarl3qj7q2zuqfl4rc6k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq2rhzn9	\\x00c57cdf5542b5fa43f94c0f0a5ca594dfeef47f8825e0285c027f51e356a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xc57cdf5542b5fa43f94c0f0a5ca594dfeef47f8825e0285c027f51e3	61	3000000	\N	\N	\N
282	141	56	addr_test1qzsvj39amncge7ggn65grsduyhvuzc5qmwwyvzle93p8gezk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqpq8yuf	\\x00a0c944bddcf08cf9089ea881c1bc25d9c16280db9c460bf92c42746456a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xa0c944bddcf08cf9089ea881c1bc25d9c16280db9c460bf92c427464	61	3000000	\N	\N	\N
283	141	57	addr_test1qqfqhcm325e5vjxyhdq0w0pzu7syjxdcd4vyzvm54h2n472k4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq7jx8an	\\x00120be37155334648c4bb40f73c22e7a04919b86d58413374add53af956a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x120be37155334648c4bb40f73c22e7a04919b86d58413374add53af9	61	3000000	\N	\N	\N
284	141	58	addr_test1qzjuk6cdq2uyp2kj3ucfu5hrh22gkf363u4kelg6ehdvlhzk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqy3hlga	\\x00a5cb6b0d02b840aad28f309e52e3ba948b263a8f2b6cfd1acddacfdc56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xa5cb6b0d02b840aad28f309e52e3ba948b263a8f2b6cfd1acddacfdc	61	3000000	\N	\N	\N
285	141	59	addr_test1qzmrnxzk2kncw9nkgrjmsmnqd4jtvw85ed3yazjmn9nemazk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpq0kz4f5	\\x00b639985655a787167640e5b86e606d64b638f4cb624e8a5b99679df456a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\xb639985655a787167640e5b86e606d64b638f4cb624e8a5b99679df4	61	3000000	\N	\N	\N
286	141	60	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	58421634445	\N	\N	\N
287	141	61	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
288	141	62	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
289	141	63	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
290	141	64	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
291	141	65	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
292	141	66	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
293	141	67	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
294	141	68	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
295	141	69	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
296	141	70	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
297	141	71	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
298	141	72	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
299	141	73	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
300	141	74	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
301	141	75	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
302	141	76	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
303	141	77	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
304	141	78	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
305	141	79	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
306	141	80	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
307	141	81	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
308	141	82	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
309	141	83	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
310	141	84	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
311	141	85	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
312	141	86	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
313	141	87	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
314	141	88	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
315	141	89	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
316	141	90	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
317	141	91	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
318	141	92	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
319	141	93	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
320	141	94	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
321	141	95	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
322	141	96	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
323	141	97	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
324	141	98	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
325	141	99	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
326	141	100	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
327	141	101	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
328	141	102	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
329	141	103	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
330	141	104	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
331	141	105	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
332	141	106	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
333	141	107	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
334	141	108	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
335	141	109	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
336	141	110	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
337	141	111	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
338	141	112	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
339	141	113	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
340	141	114	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
341	141	115	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
342	141	116	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
343	141	117	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
344	141	118	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
345	141	119	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843373792	\N	\N	\N
346	142	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	178500000	\N	\N	\N
347	142	1	addr_test1qquq7egdkp6aeuynftp82hgyg90xmr654fl0unk6arq4qljk4z60s93qqk2gthftw3tjxgrzw08fmc63ky52u2nxktpqdv2a45	\\x00380f650db075dcf0934ac2755d04415e6d8f54aa7efe4edae8c1507e56a8b4f81620059485dd2b745723206273ce9de351b128ae2a66b2c2	f	\\x380f650db075dcf0934ac2755d04415e6d8f54aa7efe4edae8c1507e	61	974447	\N	\N	\N
348	143	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	969750	\N	\N	\N
349	143	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842233745	\N	\N	\N
350	144	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
351	144	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49838205343	\N	\N	\N
352	145	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998928145422	\N	\N	\N
353	145	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4229207	\N	\N	\N
354	146	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
355	146	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998922204640	\N	\N	\N
356	147	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
357	147	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998917036235	\N	\N	\N
360	150	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	1000000	\N	\N	\N
361	150	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	8817823	\N	\N	\N
362	151	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998916864662	\N	\N	\N
363	152	0	5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg	\\x82d818582683581c599d72b5e3f5a40fb4c4eb809e904d101f908a419472f542bc7032b9a10243190378001a2a94baa3	f	\N	\N	3000000	\N	\N	\N
364	152	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5649990	\N	\N	\N
365	153	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998916684289	\N	\N	\N
366	154	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
367	154	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998911515884	\N	\N	\N
368	155	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
369	155	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5480177	\N	\N	\N
370	156	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
371	156	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998911345895	\N	\N	\N
372	157	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
373	157	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5310364	\N	\N	\N
374	158	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
375	158	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998906177490	\N	\N	\N
376	159	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
377	159	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5140551	\N	\N	\N
378	160	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
379	160	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4970738	\N	\N	\N
380	161	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
381	161	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998906007501	\N	\N	\N
382	162	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
383	162	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998905808250	\N	\N	\N
384	163	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
385	163	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998900639845	\N	\N	\N
386	164	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
387	164	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
388	165	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
389	165	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
390	166	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
391	166	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
392	167	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
393	167	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998900300043	\N	\N	\N
394	168	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
395	168	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
396	169	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
397	169	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
398	170	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
399	170	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
400	171	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
401	171	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
402	172	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
403	172	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998899620615	\N	\N	\N
404	173	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
405	173	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998894452210	\N	\N	\N
406	174	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
407	174	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998889283805	\N	\N	\N
408	175	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
409	175	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
410	176	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
411	176	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
412	177	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
413	177	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
414	178	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
415	178	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
416	179	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
417	179	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
418	180	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
419	180	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3981122	\N	\N	\N
420	181	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
421	181	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
422	182	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
423	182	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998888604377	\N	\N	\N
424	183	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
425	183	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
426	184	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
427	184	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
428	185	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
429	185	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
430	186	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
431	186	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
432	187	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
433	187	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3132057	\N	\N	\N
434	188	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
435	188	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2962244	\N	\N	\N
436	189	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
437	189	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2792431	\N	\N	\N
438	190	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
439	190	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998888434388	\N	\N	\N
440	191	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
441	191	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
442	192	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
443	192	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998888264399	\N	\N	\N
444	193	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
445	193	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2622618	\N	\N	\N
446	194	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
447	194	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	7111595	\N	\N	\N
448	195	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
449	195	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
450	196	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
451	196	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	6941782	\N	\N	\N
452	197	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
453	197	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1773553	\N	\N	\N
454	198	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
455	198	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
456	199	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
457	199	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
458	200	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
459	200	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
460	201	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
461	201	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998887415158	\N	\N	\N
462	202	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
463	202	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
464	203	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
465	203	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1603740	\N	\N	\N
466	204	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
467	204	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
468	205	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
469	205	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	6092717	\N	\N	\N
470	206	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
471	206	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998882246753	\N	\N	\N
472	207	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
473	207	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998877078348	\N	\N	\N
474	208	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
475	208	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998876908359	\N	\N	\N
476	209	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
477	209	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
478	210	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
479	210	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
480	211	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
481	211	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5922904	\N	\N	\N
482	212	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
483	212	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
484	213	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
485	213	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
486	214	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
487	214	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
488	215	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
489	215	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5753091	\N	\N	\N
490	216	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
491	216	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
492	217	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
493	217	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
494	218	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
495	218	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
496	219	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
497	219	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4150935	\N	\N	\N
498	220	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
499	220	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3981122	\N	\N	\N
500	221	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
501	221	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3811309	\N	\N	\N
502	222	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
503	222	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
504	223	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
505	223	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5413465	\N	\N	\N
506	224	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
507	224	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998871739954	\N	\N	\N
508	225	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
509	225	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
510	226	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
511	226	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3641496	\N	\N	\N
512	227	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
513	227	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998870211461	\N	\N	\N
514	228	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
515	228	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998869362220	\N	\N	\N
516	229	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
517	229	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5243652	\N	\N	\N
518	230	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
519	230	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
520	231	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
521	231	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
522	232	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
523	232	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
524	233	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
525	233	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
526	234	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
527	234	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998864193815	\N	\N	\N
528	235	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
529	235	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3981122	\N	\N	\N
530	236	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
531	236	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998859025410	\N	\N	\N
532	237	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
533	237	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
534	238	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
535	238	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
536	239	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
537	239	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
538	240	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
539	240	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
540	241	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
541	241	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5073839	\N	\N	\N
542	242	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
543	242	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3811309	\N	\N	\N
544	243	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
545	243	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
546	244	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
547	244	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
548	245	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
549	245	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998853857005	\N	\N	\N
550	246	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
551	246	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
552	247	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
553	247	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
554	248	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
555	248	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
556	249	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
557	249	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3715335	\N	\N	\N
558	250	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
559	250	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3545522	\N	\N	\N
560	251	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
561	251	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
562	252	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
563	252	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
564	253	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
565	253	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4150935	\N	\N	\N
566	254	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
567	254	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	7288146503	\N	\N	\N
568	255	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1251548136066	\N	\N	\N
569	255	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	1251548377819	\N	\N	\N
570	255	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625774188909	\N	\N	\N
571	255	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	625774188909	\N	\N	\N
572	255	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312887094455	\N	\N	\N
573	255	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	312887094455	\N	\N	\N
574	255	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156443547227	\N	\N	\N
575	255	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	156443547227	\N	\N	\N
576	255	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78221773614	\N	\N	\N
577	255	9	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	78221773614	\N	\N	\N
578	255	10	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39110886807	\N	\N	\N
579	255	11	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39110886807	\N	\N	\N
580	255	12	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39110886806	\N	\N	\N
581	255	13	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39110886806	\N	\N	\N
582	256	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
583	256	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1269340223425	\N	\N	\N
584	257	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
585	257	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39105718401	\N	\N	\N
586	258	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
587	258	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	78216605209	\N	\N	\N
588	259	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
589	259	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39105718401	\N	\N	\N
590	260	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
591	260	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39100549996	\N	\N	\N
592	261	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
593	261	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78221603625	\N	\N	\N
594	262	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
595	262	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	625769020504	\N	\N	\N
596	263	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
597	263	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	156438378822	\N	\N	\N
598	264	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
599	264	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
600	265	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
601	265	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78221433636	\N	\N	\N
602	266	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
603	266	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78216265231	\N	\N	\N
604	267	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
605	267	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1269335055020	\N	\N	\N
606	268	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
607	268	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	78211436804	\N	\N	\N
608	269	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
609	269	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	156433210417	\N	\N	\N
610	270	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
611	270	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	156428042012	\N	\N	\N
612	271	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
613	271	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
614	272	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
615	272	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39105718402	\N	\N	\N
616	273	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
617	273	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1269329886615	\N	\N	\N
618	274	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
619	274	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312881926050	\N	\N	\N
620	275	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
621	275	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
622	276	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
623	276	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
624	277	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
625	277	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625774018920	\N	\N	\N
626	278	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
627	278	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	312881926050	\N	\N	\N
628	279	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
629	279	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	625763852099	\N	\N	\N
630	280	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
631	280	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	1251543209414	\N	\N	\N
632	281	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
633	281	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	156427872023	\N	\N	\N
634	282	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
635	282	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
636	283	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
637	283	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78211096826	\N	\N	\N
638	284	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
639	284	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
640	285	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
641	285	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
642	286	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
643	286	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	312876757645	\N	\N	\N
644	287	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
645	287	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	156427702034	\N	\N	\N
646	288	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
647	288	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
648	289	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
649	289	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
650	290	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
651	290	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	156422533629	\N	\N	\N
652	291	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
653	291	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	312876587656	\N	\N	\N
654	292	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
655	292	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
656	293	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
657	293	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	312876247854	\N	\N	\N
658	294	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
659	294	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
660	295	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
661	295	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156443207425	\N	\N	\N
662	296	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
663	296	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
664	297	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
665	297	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
666	298	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
667	298	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78205928421	\N	\N	\N
668	299	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
669	299	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
670	300	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
671	300	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
672	301	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
673	301	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	312871079449	\N	\N	\N
674	302	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
675	302	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1269324718210	\N	\N	\N
676	303	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
677	303	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
678	304	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
679	304	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39100549996	\N	\N	\N
680	305	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
681	305	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
682	306	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
683	306	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4490561	\N	\N	\N
684	307	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
685	307	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	312865911044	\N	\N	\N
686	308	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
687	308	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625768850515	\N	\N	\N
688	309	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
689	309	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
690	310	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
691	310	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4490561	\N	\N	\N
692	311	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
693	311	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
694	312	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
695	312	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4490561	\N	\N	\N
696	313	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
697	313	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39100380007	\N	\N	\N
698	314	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
699	314	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4150935	\N	\N	\N
700	315	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
701	315	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39105718402	\N	\N	\N
702	316	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
703	316	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	3981122	\N	\N	\N
704	317	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
705	317	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4490561	\N	\N	\N
706	318	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
707	318	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
708	319	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
709	319	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	1251538041009	\N	\N	\N
710	320	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
711	320	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39105548413	\N	\N	\N
712	321	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
713	321	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	625758683694	\N	\N	\N
714	322	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
715	322	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	1251532872604	\N	\N	\N
716	323	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
717	323	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
718	324	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
719	324	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
720	325	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
721	325	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
722	326	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
723	326	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	312860742639	\N	\N	\N
724	327	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
725	327	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312876757645	\N	\N	\N
726	328	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
727	328	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625768340900	\N	\N	\N
728	329	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
729	329	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
730	330	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
731	330	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
732	331	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
733	331	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39100549997	\N	\N	\N
734	332	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
735	332	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4150935	\N	\N	\N
736	333	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
737	333	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
738	334	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
739	334	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78200760016	\N	\N	\N
740	335	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
741	335	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39100210195	\N	\N	\N
742	336	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
743	336	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
744	337	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
745	337	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
746	338	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
747	338	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
748	339	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
749	339	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4490561	\N	\N	\N
750	340	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
751	340	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625763172495	\N	\N	\N
752	341	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
753	341	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39100040206	\N	\N	\N
754	342	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
755	342	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	3471683	\N	\N	\N
756	343	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
757	343	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
758	344	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
759	344	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
760	345	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
761	345	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39095211602	\N	\N	\N
762	346	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
763	346	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
764	347	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
765	347	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78195591611	\N	\N	\N
766	348	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
767	348	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78190423206	\N	\N	\N
768	349	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
769	349	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4150935	\N	\N	\N
770	350	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
771	350	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
772	351	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
773	351	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
774	352	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
775	352	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4490561	\N	\N	\N
776	353	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
777	353	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4490561	\N	\N	\N
778	354	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
779	354	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39095381591	\N	\N	\N
780	355	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
781	355	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	3132057	\N	\N	\N
782	356	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
783	356	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	15732687854	\N	\N	\N
784	357	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	5	\N
785	357	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1269314483365	\N	\N	\N
786	358	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
787	358	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999996820111	\N	\N	\N
788	359	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
789	359	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999993650122	\N	\N	\N
790	360	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
791	360	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	2822839	\N	\N	\N
792	361	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
793	361	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	4999996820287	\N	\N	\N
794	362	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
795	362	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	6826447	\N	\N	\N
796	363	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
797	363	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3647130	\N	\N	\N
\.


--
-- Data for Name: withdrawal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.withdrawal (id, addr_id, amount, redeemer_id, tx_id) FROM stdin;
1	46	7288321200	\N	254
2	46	17797262056	\N	256
3	65	3463730872	\N	356
4	46	12269137707	\N	356
\.


--
-- Name: ada_pots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ada_pots_id_seq', 14, true);


--
-- Name: block_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.block_id_seq', 1329, true);


--
-- Name: collateral_tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collateral_tx_in_id_seq', 2, true);


--
-- Name: collateral_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collateral_tx_out_id_seq', 2, true);


--
-- Name: cost_model_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cost_model_id_seq', 14, true);


--
-- Name: datum_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.datum_id_seq', 5, true);


--
-- Name: delegation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delegation_id_seq', 53, true);


--
-- Name: delisted_pool_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delisted_pool_id_seq', 1, false);


--
-- Name: epoch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_id_seq', 14, true);


--
-- Name: epoch_param_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_param_id_seq', 14, true);


--
-- Name: epoch_stake_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_stake_id_seq', 320, true);


--
-- Name: epoch_sync_time_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_sync_time_id_seq', 13, true);


--
-- Name: extra_key_witness_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.extra_key_witness_id_seq', 1, false);


--
-- Name: ma_tx_mint_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_mint_id_seq', 44, true);


--
-- Name: ma_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_out_id_seq', 50, true);


--
-- Name: meta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meta_id_seq', 1, true);


--
-- Name: multi_asset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.multi_asset_id_seq', 19, true);


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

SELECT pg_catalog.setval('public.reverse_index_id_seq', 1327, true);


--
-- Name: reward_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reward_id_seq', 238, true);


--
-- Name: schema_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schema_version_id_seq', 1, true);


--
-- Name: script_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.script_id_seq', 9, true);


--
-- Name: slot_leader_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slot_leader_id_seq', 1329, true);


--
-- Name: stake_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_address_id_seq', 68, true);


--
-- Name: stake_deregistration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_deregistration_id_seq', 1, true);


--
-- Name: stake_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_registration_id_seq', 33, true);


--
-- Name: treasury_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.treasury_id_seq', 1, false);


--
-- Name: tx_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_id_seq', 363, true);


--
-- Name: tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_in_id_seq', 663, true);


--
-- Name: tx_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_metadata_id_seq', 19, true);


--
-- Name: tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_out_id_seq', 797, true);


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
-- Name: delisted_pool delisted_pool_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delisted_pool
    ADD CONSTRAINT delisted_pool_pkey PRIMARY KEY (id);


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
-- Name: epoch unique_epoch; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch
    ADD CONSTRAINT unique_epoch UNIQUE (no);


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
-- Name: epoch_stake unique_stake; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_stake
    ADD CONSTRAINT unique_stake UNIQUE (epoch_no, addr_id, pool_id);


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

