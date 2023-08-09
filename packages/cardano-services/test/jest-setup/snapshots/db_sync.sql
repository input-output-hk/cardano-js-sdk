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
1	1033	1	0	8999989979999988	0	81000010010109857	0	9890155	100
2	2014	2	87299903776960	8912690085932634	0	81000010006123481	0	4166925	200
3	3012	3	176426805052978	8735327556560293	88235632263248	81000010006123481	0	0	298
4	4025	4	262033015107268	8564971198974587	172985779794664	81000010006123481	0	0	411
5	5005	5	347682727097013	8413198338902370	239108927877136	81000010001903419	0	4220062	514
6	6021	6	431814710883797	8272167905304460	296007381665867	81000009993062309	0	9083567	601
7	7004	7	502128138987241	8151066679213017	346795188737433	81000009993062309	0	0	689
8	8013	8	573857525764315	8029338236128228	396794245045148	81000009976164521	0	16897788	803
9	9002	9	654150909815376	7899289819118678	446549294901425	81000009976164521	0	0	911
10	10001	10	733143808006562	7770390272612849	496443932082292	81000021986711083	0	587214	1013
11	11002	11	810847710791411	7642406074799492	546724227698014	81000021986711083	0	0	1133
12	12006	12	887271771539405	7517933054335167	594759186567209	81000035970633107	0	16925112	1235
13	13021	13	962451103775267	7392819020116137	644693905475489	81000035970633107	0	0	1327
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (id, hash, epoch_no, slot_no, epoch_slot_no, block_no, previous_id, slot_leader_id, size, "time", tx_count, proto_major, proto_minor, vrf_key, op_cert, op_cert_counter) FROM stdin;
1	\\x73f305ee8305acf6f0571b87718af520cd0b3fa3bcdc664ec80d52ee1d62e7e4	\N	\N	\N	\N	\N	1	0	2023-08-16 11:22:07	11	0	0	\N	\N	\N
2	\\x5368656c6c65792047656e6573697320426c6f636b2048617368200000000000	\N	\N	\N	\N	1	2	0	2023-08-16 11:22:07	23	0	0	\N	\N	\N
3	\\x19fb5b7298b0cab0aaf86fbfcacb00545329b338fffea29181ff21042194a77e	0	2	2	0	1	3	4	2023-08-16 11:22:07.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
4	\\x74330bae5c2820c8bb49228ac52f3395f29da5738439f7476011b706f22f1f72	0	3	3	1	3	4	4	2023-08-16 11:22:07.6	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
5	\\xd48915a02439c27928fa0d2c1f2aaf4731fa7981333a0dda6184600d25cf635e	0	14	14	2	4	5	265	2023-08-16 11:22:09.8	1	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
6	\\x11ca38bc4f38c6d40d9a85a0974e6d08f344c08bd3ceead83b1fba6e7d43a160	0	17	17	3	5	6	4	2023-08-16 11:22:10.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
7	\\xf190a318c13a584a0a33fca754641a31e87c2c51960da02860300d8c890156ef	0	34	34	4	6	6	341	2023-08-16 11:22:13.8	1	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
8	\\xa1465caf359b2f4639c2fbe56edca9fbf9fbd03ca04e057a9b24ea4b0fd3778b	0	35	35	5	7	8	4	2023-08-16 11:22:14	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
9	\\xc4992a8bf2df919eb973aab0be1806024a9b15481cc615a671abf831b2cac3bd	0	36	36	6	8	3	4	2023-08-16 11:22:14.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
10	\\x150aa21cd01489842c52396a5458defbc33ec0f1b3e965cca5e0be1e763f9192	0	38	38	7	9	4	4	2023-08-16 11:22:14.6	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
11	\\xf352fcfbaa0402e0ff154d3c97a3b5d0ae38bcad95acb37f9d1001c341c9cd14	0	62	62	8	10	6	371	2023-08-16 11:22:19.4	1	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
12	\\x49815a213f670ea5039c5d23f3cec03900da9b94cb61cb81405d56861cf03344	0	71	71	9	11	12	399	2023-08-16 11:22:21.2	1	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
13	\\xea15fa9dbd309ca75d024aeadfb81cd8c8bb8c23f1754a01a588935f5a14d56d	0	82	82	10	12	3	655	2023-08-16 11:22:23.4	1	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
14	\\xfff601fb498b3819f9871a636e6067bb874df5af7949895702cbc02af9b6b0d3	0	87	87	11	13	12	4	2023-08-16 11:22:24.4	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
15	\\x137bcfd3717a05766a01d296aad469979a7194d0a39c747ba7bf9fa2d2df9d81	0	105	105	12	14	15	265	2023-08-16 11:22:28	1	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
16	\\x44344a0a2a6adb4917eed152d96c6f012f658d56f7ebfd414a52f05ee68a4948	0	109	109	13	15	5	4	2023-08-16 11:22:28.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
17	\\x15df472bb0ba5e3db7bf422865948e1068eb9608a0aacaa7be78900372e73992	0	112	112	14	16	4	4	2023-08-16 11:22:29.4	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
18	\\xbb8cb15cebe151b01150427962af7cc161aec99ae44a37d8b96bcf758030fe3f	0	114	114	15	17	8	341	2023-08-16 11:22:29.8	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
19	\\x717d0db425f57e411c40db8404c44dbdffb5f03d21b1137ed0555ff28be87b5a	0	119	119	16	18	5	4	2023-08-16 11:22:30.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
20	\\xc5cb794ec50a58d8d0ff59bbe119201ae9a3f207406cb00aa1d46a6458d35a4b	0	158	158	17	19	12	371	2023-08-16 11:22:38.6	1	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
21	\\xcdc6b9b15c482b1f1be440aa02c8fc3bd9f19f3b516c9bfbcc4f636e77fdae67	0	169	169	18	20	5	399	2023-08-16 11:22:40.8	1	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
22	\\x999284eea364d6d40e4a27071a18776619a0a8df85c0a65dc7eea2cc4fc68844	0	171	171	19	21	3	4	2023-08-16 11:22:41.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
23	\\x6de0ab6cdc54f7a47ff7f2f4f7ff1ae5bce1c016f74772cd6ec4e089a98adf70	0	181	181	20	22	12	592	2023-08-16 11:22:43.2	1	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
24	\\x2bfa54c4b7e22d26f01103f7ccc9827d0512681280dcd5a95dc15e9ab533c093	0	183	183	21	23	12	4	2023-08-16 11:22:43.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
25	\\xaa21ef2f1402528c84043457404797e807eeac0431353adf9f42746a0f3fadcf	0	193	193	22	24	3	265	2023-08-16 11:22:45.6	1	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
26	\\x04b855d480e200804e05af0c9cc9d3d8ae3a4e5828b0b6c880070fb1c03a557e	0	238	238	23	25	5	341	2023-08-16 11:22:54.6	1	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
27	\\x0c7b24fcedef19b38eedfe2c9fb3ba68c18f9f7d32094f8c14621c00988b75a3	0	245	245	24	26	27	4	2023-08-16 11:22:56	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
28	\\x1db7be0ad798fd95b143ec3123d47a21aa2e7cf671328134e2acf57ace68fc6c	0	257	257	25	27	28	371	2023-08-16 11:22:58.4	1	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
29	\\x528f8dc004cbd632543d9c43fc04bc6ccf638912cacc41cf1e93c8e20119cfe7	0	259	259	26	28	3	4	2023-08-16 11:22:58.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
30	\\x824d16de11a7f7f175c129e10873a7a2e4a774af6c8a2b7c214856b3f4a66a0e	0	269	269	27	29	30	399	2023-08-16 11:23:00.8	1	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
31	\\xf2c2f6dd3bcae5f5a8d2af593299d371957876717955a0157f22c7048b8294cd	0	274	274	28	30	28	4	2023-08-16 11:23:01.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
32	\\x5d6f97b9f7dbb7f73f4096b5469d8c208e12c4ae48a4a15dba3258c27ebfede5	0	281	281	29	31	15	655	2023-08-16 11:23:03.2	1	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
33	\\xc554952fba59775eb9eb478a2b47587d19b3bb20df2f11c06a7e8d8f44961cde	0	292	292	30	32	4	265	2023-08-16 11:23:05.4	1	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
34	\\x4831795288597ac80288aeb5c8894350699aa37badd77b080d960765360d0dd1	0	294	294	31	33	8	4	2023-08-16 11:23:05.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
35	\\xf54aaeccc4e9763298853c9a0b56b6cbe0c54b77075ad81981321e8d0a44e515	0	339	339	32	34	15	341	2023-08-16 11:23:14.8	1	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
36	\\x63aaaddccc8f5c3aa2a0c0670b6ba8d94369f7c762c22bd57e6252e437d4a7c5	0	356	356	33	35	5	371	2023-08-16 11:23:18.2	1	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
37	\\x32ed7894217fca2b43abdaf8c54842443963b5753557bb054206212a6a3f122c	0	361	361	34	36	28	4	2023-08-16 11:23:19.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
38	\\x6d5c791b408bea824321dc1dc29a325d25de960b78b5cfa65d1b83c74e3bb357	0	381	381	35	37	28	399	2023-08-16 11:23:23.2	1	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
39	\\x127478b3bce345f232b2b6150e20ddd98d4298fb0977c7384ef36f5298694dab	0	385	385	36	38	15	4	2023-08-16 11:23:24	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
40	\\x8aa4cea589dee31571cad336084a8f008c3419f590c11549e4062bb7fd67a1da	0	396	396	37	39	4	655	2023-08-16 11:23:26.2	1	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
41	\\x5e14048dfa71a2721cde8934b12f5bd304e74a29efd84596d19086c0ad1ebc7a	0	404	404	38	40	6	4	2023-08-16 11:23:27.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
42	\\xa0f4d98b591fd194219491d9053929e6c3a5a7d3bb9d86055d9a9ef61dd5a5f6	0	415	415	39	41	5	265	2023-08-16 11:23:30	1	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
43	\\xbbba7333b78ae66f41728f150cb5420ae04cecc9cfef7bf68ba08cb374b51f5b	0	421	421	40	42	30	4	2023-08-16 11:23:31.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
44	\\x7261a696a78c6c48234fad0b6b97ee5471b3f5e89a1c0f84939d3343706984a8	0	426	426	41	43	12	341	2023-08-16 11:23:32.2	1	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
45	\\x174788a4fb53c561830dea98339ad454e098d38b186d8946930309ed820e51c7	0	433	433	42	44	8	4	2023-08-16 11:23:33.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
46	\\x8ae089ce320a8629636c3d2039803a51c28d542d71f0c263508b4ee4d945aba0	0	441	441	43	45	46	371	2023-08-16 11:23:35.2	1	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
47	\\x1c4c26dce1a220a2c6727d73f9d0358aaf3bd08e409d0af010f56ac4e0700021	0	453	453	44	46	46	399	2023-08-16 11:23:37.6	1	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
48	\\xc39c01fdca96957dace14b37991e94da9639346701608e2e4d382ed73a1d88d3	0	459	459	45	47	12	4	2023-08-16 11:23:38.8	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
49	\\xbf542a096c2369d9959b5d4c61039f97e3b1c255534fc31c695687fbddee2661	0	462	462	46	48	28	655	2023-08-16 11:23:39.4	1	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
50	\\xf5f7e16e909f6409d97d9f205b8dada8706720c8a29dc2e8e799783d171ca059	0	467	467	47	49	15	4	2023-08-16 11:23:40.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
51	\\x75c23744d3c33b2b6c8cc21e1101a0a4d8aa28901b940d847908e388ae74890f	0	498	498	48	50	15	265	2023-08-16 11:23:46.6	1	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
52	\\xae59972e4287cf0577935e6749c6bf4b979fe7e39b9a0d894052aa2baf722a28	0	499	499	49	51	12	4	2023-08-16 11:23:46.8	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
53	\\xc8e4d75cad1d9301b913f7be1674a7261b3870070cae1c410b32ec045fd81df0	0	508	508	50	52	12	341	2023-08-16 11:23:48.6	1	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
54	\\xdb7d2a4f840c1460659ee2b985eba906c4317066da5fc7dcb03b48cfde4f6afa	0	512	512	51	53	28	4	2023-08-16 11:23:49.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
55	\\x59fb9ebf22b4d629bf6dfa7999d934cab0b63a573533f6b4d6253098fcc0a304	0	551	551	52	54	15	371	2023-08-16 11:23:57.2	1	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
56	\\x3a78d757dade19d399eac7a0208862905e1dc8bd385e7dc9b1eb3e87cf8be06a	0	552	552	53	55	15	4	2023-08-16 11:23:57.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
57	\\x56152d64c9851e972e5266314da0858da0e7babb487a8d020b8a3175922ec810	0	558	558	54	56	6	4	2023-08-16 11:23:58.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
58	\\x95d9fe16e52a5211808aefe54f884663e3f1aaa1bc51d62b016d228ea42b2589	0	562	562	55	57	5	399	2023-08-16 11:23:59.4	1	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
59	\\x676dfde0b9580b2ce30c2c7175c0ab8c9601c678f2c275329f4fb41f209b7439	0	579	579	56	58	5	655	2023-08-16 11:24:02.8	1	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
60	\\x3e9c753f4b5f5f39d639f22aea28a3a6b0d2013b47d2236b1b8959513ecd1172	0	582	582	57	59	12	4	2023-08-16 11:24:03.4	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
61	\\xc590919f7fd850c94d8e5d0da3cc3c3ca9443381f5c12fc1f4b837f4845658d5	0	591	591	58	60	28	265	2023-08-16 11:24:05.2	1	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
62	\\x91b0ae45892d4f93d2d0bf20626444a03101d94214d6f80f44dde8e654160e4f	0	592	592	59	61	30	4	2023-08-16 11:24:05.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
63	\\xfa68d3b0ca4ca7b987ac33792edc049274d87fb802b7b99ed6dc63882708182e	0	613	613	60	62	30	341	2023-08-16 11:24:09.6	1	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
64	\\x8e282af8a290c4628fe10b9f94ea8b24110730fee760a28b57f9c06f95dfc037	0	615	615	61	63	3	4	2023-08-16 11:24:10	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
65	\\x9749858837736121686186897e2b90a5f24eefd42e208d8b1ed2a8dc22704406	0	635	635	62	64	3	371	2023-08-16 11:24:14	1	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
66	\\x771288ce59f93f77c77d8b5d8af65099555b06689421faa94fbeb7e9ddca1003	0	658	658	63	65	8	399	2023-08-16 11:24:18.6	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
67	\\x1fcd331e7b99dc2e43c1d73262d1134fe8305121706f790c847dae65425a70f3	0	663	663	64	66	8	4	2023-08-16 11:24:19.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
68	\\xf646dd246bebb0214f9607198b8df1a06b33e5e32d350273d1c0f3cd8afddf15	0	675	675	65	67	46	655	2023-08-16 11:24:22	1	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
69	\\xdf47989a3e152ca108aec836a07fea1da3e4d16efa103bb1e6f978cfab9b2502	0	691	691	66	68	46	265	2023-08-16 11:24:25.2	1	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
70	\\xcd9fad3cda5616110f3311459b08c0bcb92f1a37edaed123c32172a93244cda2	0	734	734	67	69	3	341	2023-08-16 11:24:33.8	1	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
71	\\xf7a32fc6d1fdaa72feece8967519a75402271c1d543c7921715f11f2483333b6	0	736	736	68	70	5	4	2023-08-16 11:24:34.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
72	\\xfacdbf55e0e5fc2d23a153508a1484a30843d50541e2e9d6cf4ca1b2e047e0a9	0	753	753	69	71	27	371	2023-08-16 11:24:37.6	1	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
73	\\x63e7aa464fdede0af9494d79108a6d5eefb158f807527f2ca2e8a7407f022fc9	0	754	754	70	72	3	4	2023-08-16 11:24:37.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
74	\\xffa27dbfc95bfebd7b6ca6f26616cb72081a12e20209369784bdc6e4497f3176	0	760	760	71	73	15	4	2023-08-16 11:24:39	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
75	\\x82210124c9949c5c8d6a8685bc0e7826ab2a0ac3336cc518684bc38b415f4317	0	778	778	72	74	6	399	2023-08-16 11:24:42.6	1	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
76	\\x8f913fce66d16c0274969bbfdeb62f2dbec5d3d20535acb30d8a8b76fed930a5	0	789	789	73	75	28	592	2023-08-16 11:24:44.8	1	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
77	\\xf508f3f4b252596ca4914ddcd2140e6c093b47b013ed2fd26bc5c1f6a8f89bce	0	800	800	74	76	5	399	2023-08-16 11:24:47	1	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
78	\\x973df67dcc7fd770bc3e470b01a4415f01863e2ee5639d2fcf97845a9887130a	0	804	804	75	77	4	4	2023-08-16 11:24:47.8	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
79	\\x4ed6dc9078c9da5589fba5269f449bfa61f5dd954cc2bb5fc8513f7f80757900	0	816	816	76	78	30	441	2023-08-16 11:24:50.2	1	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
80	\\xba3fc900ede5acb659663341acdc947895eece3c742b2d47ba66ee10125dfae5	0	828	828	77	79	8	265	2023-08-16 11:24:52.6	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
81	\\x06be26768e82eab75d17d1ca52ba95c0d38c026a1c99b829027a64772c5b4567	0	833	833	78	80	12	4	2023-08-16 11:24:53.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
82	\\x3e1761ae687aa0f0ac6f2929f21f1ab6bdcfd9bf588a05cefe034c2b136cf420	0	836	836	79	81	15	4	2023-08-16 11:24:54.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
83	\\x68e90e09a2b923740ca04ee8d9f75d691a7461b115eef4b7f228ce8e01edd948	0	842	842	80	82	12	341	2023-08-16 11:24:55.4	1	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
84	\\x05b8abc7572128d6605c1cb27539cbe34947c869ecdb14c722b023376ee16245	0	845	845	81	83	8	4	2023-08-16 11:24:56	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
85	\\x38c1ab7263a3793762701c03e85a59b1063734af18b5b08b9262d5636d2853de	0	853	853	82	84	12	371	2023-08-16 11:24:57.6	1	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
86	\\x796b85a8b09fe4576de823b30850c429b6de05dfefc98a261235aa2b81be3958	0	866	866	83	85	46	399	2023-08-16 11:25:00.2	1	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
87	\\xc1f0e53d617bd2a6c41caf4063613d1849ffc3a709fcb1ada1d53dcd66e6e5ff	0	882	882	84	86	30	592	2023-08-16 11:25:03.4	1	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
88	\\x03b641b9dd43dde43dfcf8661cb4981afd0fb83a50f5fe9163e2af2bf1285835	0	896	896	85	87	3	399	2023-08-16 11:25:06.2	1	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
89	\\xb40960261340416c394a8b06c06afb06701a7f64a8bc3b456c6d37372ecad444	0	910	910	86	88	6	441	2023-08-16 11:25:09	1	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
90	\\x421d11950eef6f105d9a263065519eb7f678b5cee8a5448162ba2e6e082800f0	0	928	928	87	89	28	265	2023-08-16 11:25:12.6	1	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
91	\\x6fba9b85c94d7f9ef1ef4d88cec743fa86dd06d414d8b0dfb9f6bc38b51d02f5	0	944	944	88	90	27	341	2023-08-16 11:25:15.8	1	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
92	\\x2555abdeacd6e18fba561e69bc80dda6c1ba56278a92824f911c797bf691c345	0	954	954	89	91	15	371	2023-08-16 11:25:17.8	1	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
93	\\xe3d27720263485e337b54b458a05621db5474b23b40fc220b0acff4edbda14f4	0	980	980	90	92	15	399	2023-08-16 11:25:23	1	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
94	\\xde231597cf39498221bedc697ec10346fbd9b1c7b04696251379eaf8014fe8f4	0	981	981	91	93	6	4	2023-08-16 11:25:23.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
95	\\x04011a31d5666d41fecd030fe8596d3ef71556ee3f03991a0ef6046fd1931de5	0	986	986	92	94	6	4	2023-08-16 11:25:24.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
96	\\x917c745529782e44e588cb615df3d1d5839d293d9fc9e7aa5baeca90c83ab523	0	989	989	93	95	12	656	2023-08-16 11:25:24.8	1	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
97	\\x80613acb7ebeb8004bb86995cf525939187f1dab300854aed21e109381aa91ef	0	991	991	94	96	46	4	2023-08-16 11:25:25.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
98	\\x76d5de74a0d4808fe5c8df59a2b87dd2e5dcc9c49553b81b83c5aa2bb2ce9067	0	993	993	95	97	5	4	2023-08-16 11:25:25.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
99	\\xb0917b42be17f60b0f9ea08a66334f95dccbb154ac39b50960b750dcb6618e32	0	997	997	96	98	30	4	2023-08-16 11:25:26.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
100	\\x03494e9941bd7d1a88f4811e8ae5cb4364058b9585d2fd5a88f1e9656bde62b7	1	1033	33	97	99	3	399	2023-08-16 11:25:33.6	1	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
101	\\x6ff37d842feb5a1064d4fc891c0855151f19019c24eaf5f3c1afa0f13ab8c2af	1	1040	40	98	100	6	441	2023-08-16 11:25:35	1	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
102	\\xd9d767e6a858fe7202f55c48fd628d91074f8cc8a3a779dfce389377dacb0718	1	1046	46	99	101	12	4	2023-08-16 11:25:36.2	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
103	\\x7b0351ca7a98949f4045f6b1576bf8515ae16cbd35f8f1103e1c9a48f5605374	1	1068	68	100	102	28	265	2023-08-16 11:25:40.6	1	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
104	\\xdf7bff15d93fdf531923089004412c369d1006b4955a9653c82fead9717b725e	1	1069	69	101	103	8	4	2023-08-16 11:25:40.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
105	\\x57c5c0e2aea08276fbd9a5a14a05daab6eb5dd8edbdf4104f599299cd27b7393	1	1076	76	102	104	15	4	2023-08-16 11:25:42.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
106	\\xf01dc2a63d34f18c4b2b99553865ce521afc86c6a66c3e6c9e8926c3b8a281ca	1	1084	84	103	105	30	341	2023-08-16 11:25:43.8	1	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
107	\\x588de0da0636ad98ce6a53833d3432bf3ace45841bf732a05ac737fafd9cdf42	1	1094	94	104	106	6	371	2023-08-16 11:25:45.8	1	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
108	\\xd419e641ffdac599b61e41646eaa9f23c93dd38bb1e25ae59c9b8cc825346388	1	1102	102	105	107	27	4	2023-08-16 11:25:47.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
109	\\xf6207f04a150bca06c319027f54567b817dd4afa6e5e712000e3a6bc006f369e	1	1107	107	106	108	46	399	2023-08-16 11:25:48.4	1	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
110	\\xb13ebb549da3aba9250b5de3df040aaf8cf939e531605353dbb5dc360d13d622	1	1113	113	107	109	5	4	2023-08-16 11:25:49.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
111	\\x9ef1cb5dcc26a81d012c78bed2a3f57e0f0fc3b8ee0e70123b4f55b577559d3f	1	1117	117	108	110	15	656	2023-08-16 11:25:50.4	1	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
112	\\x3d6f4c0271bb8961488490a5fed0f83379a6484019a1d3cf6964827e39dd4884	1	1128	128	109	111	30	399	2023-08-16 11:25:52.6	1	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
113	\\xf9a9fe9c7ff27472b9ab929c86903d61c85364be1d74ad0d916402cf9adba2a3	1	1143	143	110	112	5	441	2023-08-16 11:25:55.6	1	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
114	\\x5de0d5aca3f57f5854343ea38e95a39d9ca0b87b18986c6414d58c3abd692ebe	1	1148	148	111	113	5	4	2023-08-16 11:25:56.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
115	\\xbacdffd57a5db18a54f9678cb1aaf4932b821a0e0ad603ac6339928c3391c39f	1	1154	154	112	114	30	274	2023-08-16 11:25:57.8	1	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
116	\\x60e8b6751b43d53c101f926c7da7a61757506386e36c616204e6b1f045b4c484	1	1159	159	113	115	27	4	2023-08-16 11:25:58.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
117	\\x7ecedfb051b8f897e2cd67c4043a81b4abf744fcf658b60afff44f5d90ed1045	1	1174	174	114	116	3	352	2023-08-16 11:26:01.8	1	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
118	\\xe987542fee6572d0e139341fd0faa2c02055d967eebabf28ca49bbf8826b8999	1	1180	180	115	117	28	4	2023-08-16 11:26:03	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
119	\\x160413b16e6057801ed2a18cad156b00a9f104a56140f56ed73170be4c7ee661	1	1182	182	116	118	8	245	2023-08-16 11:26:03.4	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
120	\\x22ce8d126ec0bd42113dde7a7541326668d1339a86e81ea90162c7a28a92bbb8	1	1185	185	117	119	3	4	2023-08-16 11:26:04	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
121	\\x378cc9e09d7324c43cf455cebd0573469aeef1360cdeeadd68876d9fe61d7b5a	1	1190	190	118	120	6	4	2023-08-16 11:26:05	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
122	\\x1f725cad74345d8dda27ea4a590746b56d46ac97541de03bff7068f308c58744	1	1194	194	119	121	28	343	2023-08-16 11:26:05.8	1	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
123	\\xc43f9453a9dd46dfdd24c0f368f2005860850c936e20c89c6e5b31a717a27ddb	1	1223	223	120	122	28	284	2023-08-16 11:26:11.6	1	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
124	\\xcea1b7d669ca4d3ba5ae70c1eb0d55378b30adfe28793d2f8402868f947a5eae	1	1257	257	121	123	46	258	2023-08-16 11:26:18.4	1	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
125	\\x76ef11c07e0237e8d1526a341115e3ba3cc421c59525c0976b21e72434c3707e	1	1268	268	122	124	4	2445	2023-08-16 11:26:20.6	1	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
126	\\xc1b5e841d1d9891d3bfc08f376f7ce5ae5f90bd927589be2b1fff5102ab2b9a2	1	1283	283	123	125	3	246	2023-08-16 11:26:23.6	1	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
127	\\x513e1b0ad0ce43a80d87aea15b3bdd8daedcd0d7e76f4fabfb87f86ef2a12a23	1	1290	290	124	126	15	4	2023-08-16 11:26:25	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
128	\\x61c5df2455b8218b774856ca1792c6cb9ce3cec26c2642a6c747eb7f77c31d51	1	1294	294	125	127	15	2615	2023-08-16 11:26:25.8	1	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
129	\\xf7a62aa3fc1eb8ac5d9796f3026fbeb33b1ed4d702894c276f7d0a94e0deda50	1	1296	296	126	128	27	4	2023-08-16 11:26:26.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
130	\\x28834fe93dadf6324ba69f2aac2c69092d7f0a3ec20eb80dba04034c74d9f593	1	1301	301	127	129	5	4	2023-08-16 11:26:27.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
131	\\x839448565358a50fa6ae872b8b5ec173926f0a2a8dccafa95598514968777681	1	1303	303	128	130	27	469	2023-08-16 11:26:27.6	1	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
132	\\x56a582740cc1fcb5850804783ebb1eebdb6df4c0c1ab6b05f13b6958b766c717	1	1311	311	129	131	5	553	2023-08-16 11:26:29.2	1	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
133	\\x05c624bca842210e9ccc94d25a245e90b2e682003c2e8c112d670acfa794310e	1	1313	313	130	132	4	4	2023-08-16 11:26:29.6	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
134	\\x44411f86b9fc5cc275a2317f29a26d83a1075fd55273ac61e4b9731f2137f1d2	1	1329	329	131	133	3	1755	2023-08-16 11:26:32.8	1	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
135	\\xc7d2792f90ff004234fd88313d24ebb793f6ee78cbaa1db56ee6e812adb4b9e3	1	1338	338	132	134	46	671	2023-08-16 11:26:34.6	1	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
136	\\xf0c98cbcd67ba3f72651b64a11a7ddf004258b0af171f208028d5bf89762cb37	1	1358	358	133	135	15	4	2023-08-16 11:26:38.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
137	\\xc40653806086e2fc4bc6d0852cf343141f664d06d1f837c71e56d122ef6da70e	1	1360	360	134	136	8	4	2023-08-16 11:26:39	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
138	\\x6c4e6e1ac1d5ea701d9a8eeef6b7c93812343ad510437c09a19a589d094eb8a4	1	1364	364	135	137	28	4	2023-08-16 11:26:39.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
139	\\xf3c423648c818c5446ea74d4952c655085af536700f6419fb5148ec3abe8b8b3	1	1394	394	136	138	8	4	2023-08-16 11:26:45.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
140	\\x8118371bf8107e3d79f09a8f1c218a1855ad4fabddb7e00c08f152d4f201ebe1	1	1419	419	137	139	30	4	2023-08-16 11:26:50.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
141	\\x12399180ca03296cdc736b402461afbc9163717aa2776ba197a67291f0e4bef8	1	1420	420	138	140	5	4	2023-08-16 11:26:51	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
142	\\xb18f47bed0ddbd070a9080f1de90a43f4dbfe03cace2d976e6303628b9876117	1	1423	423	139	141	30	4	2023-08-16 11:26:51.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
143	\\x8d95fb44746c22e5cc9ce8b87ddd7891b0d96ce794aebd4b7bbc8e86b46e5753	1	1440	440	140	142	3	4	2023-08-16 11:26:55	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
144	\\x30cea075f79c4a2e3a052d0de3b0312cde6b5158f1749b4777c2e23d98c00dec	1	1481	481	141	143	5	4	2023-08-16 11:27:03.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
145	\\x918a324fbac3318aff159b17b868ed739aa5635493cb48794129064022de8338	1	1482	482	142	144	8	4	2023-08-16 11:27:03.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
146	\\x2a38b81e5f616bac93dd9d28f5bc2b058bf97629355f129a59be45036ef4bda6	1	1484	484	143	145	8	4	2023-08-16 11:27:03.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
147	\\x4d83d4468f5732f45ee35c2f6a10ed6f9653c14a039c6821969a6326d67f10e1	1	1498	498	144	146	8	4	2023-08-16 11:27:06.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
148	\\x3a6f4d89b67fb8326f8f2713400379ccd8309198e5a6bcf702535c38699115ac	1	1502	502	145	147	30	4	2023-08-16 11:27:07.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
149	\\x76df5ce74c50c5c2356a4b3f303e031c6c637e13e37d42f5fa5c30e68889e882	1	1532	532	146	148	5	4	2023-08-16 11:27:13.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
150	\\xb224a20759a06e6f5b08919d585783c01fe5bbfba92313e128191fbfc5050a9c	1	1534	534	147	149	4	4	2023-08-16 11:27:13.8	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
151	\\xbe4b2b964d950ed17805e3a7911609e76cd1df213017641cb718cc961788331a	1	1556	556	148	150	15	4	2023-08-16 11:27:18.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
152	\\x60a4b4c04369df90d8ec241fe64dd8c9b01026c9c26b49b77031d09f93674562	1	1562	562	149	151	15	4	2023-08-16 11:27:19.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
153	\\x081eda80c51e8917df2869bf21c8099fce6356e1ab12330bcb8e8398504ce61a	1	1586	586	150	152	3	4	2023-08-16 11:27:24.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
154	\\x34e07542b1e4f9c694d0b90ed875e4c3b1ef072680c0add530e786b91fb61f3a	1	1593	593	151	153	5	4	2023-08-16 11:27:25.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
155	\\xa758da8587192ce03ad49116803d354dbb2465cb203cce56a2f927da8c31b9d7	1	1602	602	152	154	5	4	2023-08-16 11:27:27.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
156	\\x4ed54607bf4eb2f2517621ab6b9ab050f30eccb4a481ec248a50ae50912bee9c	1	1606	606	153	155	46	4	2023-08-16 11:27:28.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
157	\\x65da7b63ddc68188bcab2171369d9b404e1fa843c86a9cbdf020904f030c33c5	1	1612	612	154	156	5	4	2023-08-16 11:27:29.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
158	\\xde355c8c626db4a2ddc6423c41667740fbc2a3223f088c71325f2d56bc2c07c3	1	1629	629	155	157	12	4	2023-08-16 11:27:32.8	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
159	\\x09d3ca3432d9bf7ed29615e526e8a569123876a7ae3a75c6197b1c69fc6bfc1d	1	1638	638	156	158	3	4	2023-08-16 11:27:34.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
160	\\xd601fd77e29cbd9e7484f5aa0cc42c8e927f3072d9e45bf70af45267d59fe195	1	1643	643	157	159	5	4	2023-08-16 11:27:35.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
161	\\xda6aefa8b0e989bbc341fccfe4b438bb4e377386f01e81416c6bac2a19c2da95	1	1644	644	158	160	46	4	2023-08-16 11:27:35.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
162	\\x52e6656746f7e3dffd874f99d55feb9785e2986c1b2337e2a98ce20b647b365d	1	1652	652	159	161	4	4	2023-08-16 11:27:37.4	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
163	\\x3e2cc22f114da48deb8fae24af86a3766c5ed9351a24c65e840a3ab144646684	1	1653	653	160	162	27	4	2023-08-16 11:27:37.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
164	\\x92ca2c7f79a9e9a8357562c2de33feea16ca24f3f8044fa673ca189436482d9a	1	1656	656	161	163	15	4	2023-08-16 11:27:38.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
165	\\xa279705be83a6f1ec1e325ac2f2e9c1e580b6b5f0833378b707473bc5538815a	1	1667	667	162	164	15	4	2023-08-16 11:27:40.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
166	\\x3ba6c799c6426d4d93c9f5bb639afd3caaccbad4cf96e9bd0c86dbdf00484ca3	1	1670	670	163	165	8	4	2023-08-16 11:27:41	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
167	\\x1cef623b665b66b6e43b82a0fced0e25ff2a3064aac11a6185ffaffd86a66eb7	1	1672	672	164	166	6	4	2023-08-16 11:27:41.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
168	\\x9c8b7b8cb96043405b793327b6f07ee1875e87b66d51c0c429070f748f95b5f6	1	1678	678	165	167	12	4	2023-08-16 11:27:42.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
169	\\x4c048778eb7625687564b601e43491b02f3767eb4b240e1b9228e4e1272f48b6	1	1679	679	166	168	4	4	2023-08-16 11:27:42.8	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
170	\\x8167ea6bb1137e8c5ab279fe15668735e80acf1797ff76a6ed8981ceedc825f8	1	1683	683	167	169	12	4	2023-08-16 11:27:43.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
171	\\xde5f29776c6c2cdd1f24b4aeac8da66da9047921f15c8bae8d6e3e06724a6262	1	1702	702	168	170	27	4	2023-08-16 11:27:47.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
172	\\x189684b1bc37b06c1be65eb2161d9ca96bd70a78a0ef19035324523721785649	1	1709	709	169	171	27	4	2023-08-16 11:27:48.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
173	\\xe7df264a1d74e7d79ae4c89c0f41c01a189ef189a6cd98abd0bcad3fb431dcf8	1	1712	712	170	172	15	4	2023-08-16 11:27:49.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
174	\\xe83f9097bdb88f01d58b8150ebeffd8de97a74ca53b919787e54823390b48784	1	1718	718	171	173	6	4	2023-08-16 11:27:50.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
175	\\x1958da75bf40c915d9aa0af324d5d411bfa7d2d095f3740efe9427c5fe61f9cf	1	1727	727	172	174	8	4	2023-08-16 11:27:52.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
176	\\x24c97eba52ab2af073f4de2d36980e3279811c1b9ce7064fe035ef8bd3d565ec	1	1734	734	173	175	46	4	2023-08-16 11:27:53.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
177	\\x97bbfc58545585988d5805311e9ae0bf4b7e5acd118e8aa4952a47c3093a0784	1	1746	746	174	176	6	4	2023-08-16 11:27:56.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
178	\\x533b9be3371b7d647388e6fe1c75d03d40f58d1d5f6d05bf9d52cfb216889ba5	1	1755	755	175	177	30	4	2023-08-16 11:27:58	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
179	\\x34b7f2b8578bd9c9f0746281587f77a5853d17ffa9727c28f1f8333c900f7b1e	1	1756	756	176	178	8	4	2023-08-16 11:27:58.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
180	\\xf47eda8c81928bad77c53c3b0d44b09f906e0e013b837ecb2401244393a28218	1	1782	782	177	179	27	4	2023-08-16 11:28:03.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
181	\\xec8948f7e378589889107eef18878393eed1a13746fa32971ceb77527dc76908	1	1786	786	178	180	27	4	2023-08-16 11:28:04.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
182	\\x66752e3df8c24af6b62b40b0db47ca5cfb0005c3bc82df67022cc61b957c6258	1	1808	808	179	181	12	4	2023-08-16 11:28:08.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
183	\\x28edf2c17706b3146ee9541fa08dfa2d6ce8214d13cbef12bb7bd30194537d0b	1	1814	814	180	182	27	4	2023-08-16 11:28:09.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
184	\\x7b59d84476e50650b7ace9b1c2bfc47d085a1ce15ea311ca37aa118b6025dcc1	1	1817	817	181	183	8	4	2023-08-16 11:28:10.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
185	\\x5e99a68934c87436ab2bfa1e8fb36a0209013ef6ebccb604e533b1ebd5039b30	1	1837	837	182	184	27	4	2023-08-16 11:28:14.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
186	\\x26931c78fd712ecc90729ad4e05778e1b54b0b64d1d971efa82ba0d3a8e9c642	1	1872	872	183	185	46	4	2023-08-16 11:28:21.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
187	\\x78fbae47703092e1cafef4ea966a050033bc3f0118751d1eeab17381ff9541c1	1	1874	874	184	186	4	4	2023-08-16 11:28:21.8	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
188	\\x118f098c6b0a86f6cc7f7c56b0c7535c8d14435061db10b3946abb64e839b5a6	1	1877	877	185	187	46	4	2023-08-16 11:28:22.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
189	\\xfd49090e862a497634875b1f24e9c13d0f6a9a58add85184f19f525ab440ee71	1	1905	905	186	188	12	4	2023-08-16 11:28:28	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
190	\\xa69687037c4dedba07b22c5595833fa9b83a7357e265ac99fe8ef8bb865a03a3	1	1926	926	187	189	12	4	2023-08-16 11:28:32.2	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
191	\\x945194a3e4ad2031284c91f39961e938d0c780eb808b32fa7d9287fb3caa1395	1	1928	928	188	190	46	4	2023-08-16 11:28:32.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
192	\\x0599de9d7165e01fe016c66ee927668c13626413ab32fa7d72f99394ccbd91c8	1	1936	936	189	191	6	4	2023-08-16 11:28:34.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
193	\\x03733fbc4cf05c1cb0a7dfcdddc6deb54b1513f610a2fb7e572414f6e83c612c	1	1938	938	190	192	8	4	2023-08-16 11:28:34.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
194	\\x568e0eb6c0b7d39921ddece63edd839343966c67075025c3f325a110f7a0e3a3	1	1941	941	191	193	12	4	2023-08-16 11:28:35.2	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
195	\\xa4a56fa8c3a3bce25aee0bf61c3426f50e7c7677d990b36a320902aa92efa693	1	1948	948	192	194	5	4	2023-08-16 11:28:36.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
196	\\x4993702f048df1946541c7c3238d99ef364c1dff07ee69fdd5b032b32fcac325	1	1949	949	193	195	12	4	2023-08-16 11:28:36.8	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
197	\\x51da0a88ed06775400b87d260feef5e9aade2cc64829fe93211d3d2ba103e2c2	1	1972	972	194	196	27	4	2023-08-16 11:28:41.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
198	\\xecb8f9591d471b8273fdf44a1bb6fc78e18424cc7738bf49983712cebebffe8f	1	1992	992	195	197	5	4	2023-08-16 11:28:45.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
199	\\x7f754569015ed84e01ebe7c91c425367c741fd4988f8e7d20becb29159ef14e8	1	1994	994	196	198	30	4	2023-08-16 11:28:45.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
200	\\xafb638e931c80d57c3933ea0a565b475db39984d887a2a1a97c7fac29d914b20	2	2014	14	197	199	8	4	2023-08-16 11:28:49.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
201	\\x5b1ffca12c319ce3b1cd5c066e5c69ef5ddca529fd57fd8809162ff43804bff8	2	2024	24	198	200	28	4	2023-08-16 11:28:51.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
202	\\xe1df18330f8fedc0b545e81034c0c15ee3fa7ed3792a537b2e912a4bb884ac71	2	2026	26	199	201	3	4	2023-08-16 11:28:52.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
203	\\xe61d9561164317252127205383d1007012e8b23397db8d2eb8a1f81caab01edb	2	2027	27	200	202	5	4	2023-08-16 11:28:52.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
204	\\xcb215bbf507773633b71da868070bea47894b71acaf5a929f81c4ceb0046cea0	2	2059	59	201	203	3	4	2023-08-16 11:28:58.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
205	\\xf0a48aca22103b9ff872b41e956b53e1513c169dc39484fa5d91f436b853911b	2	2060	60	202	204	8	4	2023-08-16 11:28:59	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
206	\\x2dc38b06bb504f7b281ca74a710230a9e028823e332545f1b77d050bff947717	2	2082	82	203	205	3	4	2023-08-16 11:29:03.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
207	\\x3f92a943b6f2e2238746fdd864cb56f8711354679ca2b0113b26f0033a52a06f	2	2088	88	204	206	46	4	2023-08-16 11:29:04.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
208	\\xa88533853fa504fa224fd90ab02ed995fb66dc329fbf57ef9d99a80dec120f62	2	2093	93	205	207	27	4	2023-08-16 11:29:05.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
209	\\x6412921e957561598d1a06415828e2ffe25a8b223f0918dc3f6a269ee044a1a9	2	2110	110	206	208	4	4	2023-08-16 11:29:09	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
210	\\xb3f174251a274097de15a3dd9caee796e4e6e8c4e0479d84a259f4caec28f25b	2	2115	115	207	209	5	4	2023-08-16 11:29:10	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
211	\\x6e90c6577750a24c59af9508c980ab5b92758034e1ce1f66dcaf11ac8d8e489a	2	2121	121	208	210	4	4	2023-08-16 11:29:11.2	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
212	\\x17ac07b290938694d020a09367465fcc5465b9d0f93a455fe858e02756a95039	2	2150	150	209	211	28	4	2023-08-16 11:29:17	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
213	\\x39ba3c8c7fd295115c996e5f1a59e1604b0d14255d7c8f71f0cae69adea05d81	2	2159	159	210	212	3	4	2023-08-16 11:29:18.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
214	\\xf9ac9a79d980cefb2d3f8f91f578c48acb913f6965422587c4426eede31c09c2	2	2171	171	211	213	6	4	2023-08-16 11:29:21.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
215	\\x6d161039b746a2d544952f25939393166aadd2974aedf2623d492b674a2fd25c	2	2175	175	212	214	4	4	2023-08-16 11:29:22	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
216	\\x6fa8c07bfe014285e8ef4a062c2270228a78b1e48a81533c0e316617b67252ff	2	2185	185	213	215	27	4	2023-08-16 11:29:24	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
217	\\xc06c983e407ff827284f89e68361757b6dc755a5d8ce6d22d2448c9465772d5f	2	2202	202	214	216	8	4	2023-08-16 11:29:27.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
218	\\xd4b6b161d3550b488001909ee056578292c00e265d327b9a79a22f10bed86b2e	2	2207	207	215	217	12	4	2023-08-16 11:29:28.4	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
219	\\xe5b1d745d790fd6c56e9ccf33bdd435767633a24132698fa0da47901ce1ae5d2	2	2224	224	216	218	28	4	2023-08-16 11:29:31.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
220	\\xb939150bedffb0a9b5e6df6de0e1f2d736fcb848ad5bab91dc62a896f7fa6e7c	2	2259	259	217	219	27	4	2023-08-16 11:29:38.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
221	\\x8016787c70ab062fcdf266432c40152484d3c178d83f638005241313221722b5	2	2288	288	218	220	5	4	2023-08-16 11:29:44.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
222	\\x17fe201d17cfcde85d59045623cefd1bd2503efd01ceefb1d82dd7d0fef0ed2c	2	2324	324	219	221	30	4	2023-08-16 11:29:51.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
223	\\xc32209970beb1d3d0b9bb324a670db66e2ac7a2ad4bd1d404e7bf82bdda45cd2	2	2327	327	220	222	3	4	2023-08-16 11:29:52.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
224	\\x91c2c5c31126e6625a312d3cd6aded0c83871aa212ea119668812a00b9f49712	2	2330	330	221	223	4	4	2023-08-16 11:29:53	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
225	\\xc176a9202f7b9e26a75998cc0e561541997099cc2599d16bc691d31d727d6dd5	2	2337	337	222	224	27	4	2023-08-16 11:29:54.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
226	\\x26f5af5b0f0acabbadc53b0cca20918e38b50d32adb148956ff92725ed399e99	2	2347	347	223	225	5	4	2023-08-16 11:29:56.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
227	\\xfd8f67263ccbc1368dcd413fe8f9b7a009bd0065d631aaff837e99ba48c74015	2	2361	361	224	226	12	4	2023-08-16 11:29:59.2	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
228	\\xa072bdab285acc46b83c10674180f54d4360bd8a6e7a9995ba1a1f03f94c8ec9	2	2368	368	225	227	5	4	2023-08-16 11:30:00.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
229	\\x05775610f0e146cb092b746a43d81945d5b435f2b9890e449df31e9233765303	2	2373	373	226	228	28	4	2023-08-16 11:30:01.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
230	\\x47c1c7b8038277bb2963abdae6346fae39e14da757cf774180c59e8cef6d64bf	2	2375	375	227	229	6	4	2023-08-16 11:30:02	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
231	\\xd037246a2a9262266d0a5f843cf2e1c9a0d684571dc5ee0d69cefc731d0e78cf	2	2379	379	228	230	12	4	2023-08-16 11:30:02.8	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
232	\\x5fbf6c02b58d7b641b13b765cdfee5adbe01cc875a8c48c255ff9c964179cd82	2	2389	389	229	231	28	4	2023-08-16 11:30:04.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
233	\\x0be6336eabe40953c49c3f55153a95f6e1dadb437aa0caa6e34c0431d9bf0089	2	2390	390	230	232	30	4	2023-08-16 11:30:05	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
234	\\x204dfd7961f3390ab3ce7c0cc5aa7eb7476ad316e91794c0533981011cdbfbbf	2	2391	391	231	233	4	4	2023-08-16 11:30:05.2	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
235	\\x2f25e14a327b6c7ab085a2345153864813c38e9f0debfc07a26485d394126c6e	2	2404	404	232	234	27	4	2023-08-16 11:30:07.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
236	\\x3c498c760a8641e26ded1dbefabbda3be57d8761981000856b087bfb00e87798	2	2405	405	233	235	3	4	2023-08-16 11:30:08	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
237	\\xffeeb5cb6cb8ff350d6db95bcc93a3f059d3c7a0d4b30c2962979db3471fc66c	2	2421	421	234	236	28	4	2023-08-16 11:30:11.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
238	\\xabcec7a3fa27720b4cb3991e949cc9bdf709bee05532445c248c590704249d9c	2	2442	442	235	237	8	4	2023-08-16 11:30:15.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
239	\\xd20b657ae129d82c4333e87cea249869fd546846cba82738ff51fc5da442c887	2	2463	463	236	238	28	4	2023-08-16 11:30:19.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
240	\\x3d8ec7e48c9cef395ef334b06ec7f5a0a039b89bb30f291d75320b26a0fae786	2	2476	476	237	239	12	4	2023-08-16 11:30:22.2	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
241	\\x46b92504b80b550250f80e7a114f433411ce896a22edb4cc4e1434dcc11a03dc	2	2482	482	238	240	15	4	2023-08-16 11:30:23.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
242	\\x1b07e85039067b033bd0bf2545d9d3712f7918dca869b481fa7c67d4e2fb8244	2	2491	491	239	241	28	4	2023-08-16 11:30:25.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
243	\\xda7f61affa1bbfd1d99ce2c617c6b35099775899bce3b53cef9e66a5992ba564	2	2493	493	240	242	8	4	2023-08-16 11:30:25.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
244	\\xf2bd63b55edefdee6655a9a3c0ad6e7303a0452a316ee94d42811b9b6686bd0a	2	2498	498	241	243	30	4	2023-08-16 11:30:26.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
245	\\x6bbeb9f352a71138704ca5d1df65890e73aa229e6e15b877081595df86adc75a	2	2499	499	242	244	6	4	2023-08-16 11:30:26.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
246	\\xeae7d1cd1d108e6bb618a99ddf3a1b3d8e9bd89f01eb0a57d99fee130b823f17	2	2512	512	243	245	30	4	2023-08-16 11:30:29.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
247	\\x7ca00e3a5fd18d070ed6ddd0e52f1c9d18bd18317fef1d1e70fb4174e9a2a694	2	2520	520	244	246	12	4	2023-08-16 11:30:31	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
248	\\x86e76154adcf6225c5c55146be504aed984cb62d071d0a1a6eab59fa7a468ea1	2	2536	536	245	247	15	4	2023-08-16 11:30:34.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
249	\\xdf27579297867d0a6626754f065682a4bfaf5b0a91c75fd57852abd2e57933b5	2	2539	539	246	248	28	4	2023-08-16 11:30:34.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
250	\\x53fbc4781d94c8fb8c1f329eba98628960c5bd0023367282b47697fc36286834	2	2542	542	247	249	12	4	2023-08-16 11:30:35.4	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
251	\\xe27757b1c8ea4f29406b90aa56a03cac8bde54a1d52a352b30663f091e32af2c	2	2549	549	248	250	6	4	2023-08-16 11:30:36.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
252	\\x7f5ad995fc4de074ff482aa4fc0db0ee0ebe6cf6feec1b23c160bf1de51cb844	2	2568	568	249	251	15	4	2023-08-16 11:30:40.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
253	\\x001b69cca48aaee8e8b551d41de98b6d4728fb6d199b248a8fcac608ec5170a1	2	2593	593	250	252	30	4	2023-08-16 11:30:45.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
254	\\x674bf64352f2275acd187dab2b8c50cbb8f353f36dc46712282e8db1b97213ea	2	2594	594	251	253	6	4	2023-08-16 11:30:45.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
255	\\x329958e951b3b38ce6c0ced73e5cb6d4a13941625009498aa35a2d7ab981c2db	2	2607	607	252	254	6	4	2023-08-16 11:30:48.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
256	\\x80e7341df5c7d2aa44803d95ef70312328d5ba7f1ee4cb5c84b5c8390f3b8ace	2	2612	612	253	255	3	4	2023-08-16 11:30:49.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
257	\\x8634cb6351d67f1acd419dc0a9495952e02d9cf95ffd13c7256c42217c4a47b0	2	2613	613	254	256	6	4	2023-08-16 11:30:49.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
258	\\x37c0eeb9ca35005f17ce7a6f649d842d26f3fed3583842d8d56ebfe94762b9d2	2	2626	626	255	257	5	4	2023-08-16 11:30:52.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
259	\\x7afc8ce0eb23ecf2886cea2cd9f25df378811af89efb6053913c59ba3a8617ac	2	2632	632	256	258	8	4	2023-08-16 11:30:53.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
260	\\x2a9bbcc2bd2ec18caa3faf57490c6226574a69e13fb76622a2b0f9e1ecefa7b2	2	2635	635	257	259	8	4	2023-08-16 11:30:54	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
261	\\x8cc9bc0d03946f1bd66a051d491b4186f06ce5ed474371898db7aecac4e80d29	2	2650	650	258	260	3	4	2023-08-16 11:30:57	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
262	\\xc26c9b50c8375a55a6a1977b6e120ddc81d6c34cc960ebc46a3b984d8490ccb1	2	2666	666	259	261	46	4	2023-08-16 11:31:00.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
263	\\x14dd73dff7b7dc20c5c2242064e46497a62b5ddcd7f1f3da7ccdd0b268fa9425	2	2673	673	260	262	30	4	2023-08-16 11:31:01.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
264	\\xfca763053aed1f2e2da92f83e4dd7ddd9d69b90270e603db35afa8b1d8e893b3	2	2676	676	261	263	15	4	2023-08-16 11:31:02.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
265	\\x2667117721fb7b7b9711cb309df86fa80c1033f05a1c0d61a9c174eca96471ec	2	2689	689	262	264	46	4	2023-08-16 11:31:04.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
266	\\x4bb62baee9cb7e443c4517ac9c17a76bfab55c7c749d160c147bddc1dc59e5cc	2	2707	707	263	265	4	4	2023-08-16 11:31:08.4	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
267	\\x9d45086cebbeb3538ca9a9ec9fc439a86d5e713318f815a03cc2401c556c7dbd	2	2713	713	264	266	4	4	2023-08-16 11:31:09.6	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
268	\\x8a3712d92db0bf37a5f0b11cfd9030e32ef07d2bbd35abc3cf8c4d48b91f82a8	2	2715	715	265	267	6	4	2023-08-16 11:31:10	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
269	\\x6d0d538d4b073b8e9a9b763d789c10ef70cc6b22dfa52836f3f5485c88e7d0f3	2	2718	718	266	268	46	4	2023-08-16 11:31:10.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
270	\\xf1d42b25656e881f1cf649fcdc98e9a266897b7d698d857295598db499bf59b1	2	2727	727	267	269	3	4	2023-08-16 11:31:12.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
271	\\x7f4c6825c5758c7e07bf8d075d967a93db00ef5c628e802e1f22e25d15e2f1f4	2	2735	735	268	270	27	4	2023-08-16 11:31:14	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
272	\\xd4072878b1fc3d685ed358067790e4c8b80820e8109ccbb01cc568992d202796	2	2746	746	269	271	3	4	2023-08-16 11:31:16.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
273	\\x86fef1827b5b218d8236fad6c967a49a67c06885ab4b5871b67642d708a265ed	2	2751	751	270	272	8	4	2023-08-16 11:31:17.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
274	\\x833c021435b9275229d839fc939c242fc328348fdd1f222ca48f14ac76608815	2	2753	753	271	273	5	4	2023-08-16 11:31:17.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
275	\\x98d254fddf957bc6376fa56f81db5ac008e5d081ec48cbbb9947b379116853c6	2	2757	757	272	274	27	4	2023-08-16 11:31:18.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
276	\\x08e1568fb578498acd4d076f66890cc283d60ac36f303b58182fe519456af8c1	2	2758	758	273	275	6	4	2023-08-16 11:31:18.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
277	\\x0560e1217210787079eea9ad8bf30f97ba1d303e43be7b81005c577e37c84525	2	2787	787	274	276	46	4	2023-08-16 11:31:24.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
278	\\x855f9c7d8621245ba5dd94fbf6ba8f5223f5323537f6e8c385acb3c7fcdf2352	2	2789	789	275	277	5	4	2023-08-16 11:31:24.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
279	\\x72a44937c5aa816c9277454a92a25955ca50da4a053bf7f9407e0664b3ff75dd	2	2813	813	276	278	6	4	2023-08-16 11:31:29.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
280	\\x1ba3692d988a809dbd8bcfac06f8c88468985dd5a67cd1498365ae0d93a6e4c4	2	2831	831	277	279	4	4	2023-08-16 11:31:33.2	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
281	\\x1f530e13631ff5da684750588407bbde18bf8a2b97546a05a8734034208ee6c9	2	2849	849	278	280	46	4	2023-08-16 11:31:36.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
282	\\x6d65a524f12ce5f6c32c4a4682d3e6b0f9a5c03bc7bec15c8c1bdf7cf0006081	2	2877	877	279	281	5	4	2023-08-16 11:31:42.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
283	\\x46e4ceeae8c76291a55226c9001df21e90c32f267646847f3cf908204418d381	2	2878	878	280	282	12	4	2023-08-16 11:31:42.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
284	\\xcf5cc4ecbcbded9d682501e7ba707e56212e7846a9ad09e0d33964d55d685525	2	2890	890	281	283	5	4	2023-08-16 11:31:45	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
285	\\x79d22bfee16726e5721696a51e58fb9c61de2921ac4af413bfff00b87aeefac0	2	2898	898	282	284	5	4	2023-08-16 11:31:46.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
286	\\x4384435332103a93e2216eed80c3cc6a527e8de191f6121d68e8c1e5f2fb1057	2	2903	903	283	285	4	4	2023-08-16 11:31:47.6	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
287	\\xe4eaa4c425eda1115a077160c1feb86de332177fc1d54846d82fb343b94e51bc	2	2914	914	284	286	27	4	2023-08-16 11:31:49.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
288	\\xfe04202c49090c4c7e5629cf954c8c7dea44ba793f68e98bbf1f0d40f46f8405	2	2930	930	285	287	4	4	2023-08-16 11:31:53	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
289	\\x28c15d0b7dfb66d36429ff3ad2d5fb049b10d0909aa99dbc780c5efe38a03b54	2	2934	934	286	288	30	4	2023-08-16 11:31:53.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
290	\\xb37d3146b293e3a71d0a1176741e7d2f3e5ac21491a4577ed6dd7a1c89773fc5	2	2936	936	287	289	8	4	2023-08-16 11:31:54.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
291	\\xab015728fe308f22a39f040d6845aea84e47a5e94439b0491093efe645df6d16	2	2951	951	288	290	30	4	2023-08-16 11:31:57.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
292	\\x00a53277c0f2d4ef7e9c98d605d91610e34c92bcb1b3a52f661264018ef04877	2	2952	952	289	291	46	4	2023-08-16 11:31:57.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
293	\\x5660c2b7e7e8e5e2c6134a51106f4a5a57dde7dc1e8b9961000fb05804057bee	2	2963	963	290	292	3	4	2023-08-16 11:31:59.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
294	\\x7758ab6c15b68dbf708f471d0f5150169e1eeba169b0625925de9a5c991e681a	2	2966	966	291	293	12	4	2023-08-16 11:32:00.2	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
295	\\x2e24e08fdc7e2281ad7eb880e9781e821ded87c035bc26ec2dc8e7a2f0542dc7	2	2980	980	292	294	12	4	2023-08-16 11:32:03	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
296	\\xa0035dfa2ca6a15a861117ace9185720c10a1670d554f4a9758226f306f67330	2	2982	982	293	295	15	4	2023-08-16 11:32:03.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
297	\\xaec9e6d1bb5464ed4d991f7ee2a4874122b2861472f52763396df8f3eefcfad2	2	2995	995	294	296	5	4	2023-08-16 11:32:06	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
298	\\xfca89141634fd4fdcc0060ea29861e6186811d00baad16a7f4aa6f0ff1f3ecd2	3	3012	12	295	297	27	4	2023-08-16 11:32:09.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
299	\\xcd76d43dd53753a05a6b995624260e60f21da906a51340175674699f1d2f2bbe	3	3015	15	296	298	28	4	2023-08-16 11:32:10	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
300	\\x5ad0583a4eb73c1f0323ad9788cd10166b3b70004f6bea22109cbf6fb01549d7	3	3023	23	297	299	46	4	2023-08-16 11:32:11.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
301	\\x691a7e4a0fe3c26db7b229f458fce5c5e6d52d8679524238de2fe3996bf72a6b	3	3025	25	298	300	4	4	2023-08-16 11:32:12	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
302	\\xe1a09eb9ec0b6b2f2c6b78340bf79430e1be286ec8365621e11ea6e0335fe06e	3	3031	31	299	301	46	4	2023-08-16 11:32:13.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
303	\\xb8cac1215dff9576324a0e4e2b15c6fe5ed6433d9b24e953df41c995d1e5d6fb	3	3055	55	300	302	15	4	2023-08-16 11:32:18	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
304	\\x194a6814d341272b043142a2469e136bc892cab6e4892733963d24d83e3c937f	3	3079	79	301	303	4	4	2023-08-16 11:32:22.8	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
305	\\x7f38f577970a42f1597089cd122ceb9bb4c76624908c54df471ec363e18c9962	3	3096	96	302	304	12	4	2023-08-16 11:32:26.2	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
306	\\x6a369fac02e707d5bdc3f94162b2541d571ab3b0dcb05b2480232edcfc7908af	3	3113	113	303	305	30	4	2023-08-16 11:32:29.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
307	\\x64128def7ac38888a9ed9d1f6ac291e89ef82097235887ea61855cef732caae5	3	3118	118	304	306	5	4	2023-08-16 11:32:30.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
308	\\x6a6fcecf458a51b8ed184c12c61415f7f64f3237169a32464e859e03a59f1c80	3	3123	123	305	307	46	4	2023-08-16 11:32:31.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
309	\\x5b962fe0df7b043ab369c7ba15791d260598778f593f3244106ae8a5ca7798ab	3	3129	129	306	308	15	4	2023-08-16 11:32:32.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
310	\\xd2488545131e05793c7d2311a80ea165b1633d2d7860b6947bcfab29e0620534	3	3140	140	307	309	46	4	2023-08-16 11:32:35	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
311	\\xd8a82009cf5d2e7eb14b66b589f3c83b8b9cd254040536befd794d033b2e42cb	3	3150	150	308	310	46	4	2023-08-16 11:32:37	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
312	\\x965625e326420d1c8cc852aad96529de9345eb29c989253e95afefe5784bac8b	3	3155	155	309	311	5	4	2023-08-16 11:32:38	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
313	\\xed4a477d3a33d69dc29518ed54528a3ba892ac4c9301fdd704ea046dddf45f53	3	3181	181	310	312	15	4	2023-08-16 11:32:43.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
314	\\xea8b5dbf62eac1494b3bd7a926a07bcbd4c364d4415141b2e972094ceff976b4	3	3187	187	311	313	4	4	2023-08-16 11:32:44.4	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
315	\\x4ff57589b01766bc35684772120c60c2050f27185a7d599af0c3502929fc1443	3	3204	204	312	314	27	4	2023-08-16 11:32:47.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
316	\\x7897b5df5a6c2b23839cfee7ea292dcebf8350be40c611eeee8414c98b7eba9e	3	3211	211	313	315	4	4	2023-08-16 11:32:49.2	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
317	\\x58d9bb630396e2bd28467b2101ce4edd562b2bb8b434c69a768b62057f09fe7e	3	3217	217	314	316	28	4	2023-08-16 11:32:50.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
318	\\x87b0f3ef0e0179af776bce883c25ac8cffe508b66795632def91644d728c5ec9	3	3233	233	315	317	3	4	2023-08-16 11:32:53.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
319	\\xcdba35eede5b1fe224164ffc4736969404051f4f2d646a2f795ce51dafa43b01	3	3237	237	316	318	3	4	2023-08-16 11:32:54.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
320	\\xcff12af097374b6afaea07de517d8e89ccf1562d3394b8d86a813e9997ff4512	3	3239	239	317	319	30	4	2023-08-16 11:32:54.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
321	\\x65c84b4a174a13640c76457ea598dfdf0d39174771fcd637c9df638d4517c929	3	3250	250	318	320	28	4	2023-08-16 11:32:57	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
323	\\xd0f90f50b31bf3523e5ef8c9d8d56e3bbba6dbe873805173ac69962552e8447b	3	3253	253	319	321	27	4	2023-08-16 11:32:57.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
324	\\xe1752ecfad77fcb846b837e9299c93061d652e25514e0bfff2622bd5835539ef	3	3256	256	320	323	28	4	2023-08-16 11:32:58.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
325	\\x9d9b4c1a3b7748edfa8f90eb9c0afec3c245d2e0af209fe37def3e09398aa762	3	3264	264	321	324	27	4	2023-08-16 11:32:59.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
326	\\x3584a4c12406d3ad8de2e87517b3e3e29379d6d155f4d2826dcdb713e3a5faca	3	3273	273	322	325	12	4	2023-08-16 11:33:01.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
327	\\x87aaf3c52adcd87169eae2dc3fc63bfef11016df22e0d6f3b8a74dad763ee2ef	3	3285	285	323	326	27	4	2023-08-16 11:33:04	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
328	\\xe8259c3b29bcbfba45942883cb06e187516540b5fa6e4fcf73a9c830b6f89a78	3	3292	292	324	327	27	4	2023-08-16 11:33:05.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
329	\\xc6d40fa9c3ba67ea8416c4b834c61721fb45a19460875b9f77411a2fa27a7c2e	3	3297	297	325	328	5	4	2023-08-16 11:33:06.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
330	\\xbfc2c60af5c51d52842475c5527e9a05c3b84c05b180bf4d0bdfb01d7eca8fbb	3	3301	301	326	329	27	4	2023-08-16 11:33:07.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
331	\\x15c71112e5a54c10385252ca52f5e56ec0c2b8399e3ae68e16b8a386d72e37b7	3	3303	303	327	330	3	4	2023-08-16 11:33:07.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
332	\\x8ea7dfb3ff8a2a4ac1c3d42db05b1fcdea37f2c6741f19340e4ee84baa1e23ed	3	3314	314	328	331	46	4	2023-08-16 11:33:09.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
333	\\xc475752fcb7a36517d69c0a6839d32fb60c8a06128b97b2eb49a46747427f500	3	3337	337	329	332	6	4	2023-08-16 11:33:14.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
334	\\xc9b04b1a4b7f135281592619d29409542318d307135d7ecfd750783cd38da9b2	3	3338	338	330	333	5	4	2023-08-16 11:33:14.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
335	\\xcdac2d4e0e1d6fb66b3adadc175a11502a83d5c80db8a81d8f3c5a6cf5420234	3	3345	345	331	334	27	4	2023-08-16 11:33:16	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
336	\\x9951e454ac906a31577926e7339c088e43bfa128b80fbb49c1d837f396d7ba05	3	3364	364	332	335	3	4	2023-08-16 11:33:19.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
337	\\x8011ee207ba278bcaa29e8d765947a28a5c5eb51033be372b94fce48622f674a	3	3372	372	333	336	3	4	2023-08-16 11:33:21.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
338	\\x1429a25a5649dc3210bf275f76c56c8aa9c49006e37d2ec4bdd377b4571730fe	3	3390	390	334	337	3	4	2023-08-16 11:33:25	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
339	\\x386e5a8951fce5725048e7f7534a15bd016b7e37f05bb68ef237fa8af953b8b5	3	3402	402	335	338	46	4	2023-08-16 11:33:27.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
340	\\x0a41a03fe656f3837aa74f43a234f7b78992b2e9278135ef188f76de52e4716f	3	3421	421	336	339	28	4	2023-08-16 11:33:31.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
341	\\x9b9e074de9d869daf7d11bcf81c8ed663c66a1957567bae1176747f8e2ceed5f	3	3429	429	337	340	12	4	2023-08-16 11:33:32.8	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
342	\\x31718dd038d7fc7e35d1a7c3c16a86bcad5b64ececf8d80971b7ddab781f27fb	3	3430	430	338	341	12	4	2023-08-16 11:33:33	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
343	\\xcb1da7d0ee74a771239dbc3a787d8e49c02a83d424b587bde2f979edf84832ea	3	3438	438	339	342	12	4	2023-08-16 11:33:34.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
344	\\x5ef44549825254f981e0586a80180fe5bfadc9af906ff9eede2bf50b79e104ea	3	3441	441	340	343	46	4	2023-08-16 11:33:35.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
345	\\x9316edd5b8870bffe5137a0c0a93fce361dba3c3d60b35a83ab6f851b4822dd8	3	3459	459	341	344	8	4	2023-08-16 11:33:38.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
346	\\x1546519e46ce978f3e905bef0d1161ce3c2eb99a86baefac0f022b7e3e081a18	3	3472	472	342	345	46	4	2023-08-16 11:33:41.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
347	\\x00349d16a0828328125ed5c210350d3f1ecc01e66167198624c9a6bd4a326677	3	3475	475	343	346	12	4	2023-08-16 11:33:42	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
348	\\x7b7f89e570151bce189535e28040f9d532eb5fd169fbc3b21a939bbaabb0a66e	3	3480	480	344	347	46	4	2023-08-16 11:33:43	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
349	\\x8ff1076b8ee557b0df2ded5511c129fd72407f30224f82438a3b8b10e77cd8b0	3	3491	491	345	348	8	4	2023-08-16 11:33:45.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
351	\\x8e1819768f4858bcb23bc629030fc11411bb7208b7244a476d2da0c9fa3b86b7	3	3498	498	346	349	15	4	2023-08-16 11:33:46.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
352	\\x7db2f36781c6fdb86a0f64effb017c13059aa1d51bf4e7e1835aec37bd919043	3	3500	500	347	351	12	4	2023-08-16 11:33:47	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
353	\\x51dbea305054d9b93f9a2e98b06fa105b459e8df73c1115b13363125d049bf7e	3	3503	503	348	352	28	4	2023-08-16 11:33:47.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
354	\\x621cc186a5fc7d7b13e03fff3022d6bfa9be7c470faadac036332773fa31e8ac	3	3510	510	349	353	4	4	2023-08-16 11:33:49	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
355	\\xe1a4eb2daf9fb88d0f22217530834be65560fda70c6d71bbd3bdf24a7762ebf2	3	3523	523	350	354	46	4	2023-08-16 11:33:51.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
356	\\x0d156f4fd82328b3b1d1f0af066a5e9fa571bd5c731a33de4bb6db11cffce1d4	3	3524	524	351	355	46	4	2023-08-16 11:33:51.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
357	\\x1202b5cecf5083252bf1bd2fe0a4052d076c4d2dae46f8cc005328976929fe3e	3	3528	528	352	356	8	4	2023-08-16 11:33:52.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
358	\\x62925c0656800213253394b0aa6a0186e5b9f6830ed46c9cf7b660af18ec2e1e	3	3530	530	353	357	15	4	2023-08-16 11:33:53	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
359	\\xfa8f1a814dafe3fa1733e9e3f22a3e969c54ee2ac5940eaa8af29160515c2310	3	3533	533	354	358	28	4	2023-08-16 11:33:53.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
360	\\x5002f1e40a93bddf0712c01b60e70b0646f50b0973f877dcc52460cfeace0b91	3	3535	535	355	359	27	4	2023-08-16 11:33:54	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
361	\\x939748207f15f03878a9546d0dd769a509520516de76ad4fa289e2e83e90dee0	3	3571	571	356	360	4	4	2023-08-16 11:34:01.2	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
362	\\x9952cb969e448ca6ed0e57c7d155c65062af0b742a4a7cdf5f7e76a3a4d8f7e4	3	3577	577	357	361	27	4	2023-08-16 11:34:02.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
363	\\x32590837f297b9ad49b1526f2aed1ebccc00e3242a2e39079923ac3cad61a475	3	3591	591	358	362	12	4	2023-08-16 11:34:05.2	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
364	\\xb09650841b2638875bd8e5e92e5710fc6d2a6bd962ab4f6cd1820bce825c014c	3	3594	594	359	363	12	4	2023-08-16 11:34:05.8	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
365	\\xe0760ac0bed332869b61efe0f1d2d5bef3a4f44c4757fd6a6efb27d35bf5bd5b	3	3598	598	360	364	30	4	2023-08-16 11:34:06.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
366	\\x347dabd93d8629b8e6bcfff7f2fbe4131bf03eb1fbb9a703471aa759a7e92bfb	3	3615	615	361	365	8	4	2023-08-16 11:34:10	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
367	\\x09f48707b4ba9a066e5c0fab4302d72f503cd43294b2942734601590d7a58d08	3	3630	630	362	366	28	4	2023-08-16 11:34:13	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
368	\\x079ddc3c453be5891da04184c29e6e4c6258764bd6fb8eb3a287857e9700c45b	3	3635	635	363	367	15	4	2023-08-16 11:34:14	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
369	\\xed63ac6a900fbbf06966f9d8942507e7675abba284234d1a2021076a30f91e1f	3	3640	640	364	368	46	4	2023-08-16 11:34:15	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
370	\\x8be92d83c5c65e1434d671cd58995cc67d683ae47af0e08ded936d7ee395ae4b	3	3641	641	365	369	46	4	2023-08-16 11:34:15.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
371	\\x6db09f3b3e450767ffc333464913ec3d2ad4d97bbfa9dbfaedd98e8947dd8bec	3	3647	647	366	370	8	4	2023-08-16 11:34:16.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
372	\\x64b6392fe0abef71e2014115e4e0e7140976b37f566f7d848f76c37be87924a0	3	3652	652	367	371	46	4	2023-08-16 11:34:17.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
373	\\x075a8f0a947654ac537b6394812eacda671509055bc70aa299d3fc8b0730c432	3	3655	655	368	372	12	4	2023-08-16 11:34:18	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
374	\\x3609c987164da3d833ca2ba4b0aae2c4a0b91953096aaf6f8455b1730041fe33	3	3668	668	369	373	27	4	2023-08-16 11:34:20.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
375	\\x3a98f06e2fc577476301eddc6f3ba1338b9d9829394e34ea207a8299e6d2f14f	3	3670	670	370	374	8	4	2023-08-16 11:34:21	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
376	\\x54e6d686ea67bb3f868264f47b0db9db62939b148a0c0d2c2b558fa97a9bf500	3	3675	675	371	375	5	4	2023-08-16 11:34:22	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
377	\\x6c40eb49298faa82bd10ae80a3c65dd84c1ff5443c9f92d29e977fca3a8ee4ce	3	3677	677	372	376	27	4	2023-08-16 11:34:22.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
378	\\xfa2f4f6069418f8712f903def788af4628b2445cf2784dc07acfe3f76ca6468a	3	3690	690	373	377	8	4	2023-08-16 11:34:25	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
379	\\x5195db01d7db8fcfe7fbcd1b281e605a794d58ac7904d8df92e8f62c2d9f32a4	3	3716	716	374	378	3	4	2023-08-16 11:34:30.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
380	\\x20bc6fe3a58d34cce93254737bad76b94897bbfeb0b45ec7e1f86f9a2a8e63c3	3	3717	717	375	379	5	4	2023-08-16 11:34:30.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
381	\\xc7433c44ed43cca57af324f2f7162ce7fc7a9642a02966b16ca46f34bc3bb93f	3	3725	725	376	380	27	4	2023-08-16 11:34:32	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
382	\\x7821f25656e2e331f48cb1530745490e0c8aa57b2ac4f2b4a39577c11d00b22a	3	3726	726	377	381	5	4	2023-08-16 11:34:32.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
383	\\x94cf8d4fd1c8513baa4f31f23c27e89e453e7bfccdd8296c4889a270b426ead1	3	3730	730	378	382	46	4	2023-08-16 11:34:33	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
384	\\x41965765a1929d9040e34ccf613779952451021464e5745453021fff9ea62225	3	3735	735	379	383	6	4	2023-08-16 11:34:34	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
385	\\x16618e657c14f3e921de3c7fffa4aa60297391d9d116ade61b4f6baedb7b83eb	3	3740	740	380	384	15	4	2023-08-16 11:34:35	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
386	\\xbc8c1997fc47ab64594b9d2b0efdadb466603848e96d075cb546cc9247f49f29	3	3745	745	381	385	27	4	2023-08-16 11:34:36	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
387	\\x9551cb11c55f89c094801847f72301046daa09814e9be89a9d0f06f03d46238f	3	3746	746	382	386	4	4	2023-08-16 11:34:36.2	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
388	\\x61772bcb724daac45754c739a0427bf5482416099309535f15481846c85b6b67	3	3751	751	383	387	4	4	2023-08-16 11:34:37.2	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
389	\\x6af16e4b928a5472bb3d38708c6964f2d6290704b36fc1fd08deafe88522dbc7	3	3762	762	384	388	46	4	2023-08-16 11:34:39.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
390	\\x9693e2f5155876602be5dbfb588084b8400034c5c3d1ba19bb624c7a5f25316e	3	3765	765	385	389	8	4	2023-08-16 11:34:40	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
391	\\x47b42641b673630de383d0905cdb0a57d8dc311832d7e54f7aff5a8a1847b805	3	3792	792	386	390	46	4	2023-08-16 11:34:45.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
392	\\xb6da4870f4ec0048f2841f7d8eaf36952101496da4d1c6376eba9f1ea3eea775	3	3798	798	387	391	4	4	2023-08-16 11:34:46.6	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
393	\\x1fbe236f779db0700b6dc5dc878a9a7a3f4e193ccb5e1886a454b26f7e0109c7	3	3813	813	388	392	28	4	2023-08-16 11:34:49.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
394	\\x4b04b4b5471ca9a6542f4078ec193ad9c522a43a342a1579547988132d9d9ba5	3	3833	833	389	393	27	4	2023-08-16 11:34:53.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
396	\\x82bbb0ac9fd346d5dc2529bb0d83d6ef97c89e841403eb3b0c999328c9c2978a	3	3845	845	390	394	4	4	2023-08-16 11:34:56	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
397	\\xb5c70ccd8eb8f573981be72fdb8d645db9b06c14ff916385b731cd30fa8f49c6	3	3854	854	391	396	8	4	2023-08-16 11:34:57.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
399	\\x8cc2432b53e8732f5e29a5d03257f791eeda6cb25c17514d9aa71a5f1745d737	3	3860	860	392	397	8	4	2023-08-16 11:34:59	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
400	\\x9ac001d5e5c8d614d375b89e516742157ecd27353a0400a10d930d401cb87be2	3	3862	862	393	399	15	4	2023-08-16 11:34:59.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
401	\\x59d8edb7961ff9a8ec195b3990ef48ca2fe22a1c859bede7be13d5c29023e03e	3	3865	865	394	400	6	4	2023-08-16 11:35:00	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
402	\\xf97ba38d77a69edd436a99b598a4dbd27f8e6ab9eed2b066e47e3208146c4b3c	3	3867	867	395	401	27	4	2023-08-16 11:35:00.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
403	\\x0b1de4d5e7442a54aa05d27f6ca969fef3bfa1a4669ba718038ba3ca38556477	3	3876	876	396	402	46	4	2023-08-16 11:35:02.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
404	\\x413e8698c6c8f90dc12efc83461669ac2238a5c18a1a72a1005c67a418445d3f	3	3891	891	397	403	30	4	2023-08-16 11:35:05.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
405	\\x84455b34240886bb5858fb81e46ae7e9fc36cd78e14eff605aa4381c32eefe29	3	3903	903	398	404	28	4	2023-08-16 11:35:07.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
406	\\x9a91b60640594eec814cd62c0fb8065074e506e15f01931ecbc58609831287b3	3	3908	908	399	405	12	4	2023-08-16 11:35:08.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
407	\\x85db482a39daf2c1bbebf715c85054a677f1e17e88e6c44e0dec0096ddfecb06	3	3909	909	400	406	15	4	2023-08-16 11:35:08.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
408	\\x4aeb851b15793fdd95d623f79aa7b839bb5564eec18ab65c31742e465b6080c7	3	3912	912	401	407	6	4	2023-08-16 11:35:09.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
409	\\xf87c00766d2e3abacd7a3912eabadd8276f33df063af1d5c226a60ea7244ebc7	3	3915	915	402	408	12	4	2023-08-16 11:35:10	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
410	\\x7a5e74bec1e117bde712ca8cf6097ac5ace66e663d36f9326af1e75dc71b357d	3	3932	932	403	409	5	4	2023-08-16 11:35:13.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
411	\\x9a6c9d5205da16dc3501141f2e5b4a13d9f05b2d7d442160f1433037b514e400	4	4025	25	404	410	6	4	2023-08-16 11:35:32	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
412	\\x52b66425de68ca28c14c2d0a27710ebcd26f6ecc9dec654c129481d2d9c4537a	4	4041	41	405	411	8	4	2023-08-16 11:35:35.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
413	\\x7490de0f7f62e819e662d44f7144dc5a9b349ba41c13833f5d450808ff9a367c	4	4042	42	406	412	27	4	2023-08-16 11:35:35.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
414	\\x283ab0f8852b108f7e06c49efdc6edf7e383ebafa9db0cc05fdc4426468dc2af	4	4060	60	407	413	12	4	2023-08-16 11:35:39	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
415	\\x1fbbd7a38ee570da2bbcefb5c71d61283ffb91dd685839be04fe831609c3708d	4	4068	68	408	414	12	4	2023-08-16 11:35:40.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
416	\\x7b91faa600ab83e2c2e5da8f86d9288110e8379253185bfca90f48066b39f1ca	4	4070	70	409	415	8	4	2023-08-16 11:35:41	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
417	\\xe3df792fb845dd4267b310be7d546fc5d369cde8b652d02cde2271ac9cfdc122	4	4076	76	410	416	46	4	2023-08-16 11:35:42.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
418	\\x5e29e5cdf0ca40373aeb5e474a787c5becb0997d59945de9b2cea396fee83a55	4	4078	78	411	417	46	4	2023-08-16 11:35:42.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
419	\\x92c6902447e2095e0afb73a1d3f4d3a1278778ab198932197a45044f8744ce3d	4	4082	82	412	418	5	4	2023-08-16 11:35:43.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
420	\\x68cb33b5648f299f55f1f7b90a7f6e263b3c617d7be353d43d48a3f7f5200272	4	4083	83	413	419	15	4	2023-08-16 11:35:43.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
421	\\x5f30290191044d357792fc63807881a46f43a2e8530138e40ff63f4011074a5d	4	4084	84	414	420	30	4	2023-08-16 11:35:43.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
422	\\x098ce4cc81c409e75c7e8722c02821beff8d16c922e0f100e44920f95879b05b	4	4088	88	415	421	30	4	2023-08-16 11:35:44.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
423	\\x828f90d13034da13121efa9ca3e9a9ba6af5d76a633b59ab77dd5b9926444ccf	4	4090	90	416	422	30	4	2023-08-16 11:35:45	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
424	\\x8b0487dd046df5cb69db748d13f3b1ab470e2c656eb58161752d4c38b287868a	4	4113	113	417	423	5	4	2023-08-16 11:35:49.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
425	\\x29960569ee38f9b9b7bc87fc9dbe41f051c39ba6192e1158119c6c258766a650	4	4119	119	418	424	3	4	2023-08-16 11:35:50.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
426	\\xc7a1cb33b559244d339a3601e4cbdb7fac65da87e3cf6711ab01fed8b0929d79	4	4130	130	419	425	6	1108	2023-08-16 11:35:53	1	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
427	\\x9c5660d5b3541fc6613cf3b05faa577294277b34f1e5ef70bcfb0ff3954cd8f4	4	4142	142	420	426	8	4	2023-08-16 11:35:55.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
428	\\xfb2c4966d094661533d281a6e3826fe4314b64b0f56229c51251dc7ce1a36425	4	4155	155	421	427	15	4	2023-08-16 11:35:58	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
429	\\xf1c34c1cbecf0d249668de918d3c7ed135b888a8462a0e745c37046ad88069fd	4	4161	161	422	428	15	4	2023-08-16 11:35:59.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
430	\\xae04b8268276420f0bc93f42a07470f11b43fcd4288d310c81dae50a303323d7	4	4181	181	423	429	3	566	2023-08-16 11:36:03.2	1	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
431	\\xb36aa007fe9f2334b5f0c568bfb21726327f60498fcf1f617ee67c79558fb32d	4	4185	185	424	430	30	4	2023-08-16 11:36:04	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
432	\\xab36c58c28324f88c16d42146697c1683e18da02ee10e5d062f27c7c38882f16	4	4200	200	425	431	3	4	2023-08-16 11:36:07	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
433	\\x1b460aefff9d2f29ac6e3faf76158fa1e982dbbb93ee59077ea08437e27b5c37	4	4214	214	426	432	15	4	2023-08-16 11:36:09.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
434	\\x17ca202c06e998da296cd0e85982b09e909043153d71119f83a40ebe889bed09	4	4228	228	427	433	3	815	2023-08-16 11:36:12.6	1	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
435	\\x40a8418658bfa96a2e7387e48f28fdb0cb510f7ee7e7d7bebdaf67b42f85f7ff	4	4235	235	428	434	46	4	2023-08-16 11:36:14	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
436	\\x1b92f87c9f1c29ee5309d62c145303f587905e736b01b053cbfb77b2edb667c9	4	4243	243	429	435	30	4	2023-08-16 11:36:15.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
437	\\x483a24d2bebe5d0e5169329f5148f8003d9f6b7abd9bb4dbb3c1b634cea05902	4	4251	251	430	436	15	4	2023-08-16 11:36:17.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
438	\\x5e3c7ea4765f6c9d3607dadf9553d45e2901bc0061df84842e0a66ecd8eb3ac5	4	4260	260	431	437	12	767	2023-08-16 11:36:19	1	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
439	\\x619ed447f6ff7db6b1d20f628438374d15b6a5f446b587c98e6d6ea12cf0e4f8	4	4264	264	432	438	3	4	2023-08-16 11:36:19.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
440	\\x5d2181d1ebdc8bc42b95314775893cbccf647834fa98288ee305f0351803a87a	4	4266	266	433	439	6	4	2023-08-16 11:36:20.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
441	\\x6b0fad4e32d895f1bfc0df5d41899124da118557a8170bb4ddaeae524bf8eb89	4	4267	267	434	440	3	4	2023-08-16 11:36:20.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
442	\\x417334a13eb193834a23ed2a9a1a47c599c5f59a1db97f37542805bdf090979f	4	4288	288	435	441	30	772	2023-08-16 11:36:24.6	1	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
443	\\xcfb073d2102fe72201cd2d6051a0491b660db2a01d88432a5b373d611d9f36d4	4	4292	292	436	442	15	4	2023-08-16 11:36:25.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
444	\\xbd87610975117a030dde5fbbbb0bcb54b74e4f6b74f4545fdb285735c3e3ce4e	4	4293	293	437	443	46	4	2023-08-16 11:36:25.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
445	\\x12de66d7e0cd75c8a584526f4d3dffe4b455952286a7032d7e6d15a95db15cfc	4	4301	301	438	444	6	4	2023-08-16 11:36:27.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
446	\\xe6cc82822ae4e4ae098b4f43f7537de72c5e266a44e9d82bef4b0958f0e28af1	4	4322	322	439	445	46	543	2023-08-16 11:36:31.4	1	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
447	\\xf3a125fa1b001884a9f49f75f010d5051fb33489b352cbc8713b0f5a2ae21534	4	4328	328	440	446	27	4	2023-08-16 11:36:32.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
448	\\xee341b2424c36300632d7c3e1a50a2c33c436c20a01db2a3302fa07ec4619b23	4	4329	329	441	447	12	4	2023-08-16 11:36:32.8	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
449	\\x54c0293e6dd6e643d45081676f55e08f487a6812aea9c7591f09458133efce5c	4	4331	331	442	448	27	4	2023-08-16 11:36:33.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
450	\\x0cf44fd96c8cddfb0cde41c64f70b5e60ef8deac681abbb42b9042ac35b89ace	4	4340	340	443	449	4	4	2023-08-16 11:36:35	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
451	\\x2b799f7e035e892d6a44bb693314a4b6aee5a01934c0a13f7533c493b3ed75ab	4	4348	348	444	450	46	1009	2023-08-16 11:36:36.6	1	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
452	\\xc7cdfb1df6ac731adb69af01105c6c9442096e6cdfb5c458ce7a58a790c55c15	4	4367	367	445	451	6	4	2023-08-16 11:36:40.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
453	\\x5a47b87f1ae3e214c9eaf8bdbf4041e8ab485d8d07f21c02cba63a55b9679a35	4	4371	371	446	452	3	4	2023-08-16 11:36:41.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
454	\\xed0b9d8fc9d84a4846b40cffd53ed456de9ad017e9ad5ffd338e4dcbe173fb83	4	4386	386	447	453	4	4	2023-08-16 11:36:44.2	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
455	\\x072aaf621785f1ba9a0c7d47157e2aa3da715fdf8c91726faf89068be0433b25	4	4391	391	448	454	46	413	2023-08-16 11:36:45.2	1	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
456	\\x7135b6b548e5b2674bdb104b20566d0225e9d035e9451c86197f2a2ea0cd46f4	4	4394	394	449	455	8	4	2023-08-16 11:36:45.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
457	\\x46663d0d4ecaa83e954c0ce18ba0575322ba9c75462808d92455b590f0abfbb4	4	4400	400	450	456	46	4	2023-08-16 11:36:47	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
458	\\x8ee100b6c22cd76dc19e41e040138b2552bd0ad9e4e82d44887e887c03adba8e	4	4401	401	451	457	30	4	2023-08-16 11:36:47.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
459	\\x3ca5fbd31000a9c9c9e7bf131e768c6bb78ad774ea34b8cf67addcc93f683f4a	4	4410	410	452	458	15	335	2023-08-16 11:36:49	1	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
460	\\xa37c3450cbc37d5bb5d23f5075ce24f1182617fccf7e0a9e7443ace3c5fa5495	4	4419	419	453	459	46	4	2023-08-16 11:36:50.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
461	\\xc67edd35a7c18d8bd9f28bc39728738b00b77afab0bc4966dbd994e1079da715	4	4458	458	454	460	5	4	2023-08-16 11:36:58.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
462	\\xb23c1adbe78ab06da147bdd3aa1ba808279db37d4db6af133de160928e87114a	4	4464	464	455	461	6	4	2023-08-16 11:36:59.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
463	\\xf4be9413fb76a00aeefbc2d2da0fece5a22d6e7a0ba6145994faf5759101412b	4	4494	494	456	462	8	308	2023-08-16 11:37:05.8	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
464	\\xa7e9855239cc256a7e511ad7c06af8a215718a4c4c76c0dbc43a3a59a09c2805	4	4502	502	457	463	8	4	2023-08-16 11:37:07.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
465	\\xe663e4b54a1f6d38a47a4f9e409bcbfe4b0f3b473a2bb6037a78bd92ca6f4a2a	4	4504	504	458	464	5	4	2023-08-16 11:37:07.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
466	\\xa7d4c6db21ea99abfe205bc8ad1b0d4df42a0aa3764146d688c7e66354fcad04	4	4530	530	459	465	15	4	2023-08-16 11:37:13	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
467	\\x1d4ed2eb9d269572b8ac9fa3832b076fdefd78db149fac7491c176533894e956	4	4546	546	460	466	28	405	2023-08-16 11:37:16.2	1	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
468	\\xd755c1ae2aab15a63cbdbaa41a4b8a43e2cd339cabce011b1e08c1775864650e	4	4556	556	461	467	8	4	2023-08-16 11:37:18.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
469	\\x3feaa5cd290f2d1649dc4e3fc1d45db72c7327929cbea5bfbffee05037e6c40c	4	4570	570	462	468	5	4	2023-08-16 11:37:21	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
470	\\x0298eca778dfaf042a61e6030cf1a1c875cc6d17888b11e62a1418bcb650a6bc	4	4575	575	463	469	15	4	2023-08-16 11:37:22	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
471	\\xb46828265fa801deef87c9847e6ea39000c5bb8cce1afa95c6c77b0bdb9e1c0d	4	4577	577	464	470	46	753	2023-08-16 11:37:22.4	1	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
472	\\x69fb61e33fbc5c3122cfcc0b19dc81c39b9be57e85e80cc28430ae7ae71459e8	4	4582	582	465	471	46	4	2023-08-16 11:37:23.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
473	\\x7b400dde92da0f5ba73a2991739cec1ab8942cd3e53cb81e1bbf66fcaa576b1d	4	4592	592	466	472	28	4	2023-08-16 11:37:25.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
474	\\x42d38ad6a3bf2686a615283e4e55faf6fd69f5447ef2d422d2bb50b10ca15038	4	4619	619	467	473	12	4	2023-08-16 11:37:30.8	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
475	\\x67612de8c01aa1fae814a0b21203991c0d511ede3ba46646419f74377cba9f2f	4	4626	626	468	474	3	831	2023-08-16 11:37:32.2	1	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
476	\\xb8ec0991cff7537a38638a10260107a049832f0db7bbbc914127bff22b0cd0af	4	4651	651	469	475	6	4	2023-08-16 11:37:37.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
477	\\x8d9fed517a22275b6fa7e8c0a3f11388f51fec299e54d602bffb1b2e755bf90d	4	4653	653	470	476	15	4	2023-08-16 11:37:37.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
478	\\x1c1a58f55a7ff388a2da3bd3401335038ac12e327e8c8d091fb375c516e02208	4	4674	674	471	477	8	4	2023-08-16 11:37:41.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
479	\\x0d8ca33c82d7c080ea4bcdc8667ebf6526431910bb0012e85612f22f25b04c82	4	4683	683	472	478	8	344	2023-08-16 11:37:43.6	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
480	\\xe83a17666cd262621e3fdc403ed29b9f6245e9bac3c71bf177140c25b016cb6e	4	4689	689	473	479	15	4	2023-08-16 11:37:44.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
481	\\xfe5d22b195f058445fbb38999a3dfdc2089b4ef36c638af932868c6e259c112c	4	4692	692	474	480	12	4	2023-08-16 11:37:45.4	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
482	\\x6af34b901be2f546701743c311b03fbc7362dbbf751d7d7c52dd18a9e19e6102	4	4703	703	475	481	12	4	2023-08-16 11:37:47.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
483	\\x2d2d3b809036db78a4b6d4a68b6d714e5901eac19444f565fe7032fb6d50add8	4	4704	704	476	482	30	753	2023-08-16 11:37:47.8	1	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
484	\\xece9438219d317c8c6cec1e14d93e667e523300e0934ee02db93cba2996276d2	4	4706	706	477	483	6	4	2023-08-16 11:37:48.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
485	\\x024778756d4dda908f132cfb6b8241f148c0cd82570a248ec94d21162d8a3a6b	4	4722	722	478	484	15	4	2023-08-16 11:37:51.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
486	\\x197a1e8650613c052346868c5453d7ae195a22e7cee6542bf7c9480128d7618c	4	4735	735	479	485	30	4	2023-08-16 11:37:54	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
487	\\x2afcc74a7e427d6b58f1c4ca00d32a3833c80730d280a05280e67348ae7e30c4	4	4741	741	480	486	8	304	2023-08-16 11:37:55.2	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
488	\\x28342d2e11ab1d3ba7ed034c29e4695898a09bcb9f5d39476d0b6c1204ca6860	4	4759	759	481	487	3	4	2023-08-16 11:37:58.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
489	\\xb07d034e20408a70200ea2a9c9202e7f8ddc542c482e039a479dfee14643e8d2	4	4766	766	482	488	6	4	2023-08-16 11:38:00.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
490	\\x94844a22d6bae90afd468a9f3fef48dd9c408f40de1de1ab8d470f4eb503a9ca	4	4790	790	483	489	6	4	2023-08-16 11:38:05	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
491	\\xad6f8bdd8e9f69a2f35f7b117dc83893ed87a4b60530ec59a5379619c842a6ff	4	4791	791	484	490	8	4	2023-08-16 11:38:05.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
492	\\xb1e842a045e3e4c8f8f562053ebfc2bea806ca2d404d24fc2804505612de6283	4	4800	800	485	491	30	753	2023-08-16 11:38:07	1	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
493	\\x9a5d3c67b89c7172804c38a66c4983366bfcfff2cfa9a4887a7bfa80138b8510	4	4803	803	486	492	3	4	2023-08-16 11:38:07.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
494	\\xc7f918bd87d391c9adb6162a85b4cecb66b7219edffd7d3881b6c53d057a1793	4	4809	809	487	493	5	4	2023-08-16 11:38:08.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
495	\\x4f21dc493a765d827db93d2a19867a37102695e37f61a80501e8b4ccc60e138f	4	4816	816	488	494	6	4	2023-08-16 11:38:10.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
496	\\xe8792e3c6db71db8cf31877116a7283bc0a305da2c4ba9ca8a7c44f6d97ad4d3	4	4824	824	489	495	27	346	2023-08-16 11:38:11.8	1	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
497	\\x801c2e41d2372e0f65854add254418644b6959604843cab008c15b3580894c6f	4	4847	847	490	496	12	4	2023-08-16 11:38:16.4	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
499	\\x23039d4d245f39a66ea2d12e24c00cf4640ea60101af29062ed4b05e7bcaea48	4	4876	876	491	497	12	4	2023-08-16 11:38:22.2	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
500	\\xedc2ace5a0fbb65e0339788c9b28479453216c4d6d959b85c42e9beb92798e4e	4	4877	877	492	499	5	4	2023-08-16 11:38:22.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
501	\\xac9005152e17df1bcb15d49ea4c2aabb30745f62b524070292ef73994efe58d3	4	4901	901	493	500	5	304	2023-08-16 11:38:27.2	1	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
502	\\x8c45aaf959cb549c1afc02d23a01ae4adfa02ef8f12ca3a172716c56c24dfe55	4	4906	906	494	501	30	4	2023-08-16 11:38:28.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
503	\\x807bee24d5a76c6d04e186b65f9ad4b00ccc19249c9885528b418b2e272c9f49	4	4907	907	495	502	15	4	2023-08-16 11:38:28.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
504	\\x5a0352ad9b274dfc40adaeba09adc06fc3bb0cf7c41ec6d4102af099bdf6dd2e	4	4918	918	496	503	30	4	2023-08-16 11:38:30.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
505	\\x52f82b09e1d042cc62a9cf71d239da2ae247eaf2c5e4361982e5546da2d33225	4	4942	942	497	504	8	329	2023-08-16 11:38:35.4	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
506	\\xfccd98e76dcc35320ec0f926af0f18d82850a634e8c5c59fe0b92022464c868a	4	4953	953	498	505	30	4	2023-08-16 11:38:37.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
508	\\x1e1e15209e60efcd6d51deb375fb437a16a30e55eb623fc854a8161d9391b799	4	4958	958	499	506	27	4	2023-08-16 11:38:38.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
509	\\x3147e9d0e968b8f62214238e73e8e0ba9375050d562a49cd704ad4983cd2bdd1	4	4959	959	500	508	6	4	2023-08-16 11:38:38.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
510	\\xae9a6790c92cc0cd9a9dba37a205bb0c75e8a1c3d9e6465a4fe81b3680cf411f	4	4964	964	501	509	8	3432	2023-08-16 11:38:39.8	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
511	\\x673074a7a93698233f9a210e355042b0c56932c71151e30f01f6bf0f9bd37e38	4	4968	968	502	510	8	4	2023-08-16 11:38:40.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
512	\\x7461e43516ce9f98be2524a3a99ae3b50e4a09fd0564138f4147e447cfd66cc8	4	4974	974	503	511	12	4	2023-08-16 11:38:41.8	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
513	\\x85d04d5903b9fee24476aaabd06c8d1b74c55077badf6f652cc3e90b818ca8ed	4	4979	979	504	512	12	4	2023-08-16 11:38:42.8	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
514	\\x16622c94183f5d1c8176d14f64514fa9a0e1a0b17d7dc9f18246c46a1b5df714	5	5005	5	505	513	27	1980	2023-08-16 11:38:48	1	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
515	\\xb73a33e2a1ef782fa8c9b2f4cae06bc2fa1fd1a2881a77b1b4b9d6a9ba813613	5	5016	16	506	514	12	4	2023-08-16 11:38:50.2	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
516	\\x611c383907ba8b16f24bbedba16c59cb76363a00f3fccde27dd16e621cd13785	5	5018	18	507	515	30	4	2023-08-16 11:38:50.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
517	\\x67a6e9e4b56a57483646c344b09f0a6bb7d82f1f487e3815e3d6dbb2dbe9f94c	5	5025	25	508	516	4	4	2023-08-16 11:38:52	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
518	\\xb927b7888c07f3faa5f98a248d87690fc6780392308a2e2cddfe090c8749800c	5	5035	35	509	517	30	1051	2023-08-16 11:38:54	1	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
519	\\xf96a6173b944ae19f18764dc37cba279bd6565b09c172eb33a8ae171bd3e9a2d	5	5047	47	510	518	30	4	2023-08-16 11:38:56.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
520	\\xe28a66bd59c841b5a6403b1cdaf68c4841593eb60b66c98a057d52f282db30f4	5	5055	55	511	519	27	4	2023-08-16 11:38:58	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
521	\\x33b5c8fe3fd8da9fa3643c59a92f728e40a9337ade11761893df6bd008064505	5	5063	63	512	520	3	4	2023-08-16 11:38:59.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
522	\\xbff1a984c827f7bd955e21e5f3b162da897a4274cc6ddcb228b868a54fa5865e	5	5079	79	513	521	5	505	2023-08-16 11:39:02.8	1	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
523	\\x9e6501987d1a2b84cb1159dc6cefc596b694cb8f0ddbd9b3ae4f834a31121321	5	5090	90	514	522	46	4	2023-08-16 11:39:05	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
524	\\x49222eab3a066655ec2a578c50f68174e482b57f8e8fc99cd9d0c34ff352c2b8	5	5091	91	515	523	27	4	2023-08-16 11:39:05.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
525	\\xcbd3e309f7ea787e291277b9aa88701f0d081d599ef4c598925de325ab5a9c70	5	5105	105	516	524	15	4	2023-08-16 11:39:08	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
526	\\x94d48833a31d98d01b7781ad1da08106315cbef80eabdac24a754a0444c61036	5	5120	120	517	525	46	401	2023-08-16 11:39:11	1	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
527	\\x523c31cd75692444d4ae862769bb2e2bc2b342128f499efc7ea9e6132a2f88f1	5	5123	123	518	526	27	4	2023-08-16 11:39:11.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
529	\\xb421df23967e85e9dac8131677c5366e24b562c67d8db58b94e5984b4ed74bd2	5	5135	135	519	527	6	4	2023-08-16 11:39:14	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
530	\\xc9c4004696fa851fd29ca785b5d333aedbeceed8408302b2daf54ae2fdb5fd8d	5	5137	137	520	529	46	4	2023-08-16 11:39:14.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
531	\\xf80680fa79762f22a3dad84854a053eb9424a77a56227e392a3ff8fc33ae5702	5	5147	147	521	530	8	684	2023-08-16 11:39:16.4	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
532	\\x7fe56ef3e262f942fac44f8f7b532788503e55c37d01684fcd027d7c3ec3ffef	5	5151	151	522	531	46	4	2023-08-16 11:39:17.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
533	\\xac0cb67ce6dfc2ea833ebcb3bca9534e44d29cf3586541fd496a9db84bbe4a0c	5	5154	154	523	532	15	4	2023-08-16 11:39:17.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
534	\\x76826fae62c1c76ae1ec25f8234a193356b3d43323c9c2adf6e56b2f0aadd98f	5	5159	159	524	533	28	4	2023-08-16 11:39:18.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
535	\\xda2f2a07430f3fad1cefe3318bf091af6c91cf3dff5aa3e8b4399e09f4e91df4	5	5162	162	525	534	30	539	2023-08-16 11:39:19.4	1	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
536	\\x45df8488c20107f9d2e694fea59114c7d34510ab2ad6ba8c363f7a4c2310804f	5	5194	194	526	535	46	4	2023-08-16 11:39:25.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
537	\\xbccede31df24d260667bd438b4cc537b913f80881f23d670196ab81cafe69565	5	5204	204	527	536	8	4	2023-08-16 11:39:27.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
538	\\x7aa357a97beba21883587c6c89e677c8d76ab84a880793933ebc9a90a28dba21	5	5215	215	528	537	12	4	2023-08-16 11:39:30	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
539	\\xee64d7dd408c7d073cec654df1146605c5f261475bfef30d14d7f9dfcb9dd698	5	5246	246	529	538	6	337	2023-08-16 11:39:36.2	1	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
540	\\x5765d9cf19f7870097d29740dcceeb4d9ac32e3826f297c4f98bf60c0b9e5429	5	5271	271	530	539	4	734	2023-08-16 11:39:41.2	2	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
541	\\xa03080dad47fad19bda04ab478623ae248024b62d19930deb230e224001658fc	5	5275	275	531	540	30	4	2023-08-16 11:39:42	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
542	\\x47a0d7c170137987150effe026191a00d26cc089e826e74389024a98b50f69ed	5	5290	290	532	541	6	4	2023-08-16 11:39:45	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
543	\\xf0ff11a3816a4713f79395110bc14b6f12549f1dafc9971d230df662680054e6	5	5305	305	533	542	3	4	2023-08-16 11:39:48	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
544	\\xdd61acdbadd117d7247a66a9fe5abd5eeb5542d01f9f3cdb7dfb55a9f18f3c9d	5	5310	310	534	543	4	4	2023-08-16 11:39:49	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
545	\\xc2481db6084ea1b6b10c612679ffc3c4be1752f63629ab1e7a2a81d31d1f126e	5	5323	323	535	544	4	293	2023-08-16 11:39:51.6	1	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
546	\\xc0af988ec1cfd2a1cbbdb6b3382f1db3f5cc5a04fd7b82c62f1bb9977d3850d9	5	5335	335	536	545	28	365	2023-08-16 11:39:54	1	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
547	\\x93e4a117769aabb350a2a8243fbf789d7a6a99d23d9eb4488119e9f8987e33bc	5	5345	345	537	546	8	293	2023-08-16 11:39:56	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
548	\\x1c9f743eed359e617e2b37191a838d70a23cc7eeb33d71561f84c1381887e7ee	5	5350	350	538	547	28	2371	2023-08-16 11:39:57	1	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
549	\\x03a7778bb30179ad4e0e6ba21ec8775658cf336f27fbd0c77eba26eaf06bf266	5	5351	351	539	548	15	4	2023-08-16 11:39:57.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
550	\\x0be330e8ff3645beb48936950e9ddf803b953caa6cfbd5ee76c3e892ec35d9dd	5	5363	363	540	549	8	8200	2023-08-16 11:39:59.6	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
552	\\x86b656735ab84fefd9e7e514496773d06b2dacd282e7256a1fa2672644f01944	5	5390	390	541	550	5	8410	2023-08-16 11:40:05	1	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
553	\\x989f808f7b01fb879fe0238c1f205b1cb70c30df9bdcc13faa2e51d3a0fbd0ed	5	5392	392	542	552	6	4	2023-08-16 11:40:05.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
554	\\x2cedb4165e62ccb687f1488c9b4f786aa6b2b5abeba6bf6f95a40a9dfae02364	5	5410	410	543	553	30	495	2023-08-16 11:40:09	1	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
555	\\xc05e006f4fa130be0f854824b5b537b45fc2d210b048fe4b2b792122169fb1b6	5	5421	421	544	554	30	4	2023-08-16 11:40:11.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
556	\\x69e4d479851c1c618fb742687f58482adcb6a00f8bb9b517c80b9c59fe157a9d	5	5448	448	545	555	12	4	2023-08-16 11:40:16.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
557	\\x99779eafe757b939e451ef24384ae4f727f411c7d04c9e34bcddbf1ecd36163a	5	5477	477	546	556	27	361	2023-08-16 11:40:22.4	1	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
558	\\xea5c5c21ef8633c7ce7e76aea3bcc8b388997796a416a918ee1504c3073b0be6	5	5484	484	547	557	4	4	2023-08-16 11:40:23.8	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
559	\\x556532f6d25a6ad58df38749ed779bb566c00b31161d7cdd0ce78ddf85bd8836	5	5556	556	548	558	30	285	2023-08-16 11:40:38.2	1	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
560	\\x204e69d19f9950ffb9956aa5d55b4613f3177594ee6ffc69635c2ef669db397c	5	5558	558	549	559	3	4	2023-08-16 11:40:38.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
561	\\x0e9d301c28a619ab4be1d9e33e92b520da02d820f32fc6cd5e5b1923b042d3ee	5	5567	567	550	560	12	4	2023-08-16 11:40:40.4	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
562	\\xf269d9059c70c20795fb27209c82ac747159017371355ea9775af1c4920c9b6c	5	5573	573	551	561	28	4	2023-08-16 11:40:41.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
563	\\xd2d3a3e4b700434f0d287ff1e5cd61dc488ea8fba1941488909aac487d1f82ef	5	5576	576	552	562	27	4	2023-08-16 11:40:42.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
564	\\xfb0b5585c1fea3fabf6d79f168969173ec3e664dfb2f1784dff91cdc85d36f8e	5	5629	629	553	563	15	294	2023-08-16 11:40:52.8	1	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
565	\\x4a1975e1a9dfc83fd5dd0a7693785820a5aced1b5f01578c2eee68e22a39aa7c	5	5637	637	554	564	12	4	2023-08-16 11:40:54.4	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
566	\\xf7ffe6e531f6d43a5ec35e0be84aa18e3c412f53c3838c1446eb9ba98b49662f	5	5667	667	555	565	4	4	2023-08-16 11:41:00.4	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
567	\\xee95b73b21793cb3a54fc704d321ad0e3ccdeb1d5e4bc320353c0cd4599e9191	5	5674	674	556	566	28	4	2023-08-16 11:41:01.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
568	\\x2076c4edb79285d02815e4b75f42a9c3a3b6faad9f8129444a3690aa932e44b0	5	5685	685	557	567	3	430	2023-08-16 11:41:04	1	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
569	\\x3819fdb8252f6d83ee2317407daa1c060ff87979df76194a58f36591b69a09eb	5	5713	713	558	568	15	4	2023-08-16 11:41:09.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
570	\\x1dfbdfa131d1bc68966e5e73484019be2df165bb145d520cacd9673ffe0c23f5	5	5714	714	559	569	6	4	2023-08-16 11:41:09.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
571	\\x1747cc47f38a73d622e2680ecc7ccdb8e798490fcf706ea04f60067a4875da42	5	5719	719	560	570	12	4	2023-08-16 11:41:10.8	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
572	\\xc1ce55123e009ac15195f271ec98ff48a72d7004b40bcec97c399f1907f8d3ec	5	5728	728	561	571	4	4	2023-08-16 11:41:12.6	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
573	\\x4953cab1d9d830ff5a246ed88ba8fe9f21e266ffc1d46d088ab64037aab8df0e	5	5736	736	562	572	3	4	2023-08-16 11:41:14.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
574	\\xf7c28c88a77be9dbb28b375f271a5aaf1f16930ed13b1f3c781ad1556459fbe7	5	5740	740	563	573	8	4	2023-08-16 11:41:15	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
575	\\x8add775586460deff9653369a6128ca2e794416fefd7f4b8cd8be9f4a1c9d098	5	5762	762	564	574	8	4	2023-08-16 11:41:19.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
576	\\x32cdb9186dac820a2850b12a1a9cd7681e61a8d929803a873c391efb42571370	5	5772	772	565	575	28	4	2023-08-16 11:41:21.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
577	\\x7d662352cdb5fe6d5fc2c277a737deb1971e4c8fdbaad8d00e4547cee3df30f4	5	5792	792	566	576	4	4	2023-08-16 11:41:25.4	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
578	\\x1bc228dcca1cee4ddc3712bccd95460cf1f091827b66c5e03bd14b595cb40bf2	5	5793	793	567	577	15	4	2023-08-16 11:41:25.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
579	\\x7a046efc1384bae25708b9a8a26b1d0a15bca0cbed90f3ca834c278ad6a4687a	5	5794	794	568	578	4	4	2023-08-16 11:41:25.8	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
580	\\x9e7376e01a0e759dcfb64b6a3ecfadd5ab817d37e911222c2fc5dad48aafd4f4	5	5800	800	569	579	3	4	2023-08-16 11:41:27	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
581	\\x98099fa40738b0d1955cdd2a74e4177669fbb31c738930b9149028318703d8d2	5	5810	810	570	580	15	4	2023-08-16 11:41:29	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
582	\\x567c5edec38cfcd38d16a616ca7f342b2ca278eda267857c57919f540f0da0d8	5	5817	817	571	581	6	4	2023-08-16 11:41:30.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
583	\\x94e9fdcfc0bccb35c3c3fdcf5608b18aeaac11ad3dace1a94d74a65290d0ecf5	5	5821	821	572	582	30	4	2023-08-16 11:41:31.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
584	\\x928d3127cbc12e40d96d68f18bbd56c9aaef893477adf87220f0b28c36524c99	5	5830	830	573	583	28	4	2023-08-16 11:41:33	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
585	\\x21116c4868583bb5b5cd8fa1a88e3c7f54bafd4a1234aed8f66b2569e33198e6	5	5831	831	574	584	30	4	2023-08-16 11:41:33.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
586	\\x547aaae8fd66ec8d8b39d9eb1702d093132df0dbcb4b4ece03551a020034b4fa	5	5833	833	575	585	28	4	2023-08-16 11:41:33.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
587	\\x6fdc0b3992340c3d5ccea66cbb8b18f6596d0f1c03504cc0cc82f6250931c7b4	5	5839	839	576	586	28	4	2023-08-16 11:41:34.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
588	\\x4a8b47a99c3e13de8a2f073dc45fbe59b3db665eaa923155f2015d5f9e6472ab	5	5850	850	577	587	12	4	2023-08-16 11:41:37	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
589	\\x9864d226ebda2877b71b670377c748884dd3678d9bf674f2fa52e39b146087d5	5	5865	865	578	588	27	4	2023-08-16 11:41:40	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
590	\\xe97536d302057ada293fb932df5be1d54fb14757980e9702c22e5aacad7b0b7d	5	5868	868	579	589	5	4	2023-08-16 11:41:40.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
591	\\x91d04cfad11fff499b1d7843151feeba3a8a0285c354337b44f67ac06b40bf85	5	5901	901	580	590	46	4	2023-08-16 11:41:47.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
592	\\xf90d1a1ea8abaae1795439f5015351e7b8bde9ac0052c8a03f8d31c27a344506	5	5902	902	581	591	15	4	2023-08-16 11:41:47.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
593	\\xa43c2f02f8070437ce86503011947c472022b7e4b66349404334a5b69cf9559e	5	5905	905	582	592	4	4	2023-08-16 11:41:48	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
594	\\x6a5507621e0832240ef25a1fe074b3fd903daec12fcab5c52f850f1456301a90	5	5909	909	583	593	4	4	2023-08-16 11:41:48.8	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
595	\\xc4d21a5c8132297b9d403b189961a95dbe9e39b7fcd3c751cdceea292827d25f	5	5926	926	584	594	27	4	2023-08-16 11:41:52.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
596	\\xf36bd67d67331521045d1a7c259f0c8f151b5f50a30c11422b9a2b45ac7a655c	5	5960	960	585	595	28	4	2023-08-16 11:41:59	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
597	\\x7d03ff9f7992cb390f553ae9ab4a4f6bb6e5be4eec8e1e1b96f6a847d1b6f88b	5	5971	971	586	596	5	4	2023-08-16 11:42:01.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
598	\\x7603dbc2d2188c227ffcc2f95b02a1090d50cd9d2a9bf1ffad261cdf57c1f8a3	5	5974	974	587	597	5	4	2023-08-16 11:42:01.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
599	\\x56dfb697d1af1577aa42b2e665a1c4c5499a0f50e3017bc35127e8f342570d3f	5	5982	982	588	598	30	4	2023-08-16 11:42:03.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
600	\\xfad4eeaedf43904995562213709689d1239fdb579023f19eff4876f7862ffc36	5	5999	999	589	599	28	4	2023-08-16 11:42:06.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
601	\\x32cd3d023703089eaaee67a9ab13eea560acb751fa7dd75144ae40015fb4a063	6	6021	21	590	600	28	4	2023-08-16 11:42:11.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
602	\\xe06483d3efb684f87e2af8cc5fd908b93fa08506f2f704ba89200dd9eac86b0b	6	6022	22	591	601	12	4	2023-08-16 11:42:11.4	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
603	\\x411912d990fa192538a637c20670c9c5d3feeb1b98c90893d851a0e36fe57827	6	6042	42	592	602	8	4	2023-08-16 11:42:15.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
604	\\xd5454d30fe3a852a15f0cc901385094cdbabc78db101e13d99aa347fb70fe492	6	6050	50	593	603	15	4	2023-08-16 11:42:17	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
605	\\xf37aa36644987f65ef6daa4e45829fea113c6e22696324280606bbe9233ae0e1	6	6061	61	594	604	4	4	2023-08-16 11:42:19.2	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
606	\\x6b276e5c833ed9fca26cc71b38445a9c24a4988767166230ed9cfebe87443abe	6	6077	77	595	605	8	4	2023-08-16 11:42:22.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
607	\\xa5ed9e2b21fabd20f01a4f03b7bb6133cb19f4f81334821ab44ed470d9e77f02	6	6080	80	596	606	28	4	2023-08-16 11:42:23	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
608	\\x9e0cb09f40d1c2318f3ab3d8698e927b30965c1cee39923b323d25c0165f8227	6	6084	84	597	607	12	4	2023-08-16 11:42:23.8	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
609	\\x2fd049def6c3bde38af110c26667ca0d4050e39738796a326ce3efaa257853cc	6	6085	85	598	608	5	4	2023-08-16 11:42:24	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
610	\\x8f5bfe3b186ebe74706b7e14d6ad79173f43e1cf788bfcfa1dc28c66d51692a8	6	6086	86	599	609	8	4	2023-08-16 11:42:24.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
611	\\xe8c014c9d6d5e27e6c7e78f382dd2a8010095d85fe831100fc2339f3efc47dde	6	6116	116	600	610	30	4	2023-08-16 11:42:30.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
612	\\x677df5605fd3c4a10c64ddd258a1664024be2194e608d6f18234a84bc8a2cf77	6	6125	125	601	611	8	4	2023-08-16 11:42:32	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
613	\\xb901ea4ad41d5d7741dcbf76be98a80d068ba0c35b7274bd14c2b8b4207c7210	6	6126	126	602	612	5	4	2023-08-16 11:42:32.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
614	\\x7bf83934e60ce97ad4e44e7b6bd604dfae70d14f55a690da83981c5f592a38f1	6	6135	135	603	613	46	4	2023-08-16 11:42:34	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
615	\\x30352b974610b7f69dfd3928996ac57f101e9f41d730236efea995504ee64d6d	6	6143	143	604	614	28	4	2023-08-16 11:42:35.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
616	\\xac9252068d406dc8e976e7ac22b366e757b4d426d7c36e7ffc7186f3b208c3c5	6	6161	161	605	615	27	4	2023-08-16 11:42:39.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
617	\\x40ea27cec781ce21deba774a6a53c6d8493e8a789a6412dea6f266cb197b2200	6	6183	183	606	616	3	4	2023-08-16 11:42:43.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
618	\\x7d847ae6d6b45e955e4a30e5fc4fcb5dbb2e3f8e7fd2e45dd8d5eae2fa9beca2	6	6190	190	607	617	3	4	2023-08-16 11:42:45	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
619	\\xad1fa8fd62716f02e64dada795e75391857f292c9d25eb0d04aa62acc3dbb5e0	6	6204	204	608	618	8	4	2023-08-16 11:42:47.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
620	\\x06e867e4361aa17e2dc7aa6803c564f986653eecc23285b2e4e5fd0d55f37dff	6	6206	206	609	619	4	4	2023-08-16 11:42:48.2	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
621	\\x3435f0cf8cd802d1a7d5c9e2cbdaa032a08e9271de0c1f36740a691842cae892	6	6212	212	610	620	3	4	2023-08-16 11:42:49.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
622	\\x10646d5394ac4a5c84c62ce39fb41a1339647364e7b952edd781d4c85ea87c72	6	6217	217	611	621	3	4	2023-08-16 11:42:50.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
623	\\x425b3463b6cfa06515a2c86287c789437ec9658a15ee962619f8acc6943c937b	6	6220	220	612	622	3	4	2023-08-16 11:42:51	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
624	\\x2f893e6b8040b0faadbd1dad81cd72b3ad5b23cb19c2fb12ca89583150e9abb7	6	6261	261	613	623	8	4	2023-08-16 11:42:59.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
625	\\x5b8e0b0e54efdd7ce7da87491cfdddf58deea9f36256c57696e3fa18fea62c95	6	6268	268	614	624	4	4	2023-08-16 11:43:00.6	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
626	\\x6ccbf930833e80d50f097b764a917b80c795636b54272e1a4e2c5d4635c689be	6	6294	294	615	625	27	4	2023-08-16 11:43:05.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
627	\\xa39723f7ba1a55b6154dcdf84fefa47600974a18e7856a5b8d95a235e0a77dbb	6	6303	303	616	626	3	4	2023-08-16 11:43:07.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
628	\\xcfc92043bffe8d973d54b70f7e3d6c678f764514502653c3d3024170a3e4da5a	6	6306	306	617	627	27	4	2023-08-16 11:43:08.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
629	\\x9fd1eeba212a8f403badb3105a981bc5701ba74e85d237bc19b310c5b66c3708	6	6317	317	618	628	6	4	2023-08-16 11:43:10.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
630	\\x0ffbdd471bc8a46cc68fa7aaa1c5f0f0a218dbc90058c2cc6bb5fde31d048e52	6	6324	324	619	629	30	4	2023-08-16 11:43:11.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
631	\\x261faaaa37d7fd5b4fa366b80e10692ee2686112a4c39ec704fd2322a1205cd4	6	6351	351	620	630	12	4	2023-08-16 11:43:17.2	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
632	\\xcaa63516ef850fbdbfcf687fba40201e86055f0640dcaa1ea188451e64ba71af	6	6369	369	621	631	5	4	2023-08-16 11:43:20.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
633	\\xeab6a51c79986c18be6608240b2e408c5f1bde2feed1f2d08214e71646a9cbb1	6	6375	375	622	632	4	4	2023-08-16 11:43:22	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
634	\\x70c94aee2428e8dc6ab1cf933626d7fa77acc860b70ccd235dc99c891469e6b3	6	6382	382	623	633	46	4	2023-08-16 11:43:23.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
635	\\x5c0de702dc4cb2008631c44a359710b2212552dd976f81475dded77e8591415f	6	6420	420	624	634	4	4	2023-08-16 11:43:31	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
636	\\xa8c6510dcb5a8c54740ca63f91c2dac4106be51a49f6543a2c1f7eeb854438e5	6	6427	427	625	635	46	4	2023-08-16 11:43:32.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
637	\\x1d395476819a4cf23d0ca5b076cf56e2e6e0ce1089cebafa29b3252b4a8e5732	6	6437	437	626	636	8	4	2023-08-16 11:43:34.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
638	\\x986efe227b9b9d4655637e46a2fb9fb7c0705fb411aa36a0d786a16cb38a1878	6	6438	438	627	637	4	4	2023-08-16 11:43:34.6	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
639	\\xf8b59e0c6ab41ab892801b4ef4d6278886509104e2357f51200479ffee4adfc9	6	6448	448	628	638	12	4	2023-08-16 11:43:36.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
640	\\xe0c14df8e6b2ad5f494887167a21bba29a28efce265af369a37416ecee722f0e	6	6468	468	629	639	15	4	2023-08-16 11:43:40.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
641	\\x43ca8af317db3db0e9d783b9fa8ad29784ccb86a847eb73acf245d831ffe50ec	6	6482	482	630	640	12	4	2023-08-16 11:43:43.4	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
642	\\xeaff014b9e5c92b19acd42c9aca9a41d385fea35b78f3f9943bf4800c5ae55ff	6	6486	486	631	641	5	4	2023-08-16 11:43:44.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
643	\\x64283d805fee8ba3f7a3bb15afd663ff11a575f4c3371a107bd89ba1ed502451	6	6491	491	632	642	3	4	2023-08-16 11:43:45.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
644	\\xe46d486ec161ec3c431a4b598e85fd4ed4673abe9fc2f560d4707d1d05e6a28d	6	6494	494	633	643	27	4	2023-08-16 11:43:45.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
645	\\x335ecc17d26a29f1333c6e3f1b2f5394cbc1fadfe7959f083c0d5b84e0de1d29	6	6501	501	634	644	15	4	2023-08-16 11:43:47.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
646	\\x93ed493c24a8e183b1b11843c3314a755cbba30c8bccb3ad1e765fa4404e8ae7	6	6503	503	635	645	12	4	2023-08-16 11:43:47.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
647	\\xa52ce7e8c11a72c096d42a20c2b87d33122315d25c4127e6bae4924683a79cf7	6	6504	504	636	646	46	4	2023-08-16 11:43:47.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
648	\\xe1764f6662c5723471498a921fbd6c9e9aa8a556f44d98176bd7ac5de31b7f93	6	6519	519	637	647	46	4	2023-08-16 11:43:50.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
649	\\x4e46e8d3d9b32d0c88cfb29c3a9505a5879c4a62bda252d8d4890aa648c62a9b	6	6554	554	638	648	46	4	2023-08-16 11:43:57.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
650	\\x44c0fafbb527ccd750d5fed4f6d326bd42cea4813b66373b8c92526084049479	6	6577	577	639	649	12	4	2023-08-16 11:44:02.4	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
651	\\xdaada5dc54d164ab961afd76d89fe43c3ab92a9fbc03309ae3dbe20b50303d16	6	6602	602	640	650	12	4	2023-08-16 11:44:07.4	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
652	\\x329b262865f4fca6688a48e9c002fe4e1a2e6d6b0562feaaa4928685c8652a44	6	6624	624	641	651	46	4	2023-08-16 11:44:11.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
653	\\x5c139407b6f9ecaba6b3c81406da89c755741bdb3b16ccc88eba35681e64b7e8	6	6642	642	642	652	6	4	2023-08-16 11:44:15.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
654	\\xf3b40df6e771ba56cfe426405f3fbe31ea788e4abdc309987e90270724a600b2	6	6647	647	643	653	28	4	2023-08-16 11:44:16.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
655	\\x43d6321cb05befd888fed596f19e7145dd71b8200299fb4d9d73a32ba79fcb5d	6	6648	648	644	654	46	4	2023-08-16 11:44:16.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
656	\\xc186ccf09c05a4aa41605f71ead4a582f4d3bbb7a685392629be8d99a2cc90e1	6	6655	655	645	655	12	4	2023-08-16 11:44:18	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
657	\\xaad8a64b0910e95abef47f3e625d3171635b3788e62b2419922dd5b18b6f8c9f	6	6662	662	646	656	8	4	2023-08-16 11:44:19.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
658	\\xdc288c5d0cc4954ab1c211be3491bf59e83b11eb6d614770c0e69b44049af69d	6	6667	667	647	657	12	4	2023-08-16 11:44:20.4	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
659	\\xc18c9e0347dc380563f1080c96e30fdb8d1b718ac2504abc6166d4d1f4f4499c	6	6675	675	648	658	5	4	2023-08-16 11:44:22	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
660	\\x0b7438963fe9420194ee5d558ce31f07735ed5dea4c12d9e377507d17231298b	6	6688	688	649	659	12	4	2023-08-16 11:44:24.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
661	\\x1e61bf9d1c007a7607ddc089070764b576eac1c98a8e1d8597ccdc1fe6f00bd3	6	6698	698	650	660	15	4	2023-08-16 11:44:26.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
662	\\x0e016f3d7adc5b375ceac4ea41efcf993152f86ffcfaeff5f455161f2a46eed5	6	6699	699	651	661	46	4	2023-08-16 11:44:26.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
663	\\x3d2d0250bf589b13818d28d53d4771664bef33530d03b82a2e7fce46d23c4d81	6	6700	700	652	662	8	4	2023-08-16 11:44:27	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
664	\\x29d2da066ce3c1e41f53e59d5c0a39464dd8eb547650946a099e37296f9b5cb5	6	6710	710	653	663	15	4	2023-08-16 11:44:29	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
665	\\x36069cb5712e075603ff9d7f135d2171f8902e835d1e655140ea0a7991d5f861	6	6747	747	654	664	6	4	2023-08-16 11:44:36.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
666	\\x2812dbd41032d0c0e6b42022a4b3c16bde524261868c7c43183841c00257d3e4	6	6753	753	655	665	27	4	2023-08-16 11:44:37.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
667	\\xd27c3e5c23316c76b3c9d8a4f402a237b9f49f22ebd93f8e0f60bf2dfaf053c1	6	6756	756	656	666	12	4	2023-08-16 11:44:38.2	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
668	\\xf6d4a2be083b7aa9ed0503cb0a384c2c7695e402fa5cf2ac83659cd5af3f3098	6	6764	764	657	667	4	4	2023-08-16 11:44:39.8	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
669	\\x545b4fe54b3fc406433cacc979ec5bec8beebf8a91d38a0b78391ecf3aa1400b	6	6766	766	658	668	46	4	2023-08-16 11:44:40.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
670	\\xa7ec3e604afdfd6f17d9c3047880452982895a71bf45496bca42e5c8879d08c1	6	6769	769	659	669	3	4	2023-08-16 11:44:40.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
671	\\x0d08f4c69ba408227afabb0b0e488a76b59675c6edb34bf3e04e46779480c8aa	6	6778	778	660	670	30	4	2023-08-16 11:44:42.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
672	\\x69e8013d9beb31a919693793ff0f55e9d6393b2c42a9d0188cbbfd24b8a9fecd	6	6812	812	661	671	4	4	2023-08-16 11:44:49.4	0	8	0	vrf_vk19uxmev34rjhm729dm4c9sfqg6lezrzune07rja2ctrzttghxv9qsy6dkjy	\\x605eff22d5b31696adae6f3ef8aa28119c33adb3f5c78cca8045509dbee63be9	0
673	\\x261c4580c506ad577b5ce9814471019a418946a57972af42546cf7c866f892c7	6	6816	816	662	672	30	4	2023-08-16 11:44:50.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
674	\\xbef0c9203d62123e285efc1cd06a709728550475bf7f294a7428a4ddae940916	6	6829	829	663	673	27	4	2023-08-16 11:44:52.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
675	\\x36dcccf99e3338dda71b101f9ce514ea011447dc56e6da7c3f30cc403e1d0ca5	6	6838	838	664	674	15	4	2023-08-16 11:44:54.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
676	\\x51161d0804081d59a14bd5b7324760de25d1898cf4a18a8b7894ad5f5d2eee75	6	6853	853	665	675	46	4	2023-08-16 11:44:57.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
677	\\x9d823c080ecc13cc609b70fdbd49c120dd0b5954a5973433b018ae981ba379f3	6	6865	865	666	676	30	4	2023-08-16 11:45:00	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
678	\\xba3d7900255cdb406b2aec1f23bb2853988180264074c5a5a05bcc18495e74ba	6	6872	872	667	677	46	4	2023-08-16 11:45:01.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
679	\\x9a0be995625f22b7e64ff16eb1c37fdb8b1877c21758d8ca7c1547ea858890d9	6	6879	879	668	678	12	4	2023-08-16 11:45:02.8	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
680	\\x25bead9ffc76612ce179616f03912fbb36fa6a648dc4974d98a27dccd5628cc7	6	6883	883	669	679	12	4	2023-08-16 11:45:03.6	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
681	\\x80832a7c99ff90164a060de8166a3f7440c0b5e03d682f3da7a383ca457a6a13	6	6911	911	670	680	6	4	2023-08-16 11:45:09.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
682	\\x459f622106a6df9aae4afc5c386c83916d9075dcf5c1fd3850f148acc3e9bb3c	6	6915	915	671	681	12	4	2023-08-16 11:45:10	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
683	\\x1f00eec672d89e29d0a75bacd72b6166fb70b6144f352ae1c544a9f27e5b8ef5	6	6929	929	672	682	46	4	2023-08-16 11:45:12.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
684	\\x254e1e53be29b672a8be7f2b1f405d6d075ec88bd4a368b57991ea2f36a258cb	6	6976	976	673	683	15	4	2023-08-16 11:45:22.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
685	\\xde94e3588a768949d6286278f13388aac2aca520ce3e6f63f3d77c622c7c2e16	6	6977	977	674	684	12	4	2023-08-16 11:45:22.4	0	8	0	vrf_vk1l74zjslxe44f5efdgm6akqevvt8ea05xlwqkt5k02retg9eqf3xsufs62l	\\x8b81277ac703d248249df7a49268652e1a55639cc751516897a08eabcdf6bfbc	0
686	\\x22f8af6b7f3c5182146f28c3874825c4843f6b3719e98221a95630b8fad3377b	6	6982	982	675	685	8	4	2023-08-16 11:45:23.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
687	\\xf83a7d6ed3e24d632f5f4d649aef8cfce75a1f9e249085562ac3b66d8b5ebb3e	6	6988	988	676	686	28	4	2023-08-16 11:45:24.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
688	\\x67860da4d748efc378710b95883be6f230ed1653ff14ce644628e91a7bd75972	6	6992	992	677	687	6	4	2023-08-16 11:45:25.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
689	\\x838434d2088a4db5ae9640478e13d1ec1c9ce9c9fcd8d68d7d0b1309d707ef8e	7	7004	4	678	688	6	4	2023-08-16 11:45:27.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
690	\\x8dbbfc288f9a06ba3b50c4b77016727f736109f4f6aa079541b1cfe8b56d2a57	7	7037	37	679	689	3	30208	2023-08-16 11:45:34.4	100	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
691	\\x7427e3511134043265ea192f6e2dac2297de078c33dd5aa429e6dce2969d6fa7	7	7042	42	680	690	27	4	2023-08-16 11:45:35.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
692	\\x74dcd6ee3c72b67c6384ff3b4b0e9562e63a12e67f14343c1b067a9402234694	7	7047	47	681	691	27	4	2023-08-16 11:45:36.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
693	\\x3b7d086d0fde1680f744603c83cf951220aaa966b4e85bdfc04cc7d029b1a46e	7	7049	49	682	692	6	4	2023-08-16 11:45:36.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
694	\\x148c233015755098d1f8a7cd5ec65b41ab4f519adb3beb1dcfda9c1619de9c52	7	7060	60	683	693	6	4	2023-08-16 11:45:39	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
695	\\x6fb5439fd21f8fb253f6052bbde24649d1f63b1ca297e3b5133ccf25b085472b	7	7069	69	684	694	27	4	2023-08-16 11:45:40.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
696	\\x2ba87822bfdf34cf0c87434893fbe776752a78b8c0c41a0ea131e3353f6347ac	7	7095	95	685	695	46	4	2023-08-16 11:45:46	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
697	\\x2fc5c3d91ae0a771fe270dec50ece25f465e404411e5c8a125b9adbbb2ac7ceb	7	7115	115	686	696	30	4	2023-08-16 11:45:50	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
698	\\x2ac25f158fe1a6fa17f957eaf3c1785c3b6d8b154b66f54e57086c45c7a778d2	7	7126	126	687	697	46	4	2023-08-16 11:45:52.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
699	\\x74094a4ff3a9fd5ffb57e836f438bb57c4fa42b19c6134b02f3773169d17115d	7	7143	143	688	698	8	4	2023-08-16 11:45:55.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
700	\\x18296e7deef3c35f22c8e5e33231db574218c6af31c31be318f3211c688313f8	7	7145	145	689	699	27	4	2023-08-16 11:45:56	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
701	\\xe12312900a2a33747c3e555d675723ad444a537b5e02f1fe273ba6d8a134671a	7	7156	156	690	700	27	4	2023-08-16 11:45:58.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
703	\\xd524fddfd35b272aaf2a1fd9f4bf72d83c81627d9bc8bfecc24eae5b203c50c8	7	7174	174	691	701	5	4	2023-08-16 11:46:01.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
704	\\xa2263d4c590feba3e5bd5a1a5d144de0e0e58bd5202a39e315ae6ea506f0737a	7	7183	183	692	703	6	4	2023-08-16 11:46:03.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
705	\\x211e6d8ed19e59561b0dd90cea4f5193602812ca8b63334bc884c8eff468fe57	7	7188	188	693	704	46	4	2023-08-16 11:46:04.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
706	\\x6fd14d155eadba4fa092794e15bbffd687c4ec55198e37026b8f824cf554ce59	7	7195	195	694	705	5	4	2023-08-16 11:46:06	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
707	\\x23e639cbcd221607a9e8752b90cf5a0f2bddeee834c404ef06122ccd00457984	7	7196	196	695	706	28	4	2023-08-16 11:46:06.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
708	\\xe0601a054bf6fcc7c100e7058365e252cffc001594361e9a10e86e8de644553d	7	7198	198	696	707	28	4	2023-08-16 11:46:06.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
709	\\x18bcc9614df3ffab935085a120144334c7fc33be6e7f866ea42995819180c64e	7	7203	203	697	708	30	4	2023-08-16 11:46:07.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
710	\\xdecb6e3dd093e9537598d89d00a4c37e4acb9f5a91c759eab7b7e05fba261954	7	7240	240	698	709	27	4	2023-08-16 11:46:15	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
711	\\xa84a86adca731173277272bf88eef35e149583df9162dae4785256f503b8862b	7	7243	243	699	710	6	4	2023-08-16 11:46:15.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
712	\\x124051902c46082c09c2b9332421aaf95beb8bdab904a190df123783ef9cf2a0	7	7247	247	700	711	27	4	2023-08-16 11:46:16.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
713	\\x5215c03f3090b56ac3fcdd36c4d821d3fbd67d4beca5dde1e2a7e6b319f111c2	7	7251	251	701	712	3	4	2023-08-16 11:46:17.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
714	\\x7a8de18258316b96b269182905c4255825cd0d5ae113a738271ef9058eaf23b5	7	7254	254	702	713	28	4	2023-08-16 11:46:17.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
715	\\xba82fb875c6b6e977ef43f68f0927f097ba838d6fb1fc63857503caf97354091	7	7270	270	703	714	46	4	2023-08-16 11:46:21	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
716	\\x63f02646d501686ac1e4ea4ea825762b90cb895df04eb45cee4d40a58ace52d8	7	7280	280	704	715	3	4	2023-08-16 11:46:23	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
717	\\xdd5a44b037a1ebb7f3946a4a06c6e817a434f180107219e43b6aa7e48816de45	7	7288	288	705	716	27	4	2023-08-16 11:46:24.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
718	\\x3be578fb5918b88ea4156a469a18883e806e9a4604744f0582cd01ecd12d6095	7	7295	295	706	717	5	4	2023-08-16 11:46:26	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
719	\\x2d821e9c04602311c8d77d2dbe3545995f21db5beeb04bd8db6e9bc550aa8bff	7	7356	356	707	718	46	4	2023-08-16 11:46:38.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
720	\\x241cf6340a0b1ffc703508a1c78a0d7cafcb67ea0fdf63d4fe93d2c913f9421f	7	7363	363	708	719	46	4	2023-08-16 11:46:39.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
721	\\xb190a47c4ecdd05e04d2e31e13726599e018f1e555528f8d42d864579de45d5e	7	7365	365	709	720	46	4	2023-08-16 11:46:40	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
722	\\x9da848cf06936678ed138d421bec9024de90eaba23c41711d8aadcb3b63a98f3	7	7367	367	710	721	8	4	2023-08-16 11:46:40.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
723	\\x7c24a734cd65f53b79dd1d0870da1e9250c4f9b2f42f6bcfa7ac37f3b9c94e56	7	7369	369	711	722	28	4	2023-08-16 11:46:40.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
724	\\xb0060d187f0f21057803530d07c1cee809b050812ed0f5c81c8068aef64e744b	7	7376	376	712	723	3	4	2023-08-16 11:46:42.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
725	\\xa67c79c9776e7421ad1d6792dae68f2c826cec9826ddf5240216fb6eb6e1470e	7	7396	396	713	724	27	4	2023-08-16 11:46:46.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
726	\\xd492d1b5b8994aea75678ba3e86842351dbf51e00ba6b4ef965a5c5e58f32266	7	7403	403	714	725	6	4	2023-08-16 11:46:47.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
727	\\x275235d6e28bb7006db6b704f6b121d436b9a2644a8cbdc26d96d7d62c9a700f	7	7404	404	715	726	27	4	2023-08-16 11:46:47.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
728	\\x16837bae96fb45787bf1a6d8ee767f0b507e409303290909ee32b65189b41098	7	7405	405	716	727	27	4	2023-08-16 11:46:48	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
729	\\xf10fa1d185b8f09fa0ba0dbeadbeec1d1595e2df8770189d030962cb519eb9c7	7	7408	408	717	728	6	4	2023-08-16 11:46:48.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
730	\\x8bfeda7f47fd18f63023e6493ea5f86ab5b171b8050bbfd33988840dde273976	7	7410	410	718	729	27	4	2023-08-16 11:46:49	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
731	\\x74abe4db581c636574a65175930b3e8e64271f7df527804a2d2d09d6b096a27f	7	7411	411	719	730	46	4	2023-08-16 11:46:49.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
732	\\xd1368cd4212452edc21471e7ef06e4c51f49004af76a5a748f9c8f954a2c2a9f	7	7412	412	720	731	30	4	2023-08-16 11:46:49.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
733	\\xc6131c370f5cd624488ced10fa8799e6ffa1b179d0e8bb11c8d7d4ed4369fdb8	7	7431	431	721	732	8	4	2023-08-16 11:46:53.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
734	\\xcd3800c2efa2b97bd1afa6e6838b0351b1660e49582d9d0411e53320577fe79e	7	7435	435	722	733	6	4	2023-08-16 11:46:54	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
735	\\xbf9730b5f18515e9f33ffa6853760220acfa90006c55e25fb4a814d973f2101a	7	7438	438	723	734	8	4	2023-08-16 11:46:54.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
736	\\x63539309a3744efaa91d4053c1ca1e408950983d66cf46cb5c46237f8d4a6a78	7	7448	448	724	735	15	4	2023-08-16 11:46:56.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
737	\\xa2eb1d35ecc4259b7620d5424d5ea6fa6b077ce5b3c3e0b7f29ba1302f107cac	7	7452	452	725	736	3	4	2023-08-16 11:46:57.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
738	\\x1c27e4ed699426ec659731f32c80077c4822b0ea3dd4a9d47211ffb5979ae2d5	7	7458	458	726	737	28	4	2023-08-16 11:46:58.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
739	\\x01785559b770fdadd6cdc0ae4177793df658534a2284f483fdadf14e55ad97ee	7	7473	473	727	738	3	4	2023-08-16 11:47:01.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
740	\\xcbb6ac15818d328046e5dbb87347e9a96e78f134fefef6bf66ec000a30836c8c	7	7487	487	728	739	27	4	2023-08-16 11:47:04.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
741	\\x71fdb411f0577c8c5a727a242831ffab74ab373eba2de265b1cb8741d46be76f	7	7489	489	729	740	15	4	2023-08-16 11:47:04.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
742	\\xb7df9e19e36b87195c93346280d07d5854073892ae35bef1ea29b06ac5874236	7	7493	493	730	741	6	4	2023-08-16 11:47:05.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
743	\\x07729d3e494e619f4acce450ad73215642e2342056b9c0411e25d3cb4651f182	7	7514	514	731	742	5	4	2023-08-16 11:47:09.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
744	\\x1e9267ad6b99a284a152f1e2c019d0337029d3d740e4fa500a3c5fb9ad72fbf9	7	7523	523	732	743	28	4	2023-08-16 11:47:11.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
745	\\x093bb7a7f4094cd615ebe6733fad1e40b8fb6a36476379bf7ed25efa537a5d4c	7	7526	526	733	744	8	4	2023-08-16 11:47:12.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
746	\\x7820e8a8c78ea73a9f537dc79c306754ef60e6ae582248ec0f319c0797f17a4d	7	7539	539	734	745	6	4	2023-08-16 11:47:14.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
747	\\xd7c07df83524118dfac00158136fb5e22b8e223fcebd33ee29ec541b5a49edcb	7	7543	543	735	746	30	4	2023-08-16 11:47:15.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
748	\\x93bd9b39d4db946a52a26d0ffea5d1c743737a70bfe330ee2fcdf8fa94cf9a9a	7	7548	548	736	747	30	4	2023-08-16 11:47:16.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
749	\\xad967365c3d20f872a477c36cb52cd7eb6f2d4614e0fb7a75a4c52f41cca88f6	7	7552	552	737	748	27	4	2023-08-16 11:47:17.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
750	\\xda9fe714b7dcd2e3664b38180efde6a7426362219d314742b5c83cde19f225dc	7	7567	567	738	749	6	4	2023-08-16 11:47:20.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
751	\\xb834facb213669fd281cc62fcff9d797d639eb40d47fe091acba78ffa3a292ff	7	7574	574	739	750	28	4	2023-08-16 11:47:21.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
752	\\x21b37cf79d8a880527eb1cb5673f164a5623f605489c2ece454d84f82c1c6373	7	7579	579	740	751	15	4	2023-08-16 11:47:22.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
753	\\xff7ab8d3f679bfc07fbf9059582aa83c733a71ceb696f54da3aefb7b39fa5475	7	7582	582	741	752	8	4	2023-08-16 11:47:23.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
754	\\x30d65dc477d03f7809b8e07c0bf95b4a96dac0255cd85547a493bc705169ed88	7	7590	590	742	753	5	4	2023-08-16 11:47:25	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
755	\\x635062f7f7f408ce7b90bf8c5b62d00c729cf4e7d756f01c421a744c5d39de2a	7	7595	595	743	754	46	4	2023-08-16 11:47:26	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
756	\\x7116ff3ca72642cb961ee8e0b9f00e7a24ea22e4a6c2335fc16b8f595c60b7d1	7	7618	618	744	755	3	4	2023-08-16 11:47:30.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
757	\\x14ae299354b002b57da483d4b404b5f080d6276710aa044ca5ee5a8a760673b6	7	7624	624	745	756	8	4	2023-08-16 11:47:31.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
758	\\xe9ced57c6c5f0718925f22422ba1e4bfc17531875c689ef622ee08c0dbdc5b85	7	7632	632	746	757	6	4	2023-08-16 11:47:33.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
759	\\x6c2c4927e214772a3acfff4832d9ef437423926fc1af5848b2a61b3b6d83c3d3	7	7634	634	747	758	6	4	2023-08-16 11:47:33.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
760	\\xe3fc9bda080b01f5146f63b089bd6b11940b2c092c832cb0c86731fbe3e3681c	7	7638	638	748	759	8	4	2023-08-16 11:47:34.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
761	\\x7d319d4623e3ed057b5d15dcce8554d20719e53f05606de647e15fb7fb125f22	7	7667	667	749	760	30	4	2023-08-16 11:47:40.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
762	\\x577d63ba8168247a22f89fb0f216a487a049ea231d5f2725e864a75ef363433e	7	7670	670	750	761	30	4	2023-08-16 11:47:41	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
763	\\xba1d17b6c20c318b09a0c44e8b307920257931c9c434621bcd8879816db77f8a	7	7682	682	751	762	27	4	2023-08-16 11:47:43.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
764	\\xf943cbdff65abb2ddb7c9fd76cd07b544e86c7b3e109dcadb7c20bf0fd0850b2	7	7699	699	752	763	46	4	2023-08-16 11:47:46.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
765	\\xc299a4075710ce848772a3e827c6b8459d996e1fcb1eedce68d6ec7f2d2671a8	7	7704	704	753	764	15	4	2023-08-16 11:47:47.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
766	\\x4f81cd9ba455b1e6efc210dbc55b615d874fcf8ce7e514446ac763b25d4dbbd2	7	7709	709	754	765	15	4	2023-08-16 11:47:48.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
767	\\x3f66b33523315564ecde438b798f45331c1adca07b058dc81479c737814b9409	7	7714	714	755	766	8	4	2023-08-16 11:47:49.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
768	\\xf1d334c9f603d59011b0ad916f045e00bf47dee9e889e39c7841034608b6ed34	7	7727	727	756	767	46	4	2023-08-16 11:47:52.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
769	\\x836f0c4ffa0d5bfb2d938d93858cbc6b60b670befa87353d438b7867510ea992	7	7745	745	757	768	46	4	2023-08-16 11:47:56	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
770	\\x3d49219c17aa866f5eea33d9654807ce45842e6ac3266d3d5c9787fbd89173c3	7	7749	749	758	769	28	4	2023-08-16 11:47:56.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
772	\\xc9ec3b5deb78f6702b34bbedad3cc66853a71d8af7562b5d58f095e0ba15721c	7	7759	759	759	770	5	4	2023-08-16 11:47:58.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
773	\\xa2b630e9a744da69076e99d5579391418a3eb3d38fd6277f0b94d53bedfcceb0	7	7760	760	760	772	30	4	2023-08-16 11:47:59	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
774	\\x84edec94cbb4214e5c9a5f7c05b269f8fcbd5c026ba50bc0ba1c76023de267ea	7	7774	774	761	773	5	4	2023-08-16 11:48:01.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
775	\\x77ca08067c066c6d0b7c13c964dc33eafc26438496c631808834ab320db6064a	7	7782	782	762	774	46	4	2023-08-16 11:48:03.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
776	\\x9f18441c387eaf297cc7155cfdb0f8642d4aa42b9b0c724075906b9f3a9abbf4	7	7785	785	763	775	27	4	2023-08-16 11:48:04	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
777	\\x66003a122d1e0f31bcfb18a7ca58e6b72bd9824cbdba986053c7ed6177a64aec	7	7806	806	764	776	5	4	2023-08-16 11:48:08.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
778	\\xd716fcecaae80fc2f61b3d88123a8c7cd1b3525280b6a7ae2e36a802b1ca6765	7	7814	814	765	777	30	4	2023-08-16 11:48:09.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
779	\\x43f5903944ecfac59890594b70f6f90577726cb826f6809c606f4ea5459ae499	7	7815	815	766	778	30	4	2023-08-16 11:48:10	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
780	\\x532a6d2f88bc336ce4362a590462c90bdce37653ea87bf3921165bfad25e51f0	7	7819	819	767	779	28	4	2023-08-16 11:48:10.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
781	\\xa05c48fb13a79610f8ce63a91f5487ee9a54b38075f4c5b9c554198a268602b7	7	7823	823	768	780	27	4	2023-08-16 11:48:11.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
782	\\xe8fc02e1bb7c0484b7f39921a777c700a3bdd2cb35acad6ee9c39ef93077c8a3	7	7827	827	769	781	30	4	2023-08-16 11:48:12.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
784	\\xda9137f35c617b99109f1abb9340d7142a72cb1a745e4f134f577647920ba689	7	7832	832	770	782	6	4	2023-08-16 11:48:13.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
785	\\x613cae158d9fc86f4468b1a9a756c4288cce78c692c3115a6284fc55ac9b74dd	7	7841	841	771	784	15	4	2023-08-16 11:48:15.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
786	\\xea3fd7b50aa3255ff11c6234f0dd1dc47ba1f329353c7354deeda09de64b9a0f	7	7843	843	772	785	28	4	2023-08-16 11:48:15.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
787	\\xc99dbe298a01cbf82466254379c35e9f5725c8f003074460c736b7460566876c	7	7846	846	773	786	30	4	2023-08-16 11:48:16.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
788	\\x3b91ad9415287dab9a33b72f23998160a3d992c4bb5c62d10b1e128b3cc154b8	7	7857	857	774	787	27	4	2023-08-16 11:48:18.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
789	\\xc8faea862610624ca7f75ee23f0db57c5334fd39f0aab2637156c64c9cc8e085	7	7858	858	775	788	3	4	2023-08-16 11:48:18.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
790	\\x08e777faeafd9bbbe2c4b8e0b7bb119d89a32b8b0f6e66b64700d71e1d61624d	7	7866	866	776	789	30	4	2023-08-16 11:48:20.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
791	\\x9b83c4c253ff9cfe843880b50b4284c702e4121175ea7c56aeac897b183512b2	7	7869	869	777	790	8	4	2023-08-16 11:48:20.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
792	\\xc7cba619ec7208eab3b42d383650fe2c2574db6bad8df64af47c5c11745983ea	7	7877	877	778	791	30	4	2023-08-16 11:48:22.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
793	\\x3463afa93c72783a78a8d33c35615b8545380272fe3a29ffdef6460c92de2f42	7	7879	879	779	792	5	4	2023-08-16 11:48:22.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
794	\\x9fffa9decefad912291741c67e793c68bb630ef1ce46801b2eee8fa4d746a910	7	7884	884	780	793	6	4	2023-08-16 11:48:23.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
795	\\x189cc8256be228e6015a87151e266c5da219d41d02af93bc88a3748415493b39	7	7892	892	781	794	30	4	2023-08-16 11:48:25.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
796	\\x89fd1258050b954bfb5c52485c8a41cbe2e7e9498f438029f20fe5a5a275107e	7	7925	925	782	795	15	4	2023-08-16 11:48:32	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
797	\\xe3ac27f5bf98d34e131dfa952a6cbe0bdc088c5504022e42bc411b5d02c1f692	7	7941	941	783	796	6	4	2023-08-16 11:48:35.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
798	\\x2e02f20e1033286afeb6b81aad7a6a2a32b8fede163e6987bd02185ca47d3046	7	7953	953	784	797	5	4	2023-08-16 11:48:37.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
799	\\xde7fa05d66a039b1ef317735356c6ce0b1ead97e03b4e065e644edf1568bb499	7	7960	960	785	798	30	4	2023-08-16 11:48:39	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
800	\\x160167201e01f94723be145e49ec453147345fd842f90fd22bb0b9b6b2834367	7	7970	970	786	799	28	4	2023-08-16 11:48:41	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
801	\\xef025a2acc85ae47f39d9a1fbddf9c9eaf084ee3b47a42ad537ea10ef37cd0e4	7	7985	985	787	800	15	4	2023-08-16 11:48:44	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
802	\\xc49bdb5e13a94bc80409fb192773cab8e248302cf9cbbbcd5a05bc8f52656025	7	7990	990	788	801	8	4	2023-08-16 11:48:45	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
803	\\x246977acddbaf2d2efdca14ecb24b7e9d43e2ccd5963234035614dc37ab3eb4a	8	8013	13	789	802	15	4	2023-08-16 11:48:49.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
804	\\x98bb9e29556b45ac58ec4bb94bf4e374b4b145927e5b0ad4a7c7ed3b53e01f76	8	8015	15	790	803	15	4	2023-08-16 11:48:50	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
805	\\x25103d603ea772beeae96c5f566ef4d36f7862203942a6f6f9e8aef27ac14a41	8	8022	22	791	804	46	4	2023-08-16 11:48:51.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
806	\\x38fe5add90123914d627ddb73265aedfed6c8d165eb92ec2f52bad30af61c753	8	8028	28	792	805	6	4	2023-08-16 11:48:52.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
808	\\xbe21f304870962ec83605445b86a13d1e0df98f9140e500ef84a0c779b63a17f	8	8030	30	793	806	27	4	2023-08-16 11:48:53	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
809	\\x48c86cc209ce9b41d13853d6f1ed6e62fe6f6a43f0f3646431d448dec1ad89ba	8	8055	55	794	808	27	4	2023-08-16 11:48:58	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
810	\\xea1a378c30b9abc17d938745d9473ac3b150e8e3de3d66e9c51d7a8871aeb057	8	8064	64	795	809	5	4	2023-08-16 11:48:59.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
811	\\x353d043aeca4e088d992449ce109e97a88ef69b96d7736f8e2c0455b5559994b	8	8065	65	796	810	46	4	2023-08-16 11:49:00	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
812	\\x9496dd2d0b69103141b8a0aee6ea1c2fe7e329049ac55bc78df193339b5b7041	8	8078	78	797	811	8	4	2023-08-16 11:49:02.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
813	\\xc584ef45d900602770083e5a1f965dd5e5c0fb510a1d75ac0535316a1667696c	8	8087	87	798	812	15	4	2023-08-16 11:49:04.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
814	\\xeff7e10510fca2da8745a3995a722dcf9305322acd89bb1789751420adb20ee3	8	8095	95	799	813	3	4	2023-08-16 11:49:06	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
815	\\xc4fec46cadd6ce2c2067be50093c7f9ba73d9ef85d7da769f8ffbb48dcd4be31	8	8100	100	800	814	6	4	2023-08-16 11:49:07	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
816	\\xd0eebd05faf37a9f38475eb3ee221e79e1601f08edc07be7a89f13dcbed3ef24	8	8101	101	801	815	5	4	2023-08-16 11:49:07.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
817	\\xebcfe4546b868be871a5095eb7e57553b1c7645a6edbce0433ea762a1f433ddc	8	8102	102	802	816	8	4	2023-08-16 11:49:07.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
818	\\x65ab8136cd01494e51536bb0a8e908e65ce327e5494ac16546837cee4bfd69bf	8	8116	116	803	817	5	4	2023-08-16 11:49:10.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
819	\\xdaca15962b27bde8a9eb1fe653c4b730713c3b57cbfd610dc68f14e1b1aa3d40	8	8130	130	804	818	27	4	2023-08-16 11:49:13	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
820	\\x07f60ab23bdf5b63bdf7300b710967f7f4d143a631d21b6c63af3ccd8a2c1439	8	8131	131	805	819	27	4	2023-08-16 11:49:13.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
821	\\xacea292899631017d42581e04b95aeb02e8533245ab891ba785d1c799a23af35	8	8137	137	806	820	3	4	2023-08-16 11:49:14.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
822	\\xd46c15a73193b295902b699edee36a7b36f3dc1daf5b7799c0771ad13af919ab	8	8138	138	807	821	5	4	2023-08-16 11:49:14.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
823	\\xf8f1ab7c3c74956bdd9889fd032e149e777ef10dab6833af58b79931f0ec0bb8	8	8153	153	808	822	28	4	2023-08-16 11:49:17.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
824	\\x3cd404f21dcaf897450159cb6bcc186c0bd2e1407f6236f2b920798e4d9b6611	8	8158	158	809	823	27	4	2023-08-16 11:49:18.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
825	\\x23c404ff321235a525e3a9e58f6504b4cba95a5b7a68740cf94513e367797b0d	8	8178	178	810	824	30	4	2023-08-16 11:49:22.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
826	\\xe8014815ccbea83ec2dab9a3f101ab2561c65e71ad6eca8e2ed5be10899e8a59	8	8183	183	811	825	15	4	2023-08-16 11:49:23.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
827	\\xccc0fc87052a0a7fd7a4acb234fdc84a9e630856fec0db356643fe82866e6762	8	8186	186	812	826	6	4	2023-08-16 11:49:24.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
828	\\xe7fd276244c88585837f0903197c02cf5805ccf87819d7061a3f74a3d5211944	8	8188	188	813	827	28	4	2023-08-16 11:49:24.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
829	\\x81704f07415124f2f5ab85ce1ba09a7a6605d990e3a1da9daab931ec31c6fe93	8	8193	193	814	828	3	4	2023-08-16 11:49:25.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
830	\\xc58e8dd276881b638dac1656aba6a5fbc5b462b56a259dc0c1701b92cf8a7a43	8	8203	203	815	829	30	4	2023-08-16 11:49:27.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
831	\\xb46545e385cfe8159ca3f2d1340ef9654f7aecd3b6c53b5364c109ad2648d6dc	8	8216	216	816	830	30	4	2023-08-16 11:49:30.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
832	\\xf4c995888f3439537a054a2921590e0fcb6d7db6b14c019ffde6433850e1b0a1	8	8227	227	817	831	6	4	2023-08-16 11:49:32.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
833	\\xf31e4e5a8679b95608ae9f1edfda3ec28b1929d5f32b411b1202ac64b1c5ea65	8	8230	230	818	832	28	4	2023-08-16 11:49:33	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
834	\\xf13bfea2042c959683b0fe037212c708ae9756f62d80224361e7685283e8ade7	8	8238	238	819	833	8	4	2023-08-16 11:49:34.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
835	\\xd40419b7f68d34049960303d9a38600ce6b9ec92e8b9c9f3280bd02b5da9404e	8	8249	249	820	834	6	4	2023-08-16 11:49:36.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
836	\\x1ea9e71b45386c261e75364dc7d526d5cb8b8d9e68c7254c7882fbe7c5d17b06	8	8261	261	821	835	3	4	2023-08-16 11:49:39.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
837	\\x825af509d9a5e015ef5fe43758e9ee8dd987a165674956ac694ac8b0ab3ba22f	8	8262	262	822	836	3	4	2023-08-16 11:49:39.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
838	\\x307321f9a6ce46abd68c417cafab251027b81cdac6161c1d8b524b498eae59af	8	8266	266	823	837	28	4	2023-08-16 11:49:40.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
839	\\xdc78e9a7213fe639fe4454cf71d6a00ebb7e59073746ea4a93f0063c34761b32	8	8304	304	824	838	15	4	2023-08-16 11:49:47.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
840	\\xe49c8d44034569060093189421815db45d77dd159ce8bf5ec7c9b0e28dee7d74	8	8314	314	825	839	27	4	2023-08-16 11:49:49.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
841	\\xcc49d57279df8a7679583a16140b985ef83e7ffea4f7a55608663687df12720a	8	8317	317	826	840	27	4	2023-08-16 11:49:50.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
842	\\x05b4faff2f206c1007b4635ee951855e278fce7774896877f500876b8703984f	8	8333	333	827	841	28	4	2023-08-16 11:49:53.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
843	\\x5d66c4e6ef059b10219cd47559cf5d4b7678ccc8957753c00b51ff3f1d9cc030	8	8361	361	828	842	46	4	2023-08-16 11:49:59.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
844	\\x257ba1b926e99e4ef8bebdc0df6b6f0b1b766218b559ea0a54308ea34fd13903	8	8364	364	829	843	3	4	2023-08-16 11:49:59.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
845	\\x8845972e1e0d9e8d06925e07b269d432ad7bffddb4d4c338e540fd8aa792ab55	8	8369	369	830	844	8	4	2023-08-16 11:50:00.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
846	\\xaff572f25cca545d9d77e236a36783c7718dd8d0ee02be94e9bcfd3d1b85c458	8	8385	385	831	845	5	4	2023-08-16 11:50:04	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
847	\\xd2476fdcdf8775965200fe0bde9ab86a2c1a6932269aec836d48a257cfbf799c	8	8387	387	832	846	6	4	2023-08-16 11:50:04.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
848	\\xd281255b21e5c50cfe62f731c83b88ca2432070af40e3eda07bde61ad12f5f1c	8	8399	399	833	847	3	4	2023-08-16 11:50:06.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
849	\\xf77dfcd01b3353680c2f0ec9e62bcb3deef69415fb526065c779392b865f5e56	8	8400	400	834	848	5	4	2023-08-16 11:50:07	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
850	\\x1de8b88703b4d49ce719511a882855c28be06a5f52c7099cb2d317d880ebc859	8	8403	403	835	849	27	4	2023-08-16 11:50:07.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
851	\\x1978ab75478de483f126f1854e5c43e07762597fe54648cf43e67ffa69b9f66d	8	8465	465	836	850	46	4	2023-08-16 11:50:20	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
852	\\xd9597b89b3a26c01cd388ddf9649787860b588d5916e5a1bf303eb87c468f354	8	8482	482	837	851	3	4	2023-08-16 11:50:23.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
853	\\xc1151d21b53f0c05a462da12d77ffc298391aa2c30f880c7aa19c0074b53f55d	8	8490	490	838	852	27	4	2023-08-16 11:50:25	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
854	\\x45b92c8fc50d3c870960cf06cb474255b5bfd2a680c0d2940e7f59f8cc9703dc	8	8507	507	839	853	15	4	2023-08-16 11:50:28.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
855	\\x88566eb9765229e244dab5e9d820f40ba5c35ed6d0faa17645bfdba110657ec0	8	8516	516	840	854	28	4	2023-08-16 11:50:30.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
856	\\xcb988fdcb2afb96fae8cac370f563e4586f03d3cc37a4db9d4144e169c162108	8	8532	532	841	855	3	4	2023-08-16 11:50:33.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
857	\\x15b7ce1cfb8874c3f01cc2e4f2219755ae1455dbeb6abe528f2e90354b959f6a	8	8534	534	842	856	28	4	2023-08-16 11:50:33.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
858	\\xd235988ddcd235945d11aad7661a3556ecdb0c938994c6310e4a9eb2867714a4	8	8535	535	843	857	46	4	2023-08-16 11:50:34	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
859	\\x4e6d203129f4e28b4ab9ae5f3ad24442c5910dafaeaf6207aa00a91676ecc5da	8	8538	538	844	858	46	4	2023-08-16 11:50:34.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
860	\\xb39e20bab84eb40b65e7fa06d4e2892388a3b232eb5852fa832d9785b4478044	8	8544	544	845	859	46	4	2023-08-16 11:50:35.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
861	\\xe884eccabb7c3dd891e221028c71ef09886e9c77a4b2baef19b33a9189a84a8b	8	8547	547	846	860	30	4	2023-08-16 11:50:36.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
862	\\x38293a50848aaf39b62af16c4061b30b29c580d2d9174cf4b0b5cf6ccef18c48	8	8550	550	847	861	3	4	2023-08-16 11:50:37	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
863	\\x74754a7f47e1c011c144ac183ee067821438b7805d3d110656af961c19f69553	8	8563	563	848	862	30	4	2023-08-16 11:50:39.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
864	\\xd900c62a82235e5a56c2cc345d537831e7b804fdc2dddb4d54b833a164b74335	8	8587	587	849	863	46	4	2023-08-16 11:50:44.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
865	\\x735da0216e8f912f25b600783afdcf93efd5767969f02497f8163581e4274434	8	8597	597	850	864	28	4	2023-08-16 11:50:46.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
866	\\x3453cc846bec15f927c074118c44d5b659d442e721d81772e207c2f89bba1c7f	8	8604	604	851	865	8	4	2023-08-16 11:50:47.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
867	\\xac58b8d5318206f5d6661575ea1c0af9053ad2fecf036074a088c2263cd967b1	8	8607	607	852	866	6	4	2023-08-16 11:50:48.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
868	\\x7fc7197f1c46639b61136ae7b65af60cc00fe3bf927efd877a3fe823ec30af76	8	8614	614	853	867	6	4	2023-08-16 11:50:49.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
869	\\x663de09bd95e875534c1aec46b25f4981994b16feccf23d33f1b1f891646d947	8	8632	632	854	868	46	4	2023-08-16 11:50:53.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
870	\\x4852029e9148906fb847f013a0f26707b8bf68b9222498521845160d9d6a596c	8	8634	634	855	869	46	4	2023-08-16 11:50:53.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
871	\\xa66f3f0d7af07cbaf7a693641c4710b8d71850c01707b67186d26c9b0634d3e7	8	8648	648	856	870	3	4	2023-08-16 11:50:56.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
872	\\x1d986ba48ba178b6b38ed140d259fd238314e1c8c06072671080256171f874a7	8	8650	650	857	871	30	4	2023-08-16 11:50:57	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
873	\\x4905a983456db1edc111a10dc5937a2fa739068c0f447d894139fa1c7fad97f9	8	8651	651	858	872	5	4	2023-08-16 11:50:57.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
874	\\x017723fa1e2626b50c7f7e8bd304d2ebeb515f143365a7be060d19c8104222c4	8	8654	654	859	873	6	4	2023-08-16 11:50:57.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
875	\\x9408ab38d100df8cded61c8d8af29d3fe582de6e65fa85cf02cc5bcd4af567e0	8	8656	656	860	874	8	4	2023-08-16 11:50:58.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
876	\\xcb2e2693751f39545fdc2c130f298f3dbf03dfba85f5e74fd43342f460930f1d	8	8666	666	861	875	6	4	2023-08-16 11:51:00.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
877	\\x19daaf2d473f1c2cc4f1b5ec72d2e3c4ac3b140114bcbf5ee26ae2072d0d044b	8	8683	683	862	876	30	4	2023-08-16 11:51:03.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
878	\\xb544e5143d7789728742198f5e4b7f93a6997b9ef72a23915a666f1a96ba36d8	8	8703	703	863	877	8	4	2023-08-16 11:51:07.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
879	\\x69bee62083754f5defb674e603a7bb8610ce33958bbb6fbf6473c6df8cae64d7	8	8704	704	864	878	30	4	2023-08-16 11:51:07.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
881	\\xe262dccc84aba4d5ecd197c4cfd8724ef7f4b67c632972776211282aaadc4adc	8	8707	707	865	879	15	4	2023-08-16 11:51:08.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
882	\\xaa594a387df4a7598c3fa938a1c3a0a820b3ea55eff9f3dd66fb7bcdf7d9e2fd	8	8728	728	866	881	3	4	2023-08-16 11:51:12.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
883	\\xf37f9f98394d88bb5e96190f100eab8791683a064df3bb2ff391299729502d14	8	8733	733	867	882	30	4	2023-08-16 11:51:13.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
884	\\xf64df5634937af9aa84dd0408a1b82ec0907a15cbf6cb2fc3ecbd7936b4a8cc9	8	8765	765	868	883	5	4	2023-08-16 11:51:20	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
885	\\x4edb841371418ab63ae81444d1176971cbf2ff015fe213160ac62467b21a4353	8	8768	768	869	884	5	4	2023-08-16 11:51:20.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
886	\\x74ee36dda3b0ccef6c921f347c02b07d21b0b2eb2953604df49a0bfdd3053a1f	8	8782	782	870	885	30	4	2023-08-16 11:51:23.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
888	\\x9c427d8aa2f750a1d2e9630719b422152621f3cbb3b9ee70465e84138b1d27dd	8	8791	791	871	886	27	4	2023-08-16 11:51:25.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
889	\\xe3ae8cb180a82509252867779f1d8b944c21ecfc81970c167a40432687a28ac9	8	8797	797	872	888	3	4	2023-08-16 11:51:26.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
890	\\xad47830331515e00e4c58395226a35331127635fba56c2eae2dc75f68d226604	8	8807	807	873	889	27	4	2023-08-16 11:51:28.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
891	\\x4e05d9f80ca7efebb75e603115583bf380d29234b7ad9564ef2a31783622ddfa	8	8816	816	874	890	46	4	2023-08-16 11:51:30.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
892	\\xb30446dd45d047d77e566cd412bfd18847f9705d9e9cbc7c6196aa996039a928	8	8825	825	875	891	27	4	2023-08-16 11:51:32	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
893	\\xad5afd5e1786652fc302ed4c6d227239502bf7843eb86ea79f7e3d7673c9b93c	8	8832	832	876	892	6	4	2023-08-16 11:51:33.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
894	\\x5af82ff8e3ab73d5054e22a4ef5593b21ac6c3ece7eb671b3d54f2863d601683	8	8854	854	877	893	46	4	2023-08-16 11:51:37.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
895	\\x3e51ed3e65ba36afc7cd53e952675f7addbc62a974e9f3066b7b6c5e2214568f	8	8856	856	878	894	46	4	2023-08-16 11:51:38.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
896	\\xb9bb1e015299e91fc7f75a23ffd7dba1469b8ed3b3aac4f446a568f3390ff9fa	8	8870	870	879	895	3	4	2023-08-16 11:51:41	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
897	\\x06b64a794f895d4992c35e1468e054061e850ab6b3739bd5f473b1781c53745f	8	8877	877	880	896	5	4	2023-08-16 11:51:42.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
898	\\xa66c614e49cffbc4393000c76d0bfe1ed0185742aeebb4feff5d761bcde4bd81	8	8889	889	881	897	27	4	2023-08-16 11:51:44.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
899	\\x8d378af20995dd95dc83586d443a568bbba6e4a29e23bef1c1ccbbd17bfc1b10	8	8899	899	882	898	5	4	2023-08-16 11:51:46.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
900	\\x54dc83717db080225e97385341f8de376fd3c0c188dcf897f467a7f3c86696a1	8	8913	913	883	899	28	4	2023-08-16 11:51:49.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
901	\\x0ce67bd7da47b88311bbc0c0f2ec2dbcbcda843324b8e8d2760a05024fa997b8	8	8920	920	884	900	15	4	2023-08-16 11:51:51	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
902	\\x840627d46d1f8ed2950a3d200848b56db704ef3417645be190cf669f96c33e44	8	8924	924	885	901	3	4	2023-08-16 11:51:51.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
903	\\x9a9efbae35a0eee20894453505798118ed8cc1f59a47161f59a2fb0378716d30	8	8926	926	886	902	46	4	2023-08-16 11:51:52.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
904	\\xaddee7ef582793265769f52533d19781529229a1799db7772216006f183e1d60	8	8931	931	887	903	15	4	2023-08-16 11:51:53.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
905	\\x49db40f84a48218ec7df01402ce12aee5512b63020f88ec655af24ea694ce67e	8	8938	938	888	904	8	4	2023-08-16 11:51:54.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
906	\\xe68eb46402aab99325f0187b06a641e4d8ecc7a5c6384e31a2e8912ba0f4e799	8	8940	940	889	905	46	4	2023-08-16 11:51:55	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
907	\\xe76eb7b13d40d1fa861cba20be605046d28d98df8ffb8124ba52090a48d267cb	8	8944	944	890	906	15	4	2023-08-16 11:51:55.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
908	\\xc3154ffda8322f7c2f18595dbeb4b6d166af6a9de95e338c9d3dd4e2e4fa1f24	8	8945	945	891	907	6	4	2023-08-16 11:51:56	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
909	\\x7abcc6e916bcd12c270ab213c161ed759d419fdc1a695323f1275c603f2f1b62	8	8948	948	892	908	30	4	2023-08-16 11:51:56.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
910	\\x86c155f1d026eb04f2427cf0f93d8d93deed3d20b7aaee2b1322853774a788ff	8	8974	974	893	909	30	4	2023-08-16 11:52:01.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
911	\\x0f1de5030276f0a52194e7f41ec67b4ea37056dce472522996f6cabc87b459c7	9	9002	2	894	910	5	4	2023-08-16 11:52:07.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
912	\\x6c11a11bf80aa4447ad1155426315b7e87f9da3f8db88daed5818af72d12d108	9	9009	9	895	911	46	4	2023-08-16 11:52:08.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
913	\\xafdf6244aa8b2ea56ef5b25afee2015f1583011dfa8d991db3fbe03304adf21d	9	9019	19	896	912	5	4	2023-08-16 11:52:10.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
914	\\x4500155b4d54039509b7127dfef2d9a7ad2a334528c9851d5c53a7b1751e479a	9	9034	34	897	913	8	4	2023-08-16 11:52:13.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
915	\\x028234ee4317f5e9a31de8de5fd5388ec055db62f872ae2d40a2700b90008c32	9	9056	56	898	914	28	4	2023-08-16 11:52:18.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
916	\\xb4c900e94efe1a5c904086916d809746b0e87a00e40010ce964da3fd59258aa6	9	9060	60	899	915	3	4	2023-08-16 11:52:19	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
917	\\x377e30e278a37fc26b9d9875764be3d7f1e2c180ff55594a3c3a912f9211cbc1	9	9061	61	900	916	6	4	2023-08-16 11:52:19.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
918	\\xc78135d8ac9a1d15dc673d53ce8c556a34f286c26b38f3f76466d52be6235706	9	9064	64	901	917	6	4	2023-08-16 11:52:19.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
919	\\xe442ccf018ce95e527ab824be5d1035c5c01f52ddc5e57a51e5c28040082e2fb	9	9077	77	902	918	15	4	2023-08-16 11:52:22.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
920	\\xb0e8e8326cc644c43a25dca059390771e507ce28ea1b883565ec1399614c1d8b	9	9094	94	903	919	8	4	2023-08-16 11:52:25.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
921	\\x342bcd6f29778fc20b52b67835631c131e3d2c95ea61b4918b89be9445716ab0	9	9115	115	904	920	27	4	2023-08-16 11:52:30	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
922	\\x96337d1682a8b5fc697c1f118525a3b15e8b4fc8d685772708780c377b5bcd4d	9	9119	119	905	921	46	4	2023-08-16 11:52:30.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
923	\\xc813c4e54a831c8705f072e528a03c97e14f70286c76e8e86436f1d710c52721	9	9124	124	906	922	46	4	2023-08-16 11:52:31.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
924	\\x9d5d94b25b251adea8a7ed81f9d154706fd87d6e1345aa7e8e527326a2daebec	9	9152	152	907	923	28	4	2023-08-16 11:52:37.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
925	\\x36a7b5182c6f23869b6a22b5807a14acdff1bd7f18c319d7f0210b083c85302f	9	9155	155	908	924	8	4	2023-08-16 11:52:38	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
926	\\x6715ddc7304e0f9010abb7d965507129a98c09924a37487b4459f8f1008bb019	9	9160	160	909	925	8	4	2023-08-16 11:52:39	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
927	\\xa4b4c51a754f7c7f58adec93af17e00f124aa68c69a7594bcf93905f571a5bfb	9	9162	162	910	926	6	4	2023-08-16 11:52:39.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
928	\\xb06fab0dcd0df728ffb57b3ad07fffccd533b57597c6de94f817f802735ecbee	9	9164	164	911	927	5	4	2023-08-16 11:52:39.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
929	\\xe3bc7f896e4b3cd9b49c1e36dc3d5f95171bf47a282b5edf0e3f8e252f8b399d	9	9175	175	912	928	46	4	2023-08-16 11:52:42	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
930	\\xfcd90a6c375a00db2a35964f78ea8372cf2b385d4ad9422cfe7b760f03b53a6b	9	9203	203	913	929	28	4	2023-08-16 11:52:47.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
931	\\xb92e8864c01af038028d6f91967ca787bd3993f36fc02d61f0cca006ab53da78	9	9204	204	914	930	15	4	2023-08-16 11:52:47.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
932	\\xf767ef90cfced275bc61443c5014201c35390528a03f1d274210f095cf908149	9	9218	218	915	931	8	4	2023-08-16 11:52:50.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
933	\\xf6b48e8f15e3e04a7916b548df062fc66bf44fd17de7423bb72fbbf903f1bc81	9	9229	229	916	932	5	4	2023-08-16 11:52:52.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
934	\\xca6595f6e6b58b27d4e2970af33c2cd668e578330b0459162449a069fbb5d566	9	9230	230	917	933	46	4	2023-08-16 11:52:53	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
935	\\x27d3831ebfa14d6465bcf13eb06a353809818618f802912ad26d98cd7c9cd6f2	9	9236	236	918	934	5	4	2023-08-16 11:52:54.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
936	\\xfcbafa27cb2a80876c35a31d092a3dc303ad9f8d0397ddac575bc3c9975b39a2	9	9237	237	919	935	46	4	2023-08-16 11:52:54.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
937	\\xd4af8330ef9f43f889fef0afe3c388d8e87a097acca2bca4153e55dadec02a77	9	9241	241	920	936	6	4	2023-08-16 11:52:55.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
938	\\xa03666c5f2a4e1013be77add3e1daf984af7e7a7ae803f8192ca8476c1f0fc38	9	9281	281	921	937	46	4	2023-08-16 11:53:03.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
939	\\x575f3426bcc0a1d7d9a5d1946b1a8f330f9d731ac117744cbcef46d4da046454	9	9282	282	922	938	3	4	2023-08-16 11:53:03.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
940	\\x45fb36c5734e20a2d1e6a85eb4750658f62c5859506eac0d633ed1d6f632656b	9	9283	283	923	939	6	4	2023-08-16 11:53:03.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
941	\\xedf5ea5791c84e7c7459f9980c84922effbe5a15fd3ebc4b300b23e519e3aeca	9	9289	289	924	940	6	4	2023-08-16 11:53:04.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
942	\\x17d97eb7fc36a0da8e8a0af2eba9e3409cf70321a309063db55abd2677c09b38	9	9292	292	925	941	6	4	2023-08-16 11:53:05.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
943	\\x738d8528a17fd305860ad1e4d4783bb28fc6616474507357fe95e33c608242bd	9	9335	335	926	942	30	4	2023-08-16 11:53:14	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
944	\\x508f59c857a9c28d68de088631ce4143d384c606e41fae74aa32e44d6a8c2648	9	9344	344	927	943	46	4	2023-08-16 11:53:15.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
945	\\x04563bd96656310e67895cdd0c5259eb1660127aadc781bb49020c94713c7608	9	9354	354	928	944	15	4	2023-08-16 11:53:17.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
946	\\xce4199d168fa01f7a4e3c24187670efc32395bbadc8458498c34b0d23b04720b	9	9366	366	929	945	27	4	2023-08-16 11:53:20.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
947	\\xec9e8886e2c6f7af88b9c0fbe9af4e15dd87ccc5b710b85fcd8abb98536f7588	9	9370	370	930	946	5	4	2023-08-16 11:53:21	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
948	\\x5cdb7405c74e9c53cf0d905ea5b30b6a3c4cc62abbf71bd894be332a13934f62	9	9377	377	931	947	15	4	2023-08-16 11:53:22.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
949	\\xe6163a27cec82524d9ccd71a179065fe0ae7f7ee5dab79c4b502029b80dc728f	9	9398	398	932	948	5	4	2023-08-16 11:53:26.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
950	\\xea89f4e38732e8d4ad63eb354dfd28e8b2093dcb2d5a9884ff81655e5c260d14	9	9414	414	933	949	5	4	2023-08-16 11:53:29.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
951	\\xeb3928750e2bb899c039996a00dc577d3107e82eb9f2f5ffb1c220601f15d50d	9	9422	422	934	950	30	4	2023-08-16 11:53:31.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
952	\\xdcfa35e70c6e71b734c7ef1b5c387908af4b827393540b186d0b1953a8131724	9	9429	429	935	951	30	4	2023-08-16 11:53:32.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
953	\\xff3f33a3dfaf58779f04f89f6a5b0f53821a6d57c5de5992b60f63435ed61e8c	9	9444	444	936	952	3	437	2023-08-16 11:53:35.8	1	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
954	\\xadb47de6ce75ed9c8d0feade1eaee0f133484f0f15d27388dacbc5b40bdbfaee	9	9472	472	937	953	28	4	2023-08-16 11:53:41.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
955	\\x6d2d203b887b0e21bced3dc52de0709791e568cb74c2e56444e71ad8dcb9864b	9	9474	474	938	954	27	4	2023-08-16 11:53:41.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
956	\\xc1f1045a05225538d1c4b6c43dcd1ee1a8c09954776ef8a6a639114d97825bab	9	9490	490	939	955	27	4	2023-08-16 11:53:45	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
957	\\xaf8285eae9c949174969154d872c50af496669a0c746efad44372fe026fb7cd1	9	9499	499	940	956	5	5844	2023-08-16 11:53:46.8	1	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
958	\\xd6ed937915c3a8058c27c68db521d843a07a1fba20ea91cfd0c56523e307083c	9	9502	502	941	957	3	4	2023-08-16 11:53:47.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
959	\\xc73633d577fd177ddaac3011b6a42e140a89af1abc48bc42ff5d25790b45dc25	9	9510	510	942	958	46	4	2023-08-16 11:53:49	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
960	\\x4e9a33e4789f0787293e5549114fc458868bd3e5b71940d2389883eaed5d1fc6	9	9516	516	943	959	6	4	2023-08-16 11:53:50.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
961	\\x3a62867a4ea24843a9940424e72946dd3095060ca4f7203493a01dc7d04982df	9	9518	518	944	960	6	4	2023-08-16 11:53:50.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
962	\\xc955fea8377ea74777e3a74bf56e37f60a6b413fe1508602c23aaf35ce42cc67	9	9524	524	945	961	46	4	2023-08-16 11:53:51.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
963	\\x9d25e0db7e6f361ff56c77c54094f5cb0f1efe30a86d002dd245646e02415591	9	9531	531	946	962	28	4	2023-08-16 11:53:53.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
964	\\xfb25bf8c4c9e56e7eb5f825c14fb7be251b06fd7c9a75add94cca7cc8252bda5	9	9533	533	947	963	3	4	2023-08-16 11:53:53.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
965	\\x80eb16f30c9876d03e02f1dc4be3e356887a33fc5481c14c1334f0a82586745b	9	9555	555	948	964	3	4	2023-08-16 11:53:58	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
966	\\xc7849a73aee8fe7b665efc10a7ffb5f74878f83cacc0cbd0267af1b640cd61cb	9	9564	564	949	965	6	4	2023-08-16 11:53:59.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
967	\\x35b9cd9c0f954635cd811daab5d2889b552287f13282f061384b8063a6931484	9	9587	587	950	966	27	4	2023-08-16 11:54:04.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
968	\\x99f93187a2550be2a954200e811d0130bad81540fde80c63ffe6645ecfacde95	9	9598	598	951	967	27	4	2023-08-16 11:54:06.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
969	\\xb1124355cb5dcf53965944ee4aeacb11e89f8b9a092a96033fbb99f85b269071	9	9602	602	952	968	3	4	2023-08-16 11:54:07.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
970	\\x21d9152781403fe43c719b22c9fb8ab857c1bf2d3751c310fd91f9687f21ab42	9	9608	608	953	969	6	4	2023-08-16 11:54:08.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
971	\\x80b124b07cda162343920e18708d2997b5ab66249a95f8e28fac4ce23412b51a	9	9614	614	954	970	8	4	2023-08-16 11:54:09.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
972	\\x5424174465e977f81f9e5120b92a519ef37cfb536f60a14eac87a2d47122d79e	9	9632	632	955	971	15	4	2023-08-16 11:54:13.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
973	\\x00222fb227a0668b263208e19e287882427b2ddba6e2d126d31cee22aeba5adc	9	9636	636	956	972	8	4	2023-08-16 11:54:14.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
974	\\xfcaf697114f4a863002b6cb01ab40d56f1f1250708c0eef0d19b74addb1102d0	9	9637	637	957	973	3	4	2023-08-16 11:54:14.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
975	\\x2ee7f6f3c069bd6a596ab274da1751ca7b7dc76c226eafc3a6cb93e59ed7e35f	9	9641	641	958	974	5	4	2023-08-16 11:54:15.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
977	\\x7a9905b1a45e85e5a34d8d47df67e735fb28f348f4e27c4682dccf1cd064f7b6	9	9664	664	959	975	28	4	2023-08-16 11:54:19.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
978	\\xbee438a2a50e44775275a3623c19bb895c9d923e0acc82a31647483f0c2aa27b	9	9665	665	960	977	15	4	2023-08-16 11:54:20	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
979	\\xfbe9ccc0ae6704a937121d9f0b9f3a5cdfcc18049ede06ec8990b1350d9cb4aa	9	9673	673	961	978	15	4	2023-08-16 11:54:21.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
980	\\xe81fd88ebb57192f13c828c1a28cb08c0c8885c0a79e93ae25987b3b63f6d688	9	9682	682	962	979	5	4	2023-08-16 11:54:23.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
981	\\xd1586083c34253f655ddd6692399f2b86f1ee0a64cf57f6fc67fa89b0ff3937a	9	9726	726	963	980	3	4	2023-08-16 11:54:32.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
982	\\x1db56f3a72a96385a33efd41cacec6366b580f3d8460c4d25f01d494776d3283	9	9732	732	964	981	8	4	2023-08-16 11:54:33.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
983	\\x543052c1c57b406d8106bbc96ea61aced2ca58e8a17e1d0a1f764ff5ec5f5bd3	9	9769	769	965	982	30	4	2023-08-16 11:54:40.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
984	\\x74946d120ed46283ed3237e6715978c319d078066b2bf976170b85656e792c82	9	9774	774	966	983	30	4	2023-08-16 11:54:41.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
985	\\x5235694171ba6fb6f4439ff02454dba1b60d45b9f81c88558dbf6b985d2a4609	9	9775	775	967	984	3	4	2023-08-16 11:54:42	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
986	\\x3067921e888c99225ee3c33dc8d5eb58d3b54eb60cd88c5bb78deba9b536cb70	9	9784	784	968	985	6	4	2023-08-16 11:54:43.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
987	\\x9e1812fc27e96938407caba1f743098fda64f78c50ce93544a8a7224c3566485	9	9796	796	969	986	5	4	2023-08-16 11:54:46.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
988	\\x3bc617a62c4dbaa9b0845065c04f1e63c4d8f2b64019e9e832513b847486e43c	9	9809	809	970	987	46	4	2023-08-16 11:54:48.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
989	\\xa757c13ecc2049b7cb6547440ec9bcb49fadec8ac659bfd5c181e6a3212748f7	9	9814	814	971	988	6	4	2023-08-16 11:54:49.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
990	\\x34779be68265343a2d094000a643230f71ef380832b724a724e28f7c94d114f3	9	9832	832	972	989	5	4	2023-08-16 11:54:53.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
991	\\x9d402b5cf279e29517b39cde091400d7b198bef6224105cc5d93e0c39ca964b9	9	9854	854	973	990	28	4	2023-08-16 11:54:57.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
992	\\x667e1bf24bf5baae858e50756250fa1317bb5bdc9b31391bfd097695e414c7d5	9	9855	855	974	991	15	4	2023-08-16 11:54:58	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
993	\\x79fafa418422ab67cfb4e5fbd35dcdf0991bdef27cb8746e7c2b1c9fd948b853	9	9874	874	975	992	46	4	2023-08-16 11:55:01.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
994	\\xf4f178c9f83b404e8f7583e6fdcf2857416d6fc65d0916cdf22a94cd78ea2e1b	9	9885	885	976	993	3	4	2023-08-16 11:55:04	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
995	\\x31fd313ac6a59ea16355bb215038b31bfad34b9d3efbceb9dd661d98e3adddf7	9	9903	903	977	994	28	4	2023-08-16 11:55:07.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
996	\\x29b469f6f69a9764e9e5a48f94811292a8bccea6d03ba3344aa393d71c00818a	9	9915	915	978	995	28	4	2023-08-16 11:55:10	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
997	\\x530b32ef6499060eebe2c82acae31d6576cc8927547f6f0ce1f0154bde914a0c	9	9917	917	979	996	3	4	2023-08-16 11:55:10.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
998	\\x3105555e77a1f92e2938bbc9d758f48dc23a96f2ad7b43287cacab7e229917d4	9	9925	925	980	997	8	4	2023-08-16 11:55:12	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
999	\\x9dedf4bdb1f7facfd81c6d4f24ae1f8e1075b7cf724b028aad6dee85a03ab339	9	9932	932	981	998	3	4	2023-08-16 11:55:13.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1000	\\x71e9e02cc2dfae72e14523936d4313c6cb1002210fdd319e849a62379bdeb82a	9	9938	938	982	999	3	4	2023-08-16 11:55:14.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1001	\\x4d23a070243541023d91aaa60f09e0529fc42520f1e3a026998780547a01b246	9	9945	945	983	1000	3	4	2023-08-16 11:55:16	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1002	\\xf2a28ed00e5a15304cb1bd2ab1860f80682e92d8fcae83fd2fc1e7c867886830	9	9950	950	984	1001	5	4	2023-08-16 11:55:17	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1003	\\x883ed3963169bf8b2ae65589af0fa6263ba70dae4e2a1f43fed744047b3c54c6	9	9951	951	985	1002	27	4	2023-08-16 11:55:17.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1004	\\xf930d46de2df4897d3d63cd72c26f622a043e04140e2576f713c54de539d1d27	9	9955	955	986	1003	3	4	2023-08-16 11:55:18	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1006	\\xf41c1707fba62c5e4b771b1109585503e58d7cf1fab64ab151e778a76f50e61b	9	9956	956	987	1004	15	4	2023-08-16 11:55:18.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1007	\\x2c11a9b93a357e76582803da0e2f64da6a269910ed58794c042ea6ac52915910	9	9958	958	988	1006	6	4	2023-08-16 11:55:18.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1008	\\xf487c17d2e651d9a0ec7d93f182c574c67a22f24ef129396587a8e053b565962	9	9959	959	989	1007	46	4	2023-08-16 11:55:18.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1009	\\xe6671cc373ba7845ba4aa76470ef7a1c93d74dbc94519891017778d754fe82a2	9	9971	971	990	1008	15	4	2023-08-16 11:55:21.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1010	\\x67f5ed795332d907b05124c39daf098904b20f4467fd997f99241daa1aa17597	9	9972	972	991	1009	6	4	2023-08-16 11:55:21.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1011	\\xd3cf6dfe5c0f5aff2089394ab2f18391f5acd5ab940e1e73360c3e65106e4693	9	9987	987	992	1010	30	4	2023-08-16 11:55:24.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1012	\\x45421e0aa1bfebf59abee5b2c0c6f654253988b0b4bb79fdf2d42386ef9f2a6b	9	9989	989	993	1011	8	4	2023-08-16 11:55:24.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1013	\\xa2d9d5ad06d6d58b28fdd21c037d1dd543adf64e0f5504a438861a75baf93c49	10	10001	1	994	1012	5	4	2023-08-16 11:55:27.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1014	\\xd26ec8ed0e8b0856b46ad4054a46811ff0d1e2939cb29c9656d2a832d56330b6	10	10022	22	995	1013	30	4	2023-08-16 11:55:31.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1015	\\xf2f148e68fa670bd1ab5ba833fec20de7873c1808e7ac7a12ed8d3c1a85f4aa8	10	10034	34	996	1014	28	4	2023-08-16 11:55:33.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1016	\\x94bb7d6691c9b5a51e96df35691639c8afbe70f2f4d5f5c26b5526a7ebea362b	10	10046	46	997	1015	8	4	2023-08-16 11:55:36.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1017	\\xf7d5e34fbdd347c81700222e4831d14d81c5bf73ebb80b7c1f0a35f8777e22e9	10	10062	62	998	1016	6	4	2023-08-16 11:55:39.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1018	\\xd79cecba2aa6526725767a2cdce15281f55623cd2c803e97ce6cd4207a2faeca	10	10063	63	999	1017	46	4	2023-08-16 11:55:39.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1019	\\x98d2a313ac2d98485e8998d56c9094ffcbcce7a824ab38dedb8411c2ef46c650	10	10066	66	1000	1018	3	4	2023-08-16 11:55:40.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1020	\\x8796bd16f91b2f579a36728914235d235f92e7a6d87c75fc81a58a87af664cc7	10	10071	71	1001	1019	8	4	2023-08-16 11:55:41.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1021	\\x996b6cba56409768997d646e6cff6872179a5c9fd653fd88cdc01f2c87db5715	10	10073	73	1002	1020	15	4	2023-08-16 11:55:41.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1022	\\xabd24f8c73c4ad7b6b29e5324cd07b5b06381420232567499238ad3ab2a6b48b	10	10076	76	1003	1021	46	4	2023-08-16 11:55:42.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1023	\\x7a10dfc4a1ba805706a26ebae68cbd3af5533ab761309845a60c5ec29e35d7cb	10	10081	81	1004	1022	27	4	2023-08-16 11:55:43.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1024	\\x8f5f6eb4c24553caae827987c253ea97db9a9242e62701a1b6e5a8b99b6cbafa	10	10094	94	1005	1023	30	4	2023-08-16 11:55:45.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1025	\\x203a7a12718afde531e281a771dea49fd3b3f9603d58819a03f09cf80211029b	10	10098	98	1006	1024	5	4	2023-08-16 11:55:46.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1026	\\x740b7fa492c626a351a7d6958bc2a7283af43382766c2e48858e96bbcec8c8f2	10	10105	105	1007	1025	8	4	2023-08-16 11:55:48	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1027	\\xefecfdd7b4b65f9fae95b7d20618879599eca9dbd447a5ba40dd0458553745ff	10	10111	111	1008	1026	27	4	2023-08-16 11:55:49.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1028	\\x32a4ef819232b57b97ed81ca114dbe8d652c14b1b7d405d0f5e76f2b814e1bbe	10	10116	116	1009	1027	5	4	2023-08-16 11:55:50.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1029	\\xcb874f4fd21adf6d453202872862901c82b64ea12b2fc42473d60767d54ec0c0	10	10118	118	1010	1028	8	4	2023-08-16 11:55:50.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1030	\\xd87bd713bbf6ac1057f0a478e3b0355a33a0b138091d43ead70bf146d4110514	10	10122	122	1011	1029	3	4	2023-08-16 11:55:51.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1031	\\xbd2b12fcb81e59ac969002e58e14e876e6e10b8353d5f48ea0f65cb9ce201b88	10	10125	125	1012	1030	6	4	2023-08-16 11:55:52	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1032	\\x502a72fbf26d3a6bd882957de7af35f0635ce226c3518fc4fb25e9846b818231	10	10127	127	1013	1031	46	4	2023-08-16 11:55:52.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1033	\\x1f7973fb4b60daf5c1d91ee37c3de7ab29488aa5c0a393f1ba1aa1edadf088cd	10	10160	160	1014	1032	30	4	2023-08-16 11:55:59	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1034	\\xc624299fb7d31ec22c87778e0ee185677f67b0f3004db68b50b4e8517528fba7	10	10162	162	1015	1033	15	4	2023-08-16 11:55:59.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1035	\\x377e30d84dcfadf244cc6ba3c1f28fa4a88b1bdfa95e35ffc3787a190d6da805	10	10163	163	1016	1034	27	4	2023-08-16 11:55:59.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1036	\\xe6fac20e618e41b73cd7848a75307f93b8debea7259cac7047fb0539322dbba0	10	10168	168	1017	1035	3	4	2023-08-16 11:56:00.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1037	\\x68fd833b6e5a51659aad15a0efca139828af010e0cad9f45984c04e61e3dc4c9	10	10173	173	1018	1036	46	4	2023-08-16 11:56:01.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1038	\\x21c416bd6b420000ad4f912c1ff2a600d876efcd1e8b3faa05aa45d21521fcda	10	10179	179	1019	1037	3	4	2023-08-16 11:56:02.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1039	\\xf48c7a65cbec6ae0ff2a6046972b78fff48459ea9e472a28abd1192cd4225264	10	10181	181	1020	1038	28	4	2023-08-16 11:56:03.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1040	\\x7d55e59f95ae67c9634e003af01c80f786f549ec658b3a7cb39b63010ab38451	10	10182	182	1021	1039	30	4	2023-08-16 11:56:03.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1041	\\xbb0224a0add2414bc5da3a705b505ac94ceaec33224e97ed0c08fa58bc3c240a	10	10195	195	1022	1040	6	4	2023-08-16 11:56:06	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1042	\\xe02116f38508a70b2dbc16694ada08408bb100bd6d94b676aac802ce78816d87	10	10200	200	1023	1041	15	4	2023-08-16 11:56:07	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1043	\\xbd0bd581f88ec08f798c9082117b8333ffefe35b8e534cc462de89b20b516600	10	10205	205	1024	1042	15	4	2023-08-16 11:56:08	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1044	\\x509f9bb3db615b6ace8e16fa47622dd2431838332b728c236ae46375fa891172	10	10208	208	1025	1043	5	4	2023-08-16 11:56:08.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1045	\\x2e06a3e399cc449768e5d9fc5a4f0ca081b23b0d11d83d7dc63cbc8d4d1b71e2	10	10230	230	1026	1044	46	4	2023-08-16 11:56:13	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1046	\\x816aad630fc240b05f44f57b63059652a5848f4ef412c934f3b378a53f36b5e0	10	10231	231	1027	1045	5	4	2023-08-16 11:56:13.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1047	\\x58cfddb10bd42662e9daf56eb53fd4945295dd9cf3ebd2b10f5e4d048353597b	10	10243	243	1028	1046	15	4	2023-08-16 11:56:15.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1048	\\x36a062607521e750c810edc0f745e7ad8d2c379f0ac1189806c3f53079fcaf0b	10	10244	244	1029	1047	3	4	2023-08-16 11:56:15.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1049	\\xbcfa7bf0959baababc3519c0442d3d51f41b41fc3b05f9c0e240163c2f97a38b	10	10254	254	1030	1048	15	4	2023-08-16 11:56:17.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1050	\\x4aefdcb09f991b7e98596bc07b392876cd4c1a5ccd5327b8113a183efdb01f88	10	10260	260	1031	1049	27	4	2023-08-16 11:56:19	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1051	\\x750f0794e0894564e7f355097e2f9a50b8a0822c7402f6e25ec095d1833ebc76	10	10276	276	1032	1050	5	4	2023-08-16 11:56:22.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1052	\\xc7c50f7978c2f0f0d6d3ba81e1911932889e1d4c37b38c82d7b2d729278e789d	10	10289	289	1033	1051	3	4	2023-08-16 11:56:24.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1053	\\x677458b286009e6dbafb470a2e61cadc76cb34d7522e9efbb7c0745a668996d2	10	10290	290	1034	1052	46	4	2023-08-16 11:56:25	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1054	\\xa5d4ede83759b1e209028657bdbe21091267600d8e4aace193939515363ec90b	10	10302	302	1035	1053	6	4	2023-08-16 11:56:27.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1055	\\x946c15f9fc1b2383a1e95565a120dc95599c4682b902554c175befac3748cc12	10	10307	307	1036	1054	46	4	2023-08-16 11:56:28.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1056	\\x29c434f51ef171747ef06a9f8d68b71a8fe46f70ce7937b1e419369d1ff7cfe1	10	10332	332	1037	1055	6	4	2023-08-16 11:56:33.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1057	\\x63d99232d13e2d47227f219a48d79d97139f120dec46f46c99a8cddf16d5e365	10	10339	339	1038	1056	46	4	2023-08-16 11:56:34.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1058	\\x1abc16c7c9a7a9c9dec394db9c8f3d0ac1072a8931c120f6472ae886fe8b21c9	10	10342	342	1039	1057	5	4	2023-08-16 11:56:35.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1059	\\x109cd6a5982c5212a7f7414e7f877278222f06327de51a90d0144baacfcd1f8d	10	10350	350	1040	1058	15	4	2023-08-16 11:56:37	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1060	\\xdf56f6089bbecbc07474b9c81ee0d0c9868c63d6c2b2d4832185f713b6aa1162	10	10355	355	1041	1059	6	4	2023-08-16 11:56:38	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1061	\\x6309e6d1af1533a042c5051eb2bcb2efb7bd427440e05cee359f48240514b3fb	10	10369	369	1042	1060	27	4	2023-08-16 11:56:40.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1062	\\x12e63fdb6fd9774a8baab3714043f7b667260280379ba57dd9d6a1d00fe66ee8	10	10399	399	1043	1061	30	4	2023-08-16 11:56:46.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1063	\\x2d3da1c816e44bc296b5b90bcd2fc371658625d30fed61e788f33acea6549c3c	10	10402	402	1044	1062	46	4	2023-08-16 11:56:47.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1064	\\x149528194963eb224a5c6950a38a3597c819d365f28bfa2536553ead11171bd4	10	10409	409	1045	1063	8	4	2023-08-16 11:56:48.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1065	\\x19e3b1dba60989ba5dfe1badde03bdccf48ba3a748def839c684e6ed401f8b84	10	10416	416	1046	1064	27	4	2023-08-16 11:56:50.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1066	\\xee1fee8eca87ea5f7494d662b2a85ea63dd3ecd22b57b6e6165299a695b806a5	10	10421	421	1047	1065	15	4	2023-08-16 11:56:51.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1067	\\xdb5b5d6aebf6a413dc4d3ed0be057c41ce2376e35eb1bd7d4013603699632577	10	10454	454	1048	1066	46	4	2023-08-16 11:56:57.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1069	\\x63bb40c984afc56367d511f695167841b132a41db44a1cebf6ebcab4c48dbac3	10	10459	459	1049	1067	3	4	2023-08-16 11:56:58.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1070	\\xd0529c3fb47ad8d94de4a11ee349b4581723434dd312e998bcf1464cdb3447cc	10	10473	473	1050	1069	8	4	2023-08-16 11:57:01.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1071	\\x6240bbc1e5c3dc60dc6046c3ed6bab6294e149a68fcedce41704f5a773dd014f	10	10474	474	1051	1070	28	4	2023-08-16 11:57:01.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1072	\\x552ab55a1d9bc029291a11e176a528c6b236eb0b94ce746a976f629f70ba6441	10	10484	484	1052	1071	8	4	2023-08-16 11:57:03.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1074	\\x320f50c4224315e36bfdf7205eb023943044fcbdef2d5cb61b451ed2030d9e49	10	10489	489	1053	1072	5	4	2023-08-16 11:57:04.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1075	\\xcd7661e826bcd8aeacf062326f688f420f0df2da4ae5a87e8292f1a22fe01f7f	10	10499	499	1054	1074	5	4	2023-08-16 11:57:06.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1076	\\xaa0fe4ba1242df172a3954f73a0a01c6d0cc4a821b8eb27d573251b6fe0eadfb	10	10502	502	1055	1075	27	4	2023-08-16 11:57:07.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1077	\\x112156e931c0443d23903ee807c1d2a86945a71761732ab4e2a0d7c0708084d4	10	10504	504	1056	1076	28	4	2023-08-16 11:57:07.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1078	\\x1dd9a7cde327253a172031d6fe777ec394c6c67dc81e807b719ab232ad464118	10	10521	521	1057	1077	27	4	2023-08-16 11:57:11.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1079	\\x9514e91ae1878f29f80b5e0c1bc021d36636f37dd8f8ea4677387f59afd14a11	10	10522	522	1058	1078	28	4	2023-08-16 11:57:11.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1080	\\xf78252d235d0a02a92db8ad2b803d09c71e1cee60b652d49ff246b1035bdfb74	10	10542	542	1059	1079	28	4	2023-08-16 11:57:15.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1081	\\xceef373c22be0379cb8866fcc09e66fde9f089439347402e935ad9b1fa11dc34	10	10543	543	1060	1080	28	4	2023-08-16 11:57:15.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1082	\\x501e127b349eb652bb093b86d7b702869c513acabf46e24402371f9b51b87a55	10	10545	545	1061	1081	15	4	2023-08-16 11:57:16	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1083	\\x2bd29900ec583a59023fb188d9c191387cc6cb1815559cd13aa4cbecc1c42135	10	10548	548	1062	1082	46	4	2023-08-16 11:57:16.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1084	\\x7fe2120e9531dbb3c1e90b775dd6b76739a51da70ca47b2acabdc98f396e1022	10	10553	553	1063	1083	3	4	2023-08-16 11:57:17.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1085	\\xa836fbb6b9b9c5627d27797bde9a438e99280fc601e5efb719758bb7f110a2fa	10	10557	557	1064	1084	8	4	2023-08-16 11:57:18.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1086	\\x467373a862afebee01d976313e973e5c77e6e288f143865845818edfe3cd9f2a	10	10563	563	1065	1085	28	4	2023-08-16 11:57:19.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1087	\\xc7461bd90db554ef8c36c362ba8a63fa2785185985d9185dcb61c86daab8c631	10	10566	566	1066	1086	6	4	2023-08-16 11:57:20.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1088	\\x9808a806d6d07218e903fcbe8f128d3e9a9d188b5d90b895bda1eb9055b9e7ab	10	10568	568	1067	1087	8	4	2023-08-16 11:57:20.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1089	\\xaaaf5907c70f1946348d99b11278ce14e5a725158b6c86fc8837fd43cc3cb767	10	10575	575	1068	1088	3	4	2023-08-16 11:57:22	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1090	\\xc40d2ad7a53bae9e3c285da1949cb8774b712082077f6d633ba37a662f57c409	10	10577	577	1069	1089	27	4	2023-08-16 11:57:22.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1091	\\x7be401cd4d73b0dfdbed92d95475f2feb2d4a386bce1fed7829ac9e30e808895	10	10595	595	1070	1090	46	4	2023-08-16 11:57:26	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1092	\\x7f6c8e5f16e1e93bccfb959210ea8f1a5fa85ef89bea374fbcbc765dbbcb3b73	10	10601	601	1071	1091	28	4	2023-08-16 11:57:27.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1093	\\xc7f21fed871660cb0d0c9fae1226fc1f0f6d634ea1a9f2aa2e0d9a709a3202bd	10	10602	602	1072	1092	6	4	2023-08-16 11:57:27.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1094	\\xfc73d10ea748972f4212813c775bc243047471ef7c0a0d4b9db9aac6724837f3	10	10624	624	1073	1093	27	4	2023-08-16 11:57:31.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1095	\\xfb970bd5eaceb717f1092bfe4c4bfad5aa5f3747b9d8c16c02e7b67241880367	10	10635	635	1074	1094	3	4	2023-08-16 11:57:34	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1096	\\xbea8c4af0d91f51d09461379ebcb06c78d110c1b69d5dcdac8e100298fb84a81	10	10645	645	1075	1095	5	4	2023-08-16 11:57:36	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1097	\\xfe5677c052b5d76a985afb088f3a95aceac21e5f47fc59219838ad746931c1d4	10	10646	646	1076	1096	30	4	2023-08-16 11:57:36.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1098	\\x1e43c9e0f291fdc3dda50db8c978a8244c92e0d54fb51a095e9050893eeef5f7	10	10651	651	1077	1097	5	4	2023-08-16 11:57:37.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1099	\\xc6a8ae3e60bec330a498a49afb75849af30a0439508d1e8ff8fd9544dc549b3d	10	10697	697	1078	1098	6	4	2023-08-16 11:57:46.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1100	\\xb537f12c136f886d74d52aaa518d6128a5e8e403fff14958b2d9b8f29263ff10	10	10718	718	1079	1099	15	4	2023-08-16 11:57:50.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1101	\\x155250c26c6199a10eb7f3ccce8e00ad3928bd200061559c81c3df56973303d7	10	10726	726	1080	1100	3	4	2023-08-16 11:57:52.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1102	\\x6810da375f6dd4d9996c353aa635cf3bccc28a8fde50dc9bb20056e6dbac3ced	10	10732	732	1081	1101	6	4	2023-08-16 11:57:53.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1103	\\xe5f78928ccaf22c87a354995d4825429b579fce9f2a38d73579f256fef49d1ec	10	10737	737	1082	1102	27	4	2023-08-16 11:57:54.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1104	\\x13927900da606e16eb5ce9b351d366ae298ff9107713acd52f1058fc864f7c14	10	10742	742	1083	1103	3	4	2023-08-16 11:57:55.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1105	\\x1b7db62e3355b597cc3648dbfb38cae7436d107b4ebb34c12d94fbc9e9348dc0	10	10743	743	1084	1104	30	4	2023-08-16 11:57:55.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1106	\\x15000b8bd735038d6abdbbacaf8dc93c786d1f345083b6ccd78a056f0d0140a0	10	10766	766	1085	1105	28	4	2023-08-16 11:58:00.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1107	\\x368536a2d37b02991bf6ae0f04840368bc6f895f87da90a39cc84d277b79f3fd	10	10769	769	1086	1106	46	4	2023-08-16 11:58:00.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1108	\\x17a8855c8dc6eb373f6860297256f99f48d78563e58d9ff491223539af04462c	10	10774	774	1087	1107	8	4	2023-08-16 11:58:01.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1109	\\x97d986e40146ece3149c1ed4d961417cfdfe875a8bb9c78b7dbaea37ae787c06	10	10794	794	1088	1108	30	4	2023-08-16 11:58:05.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1111	\\x14bf16cf3a2dc15213ad05ba6610ed511410393db390d2b12c35de6cf1e79485	10	10808	808	1089	1109	5	4	2023-08-16 11:58:08.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1112	\\xe4d41699d7104079e4a33390cb82a44f267be3f18b7b0ca4d6dd8d9eef1172a8	10	10811	811	1090	1111	8	4	2023-08-16 11:58:09.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1113	\\x21797458ac8456ca84a76f15898d1dd14b649f66f8447eec753f558602510856	10	10815	815	1091	1112	46	4	2023-08-16 11:58:10	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1114	\\x2be1fa47e4758ba13a19a6ea7e16e6b19404a3169da6bae4dae492e5eef5aad3	10	10817	817	1092	1113	27	4	2023-08-16 11:58:10.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1115	\\x45719d594af3438bc1685ccb41edd6baceb482f9d98afd648812f583bd257e37	10	10833	833	1093	1114	5	4	2023-08-16 11:58:13.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1116	\\xe4f912162c5b61fe6e210338d4d04db88ede842e38807535695ee9a3dc314bce	10	10835	835	1094	1115	6	4	2023-08-16 11:58:14	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1117	\\xff178e0ddd3e3bc3df5afdf90bba56fb984d9a4059f2e5e81bd8aa1f5ae5875a	10	10839	839	1095	1116	5	4	2023-08-16 11:58:14.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1118	\\xcafe10b03cdd0e4e34ebf86b96bc51f129c1796efc6b3ec5631162f5b4039289	10	10866	866	1096	1117	15	4	2023-08-16 11:58:20.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1119	\\xb9f53882a7d3d1637cd498bb3f4e606d2a7406e2ad889d8322bcd70ee8f91ffe	10	10874	874	1097	1118	6	4	2023-08-16 11:58:21.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1120	\\xcb0c3b6876e93fd41d2ca1f15ad378e8da07118687047873ed75a667c1e22668	10	10882	882	1098	1119	27	4	2023-08-16 11:58:23.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1121	\\x14faa634dc992a3b502d2485c8a9f9898ee25ba04e890a1e5c9d3e9240de3ff4	10	10897	897	1099	1120	28	4	2023-08-16 11:58:26.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1122	\\x943bedb6570438878109e2e70a6bccab53745ceef77e3eca284cf8c748b72e23	10	10898	898	1100	1121	46	4	2023-08-16 11:58:26.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1123	\\x5d84998e20480510e8e7a912f0a9437805962700c734f4e0039746174b2ee95d	10	10911	911	1101	1122	6	4	2023-08-16 11:58:29.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1124	\\xe6ef4096ee406ec63fe9068220f9cb6503855591341ba9e7a93ae2a86a213492	10	10920	920	1102	1123	5	4	2023-08-16 11:58:31	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1125	\\x86e80e9bc4551241abb320a4b58d88039f0dbbbc316ca9cd8cdd2f22209c25c1	10	10922	922	1103	1124	28	4	2023-08-16 11:58:31.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1126	\\xf7f6271767846a325a852d2de5a7d57be0899065aaa3d1f87fdcb89822310b68	10	10945	945	1104	1125	8	4	2023-08-16 11:58:36	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1127	\\x14896e7dcbb8c521deb683b4950cebb434fcca31468b064abf96f2db2df6b9f3	10	10948	948	1105	1126	30	4	2023-08-16 11:58:36.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1128	\\x41b46876495669804fec1c59ed8c8c9ad14ffba0bae63483264d2f73f0bff538	10	10949	949	1106	1127	28	4	2023-08-16 11:58:36.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1129	\\x7a76a90ab0cae5b2b61ffe76960c93172f415855c57fd6d9c5198aec81834ce1	10	10955	955	1107	1128	28	4	2023-08-16 11:58:38	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1130	\\x244fb76281d0637984079c37a05de0b03ca7f0d2af1868840dc42df709168514	10	10977	977	1108	1129	5	4	2023-08-16 11:58:42.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1131	\\x1f240c0fd77d87630cbb6e787df304f6bf06fbeebdf0ca75d807cc3520224b94	10	10994	994	1109	1130	5	4	2023-08-16 11:58:45.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1132	\\xbdbf95e2cd628a71b35154cb451c105caf706f63d676d6b5a99124068fbf3a30	10	10998	998	1110	1131	46	4	2023-08-16 11:58:46.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1133	\\xe34a47e655884c95fcd66eaf10b33d46f6255eb086e309a661fec84fdfe485a8	11	11002	2	1111	1132	28	4	2023-08-16 11:58:47.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1134	\\x99ef9b21e9c04cc3f774d38106de586619cc9b605e180facde9a6ace9ee739c9	11	11008	8	1112	1133	28	7353	2023-08-16 11:58:48.6	24	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1135	\\x29f8f6bf8c41e37a3ffac576aaed383358a835db0b295b84801af3523bdc145e	11	11011	11	1113	1134	3	3732	2023-08-16 11:58:49.2	12	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1136	\\xacbb2f7b0d64350fcf9c6269853d8696c04fb4ad69e59e635a51d9a01e7dbafa	11	11016	16	1114	1135	28	6537	2023-08-16 11:58:50.2	21	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1137	\\x6149bd3a867c02fd9102a553ccd0d9933a1caf8c8b8b497c62074a04a925234a	11	11021	21	1115	1136	8	6401	2023-08-16 11:58:51.2	21	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1138	\\x71b70bbfd6ead3872f33d1d2eb8a961101dc6ce72f50d8d98561fcaf9b01a7f8	11	11031	31	1116	1137	30	6822	2023-08-16 11:58:53.2	22	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1139	\\x944f122412dc883eabddb0b81308ad0c12d8427444b54cbd9a4dc260a394b7dd	11	11050	50	1117	1138	3	4	2023-08-16 11:58:57	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1140	\\x8e473a275e6c3efbe26e5b92074b1381fe91e45ec3dda8b57eecd3536ca992d0	11	11067	67	1118	1139	27	4	2023-08-16 11:59:00.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1141	\\x623505fd3c06a0b293cdb20b2c30b06565b1b49cd9aab19d093b23e28eb851c7	11	11070	70	1119	1140	46	4	2023-08-16 11:59:01	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1142	\\x2a8493ce038d6f6676f57f7fc956e2aa08ed4d3c33b492a2ec3993583230044b	11	11077	77	1120	1141	15	4	2023-08-16 11:59:02.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1143	\\xfd2bdad3760ecfd2520d6596351a5606ca3b72f1126896f54a3abe5dc094399b	11	11103	103	1121	1142	30	4	2023-08-16 11:59:07.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1144	\\xd4512041366f3bba0b99f9abcbd213ba2bdb16499478fdedf8d1846e7f950124	11	11116	116	1122	1143	3	4	2023-08-16 11:59:10.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1145	\\x493781fb892678d520d31dfa9775f4632247f5c120b41dfdb9aaa93615004eef	11	11133	133	1123	1144	3	4	2023-08-16 11:59:13.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1146	\\x9b04ac2dc692aca8027ac57ccd7e012d1ffce34faa377b0e5d4660d19f1e0ca4	11	11140	140	1124	1145	5	4	2023-08-16 11:59:15	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1147	\\x32bb390589d77ed4358997d0db14dd5b04e4c31b45c3de5a04320a054a9bd7aa	11	11152	152	1125	1146	28	4	2023-08-16 11:59:17.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1148	\\x9e44a2f41f1906ae98572b4e50df678d8c83ee6e6ccf0903568a4268fd52bf85	11	11161	161	1126	1147	5	4	2023-08-16 11:59:19.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1149	\\x5e172cbcefff0817428b51793d9cef87db5078c71e9364821777a849425e1a42	11	11190	190	1127	1148	8	4	2023-08-16 11:59:25	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1151	\\xfc92430769027c471c79b11437696332d755bea75a77d186115d1959ec861209	11	11192	192	1128	1149	3	4	2023-08-16 11:59:25.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1152	\\xd92afed35aa0afb8c16eacf7b7f3058931a4c2e2b31451b679b9856d3af71b72	11	11209	209	1129	1151	8	4	2023-08-16 11:59:28.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1153	\\x5b3a57a95777f65666f5e9c93b66a1543689719a555625c6e53b3d932164da6c	11	11215	215	1130	1152	28	4	2023-08-16 11:59:30	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1154	\\x0c39928b7573d45fd46a3097f3518aa528e416402d77fc1d5de800c820aa6a28	11	11228	228	1131	1153	15	4	2023-08-16 11:59:32.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1155	\\xfbf2fd639b2f15681ee0adfa63e8205e22687e326501c421dcbd973a902eaef8	11	11237	237	1132	1154	8	4	2023-08-16 11:59:34.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1156	\\xf7361f9b8b308366f3d376d9ab81bf6e4fca6f795ddc09dfcf3213b7c67ae692	11	11269	269	1133	1155	3	4	2023-08-16 11:59:40.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1157	\\x1c0178be32c69146fdfe3be453ee1b98441fb1886829ecb32ea145ab2ded433c	11	11283	283	1134	1156	27	4	2023-08-16 11:59:43.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1158	\\x8c85c77c05c188dd3fb4d46ada692b678c42d04efbd28c1496ae0337821d0f18	11	11300	300	1135	1157	8	4	2023-08-16 11:59:47	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1159	\\x482b2846fd55a460b2d757bed743d177312218ad9a831b756ca89b7224e275c0	11	11321	321	1136	1158	28	4	2023-08-16 11:59:51.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1160	\\x4b40c4e2ae746e0ad2ebf1553926397ea3873d4fa7d9495aa01a26ed924c8c0a	11	11322	322	1137	1159	5	4	2023-08-16 11:59:51.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1161	\\x88ee9b25c637d55ff0535fd04c852e531fee7e9ea74c94ba1b9776f3da999c46	11	11324	324	1138	1160	3	4	2023-08-16 11:59:51.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1162	\\x036eb170dc1f2d7b716a59e8e107796d7dce18513f03cd533608dee16d02d6a7	11	11329	329	1139	1161	46	4	2023-08-16 11:59:52.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1163	\\x1d70520243db5e658ad84bfdc04052d86ddf6c61459839307a8c344b4e9dbd77	11	11332	332	1140	1162	3	4	2023-08-16 11:59:53.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1164	\\xb8cab317f3f3b9bfd8d0986f10e839c8b60b640e521b9a7c5ab8287f9d35a33c	11	11333	333	1141	1163	6	4	2023-08-16 11:59:53.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1165	\\xe073492d67c601a3b550d4d4cc39360f5e9f1d1ab5f9bc61fbb94e10106b5f03	11	11338	338	1142	1164	3	4	2023-08-16 11:59:54.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1166	\\x19ef4f78e602d35caeae2657f97a30f0d41b84f524a1598f027c4914f98b7f65	11	11354	354	1143	1165	28	4	2023-08-16 11:59:57.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1167	\\xa92afa474e62b2d8e625806fdc8cdcef6e3b7fde74d9ae436787aa6eba1d6d6a	11	11358	358	1144	1166	5	4	2023-08-16 11:59:58.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1168	\\x6024798922f3ec078a8edc4136425619fdbf6791eebd58f75612562c36a2ae1b	11	11365	365	1145	1167	46	4	2023-08-16 12:00:00	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1169	\\x37764f92b4a17f5be97d1a4dbf3964a88736748aa1dd240172b57991ae36919b	11	11375	375	1146	1168	28	4	2023-08-16 12:00:02	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1170	\\x8a58a6cee6cfc2ea609c07a0bc1a36a793c8b85bde312359694dcf60f39cf34c	11	11393	393	1147	1169	27	4	2023-08-16 12:00:05.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1171	\\x919a0248cc5e82959ac848032ffeaec822e70cc42e3fe6bdcbd78b966d050de5	11	11397	397	1148	1170	15	4	2023-08-16 12:00:06.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1172	\\x65d85bc46e35183a00b86c0c41e9256902482b459f03b1d46509f1a710a2cd4a	11	11399	399	1149	1171	30	4	2023-08-16 12:00:06.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1173	\\x17c10bc8e5da1b7b6a2d18db3994d9d4850c255e84db5c1b1241e556726e443e	11	11400	400	1150	1172	28	4	2023-08-16 12:00:07	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1174	\\x1e1754f128177ff181f9897cb5ad6b35da031dfedefba0ce98b67e20bf5f3c08	11	11429	429	1151	1173	27	4	2023-08-16 12:00:12.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1175	\\x7dd09de95cf485d7867489ec21c6385e2cc2ec1d648bf2b7605a453550cd03f2	11	11454	454	1152	1174	3	4	2023-08-16 12:00:17.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1176	\\xb5629e7c54ffb73a34804e792b6ebefdf555e6d24aca2d67fb7b1e360bf72bf8	11	11457	457	1153	1175	46	4	2023-08-16 12:00:18.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1177	\\xbd50b90578163212eced29591d060e7a0fec62be012c93d186d7bbb7aa258bbe	11	11477	477	1154	1176	27	4	2023-08-16 12:00:22.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1178	\\x85ed9a3016c40779a5ed1e6124282d16881653f76a43b216032dd4ccd3dfe22e	11	11484	484	1155	1177	30	4	2023-08-16 12:00:23.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1179	\\xc33d60069fcc3365af1790fc08808eb8e856a2c35eadba9f899a54a7f787262c	11	11491	491	1156	1178	30	4	2023-08-16 12:00:25.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1180	\\x0d16701298bc9c8a3455fd52ac12104a8dd8f19cb81ddabfc2213a47ea310b38	11	11515	515	1157	1179	28	4	2023-08-16 12:00:30	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1181	\\x9934eb7d7783bcfb17d967987f3e8d97c7e24bbfa8b6599cab1b31841ba62855	11	11527	527	1158	1180	6	4	2023-08-16 12:00:32.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1182	\\x829ab23dbcad80abc94a01c267acfeac20f5ed541c62ce96cac7bb33545b9e5e	11	11551	551	1159	1181	28	4	2023-08-16 12:00:37.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1183	\\x3a4932ff26a275071cc51dbafd4c2132a035f68387b0110ebd200735cf0ba37b	11	11552	552	1160	1182	15	4	2023-08-16 12:00:37.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1184	\\x55e94be9a93717466325f551d5234d78bdad8af5b1bc5026c4e5a77b8d6086e7	11	11554	554	1161	1183	27	4	2023-08-16 12:00:37.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1185	\\xd4aad574e7232fcefba1fa5857977f9b17029fe7427015d4b20b6d15baf12563	11	11561	561	1162	1184	28	4	2023-08-16 12:00:39.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1186	\\x66dc3b059e75a550f75ac1d2d955c11286889fdb26092626bda0ce63328f616b	11	11562	562	1163	1185	3	4	2023-08-16 12:00:39.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1187	\\x7968084f2048bd96766f68d6703f9a973cb433d711ca0bf8b5df33d0de4d234f	11	11567	567	1164	1186	8	4	2023-08-16 12:00:40.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1188	\\x3c5cd743eaf0ecea5aa1c5abf233c77f95b8ebd2c916450254181b31fdfd4b28	11	11569	569	1165	1187	5	4	2023-08-16 12:00:40.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1189	\\xd34095b89100b2f68926f13cd535254cc5317a446b949bbdb627ad4c61c446ed	11	11576	576	1166	1188	27	4	2023-08-16 12:00:42.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1190	\\x9b57f6b4dcebe7269a4b6b8cdd8eb66e377c7c4edbc66061c8f9d30c99e8e7f6	11	11578	578	1167	1189	27	4	2023-08-16 12:00:42.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1191	\\xc0008950180c1a5240c6e50e8894a58fb5ee87756725fd650cce8950df846c6d	11	11580	580	1168	1190	46	4	2023-08-16 12:00:43	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1192	\\xf2af3df9b9cd9b5ff60949db8ec1a691091d3e4727df50d69617f670d79e5b14	11	11581	581	1169	1191	30	4	2023-08-16 12:00:43.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1193	\\x80df3625fcd6c59e52ac93e67ec3358feab7231bcd50fa3064b9c615c5aa8f9c	11	11639	639	1170	1192	28	4	2023-08-16 12:00:54.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1194	\\xb4208a46305291f8355c8a886915f96b4642f961d6dac03a5a721efaab2044d6	11	11640	640	1171	1193	8	4	2023-08-16 12:00:55	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1195	\\xf745833715f97da49efdbb8412d0b35c65da7520bec340f280d13044796c0e38	11	11641	641	1172	1194	15	4	2023-08-16 12:00:55.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1196	\\x674d91e5dc1133e3e41eec0089159d4faa788a2b83f8ce128da8e341e16e2d63	11	11674	674	1173	1195	28	4	2023-08-16 12:01:01.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1197	\\xc227443c9d2d444f53405b46047d3e0489b281e26c842980cee2a12e36e94915	11	11676	676	1174	1196	5	4	2023-08-16 12:01:02.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1198	\\x1f3c84c595fcab5440ec08f842ae9420619e6bc128e16ba2b065616d188a2d98	11	11698	698	1175	1197	6	4	2023-08-16 12:01:06.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1199	\\x5cbbfc8184331d72e0dffbfcc67d5c4007f8d4ad5f639fa0c7818387cd71fcdb	11	11700	700	1176	1198	8	4	2023-08-16 12:01:07	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1200	\\x91647f4997facc8090f8bd1b57f4f38a87a07723628d34fa3a3edc6b5183f939	11	11715	715	1177	1199	27	4	2023-08-16 12:01:10	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1201	\\x7bd8777fe5c208e3a62b88fc9d43a7367f7a00018d4ea3aba734cdc4c5aeb628	11	11716	716	1178	1200	6	4	2023-08-16 12:01:10.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1202	\\xf38af766508e0036432ed489aec2c9650022d80e850c7c6cad35fa3a8853a0ce	11	11718	718	1179	1201	46	4	2023-08-16 12:01:10.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1203	\\x614efa29900aa314fa381133fcb300f2d3358eb7f32784170994a9374d2f7744	11	11733	733	1180	1202	46	4	2023-08-16 12:01:13.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1204	\\x531dd4b3bdeb20d3bd307b0475cc4a8e73c57bdc7d2af82d226ff589f434d927	11	11735	735	1181	1203	15	4	2023-08-16 12:01:14	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1205	\\x97794d980f5596029387233ae13e5ebdaaf4df60ffd4818c0a84383bd8e89275	11	11743	743	1182	1204	6	4	2023-08-16 12:01:15.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1206	\\xffc3f38d56c4b0964830ab5bc5e38e42d09a971d26f8223963b59057422cf62f	11	11745	745	1183	1205	30	4	2023-08-16 12:01:16	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1207	\\x4a263c4a3d35fc1cf2f204c5a9197256f3008fe7eb20f3775bb8a6e3697a077e	11	11754	754	1184	1206	3	4	2023-08-16 12:01:17.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1208	\\x43bac314698bf3ec5d876ef3d5970afefe4e868d7bba247f2fc064c178798890	11	11776	776	1185	1207	8	4	2023-08-16 12:01:22.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1209	\\xf4fda8d62f9ebcc950d3081dab502b0527e3805c13a957eb19754abc72c51520	11	11781	781	1186	1208	8	4	2023-08-16 12:01:23.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1210	\\x85e61cc874fe80e483bdc6f2c9339182ea147e3fdff7cbd252116317e29328e7	11	11782	782	1187	1209	8	4	2023-08-16 12:01:23.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1211	\\x982b4b2845be7cdc4dcbedbfaabd5df9c51f4a64d78bad4b9d0c3725e32688ca	11	11784	784	1188	1210	8	4	2023-08-16 12:01:23.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1212	\\xd1fbef788a4b5927fce0731257bc26b967192275328d1fa0e47a4d1abb84f89c	11	11786	786	1189	1211	27	4	2023-08-16 12:01:24.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1213	\\xe0c25734c31c29d58fe09b95ffa51a0130c1d9cbd1cdfd0c42f280bf2b2e4aaa	11	11796	796	1190	1212	30	4	2023-08-16 12:01:26.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1214	\\x3369dff9aab80024bc254ddd95bccaef3e6a9e238de5db391a82ad3a80725d8b	11	11801	801	1191	1213	3	4	2023-08-16 12:01:27.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1215	\\x7a6326d040fd39d25459e5f270a052f180bde2568a218d9d63348f9d406d78e0	11	11803	803	1192	1214	28	4	2023-08-16 12:01:27.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1216	\\xe0394e44bec86ab6503c9107ee54bcf11d08882ffa5d442d2a2715c549a69c63	11	11805	805	1193	1215	30	4	2023-08-16 12:01:28	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1217	\\x992824f29555165c0743870f9182c3d3d6a6c010f57a7bb25f4e3961ed50639a	11	11809	809	1194	1216	6	4	2023-08-16 12:01:28.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1218	\\x3076b20c3a43252fbc8fd5bf33b0d21b6b78fc4d52e592d75c6949b9d86efd5b	11	11822	822	1195	1217	46	4	2023-08-16 12:01:31.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1219	\\x428deff979381e3b3074fb1fc65612d97b57ec5a93436f99bc73966e6cf64918	11	11835	835	1196	1218	15	4	2023-08-16 12:01:34	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1220	\\xcdad348028f78fe56281dd72fa5303b0e773a628d2ecb216f13f2e66b7b8deae	11	11857	857	1197	1219	3	4	2023-08-16 12:01:38.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1221	\\xe98aa0a8e8ad5cbefa0c0208bacf28723c30003f336e3d32c8b6ef68fb634b2b	11	11872	872	1198	1220	3	4	2023-08-16 12:01:41.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1222	\\xc695c7e1523d27ee9a78d548d5a874b384adb1d512f8d24eaf0c42f42b26963b	11	11875	875	1199	1221	30	4	2023-08-16 12:01:42	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1223	\\x64213f14a33641c82c938d32677324659c7a09c0b539f1fcd42ed256888456a1	11	11883	883	1200	1222	15	4	2023-08-16 12:01:43.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1224	\\xcab349d1effb19937a81ba44b32894bc692d90bf15379289cdb9813929dde57e	11	11889	889	1201	1223	6	4	2023-08-16 12:01:44.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1225	\\x80a25228f122f6001c8d5251d084d454284ebdba55a53db3765b95b4fac97dc8	11	11890	890	1202	1224	27	4	2023-08-16 12:01:45	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1226	\\x293bd76237c5ad936a0c5befd513884b4713638e34de09ca555848483e477881	11	11894	894	1203	1225	8	4	2023-08-16 12:01:45.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1227	\\xbf1ab1a1ebf71cf03e566234ba8641bce3c946c6834b32183915ca8efbfa3358	11	11895	895	1204	1226	28	4	2023-08-16 12:01:46	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1228	\\xee975fb8e2f40811a6479bc9318e94402faafdd5bf0a91c2053d05cf7cb8f46c	11	11897	897	1205	1227	30	4	2023-08-16 12:01:46.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1229	\\x3d6398797ca4284347fe05073476a151db0f96bdd3ea85503cb21c4c582296bb	11	11903	903	1206	1228	15	4	2023-08-16 12:01:47.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1230	\\xfe835f850e039437343a6d063e4ead013d7cac75337cd00bccd19d7d87887e89	11	11904	904	1207	1229	3	4	2023-08-16 12:01:47.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1231	\\xcd8ced540e466b62d269951de343bcdc9ed5d5f34e19c4ab31508a9ed0ed4d69	11	11912	912	1208	1230	15	4	2023-08-16 12:01:49.4	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1232	\\x8e61e24cd1cac795bdc4f97b965d42e77f1e15b84166ea1c1f502a8100a647d2	11	11919	919	1209	1231	8	4	2023-08-16 12:01:50.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1233	\\x5a464e32fff3bd308aa5003adcfdce5411b78734926adfa12110d862b9343bb8	11	11931	931	1210	1232	15	4	2023-08-16 12:01:53.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1234	\\x87ab4941ec9826709a0d421ebdff961be4a93c5d187e218cb3fa4c0cf55c025f	11	11957	957	1211	1233	30	4	2023-08-16 12:01:58.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1235	\\x3032af9537fdffdd814daf5956caa681433c8f52f78ba663487b1d3c5617fa24	12	12006	6	1212	1234	5	4	2023-08-16 12:02:08.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1236	\\x9fb5e617baa50111d99cf0873dac6776e20d9e497e08706bedd95f9e5afd4563	12	12013	13	1213	1235	30	4	2023-08-16 12:02:09.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1237	\\xe7cd6e88fe27fdefce71dee053cb65aabfe46652aa262503a56d546b08b1b395	12	12024	24	1214	1236	3	4	2023-08-16 12:02:11.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1238	\\x4c1072dcbac2d92c9e6cf15923f6bd7467e5fe29ba73d337bda6887001b978b3	12	12034	34	1215	1237	28	4	2023-08-16 12:02:13.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1239	\\x7757a90f2ac8ccc8b83eb48c224f43b58129e93644a7ea5a7bbc7273aac3ed1c	12	12045	45	1216	1238	15	4	2023-08-16 12:02:16	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1240	\\xd91b876fdc318a4ff92728e28dda61ac9c93efa6ba19420db403c660f0af0880	12	12056	56	1217	1239	3	4	2023-08-16 12:02:18.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1241	\\x0316330ca2ddf7b53b8f837c05f8e18a4c398431f0ab6d98e0790ce78e199149	12	12069	69	1218	1240	5	4	2023-08-16 12:02:20.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1242	\\xbe8f3e967a53461e090abcbe450918820a9503319929e370f46a266deb37be5e	12	12081	81	1219	1241	27	4	2023-08-16 12:02:23.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1243	\\x099c2b713cac79e92a0c9a761a16376dd13861c7cf91ab41496efe1f46244a8a	12	12087	87	1220	1242	5	4	2023-08-16 12:02:24.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1244	\\xfb7ea2694fa483a9942fd6c74702222daf67d81e78f3061a7d48b99f3d7758c7	12	12112	112	1221	1243	28	4	2023-08-16 12:02:29.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1245	\\xc2d57baae8b6b4754f02c0ba3c89b7a95d7c0bfc0f000001948b22a10b9d996e	12	12116	116	1222	1244	15	4	2023-08-16 12:02:30.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1246	\\x8054f7bab15a9f8585f8ed0d6cc9db781240489634938d8d8378531a58d4b91e	12	12131	131	1223	1245	46	4	2023-08-16 12:02:33.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1247	\\x7cb307e498eedb1233b5b96c7c96f3c44b22e4dc7f1d7f7e83048c4044b2ce15	12	12167	167	1224	1246	8	4	2023-08-16 12:02:40.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1248	\\x495ab69822e44fca929e2084814ea4209ca4eb6208a6bfda962ea9f1ef34c2fa	12	12168	168	1225	1247	5	4	2023-08-16 12:02:40.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1249	\\xb9744de554c10527b61c1155477edf3540ff0201a9dabe3af7a33d4a67d64f43	12	12171	171	1226	1248	46	4	2023-08-16 12:02:41.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1250	\\x3c51681bc692e2e6147f36497e98708f1be986379294cc7a55bacfb7f8fa9910	12	12177	177	1227	1249	8	4	2023-08-16 12:02:42.4	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1251	\\x090f72d7517c0325fc7d5fd5f5214ab3d0c450db1b6412ee42f02d7a71e904ea	12	12181	181	1228	1250	3	4	2023-08-16 12:02:43.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1252	\\xe93636c149aa4b63d3e0087e5b88281a47d472e1695ad94465f1c31b3d683056	12	12193	193	1229	1251	28	4	2023-08-16 12:02:45.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1253	\\x546f4dac34a4a2e4d8ecd3dac890282c0b8883efb83c6f4e077640fe08afddbd	12	12194	194	1230	1252	30	4	2023-08-16 12:02:45.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1254	\\x815da8feb9f1204bcc4d5309049039e3375aaf6462d3f3f4cfd4dadcda562910	12	12204	204	1231	1253	27	4	2023-08-16 12:02:47.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1255	\\x43af92c0de38ad1d31aad008383b323edd716a604e7d194b5d2583b8e42f8165	12	12223	223	1232	1254	46	4	2023-08-16 12:02:51.6	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1256	\\x097ca6e30e4ae7720be036c4adb78eb96242fd496f9ff2f997ca0d68c00ad722	12	12224	224	1233	1255	27	4	2023-08-16 12:02:51.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1258	\\x87f0925ccf436f1d742f8962c7ae884764fdc6b73cb7bbf64b8391cf4a2cdb5c	12	12251	251	1234	1256	5	4	2023-08-16 12:02:57.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1259	\\x56eb20b8cf2b780cbe13124fc299371019a9b408e5f075cdcddd9f4046a530e1	12	12287	287	1235	1258	46	4	2023-08-16 12:03:04.4	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1260	\\xe9cc4137823c843ebb14aa17c54d289c85fdb46b540df20f59ea079740d6a21e	12	12297	297	1236	1259	27	4	2023-08-16 12:03:06.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1261	\\xfd5f58d4d933edf4b0aa90d858c6bdee0372f6d076b1cfc5a5d9601d27a57763	12	12298	298	1237	1260	8	4	2023-08-16 12:03:06.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1262	\\xe77e3c8e599a92a51da7403766d924a26984e2faad49bf187df731a10b083205	12	12304	304	1238	1261	5	4	2023-08-16 12:03:07.8	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1263	\\xff856dbee9c2ba0445c21481f9bb2a06c718a0491086ec7970ef94573fa26bad	12	12319	319	1239	1262	3	4	2023-08-16 12:03:10.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1264	\\xfccfe17c775f5e9d61eaa7c89855e829899dd7d6618553a5e59d028db517a505	12	12321	321	1240	1263	8	4	2023-08-16 12:03:11.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1265	\\x0fb63b8bc30a809ebf0decf520b589bd5994752d4c92358314374250f4c8fdff	12	12328	328	1241	1264	5	4	2023-08-16 12:03:12.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1266	\\xd064bb87b9964ef22235beb7fd7141772e2721d5127f9e934b941fc06786ff70	12	12339	339	1242	1265	3	4	2023-08-16 12:03:14.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1267	\\x493c328bb6055d6851698f1cdea1e08db551d2328ca9969333388294de87a882	12	12359	359	1243	1266	27	4	2023-08-16 12:03:18.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1268	\\x474d22e252b7106ab2b353bbcc6042b6c1498da718b2f60e13bc8b2547e53d68	12	12383	383	1244	1267	8	4	2023-08-16 12:03:23.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1269	\\x18398771678c74677294030edcaf5ff3f570dfa44ee24b6d5514a90c15106e39	12	12384	384	1245	1268	6	4	2023-08-16 12:03:23.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1270	\\x11b575bc04edd0f0e7add7ac107f7007a74fcc0134a95b8da56a2361ac9f4d16	12	12389	389	1246	1269	27	4	2023-08-16 12:03:24.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1271	\\x4dede0a68bbe6e9ca8ca146d9dd5d81a6f821317c37ceffa186a9a3d1e15588b	12	12394	394	1247	1270	15	4	2023-08-16 12:03:25.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1272	\\x01c3b4c02db82e882eb4d31720c76f17266dfeb4ebc3e97e6cc48b92028c50a2	12	12402	402	1248	1271	30	4	2023-08-16 12:03:27.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1273	\\xc58bc667b57bab4eae03a19ead80fe8f56e3697b990aa3a9dfcd70740fa9bca7	12	12403	403	1249	1272	15	4	2023-08-16 12:03:27.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1274	\\x188eb2fc65d8ca661f33ee7988572307016db039ca7daedc7f9fe9868a5250c2	12	12447	447	1250	1273	6	4	2023-08-16 12:03:36.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1275	\\x3584e57ce1f646f05a952bb22ede27c22c8f8797008ef1fe2ead0ebfcbd643b6	12	12456	456	1251	1274	8	4	2023-08-16 12:03:38.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1276	\\xb5f09b4e7e4988af566e16e6f8adcbf974ddbf59389f315e3aa0db41d70eb24b	12	12463	463	1252	1275	3	4	2023-08-16 12:03:39.6	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1277	\\x4cb9f1b6d25578f962e90a96bea305a811d93c649c51eab2777d4ca493bc026f	12	12470	470	1253	1276	46	4	2023-08-16 12:03:41	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1278	\\x9c1f0528122f709c518dcdbaa33823a36f202e9b32601c0493b6782a4e555f84	12	12477	477	1254	1277	28	4	2023-08-16 12:03:42.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1279	\\x4de4c8c9cc24c04a46aa04f8a1135d1d827c4d5069b5f1a2be55b5d2c8010b3c	12	12484	484	1255	1278	30	4	2023-08-16 12:03:43.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1280	\\xf34abd2856dbb69409b85e5a16bab172511d3051589db9549253920c4688b74b	12	12495	495	1256	1279	8	4	2023-08-16 12:03:46	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1281	\\x50fb3e8b5f1cd82f71955206eaf06b8d540d03c023d41e07fb5b53549dec0153	12	12546	546	1257	1280	15	4	2023-08-16 12:03:56.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1282	\\xaf6fe74ad4073126f7c454c8cbc008e258065fa14d368cf311d427ac75d8262b	12	12563	563	1258	1281	27	4	2023-08-16 12:03:59.6	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1283	\\xaddc0566c37ab66c487f57896265bd7d1f108816092867116453d804ac39db62	12	12568	568	1259	1282	6	4	2023-08-16 12:04:00.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1284	\\x022781404db546be69a0ec02295408b753e47489f986677aa9bdb54f8da27e91	12	12576	576	1260	1283	30	4	2023-08-16 12:04:02.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1285	\\x02f464e12730065bc84ae83d57001199c2e1f0687b151c8060e663d344dada04	12	12582	582	1261	1284	5	4	2023-08-16 12:04:03.4	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1286	\\xc11d47e191115ae10aea0c4dd65c18e59b36fbaf9ccdbaa1fdb4a0f183dd1878	12	12584	584	1262	1285	28	4	2023-08-16 12:04:03.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1287	\\x055fd30c2926f8f1cd0516df7ccafaab629b3e00e76c803390990f23ee3cfd51	12	12598	598	1263	1286	28	4	2023-08-16 12:04:06.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1288	\\x7da49fefa9025d87e685ef8835b99e901b1f5e024bcebdf818e4502981faf0be	12	12617	617	1264	1287	3	4	2023-08-16 12:04:10.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1289	\\xc812aab52b689bd7099d9abded21462b9f65e017f06105e138cad8e4ea12e7a3	12	12619	619	1265	1288	46	4	2023-08-16 12:04:10.8	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1290	\\x3d676009affc2ee59eb2c4b13ee3ac2ac503f5067ea4f9cc96ee820068e3a3d4	12	12667	667	1266	1289	6	4	2023-08-16 12:04:20.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1291	\\x0dfaab44fbfa156fcf1439392dd325f739bea2f5cfa8b76a5baa7b818cba8274	12	12668	668	1267	1290	6	4	2023-08-16 12:04:20.6	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1292	\\xd2968692aeaec7e60de06e5f1baf7ba012ea6203c0a1159d1cb618c016975f7c	12	12692	692	1268	1291	30	4	2023-08-16 12:04:25.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1293	\\xad3885aba492f8feae89f00692906f0a4ec53ba2172e50551b2cdf788056201f	12	12696	696	1269	1292	5	4	2023-08-16 12:04:26.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1294	\\xd1b95616e389d01e46a228881c169a2cafe5c73b54ef4c5fb4b081ce0a5fcac5	12	12711	711	1270	1293	3	4	2023-08-16 12:04:29.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1295	\\x43c82070b49cbf27008a542335316db01be33564c6766e54724edac0e9a41003	12	12738	738	1271	1294	30	4	2023-08-16 12:04:34.6	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1296	\\xd7162ebc0900e4ea6ae67587a46c719af20ca43a6fc535ebf807f5688f783730	12	12739	739	1272	1295	6	4	2023-08-16 12:04:34.8	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1297	\\xc21b2334f6f19d998f7d45d74356087667a08ad7a307964538089392738cd89d	12	12746	746	1273	1296	5	4	2023-08-16 12:04:36.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1298	\\x315b62568193992521b9ea4ee10669c6db1359c32506d3459eff1ac9ab389f95	12	12755	755	1274	1297	28	4	2023-08-16 12:04:38	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1299	\\x4e90215d67b95c140e43a3fa7ca9b3842a9765d58999665ca3248ac25bd83bc4	12	12767	767	1275	1298	28	4	2023-08-16 12:04:40.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1300	\\x0976ed8ec1c35436d007c93c18ac24816d8fb1e7fc734247c7c4e99d19aa5fd5	12	12784	784	1276	1299	15	4	2023-08-16 12:04:43.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1301	\\x5cf35898eea53593b15e81f617456cb223fb4d7b254437806737556bb9f5e259	12	12789	789	1277	1300	15	4	2023-08-16 12:04:44.8	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1302	\\xf2f233b4e876af6867136922c15cf2dd6b115284ec5149fa38fea933b0e9f3c1	12	12793	793	1278	1301	8	4	2023-08-16 12:04:45.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1303	\\xbb02779a87f6e7a98734cf3be18537bc8e6fce04025fa3ea8180cde4feee40ea	12	12796	796	1279	1302	46	4	2023-08-16 12:04:46.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1304	\\x2394beed7e1f45139d7aeb84afba39fa464c8d48f03abacd20c88ffaaef8b9dc	12	12797	797	1280	1303	28	4	2023-08-16 12:04:46.4	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1305	\\x4ea35175d968a169c6cfd60daacc741c3487751ea87423608c11b2b872cd8167	12	12813	813	1281	1304	15	4	2023-08-16 12:04:49.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1306	\\x46fd49870e7f938da544271cfe4095b1e682d91b3d3b3a9b4860acbdd2be642f	12	12824	824	1282	1305	27	4	2023-08-16 12:04:51.8	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1307	\\x1ab740ca940a3104827194a6dd56ba5b5b4fff924aae9da7e789dfbd2e344443	12	12831	831	1283	1306	15	4	2023-08-16 12:04:53.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1308	\\xd372dd5df17e5fc0fb1b307647aaf279ace215094cc06bbb332b27f5358ffa07	12	12847	847	1284	1307	6	4	2023-08-16 12:04:56.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1309	\\xd26cc202bb9326c030eda7659340ca286ea66eb1c6dc36d3612ca4b55c247d83	12	12861	861	1285	1308	28	4	2023-08-16 12:04:59.2	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1310	\\xd3c6526a87b1abc34a7e64d257dcb82857a99a9b5a2b1fc5c8234f19fb744b4a	12	12864	864	1286	1309	28	4	2023-08-16 12:04:59.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1311	\\x3448b6ee3df25d261eba773b5033f230b6d3e7860ef66cd92a605098e3169673	12	12880	880	1287	1310	46	4	2023-08-16 12:05:03	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1312	\\x221ea0662ac6c0dedcac67263840abd33e9499a9517b5d3c3c699e152c2d22c0	12	12887	887	1288	1311	6	4	2023-08-16 12:05:04.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1313	\\x7d649c1493c799eecf57d496268e0d9f5564fb8f74156d3b485350d506c876ea	12	12897	897	1289	1312	6	4	2023-08-16 12:05:06.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1314	\\x629243b59bbbd1b46c5dac688fbd029ae846d3269e583412c2382bd1cfab0292	12	12909	909	1290	1313	28	4	2023-08-16 12:05:08.8	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1315	\\xf138f81d96b3d55a75c3bc28e98bfa918d4da57f7da78cc66f36a3813d72bef1	12	12912	912	1291	1314	27	4	2023-08-16 12:05:09.4	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1316	\\x0248c2129d781667e17df998b4217b071bb1d3b43be74e0840eaa049b8efb4f0	12	12930	930	1292	1315	15	4	2023-08-16 12:05:13	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1317	\\x002dfbd5e81ea54e410c321033edeaebee7fc48270421405ae39a0a94c88824c	12	12934	934	1293	1316	3	4	2023-08-16 12:05:13.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1318	\\x50e763349e81d6029d27be5fdaf45f1a1773e6fb991dd05cce0451b2003dfc1a	12	12940	940	1294	1317	28	4	2023-08-16 12:05:15	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1319	\\x01109e4fe2d7ec8609fa2085ca4e0ba2f29c2b13983e26aa0d61590c0eb22025	12	12945	945	1295	1318	8	4	2023-08-16 12:05:16	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1320	\\x31572bf89d92dd3d75d039cddf0673c96bb541947f63571bce49b3c25783d6ba	12	12947	947	1296	1319	30	4	2023-08-16 12:05:16.4	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1321	\\x899108104ff85051fce78634362e3bda81d77373ea149b4c39ca1eccb96617a2	12	12949	949	1297	1320	8	4	2023-08-16 12:05:16.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1322	\\x69815354e5c0439d3f4fca9341035d73f2a85c37bc8b606a04187854fd4d4765	12	12951	951	1298	1321	46	4	2023-08-16 12:05:17.2	0	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1323	\\x65ab7cb2c06f62e2e32f6107741a41462f0a54e29f54b76e01ad3a1996eb7c65	12	12956	956	1299	1322	5	4	2023-08-16 12:05:18.2	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1324	\\xe5a2ef30013619288457a3662b9e1817774cd6735aa681fe5d175b79dfd940a9	12	12959	959	1300	1323	8	4	2023-08-16 12:05:18.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1325	\\x8ef482a8faa3a0090b2734f614c6cc3a66ce13cd81cfebc9882d0ae95dc4d0bc	12	12970	970	1301	1324	27	4	2023-08-16 12:05:21	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1326	\\x6e681d9a4d66e042071173e733acbb72eaaec00b8bcd9795fb3d2924ea112219	12	12991	991	1302	1325	15	4	2023-08-16 12:05:25.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1327	\\x94accc324d14bcdc8a6411ab85e368d5c200065d9d1e88cf5b23e5ed54680f33	13	13021	21	1303	1326	30	4	2023-08-16 12:05:31.2	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1328	\\xd63979062df0b039cbed1e7d74bf05ace7ca6198b2da2d1421b26ff12a8b9805	13	13035	35	1304	1327	8	577	2023-08-16 12:05:34	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1329	\\xa8b71c2f03c4de312eb36a9701efe7174389a4638db7b281ea1c0deec7cc2caf	13	13052	52	1305	1328	6	4	2023-08-16 12:05:37.4	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1330	\\xf1dc1164a14f1e2c068b83d9ddc7f43d4435c8202b38adc609561e64c12f649f	13	13053	53	1306	1329	5	4	2023-08-16 12:05:37.6	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1331	\\x9d1f12bd3ee6dd0fbd622862d088d0b7db58b7b4cf96f69cbb7113129cd0c8e4	13	13056	56	1307	1330	15	4	2023-08-16 12:05:38.2	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1332	\\x47dbe9e2e5420c63cbddf362c4023e9db1e0cf1419f49e348d5e49d3c8bdfcfb	13	13061	61	1308	1331	3	4	2023-08-16 12:05:39.2	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1333	\\x9f3f610b7042f25c8d406cb9a152dda4048203b5c9a38baf932721a34c97566a	13	13075	75	1309	1332	5	4	2023-08-16 12:05:42	0	8	0	vrf_vk1ql6vkzzpx4j3tjk8m68thq8wgt3fezzvm4afesrnap2d34e8e7dslfrwty	\\xa0ed82d1ec8f74e1f11b17c7dc7660be178f89343318b2425c3e0d258689b42e	0
1334	\\xf255e99a92674e7300d5e7907c0d0e03873f3f3db7cc16fa137fad0b4a6f50c0	13	13085	85	1310	1333	3	4	2023-08-16 12:05:44	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1335	\\xc4fc5f6d37e462743fdfab2aa15a4b2b5140cdce9875b4e4330a363e454a3b9c	13	13118	118	1311	1334	46	554	2023-08-16 12:05:50.6	1	8	0	vrf_vk1wzv4myaxl5gjapqvftjccdx3tclp0p9hyr5kluln63w9ya2up2cqpcyygy	\\xd5194034fdadf2056d5ea1fb130bf3ef4f075043032b3bab88d9296d78413150	0
1336	\\x28374058cfcf35efe2897c9aedfb464296aacf88ead81c3cd03045d1ec50606a	13	13121	121	1312	1335	27	4	2023-08-16 12:05:51.2	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1337	\\x8e2725063239906eafccdb6dbaa37247a9a831f5bea055051f755eb2decab47e	13	13132	132	1313	1336	3	4	2023-08-16 12:05:53.4	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1338	\\x3f1db5c31412a498206d5a9370b0194a938a53760e10a653038afd3c24a84d42	13	13135	135	1314	1337	6	4	2023-08-16 12:05:54	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1339	\\x1079163ae531974b927cb3e9d2ee82e2480e73a67aa6fb121505e5f8955a3f07	13	13140	140	1315	1338	8	329	2023-08-16 12:05:55	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1340	\\x747ca5e131a4b8a2b8cc48e1f7a03529a90bd4b6652cef38b7929fb9b9100624	13	13150	150	1316	1339	15	4	2023-08-16 12:05:57	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1341	\\xf7525c853b6963110104872fe95956a8b99692aeef39e57a50626682e7cf8672	13	13154	154	1317	1340	8	4	2023-08-16 12:05:57.8	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1342	\\xcc2ddeb9e68c0cf18222a6ace7c905a13c1076c7f74f0879059d6a05144537aa	13	13164	164	1318	1341	30	4	2023-08-16 12:05:59.8	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1343	\\xbf2fac6612e7aa10c61b16234f2199ef13f12d57b46a103dd2a6496099be5772	13	13173	173	1319	1342	28	460	2023-08-16 12:06:01.6	1	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1344	\\xac4abc4ee1305e5366371e2f4dac9fbd39308705b80c5e81ee733a97f33ef5a6	13	13175	175	1320	1343	30	4	2023-08-16 12:06:02	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1345	\\xd8a713cdc11fbdeb78a227359c02badfecb457d311545100a8d15a6f117f9e90	13	13188	188	1321	1344	15	4	2023-08-16 12:06:04.6	0	8	0	vrf_vk1lup584mzj2gxs8u66yhfjmzh7xx5qk409kmqh5tcmm6vem32eujsmtxpke	\\xb7dd07f673b2ecc433025ec50ff9131ccbb6f587999712896da4d2790195f2d2	0
1346	\\x3c3123b376ce17dc81a21aebd59bae12cd5579057ae1ae9caac38f9e6f8666b8	13	13218	218	1322	1345	28	4	2023-08-16 12:06:10.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1347	\\x2b44a84a1b8d2c2c59641ee7b80d8b3d6881fe49376d99420b293dc262ab5525	13	13229	229	1323	1346	8	631	2023-08-16 12:06:12.8	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1348	\\xced92b6295504f2f5ce6ae3c12359ff3874294f1d6f42fe2faaeeb82fae30028	13	13235	235	1324	1347	30	4	2023-08-16 12:06:14	0	8	0	vrf_vk18gq9nf0hth9594es6ncsaaztdt7yw8mfamuskk0jdhurnkqp8jfqsw7vwy	\\xf2584895763e44e20f27c4c0eec78ae16eddd74413607f62a36030719dcf02aa	0
1349	\\x6996a2736fe82644058fa1d84fa5fee65ba02c6aa24c35b06667fd5cae452faf	13	13236	236	1325	1348	6	4	2023-08-16 12:06:14.2	0	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1350	\\x38a75c15f5d0699f20326fceb04db18a25e0ca305fb9ef71aab74c8f4510369a	13	13238	238	1326	1349	28	4	2023-08-16 12:06:14.6	0	8	0	vrf_vk1053pgyg4l9c6gmj4cl6v2hj6cpt9070pxdhqf5v5udy7xsyt07gqc2jmyu	\\x60463ff9ac4d2a02f33863fd21ba662075ecaa9148acacbf6693c12306110038	0
1351	\\xb26c8551524a160b3f6ab60377201aaccad3efeee444819cecfc52f967db89af	13	13248	248	1327	1350	6	397	2023-08-16 12:06:16.6	1	8	0	vrf_vk1sq0w9alpkr02s7pc6e73z0h3jr2shjsly0d746luk23uca3u6x2qu4wdkj	\\x670fad39b0f5cf76fa77e1fb3477eaf04bb192faa626519dbfff0cb5b9f575f4	0
1352	\\x88584d994b68f0e8a4aa5ac1b1b103c14d9add1ed74d18e6fa696acb7d824101	13	13250	250	1328	1351	27	4	2023-08-16 12:06:17	0	8	0	vrf_vk14ck4lh0nf7cw3fnnc9sryh2zgh0dd7uzrfjcncvjcd4ajsegge0sgx53qu	\\x50e174d65b949c858ae7e2ea061b071632d7f17e634891ca46717d29193e7c42	0
1353	\\x0cce3b99bb81e1b4917904bfa0a5dc5da2c07a849596d2db3204ace27a6a1ad9	13	13288	288	1329	1352	8	4	2023-08-16 12:06:24.6	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1354	\\x48b14129d47eb901afc9d35501da040daafbc6af8ca29ba9e6ed76b231df70a3	13	13300	300	1330	1353	8	4	2023-08-16 12:06:27	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1355	\\xc088584dde9e508d924c9520701d207897bd868ce6bc0f6584d47eaf8f3e9c11	13	13316	316	1331	1354	8	528	2023-08-16 12:06:30.2	1	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1356	\\xd50f6ea81b6791723face5afbdcff251c480166c102db11781c7da945e1cd126	13	13329	329	1332	1355	3	4	2023-08-16 12:06:32.8	0	8	0	vrf_vk16wmr6yrxkunl7cme6s7kkhenmegdaaxkp23c08tryllyynxkvhpq0wkx0c	\\x80b8195435aea1a9ab20f9227ad5e0630fd706e00b0e04babc865c5eb41de364	0
1357	\\x8775084733c162f4bc082d426faff91719b234ad9b2c3f7725de6779da0ad65e	13	13330	330	1333	1356	8	4	2023-08-16 12:06:33	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
1358	\\x66bd94e7977359c1655d789d97ae88641528a21751785513b05290768ed06141	13	13336	336	1334	1357	8	4	2023-08-16 12:06:34.2	0	8	0	vrf_vk19kaxqdpupcz4gkf56rs4dwuf4zn4376xfua0kvv09uf9v43d9nhsnpmtae	\\x3fe7100082825b2508d879caa10d0f24b5631792ea122d0788e7b724d66c94b1	0
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
1	99	1	addr_test1vrusj80gys259lmsgtjzc33fpuy9harf7rf82whu2dsg58q08zyuq	\\x60f9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	f	\\xf9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	\N	3681818081394197	\N	fromList []	\N	\N
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
\.


--
-- Data for Name: delegation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delegation (id, addr_id, cert_index, pool_hash_id, active_epoch_no, tx_id, slot_no, redeemer_id) FROM stdin;
1	1	1	5	2	34	0	\N
2	9	3	2	2	34	0	\N
3	10	5	9	2	34	0	\N
4	2	7	4	2	34	0	\N
5	8	9	7	2	34	0	\N
6	7	11	3	2	34	0	\N
7	3	13	10	2	34	0	\N
8	11	15	11	2	34	0	\N
9	5	17	8	2	34	0	\N
10	6	19	1	2	34	0	\N
11	4	21	6	2	34	0	\N
12	15	0	4	2	37	62	\N
13	2	0	4	2	38	71	\N
14	13	0	2	2	42	158	\N
15	9	0	2	2	43	169	\N
16	20	0	9	2	47	257	\N
17	10	0	9	2	48	269	\N
18	17	0	6	2	52	356	\N
19	4	0	6	2	53	381	\N
20	18	0	7	2	57	441	\N
21	8	0	7	2	58	453	\N
22	16	0	5	2	62	551	\N
23	1	0	5	2	63	562	\N
24	14	0	3	2	67	635	\N
25	7	0	3	2	68	658	\N
26	21	0	10	2	72	753	\N
27	3	0	10	2	73	778	\N
28	3	0	10	2	75	800	\N
29	22	0	11	2	79	853	\N
30	11	0	11	2	80	866	\N
31	11	0	11	2	82	896	\N
32	12	0	1	2	86	954	\N
33	6	0	1	2	87	980	\N
34	6	0	1	3	89	1033	\N
35	19	0	8	3	93	1094	\N
36	5	0	8	3	94	1107	\N
37	5	0	8	3	96	1128	\N
38	51	1	3	6	131	4964	\N
39	52	3	6	6	131	4964	\N
40	53	5	7	6	131	4964	\N
41	54	7	4	6	131	4964	\N
42	55	9	9	6	131	4964	\N
43	51	0	3	7	133	5035	\N
44	52	1	3	7	133	5035	\N
45	53	2	3	7	133	5035	\N
46	54	3	3	7	133	5035	\N
47	55	4	3	7	133	5035	\N
48	46	1	3	7	148	5410	\N
49	46	1	3	7	152	5685	\N
50	64	1	6	11	254	9499	\N
51	48	0	12	15	358	13173	\N
52	45	0	13	15	361	13316	\N
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
1	198818103619273034	9709606	54	97	0	2023-08-16 11:22:07.4	2023-08-16 11:25:26.4
2	69964514398000728	4166925	22	100	1	2023-08-16 11:25:33.6	2023-08-16 11:28:45.8
13	0	0	0	90	12	2023-08-16 12:02:08.2	2023-08-16 12:05:21
4	0	0	0	108	3	2023-08-16 11:32:09.4	2023-08-16 11:35:10
8	6147769930859	16897788	100	110	7	2023-08-16 11:45:27.8	2023-08-16 11:48:44
11	0	0	0	116	10	2023-08-16 11:55:27.2	2023-08-16 11:58:45.8
7	0	0	0	87	6	2023-08-16 11:42:11.2	2023-08-16 11:45:24.6
10	5106037795232	587214	2	99	9	2023-08-16 11:52:07.4	2023-08-16 11:55:24.4
14	15016356730589	1241535	7	31	13	2023-08-16 12:05:31.2	2023-08-16 12:06:33
5	80000600284472	3977605	21	100	4	2023-08-16 11:35:32	2023-08-16 11:38:41.8
3	0	0	0	97	2	2023-08-16 11:28:49.8	2023-08-16 11:32:03.4
9	0	0	0	104	8	2023-08-16 11:48:49.6	2023-08-16 11:51:56.6
12	22501817995456	16925112	100	100	11	2023-08-16 11:58:47.4	2023-08-16 12:01:53.2
6	42339617067111	9083567	20	84	5	2023-08-16 11:38:48	2023-08-16 11:42:03.4
\.


--
-- Data for Name: epoch_param; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_param (id, epoch_no, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, nonce, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, block_id, extra_entropy, coins_per_utxo_size) FROM stdin;
1	1	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x8721ae1f3638fc119943e1c15daf734226f258fa4ef20e5eb5bbc3b27e9758c3	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	100	\N	4310
2	2	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x71ca305b41170a626ecd08dbc4fab36d85ff0464bb8be40e01540deb9a164202	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	200	\N	4310
3	3	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x2970bfd00b58fb0567883b212cd27876cbd455e317387fbf3af24d8a6fc91a30	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	298	\N	4310
4	4	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x3041e52491b0dbc01f2ec0e69020e19394ab7c746bcd01ddc959c88554dcd33c	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	411	\N	4310
5	5	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x2c80a361cad42e0c956b59d7b48469467a98754b07100fc38f0e50fdad271321	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	514	\N	4310
6	6	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xd8621c0a4a8fd756715a7a32225464e7a63eabf47131dc0b86892b938112fcfb	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	601	\N	4310
7	7	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x26b535a234b7cc9680b5fdeee495f25e7ec4700d71d059d163cb05510f06b0d5	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	689	\N	4310
8	8	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xa1f32f1fef57a67a2387b96f37b43adfcea9d67391bc2f6bdb556ff37ff712aa	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	803	\N	4310
9	9	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x527920be5812783194d9e7ebb66d3dc4dab67117575c4c13e9c8bf78e3906031	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	911	\N	4310
10	10	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x3730b1614d492cc96ab8899be4004c8988756c06d4b23b05e58185e8d1729a37	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1013	\N	4310
11	11	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xce9065d84722e9ff3e336178863bcde2229dad1f49e704f68876eb524870a1da	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1133	\N	4310
12	12	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x78e3b5108147def8f89a724a0a000b1c00e023a21ee66aa062c1a5b72f2fdeec	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1235	\N	4310
13	13	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xbd403ba6b2cf67e32cf7a63bf02fd266d625fe6105c4921ac3aa74ae277d8291	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1327	\N	4310
\.


--
-- Data for Name: epoch_stake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_stake (id, addr_id, pool_id, amount, epoch_no) FROM stdin;
1	1	5	3681818181818181	1
2	9	2	3681818181818181	1
3	10	9	3681818181818181	1
4	2	4	3681818181818181	1
5	8	7	3681818181818181	1
6	7	3	3681818181818181	1
7	3	10	3681818181818181	1
8	11	11	3681818181818181	1
9	5	8	3681818181818190	1
10	6	1	3681818181818181	1
11	4	6	3681818181818181	1
12	1	5	3681818181443619	2
13	20	9	200000000	2
14	22	11	300000000	2
15	9	2	3681818181446391	2
16	13	2	600000000	2
17	17	6	500000000	2
18	14	3	500000000	2
19	10	9	3681818181443619	2
20	15	4	500000000	2
21	2	4	3681818181443619	2
22	18	7	500000000	2
23	8	7	3681818181443619	2
24	7	3	3681818181443619	2
25	16	5	500000000	2
26	3	10	3681818181265842	2
27	11	11	3681818181265842	2
28	12	1	500000000	2
29	5	8	3681818181818190	2
30	6	1	3681818181443575	2
31	21	10	300000000	2
32	4	6	3681818181443619	2
33	19	8	500000000	3
34	1	5	3681818181443619	3
35	20	9	200000000	3
36	22	11	300000000	3
37	9	2	3681818181446391	3
38	13	2	600000000	3
39	17	6	500000000	3
40	14	3	500000000	3
41	10	9	3681818181443619	3
42	15	4	500000000	3
43	2	4	3681818181443619	3
44	18	7	500000000	3
45	8	7	3681818181443619	3
46	7	3	3681818181443619	3
47	16	5	500000000	3
48	3	10	3681818181265842	3
49	11	11	3681818181265842	3
50	12	1	500000000	3
51	5	8	3681818181263035	3
52	6	1	3681818181263026	3
53	21	10	300000000	3
54	4	6	3681818181443619	3
55	19	8	500000000	4
56	1	5	3687994675702046	4
57	20	9	200000000	4
58	22	11	300000000	4
59	9	2	3688877032027451	4
60	13	2	600000000	4
61	17	6	500000000	4
62	14	3	500000000	4
63	10	9	3688877032024679	4
64	15	4	500000000	4
65	2	4	3689759388347311	4
66	18	7	500000000	4
67	8	7	3686229963056781	4
68	7	3	3692406457315209	4
69	16	5	500000000	4
70	3	10	3689759388169534	4
71	11	11	3694171169782697	4
72	12	1	500000000	4
73	5	8	3690641744489360	4
74	6	1	3687112319198821	4
75	21	10	300000000	4
76	4	6	3692406457315209	4
77	19	8	500000000	5
78	1	5	3696642648573744	5
79	20	9	200375813	5
80	22	11	300845579	5
81	9	2	3698389801669569	5
82	13	2	601550229	5
83	17	6	501056974	5
84	14	3	500939532	5
85	10	9	3695795411449477	5
86	15	4	500822091	5
87	2	4	3695812969357500	5
88	18	7	501056974	5
89	8	7	3694013138641310	5
90	7	3	3699324835612568	5
91	16	5	501174416	5
92	3	10	3697542564600018	5
93	11	11	3704548738356676	5
94	12	1	501174416	5
95	5	8	3694965732099186	5
96	6	1	3695760292070520	5
97	21	10	300634184	5
98	4	6	3700189632899738	5
99	19	8	500950790	6
100	1	5	3699287234143788	6
101	54	4	200000000	6
102	20	9	200375813	6
103	22	11	300845579	6
104	9	2	3703018089665686	6
105	13	2	817749142766	6
106	17	6	1167695541305	6
107	14	3	1867840414485	6
108	10	9	3695795411449477	6
109	15	4	2217904292357	6
110	53	7	200000000	6
111	2	4	3708376034315040	6
112	51	3	199693655	6
113	18	7	1167712541303	6
114	8	7	3700625121066352	6
115	7	3	3709904206392609	6
116	16	5	467593168119	6
117	52	6	200000000	6
118	3	10	3697542564600018	6
119	11	11	3704548738356676	6
120	12	1	1167729658800	6
121	5	8	3701967005667173	6
122	6	1	3702372257495888	6
123	21	10	300634184	6
124	55	9	200000000	6
125	4	6	3706801632324778	6
126	19	8	1608571228086	7
127	1	5	3707702633162779	7
128	54	3	0	7
129	20	9	200375813	7
130	22	11	300845579	7
131	9	2	3710029196141707	7
132	13	2	2055394568374	7
133	17	6	2898593537994	7
134	14	3	2486237448987	7
135	10	9	3695795411449477	7
136	15	4	3578955462517	7
137	53	3	0	7
138	2	4	3716086440647027	7
139	51	3	499402614	7
140	18	7	1415684497343	7
141	8	7	3702028084215265	7
142	7	3	3713406243093312	7
143	16	5	1953064925491	7
144	52	3	0	7
145	11	11	3704548738356676	7
146	5	8	3711077185677004	7
147	55	3	499846827	7
148	46	3	4998958471031	7
149	4	6	3716607948786666	7
150	19	8	2592322800714	8
151	1	5	3711879928728604	8
152	54	3	0	8
153	20	9	200375813	8
154	22	11	300845579	8
155	9	2	3714204526428248	8
156	13	2	2792608359087	8
157	17	6	3635431803804	8
158	14	3	3468830207918	8
159	10	9	3695795411449477	8
160	15	4	4316682936408	8
161	53	3	0	8
162	2	4	3720264682557768	8
163	51	3	499402614	8
164	18	7	2768567298430	8
165	8	7	3709692203157670	8
166	7	3	3718972053702673	8
167	16	5	2690635397506	8
168	52	3	0	8
169	11	11	3704548738356676	8
170	5	8	3716649562894901	8
171	55	3	499846827	8
172	46	3	4998958471031	8
173	4	6	3720781265192093	8
174	19	8	3440321880583	9
175	1	5	3715312239660153	9
176	54	3	479686	9
177	20	9	200375813	9
178	22	11	300845579	9
179	9	2	3719689866926995	9
180	13	2	3762424735350	9
181	17	6	4846896285159	9
182	14	3	4195880344904	9
183	10	9	3695795411449477	9
184	15	4	5892912624317	9
185	53	3	185362	9
186	2	4	3729158976998698	9
187	51	3	499623518	9
188	18	7	3375485963259	9
189	8	7	3713121983746394	9
190	7	3	3723076019324008	9
191	16	5	3297247734989	9
192	52	3	369509	9
193	11	11	3704548738356676	9
194	5	8	3721452676681108	9
195	55	3	499846827	9
196	46	3	4998941573243	9
197	4	6	3727629751076771	9
198	19	8	4145153871757	10
199	1	5	3723278994470673	10
200	54	3	479686	10
201	20	9	200375813	10
202	22	11	300845579	10
203	9	2	3723670367983288	10
204	13	2	4467850496787	10
205	17	6	5816013866319	10
206	14	3	5779942274707	10
207	10	9	3695795411449477	10
208	15	4	7039325536176	10
209	53	3	185362	10
210	2	4	3735611676286867	10
211	51	3	500823446	10
212	18	7	4346643110393	10
213	8	7	3718609009037545	10
214	7	3	3731998321721613	10
215	16	5	4708482769864	10
216	52	3	369509	10
217	11	11	3704548738356676	10
218	5	8	3725433012752148	10
219	55	3	501047822	10
220	46	3	5010952707019	10
221	4	6	3733090926126129	10
222	19	8	5062247997909	11
223	1	5	3729491422092629	11
224	54	3	479686	11
225	20	9	200375813	11
226	22	11	300845579	11
227	9	2	3731430716697860	11
228	13	2	5844578261748	11
229	17	6	6549873111781	11
230	14	3	6971011754837	11
231	10	9	3695795411449477	11
232	15	4	8416410138313	11
233	53	3	185362	11
234	2	4	3743353062664958	11
235	51	3	501722691	11
236	18	7	5173795456905	11
237	8	7	3723270801495249	11
238	7	3	3738694861480622	11
239	16	5	5810491421700	11
240	52	3	369509	11
241	11	11	3704548738356676	11
242	5	8	3730603626486635	11
243	55	3	501947867	11
244	64	6	2505476266139	11
245	46	3	2514477191581	11
246	4	6	3737220466420558	11
247	19	8	6010477984443	12
248	1	5	3737512697296235	12
249	54	3	480165	12
250	20	9	200375813	12
251	22	11	300845579	12
252	9	2	3739974587475681	12
253	13	2	7362877257621	12
254	17	6	7498159625683	12
255	14	3	7634309109584	12
256	10	9	3695795411449477	12
257	15	4	9650189475314	12
258	53	3	185547	12
259	2	4	3750269406350538	12
260	51	3	502222371	12
261	18	7	6029088703191	12
262	8	7	3728086070463030	12
263	7	3	3742418360269000	12
264	16	5	7234785496902	12
265	52	3	369878	12
266	11	11	3704548738356676	12
267	5	8	3735941820217074	12
268	55	3	502447770	12
269	64	6	2505476266139	12
270	46	3	2519476700802	12
271	4	6	3742545830863293	12
272	19	8	6888445474676	13
273	1	5	3743348188611654	13
274	54	3	480910	13
275	20	9	200375813	13
276	22	11	300845579	13
277	9	2	3745361307778639	13
278	13	2	8321468796988	13
279	17	6	8455894724060	13
280	14	3	8670704651980	13
281	10	9	3695795411449477	13
282	15	4	10928135041571	13
283	53	3	185835	13
284	2	4	3757419069833241	13
285	51	3	503001115	13
286	18	7	7148751969756	13
287	8	7	3734379576220620	13
288	7	3	3748221349149654	13
289	16	5	8273659964532	13
290	52	3	370452	13
291	11	11	3704548738356676	13
292	5	8	3740878142883292	13
293	55	3	503226863	13
294	64	6	0	13
295	46	3	5032727712760	13
296	4	6	3747915131972882	13
\.


--
-- Data for Name: epoch_sync_time; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_sync_time (id, no, seconds, state) FROM stdin;
1	0	1	lagging
2	1	1	lagging
3	2	1	following
4	3	186	following
5	4	197	following
6	5	204	following
7	6	197	following
8	7	202	following
9	8	198	following
10	9	200	following
11	10	201	following
12	11	201	following
13	12	203	following
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
12	-1	112	10
13	1	113	12
14	1	114	13
15	1	115	14
16	-1	116	12
17	-1	116	13
18	-1	116	14
19	-1	116	9
20	-1	116	11
21	1	117	15
22	1	117	16
23	-1	120	16
24	-1	121	15
25	1	122	15
26	1	123	15
27	-2	124	15
28	2	125	15
29	-2	126	15
30	2	127	15
31	-1	128	15
32	-1	129	15
33	1	134	17
34	-1	135	17
35	10	136	18
36	-10	137	18
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
12	1	139	9
13	1	139	11
14	1	140	12
15	1	141	9
16	1	141	11
17	1	142	13
18	1	143	9
19	1	143	11
20	1	144	14
21	1	145	12
22	1	145	9
23	1	145	11
24	1	147	15
25	1	147	16
26	1	149	15
27	1	150	16
28	1	152	16
29	1	155	15
30	1	157	15
31	1	158	15
32	2	160	15
33	2	163	15
34	1	165	15
35	1	214	17
36	10	217	18
37	13500000000000000	789	1
38	13500000000000000	789	2
39	13500000000000000	789	3
40	13500000000000000	789	4
41	2	791	5
42	1	791	6
43	1	791	7
44	2	793	5
45	1	793	6
46	1	793	7
\.


--
-- Data for Name: meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meta (id, start_time, network_name, version) FROM stdin;
1	2023-08-16 11:22:07	testnet	Version {versionBranch = [13,1,0,0], versionTags = []}
\.


--
-- Data for Name: multi_asset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.multi_asset (id, policy, name, fingerprint) FROM stdin;
1	\\x0bfbec825e34b44b8c2cbbfbd4a9d52526d77106333a1135a323189a	\\x	asset1sfyuxr0mh2tvm9xsrvdaf4hjve07qekqyyj5n7
2	\\x0bfbec825e34b44b8c2cbbfbd4a9d52526d77106333a1135a323189a	\\x74425443	asset19av40k0rqfl66lflafcya2haxhxzft0v6htwlg
3	\\x0bfbec825e34b44b8c2cbbfbd4a9d52526d77106333a1135a323189a	\\x74455448	asset1a5vwq0g4c43twtpuhaalc9hzavlf7jzr9w7yeq
4	\\x0bfbec825e34b44b8c2cbbfbd4a9d52526d77106333a1135a323189a	\\x744d494e	asset177f477ydasca25qnun59aa9m4yc5ft6rl02rzy
5	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x446f75626c6548616e646c65	asset1ss4nvcah07l2492qrfydamvukk4xdqme8k22vv
6	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x48656c6c6f48616e646c65	asset13xe953tueyajgxrksqww9kj42erzvqygyr3phl
7	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x5465737448616e646c65	asset1ne8rapyhga8jp95pemrefrgts9ht035zlmy6zj
8	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x283232322968616e646c653638	asset1ju4qkyl4p9xszrgfxfmu909q90luzqu0nyh4u8
9	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d303031	asset1p7xl6rzm50j2p6q2z7kd5wz3ytyjtxts8g8drz
10	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d303032	asset1ftcuk4459tu0kfkf2s6m034q8uudr20w7wcxej
11	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d66696c6573	asset1xac6dlxa7226c65wp8u5d4mrz5hmpaeljvcr29
12	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d76312d686578	asset1v2z720699zh5x5mzk23gv829akydgqz2zy9f6l
13	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d76312d75746638	asset16unjfedceaaven5ypjmxf5m2qd079td0g8hldp
14	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d7632	asset1yc673t4h5w5gfayuedepzfrzmtuj3s9hay9kes
15	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x68616e646c6531	asset1q0g92m9xjj3nevsw26hfl7uf74av7yce5l56jv
16	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x68616e646c6532	asset1se72wfdln5vlspqe3yg8yck0rrgand3a48rjyc
17	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x	asset1qrmynj6uhyk2hn9pc3yh0p80rg598n4yy77ays
18	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	\\x3030303030	asset1ul4zmmx2h8rqz9wswvc230w909pq2q0hne02q0
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
1	\\x280ccdd73caed5cc7418329da0bcedf408afc97d396809b32add237c	pool19qxvm4eu4m2ucaqcx2w6p08d7sy2ljta895qnve2m53hcc4nsgy
2	\\x2a688f6bcdaca28fc9dd3090aa6b0655734b35db4401b8258fd274d6	pool19f5g767d4j3gljwaxzg256cx24e5kdwmgsqmsfv06f6dvt3vs0m
3	\\x311a76aa43883b855135f885b057bc99040c2de70abd4879311303f2	pool1xyd8d2jr3qac25f4lzzmq4aunyzqct08p275s7f3zvplyx5mz3t
4	\\x4fe592360963b32969f3879523d2244262c59bb928c8708782434d67	pool1fljeydsfvwejj60ns72j853ygf3vtxae9ry8ppuzgdxkw9x3mm5
5	\\x5886e5b26784071e84af8705cb1461fb2be67ae6e43699b4631de0cc	pool1tzrwtvn8ssr3ap90suzuk9rplv47v7hxusmfndrrrhsvc3u03gl
6	\\x6943b0ddd6b64586dfb53805246923f1ea6e80a4eb55ffc9f776061f	pool1d9pmphwkkezcdha48qzjg6fr784xaq9yad2llj0hwcrp7ldnufq
7	\\x833b046b58fb26a1a5e1b89441af01bdab84073894320de2d4d29ca5	pool1svasg66clvn2rf0phz2yrtcphk4cgpecjseqmck562w22xa578g
8	\\x8a4244fd87e38f181915834328e91e4ee206c1422c473fe3ab9f4e7f	pool13fpyflv8uw83sxg4sdpj36g7fm3qds2z93rnlcatna887f4lhdm
9	\\xbd2e89744da6e4127d5af3cfd47b33abb313e242e315e7171e9990c6	pool1h5hgjazd5mjpyl26708ag7en4we38cjzuv27w9c7nxgvvl2emyc
10	\\xc1b652054e8ad1edb3284c3856f92d5a9ef5a6b07c5f1b0f03955d79	pool1cxm9yp2w3tg7mvegfsu9d7fdt200tf4s0303krcrj4whjxne52w
11	\\xf9583ec8e04bdf554e923c27f8f29f41d9f4896f1604d769df13228f	pool1l9vraj8qf0042n5j8snl3u5lg8vlfzt0zczdw6wlzv3g7ldvlw3
12	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
13	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_metadata_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata_ref (id, pool_id, url, hash, registered_tx_id) FROM stdin;
1	4	http://file-server/SP1.json	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	39
2	9	http://file-server/SP3.json	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	49
3	6	http://file-server/SP4.json	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	54
4	7	http://file-server/SP5.json	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	59
5	5	http://file-server/SP6.json	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	64
6	3	http://file-server/SP7.json	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	69
7	1	http://file-server/SP10.json	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	88
8	8	http://file-server/SP11.json	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	95
\.


--
-- Data for Name: pool_offline_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_offline_data (id, pool_id, ticker_name, hash, json, bytes, pmr_id) FROM stdin;
1	4	SP1	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	{"name": "stake pool - 1", "ticker": "SP1", "homepage": "https://stakepool1.com", "description": "This is the stake pool 1 description."}	\\x7b0a2020226e616d65223a20227374616b6520706f6f6c202d2031222c0a2020227469636b6572223a2022535031222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2031206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c312e636f6d220a7d0a	1
2	9	SP3	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	{"name": "Stake Pool - 3", "ticker": "SP3", "homepage": "https://stakepool3.com", "description": "This is the stake pool 3 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2033222c0a2020227469636b6572223a2022535033222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2033206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c332e636f6d220a7d0a	2
3	6	SP4	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	{"name": "Same Name", "ticker": "SP4", "homepage": "https://stakepool4.com", "description": "This is the stake pool 4 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535034222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2034206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c342e636f6d220a7d0a	3
4	7	SP5	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	{"name": "Same Name", "ticker": "SP5", "homepage": "https://stakepool5.com", "description": "This is the stake pool 5 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535035222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2035206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c352e636f6d220a7d0a	4
5	5	SP6a7	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	{"name": "Stake Pool - 6", "ticker": "SP6a7", "homepage": "https://stakepool6.com", "description": "This is the stake pool 6 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2036222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2036206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c362e636f6d220a7d0a	5
6	3	SP6a7	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	{"name": "", "ticker": "SP6a7", "homepage": "https://stakepool7.com", "description": "This is the stake pool 7 description."}	\\x7b0a2020226e616d65223a2022222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2037206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c372e636f6d220a7d0a	6
7	1	SP10	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	{"name": "Stake Pool - 10", "ticker": "SP10", "homepage": "https://stakepool10.com", "description": "This is the stake pool 10 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130222c0a2020227469636b6572223a202253503130222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203130206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31302e636f6d220a7d0a	7
8	8	SP11	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	{"name": "Stake Pool - 10 + 1", "ticker": "SP11", "homepage": "https://stakepool11.com", "description": "This is the stake pool 11 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130202b2031222c0a2020227469636b6572223a202253503131222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203131206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31312e636f6d220a7d0a	8
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
1	15	12
2	13	13
3	20	14
4	17	15
5	18	16
6	16	17
7	14	18
8	21	19
9	22	20
10	12	21
11	19	22
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
1	10	0	76	5
2	11	0	83	18
3	1	0	90	5
4	8	0	97	18
\.


--
-- Data for Name: pool_update; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_update (id, hash_id, cert_index, vrf_key_hash, pledge, active_epoch_no, meta_id, margin, fixed_cost, registered_tx_id, reward_addr_id) FROM stdin;
1	1	0	\\xb825aeca0448833d242faa4c7dccd80ed7975dc8a6313492d4ed8d8cc9d92514	0	2	\N	0	0	34	12
2	2	1	\\x265b7e85d737edaa1eeb3effa3b8d994f26ae22e7b21fb1e2bbf3ecb36bc566c	0	2	\N	0	0	34	13
3	3	2	\\x05ace6cbd31b5fba7aae0fbe418a1faa2243cdd8fe719447c2bb3dd6c7b2ef82	0	2	\N	0	0	34	14
4	4	3	\\x927b448ee9d4a15a5ea11c4de48ee552fa3e371c0a19c01e45d28e6f6212426e	0	2	\N	0	0	34	15
5	5	4	\\xcc8b277cda6cc09005c45e06fbaafe68fac865adfd622858cb47b2446d787e98	0	2	\N	0	0	34	16
6	6	5	\\x0e5ca4c18e299b8eb7e99982058adb1e190e08cbf4e61440b3c3d87ecb8d3492	0	2	\N	0	0	34	17
7	7	6	\\x0e39cf5cf296d28a333861798e5865b9794b42796d91bc31ef6297d2d8ff2a00	0	2	\N	0	0	34	18
8	8	7	\\x5b586190b171b79c86d744ea82029968461292ca14ef94a1a2270eeedbed4bb5	0	2	\N	0	0	34	19
9	9	8	\\xc5fba6a50bf972c8c73e871817a87d0a7d4dd7cfb299b041c9f98a0fd719f128	0	2	\N	0	0	34	20
10	10	9	\\x2a54c79aaced460f8da56dcf23283b5aeab2e37d4280bff6f69cf844a8406c5b	0	2	\N	0	0	34	21
11	11	10	\\x3b3187802eff459730a6ed16b8f74f3b9492c3299b52898df1e0fc777021c285	0	2	\N	0	0	34	22
12	4	0	\\x927b448ee9d4a15a5ea11c4de48ee552fa3e371c0a19c01e45d28e6f6212426e	400000000	3	1	0.149999999999999994	390000000	39	15
13	2	0	\\x265b7e85d737edaa1eeb3effa3b8d994f26ae22e7b21fb1e2bbf3ecb36bc566c	500000000	3	\N	0.149999999999999994	390000000	44	13
14	9	0	\\xc5fba6a50bf972c8c73e871817a87d0a7d4dd7cfb299b041c9f98a0fd719f128	600000000	3	2	0.149999999999999994	390000000	49	20
15	6	0	\\x0e5ca4c18e299b8eb7e99982058adb1e190e08cbf4e61440b3c3d87ecb8d3492	420000000	3	3	0.149999999999999994	370000000	54	17
16	7	0	\\x0e39cf5cf296d28a333861798e5865b9794b42796d91bc31ef6297d2d8ff2a00	410000000	3	4	0.149999999999999994	390000000	59	18
17	5	0	\\xcc8b277cda6cc09005c45e06fbaafe68fac865adfd622858cb47b2446d787e98	410000000	3	5	0.149999999999999994	400000000	64	16
18	3	0	\\x05ace6cbd31b5fba7aae0fbe418a1faa2243cdd8fe719447c2bb3dd6c7b2ef82	410000000	3	6	0.149999999999999994	390000000	69	14
19	10	0	\\x2a54c79aaced460f8da56dcf23283b5aeab2e37d4280bff6f69cf844a8406c5b	500000000	3	\N	0.149999999999999994	380000000	74	21
20	11	0	\\x3b3187802eff459730a6ed16b8f74f3b9492c3299b52898df1e0fc777021c285	500000000	3	\N	0.149999999999999994	390000000	81	22
21	1	0	\\xb825aeca0448833d242faa4c7dccd80ed7975dc8a6313492d4ed8d8cc9d92514	400000000	3	7	0.149999999999999994	410000000	88	12
22	8	0	\\x5b586190b171b79c86d744ea82029968461292ca14ef94a1a2270eeedbed4bb5	400000000	4	8	0.149999999999999994	390000000	95	19
23	12	0	\\x2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	500000000000000	15	\N	0.200000000000000011	1000	356	48
24	13	0	\\x641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	50000000	15	\N	0.200000000000000011	1000	359	45
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
7	9	::
8	10	::
9	11	3:37:
10	12	4:38:
11	13	5:39:
12	14	::
13	15	6:40:
14	16	::
15	17	::
16	18	7:42:
17	19	::
18	20	8:43:
19	21	9:44:
20	22	::
21	23	10:45:
22	24	::
23	25	11:46:
24	26	12:48:
25	27	::
26	28	13:49:
27	29	::
28	30	14:50:
29	31	::
30	32	15:51:
31	33	16:52:
32	34	::
33	35	17:54:
34	36	18:55:
35	37	::
36	38	19:56:
37	39	::
38	40	20:57:
39	41	::
40	42	21:58:
41	43	::
42	44	22:60:
43	45	::
44	46	23:61:
45	47	24:62:
46	48	::
47	49	25:63:
48	50	::
49	51	26:64:
50	52	::
51	53	27:66:
52	54	::
53	55	28:67:
54	56	::
55	57	::
56	58	29:68:
57	59	30:69:
58	60	::
59	61	31:70:
60	62	::
61	63	32:72:
62	64	::
63	65	33:73:
64	66	34:74:
65	67	::
66	68	35:75:
67	69	36:76:
68	70	37:78:
69	71	::
70	72	38:79:
71	73	::
72	74	::
73	75	39:80:
74	76	40:81:
75	77	41:82:
76	78	::
77	79	42:83:
78	80	43:84:
79	81	::
80	82	::
81	83	44:86:
82	84	::
83	85	45:87:
84	86	46:88:
85	87	47:89:
86	88	48:90:
87	89	49:91:
88	90	50:92:
89	91	51:94:
90	92	52:95:
91	93	53:96:
92	94	::
93	95	::
94	96	54:97:
95	97	::
96	98	::
97	99	::
98	100	55:98:
99	101	56:99:
100	102	::
101	103	57:100:
102	104	::
103	105	::
104	106	58:102:
105	107	59:103:
106	108	::
107	109	60:104:
108	110	::
109	111	61:105:
110	112	62:106:
111	113	63:107:
112	114	::
113	115	64:108:
114	116	::
115	117	65:110:
116	118	::
117	119	66:111:
118	120	::
119	121	::
120	122	67:113:
121	123	68:115:
122	124	69:117:
123	125	70:119:
124	126	71:121:
125	127	::
126	128	72:123:
127	129	::
128	130	::
129	131	74:124:1
130	132	75:126:
131	133	::
132	134	76:132:5
133	135	77:134:8
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
394	396	::
395	397	::
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
424	426	78:136:9
425	427	::
426	428	::
427	429	::
428	430	79:138:12
429	431	::
430	432	::
431	433	::
432	434	81:140:14
433	435	::
434	436	::
435	437	::
436	438	83:142:17
437	439	::
438	440	::
439	441	::
440	442	84:144:20
441	443	::
442	444	::
443	445	::
444	446	86:146:
445	447	::
446	448	::
447	449	::
448	450	::
449	451	89:147:24
450	452	::
451	453	::
452	454	::
453	455	90:149:26
454	456	::
455	457	::
456	458	::
457	459	92:151:28
458	460	::
459	461	::
460	462	::
461	463	93:153:
462	464	::
463	465	::
464	466	::
465	467	94:154:
466	468	::
467	469	::
468	470	::
469	471	95:155:29
470	472	::
471	473	::
472	474	::
473	475	96:157:30
474	476	::
475	477	::
476	478	::
477	479	98:159:
478	480	::
479	481	::
480	482	::
481	483	100:160:32
482	484	::
483	485	::
484	486	::
485	487	101:162:
486	488	::
487	489	::
488	490	::
489	491	::
490	492	102:163:33
491	493	::
492	494	::
493	495	::
494	496	103:165:34
495	497	::
497	499	::
498	500	::
499	501	104:166:
500	502	::
501	503	::
502	504	::
503	505	105:167:
504	506	::
506	508	::
507	509	::
508	510	107:169:
509	511	::
510	512	::
511	513	::
512	514	108:204:
513	515	::
514	516	::
515	517	::
516	518	143:213:
517	519	::
518	520	::
519	521	::
520	522	144:214:35
521	523	::
522	524	::
523	525	::
524	526	145:216:
525	527	::
527	529	::
528	530	::
529	531	146:217:36
530	532	::
531	533	::
532	534	::
533	535	148:219:
534	536	::
535	537	::
536	538	::
537	539	149:220:
538	540	150:222:
539	541	::
540	542	::
541	543	::
542	544	::
543	545	156:226:
544	546	157:228:
545	547	160:230:
546	548	161::
547	549	::
548	550	162:232:
550	552	223:354:
551	553	::
552	554	283:356:
553	555	::
554	556	::
555	557	284:358:
556	558	::
557	559	285:359:
558	560	::
559	561	::
560	562	::
561	563	::
562	564	286:361:
563	565	::
564	566	::
565	567	::
566	568	287:363:
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
684	686	::
685	687	::
686	688	::
687	689	::
688	690	288:364:
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
879	881	::
880	882	::
881	883	::
882	884	::
883	885	::
884	886	::
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
951	953	426:564:
952	954	::
953	955	::
954	956	::
955	957	427:566:
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
1132	1134	553:580:
1133	1135	585:628:
1134	1136	605:652:
1135	1137	640:694:
1136	1138	671:736:
1137	1139	::
1138	1140	::
1139	1141	::
1140	1142	::
1141	1143	::
1142	1144	::
1143	1145	::
1144	1146	::
1145	1147	::
1146	1148	::
1147	1149	::
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
1308	1310	::
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
1324	1326	::
1325	1327	::
1326	1328	707:780:
1327	1329	::
1328	1330	::
1329	1331	::
1330	1332	::
1331	1333	::
1332	1334	::
1333	1335	708:782:
1334	1336	::
1335	1337	::
1336	1338	::
1337	1339	709:784:
1338	1340	::
1339	1341	::
1340	1342	::
1341	1343	710:786:
1342	1344	::
1343	1345	::
1344	1346	::
1345	1347	711:788:37
1346	1348	::
1347	1349	::
1348	1350	::
1349	1351	712:790:41
1350	1352	::
1351	1353	::
1352	1354	::
1353	1355	713:792:44
1354	1356	::
1355	1357	::
1356	1358	::
\.


--
-- Data for Name: reward; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward (id, addr_id, type, amount, earned_epoch, spendable_epoch, pool_id) FROM stdin;
1	1	member	6176494258427	1	3	5
2	9	member	7058850581060	1	3	2
3	10	member	7058850581060	1	3	9
4	2	member	7941206903692	1	3	4
5	8	member	4411781613162	1	3	7
6	7	member	10588275871590	1	3	3
7	3	member	7941206903692	1	3	10
8	11	member	12352988516855	1	3	11
9	5	member	8823563226325	1	3	8
10	6	member	5294137935795	1	3	1
11	4	member	10588275871590	1	3	6
12	19	leader	0	1	3	8
13	20	leader	0	1	3	9
14	22	leader	0	1	3	11
15	13	leader	0	1	3	2
16	17	leader	0	1	3	6
17	14	leader	0	1	3	3
18	15	leader	0	1	3	4
19	18	leader	0	1	3	7
20	16	leader	0	1	3	5
21	12	leader	0	1	3	1
22	21	leader	0	1	3	10
23	1	member	8647972871698	2	4	5
24	20	member	375813	2	4	9
25	22	member	845579	2	4	11
26	9	member	9512769642118	2	4	2
27	13	member	1550229	2	4	2
28	17	member	1056974	2	4	6
29	14	member	939532	2	4	3
30	10	member	6918379424798	2	4	9
31	15	member	822091	2	4	4
32	2	member	6053581010189	2	4	4
33	18	member	1056974	2	4	7
35	8	member	7783175584529	2	4	7
36	7	member	6918378297359	2	4	3
37	16	member	1174416	2	4	5
38	3	member	7783176430484	2	4	10
39	11	member	10377568573979	2	4	11
40	12	member	1174416	2	4	1
41	5	member	4323987609826	2	4	8
42	6	member	8647972871699	2	4	1
43	21	member	634184	2	4	10
44	4	member	7783175584529	2	4	6
45	19	leader	0	2	4	8
46	20	leader	0	2	4	9
47	22	leader	0	2	4	11
48	13	leader	0	2	4	2
49	17	leader	0	2	4	6
50	14	leader	0	2	4	3
51	15	leader	0	2	4	4
52	18	leader	0	2	4	7
53	16	leader	0	2	4	5
54	12	leader	0	2	4	1
55	21	leader	0	2	4	10
56	19	member	950790	3	5	8
57	1	member	2644585570044	3	5	5
58	9	member	4628287996117	3	5	2
59	2	member	12563064957540	3	5	4
60	8	member	6611982425042	3	5	7
61	7	member	10579370780041	3	5	3
62	5	member	7001273567987	3	5	8
63	6	member	6611965425368	3	5	1
64	4	member	6611999425040	3	5	6
65	19	leader	0	3	5	8
66	20	leader	0	3	5	9
67	22	leader	0	3	5	11
68	13	leader	817147592537	3	5	2
69	17	leader	1167194484331	3	5	6
70	14	leader	1867339474953	3	5	3
71	15	leader	2217403470266	3	5	4
72	18	leader	1167211484329	3	5	7
73	16	leader	467091993703	3	5	5
74	12	leader	1167228484384	3	5	1
75	21	leader	0	3	5	10
76	12	refund	0	5	5	1
77	21	refund	0	5	5	10
78	1	member	8415399018991	4	6	5
79	9	member	7011106476021	4	6	2
80	2	member	7710406331987	4	6	4
81	8	member	1402963148913	4	6	7
82	7	member	3502036700703	4	6	3
83	5	member	9110180009831	4	6	8
84	6	member	1402610329116	4	6	1
85	4	member	9806316461888	4	6	6
86	19	leader	1608070277296	4	6	8
87	20	leader	0	4	6	9
88	22	leader	0	4	6	11
89	13	leader	1237645425608	4	6	2
90	17	leader	1730897996689	4	6	6
91	14	leader	618397034502	4	6	3
92	15	leader	1361051170160	4	6	4
93	18	leader	247971956040	4	6	7
94	16	leader	1485471757372	4	6	5
95	12	leader	247929693614	4	6	1
96	21	leader	0	4	6	10
97	1	member	4177295565825	5	7	5
98	9	member	4175330286541	5	7	2
99	2	member	4178241910741	5	7	4
100	8	member	7664118942405	5	7	7
101	7	member	5565810609361	5	7	3
102	5	member	5572377217897	5	7	8
103	6	member	7660478609729	5	7	1
104	4	member	4173316405427	5	7	6
105	19	leader	983751572628	5	7	8
106	20	leader	0	5	7	9
107	22	leader	0	5	7	11
108	13	leader	737213790713	5	7	2
109	17	leader	736838265810	5	7	6
110	14	leader	982592758931	5	7	3
111	15	leader	737727473891	5	7	4
112	18	leader	1352882801087	5	7	7
113	16	leader	737570472015	5	7	5
114	12	leader	1352260388565	5	7	1
115	21	leader	0	5	7	10
116	1	member	3432310931549	6	8	5
117	54	member	479686	6	8	4
118	9	member	5485340498747	6	8	2
119	53	member	185362	6	8	7
120	2	member	8894294440930	6	8	4
121	51	member	220904	6	8	3
122	8	member	3429780588724	6	8	7
123	7	member	4103965621335	6	8	3
124	52	member	369509	6	8	6
125	5	member	4803113786207	6	8	8
126	6	member	5485243107259	6	8	1
127	4	member	6848485884678	6	8	6
128	19	leader	847999079869	6	8	8
129	20	leader	0	6	8	9
130	22	leader	0	6	8	11
131	13	leader	969816376263	6	8	2
132	17	leader	1211464481355	6	8	6
133	14	leader	727050136986	6	8	3
134	15	leader	1576229687909	6	8	4
135	18	leader	606918664829	6	8	7
136	16	leader	606612337483	6	8	5
137	12	leader	970429428131	6	8	1
138	21	leader	0	6	8	10
139	1	member	7966754810520	7	9	5
140	9	member	3980501056293	7	9	2
141	2	member	6452699288169	7	9	4
142	51	member	1199928	7	9	3
143	8	member	5487025291151	7	9	7
144	7	member	8922302397605	7	9	3
145	5	member	3980336071040	7	9	8
146	55	member	1200995	7	9	3
147	46	member	12011133776	7	9	3
148	4	member	5461175049358	7	9	6
149	19	leader	704831991174	7	9	8
150	20	leader	0	7	9	9
151	22	leader	0	7	9	11
152	13	leader	705425761437	7	9	2
153	17	leader	969117581160	7	9	6
154	14	leader	1584061929803	7	9	3
155	15	leader	1146412911859	7	9	4
156	18	leader	971157147134	7	9	7
157	16	leader	1411235034875	7	9	5
158	1	member	6212427621956	8	10	5
159	9	member	7760348714572	8	10	2
160	2	member	7741386378091	8	10	4
161	51	member	899245	8	10	3
162	8	member	4661792457704	8	10	7
163	7	member	6696539759009	8	10	3
164	5	member	5170613734487	8	10	8
165	55	member	900045	8	10	3
166	46	member	9001337915	8	10	3
167	4	member	4129540294429	8	10	6
168	19	leader	917094126152	8	10	8
169	20	leader	0	8	10	9
170	22	leader	0	8	10	11
171	13	leader	1376727764961	8	10	2
172	17	leader	733859245462	8	10	6
173	14	leader	1191069480130	8	10	3
174	15	leader	1377084602137	8	10	4
175	18	leader	827152346512	8	10	7
176	16	leader	1102008651836	8	10	5
177	1	member	8021275203606	9	11	5
178	54	member	479	9	11	3
179	9	member	8543870777821	9	11	2
180	53	member	185	9	11	3
181	2	member	6916343685580	9	11	4
182	51	member	499680	9	11	3
183	8	member	4815268967781	9	11	7
184	7	member	3723498788378	9	11	3
185	52	member	369	9	11	3
186	5	member	5338193730439	9	11	8
187	55	member	499903	9	11	3
188	46	member	4999509221	9	11	3
189	4	member	5325364442735	9	11	6
190	19	leader	948229986534	9	11	8
191	20	leader	0	9	11	9
192	22	leader	0	9	11	11
193	13	leader	1518298995873	9	11	2
194	17	leader	948286513902	9	11	6
195	14	leader	663297354747	9	11	3
196	15	leader	1233779337001	9	11	4
197	18	leader	855293246286	9	11	7
198	16	leader	1424294075202	9	11	5
199	1	member	5835491315419	10	12	5
200	54	member	745	10	12	3
201	9	member	5386720302958	10	12	2
202	53	member	288	10	12	3
203	2	member	7149663482703	10	12	4
204	51	member	778744	10	12	3
205	8	member	6293505757590	10	12	7
206	7	member	5802988880654	10	12	3
207	52	member	574	10	12	3
208	5	member	4936322666218	10	12	8
209	55	member	779093	10	12	3
210	46	member	7791670931	10	12	3
211	4	member	5369301109589	10	12	6
212	19	leader	877967490233	10	12	8
213	20	leader	0	10	12	9
214	22	leader	0	10	12	11
215	13	leader	958591539367	10	12	2
216	17	leader	957735098377	10	12	6
217	14	leader	1036395542396	10	12	3
218	15	leader	1277945566257	10	12	4
219	18	leader	1119663266565	10	12	7
220	16	leader	1038874467630	10	12	5
221	1	member	3577802726523	11	13	5
222	54	member	718	11	13	3
223	9	member	8173893282984	11	13	2
224	53	member	277	11	13	3
225	2	member	4068221051496	11	13	4
226	51	member	751191	11	13	3
227	8	member	8194699621913	11	13	7
228	7	member	5597669131057	11	13	3
229	52	member	553	11	13	3
230	5	member	5623044738018	11	13	8
231	55	member	751529	11	13	3
232	64	member	4779264674	11	13	6
233	46	member	3764739267	11	13	3
234	4	member	7128850508915	11	13	6
235	19	leader	1001668716952	11	13	8
236	20	leader	0	11	13	9
237	22	leader	0	11	13	11
238	13	leader	1457903935836	11	13	2
239	17	leader	1273944739514	11	13	6
240	14	leader	1001157626430	11	13	3
241	15	leader	729072339382	11	13	4
242	18	leader	1459910190818	11	13	7
243	16	leader	638334790233	11	13	5
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
5	107	\\x0bfbec825e34b44b8c2cbbfbd4a9d52526d77106333a1135a323189a	timelock	{"type": "sig", "keyHash": "fe1002799671620ea8f6b862c5f6cbae7681269fa702aa56e3155e84"}	\N	\N
6	109	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	timelock	{"type": "sig", "keyHash": "5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967"}	\N	\N
7	111	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}]}	\N	\N
8	136	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}, {"type": "sig", "keyHash": "3178bf14adf78294ac2d03d60b9edfb7323d3d719e98b4b0b3ca34cd"}]}	\N	\N
\.


--
-- Data for Name: slot_leader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slot_leader (id, hash, pool_hash_id, description) FROM stdin;
1	\\x73f305ee8305acf6f0571b87718af520cd0b3fa3bcdc664ec80d52ee	\N	Genesis slot leader
2	\\x5368656c6c65792047656e6573697320536c6f744c65616465722048	\N	Shelley Genesis slot leader
5	\\xf9583ec8e04bdf554e923c27f8f29f41d9f4896f1604d769df13228f	11	Pool-f9583ec8e04bdf55
46	\\x4fe592360963b32969f3879523d2244262c59bb928c8708782434d67	4	Pool-4fe592360963b329
12	\\xc1b652054e8ad1edb3284c3856f92d5a9ef5a6b07c5f1b0f03955d79	10	Pool-c1b652054e8ad1ed
15	\\x8a4244fd87e38f181915834328e91e4ee206c1422c473fe3ab9f4e7f	8	Pool-8a4244fd87e38f18
30	\\xbd2e89744da6e4127d5af3cfd47b33abb313e242e315e7171e9990c6	9	Pool-bd2e89744da6e412
28	\\x833b046b58fb26a1a5e1b89441af01bdab84073894320de2d4d29ca5	7	Pool-833b046b58fb26a1
6	\\x5886e5b26784071e84af8705cb1461fb2be67ae6e43699b4631de0cc	5	Pool-5886e5b26784071e
27	\\x311a76aa43883b855135f885b057bc99040c2de70abd4879311303f2	3	Pool-311a76aa43883b85
3	\\x2a688f6bcdaca28fc9dd3090aa6b0655734b35db4401b8258fd274d6	2	Pool-2a688f6bcdaca28f
8	\\x6943b0ddd6b64586dfb53805246923f1ea6e80a4eb55ffc9f776061f	6	Pool-6943b0ddd6b64586
4	\\x280ccdd73caed5cc7418329da0bcedf408afc97d396809b32add237c	1	Pool-280ccdd73caed5cc
\.


--
-- Data for Name: stake_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_address (id, hash_raw, view, script_hash) FROM stdin;
1	\\xe00ec2d2899deadd95421486efd2a6f509f3a50d805c3b980a124b6d67	stake_test1uq8v955fnh4dm92zzjrwl54x75yl8fgdspwrhxq2zf9k6ech7x5ma	\N
9	\\xe01ce761550b826638b2d31a911b27df7716261c11f84e0bdd156c5215	stake_test1uqwwwc24pwpxvw9j6vdfzxe8mam3vfsuz8uyuz7az4k9y9gj6wmwd	\N
10	\\xe0358d59c4a620040a70bbc840c0e03a23d79b1819b751795f5b8b2b02	stake_test1uq6c6kwy5csqgznsh0yyps8q8g3a0xccrxm4z72ltw9jkqs9hnwyh	\N
2	\\xe071349289bc61d400ff28b5ce2524b9d2d5cc19b2da088ec97ccbed0d	stake_test1upcnfy5fh3sagq8l9z6uuffyh8fdtnqektdq3rkf0n976rgz8x6xx	\N
8	\\xe08414d83ee06ba6bdd640bc3f9ac482dd414f773793147e24bcbd0d8e	stake_test1uzzpfkp7up46d0wkgz7rlxkystw5znmhx7f3gl3yhj7smrsutu7wc	\N
7	\\xe08a794d71a51a28dff115d93944cf8825f33459730e326eb9f58d8886	stake_test1uz98jnt355dz3hl3zhvnj3x03qjlxdzewv8rym4e7kxc3pss22cqr	\N
3	\\xe097cc8a2bfd700ef5cbc0ad0750756f1b87cc5de0371e96fd162be466	stake_test1uztuez3tl4cqaawtczksw5r4dudc0nzauqm3a9hazc47gesaz9alr	\N
11	\\xe09a898c98d755481041ecc7ee8b65748b5be565b3993b066684bc5ab1	stake_test1uzdgnryc6a25syzpanr7azm9wj94het9kwvnkpnxsj794vgj7csr5	\N
5	\\xe0a20fed6323c99cf189200fbbb17de101a80082cafb77fb76261e3dce	stake_test1uz3qlmtry0yeeuvfyq8mhvtauyq6sqyzetah07mkyc0rmnsw4h6ea	\N
6	\\xe0ae26027659a6d7364d3113a48ce84d4eccfcff518f666be08ecd43df	stake_test1uzhzvqnktxndwdjdxyf6fr8gf48vel8l2x8kv6lq3mx58hccfnrmf	\N
4	\\xe0fa92b1e92f3d2bacfdf3693ba873e52f73514ea433d8b0b47508eebc	stake_test1uraf9v0f9u7jht8a7d5nh2rnu5hhx52w5sea3v95w5ywa0qqhss63	\N
15	\\xe047fbb06e348ecccfff742410177cd28a07856bf419c043a1195eef37	stake_test1uprlhvrwxj8venllwsjpq9mu629q0ptt7svuqsapr90w7dcsq97ms	\N
13	\\xe01f9b0a7b00487e83c63af90e81e4e32456001e1f3cb771c1d6c009c9	stake_test1uq0ekznmqpy8aq7x8tusaq0yuvj9vqq7ru7twuwp6mqqnjgdcrhtd	\N
20	\\xe0162fa55808616577c8f497282f98bb9f4d39d9ac5072074586ce9ed1	stake_test1uqtzlf2cppsk2a7g7jtjstuchw056wwe43g8yp69sm8fa5gdytksp	\N
17	\\xe02c674af91e82b151d926a02b047853b607f93647bb7d829c143650a4	stake_test1uqkxwjher6ptz5wey6szkprc2wmq07fkg7ahmq5uzsm9pfqmrs64k	\N
18	\\xe0728790d0a96ed80d19dc864825126e1fd4d5929975ad545722a8f9bb	stake_test1upeg0yxs49hdsrgemjrysfgjdc0af4vjn96664zhy250nwcd5gtkg	\N
16	\\xe08cd0fba2c36ff35a201a47d8ce1f98bc0a17516bef539bd4241b25a6	stake_test1uzxdp7azcdhlxk3qrfra3nslnz7q5963d0h48x75ysdjtfs79jugv	\N
14	\\xe02fde570ec198673d4ea4228ee44f42a28ee465c3c06bfa7c286a9c78	stake_test1uqhau4cwcxvxw02w5s3gaez0g23gaer9c0qxh7nu9p4fc7q5n53vm	\N
21	\\xe0b6e04d2bdeafb23216698e2011996dc9c0d80b58ad32cc32270015fc	stake_test1uzmwqnftm6hmyvskdx8zqyvedhyupkqttzkn9npjyuqptlqmd4k6s	\N
22	\\xe0180090fd83c312e4681474a9661e86db8a9c5a28dd06316cc67a1640	stake_test1uqvqpy8as0p39ergz362jes7smdc48z69rwsvvtvceapvsqflc0px	\N
12	\\xe09d223d7d6d02ab8c6a2113d20d99d5b175774ac3ae6aeb290393e7ac	stake_test1uzwjy0tad5p2hrr2yyfayrve6kch2a62cwhx46efqwf70tqghhfgl	\N
19	\\xe00daf3aa09eb42bcbc5d48a254bbb1fd94cfd02116ca96e044f28345c	stake_test1uqx67w4qn66zhj796j9z2jamrlv5elgzz9k2jmsyfu5rghq7mpet7	\N
47	\\xe01bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	stake_test1uqdlrcfc7tuta27fv0y5es5wark5kst5gcql9md02zepalg9yxxuz	\N
49	\\xe09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j	\N
50	\\xe07d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	stake_test1up73dx2qeg7gv59739gpmycmxzffyqk3ha2ctmh9ghdgneqmy000q	\N
51	\\xe072263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	stake_test1upezv0agh8cq09rt33ardnh8pdstd3lwpa5s64g2pne0uqgcygw6k	\N
52	\\xe08de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	stake_test1uzx79ge8d7gkx27vu3k9xgj9zlra0fvat5d5lxcnzm9n7hc8yk6td	\N
53	\\xe04f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	stake_test1up85ec98csnkgus5dw3x8u25mlkgu8m63hvw650ukldv04q6rf54k	\N
54	\\xe00ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	stake_test1uq8lxxfr92332xgqp66eenhpw7z04q09czgjf6uvnku20fq023mfy	\N
55	\\xe0ce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	stake_test1ur89gkdpkj42jwy3smuznfxcjdas0jz64xtckt9s8kz8h3gj4h8zv	\N
61	\\xe0e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	stake_test1urnf9ezryv9wyusynq2sal9frh6gduzq4xsa50ymmxqgrkgaazads	\N
46	\\xe0f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	stake_test1urc4mvzl2cp4gedl3yq2px7659krmzuzgnl2dpjjgsydmqqxgamj7	\N
64	\\xe0f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	stake_test1urcqjef42euycw37mup524mf4j5wqlwylwwm9wzjp4v42ksjgsgcy	\N
48	\\xe0e0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	\N
45	\\xe0a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	\N
\.


--
-- Data for Name: stake_deregistration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_deregistration (id, addr_id, cert_index, epoch_no, tx_id, redeemer_id) FROM stdin;
1	46	0	5	149	\N
\.


--
-- Data for Name: stake_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_registration (id, addr_id, cert_index, epoch_no, tx_id) FROM stdin;
1	1	0	0	34
2	9	2	0	34
3	10	4	0	34
4	2	6	0	34
5	8	8	0	34
6	7	10	0	34
7	3	12	0	34
8	11	14	0	34
9	5	16	0	34
10	6	18	0	34
11	4	20	0	34
12	15	0	0	36
13	13	0	0	41
14	20	0	0	46
15	17	0	0	51
16	18	0	0	56
17	16	0	0	61
18	14	0	0	66
19	21	0	0	71
20	22	0	0	78
21	12	0	0	85
22	19	0	1	92
23	51	0	4	131
24	52	2	4	131
25	53	4	4	131
26	54	6	4	131
27	55	8	4	131
28	46	0	5	148
29	46	0	5	152
30	64	0	9	254
31	48	0	13	357
32	45	0	13	360
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
1	\\xdb0530fcc208cc40f9ed09f4b8a2ac0246a1fef46f95f68a662404ae7f392215	1	0	910909092	0	0	0	\N	\N	t	0
2	\\x0c0190b9dc46495e740b032d7f5136816bed492191f5f742b58488f19632fe1b	1	0	910909092	0	0	0	\N	\N	t	0
3	\\xec89b4ee40176cfb716165ea56fe5dbba967b26256659e1a88bde5adadd29fc5	1	0	910909092	0	0	0	\N	\N	t	0
4	\\x76d899ed8f387429430f889f4fe325131de6d998e5f348071c5a46cbf65e4909	1	0	910909092	0	0	0	\N	\N	t	0
5	\\xfd60cddf282314e2eef54fce76a19f9dd56b9fa6d97622bf6e0834150d5a8c0c	1	0	910909092	0	0	0	\N	\N	t	0
6	\\x2bf73be738943c3b55379b86729a1bc301e13f5e6e1a1dfc2ac66c7bf5b5061b	1	0	910909092	0	0	0	\N	\N	t	0
7	\\x642e6180359bc2fec7b1043122fc8c5d57003edde82c22b5be5ec6b232494a8a	1	0	910909092	0	0	0	\N	\N	t	0
8	\\x5ea46b1de75e3a2c09c76fc8b460d7afd600a5f8e1b51422914a985b830508be	1	0	910909092	0	0	0	\N	\N	t	0
9	\\xa981f22da43885f2df6f2222673a7d8ef00310e5db09c81b86db6e0a6c966deb	1	0	910909092	0	0	0	\N	\N	t	0
10	\\x017b1fa9cb8b47adc1e0fd31401279aa4a745cdf2a0c4cfb85b5523ab0eec6d9	1	0	910909092	0	0	0	\N	\N	t	0
11	\\x9e8b883f6083a7c9b94888beb40c8c22371b62c21e453e808652d593a2d96d9f	1	0	910909092	0	0	0	\N	\N	t	0
12	\\x14ff9320c538ec5d7efd5920396e5b77cb1582327867490fc69e48b2c9ab7c5f	2	0	3681818181818181	0	0	0	\N	\N	t	0
13	\\x2e15f8259a8c05628806e57f750f7209ddf06696419fb37223388a2b196c4cfc	2	0	3681818181818181	0	0	0	\N	\N	t	0
14	\\x2e217247514a5f4170d055454810dd0321f72cf9aceb3e18d4576fed9d7d41a6	2	0	3681818181818190	0	0	0	\N	\N	t	0
15	\\x325c64b1a2d07bcbba1f8311cac45be84f506c46136e3738db26ba37e9be5969	2	0	3681818181818181	0	0	0	\N	\N	t	0
16	\\x55c8641b2e964feeee5eb62de06c6934d39bccc23e3db9de89b6584bcc3c750b	2	0	3681818181818181	0	0	0	\N	\N	t	0
17	\\x60f6800a4a4409da8b76447f0fc8b192564c4bf157f9098e08b7f18e56a261ad	2	0	3681818181818181	0	0	0	\N	\N	t	0
18	\\x668d61804f022cd64f752fab6327b0db479184b5aceb8c6f672ab8a19418e358	2	0	3681818181818181	0	0	0	\N	\N	t	0
19	\\x697bf3cd8a19ad3f33ba7f95cb81434e6e47379f9e2567d2bba4503b8c44b4a1	2	0	3681818181818190	0	0	0	\N	\N	t	0
20	\\x7d2c15c8561607a360900b4d7bd1734b9a3732331849701fdb2cce18130d1c7e	2	0	3681818181818181	0	0	0	\N	\N	t	0
21	\\x8a14958c01184ed4881dfa4b8b8ed470c410698560cd792e1e09ad2e176ac633	2	0	3681818181818181	0	0	0	\N	\N	t	0
22	\\x99a7351d4aaa703cc4c1e097d46f637d063b2a4a73275e40e25b9998fa6cbff0	2	0	3681818181818181	0	0	0	\N	\N	t	0
23	\\xb62b17caf50ebb7460f70e2f59a08c777b41673ffe2159077db21a8dda939a15	2	0	3681818181818181	0	0	0	\N	\N	t	0
24	\\xc06c54fbee952f9f87eb2e82fea26a0fd9dfb9e0d18b7250ef510fb4444e934f	2	0	3681818181818181	0	0	0	\N	\N	t	0
25	\\xc17b20f07e10d8ce0abaffa42486db5c51c29382b2e0d0767a5a24dd9dbc5562	2	0	3681818181818181	0	0	0	\N	\N	t	0
26	\\xc25a881b1eb729ea27edce3aa2ff4490f65b5d50ccf4f902436a8fcfddd70725	2	0	3681818181818181	0	0	0	\N	\N	t	0
27	\\xd18ca74014c26460c0f5644be77cc0cc6fcf0dfa3bb79565c431ef619977afdc	2	0	3681818181818181	0	0	0	\N	\N	t	0
28	\\xd9bae7f080b3afd46ef9b152037c80c66c92765460d984bfef573b937ee88304	2	0	3681818181818181	0	0	0	\N	\N	t	0
29	\\xda3fadf6d6cc3c208520ddebab9ec4a6b8121502bbc2011b3810e67dcb061714	2	0	3681818181818181	0	0	0	\N	\N	t	0
30	\\xe6b47cd67b04d3ff08290214bd2ba24261569af3081e427be21d314d0c996344	2	0	3681818181818181	0	0	0	\N	\N	t	0
31	\\xf116b6ff460e8b4d815fbfca40e83f111d4752236c6fcc0540ed70b628e370e5	2	0	3681818181818181	0	0	0	\N	\N	t	0
32	\\xf2920f3142ac06d54a08d6a9485ac2defe6cf5b510fb311d0a9da0f36abb576f	2	0	3681818181818181	0	0	0	\N	\N	t	0
33	\\xfcd2922d6b70a82f2a42e8070fae0914f3ad7ff829faa711846342f3af671259	2	0	3681818181818181	0	0	0	\N	\N	t	0
34	\\x5368656c6c65792047656e65736973205374616b696e67205478204861736820	2	0	0	0	0	0	\N	\N	t	0
35	\\xf9a2ed63af885b11272099d68d576b17bc367016702efeb85c8c9d9d10c2e9fa	5	0	3681818181651228	166953	0	263	\N	\N	t	0
36	\\x31085f0dde78c589942194186c9f7d9e656cbf9071a82554174bcf1702ed540e	7	0	3681817681473231	177997	0	339	\N	5000000	t	0
37	\\x7af5e3b739ec445810c0aa3c304cd7e0ebfd9ab455718f8a5bddb00f1b40b72a	11	0	3681817681293914	179317	0	369	\N	5000000	t	0
38	\\xd2a79ca50219ef13a39629c75736b7d805dcb48e1556e874bfef40dd29dcde08	12	0	3681818181637632	180549	0	397	\N	5000000	t	0
39	\\xd15b657d090ade3c5686f3f3e0036a805d7025cb232e76c4128ae8275f953c56	13	0	3681818181443619	194013	0	653	\N	500000	t	0
40	\\x7bb43a03bf35d4b822a99f28a2d53dee07648051247af979d664cb5011a7f85a	15	0	3681817681126961	166953	0	263	\N	\N	t	0
41	\\xae88455b995c4a536b3a94a977587fd74a237e280bcbea4e421f9bfd9785e1ff	18	0	3681817080948964	177997	0	339	\N	5000000	t	0
42	\\x76bf5c31e3af89a4cd31df8e9e02c09a9cc467e05dee380a22ce50aba1861f8d	20	0	3681817080769647	179317	0	369	\N	5000000	t	0
43	\\xccdcb830a16b73426d685deedd1d58ec3edd7cac54700f7da17cb699a5aef99e	21	0	3681818181637632	180549	0	397	\N	5000000	t	0
44	\\x190e421da565cc8f65fe7b79c47f2b84af482dd3d75e24ad2764e10959091f4e	23	0	3681818181446391	191241	0	590	\N	500000	t	0
45	\\x949cf7e9f76e50be65d95a9bfa4127303a2497d92ddae5e724083c51815776b6	25	0	3681817080602694	166953	0	263	\N	\N	t	0
46	\\x847d63e3a36b77884086f293ff042ffac86fbb1b894ae79384f5726eaf856b40	26	0	3681816880424697	177997	0	339	\N	5000000	t	0
47	\\xc1c6a7559fe3e725e3e2310ec33d09d57937f27f87e15a6fea0861f2df561f91	28	0	3681816880245380	179317	0	369	\N	5000000	t	0
48	\\x065c290aaefa541c2096e7b2f60a69fc6fea95dddeb28a728c085b3927e8bcad	30	0	3681818181637632	180549	0	397	\N	5000000	t	0
49	\\xb1f5e2a7462f6e6b73b2b953762c34cf8cc68c0b20a512e2e39cfd74162bcdd2	32	0	3681818181443619	194013	0	653	\N	500000	t	0
50	\\x185cbbdfa1e5ec7dc3129b4f9b4d075a5834f53a15e2e33a02c48cb22eb90d1b	33	0	3681816880078427	166953	0	263	\N	\N	t	0
51	\\x8099261a7b162835bfb81850db4befe3b5070dd93cc496bfcfb52ac622287ac4	35	0	3681816379900430	177997	0	339	\N	5000000	t	0
52	\\x4955e722d17997817855df2098af1272f2ae80923bfb7a2093937f8d4ef544bd	36	0	3681816379721113	179317	0	369	\N	5000000	t	0
53	\\x974b99595b50200b4b2ae53bfe7ab8652325098bb2a29a11aaedf1b70041ec22	38	0	3681818181637632	180549	0	397	\N	5000000	t	0
54	\\x1be82747bccd36a4e7012e3518c195bd483b0177dcdd8478a58e31cd072274fb	40	0	3681818181443619	194013	0	653	\N	500000	t	0
55	\\x766e3fe9fa1af99d8fa2d61fc4b729d4d2781564b76138e64bd4e8bdbef783ae	42	0	3681816379554160	166953	0	263	\N	\N	t	0
56	\\x51afc17fccf5b1ecc9252fdf7498c0c4b4d7e44bba265d561135bb5905cf9899	44	0	3681815879376163	177997	0	339	\N	5000000	t	0
57	\\x5bb7ae8e679e38f486b3fa5b29136b3a2c66c297f8c6ce1db69c6e664c1066a3	46	0	3681815879196846	179317	0	369	\N	5000000	t	0
58	\\xfd119a96d154c4dc5f5e63f0f1e013aed08f4d17df3b933d4fd4b383fbc4391a	47	0	3681818181637632	180549	0	397	\N	5000000	t	0
59	\\xae3522bd15cd871fc521e16202b1790fcfa340baa499887f30690690a5681a8e	49	0	3681818181443619	194013	0	653	\N	500000	t	0
60	\\x301157360c14ba402886a897d65546073cb1e9a26d2f7f646ff2570eee7df8ae	51	0	3681815879029893	166953	0	263	\N	\N	t	0
61	\\xd8f96c8f3667dee6ee026baa61421fcca3397e2ad2fd76e87f357a43fe591a1c	53	0	3681815378851896	177997	0	339	\N	5000000	t	0
62	\\xd10645f65cc5a0baff47032427d645851b96a7de8f37d69874f906c22480c934	55	0	3681815378672579	179317	0	369	\N	5000000	t	0
63	\\xa3bb80f1c51547138824985425898827d66de6eab2a592cdd2607a171bb9f3d2	58	0	3681818181637632	180549	0	397	\N	5000000	t	0
64	\\xf5f0c4ca4f2d5cbccd79c6ff1fbc4756b948955e91e08ce3b56a108da942bf49	59	0	3681818181443619	194013	0	653	\N	500000	t	0
65	\\x92ac27a10da9a12b08ffdabfb77df684db0cc63fca9489b1284b1283c209387d	61	0	3681815378505626	166953	0	263	\N	\N	t	0
66	\\xa832f152beb491fabb9b7d82311b6604b46defb998670bd4d964246a13467f02	63	0	3681814878327629	177997	0	339	\N	5000000	t	0
67	\\xff91ab80727156a8d56fcd9a80acfa0763e88b846847c85ef43f061715a22fe3	65	0	3681814878148312	179317	0	369	\N	5000000	t	0
68	\\x0673fa6a8d81bf8a1a226d7e9ed7cb2abe795a483a5660ababf98a8535655127	66	0	3681818181637632	180549	0	397	\N	5000000	t	0
69	\\x402a45cdc43b5b657ac3aaab0f7a3dd122649afc2e712a3204327fa84d387a20	68	0	3681818181443619	194013	0	653	\N	500000	t	0
70	\\x8b59832c864c55bcfb466d65845baa344927d616bf263633aa8e1c8b5fa8328d	69	0	3681814877981359	166953	0	263	\N	\N	t	0
71	\\x1f361be6552405c440601705f3eadda5f4f693f0efb90aecdd8ac41d159bb80f	70	0	3681814577803362	177997	0	339	\N	5000000	t	0
72	\\x9e7811e04b3eed47d781c155941dca989b6d2bc214bf2bf72c07243c0f3ab71b	72	0	3681814577624045	179317	0	369	\N	5000000	t	0
73	\\x0c05321b0f5e53fa895f937f218068da084dfc1771bab1f4776989bc235d8ff9	75	0	3681818181637632	180549	0	397	\N	5000000	t	0
74	\\x0e5067e74cb677ffc01bc4da95ffce9259d7f53f7d979f0714ffd2c827b7eb50	76	0	3681818181446391	191241	0	590	\N	500000	t	0
75	\\x6b64a64f471163bb72d8e5bd129d2037170044639dd0f423ad26e6f7726a0506	77	0	3681818181265842	180549	0	397	\N	5000000	t	0
76	\\x3717c75372cd8caa565d580400edfcf08201a5e1901d9ea65a6387cd25d01759	79	0	3681814577439800	184245	0	439	\N	500000	t	0
77	\\x00eb4d2c9a424542533f676814099e7859af2cf447818862bc9838081ab73008	80	0	3681814577272847	166953	0	263	\N	\N	t	0
78	\\x967468ca5c8732f903e5d1aa71e90978efbd92d8764436716942d05c2611b8a3	83	0	3681814277094850	177997	0	339	\N	5000000	t	0
79	\\xf3cc51fe8121c2e52b8097ff9099e51d57d6e505d4d0e88865751705fb31e2ac	85	0	3681814276915533	179317	0	369	\N	5000000	t	0
80	\\xba7f7945fb6d5be727c953b7d5fecfe194bd5c10f189db5c2c09edb7f7108c75	86	0	3681818181637632	180549	0	397	\N	5000000	t	0
81	\\xaf378eea3f1832e04761237418cf4fc7801c804e0f4895d40845e05ca69d2b34	87	0	3681818181446391	191241	0	590	\N	500000	t	0
82	\\x1bc782ee532a09490d021e0942c6a12e39c9f7c2853f1ba22c71693588183d26	88	0	3681818181265842	180549	0	397	\N	5000000	t	0
83	\\xe35be9e8caa8a858b94b81174f01ebc70ae61e3a087a1887b1bc9bd07d14e2cf	89	0	3681814276731288	184245	0	439	\N	500000	t	0
84	\\x98ee22f7034e2c85a31d2158ec5a14c9848be52706ac49809b28ea494833c236	90	0	3681814276564335	166953	0	263	\N	\N	t	0
85	\\xadeffd755672c8d8d334bd41444b5234715a9ccb6ec015574435acca4ecb7a22	91	0	3681813776386338	177997	0	339	\N	5000000	t	0
86	\\x612ff22d4be1dd865570159a4d80c840e10d7cdbc54d5693443c48ae045a1449	92	0	3681813776207021	179317	0	369	\N	5000000	t	0
87	\\xba17b06938d46ed447865d8ffef31ead8c7c6f9c2cbddf7ce6d09b2b310b86e4	93	0	3681818181637632	180549	0	397	\N	5000000	t	0
88	\\x8ddb40454179e4e5f4d55eeeb0ade5185fb55da26f920ebc32ff9d3799729d86	96	0	3681818181443575	194057	0	654	\N	500000	t	0
89	\\xdc92742f43171f79f61478f4a2b183ed4fbbc707e9db323b9403db2594e29a29	100	0	3681818181263026	180549	0	397	\N	5000000	t	0
90	\\x3f587a5d0bf607e17c9277ea06fdbb2bb50affec239b1e57128040626c4aee8d	101	0	3681813776022776	184245	0	439	\N	500000	t	0
91	\\x9d69b452b5e06a144fd83b2b324c2e4d1decfc047731f43a3612ddff9c94a442	103	0	3681813775855823	166953	0	263	\N	\N	t	0
92	\\xd21fef852a588de3429570afd14c47cc2b50816f25189d8bf760a28a494e3041	106	0	3681813275677826	177997	0	339	\N	5000000	t	0
93	\\xebf5ba872dcb06541d2967846f09a1d498257e3061ad67780d24153768bafda0	107	0	3681813275498509	179317	0	369	\N	5000000	t	0
94	\\x3978ee55e5022b681f1fe8ad68a8dc5e377893368b7d1b5e5786479737906762	109	0	3681818181637641	180549	0	397	\N	5000000	t	0
95	\\xfefc784c1fbe180be2ce736b6adc551f619f737194411aa071c18aa1c26d5f7c	111	0	3681818181443584	194057	0	654	\N	500000	t	0
96	\\x9b2565e67b5d163662c2fdad1da95ad57a8209966a447a353526a8ce62a82819	112	0	3681818181263035	180549	0	397	\N	5000000	t	0
97	\\xaf331ae2657dc3adb634d4d6579c48a015e9c4ca6365e7959b382b7bb536d713	113	0	3681813275314264	184245	0	439	\N	500000	t	0
98	\\x60bb07e225e1dde504abb4be1b8abd171cedf9e7580ccae10a250cbcc6437a4d	115	0	3681818181650832	167349	0	272	\N	\N	t	0
99	\\x404ae5aeceb0627daa922cd6beaf6dcf0addc4602bd83f42a3a5f590ff2c0ef0	117	0	99828910	171090	0	350	\N	\N	t	14
100	\\x8073a4e556a5876458dfb6f10772233e645356fef0ca05754ec5225a2a040bdb	119	0	3681818081484759	166073	0	243	\N	\N	t	0
101	\\x95822ca583ffb415283b055603abc36c9c964811fe37fe827c816ddbe02af182	122	0	3681817981314374	170385	0	341	\N	\N	t	0
102	\\x74a945d43b3f76e00184b187b27e47fa9a0e3877da2c532183378e861351f674	123	0	3681817881146585	167789	0	282	\N	\N	t	0
103	\\xd06c741a1f0ef37937a0b41737e775ec1f86a24e4fafead2fc5e8970715a6a6e	124	0	3681817780979940	166645	0	256	\N	\N	t	0
104	\\x836cd316467190ecf8eff288a710599edbeaac5b7f2085aa6e4095fecb87a8dd	125	0	3681817680717067	262873	0	2443	\N	\N	t	0
105	\\xa27b4d16c87c967664745bd4b2dab9b826d512d039e64d22ad22e229a754d6b5	126	0	3681817580550950	166117	0	244	\N	\N	t	0
106	\\xe5e00a048e45fe286e6d6a5b2495fdabe58964e6dd0d9e7c2d757e5d8bf931fd	128	0	3681817580223603	327347	0	2613	\N	\N	t	2197
107	\\xdcf217905027df05c83c04d889441110406158e106dc4526a186ae8a6b22e944	131	0	3681818181642252	175929	0	467	\N	\N	t	0
108	\\x1bb920d38926a59d80528920730182e4efc4b9c46251604f21ec1c596d0ddaec	132	0	3681813275134639	179625	0	551	\N	\N	t	0
109	\\x596c3c4a95a0a30fca9c83b28dfbe939a1d4bfd02b1fb078fcd685161770e64f	134	0	4999999767575	232425	0	1751	\N	\N	t	0
110	\\xa381289316bc3af75a6962a383b96b327cc82015b547ad10c8b2f6312bcefe63	135	0	4999989582758	184817	0	669	\N	\N	t	0
111	\\x5c3893fcb11292e1880968d2fd8f6d1a18cb64c1cba958bbf24b213b554ecda0	426	0	4999979378581	204177	0	1104	\N	5553	t	0
112	\\xd06e93dc312e3a9c50a339ddd00c645e6129d91f1ce6f58195d4c466e866b509	430	0	4999979198164	180417	0	564	\N	5601	t	0
113	\\xb249f4de56e5b4e3a73b6520af195facf9e878e90ef4fb748b6375541b2e6cfc	434	0	4999979006879	191285	0	811	\N	5654	t	0
114	\\x1d7636b22255a34fa7a05a9e8a04b82e0ef10f5d1c7ef82435a59b75c18ad38b	438	0	4999968817706	189173	0	763	\N	5691	t	0
115	\\x115688ca95fd01e463546c58ce6d35529455d05c87369f4f08c0b6e753543bff	442	0	4999968628313	189393	0	768	\N	5707	t	0
116	\\xfff9545bf4a866f8cd0119f537f92dda5178ddb7c3cd083acfd3741a6a7cb2a7	446	0	4999978448908	179405	0	541	\N	5741	t	0
117	\\x219d2ad82e7d375005f2e3f04a36a4107ce403fb3f41c0f3ed4e2ae138da545c	451	0	4999978244643	204265	0	1005	\N	5780	t	0
118	\\xf728bed39f6fb054481fe2bc6e0178065261b93f2294efb5e864df9db6a44090	455	0	4999978070958	173685	0	411	\N	5826	t	0
119	\\x10018571321eda07fe47aba94feb771b661f9570e49b197e3bcb187134531dc3	459	0	4999975900705	170253	0	333	\N	5841	t	0
120	\\x52e1d58078b47116046b1f90704f2844d6a377dbbed8f894e9b106be0f4058d0	463	0	4999973727196	173509	0	306	\N	5904	t	0
121	\\x570c22ffd7e53fc64d384c974d86efb71ed522e7280f24d10180ca3d9d062d83	467	0	1826667	173333	0	403	\N	5970	t	0
122	\\xa72cb9bea0ce78e0886e0f4f51a9d2e610291bab75fee361d70e03c5e2d63b1b	471	0	4999973534195	193001	0	749	\N	6015	t	0
123	\\x975b9c63022a3aa0eaaf1b069a24755a1a71e97e589d6210def477a241f9cb5d	475	0	4999973337762	196433	0	827	\N	6059	t	0
124	\\x1f4b911389b8f064b6b001a625665c005f77d5fd88fbf86499a75075845881fe	479	0	4999973162669	175093	0	342	\N	6114	t	0
125	\\x1070b8e682009337e815cd29dad8a5ec5ae0d482e21d52a85750fd6d8a871188	483	0	4999972969668	193001	0	749	\N	6143	t	0
126	\\x859dd28257dc486337a1f44fa4ce075d6cb0f1baae3f29e0df3418e1bde4fab9	487	0	1826667	173333	0	302	\N	6175	t	0
127	\\xa8713cf0d0a86c59cb8e3717d3359aef5100705d8731b216eb070ea233a57450	492	0	4999970776667	193001	0	749	\N	6231	t	0
128	\\xa74d0776b31b026ca087ed3923fbf0afaf570fff9f8962f95005290940d2ec7c	496	0	1824819	175181	0	344	\N	6256	t	0
129	\\x4f6249382b1a65466c71eb9e047af025a41ab0583c5ac97f8b448bef7019469a	501	0	1651486	173333	0	302	\N	6317	t	0
130	\\x4cded132a41dd177587d7933d303b9ef452e178ef1f71a54eab6d724816d5f4b	505	0	4999970258164	169989	0	327	\N	6358	t	0
131	\\x06b33e8d0cadcfa32429cf876e7c885577cb0ed0e30a4d3f8879b126a773055d	510	0	999693655	306345	0	3430	\N	6393	t	0
132	\\xda67e4493648c06099e4d7d796c5307c6252b9b1660e47f7b8dfe2ef75524383	514	0	999451198	242457	0	1978	\N	6419	t	0
133	\\xa48932f98cc29e2aedd3811b2f8aee7e6504f26c4d3278c83de8e5b35ebfadb3	518	0	499402614	201757	0	1049	\N	6465	t	0
134	\\x908cc3eea6b60ab696c0a83fb937f1f92f6af9630b39e299901499458df7b33e	522	0	4998970080431	177733	0	503	\N	6503	t	0
135	\\x8fa4e1c9db4a9043f7d4b955aa34a888588e18be81507d99014c8c81d4e2957f	526	0	2826843	173157	0	399	\N	6545	t	0
136	\\x27bb3b6bc6f0d425f2c90c99cb9deb8987621a320a0221a58e16a8830bfa2fb1	531	0	4998969721665	185609	0	682	\N	6577	t	0
137	\\xb2790ddc2517abec00e86dc228d7f7b20cbe3a216131b2892340c75f789d97bb	535	0	2820771	179229	0	537	\N	6599	t	0
138	\\x7f50d3c8c7d1b1734b01ab742137d8e667f5c246c7ccdbfb21f4c93d31950f93	539	0	4998966551412	170253	0	333	\N	6655	t	0
139	\\x72e019c38d8320c38a6c169b89d16964d8fa4208ccccd2188f273bc7313008f0	540	0	4998971025517	173333	0	403	\N	6686	t	0
140	\\xc7d90c05c2fdefe6b335894295b71cc9159e320c49ab9da382b5fa61f86c455b	540	1	4998970855352	170165	0	331	\N	6686	t	0
141	\\xe6a912136bbf4705cb70801992c2ef7804536e9aa4d7c242b893e8bd39a1d40d	545	0	1999587967637	168405	0	291	\N	6750	t	0
142	\\x8d702ee99de3fd7927a72a65f2754cdc415a557682f2150913b1be547b48ecbc	546	0	4998970515374	171573	0	363	\N	6763	t	0
143	\\x3e6f4fed3eb0b23353bca021440704972bb418b4e0c92eedcdfde702d5f5b031	547	0	4998966018542	168405	0	291	\N	6775	t	0
144	\\x4df960c0f6471befd59bd86a9fe1a32c211a46213a2f2c5846e9474e3b6c8d7d	548	0	0	5000000	0	2368	\N	\N	f	1893
145	\\xb502cab4907233483f7d23108fab08bf5217ed2ffba1b614e1f137e645c3dd73	550	0	4998960502229	516313	0	8198	\N	6791	t	0
147	\\x753e7e4afea703c40330ac685d3a484acf3e1bf66f3b2d14efc1a16b88af8249	552	0	179474447	525553	0	8408	\N	6803	t	0
148	\\x1d9bde170625ae84da29f95bf7d6bb05a6381fd342b1f0da3ee5e1c56d564fbf	554	0	83074539099	177293	0	493	\N	6832	t	0
149	\\x63b955c718c2010b2599ebe7d5b8b25f8a6291e407309a34e7619cc85c6eccd2	557	0	4157030	171397	0	359	\N	6888	t	0
150	\\x092efba96c159e5c90be71fc0f2c61400d3d24393fd58cd089a9cb5caf4831b3	559	0	83074548339	168053	0	283	\N	6924	t	0
151	\\x0ee7929a28a7faf4180b5226201c74a70512c330af57bad2ed87d8674707c022	564	0	83074547943	168449	0	292	\N	7016	t	0
152	\\xfac0addae88ace32ff146d5a70b67991dff43dbfe5b8e5406c550a72515d9fe7	568	0	97372060668	174433	0	428	\N	7114	t	0
153	\\x8526d661ff48c28acfdbde1284ab1c9cc1f30eef452466c7748d3252144fcb25	690	0	83074547943	168449	0	292	\N	8444	t	0
154	\\x7f1c3fc27adeb78aed70559ceb5cb358b4b74f892e0fd1a66491db1a07022c25	690	1	83074547943	168449	0	292	\N	8444	t	0
155	\\x4b5dc9b9f85ac900eb89168adf3a90dfac4617984f22b55c023c3143dadf5c4f	690	2	83074547943	168449	0	292	\N	8444	t	0
156	\\xb1d925fba21735d1cbdbfab2d332286a3c80f442e1ba38a5581b490a0fd31ecb	690	3	83074547943	168449	0	292	\N	8444	t	0
157	\\x4ff17209b87ed1e256299b2f9f0061dcdc55a628fded622ecf09295150916c22	690	4	83074547943	168449	0	292	\N	8444	t	0
158	\\x3e1d7dc5cbb0ed69c7eb2c8e38aa4c79702aa862866b77b198af6f296e9a574f	690	5	83074547943	168449	0	292	\N	8444	t	0
159	\\xc11d08dda746d71c17e49e81c333db1994bb0976b11a238eaaf4b7fee29e8e5d	690	6	83074547943	168449	0	292	\N	8444	t	0
160	\\x28c5da7a2c28dd3d142eeffc414d9b097e198abe184318cf567f056732561aaf	690	7	83074547943	168449	0	292	\N	8444	t	0
161	\\x801ab9dad8fa8ef630ff7cf524b06380a1b9dc3fabb3b008fdc61e87e1042f16	690	8	83074547943	168449	0	292	\N	8444	t	0
162	\\x4caee672b96e47a62cbe9b15108465a499200097cb6cdd92d622145a0a601013	690	9	83074547943	168449	0	292	\N	8444	t	0
163	\\x7a4183f658f00a3f38f5ae44897cc257b0a62e56e62b17c9b413a5d0a714e571	690	10	83079546359	170033	0	328	\N	8444	t	0
164	\\x8553c2453916907dd565d696f203a358e1bfab0adea5da4c17c8cfde4f5dd966	690	11	83074547943	168449	0	292	\N	8444	t	0
165	\\x855ea6b10b2bffd0ffcaa281704e3aeeacc561414620e1d9bef8eff502f38d5b	690	12	9830187	169813	0	323	\N	8444	t	0
166	\\x9f1f9845e347d8f4a69e7298a4cad8caaa11fff06c8c9d2b007131a5f354457d	690	13	83074377954	169989	0	327	\N	8444	t	0
167	\\x1d982af178ae27180f5126d5c8c27d7ac1c5b191b1fea9811fde280dc271c8ec	690	14	83079206557	169989	0	327	\N	8444	t	0
168	\\x9636ebdc1c932208bfc11c2afb7f73daf7fb73948b427a3f396eea4ad7ce88db	690	15	83073370694	168405	0	291	\N	8444	t	0
169	\\x5c86751a95828a8b93c2ad7990d64186d32cf53fe8bc048295061a30cb88993a	690	16	83074547943	168449	0	292	\N	8444	t	0
170	\\xc902ee0ed03f2911fd5609c6999cbaf8f751974801b74a34f9ffa5fb99b11be0	690	17	83079546359	170033	0	328	\N	8444	t	0
171	\\x0a1f215acc0841aefab0a80316af80f2120b33a3d07889c1be52dd0e3649224c	690	18	83074547943	168449	0	292	\N	8444	t	0
172	\\xe38ee2a83d87d5af48b9a0af605f3e373383a186ceb2aaa1c67b71ea777423ce	690	19	83074547943	168449	0	292	\N	8444	t	0
173	\\xd1ae00767c30676a74e37a6986cfcb37ff3d13faa437d5a17a5dec240a4ee7c8	690	20	83074547943	168449	0	292	\N	8444	t	0
174	\\x2c21bce859e5a14cfcfafd7298a410316e145d550fae1193ec67474ea40781bd	690	21	83069379538	168405	0	291	\N	8444	t	0
175	\\x671f6e2a098d6cb64c5ed265655db096ebbd5809b6a6de042178cd2ae72410fe	690	22	83074547943	168449	0	292	\N	8444	t	0
176	\\x808bd65b523dd9077c356afe03c5d2af5265f9f357ac8d8673dcb671865da656	690	23	9830187	169813	0	323	\N	8444	t	0
177	\\xff3324473c3a0a285b4a058d4f1568f2b5595a4f03791dd008e8dd0c492a6e32	690	24	83069379538	168405	0	291	\N	8444	t	0
178	\\x3f7d8f743ab0c32b003946edfbb900634dc7efb16d00ca6c4b2b6066c35ada30	690	25	83069379538	168405	0	291	\N	8444	t	0
179	\\x3f4f58703cc887635244dda83cc1295d60d3f02bb5b823ccd93b048daff11936	690	26	83074547943	168449	0	292	\N	8444	t	0
180	\\x7209a9fdb8c2051568a506d3d0be560afe3482889da1f242dbc6b06e340c369e	690	27	83069379538	168405	0	291	\N	8444	t	0
181	\\x17396e246538ec553cb45ed74d6b2081b96d38f06db71b5d6ee59e63e24818d4	690	28	83074547943	168449	0	292	\N	8444	t	0
182	\\x78b5d6c5dc6465b3b1e90ba9ed3d1b7a72d872d84af9817c4c72c8b66677ecc5	690	29	83074377954	169989	0	327	\N	8444	t	0
183	\\x8399b2d650f0ea2801b212799190bf8aff2189001478055262f28814a915f87b	690	30	9830187	169813	0	323	\N	8444	t	0
184	\\xb363f0a0cbf8aa355a78c1343abec1a45d19ff6f63df3f11a5ed0c0209f40569	690	31	83074547943	168449	0	292	\N	8444	t	0
185	\\x793ec5f2826fdf0c62c6c6f498479599eda31d452b058a9aa8403b438be3e230	690	32	9830187	169813	0	323	\N	8444	t	0
186	\\x4e19c833069d06799dbe5615496fac148dfa5cbbac4b6bc5548d1d5de0721284	690	33	83074547943	168449	0	292	\N	8444	t	0
187	\\x78125d23cfe79082548be4acbb644f228a66cad575df2d45ea2d45f1d94a92b3	690	34	83074547943	168449	0	292	\N	8444	t	0
188	\\x9c2cab598606983723181f4d6791ad9d54bfe713e7712d897c77ba75c13fa193	690	35	83073030892	169989	0	327	\N	8444	t	0
189	\\xd605dc5205218aab8883d10a3980e84a1564e110eba7418418cc4bca40647eda	690	36	83074547943	168449	0	292	\N	8444	t	0
190	\\xc0adf5e3785353037e6bc47d3e50d5038ccbc89dc382f9e38e05a24050bd962d	690	37	83069379538	168405	0	291	\N	8444	t	0
191	\\x3afb1e4afaf2bc5a1572e927da1aa8d63f94f1cacce62427747a433334e9f54a	690	38	83074547943	168449	0	292	\N	8444	t	0
192	\\xc28e0ec5fbce63a57bdef56360be6d1efbfc9368aab1a0ebae7750d1cb754731	690	39	178331771	168229	0	287	\N	8444	t	0
193	\\x7192495e5efb0c9077578915d2ccc6fad1c42c53be6faf0800feadf257bf718a	690	40	83069379538	168405	0	291	\N	8444	t	0
194	\\x5f40310cfc1925e4298e830bb69358b56530ca59ebbe4960da9e90c2c8eb35d4	690	41	9830187	169813	0	323	\N	8444	t	0
195	\\x66ed0e072277aef415976245542e40c5c3503ff3b02fe8b4a2394fe724f15534	690	42	83069379538	168405	0	291	\N	8444	t	0
196	\\x4695c478893d2546f6163e282053bba29273b674dfcd592101f524222afbabf9	690	43	83069379538	168405	0	291	\N	8444	t	0
197	\\xbc80fc9e9be725573bb543ea29895f409f97e119581d56af31b082820f21bb92	690	44	9831771	168229	0	287	\N	8444	t	0
198	\\xcbbd415a75b11f19cb1cdd7d7f179d268a3c53f86bd831ac11475a1ac7ba67d4	690	45	83074547943	168449	0	292	\N	8444	t	0
199	\\x4c65da01cd148516eda3e4eddc2dabf4ed7e39f593a91700ca40b040f115b2e9	690	46	83074547943	168449	0	292	\N	8444	t	0
200	\\x43a4f32f976559c85187fbe17b19e762f221f84e3662c3fea98bb6e131d9094c	690	47	83074377954	169989	0	327	\N	8444	t	0
201	\\x988a0bbc1c65652635f76e81f3b39f719094b2b259cdbed01511c36b6a78de24	690	48	83074208141	169989	0	327	\N	8444	t	0
202	\\xdee9798fdfc02d0165ff1d577b5dbce9f2c010404e436d2fe923abb93c3ed660	690	49	83074547943	168449	0	292	\N	8444	t	0
203	\\x6fca635e3c6f06aa693e513442df2cb471b682e271c57ca0f0298119e751d4e5	690	50	9660374	169813	0	323	\N	8444	t	0
204	\\x7117ea9980acf40dc904d9c4d7ee6a6dbad557c198e622d26ef7b309cf459e70	690	51	83074547943	168449	0	292	\N	8444	t	0
205	\\xed07f9a5059cfe48a179fc75dab1420c68ea56a6ccaa6f4d5ea7c56653d5cf62	690	52	83069209549	168405	0	291	\N	8444	t	0
206	\\x654d472f6913ad524353e231c1b841bf58ef7339b71e0017ebae2bda8c34f4b8	690	53	83074547943	168449	0	292	\N	8444	t	0
207	\\x752c129d3bd1cda08cdfcbdb81a659794ac875bb7e4547721ca41049cdaa531e	690	54	9830187	169813	0	323	\N	8444	t	0
208	\\xadab60835fb371e1abe9b87f2ad2aa1029912e94bc32b8cbea61a73ac496489c	690	55	83069039736	168405	0	291	\N	8444	t	0
209	\\xd4966a3149bb5f5b2c36ba512e0c31cdea644d0f56d290540e4e9334dd18606a	690	56	83069379538	168405	0	291	\N	8444	t	0
210	\\xd5e95d1780590a29a0bf1fc8ee98601558e6313df30b45fb67b9ef554cb92641	690	57	83074547943	168449	0	292	\N	8444	t	0
211	\\xc486b5fbfb6bbb82b4756cbca94981550cdc412a101b232e649050f048809b73	690	58	9830187	169813	0	323	\N	8444	t	0
212	\\x3cd6b411f3821162f480a78347e51b04fdc68f40b59ceb75c0d141327029e95a	690	59	9830187	169813	0	323	\N	8444	t	0
213	\\x25514e09a029f8ca8f285854dcde68cc886951d818a2d8c686e5d06e244c176d	690	60	83064211133	168405	0	291	\N	8444	t	0
214	\\xa2e4c9f4594573f36dd47de8685baca1f057a1c83aa6813af7c1cb85092c2faa	690	61	9830187	169813	0	323	\N	8444	t	0
215	\\x6fbdd64ea6803f827fc90fab8db85ad2881585eec6dc3cfe8488266fc16fe867	690	62	9660374	169813	0	323	\N	8444	t	0
216	\\x516fd368526743656158fa56a99e07527a2e203072b1fff5b5a9be10fd322fa5	690	63	9830187	169813	0	323	\N	8444	t	0
217	\\x923853d1069ca5eb2d5c164acb8b5aef725ace0dbd2c2096b19dec04ee8d70a5	690	64	9830187	169813	0	323	\N	8444	t	0
218	\\xce12090b7bd9fc8062b7cf628578e3655f1eb04eb999da69b5c9c0204ac3a711	690	65	83074547943	168449	0	292	\N	8444	t	0
219	\\x21bed0a144529872ad94839d3316c427a048a917073737cf8ea232ff7af96524	690	66	83074547943	168449	0	292	\N	8444	t	0
220	\\xcbbe7a2484dc98a40a83965c0189278886de4769164c98521e747b8d829122fe	690	67	83064211133	168405	0	291	\N	8444	t	0
221	\\xa52615fbc71bc9b2a09ffe057f61ef45a83af9779aefb6c8b70a664cd7bde179	690	68	83069379538	168405	0	291	\N	8444	t	0
222	\\x344710cfd36db56baa92839be6d68bad4dc5533a1679b0f0012ecd5a8dcc9d3c	690	69	83074547943	168449	0	292	\N	8444	t	0
223	\\xb8668fed3fcbd1ac0fb5730e1a9a7b36feb63e81a192a7ec3ce78c018d326243	690	70	83067862487	168405	0	291	\N	8444	t	0
224	\\x05e6b5631a4f6f946916b7a63e6092bcbde7aa387928d84ec7b6e9b024e7c664	690	71	83069209549	169989	0	327	\N	8444	t	0
225	\\x2c8a56171f2a95a348cd2b09ca2d898a20e65097d239939c2e53179d38db24f5	690	72	83074547943	168449	0	292	\N	8444	t	0
226	\\x5e57e786d4e6ea9424e5a2cac798312dc5350309d6c743a8832e84c8aa1244fc	690	73	83079546359	170033	0	328	\N	8444	t	0
227	\\x40b6776f37fa46eec08f9160f4d8b19192a6d807b7273800778fbc16f8ea120d	690	74	83069379538	168405	0	291	\N	8444	t	0
228	\\x1a0bf27f0ad7b0da6c4192abe44c71cb197e94e6b43bd4df03a7d6f7ed6f7c1d	690	75	9660374	169813	0	323	\N	8444	t	0
229	\\x16f706ae905edc990017fbc74f785f062e7d23786ac9cad2f986ab9f8868485c	690	76	83069379538	168405	0	291	\N	8444	t	0
230	\\x7eb9533f9fb7fba23947ecd7a631f1e24b02ac6cce3fdbd09c78d6a697d2567d	690	77	9660374	169813	0	323	\N	8444	t	0
231	\\xd10b0eb81dc12b43ab3fbb1906f15ff1872faf5b14b2f55dd1ab28c6cefcc293	690	78	83069379538	168405	0	291	\N	8444	t	0
232	\\xa0f0ab3bcec9780a735654c67859185b970979a6b5dfa529d09e97d899ead105	690	79	83069379538	168405	0	291	\N	8444	t	0
233	\\x88695d1d946a5dee2c493b6367af0d8f083f63d56ab1b17d06d49e7569870008	690	80	9830187	169813	0	323	\N	8444	t	0
234	\\x0bcbaf14b2b6428b2904ccb59d98fe4f1fb6b885516bd2db2e834f1dac42570d	690	81	83059042728	168405	0	291	\N	8444	t	0
235	\\x6d67425ba9a58e684d1697141b3a3a3ad30f8798db57abd0168269d2dcb533c5	690	82	83074377954	169989	0	327	\N	8444	t	0
236	\\xb24823789347e32f9604bcda4e558277bcd36ca5781aceb9bcce370fbecf5714	690	83	83064211133	168405	0	291	\N	8444	t	0
237	\\x390abf7ff2e6fe706e06d9545a27bf29593ed4bc4987ee1d8d600219193593e4	690	84	9830187	169813	0	323	\N	8444	t	0
238	\\x0575cca9dcc30a496a9855b18b1e45d214ae69dc5ed0e4500ae5c51d99f0f798	690	85	83079546359	170033	0	328	\N	8444	t	0
239	\\x67ff682c40821e124beb1b4647f2793f308d4c0d56920bed9fd0c29ee95bfd46	690	86	83062694082	168405	0	291	\N	8444	t	0
240	\\xca4eb80316392d3f2dabc0c9a9932b15c64e71585a9406ead77d024c1b365164	690	87	83069379538	168405	0	291	\N	8444	t	0
241	\\x62940fafa10c007edc0a0f4bea17921b72f4c7049354460b0c309d1b9dd02c46	690	88	83069209549	169989	0	327	\N	8444	t	0
242	\\x2a315a75ea669aa48ef642a9c251f996a62d4bedd50d40fb5eb8e631bed7b36f	690	89	9830187	169813	0	323	\N	8444	t	0
243	\\xe8bd9e53c4eda900b546c3be630d4e940f86f270c91999243dc10c5092d94b46	690	90	9830187	169813	0	323	\N	8444	t	0
244	\\xd96932d8eb649b0dbe77a39dd113a39c0493ccef5f8d79837cc048abdc9848f2	690	91	9661958	169813	0	323	\N	8444	t	0
245	\\x5a38faa47f09328c4c1e07ae73b0382972ad126d483aa56bbd595b7e63bffb28	690	92	9830187	169813	0	323	\N	8444	t	0
246	\\x115f1a0da69d5296e40239c150e699deb3f4370ea209e1025cbbb4dd6cc474ff	690	93	9660374	169813	0	323	\N	8444	t	0
247	\\x7bfe7ea11cb666aaa98e18d87273a342705727505ff3c3bda36248952f009e25	690	94	83059042728	168405	0	291	\N	8444	t	0
248	\\xb043dd838ffcb6fe9ca464945197dd7571597e5e27649d1334c615676fc5f337	690	95	83074547943	168449	0	292	\N	8444	t	0
249	\\x719124c62544ee77b24788fda234811e79c373dfb21aafd11883abcf6c275043	690	96	83068869923	169989	0	327	\N	8444	t	0
250	\\x6578c1c6c48a3e9aa316971da9175d9fdc28fb9965f919a1bd8fa68270fe1fef	690	97	9830187	169813	0	323	\N	8444	t	0
251	\\xc9362b363f1551df939508b446da47a94bf4bb0e8718e6ac4b8650804ce2cc73	690	98	83069379538	168405	0	291	\N	8444	t	0
252	\\x94612683ac599ee9270c87d176f8bf427a8ff0838950c0e3556be4262429e4fe	690	99	9660374	169813	0	323	\N	8444	t	0
253	\\x7c04159c5d179efc478ba4b5d9e35dc0b22574eaa76b788fd796a49a460f9978	953	0	95085675427	174741	0	435	\N	10869	t	0
254	\\x92259d01a95cc8463404c71c28203ca7458e376b03e1d4fa6e1fb4a2d21e965a	957	0	5010952119805	412473	0	5842	\N	10930	t	0
255	\\x6827dce0dbc40c1575d5e6c4119d9c107104224d89133893a729e0ced7875888	1134	0	1266738393036	174697	0	434	\N	12442	t	0
256	\\xc5efdd7edab43e08ab18fa82cfa66bce22d682609fb3ee237ca0c09bd26b87c6	1134	1	39147898253	168405	0	291	\N	12442	t	0
257	\\x622c161a6bef973493a13971e4245892f2aa8177d4ea7d6c263330c73727ace5	1134	2	156597096645	169989	0	327	\N	12442	t	0
258	\\xb58012258a86052d2169ecf39b7a03af96cadd1143fe54c725395535903810c7	1134	3	78295964912	168405	0	291	\N	12442	t	0
259	\\x137e2d55b1b8ea2ff8c99320d4bb104d14d6d8242855b1dff0db642acc98d91e	1134	4	626368898130	168405	0	291	\N	12442	t	0
260	\\xefe131608576f923a6ae8f019058c9d63de174b6911e7e7ac7bb2254a1d21d7a	1134	5	39147898253	168405	0	291	\N	12442	t	0
261	\\x5948546b43226990f83efae0b1f28a533ba9a25b9aace152a0af86f25da3b6fa	1134	6	1266733224631	168405	0	291	\N	12442	t	0
262	\\x820c2bf499aa44685daccd83a8aa87b152b5143e8c365819a83a3392f4aafc6d	1134	7	626368898130	168405	0	291	\N	12442	t	0
263	\\xe24432d1b93cc154b989395a47f0a124fc8d4e363e55e4153712c200d2a98d6b	1134	8	626368728141	169989	0	327	\N	12442	t	0
264	\\x064efa28634bf5869998c958c59e4ef7e656cec60b130db64088efe9d3623512	1134	9	39142729848	168405	0	291	\N	12442	t	0
265	\\xebaa6fcaff1138405cfe633acc091b365a18e55cec699c27365f5a17f970b4ab	1134	10	1252737964665	168405	0	291	\N	12442	t	0
266	\\x18bcd0371d6d132eb9fdfdcfd3176edba751a5ebf3eb143dffa75f2fe7459d9c	1134	11	9830187	169813	0	323	\N	12442	t	0
267	\\x68395854b6369440070a57bdc87abe7e00af9a12f41b5f48329694dff8d4dd79	1134	12	156591928240	168405	0	291	\N	12442	t	0
268	\\x84a40b87420eafa7366a2d7634c66049d2f37b1dcdb4683688b7999b7cd8f1ee	1134	13	9660374	169813	0	323	\N	12442	t	0
269	\\xcbdfdc9e98dad02be38e652ea371edcfb33d78685cb0c0cdf9a41370bdee23d2	1134	14	39137561443	168405	0	291	\N	12442	t	0
270	\\x83409ee410eb87ad249e881cb21871655ede6620953526297f5ca4ebf48c7355	1134	15	156592098229	168405	0	291	\N	12442	t	0
271	\\x3a360db2dac941d3c75401b3f152d4c2d0469ab599fd82e2e61024367bf4c1e2	1134	16	9830187	169813	0	323	\N	12442	t	0
272	\\xea9fa17a3ecdbff9255948dd1d08e5a91b23eb1911b26d022f45ca9e65535601	1134	17	1266733054642	169989	0	327	\N	12442	t	0
273	\\xbcf5000b59c7a56233caae96dac442438c7c73b97f766b4b61419998674e47b6	1134	18	78295964912	168405	0	291	\N	12442	t	0
274	\\x83050289bb65955607b6b0894fa23883785dea428f91f8aac2c0e1118c1a2199	1134	19	78290796507	168405	0	291	\N	12442	t	0
275	\\x1ee3844696979a48a687567b239c4c4ae2ac8d39babe58e2974839d074cc9792	1134	20	39147898253	168405	0	291	\N	12442	t	0
276	\\xb6f09f626032cf9c7e8e0b3e65a11ed840ece875fa4e4c4ddf2864848cde27f1	1134	21	1266727886237	168405	0	291	\N	12442	t	0
277	\\xff5d2580eac9cd57a465528b441711c8e7aac3306b7ce593db666256b8ff8624	1134	22	9830187	169813	0	323	\N	12442	t	0
278	\\x30d19d6e3d6ec344a0ff1096387ff3223a2718ea0893ee608eb7aaedfc70717a	1134	23	9830187	169813	0	323	\N	12442	t	0
279	\\x8e7b8fc2821d604ecbcf4da36ad716c318391dabefbdad9fe55235049088e49c	1135	0	39132393038	168405	0	291	\N	12442	t	0
280	\\xa4f342822402aef81419b85350d1a2374716fca3ce699edd7baf716c7c5d6bc5	1135	1	9830187	169813	0	323	\N	12442	t	0
281	\\x52759811fd536d171cc058b49b1e3720702b6228f0e0439a749dbebbbb215524	1135	2	9830187	169813	0	323	\N	12448	t	0
282	\\x6e010736176c4dd3ee0f9866eb9b53d8a82c180f84cc34b7960864e3ad488b08	1135	3	39142729848	168405	0	291	\N	12448	t	0
283	\\x004f727f8273c487d2a07c6e0a45759d5500979d15f7fed45087bd084f396e32	1135	4	9830187	169813	0	323	\N	12448	t	0
284	\\x4791d421a7ef26b2f8d97826476526b18b86a067fdd2092cdc2e72d8ffc8c2ac	1135	5	313189193465	169989	0	327	\N	12448	t	0
285	\\x42f4a133f044b0b9ada327b2fd636bf8442930f915142dee92ee688b240bf49e	1135	6	9830187	169813	0	323	\N	12448	t	0
286	\\x31ee0debeb4489fd1071c183369543eb8e22e2a249f407187aae3179c27f78d7	1135	7	9490561	169813	0	323	\N	12448	t	0
287	\\x771d1666ff266319912252a48b90c24996235dd90ddbf0a723bade052b056cb0	1135	8	9830187	169813	0	323	\N	12448	t	0
288	\\x5881d7930a8f26db169f423f3fbba26acdec550000456298ad8992e76729a171	1135	9	9830187	169813	0	323	\N	12448	t	0
289	\\x939f1ddede905ad036d7a7e17def8b001262bd4f3b46dcaa560aea8d79e0c6dc	1135	10	39147898253	168405	0	291	\N	12448	t	0
290	\\x86d0a9733e82a8b699cae3a4bc3dbb39666d390680c341f2acdd9dc6ef18081b	1135	11	39142729848	168405	0	291	\N	12448	t	0
291	\\xab6166eaa3bb5f41ad33a6ad6b2a79c248cf996ede9545d4c3a9e76becad26b2	1136	0	9830187	169813	0	323	\N	12448	t	0
292	\\x5db0f480ca4ef738a0869a87abab33a92a477d6c0cfd01554e8021b5eff87bed	1136	1	39142390046	169989	0	327	\N	12448	t	0
293	\\x9776aca5ecb661d30c604fa7b317003a963c983683df026604819b98e77d1111	1136	2	9660374	169813	0	323	\N	12451	t	0
294	\\x8e875249483cce94dcb3b1e3aca5fa87502e9cc971146149b3730753614b0042	1136	3	313184364862	168405	0	291	\N	12451	t	0
295	\\x692367d2368f211d522e895dca244eddb0b7055d5c54d49393ea6817c96b000f	1136	4	9490561	169813	0	323	\N	12451	t	0
296	\\xb25ff8b543d8ef4582f61c581868385b1871329f38f364efd584d75d2cf6ee5b	1136	5	39142729848	168405	0	291	\N	12451	t	0
297	\\x5ddfdce2f6d86f58c7830dd039881fe561d680f4f2e57af49c897eeb7ce43865	1136	6	39137561443	168405	0	291	\N	12451	t	0
298	\\x066c7f38edc41c2cb99fe5b59490bd4bfdf8473c5a239309f6574037026e033e	1136	7	9660374	169813	0	323	\N	12451	t	0
299	\\x78b63a605d23cdd58161aff512e77aadf3034b5d33cd471ca4160c422026004f	1136	8	39137051828	169989	0	327	\N	12451	t	0
300	\\x2a69d06c3b687a9d964f234c8827ca5980d5ba63c9f694a59fd9820dc4bfe5ce	1136	9	1252732796260	168405	0	291	\N	12451	t	0
301	\\xceaae57d1a41660125dc7fee805800020609e3d91e9458dea112a31b29f8422b	1136	10	9830187	169813	0	323	\N	12451	t	0
302	\\x33b805f002747029253c4b22c8a503226730b92e8766e2c7c7a5935b349b7981	1136	11	313179196457	168405	0	291	\N	12451	t	0
303	\\xf8afc4e51e9f0feefcf306fddc06695490b81e5aa8abfb71c2082abfba7239d0	1136	12	9830187	169813	0	323	\N	12451	t	0
304	\\x141631c62b35be6a71aa57e9d5eeae4ac3a5f1cf88ebcbdcdeb946d582c1c6e6	1136	13	1252727627855	168405	0	291	\N	12451	t	0
305	\\x7392b3eb2a536a4754a440a908b0e36fcde3dfbcf1b187cbaabf403e825e590a	1136	14	9830187	169813	0	323	\N	12451	t	0
306	\\xe6a9875496e9747f2e3bca8071ea8654d84018def434ca0b587bd27b1dd8c458	1136	15	626368728141	169989	0	327	\N	12451	t	0
307	\\x1d5a326ad51d6267551049ce9b0d2db6a8661c8de72854860a0faaecacb76d1a	1136	16	1252727288053	169989	0	327	\N	12451	t	0
308	\\x2dd954e18af2f0de2ed215d35f452578e7ac017fa79134aa70713a8d1d797cf2	1136	17	9830187	169813	0	323	\N	12451	t	0
309	\\x32b51339065b5844b2c53196117c562de584880820fe6a4ce5de81fb9278b8f4	1136	18	9320748	169813	0	323	\N	12451	t	0
310	\\x169b4f7bc37491d82890c1be496a756a307b75794f7ca230e52de7fca4ddab59	1136	19	39137221641	168405	0	291	\N	12451	t	0
311	\\xbcbe043736b6958ea82e77309402163caafdade1b98b45d467e0a35a90a9d0f4	1136	20	9490561	169813	0	323	\N	12451	t	0
312	\\xc712cf83cc7136611f2fdc1fd9f307fa5f5046aaceccf9258f1967ad21957a51	1137	0	1252722119648	168405	0	291	\N	12451	t	0
313	\\xe19d2d23dc8e986b1ac1b21c5ae7f8b180f167494a5326b7fff6669298ea9217	1137	1	9150935	169813	0	323	\N	12451	t	0
314	\\x8f6415857859510972367287b6e4853f176212a7c7a6a2f766403673c4e86d6d	1137	2	156591758427	169989	0	327	\N	12451	t	0
315	\\xa456e526e625d8cd7e31de8b3d89bdcaf13ac09fa20efaa750daae5219345c3e	1137	3	313174028052	168405	0	291	\N	12456	t	0
316	\\xf5cb9574ed327a514b0e8a1d45a6da6d73cec99b310a566227f8158dcbdaf31b	1137	4	9830187	169813	0	323	\N	12456	t	0
317	\\xdcff51ade27b3a6afc4067c1327bb7833fc4d480f288a22f7e5d10508b177fb0	1137	5	78290796507	168405	0	291	\N	12456	t	0
318	\\x2fae31b245fcfa720394ae6b4b92511b497c80e27769d09800cc23759057c350	1137	6	156586759835	168405	0	291	\N	12456	t	0
319	\\xc4e3f39cbebb623a55d4f108656e625f1a9b2b52bad69f67dee9d97e69dde8f4	1137	7	9660374	169813	0	323	\N	12456	t	0
320	\\xce05dc474d32df867a3d3eb48af9775fe079232ec325ab1d469567f0f4c518c0	1137	8	39132053236	168405	0	291	\N	12456	t	0
321	\\xc3d08552b4c0eba4ea42c2ee98a3495713db62acaffca2800bb1a9118399caaa	1137	9	39137561443	168405	0	291	\N	12456	t	0
322	\\x41e30efaf69cd732ccfba22e84f8a72e76d5141b632fe80ca94dfebc69f2cd48	1137	10	9830187	169813	0	323	\N	12456	t	0
323	\\x21be392452d8c0ec374511872852702d9fab6785ae6e569498131884b01d739c	1137	11	156581591430	168405	0	291	\N	12456	t	0
324	\\x23dfe3749652ad7867c87393105c2400f3482f74e08a7c07db971464ff731259	1137	12	39126884831	168405	0	291	\N	12456	t	0
325	\\x8e84a77a1ee97b18c67a8a65af7eec48fba2633c4884a11b5c5bd7224f335c74	1137	13	39121716426	168405	0	291	\N	12456	t	0
326	\\x984d4f194e5f7bda39ecc4cf73ef6235d91a2d34f6c8cc356a6f46e6ea56eafb	1137	14	9830187	169813	0	323	\N	12456	t	0
327	\\xb28158df031875f1863fbd3a67fd66809fd2631b81bc389db4ea8c8210f568f5	1137	15	39127224633	168405	0	291	\N	12456	t	0
328	\\xc8ae6490c105f7ee7aea2c28fcd3e2b1cf1f2ea5126dee471375395847bcbf90	1137	16	9660374	169813	0	323	\N	12456	t	0
329	\\x45b06eba954faed34efbcf7b8286d833b2b9d039f3599599e11908601663b6e3	1137	17	156586590022	168405	0	291	\N	12456	t	0
330	\\xcc67b60423754e64a403e5047fd9b898548c8602a4117e2ef7539f04cfa767bc	1137	18	9830187	169813	0	323	\N	12456	t	0
331	\\x164a24318de7e3ddcbbbdd33f323c6b9d0887b67037a3e207a89dfe4f41e0aea	1137	19	313188683850	169989	0	327	\N	12456	t	0
332	\\xb0efef1fffab6f520def2abc975a74668aba56f83380e7f2bfc3ef29ebf2c53f	1137	20	9830187	169813	0	323	\N	12456	t	0
333	\\xa83075ed0c5cb8f3931b4c54c2e5467d126163021f978c908718c0b481bfa246	1138	0	313188513861	169989	0	327	\N	12456	t	0
334	\\xe27c2eb5d24b8b2bf87d0452eb8dc3b1bc358d306fcf4d559f826fdae1b6c9ec	1138	1	9660374	169813	0	323	\N	12456	t	0
335	\\x57fbe7d0b1114b971a26605ac377a33e4965c5acea3601fc2e5057da41877ee7	1138	2	313168859647	168405	0	291	\N	12461	t	0
336	\\x4475f200948c2ec483ab08b02dbb97efb2780b001bbce89251fcd103b6a5bcad	1138	3	156585910594	169989	0	327	\N	12461	t	0
337	\\x462034f0a05ba9fb5afbaeaae27081ef220b021cb6a828cc957cacbd270c0a5a	1138	4	626363559736	168405	0	291	\N	12461	t	0
338	\\x0b187d03601436d4538bcc639f69ca4f9f8adbad2d5ec2fb37265db0e3dac8c3	1138	5	9830187	169813	0	323	\N	12461	t	0
339	\\x012ca48e5add11de1f6286da649cddb6f9451f356145b0569276835b8f208e1d	1138	6	1266727546435	169989	0	327	\N	12461	t	0
340	\\x5dd426c316bbc2577756779714f9a75a303914da3ab47d5192d1ba58932d8d8a	1138	7	78285628102	168405	0	291	\N	12461	t	0
341	\\x7d1481e1b187ce24b3b84a03a68ccb7daca432b33528d1cbe1aac931dd7d580d	1138	8	9490561	169813	0	323	\N	12461	t	0
342	\\x6d164ff7f1458154aa3f9529e01fe0e2eb9317b467684ebf8fdc81cd76d5565e	1138	9	156580742189	168405	0	291	\N	12461	t	0
343	\\x00e86d19fa014473d79a3b27565ffefbaa7039ac172041a67c1554f067c7b620	1138	10	9830187	169813	0	323	\N	12461	t	0
344	\\xe9bed40a08cceb931171341b9f0d7c632bda0198e2620d4d6ed3bd8c833c4a7b	1138	11	9660374	169813	0	323	\N	12461	t	0
345	\\x00f09f1e506384ffac735183fa7a0fc65e928c98bd5ca734a288e3a2025f4772	1138	12	9830187	169813	0	323	\N	12461	t	0
346	\\x93cf05924dd511056c00ac945f08bad796a2df9003b1d44f7b23a85abb0c95ab	1138	13	313163691242	168405	0	291	\N	12461	t	0
347	\\x9327eb6d2fd317bdebd3ef7629ea57395f3fbaaf33eddc48956ca365fb300495	1138	14	8811309	169813	0	323	\N	12461	t	0
348	\\x734cba253597d4cd8d2e4bf83ec0970d0d30af09fc56fe1b9a91cd97e7edfe6e	1138	15	8811309	169813	0	323	\N	12461	t	0
349	\\xef5e08217a7bf4534a6ec42a0201a872971d10559f2a39f5c5fb579bb8570cf5	1138	16	9830187	169813	0	323	\N	12461	t	0
350	\\xfdf4c9e7d8bd7306e3f2c78e23fe2de91b64141d67e22f736a70ee186b5d1933	1138	17	156576423025	168405	0	291	\N	12461	t	0
351	\\x309506f470fc9e9b4ce5d5289a06a65e8dcb1359a7d77773bf820cbb302d20cb	1138	18	9660374	169813	0	323	\N	12461	t	0
352	\\x851f2f0b116905c8e651d434a73ac0d387093a07db92fd18af002738a38ff07a	1138	19	313158522837	168405	0	291	\N	12461	t	0
353	\\xcc92274ba1f427d3d15b4cb3df34469cae6309aa641b58652b64905d5bed4dd1	1138	20	1252716951243	168405	0	291	\N	12461	t	0
354	\\x0bfb51ca0d762f25940b8a7c89fd286be63f1d9d2d922fb85e5a41aa6c109876	1138	21	9830187	169813	0	323	\N	12461	t	0
355	\\x5823a67c53d352e83fbb963797875f57b3109d2d033195aeb88fbabe73fee570	1328	0	16340493971	180901	0	575	\N	14461	t	0
356	\\x12ece0dc90bc63c26c778730b1ad21820e7ae4b0df63b387f9751fabe90725e5	1335	0	4999999820111	179889	0	552	\N	14525	t	0
357	\\xf60c413a8fbf1f9b3495d85d1a12bc52821472d00cc50defa9199afc7de45d8f	1339	0	4999996650122	169989	0	327	\N	14575	t	0
358	\\x405e3c5fcbee57a4ff22c216b3a124abf808603217c2f7aaf8ba254f7de5a0ea	1343	0	4999993474369	175753	0	458	\N	14604	t	0
359	\\x53804ce684547c2a5a3c647566bf8b7611bcc8f24a78fd0ac8556a43f05fe0b3	1347	0	9816723	183277	0	629	\N	14628	t	0
360	\\x3cd2a11247c4d7684880c680ea61b25f7fbd1edb67d8765ee0a6ca130c0e0b04	1351	0	9827019	172981	0	395	\N	14678	t	0
361	\\x8ffc4ce2b8f9367b5ecbe79889851f9b42ac28c3c49a81f4de48c7fdd9924b67	1355	0	6648274	178745	0	526	\N	14740	t	0
\.


--
-- Data for Name: tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_in (id, tx_in_id, tx_out_id, tx_out_index, redeemer_id) FROM stdin;
1	35	20	0	\N
2	36	35	1	\N
3	37	36	0	\N
4	38	15	0	\N
5	39	38	0	\N
6	40	37	0	\N
7	41	40	1	\N
8	42	41	0	\N
9	43	28	0	\N
10	44	43	0	\N
11	45	42	0	\N
12	46	45	1	\N
13	47	46	0	\N
14	48	29	0	\N
15	49	48	0	\N
16	50	47	0	\N
17	51	50	1	\N
18	52	51	0	\N
19	53	18	0	\N
20	54	53	0	\N
21	55	52	0	\N
22	56	55	1	\N
23	57	56	0	\N
24	58	24	0	\N
25	59	58	0	\N
26	60	57	0	\N
27	61	60	1	\N
28	62	61	0	\N
29	63	12	0	\N
30	64	63	0	\N
31	65	62	0	\N
32	66	65	1	\N
33	67	66	0	\N
34	68	22	0	\N
35	69	68	0	\N
36	70	67	0	\N
37	71	70	1	\N
38	72	71	0	\N
39	73	16	0	\N
40	74	73	0	\N
41	75	74	0	\N
42	76	72	0	\N
43	77	76	0	\N
44	78	77	1	\N
45	79	78	0	\N
46	80	33	0	\N
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
60	94	19	0	\N
61	95	94	0	\N
62	96	95	0	\N
63	97	93	0	\N
64	98	27	0	\N
65	99	98	0	1
66	100	98	1	\N
67	101	100	1	\N
68	102	101	1	\N
69	103	102	1	\N
70	104	103	1	\N
71	105	104	1	\N
72	106	105	0	2
73	106	105	1	\N
74	107	31	0	\N
75	108	97	0	\N
76	109	108	0	\N
77	110	109	1	\N
78	111	110	1	\N
79	112	111	0	\N
80	112	111	1	\N
81	113	112	0	\N
82	113	112	1	\N
83	114	113	1	\N
84	115	114	1	\N
85	115	113	0	\N
86	116	115	0	\N
87	116	115	1	\N
88	116	114	0	\N
89	117	116	0	\N
90	118	117	0	\N
91	118	117	1	\N
92	119	118	1	\N
93	120	119	1	\N
94	121	118	0	\N
95	122	120	0	\N
96	123	122	0	\N
97	123	122	1	\N
98	124	123	0	\N
99	124	123	1	\N
100	125	124	0	\N
101	126	125	0	\N
102	127	125	1	\N
103	128	127	0	\N
104	129	128	0	\N
105	130	129	0	\N
106	130	127	1	\N
107	131	130	0	\N
108	132	131	0	\N
109	132	131	1	\N
110	132	131	2	\N
111	132	131	3	\N
112	132	131	4	\N
113	132	131	5	\N
114	132	131	6	\N
115	132	131	7	\N
116	132	131	8	\N
117	132	131	9	\N
118	132	131	10	\N
119	132	131	11	\N
120	132	131	12	\N
121	132	131	13	\N
122	132	131	14	\N
123	132	131	15	\N
124	132	131	16	\N
125	132	131	17	\N
126	132	131	18	\N
127	132	131	19	\N
128	132	131	20	\N
129	132	131	21	\N
130	132	131	22	\N
131	132	131	23	\N
132	132	131	24	\N
133	132	131	25	\N
134	132	131	26	\N
135	132	131	27	\N
136	132	131	28	\N
137	132	131	29	\N
138	132	131	30	\N
139	132	131	31	\N
140	132	131	32	\N
141	132	131	33	\N
142	132	131	34	\N
143	133	132	0	\N
144	134	130	1	\N
145	135	134	0	\N
146	136	135	0	\N
147	136	134	1	\N
148	137	136	0	\N
149	138	136	1	\N
150	139	138	0	\N
151	139	138	1	\N
152	139	126	0	\N
153	139	137	0	\N
154	140	139	0	\N
155	140	139	1	\N
156	141	140	1	\N
157	142	140	0	\N
158	142	141	0	\N
159	142	141	1	\N
160	143	142	0	\N
161	144	143	0	\N
162	145	143	1	\N
288	153	145	75	\N
289	154	145	102	\N
290	155	145	80	\N
291	156	145	67	\N
292	157	145	85	\N
293	158	145	82	\N
294	159	145	88	\N
295	160	145	101	\N
296	161	145	100	\N
297	162	145	70	\N
298	163	154	0	\N
299	163	145	91	\N
300	164	145	107	\N
301	165	153	0	\N
302	165	159	0	\N
303	166	158	1	\N
304	166	157	0	\N
305	167	163	1	\N
306	167	165	1	\N
307	168	148	1	\N
308	169	145	117	\N
309	170	165	0	\N
310	170	145	94	\N
311	171	145	119	\N
312	172	145	84	\N
313	173	145	111	\N
314	174	172	1	\N
315	175	145	89	\N
316	176	163	0	\N
317	176	156	0	\N
318	177	153	1	\N
319	178	175	1	\N
320	179	145	108	\N
321	180	169	1	\N
322	181	145	98	\N
323	182	174	0	\N
324	182	154	1	\N
325	183	180	0	\N
326	183	173	0	\N
327	184	145	116	\N
328	185	181	0	\N
329	185	161	0	\N
330	186	145	99	\N
331	187	145	110	\N
332	188	185	1	\N
333	188	168	1	\N
334	189	145	81	\N
335	190	159	1	\N
336	191	145	68	\N
337	192	147	0	\N
338	193	171	1	\N
339	194	169	0	\N
340	194	172	0	\N
341	195	179	1	\N
342	196	173	1	\N
343	197	151	0	\N
344	198	145	103	\N
345	199	145	61	\N
346	200	199	1	\N
347	200	189	0	\N
223	147	145	0	\N
224	147	145	1	\N
225	147	145	2	\N
226	147	145	3	\N
227	147	145	4	\N
228	147	145	5	\N
229	147	145	6	\N
230	147	145	7	\N
231	147	145	8	\N
232	147	145	9	\N
233	147	145	10	\N
234	147	145	11	\N
235	147	145	12	\N
236	147	145	13	\N
237	147	145	14	\N
238	147	145	15	\N
239	147	145	16	\N
240	147	145	17	\N
241	147	145	18	\N
242	147	145	19	\N
243	147	145	20	\N
244	147	145	21	\N
245	147	145	22	\N
246	147	145	23	\N
247	147	145	24	\N
248	147	145	25	\N
249	147	145	26	\N
250	147	145	27	\N
251	147	145	28	\N
252	147	145	29	\N
253	147	145	30	\N
254	147	145	31	\N
255	147	145	32	\N
256	147	145	33	\N
257	147	145	34	\N
258	147	145	35	\N
259	147	145	36	\N
260	147	145	37	\N
261	147	145	38	\N
262	147	145	39	\N
263	147	145	40	\N
264	147	145	41	\N
265	147	145	42	\N
266	147	145	43	\N
267	147	145	44	\N
268	147	145	45	\N
269	147	145	46	\N
270	147	145	47	\N
271	147	145	48	\N
272	147	145	49	\N
273	147	145	50	\N
274	147	145	51	\N
275	147	145	52	\N
276	147	145	53	\N
277	147	145	54	\N
278	147	145	55	\N
279	147	145	56	\N
280	147	145	57	\N
281	147	145	58	\N
282	147	145	59	\N
283	148	145	97	\N
284	149	142	1	\N
285	150	145	72	\N
286	151	145	73	\N
287	152	145	60	\N
348	201	160	1	\N
349	201	194	1	\N
350	202	145	65	\N
351	203	199	0	\N
352	203	176	1	\N
353	204	145	63	\N
354	205	166	1	\N
355	206	145	113	\N
356	207	179	0	\N
357	207	182	0	\N
358	208	201	1	\N
359	209	186	1	\N
360	210	145	79	\N
361	211	191	0	\N
362	211	197	0	\N
363	212	175	0	\N
364	212	209	0	\N
365	213	193	1	\N
366	214	196	0	\N
367	214	155	0	\N
368	215	183	1	\N
369	215	202	0	\N
370	216	213	0	\N
371	216	198	0	\N
372	217	171	0	\N
373	217	212	0	\N
374	218	145	109	\N
375	219	145	87	\N
376	220	180	1	\N
377	221	181	1	\N
378	222	145	86	\N
379	223	188	1	\N
380	224	201	0	\N
381	224	221	1	\N
382	225	145	71	\N
383	226	186	0	\N
384	226	145	95	\N
385	227	191	1	\N
386	228	212	1	\N
387	228	218	0	\N
388	229	189	1	\N
389	230	207	1	\N
390	230	214	0	\N
391	231	162	1	\N
392	232	187	1	\N
393	233	226	0	\N
394	233	220	0	\N
395	234	220	1	\N
396	235	225	0	\N
397	235	184	1	\N
398	236	227	1	\N
399	237	193	0	\N
400	237	232	0	\N
401	238	235	0	\N
402	238	145	69	\N
403	239	223	1	\N
404	240	156	1	\N
405	241	229	0	\N
406	241	174	1	\N
407	242	185	0	\N
408	242	205	0	\N
409	243	164	0	\N
410	243	236	0	\N
411	244	166	0	\N
412	244	197	1	\N
413	245	224	0	\N
414	245	158	0	\N
415	246	233	1	\N
416	246	240	0	\N
417	247	236	1	\N
418	248	145	115	\N
419	249	215	1	\N
420	249	177	1	\N
421	250	222	0	\N
422	250	187	0	\N
423	251	161	1	\N
424	252	178	0	\N
425	252	243	1	\N
426	253	145	62	\N
427	254	238	0	\N
428	254	238	1	\N
429	254	224	1	\N
430	254	150	1	\N
431	254	234	0	\N
432	254	234	1	\N
433	254	151	1	\N
434	254	246	0	\N
435	254	246	1	\N
436	254	229	1	\N
437	254	228	0	\N
438	254	228	1	\N
439	254	167	0	\N
440	254	167	1	\N
441	254	219	0	\N
442	254	219	1	\N
443	254	213	1	\N
444	254	160	0	\N
445	254	242	0	\N
446	254	242	1	\N
447	254	225	1	\N
448	254	222	1	\N
449	254	237	0	\N
450	254	237	1	\N
451	254	178	1	\N
452	254	227	0	\N
453	254	200	0	\N
454	254	200	1	\N
455	254	196	1	\N
456	254	155	1	\N
457	254	162	0	\N
458	254	157	1	\N
459	254	216	0	\N
460	254	216	1	\N
461	254	245	0	\N
462	254	245	1	\N
463	254	226	1	\N
464	254	194	0	\N
465	254	241	0	\N
466	254	241	1	\N
467	254	149	0	\N
468	254	206	0	\N
469	254	206	1	\N
470	254	250	0	\N
471	254	250	1	\N
472	254	195	0	\N
473	254	195	1	\N
474	254	239	0	\N
475	254	239	1	\N
476	254	235	1	\N
477	254	215	0	\N
478	254	203	0	\N
479	254	203	1	\N
480	254	204	0	\N
481	254	204	1	\N
482	254	249	0	\N
483	254	249	1	\N
484	254	207	0	\N
485	254	182	1	\N
486	254	247	0	\N
487	254	247	1	\N
488	254	253	0	\N
489	254	253	1	\N
490	254	230	0	\N
491	254	230	1	\N
492	254	176	0	\N
493	254	183	0	\N
494	254	164	1	\N
495	254	233	0	\N
496	254	217	0	\N
497	254	217	1	\N
498	254	252	0	\N
499	254	252	1	\N
500	254	168	0	\N
501	254	188	0	\N
502	254	232	1	\N
503	254	214	1	\N
504	254	221	0	\N
505	254	208	0	\N
506	254	208	1	\N
507	254	248	0	\N
508	254	248	1	\N
509	254	184	0	\N
510	254	145	64	\N
511	254	145	66	\N
512	254	145	74	\N
513	254	145	76	\N
514	254	145	77	\N
515	254	145	78	\N
516	254	145	83	\N
517	254	145	90	\N
518	254	145	92	\N
519	254	145	93	\N
520	254	145	96	\N
521	254	145	104	\N
522	254	145	105	\N
523	254	145	106	\N
524	254	145	112	\N
525	254	145	114	\N
526	254	145	118	\N
527	254	223	0	\N
528	254	190	0	\N
529	254	190	1	\N
530	254	192	0	\N
531	254	192	1	\N
532	254	211	0	\N
533	254	211	1	\N
534	254	170	0	\N
535	254	170	1	\N
536	254	251	0	\N
537	254	251	1	\N
538	254	240	1	\N
539	254	198	1	\N
540	254	218	1	\N
541	254	231	0	\N
542	254	231	1	\N
543	254	209	1	\N
544	254	210	0	\N
545	254	210	1	\N
546	254	244	0	\N
547	254	244	1	\N
548	254	202	1	\N
549	254	243	0	\N
550	254	205	1	\N
551	254	152	0	\N
552	254	177	0	\N
553	255	254	0	\N
554	256	254	10	\N
555	257	254	6	\N
556	257	256	0	\N
557	258	254	8	\N
558	259	254	3	\N
559	260	254	12	\N
560	261	255	1	\N
561	262	254	2	\N
562	263	259	0	\N
563	263	262	1	\N
564	264	256	1	\N
565	265	254	1	\N
566	266	257	0	\N
567	266	262	0	\N
568	267	257	1	\N
569	268	264	0	\N
570	268	266	1	\N
571	269	264	1	\N
572	270	254	7	\N
573	271	255	0	\N
574	271	268	0	\N
575	272	261	1	\N
576	272	267	0	\N
577	273	254	9	\N
578	274	273	1	\N
579	275	254	11	\N
580	276	272	1	\N
581	277	274	0	\N
582	277	276	0	\N
583	278	271	0	\N
584	278	273	0	\N
585	279	269	1	\N
586	280	272	0	\N
587	280	265	0	\N
588	281	266	0	\N
589	281	263	0	\N
590	282	260	1	\N
591	283	281	0	\N
592	283	261	0	\N
593	284	254	5	\N
594	284	277	1	\N
595	285	278	0	\N
596	285	277	0	\N
597	286	285	1	\N
598	286	281	1	\N
599	287	275	0	\N
600	287	269	0	\N
601	288	282	0	\N
602	288	270	0	\N
603	289	254	13	\N
604	290	275	1	\N
605	291	283	0	\N
606	291	258	0	\N
607	292	283	1	\N
608	292	290	1	\N
609	293	286	0	\N
610	293	280	1	\N
611	294	254	4	\N
612	295	268	1	\N
613	295	280	0	\N
614	296	289	1	\N
615	297	282	1	\N
616	298	287	1	\N
617	298	279	0	\N
618	299	298	1	\N
619	299	297	1	\N
620	300	265	1	\N
621	301	298	0	\N
622	301	291	0	\N
623	302	294	1	\N
624	303	288	0	\N
625	303	294	0	\N
626	304	300	1	\N
627	305	300	0	\N
628	305	293	0	\N
629	306	259	1	\N
630	306	284	0	\N
631	307	304	1	\N
632	307	271	1	\N
633	308	292	0	\N
634	308	303	0	\N
635	309	304	0	\N
636	309	286	1	\N
637	310	292	1	\N
638	311	289	0	\N
639	311	293	1	\N
640	312	307	1	\N
641	313	288	1	\N
642	313	295	1	\N
643	314	270	1	\N
644	314	301	1	\N
645	315	302	1	\N
646	316	287	0	\N
647	316	290	0	\N
648	317	258	1	\N
649	318	267	1	\N
650	319	315	0	\N
651	319	303	1	\N
652	320	310	1	\N
653	321	296	1	\N
654	322	318	0	\N
655	322	260	0	\N
656	323	318	1	\N
657	324	320	1	\N
658	325	324	1	\N
659	326	324	0	\N
660	326	317	0	\N
661	327	279	1	\N
662	328	308	0	\N
663	328	305	1	\N
664	329	314	1	\N
665	330	327	0	\N
666	330	313	0	\N
667	331	284	1	\N
668	331	319	1	\N
669	332	326	0	\N
670	332	321	0	\N
671	333	331	1	\N
672	333	328	0	\N
673	334	302	0	\N
674	334	322	1	\N
675	335	315	1	\N
676	336	329	1	\N
677	336	311	1	\N
678	337	263	1	\N
679	338	323	0	\N
680	338	299	0	\N
681	339	338	1	\N
682	339	276	1	\N
683	340	274	1	\N
684	341	309	0	\N
685	341	328	1	\N
686	342	336	1	\N
687	343	332	0	\N
688	343	319	0	\N
689	344	278	1	\N
690	344	296	0	\N
691	345	307	0	\N
692	345	333	0	\N
693	346	335	1	\N
694	347	330	1	\N
695	347	313	1	\N
696	348	309	1	\N
697	348	344	1	\N
698	349	345	0	\N
699	349	337	0	\N
700	350	323	1	\N
701	351	345	1	\N
702	351	330	0	\N
703	352	346	1	\N
704	353	312	1	\N
705	354	314	0	\N
706	354	306	0	\N
707	355	285	0	\N
708	356	108	2	\N
709	357	356	1	\N
710	358	357	1	\N
711	359	107	0	\N
712	360	109	0	\N
713	361	360	1	\N
\.


--
-- Data for Name: tx_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_metadata (id, key, json, bytes, tx_id) FROM stdin;
1	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "TestHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "TestHandle", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": "ipfs://some-hash", "website": "https://cardano.org/", "mediaType": "image/jpeg", "description": "The Handle Standard", "augmentations": []}, "HelloHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "HelloHandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "DoubleHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "DoubleHandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a460a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656067776562736974657468747470733a2f2f63617264616e6f2e6f72672f6c446f75626c6548616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656c446f75626c6548616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6b48656c6c6f48616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656b48656c6c6f48616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6a5465737448616e646c65a86d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e646172646566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e7965696d61676570697066733a2f2f736f6d652d68617368696d65646961547970656a696d6167652f6a706567646e616d656a5465737448616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f	109
2	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"NFT-001": {"name": "One", "image": ["ipfs://some_hash1"], "version": "1.0"}, "NFT-002": {"name": "Two", "image": ["ipfs://some_hash2"], "version": "1.0"}, "NFT-files": {"id": "1", "name": "NFT with files", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": ["ipfs://somehash"], "version": "1.0", "mediaType": "image/png", "description": ["NFT with different types of files"]}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a3674e46542d303031a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65634f6e656776657273696f6e63312e30674e46542d303032a365696d6167658171697066733a2f2f736f6d655f6861736832646e616d656354776f6776657273696f6e63312e30694e46542d66696c6573a76b6465736372697074696f6e8178214e4654207769746820646966666572656e74207479706573206f662066696c65736566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e79626964613165696d616765816f697066733a2f2f736f6d6568617368696d656469615479706569696d6167652f706e67646e616d656e4e465420776974682066696c65736776657273696f6e63312e30	111
3	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"4349502d303032352d76312d686578": {"name": "CIP-0025-v1-hex", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1781e343334393530326433303330333233353264373633313264363836353738a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656f4349502d303032352d76312d6865786776657273696f6e63312e30	113
4	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"CIP-0025-v1-utf8": {"name": "CIP-0025-v1-utf8", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1704349502d303032352d76312d75746638a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65704349502d303032352d76312d757466386776657273696f6e63312e30	114
5	721	{"0x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"0x4349502d303032352d7632": {"name": "CIP-0025-v2", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a1581c17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029a14b4349502d303032352d7632a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656b4349502d303032352d76326776657273696f6e63312e30	115
6	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "handle2": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle2", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a26768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f6768616e646c6532a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653267776562736974657468747470733a2f2f63617264616e6f2e6f72672f	117
7	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	122
8	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	123
9	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	125
10	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	127
11	123	"1234"	\\xa1187b6431323334	138
\.


--
-- Data for Name: tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_out (id, tx_id, index, address, address_raw, address_has_script, payment_cred, stake_address_id, value, data_hash, inline_datum_id, reference_script_id) FROM stdin;
1	1	0	5oP9ib6ym3XY9tP3ScbxNKBSFmpBBr2pJgcS2kuBqkTL2Etk5UDAFTEywi6gNFNjS2	\\x82d818582683581c0ba9e4fc2eaf9e564cfc256030e665de24e4cd6162595af3c98e273da10243190378001ae43ec51b	f	\N	\N	910909092	\N	\N	\N
2	2	0	5oP9ib6ym3XZ4yJgjDxm3xoHGmL6JwiDAH9Apkm3yBEuWrzuVERj4wda46VKH8u5T6	\\x82d818582683581c1e157c21790d8e6b1b3365ce3b932ff1fcc197f0c28a49448219434aa10243190378001a51868d89	f	\N	\N	910909092	\N	\N	\N
3	3	0	5oP9ib6ym3Xb2RZjiePuwBYPmj5iuU3b9KQjPKe1pwtt6aeLam5ibibBRkhfXW3woq	\\x82d818582683581c45739db357a4ca8640c14a8e9fac3474ea65378eec4cd6b26710c721a10243190378001a95b23c94	f	\N	\N	910909092	\N	\N	\N
4	4	0	5oP9ib6ym3XbhWB2QXFHBP9SAVBAJQoVz6zygCNRVUL1G4y6FTqtbkv4XMDYzobdCy	\\x82d818582683581c530316260851b6322ebf5cf93f12e44f9f573a2fef2af12db287545ca10243190378001a7f988256	f	\N	\N	910909092	\N	\N	\N
5	5	0	5oP9ib6ym3Xe2vPC4WSPZKYfJmgXXquWWyvw7yFuc4z1ZN6p7jHsrE4w36uRQpMPYo	\\x82d818582683581c82005cbbcadc3cdd604c15d95179a82434ebdb4d039010c870ef3250a10243190378001a367a9bbc	f	\N	\N	910909092	\N	\N	\N
6	6	0	5oP9ib6ym3XgbWdcEHq754kuiHdD8xvRxDh3D99qJXLfEeqe4uPAhSLDQAh2hzu9R5	\\x82d818582683581cb58fd13561c0a6e7284ff993a3a14d3fe6b23a447d9dae6f4db4afdea10243190378001a66400984	f	\N	\N	910909092	\N	\N	\N
7	7	0	5oP9ib6ym3XggEcnNist1kGKRN5Ys718Qd182TiMYo4ZieE2WYSHhjF2e5H7zemGKa	\\x82d818582683581cb733721c1cc9ac7fc03441f35bce07675f29d3c00ba57fa054f037a9a10243190378001ab87863a1	f	\N	\N	910909092	\N	\N	\N
8	8	0	5oP9ib6ym3Xij3mmj5u1TaU625sXxBE1fALtbsiFzyT6gubNpZojf8Lx8ArwLSJYXJ	\\x82d818582683581ce06dbc35a89c177a1aea38b8756c9280311cd81693ea5a2492b09ae7a10243190378001af598b351	f	\N	\N	910909092	\N	\N	\N
9	9	0	5oP9ib6ym3XjWdY1yAnD7fJHi3g1SQbR1mMacngzB6uDoNRN6kLVCvRGUB9u8d6cAL	\\x82d818582683581cf03ed82455d869ae4ddde7107deff5316ae7f83d22509017ed2af589a10243190378001ae9b9cb71	f	\N	\N	910909092	\N	\N	\N
10	10	0	5oP9ib6ym3XjfycoRKMFN4sZaMhbPS4pNuBTByr4PL79QPZQpoYwyUwf8tceV4jJmG	\\x82d818582683581cf37d14f1e89de6671c2492bcd17f56b8200f1e5ab3c2a03ba8f6045fa10243190378001a115b906b	f	\N	\N	910909092	\N	\N	\N
11	11	0	5oP9ib6ym3Xk35Tw13vJFpLat31UMHamVx8VvXLbJjDMKK7mtgK1miWNGsp6eCtYy7	\\x82d818582683581cfacf7d67a148bbfa3cad972d6190bfa986cfd503251b36a8a1ff48efa10243190378001a4b035a9a	f	\N	\N	910909092	\N	\N	\N
12	12	0	addr_test1qzczzmlhqlgsek7z0lytmh58jjkh6r4e2rwh9248q6pw5rcwctfgn802mk25y9yxalf2dagf7wjsmqzu8wvq5yjtd4nsny3k2x	\\x00b0216ff707d10cdbc27fc8bdde8794ad7d0eb950dd72aaa70682ea0f0ec2d2899deadd95421486efd2a6f509f3a50d805c3b980a124b6d67	f	\\xb0216ff707d10cdbc27fc8bdde8794ad7d0eb950dd72aaa70682ea0f	\N	3681818181818181	\N	\N	\N
13	13	0	addr_test1vr5073sgc2l6x7y50tguvzhgz4vnp07j07j25v6ayqjfm5gvmna83	\\x60e8ff4608c2bfa378947ad1c60ae8155930bfd27fa4aa335d20249dd1	f	\\xe8ff4608c2bfa378947ad1c60ae8155930bfd27fa4aa335d20249dd1	\N	3681818181818181	\N	\N	\N
14	14	0	addr_test1vqxp7jlsazqud2jgmgfut7d327y973luhsfuhkeft3w4uyge84ruy	\\x600c1f4bf0e881c6aa48da13c5f9b157885f47fcbc13cbdb295c5d5e11	f	\\x0c1f4bf0e881c6aa48da13c5f9b157885f47fcbc13cbdb295c5d5e11	\N	3681818181818190	\N	\N	\N
15	15	0	addr_test1qpsa09hcjjwh5dsh8mrvqzpgvtsrg9hvdrd5vp0fmafpshr3xjfgn0rp6sq07294ecjjfwwj6hxpnvk6pz8vjlxta5xsaptnq3	\\x0061d796f8949d7a36173ec6c0082862e03416ec68db4605e9df52185c71349289bc61d400ff28b5ce2524b9d2d5cc19b2da088ec97ccbed0d	f	\\x61d796f8949d7a36173ec6c0082862e03416ec68db4605e9df52185c	\N	3681818181818181	\N	\N	\N
16	16	0	addr_test1qp7ufvwrjxxt6mm2t49hejj926usg68alnepu7xhtvjc02yhej9zhltspm6uhs9dqag82mcmslx9mcphr6t0693tu3nqh5f27d	\\x007dc4b1c3918cbd6f6a5d4b7cca4556b90468fdfcf21e78d75b2587a897cc8a2bfd700ef5cbc0ad0750756f1b87cc5de0371e96fd162be466	f	\\x7dc4b1c3918cbd6f6a5d4b7cca4556b90468fdfcf21e78d75b2587a8	\N	3681818181818181	\N	\N	\N
17	17	0	addr_test1vpzgh3qh7mz80gnqchputt2l49xer93aktkx0aanltje4jgwn4x5a	\\x60448bc417f6c477a260c5c3c5ad5fa94d91963db2ec67f7b3fae59ac9	f	\\x448bc417f6c477a260c5c3c5ad5fa94d91963db2ec67f7b3fae59ac9	\N	3681818181818181	\N	\N	\N
18	18	0	addr_test1qrvwlszmdkmv8v00aemepkuqrv4qc8sc34ccj0seswtp4386j2c7jtea9wk0mumf8w588ef0wdg5afpnmzctgagga67qrsq6ms	\\x00d8efc05b6db6c3b1efee7790db801b2a0c1e188d71893e1983961ac4fa92b1e92f3d2bacfdf3693ba873e52f73514ea433d8b0b47508eebc	f	\\xd8efc05b6db6c3b1efee7790db801b2a0c1e188d71893e1983961ac4	\N	3681818181818181	\N	\N	\N
19	19	0	addr_test1qz06laa0e7xk5wv2llvnt7xw4rauk53rxghzg6j4ccgfgrdzplkkxg7fnnccjgq0hwchmcgp4qqg9jhmwlahvfs78h8q4tzz0w	\\x009faff7afcf8d6a398affd935f8cea8fbcb5223322e246a55c610940da20fed6323c99cf189200fbbb17de101a80082cafb77fb76261e3dce	f	\\x9faff7afcf8d6a398affd935f8cea8fbcb5223322e246a55c610940d	\N	3681818181818190	\N	\N	\N
20	20	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681818181818181	\N	\N	\N
21	21	0	addr_test1qqmaeehfch8h8xhxvy5vlsv4lvj63tr6acrppja7g73tqzawycp8vkdx6umy6vgn5jxwsn2wen7075v0ve47prkdg00sh746px	\\x0037dce6e9c5cf739ae66128cfc195fb25a8ac7aee0610cbbe47a2b00bae26027659a6d7364d3113a48ce84d4eccfcff518f666be08ecd43df	f	\\x37dce6e9c5cf739ae66128cfc195fb25a8ac7aee0610cbbe47a2b00b	\N	3681818181818181	\N	\N	\N
22	22	0	addr_test1qpyk0s4ze7jht94vgm6r9d3k6kj6qa3tdv5hjfa40jhuvqv209xhrfg69r0lz9we89zvlzp97v69jucwxfhtnavd3zrq35n9ch	\\x004967c2a2cfa57596ac46f432b636d5a5a0762b6b297927b57cafc6018a794d71a51a28dff115d93944cf8825f33459730e326eb9f58d8886	f	\\x4967c2a2cfa57596ac46f432b636d5a5a0762b6b297927b57cafc601	\N	3681818181818181	\N	\N	\N
23	23	0	addr_test1vqjpd7dk5l4pv3zc2m4ur0mpqk8xfec0xmv8gqzy7p6thkcul6twx	\\x602416f9b6a7ea16445856ebc1bf61058e64e70f36d8740044f074bbdb	f	\\x2416f9b6a7ea16445856ebc1bf61058e64e70f36d8740044f074bbdb	\N	3681818181818181	\N	\N	\N
24	24	0	addr_test1qpltdjyl7qf64yfl6n7wsxcfmkjwmt555zsz50z834s76p5yznvracrt567avs9u87dvfqkag98hwdunz3lzf09apk8qnka89x	\\x007eb6c89ff013aa913fd4fce81b09dda4edae94a0a02a3c478d61ed068414d83ee06ba6bdd640bc3f9ac482dd414f773793147e24bcbd0d8e	f	\\x7eb6c89ff013aa913fd4fce81b09dda4edae94a0a02a3c478d61ed06	\N	3681818181818181	\N	\N	\N
25	25	0	addr_test1vzf6wuu7tqhfujrzhzx2r6grnnyrusdvjzpyusfzh998n7qxpav50	\\x6093a7739e582e9e4862b88ca1e9039cc83e41ac90824e4122b94a79f8	f	\\x93a7739e582e9e4862b88ca1e9039cc83e41ac90824e4122b94a79f8	\N	3681818181818181	\N	\N	\N
26	26	0	addr_test1vp50jv524k5rahc76edqmqeurc6tgqkfcsesfu3re0vcrfcy3lmp4	\\x6068f9328aada83edf1ed65a0d833c1e34b402c9c43304f223cbd981a7	f	\\x68f9328aada83edf1ed65a0d833c1e34b402c9c43304f223cbd981a7	\N	3681818181818181	\N	\N	\N
27	27	0	addr_test1vrusj80gys259lmsgtjzc33fpuy9harf7rf82whu2dsg58q08zyuq	\\x60f9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	f	\\xf9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	\N	3681818181818181	\N	\N	\N
28	28	0	addr_test1qppamws70uh4hcs0hkattvlan549d65uc7yvp25a5q0yfqcuuas42zuzvcut95c6jydj0hmhzcnpcy0cfc9a69tv2g2s5ujajf	\\x0043ddba1e7f2f5be20fbdbab5b3fd9d2a56ea9cc788c0aa9da01e44831ce761550b826638b2d31a911b27df7716261c11f84e0bdd156c5215	f	\\x43ddba1e7f2f5be20fbdbab5b3fd9d2a56ea9cc788c0aa9da01e4483	\N	3681818181818181	\N	\N	\N
29	29	0	addr_test1qzryzg8yrfv3dpptgh2axl4tvy6c3uxf9s2udffy6tzwzzp434vuff3qqs98pw7ggrqwqw3r67d3sxdh29u47kut9vpq9ppk30	\\x00864120e41a5916842b45d5d37eab613588f0c92c15c6a524d2c4e108358d59c4a620040a70bbc840c0e03a23d79b1819b751795f5b8b2b02	f	\\x864120e41a5916842b45d5d37eab613588f0c92c15c6a524d2c4e108	\N	3681818181818181	\N	\N	\N
30	30	0	addr_test1vqp506lg9e2x0t0mfwqk7ystmrn3kj5xtaegykz0sgv3m6gsrq8cq	\\x600347ebe82e5467adfb4b816f120bd8e71b4a865f7282584f82191de9	f	\\x0347ebe82e5467adfb4b816f120bd8e71b4a865f7282584f82191de9	\N	3681818181818181	\N	\N	\N
31	31	0	addr_test1vrlpqqnejeckyr4g76ux930kewh8dqfxn7ns92jkuv24apq7q60ec	\\x60fe1002799671620ea8f6b862c5f6cbae7681269fa702aa56e3155e84	f	\\xfe1002799671620ea8f6b862c5f6cbae7681269fa702aa56e3155e84	\N	3681818181818181	\N	\N	\N
32	32	0	addr_test1vzct4y9zytcsgj9939jmyzh5lfy7wn53kkw8krsxwmpze2s7s0649	\\x60b0ba90a222f10448a58965b20af4fa49e74e91b59c7b0e0676c22caa	f	\\xb0ba90a222f10448a58965b20af4fa49e74e91b59c7b0e0676c22caa	\N	3681818181818181	\N	\N	\N
33	33	0	addr_test1qpns0tgzr40fk5awaxvxlf3vskexwvgtu28x0qan789l2zv63xxf3464fqgyrmx8a69k2aytt0jktvue8vrxdp9ut2csg8eg2h	\\x006707ad021d5e9b53aee9986fa62c85b267310be28e6783b3f1cbf5099a898c98d755481041ecc7ee8b65748b5be565b3993b066684bc5ab1	f	\\x6707ad021d5e9b53aee9986fa62c85b267310be28e6783b3f1cbf509	\N	3681818181818181	\N	\N	\N
34	35	0	addr_test1qzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7m68lwcxudywen8l7apyzqthe552q7zkhaqecpp6zx27aums2pc66n	\\x009714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f47fbb06e348ecccfff742410177cd28a07856bf419c043a1195eef37	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	15	500000000	\N	\N	\N
35	35	1	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681817681651228	\N	\N	\N
36	36	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681817681473231	\N	\N	\N
37	37	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681817681293914	\N	\N	\N
72	66	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681814878327629	\N	\N	\N
38	38	0	addr_test1qpsa09hcjjwh5dsh8mrvqzpgvtsrg9hvdrd5vp0fmafpshr3xjfgn0rp6sq07294ecjjfwwj6hxpnvk6pz8vjlxta5xsaptnq3	\\x0061d796f8949d7a36173ec6c0082862e03416ec68db4605e9df52185c71349289bc61d400ff28b5ce2524b9d2d5cc19b2da088ec97ccbed0d	f	\\x61d796f8949d7a36173ec6c0082862e03416ec68db4605e9df52185c	2	3681818181637632	\N	\N	\N
39	39	0	addr_test1qpsa09hcjjwh5dsh8mrvqzpgvtsrg9hvdrd5vp0fmafpshr3xjfgn0rp6sq07294ecjjfwwj6hxpnvk6pz8vjlxta5xsaptnq3	\\x0061d796f8949d7a36173ec6c0082862e03416ec68db4605e9df52185c71349289bc61d400ff28b5ce2524b9d2d5cc19b2da088ec97ccbed0d	f	\\x61d796f8949d7a36173ec6c0082862e03416ec68db4605e9df52185c	2	3681818181443619	\N	\N	\N
40	40	0	addr_test1qzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mclnv98kqzg06puvwhep6q7fcey2cqpu8eukacur4kqp8ys32pn2z	\\x009714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f1f9b0a7b00487e83c63af90e81e4e32456001e1f3cb771c1d6c009c9	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	13	600000000	\N	\N	\N
41	40	1	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681817081126961	\N	\N	\N
42	41	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681817080948964	\N	\N	\N
43	42	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681817080769647	\N	\N	\N
44	43	0	addr_test1qppamws70uh4hcs0hkattvlan549d65uc7yvp25a5q0yfqcuuas42zuzvcut95c6jydj0hmhzcnpcy0cfc9a69tv2g2s5ujajf	\\x0043ddba1e7f2f5be20fbdbab5b3fd9d2a56ea9cc788c0aa9da01e44831ce761550b826638b2d31a911b27df7716261c11f84e0bdd156c5215	f	\\x43ddba1e7f2f5be20fbdbab5b3fd9d2a56ea9cc788c0aa9da01e4483	9	3681818181637632	\N	\N	\N
45	44	0	addr_test1qppamws70uh4hcs0hkattvlan549d65uc7yvp25a5q0yfqcuuas42zuzvcut95c6jydj0hmhzcnpcy0cfc9a69tv2g2s5ujajf	\\x0043ddba1e7f2f5be20fbdbab5b3fd9d2a56ea9cc788c0aa9da01e44831ce761550b826638b2d31a911b27df7716261c11f84e0bdd156c5215	f	\\x43ddba1e7f2f5be20fbdbab5b3fd9d2a56ea9cc788c0aa9da01e4483	9	3681818181446391	\N	\N	\N
46	45	0	addr_test1qzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mck97j4szrpv4mu3ayh9qhe3wulf5uantzswgr5tpkwnmgsjw432r	\\x009714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f162fa55808616577c8f497282f98bb9f4d39d9ac5072074586ce9ed1	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	20	200000000	\N	\N	\N
47	45	1	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681816880602694	\N	\N	\N
48	46	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681816880424697	\N	\N	\N
49	47	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681816880245380	\N	\N	\N
50	48	0	addr_test1qzryzg8yrfv3dpptgh2axl4tvy6c3uxf9s2udffy6tzwzzp434vuff3qqs98pw7ggrqwqw3r67d3sxdh29u47kut9vpq9ppk30	\\x00864120e41a5916842b45d5d37eab613588f0c92c15c6a524d2c4e108358d59c4a620040a70bbc840c0e03a23d79b1819b751795f5b8b2b02	f	\\x864120e41a5916842b45d5d37eab613588f0c92c15c6a524d2c4e108	10	3681818181637632	\N	\N	\N
51	49	0	addr_test1qzryzg8yrfv3dpptgh2axl4tvy6c3uxf9s2udffy6tzwzzp434vuff3qqs98pw7ggrqwqw3r67d3sxdh29u47kut9vpq9ppk30	\\x00864120e41a5916842b45d5d37eab613588f0c92c15c6a524d2c4e108358d59c4a620040a70bbc840c0e03a23d79b1819b751795f5b8b2b02	f	\\x864120e41a5916842b45d5d37eab613588f0c92c15c6a524d2c4e108	10	3681818181443619	\N	\N	\N
52	50	0	addr_test1qzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mevva90j85zk9gajf4q9vz8s5akqlunv3am0kpfc9pk2zjq6wtysh	\\x009714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f2c674af91e82b151d926a02b047853b607f93647bb7d829c143650a4	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	17	500000000	\N	\N	\N
53	50	1	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681816380078427	\N	\N	\N
54	51	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681816379900430	\N	\N	\N
55	52	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681816379721113	\N	\N	\N
56	53	0	addr_test1qrvwlszmdkmv8v00aemepkuqrv4qc8sc34ccj0seswtp4386j2c7jtea9wk0mumf8w588ef0wdg5afpnmzctgagga67qrsq6ms	\\x00d8efc05b6db6c3b1efee7790db801b2a0c1e188d71893e1983961ac4fa92b1e92f3d2bacfdf3693ba873e52f73514ea433d8b0b47508eebc	f	\\xd8efc05b6db6c3b1efee7790db801b2a0c1e188d71893e1983961ac4	4	3681818181637632	\N	\N	\N
57	54	0	addr_test1qrvwlszmdkmv8v00aemepkuqrv4qc8sc34ccj0seswtp4386j2c7jtea9wk0mumf8w588ef0wdg5afpnmzctgagga67qrsq6ms	\\x00d8efc05b6db6c3b1efee7790db801b2a0c1e188d71893e1983961ac4fa92b1e92f3d2bacfdf3693ba873e52f73514ea433d8b0b47508eebc	f	\\xd8efc05b6db6c3b1efee7790db801b2a0c1e188d71893e1983961ac4	4	3681818181443619	\N	\N	\N
58	55	0	addr_test1qzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mmjs7gdp2twmqx3nhyxfqj3ymsl6n2e9xt44429wg4glxasruz00r	\\x009714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f728790d0a96ed80d19dc864825126e1fd4d5929975ad545722a8f9bb	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	18	500000000	\N	\N	\N
59	55	1	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681815879554160	\N	\N	\N
60	56	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681815879376163	\N	\N	\N
61	57	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681815879196846	\N	\N	\N
62	58	0	addr_test1qpltdjyl7qf64yfl6n7wsxcfmkjwmt555zsz50z834s76p5yznvracrt567avs9u87dvfqkag98hwdunz3lzf09apk8qnka89x	\\x007eb6c89ff013aa913fd4fce81b09dda4edae94a0a02a3c478d61ed068414d83ee06ba6bdd640bc3f9ac482dd414f773793147e24bcbd0d8e	f	\\x7eb6c89ff013aa913fd4fce81b09dda4edae94a0a02a3c478d61ed06	8	3681818181637632	\N	\N	\N
63	59	0	addr_test1qpltdjyl7qf64yfl6n7wsxcfmkjwmt555zsz50z834s76p5yznvracrt567avs9u87dvfqkag98hwdunz3lzf09apk8qnka89x	\\x007eb6c89ff013aa913fd4fce81b09dda4edae94a0a02a3c478d61ed068414d83ee06ba6bdd640bc3f9ac482dd414f773793147e24bcbd0d8e	f	\\x7eb6c89ff013aa913fd4fce81b09dda4edae94a0a02a3c478d61ed06	8	3681818181443619	\N	\N	\N
64	60	0	addr_test1qzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7muv6ra69sm07ddzqxj8mr8plx9upgt4z6l02wdagfqmyknqa5mwnd	\\x009714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f8cd0fba2c36ff35a201a47d8ce1f98bc0a17516bef539bd4241b25a6	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	16	500000000	\N	\N	\N
65	60	1	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681815379029893	\N	\N	\N
66	61	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681815378851896	\N	\N	\N
67	62	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681815378672579	\N	\N	\N
68	63	0	addr_test1qzczzmlhqlgsek7z0lytmh58jjkh6r4e2rwh9248q6pw5rcwctfgn802mk25y9yxalf2dagf7wjsmqzu8wvq5yjtd4nsny3k2x	\\x00b0216ff707d10cdbc27fc8bdde8794ad7d0eb950dd72aaa70682ea0f0ec2d2899deadd95421486efd2a6f509f3a50d805c3b980a124b6d67	f	\\xb0216ff707d10cdbc27fc8bdde8794ad7d0eb950dd72aaa70682ea0f	1	3681818181637632	\N	\N	\N
69	64	0	addr_test1qzczzmlhqlgsek7z0lytmh58jjkh6r4e2rwh9248q6pw5rcwctfgn802mk25y9yxalf2dagf7wjsmqzu8wvq5yjtd4nsny3k2x	\\x00b0216ff707d10cdbc27fc8bdde8794ad7d0eb950dd72aaa70682ea0f0ec2d2899deadd95421486efd2a6f509f3a50d805c3b980a124b6d67	f	\\xb0216ff707d10cdbc27fc8bdde8794ad7d0eb950dd72aaa70682ea0f	1	3681818181443619	\N	\N	\N
70	65	0	addr_test1qzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7me0metsasvcvu75afpz3mjy7s4z3mjxts7qd0a8c2r2n3uq797yah	\\x009714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f2fde570ec198673d4ea4228ee44f42a28ee465c3c06bfa7c286a9c78	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	14	500000000	\N	\N	\N
71	65	1	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681814878505626	\N	\N	\N
73	67	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681814878148312	\N	\N	\N
74	68	0	addr_test1qpyk0s4ze7jht94vgm6r9d3k6kj6qa3tdv5hjfa40jhuvqv209xhrfg69r0lz9we89zvlzp97v69jucwxfhtnavd3zrq35n9ch	\\x004967c2a2cfa57596ac46f432b636d5a5a0762b6b297927b57cafc6018a794d71a51a28dff115d93944cf8825f33459730e326eb9f58d8886	f	\\x4967c2a2cfa57596ac46f432b636d5a5a0762b6b297927b57cafc601	7	3681818181637632	\N	\N	\N
75	69	0	addr_test1qpyk0s4ze7jht94vgm6r9d3k6kj6qa3tdv5hjfa40jhuvqv209xhrfg69r0lz9we89zvlzp97v69jucwxfhtnavd3zrq35n9ch	\\x004967c2a2cfa57596ac46f432b636d5a5a0762b6b297927b57cafc6018a794d71a51a28dff115d93944cf8825f33459730e326eb9f58d8886	f	\\x4967c2a2cfa57596ac46f432b636d5a5a0762b6b297927b57cafc601	7	3681818181443619	\N	\N	\N
76	70	0	addr_test1qzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7makupxjhh40kgepv6vwyqgejmwfcrvqkk9dxtxryfcqzh7q5sefgz	\\x009714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6fb6e04d2bdeafb23216698e2011996dc9c0d80b58ad32cc32270015fc	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	21	300000000	\N	\N	\N
77	70	1	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681814577981359	\N	\N	\N
78	71	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681814577803362	\N	\N	\N
79	72	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681814577624045	\N	\N	\N
80	73	0	addr_test1qp7ufvwrjxxt6mm2t49hejj926usg68alnepu7xhtvjc02yhej9zhltspm6uhs9dqag82mcmslx9mcphr6t0693tu3nqh5f27d	\\x007dc4b1c3918cbd6f6a5d4b7cca4556b90468fdfcf21e78d75b2587a897cc8a2bfd700ef5cbc0ad0750756f1b87cc5de0371e96fd162be466	f	\\x7dc4b1c3918cbd6f6a5d4b7cca4556b90468fdfcf21e78d75b2587a8	3	3681818181637632	\N	\N	\N
81	74	0	addr_test1qp7ufvwrjxxt6mm2t49hejj926usg68alnepu7xhtvjc02yhej9zhltspm6uhs9dqag82mcmslx9mcphr6t0693tu3nqh5f27d	\\x007dc4b1c3918cbd6f6a5d4b7cca4556b90468fdfcf21e78d75b2587a897cc8a2bfd700ef5cbc0ad0750756f1b87cc5de0371e96fd162be466	f	\\x7dc4b1c3918cbd6f6a5d4b7cca4556b90468fdfcf21e78d75b2587a8	3	3681818181446391	\N	\N	\N
82	75	0	addr_test1qp7ufvwrjxxt6mm2t49hejj926usg68alnepu7xhtvjc02yhej9zhltspm6uhs9dqag82mcmslx9mcphr6t0693tu3nqh5f27d	\\x007dc4b1c3918cbd6f6a5d4b7cca4556b90468fdfcf21e78d75b2587a897cc8a2bfd700ef5cbc0ad0750756f1b87cc5de0371e96fd162be466	f	\\x7dc4b1c3918cbd6f6a5d4b7cca4556b90468fdfcf21e78d75b2587a8	3	3681818181265842	\N	\N	\N
83	76	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681814577439800	\N	\N	\N
84	77	0	addr_test1qzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccqzg0mq7rztjxs9r549npapkm32w952xaqccke3n6zeqqfnv0t9	\\x009714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f180090fd83c312e4681474a9661e86db8a9c5a28dd06316cc67a1640	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	22	300000000	\N	\N	\N
85	77	1	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681814277272847	\N	\N	\N
86	78	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681814277094850	\N	\N	\N
87	79	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681814276915533	\N	\N	\N
88	80	0	addr_test1qpns0tgzr40fk5awaxvxlf3vskexwvgtu28x0qan789l2zv63xxf3464fqgyrmx8a69k2aytt0jktvue8vrxdp9ut2csg8eg2h	\\x006707ad021d5e9b53aee9986fa62c85b267310be28e6783b3f1cbf5099a898c98d755481041ecc7ee8b65748b5be565b3993b066684bc5ab1	f	\\x6707ad021d5e9b53aee9986fa62c85b267310be28e6783b3f1cbf509	11	3681818181637632	\N	\N	\N
89	81	0	addr_test1qpns0tgzr40fk5awaxvxlf3vskexwvgtu28x0qan789l2zv63xxf3464fqgyrmx8a69k2aytt0jktvue8vrxdp9ut2csg8eg2h	\\x006707ad021d5e9b53aee9986fa62c85b267310be28e6783b3f1cbf5099a898c98d755481041ecc7ee8b65748b5be565b3993b066684bc5ab1	f	\\x6707ad021d5e9b53aee9986fa62c85b267310be28e6783b3f1cbf509	11	3681818181446391	\N	\N	\N
90	82	0	addr_test1qpns0tgzr40fk5awaxvxlf3vskexwvgtu28x0qan789l2zv63xxf3464fqgyrmx8a69k2aytt0jktvue8vrxdp9ut2csg8eg2h	\\x006707ad021d5e9b53aee9986fa62c85b267310be28e6783b3f1cbf5099a898c98d755481041ecc7ee8b65748b5be565b3993b066684bc5ab1	f	\\x6707ad021d5e9b53aee9986fa62c85b267310be28e6783b3f1cbf509	11	3681818181265842	\N	\N	\N
91	83	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681814276731288	\N	\N	\N
92	84	0	addr_test1qzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7muayg7h6mgz4wxx5ggn6gxen4d3w4m54sawdt4jjqunu7kq5kurzp	\\x009714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f9d223d7d6d02ab8c6a2113d20d99d5b175774ac3ae6aeb290393e7ac	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	12	500000000	\N	\N	\N
93	84	1	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681813776564335	\N	\N	\N
94	85	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681813776386338	\N	\N	\N
95	86	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681813776207021	\N	\N	\N
96	87	0	addr_test1qqmaeehfch8h8xhxvy5vlsv4lvj63tr6acrppja7g73tqzawycp8vkdx6umy6vgn5jxwsn2wen7075v0ve47prkdg00sh746px	\\x0037dce6e9c5cf739ae66128cfc195fb25a8ac7aee0610cbbe47a2b00bae26027659a6d7364d3113a48ce84d4eccfcff518f666be08ecd43df	f	\\x37dce6e9c5cf739ae66128cfc195fb25a8ac7aee0610cbbe47a2b00b	6	3681818181637632	\N	\N	\N
97	88	0	addr_test1qqmaeehfch8h8xhxvy5vlsv4lvj63tr6acrppja7g73tqzawycp8vkdx6umy6vgn5jxwsn2wen7075v0ve47prkdg00sh746px	\\x0037dce6e9c5cf739ae66128cfc195fb25a8ac7aee0610cbbe47a2b00bae26027659a6d7364d3113a48ce84d4eccfcff518f666be08ecd43df	f	\\x37dce6e9c5cf739ae66128cfc195fb25a8ac7aee0610cbbe47a2b00b	6	3681818181443575	\N	\N	\N
98	89	0	addr_test1qqmaeehfch8h8xhxvy5vlsv4lvj63tr6acrppja7g73tqzawycp8vkdx6umy6vgn5jxwsn2wen7075v0ve47prkdg00sh746px	\\x0037dce6e9c5cf739ae66128cfc195fb25a8ac7aee0610cbbe47a2b00bae26027659a6d7364d3113a48ce84d4eccfcff518f666be08ecd43df	f	\\x37dce6e9c5cf739ae66128cfc195fb25a8ac7aee0610cbbe47a2b00b	6	3681818181263026	\N	\N	\N
99	90	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681813776022776	\N	\N	\N
100	91	0	addr_test1qzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mcd4ua2p845909ut4y2y49mk87efn7syytv49hqgnegx3wq5q4c0k	\\x009714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f0daf3aa09eb42bcbc5d48a254bbb1fd94cfd02116ca96e044f28345c	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	19	500000000	\N	\N	\N
101	91	1	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681813275855823	\N	\N	\N
102	92	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681813275677826	\N	\N	\N
103	93	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681813275498509	\N	\N	\N
104	94	0	addr_test1qz06laa0e7xk5wv2llvnt7xw4rauk53rxghzg6j4ccgfgrdzplkkxg7fnnccjgq0hwchmcgp4qqg9jhmwlahvfs78h8q4tzz0w	\\x009faff7afcf8d6a398affd935f8cea8fbcb5223322e246a55c610940da20fed6323c99cf189200fbbb17de101a80082cafb77fb76261e3dce	f	\\x9faff7afcf8d6a398affd935f8cea8fbcb5223322e246a55c610940d	5	3681818181637641	\N	\N	\N
105	95	0	addr_test1qz06laa0e7xk5wv2llvnt7xw4rauk53rxghzg6j4ccgfgrdzplkkxg7fnnccjgq0hwchmcgp4qqg9jhmwlahvfs78h8q4tzz0w	\\x009faff7afcf8d6a398affd935f8cea8fbcb5223322e246a55c610940da20fed6323c99cf189200fbbb17de101a80082cafb77fb76261e3dce	f	\\x9faff7afcf8d6a398affd935f8cea8fbcb5223322e246a55c610940d	5	3681818181443584	\N	\N	\N
106	96	0	addr_test1qz06laa0e7xk5wv2llvnt7xw4rauk53rxghzg6j4ccgfgrdzplkkxg7fnnccjgq0hwchmcgp4qqg9jhmwlahvfs78h8q4tzz0w	\\x009faff7afcf8d6a398affd935f8cea8fbcb5223322e246a55c610940da20fed6323c99cf189200fbbb17de101a80082cafb77fb76261e3dce	f	\\x9faff7afcf8d6a398affd935f8cea8fbcb5223322e246a55c610940d	5	3681818181263035	\N	\N	\N
107	97	0	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3681813275314264	\N	\N	\N
108	98	0	addr_test1wpnlxv2xv9a9ucvnvzqakwepzl9ltx7jzgm53av2e9ncv4sysemm8	\\x7067f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	t	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	\N	100000000	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	\N	\N
109	98	1	addr_test1vrusj80gys259lmsgtjzc33fpuy9harf7rf82whu2dsg58q08zyuq	\\x60f9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	f	\\xf9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	\N	3681818081650832	\N	\N	\N
110	99	0	addr_test1vrusj80gys259lmsgtjzc33fpuy9harf7rf82whu2dsg58q08zyuq	\\x60f9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	f	\\xf9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	\N	99828910	\N	\N	\N
111	100	0	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	\\x702618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	100000000	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	2	\N
112	100	1	addr_test1vrusj80gys259lmsgtjzc33fpuy9harf7rf82whu2dsg58q08zyuq	\\x60f9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	f	\\xf9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	\N	3681817981484759	\N	\N	\N
113	101	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	2
114	101	1	addr_test1vrusj80gys259lmsgtjzc33fpuy9harf7rf82whu2dsg58q08zyuq	\\x60f9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	f	\\xf9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	\N	3681817881314374	\N	\N	\N
115	102	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	3
116	102	1	addr_test1vrusj80gys259lmsgtjzc33fpuy9harf7rf82whu2dsg58q08zyuq	\\x60f9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	f	\\xf9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	\N	3681817781146585	\N	\N	\N
117	103	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	1
118	103	1	addr_test1vrusj80gys259lmsgtjzc33fpuy9harf7rf82whu2dsg58q08zyuq	\\x60f9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	f	\\xf9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	\N	3681817680979940	\N	\N	\N
119	104	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	4
120	104	1	addr_test1vrusj80gys259lmsgtjzc33fpuy9harf7rf82whu2dsg58q08zyuq	\\x60f9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	f	\\xf9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	\N	3681817580717067	\N	\N	\N
121	105	0	addr_test1wzem0yuxjqyrmzvrsr8xfqhumyy555ngyjxw7wrg2pav90q8cagu2	\\x70b3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	t	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	\N	100000000	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	3	\N
122	105	1	addr_test1vrusj80gys259lmsgtjzc33fpuy9harf7rf82whu2dsg58q08zyuq	\\x60f9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	f	\\xf9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	\N	3681817480550950	\N	\N	\N
123	106	0	addr_test1vrusj80gys259lmsgtjzc33fpuy9harf7rf82whu2dsg58q08zyuq	\\x60f9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	f	\\xf9091de8241542ff7042e42c46290f085bf469f0d2753afc53608a1c	\N	3681817580223603	\N	\N	\N
124	107	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\N	\N	\N
125	107	1	addr_test1vrlpqqnejeckyr4g76ux930kewh8dqfxn7ns92jkuv24apq7q60ec	\\x60fe1002799671620ea8f6b862c5f6cbae7681269fa702aa56e3155e84	f	\\xfe1002799671620ea8f6b862c5f6cbae7681269fa702aa56e3155e84	\N	3681818171642252	\N	\N	\N
126	108	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000000000	\N	\N	\N
127	108	1	addr_test1qrml5hwl9s7ydm2djyup95ud6s74skkl4zzf8zk657s8thgm78sn3uhch64ujc7ffnpga68dfdqhg3sp7tk6759jrm7spy03k9	\\x00f7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd1bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	f	\\xf7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd	47	5000000000000	\N	\N	\N
128	108	2	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	5000000000000	\N	\N	\N
129	108	3	addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k	\\x00594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	f	\\x594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0	49	5000000000000	\N	\N	\N
130	108	4	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	5000000000000	\N	\N	\N
131	108	5	addr_test1vzt3fmxa7wz55kcdt6nysx2pctxsrxauwtmsdlymmk2v7mccgwxpu	\\x609714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	f	\\x9714ecddf3854a5b0d5ea6481941c2cd019bbc72f706fc9bdd94cf6f	\N	3656813275134639	\N	\N	\N
132	109	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\N	\N	\N
133	109	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999989767575	\N	\N	\N
134	110	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\\x81cb2989cbf6c49840511d8d3451ee44f58dde2c074fc749d05deb51eeb33741	4	\N
135	110	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999979582758	\N	\N	\N
136	111	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
137	111	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999969378581	\N	\N	\N
138	112	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
139	112	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999969198164	\N	\N	\N
140	113	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
141	113	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999969006879	\N	\N	\N
142	114	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
143	114	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999958817706	\N	\N	\N
144	115	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
145	115	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999958628313	\N	\N	\N
146	116	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999978448908	\N	\N	\N
147	117	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
148	117	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999976244643	\N	\N	\N
149	118	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	2000000	\N	\N	\N
150	118	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999976070958	\N	\N	\N
151	119	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	2000000	\N	\N	\N
152	119	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999973900705	\N	\N	\N
153	120	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999973727196	\N	\N	\N
154	121	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	1826667	\N	\N	\N
155	122	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
156	122	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999971534195	\N	\N	\N
157	123	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
158	123	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999971337762	\N	\N	\N
159	124	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999973162669	\N	\N	\N
160	125	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
161	125	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999970969668	\N	\N	\N
162	126	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1826667	\N	\N	\N
163	127	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
164	127	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999968776667	\N	\N	\N
165	128	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1824819	\N	\N	\N
166	129	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1651486	\N	\N	\N
167	130	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	1000000000	\N	\N	\N
168	130	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998970258164	\N	\N	\N
169	131	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	99693655	\N	\N	\N
170	131	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	100000000	\N	\N	\N
171	131	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	100000000	\N	\N	\N
172	131	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	100000000	\N	\N	\N
173	131	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	100000000	\N	\N	\N
174	131	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	50000000	\N	\N	\N
175	131	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	50000000	\N	\N	\N
176	131	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	50000000	\N	\N	\N
177	131	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	50000000	\N	\N	\N
178	131	9	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	50000000	\N	\N	\N
179	131	10	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	25000000	\N	\N	\N
180	131	11	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	25000000	\N	\N	\N
181	131	12	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	25000000	\N	\N	\N
182	131	13	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	25000000	\N	\N	\N
183	131	14	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	25000000	\N	\N	\N
184	131	15	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	12500000	\N	\N	\N
185	131	16	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	12500000	\N	\N	\N
186	131	17	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	12500000	\N	\N	\N
187	131	18	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	12500000	\N	\N	\N
188	131	19	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	12500000	\N	\N	\N
189	131	20	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	6250000	\N	\N	\N
190	131	21	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	6250000	\N	\N	\N
191	131	22	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	6250000	\N	\N	\N
192	131	23	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	6250000	\N	\N	\N
193	131	24	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	6250000	\N	\N	\N
194	131	25	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	3125000	\N	\N	\N
195	131	26	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	3125000	\N	\N	\N
196	131	27	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	3125000	\N	\N	\N
197	131	28	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	3125000	\N	\N	\N
198	131	29	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	3125000	\N	\N	\N
199	131	30	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	3125000	\N	\N	\N
200	131	31	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	3125000	\N	\N	\N
201	131	32	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	3125000	\N	\N	\N
202	131	33	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	3125000	\N	\N	\N
203	131	34	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	3125000	\N	\N	\N
204	132	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	499604371	\N	\N	\N
205	132	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	249923414	\N	\N	\N
206	132	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	124961707	\N	\N	\N
207	132	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	62480853	\N	\N	\N
208	132	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	31240427	\N	\N	\N
209	132	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	15620213	\N	\N	\N
210	132	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	7810107	\N	\N	\N
211	132	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	3905053	\N	\N	\N
212	132	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	3905053	\N	\N	\N
213	133	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	499402614	\N	\N	\N
214	134	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
215	134	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998967080431	\N	\N	\N
216	135	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2826843	\N	\N	\N
217	136	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
218	136	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998966721665	\N	\N	\N
219	137	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2820771	\N	\N	\N
220	138	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	969750	\N	\N	\N
221	138	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998965581662	\N	\N	\N
222	139	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999382719310	\N	\N	\N
223	139	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999588306207	\N	\N	\N
224	140	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999382719310	\N	\N	\N
225	140	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999588136042	\N	\N	\N
226	141	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
227	141	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999582967637	\N	\N	\N
228	142	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998966186947	\N	\N	\N
229	142	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4328427	\N	\N	\N
230	143	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
231	143	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998961018542	\N	\N	\N
232	145	0	addr_test1qrlazutpq3jesu269paysc2rr9umpnhg42gkpxdnyyll368xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs5jkk8n	\\x00ffd17161046598715a287a4861431979b0cee8aa916099b3213ff8e8e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xffd17161046598715a287a4861431979b0cee8aa916099b3213ff8e8	61	3000000	\N	\N	\N
233	145	1	addr_test1qq7vkldrfr5mkqs47hdw0x497szgp9l58eeq8rg30qv9ah0xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs3s08q3	\\x003ccb7da348e9bb0215f5dae79aa5f4048097f43e72038d1178185edde692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x3ccb7da348e9bb0215f5dae79aa5f4048097f43e72038d1178185edd	61	3000000	\N	\N	\N
234	145	2	addr_test1qz3hclnda66wfxsmguanruntj063n3upx55pj5myaay9gclxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vseptgp3	\\x00a37c7e6deeb4e49a1b473b31f26b93f519c7813528195364ef485463e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xa37c7e6deeb4e49a1b473b31f26b93f519c7813528195364ef485463	61	3000000	\N	\N	\N
235	145	3	addr_test1qqfmymgferyfwjjlufgh7dzn0ull7juhcm0w8l3uukt4ul8xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsn95wmv	\\x0013b26d09c8c8974a5fe2517f34537f3fff4b97c6dee3fe3ce5975e7ce692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x13b26d09c8c8974a5fe2517f34537f3fff4b97c6dee3fe3ce5975e7c	61	3000000	\N	\N	\N
236	145	4	addr_test1qz9ka4c29x5jp97ujl22shfmj8uayt7p9fl7x2259tsagq8xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vswkv9yw	\\x008b6ed70a29a92097dc97d4a85d3b91f9d22fc12a7fe329542ae1d400e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x8b6ed70a29a92097dc97d4a85d3b91f9d22fc12a7fe329542ae1d400	61	3000000	\N	\N	\N
237	145	5	addr_test1qqtg7clxa7ee3r224d45q9sw5gx033l30e80eeafppvzl6hxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsn6quvf	\\x00168f63e6efb3988d4aab6b40160ea20cf8c7f17e4efce7a908582feae692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x168f63e6efb3988d4aab6b40160ea20cf8c7f17e4efce7a908582fea	61	3000000	\N	\N	\N
238	145	6	addr_test1qz8y2cwmz9lm5y4el6uymrtvf5wqgw0p2v2qt73ue6xsxkhxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsras6g7	\\x008e4561db117fba12b9feb84d8d6c4d1c0439e1531405fa3cce8d035ae692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x8e4561db117fba12b9feb84d8d6c4d1c0439e1531405fa3cce8d035a	61	3000000	\N	\N	\N
239	145	7	addr_test1qr7lfwd3rrldhgjr00xy874ppn2sc068ply6vna5cjytauhxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs0r34fn	\\x00fdf4b9b118fedba2437bcc43faa10cd50c3f470fc9a64fb4c488bef2e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xfdf4b9b118fedba2437bcc43faa10cd50c3f470fc9a64fb4c488bef2	61	3000000	\N	\N	\N
240	145	8	addr_test1qpw3qtgmacctv26uemjwyf7a377d35y9nsc7hk4scq5ajj0xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs4xvfnt	\\x005d102d1bee30b62b5ccee4e227dd8fbcd8d0859c31ebdab0c029d949e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x5d102d1bee30b62b5ccee4e227dd8fbcd8d0859c31ebdab0c029d949	61	3000000	\N	\N	\N
241	145	9	addr_test1qrgg8t6rcudyqvvn6fy22u38xvaan6wk4scsnrv2e59v0e8xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs9tyfcq	\\x00d083af43c71a403193d248a57227333bd9e9d6ac31098d8acd0ac7e4e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xd083af43c71a403193d248a57227333bd9e9d6ac31098d8acd0ac7e4	61	3000000	\N	\N	\N
242	145	10	addr_test1qpxk4w7hn6es4n06d6k9flkf8k4fr3r5llkkg4sykzxpzm8xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsx8rkjg	\\x004d6abbd79eb30acdfa6eac54fec93daa91c474ffed645604b08c116ce692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x4d6abbd79eb30acdfa6eac54fec93daa91c474ffed645604b08c116c	61	3000000	\N	\N	\N
243	145	11	addr_test1qqpz5w6mjxq5vk3mtnzgnffledla9zlf9h2gzlg6c8cm958xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsv494t9	\\x00022a3b5b9181465a3b5cc489a53fcb7fd28be92dd4817d1ac1f1b2d0e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x022a3b5b9181465a3b5cc489a53fcb7fd28be92dd4817d1ac1f1b2d0	61	3000000	\N	\N	\N
244	145	12	addr_test1qq0dqed48nkc95jf3v4rq7jldzecvsun9d50g9pkmeymgm0xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsyzljsv	\\x001ed065b53ced82d2498b2a307a5f68b38643932b68f41436de49b46de692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x1ed065b53ced82d2498b2a307a5f68b38643932b68f41436de49b46d	61	3000000	\N	\N	\N
245	145	13	addr_test1qzjms7lds7kjctktmh2l5ctje29kdtt50fv2t28e47uup90xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs0g8u5l	\\x00a5b87bed87ad2c2ecbddd5fa6172ca8b66ad747a58a5a8f9afb9c095e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xa5b87bed87ad2c2ecbddd5fa6172ca8b66ad747a58a5a8f9afb9c095	61	3000000	\N	\N	\N
246	145	14	addr_test1qzu5jgd408nzqvvdkumz0vcyaek9mfywex8m6d9jgyfrwl8xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs0q5xz9	\\x00b94921b579e620318db73627b304ee6c5da48ec98fbd34b24112377ce692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xb94921b579e620318db73627b304ee6c5da48ec98fbd34b24112377c	61	3000000	\N	\N	\N
247	145	15	addr_test1qpyprallc40mq3ledu04xkpe652g9cqkwtgzfuu9zu80quhxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs3kxx9f	\\x004811f7ffc55fb047f96f1f535839d51482e01672d024f385170ef072e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x4811f7ffc55fb047f96f1f535839d51482e01672d024f385170ef072	61	3000000	\N	\N	\N
248	145	16	addr_test1qzaecwpyhnnfd4r0yc779kmzsrnjq0jcs9ac8csd0c03wq0xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsruckyd	\\x00bb9c3824bce696d46f263de2db6280e7203e58817b83e20d7e1f1701e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xbb9c3824bce696d46f263de2db6280e7203e58817b83e20d7e1f1701	61	3000000	\N	\N	\N
249	145	17	addr_test1qpu74u7ygq384cffzlpq5juxy56fdqvcqm844qsvrlaqfxhxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsap6q9r	\\x0079eaf3c440227ae12917c20a4b86253496819806cf5a820c1ffa049ae692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x79eaf3c440227ae12917c20a4b86253496819806cf5a820c1ffa049a	61	3000000	\N	\N	\N
250	145	18	addr_test1qzuflf45d0m95cc72mj27nl5lv4nah3m08989k44mknj0nlxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vstca8kf	\\x00b89fa6b46bf65a631e56e4af4ff4fb2b3ede3b79ca72dab5dda727cfe692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xb89fa6b46bf65a631e56e4af4ff4fb2b3ede3b79ca72dab5dda727cf	61	3000000	\N	\N	\N
251	145	19	addr_test1qph259qf0u5npyxge4yl6jy2s8d93q4dns4mx2trrm9twwlxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsfzd46h	\\x006eaa14097f293090c8cd49fd488a81da5882ad9c2bb329631ecab73be692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x6eaa14097f293090c8cd49fd488a81da5882ad9c2bb329631ecab73b	61	3000000	\N	\N	\N
252	145	20	addr_test1qzh3xcdr3t8l89c0kff0le3fx3vvy4d2yd4ct2cgw9gv6nhxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs2zd0y5	\\x00af1361a38acff3970fb252ffe6293458c255aa236b85ab087150cd4ee692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xaf1361a38acff3970fb252ffe6293458c255aa236b85ab087150cd4e	61	3000000	\N	\N	\N
253	145	21	addr_test1qptp5uhrnxxx736xxrte28wtsjpzfavke35675ayjkwfj98xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vskzy3vs	\\x00561a72e3998c6f474630d7951dcb848224f596cc69af53a4959c9914e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x561a72e3998c6f474630d7951dcb848224f596cc69af53a4959c9914	61	3000000	\N	\N	\N
254	145	22	addr_test1qpdgzfxjg0r2rxgp2js53cygnr8fwh67njeukdv2lkfm8ehxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsy6vm4k	\\x005a8124d243c6a1990154a148e08898ce975f5e9cb3cb358afd93b3e6e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x5a8124d243c6a1990154a148e08898ce975f5e9cb3cb358afd93b3e6	61	3000000	\N	\N	\N
255	145	23	addr_test1qprpx2fah38mu2s287re7d0277kzj5cjvp8anh5xnaqplt8xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsrjl833	\\x004613293dbc4fbe2a0a3f879f35eaf7ac295312604fd9de869f401face692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x4613293dbc4fbe2a0a3f879f35eaf7ac295312604fd9de869f401fac	61	3000000	\N	\N	\N
256	145	24	addr_test1qp0lplf9hd2vujs323hrjcaav78hxrqu436jv6elnw64ds8xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsc8m89t	\\x005ff0fd25bb54ce4a11546e3963bd678f730c1cac75266b3f9bb556c0e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x5ff0fd25bb54ce4a11546e3963bd678f730c1cac75266b3f9bb556c0	61	3000000	\N	\N	\N
257	145	25	addr_test1qrst6xkthqsd349ejvaas38pxpts36caz3fw5ehmne94p48xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vswxcun7	\\x00e0bd1acbb820d8d4b9933bd844e1305708eb1d1452ea66fb9e4b50d4e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xe0bd1acbb820d8d4b9933bd844e1305708eb1d1452ea66fb9e4b50d4	61	3000000	\N	\N	\N
258	145	26	addr_test1qq2l9nd02ehfxwl2ktvrk5t5zgepktelmfde99mqvcsa5a0xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vshuz4xq	\\x0015f2cdaf566e933beab2d83b517412321b2f3fda5b9297606621da75e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x15f2cdaf566e933beab2d83b517412321b2f3fda5b9297606621da75	61	3000000	\N	\N	\N
259	145	27	addr_test1qpcejhsnsv8lm2swaen3kaguqpyr658aurlk4dv2jh9lrghxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsunk98h	\\x0071995e13830ffdaa0eee671b751c00483d50fde0ff6ab58a95cbf1a2e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x71995e13830ffdaa0eee671b751c00483d50fde0ff6ab58a95cbf1a2	61	3000000	\N	\N	\N
260	145	28	addr_test1qr6j6fy7t3wt87cu62yy628vl2gf30lzqzcgvffq75gslalxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsnkznxj	\\x00f52d249e5c5cb3fb1cd2884d28ecfa9098bfe200b0862520f5110ff7e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xf52d249e5c5cb3fb1cd2884d28ecfa9098bfe200b0862520f5110ff7	61	3000000	\N	\N	\N
261	145	29	addr_test1qr49ur2er986alt03n2je7zaaeck2gr005w32sq6wpjcce0xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs3aquct	\\x00ea5e0d59194faefd6f8cd52cf85dee7165206f7d1d15401a70658c65e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xea5e0d59194faefd6f8cd52cf85dee7165206f7d1d15401a70658c65	61	3000000	\N	\N	\N
262	145	30	addr_test1qqsudxj8mq0xlupslxwp36fwppf24hlctdjfqj6cm5gwxa8xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsdtrttz	\\x0021c69a47d81e6ff030f99c18e92e0852aadff85b64904b58dd10e374e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x21c69a47d81e6ff030f99c18e92e0852aadff85b64904b58dd10e374	61	3000000	\N	\N	\N
263	145	31	addr_test1qr734hdmyyhtvqjz33cd6mfzgxfgg0w8sdmlcpda49lt5whxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsrua63h	\\x00fd1addbb212eb602428c70dd6d224192843dc78377fc05bda97eba3ae692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xfd1addbb212eb602428c70dd6d224192843dc78377fc05bda97eba3a	61	3000000	\N	\N	\N
264	145	32	addr_test1qr689kzgpfa75w5qsjz3rzrxwzsdldjwgvk4t8349spe9k0xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsppr560	\\x00f472d8480a7bea3a80848511886670a0dfb64e432d559e352c0392d9e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xf472d8480a7bea3a80848511886670a0dfb64e432d559e352c0392d9	61	3000000	\N	\N	\N
265	145	33	addr_test1qp9wgmue06ju9n4ewnae3jg5yn9ukt3vhy3s3ree280aaalxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs0zazjg	\\x004ae46f997ea5c2ceb974fb98c91424cbcb2e2cb923088f3951dfdef7e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x4ae46f997ea5c2ceb974fb98c91424cbcb2e2cb923088f3951dfdef7	61	3000000	\N	\N	\N
266	145	34	addr_test1qz8q054392w86x86ug7vx5tlcmal8rf7w0drqjt5pleecjhxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsv23m9n	\\x008e07d2b12a9c7d18fae23cc3517fc6fbf38d3e73da3049740ff39c4ae692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x8e07d2b12a9c7d18fae23cc3517fc6fbf38d3e73da3049740ff39c4a	61	3000000	\N	\N	\N
267	145	35	addr_test1qqtw8z46dndpwx283psyldwhkvulnz83vlz579r7g3g3fclxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsm7un30	\\x0016e38aba6cda17194788604fb5d7b339f988f167c54f147e445114e3e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x16e38aba6cda17194788604fb5d7b339f988f167c54f147e445114e3	61	3000000	\N	\N	\N
268	145	36	addr_test1qqau7lrcyklf8rf8acn3lmpg504el7fqtmcjrq5yhg90pu0xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsn0843h	\\x003bcf7c7825be938d27ee271fec28a3eb9ff9205ef1218284ba0af0f1e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x3bcf7c7825be938d27ee271fec28a3eb9ff9205ef1218284ba0af0f1	61	3000000	\N	\N	\N
269	145	37	addr_test1qr45cvdq557draugtuvrzgwj4yznunrxvcccjdxwkt49vl0xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsze0u7g	\\x00eb4c31a0a53cd1f7885f183121d2a9053e4c6666318934ceb2ea567de692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xeb4c31a0a53cd1f7885f183121d2a9053e4c6666318934ceb2ea567d	61	3000000	\N	\N	\N
270	145	38	addr_test1qzwwhvpsdnnn2ee4xws40pv2w2hu6eurqewhtd6h8pwgrslxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsh8y0v7	\\x009cebb0306ce735673533a157858a72afcd6783065d75b757385c81c3e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x9cebb0306ce735673533a157858a72afcd6783065d75b757385c81c3	61	3000000	\N	\N	\N
271	145	39	addr_test1qzyhvulzw2rfnwdlkjyckyhfj7nu59slqy0rhl65skg8408xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vstkkh0k	\\x00897673e2728699b9bfb4898b12e997a7ca161f011e3bff5485907abce692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x897673e2728699b9bfb4898b12e997a7ca161f011e3bff5485907abc	61	3000000	\N	\N	\N
272	145	40	addr_test1qpr77mvm00xmpm85qyfwens2nmpkt8ky6ksx30y298vksvlxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsl6kexu	\\x0047ef6d9b7bcdb0ecf40112ecce0a9ec3659ec4d5a068bc8a29d96833e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x47ef6d9b7bcdb0ecf40112ecce0a9ec3659ec4d5a068bc8a29d96833	61	3000000	\N	\N	\N
273	145	41	addr_test1qphsxq6yhdn66na3992r5jsf99a8pl8nal0l033t4akc32hxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsj5ckv6	\\x006f030344bb67ad4fb129543a4a09297a70fcf3efdff7c62baf6d88aae692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x6f030344bb67ad4fb129543a4a09297a70fcf3efdff7c62baf6d88aa	61	3000000	\N	\N	\N
274	145	42	addr_test1qrrvuvp3lvnzs79c0urwu0dnu6qssqes6mqc5yandvkj3u8xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vszdxczr	\\x00c6ce3031fb262878b87f06ee3db3e681080330d6c18a13b36b2d28f0e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xc6ce3031fb262878b87f06ee3db3e681080330d6c18a13b36b2d28f0	61	3000000	\N	\N	\N
275	145	43	addr_test1qz0zp4eqv6v2hmm2fszrxm6t0sew5qxj3elf9r6nntefy5lxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsftfvy4	\\x009e20d7206698abef6a4c04336f4b7c32ea00d28e7e928f539af29253e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x9e20d7206698abef6a4c04336f4b7c32ea00d28e7e928f539af29253	61	3000000	\N	\N	\N
276	145	44	addr_test1qqd6wekjek64xpk9rzcn2tnvaj2frr9wz2ylgl3a4zasfy0xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs442jhc	\\x001ba766d2cdb55306c518b1352e6cec94918cae1289f47e3da8bb0491e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x1ba766d2cdb55306c518b1352e6cec94918cae1289f47e3da8bb0491	61	3000000	\N	\N	\N
277	145	45	addr_test1qphdchah7u7ns4qyl3at8rftenw5653lkg835hcjfqwq3x0xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsv48mfj	\\x006edc5fb7f73d385404fc7ab38d2bccdd4d523fb20f1a5f12481c0899e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x6edc5fb7f73d385404fc7ab38d2bccdd4d523fb20f1a5f12481c0899	61	3000000	\N	\N	\N
278	145	46	addr_test1qr8k4qguhj2y0lvkypvrdq4kxspctp5dlekugh3yup7g49hxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs29hu7d	\\x00cf6a811cbc9447fd9620583682b6340385868dfe6dc45e24e07c8a96e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xcf6a811cbc9447fd9620583682b6340385868dfe6dc45e24e07c8a96	61	3000000	\N	\N	\N
279	145	47	addr_test1qrjfucdw0a66yr4f6zjd65s9e2cfynvwkkp8xan8207h3qhxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsh7pa5w	\\x00e49e61ae7f75a20ea9d0a4dd5205cab0924d8eb58273766753fd7882e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xe49e61ae7f75a20ea9d0a4dd5205cab0924d8eb58273766753fd7882	61	3000000	\N	\N	\N
280	145	48	addr_test1qr93pakkn6sa2xgs33ydcaucla22qsupu3slslf0d2hjdlhxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsfnphxs	\\x00cb10f6d69ea1d519108c48dc7798ff54a04381e461f87d2f6aaf26fee692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xcb10f6d69ea1d519108c48dc7798ff54a04381e461f87d2f6aaf26fe	61	3000000	\N	\N	\N
281	145	49	addr_test1qrucwvurv6q276u9h4qy9ce4mmjfqnnsupz0w0a7s55p9w0xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs20gq7p	\\x00f98733836680af6b85bd4042e335dee4904e70e044f73fbe852812b9e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xf98733836680af6b85bd4042e335dee4904e70e044f73fbe852812b9	61	3000000	\N	\N	\N
282	145	50	addr_test1qru5p7ec0ee77k6qnqzjw0jynw6nxnf8gckqe0nd9f0tl7lxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vspt2zhp	\\x00f940fb387e73ef5b409805273e449bb5334d27462c0cbe6d2a5ebffbe692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xf940fb387e73ef5b409805273e449bb5334d27462c0cbe6d2a5ebffb	61	3000000	\N	\N	\N
283	145	51	addr_test1qp09zcd8ar3pxtumyy85kdxwgpw6vh36alcm7eanfd9dej8xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsr7g4tw	\\x005e5161a7e8e2132f9b210f4b34ce405da65e3aeff1bf67b34b4adcc8e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x5e5161a7e8e2132f9b210f4b34ce405da65e3aeff1bf67b34b4adcc8	61	3000000	\N	\N	\N
284	145	52	addr_test1qzt5rfnkwlqqx0nkyr5ul7xq7pjh3m227cxz67sdfvafqjlxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsx3yqv7	\\x009741a67677c0033e7620e9cff8c0f06578ed4af60c2d7a0d4b3a904be692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x9741a67677c0033e7620e9cff8c0f06578ed4af60c2d7a0d4b3a904b	61	3000000	\N	\N	\N
285	145	53	addr_test1qpd87fclrl9vsj7wz04lgle8fds7dv30tef26h9fzf5d9whxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs6glsy8	\\x005a7f271f1fcac84bce13ebf47f274b61e6b22f5e52ad5ca91268d2bae692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x5a7f271f1fcac84bce13ebf47f274b61e6b22f5e52ad5ca91268d2ba	61	3000000	\N	\N	\N
286	145	54	addr_test1qpzg2pf890a56spcp0p58fm8e7f8s308ydvyt0vr7e9p368xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsshd052	\\x00448505272bfb4d40380bc343a767cf927845e7235845bd83f64a18e8e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x448505272bfb4d40380bc343a767cf927845e7235845bd83f64a18e8	61	3000000	\N	\N	\N
287	145	55	addr_test1qqu6dv2lf4zf9vs0ulr99qazm5w6jvytexn6tv72j5xesuhxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs0lgpwk	\\x0039a6b15f4d4492b20fe7c65283a2dd1da9308bc9a7a5b3ca950d9872e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x39a6b15f4d4492b20fe7c65283a2dd1da9308bc9a7a5b3ca950d9872	61	3000000	\N	\N	\N
288	145	56	addr_test1qphxrlefx3ywdr0guhlfjc7k738ezq6m3gl9e3f94usymclxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vspqtyqs	\\x006e61ff293448e68de8e5fe9963d6f44f91035b8a3e5cc525af204de3e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x6e61ff293448e68de8e5fe9963d6f44f91035b8a3e5cc525af204de3	61	3000000	\N	\N	\N
289	145	57	addr_test1qq4k4sxs4t930dgclmcl6jaj7526we6tkv2zkq78g4ge0j0xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vskx0s3r	\\x002b6ac0d0aacb17b518fef1fd4bb2f515a7674bb3142b03c7455197c9e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x2b6ac0d0aacb17b518fef1fd4bb2f515a7674bb3142b03c7455197c9	61	3000000	\N	\N	\N
290	145	58	addr_test1qzn94vkldgdny2r4d6gc0u4a4eep8e5j0ywm8hqa0jes7n0xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsjk02qe	\\x00a65ab2df6a1b3228756e9187f2bdae7213e692791db3dc1d7cb30f4de692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xa65ab2df6a1b3228756e9187f2bdae7213e692791db3dc1d7cb30f4d	61	3000000	\N	\N	\N
291	145	59	addr_test1qp2xycag6n6ymhawdx0yrrvjf0wjjx9thmr833g8estrlllxjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vsld0624	\\x00546263a8d4f44ddfae699e418d924bdd2918abbec678c507cc163fffe692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\x546263a8d4f44ddfae699e418d924bdd2918abbec678c507cc163fff	61	3000000	\N	\N	\N
292	145	60	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	97372235101	\N	\N	\N
293	145	61	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
294	145	62	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
295	145	63	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
296	145	64	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
297	145	65	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
298	145	66	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
299	145	67	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
300	145	68	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
301	145	69	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
302	145	70	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
303	145	71	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
304	145	72	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
305	145	73	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
306	145	74	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
307	145	75	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
308	145	76	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
309	145	77	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
310	145	78	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
311	145	79	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
312	145	80	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
313	145	81	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
314	145	82	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
315	145	83	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
316	145	84	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
317	145	85	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
318	145	86	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
319	145	87	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
320	145	88	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
321	145	89	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
322	145	90	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
323	145	91	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
324	145	92	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
325	145	93	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
326	145	94	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
327	145	95	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
328	145	96	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
329	145	97	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
330	145	98	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
331	145	99	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
332	145	100	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
333	145	101	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
334	145	102	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
335	145	103	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
336	145	104	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
337	145	105	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
338	145	106	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
339	145	107	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
340	145	108	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
341	145	109	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
342	145	110	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
343	145	111	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
344	145	112	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
345	145	113	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
346	145	114	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
347	145	115	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
348	145	116	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
349	145	117	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
350	145	118	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
351	145	119	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074716392	\N	\N	\N
354	147	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	178500000	\N	\N	\N
355	147	1	addr_test1qrlazutpq3jesu269paysc2rr9umpnhg42gkpxdnyyll368xjtjyxgc2ufeqfxq4pm72j805smcyp2dpmg7fhkvqs8vs5jkk8n	\\x00ffd17161046598715a287a4861431979b0cee8aa916099b3213ff8e8e692e443230ae2720498150efca91df486f040a9a1da3c9bd98081d9	f	\\xffd17161046598715a287a4861431979b0cee8aa916099b3213ff8e8	61	974447	\N	\N	\N
356	148	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	1000000	\N	\N	\N
357	148	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073539099	\N	\N	\N
358	149	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4157030	\N	\N	\N
359	150	0	5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg	\\x82d818582683581c599d72b5e3f5a40fb4c4eb809e904d101f908a419472f542bc7032b9a10243190378001a2a94baa3	f	\N	\N	3000000	\N	\N	\N
360	150	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83071548339	\N	\N	\N
361	151	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
362	151	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064547943	\N	\N	\N
363	152	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	97372060668	\N	\N	\N
364	153	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
365	153	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
366	154	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
367	154	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
368	155	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
369	155	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
370	156	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
371	156	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
372	157	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
373	157	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
374	158	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
375	158	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
376	159	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
377	159	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
378	160	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
379	160	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
380	161	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
381	161	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
382	162	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
383	162	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
384	163	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
385	163	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074546359	\N	\N	\N
386	164	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
387	164	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
388	165	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
389	165	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
390	166	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
391	166	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069377954	\N	\N	\N
392	167	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
393	167	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074206557	\N	\N	\N
394	168	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
395	168	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068370694	\N	\N	\N
396	169	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
397	169	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
398	170	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
399	170	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074546359	\N	\N	\N
400	171	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
401	171	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
402	172	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
403	172	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
404	173	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
405	173	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
406	174	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
407	174	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
408	175	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
409	175	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
410	176	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
411	176	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
412	177	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
413	177	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
414	178	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
415	178	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
416	179	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
417	179	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
418	180	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
419	180	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
420	181	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
421	181	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
422	182	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
423	182	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069377954	\N	\N	\N
424	183	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
425	183	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
426	184	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
427	184	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
428	185	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
429	185	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
430	186	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
431	186	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
432	187	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
433	187	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
434	188	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
435	188	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068030892	\N	\N	\N
436	189	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
437	189	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
438	190	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
439	190	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
440	191	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
441	191	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
442	192	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
443	192	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	173331771	\N	\N	\N
444	193	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
445	193	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
446	194	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
447	194	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
448	195	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
449	195	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
450	196	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
451	196	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
452	197	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
453	197	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4831771	\N	\N	\N
454	198	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
455	198	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
456	199	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
457	199	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
458	200	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
459	200	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069377954	\N	\N	\N
460	201	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
461	201	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069208141	\N	\N	\N
462	202	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
463	202	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
464	203	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
465	203	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
466	204	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
467	204	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
468	205	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
469	205	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064209549	\N	\N	\N
470	206	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
471	206	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
472	207	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
473	207	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
474	208	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
475	208	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064039736	\N	\N	\N
476	209	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
477	209	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
478	210	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
479	210	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
480	211	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
481	211	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
482	212	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
483	212	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
484	213	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
485	213	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83059211133	\N	\N	\N
486	214	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
487	214	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
488	215	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
489	215	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
490	216	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
491	216	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
492	217	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
493	217	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
494	218	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
495	218	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
496	219	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
497	219	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
498	220	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
499	220	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83059211133	\N	\N	\N
500	221	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
501	221	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
502	222	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
503	222	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
504	223	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
505	223	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83062862487	\N	\N	\N
506	224	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
507	224	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064209549	\N	\N	\N
508	225	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
509	225	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
510	226	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
511	226	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074546359	\N	\N	\N
512	227	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
513	227	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
514	228	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
515	228	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
516	229	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
517	229	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
518	230	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
519	230	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
520	231	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
521	231	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
522	232	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
523	232	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
524	233	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
525	233	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
526	234	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
527	234	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83054042728	\N	\N	\N
528	235	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
529	235	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069377954	\N	\N	\N
530	236	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
531	236	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83059211133	\N	\N	\N
532	237	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
533	237	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
534	238	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
535	238	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074546359	\N	\N	\N
536	239	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
537	239	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83057694082	\N	\N	\N
538	240	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
539	240	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
540	241	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
541	241	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064209549	\N	\N	\N
542	242	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
543	242	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
544	243	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
545	243	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
546	244	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
547	244	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4661958	\N	\N	\N
548	245	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
549	245	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
550	246	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
551	246	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
552	247	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
553	247	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83054042728	\N	\N	\N
554	248	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
555	248	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069547943	\N	\N	\N
556	249	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
557	249	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063869923	\N	\N	\N
558	250	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
559	250	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
560	251	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
561	251	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064379538	\N	\N	\N
562	252	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
563	252	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
564	253	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
565	253	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	95080675427	\N	\N	\N
566	254	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1252737720597	\N	\N	\N
567	254	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	1252738133070	\N	\N	\N
568	254	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	626369066535	\N	\N	\N
569	254	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	626369066535	\N	\N	\N
570	254	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	313184533267	\N	\N	\N
571	254	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	313184533267	\N	\N	\N
572	254	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156592266634	\N	\N	\N
573	254	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	156592266634	\N	\N	\N
574	254	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78296133317	\N	\N	\N
575	254	9	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	78296133317	\N	\N	\N
576	254	10	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39148066658	\N	\N	\N
577	254	11	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39148066658	\N	\N	\N
578	254	12	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39148066658	\N	\N	\N
579	254	13	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39148066658	\N	\N	\N
580	255	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
581	255	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1266733393036	\N	\N	\N
582	256	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
583	256	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39142898253	\N	\N	\N
584	257	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
585	257	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156592096645	\N	\N	\N
586	258	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
587	258	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78290964912	\N	\N	\N
588	259	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
589	259	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	626363898130	\N	\N	\N
590	260	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
591	260	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39142898253	\N	\N	\N
592	261	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
593	261	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1266728224631	\N	\N	\N
594	262	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
595	262	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	626363898130	\N	\N	\N
596	263	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
597	263	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	626363728141	\N	\N	\N
598	264	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
599	264	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39137729848	\N	\N	\N
600	265	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
601	265	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1252732964665	\N	\N	\N
602	266	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
603	266	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
604	267	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
605	267	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156586928240	\N	\N	\N
606	268	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
607	268	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
608	269	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
609	269	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39132561443	\N	\N	\N
610	270	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
611	270	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156587098229	\N	\N	\N
612	271	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
613	271	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
614	272	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
615	272	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1266728054642	\N	\N	\N
616	273	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
617	273	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78290964912	\N	\N	\N
618	274	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
619	274	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78285796507	\N	\N	\N
620	275	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
621	275	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39142898253	\N	\N	\N
622	276	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
623	276	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1266722886237	\N	\N	\N
624	277	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
625	277	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
626	278	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
627	278	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
628	279	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
629	279	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39127393038	\N	\N	\N
630	280	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
631	280	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
632	281	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
633	281	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
634	282	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
635	282	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39137729848	\N	\N	\N
636	283	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
637	283	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
638	284	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
639	284	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	313184193465	\N	\N	\N
640	285	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
641	285	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
642	286	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
643	286	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
644	287	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
645	287	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
646	288	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
647	288	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
648	289	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
649	289	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39142898253	\N	\N	\N
650	290	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
651	290	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39137729848	\N	\N	\N
652	291	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
653	291	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
654	292	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
655	292	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39137390046	\N	\N	\N
656	293	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
657	293	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
658	294	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
659	294	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	313179364862	\N	\N	\N
660	295	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
661	295	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
662	296	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
663	296	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39137729848	\N	\N	\N
664	297	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
665	297	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39132561443	\N	\N	\N
666	298	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
667	298	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
668	299	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
669	299	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39132051828	\N	\N	\N
670	300	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
671	300	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1252727796260	\N	\N	\N
672	301	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
673	301	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
674	302	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
675	302	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	313174196457	\N	\N	\N
676	303	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
677	303	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
678	304	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
679	304	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1252722627855	\N	\N	\N
680	305	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
681	305	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
682	306	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
683	306	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	626363728141	\N	\N	\N
684	307	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
685	307	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1252722288053	\N	\N	\N
686	308	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
687	308	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
688	309	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
689	309	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
690	310	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
691	310	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39132221641	\N	\N	\N
692	311	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
693	311	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
694	312	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
695	312	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1252717119648	\N	\N	\N
696	313	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
697	313	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4150935	\N	\N	\N
698	314	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
699	314	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156586758427	\N	\N	\N
700	315	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
701	315	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	313169028052	\N	\N	\N
702	316	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
703	316	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
704	317	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
705	317	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78285796507	\N	\N	\N
706	318	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
707	318	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156581759835	\N	\N	\N
708	319	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
709	319	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
710	320	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
711	320	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39127053236	\N	\N	\N
712	321	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
713	321	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39132561443	\N	\N	\N
714	322	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
715	322	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
716	323	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
717	323	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156576591430	\N	\N	\N
718	324	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
719	324	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39121884831	\N	\N	\N
720	325	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
721	325	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39116716426	\N	\N	\N
722	326	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
723	326	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
724	327	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
725	327	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39122224633	\N	\N	\N
726	328	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
727	328	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
728	329	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
729	329	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156581590022	\N	\N	\N
730	330	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
731	330	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
732	331	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
733	331	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	313183683850	\N	\N	\N
734	332	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
735	332	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
736	333	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
737	333	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	313183513861	\N	\N	\N
738	334	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
739	334	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
740	335	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
741	335	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	313163859647	\N	\N	\N
742	336	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
743	336	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156580910594	\N	\N	\N
744	337	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
745	337	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	626358559736	\N	\N	\N
746	338	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
747	338	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
748	339	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
749	339	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1266722546435	\N	\N	\N
750	340	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
751	340	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78280628102	\N	\N	\N
752	341	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
753	341	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
754	342	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
755	342	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156575742189	\N	\N	\N
756	343	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
757	343	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
758	344	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
759	344	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
760	345	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
761	345	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
762	346	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
763	346	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	313158691242	\N	\N	\N
764	347	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
765	347	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3811309	\N	\N	\N
766	348	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
767	348	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3811309	\N	\N	\N
768	349	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
769	349	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
770	350	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
771	350	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156571423025	\N	\N	\N
772	351	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
773	351	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
774	352	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
775	352	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	313153522837	\N	\N	\N
776	353	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
777	353	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1252711951243	\N	\N	\N
778	354	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
779	354	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
780	355	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
781	355	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	16335493971	\N	\N	\N
782	356	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
783	356	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999996820111	\N	\N	\N
784	357	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
785	357	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999993650122	\N	\N	\N
786	358	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
787	358	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999990474369	\N	\N	\N
788	359	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
789	359	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	6816723	\N	\N	\N
790	360	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
791	360	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	6827019	\N	\N	\N
792	361	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
793	361	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3648274	\N	\N	\N
\.


--
-- Data for Name: withdrawal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.withdrawal (id, addr_id, amount, redeemer_id, tx_id) FROM stdin;
1	46	12011133776	\N	253
2	46	14000847136	\N	255
3	64	4779264674	\N	355
4	46	11556410198	\N	355
\.


--
-- Name: ada_pots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ada_pots_id_seq', 13, true);


--
-- Name: block_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.block_id_seq', 1358, true);


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

SELECT pg_catalog.setval('public.cost_model_id_seq', 13, true);


--
-- Name: datum_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.datum_id_seq', 4, true);


--
-- Name: delegation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delegation_id_seq', 52, true);


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

SELECT pg_catalog.setval('public.epoch_param_id_seq', 13, true);


--
-- Name: epoch_stake_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_stake_id_seq', 296, true);


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

SELECT pg_catalog.setval('public.ma_tx_mint_id_seq', 36, true);


--
-- Name: ma_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_out_id_seq', 46, true);


--
-- Name: meta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meta_id_seq', 1, true);


--
-- Name: multi_asset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.multi_asset_id_seq', 18, true);


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

SELECT pg_catalog.setval('public.reverse_index_id_seq', 1356, true);


--
-- Name: reward_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reward_id_seq', 243, true);


--
-- Name: schema_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schema_version_id_seq', 1, true);


--
-- Name: script_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.script_id_seq', 8, true);


--
-- Name: slot_leader_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slot_leader_id_seq', 1358, true);


--
-- Name: stake_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_address_id_seq', 67, true);


--
-- Name: stake_deregistration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_deregistration_id_seq', 1, true);


--
-- Name: stake_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_registration_id_seq', 32, true);


--
-- Name: treasury_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.treasury_id_seq', 1, false);


--
-- Name: tx_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_id_seq', 361, true);


--
-- Name: tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_in_id_seq', 713, true);


--
-- Name: tx_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_metadata_id_seq', 11, true);


--
-- Name: tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_out_id_seq', 793, true);


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

